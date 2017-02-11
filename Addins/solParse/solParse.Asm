.386
.model flat, stdcall
option casemap :none   ; case sensitive

include solParse.inc

.code

;PrintTheLine proc lpLine:DWORD
;
;	pushad
;	mov		esi,lpLine
;	xor		ecx,ecx
;	.while byte ptr [esi+ecx] && byte ptr [esi+ecx]!=VK_RETURN
;		inc		ecx
;	.endw
;	invoke lstrcpyn,offset buffer1,esi,addr [ecx+1]
;	PrintStringByAddr offset buffer1
;	popad
;	ret
;
;PrintTheLine endp
;
;PrintWord proc lpWord:DWORD,l:DWORD
;
;	pushad
;	mov		esi,lpWord
;	mov		ecx,l
;	mov		al,byte ptr [esi+ecx]
;	push	eax
;	mov		byte ptr [esi+ecx],0
;	PrintStringByAddr esi
;	pop		eax
;	mov		ecx,l
;	mov		byte ptr [esi+ecx],al
;	popad
;	ret
;
;PrintWord endp

AsciiToDw proc lpAscii:DWORD
	LOCAL	fNeg:DWORD

    push    ebx
    push    esi
    mov     esi,lpAscii
    mov		fNeg,FALSE
    mov		al,[esi]
    .if al=='-'
		inc		esi
		mov		fNeg,TRUE
    .endif
    xor     eax,eax
  @@:
    cmp     byte ptr [esi],30h
    jb      @f
    cmp     byte ptr [esi],3Ah
    jnb     @f
    mov     ebx,eax
    shl     eax,2
    add     eax,ebx
    shl     eax,1
    xor     ebx,ebx
    mov     bl,[esi]
    sub     bl,30h
    add     eax,ebx
    inc     esi
    jmp     @b
  @@:
	.if fNeg
		neg		eax
	.endif
    pop     esi
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

FindInFile proc uses ebx esi edi,nInx:DWORD,lpMem:DWORD,lpFind1:DWORD,lpFind2:DWORD,lpCharTab:DWORD
	LOCAL	nLine:DWORD
	LOCAL	lpPos:DWORD

	mov		nLine,-1
	mov		esi,lpMem
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
	.elseif nInx==6 || nInx==10
		; Enum
	  @@:
		invoke SearchMem,esi,offset szenum,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
		.endif
	.elseif nInx==7
		; Not used
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
	invoke SearchMem,esi,addr szcomment,FALSE,FALSE,lpCharTab
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
		.while word ptr [esi]!='/*' && byte ptr [esi]
			mov		al,[esi]
			.if al!=VK_RETURN && al!=0Ah
				mov		byte ptr [esi],' '
			.endif
			inc		esi
		.endw
		.if word ptr [esi]=='/*'
			mov		word ptr [esi],'  '
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
			invoke IsWord,lpword1,len1,offset szskipline
			.if eax
				; Skip line
				jmp		Nxt
			.endif
			call	GetWord
			.if ecx
				mov		len2,ecx
				mov		lpword2,esi
				lea		esi,[esi+ecx]
				invoke IsWord,lpword1,len1,offset szword1
				.if eax
					.if eax==10
						; Proc
						call	_Proc
						jmp		Nxt
					.elseif eax==11
						; Struc, Union
						call	_Struct
						jmp		Nxt
					.elseif eax==12
						; Macro
						call	_Macro
						jmp		Nxt
					.elseif eax==13
						; Enum
						call	_Enum
						jmp		Nxt
					.endif
				.endif
				invoke IsWord,lpword2,len2,offset szword2
				.if eax
					.if eax==10
						; const equ 10
						call	_Const
						jmp		Nxt
					.endif
				.endif
				invoke IsWord,lpword2,len2,offset szdatatypes
				.if eax
					.if eax>=10 && eax<=12
						; data db ?, data byte ?, data rb 10, data rs RECT,10
						call	_Data
						jmp		Nxt
					.endif
				.endif
			.elseif byte ptr [esi]==':'
				; label:
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
	.if byte ptr [esi]=='\' || byte ptr [esi]==','
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

SaveWord1:
	push	ebx
	xor		ecx,ecx
	mov		ebx,lpword1
	.while ecx<len1
		mov		al,[ebx+ecx]
		mov		[edi+ecx],al
		inc		ecx
	.endw
	mov		dword ptr [edi+ecx],0
	lea		edi,[edi+ecx+1]
	pop		ebx
	retn

SaveWord2:
	push	ebx
	xor		ecx,ecx
	mov		ebx,lpword2
	.while ecx<len2
		mov		al,[ebx+ecx]
		mov		[edi+ecx],al
		inc		ecx
	.endw
	mov		dword ptr [edi+ecx],0
	lea		edi,[edi+ecx+1]
	pop		ebx
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
		inc		esi
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

AddParam:
	call	GetWord
	.if ecx
		mov		len1,ecx
		mov		lpword1,esi
		lea		esi,[esi+ecx]
		push	ecx
		invoke strcpyn,edi,lpword1,addr [ecx+1]
		pop		ecx
		lea		edi,[edi+ecx]
		call	SkipSpc
		.if byte ptr [esi]=='['
			.while byte ptr [esi] && byte ptr [esi-1]!=']'
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			call	SkipSpc
		.endif
		mov		byte ptr [edi],':'
		inc		edi
		.if byte ptr [esi]==':'
			inc		esi
			call	GetWord
			mov		lendt,ecx
			mov		lpdt,esi
			lea		esi,[esi+ecx]
			call	ConvDataType
			mov		ecx,lendt
			push	ecx
			invoke strcpyn,edi,lpdt,addr [ecx+1]
			pop		ecx
			lea		edi,[edi+ecx]
			mov		byte ptr [edi],','
			inc		edi
		.else
			invoke strcpy,edi,addr szdword
			lea		edi,[edi+5]
			mov		byte ptr [edi],','
			inc		edi
		.endif
		jmp		AddParam
	.elseif byte ptr [esi]==','
		inc		esi
		jmp		AddParam
	.endif
	retn

_Proc:
	mov		edi,offset buffer
	call	SaveWord2
	mov		buffer1,0
	mov		buffer2,0
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke IsWord,lpword1,len1,offset szinproc
			.if eax==10
				;arg
				mov		edi,offset buffer1
				invoke strlen,edi
				lea		edi,[edi+eax]
				call	AddParam
			.elseif eax==11
				;local
				mov		edi,offset buffer2
				invoke strlen,edi
				lea		edi,[edi+eax]
				call	AddParam
			.elseif eax==12
				;endp
				.break
			.elseif eax==13
				;uses
			.endif
		.endif
	.endw
	invoke strlen,addr buffer1
	.if byte ptr buffer1[eax-1]==','
		mov		byte ptr buffer1[eax-1],0
	.endif
	invoke strlen,addr buffer2
	.if byte ptr buffer2[eax-1]==','
		mov		byte ptr buffer2[eax-1],0
	.endif
	mov		edi,offset buffer
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	invoke strcpy,edi,addr buffer1
	invoke strlen,edi
	lea		edi,[edi+eax+1]
	invoke strcpy,edi,addr buffer2
	push	3
	push	offset buffer
	push	iNbr
	push	'p'
	call	[lpAddProperty]
	retn

_Label:
	mov		edi,offset buffer
	call	SaveWord1
	push	1
	push	offset buffer
	push	iNbr
	push	'l'
	call	[lpAddProperty]
	retn

_Const:
	mov		edi,offset buffer
	call	SaveWord1
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
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke IsWord,lpword1,len1,addr szinstruct
			.if eax
				.if eax==10
					; union, struc, struct
					call	GetWord
					.if ecx
						; named
						mov		edx,nnest
						mov		lenname[edx*4],ecx
						mov		lpname[edx*4],esi
						lea		esi,[esi+ecx]
					.endif
					inc		nnest
				.elseif eax==11
					; endu, ends
					dec		nnest
					.if SIGN?
						.break
					.endif
					mov		ecx,nnest
					mov		lenname[ecx*4],0
					mov		lpname[ecx*4],0
				.endif
			.else
				; struct item
				call	SaveStructNest
				; item name
				call	SaveWord1
				dec		edi
				call	GetWord
				mov		lendt,ecx
				mov		lpdt,esi
				lea		esi,[esi+ecx]
				invoke IsWord,lpdt,lendt,addr szinstructitem
				.if eax==10
					; item rs RECT,2
					call	GetWord
					mov		lendt,ecx
					mov		lpdt,esi
					lea		esi,[esi+ecx]
					call	SkipSpc
					.if byte ptr [esi]==','
						inc		esi
						call	GetWord
						mov		len1,ecx
						mov		lpword1,esi
						lea		esi,[esi+ecx]
						mov		byte ptr [edi],'['
						inc		edi
						call	SaveWord1
						mov		byte ptr [edi-1],']'
					.endif
					; item datatype
					mov		byte ptr [edi],':'
					inc		edi
					call	ConvDataType
					mov		eax,lendt
					invoke strcpyn,edi,lpdt,addr [eax+1]
					add		edi,lendt
					mov		byte ptr [edi],','
					inc		edi
				.elseif eax==11
					; item RB 10
					call	GetWord
					mov		len1,ecx
					mov		lpword1,esi
					lea		esi,[esi+ecx]
					mov		byte ptr [edi],'['
					inc		edi
					call	SaveWord1
					mov		byte ptr [edi-1],']'
					mov		byte ptr [edi],':'
					inc		edi
					call	ConvDataType
					mov		eax,lendt
					invoke strcpyn,edi,lpdt,addr [eax+1]
					add		edi,lendt
					mov		byte ptr [edi],','
					inc		edi
				.elseif !eax
					; item datatype ?
					mov		byte ptr [edi],':'
					inc		edi
					call	ConvDataType
					mov		eax,lendt
					invoke strcpyn,edi,lpdt,addr [eax+1]
					add		edi,lendt
					mov		byte ptr [edi],','
					inc		edi
				.endif
			.endif
		.endif
	.endw
	.if byte ptr [edi-1]==','
		dec		edi
	.endif
	mov		byte ptr [edi],0
	retn

_Struct:
	mov		edi,offset buffer
	call	SaveWord2
	call	SaveStructItems
	push	2
	push	offset buffer
	push	iNbr
	push	's'
	call	[lpAddProperty]
	retn

_Macro:
	mov		edi,offset buffer
	call	SaveWord2
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke IsWord,lpword1,len1,offset szinmacro
			.if eax
				.if eax==10
					; marg
					.while byte ptr [esi]
						call	GetWord
						.if ecx
							mov		len1,ecx
							mov		lpword1,esi
							lea		esi,[esi+ecx]
							call	SaveWord1
							dec		edi
						.elseif !byte ptr [esi] || byte ptr [esi]==VK_RETURN
							.break
						.else
							mov		al,[esi]
							mov		[edi],al
							inc		esi
							inc		edi
						.endif
					.endw
				.elseif eax==11
					; endm
					.break
				.endif
			.endif
		.endif
	.endw
	.if byte ptr [edi-1]==','
		dec		edi
	.endif
	mov		byte ptr [edi],0
	push	2
	push	offset buffer
	push	iNbr
	push	'm'
	call	[lpAddProperty]
	retn

_Data:
	push	eax
	mov		edi,offset buffer
	call	SaveWord1
	dec		edi
	mov		eax,lpword2
	mov		lpdt,eax
	mov		eax,len2
	mov		lendt,eax
	pop		eax
	.if eax==10
		; data dd ?
		call	ConvDataType
		call	ArraySize
		.if byte ptr buffer1[4096]
			mov		byte ptr [edi],'['
			inc		edi
			invoke strcpy,edi,addr buffer1[4096]
			invoke strlen,edi
			lea		edi,[edi+eax]
			mov		byte ptr [edi],']'
			inc		edi
		.endif
		mov		byte ptr [edi],':'
		inc		edi
		mov		eax,lendt
		invoke strcpyn,edi,lpdt,addr [eax+1]
		add		edi,lendt
		mov		byte ptr [edi],0
		inc		edi
		mov		eax,len2
		invoke strcpyn,edi,lpword2,addr [eax+1]
		add		edi,len2
	.elseif eax==11
		; data rb 10
		call	GetWord
		mov		len1,ecx
		mov		lpword1,esi
		lea		esi,[esi+ecx]
		mov		byte ptr [edi],'['
		inc		edi
		call	SaveWord1
		mov		byte ptr [edi-1],']'
		mov		byte ptr [edi],':'
		inc		edi
		call	ConvDataType
		mov		eax,lendt
		invoke strcpyn,edi,lpdt,addr [eax+1]
		add		edi,lendt
		mov		byte ptr [edi],0
		inc		edi
		call	SaveWord2
		add		edi,len2
	.elseif eax==12
		; data rs RECT,10
		call	GetWord
		mov		lendt,ecx
		mov		lpdt,esi
		lea		esi,[esi+ecx]
		call	SkipSpc
		.if byte ptr [esi]==','
			inc		esi
			call	GetWord
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			mov		byte ptr [edi],'['
			inc		edi
			call	SaveWord1
			mov		byte ptr [edi-1],']'
		.endif
		mov		byte ptr [edi],':'
		inc		edi
		call	ConvDataType
		mov		eax,lendt
		invoke strcpyn,edi,lpdt,addr [eax+1]
		add		edi,lendt
		mov		byte ptr [edi],0
		inc		edi
		call	SaveWord2
		add		edi,len2
	.endif
	mov		byte ptr [edi],0
	push	2
	push	offset buffer
	push	iNbr
	push	'd'
	call	[lpAddProperty]
	retn

_Enum:
	mov		edi,offset buffer
	call	SaveWord2
	xor		ebx,ebx
	call	SkipSpc
	.if byte ptr [esi]==','
		inc		esi
		call	GetWord
		.if ecx
			invoke AsciiToDw,esi
			mov		ebx,eax
		.endif
	.endif
	.while byte ptr [esi]
		call	SkipLine
		call	GetWord
		.if ecx
			mov		len1,ecx
			mov		lpword1,esi
			lea		esi,[esi+ecx]
			invoke IsWord,lpword1,len1,offset szinenum
			.if eax
				.if eax==10
					.break
				.endif
			.endif
			push	edi
			call	SaveWord1
			pop		eax
			invoke strcpy,offset buffer1,eax
			invoke strlen,offset buffer1
			lea		eax,buffer1[eax+1]
			invoke DwToAscii,ebx,eax
			push	2
			push	offset buffer1
			push	iNbr
			push	'c'
			call	[lpAddProperty]
			inc		ebx
		.endif
		mov		byte ptr [edi-1],','
	.endw
	.if byte ptr [edi-1]==','
		dec		edi
	.endif
	mov		byte ptr [edi],0
	push	2
	push	offset buffer
	push	iNbr
	push	10
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
