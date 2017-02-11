.data

lpTabs		dd 200
szAssume	db 'assume',0
szNothing	db 'nothing',0
szNot		db "';/",'"',0

.data?

StBuff			db 64 dup (?)

.code

ApiStructLoad proc
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileString,addr	szIniApi,addr iniApiStruct,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr	iniAsmFile
	.if	eax
		.while iniBuffer
			invoke strcpy,addr buffer,addr AppPath
			invoke strcat,addr buffer,addr szBackSlash
			invoke strlen,addr buffer
			invoke iniGetItem,addr iniBuffer,addr buffer[eax]
			invoke AddFileToWordList,'S',0,addr	buffer,2
		.endw
	.endif
	ret

ApiStructLoad endp

ApiStructListBox proc lpList:DWORD,nType:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	chrg:CHARRANGE

	pushad
	invoke ShowWindow,hTlt,SW_HIDE
	mov		fTlt,0
	invoke SendMessage,hLB,WM_SETREDRAW,FALSE,0
	m2m		hLB,hLBU
	.if	!fLBStruct
		invoke SendMessage,hEdit,EM_EXGETSEL,0,addr	findtext.chrg
		m2m		fLBStruct,hEdit
	.endif
	invoke SendMessage,hEdit,EM_HIDESELECTION,TRUE,FALSE
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr	chrg
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr	findtext.chrg
	invoke SendMessage,hEdit,EM_GETSELTEXT,0,addr buffer1
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr	chrg
	invoke SendMessage,hEdit,EM_HIDESELECTION,FALSE,FALSE
	invoke SendMessage,hLB,LB_RESETCONTENT,0,0
	invoke SendMessage,hLB,LB_SETTABSTOPS,1,addr lpTabs
	invoke lstrcpyn,addr LineTxt,lpList,8192
  @@:
	mov		buffer,0
	invoke iniGetItem,addr LineTxt,addr	buffer
	mov		al,buffer[0]
	.if al>='0' && al<='9'
		jmp		@b
	.endif
	mov		al,buffer[0]
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
		lea		esi,buffer
		invoke SendMessage,hLB,LB_ADDSTRING,0,esi
		.if nType=='s'
			mov		edx,50000h
		.else
			mov		edx,40000h
		.endif
		invoke SendMessage,hLB,LB_SETITEMDATA,eax,edx
		jmp		@b
	.endif
	invoke ShowListBox,hEdit
	invoke SendMessage,hLB,LB_SETCURSEL,0,0
	invoke SendMessage,hLB,WM_SETREDRAW,TRUE,0
	m2m		fLB,hEdit
	popad
	ret

ApiStructListBox endp

ApiStructSrc proc lpSrc:DWORD
	LOCAL	fFound:DWORD

	pushad
	mov		fFound,FALSE
	mov		edi,lpWordList
  Nx:
	.if	[edi].PROPERTIES.nType=='S'	|| [edi].PROPERTIES.nType=='s'
		mov		al,StBuff
		.if	al
			mov		esi,offset StBuff
		.else
			mov		esi,lpSrc
		.endif
		lea		ecx,[edi+sizeof	PROPERTIES]
		dec		esi
		dec		ecx
	  @@:
		inc		esi
		inc		ecx
		mov		al,[esi]
		.if	al
			cmp		al,[ecx]
			je		@b
		.endif
		.if	al=='.'	|| al==' ' || al==VK_TAB || al=='*' ||	!al
			mov		al,[ecx]
			.if	!al; || al==':' || al=='['
				inc		ecx
				movzx	eax,[edi].PROPERTIES.nType
				invoke ApiStructListBox,ecx,eax
				mov		fFound,TRUE
				jmp		Ex
			.endif
		.endif
	.endif
	mov		ecx,[edi].PROPERTIES.nSize
	lea		edi,[edi+ecx+sizeof	PROPERTIES]
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	jne		Nx
  Ex:
	popad
	mov		eax,fFound
	ret

ApiStructSrc endp

ApiStructFind proc uses	esi	edi,lpSrc:DWORD

	mov		edi,lpWordList
  Nx:
	.if	[edi].PROPERTIES.nType=='S'	|| [edi].PROPERTIES.nType=='s'
		lea		ecx,[edi+sizeof	PROPERTIES]
		mov		esi,lpSrc
		dec		esi
		dec		ecx
	  @@:
		inc		esi
		inc		ecx
		mov		al,[esi]
		.if	al
			cmp		al,[ecx]
			je		@b
		.endif
		.if	al=='<'	|| al==',' || al=='	' || al==VK_TAB	|| !al
			mov		al,[ecx]
			.if	!al
				mov		eax,edi
				jmp		Ex
			.endif
		.endif
	.endif
	mov		ecx,[edi].PROPERTIES.nSize
	lea		edi,[edi+ecx+sizeof	PROPERTIES]
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	jne		Nx
  Ex:
	ret

ApiStructFind endp

;Find:	MyStruct	MYSTRUCT <>
ApiStructGet proc uses esi edi,lpSrc:DWORD

	mov		edi,lpWordList
  Nx:
	.if	[edi].PROPERTIES.nType=='d'
		lea		ecx,[edi+sizeof	PROPERTIES]
		mov		esi,lpSrc
		dec		esi
		dec		ecx
	  @@:
		inc		esi
		inc		ecx
		mov		al,[esi]
		.if	al
			cmp		al,[ecx]
			je		@b
		.endif
		.if	!al && (!byte ptr [ecx] || byte ptr [ecx]==':' || byte ptr [ecx]=='[')
			mov		eax,edi
			jmp		Ex
		.endif
	.endif
	mov		ecx,[edi].PROPERTIES.nSize
	lea		edi,[edi+ecx+sizeof	PROPERTIES]
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	jne		Nx
  Ex:
	ret

ApiStructGet endp

ApiStructCheck proc	hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	pf:PROFIND
	LOCAL	chrg:CHARRANGE
	LOCAL	lpPtr:DWORD
	LOCAL	lpMem:DWORD

	.if	ShowApiStruct
		invoke GetLine,hWin
		mov		edx,LineEn
		sub		edx,LineSt
		add		edx,offset LineTxt
		dec		edx
	  @@:
		mov		ax,word	ptr	[edx]
		dec		edx
		or		al,al
		je		Ex
		cmp		al,'.'
		je		@f
		cmp		ax,'>-'
		jne		@b
	  @@:
		mov		al,byte	ptr	[edx]
		.if al==VK_SPACE || al==VK_TAB
			dec		edx
			jmp		@b
		.endif
		.if	al==')'
			.if nAsm==nCPP
				;((NMHDR*)lParam)->code
				dec		edx
				.while byte ptr [edx-1] && byte ptr [edx]!=')'
					dec		edx
				.endw
			.endif
			;(RECT ptr [edx]).left
		  @@:
			dec		edx
			mov		al,byte	ptr	[edx]
			cmp		al,'('
			je		@f
			cmp		al,0
			jne		@b
			jmp		Ex
		  @@:
			inc		edx
			.while byte ptr [edx]==VK_SPACE || byte ptr [edx]==VK_TAB
				inc		edx
			.endw
			invoke ApiStructSrc,edx
		.elseif	al==']'
			;assume	edx:ptr	RECT
			;[edx].left
			push	esi
			push	edx
			invoke LoadEdit,hWin
			m2m		pf.hMem,hSrcMem
			invoke GetWindowLong,hMdiCld,16
			mov		pf.nFile,eax
			mov		pf.pFile,0
			lea		eax,buffer
			mov		pf.lpFind,eax
			mov		pf.lpNot,offset	szNot
			mov		pf.lpLine,offset LineTxt
			invoke strcpy,addr buffer,offset szAssume
			lea		esi,buffer
			add		esi,6
			mov		eax,',2,'
			mov		[esi],eax
			add		esi,3
			pop		edx
		  @@:
			dec		edx
			mov		al,byte	ptr	[edx]
			cmp		al,'['
			je		@f
			cmp		al,0
			jne		@b
			jmp		Ex
		  @@:
			inc		edx
			mov		al,[edx]
			cmp		al,']'
			je		@f
			mov		[esi],al
			inc		esi
			jmp		@b
		  @@:
			mov		eax,',2,'
			mov		[esi],eax
			add		esi,3
			mov		lpPtr,esi
			invoke strcpy,esi,offset szSrcPtr
			add		esi,3
			mov		eax,'2,'
			mov		[esi],eax
			pop		esi
			mov		buffer1,0
			invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
		  @@:
			mov		pf.nFun,0
			invoke ProFind,addr	pf
			mov		eax,chrg.cpMin
			.if	eax>pf.pFile
				.if	pf.pLine!=-1
					m2m		lpMem,pf.pFile
					mov		edx,offset LineTxt
					add		edx,pf.pLine
					add		edx,4
					invoke strcpy,addr buffer1,edx
					jmp	@b
				.endif
			.endif
			mov		al,buffer1
			.if	al
				m2m		pf.pFile,lpMem
				push	esi
				mov		esi,lpPtr
				invoke strcpy,esi,offset szNothing
				add		esi,7
				mov		eax,'2,'
				mov		[esi],eax
				pop		esi
				mov		pf.nFun,0
				invoke ProFind,addr	pf
				mov		eax,chrg.cpMin
				.if	pf.pLine!=-1 &&	eax>pf.pFile
					mov		buffer1,0
				.endif
			.endif
			mov		al,buffer1
			.if	al
				invoke ProGetWord,addr buffer1
				invoke ApiStructSrc,eax
			.endif
			mov		pf.nFun,1
			invoke ProFind,addr	pf
		.elseif	al!=' '	&& al!=VK_TAB && al!=0 && al!='>' && al!='<'
			;[edx].RECT.left
			;RECT.left[edx]
			;[edx][RECT.left]
			;[edx +	RECT.left]
			;[edx.RECT.left]
		  @@:
			dec		edx
			mov		al,byte	ptr	[edx]
			cmp		al,','
			je		@f
			cmp		al,'.'
			je		@f
			cmp		al,' '
			je		@f
			cmp		al,'+'
			je		@f
			cmp		al,'-'
			je		@f
			cmp		al,'['
			je		@f
			cmp		al,'='
			je		@f
			cmp		al,'>'
			je		@f
			cmp		al,'<'
			je		@f
			cmp		al,'!'
			je		@f
			cmp		al,'('
			je		@f
			cmp		al,'*'
			je		@f
			cmp		al,'&'
			je		@f
			cmp		al,VK_TAB
			je		@f
			cmp		al,0
			jne		@b
		  @@:
			inc		edx
			push	edx
			invoke ApiStructSrc,edx
			pop		edx
			.if	!eax &&	(ProcPos ||	!fProcInSBar)
				push	edx
				push	esi
				;LOCAL rect:RECT
				;rect.left
				invoke strcpy,addr buffer1,edx
				invoke LoadEdit,hWin
				.if	!fProcInSBar
					invoke FindProcPos,hWin
				.endif
				m2m		pf.hMem,hSrcMem
				mov		pf.nFun,0
				mov		pf.nFile,0
				m2m		pf.pFile,ProcPos
				lea		eax,buffer
				mov		pf.lpFind,eax
				mov		pf.lpNot,offset	szNot
				mov		pf.lpLine,offset LineTxt
				invoke ProGetWord,addr buffer1
				invoke strcpy,addr buffer,eax
				lea		esi,buffer
				invoke strlen,addr buffer
				add		esi,eax
				mov		eax,',3,'
				mov		[esi],eax
				add		esi,3
				.if nAsm==nCPP
					mov		dword ptr [esi],'0,;'
				.elseif nAsm==nBCET
					mov		dword ptr [esi],'2,SA'
					mov		byte ptr [esi+4],0
				.else
					mov		dword ptr [esi],'0,:'
				.endif
				pop		esi
				mov		buffer1,0
				invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
				invoke ProFind,addr	pf
				mov		eax,chrg.cpMin
				.if	eax>pf.pFile
					.if	pf.pLine!=-1
						mov		edx,offset LineTxt
						.if nAsm==nCPP
							.while byte ptr [edx]==VK_SPACE || byte ptr [edx]==VK_TAB
								inc		edx
							.endw
						.else
							add		edx,pf.pLine
							add		edx,1
						.endif
						invoke strcpy,addr buffer1,edx
					.endif
				.endif
				mov		pf.nFun,1
				invoke ProFind,addr	pf
				xor		eax,eax
				mov		al,buffer1
				.if	al
					xor		eax,eax
					.if nAsm==nBCET
						inc		eax
					.endif
					invoke ProGetWord,addr buffer1[eax]
					invoke ApiStructSrc,eax
				.endif
				pop		edx
			.endif
			.if	!eax
				;.data
				;rect		RECT <>
				;.code
				;rect.left
				pushad
				invoke GetLine,hWin
				popad
				push	edx
				invoke strcpy,addr buffer1,edx
				invoke ProGetWord,addr buffer1
				invoke strcpy,addr buffer,eax
				invoke ApiStructGet,addr buffer
				.if eax
					push	esi
					lea		esi,[eax+sizeof PROPERTIES]
					invoke strlen,esi
					lea		esi,[esi+eax+1]
					invoke ApiStructSrc,esi
					pop		esi
				.endif
				pop		edx
			.endif
		.endif
	.endif
  Ex:
	ret

ApiStructCheck endp

MakeStructTooltip proc uses	esi	edi,lpStructItems:DWORD,lpBuff:DWORD,lpType:DWORD
	LOCAL	buffer[256]:BYTE

	mov		esi,lpStructItems
	mov		edi,lpBuff
	invoke strcpy,edi,esi
	.while byte	ptr	[edi]
		invoke iniGetItem,edi,addr buffer
		invoke iniInStr,addr buffer,offset szTab
		.if	eax!=-1
			mov		buffer[eax],0
			inc		eax
			invoke ApiStructFind,addr buffer[eax]
			or		eax,eax
			je		@f
			push	esi
			push	edi
			lea		esi,[eax+sizeof	PROPERTIES]
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			invoke MakeStructTooltip,esi,edi,addr buffer
			pop		edi
			pop		esi
		.else
			invoke strcat,offset szApiToolTip,offset szComma
			.if	lpType
				invoke strcat,offset szApiToolTip,lpType
				invoke strcat,offset szApiToolTip,offset szPoint
			.endif
			invoke strcat,offset szApiToolTip,addr	buffer
		.endif
	.endw
  @@:
	ret

MakeStructTooltip endp

IsLineStruct proc uses esi edi
	LOCAL	buffer[256]:BYTE

	mov		esi,offset LineTxt
	lea		edi,buffer
	invoke GetWord
	lea		edi,buffer
	invoke GetWord
	mov		al,buffer
	or		al,al
	je		@f
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,' '
	je		@b
	cmp		al,VK_TAB
	je		@b
	cmp		al,'<'
	jne		@f
	invoke ApiStructFind,addr buffer
	or		eax,eax
	je		@f
	lea		edi,[eax+sizeof	PROPERTIES]
	invoke strlen,edi
	lea		esi,[edi+eax+1]
	invoke strcpy,offset szApiToolTip,edi
	invoke MakeStructTooltip,esi,offset	tempbuff,NULL
	mov		eax,offset szApiToolTip
	mov		lptrApi,eax
	ret
  @@:
	mov		eax,-1
	ret

IsLineStruct endp

