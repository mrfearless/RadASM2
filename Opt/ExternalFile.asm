
;Opt\ExternalFile.dlg
IDD_DLGEXTERNALFILE						equ 4100
IDC_LSTFILETYPE							equ 4101
IDC_BTNADDFILETYPE						equ 4102
IDC_BTNDELETEFILETYPE					equ 4103
IDC_EDTFILETYPE							equ 4104
IDC_EDTCOMMAND							equ 4105
IDC_BTNCOMMANDBROWSE					equ 4106

.code

SaveExternalFile proc uses ebx,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	
	mov		dword ptr buffer,'=1'
	invoke WritePrivateProfileSection,addr iniOpen,addr buffer,addr iniFile
	mov		nInx,1
	xor		ebx,ebx
	.while TRUE
		invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_GETTEXT,ebx,addr buffer
		.break .if eax==LB_ERR
		mov		al,buffer
		.if al
			invoke BinToDec,nInx,addr buffer1
			invoke WritePrivateProfileString,addr iniOpen,addr buffer1,addr buffer,addr iniFile
			inc		nInx
		.endif
		inc		ebx
	.endw
	ret

SaveExternalFile endp

ExternalFileProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		nInx,0
	  @@:
		mov		edx,nInx
		inc		edx
		invoke BinToDec,edx,addr buffer
		invoke GetPrivateProfileString,addr iniOpen,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr iniFile
		.if eax
			invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_ADDSTRING,0,addr buffer
			inc		nInx
			jmp		@b
		.endif
		invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_SETCURSEL,0,0
		mov		eax,LBN_SELCHANGE
		shl		eax,16
		or		eax,IDC_LSTFILETYPE
		invoke SendMessage,hWin,WM_COMMAND,eax,0
		invoke SetLanguage,hWin,IDD_DLGEXTERNALFILE,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SaveExternalFile,hWin
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNADDFILETYPE
				invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_GETCOUNT,0,0
				.if eax<10
					mov		ebx,eax
					mov		buffer,0
					invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_ADDSTRING,0,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_SETCURSEL,ebx,0
					mov		eax,LBN_SELCHANGE
					shl		eax,16
					or		eax,IDC_LSTFILETYPE
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endif
			.elseif eax==IDC_BTNDELETEFILETYPE
				invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		ebx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_DELETESTRING,ebx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_SETCURSEL,ebx,0
					.if eax==LB_ERR
						dec		ebx
						invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_SETCURSEL,ebx,0
					.endif
				.endif
				mov		eax,LBN_SELCHANGE
				shl		eax,16
				or		eax,IDC_LSTFILETYPE
				invoke SendMessage,hWin,WM_COMMAND,eax,0
			.elseif eax==IDC_BTNCOMMANDBROWSE
				invoke RtlZeroMemory,offset ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				m2m		ofn.hwndOwner,hWin
				m2m		ofn.hInstance,hInstance
				mov		ofn.lpstrInitialDir,offset ProjectPath
				mov		ofn.lpstrFilter,offset szFilterTools
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke GetDlgItemText,hWin,IDC_EDTCOMMAND,addr buffer,sizeof buffer
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTCOMMAND,addr buffer
				.endif
			.endif
		.elseif edx==LBN_SELCHANGE
			mov		buffer,0
			invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_GETTEXT,ebx,addr buffer
			.endif
			invoke iniGetItem,addr buffer,addr buffer1
			invoke SetDlgItemText,hWin,IDC_EDTFILETYPE,addr buffer1
			invoke SetDlgItemText,hWin,IDC_EDTCOMMAND,addr buffer
		.elseif edx==EN_CHANGE
			invoke GetDlgItemText,hWin,IDC_EDTFILETYPE,addr buffer,sizeof buffer
			mov		word ptr buffer1,','
			invoke strcat,addr buffer,addr buffer1
			invoke GetDlgItemText,hWin,IDC_EDTCOMMAND,addr buffer1,sizeof buffer1
			invoke strcat,addr buffer,addr buffer1
			invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_GETCURSEL,0,0
			xor		ebx,ebx
			.if eax!=LB_ERR
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_DELETESTRING,ebx,0
			.endif
			invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_INSERTSTRING,ebx,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTFILETYPE,LB_SETCURSEL,ebx,0
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ExternalFileProc endp
