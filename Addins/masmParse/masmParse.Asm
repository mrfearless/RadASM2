.386
.model flat, stdcall
option casemap :none   ; case sensitive

include masmParse.inc

.code

PrintTheLine proc lpLine:DWORD

	pushad
	mov		esi,lpLine
	xor		ecx,ecx
	.while byte ptr [esi+ecx] && byte ptr [esi+ecx]!=VK_RETURN
		inc		ecx
	.endw
	invoke lstrcpyn,offset buffer1,esi,addr [ecx+1]
	PrintStringByAddr offset buffer1
	popad
	ret

PrintTheLine endp

PrintWord proc lpWord:DWORD,l:DWORD

	pushad
	mov		esi,lpWord
	mov		ecx,l
	mov		al,byte ptr [esi+ecx]
	push	eax
	mov		byte ptr [esi+ecx],0
	PrintStringByAddr esi
	pop		eax
	mov		ecx,l
	mov		byte ptr [esi+ecx],al
	popad
	ret

PrintWord endp

AsciiToDw proc dwVal:DWORD,lpAscii:DWORD

    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:      
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

AsciiToDw endp

DwToAscii proc uses ebx esi edi,dwVal:DWORD,lpAscii:DWORD

	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:      
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
	ret

DwToAscii endp

strlen proc uses esi,lpSource:DWORD

	xor		eax,eax
	dec		eax
	mov		esi,lpSource
  @@:
	inc		eax
	cmp		byte ptr [esi+eax],0
	jne		@b
	ret

strlen endp

strcpy proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	mov		esi,lpSource
	xor		ecx,ecx
	mov		edi,lpDest
  @@:
	mov		al,[esi+ecx]
	mov		[edi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcpy endp

strcpyn proc uses esi edi,lpDest:DWORD,lpSource:DWORD,len:DWORD

	mov		esi,lpSource
	xor		ecx,ecx
	mov		edi,lpDest
	mov		edx,len
	dec		edx
  @@:
	mov		al,[esi+ecx]
	.if sdword ptr ecx>=edx
		xor		al,al
	.endif
	mov		[edi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcpyn endp

strcat proc uses esi edi,lpword1:DWORD,lpword2:DWORD

	mov		esi,lpword1
	mov		edi,lpword2
	invoke strlen,esi
	xor		ecx,ecx
	lea		esi,[esi+eax]
  @@:
	mov		al,[edi+ecx]
	mov		[esi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcat endp

strcmpn proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD,nCount:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	cmp		ecx,nCount
	je		@f
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	sub		al,ah
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmpn endp

strcmpin proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD,nCount:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	cmp		ecx,nCount
	je		@f
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	sub		al,ah
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmpin endp

SearchMem proc uses ebx ecx edx esi edi,hMem:DWORD,lpFind:DWORD,fMCase:DWORD,fWWord:DWORD,lpCharTab:DWORD

	mov		cl,byte ptr fWWord
	mov		ch,byte ptr fMCase
	mov		edi,hMem
	dec		edi
	mov		esi,lpFind
  Nx:
	xor		edx,edx
	inc		edi
	dec		edx
  Mr:
	inc		edx
	mov		al,[edi+edx]
	mov		ah,[esi+edx]
	.if ah && al
		cmp		al,ah
		je		Mr
		.if !ch
			;Try other case (upper/lower)
			movzx	ebx,ah
			add		ebx,lpCharTab
			cmp		al,[ebx+256]
			je		Mr
		.endif
		jmp		Nx					;Test next char
	.else
		.if !ah
			or		cl,cl
			je		@f
			;Whole word
			movzx	eax,al
			add		eax,lpCharTab
			mov		al,[eax]
			dec		al
			je		Nx				;Not found yet
			lea		eax,[edi-1]
			.if eax>=hMem
				movzx	eax,byte ptr [eax]
				add		eax,lpCharTab
				mov		al,[eax]
				dec		al
				je		Nx			;Not found yet
			.endif
		  @@:
			mov		eax,edi			;Found, return pos in eax
		.else
			xor		eax,eax			;Not found
		.endif
	.endif
	ret

SearchMem endp

SearchType proc uses esi,lpType:DWORD

	mov		esi,lpData
	mov		esi,[esi].ADDINDATA.lpWordList
	.while [esi].PROPERTIES.nSize
		movzx	eax,[esi].PROPERTIES.nType
		.if eax=='T' || eax=='t' || eax=='S' || eax=='s'
			call	Compare
			je		@f
		.endif
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
  @@:
	ret

Compare:
	lea		edx,[esi+sizeof PROPERTIES]
	mov		ecx,lpType
  @@:
	mov		al,[ecx]
	mov		ah,[edx]
	inc		ecx
	inc		edx
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if ah>='a' && ah<='z'
		and		ah,5Fh
	.endif
	sub		al,ah
	jne		@f
	cmp		al,ah
	jne		@b
  @@:
	retn

SearchType endp

DestroyToEol proc lpMem:DWORD

	mov		eax,lpMem
	.while byte ptr [eax]!=0 && byte ptr [eax]!=0Dh
		mov		byte ptr [eax],20h
		inc		eax
	.endw
	ret

DestroyToEol endp

DestroyString proc lpMem:DWORD

	mov		eax,lpMem
	movzx	ecx,byte ptr [eax]
	mov		ch,cl
	inc		eax
	.while byte ptr [eax]!=0 && byte ptr [eax]!=VK_RETURN
		mov		dx,[eax]
		.if dx==cx
			mov		word ptr [eax],'  '
			lea		eax,[eax+2]
		.else
			inc		eax
			.break .if dl==cl
			mov		byte ptr [eax-1],20h
		.endif
	.endw
	ret

DestroyString endp

DestroyCmntBlock proc uses esi,lpMem:DWORD,lpCharTab:DWORD

	mov		esi,lpMem
  @@:
	invoke SearchMem,esi,addr szcomment,FALSE,TRUE,lpCharTab
	.if eax
		mov		esi,eax
		.while eax>lpMem
			.break .if byte ptr [eax-1]==VK_RETURN || byte ptr [eax-1]==0Ah
			dec		eax
		.endw
		mov		ecx,dword ptr szstring
		mov		edx,';'
		.while eax<esi
			.if byte ptr [eax]==cl || byte ptr [eax]==ch
				;String
				invoke DestroyString,eax
				mov		esi,eax
				jmp		@b
			.elseif byte ptr [eax]==dl
				;Comment
				inc		eax
				invoke DestroyToEol,eax
				mov		esi,eax
				jmp		@b
			.endif
			inc		eax
		.endw
		lea		esi,[esi+7]
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		mov		ah,[esi]
		.if ah!=VK_RETURN && ah!=0Ah
			mov		byte ptr [esi],' '
		.endif
		.while ah!=byte ptr [esi] && byte ptr [esi+1]
			mov		al,[esi]
			.if al!=VK_RETURN && al!=0Ah
				mov		byte ptr [esi],' '
			.endif
			inc		esi
		.endw
		mov		al,[esi]
		.if al!=VK_RETURN && al!=0Ah
			mov		byte ptr [esi],' '
			inc		esi
		.endif
		jmp		@b
	.endif
	ret

DestroyCmntBlock endp

DestroyCommentsStrings proc uses esi,lpMem:DWORD

	mov		esi,lpMem
	mov		ecx,';'
	mov		edx,dword ptr szstring
	.while byte ptr [esi]
		.if byte ptr [esi]==cl
			invoke DestroyToEol,esi
			mov		esi,eax
		.elseif byte ptr [esi]==dl || byte ptr [esi]==dh
			invoke DestroyString,esi
			mov		esi,eax
			mov		ecx,';'
			mov		edx,dword ptr szstring
		.elseif byte ptr [esi]==VK_TAB
			mov		byte ptr [esi],VK_SPACE
		.else
			inc		esi
		.endif
	.endw
	ret

DestroyCommentsStrings endp

PreParse proc uses esi,lpMem:DWORD,lpCharTab:DWORD

	invoke DestroyCmntBlock,lpMem,lpCharTab
	invoke DestroyCommentsStrings,lpMem
	ret

PreParse endp

FindInFile proc uses ebx esi edi,nInx:DWORD,lpMem:DWORD,lpFind1:DWORD,lpFind2:DWORD,lpCharTab:DWORD
	LOCAL	nLine:DWORD
	LOCAL	lpPos:DWORD

	mov		nLine,-1
	mov		esi,lpMem
	invoke PreParse,esi,lpCharTab
	.if nInx==0
		; Proc
	  @@:
		invoke SearchMem,esi,offset szproc,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
	.elseif nInx==1
		; Constant
	  @@:
		invoke SearchMem,esi,offset szequ,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
		mov		esi,lpMem
	  @@:
		invoke SearchMem,esi,offset szequ2,FALSE,FALSE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
	.elseif nInx==2
		; Data
		mov		eax,lpFind1
		.if eax==lpFind2
			mov		ebx,lpData
			mov		edi,[ebx].ADDINDATA.lpWordList
			.if esi
				add		edi,[ebx].ADDINDATA.rpProjectWordList
				.while [edi].PROPERTIES.nSize
					invoke strlen,lpFind1
					mov		ebx,eax
					.if [edi].PROPERTIES.nType=='d'
						xor		ecx,ecx
						lea		edx,[edi+sizeof PROPERTIES]
						.while byte ptr [edx+ecx]
							.break .if byte ptr [edx+ecx]==':' || byte ptr [edx+ecx]=='['
							inc		ecx
						.endw
						.if ecx==ebx
							invoke strcmpn,edx,lpFind1,ebx
							.if !eax
								invoke strlen,addr [edi+sizeof PROPERTIES]
								lea		eax,[edi+eax+sizeof PROPERTIES+1]
								mov		lpFind2,eax
								.break
							.endif
						.endif
					.endif
					mov		eax,[edi].PROPERTIES.nSize
					lea		edi,[edi+eax+sizeof PROPERTIES]
				.endw
			.endif
		.endif
	  @@:
		invoke SearchMem,esi,lpFind2,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
	.elseif nInx==3
		; Macro
	  @@:
		invoke SearchMem,esi,offset szmacro,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
	.elseif nInx==4
		; Label
	  @@:
		invoke SearchMem,esi,offset szcolon,FALSE,FALSE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
	.elseif nInx==5
		; Struct
	  @@:
		invoke SearchMem,esi,offset szstruct,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
		; Union
		mov		esi,lpMem
	  @@:
		invoke SearchMem,esi,offset szunion,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
		; Struc
		mov		esi,lpMem
	  @@:
		invoke SearchMem,esi,offset szstruc,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
		; Record
		mov		esi,lpMem
	  @@:
		invoke SearchMem,esi,offset szrecord,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
	.elseif nInx==6 || nInx==10
		; Method
	  @@:
		invoke SearchMem,esi,offset szmethod,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
	.elseif nInx==7 || nInx==11
		; Object
	  @@:
		invoke SearchMem,esi,offset szobject,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
			jmp		Ex
		.endif
	.endif
  Ex:
	mov		eax,nLine
	mov		edx,lpPos
	ret

GetLineStart:
	.while esi>lpMem
		mov		al,[esi]
		.if al=='"' || al=="'"
			inc		edx
		.endif
		.break .if byte ptr [esi-1]==0Dh || byte ptr [esi-1]==0Ah
		dec		esi
	.endw
	mov		lpPos,esi
	retn

CopyLine:
	xor		edx,edx
	call	GetLineStart
	mov		edi,offset buffer
	.while byte ptr [esi]!=0Dh
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		byte ptr [edi],0
	retn

GetLineNo:
	xor		ecx,ecx
	mov		eax,esi
	mov		esi,lpMem
	.while esi<eax
		.if byte ptr [esi]==VK_RETURN
			inc		ecx
		.endif
		inc		esi
		mov		nLine,ecx
	.endw
	retn

FindInFile endp

FixUnknown proc uses ebx esi edi
	LOCAL	hMem:HGLOBAL

	mov		ebx,lpData
	mov		esi,[ebx].ADDINDATA.lpWordList
	.if esi
		; Setup an array of pointers to S, T and s types
		; This could be optimized by keeping the S and T array.
		invoke GlobalAlloc,GMEM_FIXED,1024*1024
		mov		hMem,eax
		mov		edi,eax
		mov		dx,'TS'
		mov		cl,'s'
		.while [esi].PROPERTIES.nSize
			mov		al,[esi].PROPERTIES.nType
			.if al==dl || al==dh || al==cl
				mov		[edi],esi
				lea		edi,[edi+4]
			.endif
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
		; Find the u types and match it with the S, T or s types
		; Change the u to x to have them deleted wnen the wordlist is compacted
		; If found, change the x to d
		mov		dword ptr [edi],0
		mov		esi,[ebx].ADDINDATA.lpWordList
		add		esi,[ebx].ADDINDATA.rpProjectWordList
		.while [esi].PROPERTIES.nSize
			.if [esi].PROPERTIES.nType=='u'
				; Found change u to x
				mov		byte ptr [esi].PROPERTIES.nType,'x'
				mov		ebx,hMem
				; Skip the name and point to datatype
				lea		ecx,[esi+sizeof PROPERTIES]
				.while byte ptr [ecx]
					inc		ecx
				.endw
				inc		ecx
				; Scan the array
				.while dword ptr [ebx]
					xor		edx,edx
					xor		eax,eax
					mov		edi,[ebx]
				  @@:
					mov		al,[ecx+edx]
					mov		ah,[edi+edx+sizeof PROPERTIES]
					or		ah,ah
					je		@f
					inc		edx
					sub		al,ah
					je		@b
				  @@:
					.if !eax
						; Found, change x to d
						mov		[esi].PROPERTIES.nType,'d'
						.break
					.endif
					lea		ebx,[ebx+4]
				.endw
			.endif
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
	.endif
	invoke GlobalFree,hMem
	ret

FixUnknown endp

IsWord proc uses ebx esi edi,lpWord:DWORD,lenWord:DWORD,lpList:DWORD

	mov		esi,lpList
	mov		edi,lenWord
	.while byte ptr [esi]
		movzx	ebx,byte ptr [esi+1]
		.if ebx==edi
			invoke strcmpin,addr [esi+2],lpWord,edi
			.if !eax
				movzx	eax,byte ptr [esi]
				jmp		Ex
			.endif
		.endif
		lea		esi,[esi+ebx+2]
	.endw
	xor		eax,eax
  Ex:
	ret

IsWord endp

ParseFile proc uses ebx esi edi,iNbr:DWORD,lpMem:DWORD,lpAddProperty:DWORD,lpCharTab:DWORD
	LOCAL	len1:DWORD
	LOCAL	lpword1:DWORD
	LOCAL	len2:DWORD
	LOCAL	lpword2:DWORD
	LOCAL	lendt:DWORD
	LOCAL	lpdt:DWORD
	LOCAL	nnest:DWORD
	LOCAL	lenname[8]:DWORD
	LOCAL	lpname[8]:DWORD
	LOCAL	narray:DWORD

	mov		esi,lpMem
	invoke PreParse,esi,lpCharTab
	.while byte ptr [esi]
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke IsWord,lpword1,len1,addr szskiplinefirstword
			or		eax,eax
			jne		Nxt
			call	GetWord
			.if ecx
				mov		len2,ecx
				mov		lpword2,esi
				lea		esi,[esi+ecx]
				invoke IsWord,lpword2,len2,addr szword2
				.if eax==10
					;proc
					call	_Proc
					jmp		Nxt
				.elseif eax==11
					;struct
					call	_Struct
					jmp		Nxt
				.elseif eax==12
					;record
					call	_Record
					jmp		Nxt
				.elseif eax==13
					;equ
					call	_Const
					jmp		Nxt
				.elseif eax==14
					;macro
					call	_Macro
					jmp		Nxt
				.endif
				invoke IsWord,lpword1,len1,addr szword1
				.if eax==10
					;method
					call	_Method
					jmp		Nxt
				.elseif eax==11
					;object
					call	_Object
					jmp		Nxt
				.endif
				invoke IsWord,lpword2,len2,addr szdatatypes
				.if eax
					;data
					call	_Data
					jmp		Nxt
				.endif
				;unknown
				call	_Unknown
				jmp		Nxt
			.elseif byte ptr [esi]=='='
				inc		esi
				call	_Const
			.elseif byte ptr [esi]==':'
				call	_Label
			.endif
		.endif
	  Nxt:
		call	SkipLine
	.endw
	ret

SkipLine:
	xor		eax,eax
	.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
		.if byte ptr [esi]!=VK_SPACE
			mov		al,[esi]
		.endif
		inc		esi
	.endw
	.if byte ptr [esi]==VK_RETURN
		inc		esi
	.endif
	.if byte ptr [esi]==0Ah
		inc		esi
	.endif
	.if al=='\' || al==','
		jmp		SkipLine
	.endif
	retn

SkipSpc:
	.while byte ptr [esi]==VK_SPACE
		inc		esi
	.endw
	xor		ecx,ecx
	.if byte ptr [esi]=='\'; || byte ptr [esi]==','
		inc		ecx
		.while byte ptr [esi+ecx]==VK_SPACE
			inc		ecx
		.endw
		.if byte ptr [esi+ecx]==VK_RETURN
			lea		esi,[esi+ecx+1]
			.if byte ptr [esi]==0Ah
				inc		esi
			.endif
			jmp		SkipSpc
		.endif
	.endif
	retn

SkipNewLine:
	call	SkipSpc
	.if byte ptr [esi]==VK_RETURN
		inc		esi
	.endif
	.if byte ptr [esi]==0Ah
		inc		esi
	.endif
	retn

GetWord:
	call	SkipSpc
	mov		edx,lpCharTab
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	movzx	eax,byte ptr [esi+ecx]
	cmp		byte ptr [eax+edx],1
	je		@b
	retn

SaveName:
	xor		ecx,ecx
	mov		ebx,lpword1
	mov		edi,offset buffer
	.while ecx<len1
		mov		al,[ebx+ecx]
		mov		[edi+ecx],al
		inc		ecx
	.endw
	mov		dword ptr [edi+ecx],0
	lea		edi,[edi+ecx+1]
	retn

SaveWord:
	push	ecx
	invoke strcpyn,edi,esi,addr [ecx+1]
	pop		ecx
	lea		edi,[edi+ecx]
	retn

SaveDataType:
	push	ecx
	push	esi
	mov		ebx,lendt
	.if ebx==2
	.else
		mov		esi,offset szdatatypes
		.while byte ptr [esi]
			movzx	eax,byte ptr [esi]
			.if eax==ebx
				invoke strcmpin,lpdt,addr [esi+1],ebx
				.if !eax
					inc		esi
					mov		lpdt,esi
					.break
				.endif
				mov		eax,ebx
			.endif
			lea		esi,[esi+eax+1]
		.endw
	.endif
	invoke strcpyn,edi,lpdt,addr [ebx+1]
	lea		edi,[edi+ebx]
	pop		esi
	pop		ecx
	retn

SaveParam:
	call	GetWord
	.if ecx
		push	ecx
		invoke IsWord,esi,ecx,offset szinprocparam
		pop		ecx
		.if eax
			lea		esi,[esi+ecx]
			jmp		SaveParam
		.endif
	.elseif byte ptr [esi]==','
		inc		esi
		call	SkipNewLine
		jmp		SaveParam
	.elseif byte ptr [esi]==VK_RETURN
		mov		dword ptr [edi],0
		inc		edi
		retn
	.endif
SaveParam1:
	call	GetWord
	.if ecx
		call	SaveWord
		lea		esi,[esi+ecx]
SaveParam2:
		call	GetWord
		.if !ecx
			.if byte ptr [esi]==','
				inc		esi
				call	SkipNewLine
				mov		byte ptr [edi],':'
				inc		edi
				invoke strcpyn,edi,addr szdword,6
				lea		edi,[edi+5]
				mov		byte ptr [edi],','
				inc		edi
				jmp		SaveParam1
			.elseif byte ptr [esi]==VK_RETURN
				mov		byte ptr [edi],':'
				inc		edi
				invoke strcpyn,edi,addr szdword,6
				lea		edi,[edi+5]
				mov		byte ptr [edi],','
				inc		edi
			.elseif byte ptr [esi]=='['
				.while byte ptr [esi] && byte ptr [esi-1]!=']'
					mov		al,[esi]
					.if al!=VK_SPACE
						mov		[edi],al
						inc		edi
					.elseif byte ptr [edi-1]!=VK_SPACE
						mov		[edi],al
						inc		edi
					.endif
					inc		esi
				.endw
				jmp		SaveParam2
			.elseif byte ptr [esi]==':'
				inc		esi
				mov		byte ptr [edi],':'
				inc		edi
			  @@:
				call	GetWord
				.if ecx==3
					push	ecx
					invoke strcmpin,esi,addr szptr,3
					pop		ecx
					.if !eax
						lea		esi,[esi+3]
						invoke strcpyn,edi,addr szptr,4
						lea		edi,[edi+4]
						jmp		@b
					.endif
				.endif
				mov		lendt,ecx
				mov		lpdt,esi
				lea		esi,[esi+ecx]
				call	SaveDataType
				mov		byte ptr [edi],','
				inc		edi
				call	GetWord
				.if byte ptr [esi]==','
					inc		esi
					call	SkipNewLine
					jmp		SaveParam1
				.endif
			.endif
		.endif
	.endif
	retn

SaveLocal:
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		.if ecx
			push	ecx
			invoke IsWord,esi,ecx,offset szinproc
			pop		ecx
			.if eax==10
				;local
				lea		esi,[esi+ecx]
				call	SaveParam1
			.elseif eax==11
				;endp
				retn
			.else
				lea		esi,[esi+ecx]
				call	GetWord
				.if ecx==4
					invoke IsWord,esi,ecx,offset szinproc
					.if eax==11
						;endp
						retn
					.endif
				.endif
			.endif
		.endif
	.endw
	retn

SaveStructNest:
	xor		ebx,ebx
	.while ebx<nnest
		.if lpname[ebx*4]
			mov		eax,lenname[ebx*4]
			invoke strcpyn,edi,lpname[ebx*4],addr [eax+1]
			add		edi,lenname[ebx*4]
			mov		byte ptr [edi],'.'
			inc		edi
		.endif
		inc		ebx
	.endw
	retn

SaveStructItems:
	xor		eax,eax
	xor		ecx,ecx
	mov		nnest,eax
	.while ecx<8
		mov		lenname[ecx*4],eax
		mov		lpname[ecx*4],eax
		inc		ecx
	.endw
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		.if ecx
			push	ecx
			invoke IsWord,esi,ecx,offset szinstruct
			pop		ecx
			.if eax==10
				;ends
				dec		nnest
				.if SIGN?
					.if byte ptr [edi-1]==','
						dec		edi
					.endif
					mov		byte ptr [edi],0
					inc		edi
					retn
				.endif
				mov		ecx,nnest
				mov		lenname[ecx*4],0
				mov		lpname[ecx*4],0
				xor		ecx,ecx
			.elseif eax==11
				lea		esi,[esi+ecx]
				call	GetWord
				.if ecx
					mov		edx,nnest
					mov		lenname[edx*4],ecx
					mov		lpname[edx*4],esi
					lea		esi,[esi+ecx]
				.endif
				inc		nnest
				xor		ecx,ecx
			.endif
			.if ecx
				push	esi
				lea		esi,[esi+ecx]
				call	GetWord
				.if ecx==4
					push	ecx
					invoke IsWord,esi,ecx,offset szinstruct
					pop		ecx
					.if eax==10
						pop		eax
						dec		nnest
						.if SIGN?
							.if byte ptr [edi-1]==','
								dec		edi
							.endif
							mov		byte ptr [edi],0
							inc		edi
							retn
						.endif
					.endif
				.endif
				pop		esi
				call	SaveStructNest
				call	GetWord
				call	SaveWord
				lea		esi,[esi+ecx]
				call	GetWord
				.if ecx
					mov		byte ptr [edi],':'
					inc		edi
					mov		lendt,ecx
					mov		lpdt,esi
					call	SaveDataType
				.endif
				mov		byte ptr [edi],','
				inc		edi
			.endif
		.endif
	.endw
	retn

SaveRecordItems:
	.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
		call	GetWord
		.if ecx
			call	SaveWord
			lea		esi,[esi+ecx]
			call	GetWord
			.if byte ptr [esi]==':'
				mov		byte ptr [edi],':'
				inc		edi
				inc		esi
				call	GetWord
				call	SaveWord
				lea		esi,[esi+ecx]
				mov		byte ptr [edi],','
				inc		edi
				call	GetWord
				.if byte ptr [esi]=='='
					inc		esi
					.while byte ptr [esi] && byte ptr [esi]!=',' && byte ptr [esi]!=VK_RETURN
						call	GetWord
						.if ecx
							lea		esi,[esi+ecx]
						.elseif byte ptr [esi] && byte ptr [esi]!=',' && byte ptr [esi]!=VK_RETURN
							inc		esi
						.else
							.break
						.endif
					.endw
					.if byte ptr [esi]==','
						inc		esi
						call	SkipNewLine
					.else
						retn
					.endif
				.elseif byte ptr [esi]==','
					inc		esi
					call	SkipNewLine
				.else
					retn
				.endif
			.else
				retn
			.endif
		.else
			retn
		.endif
	.endw
	retn

SkipBrace:
	xor		eax,eax
	dec		eax
SkipBrace1:
	.while byte ptr [esi]==VK_SPACE
		inc		esi
	.endw
	mov		al,[esi]
	inc		esi
	.if al=='('
		push	eax
		mov		ah,')'
		jmp		SkipBrace1
	.elseif al=='{'
		push	eax
		mov		ah,'}'
		jmp		SkipBrace1
	.elseif al=='['
		push	eax
		mov		ah,']'
		jmp		SkipBrace1
	.elseif al=='<'
		push	eax
		mov		ah,'>'
		jmp		SkipBrace1
	.elseif al=='"'
		push	eax
		mov		ah,'"'
		jmp		SkipBrace1
	.elseif al=="'"
		push	eax
		mov		ah,"'"
		jmp		SkipBrace1
	.elseif al==ah
		pop		eax
	.elseif ah==0FFh
		dec		esi
		retn
	.elseif al==VK_RETURN || al==0
		dec		esi
		pop		eax
	.endif
	jmp		SkipBrace1

ConvDataType:
	push	esi
	mov		esi,offset szdataconv
	.if lendt==2
		.while byte ptr [esi]
			invoke strcmpin,esi,lpdt,2
			.if !eax
				lea		esi,[esi+3]
				mov		lpdt,esi
				invoke strlen,esi
				mov		lendt,eax
				jmp		ExConvDataType
			.endif
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
	.elseif lendt==4 || lendt==5 || lendt==6
		.while byte ptr [esi]
			lea		esi,[esi+3]
			invoke strcmpin,esi,lpdt,lendt
			.if !eax
				mov		lpdt,esi
				jmp		ExConvDataType
			.endif
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
	.endif
  ExConvDataType:
	pop		esi
	retn

ArraySize:
	call	SkipSpc
	push	ebx
	mov		ebx,offset buffer1[8192]
	mov		word ptr [ebx-1],0
	mov		word ptr buffer1[4096-1],0
	mov		narray,0
	.while TRUE
		mov		al,[esi]
		.if al=='"' || al=="'"
			inc		esi
			.while al!=[esi] && byte ptr [esi]!=VK_RETURN && byte ptr [esi]
				inc		esi
				inc		narray
			.endw
			.if al==[esi]
				inc		esi
			.endif
			mov		al,[esi]
		.elseif al=='<'
			call	SkipBrace
			inc		narray
		.endif
		mov		ah,[ebx-1]
		.if al==' ' || al=='+' || al=='-' || al=='*' || al=='/' || al=='(' || al==')' || al==','
			.if ah==' ' || (al==',' && ah==',')
				dec		ebx
			.endif
		.endif
		.if al==' '
			.if ah=='+' || ah=='-' || ah=='*' || ah=='/' || ah=='(' || ah==')' || ah==','
				mov		al,ah
				dec		ebx
			.endif
		.endif
		.if al=='d' || al=='D'
			.if byte ptr [esi+1]=='u' || byte ptr [esi+1]=='U'
				.if byte ptr [esi+2]=='p' || byte ptr [esi+2]=='P'
					.if byte ptr [esi+3]==' ' || byte ptr [esi+3]=='('
						add		esi,3
						call	SkipSpc
						.if byte ptr [esi]=='('
							call	SkipBrace
						.endif
						call	SkipSpc
						.if byte ptr buffer1[4096]
							invoke strcat,offset buffer1[4096],offset szadd
						.endif
						mov		byte ptr [ebx-1],0
						invoke strcat,offset buffer1[4096],offset buffer1[8192]
						mov		al,[esi]
					.endif
				.endif
			.endif
		.endif
		.if al==',' || al==VK_RETURN || !al
			.if byte ptr [ebx-1]
				inc		narray
			.endif
			mov		ebx,offset buffer1[8192]
			mov		byte ptr [ebx],0
		  .break .if al==VK_RETURN || !al
		.else
			mov		[ebx],al
			inc		ebx
		.endif
		.if byte ptr [esi]==','
			inc		esi
			call	SkipNewLine
		.else
			inc		esi
		.endif
	.endw
	mov		byte ptr [ebx],0
	pop		ebx
	.if narray>1 || (byte ptr buffer1[4096] && narray)
		.if byte ptr buffer1[4096]
			invoke strcat,addr buffer1[4096],addr szadd
		.endif
		invoke DwToAscii,narray,addr buffer1[8192+1024]
		invoke strcat,addr buffer1[4096],addr buffer1[8192+1024]
	.endif
	retn

_Skip:
	mov		ebx,offset szskiplinefirstword
	mov		edi,len1
	.while byte ptr [ebx]
		movzx	eax,byte ptr [ebx]
		.if eax==edi
			invoke strcmpin,esi,addr [ebx+1],edi
			.if !eax
				mov		eax,TRUE
				retn
			.endif
			mov		eax,edi
		.endif
		lea		ebx,[ebx+eax+1]
	.endw
	xor		eax,eax
	retn

_Method:
	mov		eax,lpword2
	mov		lpword1,eax
	mov		ecx,len2
	mov		len1,ecx
	.if byte ptr [esi]=='.'
		inc		esi
		inc		ecx
		push	ecx
		call	GetWord
		lea		esi,[esi+ecx]
		pop		eax
		lea		ecx,[ecx+eax]
	.endif
	mov		len1,ecx
	call	SaveName
	call	SkipSpc
	.if byte ptr [esi]==','
		inc		esi
		call	SkipSpc
		;Skip uses
		.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN && byte ptr [esi]!=','
			inc		esi
		.endw
		.if byte ptr [esi]==','
			inc		esi
			call	SkipSpc
			.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
				mov		al,[esi]
				.if al!=VK_SPACE
					mov		[edi],al
					inc		edi
				.endif
				inc		esi
			.endw
		.endif
	.endif
	mov		byte ptr [edi],0
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		mov		len1,ecx
		mov		lpword1,esi
		lea		esi,[esi+ecx]
		.if ecx==9
			invoke IsWord,lpword1,len1,addr szinmethod
			.if eax==10
				push	2
				push	offset buffer
				push	iNbr
				push	10
				call	[lpAddProperty]
				retn
			.endif
		.endif
	.endw
	retn

_Object:
	mov		eax,len2
	mov		len1,eax
	mov		eax,lpword2
	mov		lpword1,eax
	call	SaveName
	call	SkipSpc
	.if byte ptr [esi]==','
		inc		esi
		call	SkipSpc
		.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
			mov		al,[esi]
			.if al!=VK_SPACE
				mov		[edi],al
				inc		edi
			.endif
			inc		esi
		.endw
	.endif
	mov		byte ptr [edi],0
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		mov		len1,ecx
		mov		lpword1,esi
		lea		esi,[esi+ecx]
		.if ecx==9
			invoke IsWord,lpword1,len1,addr szinobject
			.if eax==10
				push	2
				push	offset buffer
				push	iNbr
				push	11
				call	[lpAddProperty]
				retn
			.endif
		.endif
	.endw
	retn

_Proc:
	call	SaveName
	call	SaveParam
	.if byte ptr [edi-1]==','
		mov		byte ptr [edi-1],0
	.endif
	mov		word ptr [edi],0
	call	SaveLocal
	.if byte ptr [edi-1]==','
		mov		byte ptr [edi-1],0
	.endif
	mov		word ptr [edi],0
	push	3
	push	offset buffer
	push	iNbr
	push	'p'
	call	[lpAddProperty]
	retn

_Label:
	call	SaveName
	mov		byte ptr [edi],0
	push	2
	push	offset buffer
	push	iNbr
	push	'l'
	call	[lpAddProperty]
	retn

_Const:
	call	SaveName
	call	SkipSpc
	.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
		mov		al,[esi]
		.if al!=VK_SPACE
			mov		[edi],al
			inc		edi
		.elseif byte ptr [edi-1]!=VK_SPACE
			mov		[edi],al
			inc		edi
		.endif
		inc		esi
	.endw
	.if byte ptr [edi-1]==VK_SPACE
		dec		edi
	.endif
	mov		byte ptr [edi],0
	push	2
	push	offset buffer
	push	iNbr
	push	'c'
	call	[lpAddProperty]
	retn

_Struct:
	call	SaveName
	call	SaveStructItems
	push	2
	push	offset buffer
	push	iNbr
	push	's'
	call	[lpAddProperty]
	retn

_Record:
	call	SaveName
	call	SaveRecordItems
	.if byte ptr [edi-1]==','
		dec		edi
	.endif
	mov		byte ptr [edi],0
	push	2
	push	offset buffer
	push	iNbr
	push	's'
	call	[lpAddProperty]
	retn

_Macro:
	call	SaveName
	call	SkipSpc
	.while byte ptr [esi] && byte ptr [esi]!=VK_RETURN
		mov		al,[esi]
		.if al!=VK_SPACE
			mov		[edi],al
			inc		edi
		.endif
		inc		esi
	.endw
	mov		byte ptr [edi],0
	xor		edi,edi
	mov		ebx,esi
	.while byte ptr [esi] && edi<500
		call	SkipLine
		call	GetWord
		.if ecx==4
			push	ecx
			invoke IsWord,esi,ecx,offset szinmacro
			pop		ecx
			.if eax
				mov		ebx,esi
				xor		edi,edi
			.endif
		.endif
		lea		esi,[esi+ecx]
		call	GetWord
		.if ecx==5
			invoke strcmpin,esi,addr szmacro,5
			.break .if !eax
		.endif
		inc		edi
	.endw
	mov		esi,ebx
	push	2
	push	offset buffer
	push	iNbr
	push	'm'
	call	[lpAddProperty]
	retn

_Data:
	call	SaveName
	mov		eax,lpword2
	mov		lpdt,eax
	mov		eax,len2
	mov		lendt,eax
	; Check for mov	dword ptr [eax],1
	call	GetWord
	.if ecx==3
		invoke strcmpin,esi,addr szptr,3
		.if !eax
			retn
		.endif
	.endif
	call	ConvDataType
	call	ArraySize
	.if byte ptr buffer1[4096]
		mov		byte ptr [edi-1],'['
		invoke strcpy,edi,addr buffer1[4096]
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],']'
		inc		edi
		mov		byte ptr [edi],0
		inc		edi
	.endif
	.if lpdt
		mov		byte ptr [edi-1],':'
		mov		eax,lendt
		invoke strcpyn,edi,lpdt,addr [eax+1]
		add		edi,lendt
		mov		byte ptr [edi],0
		inc		edi
		mov		eax,len2
		invoke strcpyn,edi,lpword2,addr [eax+1]
		add		edi,len2
	.else
		dec		edi
		invoke strcpy,edi,addr szdword
		lea		edi,[edi+sizeof szdword]
		mov		byte ptr [edi],0
		inc		edi
		invoke strcpy,edi,addr szdword
		lea		edi,[edi+sizeof szdword]
	.endif
	mov		byte ptr [edi],0
	push	2
	push	offset buffer
	push	iNbr
	push	'd'
	call	[lpAddProperty]
	retn

_Unknown:
	call	SaveName
	mov		eax,lpword2
	mov		lpdt,eax
	mov		eax,len2
	mov		lendt,eax
	.if lendt==5
		invoke strcmpin,lpdt,addr szproto,5
		.if !eax
			retn
		.endif
	.endif
	; Check for mov	dword ptr [eax],1
	call	GetWord
	.if ecx==3
		invoke strcmpin,esi,addr szptr,3
		.if !eax
			retn
		.endif
	.endif
	call	ConvDataType
	call	ArraySize
	.if byte ptr buffer1[4096]
		mov		byte ptr [edi-1],'['
		invoke strcpy,edi,addr buffer1[4096]
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		byte ptr [edi],']'
		inc		edi
		mov		byte ptr [edi],0
		inc		edi
	.endif
	.if lpdt
		mov		byte ptr [edi-1],':'
		mov		eax,lendt
		invoke strcpyn,edi,lpdt,addr [eax+1]
		add		edi,lendt
		mov		byte ptr [edi],0
		inc		edi
		mov		eax,len2
		invoke strcpyn,edi,lpword2,addr [eax+1]
		add		edi,len2
	.else
		dec		edi
		invoke strcpy,edi,addr szdword
		lea		edi,[edi+sizeof szdword]
		mov		byte ptr [edi],0
		inc		edi
		invoke strcpy,edi,addr szdword
		lea		edi,[edi+sizeof szdword]
	.endif
	mov		byte ptr [edi],0
	push	2
	push	offset buffer
	push	iNbr
	push	'u'
	call	[lpAddProperty]
	retn

ParseFile endp

FindProcPos proc uses esi edi,lpMem:DWORD,lpPos:DWORD,lpCharTab:DWORD

	xor		eax,eax
	mov		lpFunSt,eax
	mov		lpFunEn,eax
	mov		eax,lpPos
	mov		lpFunPos,eax
	invoke ParseFile,0,lpMem,NULL,lpCharTab
	mov		esi,lpFunSt
	.if esi>lpMem
		.while byte ptr [esi-1]!=VK_RETURN && esi>lpMem
			dec		esi
		.endw
		mov		lpFunSt,esi
	.endif
	mov		eax,lpFunPos
	.if eax>=lpFunSt && eax<=lpFunEn
		mov		eax,lpFunSt
	.else
		xor		eax,eax
	.endif
	mov		lpFunPos,0
	ret

FindProcPos endp

FindLocal proc uses esi,hMem:DWORD,lpProcName:DWORD,lpMSt:DWORD,lpWord:DWORD,lpCharTab:DWORD

	mov		esi,lpData
	mov		esi,[esi].ADDINDATA.lpWordList
	.while [esi].PROPERTIES.nSize
		movzx	eax,[esi].PROPERTIES.nType
		.if eax=='p'
			call	Compare
			je		@f
		.endif
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
	xor		eax,eax
	ret
  @@:
	lea		esi,[esi+sizeof PROPERTIES]
	invoke strlen,esi
	lea		esi,[esi+eax+1]
	invoke SearchMem,esi,lpWord,TRUE,TRUE,lpCharTab
	.if !eax
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		invoke SearchMem,esi,lpWord,TRUE,TRUE,lpCharTab
	.endif
	.if eax
		invoke SearchMem,hMem,lpWord,TRUE,TRUE,lpCharTab
	.endif
	ret

Compare:
	lea		edx,[esi+sizeof PROPERTIES]
	mov		ecx,lpProcName
  @@:
	mov		al,[ecx]
	mov		ah,[edx]
	inc		ecx
	inc		edx
	sub		al,ah
	jne		@f
	cmp		al,ah
	jne		@b
  @@:
	retn

FindLocal endp

InstallDll proc uses ebx,hWin:DWORD,fOpt:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax
	;Get pointer to procs struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProcs,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0
	mov		lpData,eax
	ret

InstallDll endp

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
	.elseif reason==DLL_PROCESS_DETACH
	.endif
	mov     eax,TRUE
	ret

DllEntry Endp

End DllEntry
