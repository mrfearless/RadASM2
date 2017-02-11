
FUNCSHL							equ 1
FUNCSHR							equ 2
FUNCAND							equ 3
FUNCOR							equ 4
FUNCXOR							equ 5
FUNCADDR						equ 6
FUNCSIZEOF						equ 7

.const

szFUNC							db 'SHL',0,
								   'SHR',0,
								   'AND',0,
								   'OR',0,
								   'XOR',0,
								   'ADDR',0,
								   'SIZEOF',0,0

.code

GetFunc proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	nFunc:DWORD
	LOCAL	nLen:DWORD

	mov		al,[esi]
	.if al<'A'
		jmp		Ex
	.endif
	lea		edi,buffer
	xor		ecx,ecx
	mov		nFunc,ecx
	.while TRUE
		mov		al,[esi+ecx]
		.if (al>='A' && al<='Z') || (al>='a' && al<='z')
			mov		[edi+ecx],al
		.else
			xor		eax,eax
			.break
		.endif
		inc		ecx
	.endw
	mov		[edi+ecx],al
	mov		ebx,offset szFUNC
	lea		edi,buffer
	.while byte ptr [ebx]
		inc		nFunc
		push	ecx
		invoke strcmpi,ebx,edi
		pop		ecx
		.if !eax
			mov		eax,nFunc
			jmp		Ex
		.endif
		push	ecx
		invoke strlen,ebx
		pop		ecx
		lea		ebx,[ebx+eax+1]
	.endw
	mov		al,[esi]
  Ex:
	ret

GetFunc endp

; esi is a pointer to the value
GetValue proc uses ebx edi
	LOCAL	buffer[256]:BYTE
	LOCAL	nLen:DWORD

	push	esi
	mov		nLen,0
	lea		edi,buffer
	.while TRUE
		mov		al,[esi]
		.if (al>='0' && al<='9') || (al>='A' && al<='Z') || (al>='a' && al<='z') || al=='_'
			mov		[edi],al
			inc		edi
			inc		esi
			inc		nLen
		.else
			.break
		.endif
	.endw
	mov		byte ptr [edi],0
	lea		edi,buffer
	mov		al,[edi]
	.if al>='0' && al<='9'
		; Hex or Decimal
		invoke IsDec,edi
		.if eax
			mov		mFunc,'H'
			invoke DecToBin,edi
			jmp		Ex
		.else
			invoke IsHex,edi
			.if eax
				mov		mFunc,'H'
				invoke HexToBin,edi
				jmp		Ex
			.endif
		.endif
		mov		nError,ERR_SYNTAX
		invoke strcpy,addr szError,addr buffer
		xor		eax,eax
		jmp		Ex
	.else
		; Variable
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
			inc		nLen
		.endw
		.if byte ptr [esi]=='('
			lea		edi,buffer
			invoke strlen,edi
			lea		edi,[edi+eax]
			xor		ecx,ecx
			.while byte ptr [esi]
				mov		al,[esi]
				.if al!=VK_SPACE && al!=VK_TAB
					mov		[edi],al
					inc		edi
				.endif
				inc		esi
				inc		nLen
				.if al=='('
					inc		ecx
				.elseif al==')'
					dec		ecx
					.break .if ZERO?
				.endif
			.endw
			mov		byte ptr [edi],0
		.endif
		push	mFunc
		invoke GetVarVal,addr buffer,dbg.prevline,FALSE
		pop		mFunc
		.if eax
			.if !mFunc
				mov		mFunc,eax
			.endif
			mov		eax,var.Value
			jmp		Ex
		.else
			invoke FindTypeSize,addr buffer
			.if !edx
				.if var.nErr
					mov		eax,var.nErr
					mov		nError,eax
				.else
					mov		nError,ERR_NOTFOUND
				.endif
				invoke strcpy,addr szError,addr buffer
				xor		eax,eax
				jmp		Ex
			.endif
			mov		var.nErr,0
			mov		mFunc,'H'
		.endif
	.endif
  Ex:
	pop		esi
	add		esi,nLen
	ret

GetValue endp

; esi is a pointer to the math
CalculateIt proc uses ebx edi,PrevFunc:DWORD

  Nxt:
  	.if nError || byte ptr [esi]==';'
  		ret
  	.endif
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
		inc		esi
	.endw
	push	eax
	invoke GetFunc
	mov		edx,ecx
	movzx	ecx,al
	pop		eax
	mov		ebx,PrevFunc
	.if !ecx
		ret
	.elseif ecx==FUNCSHL
		mov		mFunc,'H'
		lea		esi,[esi+edx]
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		xchg	eax,ecx
		shl		eax,cl
	.elseif ecx==FUNCSHR
		mov		mFunc,'H'
		lea		esi,[esi+edx]
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		xchg	eax,ecx
		shr		eax,cl
	.elseif ecx==FUNCADDR
		mov		mFunc,'H'
		lea		esi,[esi+edx]
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		.if byte ptr [esi]=='('
			inc		esi
			mov		var.Address,0
			invoke CalculateIt,ecx
			.if byte ptr [esi]==')' && !nError
				mov		eax,var.Address
			.else
				mov		nError,ERR_SYNTAX
				ret
			.endif
		.else
			mov		nError,ERR_SYNTAX
			ret
		.endif
	.elseif ecx==FUNCSIZEOF
		mov		mFunc,'H'
		lea		esi,[esi+edx]
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		.if byte ptr [esi]=='('
			inc		esi
			mov		var.nArray,0
			mov		var.nSize,0
			mov		var.nInx,0
			invoke CalculateIt,ecx
			.if byte ptr [esi]==')' && !nError
				inc		esi
				.if var.nArray
					mov		eax,var.nArray
					sub		eax,var.nInx
					mov		edx,var.nSize
					mul		edx
				.endif
			.else
				mov		nError,ERR_SYNTAX
				ret
			.endif
		.else
			mov		var.nArray,0
			mov		var.nSize,0
			mov		var.nInx,0
			invoke CalculateIt,ecx
			.if !nError
				.if var.nArray
					mov		eax,var.nArray
					sub		eax,var.nInx
					mov		edx,var.nSize
					mul		edx
				.endif
			.else
				mov		nError,ERR_SYNTAX
				ret
			.endif
		.endif
	.elseif ecx==FUNCAND
		mov		mFunc,'H'
		.if ebx=='*' || ebx=='/' || ebx=='+' || ebx=='-' || ebx==FUNCSHL || ebx==FUNCSHR || ebx==FUNCSIZEOF
			ret
		.endif
		lea		esi,[esi+edx]
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		xchg	eax,ecx
		and		eax,ecx
	.elseif ecx==FUNCOR
		mov		mFunc,'H'
		.if ebx=='*' || ebx=='/' || ebx=='+' || ebx=='-' || ebx==FUNCSHL || ebx==FUNCSHR || ebx==FUNCAND || ebx==FUNCSIZEOF
			ret
		.endif
		lea		esi,[esi+edx]
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		xchg	eax,ecx
		or		eax,ecx
	.elseif ecx==FUNCXOR
		mov		mFunc,'H'
		.if ebx=='*' || ebx=='/' || ebx=='+' || ebx=='-' || ebx==FUNCSHL || ebx==FUNCSHR || ebx==FUNCAND || ebx==FUNCOR || ebx==FUNCSIZEOF
			ret
		.endif
		lea		esi,[esi+edx]
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		xchg	eax,ecx
		xor		eax,ecx
	.elseif ecx=='('
		mov		mFunc,'H'
		inc		esi
		invoke CalculateIt,ecx
	.elseif ecx==')'
		mov		mFunc,'H'
		.if  ebx==FUNCSIZEOF || ebx==FUNCADDR
			ret
		.endif
		inc		esi
		ret
	.elseif ecx=='+'
		mov		mFunc,'H'
		.if ebx=='*' || ebx=='/' || ebx==FUNCSHL || ebx==FUNCSHR || ebx==FUNCSIZEOF
			ret
		.endif
		inc		esi
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		xchg	eax,ecx
		add		eax,ecx
	.elseif ecx=='-'
		mov		mFunc,'H'
		.if ebx=='*' || ebx=='/' || ebx==FUNCSHL || ebx==FUNCSHR || ebx==FUNCSIZEOF
			ret
		.endif
		inc		esi
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		xchg	eax,ecx
		sub		eax,ecx
	.elseif ecx=='*'
		mov		mFunc,'H'
		.if ebx=='*' || ebx=='/' || ebx==FUNCSHL || ebx==FUNCSHR || ebx==FUNCSIZEOF
			ret
		.endif
		inc		esi
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		mul		ecx
	.elseif ecx=='/'
		mov		mFunc,'H'
		.if ebx=='*' || ebx=='/' || ebx==FUNCSHL || ebx==FUNCSHR || ebx==FUNCSIZEOF
			ret
		.endif
		inc		esi
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		xor		edx,edx
		xchg	eax,ecx
		div		ecx
	.elseif word ptr [esi]=='..'
		; Array 1..2
		add		esi,2
		push	eax
		invoke CalculateIt,ecx
		pop		ecx
		sub		eax,ecx
	.else
		push	esi
		invoke GetValue
		pop		edx
		.if esi==edx
			mov		nError,ERR_SYNTAX
			ret
		.endif
	.endif
	jmp		Nxt

CalculateIt endp

DoMath proc uses ebx esi edi,lpMath:DWORD

	mov		nError,0
	mov		mFunc,0
	mov		esi,lpMath
	xor		eax,eax
	invoke CalculateIt,0
	.if !nError
		mov		var.Value,eax
		mov		eax,esi
		sub		eax,lpMath
		jmp		Ex
	.endif
	xor		eax,eax
  Ex:
	ret

DoMath endp
