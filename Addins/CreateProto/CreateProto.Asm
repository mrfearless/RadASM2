;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include CreateProto.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

AddMenu proc nID:DWORD,lpText:DWORD

	mov		edx,6
	;Adjust topmost popup if maximized
	mov		eax,[lpData]
	.if [eax].ADDINDATA.fMaximized
		inc		edx
	.endif
	;Get handle of Tools popup
	mov		eax,[lpHandles]
	invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,edx
	;Add our menuitem
	invoke AppendMenu,eax,MF_STRING,nID,lpText
	ret

AddMenu endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD

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
	; Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov		IDAddIn,eax
	invoke AddMenu,IDAddIn,addr szCreateProtos
	; Messages to hook into
	mov		eax,RAM_COMMAND or RAM_CLOSE or RAM_MENUREBUILD
	mov		ecx,RAM_ADDINSLOADED
	; EDX must be null before we return
	xor		edx,edx
	ret

InstallDll Endp

ProtoProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	FALSE
		push	offset szAppName
		push	hWin
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpSetLanguage
		mov		edx,lpData
		.if [edx].ADDINDATA.fProject
			;A project is loaded, dump the procs
			;Get pointer to word list
			mov		esi,[edx].ADDINDATA.lpWordList
			;Skip the words loaded from .api files
			add		esi,[edx].ADDINDATA.rpProjectWordList
			;Loop trough the word list
			.while [esi].PROPERTIES.nSize
				;Check if it is a proc
				.if [esi].PROPERTIES.nType=='p'
					;Point to the proc name
					lea		eax,[esi+sizeof PROPERTIES]
					invoke SendDlgItemMessage,hWin,IDC_LSTPROTO,LB_ADDSTRING,0,eax
					;Save the pointer
					invoke SendDlgItemMessage,hWin,IDC_LSTPROTO,LB_SETITEMDATA,eax,esi
				.endif
				;Move to next word
				mov		eax,[esi].PROPERTIES.nSize
				lea		esi,[esi+eax+sizeof PROPERTIES]
			.endw
			invoke SendDlgItemMessage,hWin,IDC_LSTPROTO,LB_SETCARETINDEX,0,0
		.endif
		xor		eax,eax
		ret
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				;Clear the output window
				invoke clrOutput
				push	ebx
				push	edi
				xor		ebx,ebx
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTPROTO,LB_GETSEL,ebx,0
					.break .if eax==LB_ERR
					.if eax
						invoke SendDlgItemMessage,hWin,IDC_LSTPROTO,LB_GETITEMDATA,ebx,0
						;Point to the proc name
						lea		esi,[eax+sizeof PROPERTIES]
						lea		edi,buffer
						invoke lstrcpy,edi,esi
						invoke lstrlen,edi
						lea		edi,[edi+eax]
						.while eax<24
							mov		byte ptr [edi],' '
							inc		edi
							inc		eax
						.endw
						invoke lstrcpy,edi,addr szProto
						invoke lstrlen,edi
						lea		edi,[edi+eax]
						;Point to proc parameters
						invoke lstrlen,esi
						lea		esi,[esi+eax+1]
						mov		ah,VK_TAB
						.while byte ptr [esi]
							.if byte ptr [esi]==':'
								mov		[edi],ah
								inc		edi
								.while byte ptr [esi] && byte ptr [esi]!=','
									mov		al,[esi]
									mov		[edi],al
									inc		esi
									inc		edi
								.endw
								mov		ah,','
							.else
								inc		esi
							.endif
						.endw
						mov		byte ptr [edi],0
						invoke TextOutput,addr buffer
					.endif
					inc		ebx
				.endw
				pop		edi
				pop		ebx
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ProtoProc endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	mnui:MENUITEMINFO

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if edx==IDAddIn && (eax==BN_CLICKED || eax==1)
			push	NULL
			push	offset ProtoProc
			push	hWin
			push	IDD_DLGPROTO
			push	hInstance
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpModalDialog
		.endif
	.elseif eax==AIM_CLOSE
		;Remove all menu items
		mov		eax,lpHandles
		invoke DeleteMenu,[eax].ADDINHANDLES.hMenu,IDAddIn,MF_BYCOMMAND
	.elseif eax==AIM_MENUREBUILD
		invoke AddMenu,IDAddIn,addr szCreateProtos
;		invoke AddAccel
		call	Translate
	.elseif eax==AIM_ADDINSLOADED
		call	Translate
	.endif
	mov		eax,FALSE
	ret

Translate:
	push	sizeof buffer/2
	lea		eax,buffer
	push	eax
	push	2000
	push	offset szAppName
	mov		eax,lpProc
	call	[eax].ADDINPROCS.lpGetLangString
	.if eax
		mov		mnui.cbSize,sizeof mnui
		mov		mnui.fMask,MIIM_TYPE
		mov		mnui.fType,MFT_STRING
		lea		eax,buffer
		mov		mnui.dwTypeData,eax
		;Insert our menuitem
		mov		edx,[lpHandles]
		invoke SetMenuItemInfoW,(ADDINHANDLES ptr [edx]).hMenu,IDAddIn,FALSE,addr mnui
	.endif
	retn

DllProc Endp

;#########################################################################

End DllEntry
