
IDD_DLGEDITOPTION			equ 2800
IDC_EDTBACKUP				equ 2801
IDC_SPNBACKUP				equ 2802
IDC_EDTTABSIZE				equ 2803
IDC_SPNTABSIZE				equ 2804
IDC_CHKAUTOSAVE				equ 2805
IDC_CHKAUTOLOAD				equ 2831
IDC_CHKTHREADBUILD			equ 2836
IDC_CHKAUTOINDENT			equ 2806
IDC_CHKAPILIST				equ 2807
IDC_CHKAPITOOLTIP			equ 2808
IDC_CHKSIZE					equ 2809
IDC_CHKPROPERTIES			equ 2810
IDC_CHKMAXIMIZE				equ 2811
IDC_CHKWHEEL				equ 2812
IDC_CHKAPICONST				equ 2813
IDC_CHKCODEMACRO			equ 2814
IDC_CHKTABTOSPC				equ 2815
IDC_CHKAPISTRUCT			equ 2816
IDC_CHKSINGLEINSTANCE		equ 2817
IDC_CHKAPIWORD				equ 2818
IDC_CHKAPILOCWORD			equ 2819
IDC_CHKTOPMOST				equ 2820
IDC_CHKPROCSTOAPI			equ 2822
IDC_CHKENTERONTAB			equ 2834
IDC_CHKPROCINSBAR			equ 2823
IDC_CHKOPENCOLL				equ 2830
IDC_CHKCODETOOLTIP			equ 2833
IDC_EDTCODEFILES			equ 2824
IDC_CHKLISTACTIVATE			equ 2829
IDC_CHKAUTOBRACKETS			equ 2832
IDC_CHKCHANGENOTIFY			equ 2837
IDC_CHKMINIMIZE				equ 2843

IDC_CHKLNR					equ 2821
IDC_EDTPAGESIZE				equ 2828
IDC_SPNPAGESIZE				equ 2827

IDC_RBNERR0					equ 2838
IDC_RBNERR1					equ 2839
IDC_RBNERR2					equ 2840
IDC_RBNERR3					equ 2841
IDC_RBNERR4					equ 2842

.code

EditOptionSave proc uses ebx,hWin:HWND

	invoke GetDlgItem,hWin,IDUSE
	invoke IsWindowEnabled,eax
	.if eax
		invoke GetDlgItemInt,hWin,IDC_EDTBACKUP,NULL,0 ;Get data value from edit box
		.if eax<0
			mov		eax,0
		.elseif eax>9
			mov		eax,9
		.endif
		mov		Backup,eax
		invoke GetDlgItemInt,hWin,IDC_EDTTABSIZE,NULL,0 ;Get data value from edit box
		.if eax<1
			mov		eax,1
		.elseif eax>20
			mov		eax,20
		.endif
		mov		TabSize,eax
		invoke GetDlgItemInt,hWin,IDC_EDTPAGESIZE,NULL,FALSE
		mov		nPageSize,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAUTOSAVE
		.if eax
			mov		eax,TRUE
		.endif
		mov		AutoSave,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAUTOLOAD
		.if eax
			mov		eax,TRUE
		.endif
		mov		fAutoLoadPro,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKTHREADBUILD
		.if eax
			mov		eax,TRUE
		.endif
		mov		make.fExecThread,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAUTOINDENT
		.if eax
			mov		eax,TRUE
		.endif
		mov		AutoIndent,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAPILIST
		.if eax
			mov		eax,TRUE
		.endif
		mov		ShowApiList,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAPITOOLTIP
		.if eax
			mov		eax,TRUE
		.endif
		mov		ShowApiToolTip,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKPROPERTIES
		.if eax
			mov		eax,TRUE
		.endif
		mov		ShowProperties,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKWHEEL
		.if eax
			mov		eax,TRUE
		.endif
		mov		MouseWheel,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKSIZE
		.if eax
			mov		eax,TRUE
		.endif
		mov		SaveSize,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKMAXIMIZE
		.if eax
			mov		eax,TRUE
		.endif
		mov		EditMax,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAPICONST
		.if eax
			mov		eax,TRUE
		.endif
		mov		ApiConst,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKCODEMACRO
		.if eax
			mov		eax,TRUE
		.endif
		mov		CodeWriteMacro,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKTABTOSPC
		.if eax
			mov		eax,TRUE
		.endif
		mov		TabToSpc,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAPISTRUCT
		.if eax
			mov		eax,TRUE
		.endif
		mov		ShowApiStruct,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKSINGLEINSTANCE
		.if eax
			mov		eax,TRUE
		.endif
		mov		SingleInstance,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAPIWORD
		.if eax
			mov		eax,TRUE
		.endif
		mov		ApiWordConv,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAPILOCWORD
		.if eax
			mov		eax,TRUE
		.endif
		mov		ApiWordLocal,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKTOPMOST
		.if eax
			mov		eax,TRUE
		.endif
		mov		winT,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKPROCSTOAPI
		.if eax
			mov		eax,TRUE
		.endif
		mov		fAutoRefresh,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKENTERONTAB
		.if eax
			mov		eax,TRUE
		.endif
		mov		fEnterOnTab,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKPROCINSBAR
		.if eax
			mov		eax,TRUE
		.endif
		mov		fProcInSBar,eax
		.if !eax
			invoke SendMessage,hStatus,SB_SETTEXT,3,addr szNULL
		.endif
		invoke GetDlgItemText,hWin,IDC_EDTCODEFILES,offset szCodeFiles,sizeof szCodeFiles
		invoke IsDlgButtonChecked,hWin,IDC_CHKLNR
		.if eax
			mov		eax,TRUE
		.endif
		mov		LnrOnOpen,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKLISTACTIVATE
		.if eax
			mov		eax,TRUE
		.endif
		mov		ApiShiftSpace,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKOPENCOLL
		.if eax
			mov		eax,TRUE
		.endif
		mov		fOpenCollapsed,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKAUTOBRACKETS
		.if eax
			mov		eax,TRUE
		.endif
		mov		fAutoBrackets,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKCODETOOLTIP
		.if eax
			mov		eax,TRUE
		.endif
		mov		fCodeTooltip,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKCHANGENOTIFY
		.if eax
			mov		eax,TRUE
		.endif
		mov		fChangeNotify,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKMINIMIZE
		.if eax
			mov		eax,TRUE
		.endif
		mov		fMinimize,eax
		mov		ebx,IDC_RBNERR0-1
		xor		eax,eax
		.while !eax && ebx<IDC_RBNERR4
			inc		ebx
			invoke IsDlgButtonChecked,hWin,ebx
		.endw
		sub		ebx,IDC_RBNERR0
		mov		fErrBookMark,ebx
		invoke iniEditSave
		invoke UpdateAll,IDM_OPTION_EDIT
	.endif
	ret

EditOptionSave endp

EditOptionProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_SPNBACKUP,UDM_SETRANGE,0,00000009h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_SPNBACKUP,UDM_SETPOS,0,Backup		; Set default value
		invoke SendDlgItemMessage,hWin,IDC_SPNTABSIZE,UDM_SETRANGE,0,00010014h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_SPNTABSIZE,UDM_SETPOS,0,TabSize		; Set default value
		invoke SendDlgItemMessage,hWin,IDC_SPNPAGESIZE,UDM_SETRANGE,0,000000C7h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_SPNPAGESIZE,UDM_SETPOS,0,nPageSize	; Set default value
		mov		eax,BST_CHECKED
		.if !AutoSave
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAUTOSAVE,eax
		mov		eax,BST_CHECKED
		.if !fAutoLoadPro
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAUTOLOAD,eax
		mov		eax,BST_CHECKED
		.if !make.fExecThread
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKTHREADBUILD,eax
		mov		eax,BST_CHECKED
		.if !AutoIndent
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAUTOINDENT,eax
		mov		eax,BST_CHECKED
		.if !ShowApiList
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAPILIST,eax
		mov		eax,BST_CHECKED
		.if !ShowApiToolTip
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAPITOOLTIP,eax
		mov		eax,BST_CHECKED
		.if !ShowProperties
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKPROPERTIES,eax
		mov		eax,BST_CHECKED
		.if !MouseWheel
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKWHEEL,eax
		mov		eax,BST_CHECKED
		.if !SaveSize
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKSIZE,eax
		mov		eax,BST_CHECKED
		.if !EditMax
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKMAXIMIZE,eax
		mov		eax,BST_CHECKED
		.if !ApiConst
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAPICONST,eax
		mov		eax,BST_CHECKED
		.if !CodeWriteMacro
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKCODEMACRO,eax
		mov		eax,BST_CHECKED
		.if !TabToSpc
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKTABTOSPC,eax
		mov		eax,BST_CHECKED
		.if !ShowApiStruct
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAPISTRUCT,eax
		mov		eax,BST_CHECKED
		.if !SingleInstance
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKSINGLEINSTANCE,eax
		mov		eax,BST_CHECKED
		.if !ApiWordConv
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAPIWORD,eax
		mov		eax,BST_CHECKED
		.if !ApiWordLocal
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAPILOCWORD,eax
		mov		eax,BST_CHECKED
		.if !winT
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKTOPMOST,eax
		mov		eax,BST_CHECKED
		.if !fAutoRefresh
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKPROCSTOAPI,eax
		mov		eax,BST_CHECKED
		.if !fEnterOnTab
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKENTERONTAB,eax
		mov		eax,BST_CHECKED
		.if !fProcInSBar
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKPROCINSBAR,eax
		mov		eax,BST_CHECKED
		.if !LnrOnOpen
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKLNR,eax
		mov		eax,BST_CHECKED
		.if !ApiShiftSpace
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKLISTACTIVATE,eax
		mov		eax,BST_CHECKED
		.if !fOpenCollapsed
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKOPENCOLL,eax
		mov		eax,BST_CHECKED
		.if !fAutoBrackets
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKAUTOBRACKETS,eax
		mov		eax,BST_CHECKED
		.if !fCodeTooltip
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKCODETOOLTIP,eax
		mov		eax,BST_CHECKED
		.if !fChangeNotify
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKCHANGENOTIFY,eax
		mov		eax,BST_CHECKED
		.if !fMinimize
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKMINIMIZE,eax

		invoke SendDlgItemMessage,hWin,IDC_EDTCODEFILES,EM_LIMITTEXT,sizeof szCodeFiles-1,0
		invoke SetDlgItemText,hWin,IDC_EDTCODEFILES,offset szCodeFiles
		mov		eax,fErrBookMark
		.if eax>4
			mov		eax,4
		.endif
		add		eax,IDC_RBNERR0
		invoke CheckRadioButton,hWin,IDC_RBNERR0,IDC_RBNERR4,eax
		invoke GetDlgItem,hWin,IDUSE
		invoke EnableWindow,eax,0
		invoke SetLanguage,hWin,IDD_DLGEDITOPTION,FALSE
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
				invoke EditOptionSave,hWin
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif ax==IDUSE
				invoke EditOptionSave,hWin
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,0
			.elseif ax==IDC_CHKAUTOSAVE || ax==IDC_CHKAUTOLOAD || ax==IDC_CHKAUTOINDENT || ax==IDC_CHKAPILIST || ax==IDC_CHKAPITOOLTIP || ax==IDC_CHKPROPERTIES || ax==IDC_CHKWHEEL || ax==IDC_CHKSIZE || ax==IDC_CHKMAXIMIZE || ax==IDC_CHKAPICONST || ax==IDC_CHKCODEMACRO || ax==IDC_CHKTABTOSPC || ax==IDC_CHKAPISTRUCT || ax==IDC_CHKSINGLEINSTANCE || ax==IDC_CHKAPIWORD || ax==IDC_CHKAPILOCWORD || ax==IDC_CHKTOPMOST
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,TRUE
			.elseif  ax==IDC_CHKPROCSTOAPI || ax==IDC_CHKPROCINSBAR || ax==IDC_CHKLNR || ax==IDC_CHKLISTACTIVATE || ax==IDC_CHKOPENCOLL || ax==IDC_CHKAUTOBRACKETS || ax==IDC_CHKCODETOOLTIP || ax==IDC_CHKENTERONTAB || ax==IDC_CHKTHREADBUILD || ax==IDC_CHKCHANGENOTIFY || ax==IDC_RBNERR0 || ax==IDC_RBNERR1 || ax==IDC_RBNERR2 || ax==IDC_RBNERR3 || ax==IDC_RBNERR4 || ax==IDC_CHKMINIMIZE
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,TRUE
			.endif
		.elseif dx==EN_CHANGE
			.if ax==IDC_EDTBACKUP || ax==IDC_EDTTABSIZE || ax==IDC_EDTCODEFILES || ax==IDC_EDTPAGESIZE
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,1
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

EditOptionProc endp

