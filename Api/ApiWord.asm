
.code

ApiWordLoad	proc
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileString,addr	szIniApi,addr iniApiWord,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniAsmFile
	.if	eax
		.while iniBuffer
			invoke strcpy,addr buffer,addr AppPath
			invoke strcat,addr buffer,addr szBackSlash
			invoke strlen,addr buffer
			invoke iniGetItem,addr iniBuffer,addr buffer[eax]
			invoke AddFileToWordList,'W',0,addr	buffer,2
		.endw
	.endif
	ret

ApiWordLoad	endp

ApiWordConvert proc	hWin:HWND,fAI:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	chrg1:CHARRANGE
	LOCAL	chrg2:CHARRANGE
	LOCAL	nLine:DWORD

	.if	ApiWordConv
		pushad
		invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
		invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,chrg.cpMin
		mov		nLine,eax
		invoke SendMessage,hWin,EM_LINEINDEX,eax,0
		mov		chrg2.cpMin,eax
		mov		edx,chrg.cpMin
		mov		chrg2.cpMax,edx
		sub		edx,eax
		.if	edx>=2
			inc		edx
			mov		dword ptr LineTxt,edx
			invoke SendMessage,hWin,EM_GETLINE,nLine,offset LineTxt
			call ScanNot
			.if	!eax
				mov		eax,chrg.cpMin
				.if	!fAI
					dec		eax
				.endif
				mov		chrg1.cpMax,eax
				dec		eax
				mov		chrg1.cpMin,eax
				call GetWrd
				invoke strlen,offset LineWord
				.if	eax
					mov		edx,chrg1.cpMax
					sub		edx,eax
					mov		chrg1.cpMin,edx
					call TstWrd
					.if	eax
						call ConvWrd
						invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg1
						invoke SendMessage,hWin,EM_REPLACESEL,TRUE,offset LineWord
						invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
						invoke SendMessage,hWin,EM_SCROLLCARET,0,0
					.endif
				.endif
			.endif
		.endif
		popad
	.endif
	ret

GetWrd:
	mov		edx,chrg2.cpMax
	sub		edx,chrg2.cpMin
	dec		edx
	.if	!fAI
		dec		edx
	.endif
	mov		esi,offset LineTxt
	add		esi,edx
	inc		esi
	inc		edx
	inc		edx
	xor		eax,eax
	dec		ah
  @@:
	inc		ah
	dec		esi
	dec		edx
	je		@f
	mov		al,[esi]
	.if	al>='@'
		jmp		@b
	.endif
	.if	al>='0'	&& al<='9'
		jmp		@b
	.endif
  @@:
	mov		edi,offset LineWord
	or		ah,ah
	je		ExGW
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	mov		[edi],al
	.if	al>='@'
		jmp		@b
	.endif
	.if	al>='0'	&& al<='9'
		jmp		@b
	.endif
  ExGW:
	mov		al,0
	mov		[edi],al
	retn

ConvWrd:
	mov		esi,eax
	mov		edi,offset LineWord
	dec		esi
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		al,[edi]
	.if	al<'A' || al>'Z'
		mov		al,[esi]
		mov		[edi],al
	.endif
	or		al,al
	jne		@b
	retn

ScanNot:
	mov		esi,offset LineTxt
	dec		esi
	xor		eax,eax
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,';'
	je		@f
	cmp		al,'"'
	je		@f
	cmp		al,"'"
	je		@f
	or		al,al
	jne		@b
  @@:
	retn

TstWrd:
	mov		esi,offset LineWord
	mov		edi,lpWordList
  NxW:
	mov		al,[edi].PROPERTIES.nType
	cmp		al,'C'
	je		NxS
	cmp		al,'S'
	je		NxS
	cmp		al,'T'
	je		NxS
	cmp		al,'d'
	je		NxS
	cmp		al,'s'
	je		NxS
	cmp		al,'t'
	je		NxS
	mov		eax,TRUE
	xor		ecx,ecx
	dec		ecx
  NxC:
	or		al,al
	je		Found
	inc		ecx
	mov		al,[esi+ecx]
	.if	al>='a'	&& al<='z'
		and		al,5Fh
	.endif
	mov		ah,[edi+ecx+sizeof PROPERTIES]
	.if	ah>='a'	&& ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,ah
	je		NxC
  NxS:
	mov		ecx,[edi].PROPERTIES.nSize
	lea		edi,[edi+ecx+sizeof	PROPERTIES]
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	jne		NxW
	retn
  Found:
	lea		eax,[edi+sizeof	PROPERTIES]
	retn

ApiWordConvert endp

ApiWordList	proc hWin:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	nbr:DWORD
	LOCAL	buffer[256]:BYTE
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
	.if	!fProcInSBar
		invoke LoadEdit,hWin
		invoke FindProcPos,hWin
		invoke GlobalUnlock,hSrcMem
		invoke GlobalFree,hSrcMem
		mov		hSrcMem,0
	.endif
	mov		edi,lpWordList
	call	GetWords
	invoke SendMessage,hLB,WM_SETREDRAW,TRUE,0
	.if	nbr
		invoke ShowListBox,hWin
		invoke SendMessage,hLB,LB_SETCURSEL,0,0
		mov		eax,hWin
		mov		fLB,eax
		mov		fLBWord,eax
	.else
		invoke ShowWindow,hLB,SW_HIDE
		xor		eax,eax
		mov		fLB,eax
		mov		fLBWord,eax
	.endif
	popad
	ret

GetWords:
	movzx	eax,[edi].PROPERTIES.nType
	.if fLocal
		.if eax=='p' && ProcPos
			push	edi
			lea		edi,[edi+sizeof PROPERTIES]
			invoke strcmp,edi,offset szProcName
			.if !eax
				invoke strlen,edi
				lea		edi,[edi+eax+1]
				.if byte ptr [edi]
					mov		nType,80000h
					call	AddWords
				.endif
				invoke strlen,edi
				lea		edi,[edi+eax+1]
				.if byte ptr [edi]
					mov		nType,90000h
					call	AddWords
				.endif
			.endif
			pop		edi
		.endif
	.else
		.if	(eax=='W' || eax=='M' || eax=='S' || eax=='p' || eax=='c' || eax=='d' || eax=='m' || eax=='s' || eax=='l')
			push	edi
			lea		edi,[edi+sizeof PROPERTIES]
			push	eax
			.if eax=='W'
				;Word
				mov		nType,20000h
			.elseif eax=='m'
				;Macro
				mov		nType,0C0000h
			.elseif eax=='M'
				;Message
				mov		nType,0D0000h
			.elseif eax=='S'
				;Win Struct
				mov		nType,40000h
			.elseif eax=='s'
				;Struct
				mov		nType,50000h
			.elseif eax=='p'
				;Proc
				mov		nType,10000h
			.elseif eax=='c'
				;Constant
				mov		nType,30000h
			.elseif eax=='d'
				;Data
				mov		nType,0E0000h
			.elseif eax=='l'
				;Label
				mov		nType,0F0000h
			.endif
			call	AddWord
			pop		eax
			.if eax=='p' && ProcPos
				invoke strcmp,edi,offset szProcName
				.if !eax
					invoke strlen,edi
					lea		edi,[edi+eax+1]
					.if byte ptr [edi]
						mov		nType,80000h
						call	AddWords
					.endif
					invoke strlen,edi
					lea		edi,[edi+eax+1]
					.if byte ptr [edi]
						mov		nType,90000h
						call	AddWords
					.endif
				.endif
			.endif
			pop		edi
		.endif
	.endif
	mov		ecx,[edi].PROPERTIES.nSize
	lea		edi,[edi+ecx+sizeof	PROPERTIES]
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	jne		GetWords
	retn

AddWords:
  NxW:
	lea		edx,buffer
  @@:
	mov		al,[edi]
	.if al==','
		xor		al,al
	.elseif !al
		dec		edi
	.endif
	mov		[edx],al
	.if al==':'
;		mov		byte ptr [edx],0
	.endif
	inc		edi
	inc		edx
	or		al,al
	jne		@b
	push	edi
	lea		edi,buffer
	call	AddWord
	pop		edi
	cmp		byte ptr [edi],0
	jne		NxW
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

ApiWordList	endp
