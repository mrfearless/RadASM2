;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include HexVU.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

MdiCldProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_CREATE
		push	ebx
		invoke CreateWindowEx,NULL,addr szHexChild,NULL,WS_CHILD or WS_VISIBLE or WS_VSCROLL,0,0,0,0,hWin,1000,hRAInstance,0
		mov		ebx,eax
		invoke SetWindowLong,hWin,GWL_USERDATA,ebx
		invoke SendMessage,ebx,WM_SETFONT,hFont,FALSE
		pop		ebx
	.elseif eax==WM_MDIACTIVATE
		mov		eax,lParam
		.if eax==hWin
			push	eax
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpSelTab
			invoke GetDlgItem,hWin,1000
			invoke SetFocus,eax
		.endif
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,1000
		invoke MoveWindow,eax,0,0,rect.right,rect.bottom,TRUE
	.elseif eax==WM_CLOSE
		push	hWin
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpDelTab
	.endif
	invoke DefMDIChildProc,hWin,uMsg,wParam,lParam
	ret

MdiCldProc endp

HexLine proc uses ebx esi edi,lpMem:DWORD,nBytes:DWORD,nLine:DWORD,lpString:DWORD

	mov		esi,lpMem
	mov		edi,lpString
	mov		byte ptr [edi],0
	mov		ebx,nLine
	shl		ebx,4
	.if ebx<nBytes
		mov		eax,ebx
		call	HexAddr
		xor		ecx,ecx
		.while ebx<nBytes && ecx<16
			call	HexByte
		.endw
		call	Ascii
		xor		eax,eax
		inc		eax
	.else
		xor		eax,eax
	.endif
	ret

Ascii:
	.if ecx<16
		push	ecx
		sub		ecx,16
		neg		ecx
		mov		eax,ecx
		shl		ecx,1
		add		ecx,eax
		mov		al,' '
		rep stosb
		pop		ecx
	.endif
	sub		ebx,ecx
	push	ecx
	.while ecx
		mov		al,[esi+ebx]
		.if al<20h || al>7Eh
			mov		al,'.'
		.endif
		mov		[edi],al
		inc		edi
		inc		ebx
		dec		ecx
	.endw
	pop		ecx
	sub		ecx,16
	neg		ecx
	mov		al,' '
	rep stosb
	retn

HexAddr:
	push	ecx
	mov		ecx,8
  @@:
	call	Nibble
	mov		[edi],dl
	inc		edi
	dec		ecx
	jne		@b
	pop		ecx
	retn

HexByte:
	mov		al,[esi+ebx]
	shl		eax,24
	call	Nibble
	mov		[edi],dl
	inc		edi
	call	Nibble
	mov		[edi],dl
	inc		edi
	inc		ecx
	inc		ebx
	.if ecx==8
		mov		word ptr [edi],'-'
	.else
		mov		word ptr [edi],' '
	.endif
	inc		edi
	retn

Nibble:
	rol		eax,4
	push	eax
	and		eax,0Fh
	.if eax<=9
		add		eax,'0'
	.else
		add		eax,'A'-10
	.endif
	mov		edx,eax
	pop		eax
	retn

HexLine endp

TestScroll proc hWin:HWND
	LOCAL	sinf:SCROLLINFO
	LOCAL	nLine:DWORD
	LOCAL	cp:DWORD

	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_ALL
	invoke GetScrollInfo,hWin,SB_VERT,addr sinf
	invoke GetWindowLong,hWin,8
	mov		nLine,eax
	invoke GetWindowLong,hWin,12
	mov		cp,eax
	mov		edx,nLine
	mov		ecx,edx
	add		ecx,sinf.nPage
	dec		ecx
	shr		eax,5
	.if eax<edx
		sub		eax,edx
	.elseif eax>ecx
		sub		eax,ecx
	.else
		xor		eax,eax
	.endif
	add		eax,nLine
	ret

TestScroll endp

SetCaret proc hWin:HWND
	LOCAL	nLine:DWORD
	LOCAL	cp:DWORD
	LOCAL	xp:DWORD
	LOCAL	yp:DWORD

	invoke CreateCaret,hWin,NULL,fntwt,fntht
	invoke GetWindowLong,hWin,8
	mov		nLine,eax
	invoke GetWindowLong,hWin,12
	mov		cp,eax
	mov		ecx,eax
	shr		eax,1
	and		eax,0Fh
	mov		edx,3
	mul		edx
	mov		edx,fntwt
	mul		edx
	add		eax,dataxp
	test	ecx,1
	.if !ZERO?
		add		eax,fntwt
	.endif
	mov		xp,eax
	mov		eax,ecx
	shr		eax,5
	sub		eax,nLine
	mov		edx,fntht
	mul		edx
	mov		yp,eax
	invoke SetCaretPos,xp,yp
	invoke ShowCaret,hWin
	ret

SetCaret endp

HexCldProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL	sinf:SCROLLINFO
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	hMem:DWORD
	LOCAL	lpMem:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	nLine:DWORD
	LOCAL	cp:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	fControl:DWORD
	LOCAL	fShift:DWORD

	mov		eax,uMsg
	.if eax==WM_PAINT
		invoke GetClientRect,hWin,addr rect
		invoke GetWindowLong,hWin,0
		mov		hMem,eax
		invoke GetWindowLong,hWin,4
		mov		nBytes,eax
		invoke GetWindowLong,hWin,8
		mov		nLine,eax
		invoke GetWindowLong,hWin,12
		mov		cp,eax
		call	SetScroll
		invoke BeginPaint,hWin,addr ps
		invoke SelectObject,ps.hdc,hFont
		push	eax
		invoke SelectObject,ps.hdc,hPen
		push	eax
		invoke SetBkMode,ps.hdc,TRANSPARENT
		push	rect.right
		mov		eax,rect.left
		add		eax,barwt
		mov		rect.right,eax
		invoke FillRect,ps.hdc,addr rect,hBrBar
		pop		rect.right
		invoke MoveToEx,ps.hdc,barwt,0,NULL
		invoke LineTo,ps.hdc,barwt,rect.bottom
		invoke GlobalLock,hMem
		mov		lpMem,eax
		mov		rect.left,barwt+1
		xor		edx,edx
		.while edx<rect.bottom
			push	edx
			mov		eax,rect.top
			.if eax<ps.rcPaint.bottom
				add		eax,fntht
				.if eax>ps.rcPaint.top
					push	rect.bottom
					mov		rect.bottom,eax
					invoke FillRect,ps.hdc,addr rect,hBrBack
					invoke HexLine,lpMem,nBytes,nLine,addr buffer
					.if eax
						invoke SetTextColor,ps.hdc,coladdr
						invoke TextOut,ps.hdc,addrxp,rect.top,addr buffer,8
						invoke SetTextColor,ps.hdc,coldata
						invoke TextOut,ps.hdc,dataxp,rect.top,addr buffer[8],47
						invoke SetTextColor,ps.hdc,colascii
						invoke TextOut,ps.hdc,asciixp,rect.top,addr buffer[8+47+1],16
					.endif
					pop		rect.bottom
				.endif
			.endif
			pop		edx
			inc		nLine
			add		edx,fntht
			mov		rect.top,edx
		.endw
		invoke GlobalUnlock,hMem
		invoke MoveToEx,ps.hdc,line1xp,0,NULL
		invoke LineTo,ps.hdc,line1xp,rect.bottom
		invoke MoveToEx,ps.hdc,line2xp,0,NULL
		invoke LineTo,ps.hdc,line2xp,rect.bottom
		;Restore pen
		pop		eax
		invoke SelectObject,ps.hdc,eax
		;Restore font
		pop		eax
		invoke SelectObject,ps.hdc,eax
		invoke EndPaint,hWin,addr ps
	.elseif eax==WM_KEYDOWN
		invoke GetWindowLong,hWin,4
		mov		nBytes,eax
		invoke GetKeyState,VK_CONTROL
		and		eax,80h
		mov		fControl,eax
		invoke GetKeyState,VK_SHIFT
		and		eax,80h
		mov		fShift,eax
		mov		edx,wParam
		mov		eax,lParam
		shr		eax,16
		and		eax,3FFh
		.if fControl
			.if edx==28h && (eax==150h || eax==50h)
				;Ctrl+Down
				mov		eax,SB_LINEDOWN
			.elseif edx==26h && (eax==148h || eax==48h)
				;Ctrl+Up
				mov		eax,SB_LINEUP
			.elseif edx==22h && (eax==151h || eax==51h)
				;Ctrl+PgDn
				mov		eax,SB_PAGEDOWN
			.elseif edx==21h && (eax==149h || eax==49h)
				;Ctrl+PgUp
				mov		eax,SB_PAGEUP
			.elseif edx==23h && (eax==14Fh || eax==4Fh)
				;Ctrl+End
				mov		eax,SB_BOTTOM
			.elseif edx==24h && (eax==147h || eax==47h)
				;Ctrl+Home
				mov		eax,SB_TOP	
			.else
				xor		eax,eax
				dec		eax
			.endif
			.if eax!=-1
				invoke SendMessage,hWin,WM_VSCROLL,eax,0
			.endif
		.elseif !fControl
			.if edx==26h && (eax==148h || eax==48h)
				;Up
				invoke GetWindowLong,hWin,12
				sub		eax,32
				jnb		@f
				add		eax,32
			  @@:
				invoke SetWindowLong,hWin,12,eax
			.elseif edx==28h && (eax==150h || eax==50h)
				;Down
				invoke GetWindowLong,hWin,12
				add		eax,32
				mov		edx,eax
				shr		edx,1
				.if edx>=nBytes
					sub		eax,32
				.endif
				invoke SetWindowLong,hWin,12,eax
			.elseif edx==25h && (eax==14Bh || eax==4Bh)
				;Left
				invoke GetWindowLong,hWin,12
				.if eax
					dec		eax
					invoke SetWindowLong,hWin,12,eax
				.endif
			.elseif edx==27h && (eax==14Dh || eax==4Dh)
				;Right
				invoke GetWindowLong,hWin,12
				inc		eax
				mov		edx,eax
				shr		edx,1
				.if edx>=nBytes
					dec		eax
				.endif
				invoke SetWindowLong,hWin,12,eax
			.endif
			invoke GetWindowLong,hWin,8
			mov		nLine,eax
			invoke TestScroll,hWin
			.if eax!=nLine
				call	Scroll
			.endif
		.endif
		invoke SetCaret,hWin
	.elseif eax==WM_VSCROLL
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_VERT,addr sinf
		invoke GetWindowLong,hWin,8
		mov		nLine,eax
		mov		edx,wParam
		movzx	edx,dx
		.if edx==SB_THUMBTRACK || edx==SB_THUMBPOSITION
			mov		eax,sinf.nTrackPos
		.elseif edx==SB_LINEDOWN
			inc		eax
		.elseif edx==SB_LINEUP
			.if eax
				dec		eax
			.endif
		.elseif edx==SB_PAGEDOWN
			add		eax,sinf.nPage
		.elseif edx==SB_PAGEUP
			sub		eax,sinf.nPage
			jnb		@f
			xor		eax,eax
		  @@:
		.elseif edx==SB_BOTTOM
			mov		eax,sinf.nMax
		.elseif edx==SB_TOP
			xor		eax,eax
		.endif
		call	Scroll
	.elseif eax==WM_MOUSEWHEEL
		invoke GetWindowLong,hWin,8
		mov		nLine,eax
		.if sdword ptr wParam>0
			sub		eax,3
			jnb		@f
			xor		eax,eax
		  @@:
		.else
			add		eax,3
		.endif
		call	Scroll
	.elseif eax==WM_LBUTTONDOWN
		invoke SetFocus,hWin
	.elseif eax==WM_CREATE
		xor		eax,eax
		mov		nBytes,eax
		mov		nLine,eax
		call	SetScroll
	.elseif eax==WM_SETFOCUS
		xor		eax,eax
		mov		nBytes,eax
		mov		nLine,eax
		call	SetScroll
		invoke SetCaret,hWin
	.elseif eax==WM_KILLFOCUS
		invoke HideCaret,hWin
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,0
		invoke GlobalUnlock,eax
		invoke GlobalFree,eax
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
	ret

Scroll:
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_POS
	mov		sinf.nPos,eax
	invoke SetScrollInfo,hWin,SB_VERT,addr sinf,FALSE
	invoke GetScrollInfo,hWin,SB_VERT,addr sinf
	mov		eax,sinf.nPos
	.if eax!=nLine
		push	eax
		invoke SetWindowLong,hWin,8,eax
		pop		eax
		sub		eax,nLine
		neg		eax
		mov		ecx,fntht
		mul		ecx
		invoke ScrollWindow,hWin,0,eax,NULL,NULL
	.endif
	retn

SetScroll:
	mov		sinf.cbSize,sizeof sinf
	mov		sinf.fMask,SIF_ALL
	mov		sinf.nMin,0
	mov		eax,nBytes
	add		eax,15
	shr		eax,4
	mov		ecx,fntht
	mul		ecx
	xor		edx,edx
	.if eax<rect.bottom
		mov		eax,rect.bottom
	.endif
	div		ecx
	dec		eax
	mov		sinf.nMax,eax
	mov		eax,rect.bottom
	xor		edx,edx
	div		ecx
	mov		sinf.nPage,eax
	mov		eax,nLine
	mov		sinf.nPos,eax
	invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
	retn

HexCldProc endp

CreateMdi proc lpFile:DWORD

	mov		edx,lpData
	mov		eax,[edx].ADDINDATA.fEditMax
	or		eax,[edx].ADDINDATA.fMaximized
	.IF eax
		mov		eax,MDIS_ALLCHILDSTYLES or WS_MAXIMIZE
	.ELSE
		mov		eax,MDIS_ALLCHILDSTYLES
	.ENDIF
	mov		edx,lpHandles
	invoke CreateWindowEx,WS_EX_MDICHILD or WS_EX_CLIENTEDGE,addr szMdiChild,lpFile,eax,
		   CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,[edx].ADDINHANDLES.hClient,NULL,
		   hRAInstance,NULL
	push	eax
	push	lpFile
	push	eax
	mov		eax,lpProc
	call	[eax].ADDINPROCS.lpAddTab
	pop		eax
	invoke GetDlgItem,eax,1000
	ret

CreateMdi endp

OpenFileAsHex proc
	LOCAL	ofn:OPENFILENAME
	LOCAL	FileName[MAX_PATH]:BYTE
	LOCAL	hHex:HWND
	LOCAL	hFile:DWORD
	LOCAL	nSize:DWORD
	LOCAL	hMem:DWORD

	invoke RtlZeroMemory,addr ofn,sizeof ofn
	mov		ofn.lStructSize,sizeof ofn
	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hWnd
	mov		ofn.hwndOwner,eax
	m2m		ofn.hInstance,hRAInstance
	mov		ofn.lpstrFilter,offset szALLFilterString
	lea		eax,FileName
	mov		ofn.lpstrFile,eax
	mov		byte ptr [FileName],0
	mov		ofn.nMaxFile,sizeof FileName
	mov		ofn.lpstrTitle,offset szOpenAsHex
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	invoke GetOpenFileName,addr ofn
	.if eax!=0
		invoke CreateMdi,addr FileName
		mov		hHex,eax
		invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke GetFileSize,hFile,NULL
			mov		nSize,eax
			inc		eax
			invoke GlobalAlloc,GMEM_MOVEABLE,nSize
			mov		hMem,eax
			invoke GlobalLock,hMem
			mov		edx,eax
			invoke ReadFile,hFile,edx,nSize,addr nSize,NULL
			invoke CloseHandle,hFile
			invoke GlobalUnlock,hMem
			invoke SetWindowLong,hHex,0,hMem
			invoke SetWindowLong,hHex,4,nSize
			invoke SetWindowLong,hHex,8,0
			invoke SetWindowLong,hHex,12,0
		.endif
	.endif
	ret

OpenFileAsHex endp

CreateClass proc
	LOCAL	wc:WNDCLASSEX

	;Mdi Child
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset MdiCldProc
	mov		wc.cbClsExtra,NULL
	;GWL_USERDATA=hEdit,GWL_ID>=ID_FIRSTCHILD
	;0=ID_EDIT or ID_EDITTXT, 4=, 8=, 12=
	;16=Project file ID, 20=OverWrite
	mov		wc.cbWndExtra,24
	m2m		wc.hInstance,hRAInstance
	mov		wc.hbrBackground,NULL;COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szMdiChild
	m2m		wc.hIcon,NULL
	m2m		wc.hCursor,NULL
	m2m		wc.hIconSm,NULL
	invoke RegisterClassEx,addr wc
	;Hex Child
	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset HexCldProc
	mov		wc.cbClsExtra,NULL
	;0=hMem, 4=nBytes, 8=nTopLine, 12=cp
	mov		wc.cbWndExtra,16
	m2m		wc.hInstance,hRAInstance
	mov		wc.hbrBackground,NULL
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szHexChild
	m2m		wc.hIcon,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	m2m		wc.hIconSm,NULL
	invoke RegisterClassEx,addr wc
	ret

CreateClass endp

AddMenu proc
	LOCAL	nMnu:DWORD
	LOCAL	hMnu:DWORD
	LOCAL	mnui:MENUITEMINFO

	mov		nMnu,0
	;Adjust topmost popup if maximized
	mov		eax,[lpData]
	.if [eax].ADDINDATA.fMaximized
		inc		nMnu
	.endif
	;Get handle of File popup
	mov		eax,[lpHandles]
	invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,nMnu
	mov		hMnu,eax
	;Add our menuitem
	mov		mnui.cbSize,sizeof MENUITEMINFO
	mov		mnui.fMask,MIIM_ID or MIIM_TYPE
	mov		mnui.fType,MFT_STRING
	m2m		mnui.wID,IDAddIn
	mov		mnui.dwTypeData,offset szMenuItem
	invoke InsertMenuItem,hMnu,40006,FALSE,addr mnui
	ret

AddMenu endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx hWin:DWORD,fOpt:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax
	mov		eax,[eax].ADDINHANDLES.hInst
	mov		hRAInstance,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	; If Option (fOpt) = 0 then exit
	mov		eax,fOpt
	test	eax,eax
	je		@F
		; Allocate a new menu id
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDAddIn,eax
		invoke CreateClass
		invoke AddMenu
		invoke CreateFontIndirect,offset lfnt
		mov		hFont,eax
		invoke CreatePen,PS_SOLID,1,808080h
		mov		hPen,eax
		invoke GetStockObject,LTGRAY_BRUSH
		mov		hBrBar,eax
		invoke GetStockObject,WHITE_BRUSH
		mov		hBrBack,eax
		; Messages to hook into
		mov		eax,RAM_COMMAND or RAM_CLOSE
  @@:
	; ECX and EDX must be null before we return
	xor		ecx,ecx
	xor		edx,edx
	ret 

InstallDll Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov		eax,uMsg
	.IF eax==AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.IF edx==IDAddIn && eax==BN_CLICKED
			; Your addin has been selected
			invoke OpenFileAsHex
			xor		eax,eax
			inc		eax
			ret
		.ENDIF
	.ELSEIF eax==AIM_CLOSE
		;Delete font
		invoke DeleteObject,hFont
		;Delete pen
		invoke DeleteObject,hPen
	.ENDIF
	xor		eax,eax
	ret

DllProc Endp

;#########################################################################

End DllEntry
