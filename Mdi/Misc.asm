.code

xGlobalAlloc proc t:DWORD,s:DWORD

	shr		s,3
	inc		s
	shl		s,3
	invoke GlobalAlloc,t,s
	.if !eax
		invoke MessageBox,hWnd,addr szGlobalFail,addr AppName,MB_OK
		xor		eax,eax
;	.else
;		push	eax
;		push	edi
;		test	t,GMEM_FIXED
;		.if !ZERO?
;			mov		edi,eax
;			mov		ecx,s
;			shr		ecx,2
;			xor		eax,eax
;			rep stosd
;		.endif
;		pop		edi
;		pop		eax
	.endif
	ret

xGlobalAlloc endp

xHeapAlloc proc h:DWORD,t:DWORD,s:DWORD
	
	shr		s,3
	inc		s
	shl		s,3
	invoke HeapAlloc,h,t,s
	.if !eax
		invoke MessageBox,hWnd,addr szHeapFail,addr AppName,MB_OK
		xor		eax,eax
;	.else
;		push	eax
;		push	edi
;		mov		edi,eax
;		mov		ecx,s
;		shr		ecx,2
;		xor		eax,eax
;		rep stosd
;		pop		edi
;		pop		eax
	.endif
	ret

xHeapAlloc endp

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

BinToDec endp

CalcSize proc nsize:DWORD

	mov		eax,nsize
	mov		ecx,nLngSize
	mul		ecx
	shr		eax,5
	ret

CalcSize endp

GetWinSize proc hWin:HWND,fDialog:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	rect:RECT
	LOCAL	nClass:DWORD

	.if fLngNoSize!=TRUE
		invoke GetClassName,hWin,addr buffer,sizeof buffer
		invoke lstrcmpi,addr buffer,addr szComboBox
		mov		nClass,eax
		invoke GetWindowRect,hWin,addr rect
		.if !fDialog || fLngNoSize==2
			invoke GetParent,hWin
			mov		edx,eax
			push	eax
			invoke ScreenToClient,edx,addr rect.left
			pop		edx
			invoke ScreenToClient,edx,addr rect.right
		.endif
		invoke CalcSize,rect.left
		mov		rect.left,eax
		invoke CalcSize,rect.top
		mov		rect.top,eax
		invoke CalcSize,rect.right
		mov		rect.right,eax
		invoke CalcSize,rect.bottom
		mov		rect.bottom,eax
		mov		eax,rect.right
		sub		eax,rect.left
		mov		edx,rect.bottom
		sub		edx,rect.top
		.if !nClass
			add		edx,200
		.endif
		mov		ecx,SWP_NOZORDER
		.if fDialog && fLngNoSize!=2
			mov		ecx,SWP_NOMOVE or SWP_NOZORDER
		.endif
		invoke SetWindowPos,hWin,0,rect.left,rect.top,eax,edx,ecx
	.endif
	ret

GetWinSize endp

DoHelp proc lpszHelpFile:DWORD,lpszWord:DWORD

	invoke strlen,lpszHelpFile
	mov		edx,lpszHelpFile
	mov		edx,[edx+eax-4]
	and		edx,5F5F5FFFh
	.if edx=='MHC.'
		.if !hHtmlOcx
			invoke LoadLibrary,offset szhhctrl
			mov		hHtmlOcx,eax
			invoke GetProcAddress,hHtmlOcx,offset szHtmlHelpA
			mov		pHtmlHelpProc,eax
		.endif
		.if hHtmlOcx
			mov		hhaklink.cbStruct,SizeOf HH_AKLINK
			mov		hhaklink.fReserved,FALSE
			mov		eax,lpszWord
			mov		hhaklink.pszKeywords,eax
			mov		hhaklink.pszUrl,NULL
			mov		hhaklink.pszMsgText,NULL
			mov		hhaklink.pszMsgTitle,NULL
			mov		hhaklink.pszWindow,NULL
			mov		hhaklink.fIndexOnFail,TRUE
			push	0
			push	HH_DISPLAY_TOPIC
			push	lpszHelpFile
			push	0
			Call	[pHtmlHelpProc]
			mov		hHHwin,eax
			push	offset hhaklink
			push	HH_KEYWORD_LOOKUP
			push	lpszHelpFile
			push	0
			Call	[pHtmlHelpProc]
		.endif
	.elseif edx=='PLH.'
		invoke WinHelp,hWnd,lpszHelpFile,HELP_KEY,lpszWord
	.endif
	ret

DoHelp endp

; fearless Added 01/03/2017 - allow CTRL+F1 and CTRL+F2 to search online for keyword. CTRL+F1 is for MSDN, CTRL+F2 is for google.
DoOnlineHelp PROC lpszWord:DWORD, dwSearchProvider:DWORD
    
    .IF lpszWord == NULL
        .IF dwSearchProvider == 0 ; MSDN
            Invoke lstrcpy, Addr szWebSearchKeyword, Addr szMSDNHomeAddress
        .ELSE
            Invoke lstrcpy, Addr szWebSearchKeyword, Addr szGoogleHomeAddress
        .ENDIF
    .ELSE
        Invoke lstrlen, lpszWord
        .IF eax == 0
            .IF dwSearchProvider == 0 ; MSDN
                Invoke lstrcpy, Addr szWebSearchKeyword, Addr szMSDNHomeAddress
            .ELSE
                Invoke lstrcpy, Addr szWebSearchKeyword, Addr szGoogleHomeAddress
            .ENDIF        
        .ELSE
            .IF dwSearchProvider == 0 ; MSDN
                Invoke lstrcpy, Addr szWebSearchKeyword, Addr szMSDNSearchUrl
            .ELSE ; Google
                Invoke lstrcpy, Addr szWebSearchKeyword, Addr szGoogleSearchUrl
            .ENDIF
            Invoke lstrcat, Addr szWebSearchKeyword, lpszWord
        .ENDIF
        Invoke SetWindowText, hInfEdt, Addr szWebSearchKeyword
    .ENDIF

    Invoke ShellExecute, Addr szShellOpen, NULL, Addr szWebSearchKeyword, NULL, NULL, SW_SHOWNORMAL
    ret

DoOnlineHelp ENDP


