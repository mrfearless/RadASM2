GetFileIDFromProjectFileID		PROTO	:DWORD
AnyBreakPoints					PROTO

.const

FP_EQUALTO	equ	40h

ten16		dq	1.0e16

ten			dq	10.0

ten_1		dt	1.0e1
			dt	1.0e2
			dt	1.0e3
			dt	1.0e4
			dt	1.0e5
			dt	1.0e6
			dt	1.0e7
			dt	1.0e8
			dt	1.0e9
			dt	1.0e10
			dt	1.0e11
			dt	1.0e12
			dt	1.0e13
			dt	1.0e14
			dt	1.0e15
ten_16		dt	1.0e16
			dt	1.0e32
			dt	1.0e48
			dt	1.0e64
			dt	1.0e80
			dt	1.0e96
			dt	1.0e112
			dt	1.0e128
			dt	1.0e144
			dt	1.0e160
			dt	1.0e176
			dt	1.0e192
			dt	1.0e208
			dt	1.0e224
			dt	1.0e240
ten_256		dt	1.0e256
			dt	1.0e512
			dt	1.0e768
			dt	1.0e1024
			dt	1.0e1280
			dt	1.0e1536
			dt	1.0e1792
			dt	1.0e2048
			dt	1.0e2304
			dt	1.0e2560
			dt	1.0e2816
			dt	1.0e3072
			dt	1.0e3328
			dt	1.0e3584
			dt	1.0e4096
			dt	1.0e4352
			dt	1.0e4608
			dt	1.0e4864

.code

; String handling
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

strcpyn proc uses esi edi,lpDest:DWORD,lpSource:DWORD,nLen:DWORD

	mov		esi,lpSource
	mov		edx,nLen
	dec		edx
	xor		ecx,ecx
	mov		edi,lpDest
  @@:
	.if sdword ptr ecx<edx
		mov		al,[esi+ecx]
		mov		[edi+ecx],al
		inc		ecx
		or		al,al
		jne		@b
	.else
		mov		byte ptr [edi+ecx],0
	.endif
	ret

strcpyn endp

strcat proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	xor		eax,eax
	xor		ecx,ecx
	dec		eax
	mov		edi,lpDest
  @@:
	inc		eax
	cmp		[edi+eax],cl
	jne		@b
	mov		esi,lpSource
	lea		edi,[edi+eax]
  @@:
	mov		al,[esi+ecx]
	mov		[edi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcat endp

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

strcmp proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	mov		al,[esi+ecx]
	sub		al,[edi+ecx]
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmp endp

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
	sub		al,[edi+ecx]
	jne		@f
	cmp		al,[esi+ecx]
	jne		@b
  @@:
	cbw
	cwde
	ret

strcmpn endp

strcmpi proc uses esi edi,lpStr1:DWORD,lpStr2:DWORD

	mov		esi,lpStr1
	mov		edi,lpStr2
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
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

strcmpi endp

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

; Numbers
DecToBin proc uses ebx esi,lpStr:DWORD
	LOCAL	fNeg:DWORD

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
    ret

DecToBin endp

IsDec proc uses esi,lpStr:DWORD

	mov		esi,lpStr
	.if byte ptr [esi]=='-'
		inc		esi
	.endif
	.while TRUE
		mov		al,[esi]
		.if al>='0' && al<='9'
		.elseif !al || al==']'
			mov		eax,esi
			sub		eax,lpStr
			jmp		Ex
		.else
			.break
		.endif
		inc		esi
	.endw
	xor		eax,eax
  Ex:
	ret

IsDec endp

HexToBin proc uses esi,lpStr:DWORD

	mov		esi,lpStr
	xor		edx,edx
	.while byte ptr [esi]
		mov		al,[esi]
		.if al>='0' && al<='9'
			sub		al,'0'
		.elseif al>='A' && al<='F'
			sub		al,'A'-10
		.elseif al>='a' && al<='f'
			sub		al,'a'-10
		.else
			jmp		Ex
		.endif
		shl		edx,4
		or		dl,al
		inc		esi
	.endw
  Ex:
	mov		eax,edx
    ret

HexToBin endp

IsHex proc uses esi,lpStr:DWORD

	mov		esi,lpStr
	.while byte ptr [esi]
		mov		al,[esi]
		.if al>='0' && al<='9' || al>='A' && al<='F' || al>='a' && al<='f'
		.elseif (al=='h' || al=='H') && (!byte ptr [esi+1] || byte ptr [esi+1]==']')
			mov		eax,esi
			sub		eax,lpStr
			jmp		Ex
		.else
			.break
		.endif
		inc		esi
	.endw
	xor		eax,eax
  Ex:
	ret

IsHex endp

AnyToBin proc lpStr:DWORD

	invoke IsHex,lpStr
	.if eax
		invoke HexToBin,lpStr
		mov		edx,eax
		mov		eax,TRUE
		jmp		Ex
	.else
		invoke IsDec,lpStr
		.if eax
			invoke DecToBin,lpStr
			mov		edx,eax
			mov		eax,TRUE
			jmp		Ex
		.endif
	.endif
	xor		edx,edx
	xor		eax,eax
  Ex:
	ret

AnyToBin endp

PutString proc lpString:DWORD

	invoke SendMessage,hOut1,EM_REPLACESEL,FALSE,lpString
	invoke SendMessage,hOut1,EM_REPLACESEL,FALSE,addr szCR
	invoke SendMessage,hOut1,EM_SCROLLCARET,0,0
	ret

PutString endp

PutStringOut proc lpString:DWORD,hWin:HWND

	invoke SendMessage,hWin,EM_REPLACESEL,FALSE,lpString
	invoke SendMessage,hWin,EM_REPLACESEL,FALSE,addr szCR
	invoke SendMessage,hWin,EM_SCROLLCARET,0,0
	ret

PutStringOut endp

HexBYTE proc uses ebx edi,lpBuff:DWORD,Val:DWORD

	mov		edi,lpBuff
	mov		eax,Val
	mov		ah,al
	shr		al,4
	and		ah,0Fh
	.if al<=9
		add		al,30h
	.else
		add		al,41h-0Ah
	.endif
	.if ah<=9
		add		ah,30h
	.else
		add		ah,41h-0Ah
	.endif
	mov		[edi],ax
	ret

HexBYTE endp

HexWORD proc uses ecx ebx edi,lpBuff:DWORD,Val:DWORD

	mov		edi,lpBuff
	mov		ebx,Val
	rol		ebx,16
	xor		ecx,ecx
	.while ecx<2
		rol		ebx,8
		mov		eax,ebx
		invoke HexBYTE,edi,eax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],0
	ret

HexWORD endp

HexDWORD proc uses ecx ebx edi,lpBuff:DWORD,Val:DWORD

	mov		edi,lpBuff
	mov		ebx,Val
	xor		ecx,ecx
	.while ecx<4
		rol		ebx,8
		mov		eax,ebx
		invoke HexBYTE,edi,eax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],0
	ret

HexDWORD endp

HexQWORD proc uses ecx ebx edi,lpBuff:DWORD,Val:QWORD

	mov		edi,lpBuff
	mov		ebx,dword ptr Val[4]
	xor		ecx,ecx
	.while ecx<4
		rol		ebx,8
		mov		eax,ebx
		invoke HexBYTE,edi,eax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		ebx,dword ptr Val
	xor		ecx,ecx
	.while ecx<4
		rol		ebx,8
		mov		eax,ebx
		invoke HexBYTE,edi,eax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],0
	ret

HexQWORD endp

FpToAscii proc USES esi edi,lpFpin:PTR TBYTE,lpStr:PTR CHAR,fSci:DWORD
	LOCAL	iExp:DWORD
	LOCAL	stat:WORD
	LOCAL	mystat:WORD
	LOCAL	sztemp[32]:BYTE
	LOCAL	temp:TBYTE

	mov		esi,lpFpin
	mov		edi,lpStr
	.if	dword ptr [esi]== 0 && dword ptr [esi+4]==0
		; Special case zero.  fxtract fails for zero.
		mov		word ptr [edi], '0'
		ret
	.endif
	; Check for a negative number.
	push	[esi+6]
	.if	sdword ptr [esi+6]<0
		and		byte ptr [esi+9],07fh	; change to positive
		mov		byte ptr [edi],'-'		; store a minus sign
		inc		edi
	.endif
	fld		TBYTE ptr [esi]
	fld		st(0)
	; Compute the closest power of 10 below the number.  We can't get an
	; exact value because of rounding.  We could get close by adding in
	; log10(mantissa), but it still wouldn't be exact.  Since we'll have to
	; check the result anyway, it's silly to waste cycles worrying about
	; the mantissa.
	;
	; The exponent is basically log2(lpfpin).  Those of you who remember
	; algebra realize that log2(lpfpin) x log10(2) = log10(lpfpin), which is
	; what we want.
	fxtract					; ST=> mantissa, exponent, [lpfpin]
	fstp	st(0)			; drop the mantissa
	fldlg2					; push log10(2)
	fmulp	st(1),st		; ST = log10([lpfpin]), [lpfpin]
	fistp 	iExp			; ST = [lpfpin]
	; A 10-byte double can carry 19.5 digits, but fbstp only stores 18.
	.IF	iExp<18
		fld		st(0)		; ST = lpfpin, lpfpin
		frndint				; ST = int(lpfpin), lpfpin
		fcomp	st(1)		; ST = lpfpin, status set
		fstsw	ax
		.IF ah&FP_EQUALTO && !fSci	; if EQUAL
			; We have an integer!  Lucky day.  Go convert it into a temp buffer.
			call FloatToBCD
			mov		eax,17
			mov		ecx,iExp
			sub		eax,ecx
			inc		ecx
			lea		esi,[sztemp+eax]
			; The off-by-one order of magnitude problem below can hit us here.  
			; We just trim off the possible leading zero.
			.IF byte ptr [esi]=='0'
				inc esi
				dec ecx
			.ENDIF
			; Copy the rest of the converted BCD value to our buffer.
			rep movsb
			jmp ftsExit
		.ENDIF
	.ENDIF
	; Have fbstp round to 17 places.
	mov		eax, 17			; experiment
	sub		eax,iExp		; adjust exponent to 17
	call PowerOf10
	; Either we have exactly 17 digits, or we have exactly 16 digits.  We can
	; detect that condition and adjust now.
	fcom	ten16
	; x0xxxx00 means top of stack > ten16
	; x0xxxx01 means top of stack < ten16
	; x1xxxx00 means top of stack = ten16
	fstsw	ax
	.IF ah & 1
		fmul	ten
		dec		iExp
	.ENDIF
	; Go convert to BCD.
	call FloatToBCD
	lea		esi,sztemp		; point to converted buffer
	; If the exponent is between -15 and 16, we should express this as a number
	; without scientific notation.
	mov ecx, iExp
	.IF SDWORD PTR ecx>=-15 && SDWORD PTR ecx<=16 && !fSci
		; If the exponent is less than zero, we insert '0.', then -ecx
		; leading zeros, then 16 digits of mantissa.  If the exponent is
		; positive, we copy ecx+1 digits, then a decimal point (maybe), then 
		; the remaining 16-ecx digits.
		inc ecx
		.IF SDWORD PTR ecx<=0
			mov		word ptr [edi],'.0'
			add		edi, 2
			neg		ecx
			mov		al,'0'
			rep		stosb
			mov		ecx,18
		.ELSE
			.if byte ptr [esi]=='0' && ecx>1
				inc		esi
				dec		ecx
			.endif
			rep		movsb
			mov		byte ptr [edi],'.'
			inc		edi
			mov		ecx,17
			sub		ecx,iExp
		.ENDIF
		rep movsb
		; Trim off trailing zeros.
		.WHILE byte ptr [edi-1]=='0'
			dec		edi
		.ENDW
		; If we cleared out all the decimal digits, kill the decimal point, too.
		.IF byte ptr [edi-1]=='.'
			dec		edi
		.ENDIF
		; That's it.
		jmp		ftsExit
	.ENDIF
	; Now convert this to a standard, usable format.  If needed, a minus
	; sign is already present in the outgoing buffer, and edi already points
	; past it.
	mov		ecx,17
	.if byte ptr [esi]=='0'
		inc		esi
		dec		iExp
		dec		ecx
	.endif
	movsb						; copy the first digit
	mov		byte ptr [edi],'.'	; plop in a decimal point
	inc		edi
	rep movsb
	; The printf %g specified trims off trailing zeros here.  I dislike
	; this, so I've disabled it.  Comment out the if 0 and endif if you
	; want this.
	.WHILE byte ptr [edi-1]=='0'
		dec		edi
	.ENDW
	.if byte ptr [edi-1]=='.'
		dec		edi
	.endif
	; Shove in the exponent.
	mov		byte ptr [edi],'e'	; start the exponent
	mov		eax,iExp
	.IF sdword ptr eax<0		; plop in the exponent sign
		mov		byte ptr [edi+1],'-'
		neg		eax
	.ELSE
		mov		byte ptr [edi+1],'+'
	.ENDIF
	mov		ecx, 10
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+5],dl		; shove in the ones exponent digit
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+4],dl		; shove in the tens exponent digit
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+3],dl		; shove in the hundreds exponent digit
	xor		edx,edx
	div		ecx
	add		dl,'0'
	mov		[edi+2],dl		; shove in the thousands exponent digit
	add		edi,6			; point to terminator
ftsExit:
	; Clean up and go home.
	mov		esi,lpFpin
	pop		[esi+6]
	mov		byte ptr [edi],0
	fwait
	ret

; Convert a floating point register to ASCII.
; The result always has exactly 18 digits, with zero padding on the
; left if required.
;
; Entry:	ST(0) = a number to convert, 0 <= ST(0) < 1E19.
;			sztemp = an 18-character buffer.
;
; Exit:		sztemp = the converted result.
FloatToBCD:
	push	esi
	push	edi
    fbstp	temp
	; Now we need to unpack the BCD to ASCII.
    lea		esi,[temp]
    lea		edi,[sztemp]
    mov		ecx,8
    .REPEAT
		movzx	ax,byte ptr [esi+ecx]	; 0000 0000 AAAA BBBB
		rol		ax,12					; BBBB 0000 0000 AAAA
		shr		ah,4					; 0000 BBBB 0000 AAAA
		add		ax,3030h				; 3B3A
		stosw
		dec		ecx
    .UNTIL SIGN?
	pop		edi
	pop		esi
    retn

PowerOf10:
    mov		ecx,eax
    .IF	SDWORD PTR eax<0
		neg		eax
    .ENDIF
    fld1
    mov		dl,al
    and		edx,0fh
    .IF	!ZERO?
		lea		edx,[edx+edx*4]
		fld		ten_1[edx*2][-10]
		fmulp	st(1),st
    .ENDIF
    mov		dl,al
    shr		dl,4
    and		edx,0fh
    .IF !ZERO?
		lea		edx,[edx+edx*4]
		fld		ten_16[edx*2][-10]
		fmulp	st(1),st
    .ENDIF
    mov		dl,ah
    and		edx,1fh
    .IF !ZERO?
		lea		edx,[edx+edx*4]
		fld		ten_256[edx*2][-10]
		fmulp	st(1),st
    .ENDIF
    .IF SDWORD PTR ecx<0
		fdivp	st(1),st
    .ELSE
		fmulp	st(1),st
    .ENDIF
    retn

FpToAscii endp

DumpLineBYTE proc uses ebx esi edi,hWin:HWND,nAdr:DWORD,lpDumpData:DWORD,nBytes:DWORD
	LOCAL	buffer[256]:BYTE

	mov		ebx,nAdr
	mov		esi,lpDumpData
	lea		edi,buffer
	xor		ecx,ecx
	.while ecx<4
		rol		ebx,8
		mov		eax,ebx
		invoke HexBYTE,edi,eax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],' '
	inc		edi
	xor		ecx,ecx
	.while ecx<nBytes
		mov		al,[esi+ecx]
		invoke HexBYTE,edi,eax
		add		edi,2
		inc		ecx
		.if ecx==8
			mov		byte ptr [edi],'-'
		.else
			mov		byte ptr [edi],' '
		.endif
		inc		edi
	.endw
	mov		ecx,16
	sub		ecx,nBytes
	.while ecx
		mov		dword ptr [edi],'   '
		add		edi,3
		dec		ecx
	.endw
	xor		ecx,ecx
	.while ecx<nBytes
		mov		al,[esi+ecx]
		.if al<20h || al>=80h
			mov		al,'.'
		.endif
		mov		[edi],al
		inc		edi
		inc		ecx
	.endw
	mov		word ptr [edi],0Dh
	invoke SendMessage,hWin,EM_REPLACESEL,FALSE,addr buffer
	ret

DumpLineBYTE endp

DumpLineWORD proc uses ebx esi edi,hWin:HWND,nAdr:DWORD,lpDumpData:DWORD,nBytes:DWORD
	LOCAL	buffer[256]:BYTE

	mov		ebx,nAdr
	mov		esi,lpDumpData
	lea		edi,buffer
	xor		ecx,ecx
	.while ecx<4
		rol		ebx,8
		mov		eax,ebx
		invoke HexBYTE,edi,eax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],' '
	inc		edi
	xor		ecx,ecx
	.while ecx<nBytes
		mov		ax,[esi+ecx]
		invoke HexWORD,edi,eax
		add		edi,4
		add		ecx,2
		.if ecx==8
			mov		byte ptr [edi],'-'
		.else
			mov		byte ptr [edi],' '
		.endif
		inc		edi
	.endw
	mov		ecx,16
	sub		ecx,nBytes
	.while ecx
		mov		dword ptr [edi],'   '
		add		edi,3
		dec		ecx
	.endw
	xor		ecx,ecx
	.while ecx<nBytes
		mov		al,[esi+ecx]
		.if al<20h || al>=80h
			mov		al,'.'
		.endif
		mov		[edi],al
		inc		edi
		inc		ecx
	.endw
	mov		word ptr [edi],0Dh
	invoke SendMessage,hWin,EM_REPLACESEL,FALSE,addr buffer
	ret

DumpLineWORD endp

DumpLineDWORD proc uses ebx esi edi,hWin:HWND,nAdr:DWORD,lpDumpData:DWORD,nBytes:DWORD
	LOCAL	buffer[256]:BYTE

	mov		ebx,nAdr
	mov		esi,lpDumpData
	lea		edi,buffer
	xor		ecx,ecx
	.while ecx<4
		rol		ebx,8
		mov		eax,ebx
		invoke HexBYTE,edi,eax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],' '
	inc		edi
	xor		ecx,ecx
	.while ecx<nBytes
		mov		eax,[esi+ecx]
		invoke HexDWORD,edi,eax
		add		edi,8
		add		ecx,4
		.if ecx==8
			mov		byte ptr [edi],'-'
		.else
			mov		byte ptr [edi],' '
		.endif
		inc		edi
	.endw
	mov		ecx,16
	sub		ecx,nBytes
	.while ecx
		mov		dword ptr [edi],'   '
		add		edi,3
		dec		ecx
	.endw
	xor		ecx,ecx
	.while ecx<nBytes
		mov		al,[esi+ecx]
		.if al<20h || al>=80h
			mov		al,'.'
		.endif
		mov		[edi],al
		inc		edi
		inc		ecx
	.endw
	mov		word ptr [edi],0Dh
	invoke SendMessage,hWin,EM_REPLACESEL,FALSE,addr buffer
	ret

DumpLineDWORD endp

DumpLineQWORD proc uses ebx esi edi,hWin:HWND,nAdr:DWORD,lpDumpData:DWORD,nBytes:DWORD
	LOCAL	buffer[256]:BYTE

	mov		ebx,nAdr
	mov		esi,lpDumpData
	lea		edi,buffer
	xor		ecx,ecx
	.while ecx<4
		rol		ebx,8
		mov		eax,ebx
		invoke HexBYTE,edi,eax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],' '
	inc		edi
	xor		ecx,ecx
	.while ecx<nBytes
		invoke HexQWORD,edi,qword ptr[esi+ecx]
		add		edi,16
		add		ecx,8
		.if ecx==8
			mov		byte ptr [edi],'-'
		.else
			mov		byte ptr [edi],' '
		.endif
		inc		edi
	.endw
	mov		ecx,16
	sub		ecx,nBytes
	.while ecx
		mov		dword ptr [edi],'   '
		add		edi,3
		dec		ecx
	.endw
	xor		ecx,ecx
	.while ecx<nBytes
		mov		al,[esi+ecx]
		.if al<20h || al>=80h
			mov		al,'.'
		.endif
		mov		[edi],al
		inc		edi
		inc		ecx
	.endw
	mov		word ptr [edi],0Dh
	invoke SendMessage,hWin,EM_REPLACESEL,FALSE,addr buffer
	ret

DumpLineQWORD endp

EnableMenu proc uses esi edi
	LOCAL	hREd:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	nLine:DWORD
	LOCAL	nInx:DWORD

	mov		esi,offset IDAddIn
	mov		eax,lpData
	.if [eax].ADDINDATA.fProject && !fNoDebugInfo
		; Toggle &Breakpoint
		invoke EnableMenuItem,hMnu,[esi+4],MF_BYCOMMAND or MF_GRAYED
		; Run &To Caret
		invoke EnableMenuItem,hMnu,[esi+32],MF_BYCOMMAND or MF_GRAYED
		mov		eax,lpHandles
		.if [eax].ADDINHANDLES.hEdit
			mov		edx,[eax].ADDINHANDLES.hEdit
			mov		hREd,edx
			invoke GetWindowLong,[eax].ADDINHANDLES.hMdiCld,0
			.if eax==ID_EDIT
				.if dbg.hDbgThread
					invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
					mov		nLine,eax
					mov		eax,lpHandles
					invoke GetWindowLong,[eax].ADDINHANDLES.hMdiCld,16
					invoke GetFileIDFromProjectFileID,eax
					.if eax!=-1
						mov		edx,nLine
						inc		edx
						xor		ecx,ecx
						mov		edi,dbg.hMemLine
						.while ecx<dbg.inxline
							.if edx==[edi].DEBUGLINE.LineNumber
								.if ax==[edi].DEBUGLINE.FileID
									.break
								.endif
							.endif
							inc		ecx
							add		edi,sizeof DEBUGLINE
						.endw
						.if ecx!=dbg.inxline
							; Toggle &Breakpoint
							invoke EnableMenuItem,hMnu,[esi+4],MF_BYCOMMAND or MF_ENABLED
							; Run &To Caret
							invoke EnableMenuItem,hMnu,[esi+32],MF_BYCOMMAND or MF_ENABLED
						.endif
					.endif
				.else
					; Toggle &Breakpoint
					invoke EnableMenuItem,hMnu,[esi+4],MF_BYCOMMAND or MF_ENABLED
				.endif
			.endif
		.endif
		; &Clear Breakpoints
		invoke AnyBreakPoints
		.if eax
			invoke EnableMenuItem,hMnu,[esi+8],MF_BYCOMMAND or MF_ENABLED
		.else
			invoke EnableMenuItem,hMnu,[esi+8],MF_BYCOMMAND or MF_GRAYED
		.endif
		; &Run
		invoke EnableMenuItem,hMnu,[esi+12],MF_BYCOMMAND or MF_ENABLED
		; Do not Debug
		invoke EnableMenuItem,hMnu,[esi+36],MF_BYCOMMAND or MF_ENABLED
		.if dbg.hDbgThread
			; Brea&k
			invoke EnableMenuItem,hMnu,[esi+16],MF_BYCOMMAND or MF_ENABLED
			; &Stop
			invoke EnableMenuItem,hMnu,[esi+20],MF_BYCOMMAND or MF_ENABLED
			; Step &Into
			invoke EnableMenuItem,hMnu,[esi+24],MF_BYCOMMAND or MF_ENABLED
			; Step &Over
			mov		eax,MF_BYCOMMAND or MF_GRAYED
			.if dbg.inxsource
				mov		eax,MF_BYCOMMAND or MF_ENABLED
			.endif
			invoke EnableMenuItem,hMnu,[esi+28],eax
		.else
			; Brea&k
			invoke EnableMenuItem,hMnu,[esi+16],MF_BYCOMMAND or MF_GRAYED
			; &Stop
			invoke EnableMenuItem,hMnu,[esi+20],MF_BYCOMMAND or MF_GRAYED
			; Step &Into
			invoke EnableMenuItem,hMnu,[esi+24],MF_BYCOMMAND or MF_GRAYED
			; Step &Over
			invoke EnableMenuItem,hMnu,[esi+28],MF_BYCOMMAND or MF_GRAYED
			; Run &To Caret
			invoke EnableMenuItem,hMnu,[esi+32],MF_BYCOMMAND or MF_GRAYED
		.endif
	.else
		; No project loaded, disable all
		.while dword ptr [esi]
			invoke EnableMenuItem,hMnu,[esi],MF_BYCOMMAND or MF_GRAYED
			add		esi,4
		.endw
	.endif
	ret

EnableMenu endp

FindTypeSize proc uses ebx esi edi,lpType:DWORD
	LOCAL buffer[256]:BYTE

	mov		eax,lpType
	mov		eax,[eax]
	and		eax,0FF5F5F5Fh
	.if eax==' RTP'
		; Found
		mov		edx,TRUE
		mov		eax,4
		jmp		Ex
	.endif
	; Predefined datatypes, case insensitive.
	mov		esi,offset datatype
	.while [esi].DATATYPE.lpszType
		invoke strcmpi,lpType,[esi].DATATYPE.lpszType
		.if !eax
			; Found
			mov		edx,TRUE
			movzx	eax,[esi].DATATYPE.nSize
			jmp		Ex
		.endif
		lea		esi,[esi+sizeof DATATYPE]
	.endw
	; Datatypes from dbghelp, case sensitive
	mov		esi,dbg.hMemType
	xor		ebx,ebx
	.while ebx<dbg.inxtype
		.if fCaseSensitive
			invoke strcmp,addr [esi].DEBUGTYPE.szName,lpType
		.else
			invoke strcmpi,addr [esi].DEBUGTYPE.szName,lpType
		.endif
		.if !eax
			; Found
			mov		edx,TRUE
			mov		eax,[esi].DEBUGTYPE.nSize
			jmp		Ex
		.endif
		lea		esi,[esi+sizeof DEBUGTYPE]
		inc		ebx
	.endw
	; Ansi version
	invoke strcpy,addr buffer,lpType
	invoke strcat,addr buffer,addr szA
	mov		esi,dbg.hMemType
	xor		ebx,ebx
	.while ebx<dbg.inxtype
		invoke strcmp,addr [esi].DEBUGTYPE.szName,addr buffer
		.if !eax
			; Found
			mov		edx,TRUE
			mov		eax,[esi].DEBUGTYPE.nSize
			jmp		Ex
		.endif
		lea		esi,[esi+sizeof DEBUGTYPE]
		inc		ebx
	.endw
	; Widechar version
	invoke strcpy,addr buffer,lpType
	invoke strcat,addr buffer,addr szW
	mov		esi,dbg.hMemType
	xor		ebx,ebx
	.while ebx<dbg.inxtype
		invoke strcmp,addr [esi].DEBUGTYPE.szName,addr buffer
		.if !eax
			; Found
			mov		edx,TRUE
			mov		eax,[esi].DEBUGTYPE.nSize
			jmp		Ex
		.endif
		lea		esi,[esi+sizeof DEBUGTYPE]
		inc		ebx
	.endw
	; Datatypes from RadASM, case sensitive
	mov		edx,lpData
	;Get pointer to word list
	mov		esi,[edx].ADDINDATA.lpWordList
	;Only words loaded from .api files
	mov		edi,[edx].ADDINDATA.rpProjectWordList
	lea		edi,[edi+esi]
	;Loop trough the word list
	.while [esi].PROPERTIES.nSize && esi<edi
		.if [esi].PROPERTIES.nType=='T'
			.if fCaseSensitive
				invoke strcmp,addr [esi+sizeof PROPERTIES],lpType
			.else
				invoke strcmpi,addr [esi+sizeof PROPERTIES],lpType
			.endif
			.if !eax
				; Found
				lea		edi,[esi+sizeof PROPERTIES]
				invoke strlen,edi
				lea		edi,[edi+eax+1]
				invoke DecToBin,edi
				mov		edx,TRUE
				jmp		Ex
			.endif
		.endif
		;Move to next word
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
	; Type size not found
	xor		eax,eax
	xor		edx,edx
  Ex:
	ret

FindTypeSize endp

ImmPromptOn proc

	invoke SendMessage,hOut3,EM_REPLACESEL,FALSE,addr szImmPrompt
	invoke SendMessage,hOut3,EM_SCROLLCARET,0,0
	ret

ImmPromptOn endp

ImmPromptOff proc
	LOCAL	chrg:CHARRANGE
	LOCAL	buffer[32]:BYTE

	invoke SendMessage,hOut3,EM_EXGETSEL,0,addr chrg
	invoke SendMessage,hOut3,EM_LINEFROMCHAR,chrg.cpMin,0
	mov		word ptr buffer,16
	mov		edx,eax
	invoke SendMessage,hOut3,EM_GETLINE,edx,addr buffer
	mov		buffer[eax],0
	.if word ptr buffer==0D3Eh || word ptr buffer==003Eh
		mov		eax,chrg.cpMin
		mov		chrg.cpMax,eax
		dec		chrg.cpMin
		invoke SendMessage,hOut3,EM_EXSETSEL,0,addr chrg
		invoke SendMessage,hOut3,EM_REPLACESEL,FALSE,addr szNULL
		invoke SendMessage,hOut3,EM_SCROLLCARET,0,0
	.endif
	ret

ImmPromptOff endp

FindLine proc uses ebx esi edi,Address:DWORD
	LOCAL	inx:DWORD
	LOCAL	lower:DWORD
	LOCAL	upper:DWORD

	mov		eax,dbg.inxline
	mov		lower,0
	mov		upper,eax
	xor		ebx,ebx
	.while TRUE
		mov		eax,upper
		sub		eax,lower
		.break .if !eax
		shr		eax,1
		add		eax,lower
		mov		inx,eax
		call	Compare
		.if !eax || ebx>30
			; Found
			jmp		Ex
		.elseif sdword ptr eax<0
			; Smaller
			mov		eax,inx
			mov		upper,eax
		.elseif sdword ptr eax>0
			; Larger
			mov		eax,inx
			mov		lower,eax
		.endif
		inc		ebx
	.endw
	; Not found, should never happend
	call	Linear
  Ex:
	mov		eax,edi
	ret

Compare:
	call	GetPointerFromInx
	mov		eax,Address
	sub		eax,[edi].DEBUGLINE.Address
	retn

GetPointerFromInx:
	mov		eax,inx
	mov		edx,sizeof DEBUGLINE
	mul		edx
	mov		edi,dbg.hMemLine
	lea		edi,[edi+eax]
	retn

Linear:
	mov		ebx,dbg.inxline
	mov		edi,dbg.hMemLine
	mov		eax,Address
	.while ebx
		.if eax==[edi].DEBUGLINE.Address
			retn
		.elseif eax<[edi].DEBUGLINE.Address
			lea		edi,[edi-sizeof DEBUGLINE]
			retn
		.endif
		lea		edi,[edi+sizeof DEBUGLINE]
		dec		ebx
	.endw
	lea		edi,[edi-sizeof DEBUGLINE]
	retn

FindLine endp

GetPredefinedDatatype proc uses esi edi,lpType:DWORD

	mov		edi,offset datatype
	.while [edi].DATATYPE.lpszType
		invoke strcmpi,[edi].DATATYPE.lpszType,lpType
		.if !eax
			movzx	edx,[edi].DATATYPE.nSize
			movzx	ecx,[edi].DATATYPE.fSigned
			mov		eax,[edi].DATATYPE.lpszConvertType
			jmp		Ex
		.endif
		lea		edi,[edi+sizeof DATATYPE]
	.endw
	xor		eax,eax
  Ex:
	ret

GetPredefinedDatatype endp

FindSymbol proc uses esi,lpName:DWORD

	;Get pointer to symbol list
	mov		esi,dbg.hMemSymbol
	;Loop trough the symbol list
	.while [esi].DEBUGSYMBOL.szName
		.if fCaseSensitive
			invoke strcmp,lpName,addr [esi].DEBUGSYMBOL.szName
		.else
			invoke strcmpi,lpName,addr [esi].DEBUGSYMBOL.szName
		.endif
		.if !eax
			mov		eax,esi
			jmp		Ex			
		.endif
		;Move to next symbol
		lea		esi,[esi+sizeof DEBUGSYMBOL]
	.endw
	; Not found
	xor		eax,eax
  Ex:
	ret

FindSymbol endp

FindLocalVar proc uses esi edi,lpName:DWORD,lplpLocal:DWORD

	mov		esi,lplpLocal
	mov		esi,[esi]
	.while byte ptr [esi+sizeof DEBUGVAR]
		.if fCaseSensitive
			invoke strcmp,addr [esi+sizeof DEBUGVAR],lpName
		.else
			invoke strcmpi,addr [esi+sizeof DEBUGVAR],lpName
		.endif
		.if !eax
			invoke strlen,addr [esi+sizeof DEBUGVAR]
			invoke strcpy,addr var.szArray,addr [esi+eax+1+sizeof DEBUGVAR]
			mov		eax,[esi].DEBUGVAR.nSize
			mov		var.nSize,eax
			mov		eax,[esi].DEBUGVAR.nArray
			mov		var.nArray,eax
			mov		eax,[esi].DEBUGVAR.nOfs
			mov		var.nOfs,eax
			mov		eax,TRUE
			jmp		Ex
		.endif
		lea		esi,[esi+sizeof DEBUGVAR]
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		invoke strlen,esi
		lea		esi,[esi+eax+1]
	.endw
	mov		eax,lplpLocal
	mov		[eax],esi
	xor		eax,eax
  Ex:
	ret

FindLocalVar endp

FindLastLineNumber proc uses ebx esi,lpLine:DWORD,Address:DWORD

	mov		esi,lpLine
	mov		eax,Address
	xor		ecx,ecx
	xor		ebx,ebx
	.while [esi].DEBUGLINE.LineNumber
		.if eax<[esi].DEBUGLINE.Address
			mov		eax,ebx
			jmp		Ex
		.endif
		.if [esi].DEBUGLINE.LineNumber>ecx
			mov		ecx,[esi].DEBUGLINE.LineNumber
			mov		ebx,esi
		.endif
		lea		esi,[esi+sizeof DEBUGLINE]
	.endw
	xor		eax,eax
  Ex:
	ret

FindLastLineNumber endp

FindLocal proc uses esi,lpName:DWORD,nLine:DWORD
	LOCAL	nOfs:DWORD
	LOCAL	nSize:DWORD
	LOCAL	lpLocal:DWORD

	mov		esi,dbg.lpProc
	invoke FindLine,[esi].DEBUGSYMBOL.Address
	push	eax
	mov		edx,[esi].DEBUGSYMBOL.Address
	add		edx,[esi].DEBUGSYMBOL.nSize
	invoke FindLastLineNumber,eax,edx
	pop		edx
	.if edx && eax
		mov		ecx,[edx].DEBUGLINE.LineNumber
		dec		ecx
		mov		eax,[eax].DEBUGLINE.LineNumber
		dec		eax
		.if nLine>=ecx && nLine<=eax
			movzx	eax,[edx].DEBUGLINE.FileID
			mov		edx,sizeof DEBUGSOURCE
			mul		edx
			add		eax,dbg.hMemSource
			mov		eax,[eax].DEBUGSOURCE.ProjectFileID
			mov		var.ProjectFileID,eax
			mov		eax,[esi].DEBUGSYMBOL.lpType
			mov		lpLocal,eax
			invoke FindLocalVar,lpName,addr lpLocal
			.if eax
				mov		edx,var.nInx
				.if edx<var.nArray
					; PROC Parameter
					mov		eax,var.nSize
					mul		edx
					add		eax,dbg.context.regEbp
					add		eax,var.nOfs
					.if nAsm!=nFP && nAsm!=nBCET
						add		eax,4
					.endif
					mov		var.Address,eax
					invoke strcpy,addr var.szName,lpName
					mov		eax,'P'
					jmp		Ex
				.endif
			.else
				; LOCAL
				mov		eax,lpLocal
				lea		eax,[eax+sizeof DEBUGVAR+2]
				mov		lpLocal,eax
				invoke FindLocalVar,lpName,addr lpLocal
				.if eax
					mov		edx,var.nInx
					.if edx<var.nArray
						mov		eax,var.nSize
						mul		edx
						add		eax,dbg.context.regEbp
						.if nAsm==nFP || nAsm==nBCET
							add		eax,var.nOfs
						.else
							sub		eax,var.nOfs
						.endif
						mov		var.Address,eax
						invoke strcpy,addr var.szName,lpName
						mov		eax,'L'
						jmp		Ex
					.endif
				.endif
			.endif
		.endif
	.endif
	xor		eax,eax
  Ex:
	ret

FindLocal endp

FindReg proc uses esi,lpName:DWORD

	mov		esi,offset reg32
	.while [esi].REG.szName
		invoke strcmpi,lpName,addr [esi].REG.szName
		.if !eax
			mov		eax,esi
			jmp		Ex
		.endif
		lea		esi,[esi+sizeof REG]
	.endw
	xor		eax,eax
  Ex:
	ret

FindReg endp

GetIndex proc uses esi,lpVar:DWORD

	mov		esi,lpVar
	.while byte ptr [esi]
		.if byte ptr [esi]=='('
			mov		byte ptr [esi],0
			inc		esi
			invoke CalculateIt,'('
			jmp		Ex
		.endif
		inc		esi
	.endw
	xor		eax,eax
  Ex:
	ret

GetIndex endp

FindVar proc uses esi edi,lpName:DWORD,nLine:DWORD

	push	var.IsSZ
	invoke RtlZeroMemory,addr var,sizeof var
	pop		var.IsSZ
	invoke GetIndex,lpName
	mov		var.nInx,eax
	invoke FindReg,lpName
	.if eax
		; REGISTER
		mov		esi,eax
		invoke strcpy,addr var.szName,lpName
		mov		eax,[esi].REG.nSize
		mov		var.nSize,eax
		mov		eax,[esi].REG.nOfs
		lea		eax,[dbg.context+eax]
		mov		var.Address,eax
		mov		eax,'R'
		jmp		Ex
	.endif
	.if dbg.lpProc
		; Is in a proc, find parameter or local
		invoke FindLocal,lpName,nLine
		.if eax
			jmp		Ex
		.endif
	.endif
	mov		var.ProjectFileID,0
	; Global
	invoke FindSymbol,lpName
	.if eax
		mov		esi,eax
		invoke strcpy,addr var.szName,addr [esi].DEBUGSYMBOL.szName
		.if [esi].DEBUGSYMBOL.nType=='p'
			; PROC
			mov		var.nType,99
			mov		eax,[esi].DEBUGSYMBOL.nSize
			mov		var.nSize,eax
			mov		eax,[esi].DEBUGSYMBOL.Address
			mov		var.Address,eax
			mov		var.nArray,1
			mov		eax,'p'
			jmp		Ex
		.elseif [esi].DEBUGSYMBOL.nType=='d'
			; GLOBAL
			mov		eax,var.nInx
			mov		edx,[esi].DEBUGSYMBOL.nSize
			mul		edx
			add		eax,[esi].DEBUGSYMBOL.Address
			mov		var.Address,eax
			mov		eax,[esi].DEBUGSYMBOL.nSize
			mov		var.nSize,eax
			movzx	eax,[esi].DEBUGSYMBOL.nType
			mov		var.nType,eax
			mov		esi,[esi].DEBUGSYMBOL.lpType
			; Point to type
			mov		eax,var.nInx
			.if eax<[esi].DEBUGVAR.nArray
				mov		eax,[esi].DEBUGVAR.nArray
				mov		var.nArray,eax
				invoke strlen,addr [esi+sizeof DEBUGVAR]
				lea		edi,[esi+eax+1+sizeof DEBUGVAR]
				invoke strcpy,addr var.szArray,edi
				mov		eax,'d'
				jmp		Ex
			.else
				mov		var.nErr,ERR_INDEX
				xor		eax,eax
				jmp		Ex
			.endif
		.endif
	.else
		invoke IsHex,lpName
		.if eax
			invoke HexToBin,lpName
			mov		var.Value,eax
			mov		eax,'H'
			jmp		Ex
		.else
			invoke IsDec,lpName
			.if eax
				invoke DecToBin,lpName
				mov		var.Value,eax
				mov		eax,'D'
				jmp		Ex
			.endif
		.endif
	.endif
	mov		var.nErr,ERR_NOTFOUND
	xor		eax,eax
  Ex:
	ret

FindVar endp

FormatOutput proc uses ebx,lpOutput:DWORD

	.if var.lpFormat
		mov		ebx,esp
		mov		edx,var.nFormat
		.if edx & FMT_SZ
			lea		eax,var.szValue
			push	eax
		.endif
		.if edx & FMT_DEC
			push	var.Value
		.endif
		.if edx & FMT_HEX
			push	var.Value
		.endif
		.if edx & FMT_SIZE
			push	var.nSize
		.endif
		.if edx & FMT_ADDRESS
			push	var.Address
		.endif
		.if edx & FMT_TYPE
			lea		eax,var.szArray
			push	eax
		.endif
		.if edx & FMT_NAME
			lea		eax,var.szName
			push	eax
		.endif
		invoke wsprintf,lpOutput,var.lpFormat
		mov		esp,ebx
	.endif
	ret

FormatOutput endp

GetVarVal proc uses ebx esi edi,lpName:DWORD,nLine:DWORD,fShow:DWORD

	mov		var.Value,0
	invoke FindVar,lpName,nLine
	.if eax=='R'
		; REGISTER
		mov		eax,var.Address
		mov		eax,[eax]
		mov		edx,var.nSize
		.if edx==2
			movzx	eax,ax
			mov		edx,offset szReg16
		.elseif edx==1
			movzx	eax,al
			mov		edx,offset szReg8
		.elseif edx==3
			movzx	eax,ah
			mov		edx,offset szReg8
		.else
			mov		edx,offset szReg32
		.endif
		mov		var.Value,eax
		mov		var.lpFormat,edx
		mov		var.nFormat,FMT_NAME or FMT_HEX or FMT_DEC
	.elseif eax=='p'
		; PROC
		mov		var.lpFormat,offset szProc
		mov		var.nFormat,FMT_NAME or FMT_SIZE
	.elseif eax=='d'
		; GLOBAL
		mov		eax,var.nSize
		.if eax
			; Known size
			.if var.IsSZ==1
				mov		eax,var.nArray
				sub		eax,var.nInx
				.if eax>256
					mov		eax,256
				.endif
				invoke ReadProcessMemory,dbg.hdbghand,var.Address,addr var.szValue,eax,0
				mov		var.lpFormat,offset szDataSZ
				mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE or FMT_SZ
			.elseif var.IsSZ==2
				.if nAsm==nFP || nAsm==nBCET
					mov		ebx,var.Address
					invoke ReadProcessMemory,dbg.hdbghand,ebx,addr var.Address,4,0
					mov		ebx,var.Address
					invoke ReadProcessMemory,dbg.hdbghand,addr [ebx-4],addr var.nArray,4,0
					mov		eax,var.nArray
					sub		eax,var.nInx
					.if eax>256
						mov		eax,256
					.endif
					invoke ReadProcessMemory,dbg.hdbghand,var.Address,addr var.szValue,eax,0
					mov		var.lpFormat,offset szDataS
					mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE or FMT_SZ
				.else
					mov		var.nErr,ERR_SYNTAX
				.endif
			.else
				.if eax==3 || eax>4
					; Struct ,union ,QWORD or TBYTE
					mov		var.lpFormat,offset szData
					mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE
				.else
					invoke ReadProcessMemory,dbg.hdbghand,var.Address,addr var.Value,var.nSize,0
					mov		eax,var.nSize
					mov		edx,offset szData32
					.if eax==1
						mov		edx,offset szData8
					.elseif eax==2
						mov		edx,offset szData16
					.endif
					mov		var.lpFormat,edx
					mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE or FMT_HEX or FMT_DEC
				.endif
			.endif
		.else
			; Unknown size
			mov		var.lpFormat,offset szData
			mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE
		.endif
	.elseif eax=='P'
		; PROC Parameter
		mov		eax,var.nSize
		.if eax==3 || eax>4
			; Struct ,union ,QWORD or TBYTE
			mov		var.lpFormat,offset szParam
			mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE
		.else
			invoke ReadProcessMemory,dbg.hdbghand,var.Address,addr var.Value,var.nSize,0
			mov		eax,var.nSize
			mov		edx,offset szParam32
			.if eax==2
				mov		edx,offset szParam16
			.elseif eax==1
				mov		edx,offset szParam8
			.endif
			mov		var.lpFormat,edx
			mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE or FMT_HEX or FMT_DEC
		.endif
	.elseif eax=='L'
		; LOCAL
		mov		eax,var.nSize
		.if eax
			.if var.IsSZ==1
				mov		eax,var.nArray
				sub		eax,var.nInx
				.if eax>255
					mov		eax,255
				.endif
				invoke ReadProcessMemory,dbg.hdbghand,var.Address,addr var.szValue,eax,0
				mov		var.lpFormat,offset szLocalSZ
				mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE or FMT_SZ
			.elseif var.IsSZ==2
				.if nAsm==nFP || nAsm==nBCET
					mov		ebx,var.Address
					invoke ReadProcessMemory,dbg.hdbghand,ebx,addr var.Address,4,0
					mov		ebx,var.Address
					invoke ReadProcessMemory,dbg.hdbghand,addr [ebx-4],addr var.nArray,4,0
					mov		eax,var.nArray
					sub		eax,var.nInx
					.if eax>255
						mov		eax,255
					.endif
					invoke ReadProcessMemory,dbg.hdbghand,var.Address,addr var.szValue,eax,0
					mov		var.lpFormat,offset szLocalS
					mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE or FMT_SZ
				.else
					mov		var.nErr,ERR_SYNTAX
				.endif
			.else
				.if eax==3 || eax>4
					; Struct ,union ,QWORD or TBYTE
					mov		var.lpFormat, offset szLocal
					mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE
				.else
					invoke ReadProcessMemory,dbg.hdbghand,var.Address,addr var.Value,var.nSize,0
					mov		eax,var.nSize
					mov		edx,offset szLocal32
					.if eax==2
						mov		edx,offset szLocal16
					.elseif eax==1
						mov		edx,offset szLocal8
					.endif
					mov		var.lpFormat,edx
					mov		var.nFormat,FMT_NAME or FMT_TYPE or FMT_ADDRESS or FMT_SIZE or FMT_HEX or FMT_DEC
				.endif
			.endif
		.endif
	.elseif eax=='H' || eax=='D'
		; Hex or Decimal value
		mov		var.lpFormat,offset szValue
		mov		var.nFormat,FMT_HEX or FMT_DEC
	.else
		.if var.nErr==ERR_NOTFOUND
			mov		var.lpFormat,offset szErrVariableNotFound
			mov		var.nFormat,FMT_NAME
		.elseif var.nErr==ERR_INDEX
			mov		var.lpFormat,offset szErrIndexOutOfRange
			mov		var.nFormat,FMT_NAME
		.endif
		.if fShow
			invoke FormatOutput,addr outbuffer
		.endif
		xor		eax,eax
		jmp		Ex
	.endif
	.if fShow
		invoke FormatOutput,addr outbuffer
	.endif
	mov		eax,TRUE
  Ex:
	ret

GetVarVal endp

GetVarAdr proc lpName:DWORD,nLine:DWORD

	invoke FindVar,lpName,nLine
	.if eax=='R' || eax=='P' || eax=='L'
		; REGISTER, PROC Parameter or LOCAL
	.elseif eax=='d'
		; GLOBAL
		.if !var.nType
			xor		eax,eax
		.endif
	.else
		xor		eax,eax
		jmp		Ex
	.endif
  Ex:
	ret

GetVarAdr endp

WatchVars proc uses esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	outbuff[4096]:BYTE
	LOCAL	nLine:DWORD
	LOCAL	LineChangedInx:DWORD

	mov		esi,offset szWatchList
	.if byte ptr [esi]
		mov		outbuff,0
		mov		LineChangedInx,0
		mov		LineChanged,-1
		mov		nLine,0
		mov		edi,offset szOldWatch
		.while byte ptr [esi]
			invoke strcpy,addr buffer,esi
			.if word ptr buffer==':z' || word ptr buffer==':Z'
				mov		var.IsSZ,1
				invoke GetVarVal,addr buffer[2],dbg.prevline,TRUE
			.elseif word ptr buffer==':s' || word ptr buffer==':S'
				mov		var.IsSZ,2
				invoke GetVarVal,addr buffer[2],dbg.prevline,TRUE
			.else
				invoke GetVarVal,addr buffer,dbg.prevline,TRUE
			.endif
			.if !eax
				invoke wsprintf,addr outbuffer,addr szErrVariableNotFound,esi
			.endif
			invoke strcmpn,addr outbuffer,edi,255
			.if eax
				mov		edx,LineChangedInx
				lea		edx,[edx*4+offset LineChanged]
				mov		eax,nLine
				mov		[edx],eax
				mov		dword ptr [edx+4],-1
				inc		LineChangedInx
				invoke strcpyn,edi,addr outbuffer,256
			.endif
			invoke strcat,addr outbuff,addr outbuffer
			invoke strcat,addr outbuff,addr szCR
			invoke strlen,esi
			inc		nLine
			lea		esi,[esi+eax+1]
			lea		edi,[edi+256]
		.endw
		invoke SetWindowText,hDbgWatch,addr outbuff
		mov		esi,offset LineChanged
		.while dword ptr [esi]!=-1
			invoke SendMessage,hDbgWatch,REM_LINEREDTEXT,[esi],TRUE
			lea		esi,[esi+4]
		.endw
	.endif
	ret

WatchVars endp
