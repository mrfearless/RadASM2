
.const

IDD_DLGMENUEDIT			equ 2500
IDC_EDTMENUNAME			equ 2503
IDC_EDTMENUID			equ 2505
IDC_EDTSTARTID			equ 2507
IDC_EDTITEMCAPTION		equ 2512
IDC_CBOMNU				equ 2513
IDC_EDTITEMNAME			equ 2516
IDC_EDTITEMID			equ 2518
IDC_BTNINSERT			equ 2519
IDC_BTNDELETE			equ 2520
IDC_BTNL				equ 2521
IDC_BTNR				equ 2522
IDC_BTNU				equ 2523
IDC_BTND				equ 2524
IDC_LSTMNU				equ 2525
IDC_CHKCHECKED			equ 2526
IDC_CHKGRAYED			equ 2527
IDC_CHKINACTIVE			equ 2530
IDC_CHKRIGHT			equ 2508
IDC_CHKRADIO			equ 2509
IDC_CHKOWNERDRAW		equ 2531
IDC_CHKRIGHTORDER		equ 2532
IDC_BTNEXPORT			equ 2528
IDC_BTNREMOVE			equ 2529

.data

szMnuName				db 'IDR_MENU',0
MnuID					dd 10000
MnuItemID				dd 10001
szMnuItemName			db 'IDM_',0
hMnuMem					dd 0
nMnuInx					dd 0
fMnuSel					dd FALSE
MnuTabs					dd 115,120,125,130,135,140

.code

MnuGetFreeMem proc uses esi

	mov		esi,hMnuMem
	add		esi,sizeof MNUHEAD
	sub		esi,sizeof MNUITEM
  @@:
	add		esi,sizeof MNUITEM
	mov		eax,(MNUITEM ptr [esi]).itemflag
	.if eax==-1
		xor		eax,eax
	.endif
	or		eax,eax
	jne		@b
	mov		eax,esi
	ret

MnuGetFreeMem endp

MnuGetFreeID proc uses esi
	LOCAL	nId:DWORD

	mov		esi,hMnuMem
	movzx	eax,(MNUHEAD ptr [esi]).startid
	mov		nId,eax
	add		esi,sizeof MNUHEAD
	sub		esi,sizeof MNUITEM
  @@:
	add		esi,sizeof MNUITEM
	mov		eax,(MNUITEM ptr [esi]).itemflag
	cmp		eax,-1
	je		@b
	.if eax
		mov		eax,(MNUITEM ptr [esi]).itemid
		.if eax==nId
			inc		nId
			mov		esi,hMnuMem
			add		esi,sizeof MNUHEAD
			sub		esi,sizeof MNUITEM
		.endif
		jmp		@b
	.endif
	mov		eax,nId
	ret

MnuGetFreeID endp

MnuGetMem proc uses esi,hWin:HWND
	LOCAL	val:DWORD

	invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCURSEL,0,0
	mov		nMnuInx,eax
	invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
	.if !eax
		.if fMnuSel==FALSE
			invoke MnuGetFreeMem
			mov		esi,eax
			invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nMnuInx,esi
			mov		(MNUITEM ptr [esi]).itemflag,1
			invoke GetDlgItemText,hWin,IDC_EDTITEMCAPTION,addr (MNUITEM ptr [esi]).itemcaption,64
			invoke GetDlgItemText,hWin,IDC_EDTITEMNAME,addr (MNUITEM ptr [esi]).itemname,32
			invoke GetDlgItemInt,hWin,IDC_EDTITEMID,addr val,FALSE
			m2m		(MNUITEM ptr [esi]).itemid,eax
			invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCOUNT,0,0
			.if eax
				dec		eax
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,eax,0
				.if eax
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_ADDSTRING,0,addr szNULL
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,eax,0
				.endif
			.endif
			mov		eax,esi
		.endif
	.endif
	ret

MnuGetMem endp

MnuSaveDefine proc uses esi,lpName:DWORD,lpID:DWORD
	LOCAL	buffer[16]:BYTE

	mov		esi,lpName
	mov		al,[esi]
	.if al
		mov		esi,lpID
		.if word ptr [esi]
			invoke SaveStr,edi,addr szDEFINE
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveStr,edi,lpName
			add		edi,eax
			mov		al,' '
			stosb
			movzx	edx,word ptr [esi]
			invoke BinToDec,edx,addr buffer
			invoke SaveStr,edi,addr buffer
			add		edi,eax
			mov		ax,0A0Dh
			stosw
		.endif
	.endif
	ret

MnuSaveDefine endp

MnuSpc proc val:DWORD

	push	eax
	push	ecx
	mov		eax,val
	inc		eax
	add		eax,eax
	mov		ecx,eax
	mov		al,' '
	rep stosb
	pop		ecx
	pop		eax
	ret

MnuSpc endp

MnuSaveItem proc uses ebx,hWin:HWND,lpItem:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	val:DWORD
	LOCAL	pos:DWORD

	invoke SaveStr,edi,lpItem
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	xor		ebx,ebx
	mov		al,(MNUITEM ptr [esi]).itemcaption
	.if al=="-" || !al
		mov		ebx,MFT_SEPARATOR
	.else
		invoke SaveStr,edi,addr (MNUITEM ptr [esi]).itemcaption
		add		edi,eax
		mov		eax,(MNUITEM ptr [esi]).shortcut
		.if eax
			push	edi
			mov		edi,eax
			mov		val,0
			.while TRUE
				invoke SendDlgItemMessage,hWin,IDC_CBOMNU,CB_GETITEMDATA,val,0
				.if eax==CB_ERR
					mov		val,0
					.break
				.elseif eax==edi
					.break
				.endif
				inc		val
			.endw
			pop		edi
			invoke SendDlgItemMessage,hWin,IDC_CBOMNU,CB_GETLBTEXT,val,addr buffer
			mov		ax,'t\'
			stosw
			invoke SaveStr,edi,addr buffer
			add		edi,eax
		.endif
	.endif
	mov		al,22h
	stosb
	mov		pos,edi
	mov		al,','
	stosb
	mov		al,(MNUITEM ptr [esi]).itemname
	.if !al
		mov		eax,(MNUITEM ptr [esi]).itemid
		.if eax && eax!=-1
			invoke SaveVal,eax,FALSE
			mov		pos,edi
		.endif
	.else
		invoke SaveStr,edi,addr (MNUITEM ptr [esi]).itemname
		add		edi,eax
		mov		pos,edi
	.endif
	xor		edx,edx
	test	(MNUITEM ptr [esi]).flag,1
	.if !ZERO?
		mov		edx,MF_CHECKED
	.endif
	test	(MNUITEM ptr [esi]).flag,2
	.if !ZERO?
		or		edx,MF_GRAYED
	.endif
	test	(MNUITEM ptr [esi]).flag,4
	.if !ZERO?
		or		ebx,MF_RIGHTJUSTIFY
	.endif
	test	(MNUITEM ptr [esi]).flag,8
	.if !ZERO?
		or		ebx,MFT_RADIOCHECK
	.endif
	test	(MNUITEM ptr [esi]).flag,16
	.if !ZERO?
		or		edx,MF_DISABLED
	.endif
	test	(MNUITEM ptr [esi]).flag,32
	.if !ZERO?
		or		ebx,MF_OWNERDRAW
	.endif
	test	(MNUITEM ptr [esi]).flag,64
	.if !ZERO?
		or		ebx,MFT_RIGHTORDER
	.endif
	mov		al,','
	stosb
	.if ebx
		push	edx
		invoke SaveHexVal,ebx,FALSE
		mov		pos,edi
		pop		edx
	.endif
	mov		al,','
	stosb
	.if edx
		invoke SaveHexVal,edx,FALSE
		mov		pos,edi
	.endif
	mov		edi,pos
	mov		ax,0A0Dh
	stosw
	ret

MnuSaveItem endp

MnuExport proc uses esi,hWin:HWND,bSave:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hWrMem:DWORD
	LOCAL	val:DWORD
	LOCAL	level:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	push	edi
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*100
	mov     hWrMem,eax
	invoke GlobalLock,hWrMem
	mov		esi,hMnuMem
	mov		edi,hWrMem
	invoke MnuSaveDefine,addr (MNUHEAD ptr [esi]).menuname,addr (MNUHEAD ptr [esi]).menuid
	add		esi,sizeof MNUHEAD
  @@:
	mov		eax,(MNUITEM ptr [esi]).itemflag
	.if eax
		.if eax!=-1
			invoke MnuSaveDefine,addr (MNUITEM ptr [esi]).itemname,addr (MNUITEM ptr [esi]).itemid
		.endif
		add		esi,sizeof MNUITEM
		jmp		@b
	.endif
	mov		esi,hMnuMem
	mov		al,(MNUHEAD ptr [esi]).menuname
	.if al
		invoke SaveStr,edi,addr (MNUHEAD ptr [esi]).menuname
		add		edi,eax
	.else
		movzx	edx,(MNUHEAD ptr [esi]).menuid
		invoke SaveVal,edx,FALSE
	.endif
	mov		al,' '
	stosb
	invoke SaveStr,edi,addr szMENUEX
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	mov		level,0
	add		esi,sizeof MNUHEAD
  Nx:
	mov		eax,(MNUITEM ptr [esi]).itemflag
	.if eax
		.if eax!=-1
			mov		eax,(MNUITEM ptr [esi]).level
			.if eax!=level
				push	edi
				invoke MessageBox,hWin,addr szMnuErr,addr AppName,MB_OK or MB_ICONERROR
				pop		edi
				mov		eax,TRUE
				jmp		MnExEx
			.endif
			push	esi
		  @@:
			add		esi,sizeof MNUITEM
			mov		eax,(MNUITEM ptr [esi]).itemflag
			.if eax
				.if eax==-1
					jmp		@b
				.endif
				mov		eax,(MNUITEM ptr [esi]).level
			.endif
			mov		val,eax
			pop		esi
			invoke MnuSpc,level
			.if eax>level
				invoke MnuSaveItem,hWin,addr szPOPUP
			.else
				invoke MnuSaveItem,hWin,addr szMENUITEM
			.endif
			mov		eax,val
			.if eax>level
				sub		eax,level
				.if eax!=1
					push	edi
					invoke MessageBox,hWin,addr szMnuErr,addr AppName,MB_OK or MB_ICONERROR
					pop		edi
					mov		eax,TRUE
					jmp		MnExEx
				.endif
				invoke MnuSpc,level
				m2m		level,val
				invoke SaveStr,edi,addr szBEGIN
				add		edi,eax
				mov		ax,0A0Dh
				stosw
			.elseif eax<level
			  @@:
				mov		eax,val
				.if eax!=level
					dec		level
					invoke MnuSpc,level
					invoke SaveStr,edi,addr szEND
					add		edi,eax
					mov		ax,0A0Dh
					stosw
					jmp		@b
				.endif
			.endif
			add		esi,sizeof MNUITEM
			jmp		Nx
		.endif
	.endif
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	.if bSave
		invoke strcpy,addr buffer,addr ProjectPath
		invoke strlen,addr buffer
		lea		edi,buffer
		add		edi,eax
		mov		al,'R'
		stosb
		mov		al,'e'
		stosb
		mov		al,'s'
		stosb
		mov		al,'\'
		stosb
		invoke strlen,addr FileName
		mov		esi,offset FileName
		add		esi,eax
	  @@:
		dec		esi
		mov		al,[esi]
		cmp		al,'\'
		jne		@b
		inc		esi
	  @@:
		mov		al,[esi]
		cmp		al,'.'
		je		@f
		or		al,al
		je		@f
		mov		[edi],al
		inc		esi
		inc		edi
		jmp		@b
	  @@:
		mov		al,'M'
		stosb
		mov		al,'n'
		stosb
		mov		al,'u'
		stosb
		mov		al,'.'
		stosb
		mov		al,'R'
		stosb
		mov		al,'c'
		stosb
		mov		al,0
		stosb
		invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strlen,hWrMem
			mov		nBytes,eax
			invoke WriteFile,hFile,hWrMem,nBytes,addr nBytes,NULL
			invoke CloseHandle,hFile
			mov		eax,FALSE
		.else
			invoke strcpy,addr LineTxt,addr SaveFileFail
			invoke strcat,addr LineTxt,addr buffer
			invoke MessageBox,hWin,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
			mov		eax,TRUE
		.endif
	.else
		invoke OutputSelect,2
		invoke OutputClear
		invoke TextToOutput,hWrMem
		mov		eax,FALSE
	.endif
  MnExEx:
	push	eax
	invoke GlobalUnlock,hWrMem
	invoke GlobalFree,hWrMem
	pop		eax
	pop		edi
	ret

MnuExport endp

MnuSave proc uses esi edi,hWin:HWND,bSave:DWORD
	LOCAL	hMem:DWORD
	LOCAL	nInx:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MaxMem
	mov     hMem,eax
	invoke GlobalLock,hMem
	mov		esi,hMnuMem
	mov		edi,hMem
	mov		ecx,sizeof MNUHEAD
	rep movsb
	mov		nInx,0
  @@:
	invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nInx,0
	.if eax!=LB_ERR
		.if eax
			mov		esi,eax
			invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nInx,edi
			mov		eax,(MNUITEM ptr [esi]).itemflag
			.if eax!=-1
				mov		ecx,sizeof MNUITEM
				rep movsb
			.endif
		.endif
		inc		nInx
		jmp		@b
	.endif
	invoke GlobalUnlock,hMnuMem
	invoke GlobalFree,hMnuMem
	m2m		hMnuMem,hMem
	mov		eax,FALSE
	.if bSave
		invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			mov		esi,hMnuMem
			add		esi,sizeof MNUHEAD
		  @@:
			mov		eax,(MNUITEM ptr [esi]).itemflag
			.if eax
				add		esi,sizeof MNUITEM
				jmp		@b
			.endif
			mov		eax,esi
			sub		eax,hMnuMem
			mov		nBytes,eax
			invoke WriteFile,hFile,hMnuMem,nBytes,addr nBytes,NULL
			invoke CloseHandle,hFile
			mov		eax,FALSE
			.if fSaveRcFile
				invoke MnuExport,hWin,TRUE
				inc		fResChanged
				invoke DllProc,hWnd,AIM_RCSAVED,2,addr FileName,RAM_RCSAVED
			.endif
		.else
			invoke strcpy,addr LineTxt,addr SaveFileFail
			invoke strcat,addr LineTxt,addr FileName
			invoke MessageBox,hWin,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
			mov		eax,TRUE
		.endif
	.endif
	ret

MnuSave endp

MnuSetCbo proc uses ebx esi,hWin:HWND,ID:DWORD
	LOCAL	hCtl:DWORD
;	LOCAL	nChr:DWORD
	LOCAL	buffer[64]:byte

	invoke GetDlgItem,hWin,ID
	mov		hCtl,eax
	mov		esi,offset szAclKeys
	xor		ebx,ebx
	.while ebx<7
		call	AddAccel
		inc		ebx
	.endw
	invoke SendMessage,hCtl,CB_SETCURSEL,0,0
	ret

AddAccel:
	push	esi
	.while byte ptr [esi+1]
		movzx	eax,byte ptr [esi]
		.if !((!eax && ebx) || (eax>='0' && eax<='9' && ebx<2) || (eax>='A' && eax<='Z' && ebx<2))
			mov		buffer,0
			test	ebx,HOTKEYF_ALT
			.if !ZERO?
				invoke strcat,addr buffer,addr szAlt
			.endif
			test	ebx,HOTKEYF_CONTROL
			.if !ZERO?
				invoke strcat,addr buffer,addr szCtrl
			.endif
			test	ebx,HOTKEYF_SHIFT
			.if !ZERO?
				invoke strcat,addr buffer,addr szShift
			.endif
			invoke strcat,addr buffer,addr [esi+1]
			invoke SendMessage,hCtl,CB_ADDSTRING,0,addr buffer
			xor		edx,edx
			mov		dh,bl
			mov		dl,[esi]
			invoke SendMessage,hCtl,CB_SETITEMDATA,eax,edx
		.endif
		inc		esi
		invoke strlen,esi
		lea		esi,[esi+eax+1]
	.endw
	pop		esi
	retn

MnuSetCbo endp

MnuEnumProc proc hWin:HWND,lParam:LPARAM

	invoke GetWindowLong,hWin,GWL_ID
	.if eax!=2 && eax!=IDC_LSTMNU && eax!=2501 && eax!=2502 && eax!=2504 && eax!=2506 && eax!=2510 && eax!=2511 && eax!=2514 && eax!=2515 && eax!=2517
		invoke EnableWindow,hWin,FALSE
	.endif
	mov		eax,TRUE
	ret

MnuEnumProc endp

DlgMenuEditProc proc uses esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM, lParam:LPARAM
	LOCAL	hCtl:DWORD
	LOCAL	buffer[64]:byte
	LOCAL	buffer1[256]:byte
	LOCAL	val:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTMENUNAME,EM_LIMITTEXT,31,0
		invoke SendDlgItemMessage,hWin,IDC_EDTITEMCAPTION,EM_LIMITTEXT,63,0
		invoke SendDlgItemMessage,hWin,IDC_EDTITEMNAME,EM_LIMITTEXT,31,0
		invoke MnuSetCbo,hWin,IDC_CBOMNU
		invoke GetDlgItem,hWin,IDC_BTNL
		mov		hCtl,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+0,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		invoke GetDlgItem,hWin,IDC_BTNR
		mov		hCtl,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+1,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		invoke GetDlgItem,hWin,IDC_BTNU
		mov		hCtl,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+2,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		invoke GetDlgItem,hWin,IDC_BTND
		mov		hCtl,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+3,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		mov		esi,hMnuMem
		invoke SetDlgItemText,hWin,IDC_EDTMENUNAME,addr (MNUHEAD ptr [esi]).menuname
		movzx	eax,(MNUHEAD ptr [esi]).menuid
		invoke SetDlgItemInt,hWin,IDC_EDTMENUID,eax,FALSE
		movzx	eax,(MNUHEAD ptr [esi]).startid
		invoke SetDlgItemInt,hWin,IDC_EDTSTARTID,eax,FALSE
		invoke GetDlgItem,hWin,IDC_LSTMNU
		mov		hCtl,eax
		invoke SendMessage,hCtl,LB_SETTABSTOPS,6,addr MnuTabs
		add		esi,sizeof MNUHEAD
		mov		nMnuInx,0
	  @@:
		mov		eax,(MNUITEM ptr [esi]).itemflag
		.if eax
			invoke SendMessage,hCtl,LB_INSERTSTRING,nMnuInx,addr szNULL
			invoke SendMessage,hCtl,LB_SETITEMDATA,nMnuInx,esi
			invoke SendMessage,hCtl,LB_SETCURSEL,nMnuInx,0
			mov		eax,LBN_SELCHANGE
			shl		eax,16
			or		eax,IDC_LSTMNU
			invoke SendMessage,hWin,WM_COMMAND,eax,0
			add		esi,sizeof MNUITEM
			inc		nMnuInx
			jmp		@b
		.endif
		invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_ADDSTRING,0,addr szNULL
		invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,eax,0
		mov		nMnuInx,0
		invoke SendMessage,hCtl,LB_SETCURSEL,nMnuInx,0
		mov		eax,LBN_SELCHANGE
		shl		eax,16
		or		eax,IDC_LSTMNU
		invoke SendMessage,hWin,WM_COMMAND,eax,0
		invoke SetLanguage,hWin,IDD_DLGMENUEDIT,FALSE
		.if lParam
			invoke EnumChildWindows,hWin,addr MnuEnumProc,0
		.endif
    .elseif eax==WM_CLOSE
		invoke EndDialog,hWin,wParam
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		shr		eax,16
		.if eax==BN_CLICKED
			mov		eax,wParam
			and		eax,0FFFFh
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,FALSE,0
			.elseif eax==IDOK
				invoke MnuSave,hWin,TRUE
				.if !eax
					invoke SendMessage,hWin,WM_CLOSE,TRUE,0
				.endif
			.elseif eax==IDC_BTNEXPORT
				invoke MnuSave,hWin,FALSE
				invoke MnuExport,hWin,FALSE
			.elseif eax==IDC_BTNREMOVE
				invoke strcpy,addr buffer1,addr Remove
				invoke strcat,addr buffer1,addr FileName
				invoke strcat,addr buffer1,addr Remove2
				invoke MessageBox,hWin,addr buffer1,addr AppName,MB_YESNO or MB_ICONQUESTION
				.if eax==IDYES
					invoke ProRemoveFile,addr FileName
				.endif
			.elseif eax==IDC_BTNL
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					mov		eax,(MNUITEM ptr[esi]).level
					.if eax
						dec		(MNUITEM ptr[esi]).level
						mov		eax,EN_CHANGE
						shl		eax,16
						or		eax,IDC_EDTITEMCAPTION
						invoke SendMessage,hWin,WM_COMMAND,eax,0
					.endif
				.endif
			.elseif eax==IDC_BTNR
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					mov		eax,(MNUITEM ptr[esi]).level
					.if eax<9
						inc		(MNUITEM ptr[esi]).level
						mov		eax,EN_CHANGE
						shl		eax,16
						or		eax,IDC_EDTITEMCAPTION
						invoke SendMessage,hWin,WM_COMMAND,eax,0
					.endif
				.endif
			.elseif eax==IDC_BTNU
				.if nMnuInx
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
					.if eax
						mov		esi,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_DELETESTRING,nMnuInx,0
						dec		nMnuInx
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_INSERTSTRING,nMnuInx,addr szNULL
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nMnuInx,esi
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
						mov		eax,LBN_SELCHANGE
						shl		eax,16
						or		eax,IDC_LSTMNU
						invoke SendMessage,hWin,WM_COMMAND,eax,0
					.endif
				.endif
			.elseif eax==IDC_BTND
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCOUNT,0,0
				dec		eax
				.if eax!=nMnuInx
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
					.if eax
						mov		esi,eax
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_DELETESTRING,nMnuInx,0
						inc		nMnuInx
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_INSERTSTRING,nMnuInx,addr szNULL
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nMnuInx,esi
						invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
						mov		eax,LBN_SELCHANGE
						shl		eax,16
						or		eax,IDC_LSTMNU
						invoke SendMessage,hWin,WM_COMMAND,eax,0
					.endif
				.endif
			.elseif eax==IDC_BTNINSERT
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_INSERTSTRING,nMnuInx,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
				mov		eax,LBN_SELCHANGE
				shl		eax,16
				or		eax,IDC_LSTMNU
				invoke SendMessage,hWin,WM_COMMAND,eax,0
			.elseif eax==IDC_BTNDELETE
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCOUNT,0,0
				dec		eax
				.if eax!=nMnuInx
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
					.if eax
						mov		esi,eax
						mov		(MNUITEM ptr [esi]).itemflag,-1
					.endif
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_DELETESTRING,nMnuInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
					.if eax!=LB_ERR
						mov		eax,LBN_SELCHANGE
						shl		eax,16
						or		eax,IDC_LSTMNU
						invoke SendMessage,hWin,WM_COMMAND,eax,0
					.endif
				.endif
			.elseif eax==IDC_CHKCHECKED
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).flag,-1 xor 1
					invoke SendDlgItemMessage,hWin,IDC_CHKCHECKED,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).flag,1
					.endif
				.endif
			.elseif eax==IDC_CHKGRAYED
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).flag,-1 xor 2
					invoke SendDlgItemMessage,hWin,IDC_CHKGRAYED,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).flag,2
					.endif
				.endif
			.elseif eax==IDC_CHKRIGHT
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).flag,-1 xor 4
					invoke SendDlgItemMessage,hWin,IDC_CHKRIGHT,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).flag,4
					.endif
				.endif
			.elseif eax==IDC_CHKRADIO
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).flag,-1 xor 8
					invoke SendDlgItemMessage,hWin,IDC_CHKRADIO,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).flag,8
					.endif
				.endif
			.elseif eax==IDC_CHKINACTIVE
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).flag,-1 xor 16
					invoke SendDlgItemMessage,hWin,IDC_CHKINACTIVE,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).flag,16
					.endif
				.endif
			.elseif eax==IDC_CHKOWNERDRAW
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).flag,-1 xor 32
					invoke SendDlgItemMessage,hWin,IDC_CHKOWNERDRAW,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).flag,32
					.endif
				.endif
			.elseif eax==IDC_CHKRIGHTORDER
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					and		(MNUITEM ptr [esi]).flag,-1 xor 64
					invoke SendDlgItemMessage,hWin,IDC_CHKRIGHTORDER,BM_GETCHECK,0,0
					.if eax==BST_CHECKED
						or		(MNUITEM ptr [esi]).flag,64
					.endif
				.endif
			.endif
		.elseif eax==EN_CHANGE
			mov		eax,wParam
			and		eax,0FFFFh
			.if eax==IDC_EDTITEMCAPTION
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					invoke GetDlgItemText,hWin,IDC_EDTITEMCAPTION,addr buffer,64
					invoke strcpy,addr (MNUITEM ptr [esi]).itemcaption,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_DELETESTRING,nMnuInx,0
					lea		edi,buffer1
					mov		ecx,(MNUITEM ptr [esi]).level
					.if ecx>8
						mov		ecx,8
						mov		(MNUITEM ptr [esi]).level,ecx
					.endif
					.if ecx
						mov		al,'.'
					  @@:
						stosb
						stosb
						loop	@b
					.endif
					invoke strcpy,edi,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_CBOMNU,CB_GETCURSEL,0,0
					.if eax
						mov		val,eax
						invoke SendDlgItemMessage,hWin,IDC_CBOMNU,CB_GETLBTEXT,val,addr buffer
						invoke strlen,addr buffer1
						lea		edi,buffer1
						add		edi,eax
						mov		al,09h
						stosb
						invoke strcpy,edi,addr buffer
					.endif
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_INSERTSTRING,nMnuInx,addr buffer1
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETITEMDATA,nMnuInx,esi
					invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_SETCURSEL,nMnuInx,0
				.endif
			.elseif eax==IDC_EDTITEMNAME
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					invoke GetDlgItemText,hWin,IDC_EDTITEMNAME,addr (MNUITEM ptr [esi]).itemname,32
				.endif
			.elseif eax==IDC_EDTITEMID
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					invoke GetDlgItemInt,hWin,IDC_EDTITEMID,addr val,FALSE
					mov		(MNUITEM ptr [esi]).itemid,eax
				.endif
			.elseif eax==IDC_EDTMENUNAME
				mov		esi,hMnuMem
				invoke GetDlgItemText,hWin,IDC_EDTMENUNAME,addr (MNUHEAD ptr [esi]).menuname,32
			.elseif eax==IDC_EDTMENUID
				mov		esi,hMnuMem
				invoke GetDlgItemInt,hWin,IDC_EDTMENUID,addr val,FALSE
				mov		(MNUHEAD ptr [esi]).menuid,ax
			.elseif eax==IDC_EDTSTARTID
				mov		esi,hMnuMem
				invoke GetDlgItemInt,hWin,IDC_EDTSTARTID,addr val,FALSE
				mov		(MNUHEAD ptr [esi]).startid,ax
			.endif
		.elseif eax==LBN_SELCHANGE
			mov		eax,wParam
			and		eax,0FFFFh
			.if eax==IDC_LSTMNU
				mov		fMnuSel,TRUE
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETCURSEL,0,0
				mov		nMnuInx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTMNU,LB_GETITEMDATA,nMnuInx,0
				.if !eax
					invoke SendDlgItemMessage,hWin,IDC_CBOMNU,CB_SETCURSEL,0,0
					invoke SetDlgItemText,hWin,IDC_EDTITEMCAPTION,addr szNULL
					invoke SetDlgItemText,hWin,IDC_EDTITEMNAME,addr szMnuItemName
					invoke MnuGetFreeID
					invoke SetDlgItemInt,hWin,IDC_EDTITEMID,eax,FALSE
					invoke SendDlgItemMessage,hWin,IDC_CHKCHECKED,BM_SETCHECK,BST_UNCHECKED,0
					invoke SendDlgItemMessage,hWin,IDC_CHKGRAYED,BM_SETCHECK,BST_UNCHECKED,0
					invoke SendDlgItemMessage,hWin,IDC_CHKRIGHT,BM_SETCHECK,BST_UNCHECKED,0
					invoke SendDlgItemMessage,hWin,IDC_CHKRADIO,BM_SETCHECK,BST_UNCHECKED,0
					invoke SendDlgItemMessage,hWin,IDC_CHKINACTIVE,BM_SETCHECK,BST_UNCHECKED,0
					invoke SendDlgItemMessage,hWin,IDC_CHKRIGHTORDER,BM_SETCHECK,BST_UNCHECKED,0
				.else
					mov		esi,eax
					mov		edi,(MNUITEM ptr [esi]).shortcut
					mov		val,0
					.while TRUE
						invoke SendDlgItemMessage,hWin,IDC_CBOMNU,CB_GETITEMDATA,val,0
						.if eax==CB_ERR
							mov		val,0
							.break
						.elseif eax==edi
							.break
						.endif
						inc		val
					.endw
					invoke SendDlgItemMessage,hWin,IDC_CBOMNU,CB_SETCURSEL,val,0
					invoke lstrcpyn,addr buffer1,addr (MNUITEM ptr [esi]).itemname,32
					invoke SetDlgItemText,hWin,IDC_EDTITEMNAME,addr buffer1
					invoke lstrcpyn,addr buffer1,addr (MNUITEM ptr [esi]).itemcaption,64
					invoke SetDlgItemText,hWin,IDC_EDTITEMCAPTION,addr buffer1
					invoke SetDlgItemInt,hWin,IDC_EDTITEMID,(MNUITEM ptr [esi]).itemid,FALSE
					test	(MNUITEM ptr [esi]).flag,1
					.if !ZERO?
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKCHECKED,BM_SETCHECK,eax,0
					test	(MNUITEM ptr [esi]).flag,2
					.if !ZERO?
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKGRAYED,BM_SETCHECK,eax,0
					test	(MNUITEM ptr [esi]).flag,4
					.if !ZERO?
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKRIGHT,BM_SETCHECK,eax,0
					test	(MNUITEM ptr [esi]).flag,8
					.if !ZERO?
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKRADIO,BM_SETCHECK,eax,0
					test	(MNUITEM ptr [esi]).flag,16
					.if !ZERO?
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKINACTIVE,BM_SETCHECK,eax,0
					test	(MNUITEM ptr [esi]).flag,32
					.if !ZERO?
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKOWNERDRAW,BM_SETCHECK,eax,0
					test	(MNUITEM ptr [esi]).flag,64
					.if !ZERO?
						mov		eax,BST_CHECKED
					.else
						mov		eax,BST_UNCHECKED
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CHKRIGHTORDER,BM_SETCHECK,eax,0
				.endif
				mov		fMnuSel,FALSE
			.elseif eax==IDC_CBOMNU
				invoke MnuGetMem,hWin
				.if eax
					mov		esi,eax
					invoke SendDlgItemMessage,hWin,IDC_CBOMNU,CB_GETCURSEL,0,0
					invoke SendDlgItemMessage,hWin,IDC_CBOMNU,CB_GETITEMDATA,eax,0
					mov		(MNUITEM ptr [esi]).shortcut,eax
					mov		eax,EN_CHANGE
					shl		eax,16
					or		eax,IDC_EDTITEMCAPTION
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endif
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgMenuEditProc endp

ConvertShortcut proc nAccel:DWORD

	;Convert shortcut
	mov		eax,nAccel
	.if eax<=26
		;Ctrl+A - Ctrl+Z
		or		eax,240h
	.elseif eax<=26+12
		;F1 - F12
		sub		eax,26+1
		or		eax,70h
	.elseif eax<=26+12+12
		;Ctrl+F1 - Ctrl+F12
		sub		eax,26+1+12
		or		eax,270h
	.elseif eax<=26+12+12+12
		;Shift+F1 - Shift+F12
		sub		eax,26+1+12+12
		or		eax,170h
	.elseif eax<=26+12+12+12+12
		;Shift+Ctrl+F1 - Shift+Ctrl+F12
		sub		eax,26+1+12+12+12
		or		eax,370h
	.elseif eax<=26+12+12+12+12+12
		;Alt+F1 - Alt+F12
		sub		eax,26+1+12+12+12+12
		or		eax,470h
	.elseif eax<=26+12+12+12+12+12+12
		;Alt+Ctrl+F1 - Alt+Ctrl+F12
		sub		eax,26+1+12+12+12+12+12
		or		eax,670h
	.elseif eax<=26+12+12+12+12+12+12+12
		;Alt+Shift+F1 - Alt+Shift+F12
		sub		eax,26+1+12+12+12+12+12+12
		or		eax,570h
	.elseif eax<=26+12+12+12+12+12+12+12+26
		;Alt+A - Alt+Z
		sub		eax,26+12+12+12+12+12+12+12
		or		eax,440h
	.elseif eax<=26+12+12+12+12+12+12+12+26+26
		;Alt+Ctrl+A - Alt+Ctrl+Z
		sub		eax,26+12+12+12+12+12+12+12+26
		or		eax,640h
	.elseif eax<=26+12+12+12+12+12+12+12+26+26+26
		;Alt+Shift+A - Alt+Shift+Z
		sub		eax,26+12+12+12+12+12+12+12+26+26
		or		eax,540h
	.elseif eax<=26+12+12+12+12+12+12+12+26+26+26+26
		;Shift+Ctrl+A - Shift+Ctrl+Z
		sub		eax,26+12+12+12+12+12+12+12+26+26+26
		or		eax,340h
	.else
		xor		eax,eax
	.endif
	ret

ConvertShortcut endp

ConvertMnu proc uses esi,hMem:DWORD

	mov		esi,hMem
	.if [esi].MNUHEAD.version!=100
		mov		[esi].MNUHEAD.version,100
		add		esi,sizeof MNUHEAD
	  @@:
		.if [esi].MNUITEM.itemflag
			mov		eax,[esi].MNUITEM.shortcut
			.if eax
				invoke ConvertShortcut,eax
				mov		[esi].MNUITEM.shortcut,eax
			.endif
			mov		eax,[esi].MNUITEM.flag
			shl		eax,1
			or		eax,[esi].MNUITEM.dummy
			mov		[esi].MNUITEM.dummy,0
			mov		[esi].MNUITEM.flag,eax
			add		esi,sizeof MNUITEM
			jmp		@b
		.endif
	.endif
	ret

ConvertMnu endp

CreateMnu proc uses esi,fNew:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	hMem:DWORD

	invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MaxMem
		mov     hMem,eax
		invoke GlobalLock,hMem
		.if fNew==2
			invoke CloseHandle,hFile
			mov		esi,hMem
			invoke strcpy,addr [esi].MNUHEAD.menuname,addr szMnuName
			mov		eax,MnuID
			mov		[esi].MNUHEAD.menuid,ax
			mov		eax,MnuItemID
			mov		[esi].MNUHEAD.startid,ax
			mov		[esi].MNUHEAD.version,100
		.else
			invoke ReadFile,hFile,hMem,MaxMem,addr nBytes,NULL
			invoke CloseHandle,hFile
		.endif
		invoke ConvertMnu,hMem
		.if fNew==3
			mov		eax,hMem
		.else
			m2m		hMnuMem,hMem
			invoke GetFileAttributes,addr FileName
			and		eax,FILE_ATTRIBUTE_READONLY
			invoke ModalDialog,hInstance,IDD_DLGMENUEDIT,hWnd,addr DlgMenuEditProc,eax
			invoke GlobalUnlock,hMnuMem
			invoke GlobalFree,hMnuMem
		.endif
	.else
		invoke strcpy,addr LineTxt,addr OpenFileFail
		invoke strcat,addr LineTxt,addr FileName
		invoke MessageBox,hWnd,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		xor		eax,eax
	.endif
	ret

CreateMnu endp

