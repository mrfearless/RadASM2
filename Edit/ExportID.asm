
IDD_DLGEXPORTID		equ 3000
IDC_LSTFILES		equ 3001
IDC_BTNSELECT		equ 3002
IDC_BTNDESELECT		equ 3003
IDC_BTNSELECTALL	equ 3004
IDC_BTNSELECTNONE	equ 3005
IDC_BTNINVERTSEL	equ 3006

.code

ExportID proc uses esi edi,lpID:DWORD
	LOCAL	buffer[128]:BYTE

	mov		esi,lpID
	lea		edi,buffer
	.if nAsm==nCPP || nAsm==nBCET
		invoke strcpy,edi,offset szDEFINE
		add		edi,7
		mov		word ptr [edi],' '
		inc		edi
	.endif
	dec		esi
	mov		ecx,31
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,09h
	je		@b
	cmp		al,' '
	je		@b
	cmp		al,0Dh
	je		Ex
	cmp		al,00h
	je		Ex
  @@:
	mov		al,[esi]
	cmp		al,09h
	je		@f
	cmp		al,' '
	je		@f
	cmp		al,0Dh
	je		Ex
	cmp		al,00h
	je		Ex
	mov		[edi],al
	inc		esi
	inc		edi
	dec		ecx
	jmp		@b
  @@:
	.if ecx>100
		mov		ecx,0
	.endif
	mov		eax,ecx
	xor		edx,edx
	idiv	TabSize
	inc		eax
	mov		ecx,eax
	mov		al,09h
	rep stosb
	.if nAsm==nHLA
		mov		eax,' =:'
		stosd
		dec		edi
	.elseif nAsm==nCPP
	.elseif nAsm==nBCET
	.elseif nAsm==nFP
		mov		eax,' ='
		stosw
	.else
		mov		eax,' uqe'
		stosd
	.endif
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,09h
	je		@b
	cmp		al,' '
	je		@b
	cmp		al,0Dh
	je		Ex
	cmp		al,00h
	je		Ex
  @@:
	mov		al,[esi]
	cmp		al,'-'
	je		Mi
	cmp		al,'0'
	jl		@f
	cmp		al,'9'
	jg		@f
  Mi:
	mov		[edi],al
	inc		esi
	inc		edi
	jmp		@b
  @@:
	.if nAsm==nHLA || nAsm==nFP
		mov		al,';'
		stosb
	.endif
	mov		byte ptr [edi],0
	invoke TextToOutput,addr buffer
  Ex:
	ret

ExportID endp

GetMnuID proc uses esi edi,lpFileName:DWORD
	LOCAL	hFile:DWORD
	LOCAL	hMem:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	buffer[256]:BYTE

	invoke strcpy,addr FileName,addr ProjectPath
	invoke strcat,addr FileName,lpFileName
	invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,100*1024
		mov     hMem,eax
		invoke GlobalLock,hMem
		invoke ReadFile,hFile,hMem,100*1024,addr nBytes,NULL
		invoke CloseHandle,hFile
		mov		esi,hMem
		.if [esi].MNUHEAD.menuname && [esi].MNUHEAD.menuid
			invoke strcpy,addr buffer,addr (MNUHEAD ptr [esi]).menuname
			invoke strlen,addr buffer
			lea		edi,buffer[eax]
			mov		al,' '
			stosb
			movzx	eax,(MNUHEAD ptr [esi]).menuid
			invoke BinToDec,eax,edi
			invoke ExportID,addr buffer
		.endif
		add		esi,sizeof MNUHEAD
		mov		eax,(MNUITEM ptr [esi]).itemflag
		.while eax
			lea		edi,buffer
			mov		al,(MNUITEM ptr [esi]).itemname
			.if al
				mov		eax,(MNUITEM ptr [esi]).itemid
				.if eax
					invoke strcpy,addr buffer,addr (MNUITEM ptr [esi]).itemname
					invoke strlen,addr buffer
					lea		edi,buffer[eax]
					mov		al,' '
					stosb
					invoke BinToDec,(MNUITEM ptr [esi]).itemid,edi
					invoke ExportID,addr buffer
				.endif
			.endif
			add		esi,sizeof MNUITEM
			mov		eax,(MNUITEM ptr [esi]).itemflag
		.endw
		invoke GlobalUnlock,hMem
		invoke GlobalFree,hMem
	.else
		invoke strcpy,addr LineTxt,addr OpenFileFail
		invoke strcat,addr LineTxt,addr FileName
		invoke MessageBox,hWnd,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
	.endif
	ret

GetMnuID endp

GetDlgID proc uses esi edi,lpFileName:DWORD
	LOCAL	hFile:DWORD
	LOCAL	hMem:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	buffer[256]:BYTE

	invoke strcpy,addr FileName,addr ProjectPath
	invoke strcat,addr FileName,lpFileName
	invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		mov		nBytes,eax
		shr		eax,13
		inc		eax
		shl		eax,13
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov     hMem,eax
		invoke GlobalLock,hMem
		invoke ReadFile,hFile,hMem,nBytes,addr nBytes,NULL
		invoke CloseHandle,hFile
		mov		esi,hMem
		mov		eax,[esi].DLGHEAD.ver
		.if eax==100
			add		esi,sizeof DLGHEAD
			mov		eax,(DIALOG100 ptr [esi]).hwnd
			.while eax
				lea		edi,buffer
				mov		al,(DIALOG100 ptr [esi]).idname
				.if al
					mov		eax,(DIALOG100 ptr [esi]).id
					.if eax
						invoke strcpy,addr buffer,addr (DIALOG100 ptr [esi]).idname
						invoke strlen,addr buffer
						lea		edi,buffer
						add		edi,eax
						mov		al,' '
						stosb
						invoke BinToDec,(DIALOG100 ptr [esi]).id,edi
						invoke ExportID,addr buffer
					.endif
				.endif
				add		esi,sizeof DIALOG100
				mov		eax,(DIALOG100 ptr [esi]).hwnd
			.endw
		.elseif eax==101
			add		esi,sizeof DLGHEAD
			mov		eax,(DIALOG101 ptr [esi]).hwnd
			.while eax
				lea		edi,buffer
				mov		al,(DIALOG101 ptr [esi]).idname
				.if al
					mov		eax,(DIALOG101 ptr [esi]).id
					.if eax
						invoke strcpy,addr buffer,addr (DIALOG101 ptr [esi]).idname
						invoke strlen,addr buffer
						lea		edi,buffer
						add		edi,eax
						mov		al,' '
						stosb
						invoke BinToDec,(DIALOG101 ptr [esi]).id,edi
						invoke ExportID,addr buffer
					.endif
				.endif
				add		esi,sizeof DIALOG101
				mov		eax,(DIALOG101 ptr [esi]).hwnd
			.endw
		.elseif eax==102
			add		esi,sizeof DLGHEAD
			mov		eax,(DIALOG ptr [esi]).hwnd
			.while eax
				lea		edi,buffer
				mov		al,(DIALOG ptr [esi]).idname
				.if al
					mov		eax,(DIALOG ptr [esi]).id
					.if eax
						invoke strcpy,addr buffer,addr (DIALOG ptr [esi]).idname
						invoke strlen,addr buffer
						lea		edi,buffer
						add		edi,eax
						mov		al,' '
						stosb
						invoke BinToDec,(DIALOG ptr [esi]).id,edi
						invoke ExportID,addr buffer
					.endif
				.endif
				add		esi,sizeof DIALOG
				mov		eax,(DIALOG ptr [esi]).hwnd
			.endw
		.endif
		invoke GlobalUnlock,hMem
		invoke GlobalFree,hMem
	.else
		invoke strcpy,addr LineTxt,addr OpenFileFail
		invoke strcat,addr LineTxt,addr FileName
		invoke MessageBox,hWnd,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
	.endif
	ret

GetDlgID endp

IsLineCmnt proc uses esi,lpMSt:DWORD,lpMem:DWORD

	mov		esi,lpMem
	mov		al,[esi]
	.while esi!=lpMSt
		dec		esi
		mov		al,[esi]
		.if al==';' || al==0Dh
			.break
		.endif
	.endw
	.if al==';'
		mov		eax,TRUE
	.else
		mov		eax,FALSE
	.endif
	ret

IsLineCmnt endp

GetRCID proc lpFileName:DWORD
	LOCAL	lpMSt:DWORD

	invoke strcpy,addr FileName,addr ProjectPath
	invoke strcat,addr FileName,lpFileName
	mov		hFound,0
	invoke EnumChildWindows,hClient,addr CheckLoadedEnumProc,addr FileName
	mov		eax,hFound
	.if eax
		invoke LoadEdit,hFound
	.else
		invoke LoadFile,addr FileName
	.endif
	mov		eax,hSrcMem
	mov		lpMSt,eax
  Nx:
	invoke SearchMem,lpMSt,addr szDEFINE,FALSE,TRUE,FALSE
	.if eax
		push	eax
		invoke	IsLineCmnt,lpMSt,eax
		.if eax
			pop		eax
			add		eax,sizeof szDEFINE
			mov		lpMSt,eax
			jmp		Nx
		.endif
		pop		eax
		add		eax,sizeof szDEFINE
		mov		lpMSt,eax
		invoke ExportID,eax
		jmp		Nx
	.endif
	invoke GlobalUnlock,hSrcMem
	invoke GlobalFree,hSrcMem
	mov		hSrcMem,0
	ret

GetRCID endp

ExportIDProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer1[256]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	iNbr:DWORD
	LOCAL	iMiss:DWORD
	LOCAL	nInx:DWORD

	mov		eax,uMsg
    .if eax==WM_INITDIALOG
		invoke GetFileAttributes,addr ProjectFile
		.if eax!=-1
			mov		iNbr,1
			mov		iMiss,0
		  @@:
			invoke GetFileNameFromID,iNbr
			.if eax
				mov		iMiss,0
				invoke strcpy,addr buffer2,eax
				invoke GetFileImg,addr buffer2
				.if eax==4 || eax==5 || eax==6
					invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_ADDSTRING,0,addr buffer2
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETITEMDATA,nInx,iNbr
				.endif
			.else
				inc		iMiss
			.endif
			inc		iNbr
			cmp		iMiss,PRO_MAX_MISS
			jne		@b
			mov		esi,offset szAclRc
			call	GetResFile
			mov		esi,offset szResRc
			call	GetResFile
			mov		esi,offset szStrRc
			call	GetResFile
			mov		esi,offset szVerRc
			call	GetResFile
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETSEL,TRUE,-1
		.endif
		invoke SetLanguage,hWin,IDD_DLGEXPORTID,FALSE
    .elseif eax==WM_CLOSE
        invoke EndDialog,hWin,NULL
    .elseif eax==WM_COMMAND
        mov		edx,wParam
        movzx	eax,dx
        shr		edx,16
        .if edx==BN_CLICKED
            .if eax==IDCANCEL
                invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDOK
				invoke UpdateAll,IDM_FILE_SAVEALLFILES
				invoke OutputSelect,2
				invoke ShowOutput
				invoke OutputClear
				mov		nInx,0
			  @@:
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETSEL,nInx,0
				.if eax!=LB_ERR
					.if eax
						invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETITEMDATA,nInx,0
						.if eax
							mov		iNbr,eax
							invoke GetFileNameFromID,iNbr
							invoke strcpy,addr buffer2,eax
						.else
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,nInx,addr buffer2
						.endif
						.if nAsm==nHLA || nAsm==nCPP || nAsm==nFP
							mov		eax,2F2F0Dh
						.elseif nAsm==nBCET
							mov		eax,270Dh
						.else
							mov		eax,3B0Dh
						.endif
						mov		dword ptr buffer1,eax
						invoke strcat,addr buffer1,addr buffer2
						invoke TextToOutput,addr buffer1
						invoke GetFileImg,addr buffer2
						.if eax==4
							;.RC
							invoke GetRCID,addr buffer2
						.elseif eax==5
							;.Dlg
							invoke GetDlgID,addr buffer2
						.elseif eax==6
							;.Mnu
							invoke GetMnuID,addr buffer2
						.endif
					.endif
					inc		nInx
					jmp		@b
				.endif
                invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNSELECT
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETCARETINDEX,0,0
				.if eax!=LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETSEL,TRUE,eax
				.endif
			.elseif eax==IDC_BTNDESELECT
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETCARETINDEX,0,0
				.if eax!=LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETSEL,FALSE,eax
				.endif
			.elseif eax==IDC_BTNSELECTALL
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETSEL,TRUE,-1
			.elseif eax==IDC_BTNSELECTNONE
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETSEL,FALSE,-1
			.elseif eax==IDC_BTNINVERTSEL
				mov		nInx,0
			  @@:
				invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETSEL,nInx,0
				.if eax!=LB_ERR
					.if eax
						mov		eax,FALSE
					.else
						mov		eax,TRUE
					.endif
					invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETSEL,eax,nInx
					inc		nInx
					jmp		@b
				.endif
			.endif
        .endif
    .else
        mov		eax,FALSE
        ret
    .endif
    mov		eax,TRUE
    ret

GetResFile:
	mov		word ptr buffer1,'0'
	invoke GetPrivateProfileString,addr iniMakeFile,addr buffer1,addr szNULL,addr buffer1,sizeof buffer1,addr ProjectFile
	invoke strlen,addr buffer1
	sub		eax,4
	mov		byte ptr buffer1[eax],0
	invoke strcpy,addr buffer2,addr szRes
	invoke strcat,addr buffer2,addr buffer1
	invoke strcat,addr buffer2,esi
	invoke GetFileAttributes,addr buffer2
	.if eax!=-1
		invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_ADDSTRING,0,addr buffer2
		mov		nInx,eax
		invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETITEMDATA,nInx,0
	.endif
	retn

ExportIDProc endp
