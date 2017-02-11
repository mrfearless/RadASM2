
.code

;Used for debuging
hexOut proc val:DWORD
	
	pushad
	push	val
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpHexOut
	popad
	ret

hexOut endp

txtOut proc lpTxt:DWORD

	pushad
	push	lpTxt
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpTextOut
	popad
	ret

txtOut endp

ReadFromIni proc lpKey:DWORD

	invoke GetPrivateProfileInt,addr szReallyRad,lpKey,TRUE,lpIniFile
	ret

ReadFromIni endp

ReadOptions proc

	invoke ReadFromIni,offset szAddDlg
	mov		fAddDlg,eax
	invoke ReadFromIni,offset szAddMnu
	mov		fAddMnu,eax
	invoke ReadFromIni,offset szAddRes
	mov		fAddRes,eax
	invoke ReadFromIni,offset szAddFile
	mov		fAddFile,eax
	invoke ReadFromIni,offset szAddFolder
	mov		fAddFolder,eax

	invoke ReadFromIni,offset szAddAclRc
	mov		fAddAclRc,eax
	invoke ReadFromIni,offset szAddResRc
	mov		fAddResRc,eax
	invoke ReadFromIni,offset szAddStrRc
	mov		fAddStrRc,eax
	invoke ReadFromIni,offset szAddVerRc
	mov		fAddVerRc,eax
	invoke ReadFromIni,offset szAddLngRc
	mov		fAddLngRc,eax

	invoke ReadFromIni,offset szCtlClk
	mov		fCtlClk,eax
	invoke ReadFromIni,offset szMnuSel
	mov		fMnuSel,eax
	invoke ReadFromIni,offset szCtlNme
	mov		fCtlNme,eax
	invoke ReadFromIni,offset szModBuild
	mov		fModBuild,eax
	ret

ReadOptions endp

SaveToIni proc val:DWORD,lpKey:DWORD
	LOCAL	buffer[16]:BYTE

	mov		eax,val
	.if eax
		mov		word ptr buffer,'1'
	.else
		mov		word ptr buffer,'0'
	.endif
	invoke WritePrivateProfileString,addr szReallyRad,lpKey,addr buffer,lpIniFile
	ret

SaveToIni endp

SaveOptions proc

	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDDLG
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddDlg,eax
	invoke SaveToIni,eax,offset szAddDlg
	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDMNU
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddMnu,eax
	invoke SaveToIni,eax,offset szAddMnu
	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDRES
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddRes,eax
	invoke SaveToIni,eax,offset szAddRes

	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDACLRC
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddAclRc,eax
	invoke SaveToIni,eax,offset szAddAclRc
	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDRESRC
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddResRc,eax
	invoke SaveToIni,eax,offset szAddResRc
	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDSTRRC
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddStrRc,eax
	invoke SaveToIni,eax,offset szAddStrRc
	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDVERRC
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddVerRc,eax
	invoke SaveToIni,eax,offset szAddVerRc
	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDLNGRC
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddLngRc,eax
	invoke SaveToIni,eax,offset szAddLngRc

	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDFILE
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddFile,eax
	invoke SaveToIni,eax,offset szAddFile
	invoke IsDlgButtonChecked,hTabDlg,IDC_CHKADDFOLDER
	.if eax
		mov		eax,TRUE
	.endif
	mov		fAddFolder,eax
	invoke SaveToIni,eax,offset szAddFolder
	invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKCTLCLK
	.if eax
		mov		eax,TRUE
	.endif
	mov		fCtlClk,eax
	invoke SaveToIni,eax,offset szCtlClk
	invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKMNUSEL
	.if eax
		mov		eax,TRUE
	.endif
	mov		fMnuSel,eax
	invoke SaveToIni,eax,offset szMnuSel
	invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKCTLNME
	.if eax
		mov		eax,TRUE
	.endif
	mov		fCtlNme,eax
	invoke SaveToIni,eax,offset szCtlNme
	invoke IsDlgButtonChecked,hTabDlg[4],IDC_CHKMODBUILD
	.if eax
		mov		eax,TRUE
	.endif
	mov		fModBuild,eax
	invoke SaveToIni,eax,offset szModBuild
	ret

SaveOptions endp

EnableUse proc fEnable:DWORD

	invoke GetDlgItem,hDlg,IDUSE
	invoke EnableWindow,eax,fEnable
	ret

EnableUse endp

Tab1Proc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

	.if uMsg==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_CHKADDDLG
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKADDMNU
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKADDRES
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKADDFILE
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKADDFOLDER
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKADDACLRC
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKADDRESRC
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKADDSTRRC
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKADDVERRC
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKADDLNGRC
				invoke EnableUse,TRUE
			.endif
		.endif
	.elseif uMsg==WM_INITDIALOG
		push	TRUE
		push	offset szReallyRad
		push	hWin
		mov		eax,lpPStruct
		call	[eax].ADDINPROCS.lpSetLanguage
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab1Proc endp

Tab2Proc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

	.if uMsg==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_CHKCTLCLK
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKMNUSEL
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKCTLNME
				invoke EnableUse,TRUE
			.elseif eax==IDC_CHKMODBUILD
				invoke EnableUse,TRUE
			.endif
		.endif
	.elseif uMsg==WM_INITDIALOG
		push	TRUE
		push	offset szReallyRad
		push	hWin
		mov		eax,lpPStruct
		call	[eax].ADDINPROCS.lpSetLanguage
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab2Proc endp

Tab3Proc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

	.if uMsg==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		.if edx==BN_CLICKED
;			.if eax==IDC_CHKCTLCLK
;				invoke EnableUse,TRUE
;			.elseif eax==IDC_CHKMNUSEL
;				invoke EnableUse,TRUE
;			.elseif eax==IDC_CHKCTLNME
;				invoke EnableUse,TRUE
;			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab3Proc endp

Tab4Proc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

	.if uMsg==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		.if edx==BN_CLICKED
;			.if eax==IDC_CHKCTLCLK
;				invoke EnableUse,TRUE
;			.elseif eax==IDC_CHKMNUSEL
;				invoke EnableUse,TRUE
;			.elseif eax==IDC_CHKCTLNME
;				invoke EnableUse,TRUE
;			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Tab4Proc endp

OptionDlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL	ts:TC_ITEM

	.if uMsg==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		and		eax,0FFFFh
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDOK
				invoke SaveOptions
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDUSE
				invoke SaveOptions
				invoke EnableUse,FALSE
			.endif
		.endif
	.elseif uMsg==WM_NOTIFY
		mov		edx,lParam
		mov		eax,(NMHDR PTR [edx]).code
		.if eax==TCN_SELCHANGE
			invoke SendDlgItemMessage,hWin,IDC_TAB1,TCM_GETCURSEL,0,0
			.if eax!=WhichTabChosen
				push	eax
				mov		eax,WhichTabChosen
				mov		eax,[hTabDlg+eax*4]
				invoke ShowWindow,eax,SW_HIDE
				pop		eax
				mov		WhichTabChosen,eax
				mov		eax,[hTabDlg+eax*4]
				invoke ShowWindow,eax,SW_SHOWDEFAULT
			.endif
		.endif
	.elseif uMsg==WM_INITDIALOG
		mov		eax,hWin
		mov		hDlg,eax
		invoke GetDlgItem,hWin,IDC_TAB1
		mov		hTab,eax
		mov		ts.imask,TCIF_TEXT
		mov		ts.lpReserved1,0			
		mov		ts.lpReserved2,0
		mov		ts.pszText,offset TabTitle1
		mov		ts.cchTextMax,sizeof TabTitle1
		mov		ts.iImage,0
		mov		ts.lParam,0
		invoke SendMessage,hTab,TCM_INSERTITEM,0,addr ts
		mov		ts.pszText,offset TabTitle2
		mov		ts.cchTextMax,sizeof TabTitle2
		invoke SendMessage,hTab,TCM_INSERTITEM,1,addr ts

;		mov		ts.pszText,offset TabTitle3
;		mov		ts.cchTextMax,sizeof TabTitle3
;		invoke SendMessage,hTab,TCM_INSERTITEM,2,addr ts
;		mov		ts.pszText,offset TabTitle4
;		mov		ts.cchTextMax,sizeof TabTitle4
;		invoke SendMessage,hTab,TCM_INSERTITEM,3,addr ts

		invoke CreateDialogParam,hInstance,IDD_TABOPT1,hTab,addr Tab1Proc,0
		mov		hTabDlg,eax
		invoke CreateDialogParam,hInstance,IDD_TABOPT2,hTab,addr Tab2Proc,0
		mov		hTabDlg[4],eax
		invoke CreateDialogParam,hInstance,IDD_TABOPT3,hTab,addr Tab3Proc,0
		mov		hTabDlg[8],eax
		invoke CreateDialogParam,hInstance,IDD_TABOPT4,hTab,addr Tab4Proc,0
		mov		hTabDlg[12],eax
		mov		WhichTabChosen,0
		.if fAddDlg
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDDLG,BST_CHECKED
		.endif
		.if fAddMnu
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDMNU,BST_CHECKED
		.endif
		.if fAddRes
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDRES,BST_CHECKED
		.endif
		.if fAddFile
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDFILE,BST_CHECKED
		.endif
		.if fAddFolder
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDFOLDER,BST_CHECKED
		.endif
		.if fAddAclRc
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDACLRC,BST_CHECKED
		.endif
		.if fAddResRc
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDRESRC,BST_CHECKED
		.endif
		.if fAddStrRc
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDSTRRC,BST_CHECKED
		.endif
		.if fAddVerRc
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDVERRC,BST_CHECKED
		.endif
		.if fAddLngRc
			invoke CheckDlgButton,hTabDlg,IDC_CHKADDLNGRC,BST_CHECKED
		.endif
		invoke ShowWindow,hTabDlg,SW_SHOWDEFAULT
		.if fCtlClk
			invoke CheckDlgButton,hTabDlg[4],IDC_CHKCTLCLK,BST_CHECKED
		.endif
		.if fMnuSel
			invoke CheckDlgButton,hTabDlg[4],IDC_CHKMNUSEL,BST_CHECKED
		.endif
		.if fCtlNme
			invoke CheckDlgButton,hTabDlg[4],IDC_CHKCTLNME,BST_CHECKED
		.endif
		.if fModBuild
			invoke CheckDlgButton,hTabDlg[4],IDC_CHKMODBUILD,BST_CHECKED
		.endif
		push	TRUE
		push	offset szReallyRad
		push	hWin
		mov		eax,lpPStruct
		call	[eax].ADDINPROCS.lpSetLanguage
	.elseif uMsg==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

OptionDlgProc endp
