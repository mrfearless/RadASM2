.code

GetPrnCaps proc
	LOCAL	buffer[256]:BYTE

	invoke GetUserDefaultLCID
	mov		edx,eax
	invoke GetLocaleInfo,edx,LOCALE_IMEASURE,addr buffer,sizeof buffer
	mov		al,buffer
	.if al=='1'
		mov		eax,1
	.else
		mov		eax,0
	.endif
	mov		prnInches,eax
	ret

GetPrnCaps endp

ConvToPix proc lLPix:DWORD,lSize:DWORD

	mov		eax,lLPix
	.if !prnInches
		mov		ecx,1000
		mul		ecx
		xor		edx,edx
		mov		ecx,254
		div		ecx
	.else
		mov		ecx,10
		mul		ecx
	.endif
	mov		ecx,eax		;Pix pr. 100mm / 10"
	mov		eax,lSize
	mul		ecx
	xor		edx,edx
	mov		ecx,10000
	div		ecx
	ret

ConvToPix endp

PrnHilite proc uses ebx esi edi,hDC:DWORD,ptX:DWORD,ptY:DWORD,ptH:DWORD,ptT:DWORD,lpStr:DWORD
	LOCAL	len:DWORD

	invoke strlen,lpStr
	mov		len,eax
	call HiComment
	invoke strlen,lpStr
	mov		len,eax
	invoke SetTextColor,hDC,PrnColors[8]
	mov		al,'"'
	call HiString
	mov		al,"'"
	call HiString
	invoke SetTextColor,hDC,PrnColors[12]
	mov		esi,offset szOperand
  @@:
	mov		al,[esi]
	.if al
		call HiOperand
		inc		esi
		jmp		@b
	.endif
	;Begin the word search 
	mov		esi,lpStr
	mov		edi,offset ASMSyntaxArray
	invoke strlen,esi
	mov		ecx,eax
	.while ecx>0
		mov		al,byte ptr [esi]
		.if al!=' ' && al!=VK_TAB && al
			push	ecx
			call LenStr
			mov		edx,eax
			movzx	eax,byte ptr [esi]
			.if al>="A" && al<="Z"
				or		al,20h
			.endif
			shl		eax,2
			add		eax,offset ASMSyntaxArray
			mov		eax,dword ptr [eax]
			.if eax
				assume eax:ptr WORDINFO
				.while eax!=0
					.if edx==[eax].WordLen
						call CmpStr
						.if !ecx
							;hilite the word
							pushad
							push	edx
							mov		edx,[eax].pColor
							push	edx
							mov		ebx,ptX
							.if esi!=lpStr
								mov		ecx,esi
								sub		ecx,lpStr
								invoke GetTabbedTextExtent,hDC,lpStr,ecx,1,addr ptT
								and		eax,0FFFFh
								add		ebx,eax
							.endif
							pop		edx
							invoke SetTextColor,hDC,dword ptr [edx]
							pop		edx
							invoke TabbedTextOut,hDC,ebx,ptY,esi,edx,1,addr ptT,ptX
							popad
							.break
						.endif
					.endif
					mov		eax,[eax].NextLink
				.endw
			.endif
			pop		ecx
			sub		ecx,edx
			add		esi,edx
		.else
			dec		ecx
			inc		esi
		.endif
	.endw
	ret

CmpStr:
	push	esi
	push	edi
	mov		edi,[eax].pszWord
	xor		ecx,ecx
	dec		esi
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		cl,[esi]
	.if cl>="A" && cl<="Z"
		or		cl,20h
	.elseif cl==' ' || cl==VK_TAB
		xor		cl,cl
	.endif
	sub		cl,[edi]
	jne		@f
	cmp		[edi],cl
	jne		@b
  @@:
	pop		edi
	pop		esi
	retn

LenStr:
	push	esi
	dec		esi
	mov		eax,0FFFFFFFFh
  @@:
	inc		esi
	inc		eax
	cmp		byte ptr [esi],' '
	je		@f
	cmp		byte ptr [esi],VK_TAB
	je		@f
	cmp		byte ptr [esi],0
	jne		@b
  @@:
	pop		esi
	retn

HiComment:
	mov		ecx,len
	mov		edi,lpStr
	mov		al,';'
	repne scasb
	jne		NoComment
	dec		edi
	invoke SetTextColor,hDC,PrnColors[4]
	mov		ebx,ptX
	.if edi!=lpStr
		mov		ecx,edi
		sub		ecx,lpStr
		invoke GetTabbedTextExtent,hDC,lpStr,ecx,1,addr ptT
		and		eax,0FFFFh
		add		ebx,eax
	.endif
	invoke strlen,edi
	mov		ecx,eax
	invoke TabbedTextOut,hDC,ebx,ptY,edi,ecx,1,addr ptT,ptX
	mov		byte ptr [edi],0
  NoComment:
	retn

HiString:
	mov		ecx,len
	mov		edi,lpStr
  @@:
	repne scasb
	jne		NoString
	push	eax
	push	ecx
	push	edi
	push	eax
	push	ecx
	mov		ebx,ptX
	.if edi!=lpStr
		mov		ecx,edi
		sub		ecx,lpStr
		invoke GetTabbedTextExtent,hDC,lpStr,ecx,1,addr ptT
		and		eax,0FFFFh
		add		ebx,eax
	.endif
	pop		ecx
	pop		eax
	push	edi
	repne scasb
	pop		ecx
	jne		Nf
	dec		edi
  Nf:
	sub		ecx,edi
	neg		ecx
	pop		edi
	push	ecx
	invoke TabbedTextOut,hDC,ebx,ptY,edi,ecx,1,addr ptT,ptX
	pop		ecx
	mov		al,' '
	rep stosb
	pop		ecx
	pop		eax
	repne scasb
	jne		NoString
	or		ecx,ecx
	jne		@b
  NoString:
	retn

HiOperand:
	mov		ecx,len
	mov		edi,lpStr
  @@:
	repne scasb
	jne		@f
	dec		edi
	push	eax
	push	ecx
	mov		ebx,ptX
	.if edi!=lpStr
		mov		ecx,edi
		sub		ecx,lpStr
		invoke GetTabbedTextExtent,hDC,lpStr,ecx,1,addr ptT
		and		eax,0FFFFh
		add		ebx,eax
	.endif
	invoke TabbedTextOut,hDC,ebx,ptY,edi,1,1,addr ptT,ptX
	mov		byte ptr [edi],' '
	pop		ecx
	pop		eax
	inc		edi
	or		ecx,ecx
	jne		@b
  @@:
	retn

PrnHilite endp

Print proc
	LOCAL	doci:DOCINFO
	LOCAL	lf:LOGFONT
	LOCAL	hPrFont:DWORD
	LOCAL	ptX:DWORD
	LOCAL	ptY:DWORD
	LOCAL	pX:DWORD
	LOCAL	pY:DWORD
	LOCAL	pML:DWORD
	LOCAL	pMT:DWORD
	LOCAL	pMR:DWORD
	LOCAL	pMB:DWORD
	LOCAL	nLine:DWORD
	LOCAL	nMLine:DWORD
	LOCAL	pt:POINT
	LOCAL	tWt:DWORD
	LOCAL	rect:RECT
	LOCAL	hRgn:DWORD
	LOCAL   chrg:CHARRANGE
	LOCAL	nPageno:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	timebuff[32]:BYTE

	invoke GetPrnCaps
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr chrg
	mov		pd.lStructSize, sizeof pd
	m2m		pd.hwndOwner,hWnd
	m2m		pd.hInstance,hInstance
	mov		eax,chrg.cpMin
	.if eax!=chrg.cpMax
		mov		eax,PD_RETURNDC or PD_SELECTION
	.else
		invoke SendMessage,hEdit,EM_GETLINECOUNT,0,0
		mov		ecx,nPageSize
		xor		edx,edx
		div		ecx
		.if edx
			inc		eax
		.endif
		mov		pd.nMinPage,1
		mov		pd.nMaxPage,ax
		mov		pd.nFromPage,1
		mov		pd.nToPage,ax
		mov		eax,PD_RETURNDC or PD_NOSELECTION or PD_PAGENUMS
	.endif
	mov		pd.Flags,eax
	invoke PrintDlg,addr pd
	.if eax
		.if PrnTime
			invoke GetDateFormat,NULL,NULL,NULL,offset DatePic,addr timebuff,12
			invoke GetTimeFormat,NULL,TIME_FORCE24HOURFORMAT,NULL,offset TimePic,addr timebuff[11],12
		.endif
		push	ebx
		invoke GetDeviceCaps,pd.hDC,LOGPIXELSX
		mov		ebx,eax
		invoke ConvToPix,ebx,psd.ptPaperSize.x
		mov		pX,eax
		invoke ConvToPix,ebx,psd.rtMargin.left
		mov		pML,eax
		invoke ConvToPix,ebx,psd.rtMargin.right
		mov		pMR,eax
		invoke GetDeviceCaps,pd.hDC,LOGPIXELSY
		mov		ebx,eax
		invoke ConvToPix,ebx,psd.ptPaperSize.y
		mov		pY,eax
		invoke ConvToPix,ebx,psd.rtMargin.top
		mov		pMT,eax
		invoke ConvToPix,ebx,psd.rtMargin.bottom
		mov		pMB,eax
		invoke RtlZeroMemory,addr lf,sizeof lf
		invoke strcpy,addr lf.lfFaceName,addr lfntprn.lfFaceName
		invoke GetDeviceCaps,pd.hDC,LOGPIXELSY
		mov		ecx,lfntprn.lfHeight
		neg		ecx
		mul		ecx
		xor		edx,edx
		mov		ecx,72
		div		ecx
		mov		lf.lfHeight,eax;48;72
		mov		eax,lfntprn.lfWeight
		mov		lf.lfWeight,eax
		invoke CreateFontIndirect,addr lf
		mov		hPrFont,eax
		mov		doci.cbSize,sizeof doci
		mov		doci.lpszDocName,offset AppName
		mov		eax,pd.Flags
		and		eax,PD_PRINTTOFILE
		.if eax
			mov		eax,'ELIF'
			mov		dword ptr buffer,eax
			mov		eax,':'
			mov		dword ptr buffer+4,eax
			lea		eax,buffer
			mov		doci.lpszOutput,eax
		.else
			mov		doci.lpszOutput,NULL
		.endif
		mov		doci.lpszDatatype,NULL
		mov		doci.fwType,NULL
		invoke StartDoc,pd.hDC,addr doci
		mov		eax,pd.Flags
		and		eax,PD_SELECTION
		.if eax
			invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
			mov		nLine,eax
			mov		ecx,nPageSize
			xor		edx,edx
			div		ecx
			mov		nPageno,eax
			invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMax
			sub		eax,nLine
			inc		eax
			mov		nMLine,eax
			mov		pd.nToPage,-1
		.else
			movzx	eax,pd.nFromPage
			dec		eax
			mov		nPageno,eax
			mov		edx,nPageSize
			mul		edx
			mov		nLine,eax
			invoke SendMessage,hEdit,EM_GETLINECOUNT,0,0
			or		eax,eax
			je		Exx
			inc		eax
			inc		eax
			mov		nMLine,eax
		.endif
		mov		eax,pML
		mov		rect.left,eax
		mov		eax,pX
		sub		eax,pMR
		mov		rect.right,eax
		mov		eax,pMT
		mov		rect.top,eax
		mov		eax,pY
		sub		eax,pMB
		mov		rect.bottom,eax
		invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
		mov		hRgn,eax
	  NxtPage:
		inc		nPageno
		mov		eax,nPageno
		.if ax>pd.nToPage
			jmp		Exx
		.endif
		invoke StartPage,pd.hDC
		mov		eax,pMT
		mov		ptY,eax
		invoke SelectObject,pd.hDC,hPrFont
		invoke SelectObject,pd.hDC,hRgn
		;Get tab width
		mov		eax,'WWWW'
		mov		dword ptr buffer,eax
		invoke GetTextExtentPoint32,pd.hDC,addr buffer,4,addr pt
		mov		eax,pt.x
		shr		eax,2
		mov		ecx,TabSize
		mul		ecx
		mov		tWt,eax
		.if PrnUseColors
			;Set color line number / header
			invoke SetTextColor,pd.hDC,PrnColors[16]
		.endif
		;Page number
		mov		eax,PrnPageNumber
		.if eax!=3
			mov		eax,'egaP'
			mov		dword ptr buffer,eax
			mov		buffer[4],' '
			invoke BinToDec,nPageno,addr buffer[5]
			.if PrnTime
				invoke strcpy,addr prnbuff,addr timebuff
				invoke strcat,addr prnbuff,addr buffer
			.else
				invoke strcpy,addr prnbuff,addr buffer
			.endif
			invoke strlen,addr prnbuff
			mov		ecx,eax
			push	eax
			invoke GetTextExtentPoint32,pd.hDC,addr prnbuff,ecx,addr pt
			mov		eax,PrnPageNumber
			.if eax==0
				;Left
				mov		eax,pML
				mov		ptX,eax
			.elseif eax==1
				;Center
				mov		eax,pX
				sub		eax,pML
				sub		eax,pMR
				shr		eax,1
				mov		ecx,pt.x
				shr		ecx,1
				sub		eax,ecx
				add		eax,pML
				mov		ptX,eax
			.else
				;Right
				mov		eax,pX
				sub		eax,pMR
				sub		eax,pt.x
				sub		eax,72
				mov		ptX,eax
			.endif
			pop		ecx
			invoke TabbedTextOut,pd.hDC,ptX,ptY,addr prnbuff,ecx,1,addr tWt,ptX
			mov		eax,PrnHeading
			.if eax==3 || eax==PrnPageNumber
				mov		eax,pt.y
				add		ptY,eax
				shr		eax,1
				add		ptY,eax
			.endif
		.endif
		;Heading
		mov		eax,PrnHeading
		.if eax!=3
			mov		prnbuff,0
			.if PrnProDes && fProject
				invoke strcpy,addr prnbuff,addr ProjectDescr
				invoke strlen,addr prnbuff
				mov		dword ptr prnbuff[eax],' - '
			.endif
			invoke GetWindowText,hMdiCld,addr buffer,sizeof buffer
			invoke iniRStripStr,addr buffer,'\'
			inc		eax
			invoke strcat,addr prnbuff,eax
			invoke strlen,addr prnbuff
			mov		ecx,eax
			push	eax
			invoke GetTextExtentPoint32,pd.hDC,addr prnbuff,ecx,addr pt
			mov		eax,PrnHeading
			.if eax==0
				;Left
				mov		eax,pML
				mov		ptX,eax
			.elseif eax==1
				;Center
				mov		eax,pX
				sub		eax,pML
				sub		eax,pMR
				shr		eax,1
				mov		ecx,pt.x
				shr		ecx,1
				sub		eax,ecx
				add		eax,pML
				mov		ptX,eax
			.else
				;Right
				mov		eax,pX
				sub		eax,pMR
				sub		eax,pt.x
				sub		eax,72
				mov		ptX,eax
			.endif
			pop		ecx
			invoke TabbedTextOut,pd.hDC,ptX,ptY,addr prnbuff,ecx,1,addr tWt,ptX
			mov		eax,pt.y
			add		ptY,eax
			shr		eax,1
			add		ptY,eax
		.endif
	  NxtLine:
		mov		eax,ptY
		add		eax,pt.y
		add		eax,pt.y
		cmp		eax,rect.bottom
		jnb		Ep
		dec		nMLine
		je		Ep
		mov		eax,pML
		mov		ptX,eax
		mov		word ptr prnbuff,sizeof prnbuff-1
		invoke SendMessage,hEdit,EM_GETLINE,nLine,addr prnbuff
		mov		byte ptr prnbuff[eax],0
		inc		nLine
		or		eax,eax
		je		El
		.if PrnUseColors
			;Set fore color
			invoke SetTextColor,pd.hDC,PrnColors
		.endif
		invoke strlen,addr prnbuff
		mov		ecx,eax
		invoke TabbedTextOut,pd.hDC,ptX,ptY,addr prnbuff,ecx,1,addr tWt,ptX
		.if PrnUseColors
			invoke PrnHilite,pd.hDC,ptX,ptY,pt.y,tWt,addr prnbuff
		.endif
	  El:
		mov		eax,pt.y
		add		ptY,eax
		jmp		NxtLine
	  Ep:
		invoke EndPage,pd.hDC
		.if nMLine
			jmp		NxtPage
		.endif
	  Exx:
		invoke EndDoc,pd.hDC
		invoke DeleteDC,pd.hDC
		invoke DeleteObject,hPrFont
		invoke DeleteObject,hRgn
		pop		ebx
	.endif
	ret

Print endp

