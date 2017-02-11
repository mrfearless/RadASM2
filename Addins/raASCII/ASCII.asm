include ASCII.inc

.code

DlgProc proc hwnd:HWND,umsg:UINT,wParam:WPARAM,lParam:LPARAM

LOCAL szBuffer[256]:BYTE

	.if umsg==WM_CLOSE
		invoke EraseArray
		invoke DestroyIcon,hIcon
		invoke DeleteObject,hMFont
		invoke DestroyWindow,hwnd
		;invoke EndDialog,hwnd,TRUE
	.elseif umsg==WM_PAINT
		.if ( !InPaint )
			invoke PaintASCII,hwnd
		.endif
	.elseif umsg==WM_INITDIALOG
;		invoke LoadCursor,hInstance,IDC_HAND
;		mov hCurHand,eax
;		invoke LoadCursor,hInstance,IDC_ARROW
;		mov hCurArrow,eax
		invoke LoadImage,hInstance,101,IMAGE_ICON,0,0,LR_DEFAULTSIZE
		mov hIcon,eax
		invoke SendMessage,hwnd,WM_SETICON,ICON_BIG,hIcon
		invoke CreateArray
		invoke InitRects,hwnd
		invoke DefineSizes,hwnd
		invoke SendDlgItemMessage,hwnd,IDC_RBN_HEX,BM_SETCHECK,BST_CHECKED,0
		mov wOutput,IDC_RBN_HEX
		invoke CreateStandardFont
		invoke ShowFontData,hwnd,m_LogFont.lfCharSet
		invoke SetWindowPos,hwnd,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.elseif umsg==WM_MOUSEMOVE
		.if ( !wParam )
			.if ( !InMove )
				invoke SelectCurrent,hwnd,lParam
			.endif
		.endif
	.elseif umsg==WM_COMMAND
		mov eax,wParam
		mov edx,eax
		shr edx,16
		.if dx==BN_CLICKED
			.if ax == IDC_BTN_CLEAR
				invoke SetDlgItemText,hwnd,IDC_EDT_CLIP,NULL
			.elseif ax == IDC_BTN_INSERT
				invoke InsertChars,hwnd
			.elseif ax == IDC_BTN_FONT
				invoke NewFont,hwnd
			.else
				mov wOutput,ax
			.endif
		.elseif dx == EN_CHANGE
			invoke SendDlgItemMessage,hwnd,IDC_EDT_CLIP,WM_GETTEXTLENGTH,0,0
			.if ( eax )
				invoke GetDlgItem,hwnd,IDC_BTN_CLEAR
				invoke EnableWindow,eax,TRUE
				invoke GetDlgItem,hwnd,IDC_BTN_INSERT
				invoke EnableWindow,eax,TRUE
			.else
				invoke GetDlgItem,hwnd,IDC_BTN_CLEAR
				invoke EnableWindow,eax,FALSE
				invoke GetDlgItem,hwnd,IDC_BTN_INSERT
				invoke EnableWindow,eax,FALSE
			.endif
		.endif	
	.elseif umsg==WM_LBUTTONDBLCLK
		.if (wParam == MK_LBUTTON)
			invoke TypeSelected,hwnd,lParam
		.endif
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret

DlgProc endp

;prints out selected character
TypeSelected proc hwnd:HWND,lParam:LPARAM
	
LOCAL pt:POINT
LOCAL szChar[16]:BYTE
LOCAL szTemp[256]:BYTE

	push edi
	push edx
	push ecx
	push ebx
	
	mov edi,rects
	assume edi: ptr ASCIIRECT
	
	mov edx,lParam
	movzx eax,dx
	mov pt.x,eax
	shr edx,16
	mov pt.y,edx
	
	mov ecx,UpperBound
	mov ebx,sizeof ASCIIRECT
	sub edi,ebx
	_loop:
		add edi,ebx
		push ecx
		invoke PtInRect,addr [edi].rc, pt.x ,pt.y
		.if ( eax )
			.if wOutput == IDC_RBN_HEX
				.if ([edi].index > 159)
					invoke wsprintf,addr szChar,addr FormatLongHex,[edi].index 
				.else
					invoke wsprintf,addr szChar,addr FormatHex,[edi].index 
				.endif
				invoke lstrcat,addr szChar,addr HSfx
			.elseif wOutput == IDC_RBN_OCT
				invoke byt2oct,byte ptr [edi].index,addr szChar
			.elseif wOutput == IDC_RBN_DEC
				invoke wsprintf,addr szChar,addr FormatDec,[edi].index 
			.elseif wOutput == IDC_RBN_BIN
				invoke byt2bin_ex,byte ptr [edi].index,addr szChar
				invoke lstrcat,addr szChar,addr BSfx
			.endif
			invoke GetDlgItemText,hwnd,IDC_EDT_CLIP,addr szTemp,255
			.if ( eax )
				invoke lstrcat,addr szTemp,addr Comma
				invoke lstrcat,addr szTemp,addr szChar
				invoke SetDlgItemText,hwnd,IDC_EDT_CLIP,addr szTemp
			.else
				invoke SetDlgItemText,hwnd,IDC_EDT_CLIP,addr szChar
			.endif
			pop ecx
			jmp _exit	
		.endif
		pop ecx
	dec ecx
	cmp ecx,0
	jge _loop
	
	_exit:
	assume edi: nothing
	
	pop ebx
	pop ecx
	pop edx
	pop edi
	
	ret

TypeSelected endp

;selects the rectangle under mouse cursor
SelectCurrent proc hwnd:HWND,lParam:LPARAM
	
LOCAL pt:POINT
LOCAL bFound:BOOL
LOCAL bInRects:BOOL
LOCAL szBuffer[256]:BYTE

	push edi
	push edx
	push ecx
	push ebx
	
	mov bInRects,FALSE
	mov bFound,FALSE
	mov InMove,TRUE

	mov edi,rects
	assume edi: ptr ASCIIRECT
	
	mov edx,lParam
	movzx eax,dx
	mov pt.x,eax
	shr edx,16
	mov pt.y,edx
	
	mov eax,dwRight
	mov edx,dwBottom
	
	.if (pt.x < 12 || pt.x > eax || pt.y < 12 || pt.y > edx)
		.if (RectCurrent != -1)
			invoke SetDlgItemText,hwnd,IDC_SBR_ASC,NULL
			push RectCurrent
			pop RectPrev
			mov RectCurrent,-1
			mov bFound,TRUE
			jmp _exit
		.endif
	.endif
	
	mov ecx,UpperBound
	mov ebx,sizeof ASCIIRECT
	sub edi,ebx
	_loop:
		add edi,ebx
		push ecx
		invoke PtInRect,addr [edi].rc, pt.x ,pt.y
		.if ( eax )
			mov bInRects,TRUE
			mov edx,[edi].index
			.if (edx != RectCurrent)
				.if edx < 33
					add edx,101
					invoke LoadString,hInstance,edx,addr szBuffer,255
					invoke SetDlgItemText,hwnd,IDC_SBR_ASC,addr szBuffer
				.else
					invoke SetDlgItemText,hwnd,IDC_SBR_ASC,NULL
				.endif
				push RectCurrent
				pop RectPrev
				push [edi].index
				pop RectCurrent
				mov bFound,TRUE
				pop ecx
				jmp _exit
			.endif		
		.endif
		pop ecx
	dec ecx
	cmp ecx,0
	jge _loop
	
	.if ( !bInRects )
		invoke PtInRect,addr rcBig,pt.x,pt.y
		.if ( eax )
			invoke SetDlgItemText,hwnd,IDC_SBR_ASC,NULL
			push RectCurrent
			pop RectPrev
			mov RectCurrent,-1
			mov bFound,TRUE
			jmp _exit
		.endif
	.endif
	
	_exit:
	assume edi: nothing
	.if ( bFound )
		invoke RedrawWindow,hwnd,NULL,NULL,TRUE
	.endif
	mov InMove,FALSE
	
	pop ebx
	pop ecx
	pop edx
	pop edi
	
	ret

SelectCurrent endp

;draws ASCII table
PaintASCII proc hwnd:HWND
local ps:PAINTSTRUCT
local hdc:HDC
local pt:POINT
local rc:RECT
local cnt:DWORD
LOCAL sz:DWORD
LOCAL br:HBRUSH
LOCAL szBuffer[256]:BYTE
LOCAL hSelBrush:HBRUSH
LOCAL penBlue:HPEN

	push edi
	push edx
	push ebx
	
	mov InPaint,TRUE
	invoke BeginPaint,hwnd,addr ps
	mov hdc,eax
	
	invoke SelectObject,hdc,hMFont
	invoke SetBkMode,hdc,TRANSPARENT
	invoke GetSysColorBrush,COLOR_BTNSHADOW
	mov br,eax
	mov sz,sizeof ASCIIRECT

	mov edi,rects
	assume edi: ptr ASCIIRECT
;	.if RectPrev != -1
;		invoke GetSysColorBrush,COLOR_BTNFACE
;		mov hSelBrush,eax
;		mov eax,RectPrev
;		mov edx,sz
;		mul edx
;		invoke FillRect,hdc,addr [edi+eax].rc,hSelBrush
;	.endif
;	.if RectCurrent != -1
;		invoke GetStockObject,WHITE_BRUSH
;		mov hSelBrush,eax
;		mov eax,RectCurrent
;		mov edx,sz
;		mul edx
;		invoke FillRect,hdc,addr [edi+eax].rc,hSelBrush
;	.endif
	push UpperBound
	pop cnt
	sub edi,sz
	_loop:
		add edi,sz
		invoke FrameRect,hdc,addr [edi].rc,br
		.if ([edi].index > 32 && [edi].index < 128)
			invoke SetTextColor,hdc,COLOR_BLUE
			invoke DrawText,hdc,addr [edi].index,1,addr [edi].rc,DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX or DT_NOCLIP
		.elseif ([edi].index > 127)
			invoke SetTextColor,hdc,COLOR_BROWN
			invoke DrawText,hdc,addr [edi].index,1,addr [edi].rc,DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX or DT_NOCLIP
		.else
			invoke SetTextColor,hdc,COLOR_GREEN
			mov edx,[edi].index
			inc edx
			invoke LoadString,hInstance,edx,addr szBuffer,255
			invoke DrawText,hdc,addr szBuffer,-1,addr [edi].rc,DT_CENTER or DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX or DT_NOCLIP
		.endif
	dec cnt
	cmp cnt,0
	jge _loop
	assume edi: nothing
	invoke EndPaint,hwnd,addr ps
	mov InPaint,FALSE
	
	pop ebx
	pop edx
	pop edi
	
	Ret
PaintASCII EndP

;inits array of rectangles
InitRects proc hwnd:HWND
	
LOCAL sz :DWORD
LOCAL ind:DWORD
LOCAL CellW:DWORD
LOCAL JumpW:DWORD
LOCAL CellH:DWORD
LOCAL JumpH:DWORD
LOCAL rc:RECT
LOCAL rc1:RECT
LOCAL rc2:RECT
LOCAL Handle:HWND

	push edi
	push edx
	push ecx
	push ebx
	
	invoke GetClientRect,hwnd,addr rc
	mov eax,rc.right
	sub eax,rc.left
	sub eax,22	;12 + 10
	shr eax,4
	sub eax,2
	mov CellW,eax
	mov JumpW,eax
	add JumpW,2
	
	invoke GetDlgItem,hwnd,IDC_GRP_OPTIONS
	mov Handle,eax
	invoke GetWindowRect,Handle,addr rc1
	invoke GetDlgItem,hwnd,IDC_SBR_ASC
	mov Handle,eax
	invoke GetWindowRect,Handle,addr rc2
	
	mov edx,rc1.bottom
	sub edx,rc1.top

	add edx,rc2.bottom
	sub edx,rc2.top
	mov eax,rc.bottom
	sub eax,rc.top
	sub eax,edx
	sub eax,22	;12 + 10
	shr eax,4
	sub eax,2
	mov CellH,eax
	mov JumpH,eax
	add JumpH,2
	
	mov ind,0
	;lea edi,rects
	mov edi,rects
	assume edi:ptr ASCIIRECT
	xor ecx,ecx
	xor eax,eax
	add eax,12
	mov sz,sizeof ASCIIRECT
	_loop1:
		xor ebx,ebx
		xor edx,edx
		add edx,12
		_loop2:
			mov [edi].rc.left,edx
			mov [edi].rc.top,eax
			push edx
			add edx,CellW
			mov [edi].rc.right,edx
			pop edx
			push eax
			add eax,CellH
			mov [edi].rc.bottom,eax
			pop eax
			push ind
			pop [edi].index
		inc ind
		add edx,JumpW
		add edi,sz
		inc ebx
		cmp ebx,16
		jl _loop2
	add eax,JumpH
	inc ecx
	cmp ecx,16
	jl _loop1
	
	sub edi,sz
	invoke SetRect,addr rcBig,12,12,[edi].rc.right,[edi].rc.bottom
	
	assume edi:nothing
	
	pop ebx
	pop ecx
	pop edx
	pop edi
	
	ret

InitRects endp

;stores needed sizes
DefineSizes proc hwnd:HWND
	
LOCAL sz :DWORD
LOCAL rc:RECT

	push edi
	
	mov edi,rects
	assume edi:ptr ASCIIRECT
	mov sz,sizeof ASCIIRECT
	
	mov eax,255
	mul sz
	push [edi+eax].rc.right
	pop dwRight
	push [edi+eax].rc.bottom
	pop dwBottom
	
	assume edi:nothing
	
	pop edi
	
	ret

DefineSizes endp

CreateStandardFont proc
	
LOCAL ncm:NONCLIENTMETRICS

	mov ncm.cbSize,sizeof NONCLIENTMETRICS
	invoke SystemParametersInfo,SPI_GETNONCLIENTMETRICS,sizeof NONCLIENTMETRICS,addr ncm,NULL
	invoke RtlMoveMemory,addr m_LogFont,addr ncm.lfMessageFont,sizeof LOGFONT
	invoke CreateFontIndirect,addr m_LogFont
	mov hMFont,eax
	ret

CreateStandardFont endp

;creates array for storing data
CreateArray proc
	
	push edx
	
	mov eax,256
	mov edx,sizeof ASCIIRECT
	mul edx
	
	invoke LocalAlloc,LMEM_ZEROINIT,eax
	mov hMem,eax
	invoke LocalLock,hMem
	mov rects,eax
	
	pop edx
	ret

CreateArray endp

;erases array of data and frees up memory
EraseArray proc
	
	invoke LocalUnlock,hMem
	invoke LocalFree,hMem
	mov hMem,0
	ret

EraseArray endp

;converts byte to octal characters
byt2oct proc var:BYTE,lpBuffer:LPSTR

	push esi
	push edx
	
	xor eax,eax
	mov esi,lpBuffer
	mov [esi+4],al
	mov dl,OSfx
	mov [esi+3],dl
	xor edx,edx
	mov al,var
	mov dl,var
	
	and al,00000111b
	add al,48
	mov [esi+2],al
	mov al,dl
	shr al,3
	and al,00000111b
	add al,48
	mov [esi+1],al
	mov al,dl
	shr al,6
	and al,00000111b
	add al,48
	mov [esi],al
	
	pop edx
	pop esi
	
	ret

byt2oct endp

;insert string into editor window
InsertChars proc hwnd:HWND

local hEditor:HWND
local chr:CHARRANGE
local szBuffer[256]:BYTE

	call clrOutput 
	invoke GetDlgItemText,hwnd,IDC_EDT_CLIP,addr szBuffer,255
	invoke TextOutput,addr szBuffer

	Ret
InsertChars EndP

NewFont proc hwnd:HWND
	
LOCAL hdc:HDC
LOCAL cf:CHOOSEFONT

	invoke RtlZeroMemory,addr cf,sizeof CHOOSEFONT
	mov cf.lStructSize,sizeof CHOOSEFONT
	invoke GetDC,hwnd
	mov hdc,eax
	push hdc
	pop cf.hDC
	
	push hwnd
	pop cf.hwndOwner
	
	push offset m_LogFont
	pop cf.lpLogFont
	
	mov cf.nSizeMin, 8
	mov cf.nSizeMax, 72
	
	mov cf.lpTemplateName, NULL
	mov cf.lpfnHook, NULL
	
	mov cf.Flags,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
	invoke ChooseFont,addr cf
	
	.if eax != 0
		invoke ShowFontData,hwnd,m_LogFont.lfCharSet
		invoke DeleteObject,hMFont
		invoke CreateFontIndirect,addr m_LogFont
		mov hMFont,eax
		invoke SendMessage,hwnd,WM_ERASEBKGND,hdc,0
		invoke RedrawWindow,hwnd,NULL,NULL,TRUE
		invoke ReleaseDC,hwnd,hdc
	.else
		invoke ReleaseDC,hwnd,hdc
	.endif
	
	ret

NewFont endp

ShowFontData proc hwnd:HWND,charset:DWORD
	
LOCAL szData[256]:BYTE

	empty$ szData,256
	invoke lstrcat,addr szData,addr m_LogFont.lfFaceName
	invoke lstrcat,addr szData,CADD(" - ")
	.if charset == DEFAULT_CHARSET
		invoke lstrcat,addr szData,CADD("Default")
	.elseif charset == SYMBOL_CHARSET
		invoke lstrcat,addr szData,CADD("Symbol")
	.elseif charset == OEM_CHARSET
		invoke lstrcat,addr szData,CADD("OEM")
	.elseif charset == ANSI_CHARSET
		invoke lstrcat,addr szData,CADD("ANSI")
	.elseif charset == RUSSIAN_CHARSET
		invoke lstrcat,addr szData,CADD("Cyrillic")
	.elseif charset == EE_CHARSET
		invoke lstrcat,addr szData,CADD("Central European")
	.elseif charset == GREEK_CHARSET
		invoke lstrcat,addr szData,CADD("Greek")
	.elseif charset == TURKISH_CHARSET
		invoke lstrcat,addr szData,CADD("Turkish")
	.elseif charset == BALTIC_CHARSET
		invoke lstrcat,addr szData,CADD("Baltic")
	.elseif charset == HEBREW_CHARSET
		invoke lstrcat,addr szData,CADD("Hebrew")
	.elseif charset == ARABIC_CHARSET
		invoke lstrcat,addr szData,CADD("Arabic")
	.elseif charset == SHIFTJIS_CHARSET
		invoke lstrcat,addr szData,CADD("Japanese")
	.elseif charset == HANGEUL_CHARSET
		invoke lstrcat,addr szData,CADD("Hangul")
	.elseif charset == GB2313_CHARSET
		invoke lstrcat,addr szData,CADD("Simplified Chinese")
	.elseif charset == CHINESEBIG5_CHARSET
		invoke lstrcat,addr szData,CADD("Traditional Chinese")
	.elseif charset == VIETNAMESE_CHARSET
		invoke lstrcat,addr szData,CADD("Vietnamese")
	.elseif charset == THAI_CHARSET
		invoke lstrcat,addr szData,CADD("Thai")
	.else
		invoke lstrcat,addr szData,CADD("Other")
	.endif
	
	invoke SetDlgItemText,hwnd,IDC_STC_FONT,addr szData
	
	ret

ShowFontData endp
