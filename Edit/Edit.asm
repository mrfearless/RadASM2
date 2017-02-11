
.code

TrimSpaces proc
	LOCAL	nLine:DWORD
	LOCAL	chrg:CHARRANGE

	invoke SendMessage,hEdit,REM_LOCKUNDOID,TRUE,0
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		nLine,eax
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMax
	push	eax
	invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
	xor		edx,edx
	.if eax<chrg.cpMax
		inc		edx
	.endif
	pop		eax
	sub		eax,nLine
	add		eax,edx
	mov		edx,chrg.cpMin
	mov		chrg.cpMax,edx
	.while eax
		push	eax
		invoke SendMessage,hEdit,REM_TRIMSPACE,nLine,FALSE
		add		chrg.cpMax,eax
		inc		nLine
		pop		eax
		dec		eax
	.endw
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
	invoke SetFocus,hEdit
	invoke SendMessage,hEdit,REM_LOCKUNDOID,FALSE,0
	ret

TrimSpaces endp

HideSelection proc
	LOCAL	nLine:DWORD
	LOCAL	chrg:CHARRANGE

	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		nLine,eax
	invoke SendMessage,hEdit,REM_GETBOOKMARK,nLine,0
	.if eax==8
		invoke SendMessage,hEdit,REM_EXPAND,nLine,0
		invoke SendMessage,hEdit,REM_SETBOOKMARK,nLine,0
	.elseif eax==9
		invoke SendMessage,hEdit,REM_SETBOOKMARK,nLine,0
	.else
		invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMax
		.if eax>nLine
			sub		eax,nLine
			invoke SendMessage,hEdit,REM_HIDELINES,nLine,eax
		.endif
	.endif
	invoke SetFocus,hEdit
	ret

HideSelection endp

GetSelText proc lpBuff:DWORD
	LOCAL	chrg:CHARRANGE

	.if hEdit
		invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
		mov		eax,chrg.cpMax
		sub		eax,chrg.cpMin
		.if eax && eax<256
			invoke SendMessage,hEdit,EM_GETSELTEXT,0,addr tempbuff
			mov		ecx,offset tempbuff
			mov		edx,offset FindBuffer
			.while byte ptr [ecx]
				mov		al,[ecx]
				.if al<' '
					mov		byte ptr [edx],'^'
					inc		edx
					add		al,40h
				.endif
				mov		[edx],al
				inc		ecx
				inc		edx
			.endw
			mov		byte ptr [edx],0
		.endif
	.endif
	ret

GetSelText endp

GetFontWt proc hWin:HWND,hFnt:DWORD
	LOCAL	hDC:HDC
	LOCAL	tm:TEXTMETRIC
	LOCAL	pt:POINT
	LOCAL	buffer[4]:BYTE

	invoke GetDC,hWin
	mov		hDC,eax
	invoke SelectObject,hDC,hFnt
	push	eax
	invoke GetTextMetrics,hDC,addr tm
	mov		buffer,'W'
	invoke GetTextExtentPoint32,hDC,addr buffer,1,addr pt
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,hWin,hDC
	mov		eax,tm.tmHeight
	mov		fntht,eax
	mov		eax,tm.tmAveCharWidth
	mov		eax,pt.x
	mov		fntwt,eax
	ret

GetFontWt endp

MoveWin proc uses ebx,hWin:HWND,lpPt:DWORD
	LOCAL	rect:RECT
	LOCAL	xm:DWORD
	LOCAL	ym:DWORD

	invoke GetWindowRect,hWin,addr rect
	mov		eax,rect.left
	sub		rect.right,eax
	mov		eax,rect.top
	sub		rect.bottom,eax
	invoke GetSystemMetrics,SM_CXSCREEN
	sub		eax,rect.right
	mov		xm,eax
	invoke GetSystemMetrics,SM_CYSCREEN
	sub		eax,rect.bottom
	mov		ym,eax
	mov		ebx,lpPt
	mov		eax,[ebx].POINT.x
	add		eax,rect.left
	.if eax>80000000h
		mov		eax,0
	.elseif eax>xm
		mov		eax,xm
	.endif
	mov		rect.left,eax
	mov		eax,[ebx].POINT.y
	add		eax,rect.top
	.if eax>80000000h
		mov		eax,0
	.elseif eax>ym
		mov		eax,ym
	.endif
	mov		rect.top,eax
	invoke MoveWindow,hWin,rect.left,rect.top,rect.right,rect.bottom,FALSE
	ret

MoveWin endp

SaveWinPos proc uses ebx,hWin:HWND,lpPt:DWORD
	LOCAL	rect:RECT
	LOCAL	rect1:RECT

	invoke GetWindowRect,hWin,addr rect
	invoke GetClientRect,hWnd,addr rect1
	invoke ClientToScreen,hWnd,addr rect1
	mov		eax,rect1.left
	sub		rect.left,eax
	mov		eax,rect1.top
	sub		rect.top,eax
	mov		ebx,lpPt
	mov		eax,rect.left
	mov		[ebx].POINT.x,eax
	mov		eax,rect.top
	mov		[ebx].POINT.y,eax
	ret

SaveWinPos endp

VerticalCenter proc hWin:HWND,nCmnd:DWORD

	invoke SendMessage,hWin,EM_SCROLLCARET,0,0
	invoke SendMessage,hWin,nCmnd,0,0
	invoke SendMessage,hWin,EM_SCROLLCARET,0,0
	ret

VerticalCenter endp

;########################################################################

MdiActivate proc hWin:HWND

	invoke SendMessage,hClient,WM_MDIACTIVATE,hWin,0
	ret

MdiActivate endp

;########################################################################

ConvertSpcToTab proc uses esi edi
	LOCAL	ochr:CHARRANGE
	LOCAL	chr:CHARRANGE
	LOCAL	LnSt:DWORD
	LOCAL	LnEn:DWORD
	LOCAL	fChng:DWORD

	invoke SendMessage,hEdit,REM_LOCKUNDOID,TRUE,0
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr ochr
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chr
	invoke SendMessage,hEdit,EM_HIDESELECTION,TRUE,0
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chr.cpMin
	mov		LnSt,eax
	mov		eax,chr.cpMax
	dec		eax
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,eax
	mov		LnEn,eax
  nxtL:
	mov		eax,LnSt
	.if eax<=LnEn
		invoke SendMessage,hEdit,REM_GETBOOKMARK,LnSt,0
		.if eax==2
			invoke SendMessage,hEdit,REM_EXPAND,LnSt,0
		.endif
		invoke SendMessage,hEdit,EM_LINEINDEX,LnSt,0
		mov		chr.cpMin,eax
		inc		LnSt
		invoke SendMessage,hEdit,EM_LINEINDEX,LnSt,0
		mov		chr.cpMax,eax
		.if eax==chr.cpMin
			invoke SendMessage,hEdit,EM_LINELENGTH,eax,0
			add		chr.cpMax,eax
		.endif
		mov		eax,ochr.cpMax
		.if eax<chr.cpMax
			mov		chr.cpMax,eax
		.endif
		invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chr
		invoke SendMessage,hEdit,EM_GETSELTEXT,0,addr LineTxt
		mov		esi,offset LineTxt
		mov		edi,offset tempbuff
		dec		esi
		xor		edx,edx
		xor		ecx,ecx
		mov		fChng,edx
	  nxtC:
		.if ecx==TabSize
			xor		ecx,ecx
			.if edx>1
				sub		edi,edx
				dec		edx
				sub		ochr.cpMax,edx
				mov		byte ptr [edi],VK_TAB
				.if edi>offset tempbuff
					.if byte ptr [edi-1]==VK_SPACE
						mov		byte ptr [edi-1],VK_TAB
					.endif
				.endif
				inc		edi
				mov		fChng,TRUE
			.endif
			xor		edx,edx
		.endif
		inc		esi
		mov		al,[esi]
		.if al==' '
			inc		edx
			inc		ecx
		.elseif al==VK_TAB
			.if edx
				sub		edi,edx
				sub		ochr.cpMax,edx
				xor		edx,edx
				mov		fChng,TRUE
			.elseif edi>offset tempbuff
				.if byte ptr [edi-1]==VK_SPACE
					mov		[edi-1],al
					mov		fChng,TRUE
				.endif
			.endif
			xor		ecx,ecx
		.else
			xor		edx,edx
			inc		ecx
		.endif
		mov		[edi],al
		inc		edi
		or		al,al
		jne		nxtC
		.if fChng
			invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr tempbuff
		.endif
		jmp		nxtL
	.endif
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr ochr
	invoke SendMessage,hEdit,EM_HIDESELECTION,FALSE,0
	invoke SendMessage,hEdit,EM_SCROLLCARET,0,0
	invoke SendMessage,hEdit,REM_LOCKUNDOID,FALSE,0
	ret

ConvertSpcToTab endp

;########################################################################

ConvertTabToSpc proc uses esi edi
	LOCAL	ochr:CHARRANGE
	LOCAL	chr:CHARRANGE
	LOCAL	LnSt:DWORD
	LOCAL	LnEn:DWORD
	LOCAL	fChng:DWORD

	invoke SendMessage,hEdit,REM_LOCKUNDOID,TRUE,0
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr ochr
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chr
	invoke SendMessage,hEdit,EM_HIDESELECTION,TRUE,0
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chr.cpMin
	mov		LnSt,eax
	mov		eax,chr.cpMax
	dec		eax
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,eax
	mov		LnEn,eax
  nxtL:
	mov		eax,LnSt
	.if eax<=LnEn
		invoke SendMessage,hEdit,REM_GETBOOKMARK,LnSt,0
		.if eax==2
			invoke SendMessage,hEdit,REM_EXPAND,LnSt,0
		.endif
		invoke SendMessage,hEdit,EM_LINEINDEX,LnSt,0
		mov		chr.cpMin,eax
		inc		LnSt
		invoke SendMessage,hEdit,EM_LINEINDEX,LnSt,0
		mov		chr.cpMax,eax
		.if eax==chr.cpMin
			invoke SendMessage,hEdit,EM_LINELENGTH,eax,0
			add		chr.cpMax,eax
		.endif
		mov		eax,ochr.cpMax
		.if eax<chr.cpMax
			mov		chr.cpMax,eax
		.endif
		invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chr
		invoke SendMessage,hEdit,EM_GETSELTEXT,0,addr LineTxt
		mov		esi,offset LineTxt
		mov		edi,offset tempbuff
		mov		fChng,0
		.while byte ptr [esi]
			mov		al,[esi]
			.if al==VK_TAB
				mov		fChng,1
				mov		eax,edi
				sub		eax,offset tempbuff
				xor		edx,edx
				mov		ecx,TabSize
				div		ecx
				sub		ecx,edx
				mov		edx,ecx
				dec		edx
				add		ochr.cpMax,edx
				mov		al,' '
				rep stosb
			.else
				mov		[edi],al
				inc		edi
			.endif
			inc		esi
		.endw
		mov		byte ptr [edi],0
		.if fChng
			invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr tempbuff
		.endif
		jmp		nxtL
	.endif
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr ochr
	invoke SendMessage,hEdit,EM_HIDESELECTION,FALSE,0
	invoke SendMessage,hEdit,EM_SCROLLCARET,0,0
	invoke SendMessage,hEdit,REM_LOCKUNDOID,FALSE,0
	ret

ConvertTabToSpc endp

;########################################################################

ConvertCase proc fUpper:DWORD
	LOCAL	ochrg:CHARRANGE
	LOCAL	chrg:CHARRANGE

	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr ochrg
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
	mov		eax,chrg.cpMax
	sub		eax,chrg.cpMin
	.if eax<sizeof LineTxt
		invoke SendMessage,hEdit,EM_GETSELTEXT,0,addr LineTxt
		push	esi
		lea		esi,LineTxt
	  @@:
		mov		al,[esi]
		.if fUpper
			.if al>='a' && al<='z'
				and		al,5Fh
			.endif
		.else
			.if al>='A' && al<='Z'
				or		al,20h
			.endif
		.endif
		mov		[esi],al
		inc		esi
		or		al,al
		jne		@b
		pop		esi
		invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr LineTxt
		invoke SendMessage,hEdit,EM_EXSETSEL,0,addr ochrg
		invoke SendMessage,hEdit,EM_SCROLLCARET,0,0
	.endif
	ret

ConvertCase endp

;########################################################################

IndentComment proc uses esi,nChr:DWORD,fN:DWORD
	LOCAL	ochrg:CHARRANGE
	LOCAL	chrg:CHARRANGE
	LOCAL	LnSt:DWORD
	LOCAL	LnEn:DWORD
	LOCAL	buffer[32]:BYTE

	invoke GetCursor
	push	eax
	invoke LoadCursor,0,IDC_WAIT
	invoke SetCursor,eax
	invoke SendMessage,hEdit,WM_SETREDRAW,FALSE,0
	invoke SendMessage,hEdit,REM_LOCKUNDOID,TRUE,0
	.if fN
		.if nChr==VK_TAB && TabToSpc
			mov		ecx,TabSize
			push	edi
			lea		edi,buffer
			mov		al,' '
			rep stosb
			mov		al,0
			mov		[edi],al
			pop		edi
		.else
			mov		eax,nChr
			mov		dword ptr buffer[0],eax
		.endif
	.endif
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr ochrg
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hEdit,EM_HIDESELECTION,TRUE,0
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		LnSt,eax
	mov		eax,chrg.cpMax
	dec		eax
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,eax
	mov		LnEn,eax
  nxt:
	mov		eax,LnSt
	.if eax<=LnEn
		invoke SendMessage,hEdit,REM_GETBOOKMARK,LnSt,0
		.if eax==2
			invoke SendMessage,hEdit,REM_EXPAND,LnSt,0
		.endif
		invoke SendMessage,hEdit,EM_LINEINDEX,LnSt,0
		mov		chrg.cpMin,eax
		inc		LnSt
		.if fN
			mov		chrg.cpMax,eax
			invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr buffer
			invoke strlen,addr buffer
			add		ochrg.cpMax,eax
			jmp		nxt
		.else
			invoke SendMessage,hEdit,EM_LINELENGTH,eax,0
			add		eax,chrg.cpMin
			mov		chrg.cpMax,eax
			invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hEdit,EM_GETSELTEXT,0,addr LineTxt
			mov		esi,offset LineTxt
			xor		eax,eax
			mov		al,[esi]
			.if eax==nChr
				inc		esi
				invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,esi
				dec		ochrg.cpMax
			.elseif nChr==09h
				mov		ecx,TabSize
				dec		esi
			  @@:
				inc		esi
				mov		al,[esi]
				cmp		al,' '
				jne		@f
				loop	@b
				inc		esi
			  @@:
				.if al==09h
					inc		esi
					dec		ecx
				.endif
				mov		eax,TabSize
				sub		eax,ecx
				sub		ochrg.cpMax,eax
				invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,esi
			.endif
			jmp		nxt
		.endif
	.endif
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr ochrg
	invoke SendMessage,hEdit,EM_HIDESELECTION,FALSE,0
	invoke SendMessage,hEdit,EM_SCROLLCARET,0,0
	invoke SendMessage,hEdit,REM_LOCKUNDOID,FALSE,0
	invoke SendMessage,hEdit,WM_SETREDRAW,TRUE,0
	invoke SendMessage,hEdit,REM_REPAINT,0,0
	pop		eax
	invoke SetCursor,eax
	ret

IndentComment endp

;########################################################################

GetKBState proc
	
	invoke GetKeyState,VK_CONTROL
	and		eax,80h
	push	eax
	invoke GetKeyState,VK_SHIFT
	and		eax,80h
	mov		edx,eax
	pop		eax
	ret

GetKBState endp

;########################################################################

;Convert bookmarks and breakpoints from hWin to ID or from ID to hWin
ConvBookMark proc uses edi,nFrom:DWORD,nTo:DWORD

	mov		edi,offset BookMark
  @@:
	mov		eax,[edi]
	.if eax==nFrom
		mov		eax,nTo
		mov		[edi],eax
	.endif
	add		edi,3*4
	cmp		edi,offset BookMark+sizeof BookMark+sizeof BreakPoint+sizeof ErrorBookMark
	jne		@b
	ret

ConvBookMark endp

OpenBookMark proc iNbr:DWORD
	LOCAL	val:DWORD

	invoke GetFileNameFromID,iNbr
	.if eax
		push	eax
		invoke strcpy,addr FileName,addr ProjectPath
		pop		eax
		invoke strcat,addr FileName,eax
		invoke GetFullPathName,addr FileName,sizeof FileName,addr FileName,addr val
		invoke OpenEditFile
		mov		eax,hEdit
	.endif
	ret

OpenBookMark endp

;Select next or previous bookmark
SelBookMark proc  uses ecx edi,nInc:DWORD
	LOCAL	chrg:CHARRANGE

	mov		ecx,32
  @@:
	mov		eax,nInc
	add		iBookMark,eax
	and		iBookMark,1Fh
	mov		eax,iBookMark
	shl		eax,2
	mov		edi,eax
	add		edi,eax
	add		edi,eax
	add		edi,offset BookMark
	mov		eax,[edi]
	or		eax,eax
	jne		@f
	loop	@b
	jmp		Ex
  @@:
	push	edi
	.if SDWORD ptr eax<0
		and		eax,3FFh
		invoke OpenBookMark,eax
	.endif
	invoke GetParent,eax
	invoke MdiActivate,eax
	pop		edi
	mov		eax,[edi+4]
	invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
	mov		chrg.cpMin,eax
	mov		chrg.cpMax,eax
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
	invoke VerticalCenter,hEdit,REM_VCENTER
	invoke SetFocus,hEdit
  Ex:
	ret

SelBookMark endp

;Delete bookmark in hWin at current line, if it exists
DelBookMark proc uses ecx edi,iLine:DWORD

	mov		ecx,FALSE
	mov		edi,offset BookMark-12
  @@:
	add		edi,12
	cmp		edi,offset BookMark+sizeof BookMark
	je		Ex
	mov		eax,[edi]
	cmp		eax,hEdit
	jne		@b
	mov		eax,[edi+4]
	cmp		eax,iLine
	jne		@b
	mov		ecx,TRUE
  @@:
	cmp		edi,offset BookMark+sizeof BookMark-12
	je		@f
	mov		eax,[edi+12]
	mov		[edi],eax
	mov		eax,[edi+16]
	mov		[edi+4],eax
	mov		eax,[edi+20]
	mov		[edi+8],eax
	add		edi,12
	jmp		@b
  @@:
	mov		eax,0
	mov		[edi],eax
	mov		[edi+4],eax
	mov		[edi+8],eax
  Ex:
	mov		eax,ecx
	ret

DelBookMark endp

;Create a bookmark in hWin at current line
SetBookMark proc uses edi,nName:DWORD,iLine:DWORD

	mov		edi,offset BookMark+sizeof BookMark-(12*3)
  @@:
	mov		eax,[edi]
	mov		[edi+12],eax
	mov		eax,[edi+4]
	mov		[edi+16],eax
	mov		eax,[edi+8]
	mov		[edi+20],eax
	sub		edi,12
	cmp		edi,offset BookMark-12
	jne		@b
	mov		iBookMark,0
	mov		eax,hEdit
	mov		BookMark,eax
	mov		eax,iLine
	mov		BookMark+4,eax
	mov		eax,nName
	mov		BookMark+8,eax
	ret

SetBookMark endp

;Toggles a bookmark in hWin at current line
ToggleBookMark proc nName:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	iLine:DWORD

	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		iLine,eax
	invoke DelBookMark,iLine
	.if !eax
		invoke SetBookMark,nName,iLine
	.endif
	invoke SendMessage,hEdit,REM_INVALIDATELINE,iLine,0
	ret

ToggleBookMark endp

;Delete a breakpoint in hWin at current line, if it exists
DelBreakPoint proc uses ecx edi
	LOCAL	chrg:CHARRANGE
	LOCAL	iLine:DWORD
	LOCAL	nBP:DWORD

	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
	mov		nBP,0
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		iLine,eax
  Nx:
	mov		edi,offset BreakPoint-12
  @@:
	add		edi,3*4
	cmp		edi,offset BreakPoint+sizeof BreakPoint+3*4
	je		Ex
	mov		eax,[edi]
	cmp		eax,hEdit
	jne		@b
	mov		eax,[edi+4]
	cmp		eax,iLine
	jne		@b
	xor		eax,eax
	mov		[edi],eax
	mov		[edi+4],eax
	mov		[edi+8],eax
	mov		eax,edi
	sub		eax,offset BreakPoint
	mov		ecx,12
	xor		edx,edx
	div		ecx
	inc		eax
	invoke SetBreakPointVar,eax,0
	inc		nBP
	invoke SendMessage,hEdit,REM_INVALIDATELINE,iLine,0
  Ex:
	inc		iLine
	invoke SendMessage,hEdit,EM_LINEINDEX,iLine,0
	.if eax<chrg.cpMax
		invoke SendMessage,hEdit,EM_LINEFROMCHAR,eax,0
		.if eax==iLine
			jmp		Nx
		.endif
	.endif
	mov		eax,nBP
	ret

DelBreakPoint endp

;Create a breakpoint in hWin at current line
SetBreakPoint proc uses edi
	LOCAL	chrg:CHARRANGE
	LOCAL	iLine:DWORD

	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
	mov		iLine,eax
  Nx:
	mov		edi,offset BreakPoint
	xor		eax,eax
  @@:
	cmp		eax,[edi]
	je		@f
	add		edi,3*4
	cmp		edi,offset BreakPoint+sizeof BreakPoint+3*4
	jne		@b
	jmp		Ex
  @@:
	mov		eax,hEdit
	mov		[edi],eax
	mov		eax,iLine
	mov		[edi+4],eax
	mov		dword ptr [edi+8],2
	invoke SendMessage,hEdit,REM_INVALIDATELINE,iLine,0
	inc		iLine
	invoke SendMessage,hEdit,EM_LINEINDEX,iLine,0
	.if eax<chrg.cpMax
		invoke SendMessage,hEdit,EM_LINEFROMCHAR,eax,0
		.if eax==iLine
			jmp		Nx
		.endif
	.endif
  Ex:
	ret

SetBreakPoint endp

;Toggle a breakpoint in hWin at current line
ToggleBreakPoint proc

	invoke DelBreakPoint
	.if !eax
		invoke SetBreakPoint
	.endif
	ret

ToggleBreakPoint endp

ClearBreakPoints proc uses edi

	mov		edi,offset BreakPoint
	xor		eax,eax
	.while edi<offset BreakPoint+sizeof BreakPoint
		mov		[edi],eax
		add		edi,4
	.endw
	mov		edi,offset BreakPointVar
	.while edi<offset BreakPointVar+sizeof BreakPointVar
		mov		[edi],eax
		add		edi,4
	.endw
	ret

ClearBreakPoints endp

;Clear no named bookmarks
ClearBookMarks proc uses esi edi

	mov		esi,offset BookMark
	mov		edi,esi
	xor		edx,edx
  @@:
	mov		eax,[edi+8]
	.if eax!=1
		mov		eax,[edi]
		mov		[edi],edx
		mov		dword ptr [esi],eax
		mov		eax,[edi+4]
		mov		[edi+4],edx
		mov		dword ptr [esi+4],eax
		mov		eax,[edi+8]
		mov		[edi+8],edx
		mov		dword ptr [esi+8],eax
		add		esi,3*4
	.else
		mov		[edi],edx
		mov		[edi+4],edx
		mov		[edi+8],edx
	.endif
	add		edi,3*4
	cmp		edi,offset BookMark+sizeof BookMark
	jne		@b
	mov		iBookMark,0
	ret

ClearBookMarks endp

;Kill bokmarks belonging to hWin
KillBookMarks proc uses edi,hWin:HWND

	mov		edi,offset BookMark
  @@:
	mov		eax,[edi]
	.if eax==hWin
		push	edi
		.while edi<offset BookMark+sizeof BookMark
			mov		eax,[edi+12]
			mov		[edi],eax
			mov		eax,[edi+16]
			mov		[edi+4],eax
			mov		eax,[edi+20]
			mov		[edi+8],eax
			add		edi,3*4
		.endw
		pop		edi
		sub		edi,3*4
	.endif
	add		edi,3*4
	cmp		edi,offset BookMark+sizeof BookMark
	jne		@b
	ret

KillBookMarks endp

;Create a error bookmark in hWin at current line
SetErrorBookMark proc uses edi,hWin:HWND,iLine:DWORD

	mov		edi,offset ErrorBookMark
	mov		eax,iErrorBookMark
	lea		eax,[eax*2+eax]
	lea		edi,[edi+eax*4]
	mov		eax,hWin
	mov		[edi],eax
	mov		eax,iLine
	mov		[edi+4],eax
	mov		eax,99
	test	fErrBookMark,1
	.if ZERO?
		xor		eax,eax
	.endif
	mov		[edi+8],eax
	test	fErrBookMark,2
	.if !ZERO?
		invoke SendMessage,hWin,REM_SETHILITELINE,iLine,1
	.endif
	mov		eax,iErrorBookMark
	inc		eax
	and		eax,127
	mov		iErrorBookMark,eax
	ret

SetErrorBookMark endp

ClearErrorBookMarks proc uses edi

	mov		edi,offset ErrorBookMark
	.while edi<offset ErrorBookMark+sizeof ErrorBookMark
		mov		ecx,[edi]
		mov		edx,[edi+4]
		xor		eax,eax
		mov		[edi],eax
		mov		[edi+4],eax
		mov		[edi+8],eax
		.if sdword ptr ecx>0
			invoke SendMessage,ecx,REM_SETHILITELINE,edx,0
		.endif
		add		edi,3*4
	.endw
	mov		iErrorBookMark,0
	ret

ClearErrorBookMarks endp

;Is a line in hWin a bookmark
IsBookMark proc uses ebx esi edi,hWin:HWND,iLine:DWORD

	mov		ecx,hWin
	mov		edx,iLine
	mov		ebx,3*4
	mov		edi,offset BookMark-3*4
	mov		esi,offset BookMark+sizeof BookMark
	xor		eax,eax
  @@:
	add		edi,ebx
	cmp		edi,esi
	je		@f
	cmp		eax,[edi]
	je		@f
	cmp		edx,[edi+4]
	jne		@b
	cmp		ecx,[edi]
	jne		@b
	mov		eax,[edi+8]
	ret
  @@:
	mov		edi,offset ErrorBookMark-3*4
	mov		esi,offset ErrorBookMark+sizeof ErrorBookMark
	xor		eax,eax
  @@:
	add		edi,ebx
	cmp		edi,esi
	je		@f
	cmp		eax,[edi]
	je		@f
	cmp		edx,[edi+4]
	jne		@b
	cmp		ecx,[edi]
	jne		@b
	mov		eax,[edi+8]
	ret
  @@:
	mov		edi,offset BreakPoint-3*4
	mov		esi,offset BreakPoint+sizeof BreakPoint
  @@:
	add		edi,ebx
	cmp		edi,esi
	je		Ex
	cmp		edx,[edi+4]
	jne		@b
	cmp		ecx,[edi]
	jne		@b
	mov		eax,[edi+8]
	ret
  Ex:
	xor		eax,eax
	ret

IsBookMark endp

BmCallBack proc hWin:HWND,iLine:DWORD

	invoke IsBookMark,hWin,iLine
	.if eax==1
		mov		eax,3
	.elseif eax==2
		mov		eax,5
	.elseif eax==99
		mov		eax,7
	.elseif eax
		mov		eax,4
	.endif
	ret

BmCallBack endp

;Find a named bookmark and open the file
;If bookmark does not exist, create it
FindBookMark proc uses edi,nName:DWORD
	LOCAL	chrg:CHARRANGE

	mov		edi,offset BookMark
  @@:
	mov		eax,[edi+8]
	.if eax!=nName
		add		edi,3*4
		cmp		edi,offset BookMark+sizeof BookMark
		jne		@b
		invoke IsBookMark,hEdit,LastLine
		.if !eax
			invoke ToggleBookMark,nName
		.elseif eax==TRUE
			invoke ToggleBookMark,nName
			invoke ToggleBookMark,nName
		.endif
		ret
	.endif
	mov		eax,[edi]
	.if SDWORD ptr eax<0
		and		eax,3FFh
		invoke OpenBookMark,eax
	.endif
	invoke GetParent,eax
	invoke MdiActivate,eax
	mov		eax,[edi+4]
	invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
	mov		chrg.cpMin,eax
	mov		chrg.cpMax,eax
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
	invoke VerticalCenter,hEdit,REM_VCENTER
	invoke SetFocus,hEdit
	xor		eax,eax
	ret

FindBookMark endp

ShowBreakPoint proc uses edi,nID:DWORD
	LOCAL	chrg:CHARRANGE

	mov		edi,offset BreakPoint
	mov		eax,nID
	shl		eax,2
	add		edi,eax
	add		edi,eax
	add		edi,eax
	mov		eax,[edi]
	.if SDWORD ptr eax<0
		and		eax,3FFh
		invoke OpenBookMark,eax
	.endif
	invoke GetParent,eax
	invoke MdiActivate,eax
	mov		eax,[edi+4]
	invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
	mov		chrg.cpMin,eax
	invoke SendMessage,hEdit,EM_LINELENGTH,eax,0
	inc		eax
	add		eax,chrg.cpMin
	mov		chrg.cpMax,eax
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
	invoke VerticalCenter,hEdit,REM_VCENTER
	invoke SetFocus,hEdit
	xor		eax,eax
	ret

ShowBreakPoint endp

AnyBookMarks proc uses edi

	mov		edi,offset BookMark
	xor		eax,eax
  @@:
	or		eax,[edi]
	jne		Ex
	add		edi,3*4
	cmp		edi,offset BookMark+sizeof BookMark
	jne		@b
  Ex:
	ret

AnyBookMarks endp

AnyNamedBookMarks proc uses edi

	mov		edi,offset BookMark
	xor		eax,eax
  Nxt:
	or		eax,[edi]
	je		@f
	mov		eax,[edi+8]
	cmp		eax,1
	jne		Ex
  @@:
	add		edi,3*4
	cmp		edi,offset BookMark+sizeof BookMark
	jne		Nxt
  Ex:
	ret

AnyNamedBookMarks endp

AnyBreakPoints proc uses edi

	mov		edi,offset BreakPoint
	xor		eax,eax
  @@:
	or		eax,[edi]
	jne		Ex
	add		edi,3*4
	cmp		edi,offset BreakPoint+sizeof BreakPoint
	jne		@b
  Ex:
	ret

AnyBreakPoints endp

AnyErrorBookMarks proc uses edi

	mov		edi,offset ErrorBookMark
	xor		eax,eax
  @@:
	or		eax,[edi]
	jne		Ex
	add		edi,3*4
	cmp		edi,offset ErrorBookMark+sizeof ErrorBookMark
	jne		@b
  Ex:
	ret

AnyErrorBookMarks endp

IsNamedBookMark proc uses edi,nBmk:DWORD

	mov		edi,offset BookMark
	mov		eax,nBmk
  Nxt:
	cmp		eax,[edi+8]
	je		Ex
	add		edi,3*4
	cmp		edi,offset BookMark+sizeof BookMark
	jne		Nxt
	xor		eax,eax
  Ex:
	ret

IsNamedBookMark endp

AnyNoNameBookMarks proc uses edi

	mov		edi,offset BookMark
  Nxt:
	xor		eax,eax
	or		eax,[edi]
	je		@f
	mov		eax,[edi+8]
	cmp		eax,1
	je		Ex
  @@:
	add		edi,3*4
	cmp		edi,offset BookMark+sizeof BookMark
	jne		Nxt
	xor		eax,eax
  Ex:
	ret

AnyNoNameBookMarks endp

AdjustBookMarks proc uses esi,hWin:HWND,pnLine:DWORD,pnLines:DWORD

	mov		esi,offset BookMark
	mov		eax,pnLines
	sub		pnLine,eax
	.while esi<offset BookMark+sizeof BookMark+sizeof BreakPoint+sizeof ErrorBookMark
		mov		eax,dword ptr [esi]
		.if eax==hWin
			mov		eax,dword ptr [esi+4]
			.if eax>pnLine || (eax==pnLine && !LastCol)
				push	eax
				invoke SendMessage,hWin,REM_INVALIDATELINE,eax,0
				pop		eax
				add		eax,pnLines
				mov		dword ptr [esi+4],eax
				invoke SendMessage,hWin,REM_INVALIDATELINE,eax,0
			.endif
		.endif
		add		esi,3*4
	.endw
	ret

AdjustBookMarks endp

SaveBookMarks proc uses edi
	LOCAL	buffer1[8]:BYTE
	LOCAL	buffer2[128]:BYTE
	LOCAL	nInx:DWORD

	invoke ClearBookMarks
	mov		word ptr buffer1,'0'
	.while buffer1<='9'
		mov		buffer2,0
		invoke WritePrivateProfileString,addr iniProjectBookMark,addr buffer1,addr buffer2,addr ProjectFile
		movzx	eax,buffer1
		mov		edi,offset BookMark
		.while edi<offset BookMark+sizeof BookMark
			cmp		eax,[edi+8]
			jne		@f
			mov		edx,[edi]
			and		edx,3FFh
			invoke iniPutItem,edx,addr buffer2,TRUE
			mov		edx,[edi+4]
			invoke iniPutItem,edx,addr buffer2,FALSE
			invoke WritePrivateProfileString,offset iniProjectBookMark,addr buffer1,addr buffer2,addr ProjectFile
			.break
		  @@:
			add		edi,3*4
		.endw
		inc		buffer1
	.endw
	mov		edi,offset BookMark
	xor		eax,eax
	.while edi<offset BookMark+sizeof BookMark
		mov		[edi],eax
		add		edi,4
	.endw
	mov		iBookMark,1
	mov		dword ptr buffer1,'=0'
	invoke WritePrivateProfileSection,offset iniProjectBreakPoint,addr buffer1,offset ProjectFile
	mov		nInx,0
	mov		edi,offset BreakPoint
	.while edi<offset BreakPoint+sizeof BreakPoint
		.if dword ptr [edi]
			mov		buffer2,0
			invoke BinToDec,nInx,addr buffer1
			mov		edx,[edi]
			and		edx,3FFh
			invoke iniPutItem,edx,addr buffer2,TRUE
			mov		edx,[edi+4]
			invoke iniPutItem,edx,addr buffer2,TRUE
			mov		eax,edi
			sub		eax,offset BreakPoint
			mov		ecx,12
			xor		edx,edx
			div		ecx
			inc		eax
			invoke GetBreakPointVar,eax
			add		eax,4
			invoke strcat,addr buffer2,eax
			invoke WritePrivateProfileString,offset iniProjectBreakPoint,addr buffer1,addr buffer2,offset ProjectFile
			xor		eax,eax
			mov		[edi],eax
			mov		[edi+4],eax
			mov		[edi+8],eax
			inc		nInx
		.endif
		add		edi,3*4
	.endw
	ret

SaveBookMarks endp

LoadBookMarks proc uses edi
	LOCAL	buffer1[8]:BYTE
	LOCAL	buffer2[128]:BYTE
	LOCAL	buffer3[128]:BYTE
	LOCAL	nInx:DWORD

	mov		word ptr buffer1,'0'
	mov		edi,offset BookMark
	.while buffer1<='9'
		invoke GetPrivateProfileString,offset iniProjectBookMark,addr buffer1,addr szNULL,addr buffer2,64,addr ProjectFile
		.if eax
			invoke iniGetItem,addr buffer2,addr buffer3
			invoke DecToBin,addr buffer3
			or		eax,80000000h
			mov		[edi],eax
			invoke DecToBin,addr buffer2
			mov		[edi+4],eax
			movzx	eax,buffer1
			mov		[edi+8],eax
			add		edi,3*4
		.endif
		inc		buffer1
	.endw
	mov		iBookMark,1
	mov		nInx,0
	mov		edi,offset BreakPoint
  @@:
	invoke BinToDec,nInx,addr buffer1
	invoke GetPrivateProfileString,offset iniProjectBreakPoint,addr buffer1,offset szNULL,addr buffer2,64,addr ProjectFile
	.if eax
		invoke iniGetItem,addr buffer2,addr buffer3
		invoke DecToBin,addr buffer3
		or		eax,80000000h
		mov		[edi],eax
		invoke iniGetItem,addr buffer2,addr buffer3
		invoke DecToBin,addr buffer3
		mov		[edi+4],eax
		mov		dword ptr [edi+8],2
		.if byte ptr buffer2
			mov		eax,edi
			sub		eax,offset BreakPoint
			mov		ecx,12
			xor		edx,edx
			div		ecx
			inc		eax
			mov		edx,eax
			invoke SetBreakPointVar,edx,addr buffer2
		.endif
		add		edi,3*4
		inc		nInx
		jmp		@b
	.endif
	ret

LoadBookMarks endp

;########################################################################

PushRet proc hWin:HWND,nPos:DWORD

	push	edi
	mov		edi,offset RetPos+112
  @@:
	mov		eax,[edi]
	mov		[edi+8],eax
	mov		eax,[edi+4]
	mov		[edi+12],eax
	sub		edi,8
	cmp		edi,offset RetPos-8
	jne		@b
	mov		eax,hWin
	mov		RetPos,eax
	mov		eax,nPos
	mov		RetPos+4,eax
	pop		edi
	ret

PushRet endp

PopRet proc

	push	edi
	mov		edi,offset RetPos
  @@:
	mov		eax,[edi+8]
	mov		[edi],eax
	mov		eax,[edi+12]
	mov		[edi+4],eax
	add		edi,8
	cmp		edi,offset RetPos+128
	jne		@b
	pop		edi
	ret

PopRet endp

DestroyRet proc hWin:HWND

	push	ecx
	push	edi
	mov		ecx,FALSE
	mov		edi,offset RetPos
	mov		eax,hWin
  @@:
	cmp		eax,[edi]
	je		@f
	add		edi,8
	cmp		edi,offset RetPos+128
	jne		@b
	jmp		Ex
  @@:
	mov		ecx,TRUE
  @@:
	mov		eax,[edi+8]
	mov		[edi],eax
	mov		eax,[edi+12]
	mov		[edi+4],eax
	add		edi,8
	cmp		edi,offset RetPos+128
	jne		@b
  Ex:
	mov		eax,ecx
	pop		edi
	pop		ecx
	ret

DestroyRet endp

AdjustRet proc hWin:HWND,pnChar:DWORD,pnChars:DWORD
	LOCAL	nOfs:DWORD
	LOCAL	fchg:DWORD

	push	edi
	mov		edi,offset RetPos
	mov		eax,pnChars
	mov		fchg,FALSE
	.if eax>nMaxChar
		sub		eax,nMaxChar
		mov		nOfs,eax
		sub		pnChar,eax
		.while edi<offset RetPos+128
			mov		eax,[edi]
			.if eax==hWin
				mov		eax,[edi+4]
				.if eax>=pnChar
					add		eax,nOfs
					mov		[edi+4],eax
					mov		fchg,TRUE
				.endif
			.endif
			add		edi,8
		.endw
	.else
		mov		eax,nMaxChar
		sub		eax,pnChars
		mov		nOfs,eax
		.while edi<offset RetPos+128
			mov		eax,[edi]
			.if eax==hWin
				mov		eax,[edi+4]
				.if eax>pnChar
					sub		eax,nOfs
					mov		[edi+4],eax
					mov		fchg,TRUE
				.endif
			.endif
			add		edi,8
		.endw
	.endif
	pop		edi
	ret

AdjustRet endp

;########################################################################

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

;########################################################################

SetColor proc hWin:HWND

	invoke SendMessage,hWin,REM_SETCOLOR,0,addr racol
	ret

SetColor endp

;########################################################################

GoToProc proc hDlg:DWORD,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nLine:DWORD
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hDlg
		pop		hGoTo
		invoke MoveWin,hDlg,offset PosGotoLeft
		invoke SetLanguage,hDlg,IDD_GOTODLG,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		shr		eax,16
		.if ax==BN_CLICKED
			mov		eax,wParam
			.if ax==IDCANCEL
				invoke SendMessage,hDlg,WM_CLOSE,0,0
			.elseif ax==IDOK
				invoke GetDlgItemInt,hDlg,IDC_LINENO,NULL,FALSE
				dec		eax
				mov		nLine,eax
				.if hEdit
					invoke SendMessage,hEdit,EM_GETLINECOUNT,0,0
					.if eax>nLine
						invoke SendMessage,hEdit,EM_LINEINDEX,nLine,0
						mov		chrg.cpMin,eax
						mov		chrg.cpMax,eax
						invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
						invoke VerticalCenter,hEdit,REM_VCENTER
						invoke SetFocus,hEdit
						invoke SendMessage,hDlg,WM_CLOSE,0,0
					.endif
				.elseif hHexEd
					invoke SendMessage,hHexEd,EM_GETLINECOUNT,0,0
					.if eax>nLine
						invoke SendMessage,hHexEd,EM_LINEINDEX,nLine,0
						mov		chrg.cpMin,eax
						mov		chrg.cpMax,eax
						invoke SendMessage,hHexEd,EM_EXSETSEL,0,addr chrg
						invoke VerticalCenter,hHexEd,HEM_VCENTER
						invoke SetFocus,hHexEd
						invoke SendMessage,hDlg,WM_CLOSE,0,0
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke SaveWinPos,hDlg,offset PosGotoLeft
		mov		hGoTo,0
		invoke DestroyWindow,hDlg
		.if hEdit
			invoke SetFocus,hEdit
		.elseif hHexEd
			invoke SetFocus,hHexEd
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

GoToProc endp

;########################################################################

SetFormat proc hWin:HWND,hFnt:DWORD,hIFnt:DWORD,hLFnt:DWORD,fCode:DWORD
	LOCAL	rafnt:RAFONT

	mov		eax,hFnt
	mov		rafnt.hFont,eax
	mov		eax,hIFnt
	mov		rafnt.hIFont,eax
	mov		eax,hLFnt
	mov		rafnt.hLnrFont,eax
	xor		edx,edx
	.if fCode
		mov		edx,nLnSpc
	.endif
	invoke SendMessage,hWin,REM_SETFONT,edx,addr rafnt
	invoke SendMessage,hWin,REM_TABWIDTH,TabSize,TabToSpc
	mov		eax,fCode
	.if eax
		mov		eax,AutoIndent
	.endif
	invoke SendMessage,hWin,REM_AUTOINDENT,0,eax
	invoke SendMessage,hWin,REM_SETPAGESIZE,nPageSize,0
	invoke SendMessage,hWin,REM_SETCHANGEDSTATE,FALSE,0
	ret

SetFormat endp

;########################################################################

CheckModifyState proc hWin:HWND
	LOCAL	hCld:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[256]:BYTE

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		hCld,eax
	invoke SendMessage,hCld,EM_GETMODIFY,0,0
	.if eax
		invoke GetWindowText,hWin,addr buffer1,256
		invoke strcpy,addr buffer,addr WannaSave
		invoke strcat,addr buffer,addr buffer1
		mov		dword ptr buffer1,'?'
		invoke strcat,addr buffer,addr buffer1
		invoke MessageBox,hWin,addr buffer,addr AppName,MB_YESNOCANCEL or MB_ICONQUESTION
		.if eax==IDYES
			.if hEdit
				invoke SaveEdit,hWin
			.elseif hHexEd
				invoke SaveHexEdit,hWin
			.endif
		.elseif eax==IDNO
			mov		eax,FALSE
		.else
			mov		eax,TRUE
		.endif
	.endif
	ret

CheckModifyState endp

;########################################################################

OpenEditOut proc
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM
	LOCAL	chrg:CHARRANGE

	invoke RtlZeroMemory,addr ofn,sizeof ofn
	mov		ofn.lStructSize,sizeof ofn
	m2m		ofn.hwndOwner,hWnd
	m2m		ofn.hInstance,hInstance
	mov		ofn.lpstrFilter,offset ALLFilterString
	mov		ofn.lpstrFile,offset FileName
	mov		byte ptr [FileName],0
	mov		ofn.nMaxFile,sizeof FileName
	mov		ofn.lpstrDefExt,offset DefSrcExt
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	invoke GetOpenFileName,addr ofn
	.if eax!=0
		invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			m2m		editstream.dwCookie,hFile
			mov		editstream.pfnCallback,offset StreamInProc
			invoke SendMessage,hOutREd,EM_STREAMIN,SF_TEXT,addr editstream
			invoke CloseHandle,hFile
			;Initialize the modify state to false
			invoke SendMessage,hOutREd,EM_SETMODIFY,FALSE,0
			invoke SendMessage,hOutREd,EM_EMPTYUNDOBUFFER,0,0
			mov		eax,0
			mov		chrg.cpMin,eax
			mov		chrg.cpMax,eax
			invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
			invoke SetFocus,hWnd
			mov		eax,FALSE
		.else
			invoke strcpy,addr LineTxt,addr OpenFileFail
			invoke strcat,addr LineTxt,addr FileName
			invoke MessageBox,hWnd,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
			mov		eax,TRUE
		.endif
	.endif
	ret

OpenEditOut endp

SaveEditOutAs proc hWin:HWND
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM

	invoke RtlZeroMemory,addr ofn,sizeof ofn
	mov		ofn.lStructSize,sizeof ofn
	push	hWnd
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset ALLFilterString
	mov		ofn.lpstrFile,offset AltFileName
	mov		byte ptr [AltFileName],0
	mov		ofn.nMaxFile,sizeof AltFileName
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
	mov		ofn.lpstrDefExt,NULL
	invoke GetSaveFileName,addr ofn
	.if eax!=0
		invoke CreateFile,addr AltFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			;stream the text to the file
			mov		editstream.dwCookie,eax
			mov		editstream.pfnCallback,offset StreamOutProc
			invoke SendMessage,hWin,EM_STREAMOUT,SF_TEXT,addr editstream
			;Initialize the modify state to false
			invoke SendMessage,hWin,EM_SETMODIFY,FALSE,0
			invoke CloseHandle,hFile
			xor		eax,eax
			ret
		.else
			invoke strcpy,addr LineTxt,addr SaveFileFail
			invoke strcat,addr LineTxt,addr AltFileName
			invoke MessageBox,hWin,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		.endif
	.else
		invoke SetFocus,hWin
	.endif
	mov		eax,TRUE
	ret

SaveEditOutAs endp

OpenEdit proc uses esi,hWin:HWND

	invoke RtlZeroMemory,addr ofn,sizeof ofn
	mov		ofn.lStructSize,sizeof ofn
	m2m		ofn.hwndOwner,hWin
	m2m		ofn.hInstance,hInstance
	mov		ofn.lpstrFilter,offset ALLFilterString
	mov		ofn.lpstrFile,offset prnbuff
	mov		prnbuff,0
	mov		ofn.nMaxFile,sizeof prnbuff
	mov		ofn.lpstrDefExt,offset DefSrcExt
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_ALLOWMULTISELECT or OFN_EXPLORER
	invoke GetOpenFileName,addr ofn
	.if eax
		mov		esi,offset prnbuff
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		.if !byte ptr [esi]
			invoke strcpy,offset FileName,offset prnbuff
			call	OpenTheFile
		.else
			.while byte ptr [esi]
				invoke strcpy,offset FileName,offset prnbuff
				invoke strcat,offset FileName,offset szBackSlash
				invoke strcat,offset FileName,esi
				invoke strlen,esi
				lea		esi,[esi+eax+1]
				call	OpenTheFile
			.endw
		.endif
	.else
		.if hEdit
			invoke SetFocus,hEdit
		.endif
	.endif
	ret

OpenTheFile:
	invoke iniInStr,addr FileName,addr FTDlg
	.if eax!=-1
		invoke CreateDlg,FALSE
	.else
		invoke iniInStr,addr FileName,addr FTMnu
		.if eax!=-1
			invoke CreateMnu,0
		.else
			invoke OpenEditFile
		.endif
	.endif
	invoke AddRecentFile,offset FileName
	retn

OpenEdit endp

EditAttribute proc hWin:HWND,lpFileName:DWORD

	invoke GetFileAttributes,lpFileName
	and		eax,FILE_ATTRIBUTE_READONLY
	.if eax
		invoke SendMessage,hWin,REM_READONLY,0,TRUE
	.else
		invoke SendMessage,hWin,REM_READONLY,0,FALSE
	.endif
	ret

EditAttribute endp

OpenFileCheck proc uses esi fCode:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	fileext[32]:BYTE
	LOCAL	nInx:DWORD

	invoke GetKBState
	.if eax
		xor		eax,eax
		jmp		Ex
	.endif
	invoke strlen,offset FileName
	lea		esi,[offset FileName+eax]
	mov		ecx,8
  @@:
	xor		eax,eax
	dec		ecx
	je		Ex
	dec		esi
	mov		al,[esi]
	cmp		al,'.'
	jne		@b
	invoke strcpy,addr fileext,esi
	mov		buffer[0],'.'
	mov		buffer[1],0
	invoke strcat,addr fileext,addr buffer
	.if !fCode
		invoke strcpy,addr AltFileName,addr FileName
		mov		nInx,1
	  @@:
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr iniOpen,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr iniFile
		.if eax
			invoke iniGetItem,addr buffer,addr buffer1
			invoke iniInStr,addr buffer1,addr fileext
			.if eax!=-1
				invoke strlen,addr FileName
				mov		dword ptr buffer1,'"'
				invoke strcat,addr buffer1,addr FileName
				mov		dword ptr fileext,'"'
				invoke strcat,addr buffer1,addr fileext
				invoke strlen,addr FileName
				mov		ecx,eax
				lea		esi,[offset FileName+eax]
			  Pth:
				xor		eax,eax
				dec		ecx
				je		Ex
				dec		esi
				mov		al,[esi]
				cmp		al,'\'
				jne		Pth
				mov		byte ptr [esi],0
				mov		dword ptr buffer2,'"'
				invoke strcat,addr buffer2,addr FileName
				mov		dword ptr fileext,'"'
				invoke strcat,addr buffer2,addr fileext
				invoke iniPathFix,addr buffer
				invoke ShellExecute,hWnd,NULL,addr buffer,addr buffer1,addr buffer2,SW_SHOWDEFAULT
				invoke strcpy,addr FileName,addr AltFileName
				mov		eax,TRUE
			.else
				inc		nInx
				jmp		@b
			.endif
		.endif
	.else
		invoke iniInStr,addr szCodeFiles,addr fileext
	.endif
  Ex:
	ret

OpenFileCheck endp

OpenEditFile proc uses esi
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM
	LOCAL	chrg:CHARRANGE
	LOCAL	hWin:HWND
	LOCAL	hEdt:HWND
	LOCAL	ftp:DWORD

	invoke OpenFileCheck,FALSE
	.if !eax
		mov		hFound,0
		invoke UpdateAll,IDM_FILE_OPENFILE
		.if !hFound
			invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
			.if eax!=INVALID_HANDLE_VALUE
				mov		hFile,eax
				invoke GetFileImg,addr FileName
				mov		ftp,eax
				.if ftp==8
					invoke MakeMdiCldWin,addr EditCldClassName,ID_EDITTXT
				.elseif ftp==5
					invoke CloseHandle,hFile
					invoke CreateDlg,0
					mov		eax,FALSE
					ret
				.elseif ftp==6
					invoke CloseHandle,hFile
					invoke CreateMnu,0
					mov		eax,FALSE
					ret
				.elseif ftp==32 && fFileBrowserOpen
					invoke CloseHandle,hFile
					invoke OpenProject,TRUE
					mov		eax,FALSE
					ret
				.elseif ftp==33 || ftp==34
					.if ftp==34
						;.bat
						invoke GetKBState
						.if eax
							invoke MakeMdiCldWin,addr EditCldClassName,ID_EDITTXT
							jmp		@f
						.endif
					.elseif ftp==33
						;.exe
						invoke GetKBState
						.if eax
							invoke CloseHandle,hFile
							invoke OpenHexEditFile
							mov		eax,FALSE
							ret
						.endif
					.endif
					invoke CloseHandle,hFile
					invoke ShellExecute,hWin,NULL,offset FileName,NULL,NULL,SW_SHOWDEFAULT
					mov		eax,FALSE
					ret
				.elseif eax==9 || eax==35 || eax==36 || eax==30 || eax==31
					;.obj, .dll, .res, .bmp, .ico
					invoke CloseHandle,hFile
					invoke OpenHexEditFile
					mov		eax,FALSE
					ret
				.else
					invoke OpenFileCheck,TRUE
					.if eax!=-1
						invoke MakeMdiCldWin,addr EditCldClassName,ID_EDIT
					.else
						invoke MakeMdiCldWin,addr EditCldClassName,ID_EDITTXT
					.endif
				.endif
			  @@:
				mov		hWin,eax
				invoke GetWindowLong,hWin,GWL_USERDATA
				mov		hEdt,eax
				invoke SetWindowText,hWin,addr FileName
				invoke TabToolAdd,hWin,offset FileName
				invoke UpdateWindow,hWnd
				invoke SendMessage,hEdt,WM_SETREDRAW,FALSE,0
				invoke SetFocus,hWin
				.if ftp==4
					;RC file
					invoke SendMessage,hEdt,REM_SETWORDGROUP,0,1
				.endif
				invoke GetCursor
				push	eax
				invoke LoadCursor,NULL,IDC_WAIT
				invoke SetCursor,eax
				;stream the text into the raedit control
				m2m		editstream.dwCookie,hFile
				mov		editstream.pfnCallback,offset StreamInProc
				invoke SendMessage,hEdt,EM_STREAMIN,SF_TEXT,addr editstream
				invoke CloseHandle,hFile
				invoke SendMessage,hEdt,EM_GETLINECOUNT,0,0
				mov		nMaxLine,eax
				invoke EditAttribute,hEdt,addr FileName
				invoke GetWindowLong,hEdt,GWL_ID
				.if eax==ID_EDIT
					invoke SetFormat,hEdt,hFont[0],hFont[4],hFont[8],TRUE
					invoke SendMessage,hEdt,REM_SETBLOCKS,0,0
					invoke SendMessage,hEdt,REM_SETCOMMENTBLOCKS,offset CmntBlockStart,offset CmntBlockEnd
					.if fOpenCollapsed
						invoke SendMessage,hEdt,REM_COLLAPSEALL,0,0
					.endif
				.else
					invoke SetFormat,hEdt,hFontTxt,hFontTxt,hFont[8],FALSE
				.endif
				invoke SetColor,hEdt
				;Initialize the modify state to false
				invoke SendMessage,hEdt,EM_SETMODIFY,FALSE,0
				invoke SendMessage,hEdt,EM_EMPTYUNDOBUFFER,0,0
				invoke GetWindowLong,hWin,0
				invoke DllProc,hWin,AIM_EDITOPEN,hEdt,eax,RAM_EDITOPEN
				.if !eax
					mov		eax,REdPos
				.endif
				mov		chrg.cpMin,eax
				mov		chrg.cpMax,eax
				invoke SendMessage,hEdt,EM_EXSETSEL,0,addr chrg
				invoke SendMessage,hEdt,EM_SCROLLCARET,0,0
				invoke VerticalCenter,hEdt,REM_VCENTER
				.if LnrOnOpen
					invoke CheckDlgButton,hEdt,-2,TRUE
					invoke SendMessage,hEdt,WM_COMMAND,-2,0
				.endif
				invoke SendMessage,hEdt,WM_SETREDRAW,TRUE,0
				invoke SendMessage,hEdt,REM_REPAINT,0,0
				pop		eax
				invoke SetCursor,eax
				invoke SetFocus,hEdt
				.if fProject
					invoke SetWindowLong,hWin,12,FALSE
				.endif
			.else
				invoke strcpy,addr LineTxt,addr OpenFileFail
				invoke strcat,addr LineTxt,addr FileName
				invoke MessageBox,hWnd,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
				mov		eax,TRUE
				ret
			.endif
		.endif
		mov		eax,FALSE
		mov		REdPos,0
	.endif
	ret

OpenEditFile endp

;########################################################################

SaveEdit proc hWin:HWND
	LOCAL	hCld:DWORD
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		hCld,eax
	invoke SendMessage,hCld,EM_GETMODIFY,0,0
	.if eax
		invoke GetWindowText,hWin,addr FileName,255
		invoke strcmp,addr NewFile,addr FileName
		.if !eax
			invoke SaveEditAs,hWin
			ret
		.endif
		invoke BackupEdit,addr FileName,1
		invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke DllProc,hWin,AIM_EDITSAVE,hCld,addr FileName,RAM_EDITSAVE
			.if eax
				invoke CloseHandle,hFile
				mov		eax,TRUE
				ret
			.endif
			;stream the text to the file
			mov		eax,hFile
			mov		editstream.dwCookie,eax
			mov		editstream.pfnCallback,offset StreamOutProc
			invoke SendMessage,hCld,EM_STREAMOUT,SF_TEXT,addr editstream
			;Initialize the modify state to false
			invoke SendMessage,hCld,EM_SETMODIFY,FALSE,0
			invoke SendMessage,hCld,REM_SETCHANGEDSTATE,TRUE,0
			invoke InvalidateRect,hCld,NULL,TRUE
			invoke CloseHandle,hFile
			invoke GetFileImg,addr FileName
			.if eax==4
				inc		fResChanged
				invoke DllProc,hWnd,AIM_RCSAVED,0,addr FileName,RAM_RCSAVED
			.endif
			invoke UpdateFileTime,hWin
			invoke DllProc,hWin,AIM_EDITSAVED,hCld,addr FileName,RAM_EDITSAVED
			xor		eax,eax
		.else
			invoke strcpy,addr LineTxt,addr SaveFileFail
			invoke strcat,addr LineTxt,addr FileName
			invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
			mov		eax,TRUE
		.endif
	.endif
	ret

SaveEdit endp

;########################################################################

SaveEditAs proc hWin:HWND
	LOCAL	hEdt:DWORD
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		hEdt,eax
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	mov ofn.lStructSize,sizeof ofn
	push	hWin
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset ALLFilterString
	mov		ofn.lpstrFile,offset AltFileName
	mov		byte ptr [AltFileName],0
	mov		ofn.nMaxFile,sizeof AltFileName
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
	mov		ofn.lpstrDefExt,offset DefSrcExt
	invoke GetSaveFileName,addr ofn
	.if eax!=0
		invoke CreateFile,addr AltFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strcpy,addr FileName,addr AltFileName
			invoke DllProc,hWin,AIM_EDITSAVE,hEdt,addr FileName,RAM_EDITSAVE
			.if eax
				invoke CloseHandle,hFile
				mov		eax,TRUE
				ret
			.endif
			invoke TabToolDel,hWin
			invoke SetWindowText,hWin,addr FileName
			;stream the text to the file
			mov		eax,hFile
			mov		editstream.dwCookie,eax
			mov		editstream.pfnCallback,offset StreamOutProc
			invoke SendMessage,hEdt,EM_STREAMOUT,SF_TEXT,addr editstream
			invoke TabToolAdd,hWin,offset FileName
			;Initialize the modify state to false
			invoke SendMessage,hEdt,EM_SETMODIFY,FALSE,0
			invoke SendMessage,hEdt,REM_SETCHANGEDSTATE,TRUE,0
			invoke CloseHandle,hFile
			invoke DllProc,hWin,AIM_EDITSAVED,hEdt,addr FileName,RAM_EDITSAVED
			xor		eax,eax
			ret
		.else
			invoke strcpy,addr LineTxt,addr SaveFileFail
			invoke strcat,addr LineTxt,addr AltFileName
			invoke MessageBox,hWin,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		.endif
	.else
		.if hEdit
			invoke SetFocus,hEdit
		.endif
	.endif
	mov		eax,TRUE
	ret

SaveEditAs endp

;########################################################################

BackupEdit proc uses esi edi,lpFileName:DWORD,nBackup:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	dotpos:DWORD

	.if Backup==0 || fProject==0
		ret
	.endif
	mov		esi,lpFileName
	invoke strlen,esi
	lea		edx,[esi+eax-1]
	.while byte ptr [edx] && byte ptr [edx]!='\'
		.if byte ptr [edx]=='.'
			mov		dotpos,edx
		.endif
		dec		edx
	.endw
	lea		edi,buffer2
  @@:
	cmp		esi,dotpos
	je		@f
	mov		al,[esi]
	or		al,al
	je		@f
	mov		[edi],al
	inc		esi
	inc		edi
	cmp		al,'\'
	jne		@b
	lea		edi,buffer2
	jmp		@b
  @@:
	mov		byte ptr [edi],0
	invoke strcpy,addr buffer,addr BackupPath
	invoke strcat,addr buffer,addr buffer2
	invoke strlen,addr buffer
	lea		edi,buffer
	add		edi,eax
	.if nBackup==1
		mov		al,'('
		mov		[edi],al
		inc		edi
		mov		al,'1'
		mov		[edi],al
		inc		edi
		mov		al,')'
		mov		[edi],al
		inc		edi
	.else
		mov		al,[edi-2]
		inc		al
		mov		[edi-2],al
	.endif
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		@b
	mov		eax,nBackup
	.if eax<Backup
		invoke GetFileAttributes,addr buffer
		.if eax!=-1
			;File exist
			mov		eax,nBackup
			inc		eax
			invoke BackupEdit,addr buffer,eax
		.endif
	.endif
	;Rename file
	invoke CopyFile,lpFileName,addr buffer,FALSE
	ret

BackupEdit endp

;########################################################################

GetLine proc hWin:HWND

	invoke SendMessage,hWin,EM_EXGETSEL,0,addr txtrng.chrg
	mov		eax,txtrng.chrg.cpMax
	mov		LineEn,eax
	invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,txtrng.chrg.cpMin
	invoke SendMessage,hWin,EM_LINEINDEX,eax,0
	mov		txtrng.chrg.cpMin,eax
	mov		LineSt,eax
	invoke SendMessage,hWin,EM_LINELENGTH,LineSt,0
	add		eax,LineSt
	mov		txtrng.chrg.cpMax,eax
	sub		eax,txtrng.chrg.cpMin
	.if eax>2047
		mov		eax,txtrng.chrg.cpMin
		add		eax,2047
		mov		txtrng.chrg.cpMax,eax
	.endif
	m2m		txtrng.lpstrText,offset LineTxt
	invoke SendMessage,hWin,EM_GETTEXTRANGE,0,addr txtrng
	ret

GetLine endp

GetWord proc
	mov		LineStart,esi
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,' '
	je		@b
	cmp		al,09h
	je		@b
	cmp		al,0Dh
	je		@b
	cmp		al,0Ah
	je		@b
	mov		ecx,255
  @@:
	mov		al,[esi]
	cmp		al,' '
	je		@f
	cmp		al,09h
	je		@f
	cmp		al,','
	je		@f
	cmp		al,'('
	je		@f
	cmp		al,'<'
	je		@f
	or		al,al
	je		@f
	mov		[edi],al
	inc		edi
	inc		esi
	dec		ecx
	jne		@b
  @@:
	mov		LinePos,esi
	xor		al,al
	mov		[edi],al
	ret

GetWord endp

GetWordFromPos proc uses esi edi,hWin:HWND

	invoke GetLine,hWin
	invoke SendMessage,hWin,EM_EXGETSEL,0,addr txtrng.chrg
	m2m		txtrng.chrg.cpMax,txtrng.chrg.cpMin
	invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,txtrng.chrg.cpMin
	invoke SendMessage,hWin,EM_LINEINDEX,eax,0
	mov		txtrng.chrg.cpMin,eax
	mov		edx,txtrng.chrg.cpMax
	sub		edx,txtrng.chrg.cpMin
	mov		esi,offset LineTxt
	add		esi,edx
	inc		esi
	inc		edx
	inc		edx
	xor		eax,eax
	dec		ah
  @@:
	inc		ah
	dec		esi
	dec		edx
	je		@f
	movzx	ecx,byte ptr [esi]
	add		ecx,lpCharTab
	movzx	ecx,byte ptr [ecx]
	dec		ecx
	je		@b
  @@:
	mov		edi,offset LineWord
	or		ah,ah
	je		Ex
	dec		edi
  @@:
	inc		esi
	inc		edi
	movzx	eax,byte ptr [esi]
	mov		[edi],al
	add		eax,lpCharTab
	movzx	eax,byte ptr [eax]
	dec		eax
	je		@b
  Ex:
	mov		al,0
	mov		[edi],al
	mov		eax,offset LineWord
	ret

GetWordFromPos endp

SetPath proc uses esi,lpPath:DWORD
	LOCAL	buffer[256]:BYTE

	invoke strcpy,addr buffer,lpPath
	invoke strlen,addr buffer
	.if eax
		lea		esi,buffer
		add		esi,eax
		dec		esi
		mov		al,[esi]
		.if al=='\'
			mov		al,0
			mov		[esi],al
		.endif
		invoke SetCurrentDirectory,addr buffer
	.endif
	ret

SetPath endp

;########################################################################
