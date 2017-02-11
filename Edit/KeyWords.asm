
IDD_DLGKEYWORDS		equ 4200
IDC_LSTKWCOLORS		equ 4001
IDC_LSTKWACTIVE		equ 4014
IDC_LSTKWHOLD		equ 4013
IDC_LSTCOLORS		equ 4015
IDC_BTNKWAPPLY		equ 4002

IDC_BTNHOLD			equ 4009
IDC_BTNACTIVE		equ 4008
IDC_EDTKW			equ 4012
IDC_BTNKWADD		equ 4011
IDC_BTNKWDEL		equ 4010

IDC_CHKBOLD			equ 4004
IDC_CHKITALIC		equ 4003
IDC_CHKRCFILE		equ 4005

IDC_CHKFLICKER		equ 4016
IDC_CHKDIVLINE		equ 4017
IDC_CHKHILIGTH		equ 4018
IDC_CHKHILITELINE	equ 4025
IDC_CHKHILITECMNT	equ 4024

IDC_CBOTHEME		equ 4020
IDC_BTNLOADTHEME	equ 4021
IDC_BTNDELTHEME		equ 4022
IDC_BTNADDTHEME		equ 4023

szColors			dd offset racol.bckcol
					db 'Back color',0
					dd offset racol.txtcol
					db 'Text color',0
					dd offset racol.selbckcol
					db 'Selected back',0
					dd offset racol.seltxtcol
					db 'Selected text',0
					dd offset racol.hicol1
					db 'Hilited line #1',0
					dd offset racol.hicol2
					db 'Hilited line #2',0
					dd offset racol.hicol3
					db 'Indent marker',0
					dd offset racol.selbarbck
					db 'Selectionbar',0
					dd offset racol.selbarpen
					db 'Selectionbar pen',0
					dd offset racol.lnrcol
					db 'Line numbers',0
					dd offset radcol.output
					db 'Output window',0
					dd offset radcol.outputtext
					db 'Output text',0
					dd offset radcol.project
					db 'Project browser',0
					dd offset radcol.projecttext
					db 'Project text',0
					dd offset radcol.properties
					db 'Properties',0
					dd offset radcol.propertiestext
					db 'Properties text',0
					dd offset radcol.info
					db 'Info',0
					dd offset radcol.infotext
					db 'Info text',0
					dd offset radcol.dialogedit
					db 'Dialog editor',0
					dd 0,0

szKeyWords			dd offset racol.cmntcol
					db 'Comment',0
					dd offset racol.strcol
					db 'String',0
					dd offset racol.numcol
					db 'Num & hex',0
					dd offset racol.oprcol
					db 'Operator',0
					dd offset radcol.keywords[0*4]
					db 'Group#00',0
					dd offset radcol.keywords[1*4]
					db 'Group#01',0
					dd offset radcol.keywords[2*4]
					db 'Group#02',0
					dd offset radcol.keywords[3*4]
					db 'Group#03',0
					dd offset radcol.keywords[4*4]
					db 'Group#04',0
					dd offset radcol.keywords[5*4]
					db 'Group#05',0
					dd offset radcol.keywords[6*4]
					db 'Group#06',0
					dd offset radcol.keywords[7*4]
					db 'Group#07',0
					dd offset radcol.keywords[8*4]
					db 'Group#08',0
					dd offset radcol.keywords[9*4]
					db 'Group#09',0
					dd offset radcol.keywords[10*4]
					db 'Group#10',0
					dd offset radcol.keywords[11*4]
					db 'Group#11',0
					dd offset radcol.keywords[12*4]
					db 'Group#12',0
					dd offset radcol.keywords[13*4]
					db 'Constants',0
					dd offset radcol.keywords[14*4]
					db "Api's",0
					dd offset radcol.keywords[15*4]
					db 'Structures',0
					dd 0,0

MAXTHEME			equ 16
szCurrent			db 'Current',0

.data?

nKWInx				dd ?
nTHInx				dd ?
backtemp			dd 20 dup(?)

.code

SetKeyWordList proc uses esi edi,hWin:HWND,idLst:DWORD,nInx:DWORD
	LOCAL	hMem:DWORD
	LOCAL	buffer[64]:BYTE

	invoke SendDlgItemMessage,hWin,idLst,LB_RESETCONTENT,0,0
	mov		eax,nInx
	mov		nKWInx,eax
	.if sdword ptr eax>=0
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
		mov		hMem,eax
		mov		buffer,'C'
		invoke BinToDec,nInx,addr buffer[1]
		invoke GetPrivateProfileString,addr iniKeyWords,addr buffer,addr szNULL,hMem,16384,addr iniAsmFile
		mov		eax,hMem
		mov		al,[eax]
		mov		esi,hMem
		dec		esi
	  Nxt:
		inc		esi
		mov		al,[esi]
		or		al,al
		je		Ex
		cmp		al,VK_SPACE
		je		Nxt
		cmp		al,VK_TAB
		je		Nxt
		lea		edi,buffer
	  @@:
		mov		al,[esi]
		.if al==VK_SPACE || al==VK_TAB || !al
			mov		byte ptr [edi],0
			invoke SendDlgItemMessage,hWin,idLst,LB_ADDSTRING,0,addr buffer
			dec		esi
			jmp		Nxt
		.endif
		mov		[edi],al
		inc		esi
		inc		edi
		jmp		@b
	  Ex:
		invoke GlobalFree,hMem
		xor		edi,edi
		inc		edi
	.else
		xor		edi,edi
	.endif
	mov		eax,nInx
	add		eax,4
	invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
	.if eax!=LB_ERR
		shr		eax,24
		mov		esi,eax
		mov		eax,BST_UNCHECKED
		test	esi,1
		.if !ZERO?
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKBOLD,eax
		mov		eax,BST_UNCHECKED
		test	esi,2
		.if !ZERO?
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKITALIC,eax
		mov		eax,BST_UNCHECKED
		test	esi,10h
		.if !ZERO?
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKRCFILE,eax
	.endif
	mov		eax,IDC_CHKRCFILE
	call	EnableDisable
	mov		eax,IDC_EDTKW
	call	EnableDisable
	invoke SendDlgItemMessage,hWin,IDC_EDTKW,WM_GETTEXTLENGTH,0,0
	.if eax
		mov		eax,IDC_BTNKWADD
		call	EnableDisable
	.endif
	ret

EnableDisable:
	invoke GetDlgItem,hWin,eax
	invoke EnableWindow,eax,edi
	retn

SetKeyWordList endp

SaveKWList proc uses esi edi,hWin:HWND,idLst:DWORD,nInx:DWORD
	LOCAL	hMem:DWORD
	LOCAL	buffer[64]:BYTE

	.if sdword ptr nInx>=0
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
		mov		hMem,eax
		mov		edi,eax
		xor		esi,esi
	  @@:
		invoke SendDlgItemMessage,hWin,idLst,LB_GETTEXT,esi,edi
		.if eax!=LB_ERR
			invoke strlen,edi
			add		edi,eax
			mov		byte ptr [edi],VK_SPACE
			inc		edi
			inc		esi
			jmp		@b
		.endif
		.if edi!=hMem
			mov		byte ptr [edi-1],0
		.endif
		mov		buffer,'C'
		invoke BinToDec,nInx,addr buffer[1]
		invoke WritePrivateProfileString,addr iniKeyWords,addr buffer,hMem,addr iniAsmFile
		invoke GlobalFree,hMem
	.endif
	ret

SaveKWList endp

DeleteKWs proc hWin:HWND,idFrom:DWORD
	LOCAL	nInx:DWORD
	LOCAL	nCnt:DWORD

	invoke SendDlgItemMessage,hWin,idFrom,LB_GETSELCOUNT,0,0
	mov		nCnt,eax
	mov		nInx,0
	.while nCnt
		invoke SendDlgItemMessage,hWin,idFrom,LB_GETSEL,nInx,0
		.if eax
			invoke SendDlgItemMessage,hWin,idFrom,LB_DELETESTRING,nInx,0
			dec		nCnt
			mov		eax,1
		.endif
		xor		eax,1
		add		nInx,eax
	.endw
	ret

DeleteKWs endp

MoveKWs proc hWin:HWND,idFrom:DWORD,idTo:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	nCnt:DWORD

	invoke SendDlgItemMessage,hWin,idFrom,LB_GETSELCOUNT,0,0
	mov		nCnt,eax
	mov		nInx,0
	.while nCnt
		invoke SendDlgItemMessage,hWin,idFrom,LB_GETSEL,nInx,0
		.if eax
			invoke SendDlgItemMessage,hWin,idFrom,LB_GETTEXT,nInx,addr buffer
			invoke SendDlgItemMessage,hWin,idFrom,LB_DELETESTRING,nInx,0
			invoke SendDlgItemMessage,hWin,idTo,LB_ADDSTRING,0,addr buffer
			dec		nCnt
			mov		eax,1
		.endif
		xor		eax,1
		add		nInx,eax
	.endw
	ret

MoveKWs endp

UpdateEditColors proc
	LOCAL	rac:RACOLOR

	invoke SendMessage,hOut1,REM_GETCOLOR,0,addr rac
	mov		eax,radcol.output
	mov		rac.bckcol,eax
	mov		eax,radcol.outputtext
	mov		rac.txtcol,eax
	mov		eax,racol.selbarbck
	mov		rac.selbarbck,eax
	invoke SendMessage,hOut1,REM_SETCOLOR,0,addr rac
	invoke SendMessage,hOut2,REM_SETCOLOR,0,addr rac
	invoke SendMessage,hOut3,REM_SETCOLOR,0,addr rac
	.if radcol.project!=0FFFFFFh
		invoke SendMessage,hPbrTrv,TVM_SETBKCOLOR,0,radcol.project
		invoke SendMessage,hPbrTrv,TVM_SETTEXTCOLOR,0,radcol.projecttext
		invoke SendMessage,hFileTrv,TVM_SETBKCOLOR,0,radcol.project
		invoke SendMessage,hFileTrv,TVM_SETTEXTCOLOR,0,radcol.projecttext
	.endif
	.if hBrPrp
		invoke DeleteObject,hBrPrp
	.endif
	invoke CreateSolidBrush,radcol.properties
	mov		hBrPrp,eax
	.if hBrInfo
		invoke DeleteObject,hBrInfo
	.endif
	invoke CreateSolidBrush,radcol.info
	mov		hBrInfo,eax
	.if hBrDlg
		invoke DeleteObject,hBrDlg
	.endif
	invoke CreateSolidBrush,radcol.dialogedit
	mov		hBrDlg,eax
	invoke InvalidateRect,hPrpLst,NULL,TRUE
	invoke InvalidateRect,hPrpCbo,NULL,TRUE
	invoke InvalidateRect,hInfEdt,NULL,TRUE
	invoke UpdateAll,IDM_OPTION_COLORS
	invoke UpdateAll,IDM_OPTION_FONTS
	ret

UpdateEditColors endp

LoadCboTheme proc hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[64]:BYTE

	invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_RESETCONTENT,0,0
	mov		nInx,0
	.while nInx<MAXTHEME
		mov		byte ptr tempbuff,0
		invoke BinToDec,nInx,addr buffer
		mov		dword ptr tempbuff,0
		invoke GetPrivateProfileString,addr iniColor,addr buffer,addr szNULL,addr tempbuff,sizeof tempbuff,addr iniFile
		.if byte ptr tempbuff
			invoke iniGetItem,addr tempbuff,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_ADDSTRING,0,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETITEMDATA,eax,nInx
		.endif
		inc		nInx
	.endw
	invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETCURSEL,0,0
	mov		nTHInx,0
	ret

LoadCboTheme endp

SaveCboTheme proc uses ebx,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	nWInx:DWORD
	LOCAL	buffer[64]:BYTE

	mov		nInx,0
	mov		nWInx,0
	mov		ebx,offset tempbuff[1024]
	mov		dword ptr [ebx],0
	.while nInx<MAXTHEME
		invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETITEMDATA,nInx,0
		.if eax!=CB_ERR
			mov		edx,eax
			invoke BinToDec,edx,addr buffer
			mov		dword ptr tempbuff,0
			invoke GetPrivateProfileString,addr iniColor,addr buffer,addr szNULL,addr tempbuff,sizeof tempbuff,addr iniFile
			invoke iniGetItem,addr tempbuff,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETLBTEXT,nInx,ebx
			invoke strcat,ebx,addr szComma
			invoke strcat,ebx,addr tempbuff
			invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETITEMDATA,nInx,nWInx
			invoke strlen,ebx
			lea		ebx,[ebx+eax+1]
			mov		byte ptr [ebx],0
			inc		nWInx
		.endif
		inc		nInx
	.endw
	mov		nInx,0
	mov		ebx,offset tempbuff[1024]
	.while nInx<MAXTHEME && byte ptr [ebx]
		invoke BinToDec,nInx,addr buffer
		invoke WritePrivateProfileString,addr iniColor,addr buffer,ebx,addr iniFile
		invoke strlen,ebx
		lea		ebx,[ebx+eax+1]
		inc		nInx
	.endw
	ret

SaveCboTheme endp

AddCboTheme proc uses ebx,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[4]:BYTE

	mov		nInx,MAXTHEME-1
	.while nInx
		dec		nInx
		invoke BinToDec,nInx,addr buffer
		mov		dword ptr tempbuff,0
		invoke GetPrivateProfileString,addr iniColor,addr buffer,addr szNULL,addr tempbuff,sizeof tempbuff,addr iniFile
		mov		edx,nInx
		inc		edx
		invoke BinToDec,edx,addr buffer
		invoke WritePrivateProfileString,addr iniColor,addr buffer,addr tempbuff,addr iniFile
	.endw
	invoke strcpy,addr tempbuff,addr szCurrent
	invoke strcat,addr tempbuff,addr szComma
	xor		ebx,ebx
	.while ebx<19
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETITEMDATA,ebx,0
		invoke iniPutItem,eax,addr tempbuff,TRUE
		inc		ebx
	.endw
	xor		ebx,ebx
	.while ebx<19
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,ebx,0
		invoke iniPutItem,eax,addr tempbuff,TRUE
		inc		ebx
	.endw
	invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,ebx,0
	invoke iniPutItem,eax,addr tempbuff,TRUE
	xor		ebx,ebx
	.while ebx<19
		mov		eax,backtemp[ebx*4]
		invoke iniPutItem,eax,addr tempbuff,TRUE
		inc		ebx
	.endw
	mov		eax,backtemp[ebx*4]
	invoke iniPutItem,eax,addr tempbuff,FALSE
	invoke BinToDec,nInx,addr buffer
	invoke WritePrivateProfileString,addr iniColor,addr buffer,addr tempbuff,addr iniFile
	invoke LoadCboTheme,hWin
	invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_FINDSTRINGEXACT,-1,addr szCurrent
	mov		nTHInx,eax
	invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETCURSEL,eax,0
	invoke GetDlgItem,hWin,IDC_CBOTHEME
	invoke SetFocus,eax
	ret

AddCboTheme endp

ApplyCboTheme proc uses ebx,hWin:HWND
	LOCAL	buffer[4]:BYTE

	invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETCURSEL,0,0
	.if eax!=CB_ERR
		mov		nTHInx,eax
		invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETITEMDATA,eax,0
		mov		ebx,eax
		invoke BinToDec,ebx,addr buffer
		mov		dword ptr tempbuff,0
		invoke GetPrivateProfileString,addr iniColor,addr buffer,addr szNULL,addr tempbuff,sizeof tempbuff,addr iniFile
		invoke iniGetItem,addr tempbuff,addr tempbuff[8192]
		xor		ebx,ebx
		.while ebx<19
			invoke iniGetItem,addr tempbuff,addr tempbuff[8192]
			invoke DecToBin,addr tempbuff[8192]
			invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETITEMDATA,ebx,eax
			inc		ebx
		.endw
		xor		ebx,ebx
		.while ebx<20
			invoke iniGetItem,addr tempbuff,addr tempbuff[8192]
			invoke DecToBin,addr tempbuff[8192]
			invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,ebx,eax
			inc		ebx
		.endw
		xor		ebx,ebx
		.while ebx<20
			invoke iniGetItem,addr tempbuff,addr tempbuff[8192]
			invoke DecToBin,addr tempbuff[8192]
			mov		backtemp[ebx*4],eax
			inc		ebx
		.endw
		invoke GetDlgItem,hWin,IDC_LSTCOLORS
		invoke InvalidateRect,eax,NULL,FALSE
		invoke GetDlgItem,hWin,IDC_LSTKWCOLORS
		invoke InvalidateRect,eax,NULL,FALSE
		mov		eax,LBN_SELCHANGE
		shl		eax,16
		or		eax,IDC_LSTKWCOLORS
		invoke SendMessage,hWin,WM_COMMAND,eax,0
		xor		eax,eax
		inc		eax
	.else
		xor		eax,eax
	.endif
	ret

ApplyCboTheme endp

KeyWordsProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	rect:RECT
	LOCAL	hBr:DWORD
	LOCAL	cc:CHOOSECOLOR
	LOCAL	nSt:DWORD
	LOCAL	nEn:DWORD
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	esi
		push	edi
		mov		esi,offset szColors
	  @@:
		mov		edi,dword ptr [esi]
		add		esi,4
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_ADDSTRING,0,esi
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETITEMDATA,eax,[edi]
		invoke strlen,esi
		add		esi,eax
		inc		esi
		mov		edi,dword ptr [esi]
		or		edi,edi
		jne		@b
		invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETCURSEL,0,0
		mov		esi,offset szKeyWords
	  @@:
		mov		edi,dword ptr [esi]
		add		esi,4
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_ADDSTRING,0,esi
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,eax,[edi]
		invoke strlen,esi
		add		esi,eax
		inc		esi
		mov		edi,dword ptr [esi]
		or		edi,edi
		jne		@b
		mov		nKWInx,-4
		invoke SetKeyWordList,hWin,IDC_LSTKWHOLD,16
		invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETCURSEL,0,0
		mov		nKWInx,-4
		invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTKWCOLORS,0
		invoke SendDlgItemMessage,hWin,IDC_EDTKW,EM_LIMITTEXT,63,0
        mov		eax,BST_CHECKED
        .if !fUseHighLight
        	mov		eax,BST_UNCHECKED
        .endif
		invoke CheckDlgButton,hWin,IDC_CHKHILIGTH,eax
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
		mov		eax,BST_CHECKED
		.if !HiliteLine
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKHILITELINE,eax
		mov		eax,BST_CHECKED
		.if !HiliteCmnt
			mov		eax,BST_UNCHECKED
		.endif
		invoke CheckDlgButton,hWin,IDC_CHKHILITECMNT,eax
		invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_LIMITTEXT,63,0
		invoke LoadCboTheme,hWin
		mov		eax,IDC_BTNKWAPPLY
		xor		edx,edx
		call	EnButton
		mov		esi,offset backcol
		mov		edi,offset backtemp
		mov		ecx,20
		rep movsd
		pop		edi
		pop		esi
		invoke SetLanguage,hWin,IDD_DLGKEYWORDS,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				call	Update
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNKWAPPLY
				call	Update
				mov		eax,IDC_BTNKWAPPLY
				xor		edx,edx
				call	EnButton
			.elseif eax==IDC_BTNHOLD
				invoke MoveKWs,hWin,IDC_LSTKWACTIVE,IDC_LSTKWHOLD
				mov		eax,IDC_BTNHOLD
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWDEL
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNACTIVE
				invoke MoveKWs,hWin,IDC_LSTKWHOLD,IDC_LSTKWACTIVE
				mov		eax,IDC_BTNACTIVE
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNKWADD
				invoke GetDlgItemText,hWin,IDC_EDTKW,addr buffer,64
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_ADDSTRING,0,addr buffer
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_SETCURSEL,eax,0
				mov		buffer,0
				invoke SetDlgItemText,hWin,IDC_EDTKW,addr buffer
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNKWDEL
				invoke DeleteKWs,hWin,IDC_LSTKWACTIVE
				mov		eax,IDC_BTNHOLD
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWDEL
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKBOLD
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				pop		edx
				xor		eax,01000000h
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,edx,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKITALIC
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				pop		edx
				xor		eax,02000000h
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,edx,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKRCFILE
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETITEMDATA,eax,0
				pop		edx
				xor		eax,10000000h
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_SETITEMDATA,edx,eax
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_CHKFLICKER || eax==IDC_CHKDIVLINE || eax==IDC_CHKHILIGTH || eax==IDC_CHKHILITECMNT || eax==IDC_CHKHILITELINE
				mov		eax,IDC_BTNKWAPPLY
				mov		edx,TRUE
				call	EnButton
			.elseif eax==IDC_BTNADDTHEME
				invoke AddCboTheme,hWin
				call	EnTheme
			.elseif eax==IDC_BTNLOADTHEME
				invoke ApplyCboTheme,hWin
				.if eax
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.elseif eax==IDC_BTNDELTHEME
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETCURSEL,0,0
				.if eax!=CB_ERR
					invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_DELETESTRING,eax,0
					invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETCURSEL,0,0
					mov		nTHInx,0
					invoke SaveCboTheme,hWin
					call	EnTheme
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTKW
				invoke SendDlgItemMessage,hWin,IDC_EDTKW,WM_GETTEXTLENGTH,0,0
				.if eax
					mov		eax,TRUE
				.endif
				mov		edx,eax
				mov		eax,IDC_BTNKWADD
				call	EnButton
			.endif
		.elseif edx==CBN_EDITCHANGE
			.if eax==IDC_CBOTHEME
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETEDITSEL,addr nSt,addr nEn
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,WM_GETTEXT,64,addr buffer
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETITEMDATA,nTHInx,0
				.if eax!=CB_ERR
					push	eax
					invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_DELETESTRING,nTHInx,0
					invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_ADDSTRING,0,addr buffer
					mov		nTHInx,eax
					pop		eax
					invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETITEMDATA,nTHInx,eax
					invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETCURSEL,nTHInx,0
					mov		eax,nEn
					shl		eax,16
					add		eax,nSt
					invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_SETEDITSEL,0,eax
				.else
					invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,WM_SETTEXT,0,addr szNULL
				.endif
			.endif
		.elseif edx==CBN_KILLFOCUS
			.if eax==IDC_CBOTHEME
				invoke SaveCboTheme,hWin
			.endif
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTKWCOLORS
				invoke SaveKWList,hWin,IDC_LSTKWACTIVE,nKWInx
				invoke SendDlgItemMessage,hWin,IDC_LSTKWCOLORS,LB_GETCURSEL,0,0
				sub		eax,4
				invoke SetKeyWordList,hWin,IDC_LSTKWACTIVE,eax
				mov		eax,IDC_BTNHOLD
				xor		edx,edx
				call	EnButton
				mov		eax,IDC_BTNKWDEL
				xor		edx,edx
				call	EnButton
			.elseif eax==IDC_LSTKWACTIVE
				invoke SendDlgItemMessage,hWin,IDC_LSTKWACTIVE,LB_GETSELCOUNT,0,0
				.if eax
					mov		eax,TRUE
				.endif
				push	eax
				mov		edx,eax
				mov		eax,IDC_BTNHOLD
				call	EnButton
				pop		edx
				mov		eax,IDC_BTNKWDEL
				call	EnButton
			.elseif eax==IDC_LSTKWHOLD
				invoke SendDlgItemMessage,hWin,IDC_LSTKWHOLD,LB_GETSELCOUNT,0,0
				.if eax
					mov		eax,TRUE
				.endif
				mov		edx,eax
				mov		eax,IDC_BTNACTIVE
				call	EnButton
			.elseif eax==IDC_CBOTHEME
				invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETCURSEL,0,0
				.if eax!=CB_ERR
					mov		nTHInx,eax
				.endif
			.endif
		.elseif edx==LBN_DBLCLK
			.if eax==IDC_LSTKWCOLORS
				invoke GetCursorPos,addr pt
				invoke ScreenToClient,lParam,addr pt
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
				invoke SendMessage,lParam,LB_GETCURSEL,0,0
				.if pt.x>30 && pt.x<60 && eax<4
					;Back color
					mov		eax,backtemp[eax*4]
				.else
					;Text color
					invoke SendMessage,lParam,LB_GETITEMDATA,eax,0
				.endif
				push	eax
				;Mask off group/font
				and		eax,0FFFFFFh
				mov		cc.rgbResult,eax
				invoke ChooseColor,addr cc
				pop		ecx
				.if eax
					push	ecx
					invoke SendMessage,lParam,LB_GETCURSEL,0,0
					pop		ecx
					.if pt.x>30 && pt.x<60 && eax<4
						;Back color
						mov		edx,cc.rgbResult
						mov		backtemp[eax*4],edx
					.else
						;Text color
						mov		edx,cc.rgbResult
						;Group/Font
						and		ecx,0FF000000h
						or		edx,ecx
						invoke SendMessage,lParam,LB_SETITEMDATA,eax,edx
					.endif
					invoke InvalidateRect,lParam,NULL,FALSE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.elseif eax==IDC_LSTKWACTIVE || eax==IDC_LSTKWHOLD
				invoke SendMessage,lParam,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		edx,eax
					invoke SendMessage,lParam,LB_GETTEXT,edx,addr buffer
					invoke SetDlgItemText,hWin,IDC_EDTKW,addr buffer
				.endif
			.elseif eax==IDC_LSTCOLORS
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
				invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETITEMDATA,eax,0
				push	eax
				;Mask off font
				and		eax,0FFFFFFh
				mov		cc.rgbResult,eax
				invoke ChooseColor,addr cc
				pop		ecx
				.if eax
					push	ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_GETCURSEL,0,0
					pop		ecx
					mov		edx,cc.rgbResult
					;Font
					and		ecx,0FF000000h
					or		edx,ecx
					invoke SendDlgItemMessage,hWin,IDC_LSTCOLORS,LB_SETITEMDATA,eax,edx
					invoke GetDlgItem,hWin,IDC_LSTCOLORS
					invoke InvalidateRect,eax,NULL,FALSE
					mov		eax,IDC_BTNKWAPPLY
					mov		edx,TRUE
					call	EnButton
				.endif
			.endif
		.endif
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
		.if [esi].CtlID==IDC_LSTKWCOLORS && [esi].itemID<4
			push	eax
			push	edx
			mov		eax,[esi].itemID
			mov		eax,backtemp[eax*4]
			invoke CreateSolidBrush,eax
			mov		hBr,eax
			add		rect.left,30
			add		rect.right,30
			invoke FillRect,[esi].hdc,addr rect,hBr
			invoke DeleteObject,hBr
			invoke GetStockObject,BLACK_BRUSH
			invoke FrameRect,[esi].hdc,addr rect,eax
			pop		edx
			pop		eax
			add		edx,30
		.endif
		invoke TextOut,[esi].hdc,edx,[esi].rcItem.top,addr buffer,eax
		assume esi:nothing
		pop		esi
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

EnButton:
	push	edx
	invoke GetDlgItem,hWin,eax
	pop		edx
	invoke EnableWindow,eax,edx
EnTheme:
	invoke SendDlgItemMessage,hWin,IDC_CBOTHEME,CB_GETCOUNT,0,0
	push	eax
	push	eax
	invoke GetDlgItem,hWin,IDC_BTNDELTHEME
	pop		edx
	invoke EnableWindow,eax,edx
	invoke GetDlgItem,hWin,IDC_BTNLOADTHEME
	pop		edx
	invoke EnableWindow,eax,edx
	retn

Update:
	invoke SaveKWList,hWin,IDC_LSTKWACTIVE,nKWInx
	invoke SaveKWList,hWin,IDC_LSTKWHOLD,16
	invoke IsDlgButtonChecked,hWin,IDC_CHKHILIGTH
	mov		fUseHighLight,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKDIVLINE
	mov		fUseDivLine,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKFLICKER
	mov		fNoFlicker,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKHILITELINE
	mov		HiliteLine,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKHILITECMNT
	mov		HiliteCmnt,eax
	push	esi
	push	edi
	mov		esi,offset szColors
	mov		edi,IDC_LSTCOLORS
	call	SetColors
	mov		esi,offset szKeyWords
	mov		edi,IDC_LSTKWCOLORS
	call	SetColors
	mov		esi,offset backtemp
	mov		edi,offset backcol
	mov		ecx,20
	rep	movsd
	mov		eax,backcol[0*4]
	mov		racol.cmntback,eax
	mov		eax,backcol[1*4]
	mov		racol.strback,eax
	mov		eax,backcol[2*4]
	mov		racol.numback,eax
	mov		eax,backcol[3*4]
	mov		racol.oprback,eax
	pop		edi
	pop		esi
	invoke FillHiliteInfo
	invoke UpdateEditColors
	invoke iniColSave
	invoke iniEditSave
	retn

SetColors:
	mov		nInx,0
  @@:
	invoke SendDlgItemMessage,hWin,edi,LB_GETITEMDATA,nInx,0
	mov		edx,[esi]
	mov		[edx],eax
	inc		nInx
	add		esi,4
	invoke strlen,esi
	add		esi,eax
	inc		esi
	mov		eax,[esi]
	or		eax,eax
	jne		@b
	retn

KeyWordsProc endp

