TPE_STCODE		equ 1
TPE_ENCODE		equ 2
TPE_STCONST		equ 3
TPE_ENCONST		equ 4
TPE_STDATA		equ 5
TPE_ENDATA		equ 6
TPE_STMACRO		equ 7
TPE_ENMACRO		equ 8
TPE_STSTRUCT	equ 9
TPE_ENSTRUCT	equ 10
TPE_STSKIP		equ 11
TPE_ENSKIP		equ 12
TPE_STLABEL		equ 13
TPE_ENLABEL		equ 14
TPE_STLOCAL		equ 15
TPE_ENLOCAL		equ 16
TPE_ST0			equ 17
TPE_EN0			equ 18
TPE_ST1			equ 19
TPE_EN1			equ 20
TPE_ST2			equ 21
TPE_EN2			equ 22
TPE_ST3			equ 23
TPE_EN3			equ 24

NME_NONE		equ 0
NME_START		equ 1
NME_STARTOPT	equ 2
NME_END			equ 3
NME_ENDOPT		equ 4

PARSEDEF struct
	nType	dd ?
	nName	dd ?
	nLen	dd ?
	nLen2	dd ?
	rpEnd	dd ?
	rpNext	dd ?
PARSEDEF ends

.const

;Dll functions
szParseFile		db 'ParseFile',0
szFixUnknown	db 'FixUnknown',0
szFindInFile	db 'FindInFile',0
szFindProcPos	db 'FindProcPos',0
szFindLocal		db 'FindLocal',0
;Free Pascal words
szBegin			db 'begin',0
szCase			db 'case',0
szEnd			db 'end',0
szVar			db 'var',0
szConst			db 'const',0

.data?

hCodeDefs		dd ?
hParseDll		dd ?

.code

ParseLineDef proc uses ecx edx esi edi,lpSrc:DWORD,lpDest:DWORD
	LOCAL	pMax:DWORD

	mov		esi,lpSrc
	mov		edi,lpDest
	mov		eax,edi
	add		eax,8000
	mov		pMax,eax
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,' '
	je		@b
	cmp		al,VK_TAB
	je		@b
	dec		esi
	dec		edi
	xor		ecx,ecx
	xor		eax,eax
	mov		edx,nAsm
  Nxt:
	mov		ah,al
	inc		esi
	cmp		edi,pMax
	jnb		Exx
	inc		edi
	mov		al,[esi]
	.if edx==nBCET && al==0Dh && ah=='_'
		call	SkpLn
		dec		edi
		xor		ah,ah
	.endif
  @@:
	.if al==VK_TAB
		mov		al,' '
	.endif
	.if al==' ' && (ah==' ' || ah==',' || ah=='\' || ah==':' || ah=='(')
		invoke SpcSkip
	.endif
	.if al==';' && ah=='\'
		call	SkpLn
		dec		edi
		jmp		@b
	.endif
	.if al=='(' && (edx==nHLA || edx==nFP)
		dec		edi
		jmp		Nxt
	.endif
	.if al==')' && (edx==nHLA || edx==nFP)
		.if ah==' '
			dec		edi
		.endif
		jmp		Ex
	.endif
	.if al=='"' || (al=="'" && edx!=nBCET)
		call	CopyString
		dec		esi
		dec		edi
		jmp		Nxt
	.endif
	.if al==';' || (al=="'" && edx==nBCET)
		.if edx!=nHLA && edx!=nFP
			.if ah==' '
				dec		edi
			.endif
			jmp		Ex
		.else
			inc		esi
			invoke SpcSkip
			dec		esi
			.if al!=0Dh && al
				mov		al,','
			.endif
		.endif
	.endif
	.if (al==',' || al==':') && ah==' '
		dec		edi
	.endif
	mov		[edi],al
	or		al,al
	je		@f
	inc		ecx
	cmp		al,0Dh
	jne		Nxt
	inc		esi
	mov		al,[esi]
	cmp		al,0Ah
	jne		@f
	inc		esi
	inc		ecx
  @@:
	.if ah==','
		invoke SpcSkip
		dec		esi
		dec		edi
		jmp		Nxt
	.elseif ah=='\'
		invoke SpcSkip
		dec		esi
		dec		edi
		dec		edi
		jmp		Nxt
	.endif
  Ex:
	.if edx==nTASM
	  Nxx:
		invoke SpcSkip
		mov		al,[esi]
		.if al==';' || al==VK_RETURN
			call	SkpLn
			jmp		Nxx
		.endif
		mov		eax,[esi]
		and		eax,5F5F5F5Fh
		.if eax=='SESU' && (byte ptr [esi+4]==VK_SPACE || byte ptr [esi+4]==VK_TAB)
			call	SkpLn
			jmp		Nxx
		.endif
		.if eax=='ACOL' && (byte ptr [esi+4]=='L' || byte ptr [esi+4]=='l') && (byte ptr [esi+5]==VK_SPACE || byte ptr [esi+5]==VK_TAB)
			call	SkpLn
			jmp		Nxx
		.endif
		shl		eax,8
		shr		eax,8
		.if eax=='GRA' && (byte ptr [esi+3]==VK_SPACE || byte ptr [esi+3]==VK_TAB)
			add		esi,3
			invoke SpcSkip
			mov		al,','
			mov		[edi],al
			dec		esi
			jmp		Nxt
		.endif
	.endif
  Exx:
	xor		al,al
	mov		[edi],al
	mov		eax,ecx
	ret

CopyString:
	mov		ah,al
	mov		[edi],al
	inc		esi
	inc		edi
  @@:
	mov		al,[esi]
	or		al,al
	je		@f
	cmp		al,0Dh
	je		@f
	mov		[edi],al
	inc		esi
	inc		edi
	cmp		al,ah
	jne		@b
  @@:
	retn

SkpLn:
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	or		al,al
	je		@f
	cmp		al,0Dh
	jne		@b
	inc		esi
	mov		al,[esi]
	cmp		al,0Ah
	jne		@f
	inc		esi
  @@:
	retn

ParseLineDef endp

ReverseArgs proc uses edi esi,lpStr:DWORD

	mov		edi,offset tempbuff
	mov		esi,lpStr
	invoke strcpy,edi,esi
	invoke strlen,edi
	.if eax
		lea		edi,[edi+eax]
	  @@:
		dec		edi
		.if byte ptr [edi]==','
			mov		byte ptr [edi],0
			inc		edi
			invoke strcpy,esi,edi
			invoke strlen,esi
			lea		esi,[esi+eax]
			mov		byte ptr [esi],','
			inc		esi
			jmp		@b
		.elseif edi==offset tempbuff
			invoke strcpy,esi,edi
		.else
			jmp		@b
		.endif
	.endif
	ret

ReverseArgs endp

FindProcArgs proc uses edi esi,lpDest:DWORD,lpSrc:DWORD

	mov		edi,lpDest
	mov		esi,edi
	add		esi,8192
	invoke ParseLineDef,lpSrc,esi
	invoke SpcSkip
	mov		al,[esi]
	or		al,al
	je		Ex
	cmp		al,','
	je		NxtArg
  Nxt:
	invoke SpcSkip
	or		al,al
	je		Ex
	mov		eax,dword ptr [esi]
	mov		ecx,dword ptr [esi+4]
	and		eax,5F5F5F5Fh
	and		ecx,0FF5F5F5Fh
  @@:
	cmp		eax,'CDTS'
	jne		@f
	cmp		ecx,',LLA'
	jne		@f
	add		esi,8
	jmp		Nxt
  @@:
	and		ecx,5F5F5F5Fh
	cmp		eax,'VIRP'
	jne		@f
	cmp		ecx,'ETA'
	jne		@f
	add		esi,7
	jmp		Nxt
  @@:
	cmp		eax,'CDTS'
	jne		@f
	cmp		ecx,'LLA'
	jne		@f
	add		esi,7
	jmp		Nxt
  @@:
	and		ecx,5F5F5Fh
	cmp		eax,'LBUP'
	jne		@f
	cmp		ecx,'CI'
	jne		@f
	add		esi,6
	jmp		Nxt
  @@:
	and		ecx,5F5Fh
	cmp		eax,'MARF'
	jne		@f
	cmp		ecx,'E'
	jne		@f
	add		esi,5
	jmp		Nxt
  @@:
	and		ecx,5Fh
	cmp		eax,'CORP'
	jne		@f
	cmp		ecx,0
	jne		@f
	add		esi,4
	jmp		Nxt
  @@:
	cmp		eax,'SESU'
	jne		@f
	cmp		ecx,0
	jne		@f
	add		esi,4
	jmp		Nxt
  @@:
	.if nAsm==nFP
		cmp		eax,'RAV'
		jne		@f
		add		esi,4
		jmp		Nxt
	.endif
  @@:
	mov		al,[esi+3]
	.if al==' ' || al==',' || !al
		mov		eax,dword ptr [esi]
		and		eax,5F5F5Fh
		cmp		eax,'ISE'
		jne		@f
		add		esi,3
		jmp		Nxt
	  @@:
		cmp		eax,'IDE'
		jne		@f
		add		esi,3
		jmp		Nxt
	  @@:
		cmp		eax,'XBE'
		jne		@f
		add		esi,3
		jmp		Nxt
	  @@:
		cmp		eax,'XAE'
		jne		@f
		add		esi,3
		jmp		Nxt
	  @@:
		cmp		eax,'XCE'
		jne		@f
		add		esi,3
		jmp		Nxt
	  @@:
		cmp		eax,'XDE'
		jne		@f
		add		esi,3
		jmp		Nxt
	  @@:
		cmp		eax,'PBE'
		jne		@f
		add		esi,3
		jmp		Nxt
	  @@:
	.endif
	mov		ax,word ptr [esi]
	.if (al=='C' || al=='c') && (ah==' ' || !ah)
		add		esi,2
		jmp		Nxt
	.endif
	mov		al,[esi]
	.if al==','
		inc		esi
	.endif
  NxtArg:
	invoke SpcSkip
	mov		al,[esi]
	or		al,al
	je		Ex
	call GetArg
	jmp		NxtArg
  Ex:
	xor		eax,eax
	mov		[edi],al
	.if nAsm==nHLA
		mov		eax,lpDest
		inc		eax
		invoke ReverseArgs,eax
	.endif
	xor		eax,eax
	ret

CpyArg:
	xor		eax,eax
  @@:
	mov		ecx,[esi]
	and		ecx,0FF5F5F5Fh
	.if ecx==' RTP'
		mov		[edi],ecx
		add		esi,4
		add		edi,4
	.endif
	.if nAsm==nBCET
		mov		edx,[esi]
		mov		ecx,[esi+4]
		and		edx,5F5F5F5Fh
		and		ecx,0FF5Fh
		.if (edx=='AVYB' && ecx==' L') || (edx=='ERYB' && ecx==' F')
			add		esi,6
		.endif
		mov		edx,[esi]
		and		edx,0FF5F5FFFh
		.if edx==' SA '
			mov		byte ptr [edi],':'
			inc		edi
			add		esi,4
			inc		ah
		.endif
	.endif
	mov		al,[esi]
	.if (al>='0' && al<='9') || (al>='@' && al<='Z') || (al>='a' && al<='z') || al=='_' || al==':'
		.if al==':'
			inc		ah
		.endif
		.if ah && al>='a' && al<='z'
			and		al,5Fh
		.endif
		mov		[edi],al
		inc		esi
		inc		edi
		jmp		@b
	.endif
	.if !ah
		mov		dword ptr [edi],'OWD:'
		add		edi,4
		mov		word ptr [edi],'DR'
		add		edi,2
	.endif
  @@:
	mov		al,[esi]
	.if al==')' && nAsm==nBCET
		.while byte ptr [esi]
			inc		esi
		.endw
	.endif
	mov		al,[esi]
	.if al!=',' && al
		inc		esi
		jmp		@b
	.endif
	.if al==','
		inc		esi
	.endif
	retn

GetArg:
	mov		al,[esi]
	.if al>='?'
		mov		byte ptr [edi],','
		inc		edi
		call CpyArg
		mov		byte ptr [edi],0
	.elseif al==','
		mov		byte ptr [edi],','
		inc		edi
		inc		esi
		mov		byte ptr [edi],0
	.else
		inc		esi
		mov		byte ptr [edi],0
	.endif
	retn

FindProcArgs endp

IsTypeStruct proc uses esi,lpWord:DWORD
	LOCAL nType:DWORD

	mov		nType,FALSE
	mov		esi,lpWordList
	.while [esi].PROPERTIES.nSize
		mov		al,[esi].PROPERTIES.nType
		.if al=='S' || al=='s'
			invoke strcmp,lpWord,addr [esi+sizeof PROPERTIES]
			.if !eax
				inc		eax
				jmp		Ex
			.endif
		.elseif (al=='T' || al=='t') && !nType
			invoke strcmp,lpWord,addr [esi+sizeof PROPERTIES]
			.if !eax
				mov		nType,TRUE
				lea		eax,[esi+sizeof PROPERTIES]
				mov		lpWord,eax
				mov		esi,lpWordList
			.endif
		.endif
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
	xor		eax,eax
  Ex:
	ret

IsTypeStruct endp

FindStructData proc uses ebx esi edi,lpBuff:DWORD,lpMSt:DWORD,lpMEnd:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	nname:DWORD

	lea		ebx,buffer
	mov		byte ptr [ebx],0
	mov		nname,0
	mov		edi,lpBuff
	mov		esi,lpMSt
	call	SkpLn
  Nx:
	.if esi<lpMEnd
		mov		eax,edi
		sub		eax,lpBuff
		.if eax<10*1024
			call	PutItem
		.else
			call	SkpLn
		.endif
		jmp		Nx
	.endif
	mov		esi,lpMEnd
	mov		al,0
	stosb
	mov		eax,esi
	ret

AddName:
	shl		nname,1
	invoke SpcSkip
	xor		ecx,ecx
	mov		al,[esi]
	.while (al>='@' && al<='Z') || (al>='a' && al <='z') || al=='_'
		inc		ecx
		mov		[ebx],al
		inc		ebx
		inc		esi
		mov		al,[esi]
	.endw
	.if ecx
		mov		byte ptr [ebx],'.'
		inc		ebx
		mov		byte ptr [ebx],0
		inc		nname
	.endif
	retn

RemoveName:
	shr		nname,1
	.if CARRY?
		lea		ecx,buffer
		dec		ebx
		dec		ebx
		.while byte ptr [ebx]!='.' && ebx>=ecx
			mov		byte ptr [ebx],0
			dec		ebx
		.endw
		inc		ebx
	.endif
	retn

PutItem:
	invoke SpcSkip
	or		al,al
	je		PutEx
	cmp		al,0Dh
	je		PutEx
	cmp		al,';'
	je		PutEx
	cmp		al,'{'
	jne		@f
	inc		esi
	jmp	PutItem
  @@:
	cmp		al,'}'
	je		PutEx
	cmp		al,'.'
	jne		@f
	inc		esi
  @@:
	mov		eax,dword ptr [esi]
	and		eax,5F5F5F5Fh
	cmp		eax,'SDNE'
	jne		@f
	mov		cl,[esi+4]
	.if cl==';' || cl==09h || cl==' ' || cl==0Dh
		add		esi,4
		call	RemoveName
		jmp		PutEx
	.endif
  @@:
	cmp		eax,'OINU'
	jne		@f
	mov		cx,word ptr [esi+4]
	and		cl,5Fh
	cmp		cl,'N'
	jne		@f
	.if ch==';' || ch==09h || ch==' ' || ch==0Dh
		add		esi,5
		call	AddName
		jmp		PutEx
	.endif
  @@:
	cmp		eax,'URTS'
	jne		@f
	mov		cx,word ptr [esi+4]
	and		cl,5Fh
	cmp		cl,'C'
	jne		@f
	.if ch==';' || ch==09h || ch==' ' || ch==0Dh
		add		esi,5
		call	AddName
		jmp		PutEx
	.endif
  @@:
	cmp		eax,'URTS'
	jne		@f
	mov		cx,word ptr [esi+4]
	and		cx,5F5Fh
	cmp		cx,'TC'
	jne		@f
	mov		ch,byte ptr [esi+6]
	.if ch==';' || ch==09h || ch==' ' || ch==0Dh
		add		esi,6
		call	AddName
		jmp		PutEx
	.endif
  @@:
	cmp		eax,'MDTS'
	jne		@f
	mov		ecx,dword ptr [esi+4]
	cmp		ecx,'OHTE'
	jne		@f
	mov		cx,word ptr [esi+8]
	and		cl,5Fh
	cmp		cl,'D'
	jne		@f
	.if ch==09h || ch==' '
		add		esi,9
		jmp		PutItem
	.endif
  @@:
	cmp		eax,'DNE'
	je		PutEx
  @@:
	.if byte ptr [esi+2]==VK_SPACE || byte ptr [esi+2]==VK_TAB
		mov		ax,word ptr [esi]
		and		ax,5F5Fh
		.if ax=='BD' || ax=='WD' || ax=='DD' || ax=='QD' || ax=='TD'
			jmp		PutEx
		.endif
	.endif
	.if edi!=lpBuff
		mov		al,','
		stosb
	.endif
	push	esi
	lea		esi,buffer
	invoke CopyWord
	pop		esi
	invoke CopyWord
	mov		edx,esi
	.if nAsm==nBCET
		invoke SpcSkip
		mov		eax,[esi]
		and eax,0FF5F5Fh
		.if eax==' SA'
			add		esi,3
			invoke SpcSkip
			mov		edx,edi
			mov		al,':'
			stosb
			invoke CopyWord
			mov		byte ptr [edi],0
			push	edx
			inc		edx
			invoke IsTypeStruct,edx
			pop		edx
			.if !eax
				mov		edi,edx
			.endif
		.endif
		jmp		PutEx
	.elseif nAsm==nFASM
		invoke SpcSkip
		mov		edx,edi
		mov		al,':'
		stosb
		invoke CopyWord
		mov		byte ptr [edi],0
		push	edx
		inc		edx
		invoke IsTypeStruct,edx
		pop		edx
		.if !eax
			mov		edi,edx
			mov		byte ptr [edi],0
		.endif
		jmp		PutEx
	.endif
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,0Dh
	je		PutEx
	cmp		al,';'
	je		PutEx
	or		al,al
	je		PutEx
	cmp		al,'?'
	je		PutEx1
	.if al>='0' && al<='9'
		jmp		PutEx1
	.endif
	cmp		al,'<'
	jne		@b
  PutEx1:
	mov		al,':'
	stosb
	mov		esi,edx
	invoke SpcSkip
	invoke CopyWord
  PutEx:
	call	SkpLn
	retn

SkpWrd:
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	or		al,al
	je		@f
	cmp		al,VK_SPACE
	je		@f
	cmp		al,VK_TAB
	je		@f
	cmp		al,VK_RETURN
	jne		@b
  @@:
	retn

SkpLn:
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	or		al,al
	je		@f
	cmp		al,VK_RETURN
	jne		@b
	inc		esi
  @@:
	mov		al,[esi]
	cmp		al,0Ah
	jne		@f
	inc		esi
  @@:
	retn

FindStructData endp

WhatIsIt proc uses ebx esi,lpWord1:DWORD,len1:DWORD,lpWord2:DWORD,len2:DWORD,fCode:DWORD

	mov		esi,hCodeDefs
  Nxt:
	mov		eax,[esi].PARSEDEF.rpNext
	.if eax
		.if fCode && ([esi].PARSEDEF.nType==TPE_STDATA || [esi].PARSEDEF.nType==TPE_STCONST)
			mov		eax,[esi].PARSEDEF.rpNext
			lea		esi,[esi+eax]
			jmp		Nxt
		.elseif !fCode && [esi].PARSEDEF.nType==TPE_STLOCAL
			mov		eax,[esi].PARSEDEF.rpNext
			lea		esi,[esi+eax]
			jmp		Nxt
		.endif
		mov		eax,[esi].PARSEDEF.nName
		.if eax==NME_NONE
			mov		ecx,len1
			mov		ebx,lpWord1
			mov		edx,lpWord2
			.if byte ptr [edx]==':' && !len2==1 && [esi].PARSEDEF.nType==TPE_STLABEL
				xor		eax,eax
			.else
				call	TstWrd
				.if !eax && [esi].PARSEDEF.nLen2
					mov		ecx,len2
					mov		ebx,lpWord2
					call	TstWrd2
				.endif
			.endif
		.elseif eax==NME_START
			mov		ecx,len2
			mov		ebx,lpWord2
			call	TstWrd
		.elseif eax==NME_STARTOPT
			mov		ecx,len2
			mov		ebx,lpWord2
			call	TstWrd
			.if eax
				mov		ecx,len1
				mov		ebx,lpWord1
				call	TstWrd
			.endif
		.elseif eax==NME_END
			mov		ecx,len1
			mov		ebx,lpWord1
			call	TstWrd
		.elseif eax==NME_ENDOPT
			mov		ecx,len1
			mov		ebx,lpWord1
			call	TstWrd
		.endif
		.if !eax
			mov		eax,esi
		.else
			mov		eax,[esi].PARSEDEF.rpNext
			lea		esi,[esi+eax]
			jmp		Nxt
		.endif
	.endif
	ret

TstWrd:
	xor		eax,eax
	inc		eax
	.if ecx==[esi].PARSEDEF.nLen
		.while ecx
			dec		ecx
			mov		al,[ebx+ecx]
			.if al>='a' && al<='z'
				and		al,5Fh
			.endif
			sub		al,[esi+ecx+sizeof PARSEDEF]
			.break .if !ZERO?
		.endw
	.endif
	retn

TstWrd2:
	xor		eax,eax
	inc		eax
	.if ecx==[esi].PARSEDEF.nLen2
		mov		edx,[esi].PARSEDEF.nLen
		inc		edx
		.while ecx
			dec		ecx
			mov		al,[ebx+ecx]
			.if al>='a' && al<='z'
				and		al,5Fh
			.endif
			add		ecx,edx
			sub		al,[esi+ecx+sizeof PARSEDEF]
			.break .if !ZERO?
			sub		ecx,edx
		.endw
	.endif
	retn

WhatIsIt endp

CpyWrd proc uses esi edi,lpDest,lpSrc,len

	mov		esi,lpSrc
	mov		edi,lpDest
	mov		ecx,len
	rep movsb
	mov		byte ptr [edi],0
	ret

CpyWrd endp

DestroyCmntBlock proc uses esi,lpMem:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	fbyte:DWORD

	mov		fbyte,0
	mov		esi,lpMem
	invoke strcpy,addr buffer,offset CmntBlockStart
	invoke strlen,addr buffer
	.if eax
		dec		eax
		.if byte ptr buffer[eax]=='+'
			mov		byte ptr buffer[eax],0
			.if byte ptr buffer[eax-1]==' '
				dec		eax
				mov		byte ptr buffer[eax],0
			.endif
			mov		fbyte,eax
		.endif
	  @@:
		invoke SearchMem,esi,addr buffer,FALSE,fbyte,FALSE
		.if eax
			mov		esi,eax
			mov		ecx,dword ptr szCmntChar
			dec		eax
			.while eax>lpMem
				.break .if byte ptr [eax-1]==0Dh || byte ptr [eax-1]==0Ah
				.if byte ptr [eax]=='"' || byte ptr [eax]=="'" || (!ch && cl==byte ptr [eax]) || (ch && cx==word ptr [eax])
					inc		esi
					jmp		@b
				.endif
				dec		eax
			.endw
			.if fbyte
				add		esi,fbyte
				.while byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB
					inc		esi
				.endw
				mov		ah,[esi]
				.if ah!=0Dh && ah!=0Ah
					mov		byte ptr [esi],' '
				.endif
				.while ah!=byte ptr [esi] && byte ptr [esi+1]
					mov		al,[esi]
					.if al!=0Dh && al!=0Ah
						mov		byte ptr [esi],' '
					.endif
					inc		esi
				.endw
				mov		al,[esi]
				.if al!=0Dh && al!=0Ah
					mov		byte ptr [esi],' '
					inc		esi
				.endif
				jmp		@b
			.else
				invoke SearchMem,esi,offset CmntBlockEnd,FALSE,FALSE,FALSE
				.if eax
					mov		edx,eax
					.if CmntBlockEnd[1]
						inc		edx
					.endif
					.while esi<=edx
						mov		al,[esi]
						.if al!=0Dh && al!=0Ah
							mov		byte ptr [esi],' '
						.endif
						inc		esi
					.endw
					jmp		@b
				.endif
			.endif
		.endif
	.endif
	ret

DestroyCmntBlock endp

IsWord proc uses esi edi,lpWord1:DWORD,lpWord2:DWORD

	mov		edi,lpWord2
	call	TestWord
	je		Ex
	xor		eax,eax
	ret
  Ex:
	mov		eax,ecx
	ret

TestWord:
	mov		esi,lpWord1
	xor		ecx,ecx
  @@:
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	.if ah>='A' && ah<='Z'
		or		ah,20h
	.endif
	.if al>='A' && al<='Z'
		or		al,20h
	.elseif al==VK_RETURN || al==VK_SPACE || al==VK_TAB
		xor		al,al
	.endif
	cmp		al,ah
	jne		@f
	inc		ecx
	or		al,al
	jne		@b
  @@:
	retn

IsWord endp

IsWordVar proc lpWord:DWORD

	invoke IsWord,lpWord,offset szVar
	ret

IsWordVar endp

IsWordConst proc lpWord:DWORD

	invoke IsWord,lpWord,offset szConst
	ret

IsWordConst endp

IsWordBegin proc lpWord:DWORD

	invoke IsWord,lpWord,offset szBegin
	ret

IsWordBegin endp

IsWordCase proc lpWord:DWORD

	invoke IsWord,lpWord,offset szCase
	ret

IsWordCase endp

IsWordEnd proc uses esi edi,lpWord:DWORD

	mov		edi,offset szEnd
  @@:
	call	TestWord
	je		Ex
	xor		eax,eax
	ret
  Ex:
	mov		eax,ecx
	ret

TestWord:
	mov		esi,lpWord
	xor		ecx,ecx
  @@:
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	.if ah>='A' && ah<='Z'
		or		ah,20h
	.endif
	.if al>='A' && al<='Z'
		or		al,20h
	.elseif al==';'
		xor		al,al
	.endif
	cmp		al,ah
	jne		@f
	inc		ecx
	or		al,al
	jne		@b
  @@:
	retn

IsWordEnd endp

GetDup proc uses esi edi
	LOCAL	lpType:DWORD
	LOCAL	lpDup:DWORD

	mov		edi,offset prnbuff
	lea		esi,[edi+2048]
	call	CopyData
	; Copy name
	.while byte ptr [esi]
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	inc		esi
	call	IsDup
	.if edx
		; Copy dup
		mov		byte ptr [edi],'['
		inc		edi
		push	esi
		mov		esi,lpDup
		.while byte ptr [esi]!=' '
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		pop		esi
		mov		byte ptr [edi],']'
		inc		edi
	.else
		call	IsArray
		.if edx>1
			mov		byte ptr [edi],'['
			inc		edi
			invoke BinToDec,edx,edi
			invoke strlen,edi
			lea		edi,[edi+eax]
			mov		byte ptr [edi],']'
			inc		edi
		.endif
	.endif
	; Copy datatype
	mov		byte ptr [edi],':'
	inc		edi
	push	esi
	mov		esi,lpType
	.while byte ptr [esi]!=' '
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		byte ptr [edi],0
	inc		edi
	pop		esi
	; Copy the rest
	.while byte ptr [esi]
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		dword ptr [edi],0
	ret

CopyData:
	xor		ecx,ecx
	.while ecx<1024/4
		mov		eax,[edi+ecx*4]
		mov		[esi+ecx*4],eax
		inc		ecx
	.endw
	retn

IsArray:
	xor		edx,edx
	push	esi
	mov		esi,lpDup
	.while TRUE
		mov		al,[esi]
		.if al=='"' || al=="'"
			call	GetStr
		.elseif al=='<'
			mov		ah,'>'
			call	SkipIt
			inc		edx
		.elseif al==','
			inc		esi
		.elseif al
			inc		edx
			.while byte ptr [esi]!=',' && byte ptr [esi]
				inc		esi
			.endw
		.else
			.break
		.endif
	.endw
	pop		esi
	retn

SkipIt:
	xor		ecx,ecx
	.while TRUE
		.if al==[esi]
			inc		ecx
			inc		esi
		.elseif ah==[esi]
			dec		ecx
			inc		esi
		.elseif byte ptr [esi]=='"' || byte ptr [esi]=="'"
			push	eax
			push	edx
			mov		al,[esi]
			call	GetStr
			pop		edx
			pop		eax
		.elseif !byte ptr [esi]
			xor		ecx,ecx
		.else
			inc		esi
		.endif
		.break .if !ecx
	.endw
	.while al!=[esi] && byte ptr [esi]
		inc		edx
		inc		esi
	.endw
	.if al==[esi]
		inc		esi
	.endif
	retn

GetStr:
	inc		esi
	.while TRUE
		.if word ptr [esi]=='""' || word ptr [esi]=="''"
			inc		edx
			inc		esi
		.elseif al==[esi]
			.break
		.elseif byte ptr [esi]
			inc		edx
		.else
			.break
		.endif
		inc		esi
	.endw
	.if al==[esi]
		inc		esi
	.endif
	retn

IsDup:
	xor		edx,edx
	push	esi
	mov		lpType,esi
	; Skip type
	.while byte ptr [esi]!=' ' && byte ptr [esi]
		inc		esi
	.endw
	.if byte ptr [esi]==' '
		inc		esi
		mov		lpDup,esi
		; Skip dup
		.while byte ptr [esi]!=' ' && byte ptr [esi]
			inc		esi
		.endw
		.if byte ptr [esi]==' '
			inc		esi
			mov		eax,[esi]
			and		eax,5F5F5fh
			.if eax=='PUD'
				inc		edx
			.endif
		.endif
	.endif
	pop		esi
	retn

GetDup endp

ParseFile proc uses ebx esi edi,iNbr:DWORD
	LOCAL	lpWord1:DWORD
	LOCAL	len1:DWORD
	LOCAL	lpWord2:DWORD
	LOCAL	len2:DWORD
	LOCAL	lptype:DWORD
	LOCAL	lentype:DWORD
	LOCAL	lastend:DWORD
	LOCAL	nlookahead:DWORD
	LOCAL	nNest:DWORD

	.if hCodeDefs
		mov		esi,hSrcMem
		invoke DllProc,hWnd,AIM_PREPARSE,iNbr,esi,RAM_PREPARSE
		.if eax
			xor		eax,eax
			ret
		.endif
		.if hParseDll
			invoke GetProcAddress,hParseDll,offset szParseFile
			.if eax
				push	lpCharTab
				push	offset AddWordToWordList
				push	esi
				push	iNbr
				call	eax
			.endif
		.else
			invoke DestroyCmntBlock,esi
			.while byte ptr [esi]
			  NxtParse:
				call	GetWrd
				.if ecx
					mov		lpWord1,esi
					mov		len1,ecx
					lea		esi,[esi+ecx]
					call	GetWrd
					.if ecx
						mov		lpWord2,esi
						mov		len2,ecx
						lea		esi,[esi+ecx]
						invoke WhatIsIt,lpWord1,len1,lpWord2,len2,FALSE
						.if eax
							mov		ebx,eax
							mov		eax,[ebx].PARSEDEF.nType
							.if eax==TPE_STCODE
								call	ParseCode
							.elseif eax==TPE_STCONST
								call	ParseConst
							.elseif eax==TPE_STDATA
								.if nAsm==nBCET
									call	ParseFBData
								.else
									call	ParseData
								.endif
							.elseif eax==TPE_STMACRO
								call	ParseMacro
							.elseif eax==TPE_STSTRUCT
								call	ParseStruct
							.elseif eax==TPE_STLABEL
								call	ParseLabel
							.elseif eax==TPE_ST0
								mov		eax,10
								mov		edx,TPE_EN0
								call	ParseST
							.elseif eax==TPE_ST1
								mov		eax,11
								mov		edx,TPE_EN1
								call	ParseST
							.elseif eax==TPE_ST2
								mov		eax,12
								mov		edx,TPE_EN2
								call	ParseST
							.elseif eax==TPE_ST3
								mov		eax,13
								mov		edx,TPE_EN3
								call	ParseST
							.endif
						.else
							mov		eax,nAsm
							.if eax==nMASM || eax==nTASM
								mov		edx,esi
							  @@:
								mov		al,[edx]
								.if al==VK_SPACE || al==VK_TAB
									inc		edx
									jmp		@b
								.elseif al!=',' && al!=VK_RETURN
									call	ParseUnknown
								.endif
							.elseif nAsm!=nFP
								call	ParseUnknown
							.endif
						.endif
					.else
						.if nAsm==nFP
							mov		len2,0
							invoke WhatIsIt,lpWord1,len1,lpWord2,len2,FALSE
							.if eax
								.if [eax].PARSEDEF.nType==TPE_STCONST
									call 	ParseFPConst
									jmp		NxtParse
								.elseif [eax].PARSEDEF.nType==TPE_STDATA
									call 	ParseFPData
									jmp		NxtParse
								.endif
							.endif
						.endif
					.endif
				.endif
				call	SkpLn
			.endw
		.endif
		invoke DllProc,hWnd,AIM_PARSEDONE,iNbr,hSrcMem,RAM_PARSEDONE
	.endif
	ret

ParseST:
	push	edx
	push	eax
	mov		edi,offset prnbuff
	mov		eax,[ebx].PARSEDEF.nName
	.if eax==NME_START
		invoke CpyWrd,edi,lpWord1,len1
		mov		eax,len1
		lea		edi,[edi+eax]
	.elseif eax==NME_END
		invoke CpyWrd,edi,lpWord2,len2
		mov		eax,len2
		lea		edi,[edi+eax]
	.endif
	mov		dword ptr [edi],0
	pop		eax
	push	eax
	.if eax==10
		call SkpSpc
		.if byte ptr [esi]==','
			inc		esi
		.endif
		invoke FindProcArgs,edi,esi
		mov		byte ptr [edi],0
		inc		edi
	.elseif eax==11
		call SkpSpc
		.if byte ptr [esi]==','
			inc		esi
		.endif
		inc		edi
		invoke ParseLineDef,esi,edi
	.endif
	pop		eax
	invoke AddWordToWordList,eax,iNbr,offset prnbuff,2
	pop		edi
  @@:
	call	SkpLn
	call	GetWrd
	.if ecx
		mov		lpWord1,esi
		mov		len1,ecx
		lea		esi,[esi+ecx]
		call	GetWrd
		.if ecx
			mov		lpWord2,esi
			mov		len2,ecx
			lea		esi,[esi+ecx]
			invoke WhatIsIt,lpWord1,len1,lpWord2,len2,FALSE
			.if eax
				mov		eax,[eax].PARSEDEF.nType
				.if eax==edi
					retn
				.endif
			.endif
		.endif
		jmp		@b
	.endif
	retn

ParseFBData:
	mov		edi,offset prnbuff
	mov		eax,lpWord2
	mov		edx,[eax]
	and		edx,5F5F5F5Fh
	.if len2==6
		.if edx=='RAHS'
			movzx	edx,word ptr [eax+4]
			and		edx,5F5Fh
			.if edx=='DE'
				call	GetWrd
				mov		lpWord2,esi
				mov		len2,ecx
				lea		esi,[esi+ecx]
				jmp		ParseFBData
			.endif
		.endif
	.elseif len2==2
		movzx	edx,dx
		.if edx=='SA'
			; List of vars, get type
			call	GetWrd
			.if ecx
				mov		lptype,esi
				mov		lentype,ecx
				lea		esi,[esi+ecx]
				.while byte ptr [esi]!=0Dh
					call GetWrd
					.if ecx
						; var name
						mov		lpWord2,esi
						mov		len2,ecx
						lea		esi,[esi+ecx]
						invoke CpyWrd,edi,lpWord2,len2
						mov		eax,len2
						lea		edi,[edi+eax]
						call	GetWrd
						.if al=='('
							; array
							xor		edx,edx
							.while TRUE
								mov		eax,[esi]
								inc		esi
								.if al=='('
									mov		byte ptr [edi],'['
									inc		edi
									inc		edx
								.elseif al==')'
									mov		byte ptr [edi],']'
									inc		edi
									dec		edx
									.break .if !edx
								.elseif eax==' ot ' || eax==' oT ' || eax==' OT ' || eax==' Ot '
									mov		word ptr [edi],'..'
									add		edi,2
									add		esi,3
								.elseif al==','
									mov		byte ptr [edi],';'
									inc		edi
								.elseif al!=VK_SPACE && al!=VK_TAB
									mov		[edi],al
									inc		edi
								.elseif al==0Dh
									.break
								.endif
							.endw
						.elseif al==','
							inc		esi
						.endif
						mov		byte ptr [edi],':'
						inc		edi
						invoke CpyWrd,edi,lptype,lentype
						mov		eax,lentype
						lea		edi,[edi+eax]
						mov		word ptr [edi],0
						invoke AddWordToWordList,'d',iNbr,offset prnbuff,2
						mov		edi,offset prnbuff
					.else
						inc		esi
					.endif
				.endw
			.endif
		.endif
	.endif
  @@:
	invoke CpyWrd,edi,lpWord2,len2
	mov		eax,len2
	lea		edi,[edi+eax]
  NxtFB:
	call	GetWrd
	.if !ecx
		.if al=='('
			; array
			xor		edx,edx
			.while TRUE
				mov		eax,[esi]
				inc		esi
				.if al=='('
					mov		byte ptr [edi],'['
					inc		edi
					inc		edx
				.elseif al==')'
					mov		byte ptr [edi],']'
					inc		edi
					dec		edx
					.break .if !edx
				.elseif eax==' ot ' || eax==' oT ' || eax==' OT ' || eax==' Ot '
					mov		word ptr [edi],'..'
					add		edi,2
					add		esi,3
				.elseif al==','
					mov		byte ptr [edi],';'
					inc		edi
				.elseif al!=VK_SPACE && al!=VK_TAB
					mov		[edi],al
					inc		edi
				.elseif al==0Dh
					.break
				.endif
			.endw
			jmp		NxtFB
		.endif
	.elseif ecx==2
		movzx	eax,word ptr [esi]
		and		eax,5F5Fh
		.if eax=='SA'
			add		esi,2
			call	GetWrd
			mov		lptype,esi
			mov		lentype,ecx
			lea		esi,[esi+ecx]
			mov		byte ptr [edi],':'
			inc		edi
			invoke CpyWrd,edi,lptype,lentype
			mov		eax,lentype
			lea		edi,[edi+eax]
			mov		word ptr [edi],0
			invoke AddWordToWordList,'d',iNbr,offset prnbuff,2
			mov		edi,offset prnbuff
			call	GetWrd
			.if al==','
				inc		esi
				call	GetWrd
				mov		lpWord2,esi
				mov		len2,ecx
				lea		esi,[esi+ecx]
				jmp		@b
			.endif
		.endif
	.endif
	retn

ParseFPData:
	call	SkpLn
  NxtFPVar:
	call	GetWrd
	.if ecx
		mov		lpWord1,esi
		mov		len1,ecx
		lea		esi,[esi+ecx]
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		.if byte ptr [esi]==':'
			inc		esi
			call	GetWrd
			.if ecx
				.if ecx==5
					mov		eax,dword ptr [esi]
					mov		edx,dword ptr [esi+4]
					and		eax,5F5F5F5Fh
					and		edx,5Fh
					.if eax=='ARRA' && edx=='Y'
						lea		esi,[esi+ecx]
						.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
							inc		esi
						.endw
						mov		edi,offset prnbuff
						invoke CpyWrd,edi,lpWord1,len1
						mov		eax,len1
						lea		edi,[edi+eax]
						.if byte ptr [esi]=='['
							.while byte ptr [esi] && byte ptr [esi]!=0Dh
								mov		al,[esi]
								inc		esi
								.if al==','
									mov		byte ptr [edi],';'
									inc		edi
								.elseif al!=VK_SPACE && al!=VK_TAB
									mov		[edi],al
									inc		edi
								.endif
								.break .if al==']'
							.endw
							; Skip Of
							call	GetWrd
							lea		esi,[esi+ecx]
							call	GetWrd
							mov		lpWord2,esi
							mov		len2,ecx
							mov		byte ptr [edi],':'
							inc		edi
							invoke CpyWrd,edi,lpWord2,len2
							mov		eax,len2
							lea		edi,[edi+eax]
							mov		byte ptr [edi],0
							inc		edi
							invoke CpyWrd,edi,lpWord2,len2
							invoke AddWordToWordList,'d',iNbr,offset prnbuff,2
						.endif
						jmp		ParseFPData
					.endif
				.endif
				mov		lpWord2,esi
				mov		len2,ecx
				lea		esi,[esi+ecx]
				mov		edi,offset prnbuff
				invoke CpyWrd,edi,lpWord1,len1
				mov		eax,len1
				lea		edi,[edi+eax]
				mov		byte ptr [edi],':'
				inc		edi
				invoke CpyWrd,edi,lpWord2,len2
				mov		eax,len2
				lea		edi,[edi+eax]
				mov		byte ptr [edi],0
				inc		edi
				invoke CpyWrd,edi,lpWord2,len2
				invoke AddWordToWordList,'d',iNbr,offset prnbuff,2
				jmp		ParseFPData
			.endif
		.elseif byte ptr [esi]==','
			inc		esi
			push	esi
			.while TRUE
				.if byte ptr [esi]==':'
					inc		esi
					call	GetWrd
					.if ecx
						mov		lpWord2,esi
						mov		len2,ecx
						lea		esi,[esi+ecx]
						mov		edi,offset prnbuff
						invoke CpyWrd,edi,lpWord1,len1
						mov		eax,len1
						lea		edi,[edi+eax]
						mov		byte ptr [edi],':'
						inc		edi
						invoke CpyWrd,edi,lpWord2,len2
						mov		eax,len2
						lea		edi,[edi+eax]
						mov		byte ptr [edi],0
						inc		edi
						invoke CpyWrd,edi,lpWord2,len2
						pop		esi
						invoke AddWordToWordList,'d',iNbr,offset prnbuff,2
						jmp		NxtFPVar
					.endif
				.elseif !byte ptr [esi]
					.break
				.endif
				inc		esi
			.endw
			pop		esi
		.endif
		mov		esi,lpWord1
	.else
		.if byte ptr [esi]==VK_RETURN || word ptr [esi]=='//'
			jmp		ParseFPData
		.endif
	.endif
	retn

ParseFPConst:
	call	SkpLn
  NxtFPConst:
	call	GetWrd
	.if ecx
		mov		lpWord1,esi
		mov		len1,ecx
		lea		esi,[esi+ecx]
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		.if byte ptr [esi]=='='
			inc		esi
			call	GetWrd
			.if ecx || byte ptr [esi]=="'"
				.if byte ptr [esi]=="'"
					inc		ecx
					mov		al,[esi+ecx]
					.while al!="'" && al!=VK_RETURN && al
						inc		ecx
						mov		al,[esi+ecx]
					.endw
					.if al=="'"
						inc		ecx
					.endif
				.endif
				mov		lpWord2,esi
				mov		len2,ecx
				lea		esi,[esi+ecx]
				mov		edi,offset prnbuff
				invoke CpyWrd,edi,lpWord1,len1
				mov		eax,len1
				lea		edi,[edi+eax]
				mov		byte ptr [edi],0
				inc		edi
				invoke CpyWrd,edi,lpWord2,len2
				invoke AddWordToWordList,'c',iNbr,offset prnbuff,2
				jmp		ParseFPConst
			.endif
		.elseif byte ptr [esi]==','
			inc		esi
			push	esi
			.while TRUE
				.if byte ptr [esi]=='='
					inc		esi
					call	GetWrd
					.if ecx
						mov		lpWord2,esi
						mov		len2,ecx
						lea		esi,[esi+ecx]
						mov		edi,offset prnbuff
						invoke CpyWrd,edi,lpWord1,len1
						mov		eax,len1
						lea		edi,[edi+eax]
						mov		byte ptr [edi],0
						inc		edi
						invoke CpyWrd,edi,lpWord2,len2
						pop		esi
						invoke AddWordToWordList,'c',iNbr,offset prnbuff,2
						jmp		NxtFPConst
					.endif
				.elseif !byte ptr [esi]
					.break
				.endif
				inc		esi
			.endw
			pop		esi
		.endif
		mov		esi,lpWord1
	.else
		.if byte ptr [esi]==VK_RETURN || word ptr [esi]=='//'
			jmp		ParseFPConst
		.endif
	.endif
	retn

ParseCode:
	mov		lptype,0
	mov		edi,offset prnbuff
	mov		eax,[ebx].PARSEDEF.nName
	.if eax==NME_START
		invoke CpyWrd,edi,lpWord1,len1
		mov		eax,len1
		lea		edi,[edi+eax]
		mov		dword ptr [edi],0
	.elseif eax==NME_END
		.if !len2
			retn
		.endif
		invoke CpyWrd,edi,lpWord2,len2
		mov		eax,len2
		lea		edi,[edi+eax]
		mov		dword ptr [edi],0
	.endif
	invoke FindProcArgs,edi,esi
	mov		byte ptr [edi],0
	inc		edi
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	mov		dword ptr [edi],0
	mov		edx,[ebx].PARSEDEF.rpEnd
	add		edx,ebx
	mov		eax,[edx+sizeof PARSEDEF]
	.if eax!='}C{'
		mov		nNest,0
	  Nxt:
		call	SkpLn
		call	GetWrd
		mov		lpWord1,esi
		mov		len1,ecx
		lea		esi,[esi+ecx]
		.if nAsm==nFP && ecx
			invoke IsWordVar,lpWord1
			.if eax
			  NxtVar:
				call	SkpLn
			  NxtVar1:
				call	GetWrd
				.if ecx
					mov		lpWord1,esi
					mov		len1,ecx
					lea		esi,[esi+ecx]
					.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
						inc		esi
					.endw
					.if byte ptr [esi]==':'
						inc		esi
						call	GetWrd
						.if ecx
							.if ecx==5
								mov		eax,dword ptr [esi]
								mov		edx,dword ptr [esi+4]
								and		eax,5F5F5F5Fh
								and		edx,5Fh
								.if eax=='ARRA' && edx=='Y'
									lea		esi,[esi+ecx]
									.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
										inc		esi
									.endw
									.if byte ptr [edi]==','
										inc		edi
									.endif
									invoke CpyWrd,edi,lpWord1,len1
									mov		eax,len1
									lea		edi,[edi+eax]
									.if byte ptr [esi]=='['
										.while byte ptr [esi] && byte ptr [esi]!=0Dh
											mov		al,[esi]
											mov		[edi],al
											inc		esi
											inc		edi
											.break .if al==']'
										.endw
										; Skip Of
										call	GetWrd
										lea		esi,[esi+ecx]
										call	GetWrd
										mov		lpWord2,esi
										mov		len2,ecx
										mov		byte ptr [edi],':'
										inc		edi
										invoke CpyWrd,edi,lpWord2,len2
										mov		eax,len2
										lea		edi,[edi+eax]
										mov		byte ptr [edi],','
										inc		edi
									.endif
									jmp		NxtVar
								.endif
							.endif
							mov		lpWord2,esi
							mov		len2,ecx
							lea		esi,[esi+ecx]
							.if byte ptr [edi]==','
								inc		edi
							.endif
							invoke CpyWrd,edi,lpWord1,len1
							mov		eax,len1
							lea		edi,[edi+eax]
							mov		byte ptr [edi],':'
							inc		edi
							invoke CpyWrd,edi,lpWord2,len2
							mov		eax,len2
							lea		edi,[edi+eax]
							mov		byte ptr [edi],','
							jmp		NxtVar
						.endif
					.elseif byte ptr [esi]==','
						inc		esi
						push	esi
						.while TRUE
							.if byte ptr [esi]==':'
								inc		esi
								call	GetWrd
								.if ecx
									mov		lpWord2,esi
									mov		len2,ecx
									lea		esi,[esi+ecx]
									.if byte ptr [edi]==','
										inc		edi
									.endif
									invoke CpyWrd,edi,lpWord1,len1
									mov		eax,len1
									lea		edi,[edi+eax]
									mov		byte ptr [edi],':'
									inc		edi
									invoke CpyWrd,edi,lpWord2,len2
									mov		eax,len2
									lea		edi,[edi+eax]
									mov		byte ptr [edi],','
									pop		esi
									jmp		NxtVar1
								.endif
							.elseif !byte ptr [esi]
								.break
							.endif
							inc		esi
						.endw
						pop		esi
						jmp		ExCode
					.endif
				.elseif byte ptr [esi]==VK_RETURN || word ptr [esi]=='//'
					jmp		NxtVar
				.endif
			.else
				invoke IsWordConst,lpWord1
				.if eax
				  NxtConst:
					call	SkpLn
				  NxtConst1:
					call	GetWrd
					.if ecx
						mov		lpWord1,esi
						mov		len1,ecx
						lea		esi,[esi+ecx]
						.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
							inc		esi
						.endw
						.if byte ptr [esi]==':' || byte ptr [esi]=='='
							inc		esi
							.if byte ptr [edi]==','
								inc		edi
							.endif
							invoke CpyWrd,edi,lpWord1,len1
							mov		eax,len1
							lea		edi,[edi+eax]
							mov		byte ptr [edi],','
							jmp		NxtConst
						.endif
					.elseif byte ptr [esi]==VK_RETURN || word ptr [esi]=='//'
						jmp		NxtConst
					.endif
				.endif
			.endif
			invoke IsWordBegin,lpWord1
			.if eax
				inc		nNest
				jmp		Nxt
			.else
				invoke IsWordCase,lpWord1
				.if eax
					inc		nNest
					jmp		Nxt
				.else
					invoke IsWordEnd,lpWord1
					.if eax
						dec		nNest
						.if !nNest
							jmp		ExCode
						.endif
						jmp		Nxt
					.endif
				.endif
			.endif
		.endif
		call	GetWrd
		mov		lpWord2,esi
		mov		len2,ecx
		lea		esi,[esi+ecx]
		invoke WhatIsIt,lpWord1,len1,lpWord2,len2,TRUE
		.if eax
			mov		edx,[eax].PARSEDEF.nType
			.if edx!=TPE_ENCODE && byte ptr [esi]
				.if edx==TPE_STCODE
					mov		byte ptr [edi],0
					invoke AddWordToWordList,'p',iNbr,offset prnbuff,3
					jmp		ParseCode
				.elseif edx==TPE_STLOCAL || edx==TPE_STLABEL
					mov		eax,[eax].PARSEDEF.nName
					.if eax==NME_START
						.if byte ptr [edi]==','
							inc		edi
						.endif
						invoke CpyWrd,edi,lpWord1,len1
						mov		eax,len1
						lea		edi,[edi+eax]
						mov		byte ptr [edi],','
					.elseif eax==NME_END
					  @@:
						.if len2==2 && nAsm==nBCET
							mov		eax,lpWord2
							mov		eax,[eax]
							and		eax,0FF5F5Fh
							.if eax==' SA'
								call	GetWrd
								mov		lptype,esi
								mov		lentype,ecx
								lea		esi,[esi+ecx]
								call	GetWrd
								mov		lpWord2,esi
								mov		len2,ecx
								lea		esi,[esi+ecx]
							.endif
						.endif
						.if byte ptr [edi]==','
							inc		edi
						.endif
						invoke CpyWrd,edi,lpWord2,len2
						mov		eax,len2
						lea		edi,[edi+eax]
						.if nAsm==nBCET
							call	GetWrd
							.if !ecx
								.if byte ptr [esi]=='('
									mov		byte ptr [edi],'['
									inc		edi
									.while byte ptr [esi] && byte ptr [esi-1]!=')'
										mov		al,[esi]
										.if al!=VK_SPACE && al!=VK_TAB && al!='(' && al!=')'
											mov		[edi],al
											inc		edi
										.endif
										inc		esi
									.endw
									mov		byte ptr [edi],']'
									inc		edi
								.endif
							.endif
							.if !lptype
							  NxtLocalFB:
								call	GetWrd
								.if ecx==2
									mov		eax,[esi]
									and		eax,5F5Fh
									.if eax=='SA'
										lea		esi,[esi+ecx]
										call	GetWrd
										mov		lptype,esi
										mov		lentype,ecx
										lea		esi,[esi+ecx]
									.endif
								.elseif !ecx
									.if al=='('
										; array
										xor		edx,edx
										.while TRUE
											mov		eax,[esi]
											inc		esi
											.if al=='('
												mov		byte ptr [edi],'['
												inc		edi
												inc		edx
											.elseif al==')'
												mov		byte ptr [edi],']'
												inc		edi
												dec		edx
												.break .if !edx
											.elseif eax==' ot ' || eax==' oT ' || eax==' OT ' || eax==' Ot '
												mov		word ptr [edi],'..'
												add		edi,2
												add		esi,3
											.elseif al==','
												mov		byte ptr [edi],';'
												inc		edi
											.elseif al!=VK_SPACE && al!=VK_TAB
												mov		[edi],al
												inc		edi
											.elseif al==0Dh
												.break
											.endif
										.endw
										jmp		NxtLocalFB
									.endif
								.endif
							.endif
							.if lptype
								mov		byte ptr [edi],':'
								inc		edi
								invoke CpyWrd,edi,lptype,lentype
								mov		eax,lentype
								lea		edi,[edi+eax]
							.endif
						.elseif nAsm==nMASM
						  NxtL:
							call	GetWrd
							.if byte ptr [esi]==':'
								inc		esi
								call	GetWrd
								mov		lpWord1,esi
								mov		len1,ecx
								lea		esi,[esi+ecx]
								.if ecx
									mov		byte ptr [edi],':'
									inc		edi
									invoke CpyWrd,edi,lpWord1,len1
									mov		eax,len1
									lea		edi,[edi+eax]
								.endif
							.elseif byte ptr [esi]=='['
								xor		ecx,ecx
								.while byte ptr [esi+ecx]!=']' && ecx<16
									inc		ecx
								.endw
								.if ecx<16
									inc		ecx
									mov		lpWord1,esi
									mov		len1,ecx
									lea		esi,[esi+ecx]
									mov		edx,lpWord1
									xor		ecx,ecx
									.while ecx<len1
										mov		al,[edx+ecx]
										.if al!=' '
											mov		[edi],al
											inc		edi
										.endif
										inc		ecx
									.endw
									jmp		NxtL
								.endif
							.endif
						.endif
						mov		byte ptr [edi],','
						call	SkpLocal
						.if al==','
							inc		esi
							call	GetWrd
							mov		lpWord2,esi
							mov		len2,ecx
							lea		esi,[esi+ecx]
							jmp		@b
						.endif
					.endif
				.endif
				mov		lptype,0
				jmp		Nxt
			.endif
		.elseif byte ptr [esi]
			jmp		Nxt
		.endif
	.endif
ExCode:
	mov		byte ptr [edi],0
	invoke AddWordToWordList,'p',iNbr,offset prnbuff,3
	retn

ParseConst:
	mov		edi,offset prnbuff
	mov		eax,[ebx].PARSEDEF.nName
	.if eax==NME_END
		invoke CpyWrd,edi,lpWord2,len2
		mov		eax,len2
		lea		edi,[edi+eax+1]
	.else
		invoke CpyWrd,edi,lpWord1,len1
		mov		eax,len1
		lea		edi,[edi+eax+1]
		invoke CpyWrd,edi,lpWord2,len2
		mov		eax,len2
		mov		byte ptr [edi+eax],' '
		lea		edi,[edi+eax+1]
	.endif
	invoke ParseLineDef,esi,edi
	invoke AddWordToWordList,'c',iNbr,offset prnbuff,2
	retn

ParseData:
	mov		edi,offset prnbuff
	mov		eax,[ebx].PARSEDEF.nName
	mov		lptype,0
	.if eax==NME_END
		.if len2==6
			mov		eax,lpWord2
			mov		ecx,[eax+4]
			mov		eax,[eax]
			and		eax,5F5F5F5Fh
			and		ecx,5F5Fh
			.if eax=='RAHS' && ecx=='DE'
				call	GetWrd
				mov		lpWord2,esi
				mov		len2,ecx
				lea		esi,[esi+ecx]
			.endif
		.endif
		.if len2==2 && nAsm==nBCET
			mov		eax,lpWord2
			mov		eax,[eax]
			and		eax,0FF5F5Fh
			.if eax==' SA'
				call	GetWrd
				mov		lptype,esi
				mov		lentype,ecx
				lea		esi,[esi+ecx]
				call	GetWrd
				mov		lpWord2,esi
				mov		len2,ecx
				lea		esi,[esi+ecx]
			.endif
		.endif
		invoke CpyWrd,edi,lpWord2,len2
		.if nAsm==nBCET
			mov		eax,len2
			lea		edi,[edi+eax]
		.else
			mov		eax,len2
			lea		edi,[edi+eax+1]
		.endif
	.else
		call	GetWrd
		.if ecx==3
			mov		eax,[esi]
			and		eax,5F5F5Fh
			.if eax=='RTP'
				retn
			.endif
		.endif
		invoke CpyWrd,edi,lpWord1,len1
		mov		eax,len1
		lea		edi,[edi+eax+1]
		invoke CpyWrd,edi,lpWord2,len2
		mov		eax,len2
		mov		byte ptr [edi+eax],' '
		lea		edi,[edi+eax+1]
	.endif
	.if nAsm!=nBCET
		invoke ParseLineDef,esi,edi
		.if nAsm==nMASM
			invoke GetDup
		.endif
		invoke AddWordToWordList,'d',iNbr,offset prnbuff,2
		retn
	.endif
	invoke ParseLineDef,esi,offset prnbuff+512
	push	esi
	mov		esi,offset prnbuff+512
  @@:
	.if lptype
		mov		byte ptr [edi],':'
		inc		edi
		invoke CpyWrd,edi,lptype,lentype
		mov		eax,lentype
		lea		edi,[edi+eax+1]
	.endif
	.while byte ptr [esi] && byte ptr [esi]!=','
		mov		eax,[esi]
		and		eax,5F5F5FFFh
		.break .if eax=='RTP ' && !byte ptr [esi+4]
		mov		eax,[esi]
		and		eax,0FF5F5Fh
		.if eax==' SA'
			add		esi,3
			call	GetWrd
			.if !lptype
				mov		lptype,esi
				mov		lentype,ecx
				lea		esi,[esi+ecx]
				mov		byte ptr [edi],':'
				inc		edi
				invoke CpyWrd,edi,lptype,lentype
				mov		eax,lentype
				lea		edi,[edi+eax+1]
			.else
				mov		lptype,esi
				mov		lentype,ecx
				lea		esi,[esi+ecx]
			.endif
		.endif
		mov		al,[esi]
		.break .if al=='='
		mov		[edi],al
		inc		esi
		inc		edi
		.if al=='"' || al=="'"
			.while byte ptr [esi] && al!=[esi]
				mov		ah,[esi]
				mov		[edi],ah
				inc		esi
				inc		edi
			.endw
		.endif
	.endw
	.while byte ptr [edi-1]==' '
		dec		edi
	.endw
	mov		byte ptr [edi],0
	invoke AddWordToWordList,'d',iNbr,offset prnbuff,2
	.if byte ptr [esi]==','
		mov		edi,offset prnbuff
		inc		esi
		.while byte ptr [esi] && byte ptr [esi]!=' ' && byte ptr [esi]!=','
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		.if byte ptr [esi]==' '
			inc		esi
		.endif
		jmp		@b
	.endif
	pop		esi
	mov		lentype,0
	retn

ParseMacro:
	mov		nlookahead,0
	mov		lastend,esi
	mov		edi,offset prnbuff
	mov		eax,[ebx].PARSEDEF.nName
	.if eax==NME_START
		invoke CpyWrd,edi,lpWord1,len1
		mov		eax,len1
		lea		edi,[edi+eax+1]
	.elseif eax==NME_END
		invoke CpyWrd,edi,lpWord2,len2
		mov		eax,len2
		lea		edi,[edi+eax+1]
	.endif
	invoke ParseLineDef,esi,edi
	invoke AddWordToWordList,'m',iNbr,offset prnbuff,2
	mov		edx,[ebx].PARSEDEF.rpEnd
	lea		edx,[ebx+edx]
	movzx	edx,word ptr [edx+sizeof PARSEDEF]
	.if edx=='}'
		call	SkpLn
		.while byte ptr [esi] && byte ptr [esi]!='}'
			inc		esi
		.endw
		call	SkpLn
		retn
	.endif
  @@:
	inc		nlookahead
	.if nlookahead<100
		call	SkpLn
		call	GetWrd
		mov		lpWord1,esi
		mov		len1,ecx
		lea		esi,[esi+ecx]
		call	GetWrd
		mov		lpWord2,esi
		mov		len2,ecx
		lea		esi,[esi+ecx]
		invoke WhatIsIt,lpWord1,len1,lpWord2,len2,FALSE
		.if eax
			movzx	ecx,word ptr [eax+sizeof PARSEDEF]
			mov		edx,[ebx].PARSEDEF.rpEnd
			lea		edx,[ebx+edx]
			movzx	edx,word ptr [edx+sizeof PARSEDEF]
			.if ecx!=edx || ecx!='}'
				mov		eax,[eax].PARSEDEF.nType
				.if eax==TPE_ENMACRO
					mov		lastend,esi
					jmp		@b
				.elseif eax==TPE_STMACRO || eax==TPE_STCODE || eax==TPE_STSTRUCT
					mov		esi,lastend
				.elseif byte ptr [esi]
					jmp		@b
				.endif
			.endif
		.elseif byte ptr [esi]
			jmp		@b
		.endif
	.endif
	mov		esi,lastend
	retn

ParseLabel:
	invoke CpyWrd,offset prnbuff,lpWord1,len1
	invoke AddWordToWordList,'l',iNbr,offset prnbuff,1
	retn

ParseStruct:
	mov		nlookahead,1
	mov		edi,offset prnbuff
	mov		eax,[ebx].PARSEDEF.nName
	.if eax==NME_START
		invoke CpyWrd,edi,lpWord1,len1
		mov		eax,len1
		lea		edi,[edi+eax+1]
	.elseif eax==NME_END
		invoke CpyWrd,edi,lpWord2,len2
		mov		eax,len2
		lea		edi,[edi+eax+1]
	.endif
	push	esi
	mov		edx,[ebx].PARSEDEF.rpEnd
	lea		edx,[ebx+edx]
	movzx	edx,word ptr [edx+sizeof PARSEDEF]
	.if edx=='}'
		call	SkpLn
		.while byte ptr [esi] && byte ptr [esi]!='}'
			inc		esi
		.endw
		call	SkpLn
		mov		lastend,esi
		jmp		ExSt
	.endif
	.if nAsm==nBCET
		call	GetWrd
		.if ecx==2
			mov		eax,[esi]
			and		eax,0FF5F5Fh
			.if eax==' SA'
				lea		esi,[esi+ecx+1]
				.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
					mov		al,[esi]
					mov		[edi],al
					inc		esi
					inc		edi
				.endw
				mov		dword ptr [edi],0
				invoke AddWordToWordList,'t',iNbr,offset prnbuff,2
				pop		eax
				retn
			.endif
		.endif
	.endif
  @@:
	call	SkpLn
	mov		lastend,esi
	call	GetWrd
	.if ecx
		mov		lpWord1,esi
		mov		len1,ecx
		lea		esi,[esi+ecx]
		call	GetWrd
		mov		lpWord2,esi
		mov		len2,ecx
		lea		esi,[esi+ecx]
		invoke WhatIsIt,lpWord1,len1,lpWord2,len2,FALSE
		.if eax
			mov		eax,[eax].PARSEDEF.nType
			.if eax==TPE_ENSTRUCT
				dec		nlookahead
				je		ExSt
			.elseif  eax==TPE_STSTRUCT
				inc		nlookahead
			.elseif eax==TPE_STMACRO || eax==TPE_STCODE
				jmp		ExSt
			.endif
		.elseif len1==5
			mov		eax,lpWord1
			movzx	ecx,byte ptr [eax+4]
			mov		eax,[eax]
			and		eax,5F5F5F5Fh
			and		ecx,5Fh
			.if (eax=='OINU' && ecx=='N') || (eax=='URTS' && ecx=='C')
				inc		nlookahead
			.endif
		.elseif len1==6
			mov		eax,lpWord1
			movzx	ecx,word ptr [eax+4]
			mov		eax,[eax]
			and		eax,5F5F5F5Fh
			and		ecx,5F5Fh
			.if eax=='URTS' && ecx=='TC'
				inc		nlookahead
			.endif
		.elseif len1==3 && nAsm==nBCET
			mov		eax,lpWord1
			mov		eax,[eax]
			and		eax,5F5F5Fh
			.if eax=='DNE'
				dec		nlookahead
			.endif
		.endif
	.endif
	.if byte ptr [esi]
		jmp		@b
	.endif
  ExSt:
	pop		esi
	invoke FindStructData,edi,esi,lastend
	.if eax
		mov		esi,eax
		invoke AddWordToWordList,'s',iNbr,offset prnbuff,2
	.endif
	retn

ParseType:
	retn

ParseUnknown:
	mov		edi,offset prnbuff
	invoke CpyWrd,edi,lpWord1,len1
	mov		eax,len1
	lea		edi,[edi+eax+1]
	mov		eax,lpWord2
	.if byte ptr [eax]==':'
		inc		lpWord2
		dec		len2
	.endif
	push	edi
	invoke CpyWrd,edi,lpWord2,len2
	mov		eax,len2
	mov		byte ptr [edi+eax],' '
	lea		edi,[edi+eax+1]
	invoke ParseLineDef,esi,edi
	pop		edi
	invoke strlen,edi
	.if byte ptr [edi+eax-1]==VK_SPACE
		mov		byte ptr [edi+eax-1],0
	.endif
	.if nAsm==nMASM
		invoke GetDup
	.endif
	invoke AddWordToWordList,'u',iNbr,offset prnbuff,2
	retn

SkpLocal:
	mov		al,[esi]
	.if al && al!=0Dh && al!=','
		inc		esi
		jmp		SkpLocal
	.endif
	retn

SkpSpc:
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,VK_SPACE
	je		@b
	cmp		al,VK_TAB
	je		@b
	retn

SkpLn:
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	or		al,al
	je		@f
	cmp		al,VK_RETURN
	jne		@b
	inc		esi
  @@:
	mov		al,[esi]
	cmp		al,0Ah
	jne		@f
	inc		esi
  @@:
	retn

GetWrd:
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
		inc		esi
	.endw
	.if nAsm==nHLA
		mov		eax,[esi]
		and		eax,0FFFFFFh
		.if word ptr [esi]=='.w'
			add		esi,2
		.elseif eax=='.w:'
			add		esi,3
		.elseif al==':'
			inc		esi
		.endif
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
	.elseif nAsm==nFP
		mov		eax,[esi]
		.if al=='='
			inc		esi
			.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
				inc		esi
			.endw
		.endif
	.endif
	mov		edx,lpCharTab
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	movzx	eax,byte ptr [esi+ecx]
	cmp		byte ptr [eax+edx],1
	je		@b
	.if (eax==':' || eax=='{' || eax=='}') && !ecx
		jmp		@b
	.endif
	.if nAsm!=nBCET && nAsm!=nFP
		cmp		eax,'='
		je		@b
	.endif
	cmp		eax,'.'
	je		@b
	cmp		eax,'$'
	je		@b
	retn

ParseFile endp

CompactWordList proc uses esi edi

	mov		esi,lpWordList
	add		esi,rpProjectWordList
	mov		edi,esi
	.while [esi].PROPERTIES.nSize
		.if [esi].PROPERTIES.nType=='x'
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.else
			mov		ecx,[esi].PROPERTIES.nSize
			lea		ecx,[ecx+sizeof PROPERTIES]
			rep movsb
		.endif
	.endw
	mov		[edi].PROPERTIES.nSize,0
	sub		edi,lpWordList
	mov		rpWordListPos,edi
	ret

CompactWordList endp

FixUnknown proc uses ebx esi edi
	LOCAL	hMem:DWORD

	.if hParseDll
		invoke GetProcAddress,hParseDll,offset szFixUnknown
		.if eax
			call	eax
			jmp		Ex
		.endif
	.endif
	invoke xGlobalAlloc,GMEM_FIXED,1024*1024
	mov		ebx,eax
	mov		hMem,eax
	call	FindPointers
	mov		esi,lpWordList
	add		esi,rpProjectWordList
	.while [esi].PROPERTIES.nSize
		.if [esi].PROPERTIES.nType=='u'
			call	FindStruct
		.endif
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
	invoke GlobalFree,hMem
  Ex:
	ret

FindPointers:
	mov		edi,lpWordList
	add		edi,rpStructList
	.while [edi].PROPERTIES.nSize
		mov		al,[edi].PROPERTIES.nType
		.if al=='S' || al=='s' || al=='T' || al=='t'
			mov		[ebx],edi
			add		ebx,4
		.endif
		mov		eax,[edi].PROPERTIES.nSize
		lea		edi,[edi+eax+sizeof PROPERTIES]
	.endw
	mov		dword ptr [ebx],0
	retn

FindStruct:
	mov		[esi].PROPERTIES.nType,'x'
	lea		edx,[esi+sizeof PROPERTIES]
	.while byte ptr [edx]
		inc		edx
	.endw
	inc		edx
;	mov		edi,lpWordList
;	add		edi,rpStructList
	mov		ebx,hMem
	.while dword ptr [ebx];[edi].PROPERTIES.nSize
		mov		edi,[ebx]
		mov		al,[edi].PROPERTIES.nType
		.if al=='S' || al=='s'
			xor		ecx,ecx
			dec		ecx
		  @@:
			inc		ecx
			mov		al,[edi+ecx+sizeof PROPERTIES]
			mov		ah,[edx+ecx]
			or		al,al
			je		@f
			cmp		al,ah
			je		@b
			jmp		FindStruct1
		  @@:
			.if !ah || ah==VK_SPACE
				mov		[esi].PROPERTIES.nType,'d'
				.break
			.endif
		.elseif al=='T' || al=='t'
			xor		ecx,ecx
			dec		ecx
		  @@:
			inc		ecx
			mov		al,[edi+ecx+sizeof PROPERTIES]
			mov		ah,[edx+ecx]
			.if al==':'
				mov		al,0
			.endif
			or		al,al
			je		@f
			.if nAsm==nMASM
				.if al>='a' && al<='z'
					and		al,5Fh
					.if ah>='a' && ah<='z'
						and		ah,5Fh
					.endif
				.endif
			.else
				.if al>='a' && al<='z'
					and		al,5Fh
				.endif
				.if ah>='a' && ah<='z'
					and		ah,5Fh
				.endif
			.endif
			cmp		al,ah
			je		@b
			jmp		FindStruct1
		  @@:
			.if !ah || ah==VK_SPACE
				mov		[esi].PROPERTIES.nType,'d'
				.break
			.endif
		  FindStruct1:
		.endif
		lea		ebx,[ebx+4]
	.endw
	retn

FixUnknown endp

DeleteProperties proc uses esi,iNbr:DWORD

	mov		esi,lpWordList
	add		esi,rpProjectWordList
	mov		edx,iNbr
	.while [esi].PROPERTIES.nSize
		.if edx==[esi].PROPERTIES.Owner
			mov		[esi].PROPERTIES.nType,'x'
		.endif
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
	ret

DeleteProperties endp

GetCodeDef proc uses esi edi,lpMem:DWORD,lpDef:DWORD,nSTType:DWORD,nENType:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[64]:BYTE
	LOCAL	lpEnd:DWORD

	invoke strcpy,addr buffer,lpDef
	mov		edi,lpMem
	;Ending
	invoke iniGetItem,addr buffer,addr buffer1
	mov		lpEnd,edi
	mov		eax,nENType
	call	AddCodeDef
	.while buffer
		;Start
		invoke iniGetItem,addr buffer,addr buffer1
		mov		eax,nSTType
		call	AddCodeDef
	.endw
	mov		eax,edi
	sub		eax,lpMem
	ret

AddCodeDef:
	lea		esi,buffer1
	mov		[edi].PARSEDEF.nType,eax
	mov		eax,lpEnd
	sub		eax,edi
	mov		[edi].PARSEDEF.rpEnd,eax
	movzx	eax,word ptr [esi]
	.if eax==' $'
		mov		eax,NME_START
		add		esi,2
	.elseif eax==' ?'
		mov		eax,NME_STARTOPT
		add		esi,2
	.else
		invoke strlen,esi
		mov		edx,eax
		movzx	eax,word ptr [esi+edx-2]
		.if eax=='$ '
			mov		eax,NME_END
			mov		byte ptr [esi+edx-2],0
		.elseif eax=='? '
			mov		eax,NME_ENDOPT
			mov		byte ptr [esi+edx-2],0
		.else
			mov		eax,NME_NONE
		.endif
	.endif
	mov		[edi].PARSEDEF.nName,eax
	xor		ecx,ecx
	dec		ecx
	xor		eax,eax
  @@:
	inc		ecx
	mov		al,[esi+ecx]
	.if al>='a' && al<='z'
		and		al,5Fh
	.elseif al=='_'
		xor		al,al
		inc		ah
	.endif
	mov		[edi+ecx+sizeof PARSEDEF],al
	or		al,al
	jne		@b
	mov		[edi].PARSEDEF.nLen,ecx
	.if ah
	  @@:
		inc		ecx
		mov		al,[esi+ecx]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		mov		[edi+ecx+sizeof PARSEDEF],al
		or		al,al
		jne		@b
		mov		eax,ecx
		sub		eax,[edi].PARSEDEF.nLen
		dec		eax
		mov		[edi].PARSEDEF.nLen2,eax
	.endif
	lea		eax,[ecx+sizeof PARSEDEF+1]
	mov		[edi].PARSEDEF.rpNext,eax
	lea		edi,[edi+eax]
	retn

GetCodeDef endp

GetCodeDefs proc uses esi

	.if hCodeDefs
		invoke GlobalFree,hCodeDefs
	.endif
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
	mov		hCodeDefs,eax
	mov		esi,eax
	invoke GetCodeDef,esi,addr szCPSkip,TPE_STSKIP,TPE_ENSKIP
	add		esi,eax
	invoke GetCodeDef,esi,addr szCPConst,TPE_STCONST,TPE_ENCONST
	add		esi,eax
	invoke GetCodeDef,esi,addr szCPStruct,TPE_STSTRUCT,TPE_ENSTRUCT
	add		esi,eax
	invoke GetCodeDef,esi,addr szCPStruct2,TPE_STSTRUCT,TPE_ENSTRUCT
	add		esi,eax
	invoke GetCodeDef,esi,addr szCPCode,TPE_STCODE,TPE_ENCODE
	add		esi,eax
	invoke GetCodeDef,esi,addr szCPCode2,TPE_STCODE,TPE_ENCODE
	add		esi,eax
	invoke GetCodeDef,esi,addr szCPLabel,TPE_STLABEL,TPE_ENLABEL
	add		esi,eax
	invoke GetCodeDef,esi,addr szCPLocal,TPE_STLOCAL,TPE_ENLOCAL
	add		esi,eax
	invoke GetCodeDef,esi,addr szCPMacro,TPE_STMACRO,TPE_ENMACRO
	add		esi,eax
	invoke GetCodeDef,esi,addr szCPData,TPE_STDATA,TPE_ENDATA
	add		esi,eax
	invoke GetCodeDef,esi,addr szCP0,TPE_ST0,TPE_EN0
	add		esi,eax
	invoke GetCodeDef,esi,addr szCP1,TPE_ST1,TPE_EN1
	add		esi,eax
	invoke GetCodeDef,esi,addr szCP2,TPE_ST2,TPE_EN2
	add		esi,eax
	invoke GetCodeDef,esi,addr szCP3,TPE_ST3,TPE_EN3
	add		esi,eax
	ret


GetCodeDefs endp

FindProcPos proc hWin:HWND
	LOCAL	buffer[1024]:BYTE
	LOCAL	buffer1[64]:BYTE
	LOCAL	chrg:CHARRANGE
	LOCAL	lpSPos:DWORD
	LOCAL	lpMPos:DWORD
	LOCAL	lpEPos:DWORD
	LOCAL	lpMSt:DWORD
	LOCAL	fFound:DWORD
	LOCAL	fNameEnd:DWORD
	LOCAL	nNest:DWORD
	LOCAL	iNbr:DWORD
	LOCAL	lpProc:DWORD
	LOCAL	cpProc:DWORD

	pushad
	mov		fFound,FALSE
	invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
	mov		ProcPos,0
	mov		byte ptr LineTxt,0
	.if nAsm==nCPP
		invoke GetParent,hWin
		.if fProject
			invoke GetWindowLong,eax,16
		.else
			neg		eax
		.endif
		mov		iNbr,eax
		mov		esi,lpWordList
		.while [esi].PROPERTIES.nSize
			mov		eax,iNbr
			.if [esi].PROPERTIES.nType=='l' && eax==[esi].PROPERTIES.Owner
				push	esi
				;Point to the proc name
				lea		esi,[esi+sizeof PROPERTIES]
				mov		lpProc,esi
				invoke strlen,esi
				;Point to the procs start,end position
				lea		esi,[esi+eax+1]
				.if byte ptr [esi]
					invoke strcpy,addr buffer,esi
					invoke iniGetItem,addr buffer,addr buffer1
					invoke DecToBin,addr buffer1
					.if eax<chrg.cpMin
						mov		cpProc,eax
						invoke DecToBin,addr buffer
						.if eax>chrg.cpMin
							mov		esi,lpWordList
							.while [esi].PROPERTIES.nSize
								mov		eax,iNbr
								.if [esi].PROPERTIES.nType=='p' && eax==[esi].PROPERTIES.Owner
									push	esi
									;Point to the proc name
									lea		esi,[esi+sizeof PROPERTIES]
									invoke strcmp,lpProc,esi
									.if !eax
										invoke strcpy,addr szProcName,esi
										mov		eax,cpProc
										mov		ProcPos,eax
										invoke strcpy,offset LineTxt,esi
										invoke strcat,offset LineTxt,offset szLPA
										invoke strlen,esi
										lea		esi,[esi+eax+1]
										invoke strcat,offset LineTxt,esi
										invoke strcat,offset LineTxt,offset szRPA
										pop		esi
										.break
									.endif
									pop		esi
								.endif
								;Move to next word
								mov		eax,[esi].PROPERTIES.nSize
								lea		esi,[esi+eax+sizeof PROPERTIES]
							.endw
							pop		esi
							.break
						.endif
					.endif
				.endif
				pop		esi
			.endif
			;Move to next word
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
	.else
		invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,chrg.cpMin
		invoke SendMessage,hWin,EM_LINEINDEX,eax,0
		add		eax,hSrcMem
		mov		lpMPos,eax
		invoke strcpy,addr buffer,addr szCPCode
		invoke iniGetItem,addr buffer,addr szSrcEnd
		mov		eax,offset szSrcEnd
		.while byte ptr [eax]
			.if byte ptr [eax]=='_'
				mov		byte ptr [eax],' '
			.endif
			inc		eax
		.endw
		invoke iniGetItem,addr buffer,addr szSrc
		call	TestIt
		.if !fFound && szCPCode2
			invoke strcpy,addr buffer,addr szCPCode2
			invoke iniGetItem,addr buffer,addr szSrcEnd
			mov		eax,offset szSrcEnd
			.while byte ptr [eax]
				.if byte ptr [eax]=='_'
					mov		byte ptr [eax],' '
				.endif
				inc		eax
			.endw
			invoke iniGetItem,addr buffer,addr szSrc
			call	TestIt
		.endif
		.if fFound
			invoke ParseLineDef,lpSPos,offset LineTxt
			mov		eax,lpSPos
			sub		eax,hSrcMem
			inc		eax
			mov		ProcPos,eax
		.endif
	.endif
	popad
	ret

TestIt:
	mov		eax,hSrcMem
	dec		eax
	mov		lpMSt,eax
	xor		esi,esi
	mov		fNameEnd,0
  NxP:
	;Find MyProc proc
	inc		lpMSt
	mov		eax,offset szSrc
	.if word ptr [eax]==' $'
		add		eax,2
	.else
		invoke lstrlen,eax
		.if word ptr szSrc[eax-2]=='$ '
			mov		byte ptr szSrc[eax-2],0
			mov		fNameEnd,TRUE
		.endif
		mov		eax,offset szSrc
	.endif
	invoke SearchMem,lpMSt,eax,FALSE,TRUE,FALSE
	.if eax
		mov		lpMSt,eax
		xor		edx,edx
		.while eax>hSrcMem
			.if byte ptr [eax]==';' || byte ptr [eax]=='"' || byte ptr [eax]=="'"
				jmp		NxP
			.elseif byte ptr [eax-1]==0Dh
				.break
			.endif
			.if (byte ptr [eax]!=VK_SPACE || byte ptr [eax]!=VK_TAB) && fNameEnd
				inc		edx
			.endif
			dec		eax
		.endw
		.if eax<=lpMPos
			.if !edx
				mov		esi,eax
			.endif
			jmp		NxP
		.endif
	.endif
	.if esi
		mov		lpSPos,esi
		.while byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		mov		eax,offset szSrc
		.if word ptr [eax]!=' $'
			.while byte ptr [esi]!=' ' && byte ptr [esi]!=VK_TAB && byte ptr [esi]
				inc		esi
			.endw
			.while byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB
				inc		esi
			.endw
		.endif
		mov		edi,offset szProcName
	  @@:
		mov		al,[esi]
		cmp		al,' '
		je		@f
		cmp		al,09h
		je		@f
		cmp		al,0Dh
		je		@f
		cmp		al,','
		je		@f
		cmp		al,'('
		je		@f
		cmp		al,';'
		je		@f
		or		al,al
		je		@f
		mov		[edi],al
		inc		esi
		inc		edi
		jmp		@b
	  @@:
		xor		al,al
		mov		[edi],al
		mov		eax,lpMPos
		dec		eax
		mov		lpMSt,esi
	  Nx:
		;Find MyProc endp
		.if nAsm==nFP
			mov		nNest,0
			.while TRUE
				mov		al,[esi]
				.if al==VK_RETURN
					inc		esi
					.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
						inc		esi
					.endw
					.if byte ptr [esi]
						invoke IsWordBegin,esi
						.if eax
							inc		nNest
						.else
							invoke IsWordCase,esi
							.if eax
								inc		nNest
							.else
								invoke IsWordEnd,esi
								.if eax
									dec		nNest
									.if !nNest
										.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
											inc		esi
										.endw
										mov		lpEPos,esi
										.if esi>lpMPos
											mov		fFound,TRUE
										.endif
										retn
									.endif
								.endif
							.endif
						.endif
					.endif
				.elseif !al
					retn
				.else
					inc		esi
				.endif
			.endw
		.endif
		inc		lpMSt
		mov		eax,offset szSrcEnd
		.if word ptr [eax]==' $' || word ptr [eax]==' ?'
			add		eax,2
		.endif
		invoke SearchMem,lpMSt,eax,FALSE,TRUE,FALSE
		.if eax
			mov		lpMSt,eax
			mov		esi,lpMSt
		  @@:
			dec		esi
			cmp		esi,hSrcMem
			jb		@f
			mov		al,[esi]
			cmp		al,';'
			je		Nx
			cmp		al,0Dh
			jne		@b
		  @@:
			inc		esi
			mov		al,[esi]
			.if al && al!=0Dh
				jmp		@b
			.endif
			mov		lpEPos,esi
			.if esi>lpMPos
				mov		fFound,TRUE
			.endif
		.endif
	.endif
	retn

FindProcPos endp

FindProc proc hWin:HWND

	.if fProcInSBar
		pushad
		invoke LoadEdit,hWin
		invoke FindProcPos,hWin
		invoke SendMessage,hStatus,SB_SETTEXT,3,addr LineTxt
		invoke GlobalUnlock,hSrcMem
		invoke GlobalFree,hSrcMem
		mov		hSrcMem,0
		popad
	.endif
	ret

FindProc endp

