
.const

IDD_DLGOPTION		equ 2600
IDC_EDTX			equ 2601
IDC_SPNX			equ 2602
IDC_EDTY			equ 2603
IDC_SPNY			equ 2604
IDC_STCCOLOR		equ 2613
IDC_EDTDLG			equ 2610
IDC_EDTCTRL			equ 2612
IDC_CHKSHOWGRID		equ 2605
IDC_CHKSNAPTOGRID	equ 2606
IDC_CHKSHOWSIZEPOS	equ 2607
IDC_CHKSAVERCFILE	equ 2608
IDC_CHKPROPERTY		equ 2609
IDC_CHKGRIDLINE		equ 2611
IDC_CHKFONT			equ 2619

.data?

color				dd ?
hGBr				dd ?

.code

OptDialogSave proc hWin:HWND

	invoke GetDlgItemInt,hWin,IDC_EDTX,NULL,FALSE
	mov		Gridcx,eax
	invoke GetDlgItemInt,hWin,IDC_EDTY,NULL,FALSE
	mov		Gridcy,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKSHOWGRID
	.if eax
		mov		eax,TRUE
	.endif
	mov		fGrid,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKSNAPTOGRID
	.if eax
		mov		eax,TRUE
	.endif
	mov		fSnapToGrid,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKSHOWSIZEPOS
	.if eax
		mov		eax,TRUE
	.endif
	mov		fShowSizePos,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKGRIDLINE
	.if eax
		mov		eax,TRUE
	.endif
	mov		fGridLine,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKSAVERCFILE
	.if eax
		mov		eax,TRUE
	.endif
	mov		fSaveRcFile,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKPROPERTY
	.if eax
		mov		eax,TRUE
	.endif
	mov		fSimpleProperty,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKFONT
	.if eax
		mov		eax,TRUE
	.endif
	mov		fLimittedFont,eax
	invoke GetDlgItemInt,hWin,IDC_EDTDLG,NULL,FALSE
	.if !eax
		inc		eax
	.endif
	mov		DlgIDN,eax
	invoke GetDlgItemInt,hWin,IDC_EDTCTRL,NULL,FALSE
	.if !eax
		inc		eax
	.endif
	mov		CtrlIDN,eax
	mov		eax,color
	mov		GridColor,eax
	invoke MakeGridBrush
	invoke UpdateAll,IDM_FORMAT_SHOWGRID
	invoke iniDialogSave
	ret

OptDialogSave endp

OptDialogProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM, lParam:LPARAM
	LOCAL	cc:CHOOSECOLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,GridColor
		mov		color,eax
		invoke CreateSolidBrush,eax
		mov		hGBr,eax
		invoke SendDlgItemMessage,hWin,IDC_SPNX,UDM_SETRANGE,0,00020014h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_SPNX,UDM_SETPOS,0,Gridcx			; Set default value
		invoke SendDlgItemMessage,hWin,IDC_SPNY,UDM_SETRANGE,0,00020014h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_SPNY,UDM_SETPOS,0,Gridcy			; Set default value
		mov		eax,BST_CHECKED
		.if !fGrid
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKSHOWGRID,eax
		mov		eax,BST_CHECKED
		.if !fSnapToGrid
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKSNAPTOGRID,eax
		mov		eax,BST_CHECKED
		.if !fGridLine
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKGRIDLINE,eax
		mov		eax,BST_CHECKED
		.if !fShowSizePos
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKSHOWSIZEPOS,eax
		mov		eax,BST_CHECKED
		.if !fSaveRcFile
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKSAVERCFILE,eax
		mov		eax,BST_CHECKED
		.if !fSimpleProperty
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKPROPERTY,eax
		mov		eax,BST_CHECKED
		.if !fLimittedFont
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKFONT,eax
		invoke SendDlgItemMessage,hWin,IDC_EDTDLG,EM_LIMITTEXT,5,0
		invoke SetDlgItemInt,hWin,IDC_EDTDLG,DlgIDN,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTCTRL,EM_LIMITTEXT,5,0
		invoke SetDlgItemInt,hWin,IDC_EDTCTRL,CtrlIDN,FALSE
		invoke GetDlgItem,hWin,IDUSE
		invoke EnableWindow,eax,0
		invoke SetLanguage,hWin,IDD_DLGOPTION,FALSE
	.elseif eax==WM_CLOSE
		invoke DeleteObject,hGBr
		invoke EndDialog,hWin,NULL
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDOK
				invoke OptDialogSave,hWin
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDUSE
				invoke OptDialogSave,hWin
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,0
			.elseif eax==IDC_CHKSHOWGRID || eax==IDC_CHKSNAPTOGRID || eax==IDC_CHKSHOWSIZEPOS || eax==IDC_CHKSAVERCFILE || eax==IDC_CHKPROPERTY || eax==IDC_CHKGRIDLINE || eax==IDC_CHKFONT
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,TRUE
			.elseif eax==IDC_STCCOLOR
				mov		cc.lStructSize,sizeof CHOOSECOLOR
				mov		eax,hWin
				mov		cc.hwndOwner,eax
				mov		eax,hInstance
				mov		cc.hInstance,eax
				mov		cc.lpCustColors,offset CustColors
				mov		cc.Flags,CC_FULLOPEN or CC_RGBINIT
				mov		cc.lCustData,0
				mov		cc.lpfnHook,0
				mov		cc.lpTemplateName,0
				mov		eax,color
				mov		cc.rgbResult,eax
				invoke ChooseColor,addr cc
				.if eax
					invoke DeleteObject,hGBr
					mov		eax,cc.rgbResult
					mov		color,eax
					invoke CreateSolidBrush,eax
					mov		hGBr,eax
					invoke GetDlgItem,hWin,IDC_STCCOLOR
					invoke InvalidateRect,eax,NULL,TRUE
					invoke GetDlgItem,hWin,IDUSE
					invoke EnableWindow,eax,1
				.endif
			.endif
		.elseif dx==EN_CHANGE
			.if eax==IDC_EDTX || eax==IDC_EDTY || eax==IDC_EDTDLG || eax==IDC_EDTCTRL
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,1
			.endif
		.endif
	.elseif eax==WM_DRAWITEM
		mov		edx,lParam
		invoke FillRect,[edx].DRAWITEMSTRUCT.hdc,addr [edx].DRAWITEMSTRUCT.rcItem,hGBr
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

OptDialogProc endp

