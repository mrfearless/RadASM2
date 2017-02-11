comment !

#########################################################################

	RadASM (C) KetilO 2001-2009
!

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	mov		osvi.dwOSVersionInfoSize,sizeof OSVERSIONINFO
	invoke GetVersionEx,offset osvi
	.if osvi.dwPlatformId == VER_PLATFORM_WIN32_NT
		mov		fNT,TRUE
	.endif
	invoke GetCommandLine
	mov		CommandLine,eax
	;Get command line filename
	invoke PathGetArgs,CommandLine
	mov		CommandLine,eax
	invoke iniRead
	.if !eax
		.if SingleInstance
			invoke FindWindow,addr MdiClassName,NULL
			.if eax
				mov		hWnd,eax
				invoke IsIconic,hWnd
				.if eax
					invoke ShowWindow,hWnd,SW_RESTORE
				.endif
				;Get command line filename
				mov		edx,CommandLine
				mov		al,[edx]
				.if al!=0
					mov		cpd.dwData,0
					m2m		cpd.lpData,edx
					invoke strlen,edx
					inc		eax
					mov		cpd.cbData,eax
					invoke SendMessage,hWnd,WM_COPYDATA,0,offset cpd
				.endif
				invoke ExitProcess,0
			.endif
		.endif
		mov		fSearchAll,TRUE
		invoke LoadLibrary,addr RichEditDLL
		.if eax
			mov		hRichEdit,eax
			invoke LoadLibrary,addr RAEditDLL
			.if eax
				mov		hRAEdit,eax
				invoke LoadLibrary,addr RAHexEdDLL
				.if eax
					mov		hRAHexEd,eax
					invoke LoadLibrary,addr RAGridDLL
					.if eax
						mov		hRAGrid,eax
						invoke GetProcAddress,hRAEdit,offset szGetCharTabPtr
						call	eax
						mov		lpCharTab,eax
						invoke InitCommonControls
						;prepare common control structure
						mov		icex.dwSize,sizeof INITCOMMONCONTROLSEX
						mov		icex.dwICC,ICC_DATE_CLASSES or ICC_USEREX_CLASSES or ICC_INTERNET_CLASSES or ICC_ANIMATE_CLASS or ICC_HOTKEY_CLASS or ICC_PAGESCROLLER_CLASS or ICC_COOL_CLASSES
						invoke InitCommonControlsEx,addr icex
						invoke ConvertFile,addr lngFile
						invoke OleInitialize,NULL
						invoke xGlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,WRDMEM
						mov		hWordList,eax
						invoke GlobalLock,eax
						mov     lpWordList,eax
						xor		eax,eax
						mov		rpProjectWordList,eax
						mov		rpWordListPos,eax
						mov		WordListSize,WRDMEM
						invoke GetRecentFiles
						invoke UpdateMRU
						invoke iniHook
						invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
						push	eax
						push	edi
						mov		edi,offset hAddins
						mov		eax,MAX_ADDIN
						.while eax
							push	eax
							mov		eax,[edi].ADDIN.hDLL
							.if eax
								invoke FreeLibrary,eax
							.endif
							pop		eax
							add		edi,sizeof ADDIN
							dec		eax
						.endw
						mov		edi,offset CustCtrl
						mov		eax,32
						.while eax
							push	eax
							mov		eax,[edi].CUSTCTRL.hDll
							.if eax
								invoke FreeLibrary,eax
							.endif
							pop		eax
							add		edi,sizeof CUSTCTRL
							dec		eax
						.endw
						pop		edi
						invoke GlobalUnlock,hWordList
						invoke GlobalFree,hWordList
						;Environment
						.if hEnv
							invoke GlobalUnlock,hEnv
							invoke GlobalFree,hEnv
						.endif
						.if hCodeDefs
							invoke GlobalFree,hCodeDefs
						.endif
						invoke DestroyIcon,hIcon
						invoke DestroyCursor,hSplitCurV
						invoke DestroyCursor,hSplitCurH
						invoke DeleteObject,hFont
						invoke DeleteObject,hFont[4]
						invoke DeleteObject,hFont[8]
						invoke DeleteObject,hFontHex
						invoke DeleteObject,hLBFont
						invoke DeleteObject,hTTFont
						invoke DeleteObject,hFontTxt
						invoke DeleteObject,hFontIde
						invoke DestroyAcceleratorTable,hAccel
						invoke OleUninitialize
						invoke FreeLibrary,hRichEdit
						invoke FreeLibrary,hRAEdit
						invoke FreeLibrary,hRAHexEd
						invoke FreeLibrary,hRAGrid
						.if hParseDll
							invoke FreeLibrary,hParseDll
						.endif
						invoke HeapDestroy,hMainHeap
						pop		eax
					.else
						invoke FreeLibrary,hRichEdit
						invoke FreeLibrary,hRAEdit
						invoke FreeLibrary,hRAHexEd
						invoke MessageBox,0,addr NoRAGrid,addr AppName,MB_OK or MB_ICONERROR
					.endif
				.else
					invoke FreeLibrary,hRichEdit
					invoke FreeLibrary,hRAEdit
					invoke MessageBox,0,addr NoRAHexEd,addr AppName,MB_OK or MB_ICONERROR
				.endif
			.else
				invoke FreeLibrary,hRichEdit
				invoke MessageBox,0,addr NoRAEdit,addr AppName,MB_OK or MB_ICONERROR
			.endif
		.else
			invoke MessageBox,0,addr NoRichEdit,addr AppName,MB_OK or MB_ICONERROR
		.endif
	.endif
	.if hIniMem
		invoke GlobalFree,hIniMem
		mov		hIniMem,0
	.endif
	invoke ExitProcess,0

;#########################################################################

ShowSplash proc
	LOCAL	rect:RECT

	.if Splashtc
		invoke GetSplash
		.if eax
			invoke GetClientRect,hClient,addr rect
			mov		eax,rect.right
			sub		eax,rect.left
			shr		eax,1
			mov		ecx,cxDib
			shr		ecx,1
			sub		eax,ecx
			add		rect.left,eax
			mov		eax,rect.bottom
			sub		eax,rect.top
			shr		eax,1
			mov		ecx,cyDib
			shr		ecx,1
			sub		eax,ecx
			add		rect.top,eax
			invoke CreateWindowEx,WS_EX_TOPMOST or WS_EX_TOOLWINDOW,addr SplashClassName,
					NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_BORDER,
					rect.left,rect.top,cxDib,cyDib,
					hClient,NULL,hInstance,NULL
			mov     hSplash,eax
			invoke ShowWindow,hSplash,SW_SHOWNOACTIVATE
			invoke UpdateWindow,hSplash
		.endif
	.endif
	ret

ShowSplash endp

SplashProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hDC:HDC
	LOCAL	rect:RECT
	LOCAL	ps:PAINTSTRUCT
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE

	.if uMsg==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		mov		hDC,eax
	    .if pbmfh
			invoke DibShow,hDC,pbmi,pBits,cxDib,cyDib,cxClient,cyClient,IDM_SHOW_NORMAL
			mov		nInx,1
		  @@:
			invoke BinToDec,nInx,addr buffer
			invoke GetPrivateProfileString,addr iniSplash,addr buffer,addr szNULL,addr buffer,256,addr iniFile
			.if eax
				invoke iniGetItem,addr buffer,addr buffer1
				mov		eax,cxDib
				mov		rect.right,eax
				invoke DecToBin,addr buffer1
				mov		rect.left,eax
				invoke iniGetItem,addr buffer,addr buffer1
				invoke DecToBin,addr buffer1
				mov		rect.top,eax
				add		eax,20
				mov		rect.bottom,eax
				mov		buffer1,'$'
				mov		buffer1[1],'V'
				mov		buffer1[2],0
				invoke iniInStr,addr buffer,addr buffer1
				.if eax!=-1
					lea		edx,buffer
					add		edx,eax
					invoke strcpy,edx,addr AppName
				.endif
				invoke SetBkMode,hDC,TRANSPARENT
				invoke SetTextColor,hDC,0
				invoke DrawText,hDC,addr buffer,-1,addr rect,DT_NOPREFIX or DT_CENTER
				inc		nInx
				jmp		@b
			.endif
		.endif
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
	ret

SplashProc endp

;########################################################################

OpenCommandLine proc uses ebx,lpCmnd:DWORD
	LOCAL	chrg:CHARRANGE

	mov		ebx,lpCmnd
	.while byte ptr [ebx]
		.while byte ptr [ebx]==' '
			inc		ebx
		.endw
		mov		edx,offset FileName
		.if byte ptr [ebx]=='"'
			inc		ebx
			.while byte ptr [ebx]!='"' && byte ptr [ebx]
				mov		al,[ebx]
				mov		[edx],al
				inc		ebx
				inc		edx
			.endw
			inc		ebx
		.else
			.while byte ptr [ebx]!=' ' && byte ptr [ebx]
				mov		al,[ebx]
				mov		[edx],al
				inc		ebx
				inc		edx
			.endw
		.endif
		mov		byte ptr [edx],0
		.if byte ptr FileName
			mov		edx,offset FileName
			xor		ecx,ecx
			.while byte ptr [edx]
				.if byte ptr [edx]<'0' || byte ptr [edx]>'9'
					inc		ecx
				.endif
				inc		edx
			.endw
			.if hEdit && SingleInstance && !ecx
				invoke DecToBin,offset FileName
				invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
				mov		chrg.cpMin,eax
				mov		chrg.cpMax,eax
				invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
				invoke SendMessage,hEdit,REM_VCENTER,0,0
				invoke SetForegroundWindow,hWnd
				invoke SetFocus,hEdit
			.else
				invoke SendMessage,hWnd,WM_USER+998,0,offset FileName
			.endif
		.endif
	.endw
	ret

OpenCommandLine endp

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	invoke LoadIcon,hInst,IDI_MDIICO
	mov		hIcon,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		hCursor,eax
	invoke LoadCursor,hInst,IDC_SPLICURV
	mov		hSplitCurV,eax
	invoke LoadCursor,hInst,IDC_SPLICURH
	mov		hSplitCurH,eax
	;Mdi Frame
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	m2m		wc.hInstance,hInst
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset MdiClassName
	m2m		wc.hIcon,hIcon
	m2m		wc.hCursor,hCursor
	m2m		wc.hIconSm,hIcon
	invoke RegisterClassEx,addr wc
	;Full screen
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset FullScreenProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	m2m		wc.hInstance,hInst
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset FullScreenClassName
	m2m		wc.hIcon,hIcon
	m2m		wc.hCursor,hCursor
	m2m		wc.hIconSm,hIcon
	invoke RegisterClassEx,addr wc
	;Mdi Edit Child
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset EditChildProc
	mov		wc.cbClsExtra,NULL
	;GWL_USERDATA=hEdit,GWL_ID>=ID_FIRSTCHILD
	;0=ID_EDIT or ID_EDITTXT, 4=, 8=, 12=Changed since last property update
	;16=Project file ID, 20=Overwrite, 28=hRadMem
	mov		wc.cbWndExtra,32
	m2m		wc.hInstance,hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1;NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset EditCldClassName
	m2m		wc.hIcon,hIcon
	m2m		wc.hCursor,hCursor
	m2m		wc.hIconSm,hIcon
	invoke RegisterClassEx,addr wc
	;Mdi Dialog Child
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset DialogChildProc
	mov		wc.cbClsExtra,NULL
	;GWL_USERDATA=hDialog,GWL_ID>=ID_FIRSTCHILD
	;0=ID_DIALOG, 4=hMem, 8=ReadOnly
	;16=Pfoject file ID, 20=ScrollX
	;24=ScrollY, 28=hRadMem
	mov		wc.cbWndExtra,32
	m2m		wc.hInstance,hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset DialogCldClassName
	m2m		wc.hIcon,hIcon
	m2m		wc.hCursor,hCursor
	m2m		wc.hIconSm,hIcon
	invoke RegisterClassEx,addr wc
	;Mdi HexEd Child
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset HexEdChildProc
	mov		wc.cbClsExtra,NULL
	;GWL_USERDATA=hHexEd,GWL_ID>=ID_FIRSTCHILD
	;0=ID_EDITHEX, 4=, 8=, 12=
	;16=Pfoject file ID, 20=, 28=hRadMem
	mov		wc.cbWndExtra,32
	m2m		wc.hInstance,hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1;NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset HexEdCldClassName
	m2m		wc.hIcon,hIcon
	m2m		wc.hCursor,hCursor
	m2m		wc.hIconSm,hIcon
	invoke RegisterClassEx,addr wc
	;Tool windows
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset ToolWndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	m2m		wc.hInstance,hInst
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szToolClass
	m2m		wc.hIcon,NULL
	m2m		wc.hCursor,hCursor
	m2m		wc.hIconSm,NULL
	invoke RegisterClassEx,addr wc
	;Tool child windows
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset ToolCldProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	m2m		wc.hInstance,hInst
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szToolCldClass
	m2m		wc.hIcon,NULL
	m2m		wc.hCursor,hCursor
	m2m		wc.hIconSm,NULL
	invoke RegisterClassEx,addr wc
	;Dialog Edit Window
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset EditDlgProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	m2m		wc.hInstance,hInst
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset DlgEditClass
	m2m		wc.hIcon,NULL
	m2m		wc.hCursor,hCursor
	m2m		wc.hIconSm,NULL
	invoke RegisterClassEx,addr wc
	;Folder User control
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset UdcProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset UdcClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	;Splash screen
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset SplashProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset SplashClassName
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset DesignDummyProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,NULL
	push	hInstance
	pop		wc.hInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset DlgEditDummyClass
	mov		wc.hIcon,NULL
	mov		wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc

	mov     eax,WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
	mov		edx,WS_EX_LEFT or WS_EX_ACCEPTFILES
	.if winT
		or		edx,WS_EX_TOPMOST
	.endif
	invoke CreateWindowEx,edx,addr MdiClassName,addr DisplayName,eax,winX,winY,winWt,winHt,NULL,NULL,hInst,NULL
	mov     hWnd,eax
	mov     eax,SW_SHOWNORMAL
	.if winM
		mov     eax,SW_SHOWMAXIMIZED
	.endif
	invoke ShowWindow,hWnd,eax
	invoke UpdateWindow,hWnd
	invoke ShowSplash
	;Get command line filename
	mov		eax,CommandLine
	.if byte ptr [eax]
		invoke OpenCommandLine,CommandLine
	.elseif ProMenuID && fAutoLoadPro
		invoke SendMessage,hWnd,WM_COMMAND,ProMenuID,0
	.endif
	.while TRUE
		invoke GetMessage,addr msg,0,0,0
	  .break .if !eax
		invoke IsDialogMessage,hSearch,addr msg
		.if !eax
			invoke IsDialogMessage,hGoTo,addr msg
			.if !eax
				invoke IsDialogMessage,hSniplet,addr msg
				.if !eax
					invoke TranslateAccelerator,hWnd,hAccel,addr msg
					.if !eax
						invoke TranslateMessage,addr msg
						invoke DispatchMessage,addr msg
					.endif
				.endif
			.endif
		.endif
	.endw
	mov   eax,msg.wParam
	ret

WinMain endp

;#########################################################################

GetActive proc
	LOCAL	hCld:HWND

	invoke SendMessage,hClient,WM_MDIGETACTIVE,0,addr fMaximized
	mov     hMdiCld,eax
	mov     hEdit,0
	mov     hDialog,0
	.if eax
		invoke GetWindowLong,hMdiCld,GWL_USERDATA
		mov		hCld,eax
		.if hCld
			invoke GetWindowLong,hCld,GWL_ID
			.if eax==ID_EDIT || eax==ID_EDITTXT
				m2m     hEdit,hCld
			.elseif eax==ID_DIALOG
				m2m     hDialog,hCld
			.endif
		.endif
	.endif
	mov		eax,hMdiCld
	ret

GetActive endp

;#########################################################################

MenuStatus proc uses ebx
	LOCAL	chrg:CHARRANGE
	LOCAL	val:DWORD
	LOCAL	ro:DWORD

	invoke GetActive
	.if fProject
		;Project
		invoke EnableMenuItem,hMenu,IDM_FILE_CLOSEPROJECT,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_DELETEPROJECT,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_ADDNEW,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_ADDEXISTING,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_ADDEXISTINGOPEN,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_SET_ASSEMBLER,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_ACCELERATOR,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_RESOURCE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_STRINGTABLE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_VERINF,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_LANGUAGE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_GROUPS,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_SCANPROJECT,MF_ENABLED
		.if hEdit || hDialog
			invoke GetWindowLong,hMdiCld,16
			.if !eax
				invoke EnableMenuItem,hMenu,IDM_PROJECT_ADDEXISTINGOPEN,MF_ENABLED
			.endif
			invoke EnableMenuItem,hMenu,IDM_PROJECT_REMOVE,MF_ENABLED
		.else
			invoke EnableMenuItem,hMenu,IDM_PROJECT_REMOVE,MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_PROJECT_TEMPLATE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_OPTIONS,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_MAINFILES,MF_ENABLED
		.if hEdit
			invoke GetWindowLong,hEdit,GWL_STYLE
			and		eax,STYLE_READONLY
			.if eax
				invoke EnableMenuItem,hMenu,IDM_PROJECT_TLINK,MF_GRAYED
			.else
				invoke EnableMenuItem,hMenu,IDM_PROJECT_TLINK,MF_ENABLED
			.endif
		.else
			invoke EnableMenuItem,hMenu,IDM_PROJECT_TLINK,MF_GRAYED
		.endif
		.if !hDialog
			invoke EnableMenuItem,hMenu,IDM_PROJECT_REFRESH,MF_ENABLED
		.else
			invoke EnableMenuItem,hMenu,IDM_PROJECT_REFRESH,MF_GRAYED
		.endif
	.else
		;No project
		invoke EnableMenuItem,hMenu,IDM_FILE_CLOSEPROJECT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FILE_DELETEPROJECT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_ADDNEW,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_ADDEXISTING,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_SET_ASSEMBLER,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_ACCELERATOR,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_RESOURCE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_STRINGTABLE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_VERINF,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_LANGUAGE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_GROUPS,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_SCANPROJECT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_EXPORTTOOUTPUT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_REMOVE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_TEMPLATE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_OPTIONS,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_MAINFILES,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_TLINK,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_REFRESH,MF_GRAYED
	.endif
	.if hEdit
		invoke EnableMenuItem,hMenu,IDM_FILE_PRINT,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_REOPENFILE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_CLOSEFILE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEFILE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEFILEAS,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEALLFILES,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDNEXT,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDPREVIOUS,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_SELECTALL,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_GOTOLINE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_EXPANDBLOCK,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_REPLACE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDWORD,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND_NEXT_WORD,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND_PREV_WORD,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDPROC,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_TOGGLEBM,MF_ENABLED
		invoke SendMessage,hEdit,REM_GETMODE,0,0
		and		eax,MODE_BLOCK
		push	eax
		.if !eax
			mov		eax,MF_BYCOMMAND or MF_UNCHECKED
		.else
			mov		eax,MF_BYCOMMAND or MF_CHECKED
		.endif
		invoke CheckMenuItem,hMenu,IDM_EDIT_BLOCKMODE,eax
		invoke EnableMenuItem,hMenu,IDM_EDIT_BLOCKMODE,MF_ENABLED
		pop		eax
		.if !eax
			mov		eax,MF_BYCOMMAND or MF_GRAYED
		.else
			mov		eax,MF_BYCOMMAND or MF_ENABLED
		.endif
		invoke EnableMenuItem,hMenu,IDM_EDIT_BLOCK_INSERT,eax
		invoke EnableMenuItem,hMenu,IDM_EDIT_OPEN,MF_ENABLED
		.if fProject
			mov		eax,MF_BYCOMMAND or MF_ENABLED
		.else
			mov		eax,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_EDIT_TOGGLEBP,eax
		invoke IsBookMark,hEdit,Line
		.if eax>1 && eax<3
			mov		eax,MF_BYCOMMAND or MF_ENABLED
		.else
			mov		eax,MF_BYCOMMAND or MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_EDIT_ADDVAR,eax
		mov		eax,RetPos
		.if eax
			invoke EnableMenuItem,hMenu,IDM_EDIT_RETURN,MF_ENABLED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_RETURN,MF_GRAYED
		.endif
		;Check whether there is some text in the clipboard. If so, we enable the paste menuitem
		invoke SendMessage,hEdit,EM_CANPASTE,CF_TEXT,0
		.if eax==0
			;no text in the clipboard
			invoke EnableMenuItem,hMenu,IDM_EDIT_PASTE,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_PASTE,MF_ENABLED
		.endif
		;check whether the undo queue is empty
		invoke SendMessage,hEdit,EM_CANUNDO,0,0
		mov		val,eax
		.if !eax
			invoke EnableMenuItem,hMenu,IDM_EDIT_UNDO,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_UNDO,MF_ENABLED
		.endif
		;check whether the redo queue is empty
		invoke SendMessage,hEdit,EM_CANREDO,0,0
		or		val,eax
		.if !eax
			invoke EnableMenuItem,hMenu,IDM_EDIT_REDO,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_REDO,MF_ENABLED
		.endif
		.if !val
			invoke EnableMenuItem,hMenu,IDM_EDIT_EMPTY_UNDO,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_EMPTY_UNDO,MF_ENABLED
		.endif
		;check whether there is a current selection in the richedit control.
		;If there is, we enable the cut/copy/delete menuitem
		invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
		mov eax,chrg.cpMax
		sub eax,chrg.cpMin
		.if eax==0
			;no current selection
			invoke EnableMenuItem,hMenu,IDM_EDIT_COPY,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_CUT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_DELETE,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_INDENT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_OUTDENT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_COMMENT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_UNCOMMENT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_CONVERT,MF_GRAYED
			invoke SendMessage,hEdit,REM_GETBOOKMARK,Line,0
			.if eax==8 || eax==9
				invoke EnableMenuItem,hMenu,IDM_EDIT_HIDEBLOCK,MF_ENABLED
			.else
				invoke EnableMenuItem,hMenu,IDM_EDIT_HIDEBLOCK,MF_GRAYED
			.endif
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_COPY,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_EDIT_CUT,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_EDIT_DELETE,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_INDENT,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_OUTDENT,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_COMMENT,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_UNCOMMENT,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_EDIT_HIDEBLOCK,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_CONVERT,MF_ENABLED
		.endif
		invoke EnableMenuItem,hMenu,IDM_FORMAT_LOCKCONTROLS,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SENDTOBACK,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_BRINGTOFRONT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SHOWGRID,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_ALIGN,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SIZE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_CENTER,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_TABINDEX,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_EXPORTTOOUTPUT,MF_GRAYED
		invoke GetWindowLong,hEdit,GWL_STYLE
		and		eax,STYLE_READONLY
		.if eax
			invoke EnableMenuItem,hMenu,IDM_EDIT_CUT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_PASTE,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_DELETE,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_REPLACE,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_INDENT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_OUTDENT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_COMMENT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_UNCOMMENT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_HIDEBLOCK,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_CONVERT,MF_GRAYED
		.endif
	.elseif hDialog
		invoke EnableMenuItem,hMenu,IDM_FILE_PRINT,MF_GRAYED
		invoke GetWindowLong,hMdiCld,8
		mov		ro,eax
		invoke EnableMenuItem,hMenu,IDM_FILE_REOPENFILE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_CLOSEFILE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEFILE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEFILEAS,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEALLFILES,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_EMPTY_UNDO,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_SELECTALL,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDNEXT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDPREVIOUS,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_GOTOLINE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_EXPANDBLOCK,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_REPLACE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDWORD,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND_NEXT_WORD,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND_PREV_WORD,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDPROC,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_RETURN,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_TOGGLEBM,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_TOGGLEBP,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_ADDVAR,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_BLOCKMODE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_BLOCK_INSERT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_OPEN,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_EXPORTTOOUTPUT,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_INDENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_OUTDENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_COMMENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_UNCOMMENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_HIDEBLOCK,MF_GRAYED
		.if ro
			invoke EnableMenuItem,hMenu,IDM_FORMAT_LOCKCONTROLS,MF_GRAYED
			invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_LOCKCONTROLS,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_FORMAT_LOCKCONTROLS,MF_ENABLED
			invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_LOCKCONTROLS,MF_ENABLED
		.endif
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SHOWGRID,MF_ENABLED
		mov		eax,dlgpaste.hwnd
		.if eax && !ro
			invoke EnableMenuItem,hMenu,IDM_EDIT_PASTE,MF_ENABLED
			invoke EnableMenuItem,hMnuDlg,IDM_EDIT_PASTE,MF_ENABLED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_PASTE,MF_GRAYED
			invoke EnableMenuItem,hMnuDlg,IDM_EDIT_PASTE,MF_GRAYED
		.endif
		invoke GetWindowLong,hMdiCld,4
		mov		eax,(DLGHEAD ptr [eax]).undo
		.if eax && !ro
			invoke EnableMenuItem,hMenu,IDM_EDIT_UNDO,MF_ENABLED
			invoke EnableMenuItem,hMnuDlg,IDM_EDIT_UNDO,MF_ENABLED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_UNDO,MF_GRAYED
			invoke EnableMenuItem,hMnuDlg,IDM_EDIT_UNDO,MF_GRAYED
		.endif
		mov		val,MF_GRAYED
		mov		eax,hReSize
		.if eax
			invoke GetWindowLong,hReSize,GWL_USERDATA
			.if eax
				mov		eax,(DIALOG ptr [eax]).ntype
				.if eax
					mov		val,MF_ENABLED
				.endif
			.endif
		.elseif hMultiSel
			mov		val,MF_ENABLED
		.endif
		invoke EnableMenuItem,hMenu,IDM_EDIT_COPY,val
		invoke EnableMenuItem,hMnuDlg,IDM_EDIT_COPY,val
		.if ro
			mov		val,MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_FORMAT_CENTER,val
		invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_CENTER,val
		invoke EnableMenuItem,hMenu,IDM_EDIT_CUT,val
		invoke EnableMenuItem,hMnuDlg,IDM_EDIT_CUT,val
		invoke EnableMenuItem,hMenu,IDM_EDIT_DELETE,val
		invoke EnableMenuItem,hMnuDlg,IDM_EDIT_DELETE,val
		invoke GetWindowLong,hDialog,GWL_USERDATA
		mov		val,eax
		.if hReSize
			invoke GetWindowLong,hReSize,GWL_USERDATA
		.endif
		.if eax==val || ro || hMultiSel
			invoke EnableMenuItem,hMenu,IDM_FORMAT_SENDTOBACK,MF_GRAYED
			invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_SENDTOBACK,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_BRINGTOFRONT,MF_GRAYED
			invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_BRINGTOFRONT,MF_GRAYED
		.else
			push	eax
			add		val,sizeof DIALOG
			.if eax==val
				invoke EnableMenuItem,hMenu,IDM_FORMAT_SENDTOBACK,MF_GRAYED
				invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_SENDTOBACK,MF_GRAYED
			.else
				invoke EnableMenuItem,hMenu,IDM_FORMAT_SENDTOBACK,MF_ENABLED
				invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_SENDTOBACK,MF_ENABLED
			.endif
			pop		eax
			add		eax,sizeof DIALOG
			.if [eax].DIALOG.hwnd
				invoke EnableMenuItem,hMenu,IDM_FORMAT_BRINGTOFRONT,MF_ENABLED
				invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_BRINGTOFRONT,MF_ENABLED
			.else
				invoke EnableMenuItem,hMenu,IDM_FORMAT_BRINGTOFRONT,MF_GRAYED
				invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_BRINGTOFRONT,MF_GRAYED
			.endif
		.endif
		.if hMultiSel && !ro
			invoke EnableMenuItem,hMenu,IDM_FORMAT_ALIGN,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_SIZE,MF_ENABLED
			invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_ALIGN,MF_ENABLED
			invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_SIZE,MF_ENABLED
		.else
			invoke EnableMenuItem,hMenu,IDM_FORMAT_ALIGN,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_FORMAT_SIZE,MF_GRAYED
			invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_ALIGN,MF_GRAYED
			invoke EnableMenuItem,hMnuDlg,IDM_FORMAT_SIZE,MF_GRAYED
		.endif
		invoke EnableMenuItem,hMenu,IDM_FORMAT_TABINDEX,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_CONVERT,MF_GRAYED
	.elseif hHexEd
		invoke EnableMenuItem,hMenu,IDM_FILE_PRINT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FILE_REOPENFILE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_CLOSEFILE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEFILE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEFILEAS,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEALLFILES,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDNEXT,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDPREVIOUS,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_SELECTALL,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_GOTOLINE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_EXPANDBLOCK,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_REPLACE,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDWORD,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND_NEXT_WORD,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND_PREV_WORD,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDPROC,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_TOGGLEBM,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_TOGGLEBP,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_ADDVAR,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_RETURN,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_BLOCKMODE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_BLOCK_INSERT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_OPEN,MF_GRAYED
		;Check whether there is some text on the clipboard. If so, we enable the paste menuitem
		invoke SendMessage,hHexEd,EM_CANPASTE,CF_TEXT,0
		.if !eax
			;no text in the clipboard
			invoke EnableMenuItem,hMenu,IDM_EDIT_PASTE,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_PASTE,MF_ENABLED
		.endif
		;check whether the undo queue is empty
		invoke SendMessage,hHexEd,EM_CANUNDO,0,0
		mov		val,eax
		.if !eax
			invoke EnableMenuItem,hMenu,IDM_EDIT_UNDO,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_UNDO,MF_ENABLED
		.endif
		;check whether the redo queue is empty
		invoke SendMessage,hHexEd,EM_CANREDO,0,0
		or		val,eax
		.if !eax
			invoke EnableMenuItem,hMenu,IDM_EDIT_REDO,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_REDO,MF_ENABLED
		.endif
		.if !val
			invoke EnableMenuItem,hMenu,IDM_EDIT_EMPTY_UNDO,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_EMPTY_UNDO,MF_ENABLED
		.endif
		;check whether there is a current selection in the richedit control.
		;If there is, we enable the cut/copy/delete menuitem
		invoke SendMessage,hHexEd,EM_EXGETSEL,0,addr chrg
		mov eax,chrg.cpMax
		sub eax,chrg.cpMin
		.if !eax
			;no current selection
			invoke EnableMenuItem,hMenu,IDM_EDIT_COPY,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_CUT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_DELETE,MF_GRAYED
		.else
			invoke EnableMenuItem,hMenu,IDM_EDIT_COPY,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_EDIT_CUT,MF_ENABLED
			invoke EnableMenuItem,hMenu,IDM_EDIT_DELETE,MF_ENABLED
		.endif
		invoke EnableMenuItem,hMenu,IDM_FORMAT_INDENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_OUTDENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_COMMENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_UNCOMMENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_HIDEBLOCK,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_CONVERT,MF_GRAYED

		invoke EnableMenuItem,hMenu,IDM_FORMAT_LOCKCONTROLS,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SENDTOBACK,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_BRINGTOFRONT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SHOWGRID,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_ALIGN,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SIZE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_CENTER,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_TABINDEX,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_EXPORTTOOUTPUT,MF_GRAYED
		invoke GetWindowLong,hHexEd,GWL_STYLE
		and		eax,HES_READONLY
		.if eax
			invoke EnableMenuItem,hMenu,IDM_EDIT_CUT,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_PASTE,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_DELETE,MF_GRAYED
			invoke EnableMenuItem,hMenu,IDM_EDIT_REPLACE,MF_GRAYED
		.endif
	.else
		invoke EnableMenuItem,hMenu,IDM_FILE_PRINT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FILE_REOPENFILE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FILE_CLOSEFILE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEFILE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEFILEAS,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FILE_SAVEALLFILES,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_UNDO,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_REDO,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_EMPTY_UNDO,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_COPY,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_CUT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_PASTE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_DELETE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_SELECTALL,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDNEXT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDPREVIOUS,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_GOTOLINE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_EXPANDBLOCK,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_REPLACE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDWORD,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND_NEXT_WORD,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FIND_PREV_WORD,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_FINDPROC,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_RETURN,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_TOGGLEBM,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_ADDVAR,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_BLOCKMODE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_BLOCK_INSERT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_OPEN,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_TOGGLEBP,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_INDENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_OUTDENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_COMMENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_UNCOMMENT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_HIDEBLOCK,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_LOCKCONTROLS,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SENDTOBACK,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_BRINGTOFRONT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SHOWGRID,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_CONVERT,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_ALIGN,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_SIZE,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_CENTER,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_FORMAT_TABINDEX,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_PROJECT_EXPORTTOOUTPUT,MF_GRAYED
	.endif
	invoke AnyBookMarks
	.if eax
		invoke EnableMenuItem,hMenu,IDM_EDIT_NEXTBM,MF_ENABLED
		invoke EnableMenuItem,hMenu,IDM_EDIT_PREVIOUSBM,MF_ENABLED
	.else
		invoke EnableMenuItem,hMenu,IDM_EDIT_NEXTBM,MF_GRAYED
		invoke EnableMenuItem,hMenu,IDM_EDIT_PREVIOUSBM,MF_GRAYED
	.endif
	invoke AnyNoNameBookMarks
	.if eax
		invoke EnableMenuItem,hMenu,IDM_EDIT_CLEARBM,MF_ENABLED
	.else
		invoke EnableMenuItem,hMenu,IDM_EDIT_CLEARBM,MF_GRAYED
	.endif
	mov		ebx,IDM_EDIT_GOTOBM0
	.while ebx<=IDM_EDIT_GOTOBM9
		mov		eax,ebx
		sub		eax,IDM_EDIT_GOTOBM0
		or		eax,30h
		invoke IsNamedBookMark,eax
		.if eax
			invoke EnableMenuItem,hMenu,ebx,MF_BYCOMMAND or MF_ENABLED
			invoke CheckMenuItem,hMenu,ebx,MF_BYCOMMAND or MF_CHECKED
		.else
			.if hEdit
				invoke EnableMenuItem,hMenu,ebx,MF_BYCOMMAND or MF_ENABLED
				invoke CheckMenuItem,hMenu,ebx,MF_BYCOMMAND or MF_UNCHECKED
			.else
				invoke EnableMenuItem,hMenu,ebx,MF_BYCOMMAND or MF_GRAYED
			.endif
		.endif
		inc		ebx
	.endw
	invoke AnyBreakPoints
	.if eax
		invoke EnableMenuItem,hMenu,IDM_EDIT_CLEARBP,MF_BYCOMMAND or MF_ENABLED
	.else
		invoke EnableMenuItem,hMenu,IDM_EDIT_CLEARBP,MF_BYCOMMAND or MF_GRAYED
	.endif
	invoke AnyErrorBookMarks
	.if eax
		mov		eax,MF_BYCOMMAND or MF_ENABLED
	.else
		mov		eax,MF_BYCOMMAND or MF_GRAYED
	.endif
	mov		val,eax
	invoke EnableMenuItem,hMenu,IDM_EDIT_NEXTERROR,val
	invoke EnableMenuItem,hMenu,IDM_EDIT_CLEARERRORS,val
	ret

MenuStatus endp

;#########################################################################

ToolBarStatus proc uses esi
	LOCAL	chrg:CHARRANGE
	LOCAL	blrg:BLOCKRANGE
	LOCAL	val:DWORD
	LOCAL	ro:DWORD

	invoke GetActive
	invoke AnyBookMarks
	mov		edx,IDM_EDIT_NEXTBM
	call	EnableDisable
	mov		edx,IDM_EDIT_PREVIOUSBM
	call	EnableDisable
	invoke AnyNoNameBookMarks
	mov		edx,IDM_EDIT_CLEARBM
	call	EnableDisable
	.if hEdit
		mov		eax,TRUE
		mov		edx,IDM_FILE_PRINT
		call	EnableDisable
		mov		edx,IDM_FILE_SAVEFILE
		call	EnableDisable
		mov		edx,IDM_FILE_SAVEALLFILES
		call	EnableDisable
		mov		edx,IDM_EDIT_FIND
		call	EnableDisable
		mov		edx,IDM_EDIT_REPLACE
		call	EnableDisable
		;Check whether there is some text on the clipboard. If so, we enable the paste menuitem
		invoke SendMessage,hEdit,EM_CANPASTE,CF_TEXT,0
		mov		edx,IDM_EDIT_PASTE
		call	EnableDisable
		;check whether the undo queue is empty
		invoke SendMessage,hEdit,EM_CANUNDO,0,0
		mov		edx,IDM_EDIT_UNDO
		call	EnableDisable
		;check whether the redo queue is empty
		invoke SendMessage,hEdit,EM_CANREDO,0,0
		mov		edx,IDM_EDIT_REDO
		call	EnableDisable
		;check whether there is a current selection in the richedit control.
		;If there is, we enable the cut/copy/delete menuitem
		invoke SendMessage,hEdit,REM_GETMODE,0,0
		test	eax,MODE_BLOCK
		.if ZERO?
			invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
			mov eax,chrg.cpMax
			sub eax,chrg.cpMin
		.else
			invoke SendMessage,hEdit,REM_GETBLOCK,0,addr blrg
			mov		eax,blrg.clMax
			sub		eax,blrg.clMin
		.endif
		mov		edx,IDM_FORMAT_INDENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_OUTDENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_COMMENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_UNCOMMENT
		call	EnableDisable
		mov		edx,IDM_EDIT_COPY
		call	EnableDisable
		mov		edx,IDM_EDIT_CUT
		call	EnableDisable
		mov		edx,IDM_EDIT_DELETE
		call	EnableDisable
		mov		eax,TRUE
		mov		edx,IDM_EDIT_TOGGLEBM
		call	EnableDisable
		invoke GetWindowLong,hEdit,GWL_STYLE
		and		eax,STYLE_READONLY
		.if eax
			xor		eax,eax
			mov		edx,IDM_EDIT_PASTE
			call	EnableDisable
			mov		edx,IDM_EDIT_CUT
			call	EnableDisable
			mov		edx,IDM_EDIT_DELETE
			call	EnableDisable
			mov		edx,IDM_EDIT_REPLACE
			call	EnableDisable
			mov		edx,IDM_FORMAT_INDENT
			call	EnableDisable
			mov		edx,IDM_FORMAT_OUTDENT
			call	EnableDisable
			mov		edx,IDM_FORMAT_COMMENT
			call	EnableDisable
			mov		edx,IDM_FORMAT_UNCOMMENT
			call	EnableDisable
		.endif
	.elseif hDialog
		xor		eax,eax
		mov		edx,IDM_FILE_PRINT
		call	EnableDisable
		mov		edx,IDM_EDIT_FIND
		call	EnableDisable
		mov		edx,IDM_EDIT_REPLACE
		call	EnableDisable
		inc		eax
		mov		edx,IDM_FILE_SAVEFILE
		call	EnableDisable
		mov		edx,IDM_FILE_SAVEALLFILES
		call	EnableDisable
		invoke GetWindowLong,hMdiCld,8
		mov		ro,eax
		.if ro
			mov		eax,FALSE
		.else
			mov		eax,dlgpaste.hwnd
			.if eax
				mov		eax,TRUE
			.endif
		.endif
		mov		edx,IDM_EDIT_PASTE
		call	EnableDisable
		.if !ro
			invoke GetWindowLong,hDialog,GWL_USERDATA
			sub		eax,sizeof DLGHEAD
			mov		eax,(DLGHEAD ptr [eax]).undo
			.if eax
				mov		eax,TRUE
			.endif
		.else
			mov		eax,FALSE
		.endif
		mov		edx,IDM_EDIT_UNDO
		call	EnableDisable
		mov		val,FALSE
		.if hReSize
			invoke GetWindowLong,hReSize,GWL_USERDATA
			mov		eax,(DIALOG ptr [eax]).ntype
			.if eax
				mov		val,TRUE
			.endif
		.elseif hMultiSel
			mov		val,TRUE
		.endif
		mov		eax,val
		mov		edx,IDM_EDIT_COPY
		call	EnableDisable
		.if ro
			mov		val,FALSE
		.endif
		mov		eax,val
		mov		edx,IDM_EDIT_CUT
		call	EnableDisable
		mov		edx,IDM_EDIT_DELETE
		call	EnableDisable
		xor		eax,eax
		mov		edx,IDM_EDIT_TOGGLEBM
		call	EnableDisable
		mov		edx,IDM_FORMAT_INDENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_OUTDENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_COMMENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_UNCOMMENT
		call	EnableDisable
	.elseif hHexEd
		xor		eax,eax
		mov		edx,IDM_FILE_PRINT
		call	EnableDisable
		inc		eax
		mov		edx,IDM_FILE_SAVEFILE
		call	EnableDisable
		mov		edx,IDM_FILE_SAVEALLFILES
		call	EnableDisable
		mov		edx,IDM_EDIT_FIND
		call	EnableDisable
		mov		edx,IDM_EDIT_REPLACE
		call	EnableDisable
		;Check whether there is some text on the clipboard. If so, we enable the paste menuitem
		invoke SendMessage,hHexEd,EM_CANPASTE,CF_TEXT,0
		mov		edx,IDM_EDIT_PASTE
		call	EnableDisable
		;check whether the undo queue is empty
		invoke SendMessage,hHexEd,EM_CANUNDO,0,0
		mov		edx,IDM_EDIT_UNDO
		call	EnableDisable
		;check whether the redo queue is empty
		invoke SendMessage,hHexEd,EM_CANREDO,0,0
		mov		edx,IDM_EDIT_REDO
		call	EnableDisable
		;check whether there is a current selection in the richedit control.
		;If there is, we enable the cut/copy/delete menuitem
		invoke SendMessage,hHexEd,EM_EXGETSEL,0,addr chrg
		mov eax,chrg.cpMax
		sub eax,chrg.cpMin
		mov		edx,IDM_EDIT_COPY
		call	EnableDisable
		mov		edx,IDM_EDIT_CUT
		call	EnableDisable
		mov		edx,IDM_EDIT_DELETE
		call	EnableDisable
		xor		eax,eax
		mov		edx,IDM_EDIT_TOGGLEBM
		call	EnableDisable
		mov		edx,IDM_FORMAT_INDENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_OUTDENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_COMMENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_UNCOMMENT
		call	EnableDisable
	.else
		xor		eax,eax
		mov		edx,IDM_FILE_PRINT
		call	EnableDisable
		mov		edx,IDM_FILE_SAVEFILE
		call	EnableDisable
		mov		edx,IDM_FILE_SAVEALLFILES
		call	EnableDisable
		mov		edx,IDM_EDIT_FIND
		call	EnableDisable
		mov		edx,IDM_EDIT_REPLACE
		call	EnableDisable
		mov		edx,IDM_EDIT_UNDO
		call	EnableDisable
		mov		edx,IDM_EDIT_REDO
		call	EnableDisable
		mov		edx,IDM_EDIT_CUT
		call	EnableDisable
		mov		edx,IDM_EDIT_COPY
		call	EnableDisable
		mov		edx,IDM_EDIT_DELETE
		call	EnableDisable
		mov		edx,IDM_EDIT_PASTE
		call	EnableDisable
		mov		edx,IDM_EDIT_TOGGLEBM
		call	EnableDisable
		mov		edx,IDM_FORMAT_INDENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_OUTDENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_COMMENT
		call	EnableDisable
		mov		edx,IDM_FORMAT_UNCOMMENT
		call	EnableDisable
	.endif
	invoke SendMessage,hPrpTbrCode,TB_ENABLEBUTTON,3,fProject
	invoke SendMessage,hPrpTbrCode,TB_ENABLEBUTTON,4,fProject
	ret

EnableDisable:
	push	eax
	.if eax
		mov		eax,TRUE
	.endif
	invoke SendMessage,hToolBar,TB_ENABLEBUTTON,edx,eax
	pop		eax
	retn

ToolBarStatus endp

;#########################################################################

ClientProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_MOUSEMOVE
		invoke DllProc,hWin,AIM_CLIENTMOUSEMOVE,wParam,lParam,RAM_CLIENTMOUSEMOVE
		.if MnuHigh && hDialog
			mov		MnuPtx,-1
			invoke SendMessage,hDialog,WM_NCPAINT,0,0
		.endif
	.endif
	invoke CallWindowProc,OldClientProc,hWin,uMsg,wParam,lParam
	ret

ClientProc endp

TimerProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	invoke DllProc,hWin,AIM_TIMER,wParam,lParam,RAM_TIMER
	.if Splashtc
		dec		Splashtc
		.if !Splashtc
			invoke DestroyWindow,hSplash
			mov		hSplash,0
			.if pbmfh
			    invoke GlobalUnlock,pbmfh
        		invoke GlobalFree,hBmpMem
			.endif
		.endif
	.endif
	.if nLineTick
		dec		nLineTick
		.if !nLineTick
			invoke LineNo,hEdit
			invoke UpdateAll,IS_FILE_CHANGED
		.endif
	.endif
	ret

TimerProc endp

FullScreenProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	mov		eax,uMsg
	.if eax==WM_ERASEBKGND
		.if hDialog
			invoke DefWindowProc,hWin,uMsg,wParam,lParam
		.endif
		xor		eax,eax
	.elseif eax==WM_CLOSE
		invoke SendMessage,hWnd,WM_CLOSE,0,0
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

FullScreenProc endp

CmdFile proc uses ebx,hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	sfo:SHFILEOPSTRUCT

	.if eax==IDM_FILE_NEWPROJECT
		invoke ProWizShow,hWin
	.elseif eax==IDM_FILE_OPENPROJECT
		invoke OpenProject,FALSE
	.elseif eax==IDM_FILE_CLOSEPROJECT
		invoke CloseProject
	.elseif eax==IDM_FILE_DELETEPROJECT
		invoke DeleteProject
	.elseif eax==IDM_FILE_NEWFILE
		mov		FileName[0],0
		invoke MakeMdiCldWin,addr EditCldClassName,ID_EDIT
		invoke SetWindowText,hMdiCld,addr NewFile
		invoke TabToolAdd,hMdiCld,offset NewFile-1
	.elseif eax==IDM_FILE_OPENFILE
		invoke OpenEdit,hWin
	.elseif eax==IDM_FILE_REOPENFILE
		invoke GetWindowText,hMdiCld,addr FileName,sizeof FileName
		invoke GetFileAttributes,addr FileName
		.if eax!=INVALID_HANDLE_VALUE
			.if hEdit || hDialog
				invoke SendMessage,hMdiCld,WM_CLOSE,0,0
				invoke OpenEditFile
			.elseif hHexEd
				invoke SendMessage,hMdiCld,WM_CLOSE,0,0
				invoke OpenHex
			.endif
		.endif
	.elseif eax==IDM_FILE_OPENHEX
		invoke OpenHexEdit,hWin
	.elseif eax==IDM_FILE_CLOSEFILE
		invoke SendMessage,hMdiCld,WM_CLOSE,0,0
	.elseif eax==IDM_FILE_SAVEFILE
		.if hEdit
			invoke SaveEdit,hMdiCld
		.elseif hDialog
			invoke SaveDialog,hMdiCld,FALSE
		.elseif hHexEd
			invoke SaveHexEdit,hMdiCld
		.endif
	.elseif eax==IDM_FILE_SAVEFILEAS
		.if hEdit
			invoke SaveEditAs,hMdiCld
		.elseif hDialog
			invoke SaveDialog,hMdiCld,TRUE
		.elseif hHexEd
			invoke SaveHexEditAs,hMdiCld
		.endif
	.elseif eax==IDM_FILE_SAVEALLFILES
		invoke UpdateAll,IDM_FILE_SAVEALLFILES
	.elseif eax>=21000 && eax<=21009
		sub		eax,21000
		shl		eax,8
		add		eax,offset RecentFiles
		invoke strcpy,offset FileName,eax
		invoke OpenEditFile
		invoke AddRecentFile,offset FileName
	.elseif eax==IDM_FILE_PAGESETUP
		invoke GetPrnCaps
		mov		psd.lStructSize,sizeof psd
		m2m		psd.hwndOwner,hWnd
		m2m		psd.hInstance,hInstance
		.if prnInches
			mov		eax,PSD_MARGINS or PSD_INTHOUSANDTHSOFINCHES
		.else
			mov		eax,PSD_MARGINS or PSD_INHUNDREDTHSOFMILLIMETERS
		.endif
		mov		psd.Flags,eax
		invoke PageSetupDlg,addr psd
		.if eax
			invoke iniEditSave
		.endif
	.elseif eax==IDM_FILE_PRINT
		invoke Print
 	.elseif eax==IDM_FILE_EXIT
		.if fProject
			invoke CloseProject
			.if eax
				xor		eax,eax
				ret
			.endif
		.endif
		invoke SendMessage,hWin,WM_CLOSE,0,0
	.elseif eax==IDM_FILE_COPYNAME
		invoke FileGetName
		invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,offset FileToCopy
		mov		FileCutFlag,FALSE
		mov		FileToCopy,0
		invoke SetFocus,hEdit
	.elseif eax==IDM_FILE_CUT
		invoke FileGetName
		mov		FileCutFlag,TRUE
	.elseif eax==IDM_FILE_COPY
		invoke FileGetName
		mov		FileCutFlag,FALSE
	.elseif eax==IDM_FILE_PASTE
		invoke FileGetPath,addr buffer
		invoke strcat,addr buffer,offset NameToCopy
		invoke strcmp,addr buffer,offset FileToCopy
		.if !eax
			invoke FileGetPath,addr buffer
			invoke strcat,addr buffer,offset szCopyOf
			invoke strcat,addr buffer,offset NameToCopy
		.endif
		invoke GetFileAttributes,addr buffer
		.if eax!=-1
			invoke MessageBox,hWnd,offset szFileExist,offset AppName,MB_YESNO or MB_ICONQUESTION
			.if eax==IDYES
				mov		eax,-1
			.endif
		.endif
		.if eax==-1
			invoke CopyFile,offset FileToCopy,addr buffer,FALSE
			.if !eax
				invoke MessageBox,hWnd,offset szCouldNotCopy,offset AppName,MB_OK or MB_ICONERROR
			.else
				invoke FileDir,offset FilePath
				.if FileCutFlag
					invoke DeleteFile,offset FileToCopy
					.if !eax
						invoke MessageBox,hWnd,offset szCouldNotDelete,offset AppName,MB_OK or MB_ICONERROR
					.endif
					mov		FileToCopy,0
				.endif
			.endif
		.endif
	.elseif eax==IDM_FILE_DELETE
		invoke FileGetName
		.if FileToCopy
			invoke strlen,offset FileToCopy
			mov		[FileToCopy+eax+1],0
			mov		FileCutFlag,FALSE
			mov		eax,hWnd
			mov		sfo.hwnd,eax
			mov		sfo.wFunc,FO_DELETE
			mov		sfo.pFrom,offset FileToCopy
			mov		sfo.pTo,NULL
			mov		sfo.fFlags,FOF_ALLOWUNDO or FOF_SILENT
			mov		sfo.fAnyOperationsAborted,TRUE
			mov		sfo.lpszProgressTitle,NULL
			mov		sfo.hNameMappings,NULL
			invoke SHFileOperation,ADDR	sfo
			.if	!eax && !sfo.fAnyOperationsAborted
				invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_CARET,0
				mov		ebx,eax
				invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_NEXT,ebx
				.if !eax
					invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_PREVIOUS,ebx
				.endif
				xchg	eax,ebx
				invoke SendMessage,hFileTrv,TVM_DELETEITEM,0,eax
				invoke SendMessage,hFileTrv,TVM_SELECTITEM,TVGN_CARET,ebx
			.elseif eax
				invoke TextToOutput,offset FileToCopy
			.endif
		.endif
		mov		FileToCopy,0
		invoke SetFocus,hFileTrv
	.elseif eax==IDM_FILE_RENAME
		invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_CARET,hFileTrv
		.if eax
			invoke SendMessage,hFileTrv,TVM_EDITLABEL,0,eax
		.endif
	.elseif eax==IDM_FILE_EXPLORE
		invoke FileGetPath,addr buffer
		.if eax
			invoke ShellExecute,hWin,NULL,addr buffer,NULL,NULL,SW_SHOWDEFAULT
		.endif
	.else
		ret
	.endif
	xor		eax,eax
	ret

CmdFile endp

CmdEdit proc hWin:HWND
	LOCAL   chrg:CHARRANGE
	LOCAL	vTmp:DWORD

	.if eax==IDM_EDIT_CUT
		.if hEdit
			invoke SendMessage,hEdit,WM_CUT,0,0
		.elseif hDialog
			invoke CopyCtl
			invoke DeleteCtl
		.elseif hHexEd
			invoke SendMessage,hHexEd,WM_CUT,0,0
		.endif
	.elseif eax==IDM_EDIT_COPY
		.if hEdit
			invoke SendMessage,hEdit,WM_COPY,0,0
		.elseif hDialog
			invoke CopyCtl
		.elseif hHexEd
			invoke SendMessage,hHexEd,WM_COPY,0,0
		.endif
	.elseif eax==IDM_EDIT_PASTE
		.if hEdit
			invoke SetFocus,hEdit
			invoke SendMessage,hEdit,WM_PASTE,0,0
		.elseif hDialog
			invoke PasteCtl
		.elseif hHexEd
			invoke SetFocus,hHexEd
			invoke SendMessage,hHexEd,WM_PASTE,0,0
		.endif
	.elseif eax==IDM_EDIT_DELETE
		.if hEdit
			invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,0
		.elseif hDialog
			invoke DeleteCtl
		.elseif hHexEd
			invoke SendMessage,hHexEd,EM_REPLACESEL,TRUE,0
		.endif
	.elseif eax==IDM_EDIT_SELECTALL
		mov		chrg.cpMin,0
		mov		chrg.cpMax,-1
		.if hEdit
			invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
		.elseif hHexEd
			invoke SendMessage,hHexEd,EM_EXSETSEL,0,addr chrg
		.endif
	.elseif eax==IDM_EDIT_UNDO
		.if hEdit
			invoke SendMessage,hEdit,EM_UNDO,0,0
		.elseif hDialog
			invoke UndoCtl
		.elseif hHexEd
			invoke SendMessage,hHexEd,EM_UNDO,0,0
		.endif
	.elseif eax==IDM_EDIT_REDO
		.if hEdit
			invoke SendMessage,hEdit,EM_REDO,0,0
		.elseif hHexEd
			invoke SendMessage,hHexEd,EM_REDO,0,0
		.endif
	.elseif eax==IDM_EDIT_EMPTY_UNDO
		.if hEdit
			invoke SendMessage,hEdit,EM_EMPTYUNDOBUFFER,0,0
		.elseif hHexEd
			invoke SendMessage,hHexEd,EM_EMPTYUNDOBUFFER,0,0
		.endif
	.elseif eax==IDM_EDIT_FIND
		.if hEdit
			.if !hSearch
				invoke GetSelText,addr FindBuffer
				invoke ModelessDialog,hInstance,IDD_FINDDLG,hWin,addr SearchProc,FALSE
			.else
				invoke SetFocus,hSearch
			.endif
		.elseif hHexEd
			.if !hSearch
				invoke ModelessDialog,hInstance,IDD_HEXFINDDLG,hWin,addr HexFindDlgProc,FALSE
			.else
				invoke SetFocus,hSearch
			.endif
		.endif
	.elseif eax==IDM_EDIT_REPLACE
		.if hEdit
			.if !hSearch
				invoke GetSelText,addr FindBuffer
				invoke ModelessDialog,hInstance,IDD_FINDDLG,hWin,addr SearchProc,TRUE
			.else
				invoke SetFocus,hSearch
			.endif
		.elseif hHexEd
			.if !hSearch
				invoke ModelessDialog,hInstance,IDD_HEXFINDDLG,hWin,addr HexFindDlgProc,TRUE
			.else
				invoke SetFocus,hSearch
			.endif
		.endif
	.elseif eax==IDM_EDIT_GOTOLINE
		.if hGoTo==0
			invoke ModelessDialog,hInstance,IDD_GOTODLG,hWin,addr GoToProc,0
		.else
			invoke SetFocus,hGoTo
		.endif
	.elseif eax==IDM_EDIT_FINDNEXT
		.if hEdit
			.if !hSearch
				invoke GetSelText,addr FindBuffer
				invoke FixFind,offset FindBuffer,offset FindBufferFixed,fIgnoreWhiteSpace
			.endif
			invoke strlen,addr FindBuffer
			.if eax
				invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findtext.chrg
				m2m		findtext.chrg.cpMin,findtext.chrg.cpMax
				mov		findtext.chrg.cpMax,-1
				mov		findtext.lpstrText,offset FindBufferFixed
				mov		edx,FR_DOWN
				.if fMatchCase
					or		edx,FR_MATCHCASE
				.endif
				.if fWholeWord
					or		edx,FR_WHOLEWORD
				.endif
				invoke SendMessage,hEdit,EM_FINDTEXTEX,edx,addr findtext
				.if eax!=-1
					invoke SendMessage,hEdit,EM_EXSETSEL,0,addr findtext.chrgText
					invoke VerticalCenter,hEdit,REM_VCENTER
				.endif
			.endif
		.elseif hHexEd
			mov		eax,fr
			or		eax,FR_DOWN
			invoke HexFind,eax
		.endif
	.elseif eax==IDM_EDIT_FINDPREVIOUS
		.if hEdit
			.if !hSearch
				invoke GetSelText,addr FindBuffer
				invoke FixFind,offset FindBuffer,offset FindBufferFixed,fIgnoreWhiteSpace
			.endif
			invoke strlen,addr FindBuffer
			.if eax
				invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findtext.chrg
				mov 	findtext.chrg.cpMax,0
				mov 	findtext.lpstrText,offset FindBufferFixed
				xor		edx,edx
				.if fMatchCase
					or		edx,FR_MATCHCASE
				.endif
				.if fWholeWord
					or		edx,FR_WHOLEWORD
				.endif
				invoke SendMessage,hEdit,EM_FINDTEXTEX,edx,addr findtext
				.if eax!=-1
					invoke SendMessage,hEdit,EM_EXSETSEL,0,addr findtext.chrgText
					invoke VerticalCenter,hEdit,REM_VCENTER
				.endif
			.endif
		.elseif hHexEd
			mov		eax,fr
			and		eax,(-1 xor FR_DOWN)
			invoke HexFind,eax
		.endif
	.elseif eax==IDM_EDIT_FINDPROC
		.if hEdit
			mov		eax,hEdit
			mov		vTmp,eax
			invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
			invoke GetWordFromPos,hEdit
			mov		al,[eax]
			.if al
				invoke lstrcpyn,addr FindBuffer,addr LineWord,sizeof FindBuffer
				invoke ScanWord,addr LineWord,addr LineTxt
				.if eax
					invoke PushRet,vTmp,chrg.cpMin
					invoke VerticalCenter,hEdit,REM_VCENTER
				.else
					mov		edx,lpCharTab
					lea		edx,[edx+'.']
					push	edx
					movzx	eax,byte ptr [edx]
					push	eax
					mov		byte ptr [edx],1
					invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
					invoke GetWordFromPos,hEdit
					invoke lstrcpyn,addr FindBuffer,addr LineWord,sizeof FindBuffer
					invoke ScanWord,addr LineWord,addr LineTxt
					.if eax
						invoke PushRet,vTmp,chrg.cpMin
						invoke VerticalCenter,hEdit,REM_VCENTER
					.endif
					pop		eax
					pop		edx
					mov		[edx],al
				.endif
			.endif
		.endif
	.elseif eax==IDM_EDIT_RETURN
		invoke IsWindow,RetPos
		.if eax
			mov		eax,RetPos
			.if eax
				invoke GetParent,eax
				invoke MdiActivate,eax
				invoke SetFocus,hEdit
				mov		eax,RetPos+4
				mov		chrg.cpMin,eax
				mov		chrg.cpMax,eax
				invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
				invoke VerticalCenter,hEdit,REM_VCENTER
			.endif
		.endif
		invoke PopRet
	.elseif eax==IDM_EDIT_FINDWORD
		.if hEdit
			invoke GetWordFromPos,hEdit
			invoke lstrcpyn,addr FindBuffer,addr LineWord,sizeof FindBuffer
			.if hSearch==0
				invoke ModelessDialog,hInstance,IDD_FINDDLG,hWin,addr SearchProc,FALSE
			.else
				invoke SetDlgItemText,hSearch,IDC_FINDCBO,addr FindBuffer
				invoke SetFocus,hSearch
			.endif
		.endif
	.elseif eax==IDM_EDIT_FIND_NEXT_WORD
		.if hEdit
			invoke GetWordFromPos,hEdit
			invoke lstrcpyn,addr FindBuffer,addr LineWord,sizeof FindBuffer
			invoke strlen,addr FindBuffer
			.if eax
				invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findtext.chrg
				m2m		findtext.chrg.cpMin,findtext.chrg.cpMax
				mov		findtext.chrg.cpMax,-1
				mov		findtext.lpstrText,offset FindBufferFixed
				mov		fMatchCase,TRUE
				mov		fWholeWord,TRUE
				invoke SendMessage,hEdit,EM_FINDTEXTEX,FR_DOWN or FR_MATCHCASE or FR_WHOLEWORD,addr findtext
				.if eax!=-1
					invoke SendMessage,hEdit,EM_EXSETSEL,0,addr findtext.chrgText
					invoke VerticalCenter,hEdit,REM_VCENTER
				.endif
			.endif
		.endif
	.elseif eax==IDM_EDIT_FIND_PREV_WORD
		.if hEdit
			invoke GetWordFromPos,hEdit
			invoke lstrcpyn,addr FindBuffer,addr LineWord,sizeof FindBuffer
			invoke strlen,addr FindBuffer
			.if eax
				invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findtext.chrg
				mov		findtext.chrg.cpMax,0
				mov		findtext.lpstrText,offset FindBufferFixed
				mov		fMatchCase,TRUE
				mov		fWholeWord,TRUE
				invoke SendMessage,hEdit,EM_FINDTEXTEX,FR_MATCHCASE or FR_WHOLEWORD,addr findtext
				.if eax!=-1
					invoke SendMessage,hEdit,EM_EXSETSEL,0,addr findtext.chrgText
					invoke VerticalCenter,hEdit,REM_VCENTER
				.endif
			.endif
		.endif
	.elseif eax==IDM_EDIT_TOGGLEBM
		invoke ToggleBookMark,1
	.elseif eax==IDM_EDIT_NEXTBM
		invoke SelBookMark,-1
	.elseif eax==IDM_EDIT_PREVIOUSBM
		invoke SelBookMark,1
	.elseif eax==IDM_EDIT_CLEARBM
		invoke ClearBookMarks
		invoke UpdateAll,WM_PAINT
	.elseif eax>=IDM_EDIT_GOTOBM0 && eax<=IDM_EDIT_GOTOBM9
		sub		eax,IDM_EDIT_GOTOBM0
		or		eax,30h
		invoke FindBookMark,eax
	.elseif eax==IDM_EDIT_TOGGLEBP
		invoke ToggleBreakPoint
	.elseif eax==IDM_EDIT_CLEARBP
		invoke ClearBreakPoints
		invoke UpdateAll,WM_PAINT
	.elseif eax==IDM_EDIT_ADDVAR
		invoke ModalDialog,hInstance,IDD_DLGBPVAR,hWin,offset DlgBPVarProc,NULL
	.elseif eax==IDM_EDIT_NEXTERROR
		invoke AnyErrorBookMarks
		.if !eax
			jmp		Ex
		.endif
	  @@:
		mov		eax,iErrorBookMark
		and		eax,31
		mov		ebx,offset ErrorBookMark
		lea		eax,[eax*2+eax]
		lea		ebx,[ebx+eax*4]
		mov		eax,[ebx]
		.if !eax
			mov		iErrorBookMark,eax
			jmp		@b
		.endif
		.if SDWORD ptr eax<0
			and		eax,3FFh
			invoke OpenBookMark,eax
		.endif
		invoke GetParent,eax
		invoke MdiActivate,eax
		mov		eax,[ebx+4]
		invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
		mov		chrg.cpMin,eax
		mov		chrg.cpMax,eax
		invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
		invoke VerticalCenter,hEdit,REM_VCENTER
		invoke SetFocus,hEdit
		inc		iErrorBookMark
		and		iErrorBookMark,31
	.elseif eax==IDM_EDIT_CLEARERRORS
		invoke ClearErrorBookMarks
	.elseif eax>=IDM_TAB1 && eax<=IDM_TAB10
		sub		eax,IDM_TAB1
		invoke TabToolSetSel,eax
	.elseif eax==IDM_EDIT_BLOCKMODE
		invoke SendMessage,hEdit,REM_GETMODE,0,0
		xor		eax,MODE_BLOCK
		invoke SendMessage,hEdit,REM_SETMODE,eax,0
	.elseif eax==IDM_EDIT_BLOCK_INSERT
		invoke ModalDialog,hInstance,IDD_BLOCKDLG,hWin,offset BlockDlgProc,NULL
	.elseif eax==IDM_EDIT_EXPANDBLOCK
		invoke GetFocus
		.if eax==hPbrTrv
			.if fProExp
				invoke GroupExpandAll,hPbrTrv,0
			.else
				invoke GroupCollapseAll,hPbrTrv,0
			.endif
			xor		fProExp,1
		.elseif hEdit
			invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
			invoke SendMessage,hEdit,EM_LINEFROMCHAR,chrg.cpMin,0
			mov		ebx,eax
			mov		vTmp,eax
			invoke SendMessage,hEdit,REM_GETBOOKMARK,ebx,0
			.if !eax
				inc		ebx
				invoke SendMessage,hEdit,REM_ISLINEHIDDEN,ebx,0
				.if eax
					.while eax
						inc		ebx
						invoke SendMessage,hEdit,REM_ISLINEHIDDEN,ebx,0
					.endw
					dec		ebx
					.while ebx!=vTmp
						invoke SendMessage,hEdit,REM_GETBOOKMARK,ebx,0
						.if eax==2
							invoke SendMessage,hEdit,REM_EXPAND,ebx,0
						.else
							invoke SendMessage,hEdit,REM_HIDELINE,ebx,FALSE
						.endif
						dec		ebx
					.endw
					invoke SendMessage,hEdit,REM_REPAINT,0,0
					jmp		Ex
				.endif
				mov		ebx,vTmp
			.endif
		  Nxt:
			invoke SendMessage,hEdit,REM_ISLINEHIDDEN,ebx,0
			.if eax && ebx
				dec		ebx
				jmp		Nxt
			.endif
			invoke SendMessage,hEdit,REM_GETBOOKMARK,ebx,0
			.if !eax && ebx
				dec		ebx
				jmp		Nxt
			.endif
			.if eax==1
				invoke SendMessage,hEdit,REM_COLLAPSE,ebx,0
				call	SetSel
			.elseif eax==2
				invoke SendMessage,hEdit,REM_EXPAND,ebx,0
				mov		ebx,vTmp
				call	SetSel
			.elseif eax==8
				invoke SendMessage,hEdit,REM_EXPAND,ebx,0
				.if eax
					push	eax
					invoke SendMessage,hEdit,REM_SETBOOKMARK,ebx,9
					pop		eax
					neg		eax
					invoke SendMessage,hEdit,REM_SETBMID,ebx,eax
					call	SetSel
				.endif
			.elseif eax==9
				;Collapse
				invoke SendMessage,hEdit,REM_GETBMID,ebx,0
				push	eax
				invoke SendMessage,hEdit,REM_SETBOOKMARK,ebx,0
				pop		eax
				neg		eax
				inc		eax
				invoke SendMessage,hEdit,REM_HIDELINES,ebx,eax
				call	SetSel
			.endif
		.endif
	.elseif eax==IDM_EDIT_HIDEBLOCK
		invoke HideSelection
	.elseif eax==IDM_EDIT_OPEN
		invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
		invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
		push	eax
		mov		word ptr LineTxt,sizeof LineTxt-1
		invoke SendMessage,hEdit,EM_GETLINE,eax,offset LineTxt
		mov		LineTxt[eax],0
		pop		eax
		invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
		sub		eax,chrg.cpMin
		neg		eax
		.while LineTxt[eax]!=' ' && LineTxt[eax]!=VK_TAB && LineTxt[eax]!="'" && LineTxt[eax]!='"' && LineTxt[eax]
			inc		eax
		.endw
		.if LineTxt[eax]=="'" || LineTxt[eax]=='"'
			inc		eax
		.endif
		mov		LineTxt[eax],0
		mov		LineWord,0
		.if eax
			dec		eax
			.while eax && (LineTxt[eax]==' ' || LineTxt[eax]==VK_TAB)
				mov		LineTxt[eax],0
				dec		eax
			.endw
			.if eax
				mov		dl,LineTxt[eax]
				.if dl=='"' || dl=="'"
					mov		LineTxt[eax],0
					dec		eax
					.while eax && dl!=LineTxt[eax]
						dec		eax
					.endw
					.if dl==LineTxt[eax]
						inc		eax
					.endif
					invoke strcpy,offset LineWord,addr LineTxt[eax]
				.else
					.while eax && LineTxt[eax]!=' ' && LineTxt[eax]!=VK_TAB
						dec		eax
					.endw
					.if LineTxt[eax]==' ' || LineTxt[eax]==VK_TAB
						inc		eax
					.endif
					invoke strcpy,offset LineWord,addr LineTxt[eax]
				.endif
			.endif
		.endif
		.if LineWord
			;Current or full path
			invoke GetFileAttributes,offset LineWord
			.if eax!=-1
				invoke GetFullPathName,offset LineWord,sizeof FileName,offset FileName,addr vTmp
				invoke OpenEditFile
				jmp		Ex
			.endif
			;Include path
			invoke strcpy,offset LineTxt,offset Incl
			invoke strcat,offset LineTxt,offset szBackSlash
			invoke strcat,offset LineTxt,offset LineWord
			invoke GetFileAttributes,offset LineTxt
			.if eax!=-1
				invoke GetFullPathName,offset LineTxt,sizeof FileName,offset FileName,addr vTmp
				invoke OpenEditFile
				jmp		Ex
			.endif
		.endif
	.else
		ret
	.endif
  Ex:
	xor		eax,eax
	ret

SetSel:
	invoke SendMessage,hEdit,EM_LINEINDEX,ebx,0
	mov		chrg.cpMin,eax
	mov		chrg.cpMax,eax
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
	invoke SendMessage,hEdit,EM_SCROLLCARET,0,0
	retn

CmdEdit endp

CmdView proc hWin:HWND
	LOCAL	rect:RECT

	.if eax==IDM_VIEW_TOOLBAR
		xor		dword ptr winTbr,1
		.if winTbr
			mov		eax,SW_SHOWNA
		.else
			mov		eax,SW_HIDE
		.endif
		invoke ShowWindow,hToolBar,eax
		invoke SendMessage,hWin,WM_SIZE,0,0
	.elseif eax==IDM_VIEW_TOOLBOX
		invoke ToolMessage,hTlb,TLM_HIDE,0
	.elseif eax==IDM_VIEW_OUTPUTWINDOW
		invoke ToolMessage,hOut,TLM_HIDE,0
	.elseif eax==IDM_VIEW_PROJECTBROWSER
		invoke ToolMessage,hPbr,TLM_HIDE,0
	.elseif eax==IDM_VIEW_PROPERTIES
		invoke ToolMessage,hPrp,TLM_HIDE,0
	.elseif eax==IDM_VIEW_TABTOOL
		invoke ToolMessage,hTab,TLM_HIDE,0
	.elseif eax==IDM_VIEW_INFOTOOL
		invoke ToolMessage,hInf,TLM_HIDE,0
	.elseif eax==IDM_VIEW_TOOL1
		invoke ToolMessage,hTl1,TLM_HIDE,0
	.elseif eax==IDM_VIEW_TOOL2
		invoke ToolMessage,hTl2,TLM_HIDE,0
	.elseif eax==IDM_VIEW_STATUSBAR
		xor		dword ptr winSbr,1
		.if winSbr
			mov		eax,SW_SHOWNA
		.else
			mov		eax,SW_HIDE
		.endif
		invoke ShowWindow,hStatus,eax
		invoke SendMessage,hWin,WM_SIZE,0,0
	.elseif eax==IDM_VIEW_FULLSCREEN
		.if hMdiCld && !hDialog
			.if !hFullScreen
				invoke CreateWindowEx,NULL,addr FullScreenClassName,NULL,WS_POPUP or WS_VISIBLE or WS_MAXIMIZE,0,0,0,0,hWnd,NULL,hInstance,NULL
				mov     hFullScreen,eax
				push	ebx
				mov		ebx,hEdit
				.if !ebx
					mov		ebx,hDialog
					.if !ebx
						mov		ebx,hHexEd
					.endif
				.endif
				invoke SetParent,ebx,hFullScreen
				.if !hDialog
					invoke ShowWindow,ebx,SW_SHOWMAXIMIZED
				.endif
				invoke SetFocus,ebx
				pop		ebx
			.else
				push	ebx
				mov		ebx,hEdit
				.if !ebx
					mov		ebx,hDialog
					.if !ebx
						mov		ebx,hHexEd
					.endif
				.endif
				invoke SetParent,ebx,hMdiCld
				invoke DestroyWindow,hFullScreen
				mov		hFullScreen,0
				invoke GetClientRect,hMdiCld,addr rect
				invoke SetWindowPos,ebx,HWND_TOP,rect.left,rect.top,rect.right,rect.bottom,0
				pop		ebx
			.endif
		.endif
	.else
		ret
	.endif
	xor		eax,eax
	ret

CmdView endp

CmdFormat proc hWin:HWND
	LOCAL	rect:RECT

	.if eax==IDM_FORMAT_INDENT
		invoke IndentComment,VK_TAB,TRUE
	.elseif eax==IDM_FORMAT_OUTDENT
		invoke IndentComment,VK_TAB,FALSE
	.elseif eax==IDM_FORMAT_COMMENT
		push	esi
		mov		esi,offset szCmntChar
	  @@:
		movzx	eax,byte ptr [esi]
		.if eax
			invoke IndentComment,eax,TRUE
			inc		esi
			jmp		@b
		.endif
		pop		esi
	.elseif eax==IDM_FORMAT_UNCOMMENT
		push	esi
		mov		esi,offset szCmntChar
	  @@:
		movzx	eax,byte ptr [esi]
		.if eax
			invoke IndentComment,eax,FALSE
			inc		esi
			jmp		@b
		.endif
		pop		esi
	.elseif eax==IDM_FORMAT_SPCTOTAB
		invoke ConvertSpcToTab
	.elseif eax==IDM_FORMAT_TABTOSPC
		invoke ConvertTabToSpc
	.elseif eax==IDM_FORMAT_UCASE
		invoke ConvertCase,TRUE
	.elseif eax==IDM_FORMAT_LCASE
		invoke ConvertCase,FALSE
	.elseif eax==IDM_FORMAT_TRIM
		invoke TrimSpaces
	.elseif eax==IDM_FORMAT_SENDTOBACK
		invoke SendToBack,hReSize
	.elseif eax==IDM_FORMAT_BRINGTOFRONT
		invoke BringToFront,hReSize
	.elseif eax==IDM_FORMAT_LOCKCONTROLS
		.if hMdiCld && hDialog
			invoke SetFocus,hDialog
			invoke GetWindowLong,hMdiCld,4
			.if eax
				xor		(DLGHEAD ptr [eax]).locked,TRUE
				.if hReSize
					invoke SizeingRect,hReSize,FALSE
				.endif
				invoke SetChanged,TRUE,hMdiCld
			.endif
		.endif
	.elseif eax==IDM_FORMAT_SHOWGRID
		.if hDialog
			invoke SetFocus,hDialog
		.endif
		xor		fGrid,TRUE
		invoke UpdateAll,IDM_FORMAT_SHOWGRID
	.elseif eax>=IDM_FORMAT_ALIGN_LEFT && eax<=IDM_FORMAT_SIZE_BOTH
		invoke AlignSizeCtl,eax
	.elseif eax==IDM_FORMAT_CENTER_HOR || eax==IDM_FORMAT_CENTER_VER
		invoke AlignSizeCtl,eax
	.elseif eax==IDM_FORMAT_TABINDEX
		.if hTabSet
			invoke DestroyWindow,hTabSet
			mov		hTabSet,0
		.else
			invoke GetClientRect,hMdiCld,addr rect
			invoke CreateWindowEx,WS_EX_TRANSPARENT,addr DlgEditDummyClass,NULL,WS_CHILD or WS_VISIBLE,0,0,rect.right,rect.bottom,hMdiCld,123456789,hInstance,0
			mov		hTabSet,eax
			invoke SetWindowPos,eax,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
			mov		nTabSet,0
		.endif
	.else
		ret
	.endif
	xor		eax,eax
	ret

CmdFormat endp

CmdProject proc hWin:HWND
	LOCAL	tvi:TV_ITEMEX
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	vTmp:DWORD
	LOCAL	nInx:DWORD

	.if eax==IDM_PROJECT_ADDNEWASM
		invoke ProAddNew,hWin,0
	.elseif eax==IDM_PROJECT_ADDNEWDIALOG
		invoke ProAddNew,hWin,1
	.elseif eax==IDM_PROJECT_ADDNEWMENU
		invoke ProAddNew,hWin,2
	.elseif eax==IDM_PROJECT_ADDNEWINC
		invoke ProAddNew,hWin,3
	.elseif eax==IDM_PROJECT_ADDNEWRC
		invoke ProAddNew,hWin,4
	.elseif eax==IDM_PROJECT_ADDNEWTXT
		invoke ProAddNew,hWin,5
	.elseif eax==IDM_PROJECT_ADDNEWMODULE
		invoke ProAddNew,hWin,6
	.elseif eax==IDM_PROJECT_ADDNEWFILE
		invoke ProAddNew,hWin,7
	.elseif eax==IDM_PROJECT_ADDEXISTINGFILE
		invoke ProAddExist,hWin,0
	.elseif eax==IDM_PROJECT_ADDEXISTINGDIALOG
		invoke ProAddExist,hWin,1
	.elseif eax==IDM_PROJECT_ADDEXISTINGMENU
		invoke ProAddExist,hWin,2
	.elseif eax==IDM_PROJECT_ADDEXISTINGOBJ
		invoke ProAddExist,hWin,3
	.elseif eax==IDM_PROJECT_ADDEXISTINGMODULE
		invoke ProAddExist,hWin,4
	.elseif eax==IDM_PROJECT_ADDEXISTINGOPEN
		invoke ProAddExist,hWin,5
	.elseif eax==IDM_PROJECT_ACCELERATOR
		invoke ModalDialog,hInstance,IDD_DLGACCELERATOR,hWin,addr AccelEditProc,NULL
	.elseif eax==IDM_PROJECT_RESOURCE
		invoke ModalDialog,hInstance,IDD_DLGRESOURCE,hWin,addr ResourceProc,NULL
	.elseif eax==IDM_PROJECT_STRINGTABLE
		invoke ModalDialog,hInstance,IDD_DLGSTRINGTABLE,hWin,addr StringTableProc,NULL
	.elseif eax==IDM_PROJECT_VERINF
		invoke ModalDialog,hInstance,IDD_DLGVERINFO,hWin,addr VerinfoDlgProc,NULL
	.elseif eax==IDM_PROJECT_LANGUAGE
		invoke LanguageInit
		invoke ModalDialog,hInstance,IDD_LANGUAGE,hWin,addr LanguageProc,NULL
		.if eax
			invoke LanguageSave
			invoke LanguageEditExport,FALSE
		.endif
	.elseif eax==IDM_PROJECT_GROUPS
		invoke ModalDialog,hInstance,IDD_DLGPROJECTGROUPS,hWin,addr ProjectGroupsProc,hWin
	.elseif eax==IDM_PROJECT_EXPORTTOOUTPUT
		invoke ExportDialog,hMdiCld,FALSE
	.elseif eax==IDM_PROJECT_REMOVE || eax==IDM_PROMNU_REMOVE
		.if eax==IDM_PROJECT_REMOVE
			invoke GetWindowText,hMdiCld,addr FileName,sizeof FileName
			invoke GetWindowLong,hMdiCld,16
			mov		nInx,eax
		.else
			invoke GetSelected,addr tvi,addr buffer,sizeof buffer
			mov		nInx,eax
			invoke strcpy,addr FileName,addr ProjectPath
			invoke strcat,addr FileName,addr buffer
			invoke GetFullPathName,addr FileName,sizeof FileName,addr FileName,addr vTmp
		.endif
		invoke strcpy,addr buffer,addr Remove
		invoke strcat,addr buffer,addr FileName
		invoke strcat,addr buffer,addr Remove2
		invoke MessageBox,hWin,addr buffer,addr AppName,MB_YESNO or MB_ICONQUESTION
		.if eax==IDYES
			invoke ProRemoveFile,addr FileName
			invoke DllProc,hWin,AIM_PROJECTREMOVE,nInx,addr FileName,RAM_PROJECTREMOVE
		.else
			.if hEdit
				invoke SetFocus,hEdit
			.endif
		.endif
	.elseif eax==IDM_PROJECT_TEMPLATE
		invoke ModalDialog,hInstance,IDD_DLGTPLCREATE,hWin,addr TplCreateProc,hWin
	.elseif eax==IDM_PROJECT_OPTIONS
		invoke ModalDialog,hInstance,IDD_PROOPTION,hWin,addr OptProjectProc,0
	.elseif eax==IDM_PROJECT_MAINFILES
		invoke ModalDialog,hInstance,IDD_DLGMAINFILES,hWin,addr MainFilesDialogProc,0
	.elseif eax==IDM_TLINK_BUG
		invoke SetTextLink,1
	.elseif eax==IDM_TLINK_NOTE
		invoke SetTextLink,2
	.elseif eax==IDM_TLINK_TODO
		invoke SetTextLink,3
	.elseif eax==IDM_PROJECT_REFRESH
		invoke RefreshProperty
		mov		fProperty,4
		invoke SetProperty,0,0
	.elseif eax==IDM_PROJECT_SCANPROJECT
		invoke ModalDialog,hInstance,IDD_DLGPROJECTSCAN,hWin,addr ScanProjectProc,0
	.elseif eax==IDM_PROMNU_FILEPROP
		invoke RefreshProperty
		mov		fProperty,3
		invoke SetProperty,0,0
	.elseif eax==IDM_PROMNU_RENAME
		invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_CARET,hPbrTrv
		.if	eax
			invoke SendMessage,hPbrTrv,TVM_EDITLABEL,0,eax
		.endif
	.elseif eax==IDM_PROMNU_COPY
		invoke GetSelected,addr tvi,addr buffer,sizeof buffer
		invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr buffer
		invoke SetFocus,hEdit
	.elseif eax==IDM_PROMNU_LOCK
		invoke GetSelected,addr tvi,addr buffer,sizeof buffer
		invoke strcpy,addr FileName,addr ProjectPath
		invoke strcat,addr FileName,addr buffer
		invoke GetFullPathName,addr FileName,sizeof FileName,addr FileName,addr vTmp
		invoke GetFileAttributes,addr FileName
		xor		eax,FILE_ATTRIBUTE_READONLY
		push	eax
		invoke SetFileAttributes,addr FileName,eax
		invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_CARET,0
		mov		tvi.hItem,eax
		mov		tvi.imask,TVIF_IMAGE or TVIF_SELECTEDIMAGE
		invoke SendMessage,hPbrTrv,TVM_GETITEM,0,addr tvi
		pop		edx
		and		edx,FILE_ATTRIBUTE_READONLY
		.if edx
			add		tvi.iImage,11
			add		tvi.iSelectedImage,11
		.else
			sub		tvi.iImage,11
			sub		tvi.iSelectedImage,11
		.endif
		invoke SendMessage,hPbrTrv,TVM_SETITEM,0,addr tvi
		mov		hFound,0
		invoke EnumChildWindows,hClient,addr CheckLoadedEnumProc,addr FileName
		.if hFound
			invoke EditAttribute,hFound,addr FileName
			invoke SendMessage,hFound,WM_PAINT,0,0
		.else
			invoke EnumChildWindows,hClient,addr CheckLoadedDlgEnumProc,addr FileName
			.if hFound
				invoke GetFileAttributes,addr FileName
				and		eax,FILE_ATTRIBUTE_READONLY
				mov		vTmp,eax
				invoke SetWindowLong,hFound,8,eax
				invoke UpdateSizeingRect,hFound,vTmp
			.endif
		.endif
	.elseif eax>=23000 && eax<=23031
		invoke GetMenuString,hMenu,eax,offset iniBuffer,16,MF_BYCOMMAND
		invoke strcpy,addr buffer2,addr AppPath
		invoke strcat,addr buffer2,addr szBackSlash
		invoke strcat,addr buffer2,addr iniBuffer
		invoke strcat,addr buffer2,addr FTIni
		invoke GetFileAttributes,addr buffer2
		.if eax!=INVALID_HANDLE_VALUE
			invoke SetAssembler,addr iniBuffer
			invoke SendMessage,hStatus,SB_SETTEXT,2,addr szAssembler
		.else
			invoke strcpy,addr LineTxt,addr OpenFileFail
			invoke strcat,addr LineTxt,addr buffer2
			invoke strcat,addr LineTxt,addr LanguagePack
			invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		.endif
	.else
		ret
	.endif
	xor		eax,eax
	ret

CmdProject endp

CmdWindow proc hWin:HWND

	.if eax==IDM_WINDOW_SPLIT
		.if hEdit
			invoke SendMessage,hEdit,REM_GETSPLIT,0,0
			.if eax
				xor		eax,eax
			.else
				mov		eax,500
			.endif
			invoke SendMessage,hEdit,REM_SETSPLIT,eax,0
		.elseif hHexEd
			invoke SendMessage,hHexEd,HEM_GETSPLIT,0,0
			.if eax
				xor		eax,eax
			.else
				mov		eax,500
			.endif
			invoke SendMessage,hHexEd,HEM_SETSPLIT,eax,0
		.endif
	.elseif eax==IDM_WINDOW_TILEHOR
		invoke SendMessage,hClient,WM_MDITILE,MDITILE_HORIZONTAL,0
	.elseif eax==IDM_WINDOW_TILEVER
		invoke SendMessage,hClient,WM_MDITILE,MDITILE_VERTICAL,0
	.elseif eax==IDM_WINDOW_CASCADE
		invoke SendMessage,hClient,WM_MDICASCADE,0,0
	.elseif eax==IDM_WINDOW_ARRANGEICONS
		invoke SendMessage,hClient,WM_MDIICONARRANGE,0,0
	.elseif eax==IDM_WINDOW_NEXTWINDOW
		invoke GetFocus
		invoke GetParent,eax
		.if eax==hOut1
			invoke OutputSelect,2
		.elseif eax==hOut2
			invoke OutputSelect,3
		.elseif eax==hOut3
			invoke OutputSelect,1
		.else
			invoke SendMessage,hClient,WM_MDINEXT,NULL,TRUE
			xor		eax,eax
			.if hEdit
				mov		eax,hEdit
			.elseif hDialog
				mov		eax,hMdiCld
			.elseif hHexEd
				mov		eax,hHexEd
			.endif
			.if eax
				invoke SetFocus,eax
			.endif
		.endif
	.elseif eax==IDM_WINDOW_PREVIOUS
		invoke GetFocus
		invoke GetParent,eax
		.if eax==hOut1
			invoke OutputSelect,3
		.elseif eax==hOut2
			invoke OutputSelect,1
		.elseif eax==hOut3
			invoke OutputSelect,2
		.else
			invoke SendMessage,hClient,WM_MDINEXT,NULL,FALSE
			xor		eax,eax
			.if hEdit
				mov		eax,hEdit
			.elseif hDialog
				mov		eax,hMdiCld
			.elseif hHexEd
				mov		eax,hHexEd
			.endif
			.if eax
				invoke SetFocus,eax
			.endif
		.endif
	.elseif eax==IDM_WINDOW_CLOSE
		invoke SendMessage,hMdiCld,WM_CLOSE,0,0
	.elseif eax==IDM_WINDOW_CLOSEALL
	  @@:
		invoke SendMessage,hClient,WM_MDIGETACTIVE,0,0
		.if eax
			push    eax
			invoke SendMessage,eax,WM_SETFOCUS,0,0
			pop     eax
			invoke SendMessage,eax,WM_CLOSE,0,0
			or      eax,eax
			je		@B
		.endif
	.elseif eax==IDM_WINDOW_CLOSEALLBUT
		push	esi
		push	edi
		invoke SendMessage,hClient,WM_MDIGETACTIVE,0,0
		; get active mdi handle in esi
		mov		esi,eax
		invoke SendMessage,hClient,WM_MDINEXT,NULL,0; go to next
	  @@:
		invoke SendMessage,hClient,WM_MDIGETACTIVE,0,0
		.if eax && eax != esi
			mov		edi,eax
			invoke SendMessage,edi,WM_SETFOCUS,0,0
			invoke SendMessage,edi,WM_CLOSE,0,0
			or      eax,eax
			je		@B
		.endif
		pop		edi
		pop		esi
	.elseif eax==IDM_WINDOW_MAXIMIZE
		mov		fMaximized,TRUE
		invoke SendMessage,hClient,WM_MDIMAXIMIZE,hMdiCld,0
	.elseif eax==IDM_WINDOW_RESTORE
		mov		fMaximized,FALSE
		invoke SendMessage,hClient,WM_MDIRESTORE,hMdiCld,0
	.elseif eax==IDM_WINDOW_MINIMIZE
		invoke ShowWindow,hMdiCld,SW_MINIMIZE
	.elseif eax==IDM_WINDOW_EDIT
		.if hEdit
			mov		eax,hEdit
		.elseif hDialog
			mov		eax,hDialog
		.elseif hHexEd
			mov		eax,hHexEd
		.else
			mov		eax,hWnd
		.endif
		invoke SetFocus,eax
	.elseif eax==IDM_WINDOW_PROJECT
		invoke IsWindowVisible,hPbrTrv
		.if eax
			invoke SetFocus,hPbrTrv
		.else
			invoke SetFocus,hFileTrv
		.endif
	.elseif eax==IDM_WINDOW_PROPERTY
		invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
		.if eax==LB_ERR
			invoke SendMessage,hPrpLst,LB_SETCURSEL,0,0
		.endif
		invoke SetFocus,hPrpLst
	.elseif eax==IDM_WINDOW_OUTPUT
		invoke ShowOutput
		invoke SetFocus,hOutREd
	.else
		ret
	.endif
	xor		eax,eax
	ret

CmdWindow endp

CmdOption proc hWin:HWND

	.if eax==IDM_OPTION_LANGUAGE
		invoke ModalDialog,hInstance,IDD_DLGLANGUAGE,hWin,addr LanguageOptionProc,0
	.elseif eax==IDM_OPTION_PROGLANGUAGE
		invoke ModalDialog,hInstance,IDD_DLGPROGLANGUAGE,hWin,addr ProgLanguageProc,0
	.elseif eax==IDM_OPTION_COLORS
		invoke ModalDialog,hInstance,IDD_DLGKEYWORDS,hWin,addr KeyWordsProc,0
	.elseif eax==IDM_OPTION_PRNCOLORS
		invoke ModalDialog,hInstance,IDD_DLGPRINTOPTION,hWin,addr PrintOptionProc,0
	.elseif eax==IDM_OPTION_ACCEL
		invoke ModalDialog,hInstance,IDD_DLGACCELOPTION,hWin,addr AccelOptionProc,0
	.elseif eax==IDM_OPTION_FONTS
		invoke ModalDialog,hInstance,IDD_OPTION_FONTS,hWin,addr FontOptionProc,0
	.elseif eax==IDM_OPTION_EDIT
		invoke ModalDialog,hInstance,IDD_DLGEDITOPTION,hWin,addr EditOptionProc,0
	.elseif eax==IDM_OPTION_DIALOG
		invoke ModalDialog,hInstance,IDD_DLGOPTION,hWin,addr OptDialogProc,0
	.elseif eax==IDM_OPTION_CUSTCTRL
		invoke ModalDialog,hInstance,IDD_DLGCUSTCTRL,hWin,addr CustomControlsProc,0
	.elseif eax==IDM_OPTION_FILEASS
		invoke ModalDialog,hInstance,IDD_DLGOPTIONFILEASS,hWin,addr FileAssDialogProc,0
	.elseif eax==IDM_OPTION_FILEBROWSER
		invoke ModalDialog,hInstance,IDD_DLGFILEBROWSER,hWin,addr FileBrowserProc,0
	.elseif eax==IDM_OPTION_EXTERNALFILE
		invoke ModalDialog,hInstance,IDD_DLGEXTERNALFILE,hWin,addr ExternalFileProc,0
	.elseif eax==IDM_OPTION_SNIPLET
		invoke ModalDialog,hInstance,IDD_SNIPLETOPTION,hWin,addr SnipletOptionProc,0
	.elseif eax==IDM_OPTION_PATHS
		invoke ModalDialog,hInstance,IDD_PATHOPTION,hWin,addr PathOptionProc,0
	.elseif eax==IDM_OPTION_ENVIRONMENT
		invoke ModalDialog,hInstance,IDD_ENVIRONMENTOPTION,hWin,addr EnvironmentOptionsProc,0
	.elseif eax==IDM_OPTION_TOOLWINDOWS
		invoke ModalDialog,hInstance,IDD_TOOLOPTIONS,hWin,addr ToolOptionsProc,0
	.elseif eax==IDM_OPTION_MAKEMNU
		invoke ModalDialog,hInstance,IDD_DLGOPTMNU,hWin,addr MenuOptionProc,1
	.elseif eax==IDM_OPTION_TOOLMNU
		invoke ModalDialog,hInstance,IDD_DLGOPTMNU,hWin,addr MenuOptionProc,2
	.elseif eax==IDM_OPTION_HELPMNU
		invoke ModalDialog,hInstance,IDD_DLGOPTMNU,hWin,addr MenuOptionProc,3
	.else
		ret
	.endif
	xor		eax,eax
	ret

CmdOption endp

CmdMenus proc hWin:HWND,wParam:WPARAM
	LOCAL	iNbr:DWORD
	LOCAL	nMiss:DWORD
	LOCAL   buffer[256]:BYTE
	LOCAL   buffer2[256]:BYTE
	LOCAL   buffer3[256]:BYTE
	LOCAL   buffer4[256]:BYTE
	LOCAL   buffer5[256]:BYTE
	LOCAL   buffer6[256]:BYTE

	movzx	eax,word ptr wParam
	.if eax>=20001 && eax<=20128
		push	eax
		invoke SetFocus,hWnd
		pop		eax
		sub		eax,20001
		mov		ecx,sizeof MENU
		mul		ecx
		add		eax,offset MenuData
		push	eax
		invoke strcpy,addr buffer,eax
		pop		edx
		inc		(MENU ptr [edx]).ncalls
		mov		al,(MENU ptr [edx]).param
		.if al=='P'
			;Open MRU project
			invoke strcpy,addr FileName,addr buffer
			invoke OpenProject,TRUE
		.elseif al=='K'
			.if hEdit
				invoke SetFocus,hEdit
				invoke MacroPlay,addr buffer
			.endif
		.elseif al=='M'
			;Make
			invoke LoadCursor,0,IDC_WAIT
			invoke SetCursor,eax
			.if AutoSave
				invoke UpdateAll,IDM_FILE_SAVEALLFILES
			.endif
			invoke ClearErrorBookMarks
			invoke OutputSelect,1
			invoke OutputClear
			movzx	eax,word ptr wParam
			.if (eax==IDM_MAKE_GO || eax==IDM_MAKE_BUILD) && fProject && fResProject
			mov		word ptr iniBuffer,'1'
				.if fProject
					invoke GetPrivateProfileString,addr iniMakeDef,addr iniBuffer,addr szNULL,addr iniBuffer,192,addr ProjectFile
					.if !eax
					   	invoke GetPrivateProfileString,addr ProjectType,addr iniBuffer,addr szNULL,addr iniBuffer,192,addr iniAsmFile
					.endif
				.else
					invoke GetPrivateProfileString,addr iniMakeDefNoPro,addr iniBuffer,addr szNULL,addr iniBuffer,192,addr iniAsmFile
				.endif
				.if eax
					.if !fResChanged
						invoke ResFileExist
						.if !eax
							mov		fResChanged,TRUE
						.endif
					.endif
					.if fResChanged
						invoke CmdMenus,hWin,IDM_MAKE_COMPILERC
						.if eax
							xor		eax,eax
							ret
						.endif
					.endif
				.endif
			.endif
			invoke DllProc,hWin,AIM_MAKEBEGIN,0,addr buffer,RAM_MAKEBEGIN
			mov		word ptr buffer2,'3'
			invoke iniInStr,addr buffer,addr buffer2
			.if eax!=-1
				mov		dword ptr buffer6,'9999'
				invoke OutPutMake,addr buffer2,addr buffer6
				.if eax
					jmp		Err
				.endif
			.endif
		  @@:
			.if fProject
				invoke SetPath,addr ProjectPath
			.else
				.if hMdiCld
					invoke GetWindowText,hMdiCld,addr buffer2,sizeof buffer2
					invoke iniRStripStr,addr buffer2,'\'
					invoke SetPath,addr buffer2
				.endif
			.endif
			mov		dword ptr buffer2,0
			invoke iniGetItem,addr buffer,addr buffer2
			movzx	eax,word ptr buffer2
			.if eax
				.if eax=='6'
					mov		nMiss,0
					mov		iNbr,PRO_START_OBJ
				  Nx:
					invoke GetFileNameFromID,iNbr
					.if eax
						invoke strcpy,addr buffer6,eax
						mov		nMiss,0
						invoke GetFileImg,addr buffer6
						.if eax==3
							invoke iniRStripStr,addr buffer6,'.'
							invoke DllProc,hWin,AIM_MODULEBUILD,addr buffer6,0,RAM_MODULEBUILD
							.if !eax
								push	dword ptr buffer2
								invoke OutPutMake,addr buffer2,addr buffer6
								pop		dword ptr buffer2
							.else
								xor		eax,eax
							.endif
							or		eax,eax
							jne		Err
						.endif
					.else
						inc		nMiss
					.endif
					inc		iNbr
					cmp		nMiss,PRO_MAX_MISS
					jne		Nx
				.else
					invoke OutPutMake,addr buffer2,addr buffer2
				.endif
				or		eax,eax
				je		@b
			  Err:
				.if eax!=1234
					invoke TextToOutput,addr szErrors
				.endif
				mov		eax,TRUE
			.else
				mov		AsmFlag,FALSE
				invoke TextToOutput,addr szFinished
				movzx	eax,word ptr wParam
				.if eax==IDM_MAKE_COMPILERC
					mov		fResChanged,0
				.endif
				.if !make.fRun
					mov		eax,hEdit
					.if !eax
						mov		eax,hWnd
					.endif
					invoke SetFocus,eax
				.endif
				xor		eax,eax
			.endif
			push	eax
			invoke DllProc,hWin,AIM_MAKEDONE,0,eax,RAM_MAKEDONE
			.if AsmFlag
				invoke FindErrors,addr tempbuff
			.endif
			invoke LoadCursor,0,IDC_ARROW
			invoke SetCursor,eax
			pop		eax
			ret
		.elseif al=='H'
			invoke iniInStr,addr buffer,offset FTExe
			inc		eax
			jne		@f
			invoke iniInStr,addr buffer,offset FTHlp
			.if eax==-1
				invoke ShellExecute,hWin,NULL,addr buffer,NULL,NULL,SW_SHOWDEFAULT
			.else
				invoke WinHelp,hWin,addr buffer,HELP_KEY,addr szNULL
			.endif
		.elseif al=='T'
		  @@:
			invoke iniGetItem,addr buffer,addr buffer2
			mov		al,buffer2[0]
			.if al
				invoke GetShortPathName,addr buffer2,addr buffer2,sizeof buffer2
			.endif
			mov		al,buffer[0]
			.if al
				mov		buffer3[0],0
				mov		buffer4[0],0
				.if fProject
					invoke strcpy,addr buffer4,addr ProjectPath
					invoke strlen,addr buffer4
					lea		edx,[buffer4+eax-1]
					mov		byte ptr [edx],0
					invoke GetShortPathName,addr buffer4,addr buffer4,sizeof buffer4
				.endif
			  @@:
				invoke iniGetItem,addr buffer,addr buffer5
				mov		ax,word ptr buffer5[0]
				.if !fProject && al>='0' && al<='9'
					invoke RtlZeroMemory,addr ofn,sizeof ofn
					mov		ofn.lStructSize,sizeof ofn
					m2m		ofn.hwndOwner,hWnd
					m2m		ofn.hInstance,hInstance
					mov		ofn.lpstrFilter,offset ANYFilterString
					lea		eax,buffer5
					mov		ofn.lpstrFile,eax
					mov		buffer5[0],0
					mov		ofn.nMaxFile,sizeof buffer5
					mov		ofn.lpstrDefExt,0
					mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
					invoke GetOpenFileName,addr ofn
					.if eax
						invoke GetShortPathName,addr buffer5,addr buffer5,sizeof buffer5
						mov		eax,TRUE
					.endif
				.elseif fProject && al>='0' && al<='9'
					mov		word ptr buffer5[0],ax
					mov		buffer5[2],0
					invoke GetPrivateProfileString,addr iniMakeFile,addr buffer5,addr szNULL,addr buffer5,128,addr ProjectFile
					invoke strcpy,offset FileName,offset ProjectPath
					invoke strcat,offset FileName,addr buffer5
					invoke strcpy,addr buffer5,offset FileName
					invoke GetShortPathName,addr buffer5,addr buffer5,sizeof buffer5
					mov		eax,TRUE
				.elseif ax=='$$'
					.if hEdit
						invoke GetWindowText,hMdiCld,addr buffer5,sizeof buffer5
						invoke GetShortPathName,addr buffer5,addr buffer5,sizeof buffer5
						mov		eax,TRUE
					.else
						mov		eax,FALSE
					.endif
				.elseif al=='$'
					.if hEdit
						invoke strcpy,addr buffer6,addr buffer5[1]
						invoke GetWindowText,hMdiCld,addr buffer5,sizeof buffer5
						invoke GetShortPathName,addr buffer5,addr buffer5,sizeof buffer5
						invoke iniRStripStr,addr buffer5,'.'
						invoke strcat,addr buffer5,addr buffer6
						mov		eax,TRUE
					.else
						mov		eax,FALSE
					.endif
				.endif
				.if eax
					invoke strcat,addr buffer3,addr buffer5
					mov		al,buffer[0]
					.if al
						invoke strcat,addr buffer3,addr szSpace
						jmp		@b
					.endif
					mov		al,buffer2[0]
					.if al
						invoke ShellExecute,hWin,NULL,addr buffer2,addr buffer3,addr buffer4,SW_SHOWDEFAULT
					.else
						invoke ShellExecute,hWin,NULL,addr buffer3,NULL,NULL,SW_SHOWDEFAULT
					.endif
				.endif
			.else
				invoke ShellExecute,hWin,NULL,addr buffer2,NULL,NULL,SW_SHOWDEFAULT
			.endif
		.endif
	.else
		ret
	.endif
	xor		eax,eax
	ret

CmdMenus endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL   tbH:DWORD
	LOCAL   sbH:DWORD
	LOCAL   rect:RECT
	LOCAL   ps:PAINTSTRUCT
	LOCAL   cc:CLIENTCREATESTRUCT
	LOCAL   buffer[256]:BYTE
	LOCAL   buffer2[256]:BYTE
	LOCAL	lf:LOGFONT
	LOCAL	pt:POINT
	LOCAL   chrg:CHARRANGE
	LOCAL	nInx:DWORD
	LOCAL	hMem:DWORD

	mov		eax,uMsg
	.if eax==WM_SIZE
		.if wParam!=SIZE_MINIMIZED
			mov		eax,lParam
			.if eax
				.if eax!=OldHtWt
					mov		OldHtWt,eax
					invoke MoveWindow,hStatus,0,0,0,0,FALSE
				.endif
			.else
				invoke LockWindowUpdate,hWin
			.endif
			.if winTbr
				invoke GetWindowRect,hToolBar,addr rect
				mov		eax,rect.bottom
				sub		eax,rect.top
				add		eax,2
			.else
				xor		eax,eax
			.endif
			mov		tbH,eax
			.if winSbr
				invoke GetWindowRect,hStatus,addr rect
				mov		eax,rect.bottom
				sub		eax,rect.top
			.else
				xor		eax,eax
			.endif
			mov		sbH,eax
			invoke GetClientRect,hWin,addr rect
			mov		ecx,rect.right
			inc		ecx
			xor		edx,edx
			.if winTbr
				mov		edx,2
			.endif
			invoke MoveWindow,hDivLine,0,0,ecx,edx,TRUE
			xor		edx,edx
			.if fDivider
				mov		edx,2
			.endif
			mov		eax,tbH
			add		eax,edx
			add		rect.top,eax
			mov		eax,sbH
			sub		rect.bottom,eax
			mov		eax,rect.top
			sub		eax,edx
			mov		ecx,rect.right
			inc		ecx
			invoke MoveWindow,hDivider,0,eax,ecx,edx,TRUE
			invoke CopyRect,offset mdirect,addr rect
			invoke ToolMessage,0,TLM_SIZE,addr rect
			.if !lParam
				invoke LockWindowUpdate,0
			.endif
			.if wParam==SIZE_RESTORED
				invoke GetSystemMetrics,SM_CXSCREEN
				.if eax==scrnsize.ccx
					invoke GetWindowRect,hWin,addr scrnsize.rect
					mov		scrnsize.fmax,FALSE
				.endif
			.elseif wParam==SIZE_MAXIMIZED
				mov		scrnsize.fmax,TRUE
			.endif
		.endif
	.elseif eax==WM_COPYDATA
		push	esi
		push	edi
		mov		esi,lParam
		mov		ecx,[esi].COPYDATASTRUCT.cbData
		mov		esi,[esi].COPYDATASTRUCT.lpData
		.if !wParam
			push	ecx
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
			mov		edi,eax
			pop		ecx
			push	edi
			rep movsb
			pop		edi
			invoke OpenCommandLine,edi
			invoke GlobalFree,edi
		.elseif wParam==-1
			mov		edi,offset FileName
			rep movsb
			invoke SendMessage,hWin,WM_COMMAND,-1,-1
		.endif
		pop		edi
		pop		esi
		ret
	.elseif eax==WM_MOUSEMOVE
		invoke ToolMessage,0,TLM_MOUSEMOVE,lParam
	.elseif eax==WM_LBUTTONDOWN
		invoke ToolMessage,0,TLM_LBUTTONDOWN,lParam
	.elseif eax==WM_LBUTTONUP
		invoke ToolMessage,0,TLM_LBUTTONUP,lParam
	.elseif eax==WM_TOOLDBLCLICK
		mov		eax,wParam
		.if eax==hPbrTrv
			invoke ProjectDblClick,hPbrTrv,lParam
		.endif
	.elseif eax==WM_TOOLCLICK

	.elseif eax==WM_TOOLRCLICK
		mov		eax,wParam
		.if eax==hPbrTrv
			invoke ProjectRClick,hPbrTrv,lParam
		.endif
	.elseif eax==WM_TOOLSIZE
		mov		eax,wParam
		.if eax==hTlb
			invoke ToolBoxSize,lParam
		.elseif eax==hPrp
			invoke ToolPropertySize,lParam
		.elseif eax==hPbr
			invoke ToolProjectSize,lParam
		.elseif eax==hOut
			invoke ToolOutputSize,lParam
		.elseif eax==hInf
			invoke InfoToolSize,lParam
		.endif
	.elseif eax==WM_INITMENUPOPUP
		invoke MenuStatus
		invoke DllProc,hWin,AIM_INITMENUPOPUP,wParam,lParam,RAM_INITMENUPOPUP
		mov 	eax,lParam
		.if fMaximized
			dec		eax
		.endif
		.if ax==MENUFILE
			invoke SetRecentFilesMenu
		.elseif ax==MENUFORMAT
			mov		eax,0
			.if hMdiCld
				.if hDialog
					invoke GetWindowLong,hMdiCld,4
					.if eax
						mov		eax,(DLGHEAD ptr [eax]).locked
						.if eax
							mov		eax,MF_CHECKED
						.endif
					.endif
				.endif
			.endif
			invoke CheckMenuItem,hMenu,IDM_FORMAT_LOCKCONTROLS,eax
			mov		eax,fGrid
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_FORMAT_SHOWGRID,eax
		.elseif	ax==MENUVIEW
			mov		eax,winTbr
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_TOOLBAR,eax
			invoke ToolMessage,hTlb,TLM_GET_VISIBLE,0
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_TOOLBOX,eax
			invoke ToolMessage,hOut,TLM_GET_VISIBLE,0
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_OUTPUTWINDOW,eax
			invoke ToolMessage,hPbr,TLM_GET_VISIBLE,0
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_PROJECTBROWSER,eax
			invoke ToolMessage,hPrp,TLM_GET_VISIBLE,0
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_PROPERTIES,eax
			invoke ToolMessage,hTab,TLM_GET_VISIBLE,0
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_TABTOOL,eax
			invoke ToolMessage,hInf,TLM_GET_VISIBLE,0
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_INFOTOOL,eax
			invoke ToolMessage,hTl1,TLM_GET_VISIBLE,0
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_TOOL1,eax
			invoke ToolMessage,hTl2,TLM_GET_VISIBLE,0
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_TOOL2,eax
			mov		eax,winSbr
			.if eax
				mov		eax,MF_CHECKED
			.endif
			invoke CheckMenuItem,hMenu,IDM_VIEW_STATUSBAR,eax
		.elseif ax==MENUPROJECT
			push	ebx
			xor		ebx,ebx
			.while TRUE
				invoke GetMenuString,hMnuAsm,ebx,addr buffer,sizeof buffer,MF_BYPOSITION
				.break .if !eax
				invoke strcmpi,addr buffer,addr szAssembler
				.if !eax
					invoke CheckMenuItem,hMnuAsm,ebx,MF_BYPOSITION or MF_CHECKED
				.else
					invoke CheckMenuItem,hMnuAsm,ebx,MF_BYPOSITION or MF_UNCHECKED
				.endif
				inc		ebx
			.endw
			pop		ebx
		.endif
	.elseif eax==WM_COMMAND
		invoke DllProc,hWin,AIM_COMMAND,wParam,lParam,RAM_COMMAND
		.if wParam==-1 && lParam==-1
			ret
		.endif
		.if eax
			jmp		Ex
		.endif
		.if hProjectGroup
			invoke SendMessage,hProjectGroup,uMsg,wParam,lParam
			jmp		Ex
		.endif
		mov		eax,wParam
		shr		eax,16
		.if eax==BN_CLICKED || eax==1
			invoke GetActive
			.if hDialog
				invoke SetFocus,hMdiCld
			.endif
			movzx	eax,word ptr wParam
			.if eax==IDM_HELPF1
				mov		LineWord[0],0
				.if fLB
					invoke SendMessage,hLB,LB_GETCURSEL,0,0
					.if eax!=LB_ERR
						invoke SendMessage,hLB,LB_GETTEXT,eax,offset LineWord
					.endif
				.else
					.if hEdit
						invoke GetWordFromPos,hEdit
					.endif
				.endif
				invoke DoHelp,offset F1,offset LineWord
				;invoke WinHelp,hWin,offset F1,HELP_KEY,offset LineWord
				inc		nF1
				xor		eax,eax
			.else
				push	eax
				invoke ShowWindow,hTlt,SW_HIDE
				mov		fTlt,0
				invoke ShowWindow,hLB,SW_HIDE
				xor		eax,eax
				mov		fLB,eax
				mov		fLBConst,eax
				mov		fLBStruct,eax
				mov		fLBWord,eax
				mov		fLBType,eax
				pop		eax
			.endif
			.if eax
				invoke CmdFile,hWin
			.endif
			.if eax
				invoke CmdEdit,hWin
			.endif
			.if eax
				invoke CmdView,hWin
			.endif
			.if eax
				invoke CmdFormat,hWin
			.endif
			.if eax
				invoke CmdProject,hWin
			.endif
			.if eax
				invoke CmdWindow,hWin
			.endif
			.if eax
				invoke CmdOption,hWin
			.endif
			.if eax
				invoke CmdMenus,hWin,wParam
				.if eax==1
					xor		eax,eax
				.endif
			.endif
			.if eax
				.if eax==IDM_USERBTN1
					mov		eax,UserBtnID
					invoke PostMessage,hWin,WM_COMMAND,eax,0
				.elseif eax==IDM_USERBTN2
					mov		eax,UserBtnID
					inc		eax
					invoke PostMessage,hWin,WM_COMMAND,eax,0
				.elseif eax==IDM_TOOLS_SNIPLETS
					invoke ModelessDialog,hInstance,IDD_DLGSNIPLETS,hWin,addr SnipletsProc,0
				.elseif eax==IDM_TOOLS_EXPORT
					invoke ModalDialog,hInstance,IDD_DLGEXPORTID,hWin,addr ExportIDProc,0
				.elseif eax==IDM_MACRO_RECORD
					invoke MacroRecord
				.elseif eax==IDM_MACRO_MANAGE
					invoke ModalDialog,hInstance,IDD_DLGOPTMNU,hWin,addr MenuOptionProc,4
				.elseif eax==IDM_HELP_ABOUT
					invoke ModalDialog,hInstance,IDD_DLGABOUT,hWin,addr AboutProc,0
				.elseif eax==IDM_HELPCF1
					mov		LineWord[0],0
					.if hEdit
						invoke GetWordFromPos,hEdit
					.endif
					invoke DoHelp,offset CF1,offset LineWord
					;invoke WinHelp,hWin,addr CF1,HELP_KEY,addr LineWord
					inc		nCF1
				.elseif eax==IDM_HELPSF1
					mov		LineWord[0],0
					.if hEdit
						invoke GetWordFromPos,hEdit
					.endif
					invoke DoHelp,offset SF1,offset LineWord
					;invoke WinHelp,hWin,addr SF1,HELP_KEY,addr LineWord
					inc		nSF1
				.elseif eax==IDM_HELPCSF1
					mov		LineWord[0],0
					.if hEdit
						invoke GetWordFromPos,hEdit
					.endif
					invoke DoHelp,offset CSF1,offset LineWord
					;invoke WinHelp,hWin,addr CSF1,HELP_KEY,addr LineWord
					inc		nCSF1
				.elseif eax==IDM_OUTPUT_OPEN
					invoke OpenEditOut
				.elseif eax==IDM_OUTPUT_SAVE
					invoke SaveEditOutAs,hOutREd
				.elseif eax==IDM_OUTPUT_UNDO
					invoke SendMessage,hOutREd,EM_UNDO,0,0
				.elseif eax==IDM_OUTPUT_REDO
					invoke SendMessage,hOutREd,EM_REDO,0,0
				.elseif eax==IDM_OUTPUT_CUT
					invoke SendMessage,hOutREd,WM_CUT,0,0
				.elseif eax==IDM_OUTPUT_COPY
					invoke SendMessage,hOutREd,WM_COPY,0,0
				.elseif eax==IDM_OUTPUT_PASTE
					invoke SendMessage,hOutREd,WM_PASTE,0,0
				.elseif eax==IDM_OUTPUT_DELETE
					invoke SendMessage,hOutREd,EM_REPLACESEL,TRUE,0
				.elseif eax==IDM_OUTPUT_CLEAR
					invoke SendMessage,hOutREd,WM_SETTEXT,0,addr szNULL
				.elseif eax==IDM_OUTPUT_COPYALL
					mov		chrg.cpMin,0
					mov		chrg.cpMax,-1
					invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hOutREd,WM_COPY,0,0
				.elseif eax==IDM_OUTPUT_CUTALL
					mov		chrg.cpMin,0
					mov		chrg.cpMax,-1
					invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hOutREd,WM_CUT,0,0
				.elseif eax==IDM_PROPERTY_GOTO
					invoke SendMessage,hPrpLstCode,WM_LBUTTONDBLCLK,0,0
				.elseif eax==IDM_PROPERTY_SCAN
					call GetLbText
					invoke ScanProject,addr lbbuffer
				.elseif eax==IDM_PROPERTY_FIND
					call GetLbText
					invoke strcpy,offset FindBuffer,addr lbbuffer
					.if hSearch
						invoke SetDlgItemText,hSearch,IDC_FINDCBO,offset FindBuffer
					.endif
					invoke SendMessage,hWnd,WM_COMMAND,IDM_EDIT_FIND,0
				.elseif eax==IDM_PROPERTY_FINDNEXT
					call GetLbText
					invoke strcpy,offset FindBuffer,addr lbbuffer
					invoke SendMessage,hWnd,WM_COMMAND,IDM_EDIT_FINDNEXT,0
				.elseif eax==IDM_PROPERTY_FINDPREV
					call GetLbText
					invoke strcpy,offset FindBuffer,addr lbbuffer
					invoke SendMessage,hWnd,WM_COMMAND,IDM_EDIT_FINDPREVIOUS,0
				.elseif eax==IDM_PROPERTY_COPY
					call GetLbText
					invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr lbbuffer
					invoke SetFocus,hEdit
				.elseif eax==IDM_PROPERTY_PROTO
					invoke SendMessage,hPrpLstCode,LB_GETCURSEL,0,0
					.if eax!=LB_ERR
						push	esi
						push	edi
						mov		nInx,eax
						invoke SendMessage,hPrpLstCode,LB_GETTEXT,nInx,addr lbbuffer
						lea		edi,lbbuffer[2048]
						mov		byte ptr [edi],09h
						inc		edi
						invoke ProtoFindProc,addr lbbuffer
						.if eax
							mov		esi,eax
							invoke strlen,esi
							lea		esi,[esi+eax+1]
							mov		al,[esi]
							.if al
							  @@:
								mov		al,[esi]
								.if al==':'
									.while al!=',' && al
										mov		[edi],al
										inc		edi
										inc		esi
										mov		al,[esi]
									.endw
									mov		byte ptr [edi],','
									inc		edi
									.if al==','
										inc		esi
										jmp		@b
									.endif
								.elseif al
									inc		esi
									jmp		@b
								.endif
							.endif
						.endif
						dec		edi
						mov		byte ptr [edi],0
						invoke strlen,addr lbbuffer
						mov		ecx,TabSize
						xor		edx,edx
						div		ecx
						mul		ecx
						.while eax<20
							push	eax
							invoke strcat,addr lbbuffer,offset szTab
							pop		eax
							add		eax,TabSize
						.endw
						invoke strcat,addr lbbuffer,offset szTab
						invoke strcat,addr lbbuffer,offset szPROTO
						invoke strcat,addr lbbuffer,addr lbbuffer[2048]
						pop		edi
						pop		esi
					.endif
					invoke strcat,addr lbbuffer,offset szCR
					invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr lbbuffer
					invoke SetFocus,hEdit
				.else
					jmp		ExDef
				.endif
			.endif
			invoke DllProc,hWin,AIM_COMMANDDONE,wParam,lParam,RAM_COMMANDDONE
			mov		nLineTick,1
		.endif
	.elseif eax==WM_ACTIVATE
		.if hEdit
			invoke SetFocus,hEdit
		.elseif hHexEd
			invoke SetFocus,hHexEd
		.elseif hDialog
			invoke SendMessage,hDialog,WM_NCACTIVATE,TRUE,0
		.endif
		mov		eax,wParam
		movzx	eax,ax
		.if eax==WA_INACTIVE
			.if fTlt
				invoke ShowWindow,hTlt,SW_HIDE
				mov		fTlt,0
			.endif
			.if fLB
				invoke ShowWindow,hLB,SW_HIDE
				xor		eax,eax
				mov		fLB,eax
				mov		fLBConst,eax
				mov		fLBStruct,eax
				mov		fLBWord,eax
				mov		fLBType,eax
			.endif
		.endif
		mov		nLineTick,2
	.elseif eax==WM_CONTEXTMENU
		mov		eax,wParam
		.if eax==hToolBar
			invoke GetCapture
			.if eax
				invoke ReleaseCapture
			.endif
			xor		eax,eax
			ret
		.endif
		invoke GetCapture
		.if eax
			xor		eax,eax
			ret
		.endif
		invoke DllProc,hWin,AIM_CONTEXTMENU,wParam,lParam,RAM_CONTEXTMENU
		.if eax
			xor		eax,eax
			ret
		.endif
		mov		eax,lParam
		.if eax!=-1
			cwde
			mov		pt.x,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			mov		pt.y,eax
		.else
			invoke GetWindowRect,hClient,addr rect
			mov		eax,rect.left
			add		eax,10
			mov		pt.x,eax
			mov		eax,rect.top
			add		eax,10
			mov		pt.y,eax
		.endif
		.if fMaximized
			invoke GetSubMenu,hMenu,MENUFILE+1
		.else
			invoke GetSubMenu,hMenu,MENUFILE
		.endif
		invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWnd,0
	.elseif eax==WM_CREATE
		m2m     hWnd,hWin
		invoke GetSystemMetrics,SM_CXSCREEN
		mov		scrnsize.ccx,eax
		;Toolbar
		invoke DoToolBar
		;Statusbar
		invoke DoStatus
		mov		cc.hWindowMenu,0
		mov		cc.idFirstChild,ID_FIRSTCHILD
		;Mdi Client
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr mdiCl,NULL,WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_HSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,0,0,0,0,hWin,NULL,hInstance,addr cc
		mov     hClient,eax
		invoke SetupMenus,hWin
		invoke SetWindowLong,hClient,GWL_WNDPROC,addr ClientProc
		mov		OldClientProc,eax
		;Api ListBox & fake Toolrip font
		invoke CreateFontIndirect,addr lfnttool
		mov     hLBFont,eax
		;Dialog font
		invoke CreateFontIndirect,addr lfntide
		mov		hFontIde,eax
		;Tab tool
		invoke RtlZeroMemory,addr lf,sizeof lf
		mov		lf.lfHeight,-10
		mov		lf.lfWeight,700
		invoke strcpy,addr lf.lfFaceName,addr szTTFont
		invoke CreateFontIndirect,addr lf
		mov     hTTFont,eax
		invoke CreateWindowEx,0,addr szStatic,NULL,WS_CHILD or WS_VISIBLE or 10h,0,0,0,0,hWin,NULL,hInstance,NULL
		mov		hDivLine,eax
		invoke CreateWindowEx,0,addr szStatic,NULL,WS_CHILD or WS_VISIBLE or 10h,0,0,0,0,hWin,NULL,hInstance,NULL
		mov		hDivider,eax
		invoke ToolMessage,0,TLM_INIT,0
		;Create the tools in clipping order
		invoke strcpy,addr buffer,addr Clipping
	  @@:
		invoke iniGetItem,addr buffer,addr buffer2
		mov		al,buffer2[0]
		.if al
			.if al=='1'
				;Project Explorer With Tree View
				invoke Do_ProjectTool
				mov     hPbr,eax
			.elseif al=='2'
				;Output Window With RichEdit
				invoke Do_OutPutTool
				mov     hOut,eax

			.elseif al=='3'
				;ToolBox With Buttons
				invoke Do_ToolBox
				mov     hTlb,eax
			.elseif al=='4'
				;Property with cbo & lst
				invoke Do_Properties
				mov     hPrp,eax
			.elseif al=='5'
				;TabTool
				invoke Do_TabTool
				mov     hTab,eax
			.elseif al=='6'
				;InfoTool
				invoke Do_InfoTool
				mov     hInf,eax
			.elseif al=='7'
				;Tool1
				invoke Do_Tool1
				mov     hTl1,eax
			.elseif al=='8'
				;Tool2
				invoke Do_Tool2
				mov     hTl2,eax
			.endif
			jmp		@b
		.endif
		invoke GetPrivateProfileString,addr iniAssembler,addr iniAssembler,addr szNULL,addr iniBuffer,128,addr iniFile
		.while iniBuffer
			invoke iniGetItem,addr iniBuffer,addr buffer
			invoke strcpy,addr iniAsmFile,addr AppPath
			invoke strcat,addr iniAsmFile,addr szBackSlash
			invoke strcat,addr iniAsmFile,addr buffer
			invoke strcat,addr iniAsmFile,addr FTIni
			invoke GetFileAttributes,addr iniAsmFile
			.break .if eax!=INVALID_HANDLE_VALUE
		.endw
		.if eax==INVALID_HANDLE_VALUE
			invoke ExitProcess,1
		.endif
		invoke SetAssembler,addr buffer
		;Set menu & toolbar
		invoke MenuStatus
		;Fake Tooltip brush
		invoke CreateSolidBrush,0E0FFFFh
		mov		hBrTlt,eax
		;Property brush
		.if hBrPrp
			invoke DeleteObject,hBrPrp
		.endif
		invoke CreateSolidBrush,radcol.properties
		mov		hBrPrp,eax
		;Info brush
		.if hBrInfo
			invoke DeleteObject,hBrInfo
		.endif
		invoke CreateSolidBrush,radcol.info
		mov		hBrInfo,eax
		;Dialog brush
		.if hBrDlg
			invoke DeleteObject,hBrDlg
		.endif
		invoke CreateSolidBrush,radcol.dialogedit
		mov		hBrDlg,eax
		invoke MakeGridBrush
		;Create the imagelist
		invoke ImageList_Create,16,16,ILC_MASK or ILC_COLOR8,16,0
		mov		hTypeIml,eax
		invoke LoadBitmap,hInstance,IDB_TYPES
		push	eax
		invoke ImageList_AddMasked,hTypeIml,eax,0FF00FFh
		pop		eax
		invoke DeleteObject,eax
		;Api listbox unsorted
		invoke CreateWindowEx,WS_EX_PALETTEWINDOW or WS_EX_TOPMOST,addr szListBox,NULL,WS_CHILD or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_SIZEBOX or WS_VSCROLL or LBS_HASSTRINGS or LBS_USETABSTOPS or LBS_OWNERDRAWVARIABLE,0,0,apilbwt,apilbht,hWin,NULL,hInstance,NULL
		mov		hLBU,eax
		mov		hLB,eax
		INVOKE GetDesktopWindow
		invoke SetWindowLong,hLBU,GWL_HWNDPARENT,eax
		;Set font
		invoke SendMessage,hLBU,WM_SETFONT,hLBFont,0
		;Subclass the listbox control
		invoke SetWindowLong,hLBU,GWL_WNDPROC, addr ListBoxProc
		mov		OldListBoxProc,eax
		;Api listbox sorted
		invoke CreateWindowEx,WS_EX_PALETTEWINDOW or WS_EX_TOPMOST,addr szListBox,NULL,WS_CHILD or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_SIZEBOX or WS_VSCROLL or LBS_HASSTRINGS or LBS_USETABSTOPS or LBS_SORT or LBS_OWNERDRAWVARIABLE,0,0,apilbwt,apilbht,hWin,NULL,hInstance,NULL
		mov		hLBS,eax
		INVOKE GetDesktopWindow
		invoke SetWindowLong,hLBS,GWL_HWNDPARENT,eax
		;Set font
		invoke SendMessage,hLBS,WM_SETFONT,hLBFont,0
		;Subclass the listbox control
		invoke SetWindowLong,hLBS,GWL_WNDPROC, addr ListBoxProc
		mov		OldListBoxProc,eax
		;Fake tooltip
		invoke CreateWindowEx,WS_EX_TOPMOST,addr szStatic,0,WS_POPUP or WS_BORDER or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,0,0,0,0,hWin,0,hInstance,0
		mov		hTlt,eax
		invoke SendMessage,hTlt,WM_SETFONT,hLBFont,0
		invoke SetPath,addr App
		invoke DllHook,hWin
		invoke SetTimer,hWin,200,100,addr TimerProc
		invoke ToolBarStatus
		invoke SendMessage,hStatus,SB_SETTEXT,2,addr szAssembler
		invoke iniSetAsmMenu
		invoke FileDir,offset FilePath
	.elseif eax==WM_MEASUREITEM
		push	esi
		mov		esi,lParam
		assume esi:ptr MEASUREITEMSTRUCT
		.if [esi].CtlType==ODT_LISTBOX
			mov		eax,lfnttool.lfHeight
			.if sdword ptr eax<0
				neg		eax
			.endif
			add		eax,4
			mov		[esi].itemHeight,eax
			mov		lbItehHeight,eax
		.endif
		assume esi:nothing
		pop		esi
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		.if [esi].CtlType==ODT_LISTBOX
			test	[esi].itemState,ODS_SELECTED
			.if ZERO?
				push	COLOR_WINDOW
				mov		eax,COLOR_WINDOWTEXT
			.else
				push	COLOR_HIGHLIGHT
				mov		eax,COLOR_HIGHLIGHTTEXT
			.endif
			invoke GetSysColor,eax
			invoke SetTextColor,[esi].hdc,eax
			pop		eax
			invoke GetSysColor,eax
			invoke SetBkColor,[esi].hdc,eax
			invoke SetBkMode,[esi].hdc,TRANSPARENT
			mov		eax,[esi].itemData
			shr		eax,16
			mov		edx,[esi].rcItem.bottom
			sub		edx,[esi].rcItem.top
			.if edx<16
				mov		edx,16
			.endif
			sub		edx,16
			shr		edx,1
			add		edx,[esi].rcItem.top
			invoke ImageList_Draw,hTypeIml,eax,[esi].hdc,[esi].rcItem.left,edx,ILD_NORMAL
			mov		[esi].rcItem.left,18
			invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr buffer
			invoke ExtTextOut,[esi].hdc,20,[esi].rcItem.top,ETO_OPAQUE,addr [esi].rcItem,addr buffer,eax,NULL
		.endif
		assume esi:nothing
		pop		esi
		jmp		ExDef
	.elseif eax==WM_CTLCOLORSTATIC
		mov		eax,lParam
		.if	eax==hTlt
			invoke SetBkMode,wParam,TRANSPARENT
			mov		eax,hBrTlt
			ret
		.endif
		jmp		ExDef
	.elseif eax==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke ToolMessage,0,TLM_PAINT,0
		invoke EndPaint,hWin,addr ps
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,(NMHDR ptr [edx]).code
		.if eax==TTN_NEEDTEXTW || eax==TTN_NEEDTEXT
			;Toolbar tooltip
			invoke GetToolBarTooltip,hWin,(NMHDR ptr [edx]).idFrom
			mov		edx,lParam
			mov		(TOOLTIPTEXT ptr [edx]).lpszText,eax
		.elseif eax==TCN_SELCHANGE
			invoke TabToolSel,hClient
		.endif
	.elseif eax==AIM_GETHANDLES
		mov		eax,offset hWnd
		ret
	.elseif eax==AIM_GETPROCS
		mov		eax,offset lpTextOut
		ret
	.elseif eax==AIM_GETDATA
		mov		eax,offset nRadASMVer
		ret
	.elseif eax==AIM_GETMENUID
		mov		eax,nAddInMenuID
		inc		nAddInMenuID
		ret
	.elseif eax==WM_DISPLAYCHANGE
		mov		edx,lParam
		movzx	eax,dx
		shr		edx,16
		.if eax==scrnsize.ccx && !scrnsize.fmax
			mov		eax,scrnsize.rect.right
			sub		eax,scrnsize.rect.left
			mov		edx,scrnsize.rect.bottom
			sub		edx,scrnsize.rect.top
			invoke MoveWindow,hWin,scrnsize.rect.left,scrnsize.rect.top,eax,edx,TRUE
		.endif
	.elseif eax==WM_CLOSE
		.if fProject
			invoke CloseProject
			.if eax
				xor eax,eax
				ret
			.endif
		.else
			invoke UpdateAll,IDM_FILE_CLOSEFILE
			invoke GetActive
			.if hMdiCld
				xor		eax,eax
				ret
			.endif
		.endif
		invoke KillTimer,hWin,200
		invoke DllProc,hWin,AIM_CLOSE,wParam,lParam,RAM_CLOSE
		.if nF1
			invoke WinHelp,hWin,addr F1,HELP_QUIT,NULL
		.endif
		.if nCF1
			invoke WinHelp,hWin,addr CF1,HELP_QUIT,NULL
		.endif
		.if nSF1
			invoke WinHelp,hWin,addr SF1,HELP_QUIT,NULL
		.endif
		.if nCSF1
			invoke WinHelp,hWin,addr CSF1,HELP_QUIT,NULL
		.endif
		mov		edx,offset MenuData
	  @@:
		push	edx
		mov		al,(MENU ptr [edx]).param
		or		al,al
		je		@f
		.if al=='H'
			mov		eax,(MENU ptr [edx]).ncalls
			.if eax
				invoke WinHelp,hWin,addr (MENU ptr [edx]).cmnd,HELP_QUIT,NULL
			.endif
		.endif
		pop		edx
		add		edx,sizeof MENU
		jmp		@b
	  @@:
		invoke SaveRecentFiles
		invoke iniWinSavePos
		invoke DestroyWindow,hTlt
		jmp		ExDef
	.elseif eax==WM_DESTROY
		invoke DestroyWindow,hDivLine
		invoke DestroyWindow,hDivider
		invoke DestroyWindow,hOutBtn1
		invoke DestroyWindow,hOutBtn2
		invoke DestroyWindow,hOutBtn3
		invoke DestroyWindow,hToolTip
		invoke DestroyWindow,hToolBar
		invoke DestroyWindow,hPrpTbrCode
		invoke DestroyWindow,hPbrTbr
		invoke DestroyWindow,hOut
		invoke DestroyWindow,hPbr
		invoke DestroyWindow,hPrp
		invoke DestroyWindow,hInfEdt
		invoke DestroyWindow,hInf
		invoke DestroyWindow,hTlb
		invoke DestroyWindow,hLBU
		invoke DestroyWindow,hLBS
		invoke iniDestroySubMenu
		invoke DestroyMenu,hMenu
		invoke DestroyMenu,hToolMenu
		invoke DeleteObject,hBrTlt
		invoke DeleteObject,hBrPrp
		invoke DeleteObject,hBrInfo
		invoke DeleteObject,hBrDlg
		invoke DeleteObject,hGridBr
		invoke ImageList_Destroy,hTbrIml
		invoke ImageList_Destroy,hTypeIml
		invoke ImageList_Destroy,hBoxIml
		invoke PostQuitMessage,NULL
		jmp		ExDef
	.elseif eax==WM_USER+997
		invoke OutputSelect,lParam
		mov		eax,hOutREd
		ret
	.elseif eax==WM_USER+998
		mov		edx,lParam
		.if edx
			.if al
				invoke strcpy,addr FileName,edx
				invoke iniInStr,addr FileName,addr FTRap
				.if eax!=-1
					invoke strcpy,addr buffer,addr FileName
					invoke CloseProject
					.if !eax
						invoke strcpy,addr FileName,addr buffer
						invoke GetProject
					.endif
				.else
					invoke OpenEditFile
					invoke AddRecentFile,offset FileName
				.endif
			.endif
		.endif
	.elseif eax==WM_DROPFILES
		push	ebx
		xor		ebx,ebx
	  @@:
		invoke DragQueryFile,wParam,ebx,offset FileName,sizeof FileName
		.if eax
			invoke iniInStr,addr FileName,addr FTRap
			.if eax!=-1
				invoke strcpy,addr buffer,addr FileName
				invoke CloseProject
				.if !eax
					invoke strcpy,addr FileName,addr buffer
					invoke GetProject
				.endif
			.else
				invoke OpenEditFile
				inc		ebx
				jmp		@b
			.endif
		.endif
		pop		ebx
	.elseif eax==WM_QUERYENDSESSION
		invoke SendMessage,hWin,WM_CLOSE,0,0
	.else
  ExDef:
		invoke DefFrameProc,hWin,hClient,uMsg,wParam,lParam
		ret
	.endif
  Ex:
	xor     eax,eax
	ret

GetLbText:
	mov		lbbuffer,0
	invoke SendMessage,hPrpLstCode,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		invoke SendMessage,hPrpLstCode,LB_GETTEXT,nInx,addr lbbuffer

	.endif
	retn

WndProc endp

MakeMdiCldWin proc lpClass:DWORD,ID:DWORD
	LOCAL	hWin:HWND
	LOCAL	hEdt:DWORD
	LOCAL	ws:DWORD
	LOCAL	rect:RECT
	LOCAL	iNbr:DWORD

	xor		eax,eax
	mov		rect.left,eax
	mov		rect.top,eax
	mov		rect.right,eax
	mov		rect.bottom,eax
	mov		REdPos,0
	invoke ProSetPos,addr rect
	mov		iNbr,eax
	mov		eax,ID
	mov		MdiID,eax
	mov		ws,MDIS_ALLCHILDSTYLES or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
	.if eax==ID_DIALOG
		mov		ws,MDIS_ALLCHILDSTYLES or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_VSCROLL or WS_HSCROLL
	.endif
	.if fMaximized || EditMax
		or		ws,WS_MAXIMIZE
	.endif
	invoke CreateWindowEx,WS_EX_MDICHILD or WS_EX_CLIENTEDGE,lpClass,NULL,ws,rect.left,rect.top,rect.right,rect.bottom,hClient,NULL,hInstance,NULL
	mov		hWin,eax
	invoke SetWindowLong,hWin,0,ID			;ID_EDIT, ID_EDITTXT, ID_DIALOG
	invoke SetWindowLong,hWin,4,0			;SplittMode, hMem
	invoke SetWindowLong,hWin,16,iNbr		;Project file ID
	.if ID==ID_EDIT || ID==ID_EDITTXT
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		hEdt,eax
		mov		edx,iNbr
		.if edx
			or		edx,80000000h
			invoke ConvBookMark,edx,hEdt
		.endif
	.endif
	invoke ProSetTrv,hWin
	mov		eax,hWin
	ret

MakeMdiCldWin endp

;#########################################################################

DialogChildProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hDlg:HWND
	LOCAL	hMem:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	ps:PAINTSTRUCT
	LOCAL	hDC:HDC
	LOCAL	sinf:SCROLLINFO
	LOCAL	hMnu:DWORD
	LOCAL	ro:DWORD

	assume eax:nothing
	mov		eax,uMsg
	.if eax==WM_CREATE
		invoke SetWindowLong,hWin,0,MdiID			;ID
		invoke SetWindowLong,hWin,GWL_USERDATA,0	;hDialog
		invoke SetWindowLong,hWin,4,0				;hMem
		invoke GetProcessHeap
		invoke xHeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof RADMEM
		invoke SetWindowLong,hWin,28,eax			;RADMEM
	.elseif eax==WM_KEYDOWN
		invoke GetWindowLong,hWin,8
		mov		ro,eax
		invoke GetKBState
		mov		ecx,wParam
		.if hReSize || hMultiSel
			.if !eax && !edx && !ro
				.if ecx==VK_DELETE
					invoke DeleteCtl
				.elseif ecx==VK_PGDN 
					.if hReSize
						invoke GetWindowLong,hReSize,GWL_USERDATA
						.if eax
							mov		edx,[eax].DIALOG.tab
							mov		eax,[eax].DIALOG.hwnd
							inc		edx
							invoke SetNewTab,eax,edx
							invoke UpdateCtl,hReSize
						.endif
					.endif
				.elseif ecx==VK_PGUP
					.if hReSize
						invoke GetWindowLong,hReSize,GWL_USERDATA
						.if eax
							mov		edx,[eax].DIALOG.tab
							mov		eax,[eax].DIALOG.hwnd
							.if edx
								dec		edx
								invoke SetNewTab,eax,edx
								invoke UpdateCtl,hReSize
							.endif
						.endif
					.endif
				.endif
			.elseif !edx && eax
				.if ecx==VK_V && !ro
					invoke PasteCtl
				.elseif ecx==VK_C
					invoke CopyCtl
				.elseif ecx==VK_X && !ro
					invoke CopyCtl
					invoke DeleteCtl
				.elseif ecx==VK_Z && !ro
					invoke UndoCtl
				.endif
			.endif
		.endif
		invoke GetKBState
		mov		ecx,wParam
		.if hReSize
			.if !eax && !edx
				.if ecx==VK_TAB || ecx==VK_RIGHT || ecx==VK_DOWN
					invoke GetWindowLong,hReSize,GWL_USERDATA
					.if eax
						push	esi
						mov		esi,eax
						mov		eax,(DIALOG ptr [esi]).ntype
						.if eax
							mov		eax,(DIALOG ptr [esi]).tab
							inc		eax
						.endif
						invoke FindTab,eax,hWin
						.if !eax
							invoke FindTab,0,hWin
						.endif
						.if eax
							invoke SizeingRect,eax,FALSE
						.endif
						pop		esi
					.endif
				.elseif ecx==VK_LEFT || ecx==VK_UP
					invoke GetWindowLong,hReSize,GWL_USERDATA
					.if eax
						push	esi
						mov		esi,eax
						mov		eax,(DIALOG ptr [esi]).tab
						dec		eax
						invoke FindTab,eax,hWin
						.if !eax
							invoke GetFreeTab
							.if eax
								dec		eax
								invoke FindTab,eax,hWin
							.endif
						.endif
						.if eax
							invoke SizeingRect,eax,FALSE
						.endif
						pop		esi
					.endif
				.elseif ecx==VK_RETURN
					invoke SetFocus,hPrpLst
					invoke SendMessage,hPrpLst,WM_CHAR,VK_RETURN,0
				.endif
			.elseif !edx && eax && !ro
				invoke GetWindowLong,hReSize,GWL_USERDATA
				.if eax
					push	esi
					mov		esi,eax
					mov		eax,wParam
					.if eax==VK_LEFT
						.if fSnapToGrid
							mov		eax,(DIALOG ptr [esi]).x
							sub		eax,Gridcx
							xor		edx,edx
							idiv	Gridcx
							imul	Gridcx
							mov		(DIALOG ptr [esi]).x,eax
						.else
							dec		(DIALOG ptr [esi]).x
						.endif
						invoke UpdateCtl,hReSize
					.elseif eax==VK_RIGHT
						.if fSnapToGrid
							mov		eax,(DIALOG ptr [esi]).x
							add		eax,Gridcx
							xor		edx,edx
							idiv	Gridcx
							imul	Gridcx
							mov		(DIALOG ptr [esi]).x,eax
						.else
							inc		(DIALOG ptr [esi]).x
						.endif
						invoke UpdateCtl,hReSize
					.elseif eax==VK_UP
						.if fSnapToGrid
							mov		eax,(DIALOG ptr [esi]).y
							sub		eax,Gridcy
							xor		edx,edx
							idiv	Gridcy
							imul	Gridcy
							mov		(DIALOG ptr [esi]).y,eax
						.else
							dec		(DIALOG ptr [esi]).y
						.endif
						invoke UpdateCtl,hReSize
					.elseif eax==VK_DOWN
						.if fSnapToGrid
							mov		eax,(DIALOG ptr [esi]).y
							add		eax,Gridcy
							xor		edx,edx
							idiv	Gridcy
							imul	Gridcy
							mov		(DIALOG ptr [esi]).y,eax
						.else
							inc		(DIALOG ptr [esi]).y
						.endif
						invoke UpdateCtl,hReSize
					.endif
					pop		esi
				.endif
			.elseif edx && !eax && !ro
				invoke GetWindowLong,hReSize,GWL_USERDATA
				.if eax
					push	esi
					mov		esi,eax
					mov		eax,wParam
					.if eax==VK_LEFT
						mov		eax,(DIALOG ptr [esi]).ccx
						.if eax>1
							dec		(DIALOG ptr [esi]).ccx
							invoke UpdateCtl,hReSize
						.endif
					.elseif eax==VK_RIGHT
						inc		(DIALOG ptr [esi]).ccx
						invoke UpdateCtl,hReSize
					.elseif eax==VK_UP
						mov		eax,(DIALOG ptr [esi]).ccy
						.if eax>1
							dec		(DIALOG ptr [esi]).ccy
							invoke UpdateCtl,hReSize
						.endif
					.elseif eax==VK_DOWN
						inc		(DIALOG ptr [esi]).ccy
						invoke UpdateCtl,hReSize
					.endif
					pop		esi
				.endif
			.elseif eax && edx
				mov		eax,wParam
				.if eax==VK_UP || eax==VK_DOWN
					invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
					.if eax==LB_ERR
						invoke SendMessage,hPrpLst,LB_SETCURSEL,0,0
					.else
						.if wParam==VK_DOWN
							inc		eax
						.else
							.if eax
								dec		eax
							.endif
						.endif
						invoke SendMessage,hPrpLst,LB_SETCURSEL,eax,0
					.endif
					invoke PropListSetPos
					.if !eax
						invoke PropListSetTxt,hPrpLst
					.endif
				.elseif eax==VK_LEFT || eax==VK_RIGHT
					invoke IsWindowVisible,hPrpTxt
					.if eax
						invoke SetFocus,hPrpTxt
					.else
						invoke SendMessage,hPrpLst,WM_COMMAND,1,0
						invoke IsWindowVisible,hTxtLst
						.if eax
							invoke SetFocus,hTxtLst
						.endif
					.endif
				.endif
			.endif
		.elseif hMultiSel
			.if eax && !edx && !ro
				.if fSnapToGrid
					mov		eax,Gridcx
					mov		edx,Gridcy
				.else
					mov		eax,1
					mov		edx,1
				.endif
				.if ecx==VK_UP
					neg		edx
					invoke MoveMultiSel,0,edx
				.elseif ecx==VK_DOWN
					invoke MoveMultiSel,0,edx
				.elseif ecx==VK_LEFT
					neg		eax
					invoke MoveMultiSel,eax,0
				.elseif ecx==VK_RIGHT
					invoke MoveMultiSel,eax,0
				.endif
			.endif
		.endif
		invoke ToolBarStatus
	.elseif eax==WM_MDIACTIVATE
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		hDlg,eax
		.if hDlg
			mov		eax,hWin
			.if eax==lParam
				mov		hMdiCld,eax
				m2m		hDialog,hDlg
				mov		hEdit,0
				mov		hHexEd,0
				invoke PropSetOwner,FALSE
				invoke TabToolSet,hWin
				invoke SendMessage,hDlg,WM_NCACTIVATE,1,0
				invoke SizeingRect,hDlg,FALSE
				invoke ProSetTrv,hWin
				mov		nLineTick,1
				.if fCodeTooltip
					invoke SendMessage,hInfEdt,WM_SETTEXT,0,offset szNULL
				.endif
				.if hFullScreen
					invoke ShowWindow,hFullScreen,SW_HIDE
				.endif
			.elseif eax==wParam
				invoke SendMessage,hDlg,WM_NCACTIVATE,0,0
				invoke DestroySizeingRect
				mov		nLineTick,1
				.if hFullScreen
					invoke GetWindowLong,hWin,GWL_USERDATA
					invoke SetParent,eax,hWin
					invoke SendMessage,hWnd,WM_SIZE,0,0
				.endif
			.endif
		.endif
		invoke DllProc,hWin,AIM_MDIACTIVATE,wParam,lParam,RAM_MDIACTIVATE
	.elseif eax==WM_CLOSE
		invoke GetWindowLong,hWin,4
		mov		hMem,eax
		.if hMem
			mov		eax,hMem
			mov		eax,(DLGHEAD ptr [eax]).changed
			.if eax
				invoke GetWindowText,hWin,addr buffer1,256
				invoke strcpy,addr buffer,addr WannaSave
				invoke strcat,addr buffer,addr buffer1
				mov		word ptr buffer1,'?'
				invoke strcat,addr buffer,addr buffer1
				invoke MessageBox,hWin,addr buffer,addr AppName,MB_YESNOCANCEL or MB_ICONQUESTION
				.if eax==IDYES
					invoke SaveDialog,hWin,FALSE
					.if eax
						mov		eax,TRUE
						ret
					.endif
				.elseif eax==IDCANCEL
					mov		eax,TRUE
					ret
				.endif
			.endif
		.endif
		.if SaveSize
			invoke ProSavePos,hWin
		.endif
		invoke TabToolDel,hWin
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		hDlg,eax
		.if hDlg
			invoke PropertyList,0
			invoke DestroyWindow,hDlg
			invoke SetWindowLong,hWin,GWL_USERDATA,0
			invoke SetWindowLong,hWin,4,0
			mov		edx,hMem
			mov		eax,[edx].DLGHEAD.hfont
			invoke DeleteObject,eax
			mov		edx,hMem
			add		edx,sizeof DLGHEAD
			.while TRUE
				mov		eax,[edx].DIALOG.hwnd
				.break .if !eax
				mov		eax,[edx].DIALOG.himg
				.if eax
					push	edx
					invoke DeleteObject,eax
					pop		edx
				.endif
				add		edx,sizeof DIALOG
			.endw
			invoke GlobalUnlock,hMem
			invoke GlobalFree,hMem
		.endif
		.if fCodeTooltip
			invoke SendMessage,hInfEdt,WM_SETTEXT,0,offset szNULL
		.endif
		mov		hReSize,0
		mov		hDialog,0
		mov		hMdiCld,0
		mov		nLineTick,1
		invoke GetWindowLong,hWin,28
		push	eax
		invoke GetProcessHeap
		pop		edx
		invoke HeapFree,eax,0,edx
	.elseif eax==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		mov		hDC,eax
		invoke FillRect,hDC,addr ps.rcPaint,hBrDlg
		invoke SetChanged,2,hWin
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.elseif eax==WM_SIZE
		.if wParam==SIZE_MAXIMIZED
			mov		fMaximized,TRUE
		.elseif wParam==SIZE_RESTORED || wParam==SIZE_MINIMIZED
			mov		fMaximized,FALSE
		.endif
	.elseif eax==WM_CONTEXTMENU
		invoke GetCapture
		.if eax
			xor		eax,eax
			ret
		.endif
		invoke DllProc,hWin,AIM_CONTEXTMENU,wParam,lParam,RAM_CONTEXTMENU
		.if eax
			xor		eax,eax
			ret
		.endif
		invoke MenuStatus
		mov		eax,lParam
		.if eax!=-1
			cwde
			mov		pt.x,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			mov		pt.y,eax
		.else
			invoke GetWindowRect,hWin,addr rect
			mov		eax,rect.left
			add		eax,10
			mov		pt.x,eax
			mov		eax,rect.top
			add		eax,10
			mov		pt.y,eax
		.endif
		invoke GetSubMenu,hToolMenu,2
		mov		hMnu,eax
		invoke GetWindowLong,hWin,4
		.if eax
			mov		eax,(DLGHEAD ptr [eax]).locked
			.if eax
				mov		eax,MF_CHECKED
			.endif
		.endif
		invoke CheckMenuItem,hMnu,IDM_FORMAT_LOCKCONTROLS,eax
		mov		eax,fGrid
		.if eax
			mov		eax,MF_CHECKED
		.endif
		invoke CheckMenuItem,hMnu,IDM_FORMAT_SHOWGRID,eax
		invoke TrackPopupMenu,hMnu,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWnd,0
		xor		eax,eax
		ret
	.elseif eax==WM_MOUSEMOVE || eax==WM_NCMOUSEMOVE
		.if MnuHigh && hDialog
			mov		MnuPtx,-1
			invoke SendMessage,hDialog,WM_NCPAINT,0,0
		.endif
		invoke SendMessage,hStatus,SB_SETTEXT,0,offset szNULL
		invoke SendMessage,hInfEdt,WM_SETTEXT,0,offset szNULL
		mov		infoshowhwnd,eax
	.elseif eax==WM_HSCROLL
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==SB_THUMBTRACK || eax==SB_THUMBPOSITION
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			mov		eax,wParam
			shr		eax,16
			mov		sinf.nPos,eax
			invoke SetScrollInfo,hWin,SB_HORZ,addr sinf,TRUE
			invoke GetWindowLong,hWin,20
			sub		eax,sinf.nPos
			shl		eax,3
			invoke ScrollWindow,hWin,eax,0,NULL,NULL
			invoke SetWindowLong,hWin,20,sinf.nPos
			invoke GetClientRect,hWin,addr rect
			mov		rect.bottom,6
			invoke InvalidateRect,hWin,addr rect,TRUE
			invoke UpdateWindow,hWin
		.elseif eax==SB_LINELEFT || eax==SB_LINERIGHT || eax==SB_PAGELEFT || eax==SB_PAGERIGHT
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			invoke GetScrollInfo,hWin,SB_HORZ,addr sinf
			mov		ecx,sinf.nPos
			mov		eax,wParam
			.if eax==SB_LINERIGHT
				inc		ecx
			.elseif eax==SB_LINELEFT
				.if ecx
					dec		ecx
				.endif
			.elseif eax==SB_PAGERIGHT
				add		ecx,8
			.elseif eax==SB_PAGELEFT
				.if ecx>8
					sub		ecx,8
				.else
					mov		ecx,0
				.endif
			.endif
			shl		ecx,16
			or		ecx,SB_THUMBPOSITION
			invoke SendMessage,hWin,WM_HSCROLL,ecx,0
		.endif
		xor eax,eax
		ret
	.elseif eax==WM_VSCROLL
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==SB_THUMBTRACK || eax==SB_THUMBPOSITION
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			mov		eax,wParam
			shr		eax,16
			mov		sinf.nPos,eax
			invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
			invoke GetWindowLong,hWin,24
			sub		eax,sinf.nPos
			shl		eax,3
			invoke ScrollWindow,hWin,0,eax,NULL,NULL
			invoke SetWindowLong,hWin,24,sinf.nPos
			invoke GetClientRect,hWin,addr rect
			mov		rect.right,6
			invoke InvalidateRect,hWin,addr rect,TRUE
			invoke UpdateWindow,hWin
		.elseif eax==SB_LINEDOWN || eax==SB_LINEUP || eax==SB_PAGEDOWN || eax==SB_PAGEUP
			mov		sinf.cbSize,sizeof sinf
			mov		sinf.fMask,SIF_POS
			invoke GetScrollInfo,hWin,SB_VERT,addr sinf
			mov		ecx,sinf.nPos
			mov		eax,wParam
			.if eax==SB_LINEDOWN
				inc		ecx
			.elseif eax==SB_LINEUP
				.if ecx
					dec		ecx
				.endif
			.elseif eax==SB_PAGEDOWN
				add		ecx,8
			.elseif eax==SB_PAGEUP
				.if ecx>8
					sub		ecx,8
				.else
					mov		ecx,0
				.endif
			.endif
			shl		ecx,16
			or		ecx,SB_THUMBPOSITION
			invoke SendMessage,hWin,WM_VSCROLL,ecx,0
		.endif
		xor eax,eax
		ret
	.elseif eax==WM_MOUSEWHEEL
		mov		eax,wParam
		.if sdword ptr eax<0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
		.else
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEUP,0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEUP,0
			invoke SendMessage,hWin,WM_VSCROLL,SB_LINEUP,0
		.endif
		xor		eax,eax
		ret
	.endif
	invoke DefMDIChildProc,hWin,uMsg,wParam,lParam
	ret

DialogChildProc endp

;#########################################################################

FindTooltipWord proc hWin:HWND,fCaret:DWORD
	LOCAL	hEdt:HWND
	LOCAL	pt:POINT
	LOCAL	chrg:CHARRANGE
	LOCAL	buffer[64]:BYTE

	mov		byte ptr tempbuff,0
	.if fCaret
		mov		eax,hWin
		mov		hEdt,eax
		invoke GetCaretPos,addr pt
	.else
		invoke GetParent,hWin
		mov		hEdt,eax
		invoke GetCursorPos,addr pt
		invoke ScreenToClient,hWin,addr pt
	.endif
	invoke SendMessage,hEdt,EM_CHARFROMPOS,0,addr pt
	.if eax!=infoshowcp
		mov		infoshowcp,eax
		mov		chrg.cpMin,eax
		mov		chrg.cpMax,eax
		push	pt.x
		push	pt.y
		invoke SendMessage,hEdt,EM_POSFROMCHAR,addr pt,eax
		pop		edx
		pop		ecx
		sub		edx,pt.y
		.if CARRY?
			neg		edx
		.endif
		sub		ecx,pt.x
		.if CARRY?
			neg		ecx
		.endif
		.if ecx<10 && edx<10
			invoke SendMessage,hEdt,REM_ISCHARPOS,infoshowcp,0
			.if !eax
				.if fCaret
					invoke SendMessage,hEdt,REM_GETWORD,sizeof buffer,addr buffer
				.else
					invoke SendMessage,hEdt,REM_GETCURSORWORD,sizeof buffer,addr buffer
				.endif
				invoke GetParent,hEdt
				push	eax
				invoke GetWindowLong,eax,0
				mov		edx,eax
				pop		ecx
				invoke DllProc,ecx,AIM_CODEINFO,edx,addr buffer,RAM_CODEINFO
				.if eax
					invoke strcpy,addr tempbuff,eax
				.else
					push	esi
					mov		esi,lpWordList
					.while [esi].PROPERTIES.nSize
						.if [esi].PROPERTIES.nType!='C'
							.if [esi].PROPERTIES.nType=='d'
								lea		ecx,buffer
								lea		edx,[esi+sizeof PROPERTIES]
								.while TRUE
									mov		al,[ecx]
									mov		ah,[edx]
									.if !al
										.if ah==':' || ah=='[' || !ah
											xor		eax,eax
											.break
										.endif
									.elseif al!=ah
										.break
									.endif
									inc		ecx
									inc		edx
								.endw
							.else
								invoke strcmp,addr buffer,addr [esi+sizeof PROPERTIES]
							.endif
							.if !eax
								invoke strcpy,offset tempbuff,addr buffer
								.if [esi].PROPERTIES.nType!='l'
									invoke strlen,addr [esi+sizeof PROPERTIES]
									.if byte ptr [esi+eax+sizeof PROPERTIES+1]
										push	eax
										.if nAsm==nBCET && ([esi].PROPERTIES.nType=='A' || [esi].PROPERTIES.nType=='p')
											mov		eax,offset szLPA
										.else
											mov		eax,offset szComma
										.endif
										invoke strcat,offset tempbuff,eax
										pop		eax
										invoke strcat,offset tempbuff,addr [esi+eax+sizeof PROPERTIES+1]
									.endif
									mov		esi,offset tempbuff
									.while byte ptr [esi]
										.if byte ptr [esi]==VK_TAB
											mov		byte ptr [esi],':'
										.endif
										inc		esi
									.endw
								.endif
								.break
							.endif
						.endif
						mov		ecx,[esi].PROPERTIES.nSize
						lea		esi,[esi+ecx+sizeof PROPERTIES]
					.endw
					pop		esi
				.endif
			.endif
		.else
			mov		infoshowcp,-1
		.endif
		invoke SendMessage,hInfEdt,WM_SETTEXT,0,offset tempbuff
	.endif
	ret

FindTooltipWord endp

LineNo proc hWin:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	lLines:DWORD
	LOCAL	lChars:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	hMdi:HWND

	.if hWin
		.if fCodeTooltip
			invoke FindTooltipWord,hWin,TRUE
		.endif
		invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
		mov		eax,Line
		inc		eax
		invoke BinToDec,eax,addr szLine+4
		mov		eax,Col
		mov		LastCol,eax
		inc		eax
		invoke BinToDec,eax,addr szChar+7
		invoke strcpy,addr buffer,addr szLine
		invoke strcat,addr buffer,addr szChar
		.if nPageSize
			mov		eax,nPage
			inc		eax
			invoke BinToDec,eax,addr szPage+5
			invoke strcat,addr buffer,addr szPage
		.endif
		invoke SendMessage,hWin,EM_GETLINECOUNT,0,0
		.if eax!=nMaxLine
			mov		lLines,eax
			sub		eax,nMaxLine
			invoke AdjustBookMarks,hWin,Line,eax
			mov		eax,lLines
			mov		nMaxLine,eax
		.endif
		mov		eax,nMaxLine
		.if eax
			dec		eax
		.endif
		invoke SendMessage,hWin,EM_LINEINDEX,eax,0
		mov		lChars,eax
		invoke SendMessage,hWin,EM_LINELENGTH,lChars,0
		add		lChars,eax
		mov		eax,lChars
		.if eax!=nMaxChar
			invoke AdjustRet,hWin,chrg.cpMin,lChars
			mov		eax,lChars
			mov		nMaxChar,eax
		.endif
		mov		eax,chrg.cpMax
		sub		eax,chrg.cpMin
		.if eax
			invoke BinToDec,eax,addr szSel+6
			invoke strcat,addr buffer,addr szSel
		.else
			mov		eax,nMaxChar
			.if nMaxLine
				add		eax,nMaxLine
				inc		eax
			.endif
			invoke BinToDec,eax,addr szSize+7
			invoke strcat,addr buffer,addr szSize
		.endif
		invoke SendMessage,hStatus,SB_SETTEXT,0,addr buffer
		mov		eax,Line
		.if eax!=LastLine
			mov		eax,hWin
			.if eax==fCodeMacro
				invoke CodeMacro,hWin,LastLine
			.endif
			invoke CodeLine,hWin,Line
			mov		eax,Line
			mov		LastLine,eax
			invoke ShowWindow,hTlt,SW_HIDE
			mov		fTlt,0
			;Hide LB
			invoke ShowWindow,hLB,SW_HIDE
			xor		eax,eax
			mov		fLB,eax
			mov		fLBConst,eax
			mov		fLBStruct,eax
			mov		fLBWord,eax
			mov		fLBType,eax
			mov		StBuff,al
			.if fAutoRefresh
				;Refresh open files
				invoke EnumChildWindows,hClient,addr SetOpenProperty,-1
				.if nUpdated
					invoke FixUnknown
					invoke CompactWordList
					invoke SendMessage,hPrpCbo,CB_GETCURSEL,0,0
					.if eax==CB_ERR
						xor		eax,eax
					.endif
					push	eax
					invoke SendMessage,hPrpCbo,CB_GETITEMDATA,eax,0
					pop		edx
					.if eax<=5 || (eax>=10 && eax<=13)
						invoke SetProperty,eax,edx
					.endif
					mov		nUpdated,0
				.endif
			.endif
			invoke FindProc,hWin
		.endif
		invoke GetParent,hWin
		mov		hMdi,eax
		invoke GetWindowLong,hMdi,20
		.if eax
			invoke SendMessage,hStatus,SB_SETTEXT,1,addr szNULL
		.else
			invoke SendMessage,hStatus,SB_SETTEXT,1,addr szINS
		.endif
	.else
		.if hHexEd
			invoke BinToDec,Col,offset szPos+5
			invoke strlen,offset szPos
			mov		dword ptr szPos[eax],'x0( '
			mov		dword ptr szPos[eax+4],0
			mov		eax,Col
			invoke hexEax
			mov		eax,offset strHex
			.while eax<offset strHex+7 && byte ptr [eax]=='0'
				inc		eax
			.endw
			invoke strcat,offset szPos,eax
			invoke strlen,offset szPos
			mov		dword ptr szPos[eax],')'
			invoke SendMessage,hStatus,SB_SETTEXT,0,offset szPos
		.else
			invoke SendMessage,hStatus,SB_SETTEXT,0,addr szNULL
		.endif
		invoke SendMessage,hStatus,SB_SETTEXT,1,addr szNULL
		invoke SendMessage,hStatus,SB_SETTEXT,3,addr szNULL
		mov		LastLine,-1
		mov		LastCol,-1
	.endif
	invoke ToolBarStatus
	ret

LineNo endp

InitLineNo proc hWin:HWND

	invoke SendMessage,hWin,EM_GETLINECOUNT,0,0
	mov		nMaxLine,eax
	.if eax
		dec		eax
	.endif
	invoke SendMessage,hWin,EM_LINEINDEX,eax,0
	mov		nMaxChar,eax
	invoke SendMessage,hWin,EM_LINELENGTH,nMaxChar,0
	add		nMaxChar,eax
	mov		fCodeMacro,-1
	ret

InitLineNo endp

EditChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hEdt:HWND
	LOCAL	rect:RECT
	LOCAL	ws:DWORD
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_CREATE
		mov		nLastLine,0
		invoke SetWindowLong,hWin,0,MdiID		;ID
		mov		LastLine,-1
		mov		LastCol,-1
		m2m     hMdiCld,hWin
		mov		ws,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or STYLE_DRAGDROP or STYLE_SCROLLTIP or STYLE_AUTOSIZELINENUM
		.if MdiID==ID_EDITTXT
			or		ws,STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NODIVIDERLINE
		.elseif !fUseHighLight
			or		ws,STYLE_NOHILITE
		.elseif HiliteCmnt
			or		ws,STYLE_HILITECOMMENT
		.endif
		.if !fUseDivLine
			or		ws,STYLE_NODIVIDERLINE
		.endif
		.if !fNoFlicker
			or		ws,STYLE_NOBACKBUFFER
		.endif
		invoke CreateWindowEx,NULL,addr RAEditClass,0,ws,0,0,0,0,hWin,MdiID,hInstance,0
		mov		hEdt,eax
		invoke SetWindowLong,hWin,GWL_USERDATA,hEdt
		.if MdiID==ID_EDIT
			;Subclass the RAEdit control
			invoke SendMessage,hEdt,REM_SUBCLASS,0,addr EditProc
			mov		OldEditProc,eax
			;Set font & format
			invoke SetFormat,hEdt,hFont[0],hFont[4],hFont[8],TRUE
			mov		eax,STYLEEX_BLOCKGUIDE or STILEEX_LINECHANGED
			.if nAsm==nCPP
				mov		eax,STYLEEX_BLOCKGUIDE or STILEEX_LINECHANGED or STILEEX_STRINGMODEC
			.elseif nAsm==nBCET
				mov		eax,STYLEEX_BLOCKGUIDE or STILEEX_LINECHANGED or STILEEX_STRINGMODEFB
			.endif
			invoke SendMessage,hEdt,REM_SETSTYLEEX,eax,0
		.else
			;Subclass the RAEdit control
			invoke SendMessage,hEdt,REM_SUBCLASS,0,addr EditTxtProc
			mov		OldEditProc,eax
			;Set font & format
			invoke SetFormat,hEdt,hFontTxt,hFontTxt,hFont[8],FALSE
			invoke SendMessage,hEdt,REM_SETSTYLEEX,STILEEX_LINECHANGED,0
		.endif
		;Set the text/background color
		invoke SetColor,hEdt
		invoke SendMessage,hEdt,EM_SETMODIFY,FALSE,0
		invoke SendMessage,hEdt,EM_EMPTYUNDOBUFFER,0,0
		invoke SendMessage,hEdt,REM_BMCALLBACK,0,offset BmCallBack
		invoke GetProcessHeap
		invoke xHeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof RADMEM
		invoke SetWindowLong,hWin,28,eax			;RADMEM
	.elseif eax==WM_SIZE
		mov		eax,wParam
		.if eax==SIZE_MAXIMIZED
			mov		fMaximized,TRUE
		.elseif eax==SIZE_RESTORED || eax==SIZE_MINIMIZED
			mov		fMaximized,FALSE
		.endif
	.elseif eax==WM_WINDOWPOSCHANGED
		.if !hFullScreen
			invoke GetWindowLong,hWin,GWL_USERDATA
			mov		hEdt,eax
			.if fMaximized
				invoke GetClientRect,hClient,addr rect
			.else
				invoke GetClientRect,hWin,addr rect
			.endif
			invoke MoveWindow,hEdt,rect.left,rect.top,rect.right,rect.bottom,FALSE
		.endif
	.elseif eax==WM_MDIACTIVATE
		mov		nLineTick,10
		mov		eax,hWin
		.if eax==lParam
			;Activate
			mov		hMdiCld,eax
			invoke GetWindowLong,hWin,GWL_USERDATA
			mov		hEdit,eax
			mov		hDialog,0
			mov		hHexEd,0
			invoke PropSetOwner,TRUE
			invoke InitLineNo,hEdit
			invoke TabToolSet,hWin
			invoke ProSetTrv,hWin
			invoke SetFocus,hEdit
			mov		nLastLine,0
			mov		LastLine,-1
			mov		fCodeMacro,-1
			invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
			invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
			mov		Line,eax
			.if hFullScreen
				invoke ShowWindow,hFullScreen,SW_SHOWNA
				invoke SetParent,hEdit,hFullScreen
				invoke ShowWindow,hEdit,SW_SHOWMAXIMIZED
				invoke SetFocus,hEdit
			.endif
			.if fProperty==1
				invoke SendMessage,hPrpCbo,CB_GETCURSEL,0,0
				.if eax==CB_ERR
					xor		eax,eax
				.endif
				push	eax
				invoke SendMessage,hPrpCbo,CB_GETITEMDATA,eax,0
				pop		edx
				.if eax<=5 || (eax>=10 && eax<=13)
					invoke SetProperty,eax,edx
				.endif
			.endif
		.else
			.if hFullScreen
				invoke GetWindowLong,hWin,GWL_USERDATA
				invoke SetParent,eax,hWin
				invoke SendMessage,hWnd,WM_SIZE,0,0
			.endif
		.endif
		invoke ShowWindow,hTlt,SW_HIDE
		mov		fTlt,0
		invoke ShowWindow,hLB,SW_HIDE
		xor		eax,eax
		mov		fLB,eax
		mov		fLBConst,eax
		mov		fLBStruct,eax
		mov		fLBWord,eax
		mov		fLBType,eax
		mov		StBuff,al
		invoke DllProc,hWin,AIM_MDIACTIVATE,wParam,lParam,RAM_MDIACTIVATE
		mov		nLineTick,1
	.elseif eax==WM_CLOSE
		invoke CheckModifyState,hWin
		.if eax
			ret
		.endif
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		hEdt,eax
		invoke GetWindowLong,hWin,0
		invoke DllProc,hWin,AIM_EDITCLOSE,hEdt,eax,RAM_EDITCLOSE
		.if eax
			ret
		.endif
		.if SaveSize
			invoke ProSavePos,hWin
		.endif
		invoke ShowWindow,hTlt,SW_HIDE
		mov		fTlt,0
		invoke ShowWindow,hLB,SW_HIDE
		xor		eax,eax
		mov		fLB,eax
		mov		fLBConst,eax
		mov		fLBStruct,eax
		mov		fLBWord,eax
		mov		fLBType,eax
		mov		StBuff,al
		mov		eax,hEdt
		.while eax
			invoke DestroyRet,hEdt
		.endw
		invoke GetWindowLong,hWin,16
		.if eax
			or		eax,80000000h
			invoke ConvBookMark,hEdt,eax
		.else
			invoke KillBookMarks,hEdt
		.endif
		invoke TabToolDel,hWin
		mov     hMdiCld,0
		mov     hEdit,0
		mov		hDialog,0
		.if !fProject
			mov		eax,hWin
			neg		eax
			invoke DeleteProperties,eax
			invoke SendMessage,hPrpCbo,CB_GETCURSEL,0,0
			.if eax==CB_ERR
				xor		eax,eax
			.endif
			push	eax
			invoke SendMessage,hPrpCbo,CB_GETITEMDATA,eax,0
			pop		edx
			.if eax<=5 || (eax>=10 && eax<=13)
				invoke SetProperty,eax,edx
			.endif
		.endif
		mov		nLineTick,1
		.if fCodeTooltip
			invoke SendMessage,hInfEdt,WM_SETTEXT,0,offset szNULL
		.endif
		invoke GetWindowLong,hWin,0
		invoke DllProc,hWin,AIM_EDITCLOSED,hEdt,eax,RAM_EDITCLOSED
		invoke DestroyWindow,hEdt
		invoke GetWindowLong,hWin,28
		push	eax
		invoke GetProcessHeap
		pop		edx
		invoke HeapFree,eax,0,edx
	.elseif eax==WM_NOTIFY
		mov		eax,hWin
		.if eax==hMdiCld
			mov		edi,lParam
			.if [edi].NMHDR.code==EN_SELCHANGE && ([edi].NMHDR.idFrom==ID_EDIT || [edi].NMHDR.idFrom==ID_EDITTXT)
				mov		nLineTick,2
				invoke GetWindowLong,hWin,GWL_USERDATA
				mov     hEdt,eax
				mov		eax,[edi].NMHDR.idFrom
				invoke DllProc,hWin,AIM_EDITSELCHANGE,hEdt,eax,RAM_EDITSELCHANGE
				mov		eax,[edi].RASELCHANGE.line
				mov		Line,eax
				mov		eax,[edi].RASELCHANGE.npage
				mov		nPage,eax
				mov		eax,[edi].RASELCHANGE.chrg.cpMin
				sub		eax,[edi].RASELCHANGE.cpLine
				mov		Col,eax
				.if [edi].RASELCHANGE.seltyp==SEL_OBJECT
					mov		esi,[edi].RASELCHANGE.line
					invoke SendMessage,hEdt,REM_GETBOOKMARK,esi,0
					.if eax==1
						;Collapse
						invoke GetKeyState,VK_CONTROL
						test	eax,80h
						.if ZERO?
							invoke SendMessage,hEdt,REM_COLLAPSE,esi,0
						.else
							invoke SendMessage,hEdt,REM_GETBLOCKEND,esi,0
							.if eax!=-1
								dec		eax
								mov		ebx,esi
								mov		esi,eax
								.while esi>=ebx && esi!=-1
									invoke SendMessage,hEdt,REM_COLLAPSE,esi,0
									invoke SendMessage,hEdt,REM_PRVBOOKMARK,esi,1
									mov		esi,eax
								.endw
							.endif
						.endif
					.elseif eax==2
						;Expand
						invoke GetKeyState,VK_CONTROL
						test	eax,80h
						.if ZERO?
							invoke SendMessage,hEdt,REM_EXPAND,esi,0
						.else
							invoke SendMessage,hEdt,REM_GETBLOCKEND,esi,0
							.if eax!=-1
								mov		ebx,eax
								.while esi<ebx
									invoke SendMessage,hEdt,REM_EXPAND,esi,0
									invoke SendMessage,hEdt,REM_NXTBOOKMARK,esi,2
									mov		esi,eax
								.endw
							.endif
						.endif
					.elseif eax==8
						;Expand
						invoke SendMessage,hEdt,REM_EXPAND,esi,0
						.if eax
							push	eax
							invoke SendMessage,hEdt,REM_SETBOOKMARK,esi,9
							pop		eax
							neg		eax
							invoke SendMessage,hEdt,REM_SETBMID,esi,eax
						.endif
					.elseif eax==9
						;Collapse
						invoke SendMessage,hEdt,REM_GETBMID,esi,0
						push	eax
						invoke SendMessage,hEdt,REM_SETBOOKMARK,esi,0
						pop		eax
						neg		eax
						inc		eax
						invoke SendMessage,hEdt,REM_HIDELINES,esi,eax
					.endif
				.else
					invoke SendMessage,hEdt,REM_BRACKETMATCH,0,0
					invoke SetWindowLong,hWin,4,[edi].RASELCHANGE.line
					mov		ebx,eax
					invoke SendMessage,hEdt,REM_GETHILITELINE,ebx,0
					.if eax==2
						invoke SendMessage,hEdt,REM_SETHILITELINE,ebx,0
					.endif
					mov		eax,[edi].NMHDR.idFrom
					.if [edi].RASELCHANGE.fchanged && eax==ID_EDIT
						invoke SendMessage,hEdt,REM_GETHILITELINE,[edi].RASELCHANGE.line,0
						.if eax==1
							invoke SendMessage,hEdt,REM_SETHILITELINE,[edi].RASELCHANGE.line,0
						.endif
						.if ![edi].RASELCHANGE.nWordGroup
							invoke SendMessage,hEdt,REM_SETCOMMENTBLOCKS,offset CmntBlockStart,offset CmntBlockEnd
						.endif
						;Changed since last property update
						invoke SetWindowLong,hWin,12,TRUE
					  OnceMore:
						invoke SendMessage,hEdt,REM_GETBOOKMARK,nLastLine,0
						mov		ebx,eax
						mov		eax,-1
						.if byte ptr szInclude
							invoke SendMessage,hEdt,REM_ISLINE,nLastLine,offset szInclude
						.endif
						.if eax==-1
							.if byte ptr szIncludeLib
								invoke SendMessage,hEdt,REM_ISLINE,nLastLine,offset szIncludeLib
							.endif
						.endif
						.if eax==-1
							mov		esi,offset rablkdef
							.while [esi].RABLOCKDEF.lpszStart
								mov		edx,[esi].RABLOCKDEF.flag
								shr		edx,16
								.if edx==[edi].RASELCHANGE.nWordGroup
									invoke SendMessage,hEdt,REM_ISLINE,nLastLine,[esi].RABLOCKDEF.lpszStart
								.endif
							  .break .if eax!=-1
								add		esi,sizeof RABLOCKDEF
							.endw
						.else
							mov		eax,-1
						.endif
						.if eax==-1
							.if ebx==1 || ebx==2
								.if ebx==2
									invoke SendMessage,hEdt,REM_EXPAND,nLastLine,0
								.endif
								invoke SendMessage,hEdt,REM_SETBOOKMARK,nLastLine,0
								invoke SendMessage,hEdt,REM_SETDIVIDERLINE,nLastLine,FALSE
								invoke SendMessage,hEdt,REM_SETSEGMENTBLOCK,nLastLine,FALSE
							.endif
						.else
							mov		eax,nLastLine
							inc		eax
							invoke SendMessage,hEdt,REM_ISLINEHIDDEN,eax,0
							.if eax
								invoke SendMessage,hEdt,REM_SETBOOKMARK,nLastLine,2
							.else
								invoke SendMessage,hEdt,REM_SETBOOKMARK,nLastLine,1
							.endif
							mov		eax,[esi].RABLOCKDEF.flag
							and		eax,BD_DIVIDERLINE
							invoke SendMessage,hEdt,REM_SETDIVIDERLINE,nLastLine,eax
							mov		eax,[esi].RABLOCKDEF.flag
							and		eax,BD_SEGMENTBLOCK
							invoke SendMessage,hEdt,REM_SETSEGMENTBLOCK,nLastLine,eax
						.endif
						mov		eax,[edi].RASELCHANGE.line
						.if eax>nLastLine
							inc		nLastLine
							jmp		OnceMore
						.elseif eax<nLastLine
							dec		nLastLine
							jmp		OnceMore
						.endif
					.endif
					.if HiliteLine
						mov		ebx,[edi].RASELCHANGE.line
						invoke SendMessage,hEdt,REM_GETHILITELINE,ebx,0
						.if !eax
							invoke SendMessage,hEdt,REM_SETHILITELINE,ebx,2
						.endif
					.endif
					mov		eax,[edi].RASELCHANGE.line
					mov		nLastLine,eax
				.endif
			.endif
		.endif
		xor		eax,eax
		ret
	.elseif eax==WM_COMMAND
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		hEdt,eax
		mov		eax,wParam
		and		eax,0FFFFh
		.if ax==-3
			;Expand button clicked
			invoke SendMessage,hEdt,REM_EXPANDALL,0,0
			invoke SendMessage,hEdt,EM_SCROLLCARET,0,0
			invoke SendMessage,hEdt,REM_REPAINT,0,0
		.elseif ax==-4
			;Collapse button clicked
			invoke SendMessage,hEdt,REM_COLLAPSEALL,0,0
			invoke SendMessage,hEdt,EM_SCROLLCARET,0,0
			invoke SendMessage,hEdt,REM_REPAINT,0,0
		.endif
		xor		eax,eax
		ret
	.elseif eax==WM_MOVE
		invoke GetWindowLong,hWin,GWL_USERDATA
		.if eax==fTlt
			invoke ApiToolTip,eax
		.elseif eax==fLB
			invoke ApiListBox,eax
		.endif
		xor		eax,eax
		ret
	.elseif eax==WM_DESTROY
		.if hFullScreen
			invoke SendMessage,hClient,WM_MDIGETACTIVE,0,0
			.if !eax
				invoke DestroyWindow,hFullScreen
				mov		hFullScreen,0
			.endif
		.endif
	.elseif eax==WM_ERASEBKGND
		.if hFullScreen
			invoke DefWindowProc,hWin,uMsg,wParam,lParam
		.endif
		xor		eax,eax
	.endif
	invoke DefMDIChildProc,hWin,uMsg,wParam,lParam
	ret

EditChildProc endp

HexEdChildProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hEdt:HWND
	LOCAL	rect:RECT
	LOCAL	ws:DWORD
	LOCAL	hef:HEFONT
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_CREATE
		mov		nLastLine,0
		invoke SetWindowLong,hWin,0,MdiID		;ID
		mov		LastLine,-1
		mov		LastCol,-1
		m2m     hMdiCld,hWin
		mov		ws,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS
		invoke CreateWindowEx,NULL,addr RAHexEdClass,0,ws,0,0,0,0,hWin,MdiID,hInstance,0
		mov		hEdt,eax
		invoke SetWindowLong,hWin,GWL_USERDATA,hEdt
		invoke GetWindowLong,hEdt,0
		mov		ebx,eax
		invoke SetWindowLong,[ebx].HEEDIT.edta.hwnd,GWL_WNDPROC,offset HexEditProc
		invoke SetWindowLong,[ebx].HEEDIT.edtb.hwnd,GWL_WNDPROC,offset HexEditProc
		mov		OldHexEditProc,eax
		mov		eax,hFontHex
		mov		hef.hFont,eax
		mov		eax,hFont[8]
		mov		hef.hLnrFont,eax
		invoke SendMessage,hEdt,HEM_SETFONT,0,addr hef
		invoke GetProcessHeap
		invoke xHeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof RADMEM
		invoke SetWindowLong,hWin,28,eax			;RADMEM
	.elseif eax==WM_SIZE
		.if wParam==SIZE_MAXIMIZED
			mov		fMaximized,TRUE
		.elseif wParam==SIZE_RESTORED || wParam==SIZE_MINIMIZED
			mov		fMaximized,FALSE
		.endif
	.elseif eax==WM_WINDOWPOSCHANGED
		.if !hFullScreen
			invoke GetWindowLong,hWin,GWL_USERDATA
			mov		hEdt,eax
			.if fMaximized
				invoke GetClientRect,hClient,addr rect
			.else
				invoke GetClientRect,hWin,addr rect
			.endif
			invoke MoveWindow,hEdt,rect.left,rect.top,rect.right,rect.bottom,FALSE
		.endif
	.elseif eax==WM_MDIACTIVATE
		mov		nLineTick,10
		mov		eax,hWin
		.if eax==lParam
			mov		hMdiCld,eax
			invoke GetWindowLong,hWin,GWL_USERDATA
			mov		hHexEd,eax
			mov		hEdit,0
			mov		hDialog,0
			invoke TabToolSet,hWin
			invoke SetFocus,hHexEd
			mov		nLastLine,0
			mov		LastLine,-1
			mov		fCodeMacro,-1
			.if hFullScreen
				invoke ShowWindow,hFullScreen,SW_SHOWNA
				invoke SetParent,hHexEd,hFullScreen
				invoke ShowWindow,hHexEd,SW_SHOWMAXIMIZED
				invoke SetFocus,hHexEd
			.endif
		.else
			.if hFullScreen
				invoke GetWindowLong,hWin,GWL_USERDATA
				invoke SetParent,eax,hWin
				invoke SendMessage,hWnd,WM_SIZE,0,0
			.endif
		.endif
		invoke ShowWindow,hTlt,SW_HIDE
		mov		fTlt,0
		invoke ShowWindow,hLB,SW_HIDE
		xor		eax,eax
		mov		fLB,eax
		mov		fLBConst,eax
		mov		fLBStruct,eax
		mov		fLBWord,eax
		mov		fLBType,eax
		mov		StBuff,al
		invoke DllProc,hWin,AIM_MDIACTIVATE,wParam,lParam,RAM_MDIACTIVATE
		mov		nLineTick,1
	.elseif eax==WM_CLOSE
		invoke CheckModifyState,hWin
		.if eax
			ret
		.endif
		invoke TabToolDel,hWin
		mov     hMdiCld,0
		mov     hEdit,0
		mov		hHexEd,0
		mov		hDialog,0
		mov		nLineTick,1
		.if fCodeTooltip
			invoke SendMessage,hInfEdt,WM_SETTEXT,0,offset szNULL
		.endif
		invoke GetWindowLong,hWin,28
		push	eax
		invoke GetProcessHeap
		pop		edx
		invoke HeapFree,eax,0,edx
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,GWL_USERDATA
		invoke DestroyWindow,eax
	.elseif eax==WM_NOTIFY
		mov		edi,lParam
		.if [edi].NMHDR.code==EN_SELCHANGE && [edi].NMHDR.idFrom==ID_EDITHEX
			mov		eax,[edi].HESELCHANGE.chrg.cpMin
			shr		eax,1
			mov		Col,eax
			mov		nLineTick,1
			.if fCodeTooltip
				invoke GetWindowLong,hWin,GWL_USERDATA
				invoke SendMessage,eax,HEM_GETBYTE,[edi].HESELCHANGE.chrg.cpMin,0
				.if eax!=-1
					mov		dword ptr tempbuff,':ceD'
					mov		dword ptr tempbuff[4],' '
					push	eax
					invoke BinToDec,eax,offset tempbuff+5
					invoke strcat,offset tempbuff,offset szBin
					invoke strlen,offset tempbuff
					pop		edx
					mov		ecx,8
					mov		byte ptr tempbuff[eax+ecx],0
					.while ecx
						dec		ecx
						shr		edx,1
						.if CARRY?
							mov		byte ptr tempbuff[eax+ecx],'1'
						.else
							mov		byte ptr tempbuff[eax+ecx],'0'
						.endif
					.endw
					invoke SendMessage,hInfEdt,WM_SETTEXT,0,offset tempbuff
				.else
					invoke SendMessage,hInfEdt,WM_SETTEXT,0,offset szNULL
				.endif
			.endif
		.endif
	.endif
	invoke DefMDIChildProc,hWin,uMsg,wParam,lParam
	ret

HexEdChildProc endp

;#########################################################################

WinEnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	buffer[MAX_PATH*2]:BYTE
	LOCAL	hef:HEFONT

	invoke GetWindowLong,hWin,GWL_ID
	mov		edx,lParam
	.if eax>=ID_FIRSTCHILD &&  eax<=ID_LASTCHILD
		invoke GetWindowLong,hWin,0
		mov		edx,lParam
		.if edx==IDM_FILE_SAVEALLFILES
			.if eax==ID_EDIT || eax==ID_EDITTXT
				invoke SaveEdit,hWin
				xor     eax,1
				ret
			.elseif eax==ID_DIALOG
				invoke SaveDialog,hWin,FALSE
				xor		eax,1
				ret
			.elseif eax==ID_EDITHEX
				invoke SaveHexEdit,hWin
				xor     eax,1
				ret
			.endif
		.elseif edx==IDM_FILE_OPENFILE
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke lstrcmpi,addr FileName,addr buffer
			.if !eax
				m2m		hFound,hWin
				invoke MdiActivate,hWin
				xor		eax,eax
				ret
			.endif
		.elseif edx==IDM_FILE_CLOSEFILE
			invoke SendMessage,hWin,WM_CLOSE,0,0
			xor		eax,1
			ret
		.elseif edx==IDM_OPTION_COLORS
			.if eax==ID_DIALOG
				invoke InvalidateRect,hWin,NULL,TRUE
			.endif
		.elseif edx==FIND_OPEN_FILENAME
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke lstrcmpi,addr buffer,offset FileName
			.if !eax
				m2m		hFound,hWin
				xor		eax,eax
				ret
			.endif
		.elseif edx==QUERY_SAVE
			.if eax==ID_EDIT || eax==ID_EDITTXT || eax==ID_EDITHEX
				invoke GetWindowLong,hWin,GWL_USERDATA
				invoke SendMessage,eax,EM_GETMODIFY,0,0
			.elseif eax==ID_DIALOG
				invoke GetWindowLong,hWin,4
				mov		eax,(DLGHEAD ptr [eax]).changed
			.endif
			.if eax
				invoke SendMessage,hClient,WM_MDIACTIVATE,hWin,0
				invoke GetWindowText,hWin,addr buffer[MAX_PATH],sizeof buffer-MAX_PATH
				invoke strcpy,addr buffer,addr WannaSave
				invoke strcat,addr buffer,addr buffer[MAX_PATH]
				mov		word ptr buffer[MAX_PATH],'?'
				invoke strcat,addr buffer,addr buffer[MAX_PATH]
				invoke MessageBox,hWin,addr buffer,addr AppName,MB_YESNOCANCEL or MB_ICONQUESTION
				.if eax==IDNO
					mov		edx,offset hNoSave
					.while dword ptr [edx]
						lea		edx,[edx+4]
					.endw
					mov		eax,hWin
					mov		[edx],eax
				.elseif eax==IDCANCEL
					inc		fCancelSave
					xor		eax,eax
					ret
				.endif
			.endif
		.elseif edx==IS_FILE_CHANGED
			.if fChangeNotify
				.if eax==ID_EDIT || eax==ID_EDITTXT || eax==ID_DIALOG || eax==ID_EDITHEX
					invoke GetCapture
					.if !eax
						invoke GetWindowLong,hWin,28
						.if [eax].RADMEM.changed
							mov		[eax].RADMEM.changed,FALSE
							invoke GetWindowText,hWin,addr buffer,sizeof buffer
							invoke lstrcpy,addr LineTxt,addr szChanged
							invoke lstrcat,addr LineTxt,addr buffer
							invoke lstrcat,addr LineTxt,addr szReopenFile
							invoke MessageBox,hWnd,addr LineTxt,addr AppName,MB_YESNO or MB_ICONQUESTION
							.if eax==6
								invoke GetWindowText,hWin,addr FileName,sizeof FileName
								invoke GetFileAttributes,addr FileName
								.if eax!=INVALID_HANDLE_VALUE
									invoke GetWindowLong,hWin,0
									.if eax==ID_EDIT || eax==ID_EDITTXT || eax==ID_DIALOG
										invoke SendMessage,hWin,WM_CLOSE,0,0
										invoke OpenEditFile
									.elseif  eax==ID_EDITHEX
										invoke SendMessage,hWin,WM_CLOSE,0,0
										invoke OpenHex
									.endif
								.endif
							.endif
						.endif
					.else
						mov		nLineTick,2
						xor		eax,eax
						ret
					.endif
				.endif
			.else
				xor		eax,eax
				ret
			.endif
		.endif
	.elseif eax==ID_EDIT
		.if edx==IDM_OPTION_FONTS || edx==IDM_OPTION_COLORS || edx==IDM_OPTION_EDIT
			invoke GetWindowLong,hWin,GWL_STYLE
			.if fUseHighLight
				and		eax,-1 xor STYLE_NOHILITE
			.else
				or		eax,STYLE_NOHILITE
			.endif
			.if fUseDivLine
				and		eax,-1 xor STYLE_NODIVIDERLINE
			.else
				or		eax,STYLE_NODIVIDERLINE
			.endif
			.if fNoFlicker
				and		eax,-1 xor STYLE_NOBACKBUFFER
			.else
				or		eax,STYLE_NOBACKBUFFER
			.endif
			.if HiliteCmnt
				or		eax,STYLE_HILITECOMMENT
			.else
				and		eax,-1 xor STYLE_HILITECOMMENT
			.endif
			invoke SetWindowLong,hWin,GWL_STYLE,eax
			invoke SetFormat,hWin,hFont[0],hFont[4],hFont[8],TRUE
			invoke SetColor,hWin
		.elseif edx==WM_PAINT
			invoke SendMessage,hWin,REM_REPAINT,0,0
		.endif
	.elseif eax==ID_EDITTXT
		.if edx==IDM_OPTION_FONTS
			invoke SetFormat,hWin,hFontTxt,hFontTxt,hFont[8],FALSE
			invoke SetColor,hWin
		.elseif edx==WM_PAINT
			invoke SendMessage,hWin,REM_REPAINT,0,0
		.elseif edx==IDM_OPTION_COLORS
			invoke SetColor,hWin
		.elseif edx==IDM_OPTION_EDIT
			invoke SendMessage,hWin,REM_SETPAGESIZE,nPageSize,0
			invoke SendMessage,hWin,REM_REPAINT,0,0
		.endif
	.elseif eax==ID_EDITHEX
		.if edx==IDM_OPTION_FONTS
			mov		eax,hFontHex
			mov		hef.hFont,eax
			mov		eax,hFont[8]
			mov		hef.hLnrFont,eax
			invoke SendMessage,hWin,HEM_SETFONT,0,addr hef
		.endif
	.elseif eax==ID_DIALOG
		.if edx==IDM_FORMAT_SHOWGRID || edx==IDM_OPTION_COLORS
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
	.endif
	mov		eax,1
	ret

WinEnumProc endp

UpdateAll proc lParam:LPARAM

	invoke EnumChildWindows,hClient,addr WinEnumProc,lParam
	ret

UpdateAll endp

;#########################################################################

HexEditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_CHAR
		.if wParam==VK_ESCAPE
			.if hFullScreen
				invoke SendMessage,hWnd,WM_COMMAND,IDM_VIEW_FULLSCREEN,0
			.endif
		.endif
	.endif
	invoke CallWindowProc,OldHexEditProc,hWin,uMsg,wParam,lParam
	ret

HexEditProc endp

EditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	pt:POINT
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_CONTEXTMENU
		invoke DllProc,hWin,AIM_CONTEXTMENU,wParam,lParam,RAM_CONTEXTMENU
		.if eax
			xor		eax,eax
			ret
		.endif
		mov		eax,lParam
		.if lParam!=-1
			cwde
			mov		pt.x,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			inc		eax
			mov		pt.y,eax
		.else
			invoke GetCaretPos,addr pt
			invoke ClientToScreen,hWin,addr pt
		.endif
		.if fMaximized
			invoke GetSubMenu,hMenu,MENUEDIT+1
		.else
			invoke GetSubMenu,hMenu,MENUEDIT
		.endif
		invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWnd,NULL
		xor		eax,eax
		ret
	.elseif eax==WM_SETFOCUS || eax==WM_CREATE
		invoke GetParent,hWin
		mov		hEdit,eax
	.elseif eax==WM_KEYDOWN
		invoke GetParent,hWin
		mov		hEdit,eax
		invoke DllProc,hEdit,AIM_EDITKEYDOWN,wParam,lParam,RAM_EDITKEYDOWN
		.if eax
			xor		eax,eax
			ret
		.endif
		invoke GetKBState
		mov      ecx,wParam
		.if eax && !edx			;Ctrl
			.if ecx==VK_SPACE
				.if fLB
					mov		wParam,VK_TAB
					mov		fEatChar,TRUE
				.else
					mov		fLocal,FALSE
					invoke ApiWordList,hEdit
					xor		eax,eax
					mov		fEatChar,TRUE
					ret
				.endif
			.endif
		.elseif !eax && edx		;Shift
			.if ecx==VK_SPACE && ApiShiftSpace
				.if fLB
					mov		wParam,VK_TAB
					mov		fEatChar,TRUE
				.else
					mov		fLocal,FALSE
					invoke ApiWordList,hEdit
					xor		eax,eax
					mov		fEatChar,TRUE
					ret
				.endif
			.elseif ecx==VK_TAB
				invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMin
				.if eax!=chrg.cpMax
					.if eax>chrg.cpMax
						xchg	eax,chrg.cpMax
						mov		chrg.cpMin,eax
					.endif
					invoke SendMessage,hEdit,EM_LINELENGTH,chrg.cpMin,0
					push	eax
					invoke SendMessage,hEdit,EM_LINEFROMCHAR,chrg.cpMin,0
					invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
					pop		edx
					add		edx,eax
					.if eax==chrg.cpMin && edx<=chrg.cpMax
						invoke IndentComment,VK_TAB,FALSE
						xor		eax,eax
						mov		fEatChar,TRUE
						ret
					.endif
				.endif
			.endif
		.elseif eax && edx		;Shift+Ctrl
			.if ecx==VK_SPACE
				.if fTlt
					invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr szTltSel
					invoke ApiToolTip,hEdit
					xor		eax,eax
					mov		fEatChar,FALSE
					ret
				.elseif fLB
					mov		wParam,VK_TAB
					mov		fEatChar,TRUE
				.else
					;Locals only
					mov		fLocal,TRUE
					invoke ApiWordList,hEdit
					xor		eax,eax
					mov		fEatChar,eax
					ret
				.endif
			.endif
		.elseif !eax && !edx	;None
			.if ecx==VK_INSERT
				invoke GetWindowLong,hMdiCld,20
				xor		eax,TRUE
				invoke SetWindowLong,hMdiCld,20,eax
				mov		nLineTick,1
			.elseif ecx==VK_TAB
				invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMin
				.if eax!=chrg.cpMax
					.if eax>chrg.cpMax
						xchg	eax,chrg.cpMax
						mov		chrg.cpMin,eax
					.endif
					invoke SendMessage,hEdit,EM_LINELENGTH,chrg.cpMin,0
					push	eax
					invoke SendMessage,hEdit,EM_LINEFROMCHAR,chrg.cpMin,0
					invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
					pop		edx
					add		edx,eax
					.if eax==chrg.cpMin && edx<=chrg.cpMax
						invoke IndentComment,VK_TAB,TRUE
						xor		eax,eax
						mov		fEatChar,TRUE
						ret
					.endif
				.endif
			.endif
		.endif
		.if fLB
			invoke IsWindowVisible,hLB
			.if eax
				mov		ecx,wParam
				mov		eax,lParam
				shr		eax,16
				and		eax,3FFFh
				.if eax==0150h || eax==0148h || eax==0151h || eax==0149h
					invoke PostMessage,hLB,uMsg,wParam,lParam
					xor		eax,eax
					ret
				.elseif ecx==VK_TAB || ecx==VK_RETURN
					.if ecx==VK_TAB
						invoke GetFocus
						.if eax!=hLB && fEnterOnTab
							invoke SendMessage,hLB,LB_GETCOUNT,0,0
							.if eax
								invoke SetFocus,hLB
							.endif
							mov		fEatChar,TRUE
							xor		eax,eax
							ret
						.endif
					.endif
					invoke SendMessage,hLB,LB_GETCURSEL,0,0
					.if eax!=LB_ERR
						mov		edx,eax
						push	edx
						invoke SendMessage,hLB,LB_GETTEXT,edx,addr buffer
						.if fLBStruct || fLBWord
							lea		edx,buffer
							dec		edx
						  @@:
							inc		edx
							mov		al,[edx]
							or		al,al
							je		@f
							cmp		al,'['
							je		En
							cmp		al,':';VK_TAB
							jne		@b
						  En:
							mov		al,0
							mov		[edx],al
							inc		edx
							invoke strcpy,offset StBuff,edx
							invoke strcat,offset StBuff,offset szPoint
						  @@:
						.elseif fInc
							invoke strcpy,addr buffer,addr szIncludeSt
							invoke strlen,addr buffer
							lea		eax,buffer[eax]
							pop		edx
							push	edx
							invoke SendMessage,hLB,LB_GETTEXT,edx,eax
							invoke strcat,addr buffer,addr szIncludeEn
						.elseif fLib
							invoke strcpy,addr buffer,addr szIncludeLibSt
							invoke strlen,addr buffer
							lea		eax,buffer[eax]
							pop		edx
							push	edx
							invoke SendMessage,hLB,LB_GETTEXT,edx,eax
							invoke strcat,addr buffer,addr szIncludeLibEn
						.endif
						pop		edx
						invoke SendMessage,hLB,LB_GETITEMDATA,edx,0
						mov		szApiEnd,al
						invoke ShowWindow,hLB,SW_HIDE
						invoke SendMessage,hEdit,EM_HIDESELECTION,TRUE,0
						invoke SendMessage,hEdit,EM_EXSETSEL,0,addr findtext.chrg
						invoke strlen,addr buffer
						lea		eax,buffer[eax-1]
						.while byte ptr [eax]==')'
							mov		byte ptr [eax],0
							dec		eax
						.endw
						lea		eax,buffer
						.while byte ptr [eax]=='('
							inc		eax
						.endw
						invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,eax
						mov		al,szApiEnd
						.if al==','
							.if fNoTrig || nAsm==nHLA || nAsm==nCPP || nAsm==nFP
								mov		szApiEnd,'('
							.endif
							invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr szApiEnd
							invoke ApiToolTip,hEdit
						.endif
						invoke SendMessage,hEdit,EM_HIDESELECTION,FALSE,0
					.endif
					mov		fEatChar,TRUE
					xor		eax,eax
					.if !fLBConst
						mov		fLB,eax
						mov		fLBStruct,eax
						mov		fLBWord,eax
						mov		fLBType,eax
					.endif
					ret
				.endif
			.endif
		.endif
		mov      ecx,wParam
		.if ecx==VK_RETURN
			invoke ShowWindow,hLB,SW_HIDE
			xor		eax,eax
			mov		fLB,eax
			mov		fLBConst,eax
			mov		fLBStruct,eax
			mov		fLBWord,eax
			mov		fLBType,eax
			mov		StBuff,al
			m2m		fCodeMacro,hEdit
			invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
			invoke SendMessage,hEdit,REM_ISCHARPOS,chrg.cpMin,0
			.if !eax
				invoke ApiWordConvert,hEdit,TRUE
			.endif
		.else
			mov		fCodeMacro,-1
		.endif
	.elseif eax==WM_CHAR
		invoke DllProc,hEdit,AIM_EDITCHAR,wParam,lParam,RAM_EDITCHAR
		.if fEatChar || eax
			xor		eax,eax
			mov		fEatChar,eax
			ret
		.elseif wParam=='[' && fAutoBrackets
			push	ebx
			mov		fAutoBrackets,0
			invoke SendMessage,hEdit,REM_GETCHARTAB,'.',0
			push	eax
			invoke SendMessage,hEdit,REM_GETCHARTAB,'+',0
			push	eax
			invoke SendMessage,hEdit,REM_GETCHARTAB,'-',0
			push	eax
			invoke SendMessage,hEdit,REM_GETCHARTAB,':',0
			push	eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,'.',CT_CHAR
			invoke SendMessage,hEdit,REM_SETCHARTAB,'+',CT_CHAR
			invoke SendMessage,hEdit,REM_SETCHARTAB,'-',CT_CHAR
			invoke SendMessage,hEdit,REM_SETCHARTAB,':',CT_CHAR
			invoke SendMessage,hWin,WM_CHAR,'[',lParam
			invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
			mov		ebx,chrg.cpMin
			invoke SendMessage,hEdit,EM_FINDWORDBREAK,WB_MOVEWORDRIGHT,ebx
			mov		chrg.cpMin,eax
			mov		chrg.cpMax,eax
			sub		ebx,eax
			invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hWin,WM_CHAR,']',lParam
			pop		eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,':',eax
			pop		eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,'-',eax
			pop		eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,'+',eax
			pop		eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,'.',eax
			.if !ebx
				invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
			.endif
			invoke SendMessage,hEdit,EM_SCROLLCARET,0,0
			mov		fAutoBrackets,1
			pop		ebx
			xor		eax,eax
			ret
		.elseif wParam==']' && fAutoBrackets
			push	ebx
			mov		fAutoBrackets,0
			invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
			invoke SendMessage,hEdit,REM_GETCHARTAB,'.',0
			push	eax
			invoke SendMessage,hEdit,REM_GETCHARTAB,'+',0
			push	eax
			invoke SendMessage,hEdit,REM_GETCHARTAB,'-',0
			push	eax
			invoke SendMessage,hEdit,REM_GETCHARTAB,':',0
			push	eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,'.',CT_CHAR
			invoke SendMessage,hEdit,REM_SETCHARTAB,'+',CT_CHAR
			invoke SendMessage,hEdit,REM_SETCHARTAB,'-',CT_CHAR
			invoke SendMessage,hEdit,REM_SETCHARTAB,':',CT_CHAR
			mov		ebx,chrg.cpMin
			invoke SendMessage,hWin,WM_CHAR,']',lParam
			invoke SendMessage,hEdit,EM_FINDWORDBREAK,WB_MOVEWORDLEFT,ebx
			.if eax!=ebx
				mov		chrg.cpMin,eax
				mov		chrg.cpMax,eax
				inc		ebx
			.endif
			invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hWin,WM_CHAR,'[',lParam
			pop		eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,':',eax
			pop		eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,'-',eax
			pop		eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,'+',eax
			pop		eax
			invoke SendMessage,hEdit,REM_SETCHARTAB,'.',eax
			inc		ebx
			mov		chrg.cpMin,ebx
			mov		chrg.cpMax,ebx
			invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hEdit,EM_SCROLLCARET,0,0
			mov		fAutoBrackets,1
			pop		ebx
			xor		eax,eax
			ret
		.endif
		invoke CallWindowProc,OldEditProc,hWin,uMsg,wParam,lParam
		mov		eax,wParam
		.if eax==1Bh || eax==0Dh
			invoke ShowWindow,hLB,SW_HIDE
			.if fTlt
				invoke ShowWindow,hTlt,SW_HIDE
			.endif
			.if !fLB && !fTlt && hFullScreen && wParam==1Bh
				invoke SendMessage,hWnd,WM_COMMAND,IDM_VIEW_FULLSCREEN,0
			.endif
			xor		eax,eax
			mov		fTlt,eax
			mov		fLB,eax
			mov		fLBConst,eax
			mov		fLBStruct,eax
			mov		fLBWord,eax
			mov		fLBType,eax
			mov		StBuff,al
		.else
			invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
			invoke SendMessage,hEdit,REM_ISCHARPOS,chrg.cpMin,0
			.if !eax
				.if !fLBConst && !fLBStruct && !fLBWord && !fLBType
					invoke ApiCheck,hEdit,wParam
					invoke ApiListBox,hEdit
					.if !fLB
						.if nAsm==nBCET && (wParam==' ' || wParam==VK_TAB)
							invoke TypeCheck,hEdit
						.endif
						.if !fLB
							mov		eax,wParam
							.if fTlt && al==')'
								mov		fTlt,0
								invoke ShowWindow,hTlt,SW_HIDE
							.elseif (al<'0' && al>1Fh) || (al>'9' && al<'@') || (al>'Z' && al<'_') || (al>'z' && al<7Fh) || al==0Dh || al==09h
								invoke ApiWordConvert,hEdit,0
							.endif
						.endif
					.endif
				.elseif fLBType
					invoke ApiTypeList,hEdit
				.elseif fLBConst
					push	findtext.chrg.cpMin
					invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findtext.chrg
					pop		findtext.chrg.cpMin
					mov		eax,findtext.chrg.cpMax
					mov		edx,eax
					sub		edx,findtext.chrg.cpMin
					.if eax>=findtext.chrg.cpMin && edx<128
						invoke ApiConstList,lpApiLine,nCommaCont
						invoke SendMessage,hLB,LB_GETCOUNT,0,0
						.if !eax
							invoke ShowWindow,hLB,SW_HIDE
						.endif
					.else
						invoke ShowWindow,hLB,SW_HIDE
						xor		eax,eax
						mov		fLB,eax
						mov		fLBConst,eax
						mov		fLBStruct,eax
						mov		fLBWord,eax
						mov		fLBType,eax
					.endif
				.elseif fLBStruct
					push	findtext.chrg.cpMin
					invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findtext.chrg
					pop		findtext.chrg.cpMin
					mov		eax,findtext.chrg.cpMax
					.if eax>=findtext.chrg.cpMin
						invoke ApiStructCheck,hEdit
						invoke SendMessage,hLB,LB_GETCOUNT,0,0
						.if !eax
							invoke ShowWindow,hLB,SW_HIDE
						.endif
					.else
						invoke ShowWindow,hLB,SW_HIDE
						xor		eax,eax
						mov		fLB,eax
						mov		fLBConst,eax
						mov		fLBStruct,eax
						mov		fLBWord,eax
						mov		fLBType,eax
						mov		StBuff,al
					.endif
				.elseif fLBWord
					.if wParam>=' ' || wParam==8
						invoke ApiWordList,hEdit
					.endif
				.endif
				mov		eax,wParam
				.if eax==',' || eax=='<' || (eax=='(' && fNoTrig)
					invoke ShowWindow,hLB,SW_HIDE
					xor		eax,eax
					mov		fLB,eax
					mov		fLBConst,eax
					mov		fLBStruct,eax
					mov		fLBWord,eax
					mov		fLBType,eax
					mov		StBuff,al
					invoke ApiToolTip,hEdit
					invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findtext.chrg
				.elseif eax==' ' && fLBConst
					invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findtext.chrg
					invoke ApiConstList,lpApiLine,nCommaCont
				.elseif eax=='.' && !fLBConst
					invoke ApiStructCheck,hEdit
				.elseif eax=='>' && !fLBConst && (nAsm==nCPP || nAsm==nBCET)
					invoke SendMessage,hEdit,EM_EXGETSEL,0,addr txtrng.chrg
					mov		eax,txtrng.chrg.cpMin
					.if eax>2
						sub		eax,2
						mov		txtrng.chrg.cpMin,eax
						lea		eax,buffer
						mov		txtrng.lpstrText,eax
						invoke SendMessage,hEdit,EM_GETTEXTRANGE,0,addr txtrng
						.if word ptr buffer=='>-'
							invoke ApiStructCheck,hEdit
						.endif
					.endif
				.endif
			.endif
		.endif
		xor		eax,eax
		ret
	.elseif eax==WM_NCLBUTTONDOWN
		invoke SetFocus,hWin
		invoke GetParent,hWin
		mov		hEdit,eax
	.elseif eax==WM_LBUTTONDOWN
		mov		fCodeMacro,-1
	.elseif eax==WM_MOUSEWHEEL
		.if !MouseWheel
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_MOUSEMOVE
		invoke DllProc,hWin,AIM_EDITMOUSEMOVE,wParam,lParam,RAM_EDITMOUSEMOVE
		.if fCodeTooltip
			invoke CallWindowProc,OldEditProc,hWin,uMsg,wParam,lParam
			push	eax
			invoke GetCursorPos,addr pt
			mov		eax,pt.x
			sub		eax,infoshowpt.x
			.if CARRY?
				neg		eax
			.endif
			mov		edx,pt.y
			sub		edx,infoshowpt.y
			.if CARRY?
				neg		edx
			.endif
			.if eax>2 || edx>2
				mov		eax,pt.x
				mov		infoshowpt.x,eax
				mov		eax,pt.y
				mov		infoshowpt.y,eax
				invoke FindTooltipWord,hWin,FALSE
			.endif
			pop		eax
			ret
		.endif
	.endif
	invoke CallWindowProc,OldEditProc,hWin,uMsg,wParam,lParam
	ret

EditProc endp

;#########################################################################

EditTxtProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_CONTEXTMENU
		invoke DllProc,hWin,AIM_CONTEXTMENU,wParam,lParam,RAM_CONTEXTMENU
		.if eax
			xor		eax,eax
			ret
		.endif
		mov		eax,lParam
		.if lParam!=-1
			cwde
			mov		pt.x,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			inc		eax
			mov		pt.y,eax
		.else
			invoke GetCaretPos,addr pt
			invoke ClientToScreen,hWin,addr pt
		.endif
		.if fMaximized
			invoke GetSubMenu,hMenu,MENUEDIT+1
		.else
			invoke GetSubMenu,hMenu,MENUEDIT
		.endif
		invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWnd,0
		xor		eax,eax
		ret
	.elseif eax==WM_NCLBUTTONDOWN
		invoke SetFocus,hWin
		m2m		hEdit,hWin
	.elseif eax==WM_MOUSEWHEEL
		.if !MouseWheel
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_KEYDOWN
		invoke GetKBState
		mov      ecx,wParam
		.if !eax && edx		;Shift
			.if ecx==VK_TAB
				invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMin
				.if eax!=chrg.cpMax
					.if eax>chrg.cpMax
						xchg	eax,chrg.cpMax
						mov		chrg.cpMin,eax
					.endif
					invoke SendMessage,hEdit,EM_LINELENGTH,chrg.cpMin,0
					push	eax
					invoke SendMessage,hEdit,EM_LINEFROMCHAR,chrg.cpMin,0
					invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
					pop		edx
					add		edx,eax
					.if eax==chrg.cpMin && edx<=chrg.cpMax
						invoke IndentComment,VK_TAB,FALSE
						xor		eax,eax
						mov		fEatChar,TRUE
						ret
					.endif
				.endif
			.endif
		.elseif !eax && !edx	;None
			.if ecx==VK_INSERT
				invoke GetWindowLong,hMdiCld,20
				xor		eax,TRUE
				invoke SetWindowLong,hMdiCld,20,eax
				mov		nLineTick,1
			.elseif ecx==VK_TAB
				invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
				mov		eax,chrg.cpMin
				.if eax!=chrg.cpMax
					.if eax>chrg.cpMax
						xchg	eax,chrg.cpMax
						mov		chrg.cpMin,eax
					.endif
					invoke SendMessage,hEdit,EM_LINELENGTH,chrg.cpMin,0
					push	eax
					invoke SendMessage,hEdit,EM_LINEFROMCHAR,chrg.cpMin,0
					invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
					pop		edx
					add		edx,eax
					.if eax==chrg.cpMin && edx<=chrg.cpMax
						invoke IndentComment,VK_TAB,TRUE
						xor		eax,eax
						mov		fEatChar,TRUE
						ret
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_CHAR
		.if fEatChar
			xor		eax,eax
			mov		fEatChar,eax
			ret
		.endif
		.if wParam==VK_ESCAPE
			.if hFullScreen
				invoke SendMessage,hWnd,WM_COMMAND,IDM_VIEW_FULLSCREEN,0
			.endif
		.endif
	.endif
	invoke CallWindowProc,OldEditProc,hWin,uMsg,wParam,lParam
	ret

EditTxtProc endp

;#########################################################################

ListBoxProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_LBUTTONDBLCLK
		invoke SendMessage,hEdit,WM_KEYDOWN,VK_TAB,0
		invoke SendMessage,hEdit,WM_CHAR,VK_TAB,0
		xor		eax,eax
		ret
	.elseif eax==WM_LBUTTONDOWN
		mov		edx,lParam
		movsx	eax,dx
		shr		edx,16
		movsx	edx,dx
		mov		pt.x,eax
		mov		pt.y,edx
		invoke SendMessage,hWin,LB_GETTOPINDEX,0,0
		.if eax!=LB_ERR
			push	eax
			mov		ecx,lbItehHeight

			mov		eax,pt.y
			xor		edx,edx
			div		ecx
			pop		ecx
			add		eax,ecx
			invoke SendMessage,hWin,LB_SETCURSEL,eax,0
		.endif
		xor		eax,eax
		ret
	.elseif eax==WM_SIZE
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		mov		apilbwt,eax
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		apilbht,eax
	.endif
	invoke CallWindowProc,OldListBoxProc,hWin,uMsg,wParam,lParam
	ret

ListBoxProc endp

;#########################################################################

end start


