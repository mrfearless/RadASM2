
.const

IDD_SNIPLETOPTION						equ 2200
IDC_CHKSELALL							equ 2201
IDC_RBNTOEDITOR							equ 2202
IDC_RBNTOCLIPBOARD						equ 2203
IDC_RBNTOOUTPUT							equ 2204
IDC_CHKCLOSE							equ 2205
IDC_CHKEXPANDED							equ 2206

.code

SnipletSave proc hWin:HWND

	invoke IsDlgButtonChecked,hWin,IDC_CHKSELALL
	.if eax
		mov		eax,TRUE
	.endif
	mov		fSelectAll,eax

	mov		nCopyTo,0
	invoke IsDlgButtonChecked,hWin,IDC_RBNTOCLIPBOARD
	.if eax
		mov		nCopyTo,1
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_RBNTOOUTPUT
	.if eax
		mov		nCopyTo,2
	.endif

	invoke IsDlgButtonChecked,hWin,IDC_CHKCLOSE
	.if eax
		mov		eax,TRUE
	.endif
	mov		fClose,eax

	invoke IsDlgButtonChecked,hWin,IDC_CHKEXPANDED
	.if eax
		mov		eax,TRUE
	.endif
	mov		fExpanded,eax

	invoke iniSnipletSave
	ret

SnipletSave endp

SnipletOptionProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_INITDIALOG
		mov		eax,BST_CHECKED
		.if !fSelectAll
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKSELALL,eax
		mov		eax,nCopyTo
		.if eax>2
			mov		eax,2
		.endif
		add		eax,IDC_RBNTOEDITOR
		invoke CheckRadioButton,hWin,IDC_RBNTOEDITOR,IDC_RBNTOOUTPUT,eax
		mov		eax,BST_CHECKED
		.if !fClose
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKCLOSE,eax
		mov		eax,BST_CHECKED
		.if !fExpanded
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKEXPANDED,eax

		invoke GetDlgItem,hWin,IDUSE
		invoke EnableWindow,eax,0
		invoke SetLanguage,hWin,IDD_SNIPLETOPTION,FALSE
	.elseif uMsg==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.elseif uMsg==WM_COMMAND
		mov eax,wParam
		mov edx,eax
		shr edx,16
		.if dx==BN_CLICKED
			.if ax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif ax==IDOK
				invoke SnipletSave,hWin
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif ax==IDUSE
				invoke SnipletSave,hWin
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,0
			.elseif ax==IDC_CHKEXPANDED || ax==IDC_CHKSELALL || ax==IDC_CHKCLOSE || ax==IDC_RBNTOEDITOR || ax==IDC_RBNTOCLIPBOARD || ax==IDC_RBNTOOUTPUT
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,TRUE
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

SnipletOptionProc endp

