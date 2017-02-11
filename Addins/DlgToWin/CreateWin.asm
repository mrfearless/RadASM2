.code

BinToDec proc dwVal:DWORD,lpAscii:DWORD

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
	push	edi
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
	pop		eax
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

BinToDec endp

BinToHex proc uses esi edi,val:DWORD,lpDest:DWORD
	LOCAL	buffer[8]:BYTE
	LOCAL	pRet:DWORD

	lea     edi,buffer[7]
	mov		eax,val
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	lea		esi,buffer
	mov		edi,lpDest
	xor		edx,edx
	mov		ecx,8
  @@:
	mov		al,[esi]
	mov		[edi],al
	.if al!='0'
        .if !edx && al>='A'
        	mov    byte ptr [edi],'0'
        	inc    edi
        	mov		[edi],al
        .endif
		mov		edx,1
	.endif
	add		edi,edx
	inc		esi
	dec		ecx
	jne		@b
    .if !edx
		inc		edi
    .endif
	mov		word ptr [edi],'h'
	inc		edi
	mov		eax,edi
	ret

  hexNibble:
	push    eax
	and     eax,0Fh
	cmp     eax,0Ah
	jb      hexNibble1
	add     eax,07h
  hexNibble1:
	add     eax,30h
	mov     [edi],al
	dec     edi
	pop     eax
	shr     eax,4
	pop		pRet
	jmp		pRet

BinToHex endp

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

StrInStr proc uses esi edi,lpStr:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	mov		esi,lpSrc
	lea		edi,buffer
  Nxt:
	mov		al,[esi]
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		Nxt
	mov		edi,lpStr
	dec		edi
  Nxt1:
	inc		edi
	push	edi
	lea		esi,buffer
  Nxt2:
	mov		ah,[esi]
	or		ah,ah
	je		Found
	mov		al,[edi]
	or		al,al
	je		NotFound
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	inc		esi
	inc		edi
	cmp		al,ah
	je		Nxt2
	pop		edi
	jmp		Nxt1
  Found:
	pop		eax
	sub		eax,lpStr
    ret
  NotFound:
	pop		eax
	mov		eax,-1
    ret

StrInStr endp

GetClass proc nCtl:DWORD
	LOCAL	buffer[2048]:BYTE

	invoke lstrcpy,addr buffer,addr szClass
	mov		eax,nCtl
	.while eax
		push	eax
		invoke StrGetItem,addr sClassName,addr buffer
		invoke StrGetItem,addr sClass,addr buffer
		pop		eax
		dec		eax
	.endw
	ret

GetClass endp

GetCaption proc nCtl:DWORD
	LOCAL	buffer[2048]:BYTE

	invoke lstrcpy,addr buffer,addr szCaption
	mov		eax,nCtl
	.while eax
		push	eax
		invoke StrGetItem,addr sCaption,addr buffer
		invoke StrGetItem,addr sName,addr buffer
		pop		eax
		dec		eax
	.endw
	ret

GetCaption endp

GetCreate proc uses edi,lpDest:DWORD,lpCtrl:DWORD,lpIndent:DWORD

	mov		edi,lpDest
	invoke lstrcpy,edi,lpIndent
	invoke lstrlen,lpIndent
	add		edi,eax
	invoke lstrcpy,edi,addr szCreateWindow
	add		edi,sizeof szCreateWindow-1
	mov		esi,lpCtrl
	mov		eax,DIALOG.exstyle[esi]
	invoke BinToHex,eax,edi
	mov		edi,eax
	mov		al,','
	stosb
	invoke lstrcpy,edi,addr szAddr
	add		edi,5
	mov		eax,DIALOG.ntype[esi]
	.if eax>32
		;Custom control. Use the typeid to identify control
		mov		eax,DIALOG.ntypeid[esi]
		mov		edx,offset CustClassTranslate
		.while dword ptr [edx]
			.break .if eax==[edx]
			add		edx,8
		.endw
		mov		eax,[edx+4]
	.endif
	add		eax,offset nClass
	xor		edx,edx
	mov		dl,[eax]
	inc		edx
	invoke GetClass,edx
	invoke lstrcpy,edi,addr sClassName
	invoke lstrlen,addr sClassName
	add		edi,eax
	mov		al,','
	stosb
	mov		al,DIALOG.caption[esi]
	.if al
		invoke lstrcpy,edi,addr szAddr
		add		edi,5
		mov		eax,DIALOG.ntype[esi]
		.if eax>32
			;Custom control. Use the typeid to identify control
			mov		eax,DIALOG.ntypeid[esi]
			mov		edx,offset CustClassTranslate
			.while dword ptr [edx]
				.break .if eax==[edx]
				add		edx,8
			.endw
			mov		eax,[edx+4]
		.endif
		push	eax
		add		eax,2
		invoke GetCaption,eax
		invoke lstrlen,addr sCaption
		lea		edx,sCaption
		add		edx,eax
		pop		eax
		shl		eax,2
		add		eax,offset nCaption
		mov		eax,[eax]
		invoke BinToDec,eax,edx
		invoke lstrcpy,edi,addr sCaption
		invoke lstrlen,addr sCaption
		add		edi,eax
	.else
		mov		al,'0'
		stosb
	.endif
	mov		al,','
	stosb
	mov		eax,DIALOG.style[esi]
	invoke BinToHex,eax,edi
	mov		edi,eax
	mov		al,','
	stosb
	mov		eax,DIALOG.x[esi]
	invoke BinToDec,eax,edi
	mov		edi,eax
	mov		al,','
	stosb
	mov		eax,DIALOG.y[esi]
	invoke BinToDec,eax,edi
	mov		edi,eax
	mov		al,','
	stosb
	mov		eax,DIALOG.ccx[esi]
	invoke BinToDec,eax,edi
	mov		edi,eax
	mov		al,','
	stosb
	mov		eax,DIALOG.ccy[esi]
	invoke BinToDec,eax,edi
	mov		edi,eax
	mov		al,','
	stosb
	mov		eax,DIALOG.ntype[esi]
	.if eax
		invoke lstrcpy,edi,addr szhWin
		add		edi,4
		mov		al,','
		stosb
		mov		al,DIALOG.idname[esi]
		mov		edx,DIALOG.id[esi]
		.if al && edx
			lea		eax,DIALOG.idname[esi]
			push	eax
			invoke lstrcpy,edi,eax
			pop		eax
			invoke lstrlen,eax
			add		edi,eax
		.else
			mov		eax,DIALOG.id[esi]
			invoke BinToDec,eax,edi
			mov		edi,eax
		.endif
		mov		al,','
		stosb
		invoke lstrcpy,edi,addr szhInstance
		add		edi,9
		mov		al,','
		stosb
	.else
		mov		al,'0'
		stosb
		mov		al,','
		stosb
		mov		al,'0'
		stosb
		mov		al,','
		stosb
		invoke lstrcpy,edi,addr szhInst
		add		edi,5
		mov		al,','
		stosb
	.endif
	mov		al,'0'
	stosb
	mov		al,0Dh
	stosb
	mov		al,0Ah
	stosb
	mov		al,0
	mov		[edi],al
	mov		eax,edi
	ret

GetCreate endp

BuildEqu proc lpDest:DWORD,lpIndent:DWORD,lpName:DWORD,nID:DWORD

	invoke lstrcpy,lpDest,lpIndent
	invoke lstrlen,lpIndent
	add		lpDest,eax
	invoke lstrcpy,lpDest,lpName
	invoke lstrlen,lpName
	mov		edx,lpDest
	add		edx,eax
	and		eax,1Ch
	.while eax<32
		mov		byte ptr [edx],09h
		inc		edx
		add		eax,4
	.endw
	mov		eax,' uqe'
	mov		[edx],eax
	add		edx,4
	mov		lpDest,edx
	mov		eax,nID
	invoke BinToDec,eax,lpDest
	invoke lstrlen,lpDest
	mov		edx,lpDest
	add		edx,eax
	mov		eax,0A0Dh
	mov		[edx],eax
	add		edx,2
	mov		eax,edx
	ret

BuildEqu endp

BuildCtlID proc uses esi,lpDest:DWORD,lpIndent:DWORD
	LOCAL	buffer[4096]:BYTE

	mov		eax,lpHStruct
	mov		eax,ADDINHANDLES.hMdiCld[eax]
	invoke GetWindowLong,eax,4
	mov		esi,eax
	add		esi,sizeof DLGHEAD
  Nx:
	mov		al,DIALOG.idname[esi]
	.if al
		mov		eax,DIALOG.id[esi]
		.if eax
			lea		edx,DIALOG.idname[esi]
			invoke BuildEqu,lpDest,lpIndent,edx,eax
			mov		lpDest,eax
		.endif
	.endif
  @@:
	add		esi,sizeof DIALOG
	cmp		DIALOG.hwnd[esi],-1
	je		@b
	cmp		DIALOG.hwnd[esi],0
	jne		Nx
	mov		eax,lpDest
	ret

BuildCtlID endp

BuildMnuID proc uses esi,hMnuMem:DWORD,lpDest:DWORD,lpIndent:DWORD
	LOCAL	buffer[4096]:BYTE

	.if hMnuMem
		mov		esi,hMnuMem
		mov		al,MNUHEAD.menuname[esi]
		.if al
			mov		eax,MNUHEAD.menuid[esi]
			.if eax
				lea		edx,MNUHEAD.menuname[esi]
				invoke BuildEqu,lpDest,lpIndent,edx,eax
				mov		lpDest,eax
			.endif
		.endif
		add		esi,sizeof MNUHEAD
		mov		eax,MNUITEM.itemflag[esi]
		.while eax
			mov		al,MNUITEM.itemname[esi]
			.if al
				mov		eax,MNUITEM.itemid[esi]
				.if eax
					lea		edx,MNUITEM.itemname[esi]
					invoke BuildEqu,lpDest,lpIndent,edx,eax
					mov		lpDest,eax
				.endif
			.endif
			add		esi,sizeof MNUITEM
			mov		eax,MNUITEM.itemflag[esi]
		.endw
	.endif
	mov		eax,lpDest
	ret

BuildMnuID endp

BuildDb proc lpDest:DWORD,lpIndent:DWORD,lpName:DWORD,lpText:DWORD

	invoke lstrcpy,lpDest,lpIndent
	invoke lstrlen,lpIndent
	add		lpDest,eax
	invoke lstrcpy,lpDest,lpName
	invoke lstrlen,lpName
	mov		edx,lpDest
	add		edx,eax
	and		eax,1Ch
	.while eax<32
		mov		byte ptr [edx],09h
		inc		edx
		add		eax,4
	.endw
	mov		eax,"' bd"
	mov		[edx],eax
	add		edx,4
	mov		lpDest,edx
	invoke lstrcpy,lpDest,lpText
	invoke lstrlen,lpDest
	mov		edx,lpDest
	add		edx,eax
	mov		eax,"0,'"
	mov		[edx],eax
	add		edx,3
	mov		eax,0A0Dh
	mov		[edx],eax
	add		edx,2
	mov		eax,edx
	ret

BuildDb endp

BuildWinClass proc uses esi,lpDest:DWORD,lpIndent:DWORD

	mov		eax,lpHStruct
	mov		eax,ADDINHANDLES.hMdiCld[eax]
	invoke GetWindowLong,eax,4
	mov		esi,eax
	invoke GetClass,1
	mov		al,DLGHEAD.class[esi]
	.if al
		lea		eax,DLGHEAD.class[esi]
		invoke lstrcpy,addr sClass,eax
	.endif
	invoke BuildDb,lpDest,lpIndent,addr sClassName,addr sClass
	ret

BuildWinClass endp

BuildCtlClass proc uses esi,lpDest:DWORD,lpIndent:DWORD
	LOCAL	buffer[4096]:BYTE

	mov		fClass,0
	mov		eax,lpHStruct
	mov		eax,ADDINHANDLES.hMdiCld[eax]
	invoke GetWindowLong,eax,4
	mov		esi,eax
	add		esi,sizeof DLGHEAD
  NxClass:
	mov		eax,DIALOG.ntype[esi]
	.if eax>32
		;Custom control. Use the typeid to identify control
		mov		eax,DIALOG.ntypeid[esi]
		mov		edx,offset CustClassTranslate
		.while dword ptr [edx]
			.break .if eax==[edx]
			add		edx,8
		.endw
		mov		eax,[edx+4]
	.endif
	.if eax
		add		eax,offset nClass
		xor		edx,edx
		mov		dl,[eax]
		mov		cl,dl
		.if dl>31
			and		cl,31
		.endif
		mov		eax,1
		shl		eax,cl
		mov		ecx,eax
		.if dl>31
			and		ecx,fClass+4
		.else
			and		ecx,fClass
		.endif
		.if !ecx
			.if dl>31
				or		fClass+4,eax
			.else
				or		fClass,eax
			.endif
			inc		edx
			invoke GetClass,edx
			invoke BuildDb,lpDest,lpIndent,addr sClassName,addr sClass
			mov		lpDest,eax
		.endif
	.endif
  @@:
	add		esi,sizeof DIALOG
	cmp		DIALOG.hwnd[esi],-1
	je		@b
	cmp		DIALOG.hwnd[esi],0
	jne		NxClass
	mov		eax,lpDest
	ret

BuildCtlClass endp

BuildCtlName proc uses esi edi,lpDest:DWORD,lpIndent:DWORD
	LOCAL	buffer[4096]:BYTE

	mov		edi,offset nCaption
	mov		eax,0
	mov		ecx,64
	rep stosd
	mov		eax,lpHStruct
	mov		eax,ADDINHANDLES.hMdiCld[eax]
	invoke GetWindowLong,eax,4
	mov		esi,eax
	add		esi,sizeof DLGHEAD
  NxName:
	mov		eax,DIALOG.ntype[esi]
	.if eax>32
		;Custom control. Use the typeid to identify control
		mov		eax,DIALOG.ntypeid[esi]
		mov		edx,offset CustClassTranslate
		.while dword ptr [edx]
			.break .if eax==[edx]
			add		edx,8
		.endw
		mov		eax,[edx+4]
	.endif
	shl		eax,2
	add		eax,offset nCaption
	inc		dword ptr [eax]
	mov		al,DIALOG.idname[esi]
	.if al
		mov		eax,DIALOG.id[esi]
		.if !eax
			mov		eax,DIALOG.ntype[esi]
			.if eax>32
				;Custom control. Use the typeid to identify control
				mov		eax,DIALOG.ntypeid[esi]
				mov		edx,offset CustClassTranslate
				.while dword ptr [edx]
					.break .if eax==[edx]
					add		edx,8
				.endw
				mov		eax,[edx+4]
			.endif
			push	eax
			add		eax,2
			invoke GetCaption,eax
			invoke lstrcpy,addr buffer,addr sName
			invoke lstrlen,addr buffer
			lea		edx,buffer
			add		edx,eax
			pop		eax
			shl		eax,2
			add		eax,offset nCaption
			mov		eax,[eax]
			invoke BinToDec,eax,edx
			lea		edx,DIALOG.idname[esi]
			invoke BuildDb,lpDest,lpIndent,addr buffer,edx
			mov		lpDest,eax
		.endif
	.endif
  @@:
	add		esi,sizeof DIALOG
	cmp		DIALOG.hwnd[esi],-1
	je		@b
	cmp		DIALOG.hwnd[esi],0
	jne		NxName
	mov		eax,lpDest
	ret

BuildCtlName endp

BuildMnuName proc uses esi,hMnuMem:DWORD,lpDest:DWORD,lpIndent:DWORD

	.if hMnuMem
		mov		esi,hMnuMem
		mov		al,MNUHEAD.menuname[esi]
		.if al
			mov		eax,MNUHEAD.menuid[esi]
			.if !eax
				invoke GetCaption,1
				lea		edx,MNUHEAD.menuname[esi]
				invoke BuildDb,lpDest,lpIndent,addr sName,edx
				mov		lpDest,eax
			.endif
		.endif
	.endif
	mov		eax,lpDest
	ret

BuildMnuName endp

BuildCtlCaption proc uses esi edi,lpDest:DWORD,lpIndent:DWORD
	LOCAL	buffer[4096]:BYTE

	mov		edi,offset nCaption
	mov		eax,0
	mov		ecx,64
	rep stosd
	mov		eax,lpHStruct
	mov		eax,ADDINHANDLES.hMdiCld[eax]
	invoke GetWindowLong,eax,4
	mov		esi,eax
	add		esi,sizeof DLGHEAD
  NxCap:
	mov		eax,DIALOG.ntype[esi]
	.if eax>32
		;Custom control. Use the typeid to identify control
		mov		eax,DIALOG.ntypeid[esi]
		mov		edx,offset CustClassTranslate
		.while dword ptr [edx]
			.break .if eax==[edx]
			add		edx,8
		.endw
		mov		eax,[edx+4]
	.endif
	shl		eax,2
	add		eax,offset nCaption
	inc		dword ptr [eax]
	mov		al,DIALOG.caption[esi]
	.if al
		mov		eax,DIALOG.ntype[esi]
		.if eax>32
			;Custom control. Use the typeid to identify control
			mov		eax,DIALOG.ntypeid[esi]
			mov		edx,offset CustClassTranslate
			.while dword ptr [edx]
				.break .if eax==[edx]
				add		edx,8
			.endw
			mov		eax,[edx+4]
		.endif
		add		eax,2
		invoke GetCaption,eax
		invoke lstrcpy,addr buffer,addr sCaption
		invoke lstrlen,addr buffer
		lea		edx,buffer
		add		edx,eax
		mov		eax,DIALOG.ntype[esi]
		.if eax>32
			;Custom control. Use the typeid to identify control
			push	edx
			mov		eax,DIALOG.ntypeid[esi]
			mov		edx,offset CustClassTranslate
			.while dword ptr [edx]
				.break .if eax==[edx]
				add		edx,8
			.endw
			mov		eax,[edx+4]
			pop		edx
		.endif
		shl		eax,2
		add		eax,offset nCaption
		mov		eax,[eax]
		invoke BinToDec,eax,edx
		lea		edx,DIALOG.caption[esi]
		invoke BuildDb,lpDest,lpIndent,addr buffer,edx
		mov		lpDest,eax
	.endif
  @@:
	add		esi,sizeof DIALOG
	cmp		DIALOG.hwnd[esi],-1
	je		@b
	cmp		DIALOG.hwnd[esi],0
	jne		NxCap
	mov		eax,lpDest
	ret

BuildCtlCaption endp

BuildWindow proc uses esi edi,lpDest:DWORD,lpIndent:DWORD
	LOCAL	buffer[4096]:BYTE

	mov		nCaption,1
	mov		eax,lpHStruct
	mov		eax,ADDINHANDLES.hMdiCld[eax]
	invoke GetWindowLong,eax,4
	mov		esi,eax
	add		esi,sizeof DLGHEAD
	invoke GetCreate,addr buffer,esi,lpIndent
	invoke lstrcpy,lpDest,addr buffer
	invoke lstrlen,addr buffer
	add		lpDest,eax
	mov		eax,lpDest
	ret

BuildWindow endp

BuildControls proc uses esi edi,lpDest:DWORD,lpIndent:DWORD
	LOCAL	buffer[4096]:BYTE

	mov		edi,offset nCaption
	mov		eax,0
	mov		ecx,64
	rep stosd
	mov		eax,lpHStruct
	mov		eax,ADDINHANDLES.hMdiCld[eax]
	invoke GetWindowLong,eax,4
	mov		esi,eax
	add		esi,sizeof DLGHEAD
  NxCtl:
	mov		eax,DIALOG.ntype[esi]
	.if eax>32
		;Custom control. Use the typeid to identify control
		mov		eax,DIALOG.ntypeid[esi]
		mov		edx,offset CustClassTranslate
		.while dword ptr [edx]
			.break .if eax==[edx]
			add		edx,8
		.endw
		mov		eax,[edx+4]
	.endif
	shl		eax,2
	add		eax,offset nCaption
	inc		dword ptr [eax]
	mov		eax,DIALOG.ntype[esi]
	.if eax
		invoke GetCreate,addr buffer,esi,lpIndent
		invoke lstrcpy,lpDest,addr buffer
		invoke lstrlen,addr buffer
		add		lpDest,eax
	.endif
  @@:
	add		esi,sizeof DIALOG
	cmp		DIALOG.hwnd[esi],-1
	je		@b
	cmp		DIALOG.hwnd[esi],0
	jne		NxCtl
	mov		eax,lpDest
	ret

BuildControls endp

BuildCommands proc uses esi,hMnuMem:DWORD,lpDest:DWORD,lpIndent:DWORD
	LOCAL	buffer[4096]:BYTE
	LOCAL	nNum:DWORD

	mov		nNum,0
	mov		eax,lpHStruct
	mov		eax,ADDINHANDLES.hMdiCld[eax]
	invoke GetWindowLong,eax,4
	mov		esi,eax
	add		esi,sizeof DLGHEAD
  NxCtl:
	mov		eax,DIALOG.ntype[esi]
	.if eax==4
		invoke lstrcpy,lpDest,lpIndent
		invoke lstrlen,lpIndent
		add		lpDest,eax
		.if !nNum
			invoke lstrcpy,lpDest,addr szIf
			invoke lstrlen,addr szIf
		.else
			invoke lstrcpy,lpDest,addr szElseIf
			invoke lstrlen,addr szElseIf
		.endif
		add		lpDest,eax
		mov		al,DIALOG.idname[esi]
		.if al
			lea		eax,DIALOG.idname[esi]
			push	eax
			invoke lstrcpy,lpDest,eax
			pop		eax
			invoke lstrlen,eax
			add		lpDest,eax
		.else
			mov		eax,DIALOG.id[esi]
			invoke BinToDec,eax,lpDest
			mov		lpDest,eax
		.endif
		mov		edx,lpDest
		mov		eax,0A0Dh
		mov		[edx],eax
		add		lpDest,2
		inc		nNum
	.endif
  @@:
	add		esi,sizeof DIALOG
	cmp		DIALOG.hwnd[esi],-1
	je		@b
	cmp		DIALOG.hwnd[esi],0
	jne		NxCtl

	.if hMnuMem
		mov		esi,hMnuMem
		add		esi,sizeof MNUHEAD
	  NxMnu:
		mov		eax,MNUITEM.itemid[esi]
		.if eax
			invoke lstrcpy,lpDest,lpIndent
			invoke lstrlen,lpIndent
			add		lpDest,eax
			.if !nNum
				invoke lstrcpy,lpDest,addr szIf
				invoke lstrlen,addr szIf
			.else
				invoke lstrcpy,lpDest,addr szElseIf
				invoke lstrlen,addr szElseIf
			.endif
			add		lpDest,eax
			mov		al,MNUITEM.itemname[esi]
			.if al
				lea		eax,MNUITEM.itemname[esi]
				push	eax
				invoke lstrcpy,lpDest,eax
				pop		eax
				invoke lstrlen,eax
				add		lpDest,eax
			.else
				mov		eax,MNUITEM.itemid[esi]
				invoke BinToDec,eax,lpDest
				mov		lpDest,eax
			.endif
			mov		edx,lpDest
			mov		eax,0A0Dh
			mov		[edx],eax
			add		lpDest,2
			inc		nNum
		.endif
		add		esi,sizeof MNUITEM
		cmp		MNUITEM.itemflag[esi],0
		jne		NxMnu
	.endif
	.if nNum
		invoke lstrcpy,lpDest,lpIndent
		invoke lstrlen,lpIndent
		add		lpDest,eax
		invoke lstrcpy,lpDest,addr szEndIf
		invoke lstrlen,addr szEndIf
		add		lpDest,eax
		mov		edx,lpDest
		mov		eax,0A0Dh
		mov		[edx],eax
		add		lpDest,2
	.endif
	mov		eax,lpDest
	ret

BuildCommands endp

CreateWin proc uses esi edi,hFile:DWORD,hMnuMem:DWORD,hWrMem:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	fSize:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	fBuff[1024*10]:BYTE
	LOCAL	bLine[2048]:BYTE
	LOCAL	mPos:DWORD
	LOCAL	indent[256]:BYTE

	invoke GetFileSize,hFile,NULL
	mov		fSize,eax
	mov		nBytes,0
	mov		eax,hWrMem
	mov		mPos,eax
	lea		esi,fBuff
	lea		edi,bLine
	.while fSize || nBytes
		.if !nBytes
			;Fill buffer with template data
			mov		eax,sizeof fBuff
			mov		nBytes,eax
			push	edi
			invoke ReadFile,hFile,addr fBuff,nBytes,addr nBytes,NULL
			pop		edi
			mov		eax,nBytes
			sub		fSize,eax
			lea		esi,fBuff
		.endif
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		.if al==0Ah
			;End of line. Process the line
			push	esi
			mov		byte ptr [edi],0
			lea		esi,bLine
			mov		edi,mPos
;ID
			invoke StrInStr,esi,addr szCmdDefCtlID
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdDefCtlID-1
				invoke BuildCtlID,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
			invoke StrInStr,esi,addr szCmdDefMnuID
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdDefMnuID-1
				invoke BuildMnuID,hMnuMem,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
;Class
			invoke StrInStr,esi,addr szCmdDefWinClass
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdDefWinClass-1
				invoke BuildWinClass,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
			invoke StrInStr,esi,addr szCmdDefCtlClass
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdDefCtlClass-1
				invoke BuildCtlClass,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
;Name
			invoke StrInStr,esi,addr szCmdDefCtlName
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdDefCtlName-1
				invoke BuildCtlName,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
			invoke StrInStr,esi,addr szCmdDefMnuName
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdDefMnuName-1
				invoke BuildMnuName,hMnuMem,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
;Caption
			invoke StrInStr,esi,addr szCmdDefCtlCaption
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdDefCtlCaption-1
				invoke BuildCtlCaption,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
;Create
			invoke StrInStr,esi,addr szCmdCreateWin
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdCreateWin-1
				invoke BuildWindow,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
			invoke StrInStr,esi,addr szCmdCreateCtl
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdCreateCtl-1
				invoke BuildControls,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
;Command
			invoke StrInStr,esi,addr szCmdCommand
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,addr indent,esi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdCommand-1
				invoke BuildCommands,hMnuMem,edi,addr indent
				mov		edi,eax
				mov		al,[esi]
				.if al==0Dh
					add		esi,2
				.endif
				jmp		Done
			.endif
;Get win name
			invoke StrInStr,esi,addr szCmdGetWinName
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,edi,esi,eax
				pop		eax
				push	eax
				add		edi,eax
				push	esi
				mov		eax,lpHStruct
				mov		eax,ADDINHANDLES.hMdiCld[eax]
				invoke GetWindowLong,eax,4
				mov		esi,eax
				add		esi,sizeof DLGHEAD
				mov		eax,DIALOG.id[esi]
				.if !eax
					mov		al,DIALOG.idname[esi]
					.if al
						invoke lstrcpy,edi,addr szOffset
						invoke lstrlen,addr szOffset
						add		edi,eax
						invoke GetCaption,2
						invoke lstrcpy,edi,addr sName
						invoke lstrlen,addr sName
						add		edi,eax
					.else
						mov		al,'0'
						stosb
						mov		byte ptr [edi],0
					.endif
				.else
					mov		al,DIALOG.idname[esi]
					.if al
						lea		esi,DIALOG.idname[esi]
						invoke lstrcpy,edi,esi
						invoke lstrlen,esi
						add		edi,eax
					.else
						invoke BinToDec,eax,edi
						mov		edi,eax
					.endif
				.endif
				pop		esi
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdGetWinName-1
				jmp		Done
			.endif
;get proc name
			invoke StrInStr,esi,addr szCmdGetProcName
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,edi,esi,eax
				pop		eax
				push	eax
				add		edi,eax
				invoke lstrcpy,edi,addr szProcName
				invoke lstrlen,addr szProcName
				add		edi,eax
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdGetProcName-1
				jmp		Done
			.endif
;Get menu name
			invoke StrInStr,esi,addr szCmdGetMnuName
			.if eax!=-1
				push	eax
				inc		eax
				invoke lstrcpyn,edi,esi,eax
				pop		eax
				push	eax
				add		edi,eax
				.if hMnuMem
					push	esi
					mov		esi,hMnuMem
					mov		eax,MNUHEAD.menuid[esi]
					.if !eax
						mov		al,MNUHEAD.menuname[esi]
						.if al
							invoke lstrcpy,edi,addr szOffset
							invoke lstrlen,addr szOffset
							add		edi,eax
							invoke GetCaption,1
							invoke lstrcpy,edi,addr sName
							invoke lstrlen,addr sName
							add		edi,eax
						.else
							mov		al,'0'
							stosb
							mov		byte ptr [edi],0
						.endif
					.else
						mov		al,MNUHEAD.menuname[esi]
						.if al
							lea		esi,MNUHEAD.menuname[esi]
							invoke lstrcpy,edi,esi
							invoke lstrlen,esi
							add		edi,eax
						.else
							invoke BinToDec,eax,edi
							mov		edi,eax
						.endif
					.endif
					pop		esi
				.else
					mov		al,'0'
					stosb
					mov		byte ptr [edi],0
				.endif
				pop		eax
				add		esi,eax
				add		esi,sizeof szCmdGetMnuName-1
				jmp		Done
			.endif
		  Done:
			invoke lstrcpy,edi,esi
			invoke lstrlen,esi
			add		edi,eax
			mov		mPos,edi
			pop		esi
			lea		edi,bLine
		.endif
		dec		nBytes
	.endw
	xor		eax,eax
	ret

CreateWin endp

GetFileName proc lpBuff:DWORD

	invoke lstrlen,lpBuff
	mov		edx,eax
	add		edx,lpBuff
	.if eax
		.while TRUE
			dec		edx
			mov		al,[edx]
			.if al=='\'
				.break
			.endif
		.endw
		inc		edx
	.endif
	mov		eax,edx
	ret

GetFileName endp

CodeWriteProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[512]:BYTE
	LOCAL	ofn:OPENFILENAME
	LOCAL	hWrMem:DWORD
	LOCAL	hMnuMem:DWORD
	LOCAL	nInx:DWORD
	LOCAL	hFile:DWORD
	LOCAL	hMnu:DWORD
	LOCAL	fSize:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,lpHStruct
		invoke GetWindowLong,[eax].ADDINHANDLES.hMdiCld,4
		mov		eax,[eax].DLGHEAD.ver
		.if eax!=102
			invoke MessageBox,hWin,offset szVerErr,offset szDlgToWin,MB_OK or MB_ICONERROR
			invoke EndDialog,hWin,1
			mov		eax,TRUE
			ret
		.endif
		invoke lstrcpy,addr buffer,addr szExport
		.while TRUE
			invoke StrGetItem,addr buffer1,addr buffer
			mov		al,buffer1
			.if al
				invoke SendDlgItemMessage,hWin,IDC_CBOEXPORT,CB_ADDSTRING,0,addr buffer1
			.else
				.break
			.endif
		.endw
		mov		eax,lpHStruct
		mov		eax,ADDINHANDLES.hMdiCld[eax]
		invoke GetWindowLong,eax,16
		mov		edx,eax
		invoke BinToDec,edx,addr buffer
		mov		edx,lpDStruct
		mov		edx,ADDINDATA.lpProject[edx]
		push	edx
		invoke GetPrivateProfileInt,addr szIniApp,addr buffer,0,edx
		invoke SendDlgItemMessage,hWin,IDC_CBOEXPORT,CB_SETCURSEL,eax,0
		pop		edx
		invoke GetPrivateProfileString,addr szIniApp,addr buffer,addr szNULL,addr buffer1,sizeof buffer1,edx
		invoke StrGetItem,addr buffer,addr buffer1
		invoke StrGetItem,addr szTemplateFile,addr buffer1
		invoke GetFileName,addr szTemplateFile
		invoke SetDlgItemText,hWin,IDC_EDTTEMPLATE,eax
		invoke StrGetItem,addr szMenuFile,addr buffer1
		invoke GetFileName,addr szMenuFile
		invoke SetDlgItemText,hWin,IDC_EDTMENU,eax
		invoke StrGetItem,addr szProcName,addr buffer1
		mov		al,byte ptr szProcName
		.if !al
			invoke lstrcpy,addr szProcName,addr szProc
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTPROC,addr szProcName
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetDlgItemText,hWin,IDC_EDTPROC,addr szProcName,sizeof szProcName
				mov		hMnuMem,0
				mov		al,byte ptr szMenuFile
				.if al
					invoke CreateFile,addr szMenuFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						mov		hMnu,eax
						invoke GetFileSize,hMnu,NULL
						mov		fSize,eax
						invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*100
						invoke GlobalLock,eax
						mov     hMnuMem,eax
						invoke ReadFile,hMnu,hMnuMem,fSize,addr fSize,NULL
						invoke CloseHandle,hMnu
					.else
						;Menu not found
						invoke lstrcpy,addr buffer1,addr szNotFound
						invoke lstrcat,addr buffer1,addr szMenuFile
						invoke MessageBox,hWnd,addr buffer1,addr szDlgToWin,MB_OK or MB_ICONSTOP
						mov		eax,TRUE
						ret
					.endif
				.endif
				invoke SendDlgItemMessage,hWin,IDC_CBOEXPORT,CB_GETCURSEL,0,0
				mov		nInx,eax
				mov		eax,lpHStruct
				mov		eax,ADDINHANDLES.hMdiCld[eax]
				invoke GetWindowLong,eax,16
				mov		edx,eax
				invoke BinToDec,edx,addr buffer
				invoke BinToDec,nInx,addr buffer1
				invoke lstrlen,addr buffer1
				mov		edx,eax
				mov		buffer1[edx],','
				inc		edx
				invoke lstrcpy,addr buffer1[edx],offset szTemplateFile
				invoke lstrlen,addr buffer1
				mov		edx,eax
				mov		buffer1[edx],','
				inc		edx
				invoke lstrcpy,addr buffer1[edx],offset szMenuFile
				invoke lstrlen,addr buffer1
				mov		edx,eax
				mov		buffer1[edx],','
				inc		edx
				invoke lstrcpy,addr buffer1[edx],offset szProcName
				mov		edx,lpDStruct
				mov		edx,ADDINDATA.lpProject[edx]
				invoke WritePrivateProfileString,addr szIniApp,addr buffer,addr buffer1,edx
				invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*100
				invoke GlobalLock,eax
				mov     hWrMem,eax
				mov		eax,nInx
				.if eax==0
					invoke CreateFile,addr szTemplateFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						mov		hFile,eax
					.else
						;Template not found
						invoke lstrcpy,addr buffer1,addr szNotFound
						invoke lstrcat,addr buffer1,addr szTemplateFile
						invoke MessageBox,hWnd,addr buffer1,addr szDlgToWin,MB_OK or MB_ICONSTOP
						mov		eax,TRUE
						ret
					.endif
					invoke CreateWin,hFile,hMnuMem,hWrMem
					invoke CloseHandle,hFile
				.elseif eax==1
					invoke BuildCtlID,hWrMem,addr szNULL
					mov		edx,eax
					invoke BuildMnuID,hMnuMem,edx,addr szNULL
				.elseif eax==2
					invoke BuildWinClass,hWrMem,addr szNULL
					mov		edx,eax
					invoke BuildCtlClass,edx,addr szNULL
				.elseif eax==3
					invoke BuildCtlName,hWrMem,addr szNULL
					mov		edx,eax
					invoke BuildMnuName,hMnuMem,edx,addr szNULL
				.elseif eax==4
					invoke BuildCtlCaption,hWrMem,addr szNULL
				.elseif eax==5
					invoke BuildWindow,hWrMem,addr szNULL
				.elseif eax==6
					invoke BuildControls,hWrMem,addr szNULL
				.elseif eax==7
					invoke BuildCommands,hMnuMem,hWrMem,addr szNULL
				.endif
				push	2
				mov		eax,lpPStruct
				call ADDINPROCS.lpOutputSelect[eax]
				mov		eax,lpPStruct
				call ADDINPROCS.lpClearOut[eax]
				push	hWrMem
				mov		eax,lpPStruct
				call ADDINPROCS.lpTextOut[eax]
				invoke GlobalUnlock,hWrMem
				invoke GlobalFree,hWrMem
				.if hMnuMem
					invoke GlobalUnlock,hMnuMem
					invoke GlobalFree,hMnuMem
				.endif
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNTEMPLATE
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,offset szRad
				mov		al,byte ptr szTemplateFile
				.if al
					invoke GetFileName,addr szTemplateFile
					sub		eax,offset szTemplateFile
					invoke lstrcpyn,addr buffer1,addr szTemplateFile,eax
					lea		eax,buffer1
				.else
					mov		eax,lpDStruct
					mov		eax,ADDINDATA.lpTpl[eax]
				.endif
				mov		ofn.lpstrInitialDir,eax
				mov		ofn.lpstrFile,offset szTemplateFile
				mov		ofn.nMaxFile,sizeof szTemplateFile
				mov		ofn.lpstrDefExt,0
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					mov		eax,lpDStruct
					mov		eax,ADDINDATA.lpTpl[eax]
					invoke lstrlen,eax
					mov		edx,eax
					inc		edx
					invoke SetDlgItemText,hWin,IDC_EDTTEMPLATE,addr szTemplateFile[edx]
				.endif
			.elseif eax==IDC_BTNMENU
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,offset szMnu
				mov		al,byte ptr szMenuFile
				.if al
					invoke GetFileName,addr szMenuFile
					sub		eax,offset szMenuFile
					invoke lstrcpyn,addr buffer1,addr szMenuFile,eax
				.else
					mov		eax,lpDStruct
					mov		eax,ADDINDATA.lpProject[eax]
					invoke lstrcpy,addr buffer1,eax
					invoke lstrlen,addr buffer1
					mov		edx,eax
					.while TRUE
						mov		al,buffer1[edx]
						mov		buffer1[edx],0
						dec		edx
						.if al=='\'
							.break
						.endif
					.endw
				.endif
				lea		eax,buffer1
				mov		ofn.lpstrInitialDir,eax
				mov		ofn.lpstrFile,offset szMenuFile
				mov		ofn.nMaxFile,sizeof szMenuFile
				mov		ofn.lpstrDefExt,0
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke lstrlen,addr buffer1
					mov		edx,eax
					inc		edx
					invoke SetDlgItemText,hWin,IDC_EDTMENU,addr szMenuFile[edx]
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

CodeWriteProc endp
