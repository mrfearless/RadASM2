
.const

IDD_DLGCOLOR							equ 2100
IDC_STCEDTCOL1							equ 2101
IDC_STCEDTCOL2							equ 2102
IDC_STCEDTCOL3							equ 2103
IDC_STCSYNCOL1							equ 2104
IDC_STCSYNCOL2							equ 2105
IDC_STCSYNCOL3							equ 2106
IDC_STCKEYCOL0							equ 2107
IDC_STCKEYCOL1							equ 2108
IDC_STCKEYCOL2							equ 2109
IDC_STCKEYCOL3							equ 2110
IDC_STCKEYCOL4							equ 2111
IDC_STCKEYCOL5							equ 2112
IDC_STCKEYCOL6							equ 2113
IDC_STCKEYCOL7							equ 2114
IDC_STCKEYCOL8							equ 2115
IDC_STCKEYCOL9							equ 2116

IDC_CHKHIGHLIGHT						equ 2117
IDC_CHKDIVLINE							equ 2133
IDC_CHKFLICKER							equ 2134

IDC_LSTCX								equ 2118
IDC_LSTC10								equ 2119
IDC_BTNTOC10							equ 2120
IDC_BTNTOCX								equ 2121
IDC_EDTCX								equ 2122
IDC_BTNADD								equ 2123
IDC_BTNDEL								equ 2124
IDC_FRACX								equ 2125
IDC_STCWINCOL1							equ 2126
IDC_STCWINCOL2							equ 2127
IDC_STCWINCOL3							equ 2128
IDC_STCWINCOL4							equ 2129
IDC_CHKFONTBOLD							equ 2130
IDC_CHKFONTITALIC						equ 2131
IDC_FRAFONT								equ 2132

.data?

szKW			db 4 dup(?)
OldStcColorProc	dd ?
hStcMouse		dd ?
hBrBtn			dd ?
hBrStc			dd ?
nFont			dd ?

.data

szFont			db ' Font',0

.code

;########################################################################

DeleteKeyWords proc hWin:HWND,IDFROM:DWORD
	LOCAL	nInx:DWORD
	LOCAL	nCnt:DWORD

	invoke SendDlgItemMessage,hWin,IDFROM,LB_GETSELCOUNT,0,0
	mov		nCnt,eax
	mov		nInx,0
	.while nCnt
		invoke SendDlgItemMessage,hWin,IDFROM,LB_GETSEL,nInx,0
		.if eax
			invoke SendDlgItemMessage,hWin,IDFROM,LB_DELETESTRING,nInx,0
			dec		nCnt
			mov		eax,1
		.endif
		xor		eax,1
		add		nInx,eax
	.endw
	ret

DeleteKeyWords endp

MoveKeyWords proc hWin:HWND,IDFROM:DWORD,IDTO:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	nCnt:DWORD

	invoke SendDlgItemMessage,hWin,IDFROM,LB_GETSELCOUNT,0,0
	mov		nCnt,eax
	mov		nInx,0
	.while nCnt
		invoke SendDlgItemMessage,hWin,IDFROM,LB_GETSEL,nInx,0
		.if eax
			invoke SendDlgItemMessage,hWin,IDFROM,LB_GETTEXT,nInx,addr buffer
			invoke SendDlgItemMessage,hWin,IDFROM,LB_DELETESTRING,nInx,0
			invoke SendDlgItemMessage,hWin,IDTO,LB_ADDSTRING,0,addr buffer
			dec		nCnt
			mov		eax,1
		.endif
		xor		eax,1
		add		nInx,eax
	.endw
	ret

MoveKeyWords endp

SaveKeyWordList proc hWin:HWND,IDLST:DWORD

	invoke RtlZeroMemory,addr LineTxt,sizeof LineTxt
	invoke SendDlgItemMessage,hWin,IDLST,LB_GETCOUNT,0,0
	.if eax && eax!=LB_ERR
		push	esi
		mov		esi,offset LineTxt
		xor		edx,edx
		.while eax
			push	eax
			push	edx
			push	esi
			invoke SendDlgItemMessage,hWin,IDLST,LB_GETTEXT,edx,esi
			pop		esi
			push	esi
			invoke lstrlen,esi
			pop		esi
			add		esi,eax
			mov		al,' '
			mov		[esi],al
			inc		esi
			pop		edx
			pop		eax
			inc		edx
			dec		eax
		.endw
		pop		esi
	.endif
	invoke WritePrivateProfileString,addr iniKeyWords,addr szKW,addr LineTxt,addr iniAsmFile
	ret

SaveKeyWordList endp

KeyWordList proc hWin:HWND,IDLST:DWORD
	LOCAL	buffer[40]:BYTE

	mov		eax,dword ptr szKW
	mov		dword ptr buffer,eax
	invoke lstrlen,addr buffer
	mov		word ptr buffer[eax],' '
	invoke lstrcat,addr buffer,addr iniKeyWords
	invoke SendDlgItemMessage,hWin,IDC_FRACX,WM_SETTEXT,0,addr buffer
	invoke SendDlgItemMessage,hWin,IDLST,LB_RESETCONTENT,0,0
	invoke RtlZeroMemory,addr LineTxt,sizeof LineTxt
	invoke GetPrivateProfileString,addr iniKeyWords,addr szKW,addr szNULL,addr LineTxt,sizeof LineTxt,addr iniAsmFile
	.if eax!=0
		push	esi
		mov		esi,offset LineTxt
	  Nx:
		mov		al,[esi]
		cmp		al,' '
		jne		@f
		inc		esi
		jmp		Nx
	  @@:
		push	esi
		mov		edx,esi
		dec		esi
	  @@:
		inc		esi
		mov		al,[esi]
		or		al,al
		je		@f
		cmp		al,' '
		jne		@b
		mov		al,0
		mov		[esi],al
	  @@:
		invoke SendDlgItemMessage,hWin,IDLST,LB_ADDSTRING,0,edx
		pop		esi
	  @@:
		mov		al,[esi]
		inc		esi
		or		al,al
		jne		@b
		mov		al,[esi]
		or		al,al
		jne		Nx
		pop		esi
	.endif
	ret

KeyWordList endp

StcColorProc PROC hWin:HWND,uMsg:DWORD,wParam:WPARAM, lParam:LPARAM

	.if uMsg==WM_MOUSEMOVE
		.if hStcMouse
			invoke InvalidateRect,hStcMouse,NULL,TRUE
		.endif
		mov		eax,hWin
		mov		hStcMouse,eax
		invoke InvalidateRect,hWin,NULL,TRUE
	.endif
	invoke CallWindowProc,OldStcColorProc,hWin,uMsg,wParam,lParam
	ret

StcColorProc endp

EditColorProc PROC hWin:HWND,uMsg:DWORD,wParam:WPARAM, lParam:LPARAM
	LOCAL	buffer[64]:BYTE
	LOCAL	hCtl:HWND

	mov		eax,uMsg
    .if eax==WM_INITDIALOG
    	push	esi
    	push	edi
    	mov		edi,offset lColorArray
    	mov		esi,offset ColorArray
    	mov		ecx,20
    	rep movsd
		pop		edi
		pop		esi
        mov		eax,BST_CHECKED
        .if !fUseHighLight
        	mov		eax,BST_UNCHECKED
        .endif
		invoke CheckDlgButton,hWin,IDC_CHKHIGHLIGHT,eax
        mov		eax,BST_CHECKED
        .if !fUseDivLine
        	mov		eax,BST_UNCHECKED
        .endif
		invoke CheckDlgButton,hWin,IDC_CHKDIVLINE,eax
        mov		eax,BST_CHECKED
        .if !fNoFlicker
        	mov		eax,BST_UNCHECKED
        .endif
		invoke CheckDlgButton,hWin,IDC_CHKFLICKER,eax

		mov		eax,'01C'
		mov		dword ptr szKW,eax
		invoke KeyWordList,hWin,IDC_LSTC10
		mov		eax,'0C'
		mov		dword ptr szKW,eax
		invoke KeyWordList,hWin,IDC_LSTCX
		invoke SendDlgItemMessage,hWin,IDC_EDTCX,EM_LIMITTEXT,32,0
        invoke GetDlgItem,hWin,IDUSE
        invoke EnableWindow,eax,0
		invoke GetSysColor,COLOR_BTNFACE
		invoke CreateSolidBrush,eax
		mov		hBrBtn,eax
		invoke CreateSolidBrush,0A0A0A0h
		mov		hBrStc,eax
		mov		eax,1000
		.while eax<=1012
			push	eax
			invoke GetDlgItem,hWin,eax
			mov		hCtl,eax
			invoke SetWindowLong,hCtl,GWL_WNDPROC,offset StcColorProc
			mov		OldStcColorProc,eax
			pop		eax
			inc		eax
		.endw
		mov		eax,offset lColorArray+12
		mov		nFont,eax
		call SetChkFont
		invoke GetDlgItem,hWin,IDUSE
		invoke EnableWindow,eax,FALSE
    .elseif eax==WM_CLOSE
		invoke DeleteObject,hBrTmp
		invoke DeleteObject,hBrBtn
		invoke DeleteObject,hBrStc
        invoke EndDialog,hWin,NULL
    .elseif eax==WM_COMMAND
        mov eax,wParam
        mov edx,eax
        shr edx,16
        .if dx==BN_CLICKED
            .if ax==IDCANCEL
				invoke SaveKeyWordList,hWin,IDC_LSTCX
				mov		eax,'01C'
				mov		dword ptr szKW,eax
				invoke SaveKeyWordList,hWin,IDC_LSTC10
                invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
            .elseif ax==IDOK
                invoke OptColorSave,hWin
                invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
            .elseif ax==IDUSE
                invoke OptColorSave,hWin
                invoke GetDlgItem,hWin,IDUSE
                invoke EnableWindow,eax,FALSE
            .elseif ax==IDC_BTNADD
				invoke GetDlgItemText,hWin,IDC_EDTCX,addr buffer,64
				invoke SendDlgItemMessage,hWin,IDC_LSTCX,LB_ADDSTRING,0,addr buffer
				invoke SetDlgItemText,hWin,IDC_EDTCX,addr szNULL
                invoke GetDlgItem,hWin,IDUSE
                invoke EnableWindow,eax,TRUE
            .elseif ax==IDC_BTNDEL
				invoke DeleteKeyWords,hWin,IDC_LSTCX
				invoke DeleteKeyWords,hWin,IDC_LSTC10
                invoke GetDlgItem,hWin,IDUSE
                invoke EnableWindow,eax,TRUE
				mov		eax,LBN_SELCHANGE
				shl		eax,16
				mov		ax,IDC_LSTCX
				invoke SendMessage,hWin,WM_COMMAND,eax,0
            .elseif ax==IDC_BTNTOC10
				invoke MoveKeyWords,hWin,IDC_LSTCX,IDC_LSTC10
				mov		eax,LBN_SELCHANGE
				shl		eax,16
				mov		ax,IDC_LSTC10
				invoke SendMessage,hWin,WM_COMMAND,eax,0
                invoke GetDlgItem,hWin,IDUSE
                invoke EnableWindow,eax,1
            .elseif ax==IDC_BTNTOCX
				invoke MoveKeyWords,hWin,IDC_LSTC10,IDC_LSTCX
				mov		eax,LBN_SELCHANGE
				shl		eax,16
				mov		ax,IDC_LSTCX
				invoke SendMessage,hWin,WM_COMMAND,eax,0
                invoke GetDlgItem,hWin,IDUSE
                invoke EnableWindow,eax,1
            .elseif ax==IDC_CHKHIGHLIGHT || ax==IDC_CHKDIVLINE || ax==IDC_CHKFLICKER || ax==IDC_CHKFONTBOLD || ax==IDC_CHKFONTITALIC
				.if ax==IDC_CHKFONTBOLD
					mov		edx,nFont
					mov		eax,[edx]
					xor		eax,1000000h
					mov		[edx],eax
				.elseif ax==IDC_CHKFONTITALIC
					mov		edx,nFont
					mov		eax,[edx]
					xor		eax,2000000h
					mov		[edx],eax
				.endif
                invoke GetDlgItem,hWin,IDUSE
                invoke EnableWindow,eax,TRUE
            .elseif (ax>=IDC_STCEDTCOL1 && ax<=IDC_STCKEYCOL9) || (ax>=IDC_STCWINCOL1 && ax<=IDC_STCWINCOL4)
				.if ax>=IDC_STCSYNCOL1 && ax<=IDC_STCKEYCOL9
					push	eax
					and		eax,0FFFFh
					.if eax>=IDC_STCSYNCOL1 && eax<=IDC_STCSYNCOL3
						push	eax
						mov		edx,eax
						sub		edx,IDC_STCSYNCOL1-1010
						invoke SendDlgItemMessage,hWin,edx,WM_GETTEXT,16,addr buffer
						pop		eax
						sub		eax,IDC_STCSYNCOL1-3
					.else
						push	eax
						mov		edx,eax
						sub		edx,IDC_STCKEYCOL0-1000
						invoke SendDlgItemMessage,hWin,edx,WM_GETTEXT,16,addr buffer
						pop		eax
						sub		eax,IDC_STCKEYCOL0-6
					.endif
					shl		eax,2
					add		eax,offset lColorArray
					mov		nFont,eax
					call SetChkFont
					invoke lstrcat,addr buffer,addr szFont
					invoke SetDlgItemText,hWin,IDC_FRAFONT,addr buffer
					pop		eax
				.endif
				.if ax>=IDC_STCKEYCOL0 && ax<=IDC_STCKEYCOL9
					push	eax
					push	eax
					invoke SaveKeyWordList,hWin,IDC_LSTCX
					pop		eax
					sub		ax,IDC_STCKEYCOL0-1000
					invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,3,addr szKW
					invoke KeyWordList,hWin,IDC_LSTCX
					pop		eax
				.endif
                xor     edx,edx
                mov     dx,ax
                mov     lpcc.lStructSize,sizeof CHOOSECOLOR
                mov     eax,hWin
                mov     lpcc.hwndOwner,eax
                mov     eax,hInstance
                mov     lpcc.hInstance,eax
                mov     lpcc.lpCustColors,offset CustColors
                mov     lpcc.Flags,CC_FULLOPEN or CC_RGBINIT
                mov     lpcc.lCustData,0
				mov		lpcc.lpfnHook,0
				mov		lpcc.lpTemplateName,0
				.if edx>=IDC_STCWINCOL1
	                sub		edx,IDC_STCWINCOL1
    	            shl		edx,2
        	        add		edx,offset lColorArray[64]
				.else
	                sub		edx,IDC_STCEDTCOL1
    	            shl		edx,2
        	        add		edx,offset lColorArray
				.endif
                push    edx
                mov     eax,dword ptr [edx]
                and		eax,0FFFFFFh
                mov     lpcc.rgbResult,eax
                invoke ChooseColor,addr lpcc
                pop     edx
                mov     eax,lpcc.rgbResult
                mov		ecx,dword ptr [edx]
                and		ecx,0FF000000h
                or		eax,ecx
                cmp     eax,dword ptr [edx]
                je      @f
                mov     dword ptr [edx],eax
                invoke GetDlgItem,hWin,IDUSE
                invoke EnableWindow,eax,1
                invoke InvalidateRect,hWin,NULL,TRUE                
              @@:
            .endif
		.elseif ax>=1010 && ax<=1012
			and		eax,0FFFFh
			mov		nFont,eax
			mov		edx,eax
			invoke SendDlgItemMessage,hWin,edx,WM_GETTEXT,16,addr buffer
			invoke lstrcat,addr buffer,addr szFont
			invoke SetDlgItemText,hWin,IDC_FRAFONT,addr buffer
			mov		eax,nFont
			sub		eax,1010-3
			shl		eax,2
			add		eax,offset lColorArray
			mov		nFont,eax
			call SetChkFont
		.elseif ax>=1000 && ax<=1009
			push	eax
			invoke SaveKeyWordList,hWin,IDC_LSTCX
			pop		eax
			and		eax,0FFFFh
			mov		nFont,eax
			invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,3,addr szKW
			invoke SendDlgItemMessage,hWin,nFont,WM_GETTEXT,3,addr buffer
			mov		eax,nFont
			sub		eax,1000-6
			shl		eax,2
			add		eax,offset lColorArray
			mov		nFont,eax
			invoke lstrcat,addr buffer,addr szFont
			invoke SetDlgItemText,hWin,IDC_FRAFONT,addr buffer
			call SetChkFont
			invoke KeyWordList,hWin,IDC_LSTCX
			mov		eax,LBN_SELCHANGE
			shl		eax,16
			mov		ax,IDC_LSTCX
			invoke SendMessage,hWin,WM_COMMAND,eax,0
		.elseif dx==LBN_SELCHANGE
			invoke SendDlgItemMessage,hWin,IDC_LSTCX,LB_GETSELCOUNT,0,0
			.if eax
				mov		eax,TRUE
			.endif
			push	eax
			invoke GetDlgItem,hWin,IDC_BTNTOC10
			pop		edx
			push	edx
			invoke EnableWindow,eax,edx
			invoke GetDlgItem,hWin,IDC_BTNDEL
			pop		edx
			invoke EnableWindow,eax,edx
			invoke SendDlgItemMessage,hWin,IDC_LSTC10,LB_GETSELCOUNT,0,0
			.if eax
				mov		eax,TRUE
			.endif
			push	eax
			invoke GetDlgItem,hWin,IDC_BTNTOCX
			pop		edx
			push	edx
			invoke EnableWindow,eax,edx
			pop		edx
			.if edx
				invoke GetDlgItem,hWin,IDC_BTNDEL
				invoke EnableWindow,eax,TRUE
			.endif
		.elseif dx==EN_CHANGE
			invoke GetDlgItemText,hWin,IDC_EDTCX,addr buffer,64
			.if eax
				mov		eax,TRUE
			.endif
			push	eax
			invoke GetDlgItem,hWin,IDC_BTNADD
			pop		edx
			invoke EnableWindow,eax,edx
        .endif
	.elseif eax==WM_CTLCOLORSTATIC
		invoke GetWindowLong,lParam,GWL_ID
		.if eax>=IDC_STCEDTCOL1 && eax<=IDC_STCKEYCOL9
			.if hBrTmp
				push	eax
				invoke DeleteObject,hBrTmp
				pop		eax
			.endif
			sub		eax,IDC_STCEDTCOL1
			shl		eax,2
			add		eax,offset lColorArray
			mov		eax,dword ptr [eax]
			and		eax,0FFFFFFh
			invoke CreateSolidBrush,eax
			mov		hBrTmp,eax
			ret
		.elseif eax>=IDC_STCWINCOL1 && eax<=IDC_STCWINCOL4
			.if hBrTmp
				push	eax
				invoke DeleteObject,hBrTmp
				pop		eax
			.endif
			sub		eax,IDC_STCWINCOL1
			shl		eax,2
			add		eax,offset lColorArray[64]
			mov		eax,dword ptr [eax]
			and		eax,0FFFFFFh
			invoke CreateSolidBrush,eax
			mov		hBrTmp,eax
			ret
		.elseif eax>=1000 && eax<=1012
			invoke GetDlgItem,hWin,eax
			.if eax==hStcMouse
				invoke SetTextColor,wParam,0FFh
				invoke SetBkMode,wParam,TRANSPARENT
				mov		eax,hBrStc
				ret
			.endif
			invoke SetTextColor,wParam,0
			invoke SetBkMode,wParam,TRANSPARENT
			mov		eax,hBrBtn
			ret
		.endif
		mov eax,FALSE
		ret
	.elseif eax==WM_MOUSEMOVE
		mov		eax,hStcMouse
		.if eax
			mov		hStcMouse,0
			invoke InvalidateRect,eax,NULL,TRUE
		.endif
    .else
        mov		eax,FALSE
        ret
    .endif
    mov		eax,TRUE
    ret

SetChkFont:
	mov		eax,nFont
	mov		eax,dword ptr [eax]
	push	eax
	and		eax,1000000h
	.if eax
		mov		eax,BST_CHECKED
	.endif
	invoke CheckDlgButton,hWin,IDC_CHKFONTBOLD,eax
	pop		eax
	and		eax,2000000h
	.if eax
		mov		eax,BST_CHECKED
	.endif
	invoke CheckDlgButton,hWin,IDC_CHKFONTITALIC,eax
	retn

EditColorProc endp

UpdateEditColors proc

	invoke SendMessage,hOut1,REM_GETCOLOR,0,addr racol
	mov		eax,ColorArray[16*4]
	mov		racol.bckcol,eax
	mov		racol.txtcol,0
	mov		eax,ColorArray[2*4]
	mov		racol.selbarbck,eax
	invoke SendMessage,hOut1,REM_SETCOLOR,0,addr racol
	invoke SendMessage,hOut2,REM_SETCOLOR,0,addr racol
	invoke SendMessage,hOut3,REM_SETCOLOR,0,addr racol
	push	hPbrIml
	invoke Do_ImageList,hInstance,IDB_MDITV,16,20,ColorArray[68],0FFFFFFh
	mov     hPbrIml,eax
	invoke SendMessage,hPbrTrv,TVM_SETIMAGELIST,TVSIL_NORMAL,hPbrIml
	invoke SendMessage,hFileTrv,TVM_SETIMAGELIST,TVSIL_NORMAL,hPbrIml
	mov		eax,ColorArray[68]
	.if eax!=0FFFFFFh
		push	eax
		invoke SendMessage,hPbrTrv,TVM_SETBKCOLOR,0,eax
		pop		eax
		invoke SendMessage,hFileTrv,TVM_SETBKCOLOR,0,eax
	.endif
	pop		eax
	invoke ImageList_Destroy,eax
	invoke DeleteObject,hBrPrp
	invoke CreateSolidBrush,ColorArray[72]
	mov		hBrPrp,eax
	invoke DeleteObject,hBrDlg
	invoke CreateSolidBrush,ColorArray[76]
	mov		hBrDlg,eax
	invoke InvalidateRect,hPrpLst,NULL,TRUE
	invoke InvalidateRect,hPrpCbo,NULL,TRUE
	invoke UpdateAll,IDM_OPTION_COLORS
	invoke UpdateAll,IDM_OPTION_FONT
	ret

UpdateEditColors endp

OptColorSave proc hWin:DWORD

	mov		eax,dword ptr szKW
	push	eax
	invoke SaveKeyWordList,hWin,IDC_LSTCX
	mov		eax,'01C'
	mov		dword ptr szKW,eax
	invoke SaveKeyWordList,hWin,IDC_LSTC10
    invoke GetDlgItem,hWin,IDUSE
    invoke IsWindowEnabled,eax
    .if eax
    	push	esi
    	push	edi
    	mov		esi,offset lColorArray
    	mov		edi,offset ColorArray
    	mov		ecx,20
    	cld
    	rep movsd
		pop		edi
		pop		esi
		;Load the words to be hilighted
		invoke FillHiliteInfo
    	invoke IsDlgButtonChecked,hWin,IDC_CHKHIGHLIGHT
		.if eax
    		mov		eax,TRUE
    	.endif
    	mov		fUseHighLight,eax
    	invoke IsDlgButtonChecked,hWin,IDC_CHKDIVLINE
		.if eax
    		mov		eax,TRUE
    	.endif
    	mov		fUseDivLine,eax
    	invoke IsDlgButtonChecked,hWin,IDC_CHKFLICKER
		.if eax
    		mov		eax,TRUE
    	.endif
    	mov		fNoFlicker,eax

		invoke iniColSave
		invoke CreateCodeFont
	    invoke SetFormat,hOut3,hFont,hFont,hFont
	    invoke SetFormat,hOut2,hFont,hFont,hFont
	    invoke SetFormat,hOut1,hFont,hFont,hFont
		invoke UpdateEditColors
    .endif
	pop		eax
	mov		dword ptr szKW,eax
    ret

OptColorSave endp

