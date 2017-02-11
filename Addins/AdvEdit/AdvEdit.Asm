;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include AdvEdit.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD
	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret
DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx esi edi,hWin:DWORD,fOpt:DWORD
	LOCAL	mnui:MENUITEMINFO

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	invoke CreatePopupMenu
	mov		hMnu,eax
	;Edit menu
	mov		edx,1
	;Adjust topmost popup if maximized.
	mov		eax,[lpData]
	.if [eax].ADDINDATA.fMaximized
		inc		edx
	.endif
	;Get handle of edit popup
	mov		eax,[lpHandles]
	invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,edx		;Edit menu
	push	eax
	;Add our menuitem
	invoke AppendMenu,eax,MF_POPUP or MF_STRING,hMnu,addr EditMenu
	mov		edi,offset IDAddIn
	; Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov		[edi],eax
	add		edi,4
	mov		mnui.cbSize,sizeof MENUITEMINFO
	mov		mnui.fMask,MIIM_ID
	mov		mnui.wID,eax
	pop		eax
	push	eax
	invoke GetMenuItemCount,eax
	lea		ecx,[eax-1]
	pop		edx
	invoke SetMenuItemInfo,edx,ecx,TRUE,addr mnui
	mov		esi,offset MenuItems
	.while byte ptr [esi]
		; Allocate a new menu id
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		[edi],eax
		;Add our menuitem
		invoke AppendMenu,hMnu,MF_STRING,[edi],esi
		add		edi,4
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
	.endw
	; Messages to hook into
	mov		eax,RAM_COMMAND or RAM_CLOSE
	mov		ecx,RAM_ADDINSLOADED
	; EDX must be null before we return
	xor		edx,edx
	ret

InstallDll Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	chrgtmp:CHARRANGE
	LOCAL	chrg:CHARRANGE
	LOCAL	mnui:MENUITEMINFO
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		ebx,lpHandles
		mov		ebx,[ebx].ADDINHANDLES.hEdit
		.if ebx
			mov		eax,wParam
			movzx	edx,ax
			shr		eax,16
			.if eax==BN_CLICKED
				.if edx==IDAddIn[4]
					;Get current path
					invoke GetParent,ebx
					mov		edx,eax
					invoke GetWindowText,edx,addr buffer,sizeof buffer
					.while eax
						dec		eax
						.break .if buffer[eax]=='\'
					.endw
					mov		buffer[eax],0
					invoke SendMessage,ebx,EM_REPLACESEL,TRUE,addr buffer
				.elseif edx==IDAddIn[8]
					;Copy all
					invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
					mov		chrgtmp.cpMin,0
					mov		chrgtmp.cpMax,-1
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrgtmp
					invoke SendMessage,ebx,WM_COPY,0,0
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrg
				.elseif edx==IDAddIn[12]
					;Copy current line
					invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ebx,EM_LINEFROMCHAR,chrg.cpMin,0
					push	eax
					invoke SendMessage,ebx,EM_LINEINDEX,eax,0
					mov		chrgtmp.cpMin,eax
					pop		eax
					inc		eax
					invoke SendMessage,ebx,EM_LINEINDEX,eax,0
					.if eax==chrgtmp.cpMin
						mov		eax,-1
					.endif
					mov		chrgtmp.cpMax,eax
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrgtmp
					invoke SendMessage,ebx,WM_COPY,0,0
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,ebx,EM_SCROLLCARET,0,0
				.elseif edx==IDAddIn[16]
					;Delete current line
					invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ebx,EM_LINEFROMCHAR,chrg.cpMin,0
					push	eax
					invoke SendMessage,ebx,EM_LINEINDEX,eax,0
					mov		chrg.cpMin,eax
					pop		eax
					inc		eax
					invoke SendMessage,ebx,EM_LINEINDEX,eax,0
					.if eax==chrg.cpMin
						mov		eax,-1
					.endif
					mov		chrg.cpMax,eax
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrg
					mov		buffer,0
					invoke SendMessage,ebx,EM_REPLACESEL,TRUE,addr buffer
				.elseif edx==IDAddIn[20]
					;Select current line
					invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ebx,EM_LINEFROMCHAR,chrg.cpMin,0
					push	eax
					invoke SendMessage,ebx,EM_LINEINDEX,eax,0
					mov		chrg.cpMin,eax
					pop		eax
					inc		eax
					invoke SendMessage,ebx,EM_LINEINDEX,eax,0
					.if eax==chrg.cpMin
						mov		eax,-1
					.endif
					mov		chrg.cpMax,eax
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrg
				.elseif edx==IDAddIn[24]
					;Delete to start of line
					invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ebx,EM_LINEFROMCHAR,chrg.cpMin,0
					invoke SendMessage,ebx,EM_LINEINDEX,eax,0
					mov		chrg.cpMin,eax
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrg
					mov		buffer,0
					invoke SendMessage,ebx,EM_REPLACESEL,TRUE,addr buffer
				.elseif edx==IDAddIn[28]
					;Delete to end of line
					invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ebx,EM_LINEFROMCHAR,chrg.cpMin,0
					push	eax
					invoke SendMessage,ebx,EM_LINEINDEX,eax,0
					mov		chrgtmp.cpMin,eax
					pop		eax
					inc		eax
					invoke SendMessage,ebx,EM_LINEINDEX,eax,0
					.if eax==chrgtmp.cpMin
						mov		eax,-1
					.else
						dec		eax
					.endif
					mov		chrgtmp.cpMax,eax
					mov		eax,chrg.cpMin
					mov		chrgtmp.cpMin,eax
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrgtmp
					mov		buffer,0
					invoke SendMessage,ebx,EM_REPLACESEL,TRUE,addr buffer
				.elseif edx==IDAddIn[32]
					;Delete to start of word
					invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ebx,EM_FINDWORDBREAK,WB_MOVEWORDLEFT,chrg.cpMin
					.if eax && eax==chrg.cpMin
						dec		eax
					.endif
					mov		chrg.cpMin,eax
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrg
					mov		buffer,0
					invoke SendMessage,ebx,EM_REPLACESEL,TRUE,addr buffer
				.elseif edx==IDAddIn[36]
					;Delete to end of word
					invoke SendMessage,ebx,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,ebx,EM_FINDWORDBREAK,WB_MOVEWORDRIGHT,chrg.cpMin
					.if eax==chrg.cpMin
						inc		eax
					.endif
					mov		chrg.cpMax,eax
					invoke SendMessage,ebx,EM_EXSETSEL,0,addr chrg
					mov		buffer,0
					invoke SendMessage,ebx,EM_REPLACESEL,TRUE,addr buffer
				.endif
			.endif
		.endif
	.elseif eax==AIM_CLOSE
		.if hMnu
			;Remove the menu we added
			mov		eax,[lpHandles]
			mov		ebx,[eax].ADDINHANDLES.hMenu
			;Edit menu
			mov		edx,1
			;Adjust topmost popup if maximized.
			mov		eax,[lpData]
			.if [eax].ADDINDATA.fMaximized
				inc		edx
			.endif
			;Get handle of edit popup
			mov		eax,[lpHandles]
			invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,edx		;Edit menu
			mov		ebx,eax
			xor		eax,eax
			.while eax<64
				push	eax
				invoke GetSubMenu,ebx,eax
				.if eax==hMnu
					pop		eax
					invoke DeleteMenu,ebx,eax,MF_BYPOSITION
					.break
				.endif
				pop		eax
				inc		eax
			.endw
			mov		hMnu,0
			invoke RtlZeroMemory,addr IDAddIn,sizeof IDAddIn
		.endif
	.elseif eax==AIM_ADDINSLOADED
		;Language translate the menu items
		push	edi
		mov		ebx,offset EditMenu
		mov		edi,2000
		mov		ebx,offset IDAddIn
		.while dword ptr [ebx]
			push	sizeof buffer/2
			lea		eax,buffer
			push	eax
			push	edi
			push	offset szAppName
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpGetLangString
			.if eax
				mov		mnui.cbSize,sizeof mnui
				mov		mnui.fMask,MIIM_TYPE
				mov		mnui.fType,MFT_STRING
				lea		eax,buffer
				mov		mnui.dwTypeData,eax
				;Update our menuitem
				mov		edx,[lpHandles]
				invoke SetMenuItemInfoW,[edx].ADDINHANDLES.hMenu,[ebx],FALSE,addr mnui
			.endif
			inc		edi
			add		ebx,4
		.endw
		pop		edi
	.endif
	mov		eax,FALSE
	ret

DllProc Endp

;#########################################################################

End DllEntry
