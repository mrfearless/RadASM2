
.const

;Ver\VerInfo.dlg
IDD_DLGVERINFO		equ 2900
IDC_EDTVERNAME		equ 2901
IDC_EDTVERID		equ 2902
IDC_EDTVERFILE		equ 2903
IDC_EDTVERPROD		equ 2904
IDC_CBOVEROS		equ 2905
IDC_CBOVERTYPE		equ 2906
IDC_CBOVERLANG		equ 2907
IDC_CBOVERCHAR		equ 2908
IDC_LSTVER			equ 2909
IDC_EDTVER			equ 2910
IDC_BTNVEREXPORT	equ 2911

.data

iniVerInf			db 'VerInf',0
iniVerFV			db 'FV',0
iniVerPV			db 'PV',0
iniVerOS			db 'VerOS',0
iniVerFT			db 'VerFT',0
iniVerLNG			db 'VerLNG',0
iniVerCHS			db 'VerCHS',0
szStringFileInfo	db 'StringFileInfo',0
szVarFileInfo		db 'VarFileInfo',0
szTranslation		db 'Translation',0

szVerRc				db 'Ver.rc',0

.data?

VerInfTxt			db 256*16 dup(?)

.code

VerinfoGetVal proc lpData:DWORD
	
	mov		edx,lpData
	mov		ax,[edx]
	.if ax=='x0' || ax=='X0'
		add		edx,2
		xor		eax,eax
		xor		ecx,ecx
		mov		cl,[edx]
	  @@:
		.if cl>='0' && cl<='9'
			shl		eax,4
			sub		cl,'0'
			or		al,cl
		.elseif cl>='A' && cl<='F'
			shl		eax,4
			sub		cl,'A'-10
			or		al,cl
		.elseif cl>='a' && cl<='f'
			shl		eax,4
			sub		cl,'a'-10
			or		al,cl
		.endif
		inc		edx
		mov		cl,[edx]
		or		cl,cl
		jne		@b
	.else
		invoke DecToBin,edx
	.endif	
	ret

VerinfoGetVal endp

VerinfoSaveCbo proc hWin:HWND,nID:DWORD,lpKey:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	val:DWORD

	invoke SendDlgItemMessage,hWin,nID,CB_GETCURSEL,0,0
	invoke SendDlgItemMessage,hWin,nID,CB_GETITEMDATA,eax,0
	mov		val,eax
	push	edi
	lea		edi,buffer
	mov		al,'0'
	stosb
	mov		al,'x'
	stosb
	mov		eax,val
	invoke hexEax
	invoke strcpy,edi,addr strHex
	invoke WritePrivateProfileString,addr iniVerInf,lpKey,addr buffer,addr ProjectFile
	pop		edi
	ret

VerinfoSaveCbo endp

VerinfoSave proc hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	val:DWORD

	invoke SendDlgItemMessage,hWin,IDC_EDTVERNAME,WM_GETTEXT,32,addr buffer
	invoke WritePrivateProfileString,addr iniVerInf,addr iniVerNme,addr buffer,addr ProjectFile
	invoke SendDlgItemMessage,hWin,IDC_EDTVERID,WM_GETTEXT,5,addr buffer
	invoke WritePrivateProfileString,addr iniVerInf,addr iniVerID,addr buffer,addr ProjectFile
	invoke SendDlgItemMessage,hWin,IDC_EDTVERFILE,WM_GETTEXT,11,addr buffer
	invoke WritePrivateProfileString,addr iniVerInf,addr iniVerFV,addr buffer,addr ProjectFile
	invoke SendDlgItemMessage,hWin,IDC_EDTVERPROD,WM_GETTEXT,11,addr buffer
	invoke WritePrivateProfileString,addr iniVerInf,addr iniVerPV,addr buffer,addr ProjectFile
	invoke VerinfoSaveCbo,hWin,IDC_CBOVEROS,addr iniVerOS
	invoke VerinfoSaveCbo,hWin,IDC_CBOVERTYPE,addr iniVerFT
	invoke VerinfoSaveCbo,hWin,IDC_CBOVERLANG,addr iniVerLNG
	invoke VerinfoSaveCbo,hWin,IDC_CBOVERCHAR,addr iniVerCHS
	invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETCOUNT,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		.while nInx
			dec		nInx
			invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETTEXT,nInx,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETITEMDATA,nInx,0
			mov		val,eax
			invoke WritePrivateProfileString,addr iniVerInf,addr buffer,val,addr ProjectFile
		.endw
	.endif
	ret

VerinfoSave endp

VerinfoSetCbo proc hWin:HWND,nID:DWORD,lpKey:DWORD
	LOCAL	nInx:DWORD
	LOCAL	nSel:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	val:DWORD
	LOCAL	valSel:DWORD

	mov		nInx,1
	.while TRUE
		invoke BinToDec,nInx,addr buffer
	    invoke GetPrivateProfileString,lpKey,addr buffer,addr szNULL,addr iniBuffer,128,addr iniFile
		.if !eax
			.break
		.endif
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke SendDlgItemMessage,hWin,nID,CB_ADDSTRING,0,addr buffer
		mov		val,eax
		invoke VerinfoGetVal,addr iniBuffer
		invoke SendDlgItemMessage,hWin,nID,CB_SETITEMDATA,val,eax
		inc		nInx
	.endw
    invoke GetPrivateProfileString,addr iniVerInf,lpKey,addr szNULL,addr buffer,128,addr ProjectFile
	.if !eax
	    invoke GetPrivateProfileString,addr iniVerInf,lpKey,addr szNULL,addr buffer,128,addr iniFile
	.endif
	invoke VerinfoGetVal,addr buffer
	mov		valSel,eax
	mov		nSel,0
	.while nInx
		dec		nInx
		invoke SendDlgItemMessage,hWin,nID,CB_GETITEMDATA,nInx,0
		.if eax==valSel
			mov		eax,nInx
			mov		nSel,eax
		.endif
	.endw
	invoke SendDlgItemMessage,hWin,nID,CB_SETCURSEL,nSel,0
	ret

VerinfoSetCbo endp

VerinfoExport proc uses edi,fOut:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	hWrMem:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*16
	mov     hWrMem,eax
	invoke GlobalLock,hWrMem
	mov		edi,hWrMem

	invoke SaveStr,edi,addr szDEFINE
	add		edi,eax
	mov		al,' '
	stosb
	;Name
    invoke GetPrivateProfileString,addr iniVerInf,addr iniVerNme,addr szNULL,addr buffer1,128,addr ProjectFile
    .if !eax
    	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerNme,addr szNULL,addr buffer1,128,addr iniFile
	.endif
	invoke SaveStr,edi,addr buffer1
	add		edi,eax
	mov		al,' '
	stosb
	;ID
	invoke GetPrivateProfileInt,addr iniVerInf,addr iniVerID,1,addr ProjectFile
    .if !eax
		invoke GetPrivateProfileInt,addr iniVerInf,addr iniVerID,1,addr iniFile
	.endif
	invoke BinToDec,eax,edi
	invoke strlen,edi
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	;Name
    invoke GetPrivateProfileString,addr iniVerInf,addr iniVerNme,addr szNULL,edi,128,addr ProjectFile
    .if !eax
    	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerNme,addr szNULL,edi,128,addr iniFile
	.endif
	invoke strlen,edi
	add		edi,eax
	mov		al,' '
	stosb
	invoke SaveStr,edi,addr szVERSIONINFO
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	invoke SaveStr,edi,addr szFILEVERSION
	add		edi,eax
	mov		al,' '
	stosb
	;File version
    invoke GetPrivateProfileString,addr iniVerInf,addr iniVerFV,addr szNULL,addr buffer1,128,addr ProjectFile
    .if !eax
	    invoke GetPrivateProfileString,addr iniVerInf,addr iniVerFV,addr szNULL,addr buffer1,128,addr iniFile
	.endif
	lea		edx,buffer1
	.while TRUE
		mov		al,[edx]
		.if !al
			mov		al,0Dh
			stosb
			mov		al,0Ah
			stosb
			.break
		.endif
		.if al=='.'
			mov		al,','
		.endif
		stosb
		inc		edx
	.endw
	;Product version
	invoke SaveStr,edi,addr szPRODUCTVERSION
	add		edi,eax
	mov		al,' '
	stosb
	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerPV,addr szNULL,addr buffer1,128,addr ProjectFile
    .if !eax
		invoke GetPrivateProfileString,addr iniVerInf,addr iniVerPV,addr szNULL,addr buffer1,128,addr iniFile
	.endif
	lea		edx,buffer1
	.while TRUE
		mov		al,[edx]
		.if !al
			mov		al,0Dh
			stosb
			mov		al,0Ah
			stosb
			.break
		.endif
		.if al=='.'
			mov		al,','
		.endif
		stosb
		inc		edx
	.endw
	;File OS
	invoke SaveStr,edi,addr szFILEOS
	add		edi,eax
	mov		al,' '
	stosb
	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerOS,addr szNULL,addr buffer1,128,addr ProjectFile
	.if !eax
		invoke GetPrivateProfileString,addr iniVerInf,addr iniVerOS,addr szNULL,addr buffer1,128,addr iniFile
	.endif
	.if eax
		invoke SaveStr,edi,addr buffer1
		add		edi,eax
	.endif
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	;File type
	invoke SaveStr,edi,addr szFILETYPE
	add		edi,eax
	mov		al,' '
	stosb
	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerFT,addr szNULL,addr buffer1,128,addr ProjectFile
	.if !eax
		invoke GetPrivateProfileString,addr iniVerInf,addr iniVerFT,addr szNULL,addr buffer1,128,addr iniFile
	.endif
	.if eax
		invoke SaveStr,edi,addr buffer1
		add		edi,eax
	.endif
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szBLOCK
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	invoke SaveStr,edi,addr szStringFileInfo
	add		edi,eax
	mov		al,22h
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,' '
	stosb
	stosb
	stosb
	stosb
	invoke SaveStr,edi,addr szBLOCK
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerLNG,addr szNULL,addr buffer1,128,addr ProjectFile
	.if !eax
		invoke GetPrivateProfileString,addr iniVerInf,addr iniVerLNG,addr szNULL,addr buffer1,128,addr iniFile
	.endif
	.if eax
		invoke SaveStr,edi,addr buffer1[6]
		add		edi,eax
	.endif
	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerCHS,addr szNULL,addr buffer1,128,addr ProjectFile
	.if !eax
		invoke GetPrivateProfileString,addr iniVerInf,addr iniVerCHS,addr szNULL,addr buffer1,128,addr iniFile
	.endif
	.if eax
		invoke SaveStr,edi,addr buffer1[6]
		add		edi,eax
	.endif
	mov		al,22h
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	mov		al,' '
	stosb
	stosb
	stosb
	stosb
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	mov		nInx,1
	.while nInx<=32
		invoke BinToDec,nInx,addr buffer
	    invoke GetPrivateProfileString,addr iniVerInf,addr buffer,addr szNULL,addr iniBuffer,128,addr iniFile
		.if !eax
			.break
		.endif
		invoke iniGetItem,addr iniBuffer,addr buffer
	    invoke GetPrivateProfileString,addr iniVerInf,addr buffer,addr szNULL,addr buffer1,128,addr ProjectFile
		.if eax
			mov		al,' '
			stosb
			stosb
			stosb
			stosb
			stosb
			stosb
			invoke SaveStr,edi,addr szVALUE
			add		edi,eax
			mov		al,' '
			stosb
			mov		al,22h
			stosb
			invoke SaveStr,edi,addr buffer
			add		edi,eax
			mov		al,22h
			stosb
			mov		al,','
			stosb
			mov		al,' '
			stosb
			mov		al,22h
			stosb
			invoke SaveStr,edi,addr buffer1
			add		edi,eax
			mov		al,'\'
			stosb
			mov		al,'0'
			stosb
			mov		al,22h
			stosb
			mov		al,0Dh
			stosb
			mov		al,0Ah
			stosb
		.endif
		inc		nInx
	.endw
	mov		al,' '
	stosb
	stosb
	stosb
	stosb
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szBLOCK
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	invoke SaveStr,edi,addr szVarFileInfo
	add		edi,eax
	mov		al,22h
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	mov		al,' '
	stosb
	stosb
	stosb
	stosb
	invoke SaveStr,edi,addr szVALUE
	add		edi,eax
	mov		al,' '
	stosb
	mov		al,22h
	stosb
	invoke SaveStr,edi,addr szTranslation
	add		edi,eax
	mov		al,22h
	stosb
	mov		al,','
	stosb
	mov		al,' '
	stosb
	mov		al,'0'
	stosb
	mov		al,'x'
	stosb
	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerLNG,addr szNULL,addr buffer1,128,addr ProjectFile
	.if !eax
		invoke GetPrivateProfileString,addr iniVerInf,addr iniVerLNG,addr szNULL,addr buffer1,128,addr iniFile
	.endif
	.if eax
		invoke SaveStr,edi,addr buffer1[6]
		add		edi,eax
	.endif
	mov		al,','
	stosb
	mov		al,' '
	stosb
	mov		al,'0'
	stosb
	mov		al,'x'
	stosb
	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerCHS,addr szNULL,addr buffer1,128,addr ProjectFile
	.if !eax
		invoke GetPrivateProfileString,addr iniVerInf,addr iniVerCHS,addr szNULL,addr buffer1,128,addr iniFile
	.endif
	.if eax
		invoke SaveStr,edi,addr buffer1[6]
		add		edi,eax
	.endif
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	mov		al,' '
	stosb
	stosb
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb

	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,0
	stosb

	.if fOut
		invoke OutputSelect,2
		invoke OutputClear
		invoke ShowOutput
		invoke TextToOutput,hWrMem
	.else
		invoke GetPrivateProfileString,addr iniProject,addr szVerRc,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		.if !eax
			;Delete resources from main RC
			mov		dword ptr buffer,'1'
			invoke WritePrivateProfileString,addr iniProject,addr szVerRc,addr buffer,addr ProjectFile
			mov		dword ptr buffer,0
			invoke DllProc,hWnd,AIM_RCUPDATE,2,addr buffer,RAM_RCUPDATE
		.endif
		mov		word ptr buffer,'0'
		invoke GetPrivateProfileString,addr iniMakeFile,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		invoke strlen,addr buffer
		sub		eax,4
		mov		byte ptr buffer[eax],0
		invoke strcpy,addr buffer1,addr ProjectPath
		invoke strcat,addr buffer1,addr szRes
		invoke strcat,addr buffer1,addr buffer
		invoke strcat,addr buffer1,addr szVerRc
		invoke GetFileAttributes,addr buffer1
		.if eax==-1
			invoke DllProc,hWnd,AIM_PROJECTADDNEW,-3,addr ProjectFile,RAM_PROJECTADDNEW
		.endif
		invoke CreateFile,addr buffer1,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strlen,hWrMem
			mov		nBytes,eax
			invoke WriteFile,hFile,hWrMem,nBytes,addr nBytes,NULL
			invoke CloseHandle,hFile
			inc		fResChanged
			invoke DllProc,hWnd,AIM_RCSAVED,3,addr buffer1,RAM_RCSAVED
		.endif
	.endif
	invoke GlobalUnlock,hWrMem
	invoke GlobalFree,hWrMem
	ret

VerinfoExport endp

VerinfoDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	val:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SendDlgItemMessage,hWin,IDC_EDTVERNAME,EM_LIMITTEXT,32,0
	    invoke GetPrivateProfileString,addr iniVerInf,addr iniVerNme,addr szNULL,addr iniBuffer,128,addr ProjectFile
	    .if !eax
	    	invoke GetPrivateProfileString,addr iniVerInf,addr iniVerNme,addr szNULL,addr iniBuffer,128,addr iniFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTVERNAME,addr iniBuffer
		invoke SendDlgItemMessage,hWin,IDC_EDTVERID,EM_LIMITTEXT,6,0
		invoke GetPrivateProfileInt,addr iniVerInf,addr iniVerID,1,addr ProjectFile
	    .if !eax
			invoke GetPrivateProfileInt,addr iniVerInf,addr iniVerID,1,addr iniFile
		.endif
		invoke SetDlgItemInt,hWin,IDC_EDTVERID,eax,TRUE
		invoke SendDlgItemMessage,hWin,IDC_EDTVERFILE,EM_LIMITTEXT,16,0
	    invoke GetPrivateProfileString,addr iniVerInf,addr iniVerFV,addr szNULL,addr iniBuffer,128,addr ProjectFile
	    .if !eax
		    invoke GetPrivateProfileString,addr iniVerInf,addr iniVerFV,addr szNULL,addr iniBuffer,128,addr iniFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTVERFILE,addr iniBuffer
		invoke SendDlgItemMessage,hWin,IDC_EDTVERPROD,EM_LIMITTEXT,16,0
		invoke GetPrivateProfileString,addr iniVerInf,addr iniVerPV,addr szNULL,addr iniBuffer,128,addr ProjectFile
	    .if !eax
			invoke GetPrivateProfileString,addr iniVerInf,addr iniVerPV,addr szNULL,addr iniBuffer,128,addr iniFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTVERPROD,addr iniBuffer
		invoke VerinfoSetCbo,hWin,IDC_CBOVEROS,addr iniVerOS
		invoke VerinfoSetCbo,hWin,IDC_CBOVERTYPE,addr iniVerFT
		invoke VerinfoSetCbo,hWin,IDC_CBOVERLANG,addr iniVerLNG
		invoke VerinfoSetCbo,hWin,IDC_CBOVERCHAR,addr iniVerCHS
		mov		nInx,1
		mov		val,offset VerInfTxt
		.while nInx<=32
			invoke BinToDec,nInx,addr buffer
		    invoke GetPrivateProfileString,addr iniVerInf,addr buffer,addr szNULL,addr iniBuffer,128,addr iniFile
			.if !eax
				.break
			.endif
			invoke iniGetItem,addr iniBuffer,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_ADDSTRING,0,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_SETITEMDATA,eax,val
		    invoke GetPrivateProfileString,addr iniVerInf,addr buffer,addr iniBuffer,addr buffer,128,addr ProjectFile
			invoke strcpy,val,addr buffer
			add		val,256
			inc		nInx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_EDTVER,EM_LIMITTEXT,256,0
		invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_SETCURSEL,0,0
		invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETITEMDATA,0,0
		invoke SendDlgItemMessage,hWin,IDC_EDTVER,WM_SETTEXT,0,eax
		invoke SetLanguage,hWin,IDD_DLGVERINFO,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke VerinfoSave,hWin
				invoke VerinfoExport,FALSE
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNVEREXPORT
				invoke VerinfoSave,hWin
				invoke VerinfoExport,TRUE
			.endif
		.elseif edx==EN_CHANGE
			.if eax==IDC_EDTVER
				invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETITEMDATA,eax,0
				invoke SendDlgItemMessage,hWin,IDC_EDTVER,WM_GETTEXT,256,eax
			.endif
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_LSTVER
				invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_LSTVER,LB_GETITEMDATA,eax,0
				invoke SendDlgItemMessage,hWin,IDC_EDTVER,WM_SETTEXT,0,eax
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

VerinfoDlgProc endp
