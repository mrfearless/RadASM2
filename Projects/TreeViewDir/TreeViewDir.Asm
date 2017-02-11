.386
.model flat,stdcall
option casemap:none

include TreeViewDir.Inc

.code

start:

	invoke GetModuleHandle,NULL
	mov    hInstance,eax
	invoke GetCommandLine
	invoke InitCommonControls
	invoke LoadLibrary,addr RichEditDLL
	mov		hRichEdDLL,eax
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
	push	eax
	invoke FreeLibrary,hRichEdDLL
	pop		eax
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,SIZEOF WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,OFFSET WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,OFFSET MenuName
	mov		wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,hInst,IDI_MAINICO
	mov		hIcon,eax
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,hInst,IDC_VSPLITCUR
	mov		hSCur,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		hACur,eax
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,addr DlgName,NULL,OFFSET WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

StreamInProc proc hFile:DWORD,pBuffer:DWORD,NumBytes:DWORD,pBytesRead:DWORD
	invoke ReadFile,hFile,pBuffer,NumBytes,pBytesRead,0
	xor		eax,1
	ret

StreamInProc endp

StreamOutProc proc hFile:DWORD,pBuffer:DWORD,NumBytes:DWORD,pBytesWritten:DWORD
	invoke WriteFile,hFile,pBuffer,NumBytes,pBytesWritten,0
	xor		eax,1
	ret

StreamOutProc endp

SetWinCaption proc
	LOCAL	buffer[sizeof AppName+3+MAX_PATH]:BYTE
	LOCAL	buffer1[4]:BYTE

	;Add filename to windows caption
	invoke lstrcpy,addr buffer,addr AppName
	mov		eax,' - '
	mov		dword ptr buffer1,eax
	invoke lstrcat,addr buffer,addr buffer1
	invoke lstrcat,addr buffer,addr FileName
	invoke SetWindowText,hWnd,addr buffer
	ret

SetWinCaption endp

TrvAddNode proc hPar:DWORD,lpPth:DWORD,nImg:DWORD
	LOCAL	tvins:TV_INSERTSTRUCT

	mov		eax,hPar
    mov		tvins.hParent,eax
    ;Saveing hPar simplifies building path
    ;when user selects an item
    mov		tvins.item.lParam,eax
    mov		tvins.hInsertAfter,0
    mov		tvins.item.imask,TVIF_TEXT or TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE
	mov		eax,lpPth
	mov		tvins.item.pszText,eax
	mov		eax,nImg
    mov		tvins.item.iImage,eax
    mov		tvins.item.iSelectedImage,eax
    invoke SendMessage,hTrv,TVM_INSERTITEM,0,addr tvins
    ret

TrvAddNode endp

TrvDir proc uses ebx,hPar:DWORD,lpPth:DWORD
	LOCAL	buffer[128]:BYTE
	LOCAL	hwfd:DWORD
	LOCAL	hpar:DWORD

	;Make the path local
	invoke lstrcpy,addr buffer,lpPth
	;Check if path ends with '\'. If not add.
	invoke lstrlen,addr buffer
	dec		eax
	.if buffer[eax]!='\'
		invoke lstrcat,addr buffer,addr szBS
	.endif
	;Add '*.*'
	invoke lstrcat,addr buffer,addr szAPA
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
				invoke TrvAddNode,hPar,addr wfd.cFileName,IMG_FOLDER
				mov		hpar,eax
				invoke lstrlen,addr buffer
				mov		edx,eax
				push	edx
				sub		edx,3
				;Do not remove the '\'
				.if buffer[edx]=='\'
					inc		edx
				.endif
				;Add new dir to path
				invoke lstrcpy,addr buffer[edx],addr wfd.cFileName
				;Call myself again
				invoke TrvDir,hpar,addr buffer
				pop		edx
				;Remove what was added
				mov		buffer[edx],0
			.endif
		.else
			;Add file
			invoke lstrlen,addr szRoot
			mov		ebx,eax
			inc		ebx
			invoke lstrlen,addr buffer[ebx]
			sub		eax,2
			invoke lstrcpyn,addr FileName,addr buffer[ebx],eax
			invoke lstrcat,addr FileName,addr wfd.cFileName
			invoke lstrcat,addr FileName,addr szCRLF
			invoke SendMessage,hREd,EM_REPLACESEL,FALSE,addr FileName
			;Some file filtering could be done here
			invoke TrvAddNode,hPar,addr wfd.cFileName,IMG_FILE
		.endif
		;Any more matches?
		invoke FindNextFile,hwfd,addr wfd
		or		eax,eax
		jne		Next
		;No more matches, close handle
		invoke FindClose,hwfd
	.endif
	;Sort the children
	invoke SendMessage,hTrv,TVM_SORTCHILDREN,0,hPar
	;Expand the tree
	invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,hPar
	ret

TrvDir endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	pt1:POINT
	LOCAL	hCur:DWORD
	LOCAL	hBmp:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	lpht:TV_HITTESTINFO
	LOCAL	lptvi:TV_ITEM
	LOCAL	hFile:DWORD
	LOCAL   editstream:EDITSTREAM

	.if uMsg==WM_INITDIALOG
		;Save handle of dialog
		push	hWin
		pop		hWnd
		;Create an imagelist
		invoke ImageList_Create,16,16,ILC_COLOR8,5,5
		mov		hIml,eax
		;Add images
		invoke LoadBitmap,hInstance,IDB_TRVBITMAP
		mov		hBmp,eax
	    invoke ImageList_Add,hIml,hBmp,NULL
	    invoke DeleteObject,hBmp
		;Create a static with border
		;This will be used for resize bar
		invoke CreateWindowEx,NULL,addr szStatic,NULL,WS_POPUP or WS_BORDER,0,0,0,0,hWin,NULL,hInstance,0
		mov		hStc,eax
		;Get handle of RichEdit window
		invoke GetDlgItem,hWin,IDC_RED
		mov		hREd,eax
		;Get handle of TreeView window
		invoke GetDlgItem,hWin,IDC_TRV
		mov		hTrv,eax
		invoke SendMessage,hTrv,TVM_SETIMAGELIST,0,hIml
	.elseif uMsg==WM_COMMAND
		mov eax,wParam
		and		eax,0FFFFh
		.if eax==IDOK
			invoke GetDlgItemText,hWin,1003,addr szRoot,sizeof szRoot
			;Delete all items
			invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
			invoke SendMessage,hTrv,TVM_DELETEITEM,0,eax
			invoke SendMessage,hREd,WM_SETTEXT,0,0
			;Add root to TreeViev
			invoke TrvAddNode,0,addr szRoot,IMG_DRIVE
			;Save returned root node
			push	eax
			;Fill TreeView with dir info
			invoke TrvDir,eax,addr szRoot
			;Expand the root node
			pop		eax
			invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,eax
			invoke SetFocus,hTrv
		.elseif eax==IDM_FILE_EXIT
			invoke SendMessage,hWin,WM_CLOSE,0,0
		.elseif eax==IDM_HELP_ABOUT
			invoke ShellAbout,hWin,addr AppName,addr AboutMsg,hIcon
		.endif
    .elseif uMsg==WM_MOUSEMOVE
    	mov		eax,lParam
   		and		eax,0FFFFh
   		mov		pt.x,eax
   		mov		eax,lParam
   		shr		eax,16
   		mov		pt.y,eax
		mov		pt1.x,0
		mov		pt1.y,0
		invoke ClientToScreen,hWin,addr pt1
		invoke GetWindowRect,hTrv,addr rect
		.if fResize<2
			;Still in cur move state
			;Reset resize state flag
			mov		fResize,0
			;Set hCur to ArrowCursor
			mov		eax,hACur
			mov		hCur,eax
			;Check if cur is on resize area
			;Check if cur on resize Y-dir
			mov		eax,pt1.x
			sub		rect.left,eax
			sub		rect.right,eax
			mov		eax,pt1.y
			sub		rect.top,eax
			sub		rect.bottom,eax
			mov		eax,pt.y
			.if eax>rect.top && eax<rect.bottom
				;Check if cur on resize X-dir
				mov		eax,rect.right
				mov		rect.left,eax
				;The width of resize bar is 4
				add		eax,4
				mov		rect.right,eax
				mov		eax,pt.x
				.if eax>rect.left && eax<rect.right
					;Set flag indicating cur on resize
					mov		fResize,1
					;Set hCur to VSplittCursor
					mov		eax,hSCur
					mov		hCur,eax
				.endif
			.endif
			invoke SetCursor,hCur
		.else
			;State is resize in progress
			;Move the resize bar
			mov		eax,rect.top
			sub		rect.bottom,eax
			mov		eax,pt.x
    		.if eax<50 || eax>=8000h
    			mov		eax,50
    		.elseif eax>550
    			mov		eax,550
    		.endif
			add		eax,pt1.x
			mov		rect.left,eax
			invoke MoveWindow,hStc,rect.left,rect.top,2,rect.bottom,TRUE
			;Force repaint of RichEdit
			invoke SendMessage,hREd,WM_PAINT,0,0
			;and TreeView
			invoke SendMessage,hTrv,WM_PAINT,0,0
		.endif
    .elseif uMsg==WM_LBUTTONDOWN
		.if fResize==1
			;Set flag to resize in progress
			mov		fResize,2
			;Capture cur and show resize bar
			invoke SetCursor,hSCur
			invoke SetCapture,hWin
			invoke ShowWindow,hStc,SW_SHOWNA
		.endif
    .elseif uMsg==WM_LBUTTONUP
		.if fResize==2
			;Reset flag
			mov		fResize,0
			invoke ShowWindow,hStc,SW_HIDE
			invoke ReleaseCapture
			;Do the resizeing
	    	mov		eax,lParam
    		and		eax,0FFFFh
    		;Less than 50 or more than 550 not allowed
    		.if eax<50 || eax>8000h
    			mov		eax,50
    		.elseif eax>550
    			mov		eax,550
    		.endif
    		mov		pt.x,eax
			mov		pt1.x,0
			mov		pt1.y,0
			invoke ClientToScreen,hWin,addr pt1
    		;Calculate new size/pos of TreeView
			invoke GetWindowRect,hTrv,addr rect
			mov		eax,pt.x
			sub		eax,2
			mov		rect.right,eax
			mov		eax,pt1.x
			sub		rect.left,eax
			mov		eax,pt1.y
			sub		rect.top,eax
			sub		rect.bottom,eax
			;Calculate width
			mov		eax,rect.left
			sub		rect.right,eax
			;Calculate height
			mov		eax,rect.top
			sub		rect.bottom,eax
			invoke MoveWindow,hTrv,rect.left,rect.top,rect.right,rect.bottom,TRUE
			;Calculate new size/pos of RichEdit
			invoke GetWindowRect,hREd,addr rect
			mov		eax,pt.x
			add		eax,2
			mov		rect.left,eax
			mov		eax,pt1.x
			sub		rect.right,eax
			mov		eax,pt1.y
			sub		rect.top,eax
			sub		rect.bottom,eax
			;Calculate width
			mov		eax,rect.left
			sub		rect.right,eax
			;Calculate height
			mov		eax,rect.top
			sub		rect.bottom,eax
			invoke MoveWindow,hREd,rect.left,rect.top,rect.right,rect.bottom,TRUE
		.endif
    .elseif uMsg==WM_NOTIFY
		.if wParam==IDC_TRV
			mov		edx,lParam
			mov		eax,(NM_TREEVIEW ptr [edx]).hdr.code
			.if eax==TVN_SELCHANGED
				;User changed selection in TreeView
				lea		edx,(NM_TREEVIEW ptr [edx]).itemNew
				mov		(TV_ITEM ptr [edx]).imask,TVIF_PARAM or TVIF_TEXT or TVIF_IMAGE
				lea		eax,buffer
				mov		(TV_ITEM ptr [edx]).pszText,eax
				mov		(TV_ITEM ptr [edx]).cchTextMax,sizeof buffer
				;check if item is a file
				push	edx
				invoke SendMessage,hTrv,TVM_GETITEM,0,edx
				pop		edx
				mov		eax,(TV_ITEM ptr [edx]).iImage
				.if eax==IMG_FILE
					;Build the path backwards
					;Zero out buffer1
					mov		buffer1[0],0
				  @@:
					push	edx
					invoke SendMessage,hTrv,TVM_GETITEM,0,edx
					;Check if it ends with '\'
					invoke lstrlen,addr buffer
					dec		eax
					.if buffer[eax]=='\'
						;Ends with '\', remove it
						mov		buffer[eax],0
					.endif
					;Add what's in buffer1
					invoke lstrcat,addr buffer,addr buffer1
					;Add '\' at start and copy back to buffer1
					mov		buffer1[0],'\'
					invoke lstrcpy,addr buffer1[1],addr buffer
					pop		edx
					;Check if at root
					mov		eax,(TV_ITEM ptr [edx]).lParam
					.if eax
						;Not at root yet
						mov		(TV_ITEM ptr [edx]).hItem,eax
						jmp		@b
					.endif
					;Check if it's same as last selection
					invoke lstrcmp,addr buffer,addr FileName
					.if eax
						;Not same, show content
						invoke lstrcpy,addr FileName,addr buffer
						invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
						.if eax!=INVALID_HANDLE_VALUE
							mov		hFile,eax
							invoke SendMessage,hREd,WM_SETTEXT,0,addr szNULL
							;stream the text into the richedit control
							mov		eax,hFile
							mov		editstream.dwCookie,eax
							mov		editstream.pfnCallback,offset StreamInProc
							invoke SendMessage,hREd,EM_STREAMIN,SF_TEXT,addr editstream
							invoke CloseHandle,hFile
							invoke SetWinCaption
						.endif
					.endif
				.endif
			.endif
		.endif
	.elseif uMsg==WM_CLOSE
		invoke DestroyWindow,hWin
	.elseif uMsg==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

end start
