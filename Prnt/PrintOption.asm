
IDD_DLGPRINTOPTION	equ 3500
IDC_RBNPN1			equ 3501
IDC_RBNPN2			equ 3502
IDC_RBNPN3			equ 3503
IDC_RBNPN4			equ 3504
IDC_CHKPNTS			equ 3505
IDC_RBNPH1			equ 3506
IDC_RBNPH2			equ 3507
IDC_RBNPH3			equ 3508
IDC_RBNPH4			equ 3509
IDC_CHKPHPD			equ 3510
IDC_CHKUSECOLORS	equ 3511
IDC_LSTPRNKW		equ 3512

.data

szPrnSyntax			db 'Text',0
					db 'Comment',0
					db 'String',0
					db 'Operator',0
					db 'Heading',0
					db 'Group#00',0
					db 'Group#01',0
					db 'Group#02',0
					db 'Group#03',0
					db 'Group#04',0
					db 'Group#05',0
					db 'Group#06',0
					db 'Group#07',0
					db 'Group#08',0
					db 'Group#09',0
					db 'Group#10',0
					db 'Group#11',0
					db 'Group#12',0
					db 'Group#13',0
					db 'Group#14',0
					db 'Group#15',0,0

.code

PrintSaveProc proc hWin:HWND
	LOCAL	nInx:DWORD

	invoke GetDlgItem,hWin,IDUSE
	invoke IsWindowEnabled,eax
	.if eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKPNTS
		.if eax
			mov		eax,TRUE
		.endif
		mov		PrnTime,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKPHPD
		.if eax
			mov		eax,TRUE
		.endif
		mov		PrnProDes,eax
		invoke IsDlgButtonChecked,hWin,IDC_CHKUSECOLORS
		.if eax
			mov		eax,TRUE
		.endif
		mov		PrnUseColors,eax
		mov		eax,IDC_RBNPN1
		mov		edx,0
		.while eax<=IDC_RBNPN4
			push	eax
			push	edx
			invoke IsDlgButtonChecked,hWin,eax
			pop		edx
			.if eax
				mov		PrnPageNumber,edx
			.endif
			pop		eax
			inc		edx
			inc		eax
		.endw
		mov		eax,IDC_RBNPH1
		mov		edx,0
		.while eax<=IDC_RBNPH4
			push	eax
			push	edx
			invoke IsDlgButtonChecked,hWin,eax
			pop		edx
			.if eax
				mov		PrnHeading,edx
			.endif
			pop		eax
			inc		edx
			inc		eax
		.endw
		push	edi
		mov		edi,offset PrnColors
		mov		nInx,0
		.while nInx<5+16
			invoke SendDlgItemMessage,hWin,IDC_LSTPRNKW,LB_GETITEMDATA,nInx,0
			mov		[edi],eax
			add		edi,4
			inc		nInx
		.endw
		pop		edi
		invoke iniEditSave
		invoke iniColSave
	.endif
	ret

PrintSaveProc endp

PrintOptionProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hBr:DWORD
	LOCAL	rect:RECT
	LOCAL	buffer[32]:BYTE
	LOCAL	cc:CHOOSECOLOR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	esi
		push	edi
		mov		esi,offset szPrnSyntax
		mov		edi,offset PrnColors
	  @@:
		invoke SendDlgItemMessage,hWin,IDC_LSTPRNKW,LB_ADDSTRING,0,esi
		invoke SendDlgItemMessage,hWin,IDC_LSTPRNKW,LB_SETITEMDATA,eax,[edi]
		add		edi,4
		invoke strlen,esi
		add		esi,eax
		inc		esi
		mov		al,[esi]
		or		al,al
		jne		@b
		mov		eax,PrnPageNumber
		add		eax,IDC_RBNPN1
		invoke CheckDlgButton,hWin,eax,BST_CHECKED
		mov		eax,PrnHeading
		add		eax,IDC_RBNPH1
		invoke CheckDlgButton,hWin,eax,BST_CHECKED
		mov		eax,PrnTime
		.if eax
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKPNTS,eax
		mov		eax,PrnProDes
		.if eax
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKPHPD,eax
		mov		eax,PrnUseColors
		.if eax
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKUSECOLORS,eax
		pop		edi
		pop		esi
		invoke GetDlgItem,hWin,IDC_RBNPN1
		invoke SetFocus,eax
		invoke GetDlgItem,hWin,IDUSE
		invoke EnableWindow,eax,FALSE
		invoke SetLanguage,hWin,IDD_DLGPRINTOPTION,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke PrintSaveProc,hWin
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDUSE
				invoke PrintSaveProc,hWin
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,FALSE
			.elseif eax>=IDC_RBNPN1 && eax<=IDC_CHKUSECOLORS
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,TRUE
			.endif
		.elseif edx==LBN_DBLCLK
			.if eax==IDC_LSTPRNKW
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
				invoke SendDlgItemMessage,hWin,IDC_LSTPRNKW,LB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_LSTPRNKW,LB_GETITEMDATA,eax,0
				push	eax
				;Mask off group/font
				and		eax,0FFFFFFh
				mov		cc.rgbResult,eax
				invoke ChooseColor,addr cc
				pop		ecx
				.if eax
					push	ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTPRNKW,LB_GETCURSEL,0,0
					pop		ecx
					mov		edx,cc.rgbResult
					;Group/Font
					and		ecx,0FF000000h
					or		edx,ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTPRNKW,LB_SETITEMDATA,eax,edx
					invoke GetDlgItem,hWin,IDC_LSTPRNKW
					invoke InvalidateRect,eax,NULL,FALSE
					invoke GetDlgItem,hWin,IDUSE
					invoke EnableWindow,eax,TRUE
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		test	[esi].itemState,ODS_SELECTED
		.if ZERO?
			push	COLOR_WINDOW
			mov		eax,COLOR_WINDOWTEXT
		.else
			push	COLOR_HIGHLIGHT
			mov		eax,COLOR_HIGHLIGHTTEXT
		.endif
		invoke GetSysColor,eax
		invoke SetTextColor,[esi].hdc,eax
		pop		eax
		invoke GetSysColor,eax
		invoke SetBkColor,[esi].hdc,eax
		invoke ExtTextOut,[esi].hdc,0,0,ETO_OPAQUE,addr [esi].rcItem,NULL,0,NULL
		mov		eax,[esi].rcItem.left
		inc		eax
		mov		rect.left,eax
		add		eax,25
		mov		rect.right,eax
		mov		eax,[esi].rcItem.top
		inc		eax
		mov		rect.top,eax
		mov		eax,[esi].rcItem.bottom
		dec		eax
		mov		rect.bottom,eax
		mov		eax,[esi].itemData
		and		eax,0FFFFFFh
		invoke CreateSolidBrush,eax
		mov		hBr,eax
		invoke FillRect,[esi].hdc,addr rect,hBr
		invoke DeleteObject,hBr
		invoke GetStockObject,BLACK_BRUSH
		invoke FrameRect,[esi].hdc,addr rect,eax
		invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr buffer
		invoke strlen,addr buffer
		mov		edx,[esi].rcItem.left
		add		edx,30
		invoke TextOut,[esi].hdc,edx,[esi].rcItem.top,addr buffer,eax
		assume esi:nothing
		pop		esi
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

PrintOptionProc endp

