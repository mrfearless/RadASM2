
.code

ApiConstListBox	proc lpMem:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	chrg:CHARRANGE
	LOCAL	nbr:DWORD

	pushad
	mov		nbr,0
	m2m		hLB,hLBU
	invoke ShowWindow,hTlt,SW_HIDE
	mov		fTlt,0
	.if	!fLBConst
		invoke SendMessage,hEdit,EM_EXGETSEL,0,addr	findtext.chrg
		m2m		fLBConst,hEdit
	.endif
	invoke SendMessage,hEdit,EM_HIDESELECTION,TRUE,FALSE
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr	chrg
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr	findtext.chrg
	invoke SendMessage,hEdit,EM_GETSELTEXT,0,addr buffer1
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr	chrg
	invoke SendMessage,hEdit,EM_HIDESELECTION,FALSE,FALSE
	invoke SendMessage,hLB,WM_SETREDRAW,FALSE,0
	invoke SendMessage,hLB,LB_RESETCONTENT,0,0
  @@:
	invoke iniGetItem,lpMem,addr buffer
	mov		al,buffer
	.if	al
		lea		esi,buffer
		lea		edi,buffer1
		dec		esi
		dec		edi
	  Nxt:
		inc		esi
		inc		edi
		mov		al,[edi]
		.if	al
			.if	al>='a'	&& al<='z'
				and		al,5Fh
			.endif
			mov		ah,[esi]
			.if	ah>='a'	&& ah<='z'
				and		ah,5Fh
			.endif
			cmp		al,ah
			je		Nxt
			jmp		@b
		.endif
		invoke SendMessage,hLB,LB_ADDSTRING,0,addr buffer
		invoke SendMessage,hLB,LB_SETITEMDATA,eax,20000h
		jmp		@b
	.endif
	invoke ShowListBox,hEdit
	invoke SendMessage,hLB,LB_SETCURSEL,0,0
	invoke SendMessage,hLB,WM_SETREDRAW,TRUE,0
	m2m		fLB,hEdit
	popad
	ret

ApiConstListBox	endp

ApiConstSrc	proc lpSrc:DWORD
	LOCAL	hMem:HGLOBAL

	pushad
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		hMem,eax
	mov		edi,lpWordList
  Nx:
	.if	[edi].PROPERTIES.nType=='C'
		mov		esi,lpSrc
		lea		ecx,[edi+sizeof	PROPERTIES]
		dec		esi
		dec		ecx
	  @@:
		inc		esi
		inc		ecx
		mov		al,[esi]
		or		al,al
		je		@f
		cmp		al,[ecx]
		je		@b
	  @@:
		.if	!al
			mov		al,[ecx]
			.if	!al
				inc		ecx
				mov		eax,hMem
				.if byte ptr [eax]
					push	ecx
					invoke strcat,hMem,addr szComma
					pop		ecx
				.endif
				invoke strcat,hMem,ecx
			.endif
		.endif
	.endif
	mov		ecx,[edi].PROPERTIES.nSize
	lea		edi,[edi+ecx+sizeof	PROPERTIES]
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	jne		Nx
	mov		eax,hMem
	.if byte ptr [eax]
		invoke ApiConstListBox,hMem
	.endif
	invoke GlobalFree,hMem
	popad
	ret

ApiConstSrc	endp

ApiConstList proc lpApi:DWORD,nCount:DWORD
	LOCAL	buffer[256]:BYTE

	pushad
	.if	ApiConst
		invoke BinToDec,nCount,addr buffer
		invoke strlen,addr	buffer
		lea		edi,buffer
		add		edi,eax
		mov		esi,lpApi
	  @@:
		mov		al,[esi]
		cmp		al,','
		je		@f
		cmp		al,'('
		je		@f
		or		al,al
		je		Ex
		mov		[edi],al
		inc		esi
		inc		edi
		jmp		@b
	  @@:
		mov		byte ptr [edi],0
		invoke ApiConstSrc,addr	buffer
	  Ex:
	.endif
	popad
	ret

ApiConstList endp

ApiConstLoad proc
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileString,addr	szIniApi,addr iniApiConst,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniAsmFile
	.if	eax
		.while iniBuffer
			invoke strcpy,addr buffer,addr AppPath
			invoke strcat,addr buffer,addr szBackSlash
			invoke strlen,addr buffer
			invoke iniGetItem,addr iniBuffer,addr buffer[eax]
			invoke AddFileToWordList,'C',0,addr	buffer,2
		.endw
	.endif
	ret

ApiConstLoad endp
