IDD_BLOCKDLG		equ 5200
IDC_EDTBLOCKINSERT	equ 5201

.code

BlockDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTBLOCKINSERT,EM_LIMITTEXT,255,0
		invoke SetLanguage,hWin,IDD_BLOCKDLG,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendDlgItemMessage,hWin,IDC_EDTBLOCKINSERT,WM_GETTEXT,sizeof buffer,addr buffer
				invoke SendMessage,hEdit,REM_BLOCKINSERT,0,addr buffer
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

BlockDlgProc endp
