IDD_DLGPROJECTSCAN		equ 4800
IDC_EDTWORD				equ 1001

.code

ScanProjectProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[64]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetLanguage,hWin,IDD_DLGPROJECTSCAN,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetDlgItemText,hWin,IDC_EDTWORD,addr buffer,sizeof buffer
				.if buffer
					invoke ScanProject,addr buffer
					invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				.endif
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

ScanProjectProc endp
