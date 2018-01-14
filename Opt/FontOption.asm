;Opt\FontOption.dlg
IDD_OPTION_FONTS		equ 5100
IDC_BTNCODE				equ 1001
IDC_STCCODE				equ 1011
IDC_BTNTEXT				equ 1002
IDC_STCTEXT				equ 1012
IDC_BTNHEX				equ 1004
IDC_STCHEX				equ 1014
IDC_BTNLNR				equ 1005
IDC_STCLNR				equ 1015
IDC_STCDLG				equ 1008
IDC_BTNDLG				equ 1009
IDC_BTNTOOL				equ 1003
IDC_STCTOOL				equ 1013
IDC_BTNPRN				equ 1006
IDC_STCPRN				equ 1016
IDC_BTNIDE				equ 1017
IDC_STCIDE				equ 1010
IDC_BTNFONTAPPLY		equ 1007

.data?

lfntcode				LOGFONT <?>
lfnttxt					LOGFONT <?>
lfnthex					LOGFONT <?>
lfntlnr					LOGFONT <?>
lfntdlg					LOGFONT <?>
lfnttool				LOGFONT <?>
lfntprn					LOGFONT <?>
lfntide					LOGFONT <?>
font					FONTS <>

.code

FontChoose proc hWin:HWND,lf:DWORD,fStyle:DWORD,nColor:DWORD
    LOCAL hDC   :DWORD
    LOCAL cf    :CHOOSEFONT

    mov		cf.lStructSize,sizeof CHOOSEFONT
    invoke GetDC,hWin
    mov		hDC, eax
    mov		cf.hDC,eax
    m2m		cf.hWndOwner,hWin
    m2m		cf.lpLogFont,lf
    mov		cf.iPointSize,0
    m2m		cf.Flags,fStyle
	mov		eax,nColor
	mov		cf.rgbColors,eax
    mov		cf.lCustData,0
    mov		cf.lpfnHook,0
    mov		cf.lpTemplateName,0
    mov		cf.hInstance,0
    mov		cf.lpszStyle,0
    mov		cf.nFontType,0
    mov		cf.Alignment,0
    mov		cf.nSizeMin,0
    mov		cf.nSizeMax,0
    invoke ChooseFont,addr cf
    push	eax
    invoke ReleaseDC,hWin,hDC
    pop		eax
    .if eax
		mov		dl,10
    	mov		eax,cf.iPointSize
    	idiv	dl
    	and		eax,0FFh
		mov		edx,cf.rgbColors
    .endif
    ret

FontChoose endp

CreateCodeFont proc

	.if hFont
		invoke DeleteObject,hFont
		invoke DeleteObject,hFont[4]
		invoke DeleteObject,hFont[8]
	.endif
	invoke CreateFontIndirect,addr lfntcode
	mov     hFont,eax
	mov		al,lfntcode.lfItalic
	push	eax
	mov		lfntcode.lfItalic,TRUE
	invoke CreateFontIndirect,addr lfntcode
	mov     hFont[4],eax
	pop		eax
	mov		lfntcode.lfItalic,al
	invoke CreateFontIndirect,addr lfntlnr
	mov     hFont[8],eax
	ret

CreateCodeFont endp

UpdateToolFonts proc

	.if hLBFont
		invoke DeleteObject,hLBFont
	.endif
	invoke CreateFontIndirect,addr lfnttool
	mov     hLBFont,eax
	;Property
	mov		eax,hPrpCboCode
	call	UpdateToolFont
	mov		eax,hPrpCboDlg
	call	UpdateToolFont
	mov		eax,hPrpLstCode
	call	UpdateToolFont
	mov		eax,hPrpLstDlg
	call	UpdateToolFont
	mov eax, hPrpTxtDesc
	call UpdateToolFont
	mov		eax,hPrpTxt
	call	UpdateToolFont
	mov		eax,hPrpTxtMulti
	call	UpdateToolFont
	mov		eax,hTxtLst
	call	UpdateToolFont
	;Project
	mov		eax,hPbrTrv
	call	UpdateToolFont
	mov		eax,hFileTrv
	call	UpdateToolFont
	;Tab tool
	mov		eax,hTab
	call	UpdateToolFont
	;Info tool
	mov		eax,hInfEdt
	call	UpdateToolFont
	;Fake tooltip
	mov		eax,hTlt
	call	UpdateToolFont
	;Api listbox
	mov		eax,hLBU
	call	UpdateToolFont
	mov		eax,hLBS
	call	UpdateToolFont
	invoke ToolPropertySize,0
	ret

UpdateToolFont:
	invoke SendMessage,eax,WM_SETFONT,hLBFont,TRUE
	retn

UpdateToolFonts endp

;########################################################################

ApplyFonts proc fSaveFonts:DWORD

	.if fSaveFonts
		invoke GetObject,font.hFontCode,sizeof lfntcode,addr lfntcode
		invoke GetObject,font.hFontTxt,sizeof lfnttxt,addr lfnttxt
		invoke GetObject,font.hFontHex,sizeof lfnthex,addr lfnthex
		invoke GetObject,font.hFontLnr,sizeof lfntlnr,addr lfntlnr
		invoke GetObject,font.hFontDlg,sizeof lfntdlg,addr lfntdlg
		invoke GetObject,font.hFontTool,sizeof lfnttool,addr lfnttool
		invoke GetObject,font.hFontPrn,sizeof lfntprn,addr lfntprn
		invoke GetObject,font.hFontIde,sizeof lfntide,addr lfntide
		invoke iniEditSave
		invoke iniWinSaveFont
	.endif
	invoke CreateCodeFont
	invoke UpdateToolFonts
	.if hFontTxt
		invoke DeleteObject,hFontTxt
	.endif
	invoke CreateFontIndirect,addr lfnttxt
	mov     hFontTxt,eax
	.if hFontHex
		invoke DeleteObject,hFontHex
	.endif
	invoke CreateFontIndirect,addr lfnthex
	mov     hFontHex,eax
	.if hFontIde
		invoke DeleteObject,hFontIde
	.endif
	invoke CreateFontIndirect,addr lfntide
	mov     hFontIde,eax
	.if hSearch
		;IDD_FINDDLG
		invoke SetLanguage,hSearch,102,TRUE
	.endif
	.if hGoTo
		;IDD_GOTODLG
		invoke SetLanguage,hGoTo,103,TRUE
	.endif
	.if hSniplet
		;IDD_DLGSNIPLETS
		invoke SetLanguage,hSniplet,3100,TRUE
	.endif
	invoke UpdateAll,IDM_OPTION_FONTS
	invoke SetFormat,hOut1,hFont,hFont,hFont,FALSE
	invoke SetFormat,hOut2,hFont,hFont,hFont,FALSE
	invoke SetFormat,hOut3,hFont,hFont,hFont,FALSE
	ret

ApplyFonts endp

FontOptionProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	lf:LOGFONT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetLanguage,hWin,IDD_OPTION_FONTS,FALSE
		mov		eax,IDC_STCCODE
		mov		edx,hFont[0]
		call	MakeFont
		mov		font.hFontCode,eax
		mov		eax,IDC_STCTEXT
		mov		edx,hFontTxt
		call	MakeFont
		mov		font.hFontTxt,eax
		mov		eax,IDC_STCHEX
		mov		edx,hFontHex
		call	MakeFont
		mov		font.hFontHex,eax
		mov		eax,IDC_STCLNR
		mov		edx,hFont[8]
		call	MakeFont
		mov		font.hFontLnr,eax
		invoke CreateFontIndirect,addr lfntdlg
		push	eax
		mov		edx,eax
		mov		eax,IDC_STCDLG
		call	MakeFont
		mov		font.hFontDlg,eax
		pop		eax
		invoke DeleteObject,eax
		mov		eax,IDC_STCTOOL
		mov		edx,hLBFont
		call	MakeFont
		mov		font.hFontTool,eax
		invoke CreateFontIndirect,addr lfntprn
		push	eax
		mov		edx,eax
		mov		eax,IDC_STCPRN
		call	MakeFont
		mov		font.hFontPrn,eax
		pop		eax
		invoke DeleteObject,eax
		mov		eax,IDC_STCIDE
		mov		edx,hFontIde
		call	MakeFont
		mov		font.hFontIde,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetDlgItem,hWin,IDC_BTNFONTAPPLY
				invoke IsWindowEnabled,eax
				.if eax
					invoke ApplyFonts,TRUE
				.endif
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNFONTAPPLY
				invoke GetDlgItem,hWin,IDC_BTNFONTAPPLY
				invoke EnableWindow,eax,FALSE
				invoke ApplyFonts,TRUE
				invoke SetLanguage,hWin,IDD_OPTION_FONTS,TRUE
				mov		edx,IDC_STCCODE
				mov		eax,font.hFontCode
				call	SetFont
				mov		edx,IDC_STCTEXT
				mov		eax,font.hFontTxt
				call	SetFont
				mov		edx,IDC_STCHEX
				mov		eax,font.hFontHex
				call	SetFont
				mov		edx,IDC_STCLNR
				mov		eax,font.hFontLnr
				call	SetFont
				mov		edx,IDC_STCDLG
				mov		eax,font.hFontDlg
				call	SetFont
				mov		edx,IDC_STCTOOL
				mov		eax,font.hFontTool
				call	SetFont
				mov		edx,IDC_STCPRN
				mov		eax,font.hFontPrn
				call	SetFont
			.elseif eax==IDC_BTNCODE
				mov		eax,IDC_STCCODE
				mov		edx,font.hFontCode
				mov		ecx,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				call	GetFont
				mov		font.hFontCode,eax
			.elseif eax==IDC_BTNTEXT
				mov		eax,IDC_STCTEXT
				mov		edx,font.hFontTxt
				mov		ecx,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				call	GetFont
				mov		font.hFontTxt,eax
			.elseif eax==IDC_BTNHEX
				mov		eax,IDC_STCHEX
				mov		edx,font.hFontHex
				mov		ecx,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT or CF_FIXEDPITCHONLY
				call	GetFont
				mov		font.hFontHex,eax
			.elseif eax==IDC_BTNLNR
				mov		eax,IDC_STCLNR
				mov		edx,font.hFontLnr
				mov		ecx,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				call	GetFont
				mov		font.hFontLnr,eax
			.elseif eax==IDC_BTNDLG
				mov		eax,IDC_STCDLG
				mov		edx,font.hFontDlg
				mov		ecx,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				call	GetFont
				mov		font.hFontDlg,eax
			.elseif eax==IDC_BTNTOOL
				mov		eax,IDC_STCTOOL
				mov		edx,font.hFontTool
				mov		ecx,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				call	GetFont
				mov		font.hFontTool,eax
			.elseif eax==IDC_BTNPRN
				mov		eax,IDC_STCPRN
				mov		edx,font.hFontPrn
				mov		ecx,CF_PRINTERFONTS or CF_INITTOLOGFONTSTRUCT
				call	GetFont
				mov		font.hFontPrn,eax
			.elseif eax==IDC_BTNIDE
				mov		eax,IDC_STCIDE
				mov		edx,font.hFontIde
				mov		ecx,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				call	GetFont
				mov		font.hFontIde,eax
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke DeleteObject,font.hFontCode
		invoke DeleteObject,font.hFontTxt
		invoke DeleteObject,font.hFontHex
		invoke DeleteObject,font.hFontLnr
		invoke DeleteObject,font.hFontDlg
		invoke DeleteObject,font.hFontTool
		invoke DeleteObject,font.hFontPrn
		invoke DeleteObject,font.hFontIde
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

GetFont:
	push	eax	;ID
	push	edx	;FONT
	push	ecx
	invoke GetObject,edx,sizeof lf,addr lf
	pop		ecx
  @@:
	invoke FontChoose,hWin,addr lf,ecx,0
	.if eax
		invoke GetDlgItem,hWin,IDC_BTNFONTAPPLY
		invoke EnableWindow,eax,TRUE
		pop		edx
		invoke DeleteObject,edx
		pop		eax
		call	MakeFont1
	.else
		pop		eax
		pop		edx
	.endif
	retn

MakeFont:
	push	eax
	invoke GetObject,edx,sizeof lf,addr lf
	pop		eax
MakeFont1:
	push	eax
	invoke CreateFontIndirect,addr lf
	pop		edx
SetFont:
	push	eax
	push	edx
	push	edx
	mov		edx,eax
	invoke GetObject,edx,sizeof lf,addr lf
	pop		edx
	invoke SetDlgItemText,hWin,edx,addr lf.lfFaceName
	pop		edx
	pop		eax
	push	eax
	push	edx
	invoke SendDlgItemMessage,hWin,edx,WM_SETFONT,eax,FALSE
	pop		edx
	invoke GetDlgItem,hWin,edx
	invoke InvalidateRect,eax,NULL,TRUE
	pop		eax
	retn

FontOptionProc endp
