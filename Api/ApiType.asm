.code

ApiTypeLoad proc
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileString,addr	szIniApi,addr iniApiType,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr	iniAsmFile
	.if	eax
		.while iniBuffer
			invoke strcpy,addr buffer,addr AppPath
			invoke strcat,addr buffer,addr szBackSlash
			invoke strlen,addr buffer
			invoke iniGetItem,addr iniBuffer,addr buffer[eax]
			invoke AddFileToWordList,'T',0,addr	buffer,2
		.endw
	.endif
	ret

ApiTypeLoad endp

ApiArrayLoad proc
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileString,addr	szIniApi,addr iniApiArray,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniAsmFile
	.if	eax
		.while iniBuffer
			invoke strcpy,addr buffer,addr AppPath
			invoke strcat,addr buffer,addr szBackSlash
			invoke strlen,addr buffer
			invoke iniGetItem,addr iniBuffer,addr buffer[eax]
			invoke AddFileToWordList,'R',0,addr	buffer,2
		.endw
	.endif
	ret

ApiArrayLoad endp

ApiTypeList	proc hWin:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	nbr:DWORD
;	LOCAL	buffer[64]:BYTE
	LOCAL	nType:DWORD

	pushad
	invoke ShowWindow,hLBU,SW_HIDE
	m2m		hLB,hLBS
	invoke SendMessage,hLB,WM_SETREDRAW,FALSE,0
	invoke SendMessage,hWin,EM_HIDESELECTION,TRUE,FALSE
	invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
	.if	chrg.cpMin
		dec		chrg.cpMin
		invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
		inc		chrg.cpMin
	.endif
	invoke GetWordFromPos,hWin
	invoke strlen,offset LineWord
	mov		edx,chrg.cpMin
	mov		findtext.chrg.cpMax,edx
	sub		edx,eax
	mov		findtext.chrg.cpMin,edx
	invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
	invoke SendMessage,hWin,EM_HIDESELECTION,FALSE,FALSE
	invoke SendMessage,hLB,LB_RESETCONTENT,0,0
	mov		nbr,0
	mov		edi,lpWordList
	call	GetWords
	invoke SendMessage,hLB,WM_SETREDRAW,TRUE,0
	.if	nbr
		invoke ShowListBox,hWin
		invoke SendMessage,hLB,LB_SETCURSEL,0,0
		mov		eax,hWin
		mov		fLB,eax
		mov		fLBType,eax
	.else
		invoke ShowWindow,hLB,SW_HIDE
		xor		eax,eax
		mov		fLB,eax
		mov		fLBType,eax
	.endif
	popad
	ret

GetWords:
	movzx	eax,[edi].PROPERTIES.nType
	.if	eax=='T' || eax=='t' || eax=='S' || eax=='s'
		.if eax=='T'
			mov		nType,0A0000h
		.elseif eax=='t'
			mov		nType,0A0000h
		.elseif eax=='S'
			;Win Struct
			mov		nType,40000h
		.elseif eax=='s'
			;Struct
			mov		nType,50000h
		.endif
		push	edi
		lea		edi,[edi+sizeof PROPERTIES]
		call	AddWord
		pop		edi
	.endif
	mov		ecx,[edi].PROPERTIES.nSize
	lea		edi,[edi+ecx+sizeof	PROPERTIES]
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	jne		GetWords
	retn

AddWord:
	mov		esi,offset LineWord
	xor		ecx,ecx
	dec		ecx
  NxC:
	inc		ecx
	mov		al,[esi+ecx]
	or		al,al
	je		@f
	.if	al>='a'	&& al<='z'
		and		al,5Fh
	.endif
	mov		ah,[edi+ecx]
	.if	ah>='a'	&& ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,ah
	je		NxC
	jmp		Ex
  @@:
	invoke SendMessage,hLBS,LB_ADDSTRING,0,edi
	invoke SendMessage,hLBS,LB_SETITEMDATA,eax,nType
	inc		nbr
  Ex:
	retn

ApiTypeList	endp

TypeCheck proc uses esi,hWin:HWND

	invoke GetLine,hWin
	mov		esi,offset LineTxt
	add		esi,LineEn
	sub		esi,LineSt
	dec		esi
	.while esi>offset LineTxt && (byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB)
		dec		esi
	.endw
	.while esi>offset LineTxt && byte ptr [esi]!=' ' && byte ptr [esi]!=VK_TAB
		dec		esi
	.endw
	.if byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB
		inc		esi
		.if byte ptr [esi+2]==' ' || byte ptr [esi+2]==VK_TAB
			mov		ax,[esi]
			and		ax,5F5Fh
			.if ax=='SA'
				invoke ApiTypeList,hWin
			.endif
		.endif
	.endif
	ret

TypeCheck endp

