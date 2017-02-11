
.code

BinToDec proc dwVal:DWORD,lpAscii:DWORD

	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
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
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	pop		ebx
	ret

BinToDec endp

DecToBin proc lpStr:DWORD
	LOCAL	fNeg:DWORD

    push    ebx
    push    esi
    mov     esi,lpStr
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

DecToBin endp

StrGetItem proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	mov		esi,lpSource
	mov		edi,lpDest
  @@:
  	mov		al,[esi]
  	cmp		al,','
  	jz		@f
	or		al,al
  	jz		@f
  	mov		[edi],al
  	inc		esi
  	inc		edi
	jmp		@b
  @@:
  	or		al,al
  	jz		@f
  	inc		esi
  	mov		al,0
  @@:
  	mov		[edi],al
  	mov		eax,edi
  	sub		eax,lpDest
  	push	eax
	mov		edi,lpSource
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jnz		@b
	pop		eax
	ret

StrGetItem endp

StrPutValue proc uses edi,Value:DWORD,lpDest:DWORD,fComma:DWORD
	LOCAL	buffer[16]:BYTE

	invoke BinToDec,Value,addr buffer
	invoke lstrlen,lpDest
	mov		edi,lpDest
	add		edi,eax
	invoke lstrcpy,edi,addr buffer
	.if fComma
		invoke lstrlen,lpDest
		mov		edi,lpDest
		add		edi,eax
		mov		word ptr [edi],','
	.endif
	ret

StrPutValue endp

StrPutString proc uses edi,lpStr:DWORD,lpDest:DWORD,fComma:DWORD

	invoke lstrlen,lpDest
	mov		edi,lpDest
	add		edi,eax
	invoke lstrcpy,edi,lpStr
	.if fComma
		invoke lstrlen,lpDest
		mov		edi,lpDest
		add		edi,eax
		mov		word ptr [edi],','
	.endif
	ret

StrPutString endp

