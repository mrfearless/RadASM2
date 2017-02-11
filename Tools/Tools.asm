; ######################################################################

	ToolWndProc			PROTO :DWORD,:DWORD,:DWORD,:DWORD
	ToolCldWndProc		PROTO :DWORD,:DWORD,:DWORD,:DWORD
	ToolMessage			PROTO :DWORD,:DWORD,:DWORD
	ToolMsgAll			PROTO :DWORD,:DWORD,:DWORD
	ToolMsg				PROTO :DWORD,:DWORD,:DWORD
	ToolHitTest			PROTO :DWORD,:DWORD

.const

	;Message to Mdi
	WM_TOOLDBLCLICK	equ	WM_USER+1
	WM_TOOLSIZE		equ	WM_USER+2
	WM_TOOLCLICK	equ	WM_USER+3
	WM_TOOLRCLICK	equ	WM_USER+4

	;Tool messages
	TLM_INIT		equ	1
	TLM_CREATE		equ	2

	TLM_DOCKING		equ	4
	TLM_HIDE		equ	5
	TLM_MOUSEMOVE	equ	6
	TLM_LBUTTONDOWN	equ	7
	TLM_LBUTTONUP	equ	8
	TLM_PAINT		equ	9
	TLM_SIZE		equ	10
	TLM_REDRAW		equ	11
	TLM_CAPTION		equ	12
	TLM_ADJUSTRECT	equ	13
	TLM_GET_VISIBLE	equ	14
	TLM_GET_STRUCT	equ	15

	TLM_SETTBR		equ	17
	TLM_GET_DOCKED	equ	18
	TLM_MOVETEST	equ	19

	;Docking positions
	TL_LEFT			equ	1
	TL_TOP			equ	2
	TL_RIGHT		equ	3
	TL_BOTTOM		equ	4

	;Tool cursor flags
	TL_ONRESIZE		equ	1
	TL_ONCAPTION	equ	2
	TL_ONCLOSE		equ	3

	;Caption & resize bar size
	TOTCAPHT		equ	14
	CAPHT			equ	12
	RESIZEBAR		equ	2
	BUTTONT			equ	1
	BUTTONR			equ	1
	BUTTONHT		equ	10
	BUTTONWT		equ	10

	DOCKING struct
	  ID				dd ?
	  Caption			dd ?
	  Visible			dd ?
	  Docked			dd ?
	  Position			dd ?
	  IsChild			dd ?
	  DockWidth			dd ?
	  DockHeight		dd ?
	  FloatRect			RECT <>
	DOCKING ends

	TOOL struct
	  ID				dd ?
	  Caption			dd ?
	  Visible			dd ?
	  Docked			dd ?
	  Position			dd ?
	  IsChild			dd ?
	  dWidth			dd ?
	  dHeight			dd ?	;+28
	  fr				RECT <> ;Floating
	  dr				RECT <> ;Docked
	  wr				RECT <> ;Child window
	  rr				RECT <> ;Resize
	  tr				RECT <> ;Top
	  cr				RECT <> ;Caption
	  br				RECT <> ;Close button
	  dFocus			dd ?
	  dCurFlag			dd ?
	  hWin				dd ?
	  hCld				dd ?
	  lpfnOldCldWndProc	dd ?
	TOOL ends

.data

	szToolClass			db "ToolClass",0
	szToolCldClass		db "ToolCldClass",0

; ######################################################################

.data?

	ToolResize          dd ?
	ToolMove            dd ?
	MoveRect            RECT <?>
	DrawRect            RECT <?>
	ClientRect          RECT <?>
	FloatRect			RECT <?>
	MovePt              POINT <?>
	MoveCur             dd ?
	hRect				dd MAXMULSEL*4 dup(?)

	;The order in ToolPool decides the clipping
	;Max 10 tools
	ToolPtr				dd ?
	ToolPool			dd 4*10 dup(?)				;hCld, ptr TOOL data struct
	ToolData			db sizeof TOOL * 10 dup(?)	;TOOL data structs

; ######################################################################

.code

Do_ToolFloat proc lpTool:DWORD
	LOCAL   tW:DWORD
	LOCAL   tH:DWORD

	assume edx:ptr TOOL
	mov     edx,lpTool
	mov     eax,[edx].fr.right
	sub     eax,[edx].fr.left
	mov     tW,eax
	mov     eax,[edx].fr.bottom
	sub     eax,[edx].fr.top
	mov     tH,eax
	invoke CreateWindowEx,WS_EX_TOOLWINDOW,addr szToolClass,[edx].Caption,
			WS_CAPTION or WS_SIZEBOX or WS_SYSMENU or WS_POPUP or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,
			[edx].fr.left,[edx].fr.top,tW,tH,hWnd,0,hInstance,edx
	mov     edx,lpTool
	mov     [edx].hWin,eax
	assume edx:nothing
	ret

Do_ToolFloat endp

ToolDrawRect proc uses esi edi,lpRect:DWORD,nFun:DWORD,nInx:DWORD
	LOCAL	ht:DWORD
	LOCAL	wt:DWORD
	LOCAL	rect:RECT

	invoke CopyRect,addr rect,lpRect
	lea		esi,rect
	assume esi:ptr RECT
	sub		[esi].right,1
	mov		eax,[esi].right
	sub		eax,[esi].left
	jns		@f
	mov		eax,[esi].right
	xchg	eax,[esi].left
	mov		[esi].right,eax
	sub		eax,[esi].left
	dec		[esi].left
	inc		[esi].right
	inc		eax
  @@:
	mov		wt,eax
	sub		[esi].bottom,1
	mov		eax,[esi].bottom
	sub		eax,[esi].top
	jns		@f
	mov		eax,[esi].bottom
	xchg	eax,[esi].top
	mov		[esi].bottom,eax
	sub		eax,[esi].top
	dec		[esi].top
	inc		[esi].bottom
	inc		eax
  @@:
	mov		ht,eax
	dec		[esi].right
	dec		[esi].bottom
	mov		edi,nInx
	shl		edi,4
	add		edi,offset hRect
	.if nFun==0
		invoke CreateWindowEx,0,addr szStatic,0,WS_POPUP or SS_BLACKRECT,[esi].left,[esi].top,wt,2,hWnd,0,hInstance,0
		mov		[edi],eax
		invoke ShowWindow,eax,SW_SHOWNOACTIVATE
		invoke CreateWindowEx,0,addr szStatic,0,WS_POPUP or SS_BLACKRECT,[esi].right,[esi].top,2,ht,hWnd,0,hInstance,0
		mov		[edi+4],eax
		invoke ShowWindow,eax,SW_SHOWNOACTIVATE
		invoke CreateWindowEx,0,addr szStatic,0,WS_POPUP or SS_BLACKRECT,[esi].left,[esi].bottom,wt,2,hWnd,0,hInstance,0
		mov		[edi+8],eax
		invoke ShowWindow,eax,SW_SHOWNOACTIVATE
		invoke CreateWindowEx,0,addr szStatic,0,WS_POPUP or SS_BLACKRECT,[esi].left,[esi].top,2,ht,hWnd,0,hInstance,0
		mov		[edi+12],eax
		invoke ShowWindow,eax,SW_SHOWNOACTIVATE
	.elseif nFun==1
		invoke MoveWindow,[edi],[esi].left,[esi].top,wt,3,TRUE
		invoke MoveWindow,[edi+4],[esi].right,[esi].top,3,ht,TRUE
		invoke MoveWindow,[edi+8],[esi].left,[esi].bottom,wt,3,TRUE
		invoke MoveWindow,[edi+12],[esi].left,[esi].top,3,ht,TRUE
	.elseif nFun==2
		invoke DestroyWindow,[edi]
		mov		dword ptr [edi],0
		invoke DestroyWindow,[edi+4]
		mov		dword ptr [edi+4],0
		invoke DestroyWindow,[edi+8]
		mov		dword ptr [edi+8],0
		invoke DestroyWindow,[edi+12]
		mov		dword ptr [edi+12],0
	.endif
	assume esi:nothing
	ret

ToolDrawRect endp

Rotate proc uses esi edi,hBmpDest:DWORD,hBmpSrc:DWORD,x:DWORD,y:DWORD,nRotate:DWORD
	LOCAL	bmd:BITMAP
	LOCAL	nbitsd:DWORD
	LOCAL	hmemd:DWORD
	LOCAL	bms:BITMAP
	LOCAL	nbitss:DWORD
	LOCAL	hmems:DWORD

	;Get info on destination bitmap
	invoke GetObject,hBmpDest,sizeof BITMAP,addr bmd
	mov		eax,bmd.bmWidthBytes
	mov		edx,bmd.bmHeight
	mul		edx
	mov		nbitsd,eax
	;Allocate memory for destination bitmap bits
	invoke xGlobalAlloc,GMEM_FIXED,nbitsd
	mov		hmemd,eax
	;Get the destination bitmap bits
	invoke GetBitmapBits,hBmpDest,nbitsd,hmemd
	;Get info on source bitmap
	invoke GetObject,hBmpSrc,sizeof BITMAP,addr bms
	mov		eax,bms.bmWidthBytes
	mov		edx,bms.bmHeight
	mul		edx
	mov		nbitss,eax
	;Allocate memory for source bitmap bits
	invoke xGlobalAlloc,GMEM_FIXED,nbitss
	mov		hmems,eax
	;Get the source bitmap bits
	invoke GetBitmapBits,hBmpSrc,nbitss,hmems
	;Copy the pixels one by one
	xor		edx,edx
	.while edx<bms.bmHeight
		xor		ecx,ecx
		.while ecx<bms.bmWidth
			call	CopyPix
			inc		ecx
		.endw
		inc		edx
	.endw
	;Copy back the destination bitmap bits
	invoke SetBitmapBits,hBmpDest,nbitsd,hmemd
	;Free allocated memory
	invoke GlobalFree,hmems
	invoke GlobalFree,hmemd
	ret

CopyPix:
	push	ecx
	push	edx
	mov		esi,hmems
	push	edx
	mov		eax,bms.bmWidthBytes
	mul		edx
	add		esi,eax
	movzx	eax,bms.bmBitsPixel
	shr		eax,3
	mul		ecx
	add		esi,eax
	pop		edx
	mov		eax,nRotate
	.if eax==1
		;Rotate 90 degrees
		sub		edx,bms.bmHeight
		neg		edx
		xchg	ecx,edx
	.elseif eax==2
		;Rotate 180 degrees
		sub		edx,bms.bmHeight
		neg		edx
		sub		ecx,bms.bmWidth
		neg		ecx
	.elseif eax==3
		;Rotate 270 degrees
		sub		ecx,bms.bmWidth
		neg		ecx
		xchg	ecx,edx
	.endif
	;Add the destination offsets
	add		ecx,x
	add		edx,y
	.if  ecx<bmd.bmWidth && edx<bmd.bmHeight
		;Calculate destination adress
		mov		edi,hmemd
		mov		eax,bmd.bmWidthBytes
		mul		edx
		add		edi,eax
		movzx	eax,bmd.bmBitsPixel
		shr		eax,3
		xchg	eax,ecx
		mul		ecx
		add		edi,eax
		;And copy the byte(s)
		rep movsb
	.endif
	pop		edx
	pop		ecx
	retn

Rotate endp

GetToolPtr proc

	mov     edx,offset ToolPool-16
  @@:
	add     edx,16
	cmp     dword ptr [edx],0
	jz      @f
	cmp     eax,dword ptr [edx]
	jnz     @b
	mov     edx,dword ptr [edx+4]
	ret
  @@:
	xor     edx,edx
	ret

GetToolPtr endp

ToolMessage proc hWin:HWND,uMsg:UINT,lParam:LPARAM
	LOCAl   pt:POINT
	LOCAL   rect:RECT
	LOCAL   clW:DWORD
	LOCAL   clH:DWORD
	LOCAL	tls[8]:TOOL

	mov		eax,uMsg
	.if eax==TLM_INIT
		mov     ToolPtr,0
	.elseif eax==TLM_SIZE
		invoke ToolMsgAll,TLM_ADJUSTRECT,lParam,1
		invoke ToolMsgAll,TLM_ADJUSTRECT,lParam,2
		invoke CopyRect,addr ClientRect,lParam
		mov     edx,lParam
		assume edx:ptr RECT
		mov     eax,[edx].right
		sub     eax,[edx].left
		mov     clW,eax
		mov     eax,[edx].bottom
		sub     eax,[edx].top
		mov     clH,eax
		invoke MoveWindow,hClient,[edx].left,[edx].top,clW,clH,TRUE
		assume edx:nothing
		invoke ToolMsgAll,TLM_REDRAW,0,1
		invoke ToolMsgAll,TLM_REDRAW,0,2
	.elseif eax==TLM_PAINT
		invoke ToolMsgAll,TLM_CAPTION,0,0
	.elseif eax==TLM_CREATE
		push    ecx
		push    esi
		push    edi
		mov     esi,offset ToolPool
		mov     eax,ToolPtr
		add     esi,eax
		add     ToolPtr,16
		shr     eax,4
		mov     ecx,sizeof TOOL
		mul     ecx
		mov     edi,offset ToolData
		add     edi,eax
		push    edi
		mov     eax,hWin
		mov     dword ptr [esi],eax
		mov     dword ptr [esi+4],edi
		mov     esi,lParam
		mov     ecx,sizeof DOCKING
		cld
		rep movsb
		mov     ecx,sizeof TOOL - sizeof DOCKING
		xor     al,al
		rep stosb
		pop     edx
		push    edx
		invoke Do_ToolFloat,edx
		pop     edx
		push    eax
		assume edx:ptr TOOL
		mov     [edx].hWin,eax
		m2m     [edx].hCld,hWin
		push    edx
		invoke SetWindowLong,[edx].hCld,GWL_WNDPROC,addr ToolCldWndProc
		pop     edx
		mov     [edx].lpfnOldCldWndProc,eax
		invoke ToolMsg,[edx].hCld,TLM_SETTBR,0
		pop     eax
		pop     edi
		pop     esi
		pop     ecx
	.elseif eax==TLM_MOUSEMOVE
		mov     eax,lParam
		and     eax,0FFFFh
		cwde
		mov     pt.x,eax
		mov     eax,lParam
		shr     eax,16
		cwde
		mov     pt.y,eax
		.if ToolResize
			invoke CopyRect,addr DrawRect,addr MoveRect
			mov     eax,pt.x
			cwde
			.if eax<0
				mov     pt.x,0
			.endif
			mov     eax,pt.y
			cwde
			.if eax<0
				mov     pt.y,0
			.endif
			mov     eax,ToolResize
			call GetToolPtr
			assume edx:ptr TOOL
			mov     eax,[edx].Position
			.if eax==TL_LEFT
				mov     eax,ClientRect.right
				sub     eax,RESIZEBAR
				.if eax<pt.x
					mov     pt.x,eax
				.endif
				mov     eax,[edx].dr.left
				add     eax,RESIZEBAR+2
				.if eax>pt.x
					mov     pt.x,eax
				.endif
				mov     eax,pt.x
				sub     eax,MovePt.x
				add     DrawRect.right,eax
				mov		eax,DrawRect.bottom
				sub		eax,DrawRect.top
				invoke MoveWindow,hTlt,DrawRect.right,DrawRect.top,2,eax,TRUE
			.elseif eax==TL_TOP
				mov     eax,ClientRect.bottom
				sub     eax,RESIZEBAR+1
				.if eax<pt.y
					mov     pt.y,eax
				.endif
				mov     eax,[edx].dr.top
				add     eax,TOTCAPHT+RESIZEBAR+2
				.if eax>pt.y
					mov     pt.y,eax
				.endif
				mov     eax,pt.y
				sub     eax,MovePt.y
				add     DrawRect.bottom,eax
				mov		eax,DrawRect.right
				sub		eax,DrawRect.left
				invoke MoveWindow,hTlt,DrawRect.left,DrawRect.bottom,eax,2,TRUE
			.elseif eax==TL_RIGHT
				mov     eax,ClientRect.left
				add     eax,RESIZEBAR
				.if eax>pt.x
					mov     pt.x,eax
				.endif
				mov     eax,[edx].dr.right
				sub     eax,RESIZEBAR+2
				.if eax<pt.x
					mov     pt.x,eax
				.endif
				mov     eax,pt.x
				sub     eax,MovePt.x
				add     DrawRect.left,eax
				mov		eax,DrawRect.bottom
				sub		eax,DrawRect.top
				invoke MoveWindow,hTlt,DrawRect.left,DrawRect.top,2,eax,TRUE
			.elseif eax==TL_BOTTOM
				mov     eax,ClientRect.top
				add     eax,RESIZEBAR+1
				.if eax>pt.y
					mov     pt.y,eax
				.endif
				mov     eax,[edx].dr.bottom
				sub     eax,TOTCAPHT+RESIZEBAR+2
				.if eax<pt.y
					mov     pt.y,eax
				.endif
				mov     eax,pt.y
				sub     eax,MovePt.y
				add     DrawRect.top,eax
				mov		eax,DrawRect.right
				sub		eax,DrawRect.left
				invoke MoveWindow,hTlt,DrawRect.left,DrawRect.top,eax,2,TRUE
			.endif
			invoke ShowWindow,hTlt,SW_SHOWNOACTIVATE
			assume edx:nothing
		.elseif ToolMove
			push	esi
			push	edi
			lea		edi,tls
			mov		esi,offset ToolData
			mov		ecx,sizeof tls
			rep movsb
			pop		edi
			pop		esi

			invoke CopyRect,addr DrawRect,addr MoveRect
			mov     eax,pt.x
			sub     eax,MovePt.x
			add     DrawRect.left,eax
			add     DrawRect.right,eax
			mov     eax,pt.y
			sub     eax,MovePt.y
			add     DrawRect.top,eax
			add     DrawRect.bottom,eax

			invoke ToolMsg,ToolMove,TLM_MOVETEST,addr pt
			invoke CopyRect,addr rect,offset mdirect
			invoke ToolMsgAll,TLM_ADJUSTRECT,addr rect,1
			invoke ToolMsgAll,TLM_ADJUSTRECT,addr rect,2
			mov		eax,ToolMove
			invoke GetToolPtr
			.if [edx].TOOL.Docked
				invoke CopyRect,addr rect,addr [edx].TOOL.dr
				invoke ClientToScreen,hWnd,addr rect
				invoke ClientToScreen,hWnd,addr rect.right
			.else
				invoke CopyRect,addr rect,addr [edx].TOOL.fr
				invoke ClientToScreen,hWnd,addr pt
				mov		edx,rect.right
				sub		edx,rect.left
				mov		eax,pt.x
				mov		rect.left,eax
				add		eax,edx
				mov		rect.right,eax
				shr		edx,1
				sub		rect.left,edx
				sub		rect.right,edx
				mov		edx,rect.bottom
				sub		edx,rect.top
				mov		eax,pt.y
				sub		eax,10
				mov		rect.top,eax
				add		eax,edx
				mov		rect.bottom,eax
				invoke CopyRect,offset FloatRect,addr rect
			.endif
			push	esi
			push	edi
			lea		esi,tls
			mov		edi,offset ToolData
			mov		ecx,sizeof tls
			rep movsb
			pop		edi
			pop		esi
			invoke ToolDrawRect,addr rect,1,0
		.else
			invoke ToolMsgAll,uMsg,addr pt,0
		.endif
	.elseif eax==TLM_LBUTTONDOWN
		mov     eax,lParam
		and     eax,0FFFFh
		mov     MovePt.x,eax
		mov     eax,lParam
		shr     eax,16
		mov     MovePt.y,eax
		invoke ToolMsgAll,uMsg,addr pt,0
	.elseif eax==TLM_LBUTTONUP
		mov     eax,lParam
		and     eax,0FFFFh
		mov     pt.x,eax
		mov     eax,lParam
		shr     eax,16
		mov     pt.y,eax
		.if ToolResize
			invoke ToolMsg,ToolResize,uMsg,addr pt
			mov     ToolResize,0
		.elseif ToolMove
			invoke ToolMsg,ToolMove,uMsg,addr pt
			mov     ToolMove,0
		.endif
		invoke InvalidateRect,hClient,NULL,TRUE
	.elseif eax==TLM_HIDE
		invoke ToolMsg,hWin,uMsg,lParam
		mov		eax,hWin
		invoke GetToolPtr
		invoke ToolMsgAll,uMsg,edx,3
	.else
		invoke ToolMsg,hWin,uMsg,lParam
	.endif
	ret

ToolMessage endp

ToolMsgAll proc uses ecx esi,uMsg:UINT,lParam:LPARAM,fTpe:DWORD

	mov     ecx,8
	mov     esi,offset ToolPool
  Nxt:
	mov     eax,dword ptr [esi]
	or      eax,eax
	je		Ex
	push    ecx
	mov		edx,[esi+4]
	assume edx:ptr TOOL
	mov		eax,[edx].IsChild
	.if fTpe==0
		invoke ToolMsg,[esi],uMsg,lParam
	.elseif fTpe==1 && !eax
		invoke ToolMsg,[esi],uMsg,lParam
	.elseif fTpe==2 && eax
		invoke ToolMsg,[esi],uMsg,lParam
	.elseif fTpe==3
		mov		ecx,lParam
		.if [edx].Docked && [ecx].TOOL.Docked && eax==[ecx].TOOL.ID
			mov		eax,[edx].Visible
			.if eax!=[ecx].TOOL.Visible
				invoke ToolMsg,[esi],uMsg,lParam
			.endif
		.endif
	.endif
	assume eax:nothing
	pop     ecx
	add     esi,4*4
	dec		ecx
	jne		Nxt
  Ex:
	ret

ToolMsgAll endp

GetToolPtrID proc

	push	edx
	mov     edx,offset ToolPool-16
  @@:
	add     edx,16
	cmp     dword ptr [edx],0
	je      @f
	push	edx
	mov     edx,dword ptr [edx+4]
	assume edx:ptr TOOL
	cmp     eax,[edx].ID
	assume edx:nothing
	pop		edx
	jne     @b
	mov     eax,dword ptr [edx+4]
	pop		edx
	ret
  @@:
	xor     eax,eax
	pop		edx
	ret

GetToolPtrID endp

IsOnTool proc lpPt:DWORD

	push	ebx
	push	ecx
	push	edx
	mov		ebx,lpPt
	assume ebx:ptr POINT
	mov		edx,offset ToolData
	assume edx:ptr TOOL
  @@:
	mov		eax,[edx].ID
	.if eax
		mov		eax,[edx].Visible
		and		eax,[edx].Docked
		.if eax
			mov		eax,[edx].IsChild
			.if !eax
				mov		eax,[ebx].x
				.if eax>[edx].dr.left && eax<[edx].dr.right
					mov		eax,[ebx].y
					.if eax>[edx].dr.top && eax<[edx].dr.bottom
						mov		eax,[edx].ID
						jmp		@f
					.endif
				.endif
			.endif
		.endif
		add		edx,sizeof TOOL
		jmp		@b
	.endif
  @@:
	assume edx:nothing
	assume ebx:nothing
	pop		edx
	pop		ecx
	pop		ebx
	ret

IsOnTool endp

SetIsChildTo proc nID:DWORD,nToID:DWORD

	push	edx
	mov		edx,offset ToolData
	assume edx:ptr TOOL
  @@:
	mov		eax,[edx].ID
	.if eax
		mov		eax,[edx].IsChild
		.if eax==nID
			m2m		[edx].IsChild,nToID
		.endif
		add		edx,sizeof TOOL
		jmp		@b
	.endif
	assume edx:nothing
	pop		edx
	ret

SetIsChildTo endp

ToolMsg proc uses ebx esi,hCld:DWORD,uMsg:UINT,lpRect:DWORD
	LOCAL   rect:RECT
	LOCAL   dWidth:DWORD
	LOCAL   dHeight:DWORD
	LOCAL   hWin:HWND
	LOCAL   hDC:HDC
	LOCAL   hCur:DWORD
	LOCAL   parPosition:DWORD
	LOCAL	pardWidth:DWORD
	LOCAL	pardHeight:DWORD
	LOCAL	parDocked:DWORD
	LOCAL	pt:POINT
	LOCAL	rect2:RECT
	LOCAL	sDC:HDC
	LOCAL	hBmp1:DWORD
	LOCAL	hBmp2:DWORD

	mov     eax,hCld
	call    GetToolPtr
	mov		esi,edx
	assume esi:ptr TOOL
	mov     ebx,lpRect
	assume ebx:ptr RECT
	mov		eax,uMsg
	.if eax==TLM_MOUSEMOVE
		mov     [esi].dCurFlag,0
		mov     hCur,0
		.if [esi].Visible && [esi].Docked && !ToolResize
			;Check if mouse is on this tools caption, close button or sizeing boarder and set cursor
			mov     hCur,0
			invoke ToolHitTest,addr [esi].rr,ebx
			.if eax
				;Cursor on resize bar
				mov     [esi].dCurFlag,TL_ONRESIZE
				mov     eax,[esi].Position
				.if eax==TL_TOP || eax==TL_BOTTOM
					m2m     hCur,hSplitCurH;IDC_SIZENS
				.else
					m2m     hCur,hSplitCurV;IDC_SIZEWE
				.endif
			.else
				invoke ToolHitTest,addr [esi].cr,ebx
				.if eax
					;Cursor on caption
					mov     hCur,IDC_HAND
					mov     [esi].dCurFlag,TL_ONCAPTION
					invoke ToolHitTest,addr [esi].br,ebx
					.if eax
						;Cursor on close button
						mov     hCur,IDC_ARROW
						mov     [esi].dCurFlag,TL_ONCLOSE
					.endif
					invoke LoadCursor,0,hCur
					mov		hCur,eax
				.endif
			.endif
			mov     eax,hCur
			.if eax
				mov     MoveCur,eax
				invoke SetCursor,eax
				mov     eax,TRUE
				ret
			.endif
		.endif
	.elseif eax==TLM_MOVETEST
		call ToolMov
	.elseif eax==TLM_SETTBR
		mov		eax,[esi].ID
		.if eax==1
			mov		eax,IDM_VIEW_PROJECTBROWSER
		.elseif eax==2
			mov		eax,IDM_VIEW_OUTPUTWINDOW
		.elseif eax==3
			mov		eax,IDM_VIEW_TOOLBOX
		.elseif eax==4
			mov		eax,IDM_VIEW_PROPERTIES
		.elseif eax==5
			mov		eax,0
		.endif
		.if eax
			invoke SendMessage,hToolBar,TB_CHECKBUTTON,eax,[esi].Visible
		.endif
		mov     eax,TRUE
		ret
	.elseif eax==TLM_LBUTTONDOWN
		.if [esi].dCurFlag
			.if [esi].dCurFlag==TL_ONCLOSE
				mov     [esi].Visible,FALSE
				invoke ToolMsg,hCld,TLM_SETTBR,0
				invoke SendMessage,hWnd,WM_SIZE,0,0
				mov     eax,TRUE
				ret
			.else
				invoke SetFocus,hCld
				mov		pt.x,0
				mov		pt.y,0
				invoke ClientToScreen,hWnd,addr pt
				invoke CopyRect,addr DrawRect,addr [esi].dr
				mov		eax,pt.x
				dec		eax
				add		DrawRect.left,eax
				inc		eax
				inc		eax
				add		DrawRect.right,eax
				mov		eax,pt.y
				add		DrawRect.top,eax
				inc		eax
				add		DrawRect.bottom,eax
				invoke CopyRect,addr MoveRect,addr DrawRect
				invoke SetCursor,MoveCur
				invoke SetCapture,hWnd
				.if [esi].dCurFlag==TL_ONRESIZE
					mov     eax,hCld
					mov     ToolResize,eax
					invoke ShowWindow,hTlt,SW_SHOWNOACTIVATE
					mov     eax,TRUE
					ret
				.elseif [esi].dCurFlag==TL_ONCAPTION
					mov     eax,hCld
					mov     ToolMove,eax
					invoke ToolDrawRect,addr DrawRect,0,0
					mov     eax,TRUE
					ret
				.endif
			.endif
		.endif
	.elseif eax==TLM_LBUTTONUP
		invoke ReleaseCapture
		.if ToolResize
			mov     edx,[esi].Position
			.if edx==TL_BOTTOM || edx==TL_TOP
				mov     eax,DrawRect.bottom
				sub     eax,DrawRect.top
				sub		eax,1
				mov     [esi].dHeight,eax
			.elseif edx==TL_LEFT || edx==TL_RIGHT
				mov     eax,DrawRect.right
				sub     eax,DrawRect.left
				sub		eax,2
				.if edx==TL_RIGHT
					dec		eax
				.endif
				mov     [esi].dWidth,eax
			.endif
			invoke ShowWindow,hTlt,SW_HIDE
		.elseif ToolMove
			invoke ToolDrawRect,addr DrawRect,2,0
			call ToolMov
			.if ![esi].Docked
				mov		eax,FloatRect.right
				sub		eax,FloatRect.left
				mov		edx,FloatRect.bottom
				sub		edx,FloatRect.top
				invoke MoveWindow,[esi].hWin,FloatRect.left,FloatRect.top,eax,edx,TRUE
			.endif
			call TestTab
			assume ebx:ptr RECT
		.endif
		invoke SendMessage,hWnd,WM_SIZE,0,0
		invoke SetFocus,hCld
	.elseif eax==TLM_DOCKING
		;Docked/floating
		xor     [esi].Docked,TRUE
		.if ![esi].Visible
			invoke ToolMsg,hCld,TLM_HIDE,lpRect
		.else
			invoke SendMessage,hWnd,WM_SIZE,0,0
		.endif
		call TestTab
		mov     eax,TRUE
		ret
	.elseif eax==TLM_HIDE
		;Hide/show
		xor     [esi].Visible,TRUE
		invoke ToolMsg,hCld,TLM_SETTBR,0
		invoke SendMessage,hWnd,WM_SIZE,0,0
		invoke InvalidateRect,hClient,NULL,TRUE
		invoke DllProc,hWin,AIM_TOOLSHOW,[esi].Visible,[esi].ID,RAM_TOOLSHOW
		mov     eax,TRUE
		ret
	.elseif eax==TLM_CAPTION
		;Draw the tools caption
		.if [esi].Visible && [esi].Docked
			;Draw caption background
			invoke GetDC,hWnd
			mov     hDC,eax
			invoke GetStockObject,DEFAULT_GUI_FONT
			invoke SelectObject,hDC,eax
			push	eax
			invoke FillRect,hDC,addr [esi].tr,COLOR_BTNFACE+1
			invoke SetBkMode,hDC,TRANSPARENT
			;Draw resizing bar
			invoke FillRect,hDC,addr [esi].rr,COLOR_BTNFACE+1
			;Draw Caption
			.if [esi].dFocus
				invoke SetTextColor,hDC,0FFFFFFh
				mov		eax,COLOR_ACTIVECAPTION+1
			.else
				invoke SetTextColor,hDC,0C0C0C0h
				mov		eax,COLOR_INACTIVECAPTION+1
			.endif
			mov		ebx,eax
			invoke FillRect,hDC,addr [esi].cr,eax
			mov		eax,[esi].IsChild
			xor		ecx,ecx
			.if eax
				invoke GetToolPtrID
				mov		edx,eax
				mov		ecx,[edx].TOOL.Visible
				and		ecx,[edx].TOOL.Docked
			.endif
			mov		eax,[esi].Position
			.if fRightCaption
				.if ((eax==TL_TOP || eax==TL_BOTTOM) && !ecx) || (eax==TL_RIGHT && ecx)
					mov		eax,[esi].Caption
					mov		al,byte ptr [eax]
					.if al
						dec		ebx
						invoke GetSysColor,ebx
						mov		ebx,eax
						;Create a memory DC for the source
						invoke CreateCompatibleDC,hDC
						mov		sDC,eax
						invoke GetTextColor,hDC
						invoke SetTextColor,sDC,eax
						invoke GetStockObject,DEFAULT_GUI_FONT
						invoke SelectObject,sDC,eax
						push	eax
						;Get size of text to draw
						mov		rect2.left,0
						mov		rect2.top,0
						mov		rect2.right,0
						mov		rect2.bottom,0
						invoke DrawText,sDC,[esi].Caption,-1,addr rect2,DT_CALCRECT or DT_SINGLELINE or DT_LEFT or DT_TOP
						;Create a bitmap for the rotated text
						invoke CreateCompatibleBitmap,hDC,rect2.bottom,rect2.right
						mov		hBmp1,eax
						;Create a bitmap for the text
						invoke CreateCompatibleBitmap,hDC,rect2.right,rect2.bottom
						mov		hBmp2,eax
						;and select it into source DC
						invoke SelectObject,sDC,hBmp2
						push	eax
						invoke SetBkColor,sDC,ebx
						;Draw the text
						invoke DrawText,sDC,[esi].Caption,-1,addr rect2,DT_SINGLELINE or DT_LEFT or DT_TOP
						;Rotate the bitmap
						invoke Rotate,hBmp1,hBmp2,0,0,1
						pop		eax
						invoke SelectObject,sDC,eax
						;Delete created source bitmap
						invoke DeleteObject,eax
						invoke SelectObject,sDC,hBmp1
						push	eax
						;Blit the destination bitmap onto window bitmap
						mov		eax,[esi].cr.top
						inc		eax
						mov		edx,[esi].cr.left
						dec		edx
						invoke BitBlt,hDC,edx,eax,rect2.bottom,rect2.right,sDC,0,0,SRCCOPY
						pop		eax
						invoke SelectObject,sDC,eax
						;Delete created source bitmap
						invoke DeleteObject,eax
						pop		eax
						invoke SelectObject,sDC,eax
						invoke DeleteDC,sDC
					.endif
				.else
					dec		[esi].cr.top
					inc		[esi].cr.left
					invoke DrawText,hDC,[esi].Caption,-1,addr [esi].cr,0
					inc		[esi].cr.top
					dec		[esi].cr.left
				.endif
			.else
				dec		[esi].cr.top
				inc		[esi].cr.left
				invoke DrawText,hDC,[esi].Caption,-1,addr [esi].cr,0
				inc		[esi].cr.top
				dec		[esi].cr.left
			.endif
			;Draw close button
			invoke DrawFrameControl,hDC,addr [esi].br,DFC_CAPTION,DFCS_CAPTIONCLOSE
			invoke ReleaseDC,hWnd,hDC
			pop		eax
			invoke SelectObject,hDC,eax
		.endif
	.elseif eax==TLM_REDRAW
		;Hide/Show floating/docked window
		.if [esi].Visible
			.if [esi].Docked
				;Hide the floating form
				invoke ShowWindow,[esi].hWin,SW_HIDE
				;Make the mdi frame the parent
				invoke SetParent,[esi].hCld,hWnd
				mov     eax,[esi].wr.right
				sub     eax,[esi].wr.left
				mov     dWidth,eax
				mov     eax,[esi].wr.bottom
				sub     eax,[esi].wr.top
				mov     dHeight,eax
				invoke MoveWindow,[esi].hCld,[esi].wr.left,[esi].wr.top,dWidth,dHeight,TRUE
				invoke ShowWindow,[esi].hCld,SW_SHOWNOACTIVATE
			.else
				;Show the floating window
				invoke SetParent,[esi].hCld,[esi].hWin
				invoke GetClientRect,[esi].hWin,addr rect
				invoke MoveWindow,[esi].hCld,rect.left,rect.top,rect.right,rect.bottom,FALSE
				invoke ShowWindow,[esi].hWin,SW_SHOWNOACTIVATE
				invoke ShowWindow,[esi].hCld,SW_SHOWNOACTIVATE
			.endif
		.else
			.if [esi].Docked
				;Hide the floating form
				invoke ShowWindow,[esi].hWin,SW_HIDE
				;Hide docked window
				invoke ShowWindow,[esi].hCld,SW_HIDE
			.else
				;Hide the floating window
				invoke ShowWindow,[esi].hCld,SW_HIDE
				invoke ShowWindow,[esi].hWin,SW_HIDE
			.endif
		.endif
	.elseif eax==TLM_ADJUSTRECT
		.if [esi].Visible && [esi].Docked
			mov		parPosition,-1
			mov		parDocked,0
			mov		eax,[esi].IsChild
			.if eax
				m2m		dWidth,[esi].dWidth
				push	esi
				;Get parent from ID
				mov		eax,[esi].IsChild
				invoke GetToolPtrID
				mov		esi,eax
				m2m		parPosition,[esi].Position
				m2m		pardWidth,[esi].dWidth
				m2m		pardHeight,[esi].dHeight
				;Is parent visible & docked
				mov		eax,[esi].Visible
				and		eax,[esi].Docked
				mov		parDocked,eax
				.if eax
					.if parPosition==TL_LEFT || parPosition==TL_RIGHT
						;Resize the tool's client rect instead
						lea		eax,[esi].wr
						mov		lpRect,eax
						pop		eax
						push	eax
						mov		(TOOL ptr [eax]).Position,TL_BOTTOM
					.else
						;Resize the tool's client, top, caption & button rect instead
						lea		eax,[esi].wr
						mov		lpRect,eax
						mov		eax,dWidth
						.if fRightCaption
							add		[esi].wr.right,TOTCAPHT-1
							inc		eax
							sub		[esi].cr.left,eax
							sub		[esi].tr.left,eax
							sub		[esi].cr.right,eax
							sub		[esi].tr.right,eax
							sub		[esi].br.left,eax
							sub		[esi].br.right,eax
						.else
							sub		[esi].tr.right,eax
							sub		[esi].cr.right,eax
							sub		[esi].br.left,eax
							sub		[esi].br.right,eax
						.endif
						pop		eax
						push	eax
						mov		(TOOL ptr [eax]).Position,TL_RIGHT
					.endif
				.else
					pop		esi
					push	esi
					m2m		[esi].Position,parPosition
					.if parPosition==TL_LEFT || parPosition==TL_RIGHT
						m2m		[esi].dWidth,pardWidth
					.else
						m2m		[esi].dHeight,pardHeight
					.endif
				.endif
				pop		esi
			.endif
			;Resize mdi client & calculate all the tools RECT's
			mov     ebx,lpRect
			invoke CopyRect,addr [esi].dr,ebx
			mov     eax,[esi].Position
			.if eax==TL_LEFT
				mov     eax,[esi].dWidth
				add     [ebx].left,eax
				add		eax,[esi].dr.left
				mov		[esi].dr.right,eax
				call SizeRight
				call CaptionTop
			.elseif eax==TL_TOP
				mov		eax,[esi].dHeight
				add		[ebx].top,eax
				add		eax,[esi].dr.top
				mov		[esi].dr.bottom,eax
				call SizeBottom
				.if fRightCaption
					call CaptionRight
				.else
					call CaptionTop
				.endif
			.elseif eax==TL_RIGHT
				mov     eax,[esi].dWidth
				sub     [ebx].right,eax
				neg		eax
				add		eax,[esi].dr.right
;				dec		eax
				mov		[esi].dr.left,eax
				call SizeLeft
				.if [esi].IsChild && fRightCaption && parDocked
					sub     [ebx].right,TOTCAPHT
					call CaptionRight
				.else
					.if [esi].IsChild && parDocked
						sub     [esi].dr.top,TOTCAPHT
						sub     [esi].wr.top,TOTCAPHT
						sub     [esi].rr.top,TOTCAPHT
					.endif
					call CaptionTop
				.endif
			.elseif eax==TL_BOTTOM
				mov     eax,[esi].dHeight
				sub     [ebx].bottom,eax
				neg		eax
				add		eax,[esi].dr.bottom
				mov		[esi].dr.top,eax
				call SizeTop
				.if ((parPosition==TL_LEFT || parPosition==TL_RIGHT) && parDocked) || !fRightCaption
					call CaptionTop
				.else
					call CaptionRight
				.endif
			.endif
		.endif
	.elseif eax==TLM_GET_VISIBLE
		mov		eax,[esi].Visible
		ret
	.elseif eax==TLM_GET_DOCKED
		mov		eax,[esi].Docked
		ret
	.elseif eax==TLM_GET_STRUCT
		mov		eax,esi
		ret
	.endif
	mov     eax,FALSE
	ret

TestTab:
	mov		eax,[esi].hCld
	.if eax==hTab
		mov     eax,[esi].Position
		.if eax==TL_TOP || eax==TL_BOTTOM || ![esi].Docked
			mov		edx,WS_VISIBLE or WS_CHILD or WS_TABSTOP or TCS_FOCUSNEVER or TCS_BUTTONS
		.else
			mov		edx,WS_VISIBLE or WS_CHILD or WS_TABSTOP or TCS_FOCUSNEVER or TCS_BUTTONS or TCS_VERTICAL or TCS_RIGHT
		.endif
		.if fMultiLine
			or		edx,TCS_MULTILINE
		.endif
		invoke SetWindowLong,hTab,GWL_STYLE,edx
		invoke SendMessage,hTab,WM_SETFONT,0,TRUE
		invoke SendMessage,hTab,WM_SETFONT,hLBFont,TRUE
	.endif
	retn

SizeLeft:
	invoke CopyRect,addr [esi].wr,addr [esi].dr
	mov		eax,[esi].wr.left
	mov		[esi].rr.left,eax
	add		eax,RESIZEBAR
	mov		[esi].wr.left,eax
	mov		[esi].rr.right,eax
	mov		eax,[esi].wr.top
	mov		[esi].rr.top,eax
	mov		eax,[esi].wr.bottom
	mov		[esi].rr.bottom,eax
	retn

SizeTop:
	invoke CopyRect,addr [esi].wr,addr [esi].dr
	mov		eax,[esi].wr.left
	mov		[esi].rr.left,eax
	mov		eax,[esi].wr.right
	mov		[esi].rr.right,eax
	mov		eax,[esi].wr.top
	mov		[esi].rr.top,eax
	add		eax,RESIZEBAR
	mov		[esi].wr.top,eax
	mov		[esi].rr.bottom,eax
	retn

SizeRight:
	invoke CopyRect,addr [esi].wr,addr [esi].dr
	mov		eax,[esi].wr.right
	mov		[esi].rr.right,eax
	sub		eax,RESIZEBAR
	mov		[esi].wr.right,eax
	mov		[esi].rr.left,eax
	mov		eax,[esi].wr.top
	mov		[esi].rr.top,eax
	mov		eax,[esi].wr.bottom
	mov		[esi].rr.bottom,eax
	retn

SizeBottom:
	invoke CopyRect,addr [esi].wr,addr [esi].dr
	mov		eax,[esi].wr.left
	mov		[esi].rr.left,eax
	mov		eax,[esi].wr.right
	mov		[esi].rr.right,eax
	mov		eax,[esi].wr.bottom
	mov		[esi].rr.bottom,eax
	sub		eax,RESIZEBAR
	mov		[esi].wr.bottom,eax
	mov		[esi].rr.top,eax
	retn

CaptionTop:
	mov		eax,[esi].wr.left
	mov		[esi].tr.left,eax
	mov		[esi].cr.left,eax
	mov		eax,[esi].wr.right
	mov		[esi].tr.right,eax
	mov		[esi].cr.right,eax
	mov		eax,[esi].wr.top
	mov		[esi].tr.top,eax
	inc		eax
	mov		[esi].cr.top,eax
	add		eax,TOTCAPHT-1
	mov		[esi].wr.top,eax
	mov		[esi].tr.bottom,eax
	dec		eax
	mov		[esi].cr.bottom,eax

	mov		eax,[esi].cr.top
	add		eax,BUTTONT
	mov		[esi].br.top,eax
	add		eax,BUTTONHT
	mov		[esi].br.bottom,eax
	mov		eax,[esi].cr.right
	sub		eax,BUTTONR
	mov		[esi].br.right,eax
	sub		eax,BUTTONWT
	mov		[esi].br.left,eax
	retn

CaptionRight:
	mov		eax,[esi].wr.right
	mov		[esi].tr.right,eax
	dec		eax
	mov		[esi].cr.right,eax
	sub		eax,TOTCAPHT-1
	mov		[esi].tr.left,eax
	inc		eax
	mov		[esi].cr.left,eax
	mov		[esi].wr.right,eax
	mov		eax,[esi].wr.top
	mov		[esi].tr.top,eax
	mov		[esi].cr.top,eax
	mov		eax,[esi].wr.bottom
	mov		[esi].tr.bottom,eax
	mov		[esi].cr.bottom,eax

	mov		eax,[esi].cr.right
	sub		eax,BUTTONT
	mov		[esi].br.right,eax
	sub		eax,BUTTONHT
	mov		[esi].br.left,eax
	mov		eax,[esi].cr.bottom
	sub		eax,BUTTONR
	mov		[esi].br.bottom,eax
	sub		eax,BUTTONWT
	mov		[esi].br.top,eax
	retn

ToolMov:
	invoke IsOnTool,ebx
	.if eax!=0 && eax!=[esi].ID
		;If Tool has child
		mov     [esi].IsChild,eax
		invoke SetIsChildTo,[esi].ID,eax
	.else
		.if eax<50 || eax>-50
			mov     eax,MoveRect.top
			sub     eax,DrawRect.top
			.if eax<50 || eax>-50
				retn
			.endif
		.endif
		invoke GetWindowRect,hWnd,addr rect2
		sub		rect2.left,50
		sub		rect2.top,50
		add		rect2.right,50
		add		rect2.bottom,50
		mov     eax,MoveRect.left
		sub     eax,DrawRect.left
		mov     ebx,lpRect
		assume ebx:ptr POINT
		mov     eax,[ebx].x
		cwde
		mov     [ebx].x,eax
		.if sdword ptr eax<rect2.left || sdword ptr eax>rect2.right
			mov     [esi].Docked,FALSE
			retn
		.endif
		mov     eax,[ebx].y
		cwde
		mov     [ebx].y,eax
		.if sdword ptr eax<rect2.top || sdword ptr eax>rect2.bottom
			mov     [esi].Docked,FALSE
			retn
		.endif
		mov     eax,[ebx].x
		sub     eax,ClientRect.left
		.if eax<50 || eax>-50
			mov     [esi].Position,TL_LEFT
			mov     [esi].IsChild,0
		.else
			mov     eax,[ebx].y
			sub     eax,ClientRect.top
			.if eax<50 || eax>-50
				mov     [esi].Position,TL_TOP
				mov     [esi].IsChild,0
			.else
				mov     eax,[ebx].x
				sub     eax,ClientRect.right
				.if eax<50 || eax>-50
					mov     [esi].Position,TL_RIGHT
					mov     [esi].IsChild,0
				.else
					mov     eax,[ebx].y
					sub     eax,ClientRect.bottom
					.if eax<50 || eax>-50
						mov     [esi].Position,TL_BOTTOM
						mov     [esi].IsChild,0
					.else
						mov     [esi].Docked,FALSE
					.endif
				.endif
			.endif
		.endif
	.endif
	retn

	assume esi:nothing
	assume ebx:nothing

ToolMsg endp

ToolHitTest proc lpRect:DWORD,lpPoint:DWORD
	LOCAL fHit:DWORD
	
	assume ebx:ptr RECT
	assume edx:ptr POINT
	mov     fHit,FALSE
	push    edx
	push    ebx
	mov     edx,lpPoint
	mov     ebx,lpRect
	mov     eax,[edx].x
	.if eax>=[ebx].left && eax<[ebx].right
		mov     eax,[edx].y
		.if eax>=[ebx].top && eax<[ebx].bottom
			mov     fHit,TRUE
		.endif
	.endif
	pop     ebx
	pop     edx
	mov     eax,fHit
	assume ebx:nothing
	assume edx:nothing
	ret

ToolHitTest endp

ToolWndProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL   rect:RECT
	LOCAL	pt:POINT
	LOCAL   tlW:DWORD
	LOCAL   tlH:DWORD

	mov		eax,uMsg
	.if eax==WM_CREATE
		mov     edx,lParam
		mov     eax,[edx].CREATESTRUCT.lpCreateParams
		invoke SetWindowLong,hWin,GWL_USERDATA,eax
	.elseif eax==WM_SIZE
		mov     eax,hWin
		call    GetToolStruct
		mov		ebx,edx
		.if [ebx].TOOL.Visible
			invoke GetWindowRect,hWin,addr [ebx].TOOL.fr
			invoke GetClientRect,hWin,addr rect
			mov     eax,rect.right
			sub     eax,rect.left
			mov     tlW,eax
			mov     eax,rect.bottom
			sub     eax,rect.top
			mov     tlH,eax
			invoke MoveWindow,[ebx].TOOL.hCld,rect.left,rect.top,tlW,tlH,TRUE
		.endif
	.elseif eax==WM_SHOWWINDOW
		mov     eax,hWin
		call    GetToolStruct
		.if ![edx].TOOL.Visible || [edx].TOOL.Docked
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_MOVE
		mov     eax,hWin
		call    GetToolStruct
		invoke GetWindowRect,hWin,addr [edx].TOOL.fr
	.elseif eax==WM_NCLBUTTONDOWN
		.if wParam==HTCAPTION
			invoke LoadCursor,0,IDC_HAND
			mov		MoveCur,eax
			mov     eax,hWin
			call    GetToolStruct
			mov		ebx,edx
			mov		[ebx].TOOL.dCurFlag,TL_ONCAPTION
			mov		[ebx].TOOL.Docked,TRUE
			mov		eax,[ebx].TOOL.fr.top
			add		eax,10
			mov		pt.y,eax
			mov		eax,[ebx].TOOL.fr.right
			sub		eax,[ebx].TOOL.fr.left
			shr		eax,1
			add		eax,[ebx].TOOL.fr.left
			mov		pt.x,eax
			invoke SetCursorPos,pt.x,pt.y
			invoke ToolMsg,[ebx].TOOL.hCld,TLM_LBUTTONDOWN,addr pt
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_NOTIFY
		mov		ebx,lParam
		mov		eax,[ebx].NMHDR.hwndFrom
		.if eax==hTab && [ebx].NMHDR.code==TCN_SELCHANGE
			invoke TabToolSel,hClient
		.endif
	.elseif eax==WM_CLOSE
		mov     eax,hWin
		call    GetToolStruct
		mov     eax,[edx].TOOL.hCld
		invoke ToolMessage,eax,TLM_HIDE,0
		invoke InvalidateRect,hClient,NULL,TRUE
		xor		eax,eax
		ret
	.endif
	invoke  DefWindowProc,hWin,uMsg,wParam,lParam
	ret

ToolWndProc endp

ToolCldProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	buffer[8]:BYTE
	LOCAL	buffer1[8]:BYTE

	mov		eax,uMsg
	.if eax==WM_CTLCOLORSTATIC
		invoke SetBkMode,wParam,TRANSPARENT
		invoke SetTextColor,wParam,radcol.infotext
		mov		eax,hBrInfo
		ret
	.elseif eax==WM_NOTIFY
		mov		ebx,lParam
		mov		eax,(NMHDR ptr [ebx]).code
		.if eax==TVN_BEGINDRAG
			.if fGroup && sdword ptr [ebx].NM_TREEVIEW.itemNew.lParam>0
				invoke GroupTVBeginDrag,[ebx].NMHDR.hwndFrom,hWin,lParam
			.else
				invoke SendMessage,[ebx].NMHDR.hwndFrom,TVM_SELECTITEM,TVGN_CARET,[ebx].NM_TREEVIEW.itemNew.hItem
			.endif
		.endif
	.elseif eax==WM_LBUTTONUP
		.if IsDragging
			mov		IsDragging,FALSE
			invoke GroupTVEndDrag,hPbrTrv
			mov		esi,offset profile
			.while [esi].PROFILE.lpszFile
				invoke BinToDec,[esi].PROFILE.iNbr,addr buffer
				invoke BinToDec,[esi].PROFILE.nGrp,addr buffer1
				invoke WritePrivateProfileString,addr iniProjectGroup,addr buffer,addr buffer1,addr ProjectFile
				lea		esi,[esi+sizeof PROFILE]
			.endw
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_MOUSEMOVE
		.if IsDragging
			invoke GetCursorPos,addr pt
			invoke ImageList_DragMove,pt.x,pt.y
			invoke GetWindowRect,hPbrTrv,addr rect
			invoke GetScrollPos,hPbrTrv,SB_VERT
			mov		ebx,eax
			mov		edx,pt.y
			.if sdword ptr edx<rect.top
				dec		ebx
				mov		eax,ebx
				shl		eax,16
				or		eax,SB_LINEUP
				invoke SendMessage,hPbrTrv,WM_VSCROLL,eax,0
			.elseif sdword ptr edx>rect.bottom
				inc		ebx
				mov		eax,ebx
				shl		eax,16
				or		eax,SB_LINEDOWN
				invoke SendMessage,hPbrTrv,WM_VSCROLL,eax,0
			.endif
		.endif
		xor		eax,eax
		jmp		Ex
	.endif
	invoke  DefWindowProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ToolCldProc endp

GetToolStruct proc

	invoke GetWindowLong,eax,GWL_USERDATA
	mov     edx,eax
	ret

GetToolStruct endp

EnableProjectBrowser proc fFlag:DWORD

	.if fFlag
		invoke SendMessage,hPbrTbr,TB_CHECKBUTTON,11,TRUE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,11,TRUE
		invoke SendMessage,hPbrTbr,TB_CHECKBUTTON,13,FALSE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,13,FALSE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,12,FALSE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,18,FALSE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,14,TRUE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,15,TRUE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,1,TRUE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,16,TRUE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,17,TRUE
		invoke ShowWindow,hFileTrv,SW_HIDE
		invoke ShowWindow,hPbrTrv,SW_SHOW
	.else
		invoke SendMessage,hPbrTbr,TB_CHECKBUTTON,11,FALSE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,11,FALSE
		invoke SendMessage,hPbrTbr,TB_CHECKBUTTON,13,TRUE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,13,TRUE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,12,TRUE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,18,TRUE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,14,FALSE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,15,FALSE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,1,FALSE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,16,FALSE
		invoke SendMessage,hPbrTbr,TB_HIDEBUTTON,17,FALSE
		invoke ShowWindow,hFileTrv,SW_SHOW
		invoke ShowWindow,hPbrTrv,SW_HIDE
	.endif
	ret

EnableProjectBrowser endp

ToolCldWndProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	tvi:TV_ITEMEX
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[8]:BYTE
	LOCAL	tch:TC_HITTESTINFO

	mov		eax,uMsg
	.if eax==WM_SETFOCUS
		mov     eax,hWin
		call    GetToolPtr
		mov     (TOOL ptr [edx]).dFocus,TRUE
		invoke ToolMsg,hWin,TLM_CAPTION,0
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		.if [esi].itemID!=LB_ERR
			test	[esi].itemState,ODS_SELECTED
			.if ZERO?
				invoke SetTextColor,[esi].hdc,radcol.propertiestext
				invoke SetBkColor,[esi].hdc,radcol.properties
			.else
				invoke GetSysColor,COLOR_HIGHLIGHTTEXT
				invoke SetTextColor,[esi].hdc,eax
				invoke GetSysColor,COLOR_HIGHLIGHT
				invoke SetBkColor,[esi].hdc,eax
			.endif
			push	[esi].rcItem.right
			mov		eax,[esi].hwndItem
			.if eax==hPrpLstDlg
				mov		eax,lbTp
				mov		[esi].rcItem.right,eax
			.endif
			invoke ExtTextOut,[esi].hdc,0,0,ETO_OPAQUE,addr [esi].rcItem,NULL,0,NULL
			pop		[esi].rcItem.right
			invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr tempbuff
			mov		eax,offset tempbuff
			.while byte ptr [eax] && byte ptr [eax]!=VK_TAB
				inc		eax
			.endw
			sub		eax,offset tempbuff
			invoke TextOut,[esi].hdc,2,[esi].rcItem.top,addr tempbuff,eax
			mov		eax,[esi].hwndItem
			.if eax==hPrpLstDlg
				invoke SetTextColor,[esi].hdc,radcol.propertiestext
				invoke SetBkColor,[esi].hdc,radcol.properties
				mov		edx,offset tempbuff
				.while byte ptr [edx] && byte ptr [edx]!=VK_TAB
					inc		edx
				.endw
				inc		edx
				mov		eax,edx
				.while byte ptr [eax] && byte ptr [eax]!=VK_TAB
					inc		eax
				.endw
				sub		eax,edx
				mov		ecx,lbTp
				add		ecx,2
				invoke TextOut,[esi].hdc,ecx,[esi].rcItem.top,edx,eax
			.endif
			invoke CreatePen,PS_SOLID,0,0C0C0C0h
			invoke SelectObject,[esi].hdc,eax
			push	eax
			mov		edx,[esi].rcItem.bottom
			dec		edx
			invoke MoveToEx,[esi].hdc,[esi].rcItem.left,edx,NULL
			mov		edx,[esi].rcItem.bottom
			dec		edx
			invoke LineTo,[esi].hdc,[esi].rcItem.right,edx
			mov		eax,[esi].hwndItem
			.if eax==hPrpLstDlg
				mov		edx,[esi].rcItem.left
				add		edx,lbTp
				invoke MoveToEx,[esi].hdc,edx,[esi].rcItem.top,NULL
				mov		edx,[esi].rcItem.left
				add		edx,lbTp
				invoke LineTo,[esi].hdc,edx,[esi].rcItem.bottom
			.endif
			pop		eax
			invoke SelectObject,[esi].hdc,eax
			invoke DeleteObject,eax
		.endif
		assume esi:nothing
		pop		esi
		xor		eax,eax
		ret
	.elseif eax==WM_CONTEXTMENU
		invoke DllProc,hWin,AIM_CONTEXTMENU,wParam,lParam,RAM_CONTEXTMENU
		.if eax
			xor		eax,eax
			ret
		.endif
		mov		eax,lParam
		mov		edx,hWin
		.if eax!=-1
			cwde
			mov		pt.x,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			mov		pt.y,eax
		.elseif edx==hOut
			invoke GetCaretPos,addr pt
			invoke ClientToScreen,hWin,addr pt
		.else
			invoke GetWindowRect,hWin,addr rect
			mov		eax,rect.left
			add		eax,10
			mov		pt.x,eax
			mov		eax,rect.top
			add		eax,10
			mov		pt.y,eax
		.endif
		mov		eax,hWin
		.if eax==hPbr
			invoke IsWindowVisible,hPbrTrv
			.if eax
				invoke EnableMenuItem,hToolMenu,IDM_PROJECT_ADDNEW,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_PROJECT_ADDEXISTING,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_PROJECT_ADDEXISTINGOPEN,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_PROMNU_FILEPROP,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_PROMNU_REMOVE,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_PROMNU_RENAME,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_PROMNU_LOCK,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_PROMNU_COPY,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_FILE_CLOSEPROJECT,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_FILE_DELETEPROJECT,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_PROJECT_REFRESH,MF_GRAYED
				invoke EnableMenuItem,hToolMenu,IDM_PROJECT_GROUPS,MF_GRAYED
				.if fProject
					;Project
					invoke EnableMenuItem,hToolMenu,IDM_PROJECT_ADDNEW,MF_ENABLED
					invoke EnableMenuItem,hToolMenu,IDM_PROJECT_ADDEXISTING,MF_ENABLED
					invoke EnableMenuItem,hToolMenu,IDM_FILE_CLOSEPROJECT,MF_ENABLED
					invoke EnableMenuItem,hToolMenu,IDM_FILE_DELETEPROJECT,MF_ENABLED
					invoke EnableMenuItem,hToolMenu,IDM_PROJECT_GROUPS,MF_ENABLED
					.if hDialog
						invoke EnableMenuItem,hToolMenu,IDM_PROJECT_REFRESH,MF_GRAYED
					.else
						invoke EnableMenuItem,hToolMenu,IDM_PROJECT_REFRESH,MF_ENABLED
					.endif
					invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_CARET,hPbrTrv
					.if eax
						mov		tvi.hItem,eax
						mov		tvi.imask,TVIF_PARAM or TVIF_TEXT
						lea		eax,buffer
						mov		tvi.pszText,eax
						mov		tvi.cchTextMax,sizeof buffer
						invoke SendMessage,hPbrTrv,TVM_GETITEM,0,addr tvi
						.if sdword ptr tvi.lParam>0
							invoke GetFileImg,addr buffer
							.if eax==2 || eax==3
								invoke EnableMenuItem,hToolMenu,IDM_PROMNU_FILEPROP,MF_ENABLED
							.endif
							invoke EnableMenuItem,hToolMenu,IDM_PROMNU_REMOVE,MF_ENABLED
							invoke EnableMenuItem,hToolMenu,IDM_PROMNU_RENAME,MF_ENABLED
							invoke EnableMenuItem,hToolMenu,IDM_PROMNU_LOCK,MF_ENABLED
							.if hEdit
								invoke EnableMenuItem,hToolMenu,IDM_PROMNU_COPY,MF_ENABLED
							.endif
						.endif
					.endif
					.if hEdit || hDialog
						invoke GetWindowLong,hMdiCld,16
						.if !eax
							invoke EnableMenuItem,hToolMenu,IDM_PROJECT_ADDEXISTINGOPEN,MF_ENABLED
						.endif
					.endif
				.endif
				invoke GetSubMenu,hToolMenu,0
			.else
				invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_CARET,hFileTrv
				.if eax
					mov		tvi.hItem,eax
					mov		tvi.imask,TVIF_PARAM or TVIF_TEXT or TVIF_IMAGE
					lea		eax,buffer
					mov		tvi.pszText,eax
					mov		tvi.cchTextMax,sizeof buffer
					invoke SendMessage,hPbrTrv,TVM_GETITEM,0,addr tvi
				.endif
				invoke EnableMenuItem,hToolMenu,IDM_FILE_COPYNAME,MF_GRAYED
				mov		eax,tvi.iImage
				.if eax>IML_START+1 && eax<IML_START+11
					invoke EnableMenuItem,hToolMenu,IDM_FILE_CUT,MF_ENABLED
					invoke EnableMenuItem,hToolMenu,IDM_FILE_COPY,MF_ENABLED
					invoke EnableMenuItem,hToolMenu,IDM_FILE_DELETE,MF_ENABLED
					invoke EnableMenuItem,hToolMenu,IDM_FILE_RENAME,MF_ENABLED
					.if hEdit
						invoke EnableMenuItem,hToolMenu,IDM_FILE_COPYNAME,MF_ENABLED
					.endif
				.else
					invoke EnableMenuItem,hToolMenu,IDM_FILE_CUT,MF_GRAYED
					invoke EnableMenuItem,hToolMenu,IDM_FILE_COPY,MF_GRAYED
					invoke EnableMenuItem,hToolMenu,IDM_FILE_DELETE,MF_GRAYED
					invoke EnableMenuItem,hToolMenu,IDM_FILE_RENAME,MF_GRAYED
				.endif
				mov		al,FileToCopy
				.if al
					mov		eax,MF_ENABLED
				.else
					mov		eax,MF_GRAYED
				.endif
				invoke EnableMenuItem,hToolMenu,IDM_FILE_PASTE,eax
				invoke GetSubMenu,hToolMenu,3
			.endif
		.elseif eax==hOut
			invoke GetSubMenu,hToolMenu,1
		.elseif eax==hTab
			invoke GetCursorPos,addr tch.pt
			invoke GetClientRect,hTab,addr rect
			invoke ClientToScreen,hWin,addr rect
			mov		eax,rect.left
			sub		tch.pt.x,eax
			mov		eax,rect.top
			sub		tch.pt.y,eax
			invoke SendMessage,hTab,TCM_HITTEST,0,addr tch
			push	fMaximized
			.if eax!=-1
				invoke TabToolSetSel,eax
			.endif
			mov		eax,MENUWINDOW
			pop		edx
			.if edx
				inc		eax
			.endif
			invoke GetSubMenu,hMenu,eax
		.else
			mov		eax,0
		.endif
		.if eax
			invoke TrackPopupMenu,eax,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWnd,0
		.endif
		xor		eax,eax
		ret
	.elseif eax==WM_COMMAND
		invoke DllProc,hWnd,AIM_COMMAND,wParam,lParam,RAM_COMMAND
		.if eax
			xor		eax,eax
			ret
		.endif
		mov		edx,wParam
		shr		edx,16
		.if edx==BN_CLICKED
			mov		eax,wParam
			.if eax==5
				.if !fProject
					invoke EnumChildWindows,hClient,addr SetOpenProperty,-2
				.endif
				invoke RefreshProperty
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
			.elseif eax>=1 && eax<=4
				mov		fProperty,eax
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
			.elseif eax==11
				invoke EnableProjectBrowser,TRUE
			.elseif eax==12
				xor		fGroup,1
				.if fProject
					invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
					invoke SendMessage,hPbrTrv,TVM_DELETEITEM,0,eax
					invoke GetProjectFiles,FALSE
					.if hMdiCld
						invoke ProSetTrv,hMdiCld
					.else
						invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
						invoke SendMessage,hPbrTrv,TVM_SELECTITEM,TVGN_CARET,eax
					.endif
				.endif
			.elseif eax==18
				.if fProject
					xor		fExpand,1
					.if fExpand
						invoke GroupExpandAll,hPbrTrv,0
					.else
						invoke GroupCollapseAll,hPbrTrv,0
					.endif
				.endif
			.elseif eax==13
				invoke EnableProjectBrowser,FALSE
			.elseif eax==14
				xor		fFileBrowser,1
				invoke FileDir,offset FilePath
			.elseif eax==15
				invoke iniRStripStr,offset FilePath,'\'
				invoke strlen,offset FilePath
				.if byte ptr FilePath[eax-1]==':'
					invoke strcat,offset FilePath,offset szBackSlash
				.endif
				invoke FileDir,offset FilePath
			.elseif eax==16
				movzx	eax,nFileBrowser
				and		al,0Fh
				mov		edx,MAX_PATH
				mul		edx
				add		eax,offset FilePaths
				invoke strcpy,eax,offset FilePath
				mov		ecx,10
				.while ecx
					push	ecx
					movzx	eax,nFileBrowser
					dec		al
					.if al<'0'
						mov		al,'9'
					.endif
					mov		nFileBrowser,al
					and		al,0Fh
					mov		edx,MAX_PATH
					mul		edx
					add		eax,offset FilePaths
					mov		edx,eax
					movzx	eax,byte ptr [edx]
					pop		ecx
				  .break .if eax
					dec		ecx
				.endw
				invoke strcpy,offset FilePath,edx
				invoke FileDir,offset FilePath
			.elseif eax==17
				movzx	eax,nFileBrowser
				and		al,0Fh
				mov		edx,MAX_PATH
				mul		edx
				add		eax,offset FilePaths
				invoke strcpy,eax,offset FilePath
				mov		ecx,10
				.while ecx
					push	ecx
					movzx	eax,nFileBrowser
					inc		al
					.if al>'9'
						mov		al,'0'
					.endif
					mov		nFileBrowser,al
					and		al,0Fh
					mov		edx,MAX_PATH
					mul		edx
					add		eax,offset FilePaths
					mov		edx,eax
					movzx	eax,byte ptr [edx]
					pop		ecx
				  .break .if eax
					dec		ecx
				.endw
				invoke strcpy,offset FilePath,edx
				invoke FileDir,offset FilePath
			.endif
		.elseif edx==LBN_SELCHANGE
			invoke SendMessage,lParam,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				mov		edx,eax
				mov		eax,lParam
				.if eax==hPrpLstCode
					invoke SendMessage,lParam,LB_GETITEMRECT,edx,addr rect
					mov		eax,lbHt
					sub		rect.right,eax
					sub		rect.top,1
					invoke SetWindowPos,hTxtBtn,HWND_TOP,rect.right,rect.top,eax,eax,0
					invoke ShowWindow,hTxtBtn,SW_SHOWNOACTIVATE
				.elseif eax==hPrpLstDlg
					invoke PropListSetPos
				.endif
			.endif
		.endif
		invoke DllProc,hWnd,AIM_COMMANDDONE,wParam,lParam,RAM_COMMANDDONE
	.elseif eax==WM_NOTIFY
		mov		ebx,lParam
		mov		eax,(NMHDR ptr [ebx]).code
		mov		ecx,(NMHDR ptr [ebx]).hwndFrom
		.if eax==TTN_NEEDTEXTW || eax==TTN_NEEDTEXT
			;Toolbar tooltip
			invoke GetToolBarTooltip,hWin,(NMHDR ptr [ebx]).idFrom
			mov		(TOOLTIPTEXT ptr [ebx]).lpszText,eax
		.elseif eax==TVN_BEGINLABELEDIT
			.if ecx==hPbrTrv
				.if sdword ptr [ebx].NMTVDISPINFO.item.lParam>0
					invoke strcpy,offset FileToCopy,[ebx].NMTVDISPINFO.item.pszText
					xor		eax,eax
				.else
					mov		eax,TRUE
				.endif
			.elseif ecx==hFileTrv
				invoke FileGetName
				xor		eax,eax
			.endif
			jmp		Ex
		.elseif eax==TVN_ENDLABELEDIT
			xor		eax,eax
			.if ecx==hPbrTrv
				.if [ebx].NMTVDISPINFO.item.pszText
					invoke strcpy,addr buffer,[ebx].NMTVDISPINFO.item.pszText
					invoke strcmp,addr buffer,offset FileToCopy
					.if eax
						.if sdword ptr [ebx].NMTVDISPINFO.item.lParam>0
							; File
							invoke SetCurrentDirectory,offset ProjectPath
							invoke MoveFile,offset FileToCopy,addr buffer
							.if eax
								mov		eax,[ebx].NMTVDISPINFO.item.lParam
								mov		edx,eax
								invoke BinToDec,edx,addr buffer1
								invoke WritePrivateProfileString,addr iniProjectFiles,addr buffer1,addr buffer,addr ProjectFile
								invoke GetPrivateProfileSection,addr iniProjectFiles,hMemPro,32*1024-1,addr	ProjectFile
								mov		hFound,0
								invoke strcpy,offset FileName,offset ProjectPath
								invoke strcat,offset FileName,offset FileToCopy
								invoke GetFullPathName,addr FileName,sizeof FileName,addr FileName,addr buffer1
								invoke UpdateAll,FIND_OPEN_FILENAME
								.if hFound
									invoke DelPath,hFound
									invoke strcpy,offset FileName,offset ProjectPath
									invoke strcat,offset FileName,addr buffer
									invoke GetFullPathName,addr FileName,sizeof FileName,addr FileName,addr buffer1
									invoke SetWindowText,hFound,addr FileName
									invoke strlen,addr buffer
									.while eax
										.break .if buffer[eax-1]=='\'
										dec		eax
									.endw
									invoke TabToolUpdate,hFound,addr buffer[eax]
									invoke AddPath,hFound
								.endif
								invoke DllProc,hWnd,AIM_PROJECTRENAME,offset FileToCopy,addr buffer,RAM_PROJECTRENAME
								mov		eax,TRUE
								jmp		Ex
							.endif
;						.elseif sdword ptr [ebx].NMTVDISPINFO.item.lParam<0
;							; Group
;							invoke SendMessage,hPbrTrv,TVM_SETITEM,0,addr [ebx].NMTVDISPINFO.item
;;							invoke GroupGetExpand,hPbrTrv
;;							invoke GroupUpdateGroup,hPbrTrv
;							invoke GroupSaveGroups,hPbrTrv
;							mov		eax,TRUE
;							jmp		Ex
						.endif
					.endif
				.endif
			.elseif ecx==hFileTrv
				.if [ebx].NMTVDISPINFO.item.pszText
					invoke FileGetPath,addr buffer
					invoke strcat,addr buffer,[ebx].NMTVDISPINFO.item.pszText
					invoke lstrcmpi,addr buffer,offset FileToCopy
					.if eax
						invoke MoveFile,offset FileToCopy,addr buffer
						mov		eax,TRUE
					.endif
				.endif
				mov		FileToCopy,0
			.endif
			jmp		Ex
		.endif
	.elseif eax==WM_LBUTTONDOWN
		invoke SetFocus,hWin
		invoke SendMessage,hWnd,WM_TOOLCLICK,hWin,lParam
	.elseif eax==WM_RBUTTONDOWN
		invoke SetFocus,hWin
		invoke SendMessage,hWnd,WM_TOOLRCLICK,hWin,lParam
		xor		eax,eax
		ret
	.elseif eax==WM_LBUTTONDBLCLK
		mov		eax, hWin
		.if eax==hTab
			mov		tabinx,-1
			invoke GetCursorPos,addr tch.pt
			invoke GetClientRect,hTab,addr rect
			invoke ClientToScreen,hWin,addr rect
			mov		eax,rect.left
			sub		tch.pt.x,eax
			mov		eax,rect.top
			sub		tch.pt.y,eax
			invoke SendMessage,hTab,TCM_HITTEST,0,addr tch
			; get tab that was dblclicked
			.if eax != -1
				push	eax
				invoke SendMessage,hTab,TCM_GETCURSEL,0,0
				pop		edx
				; is tab that was dblclicked also selected?
				.if eax == edx
					invoke SendMessage,hMdiCld,WM_CLOSE,0,0
				.endif
			.endif
		.else
			invoke SendMessage,hWnd,WM_TOOLDBLCLICK,hWin,lParam
		.endif	
		xor		eax,eax
		ret
	.elseif eax==WM_KILLFOCUS
		mov     eax, hWin
		call    GetToolPtr
		mov     (TOOL ptr [edx]).dFocus,FALSE
		invoke ToolMsg,hWin,TLM_CAPTION,0
	.elseif eax==WM_LBUTTONDBLCLK
		invoke SendMessage,hWnd,WM_TOOLDBLCLICK,hWin,lParam
		xor		eax,eax
		ret
	.elseif eax==WM_SIZE
		invoke SendMessage,hWnd,WM_TOOLSIZE,hWin,lParam
	.elseif eax==WM_MOUSEWHEEL
		.if !MouseWheel
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_CTLCOLORLISTBOX
		invoke SetTextColor,wParam,radcol.propertiestext
		invoke SetBkColor,wParam,radcol.properties
		mov		eax,hBrPrp
		ret
	.elseif eax==WM_CTLCOLOREDIT
		mov		eax,hWin
		.if eax!=hPbr
			invoke SetTextColor,wParam,radcol.propertiestext
			invoke SetBkColor,wParam,radcol.properties
			mov		eax,hBrPrp
			ret
		.endif
	.endif
	mov     eax,hWin
	call    GetToolPtr
	mov     eax,(TOOL ptr [edx]).lpfnOldCldWndProc
	invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
  Ex:
	ret

ToolCldWndProc endp

