.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include TbrCreate.inc
include TbrString.asm

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
	invoke GetCommandLine
	mov		CommandLine,eax
    invoke InitCommonControls
	invoke LoadLibrary,addr RichEditDLL
	mov		hRichEdDLL,eax
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	push	eax
	invoke FreeLibrary,hRichEdDLL
	pop		eax
	invoke ExitProcess,0

;########################################################################

SetTitle proc hWin:HWND
	LOCAL	buffer[512]:BYTE

	invoke lstrcpy,addr buffer,addr szAppTitle
	invoke lstrcat,addr buffer,addr FileName
	invoke SetWindowText,hWin,addr buffer
	ret

SetTitle endp

ShowMToolBar proc hWin:HWND
	LOCAL	tbb:TBBUTTON
	LOCAL	tbab:TBADDBITMAP
	LOCAL	nInx:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	ws:DWORD
	LOCAL	btnwt:DWORD
	LOCAL	btnht:DWORD
	LOCAL	bmpwt:DWORD
	LOCAL	bmpht:DWORD

	.if hMTbr
		invoke DestroyWindow,hMTbr
	.endif
	invoke GetDlgItemInt,hWin,IDC_EDTBTNSIZE,NULL,FALSE
	.if eax<16
		mov		eax,16
	.endif
	mov		btnwt,eax
	mov		btnht,eax
	mov		bmpwt,eax
	mov		bmpht,eax
	mov		ws,WS_CHILD or WS_VISIBLE
	invoke IsDlgButtonChecked,hWin,IDC_CHKFLAT
	.if eax
		or		ws,TBSTYLE_FLAT
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKWRAP
	.if eax
		or		ws,TBSTYLE_WRAPABLE
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKNODIVIDER
	.if eax
		or		ws,CCS_NODIVIDER
	.endif

	invoke IsDlgButtonChecked,hWin,IDC_CHKTIP
	.if eax
		or		ws,TBSTYLE_TOOLTIPS
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKLIST
	.if eax
		or		ws,TBSTYLE_LIST
	.endif
	invoke CreateWindowEx,0h,addr szToolBar,0,ws,0,0,0,0,hWin,0,hInstance,0
	mov		hMTbr,eax
	invoke SendMessage,hMTbr,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	mov		eax,btnht
	shl		eax,16
	or		eax,btnwt
	invoke SendMessage,hMTbr,TB_SETBUTTONSIZE,0,eax
	mov		eax,bmpht
	shl		eax,16
	or		eax,bmpwt
	invoke SendMessage,hMTbr,TB_SETBITMAPSIZE,0,eax
    m2m		tbab.hInst,hBmpInst
    m2m		tbab.nID,hBmp
    invoke SendMessage,hMTbr,TB_ADDBITMAP,12,addr tbab
	mov		tbb.fsState,TBSTATE_ENABLED
	mov		tbb.dwData,0
	mov		tbb.iString,0
	mov		nInx,0
	.while nInx<64
		invoke SendMessage,hLBMTbr,LB_GETITEMDATA,nInx,0
		.if eax!=LB_ERR
			invoke SendMessage,hLBMTbr,LB_GETTEXT,nInx,addr buffer
			mov		al,buffer
			.if al=='-'
			    mov		tbb.iBitmap,0
			    mov		tbb.idCommand,0
			    mov		tbb.fsStyle,TBSTYLE_SEP
			.else
				invoke SendMessage,hLBMTbr,LB_GETITEMDATA,nInx,0
				shr		eax,16
				push	eax
				and		eax,0FFh
				mov		tbb.iBitmap,eax
				m2m		tbb.idCommand,nInx
				pop		edx
				shr		edx,8
				mov		eax,TBSTYLE_BUTTON
				test	edx,1
				je		@f
				or		eax,TBSTYLE_CHECK
			  @@:
				test	edx,2
				je		@f
				or		eax,TBSTYLE_GROUP
			  @@:
				mov		tbb.fsStyle,al
			.endif
			invoke SendMessage,hMTbr,TB_ADDBUTTONS,1,addr tbb
		.endif
		inc		nInx
	.endw
	invoke SendMessage,hMTbr,TB_AUTOSIZE,0,0
	ret

ShowMToolBar endp

ShowToolBar proc hWin:HWND
	LOCAL	tbb:TBBUTTON
	LOCAL	tbab:TBADDBITMAP
	LOCAL	nInx:DWORD
	LOCAL	btnwt:DWORD
	LOCAL	btnht:DWORD
	LOCAL	bmpwt:DWORD
	LOCAL	bmpht:DWORD

	.if hTbr
		invoke DestroyWindow,hTbr
	.endif
	invoke GetDlgItemInt,hWin,IDC_EDTBTNSIZE,NULL,FALSE
	.if eax<16
		mov		eax,16
	.endif
	mov		btnwt,eax
	mov		btnht,eax
	mov		bmpwt,eax
	mov		bmpht,eax
	invoke CreateWindowEx,0h,addr szToolBar,0,50000020h or TBSTYLE_WRAPABLE,0,0,0,0,hStc,0,hInstance,0
	mov		hTbr,eax
	invoke SendMessage,hTbr,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	mov		eax,btnht
	shl		eax,16
	or		eax,btnwt
	invoke SendMessage,hTbr,TB_SETBUTTONSIZE,0,eax
	mov		eax,bmpht
	shl		eax,16
	or		eax,bmpwt
	invoke SendMessage,hTbr,TB_SETBITMAPSIZE,0,eax
    m2m		tbab.hInst,hBmpInst
    m2m		tbab.nID,hBmp
    invoke SendMessage,hTbr,TB_ADDBITMAP,12,addr tbab
	mov		tbb.fsState,TBSTATE_ENABLED
	mov		tbb.dwData,0
	mov		tbb.iString,0
	mov		nInx,0
	.while nInx<11*8
		mov		eax,nInx
		mov		tbb.iBitmap,eax
		inc		eax
		mov		tbb.idCommand,eax
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hTbr,TB_ADDBUTTONS,1,addr tbb
		inc		nInx
	.endw
	invoke SendMessage,hTbr,TB_AUTOSIZE,0,0
	ret

ShowToolBar endp

StcProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD

	mov		eax,uMsg
	.if eax==WM_COMMAND
		invoke SendMessage,hLBMTbr,LB_GETCURSEL,0,0
		.if eax!=LB_ERR
			mov		nInx,eax
			invoke SendMessage,hLBMTbr,LB_GETITEMDATA,nInx,0
			and		eax,0FF00FFFFh
			mov		edx,wParam
			shl		edx,16
			dec		edx
			and		edx,0FF0000h
			or		eax,edx
			invoke SendMessage,hLBMTbr,LB_SETITEMDATA,nInx,eax
			invoke ShowMToolBar,hWnd
		.else
			invoke MessageBeep,MB_OK
		.endif
	.endif
	invoke CallWindowProc,OldStcProc,hWin,uMsg,wParam,lParam
	ret

StcProc endp

GetMenuItems proc uses esi edi,hWin:HWND
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	hMem:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	lbTabs:DWORD

	invoke GetDlgItemText,hWin,IDC_EDTM,addr buffer,sizeof buffer
	invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,65536
		mov     hMem,eax
		invoke GlobalLock,hMem
		invoke ReadFile,hFile,hMem,65536,addr nBytes,NULL
		invoke CloseHandle,hFile
		invoke SendDlgItemMessage,hWin,IDC_LSTM,LB_RESETCONTENT,0,0
		mov		lbTabs,200
		invoke SendDlgItemMessage,hWin,IDC_LSTM,LB_SETTABSTOPS,1,addr lbTabs
		mov		esi,hMem
		add		esi,sizeof MNUHEAD
		assume esi:ptr MNUITEM
		mov		eax,[esi].itemflag
		.while eax
			mov		eax,[esi].level
			.if !eax
				invoke SendDlgItemMessage,hWin,IDC_LSTM,LB_ADDSTRING,0,addr [esi].itemcaption
			.else
				lea		edi,buffer
				mov		ecx,eax
				.while ecx
					mov		eax,'..'
					stosd
					dec		edi
					dec		edi
					dec		ecx
				.endw
				invoke lstrcpyn,edi,addr [esi].itemcaption,64
				mov		al,[esi].itemcaption
				.if al=='-'
					invoke SendDlgItemMessage,hWin,IDC_LSTM,LB_ADDSTRING,0,addr buffer
				.else
					invoke lstrlen,edi
					add		edi,eax
					mov		al,VK_TAB
					stosb
					invoke lstrcpyn,edi,addr [esi].itemname,32
					invoke SendDlgItemMessage,hWin,IDC_LSTM,LB_ADDSTRING,0,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTM,LB_SETITEMDATA,eax,[esi].itemid
				.endif
			.endif
			add		esi,sizeof MNUITEM
			mov		eax,[esi].itemflag
		.endw
		invoke GlobalUnlock,hMem
		invoke GlobalFree,hMem
	.endif
	ret

GetMenuItems endp

WriteTbrFile proc hWin:HWND
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	nInx:DWORD

	invoke lstrcmpi,addr FileName,addr szUntitled
	.if !eax
		invoke RtlZeroMemory,addr ofn,sizeof ofn
		mov		ofn.lStructSize,sizeof ofn
		m2m		ofn.hwndOwner,hWin
		m2m		ofn.hInstance,hInstance
		mov		ofn.lpstrInitialDir,offset ProjectPath
		mov		ofn.lpstrFilter,offset TBRFilterString
		mov		ofn.lpstrDefExt,offset DefTbrExt
		mov		ofn.lpstrTitle,0
		mov		ofn.lpstrFile,offset FileName
		mov		ofn.nMaxFile,sizeof FileName
		mov		ofn.Flags,OFN_OVERWRITEPROMPT or OFN_PATHMUSTEXIST
		invoke GetSaveFileName,addr ofn
		invoke SetDlgItemText,hWin,IDC_EDTOUT,addr FileName
		or		eax,eax
		je		Ex
	.endif
	invoke SetTitle,hWin
	mov		buffer,0
	invoke WritePrivateProfileSection,addr iniTbr,addr szNULL,addr FileName
	invoke GetDlgItemText,hWin,IDC_EDTTN,addr buffer1,sizeof buffer1
	invoke StrPutString,addr buffer1,addr buffer,TRUE
	invoke GetDlgItemInt,hWin,IDC_EDTIDTN,addr nInx,FALSE
	mov		edx,eax
	invoke StrPutValue,edx,addr buffer,TRUE
	mov		nInx,0
	invoke IsDlgButtonChecked,hWin,IDC_CHKFLAT
	.if eax
		or		nInx,1
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKWRAP
	.if eax
		or		nInx,2
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKTIP
	.if eax
		or		nInx,4
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKLIST
	.if eax
		or		nInx,8
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKNODIVIDER
	.if eax
		or		nInx,16
	.endif
	invoke StrPutValue,nInx,addr buffer,FALSE
	invoke WritePrivateProfileString,addr iniTbr,addr iniTbr,addr buffer,addr FileName
	mov		buffer,0
	invoke GetDlgItemText,hWin,IDC_EDTB,addr buffer1,sizeof buffer1
	invoke StrPutString,addr buffer1,addr buffer,TRUE
	invoke GetDlgItemText,hWin,IDC_EDTBN,addr buffer1,sizeof buffer1
	invoke StrPutString,addr buffer1,addr buffer,TRUE
	invoke GetDlgItemText,hWin,IDC_EDTBNBR,addr buffer1,sizeof buffer1
	invoke StrPutString,addr buffer1,addr buffer,FALSE
	invoke WritePrivateProfileString,addr iniTbr,addr iniBmp,addr buffer,addr FileName
	invoke GetDlgItemText,hWin,IDC_EDTM,addr buffer,sizeof buffer
	invoke WritePrivateProfileString,addr iniTbr,addr iniMnu,addr buffer,addr FileName
	invoke GetDlgItemInt,hWin,IDC_EDTBTNSIZE,NULL,FALSE
	.if eax<16
		mov		eax,16
	.endif
	mov		nInx,eax
	invoke BinToDec,nInx,addr buffer
	invoke WritePrivateProfileString,addr iniTbr,addr iniSize,addr buffer,addr FileName
	mov		nInx,0
  @@:
	invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETTEXT,nInx,addr buffer1
	.if eax!=LB_ERR
		mov		buffer,0
		invoke StrPutString,addr buffer1,addr buffer,TRUE
		invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
		push	eax
		mov		edx,eax
		and		edx,0FFFFh
		;ID
		invoke StrPutValue,edx,addr buffer,TRUE
		pop		edx
		shr		edx,16
		push	edx
		shr		edx,8
		;Style
		invoke StrPutValue,edx,addr buffer,TRUE
		pop		edx
		and		edx,0FFh
		;Bitmap ID
		invoke StrPutValue,edx,addr buffer,FALSE
		invoke BinToDec,nInx,addr buffer1
		invoke WritePrivateProfileString,addr iniTbr,addr buffer1,addr buffer,addr FileName
		inc		nInx
		jmp		@b
	.endif
  Ex:
	ret

WriteTbrFile endp

ReadTbrFile proc hWin:HWND
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[512]:BYTE
	LOCAL	nInx:DWORD

	invoke GetPrivateProfileString,addr iniTbr,addr iniTbr,addr szNULL,addr buffer,sizeof buffer,addr FileName
	.if eax
		invoke StrGetItem,addr buffer1,addr buffer
		invoke SetDlgItemText,hWin,IDC_EDTTN,addr buffer1
		invoke StrGetItem,addr buffer1,addr buffer
		invoke DecToBin,addr buffer1
		invoke SetDlgItemInt,hWin,IDC_EDTIDTN,eax,FALSE
		invoke StrGetItem,addr buffer1,addr buffer
		invoke DecToBin,addr buffer1
		mov		nInx,eax
		and		eax,1
		invoke CheckDlgButton,hWin,IDC_CHKFLAT,eax
		mov		eax,nInx
		shr		eax,1
		and		eax,1
		invoke CheckDlgButton,hWin,IDC_CHKWRAP,eax
		mov		eax,nInx
		shr		eax,2
		and		eax,1
		invoke CheckDlgButton,hWin,IDC_CHKTIP,eax
		mov		eax,nInx
		shr		eax,3
		and		eax,1
		invoke CheckDlgButton,hWin,IDC_CHKLIST,eax
		mov		eax,nInx
		shr		eax,4
		and		eax,1
		invoke CheckDlgButton,hWin,IDC_CHKNODIVIDER,eax
		invoke GetPrivateProfileString,addr iniTbr,addr iniBmp,addr szNULL,addr buffer,sizeof buffer,addr FileName
		invoke StrGetItem,addr buffer1,addr buffer
		invoke SetDlgItemText,hWin,IDC_EDTB,addr buffer1
		mov		al,buffer1
		.if al
		    mov		hBmpInst,0
			.if hBmp
				invoke DeleteObject,hBmp
			.endif
		    invoke LoadImage,0,addr buffer1,IMAGE_BITMAP,0,0,LR_LOADFROMFILE or LR_LOADMAP3DCOLORS
	    	mov		hBmp,eax
		.endif
		invoke StrGetItem,addr buffer1,addr buffer
		invoke SetDlgItemText,hWin,IDC_EDTBN,addr buffer1
		invoke StrGetItem,addr buffer1,addr buffer
		invoke SetDlgItemText,hWin,IDC_EDTBNBR,addr buffer1
		invoke ShowToolBar,hWin
		invoke GetPrivateProfileString,addr iniTbr,addr iniMnu,addr szNULL,addr buffer,sizeof buffer,addr FileName
		.if eax
			invoke SetDlgItemText,hWin,IDC_EDTM,addr buffer
			invoke GetMenuItems,hWin
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTM,addr buffer
		invoke GetPrivateProfileInt,addr iniTbr,addr iniSize,16,addr FileName
		invoke SendDlgItemMessage,hWin,IDC_UDN1,UDM_SETPOS,0,eax
		invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_RESETCONTENT,0,0
		mov		nInx,0
	  @@:
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniTbr,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr FileName
		.if eax
			invoke StrGetItem,addr buffer1,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_ADDSTRING,0,addr buffer1
			invoke StrGetItem,addr buffer1,addr buffer
			invoke DecToBin,addr buffer1
			push	eax
			invoke StrGetItem,addr buffer1,addr buffer
			invoke DecToBin,addr buffer1
			push	eax
			invoke StrGetItem,addr buffer1,addr buffer
			invoke DecToBin,addr buffer1
			shl		eax,16
			pop		edx
			shl		edx,24
			or		eax,edx
			pop		edx
			or		eax,edx
			invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETITEMDATA,nInx,eax
			inc		nInx
			jmp		@b
		.endif
		invoke ShowMToolBar,hWin
		invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETCURSEL,0,0
		mov		eax,LBN_SELCHANGE
		shl		eax,16
		or		eax,IDC_LSTT
		invoke SendMessage,hWin,WM_COMMAND,eax,0
		invoke SetTitle,hWin
	.endif
	ret

ReadTbrFile endp

NewTbr proc hWin:HWND
	LOCAL	hCtl:HWND
	LOCAL   lhBmp:DWORD
	LOCAL   lhIml:DWORD

	invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_RESETCONTENT,0,0
	invoke SendDlgItemMessage,hWin,IDC_LSTM,LB_RESETCONTENT,0,0
	invoke LoadBitmap,hInstance,IDB_MNUARROW
	mov     lhBmp,eax
	invoke ImageList_Create,16,16,ILC_COLOR8,4,0
	mov     lhIml,eax
	invoke ImageList_Add,lhIml,lhBmp,NULL
	invoke DeleteObject,lhBmp
	invoke GetDlgItem,hWin,IDC_BTNU
	mov		hCtl,eax
	invoke ImageList_GetIcon,lhIml,2,ILD_NORMAL
	invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
	invoke GetDlgItem,hWin,IDC_BTND
	mov		hCtl,eax
	invoke ImageList_GetIcon,lhIml,3,ILD_NORMAL
	invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
	.if hBmp
		invoke DeleteObject,hBmp
	.endif
	mov		hBmpInst,HINST_COMMCTRL
	mov		hBmp,IDB_STD_SMALL_COLOR
	invoke SetDlgItemText,hWin,IDC_EDTTN,NULL
	invoke SetDlgItemText,hWin,IDC_EDTIDTN,NULL
	invoke SetDlgItemText,hWin,IDC_EDTT,NULL
	invoke SetDlgItemText,hWin,IDC_EDTIDT,NULL
	invoke SetDlgItemText,hWin,IDC_EDTB,NULL
	invoke SetDlgItemText,hWin,IDC_EDTBN,addr szIDB
	invoke SetDlgItemInt,hWin,IDC_EDTBNBR,15,FALSE
	invoke SetDlgItemText,hWin,IDC_EDTM,NULL
	invoke CheckDlgButton,hWin,IDC_CHKFLAT,BST_UNCHECKED
	invoke CheckDlgButton,hWin,IDC_CHKWRAP,BST_UNCHECKED
	invoke CheckDlgButton,hWin,IDC_CHKNODIVIDER,BST_UNCHECKED
	invoke CheckDlgButton,hWin,IDC_CHKTIP,BST_UNCHECKED
	invoke CheckDlgButton,hWin,IDC_CHKLIST,BST_UNCHECKED
	invoke CheckDlgButton,hWin,IDC_CHKCHECK,BST_UNCHECKED
	invoke CheckDlgButton,hWin,IDC_CHKGROUP,BST_UNCHECKED
	invoke lstrcpy,addr FileName,addr szUntitled
	invoke ShowToolBar,hWin
	invoke ShowMToolBar,hWin
	invoke SetTitle,hWin
	ret

NewTbr endp

CopyStr proc lpSrc:DWORD

	mov		esi,lpSrc
	dec		esi
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	mov		[edi],al
	or		al,al
	jne		@b
	ret

CopyStr endp

CopyCrLf proc

	invoke CopyStr,addr szCRLF
	ret

CopyCrLf endp

CopyVal proc nVal:DWORD
	LOCAL	buffer[256]:BYTE

	invoke BinToDec,nVal,addr buffer
	invoke CopyStr,addr buffer
	ret

CopyVal endp

CopyTab proc nTab:DWORD

	mov		ecx,nTab
	mov		al,09h
	rep stosb
	mov		byte ptr [edi],0
	ret

CopyTab endp

ExportEqu proc lpSrc:DWORD,nVal:DWORD
	LOCAL	buffer[256]:BYTE

	.if nVal
		mov		eax,lpSrc
		mov		al,[eax]
		.if al
			push	edi
			invoke CopyStr,lpSrc
			pop		eax
			sub		eax,edi
			add		eax,32
			dec		eax
			shr		eax,2
			inc		eax
			invoke CopyTab,eax
			invoke CopyStr,addr szEQU
			invoke CopyVal,nVal
			invoke CopyCrLf
		.endif
	.endif
	ret

ExportEqu endp

FBExportEqu proc lpSrc:DWORD,nVal:DWORD
	LOCAL	buffer[256]:BYTE

	.if nVal
		mov		eax,lpSrc
		mov		al,[eax]
		.if al
			push	edi
			invoke CopyStr,addr szFBDEFINE
			invoke CopyStr,lpSrc
			pop		eax
			sub		eax,edi
			add		eax,32
			dec		eax
			shr		eax,2
			inc		eax
			invoke CopyTab,eax
			invoke CopyVal,nVal
			invoke CopyCrLf
		.endif
	.endif
	ret

FBExportEqu endp

ExportBtns proc hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nNbr:DWORD
	LOCAL	nInx:DWORD

	mov		nNbr,0
	mov		nInx,0
	.while nInx<64
		invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETTEXT,nInx,addr buffer
		.if eax!=LB_ERR
			.if nNbr
				invoke CopyTab,8
			.else
				invoke CopyStr,addr szTBRBTNS
			.endif
			inc		nNbr
			invoke CopyStr,addr szTBBUTTON
			mov		al,buffer
			.if al=='-'
				invoke CopyVal,0
				mov		al,','
				stosb
				invoke CopyVal,0
				mov		al,','
				stosb
				invoke CopyStr,addr szTBSTE
				mov		al,','
				stosb
				invoke CopyStr,addr szTBSTS
				mov		al,','
				stosb
				invoke CopyVal,0
				mov		al,','
				stosb
				invoke CopyVal,0
			.else
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
				shr		eax,16
				push	eax
				and		eax,0FFh
				invoke CopyVal,eax
				mov		al,','
				stosb
				invoke CopyStr,addr buffer
				mov		al,','
				stosb
				invoke CopyStr,addr szTBSTE
				mov		al,','
				stosb
				invoke CopyStr,addr szTBSTB
				pop		eax
				shr		eax,8
				.if eax==1
					invoke CopyStr,addr szTBSTC
				.elseif eax==2
					invoke CopyStr,addr szTBSTG
				.elseif eax==3
					invoke CopyStr,addr szTBSTC
					invoke CopyStr,addr szTBSTG
				.endif
				mov		al,','
				stosb
				invoke CopyVal,0
				mov		al,','
				stosb
				invoke CopyVal,0
			.endif
			mov		al,'>'
			stosb
			invoke CopyCrLf
			mov		byte ptr [edi],0
		.endif
		inc		nInx
	.endw
	invoke ExportEqu,addr szNBTNS,nNbr
	invoke CopyCrLf
	mov		byte ptr [edi],0
	ret

ExportBtns endp

FBExportBtns proc hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nNbr:DWORD
	LOCAL	nInx:DWORD

	invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCOUNT,0,0
	mov		nNbr,eax
	mov		nBtns,eax
	mov		nInx,eax
	.while nInx
		dec		nInx
		invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETTEXT,nInx,addr buffer
		.if eax!=LB_ERR
			invoke CopyStr,addr szFBTBRBTNS
			invoke CopyVal,nNbr
			dec		nNbr
			invoke CopyStr,addr szFBTBBUTTON
			mov		al,buffer
			.if al=='-'
				invoke CopyVal,0
				mov		al,','
				stosb
				invoke CopyVal,0
				mov		al,','
				stosb
				invoke CopyStr,addr szTBSTE
				mov		al,','
				stosb
				invoke CopyStr,addr szTBSTS
				mov		al,','
				stosb
				invoke CopyVal,0
				mov		al,','
				stosb
				invoke CopyVal,0
			.else
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
				shr		eax,16
				push	eax
				and		eax,0FFh
				invoke CopyVal,eax
				mov		al,','
				stosb
				invoke CopyStr,addr buffer
				mov		al,','
				stosb
				invoke CopyStr,addr szTBSTE
				mov		al,','
				stosb
				invoke CopyStr,addr szTBSTB
				pop		eax
				shr		eax,8
				.if eax==1
					invoke CopyStr,addr szTBSTC
				.elseif eax==2
					invoke CopyStr,addr szTBSTG
				.elseif eax==3
					invoke CopyStr,addr szTBSTC
					invoke CopyStr,addr szTBSTG
				.endif
				mov		al,','
				stosb
				invoke CopyVal,0
				mov		al,','
				stosb
				invoke CopyVal,0
			.endif
			mov		al,')'
			stosb
			invoke CopyCrLf
			mov		byte ptr [edi],0
		.endif
	.endw
	invoke CopyCrLf
	mov		byte ptr [edi],0
	ret

FBExportBtns endp

ExportConst proc hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	invoke CopyStr,addr szCONST
	invoke GetDlgItemText,hWin,IDC_EDTTN,addr buffer,sizeof buffer
	invoke GetDlgItemInt,hWin,IDC_EDTIDTN,addr nInx,FALSE
	invoke ExportEqu,addr buffer,eax
	mov		nInx,0
	.while nInx<64
		invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETTEXT,nInx,addr buffer
		.if eax!=LB_ERR
			mov		al,buffer
			.if al!='-'
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
				and		eax,0FFFFh
				invoke ExportEqu,addr buffer,eax
			.endif
		.endif
		inc		nInx
	.endw
	invoke CopyCrLf
	invoke ExportBtns,hWin
	ret

ExportConst endp

FBExportConst proc hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	invoke GetDlgItemText,hWin,IDC_EDTTN,addr buffer,sizeof buffer
	invoke GetDlgItemInt,hWin,IDC_EDTIDTN,addr nInx,FALSE
	invoke FBExportEqu,addr buffer,eax
	mov		nInx,0
	.while nInx<64
		invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETTEXT,nInx,addr buffer
		.if eax!=LB_ERR
			mov		al,buffer
			.if al!='-'
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
				and		eax,0FFFFh
				invoke FBExportEqu,addr buffer,eax
			.endif
		.endif
		inc		nInx
	.endw
	invoke CopyCrLf
	ret

FBExportConst endp

ExportData proc hWin:HWND

	invoke CopyStr,addr szDATA
	ret

ExportData endp

FBExportData proc hWin:HWND

	invoke CopyStr,addr szFBDATA
	ret

FBExportData endp

ExportCodeCreate proc hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	invoke ExportConst,hWin
	invoke ExportData,hWin
	invoke CopyStr,addr szCODE
	invoke CopyStr,addr szDOTBRC1
	invoke IsDlgButtonChecked,hWin,IDC_CHKFLAT
	.if eax
		invoke CopyStr,addr szTBSTF
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKWRAP
	.if eax
		invoke CopyStr,addr szTBSTW
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKNODIVIDER
	.if eax
		invoke CopyStr,addr szTBSTND
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKTIP
	.if eax
		invoke CopyStr,addr szTBSTT
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKLIST
	.if eax
		invoke CopyStr,addr szTBSTL
	.endif
	invoke CopyStr,addr szDOTBRC2
	invoke GetDlgItemText,hWin,IDC_EDTTN,addr buffer,sizeof buffer
	mov		al,buffer
	.if !al
		invoke GetDlgItemText,hWin,IDC_EDTIDTN,addr buffer,sizeof buffer
	.endif
	invoke CopyStr,addr buffer
	invoke CopyStr,addr szDOTBRC3
	invoke CopyStr,addr szDOTBR1
	invoke GetDlgItemText,hWin,IDC_EDTB,addr buffer,sizeof buffer
	mov		al,buffer
	.if al
		invoke CopyStr,addr szHINST
	.else
		invoke CopyStr,addr szHINSTC
	.endif
	invoke CopyStr,addr szSBM
	invoke GetDlgItemText,hWin,IDC_EDTBN,addr buffer,sizeof buffer
	invoke CopyStr,addr buffer
	invoke CopyStr,addr szDOTBR2
	invoke GetDlgItemText,hWin,IDC_EDTBNBR,addr buffer,sizeof buffer
	invoke CopyStr,addr buffer
	invoke CopyStr,addr szDOTBR3
	ret

ExportCodeCreate endp

FBExportCodeCreate proc hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	invoke FBExportConst,hWin
	invoke FBExportData,hWin
	invoke CopyStr,addr szFBDOTBRC1
	invoke FBExportBtns,hWin
	invoke CopyStr,addr szFBDOTBRC2
	invoke IsDlgButtonChecked,hWin,IDC_CHKFLAT
	.if eax
		invoke CopyStr,addr szTBSTF
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKWRAP
	.if eax
		invoke CopyStr,addr szTBSTW
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKNODIVIDER
	.if eax
		invoke CopyStr,addr szTBSTND
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKTIP
	.if eax
		invoke CopyStr,addr szTBSTT
	.endif
	invoke IsDlgButtonChecked,hWin,IDC_CHKLIST
	.if eax
		invoke CopyStr,addr szTBSTL
	.endif
	invoke CopyStr,addr szDOTBRC2
	invoke GetDlgItemText,hWin,IDC_EDTTN,addr buffer,sizeof buffer
	mov		al,buffer
	.if !al
		invoke GetDlgItemText,hWin,IDC_EDTIDTN,addr buffer,sizeof buffer
	.endif
	invoke CopyStr,addr buffer
	invoke CopyStr,addr szFBDOTBRC3
	invoke CopyStr,addr szFBDOTBR1
	invoke GetDlgItemText,hWin,IDC_EDTB,addr buffer,sizeof buffer
	mov		al,buffer
	.if al
		invoke CopyStr,addr szHINST
	.else
		invoke CopyStr,addr szHINSTC
	.endif
	invoke CopyStr,addr szFBSBM
	invoke GetDlgItemText,hWin,IDC_EDTBN,addr buffer,sizeof buffer
	invoke CopyStr,addr buffer

	invoke CopyStr,addr szFBDOTBR2
	invoke GetDlgItemText,hWin,IDC_EDTBNBR,addr buffer,sizeof buffer
	invoke CopyStr,addr buffer

	invoke CopyStr,addr szFBDOTBR3
	invoke CopyVal,nBtns
	invoke CopyStr,addr szFBDOTBR4
	ret

FBExportCodeCreate endp

ExportCodeNoCreate proc hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	invoke ExportConst,hWin
	invoke CopyStr,addr szCODE
	invoke CopyStr,addr szDOTBRNC1
	invoke CopyStr,addr szDOTBR1
	invoke GetDlgItemText,hWin,IDC_EDTB,addr buffer,sizeof buffer
	mov		al,buffer
	.if al
		invoke CopyStr,addr szHINST
	.else
		invoke CopyStr,addr szHINSTC
	.endif
	invoke CopyStr,addr szSBM
	invoke GetDlgItemText,hWin,IDC_EDTBN,addr buffer,sizeof buffer
	invoke CopyStr,addr buffer

	invoke CopyStr,addr szDOTBR2
	invoke GetDlgItemText,hWin,IDC_EDTBNBR,addr buffer,sizeof buffer
	invoke CopyStr,addr buffer

	invoke CopyStr,addr szDOTBR3
	ret

ExportCodeNoCreate endp

FBExportCodeNoCreate proc hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	invoke FBExportConst,hWin
	invoke CopyStr,addr szFBDOTBRNC1
	invoke FBExportBtns,hWin
	invoke CopyStr,addr szFBDOTBR1
	invoke GetDlgItemText,hWin,IDC_EDTB,addr buffer,sizeof buffer
	mov		al,buffer
	.if al
		invoke CopyStr,addr szHINST
	.else
		invoke CopyStr,addr szHINSTC
	.endif
	invoke CopyStr,addr szFBSBM
	invoke GetDlgItemText,hWin,IDC_EDTBN,addr buffer,sizeof buffer
	invoke CopyStr,addr buffer

	invoke CopyStr,addr szFBDOTBR2
	invoke GetDlgItemText,hWin,IDC_EDTBNBR,addr buffer,sizeof buffer
	invoke CopyStr,addr buffer

	invoke CopyStr,addr szFBDOTBR3
	invoke CopyVal,nBtns
	invoke CopyStr,addr szFBDOTBR4
	ret

FBExportCodeNoCreate endp

ExportTbr proc uses esi edi,hWin:HWND,nType:DWORD
	LOCAL	hMem:DWORD
	LOCAL	nVal:DWORD

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,65536
	invoke GlobalLock,eax
	mov     hMem,eax
	mov		edi,eax
	invoke GetDlgItemInt,hWin,IDC_EDTIDTN,addr nVal,FALSE
	.if eax
		.if nType
			;FreeBASIC
			invoke FBExportCodeCreate,hWin
		.else
			;masm
			invoke ExportCodeCreate,hWin
		.endif
	.else
		.if nType
			;FreeBASIC
			invoke FBExportCodeNoCreate,hWin
		.else
			;masm
			invoke ExportCodeNoCreate,hWin
		.endif
	.endif
	invoke SendDlgItemMessage,hWin,IDC_EDTOUT,WM_SETTEXT,0,hMem
	invoke GlobalUnlock,hMem
	invoke GlobalFree,hMem
	ret

ExportTbr endp

SetFormat proc hWin:DWORD
    LOCAL	chrg:CHARRANGE
	LOCAL	pf:PARAFORMAT2
	LOCAL	tp:DWORD
	LOCAL	buffer[16]:BYTE
	LOCAL	pt:POINT
	LOCAL	hDC:HDC
	LOCAL	lfnt:LOGFONT

	;Create font
	invoke RtlZeroMemory,addr lfnt,sizeof lfnt
	mov		lfnt.lfHeight,-12
	mov		lfnt.lfWeight,400
	invoke lstrcat,addr lfnt.lfFaceName,offset szFont
	invoke CreateFontIndirect,addr lfnt
	mov		hFont,eax
	;Select all text
	mov		chrg.cpMin,0
	mov		chrg.cpMax,-1
	invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
	;Set font
	invoke SendMessage,hWin,WM_SETFONT,hFont,0
	;Get tab width
	invoke GetDC,hWin
	mov		hDC,eax
	invoke SelectObject,hDC,hFont
	push	eax
	mov		eax,'WWWW'
	mov		dword ptr buffer,eax
	invoke GetTextExtentPoint32,hDC,addr buffer,4,addr pt
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,hWin,hDC
	mov		eax,pt.x
	mov		ecx,4
	mul		ecx
	mov		ecx,15
	mul		ecx
	shr		eax,2
	mov		tp,eax
	;Set tab stops
	mov		pf.cbSize,sizeof pf
	mov		pf.dwMask,PFM_TABSTOPS
	mov		pf.cTabCount,MAX_TAB_STOPS
	xor		eax,eax
	xor		edx,edx
	mov		ecx,MAX_TAB_STOPS
  @@:
	add		eax,tp
	mov		dword ptr pf.rgxTabs[edx],eax
	add		edx,4
	loop	@b
	invoke SendMessage,hWin,EM_SETPARAFORMAT,0,addr pf
	;Restore selection
	mov		chrg.cpMin,0
	mov		chrg.cpMax,0
	invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
	ret

SetFormat endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ofn:OPENFILENAME
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	val:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		m2m		hWnd,hWin
		invoke SendDlgItemMessage,hWin,IDC_UDN1,UDM_SETRANGE,0,00100030h	; Set range
		invoke SendDlgItemMessage,hWin,IDC_UDN1,UDM_SETPOS,0,10h			; Set default value
		invoke GetDlgItem,hWin,IDC_EDTOUT
		invoke SetFormat,eax
		invoke GetDlgItem,hWin,IDC_STCB
		mov		hStc,eax
		invoke SetWindowLong,hStc,GWL_WNDPROC,offset StcProc
		mov		OldStcProc,eax
		invoke GetDlgItem,hWin,IDC_LSTT
		mov		hLBMTbr,eax
		invoke NewTbr,hWin
		;Get current directory
		invoke GetCurrentDirectory,sizeof ProjectPath,addr ProjectPath
		;Get command line filename
		invoke PathGetArgs,CommandLine
		mov		val,eax
		mov		al,[eax]
		.if al
			.if al=='"'
				invoke PathUnquoteSpaces,val
			.endif
			invoke lstrcpyn,addr FileName,val,MAX_PATH
			invoke ReadTbrFile,hWin
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDC_BTNB
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				m2m		ofn.hwndOwner,hWin
				m2m		ofn.hInstance,hInstance
				mov		ofn.lpstrInitialDir,offset ProjectPath
				mov		ofn.lpstrFilter,offset BMPFilterString
				mov		ofn.lpstrDefExt,offset DefBmpExt
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke GetDlgItemText,hWin,IDC_EDTB,addr buffer,sizeof buffer
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTB,addr buffer
				    mov		hBmpInst,0
					.if hBmp
						invoke DeleteObject,hBmp
					.endif
				    invoke LoadImage,0,addr buffer,IMAGE_BITMAP,0,0,LR_LOADFROMFILE or LR_LOADMAP3DCOLORS
			    	mov		hBmp,eax
					invoke ShowToolBar,hWin
					invoke ShowMToolBar,hWin
				.endif
			.elseif eax==IDC_BTNM
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				m2m		ofn.hwndOwner,hWin
				m2m		ofn.hInstance,hInstance
				mov		ofn.lpstrInitialDir,offset ProjectPath
				mov		ofn.lpstrFilter,offset MNUFilterString
				mov		ofn.lpstrDefExt,offset DefMnuExt
				mov		ofn.lpstrTitle,0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				invoke GetDlgItemText,hWin,IDC_EDTM,addr buffer,sizeof buffer
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTM,addr buffer
					invoke GetMenuItems,hWin
				.endif
			.elseif eax==IDC_BTNU
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCURSEL,0,0
				.if eax && eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
					push	eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_DELETESTRING,nInx,0
					dec		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_INSERTSTRING,nInx,addr buffer
					pop		eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETITEMDATA,nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETCURSEL,nInx,0
					invoke ShowMToolBar,hWin
					mov		eax,LBN_SELCHANGE
					shl		eax,16
					or		eax,IDC_LSTT
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endif
			.elseif eax==IDC_BTND
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCOUNT,0,0
					dec		eax
					.if eax!=nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
						push	eax
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETTEXT,nInx,addr buffer
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_DELETESTRING,nInx,0
						inc		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_INSERTSTRING,nInx,addr buffer
						pop		eax
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETITEMDATA,nInx,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETCURSEL,nInx,0
						invoke ShowMToolBar,hWin
						mov		eax,LBN_SELCHANGE
						shl		eax,16
						or		eax,IDC_LSTT
						invoke SendMessage,hWin,WM_COMMAND,eax,0
					.endif
				.endif
			.elseif eax==IDC_BTNADDBTN
				invoke SendMessage,hLBMTbr,LB_ADDSTRING,0,addr szID
				mov		nInx,eax
				invoke SendMessage,hLBMTbr,LB_SETITEMDATA,nInx,0FF0000h
				invoke ShowMToolBar,hWin
				invoke SendMessage,hLBMTbr,LB_SETCURSEL,nInx,0
				mov		eax,LBN_SELCHANGE
				shl		eax,16
				or		eax,IDC_LSTT
				invoke SendMessage,hWin,WM_COMMAND,eax,0
			.elseif eax==IDC_BTNINSBTN
				invoke SendMessage,hLBMTbr,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendMessage,hLBMTbr,LB_INSERTSTRING,nInx,addr szID
					mov		nInx,eax
					invoke SendMessage,hLBMTbr,LB_SETITEMDATA,nInx,0FF0000h
					invoke ShowMToolBar,hWin
					invoke SendMessage,hLBMTbr,LB_SETCURSEL,nInx,0
					mov		eax,LBN_SELCHANGE
					shl		eax,16
					or		eax,IDC_LSTT
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endif
			.elseif eax==IDC_BTNADDSEP
				invoke SendMessage,hLBMTbr,LB_ADDSTRING,0,addr szSep
				mov		nInx,eax
				invoke SendMessage,hLBMTbr,LB_SETITEMDATA,nInx,0h
				invoke ShowMToolBar,hWin
				invoke SendMessage,hLBMTbr,LB_SETCURSEL,nInx,0
				mov		eax,LBN_SELCHANGE
				shl		eax,16
				or		eax,IDC_LSTT
				invoke SendMessage,hWin,WM_COMMAND,eax,0
			.elseif eax==IDC_BTNINSSEP
				invoke SendMessage,hLBMTbr,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendMessage,hLBMTbr,LB_INSERTSTRING,nInx,addr szSep
					mov		nInx,eax
					invoke SendMessage,hLBMTbr,LB_SETITEMDATA,nInx,0h
					invoke ShowMToolBar,hWin
					invoke SendMessage,hLBMTbr,LB_SETCURSEL,nInx,0
					mov		eax,LBN_SELCHANGE

					shl		eax,16
					or		eax,IDC_LSTT
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endif
			.elseif eax==IDC_BTNDEL
				invoke SendMessage,hLBMTbr,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendMessage,hLBMTbr,LB_DELETESTRING,nInx,0
					invoke ShowMToolBar,hWin
					invoke SendMessage,hLBMTbr,LB_SETCURSEL,nInx,0
					mov		eax,LBN_SELCHANGE
					shl		eax,16
					or		eax,IDC_LSTT
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endif
			.elseif eax==IDC_CANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDC_BTNEXPORT
				invoke WriteTbrFile,hWin
				invoke ExportTbr,hWin,0
			.elseif eax==IDC_BTNEXPORTFB
				invoke WriteTbrFile,hWin
				invoke ExportTbr,hWin,1
			.elseif eax==IDC_BTNNEW
				invoke NewTbr,hWin
			.elseif eax==IDC_BTNOPEN
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				m2m		ofn.hwndOwner,hWin
				m2m		ofn.hInstance,hInstance
				mov		ofn.lpstrInitialDir,offset ProjectPath
				mov		ofn.lpstrFilter,offset TBRFilterString
				mov		ofn.lpstrDefExt,offset DefTbrExt
				mov		ofn.lpstrTitle,0
				mov		ofn.lpstrFile,offset FileName
				mov		ofn.nMaxFile,sizeof FileName
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke ReadTbrFile,hWin
				.endif
			.elseif eax==IDC_BTNSAVE
				invoke WriteTbrFile,hWin
			.elseif eax==IDC_CHKFLAT
				invoke ShowMToolBar,hWin
			.elseif eax==IDC_CHKWRAP
				invoke ShowMToolBar,hWin
			.elseif eax==IDC_CHKNODIVIDER
				invoke ShowMToolBar,hWin
			.elseif eax==IDC_CHKTIP
				invoke ShowMToolBar,hWin
			.elseif eax==IDC_CHKLIST
				invoke ShowMToolBar,hWin
			.elseif eax==IDC_CHKCHECK
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
					push	eax
					invoke IsDlgButtonChecked,hWin,IDC_CHKCHECK
					pop		edx
					.if eax
						or		edx,1000000h
					.else
						and		edx,-1 xor 1000000h
					.endif
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETITEMDATA,nInx,edx
					invoke ShowMToolBar,hWin
				.endif
			.elseif eax==IDC_CHKGROUP
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
					push	eax
					invoke IsDlgButtonChecked,hWin,IDC_CHKGROUP
					pop		edx
					.if eax
						or		edx,2000000h
					.else
						and		edx,-1 xor 2000000h
					.endif
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETITEMDATA,nInx,edx
					invoke ShowMToolBar,hWin
				.endif
			.elseif eax<56
				invoke SendMessage,hLBMTbr,LB_SETCURSEL,eax,0
				mov		eax,LBN_SELCHANGE
				shl		eax,16
				or		eax,IDC_LSTT
				invoke SendMessage,hWin,WM_COMMAND,eax,0
			.endif
		.elseif edx==LBN_DBLCLK
			.if eax==IDC_LSTM
				invoke SendDlgItemMessage,hWin,IDC_LSTM,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTM,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCURSEL,0,0
					.if eax!=LB_ERR
						mov		nInx,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
						push	eax
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_DELETESTRING,nInx,0
						lea		edx,buffer
						dec		edx
					  @@:
						inc		edx
						mov		al,[edx]
						or		al,al
						je		@f
						cmp		al,VK_TAB
						jne		@b
						inc		edx
					  @@:
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_INSERTSTRING,nInx,edx
						pop		eax
						and		eax,0FFFF0000h
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETITEMDATA,nInx,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETCURSEL,nInx,0
						mov		eax,LBN_SELCHANGE
						shl		eax,16
						or		eax,IDC_LSTT
						invoke SendMessage,hWin,WM_COMMAND,eax,0
					.else
						pop		eax
						invoke MessageBeep,MB_OK
					.endif
				.endif
			.endif
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTT
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_EDTT,WM_SETTEXT,0,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
					push	eax
					and		eax,0FFFFh
					invoke SetDlgItemInt,hWin,IDC_EDTIDT,eax,FALSE
					pop		eax
					push	eax
					shr		eax,24
					and		eax,1
					invoke CheckDlgButton,hWin,IDC_CHKCHECK,eax
					pop		eax
					shr		eax,25
					and		eax,1
					invoke CheckDlgButton,hWin,IDC_CHKGROUP,eax
				.else
					invoke SendDlgItemMessage,hWin,IDC_EDTT,WM_SETTEXT,0,NULL
					invoke SendDlgItemMessage,hWin,IDC_EDTIDT,WM_SETTEXT,0,NULL
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTT
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke GetDlgItemText,hWin,IDC_EDTT,addr buffer,256
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
					push	eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_DELETESTRING,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_INSERTSTRING,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETCURSEL,nInx,0
					pop		eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETITEMDATA,nInx,eax
				.endif
			.elseif eax==IDC_EDTIDT
				invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_GETITEMDATA,nInx,0
					push	eax
					invoke GetDlgItemInt,hWin,IDC_EDTIDT,addr val,FALSE
					pop		edx
					and		edx,0FFFF0000h
					or		eax,edx
					invoke SendDlgItemMessage,hWin,IDC_LSTT,LB_SETITEMDATA,nInx,eax
				.endif
			.elseif eax==IDC_EDTBTNSIZE
				invoke ShowToolBar,hWin
				invoke ShowMToolBar,hWin
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
