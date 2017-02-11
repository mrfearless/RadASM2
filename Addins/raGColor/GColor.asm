include GColor.inc

.code
dw2hex proc source:DWORD, lpBuffer:DWORD

    push esi

    mov edx, lpBuffer
    mov esi, source

    xor eax, eax
    xor ecx, ecx

    mov [edx+8], al         ; put terminator at correct length
    mov cl, 7               ; length of hexstring - 1

  @@:
    mov eax, esi            ; we're going to work on AL
    and al, 00001111b       ; mask out high nibble

    cmp al,10
    sbb al,69h
    das

    mov [edx + ecx], al     ; store the asciihex(AL) in the string
    shr esi, 4              ; next nibble
    dec ecx                 ; decrease counter (one byte less than dec cl :-)
    jns @B                  ; eat them if there's any more

    pop esi

    ret

dw2hex endp

CreateTextFont proc hwnd:HWND
	
LOCAL ncm		:NONCLIENTMETRICS
LOCAL lf		:LOGFONT
LOCAL hdc		:HDC

	invoke GetDC,hwnd
	mov hdc,eax
	invoke RtlZeroMemory,addr lf,sizeof LOGFONT
	invoke GetDeviceCaps,hdc,LOGPIXELSY
	invoke MulDiv,8,eax,72
	neg eax 
	mov lf.lfHeight,eax
	mov lf.lfWeight,FW_NORMAL
	invoke lstrcpy,addr lf.lfFaceName,addr szFontName
	invoke CreateFontIndirect,addr lf
	push eax
	invoke ReleaseDC,hwnd,hdc
	pop eax
	ret

CreateTextFont endp

RegisterWindows proc hInst:HINSTANCE
	
LOCAL wc		:WNDCLASSEX

	mov wc.cbSize,sizeof WNDCLASSEX
	mov wc.style,CS_HREDRAW or CS_VREDRAW
	mov wc.cbClsExtra,NULL
	mov wc.cbWndExtra,NULL
	m2m wc.hInstance,hInst
	mov wc.hIcon,NULL
	mov wc.hCursor,NULL
	mov wc.hIconSm,NULL
	invoke LoadCursor,NULL,IDC_ARROW
	mov wc.hCursor,eax
	mov wc.lpszMenuName,NULL
	mov wc.hbrBackground,COLOR_WINDOW + 1
	mov wc.lpszClassName,offset szClrClass
	mov wc.lpfnWndProc,offset ClrProc
	invoke RegisterClassEx,addr wc
	mov wc.hbrBackground,COLOR_BTNFACE + 1
	mov wc.lpszClassName,offset szLblClass
	mov wc.lpfnWndProc,offset LblProc
	invoke RegisterClassEx,addr wc
	ret

RegisterWindows endp

DrawFRect proc hwnd:HWND
	
LOCAL rc		:RECT
LOCAL hdc		:HDC

	invoke GetWindowRect,hwnd,addr rc
	invoke MapWindowPoints,HWND_DESKTOP,hDialog,addr rc,2
	invoke InflateRect,addr rc,2,2
	invoke GetDC,hDialog
	mov hdc,eax
	invoke DrawFocusRect,hdc,addr rc
	invoke ReleaseDC,hDialog,hdc	
	ret

DrawFRect endp

ClrProc	proc hwnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
LOCAL hdc		:HDC
LOCAL ps		:PAINTSTRUCT
LOCAL rc		:RECT

	.if uMsg==WM_DESTROY
		invoke RemoveProp,hwnd,addr szSysColor
		invoke RemoveProp,hwnd,addr szSysBrush
	.elseif uMsg==WM_PAINT
		invoke BeginPaint,hwnd,addr ps
		mov hdc,eax
		invoke GetClientRect,hwnd,addr rc
		invoke GetProp,hwnd,addr szSysBrush
		invoke FillRect,hdc,addr rc,eax
		invoke EndPaint,hwnd,addr ps
	.elseif uMsg==WM_LBUTTONDOWN
		invoke SetFocus,hwnd
		invoke GetProp,hwnd,addr szSysColor
		invoke SendMessage,hDialog,SETRGBSTRING,0,eax
	.elseif uMsg==WM_SETFOCUS
		invoke DrawFRect,hwnd
	.elseif uMsg==WM_KILLFOCUS
		invoke DrawFRect,hwnd
	.else
		invoke DefWindowProc,hwnd,uMsg,wParam,lParam
		ret
	.endif
	
	xor eax,eax
	ret

ClrProc endp

LblProc	proc hwnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
LOCAL hdc		:HDC
LOCAL ps		:PAINTSTRUCT
LOCAL rc		:RECT
LOCAL pt		:POINT

	.if uMsg==WM_DESTROY
		invoke RemoveProp,hwnd,addr szCaption
	.elseif uMsg==WM_PAINT
		invoke BeginPaint,hwnd,addr ps
		mov hdc,eax
		invoke SetBkMode,hdc,TRANSPARENT
		invoke SelectObject,hdc,hFont
		invoke GetClientRect,hwnd,addr rc
		invoke GetProp,hwnd,addr szCaption
		mov ecx,eax
		invoke DrawText,hdc,ecx,-1,addr rc,DT_LEFT or DT_SINGLELINE or DT_VCENTER
		invoke EndPaint,hwnd,addr ps
	.else
		invoke DefWindowProc,hwnd,uMsg,wParam,lParam
		ret
	.endif
	
	xor eax,eax
	ret

LblProc endp

GetMeasures proc hwnd:HWND
	
LOCAL rc		:RECT
LOCAL pt 		:POINT
LOCAL hdc		:HDC

	invoke GetDC,hwnd
	mov hdc,eax
	invoke SaveDC,hdc
	invoke SelectObject,hdc,hFont
	invoke GetTextExtentPoint32,hdc,CTEXT("Hex Value"),9,addr pt
	m2m wHex,pt.x
	add wHex,8
	invoke GetTextExtentPoint32,hdc,CTEXT("Application workspace"),21,addr pt
	m2m lx,pt.x
	m2m ly,pt.y
	invoke RestoreDC,hdc,-1
	invoke ReleaseDC,hwnd,hdc
	invoke SetRect,addr rc,0,0,15,11
	invoke MapDialogRect,hwnd,addr rc
	m2m cxC,rc.right
	m2m cyC,rc.bottom
	mov eax,lx
	add eax,cxC
	add eax,10
	shl eax,1
	add eax,8
	
	ret

GetMeasures endp

CreatePair proc hwnd:HWND,lft:DWORD,crColor:COLORREF,lpRC:DWORD,lpText:LPSTR
	
LOCAL hTmp		:HWND

	push edi
	assume edi: ptr RECT
	mov edi,lpRC
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szClrClass,NULL,WS_CHILD or WS_TABSTOP or WS_VISIBLE,[edi].left,[edi].top,cxC,cyC,hwnd,NULL,hInstance,NULL
	mov hTmp,eax
	invoke GetSysColor,crColor
	invoke SetProp,hTmp,addr szSysColor,eax
	invoke GetSysColorBrush,crColor
	invoke SetProp,hTmp,addr szSysBrush,eax
	invoke CreateWindowEx,NULL,addr szLblClass,NULL,WS_CHILD or WS_VISIBLE,lft,[edi].top,lx,ly,hwnd,NULL,hInstance,NULL
	invoke SetProp,eax,addr szCaption,lpText
	assume edi: nothing
	pop edi
	ret

CreatePair endp

DrawColors proc hwnd:HWND,xStart:DWORD
	
LOCAL rc		:RECT
LOCAL hTmp		:HWND
LOCAL lft		:DWORD
LOCAL cHt		:DWORD
LOCAL cTp		:DWORD
LOCAL pt		:POINT
LOCAL hdc		:HDC

	invoke SetRect,addr rc,4,4,144,13
	invoke MapDialogRect,hwnd,addr rc
	m2m cTp,rc.top
	mov eax,rc.bottom
	sub eax,rc.top
	mov cHt,eax
	
	invoke SetRect,addr rc,280,4,288,120
	invoke MapDialogRect,hwnd,addr rc
	
	m2m rc.left,xStart
	mov eax,rc.left
	add eax,3
	add eax,cxC
	mov lft,eax
	
	invoke MapWindowPoints,HWND_DESKTOP,hwnd,addr rcTemp,2
	mov eax,rcTemp.bottom
	sub eax,rcTemp.top
	push eax
	invoke GetDC,hwnd
	mov hdc,eax
	invoke GetTextExtentPoint32,hdc,CTEXT("HEX Value"),9,addr pt
	invoke ReleaseDC,hwnd,hdc
	pop eax
	push eax
	invoke CreateWindowEx,NULL,addr szLblClass,NULL,WS_CHILD or WS_VISIBLE,rcTemp.left,rcTemp.top,pt.x,eax,hwnd,NULL,hInstance,NULL
	invoke SetProp,eax,addr szCaption,CTEXT("HEX Value")
	
	pop eax
	mov ecx,rcTemp.left
	add ecx,wHex
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,CTEXT("Edit"),NULL,WS_CHILD or WS_VISIBLE,ecx,rcTemp.top,lx,eax,hwnd,NULL,hInstance,NULL
	mov hHex,eax
	invoke SendMessage,hHex,WM_SETFONT,hFont,TRUE

	invoke CreateWindowEx,NULL,addr szLblClass,NULL,WS_CHILD or WS_VISIBLE,rc.left,cTp,lx,cHt,hwnd,NULL,hInstance,NULL
	invoke SetProp,eax,addr szCaption,CTEXT("System colors:")
	
	invoke GetDlgItem,hwnd,COLOR_BOX1
	mov hTmp,eax
	push rc.left
	invoke GetWindowRect,hTmp,addr rc
	invoke MapWindowPoints,HWND_DESKTOP,hwnd,addr rc,2
	pop rc.left
	push rc.top
	
	invoke CreatePair,hwnd,lft,COLOR_SCROLLBAR,addr rc,CTEXT("Scrollbar")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_BACKGROUND,addr rc,CTEXT("Desktop")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_ACTIVECAPTION,addr rc,CTEXT("Active caption")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_INACTIVECAPTION,addr rc,CTEXT("Inactive caption")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_MENU,addr rc,CTEXT("Menu")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_WINDOW,addr rc,CTEXT("Window")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_WINDOWFRAME,addr rc,CTEXT("Window frame")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_MENUTEXT,addr rc,CTEXT("Menu text")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_WINDOWTEXT,addr rc,CTEXT("Window text")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_CAPTIONTEXT,addr rc,CTEXT("Caption text")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_ACTIVEBORDER,addr rc,CTEXT("Active border")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_INACTIVEBORDER,addr rc,CTEXT("Inactive border")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_APPWORKSPACE,addr rc,CTEXT("Application workspace")
	mov eax,lft
	add eax,lx
	add eax,cxC
	add eax,8
	mov lft,eax
	
	sub eax,2
	sub eax,cxC
	mov rc.left,eax
	
	pop rc.top
	
	invoke CreatePair,hwnd,lft,COLOR_HIGHLIGHT,addr rc,CTEXT("Highlight")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_HIGHLIGHTTEXT,addr rc,CTEXT("Highlight text")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_BTNFACE,addr rc,CTEXT("Button face")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_BTNSHADOW,addr rc,CTEXT("Button shadow")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_GRAYTEXT,addr rc,CTEXT("Gray text")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_BTNTEXT,addr rc,CTEXT("Button text")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_INACTIVECAPTIONTEXT,addr rc,CTEXT("Inactive caption text")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_BTNHIGHLIGHT,addr rc,CTEXT("Button highlight")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_3DDKSHADOW,addr rc,CTEXT("3D dark shadow")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_3DLIGHT,addr rc,CTEXT("3D light")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	
	invoke CreatePair,hwnd,lft,COLOR_INFOTEXT,addr rc,CTEXT("Info text")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3

	invoke CreatePair,hwnd,lft,COLOR_INFOBK,addr rc,CTEXT("Info back")
	mov eax,cyC
	add rc.top,eax
	add rc.top,3
	ret

DrawColors endp

CCHookProc proc hwnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
LOCAL wp			:WINDOWPLACEMENT
LOCAL rc			:RECT
LOCAL hTmp			:HWND
LOCAL r				:DWORD
LOCAL g				:DWORD
LOCAL b				:DWORD

	.if uMsg==WM_INITDIALOG
;		invoke RegisterWindowMessage,addr ColorOK
;		mov COLOROKSTRING,eax
		invoke RegisterWindows,hInstance
		invoke CreateTextFont,hwnd
		mov hFont,eax
		invoke SetWindowText,hwnd,CTEXT("GColor")
		m2m hDialog,hwnd
		invoke RegisterWindowMessage,addr SetRGBColor
		mov SETRGBSTRING,eax
		mov wp.iLength,sizeof WINDOWPLACEMENT
		invoke GetWindowPlacement,hwnd,addr wp
		invoke CopyRect,addr rc,addr wp.rcNormalPosition
		invoke MapWindowPoints,HWND_DESKTOP,hwnd,addr rc,2
		invoke GetMeasures,hwnd
		add wp.rcNormalPosition.right,eax
		push rc.right
		invoke SetWindowPlacement,hwnd,addr wp
		invoke GetDlgItem,hwnd,COLOR_MIX
		mov hTmp,eax
		invoke ShowWindow,eax,SW_HIDE
		invoke GetWindowRect,hTmp,addr rc
		invoke MapWindowPoints,HWND_DESKTOP,hwnd,addr rc,2
		invoke GetDlgItem,hwnd,COLOR_ADD
		mov hTmp,eax
		invoke GetWindowRect,hTmp,addr rcTemp
		mov eax,rc.right
		sub eax,rc.left
		mov ecx,rc.bottom
		sub ecx,rc.top
		invoke MoveWindow,hTmp,rc.left,rc.top,eax,ecx,TRUE
		pop ecx
		invoke DrawColors,hwnd,ecx
		invoke GetDlgItem,hwnd,COLOR_RED
		invoke SendMessage,hwnd,WM_COMMAND,COLOR_RED,eax
	.elseif uMsg==WM_DESTROY
		invoke DeleteObject,hFont
	.else
		.if uMsg==WM_COMMAND
			LOWORD wParam
			.if eax==COLOR_RED || eax==COLOR_BLUE || eax==COLOR_GREEN
				invoke GetDlgItemInt,hwnd,COLOR_RED,FALSE,FALSE
				mov r,eax
				invoke GetDlgItemInt,hwnd,COLOR_GREEN,FALSE,FALSE
				mov g,eax
				invoke GetDlgItemInt,hwnd,COLOR_BLUE,FALSE,FALSE
				mov b,eax
				RGB r,g,b
				invoke SendMessage,hHex,WM_SETTEXT,0,formhex$(eax)
			.endif
		.endif
		mov eax,FALSE
	.endif
	
	ret

CCHookProc endp

ShowColors proc hOwner:HWND,crInitColor:COLORREF
	
LOCAL chc		:CHOOSECOLOR

	invoke RtlZeroMemory,addr chc,sizeof CHOOSECOLOR
	mov chc.lStructSize,sizeof CHOOSECOLOR
	m2m chc.hwndOwner,hOwner
	m2m chc.rgbResult,crInitColor
	mov chc.lpCustColors,offset CustColors
	mov chc.Flags,CC_FULLOPEN or CC_RGBINIT or CC_ENABLEHOOK
	mov chc.lpfnHook,offset CCHookProc
	invoke ChooseColor,addr chc
	ret

ShowColors endp

GetColor proc hOwner:HWND,crInitColor:COLORREF,lpResult:DWORD
	
LOCAL chc		:CHOOSECOLOR

	push edi
	invoke RtlZeroMemory,addr chc,sizeof CHOOSECOLOR
	mov chc.lStructSize,sizeof CHOOSECOLOR
	m2m chc.hwndOwner,hOwner
	m2m chc.rgbResult,crInitColor
	mov chc.lpCustColors,offset CustColors
	mov chc.Flags,CC_FULLOPEN or CC_RGBINIT or CC_ENABLEHOOK
	mov chc.lpfnHook,offset CCHookProc
	xor eax,eax
	invoke ChooseColor,addr chc
	.if eax
		mov edi,lpResult
		mov ecx,chc.rgbResult
		mov [edi],ecx
	.endif
	pop edi
	ret

GetColor endp

