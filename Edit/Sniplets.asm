
.data

szNewSniplet		db 'New sniplet',0

.data?

fSnpResize			dd ?
szFile				db MAX_PATH dup(?)
hSnp				dd ?
hSnpRed				dd ?

;Edit\Sniplets.dlg
IDD_DLGSNIPLETS		equ 3100
IDC_TRVSNIPLET		equ 3101
IDC_REDSNIPLET		equ 3102
IDC_BTNOUTPUT		equ 3107
IDC_BTNCLIPBOARD	equ 3106
IDC_BTNSELALL		equ 3104
IDC_BTNCLROUTPUT	equ 3103
IDC_BTNEDITOR		equ 3105
IDC_BTNOPEN			equ 3108
IDC_BTNADDNEW		equ 3109

BTN_WT				equ 84

.code

TrvAddNode proc hTrv:HWND,hPar:DWORD,lpPth:DWORD,nImg:DWORD
	LOCAL	tvins:TV_INSERTSTRUCT

	mov		eax,hPar
    mov		tvins.hParent,eax
    mov		tvins.item.lParam,eax
    mov		tvins.hInsertAfter,0
    mov		tvins.item._mask,TVIF_TEXT or TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE
	mov		eax,lpPth
	mov		tvins.item.pszText,eax
	mov		eax,nImg
    mov		tvins.item.iImage,eax
    mov		tvins.item.iSelectedImage,eax
    invoke SendMessage,hTrv,TVM_INSERTITEM,0,addr tvins
    ret

TrvAddNode endp

TrvDir proc hTrv:HWND,hPar:DWORD,lpPth:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hwfd:DWORD
	LOCAL	hpar:DWORD
	LOCAL	ftp:DWORD

	;Make the path local
	invoke strcpy,addr buffer,lpPth
	;Check if path ends with '\'. If not add.
	invoke strlen,addr buffer
	dec		eax
	mov		al,buffer[eax]
	.if al!='\'
		invoke strcat,addr buffer,addr szBackSlash
	.endif
	;Add '*.*'
	invoke strcat,addr buffer,addr szAPA
	;Find first match, if any
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		;Save returned handle
		mov		hwfd,eax
	  Next:
		;Check if found is a dir
		mov		eax,wfd.dwFileAttributes
		and		eax,FILE_ATTRIBUTE_DIRECTORY
		.if eax
			;Do not include '.' and '..'
			mov		al,wfd.cFileName
			.if al!='.'
				invoke TrvAddNode,hTrv,hPar,addr wfd.cFileName,IML_START+0
				mov		hpar,eax
				invoke strlen,addr buffer
				mov		edx,eax
				push	edx
				sub		edx,3
				;Do not remove the '\'
				mov		al,buffer[edx]
				.if al=='\'
					inc		edx
				.endif
				;Add new dir to path
				invoke strcpy,addr buffer[edx],addr wfd.cFileName
				;Call myself again, thats recursive!
				invoke TrvDir,hTrv,hpar,addr buffer
				pop		edx
				;Remove what was added
				mov		buffer[edx],0
			.endif
		.else
			;Add file
			;Some file filtering could be done here
			invoke GetFileImg,addr wfd.cFileName
			add		eax,IML_START
			mov		ftp,eax
			invoke TrvAddNode,hTrv,hPar,addr wfd.cFileName,ftp
		.endif
		;Any more matches?
		invoke FindNextFile,hwfd,addr wfd
		or		eax,eax
		jne		Next
		;No more matches, close find
		invoke FindClose,hwfd
	.endif
	;Sort the children
	invoke SendMessage,hTrv,TVM_SORTCHILDREN,0,hPar
	;Expand the tree
	.if fExpanded
		invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,hPar
	.endif
	ret

TrvDir endp

SnipletsProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	pt1:POINT
	LOCAL	hCur:DWORD
	LOCAL	hCtl:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	hFile:DWORD
	LOCAL   editstream:EDITSTREAM
	LOCAL	wht:DWORD
	LOCAL	wwt:DWORD
	LOCAL	twt:DWORD
	LOCAL	rwt:DWORD
	LOCAL	blft:DWORD
	LOCAL	btop:DWORD
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hSniplet,eax
		mov		hSnp,eax
		invoke SetLanguage,hWin,IDD_DLGSNIPLETS,FALSE
		invoke GetDlgItem,hWin,IDC_TRVSNIPLET
		mov		hCtl,eax
		invoke SendMessage,hCtl,TVM_SETIMAGELIST,0,hTbrIml
		invoke TrvDir,hCtl,0,addr Snp
		invoke GetDlgItem,hWin,IDC_REDSNIPLET
		mov		hSnpRed,eax
		invoke SetFormat,hSnpRed,hFont,hFont,hFont,TRUE
		;Set the default text/background color
		invoke SetColor,hSnpRed
		.if !fUseHighLight
			invoke GetWindowLong,hSnpRed,GWL_STYLE
			or		eax,STYLE_NOHILITE
			invoke SetWindowLong,hSnpRed,GWL_STYLE,eax
		.endif
		mov		szFile[0],0
		mov		eax,radcol.project
		.if eax!=0FFFFFFh
			invoke SendMessage,hCtl,TVM_SETBKCOLOR,0,eax
			invoke SendMessage,hCtl,TVM_SETTEXTCOLOR,0,radcol.projecttext
		.endif
		invoke MoveWindow,hCtl,0,0,SnipSplit,0,FALSE
		invoke MoveWindow,hWin,SnipLeft,SnipTop,SnipWidth,SnipHeight,FALSE
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.right
		mov		wwt,eax
		mov		eax,rect.bottom
		mov		wht,eax
		invoke GetDlgItem,hWin,IDC_TRVSNIPLET
		mov		hCtl,eax
		invoke GetWindowRect,hCtl,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		mov		twt,eax
		mov		eax,wht
		sub		eax,38
		invoke MoveWindow,hCtl,4,4,twt,eax,TRUE
		invoke GetDlgItem,hWin,IDC_REDSNIPLET
		mov		hCtl,eax
		mov		eax,wwt
		sub		eax,twt
		sub		eax,12
		mov		rwt,eax
		mov		edx,twt
		add		edx,8
		mov		eax,wht
		sub		eax,38
		invoke MoveWindow,hCtl,edx,4,rwt,eax,TRUE
		mov		eax,wht
		sub		eax,29
		mov		btop,eax
		mov		eax,wwt
		sub		eax,4+BTN_WT
		mov		blft,eax
		invoke GetDlgItem,hWin,IDCANCEL
		mov		hCtl,eax
		invoke MoveWindow,hCtl,blft,btop,BTN_WT,24,TRUE
		invoke GetDlgItem,hWin,IDC_BTNOUTPUT
		mov		hCtl,eax
		sub		blft,3+BTN_WT
		invoke MoveWindow,hCtl,blft,btop,BTN_WT,24,TRUE
		invoke GetDlgItem,hWin,IDC_BTNCLIPBOARD
		mov		hCtl,eax
		sub		blft,3+BTN_WT
		invoke MoveWindow,hCtl,blft,btop,BTN_WT,24,TRUE
		invoke GetDlgItem,hWin,IDC_BTNEDITOR
		mov		hCtl,eax
		sub		blft,3+BTN_WT
		invoke MoveWindow,hCtl,blft,btop,BTN_WT,24,TRUE
		invoke GetDlgItem,hWin,IDC_BTNSELALL
		mov		hCtl,eax
		sub		blft,9+BTN_WT
		invoke MoveWindow,hCtl,blft,btop,BTN_WT,24,TRUE
		invoke GetDlgItem,hWin,IDC_BTNCLROUTPUT
		mov		hCtl,eax
		sub		blft,3+BTN_WT
		invoke MoveWindow,hCtl,blft,btop,BTN_WT,24,TRUE
		invoke GetDlgItem,hWin,IDC_BTNOPEN
		mov		hCtl,eax
		sub		blft,3+BTN_WT
		invoke MoveWindow,hCtl,blft,btop,BTN_WT,24,TRUE
		invoke GetDlgItem,hWin,IDC_BTNADDNEW
		mov		hCtl,eax
		sub		blft,3+BTN_WT
		invoke MoveWindow,hCtl,blft,btop,BTN_WT,24,TRUE
	.elseif eax==WM_CLOSE
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.left
		mov		SnipLeft,eax
		mov		eax,rect.top
		mov		SnipTop,eax
		mov		eax,rect.right
		sub		eax,rect.left
		mov		SnipWidth,eax
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		SnipHeight,eax
;		invoke EndDialog,hWin,NULL
		invoke DestroyWindow,hWin
		mov		hSniplet,0
	.elseif eax==WM_COMMAND
		mov eax,wParam
		mov edx,eax
		shr edx,16
		.if dx==BN_CLICKED
			push	eax
			invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,EM_EXGETSEL,0,addr chrg
			mov		ecx,chrg.cpMax
			sub		ecx,chrg.cpMin
			pop		eax
			.if ax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif ax==IDC_BTNCLROUTPUT
				invoke OutputSelect,2
				invoke OutputClear
				invoke ShowOutput
			.elseif ax==IDC_BTNSELALL
				invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,EM_SETSEL,0,-1
			.elseif ax==IDC_BTNEDITOR && ecx
				.if hEdit
					invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,WM_COPY,0,0
					invoke SendMessage,hEdit,WM_PASTE,0,0
				.endif
			.elseif ax==IDC_BTNCLIPBOARD && ecx
				invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,WM_COPY,0,0
			.elseif ax==IDC_BTNOUTPUT && ecx
				invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,WM_COPY,0,0
				invoke OutputSelect,2
				invoke ShowOutput
				invoke SendMessage,hOutREd,WM_PASTE,0,0
			.elseif ax==IDC_BTNOPEN
				invoke strcpy,addr FileName,addr szFile
				invoke OpenEditFile
			.elseif ax==IDC_BTNADDNEW
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				m2m		ofn.hwndOwner,hWnd
				m2m		ofn.hInstance,hInstance
				mov		ofn.lpstrTitle,offset szNewSniplet
				mov		ofn.lpstrFilter,offset ALLFilterString
				mov		ofn.lpstrFile,offset FileName
				mov		byte ptr [FileName],0
				mov		ofn.nMaxFile,sizeof FileName
				mov		ofn.lpstrDefExt,offset DefSrcExt
				mov		ofn.lpstrInitialDir,offset Snp
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetSaveFileName,addr ofn
				.if eax
					invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
					invoke CloseHandle,eax
					invoke GetDlgItem,hWin,IDC_TRVSNIPLET
					mov		hCtl,eax
					.while eax
						invoke SendMessage,hCtl,TVM_GETNEXTITEM,TVGN_ROOT,0
						.if eax
							invoke SendMessage,hCtl,TVM_DELETEITEM,0,eax
						.endif
					.endw
					invoke TrvDir,hCtl,0,addr Snp
				.endif
			.endif
		.endif
	.elseif eax==WM_MOUSEMOVE
		mov		eax,lParam
		and		eax,0FFFFh
		mov		pt.x,eax
		mov		eax,lParam
		shr		eax,16
		mov		pt.y,eax
		mov		pt1.x,0
		mov		pt1.y,0
		invoke ClientToScreen,hWin,addr pt1
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,50
		mov		wwt,eax
		invoke GetDlgItem,hWin,IDC_TRVSNIPLET
		mov		hCtl,eax
		invoke GetWindowRect,hCtl,addr rect
		.if fSnpResize<2
			mov		eax,pt1.x
			sub		rect.left,eax
			sub		rect.right,eax
			mov		eax,pt1.y
			sub		rect.top,eax
			sub		rect.bottom,eax
			mov		fSnpResize,0
			invoke LoadCursor,0,IDC_ARROW
			mov		hCur,eax
			mov		eax,pt.y
			.if eax>rect.top && eax<rect.bottom
				mov		eax,rect.right
				mov		rect.left,eax
				add		eax,4
				mov		rect.right,eax
				mov		eax,pt.x
				.if eax>rect.left && eax<rect.right
					m2m		hCur,hSplitCurV
					mov		fSnpResize,1
				.endif
			.endif
			invoke SetCursor,hCur
		.else
			mov		eax,rect.top
			sub		rect.bottom,eax
			mov		eax,pt.x
			.if eax<50 || eax>8000h
				mov		eax,50
			.elseif eax>wwt
				mov		eax,wwt
			.endif
			add		eax,pt1.x
			mov		rect.left,eax
			invoke MoveWindow,hTlt,rect.left,rect.top,2,rect.bottom,TRUE
		.endif
	.elseif eax==WM_LBUTTONDOWN
		.if fSnpResize==1
			invoke SetCursor,hSplitCurV
			invoke SetCapture,hWin
			mov		fSnpResize,2
			invoke ShowWindow,hTlt,SW_SHOWNA
		.endif
	.elseif eax==WM_LBUTTONUP
		.if fSnpResize==2
			invoke GetClientRect,hWin,addr rect
			mov		eax,rect.right
			sub		eax,50
			mov		wwt,eax
			invoke ShowWindow,hTlt,SW_HIDE
			invoke ReleaseCapture
			mov		fSnpResize,0
			mov		eax,lParam
			and		eax,0FFFFh
			.if eax<50 || eax>8000h
				mov		eax,50
			.elseif eax>wwt
				mov		eax,wwt
			.endif
			mov		pt.x,eax
			mov		pt1.x,0
			mov		pt1.y,0
			invoke ClientToScreen,hWin,addr pt1
			invoke GetDlgItem,hWin,IDC_TRVSNIPLET
			mov		hCtl,eax
			invoke GetWindowRect,hCtl,addr rect
			mov		eax,pt.x
			sub		eax,2
			mov		rect.right,eax
			mov		eax,pt1.x
			sub		rect.left,eax
			mov		eax,pt1.y
			sub		rect.top,eax
			sub		rect.bottom,eax
			mov		eax,rect.left
			sub		rect.right,eax
			mov		eax,rect.right
			mov		SnipSplit,eax
			mov		eax,rect.top
			sub		rect.bottom,eax
			invoke MoveWindow,hCtl,rect.left,rect.top,rect.right,rect.bottom,TRUE
			invoke GetDlgItem,hWin,IDC_REDSNIPLET
			mov		hCtl,eax
			invoke GetWindowRect,hCtl,addr rect
			mov		eax,pt.x
			add		eax,2
			mov		rect.left,eax
			mov		eax,pt1.x
			sub		rect.right,eax
			mov		eax,pt1.y
			sub		rect.top,eax
			sub		rect.bottom,eax
			mov		eax,rect.left
			sub		rect.right,eax
			mov		eax,rect.top
			sub		rect.bottom,eax
			invoke MoveWindow,hCtl,rect.left,rect.top,rect.right,rect.bottom,TRUE
		.endif
	.elseif eax==WM_NOTIFY
		.if wParam==IDC_TRVSNIPLET
			mov		edx,lParam
			mov		eax,(NMTREEVIEW ptr [edx]).hdr.code
			.if eax==TVN_SELCHANGEDW || eax==TVN_SELCHANGED
				lea		edx,(NMTREEVIEW ptr [edx]).itemNew
				mov		(TV_ITEMEX ptr [edx]).imask,TVIF_PARAM or TVIF_TEXT
				lea		eax,buffer
				mov		(TV_ITEMEX ptr [edx]).pszText,eax
				mov		(TV_ITEMEX ptr [edx]).cchTextMax,sizeof buffer
				mov		buffer1[0],0
				mov		buffer1[1],0
			  @@:
				push	edx
				invoke SendDlgItemMessage,hWin,IDC_TRVSNIPLET,TVM_GETITEM,0,edx
				invoke strcat,addr buffer,addr buffer1
				invoke strcpy,addr buffer1[1],addr buffer
				mov		buffer1[0],'\'
				pop		edx
				mov		eax,(TV_ITEMEX ptr [edx]).lParam
				.if eax
					mov		(TV_ITEMEX ptr [edx]).hItem,eax
					jmp		@b
				.endif
				invoke strcpy,addr buffer,addr Snp
				invoke strcat,addr buffer,addr buffer1
				invoke strcmp,addr buffer,addr szFile
				.if eax
					invoke GetDlgItem,hWin,IDC_REDSNIPLET
					mov		hCtl,eax
					invoke strcpy,addr szFile,addr buffer
					invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						mov		hFile,eax
						invoke SendMessage,hCtl,WM_SETTEXT,0,0
						;stream the text into the richedit control
						m2m		editstream.dwCookie,hFile
						mov		editstream.pfnCallback,offset StreamInProc
						invoke SendMessage,hCtl,EM_STREAMIN,SF_TEXT,addr editstream
						invoke CloseHandle,hFile
						invoke SendMessage,hCtl,EM_SETMODIFY,FALSE,0
						invoke SendMessage,hCtl,EM_SETSEL,0,0
						invoke GetDlgItem,hWin,IDC_BTNOPEN
						invoke EnableWindow,eax,TRUE
					.else
						invoke SetWindowText,hCtl,addr szNULL
						invoke GetDlgItem,hWin,IDC_BTNOPEN
						invoke EnableWindow,eax,FALSE
					.endif
				.endif
			.elseif eax==NM_DBLCLK
				invoke GetDlgItem,hWin,IDC_BTNOPEN
				invoke IsWindowEnabled,eax
				.if eax
					.if fSelectAll
						invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,EM_SETSEL,0,-1
					.endif
					invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,EM_EXGETSEL,0,addr chrg
					mov		eax,chrg.cpMax
					sub		eax,chrg.cpMin
					.if eax
						.if nCopyTo==0
							.if hEdit
								invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,WM_COPY,0,0
								invoke SendMessage,hEdit,WM_PASTE,0,0
							.endif
						.elseif nCopyTo==1
							invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,WM_COPY,0,0
						.elseif nCopyTo==2
							invoke SendDlgItemMessage,hWin,IDC_REDSNIPLET,WM_COPY,0,0
							invoke OutputSelect,2
							invoke SendMessage,hOutREd,WM_PASTE,0,0
						.endif
					.endif
					.if fClose
						invoke SendMessage,hWin,WM_CLOSE,0,0
					.endif
				.endif
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

SnipletsProc endp

