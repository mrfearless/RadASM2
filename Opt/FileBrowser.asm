
;Opt\FileBrowser.dlg
IDD_DLGFILEBROWSER						equ 4000
IDC_LSTFOLDER							equ 4001
IDC_BTNFOLDERU							equ 4008
IDC_BTNFOLDERD							equ 4007
IDC_BTNADDFOLDER						equ 4002
IDC_BTNDELETEFOLDER						equ 4003
IDC_EDTFOLDER							equ 4004
IDC_BTNBROWSEFOLDER						equ 4005
IDC_EDTFILTER							equ 4006

.code

SaveFileBrowser proc uses ebx,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke RtlZeroMemory,offset FilePaths,sizeof FilePaths
	mov		nInx,0
	mov		ebx,offset FilePaths
	mov		eax,10
	.while eax
		push	eax
		invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETTEXT,nInx,addr buffer
		.if eax!=LB_ERR
			mov		al,buffer
			.if al
				invoke strcpy,ebx,addr buffer
				add		ebx,MAX_PATH
			.endif
		.endif
		pop		eax
		inc		nInx
		dec		eax
	.endw
	invoke GetDlgItemText,hWin,IDC_EDTFILTER,offset FileFilter,sizeof FileFilter-1
	invoke iniFileBrowserSave
	ret

SaveFileBrowser endp

FileBrowserProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		ebx,offset FilePaths
		mov		eax,10
		.while eax
			push	eax
			mov		al,[ebx]
			.if al
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_ADDSTRING,0,ebx
			.endif
			add		ebx,MAX_PATH
			pop		eax
			dec		eax
		.endw
		invoke SendDlgItemMessage,hWin,IDC_EDTFILTER,EM_LIMITTEXT,sizeof FileFilter-1,0
		invoke SetDlgItemText,hWin,IDC_EDTFILTER,offset FileFilter
		invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_SETCURSEL,0,0
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNFOLDERU,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+3,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNFOLDERD,BM_SETIMAGE,IMAGE_ICON,eax
		mov		eax,LBN_SELCHANGE
		shl		eax,16
		or		eax,IDC_LSTFOLDER
		invoke SendMessage,hWin,WM_COMMAND,eax,0
		invoke SetLanguage,hWin,IDD_DLGFILEBROWSER,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SaveFileBrowser,hWin
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNFOLDERU
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETCURSEL,0,0
				.if eax && eax!=LB_ERR
					mov		ebx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETTEXT,ebx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_DELETESTRING,ebx,0
					dec		ebx
					invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_INSERTSTRING,ebx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_SETCURSEL,ebx,0
				.endif
			.elseif eax==IDC_BTNFOLDERD
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		ebx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETCOUNT,0,0
					dec		eax
					.if eax!=ebx
						invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETTEXT,ebx,addr buffer
						invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_DELETESTRING,ebx,0
						inc		ebx
						invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_INSERTSTRING,ebx,addr buffer
						invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_SETCURSEL,ebx,0
					.endif
				.endif
			.elseif eax==IDC_BTNADDFOLDER
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETCOUNT,0,0
				.if eax<10
					mov		ebx,eax
					mov		buffer,0
					invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_ADDSTRING,0,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_SETCURSEL,ebx,0
					mov		eax,LBN_SELCHANGE
					shl		eax,16
					or		eax,IDC_LSTFOLDER
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endif
			.elseif eax==IDC_BTNDELETEFOLDER
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		ebx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_DELETESTRING,ebx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_SETCURSEL,ebx,0
					.if eax==LB_ERR
						dec		ebx
						invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_SETCURSEL,ebx,0
					.endif
				.endif
				mov		eax,LBN_SELCHANGE
				shl		eax,16
				or		eax,IDC_LSTFOLDER
				invoke SendMessage,hWin,WM_COMMAND,eax,0
			.elseif eax==IDC_BTNBROWSEFOLDER
				invoke BrowseFolder,hWin,IDC_EDTFOLDER
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTFOLDER
				invoke GetDlgItemText,hWin,IDC_EDTFOLDER,addr buffer,sizeof buffer
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETCURSEL,0,0
				.if eax==LB_ERR
					xor		eax,eax
				.endif
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_DELETESTRING,ebx,0
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_INSERTSTRING,ebx,addr buffer
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_SETCURSEL,ebx,0
			.endif
		.elseif edx==LBN_SELCHANGE
			mov		buffer,0
			invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTFOLDER,LB_GETTEXT,ebx,addr buffer
			.endif
			invoke SetDlgItemText,hWin,IDC_EDTFOLDER,addr buffer
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

FileBrowserProc endp
