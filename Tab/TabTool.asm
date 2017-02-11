
.const

TCS_SCROLLOPPOSITE      equ 0001h
TCS_BOTTOM              equ 0002h
TCS_RIGHT               equ 0002h
TCS_MULTISELECT         equ 0004h
TCS_FLATBUTTONS         equ 0008h
TCS_FORCEICONLEFT       equ 0010h
TCS_FORCELABELLEFT      equ 0020h
TCS_HOTTRACK            equ 0040h
TCS_VERTICAL            equ 0080h
TCS_TABS                equ 0000h
TCS_BUTTONS             equ 0100h
TCS_SINGLELINE          equ 0000h
TCS_MULTILINE           equ 0200h
TCS_RIGHTJUSTIFY        equ 0000h
TCS_FIXEDWIDTH          equ 0400h
TCS_RAGGEDRIGHT         equ 0800h
TCS_FOCUSONBUTTONDOWN   equ 1000h
TCS_OWNERDRAWFIXED      equ 2000h
TCS_TOOLTIPS            equ 4000h
TCS_FOCUSNEVER          equ 8000h

.code

TabProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ht:TC_HITTESTINFO
	LOCAL	tci:TC_ITEM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_LBUTTONDOWN
		mov		eax,lParam
		movzx	edx,ax
		shr		eax,16
		mov		ht.pt.x,edx
		mov		ht.pt.y,eax
		invoke SendMessage,hWin,TCM_HITTEST,0,addr ht
		.if eax!=-1
			mov		tabinx,eax
			invoke SendMessage,hWin,TCM_SETCURSEL,eax,0
			mov		tci.imask,TCIF_PARAM
			invoke SendMessage,hTab,TCM_GETITEM,tabinx,addr tci
			invoke TabToolSel,tci.lParam
			invoke SendMessage,hPbrTrv,TVM_SELECTITEM,TVGN_CARET,hRoot
			invoke ProSetTrv,hMdiCld
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_MOUSEMOVE
		test	wParam,MK_LBUTTON
		.if !ZERO?
			mov		eax,lParam
			movzx	edx,ax
			shr		eax,16
			mov		ht.pt.x,edx
			mov		ht.pt.y,eax
			invoke SendMessage,hWin,TCM_GETITEMRECT,tabinx,addr rect
			sub		rect.left,30
			add		rect.right,30
			mov		eax,ht.pt.x
			.if sdword ptr eax<rect.left || sdword ptr eax>rect.right
				invoke SendMessage,hWin,TCM_HITTEST,0,addr ht
				.if eax!=tabinx && sdword ptr eax>=0 && sdword ptr tabinx>=0
					push	eax
					mov		tci.imask,TCIF_TEXT Or TCIF_IMAGE Or TCIF_PARAM
					lea		eax,buffer
					mov		tci.pszText,eax
					mov		tci.cchTextMax,MAX_PATH
					invoke SendMessage,hWin,TCM_GETITEM,tabinx,addr tci
					invoke SendMessage,hWin,TCM_DELETEITEM,tabinx,0
					pop		tabinx
					invoke SendMessage,hWin,TCM_INSERTITEM,tabinx,addr tci
				.endif
			.endif
			xor		eax,eax
			ret
		.endif
	.endif
	invoke CallWindowProc,lpOldTabProc,hWin,uMsg,wParam,lParam
	ret

TabProc endp

Do_TabTool proc
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer2[64]:BYTE
    LOCAL   sTool:DOCKING
    LOCAL   hWin:HWND

    mov		sTool.ID,5
    mov     sTool.Caption,offset szNULL
	invoke strcpy,addr buffer,addr TabTool
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Visible,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Docked,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Position,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.IsChild,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.DockWidth,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.DockHeight,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.left,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.top,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.right,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.bottom,eax
	mov     eax,sTool.Position
	.if eax==TL_TOP || eax==TL_BOTTOM
		mov		edx,WS_VISIBLE or WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or WS_TABSTOP or TCS_FOCUSNEVER or TCS_BUTTONS
	.else
		mov		edx,WS_VISIBLE or WS_CHILD or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or WS_TABSTOP or TCS_FOCUSNEVER or TCS_BUTTONS or TCS_VERTICAL or TCS_RIGHT
	.endif	
	.if fMultiLine
		or		edx,TCS_MULTILINE
	.endif
	invoke CreateWindowEx,0,addr szTabControl,0,
			edx,0,0,0,0,hWnd,0,hInstance, 0
    mov     hWin, eax
    invoke ToolMessage,hWin,TLM_CREATE,addr sTool
	invoke SendMessage,hWin,TCM_SETIMAGELIST,0,hTbrIml
	invoke SetWindowLong,hWin,GWL_WNDPROC,offset TabProc
	mov		lpOldTabProc,eax
    mov     eax, hWin
    ret

Do_TabTool endp

TabToolSet proc hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		eax,tci.lParam
			.if eax==hWin
				invoke SendMessage,hTab,TCM_SETCURSEL,nInx,0
				xor eax,eax
			.endif
		.endif
	.endw
	ret

TabToolSet endp

TabToolUpdate proc hWin:HWND,lpText:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		eax,tci.lParam
			.if eax==hWin
				mov		tci.imask,TCIF_TEXT
				mov		eax,lpText
				mov		tci.pszText,eax
				invoke SendMessage,hTab,TCM_SETITEM,nInx,addr tci
				xor eax,eax
			.endif
		.endif
	.endw
	ret

TabToolUpdate endp

TabToolSel proc hWin:HWND
	LOCAL	tci:TC_ITEM

	invoke SendMessage,hTab,TCM_GETCURSEL,0,0
	mov		tci.imask,TCIF_PARAM
	mov		edx,eax
	invoke SendMessage,hTab,TCM_GETITEM,edx,addr tci
	invoke MdiActivate,tci.lParam
	ret

TabToolSel endp

TabToolSetSel proc nInx:DWORD
	LOCAL	tci:TC_ITEM

	invoke SendMessage,hTab,TCM_SETCURSEL,nInx,0
	.if eax!=-1
		mov		tci.imask,TCIF_PARAM
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		invoke MdiActivate,tci.lParam
	.endif
	ret

TabToolSetSel endp

TabToolAdd proc hWin:HWND,lpFileName:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	tci:TC_ITEM

	invoke strcpy,addr buffer,lpFileName
	invoke iniRStripStr,addr buffer,'\'
	.if !byte ptr [eax]
		inc		eax
	.endif
	mov		tci.imask,TCIF_TEXT or TCIF_PARAM or TCIF_IMAGE
	mov		tci.pszText,eax
	mov		tci.cchTextMax,20
	m2m		tci.lParam,hWin
	invoke GetFileImg,lpFileName
	.if	eax>=30
		mov		eax,7
	.endif
	add		eax,IML_START
	mov		tci.iImage,eax
	invoke SendMessage,hTab,TCM_INSERTITEM,999,addr tci
	invoke SendMessage,hTab,TCM_SETCURSEL,eax,0
	invoke AddPath,hWin
	ret

TabToolAdd endp

TabToolDel proc hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		nInx,-1
	mov		tci.imask,TCIF_PARAM
	mov		eax,TRUE
	.while eax
		inc		nInx
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.if eax
			mov		eax,tci.lParam
			.if eax==hWin
				invoke SendMessage,hTab,TCM_DELETEITEM,nInx,0
				invoke DelPath,hWin
				xor eax,eax
			.endif
		.endif
	.endw
	ret

TabToolDel endp

