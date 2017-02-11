
IDD_DLGPROGLANGUAGE				equ 5500
IDC_BTNPLBROWSE					equ 1001
IDC_EDTPL						equ 1002
IDC_BTNPLDEL					equ 1003
IDC_BTNPLADD					equ 1004
IDC_BTNPLDN						equ 1007
IDC_BTNPLUP						equ 1008
IDC_LSTPL						equ 1009
IDC_EDTPLDESC					equ 1005

.const

iniDescription					db 'Description',0

.code

ProgLanguageProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	nInx:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetLanguage,hWin,IDD_DLGPROGLANGUAGE,FALSE
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNPLUP,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+3,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNPLDN,BM_SETIMAGE,IMAGE_ICON,eax
		invoke GetPrivateProfileString,addr iniAssembler,addr iniAssembler,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniFile
		.while TRUE
			invoke iniGetItem,addr iniBuffer,addr buffer
			.break .if !buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_ADDSTRING,0,addr buffer
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETCURSEL,0,0
		call SetDescription
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		iniBuffer,0
				xor		eax,eax
				mov		nInx,eax
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETTEXT,nInx,addr buffer
					.break .if eax==LB_ERR
					.if iniBuffer
						invoke strcat,addr iniBuffer,addr szComma
					.endif
					invoke strcat,addr iniBuffer,addr buffer
					inc		nInx
				.endw
				invoke WritePrivateProfileString,addr iniAssembler,addr iniAssembler,addr iniBuffer,addr iniFile
				invoke iniSetAsmMenu
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNPLDEL
				invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_DELETESTRING,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETCURSEL,nInx,0
					.if eax==LB_ERR
						dec		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETCURSEL,nInx,0
					.endif
				.endif
				call SetDescription
			.elseif eax==IDC_BTNPLADD
				invoke GetDlgItemText,hWin,IDC_EDTPL,addr buffer,sizeof buffer
				invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_ADDSTRING,0,addr buffer
				invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETCURSEL,eax,0
				invoke SendDlgItemMessage,hWin,IDC_EDTPL,WM_SETTEXT,0,NULL
				call SetDescription
			.elseif eax==IDC_BTNPLDN
				invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETCURSEL,0,0
				mov		nInx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETCOUNT,0,0
				dec		eax
				.if eax!=nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_DELETESTRING,nInx,0
					inc		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_INSERTSTRING,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETCURSEL,nInx,0
				.endif
			.elseif eax==IDC_BTNPLUP
				invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETCURSEL,0,0
				.if eax
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_DELETESTRING,nInx,0
					dec		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_INSERTSTRING,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_SETCURSEL,nInx,0
				.endif
			.elseif eax==IDC_BTNPLBROWSE
				invoke RtlZeroMemory,offset ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				m2m		ofn.hwndOwner,hWin
				m2m		ofn.hInstance,hInstance
				mov		ofn.lpstrInitialDir,offset AppPath
				mov		eax,lpFilter
				mov		ofn.lpstrFilter,offset INIFilterString
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke GetDlgItemText,hWin,IDC_EDTPL,addr buffer,sizeof buffer
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke RemovePath,addr buffer,offset AppPath,addr iniBuffer
					.if byte ptr [eax]=='\'
						inc		eax
					.endif
					invoke strcpy,addr buffer,eax
					lea		eax,buffer
					.while byte ptr [eax]
						.if byte ptr [eax]=='.'
							mov		byte ptr [eax],0
						.endif
						inc		eax
					.endw
					invoke SetDlgItemText,hWin,IDC_EDTPL,addr buffer
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTPL
				invoke SendDlgItemMessage,hWin,IDC_EDTPL,WM_GETTEXTLENGTH,0,0
				push	eax
				invoke GetDlgItem,hWin,IDC_BTNPLADD
				pop		edx
				invoke EnableWindow,eax,edx
			.endif
		.elseif edx==LBN_SELCHANGE
			call SetDescription
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

SetDescription:
	invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		invoke SendDlgItemMessage,hWin,IDC_LSTPL,LB_GETTEXT,nInx,addr iniBuffer
		invoke strcpy,addr buffer,addr AppPath
		invoke strcat,addr buffer,addr szBackSlash
		invoke strcat,addr buffer,addr iniBuffer
		invoke strcat,addr buffer,addr FTIni
		mov		word ptr iniBuffer,'1'
		invoke GetPrivateProfileString,addr iniDescription,addr iniBuffer,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr buffer
	.else
		mov		iniBuffer,0
	.endif
	invoke ConvertCaption,addr buffer,addr iniBuffer
	invoke SetDlgItemText,hWin,IDC_EDTPLDESC,addr buffer
	retn

ProgLanguageProc endp
