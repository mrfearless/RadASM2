
IDD_DLGCUSTCTRL			equ 5600
IDC_BTNCUSTCTRLBROWSE	equ 5601
IDC_EDTCUSTCTRL			equ 5602
IDC_BTNCUSTCTRLDEL		equ 5603
IDC_BTNCUSTCTRLADD		equ 5604
IDC_BTNCUSTCTRLDN		equ 5605
IDC_BTNCUSTCTRLUP		equ 5606
IDC_LSTCUSTCTRL			equ 5607

.code

CustomControlsProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[8]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetLanguage,hWin,IDD_DLGCUSTCTRL,FALSE
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNCUSTCTRLUP,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+3,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNCUSTCTRLDN,BM_SETIMAGE,IMAGE_ICON,eax
		invoke SendDlgItemMessage,hWin,IDC_EDTCUSTCTRL,EM_LIMITTEXT,MAX_PATH-1,0
		mov		nInx,1
	  Nxt:
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,offset iniCustCtrl,addr buffer,offset szNULL,addr buffer,sizeof buffer,offset iniFile
		.if eax
			invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_ADDSTRING,0,addr buffer
			inc		nInx
			jmp		Nxt
		.endif
		invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_SETCURSEL,0,0
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		word ptr buffer,0
				invoke WritePrivateProfileSection,offset iniCustCtrl,addr buffer,addr iniFile
				mov		nInx,0
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_GETTEXT,nInx,addr buffer
					.break .if eax==LB_ERR
					inc		nInx
					invoke BinToDec,nInx,addr buffer1
					invoke WritePrivateProfileString,offset iniCustCtrl,addr buffer1,addr buffer,addr iniFile
				.endw
				invoke MessageBox,hWin,offset szRestart,offset AppName,MB_OK or MB_ICONINFORMATION
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNCUSTCTRLUP
				invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_GETCURSEL,0,0
				.if eax && eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_DELETESTRING,nInx,0
					dec		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_INSERTSTRING,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_SETCURSEL,nInx,0
				.endif
			.elseif eax==IDC_BTNCUSTCTRLDN
				invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_GETCOUNT,0,0
					dec		eax
					.if eax!=nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_GETTEXT,nInx,addr buffer
						invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_DELETESTRING,nInx,0
						inc		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_INSERTSTRING,nInx,addr buffer
						invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_SETCURSEL,nInx,0
					.endif
				.endif
			.elseif eax==IDC_BTNCUSTCTRLADD
				invoke GetDlgItemText,hWin,IDC_EDTCUSTCTRL,addr buffer,sizeof buffer
				invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_ADDSTRING,0,addr buffer
				invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_SETCURSEL,eax,0
				invoke SendDlgItemMessage,hWin,IDC_EDTCUSTCTRL,WM_SETTEXT,0,addr szNULL
			.elseif eax==IDC_BTNCUSTCTRLDEL
				invoke SendDlgItemMessage,hWin,IDC_EDTCUSTCTRL,WM_SETTEXT,0,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_DELETESTRING,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_SETCURSEL,nInx,0
					.if eax==LB_ERR
						dec		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTCUSTCTRL,LB_SETCURSEL,nInx,0
					.endif
				.endif
			.elseif eax==IDC_BTNCUSTCTRLBROWSE
				invoke RtlZeroMemory,offset ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				m2m		ofn.hwndOwner,hWin
				m2m		ofn.hInstance,hInstance
				mov		ofn.lpstrInitialDir,offset AppPath
				mov		ofn.lpstrFilter,offset DLLFilterString
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke GetDlgItemText,hWin,IDC_EDTCUSTCTRL,addr buffer,sizeof buffer
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTCUSTCTRL,addr buffer
				.endif
			.endif
		.elseif edx==EN_CHANGE
			invoke GetDlgItem,hWin,IDC_BTNCUSTCTRLADD
			push	eax
			invoke SendDlgItemMessage,hWin,IDC_EDTCUSTCTRL,WM_GETTEXTLENGTH,0,0
			pop		edx
			invoke EnableWindow,edx,eax
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

CustomControlsProc endp
