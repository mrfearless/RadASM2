
;Edit\MainFiles.dlg
IDD_DLGMAINFILES		equ 4400
IDC_LSTMAINFILES		equ 4402
IDC_EDTMAINFILES		equ 4404
IDC_BTNMAINFILES		equ 4405

.code

UpdateMainFiles proc hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[16]:BYTE

	mov		nInx,0
	.while nInx<20
		invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_GETTEXT,nInx,addr buffer
		invoke BinToDec,nInx,addr buffer1
		lea		edx,buffer[1]
		.while byte ptr [edx-1]!=VK_TAB
			inc		edx
		.endw
		.if byte ptr [edx]
			invoke WritePrivateProfileString,addr iniMakeFile,addr buffer1,edx,addr ProjectFile
		.endif
		inc		nInx
	.endw
	ret

UpdateMainFiles endp

MainFilesDialogProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		dword ptr buffer,12
		invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_SETTABSTOPS,1,addr buffer
		mov		buffer2,0
		mov		nInx,0
		.while nInx<20
			invoke BinToDec,nInx,addr buffer
			mov		dword ptr buffer1,'$('
			invoke BinToDec,nInx,addr buffer1[2]
			invoke strlen,addr buffer1
			mov		dword ptr buffer1[eax],(VK_TAB shl 8) or ')'
			invoke GetPrivateProfileString,addr iniMakeFile,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
			.if eax
				invoke strcat,addr buffer1,addr buffer
				.if !nInx
					invoke strcpy,addr buffer2,addr buffer
					invoke strlen,addr buffer2
					mov		byte ptr buffer2[eax-4],0
				.endif
			.else
				invoke BinToDec,nInx,addr buffer
				invoke GetPrivateProfileString,addr iniMakeFile,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr iniAsmFile
				.if eax
					invoke strcat,addr buffer1,addr buffer2
					invoke strcat,addr buffer1,addr buffer
				.endif
			.endif
			invoke SendDlgItemMessage,hWin,IDC_EDTMAINFILES,EM_LIMITTEXT,64,0
			invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_ADDSTRING,0,addr buffer1
			inc		nInx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_SETCURSEL,0,0
		invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTMAINFILES,0
		invoke SetLanguage,hWin,IDD_DLGMAINFILES,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke UpdateMainFiles,hWin
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNMAINFILES
				invoke RtlZeroMemory,offset ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				m2m		ofn.hwndOwner,hWin
				m2m		ofn.hInstance,hInstance
				mov		ofn.lpstrInitialDir,offset ProjectPath
				mov		ofn.lpstrFilter,0
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke GetDlgItemText,hWin,IDC_EDTMAINFILES,addr buffer,sizeof buffer
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke RemoveProjectPath,addr buffer,addr buffer1
					invoke SetDlgItemText,hWin,IDC_EDTMAINFILES,eax
				.endif
			.endif
		.elseif edx==LBN_SELCHANGE
			mov		buffer,0
			invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_GETTEXT,ebx,addr buffer
				lea		ebx,buffer[1]
				.while byte ptr [ebx-1]!=VK_TAB
					inc		ebx
				.endw
				invoke SetDlgItemText,hWin,IDC_EDTMAINFILES,ebx
			.endif
		.elseif edx==EN_CHANGE
			invoke GetDlgItemText,hWin,IDC_EDTMAINFILES,addr buffer,sizeof buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_GETCURSEL,0,0
			xor		ebx,ebx
			.if eax!=LB_ERR
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_DELETESTRING,ebx,0
			.endif
			mov		dword ptr buffer1,'$('
			invoke BinToDec,ebx,addr buffer1[2]
			invoke strlen,addr buffer1
			mov		dword ptr buffer1[eax],(VK_TAB shl 8) or ')'
			invoke strcat,addr buffer1,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_INSERTSTRING,ebx,addr buffer1
			invoke SendDlgItemMessage,hWin,IDC_LSTMAINFILES,LB_SETCURSEL,ebx,0
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

MainFilesDialogProc endp
