;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include ProcDump.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov eax,hInst
	mov hInstance,eax
	mov eax,TRUE
	ret

DllEntry Endp

AddMenu proc

	.if IDAddIn
		mov		edx,4		;Project menu
		;Adjust topmost popup if maximized.
		mov		eax,lpData
		mov		eax,[eax].ADDINDATA.fMaximized
		.if eax
			inc		edx
		.endif
		;Get handle of menu
		mov		eax,lpHandles
		mov		eax,[eax].ADDINHANDLES.hMenu
		;Get handle of Project popup
		invoke GetSubMenu,eax,edx
		;Add our menuitem
		invoke AppendMenu,eax,MF_STRING,IDAddIn,addr szProcDump
	.endif
	ret

AddMenu endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx hWin:DWORD,fOpt:DWORD

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
	; If Option (fOpt) = 0 then exit
	mov		eax,fOpt
	test	eax,eax
	je @F
		; Allocate a new menu id
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDAddIn,eax
		mov		mytbbutton.idCommand,eax 
		invoke AddMenu
		mov		ebx,[lpHandles] 
		mov		ebx,(ADDINHANDLES ptr [ebx]).hToolBar 
		invoke SendMessage,ebx,TB_GETIMAGELIST,0,0 
		push	eax 
		invoke LoadBitmap,hInstance,100 
		pop		edx
		push	eax 
		invoke ImageList_AddMasked,edx,eax,808080h 
		mov   mytbbutton.iBitmap,eax 
		pop		eax
		invoke DeleteObject,eax 
		invoke SendMessage,ebx,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0 
		invoke SendMessage,ebx,TB_INSERTBUTTON,-1,offset mytbbutton 
		; Messages to hook into
		mov		eax,RAM_COMMAND OR RAM_CLOSE OR RAM_TBRTOOLTIP
	@@:
	; ECX and EDX must be null before we return
	xor		ecx,ecx
	xor		edx,edx
	ret 

InstallDll Endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

BinToDec proc dwVal:DWORD,lpAscii:DWORD

    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:      
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

BinToDec endp

ProcDump proc uses esi

	mov		edx,lpData
	;Get pointer to word list
	mov		esi,[edx].ADDINDATA.lpWordList
	;Skip the words loaded from .api files
	add		esi,[edx].ADDINDATA.rpProjectWordList
	;Clear the output window
	invoke clrOutput
	;Loop trough the word list
	.while [esi].PROPERTIES.nSize
		;Check if it is a proc
		.if [esi].PROPERTIES.nType=='p'
			push	esi
			;Point to the proc name
			mov		edx,[esi].PROPERTIES.Owner
			invoke BinToDec,edx,addr buffer
			lea		esi,[esi+sizeof PROPERTIES]
			invoke lstrcat,addr buffer,esi
			invoke lstrlen,esi
			;Point to the procs parameters
			lea		esi,[esi+eax+1]
			.if byte ptr [esi]
				invoke lstrlen,addr buffer
				mov		word ptr buffer[eax],','
				invoke lstrcat,addr buffer,esi
			.endif
			invoke lstrlen,esi
			;Point to the procs locals
			lea		esi,[esi+eax+1]
			.if byte ptr [esi]
				invoke lstrlen,addr buffer
				mov		dword ptr buffer[eax],':L '
				invoke lstrcat,addr buffer,esi
			.endif
			;Output the proc name
			invoke TextOutput,addr buffer
			pop		esi
		.endif
		;Move to next word
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
	ret

ProcDump endp

StructDump proc uses esi

	mov		edx,lpData
	;Get pointer to word list
	mov		esi,[edx].ADDINDATA.lpWordList
	;Skip the words loaded from .api files
	add		esi,[edx].ADDINDATA.rpProjectWordList
	;Clear the output window
	invoke clrOutput
	;Loop trough the word list
	.while [esi].PROPERTIES.nSize
		;Check if it is a struct
		.if [esi].PROPERTIES.nType=='s'
			push	esi
			;Point to the struct name
			lea		esi,[esi+sizeof PROPERTIES]
			invoke lstrcpy,addr buffer,esi
			invoke lstrlen,esi
			;Point to the struct items
			lea		esi,[esi+eax+1]
			.if byte ptr [esi]
				invoke lstrlen,addr buffer
				mov		word ptr buffer[eax],','
				invoke lstrcat,addr buffer,esi
			.endif
			;Output the struct definition
			invoke TextOutput,addr buffer
			pop		esi
		.endif
		;Move to next word
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
	ret

StructDump endp

AllDump proc uses esi

	mov		edx,lpData
	;Get pointer to word list
	mov		esi,[edx].ADDINDATA.lpWordList
	;Skip the words loaded from .api files
	add		esi,[edx].ADDINDATA.rpProjectWordList
	;Clear the output window
	invoke clrOutput
	;Loop trough the word list
	.while [esi].PROPERTIES.nSize
		push	esi
		;Point to the struct name
		movzx	eax,[esi].PROPERTIES.nType
		mov		ah,VK_TAB
		mov		dword ptr buffer,eax
		lea		esi,[esi+sizeof PROPERTIES]
		invoke lstrcpy,addr buffer[2],esi
		invoke TextOutput,addr buffer
		pop		esi
		;Move to next word
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
	ret

AllDump endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if edx==IDAddIn && eax==BN_CLICKED
			; Your addin has been selected
			;invoke ProcDump
			invoke ProcDump
			;invoke AllDump
		.endif
	.elseif eax==AIM_CLOSE
		; Delete menu item
		mov edx,lpHandles
		invoke DeleteMenu,[edx].ADDINHANDLES.hMenu,IDAddIn,MF_BYCOMMAND
		; Delete toolbar button
		mov edx,lpHandles
		invoke SendMessage,[edx].ADDINHANDLES.hToolBar,TB_COMMANDTOINDEX,IDAddIn,0
		mov edx,lpHandles
		invoke SendMessage,[edx].ADDINHANDLES.hToolBar,TB_DELETEBUTTON,eax,0
		mov IDAddIn,0
	.elseif eax==AIM_TBRTOOLTIP
		mov eax,offset szProcDump
		ret
	.endif
	mov		eax,FALSE
	ret

DllProc Endp

;#########################################################################

End DllEntry
