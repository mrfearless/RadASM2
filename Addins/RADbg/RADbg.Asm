.386
.model flat,stdcall
option casemap:none

include RADbg.inc
include RADbgFile.asm

.code

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

    push    hInst
    pop     hInstance
    mov     eax,TRUE
    ret

DllEntry Endp

InstallDll proc hWin:DWORD,fOpt:DWORD

	;Save handle of mdi frame
	push	hWin
	pop		hWnd
	.if fOpt==1
		;Use int 3 debugging
		mov		fInt3,TRUE
	.elseif fOpt>15
		;Output to RadASM output window#1
		mov		eax,fOpt
		sub		eax,15
		mov		fOut,eax
	.endif
	mov		RbnID,IDC_RBN1
	;Get pointer to handles struct
	invoke SendMessage,hWin,AIM_GETHANDLES,0,0
	mov		lpHStruct,eax
	;Get pointer to proc struct
	invoke SendMessage,hWin,AIM_GETPROCS,0,0
	mov		lpPStruct,eax
	;Get pointer to data struct
	invoke SendMessage,hWin,AIM_GETDATA,0,0
	mov		lpDStruct,eax
	;Returned value tells RadASM which messages you are hooking into
	;Hook into AIM_COMMAND, AIM_MAKEBEGIN and AIM_MAKEDONE
	mov		eax,RAM_COMMAND or RAM_MAKEBEGIN or RAM_MAKEDONE
	;Note!
	;Also set ecx and edx to NULL in case more than 32 hooks are
	;needed in the future.
	xor		ecx,ecx
	xor		edx,edx
    ret

InstallDll endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

OutputRegs proc hWin:HWND,fClear:DWORD
	LOCAL	buffer[1024]:BYTE
	LOCAL	buffer1[64]:BYTE

	.if fClear
		invoke SetWindowText,hWin,offset szNULL
	.endif
	invoke SendMessage,hWin,EM_REPLACESEL,FALSE,offset szFlags
	push	esi
	push	edi
	mov		esi,offset szRegs
	mov		edi,lpRegs
	mov		eax,IDC_RBN3
	mov		edx,[edi].RADBG._efl
	call ShowReg
	mov		eax,RbnID
	mov		edx,[edi].RADBG._eax
	call ShowReg
	mov		edx,[edi].RADBG._ebx
	call ShowReg
	mov		edx,[edi].RADBG._ecx
	call ShowReg
	mov		edx,[edi].RADBG._edx
	call ShowReg
	mov		edx,[edi].RADBG._esi
	call ShowReg
	mov		edx,[edi].RADBG._edi
	call ShowReg
	mov		edx,[edi].RADBG._ebp
	call ShowReg
	mov		edx,[edi].RADBG._esp
	call ShowReg
	mov		edx,[edi].RADBG._eip
	call ShowReg
	push	eax
	push	esi
	mov		esi,lpDStruct
	mov		esi,[esi].ADDINDATA.lpBreakPointVar
	mov		edx,[edi].RADBG.nid
	inc		edx
	.while dword ptr [esi]
		.if edx==dword ptr [esi]
			add		esi,4
			invoke SendMessage,hWin,EM_REPLACESEL,FALSE,esi
			invoke SendMessage,hWin,EM_REPLACESEL,FALSE,offset szCRLF
			xor		edx,edx
			.break
		.endif
		add		esi,4
		push	edx
		add		esi,4
		invoke lstrlen,esi
		add		esi,eax
		inc		esi
		pop		edx
	.endw
	pop		esi
	pop		eax
	.if !edx
		mov		edx,[edi].RADBG._var
		call ShowReg
	.else
		add		esi,4
	.endif
	mov		edx,[edi].RADBG._err
	.if edx
		call ShowReg
		invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM,0,[edi].RADBG._err,0,addr buffer,sizeof buffer,0
		invoke SendMessage,hWin,EM_REPLACESEL,FALSE,addr buffer
	.endif
	pop		edi
	pop		esi
	ret

CopyRegName:
	lea		edx,buffer
  @@:
	mov		al,[esi]
	mov		[edx],al
	inc		esi
	inc		edx
	cmp		al,' '
	jne		@b
	mov		byte ptr [edx],0
	retn

ShowReg:
	push	eax
	push	eax
	push	edx
	call CopyRegName
	pop		edx
	pop		eax
	.if eax==IDC_RBN1
		invoke DwToHex,edx,addr buffer1
	.elseif eax==IDC_RBN2
		invoke DwToAscii,edx,addr buffer1
	.else
		invoke DwToBin,edx,addr buffer1
	.endif
	invoke lstrcat,addr buffer,addr buffer1
	mov		dword ptr buffer1,0A0Dh
	invoke lstrcat,addr buffer,addr buffer1
	invoke SendMessage,hWin,EM_REPLACESEL,FALSE,addr buffer
	pop		eax
	retn

OutputRegs endp

;This proc handles messages sent from RadASM to our dll
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	radbg:RADBG
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[256]:BYTE

	mov		eax,uMsg
	.if eax==AIM_COMMAND && wParam==-1 && lParam==-1
		push	esi
		push	edi
		mov		esi,lpDStruct
		mov		edx,[esi].ADDINDATA.lpBreakPoint
		mov		esi,[esi].ADDINDATA.lpFile
		lea		edi,radbg
		mov		ecx,sizeof radbg
		rep movsb
		lea		edi,radbg
		mov		eax,[edi].RADBG.nid
		shl		eax,2
		add		edx,eax
		add		edx,eax
		add		edx,eax
		.if dword ptr [edx] && dword ptr [edx+8]==2
			push	dword ptr [edx+4]
			shr		eax,2
			push	eax
			mov		eax,lpPStruct
			mov		eax,[eax].ADDINPROCS.lpShowBreakPoint
			call	eax
			pop		edx
			.if fOut
				inc		edx
				invoke DwToAscii,edx,addr buffer1
				push	1
				mov		eax,lpPStruct
				call [eax].ADDINPROCS.lpOutputSelect

				mov		word ptr buffer,0A0Dh
				mov		eax,lpHStruct
				mov		edx,[eax].ADDINHANDLES.hMdiCld
				invoke GetWindowText,edx,addr buffer[2],sizeof buffer-16
				lea		eax,buffer2
				push	eax
				lea		eax,buffer[2]
				push	eax
				mov		eax,lpPStruct
				call [eax].ADDINPROCS.lpRemoveProjectPath
				invoke lstrcpy,addr buffer[2],eax
				invoke lstrcat,addr buffer,offset szLPA
				invoke lstrcat,addr buffer,addr buffer1
				invoke lstrcat,addr buffer,offset szRPA
				lea		eax,buffer
				push	eax
				mov		eax,lpPStruct
				call [eax].ADDINPROCS.lpTextOut
				mov		lpRegs,edi
				mov		eax,lpHStruct
				mov		eax,[eax].ADDINHANDLES.hOut1
				invoke OutputRegs,eax,FALSE
				invoke SendMessage,hWin,WM_PAINT,0,0
				mov		eax,lpHStruct
				mov		eax,[eax].ADDINHANDLES.hOut1
				invoke SendMessage,eax,WM_PAINT,0,0
				invoke GetTickCount
				mov		esi,eax
				mov		eax,fOut
				dec		eax
				mov		edx,1000
				mul		edx
				add		esi,eax
				xor		eax,eax
				.while eax<esi
					invoke GetTickCount
				.endw
				.if fOut==1
					call	ShowDialog
;					invoke DialogBoxParam,hInstance,IDD_DLG1,NULL,offset DlgProc,edi
				.else
					mov		eax,TRUE
				.endif
			.else
				call	ShowDialog
;				invoke DialogBoxParam,hInstance,IDD_DLG1,NULL,offset DlgProc,edi
			.endif
		.else
			mov		eax,TRUE
		.endif
		pop		edi
		pop		esi
		ret
	.elseif eax==AIM_MAKEBEGIN
		mov		edx,lParam
		;Check if make command has assemble command
		.if word ptr [edx]=='2' || word ptr [edx]==',2' || word ptr [edx+2]=='2' || word ptr [edx+2]==',2'
			invoke ProcessFiles
		.endif
	.elseif eax==AIM_MAKEDONE
		invoke RestoreFiles
	.endif
	xor		eax,eax
	ret

ShowDialog:
	push	edi
	push	offset DlgProc
	push	NULL
	push	IDD_DLG1
	push	hInstance
	mov		eax,lpPStruct
	call	[eax].ADDINPROCS.lpModalDialog
	retn

DllProc endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDT1,WM_GETFONT,0,0
		push	eax
		push	TRUE
		push	offset szAppName
		push	hWin
		mov		eax,lpPStruct
		call	[eax].ADDINPROCS.lpSetLanguage
		pop		eax
		invoke SendDlgItemMessage,hWin,IDC_EDT1,WM_SETFONT,eax,FALSE
		invoke SetWindowPos,hWin,0,winX,winY,0,0,SWP_NOSIZE or SWP_NOZORDER
		invoke CheckDlgButton,hWin,RbnID,BST_CHECKED
		mov		eax,lParam
		mov		lpRegs,eax
		call ShowRegs
	.elseif eax==WM_MOVE
		mov		eax,lParam
		and		eax,0FFFFh
		mov		winX,eax
		mov		eax,lParam
		shr		eax,16
		mov		winY,eax
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.left
		mov		winX,eax
		mov		eax,rect.top
		mov		winY,eax
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax==IDC_BTN1
				;Terminate
				invoke SendMessage,hWin,WM_CLOSE,NULL,FALSE
			.elseif eax==IDC_BTN2
				;Clear bookmark
				mov		eax,lpRegs
				mov		eax,[eax].RADBG.nid
				mov		ecx,12
				mul		ecx
				mov		edx,lpDStruct
				mov		edx,[edx].ADDINDATA.lpBreakPoint
				mov		dword ptr [edx+eax+8],3
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax>=IDC_RBN1 && eax<=IDC_RBN3
				mov		RbnID,eax
				call ShowRegs
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,lParam
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

ShowRegs:
	invoke GetDlgItem,hWin,IDC_EDT1
	invoke OutputRegs,eax,TRUE
	retn

DlgProc endp

End DllEntry
