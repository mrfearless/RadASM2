IDD_DLGBPVAR	equ 3800
IDC_EDTBPVAR	equ 3801
IDC_BTNBPCLEAR	equ 3802

.code

GetBreakPointID proc uses edi

	mov		edi,offset BreakPoint
	mov		eax,hEdit
	mov		edx,Line
	.while edi<offset BreakPoint+sizeof BreakPoint
		.if eax==[edi] && edx==[edi+4]
			mov		eax,edi
			sub		eax,offset BreakPoint
			mov		ecx,12
			xor		edx,edx
			div		ecx
			jmp		Ex
		.endif
		add		edi,12
	.endw
	xor		eax,eax
	dec		eax
  Ex:
	inc		eax
	ret

GetBreakPointID endp

GetBreakPointVar proc uses edi,nID:DWORD

	mov		edi,offset BreakPointVar
	mov		edx,nID
	.while dword ptr [edi]
		.if edx==dword ptr [edi]
			jmp		Ex
		.endif
		.if dword ptr [edi]
			push	edx
			add		edi,4
			invoke strlen,edi
			add		edi,eax
			inc		edi
			pop		edx
		.endif
	.endw
  Ex:
	mov		eax,edi
	ret

GetBreakPointVar endp

DelBreakPointVar proc uses esi edi,lpBPVar:DWORD

	mov		edi,lpBPVar
	mov		esi,edi
	add		esi,4
	invoke strlen,esi
	add		esi,eax
	inc		esi
	mov		ecx,offset BreakPointVar+sizeof BreakPointVar
	sub		ecx,esi
	rep movsb
	ret

DelBreakPointVar endp

SetBreakPointVar proc uses esi edi,nID:DWORD,lpVar:DWORD

	invoke GetBreakPointVar,nID
	.if dword ptr [eax]
		invoke DelBreakPointVar,eax
	.endif
	mov		edi,offset BreakPointVar
  @@:
	mov		eax,[edi]
	.if eax
		add		edi,4
		invoke strlen,edi
		add		edi,eax
		inc		edi
		jmp		@b
	.endif
	.if edi<offset BreakPointVar+sizeof BreakPointVar-36
		mov		esi,lpVar
		.if esi
			.if byte ptr [esi]
				mov		eax,nID
				mov		[edi],eax
				add		edi,4
				invoke strcpy,edi,esi
			.endif
		.endif
	.endif
	ret

SetBreakPointVar endp

DlgBPVarProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[32]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTBPVAR,EM_LIMITTEXT,31,0
		invoke GetBreakPointID
		invoke GetBreakPointVar,eax
		.if dword ptr [eax]
			add		eax,4
			invoke SetDlgItemText,hWin,IDC_EDTBPVAR,eax
		.endif
		invoke SetLanguage,hWin,IDD_DLGBPVAR,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetDlgItemText,hWin,IDC_EDTBPVAR,addr buffer,sizeof buffer
				invoke GetBreakPointID
				mov		edx,eax
				invoke SetBreakPointVar,edx,addr buffer
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNBPCLEAR
				invoke GetBreakPointID
				invoke SetBreakPointVar,eax,0
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
;invoke DumpBP
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgBPVarProc endp
