
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

; Number convert
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

BinToDec proc lpszDec:DWORD,nVal:DWORD
	
	invoke wsprintf,lpszDec,addr szFmtDec,nVal
	ret

BinToDec endp

; File handling
ReadTheFile proc uses ebx,lpFileName:DWORD
	LOCAL	hMem:HGLOBAL
	LOCAL	hFile:HANDLE
	LOCAL	BytesRead:DWORD

	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		mov		ebx,eax
		inc		ebx
		; Allocate memory for files
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,ebx
		mov		hMem,eax
		dec		ebx
		invoke ReadFile,hFile,hMem,ebx,addr BytesRead,NULL
		invoke CloseHandle,hFile
		mov		eax,hMem
	.else
		xor		eax,eax
	.endif
	ret

ReadTheFile endp

ParseStructSizeFile proc uses ebx esi edi,hMemFile:HGLOBAL,hMemSize:HGLOBAL

	mov		esi,hMemFile
	mov		edi,hMemSize
	.while byte ptr [esi]
		; Skip empty line
		.while byte ptr [esi]==0Dh || byte ptr [esi]==0Ah
			inc		esi
		.endw
		; Get name
		xor		eax,eax
		xor		ebx,ebx
		.while byte ptr [esi]!=',' && byte ptr [esi]
			mov		al,[esi]
			.if al==':'
				mov		ah,al
				xor		al,al
			.endif
			mov		[edi].STRUCTSIZE.szName[ebx],al
			inc		esi
			inc		ebx
		.endw
		; Zero terminate name / alignment
		mov		[edi].STRUCTSIZE.szName[ebx],0
		.if ah!=':'
			; No alignment
			inc		ebx
			mov		[edi].STRUCTSIZE.szName[ebx],0
		.endif
		; Get size
		inc		esi
		invoke DecToBin,esi
		mov		[edi].STRUCTSIZE.nSize,eax
		; Move to next line
		.while byte ptr [esi-1]!=0Ah && byte ptr [esi]
			inc		esi
		.endw
		; Pont to next STRUCTSIZE
		lea		edi,[edi+ebx+sizeof STRUCTSIZE]
	.endw
	ret

ParseStructSizeFile endp

ParseSizeFile proc uses ebx esi edi,hMemFile:HGLOBAL,hMemSize:HGLOBAL

	mov		esi,hMemFile
	mov		edi,hMemSize
	.while byte ptr [esi]
		; Skip empty line
		.while byte ptr [esi]==0Dh || byte ptr [esi]==0Ah
			inc		esi
		.endw
		; Get name
		xor		ebx,ebx
		.while byte ptr [esi]!=',' && byte ptr [esi]
			mov		al,[esi]
			mov		[edi].STRUCTSIZE.szName[ebx],al
			inc		esi
			inc		ebx
		.endw
		; Zero terminate name
		mov		[edi].STRUCTSIZE.szName[ebx],0
		; Get size
		inc		esi
		invoke DecToBin,esi
		mov		[edi].STRUCTSIZE.nSize,eax
		; Move to next line
		.while byte ptr [esi-1]!=0Ah && byte ptr [esi]
			inc		esi
		.endw
		; Pont to next STRUCTSIZE
		lea		edi,[edi+ebx+sizeof STRUCTSIZE]
	.endw
	ret

ParseSizeFile endp

FindPredefinedTypeSize proc uses esi,lpszType:DWORD

	; Check predefined datatypes
	mov		esi,offset predatatype
	.while [esi].PREDATATYPE.lpName
		invoke strcmpi,lpszType,[esi].PREDATATYPE.lpName
		.if !eax
			; Found predefined datatype, convert it
			invoke strcpy,lpszType,[esi].PREDATATYPE.lpConvert
			; Get size
			mov		eax,[esi].PREDATATYPE.nSize
			jmp		Ex
		.endif
		; Point to next PREDATATYPE
		lea		esi,[esi+sizeof PREDATATYPE]
	.endw
	xor		eax,eax
  Ex:
	ret

FindPredefinedTypeSize endp

; Search type lists
FindTypeSize proc uses esi,lpszType:DWORD

	; Check predefined datatypes
	invoke FindPredefinedTypeSize,lpszType
	.if eax
		; Found
		xor		edx,edx
		jmp		Ex
	.endif
	; Check types
	mov		esi,hMemTypeSize
	.while [esi].STRUCTSIZE.szName
		invoke strcmp,lpszType,addr [esi].STRUCTSIZE.szName
		.if !eax
			; Get size
			mov		eax,[esi].STRUCTSIZE.nSize
			xor		edx,edx
			jmp		Ex
		.endif
		; Point to next STRUCTSIZE
		; Name lenght
		invoke strlen,addr [esi].STRUCTSIZE.szName
		lea		esi,[esi+eax+sizeof STRUCTSIZE]
	.endw
	; Check structures
	mov		esi,hMemStructSize
	.while [esi].STRUCTSIZE.szName
		invoke strcmp,lpszType,addr [esi].STRUCTSIZE.szName
		.if !eax
			push	esi
			; Get alignment
			; Name lenght
			invoke strlen,addr [esi].STRUCTSIZE.szName
			lea		esi,[esi+eax+sizeof STRUCTSIZE]
			xor		edx,edx
			.if byte ptr [esi]
				invoke FindPredefinedTypeSize,esi
				mov		edx,eax
			.endif
			pop		esi
			; Get size
			mov		eax,[esi].STRUCTSIZE.nSize
			jmp		Ex
		.endif
		; Point to next STRUCTSIZE
		; Name lenght
		invoke strlen,addr [esi].STRUCTSIZE.szName
		push	eax
		; Alignment lenght
		invoke strlen,addr [esi+eax+1].STRUCTSIZE.szName
		pop		edx
		lea		eax,[edx+eax+1]
		lea		esi,[esi+eax+sizeof STRUCTSIZE]
	.endw
	xor		eax,eax
	xor		edx,edx
  Ex:
	ret

FindTypeSize endp

FindConstSize proc uses ebx esi edi,lpszConst:DWORD

	; Check constants
	mov		esi,hMemConstSize
	.while [esi].STRUCTSIZE.szName
		invoke strcmp,lpszConst,addr [esi].STRUCTSIZE.szName
		.if !eax
			; Get size
			mov		eax,[esi].STRUCTSIZE.nSize
			jmp		Ex
		.endif
		; Point to next STRUCTSIZE
		; Name lenght
		invoke strlen,addr [esi].STRUCTSIZE.szName
		lea		esi,[esi+eax+sizeof STRUCTSIZE]
	.endw
	; Check types
	mov		esi,hMemTypeSize
	.while [esi].STRUCTSIZE.szName
		invoke strcmp,lpszConst,addr [esi].STRUCTSIZE.szName
		.if !eax
			; Get size
			mov		eax,[esi].STRUCTSIZE.nSize
			jmp		Ex
		.endif
		; Point to next STRUCTSIZE
		; Name lenght
		invoke strlen,addr [esi].STRUCTSIZE.szName
		lea		esi,[esi+eax+sizeof STRUCTSIZE]
	.endw
	; Check structures
	mov		esi,hMemStructSize
	.while [esi].STRUCTSIZE.szName
		invoke strcmp,lpszConst,addr [esi].STRUCTSIZE.szName
		.if !eax
			; Get size
			mov		eax,[esi].STRUCTSIZE.nSize
			jmp		Ex
		.endif
		; Point to next STRUCTSIZE
		; Name lenght
		invoke strlen,addr [esi].STRUCTSIZE.szName
		push	eax
		; Alignment lenght
		invoke strlen,addr [esi+eax+1].STRUCTSIZE.szName
		pop		edx
		lea		eax,[edx+eax+1]
		lea		esi,[esi+eax+sizeof STRUCTSIZE]
	.endw
	xor		eax,eax
  Ex:
	ret

FindConstSize endp

;DestroyCommentBlock proc uses esi,lpszStruct:DWORD
;	LOCAL	szitem[256]:BYTE
;
;  @@:
;	lea		ebx,szitem
;	call	GetItem
;	invoke strcmp,addr szitem,addr szComment
;	.if !eax
;		push	esi
;		call	SkipWhiteSpace
;		mov		al,[esi]
;		mov		byte ptr [esi],' '
;		.while al!=byte ptr [esi]
;			.if byte ptr [esi]!=0Dh && byte ptr [esi]!=0Ah
;				mov		byte ptr [esi],' '
;			.endif
;			inc		esi
;		.endw
;		call	DestroyToEol
;		pop		eax
;		push	esi
;		mov		esi,eax
;		call	DestroyToEol
;		pop		esi
;	.endif
;	call	SkipToEol
;	call	SkipCrLf
;	.if byte ptr [esi]
;		jmp		@b
;	.endif
;	ret
;
;SkipWhiteSpace:
;	.while byte ptr [esi]==VK_SPACE
;		inc		esi
;	.endw
;	retn
;
;SkipCrLf:
;	call	SkipWhiteSpace
;	.if byte ptr [esi]==VK_RETURN
;		inc		esi
;		.if byte ptr [esi]==0Ah
;			inc		esi
;			jmp		SkipCrLf
;		.endif
;	.endif
;	retn
;
;SkipToEol:
;	.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
;		inc		esi
;	.endw
;	retn
;
;GetItem:
;	call	SkipWhiteSpace
;	.while byte ptr [esi]!=VK_SPACE && byte ptr [esi]!=VK_RETURN && byte ptr [esi]
;		mov		al,[esi]
;		mov		[ebx],al
;		inc		esi
;		inc		ebx
;	.endw
;	mov		byte ptr [ebx],0
;	retn
;
;DestroyToEol:
;	.while byte ptr [esi] && byte ptr [esi]!=0Dh
;		mov		byte ptr [esi],' '
;		inc		esi
;	.endw
;	retn
;
;DestroyCommentBlock endp
;
DestroyWords proc uses esi edi,lpszStruct:DWORD
	LOCAL	szitem1[256]:BYTE
	LOCAL	szitem2[256]:BYTE
	LOCAL	lpline:DWORD

	mov		esi,lpszStruct
  @@:
	mov		lpline,esi
	lea		ebx,szitem1
	call	GetItem
	lea		ebx,szitem2
	call	GetItem
	lea		ebx,szitem1
	mov		edi,offset szFirstWord
	call	TestWords
	.if !eax
		lea		ebx,szitem2
		mov		edi,offset szSecondWord
		call	TestWords
	.endif
	.if eax
		mov		esi,lpline
		call	DestroyToEol
	.endif
	call	SkipToEol
	call	SkipCrLf
	.if byte ptr [esi]
		jmp		@b
	.endif
	ret

TestWords:
	.while byte ptr [edi]
		invoke strcmpi,ebx,edi
		.if eax
			invoke strlen,edi
			lea		edi,[edi+eax+1]
		.else
			inc		eax
			retn
		.endif
	.endw
	xor		eax,eax
	retn

SkipWhiteSpace:
	.while byte ptr [esi]==VK_SPACE
		inc		esi
	.endw
	retn

SkipCrLf:
	call	SkipWhiteSpace
	.if byte ptr [esi]==VK_RETURN
		inc		esi
		.if byte ptr [esi]==0Ah
			inc		esi
			jmp		SkipCrLf
		.endif
	.endif
	retn

SkipToEol:
	.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
		inc		esi
	.endw
	retn

GetItem:
	call	SkipWhiteSpace
	.while byte ptr [esi]!=VK_SPACE && byte ptr [esi]!=VK_RETURN && byte ptr [esi]
		mov		al,[esi]
		mov		[ebx],al
		inc		esi
		inc		ebx
	.endw
	mov		byte ptr [ebx],0
	retn

DestroyToEol:
	.while byte ptr [esi] && byte ptr [esi]!=0Dh
		mov		byte ptr [esi],' '
		inc		esi
	.endw
	retn

DestroyWords endp

; Pre parse. Destroys comments and replace tab with space
PreParse proc uses esi,lpszStruct:DWORD

	mov		esi,lpszStruct
	.while byte ptr [esi]
		.if byte ptr [esi]==';'
			call	DestroyToEol
		.elseif byte ptr [esi]==VK_TAB
			mov		byte ptr [esi],' '
		.endif
		inc		esi
	.endw
;	invoke DestroyCommentBlock,lpszStruct
	invoke DestroyWords,lpszStruct
	ret

DestroyToEol:
	.while byte ptr [esi] && byte ptr [esi]!=0Dh
		mov		byte ptr [esi],' '
		inc		esi
	.endw
	retn

PreParse endp

; Parse the structure. esi is a pointer to the structure
ParseStruct proc lpszName:DWORD,lpSize:DWORD,lpOut:DWORD,nUnion:DWORD,nAlign:DWORD
	LOCAL	szitem1[128]:BYTE
	LOCAL	szitem2[128]:BYTE
	LOCAL	szitem3[128]:BYTE
	LOCAL	szitem4[128]:BYTE
	LOCAL	szout[2048]:BYTE
	LOCAL	nsize:DWORD

	mov		nsize,0
	mov		szout,0
  Nxt:
	lea		ebx,szitem1
	call	GetItem
	lea		ebx,szitem2
	call	GetItem
	lea		ebx,szitem3
	call	GetItem
	lea		ebx,szitem4
	call	GetItem
	call	SkipToEol
	call	SkipCrLf
	invoke strcmpi,addr szitem2,addr szUnion
	.if !eax
		; Main Union
		.if szitem3
			invoke FindPredefinedTypeSize,addr szitem3
		.endif
		mov		nAlign,eax
		invoke ParseStruct,NULL,addr nsize,addr szout,0,eax
		; Union name
		invoke strcat,lpOut,addr szitem1
		; Alignment
		invoke strcat,lpOut,addr szColon
		.if szitem3
			invoke strcat,lpOut,addr szitem3
		.else
			invoke strcat,lpOut,addr szBYTE
		.endif
		; Size
		invoke strcat,lpOut,addr szComma
		mov		ebx,nAlign
		call	AlignIt
		invoke BinToDec,addr szTemp,nsize
		invoke strcat,lpOut,addr szTemp
		; Itsms
		invoke strcat,lpOut,addr szout
		mov		eax,esi
		jmp		Ex
	.else
		invoke strcmpi,addr szitem2,addr szStruct
		.if !eax
			; Main Struct
			.if szitem3
				invoke FindPredefinedTypeSize,addr szitem3
			.endif
			mov		nAlign,eax
			invoke ParseStruct,NULL,addr nsize,addr szout,0,eax
			; Struct name
			invoke strcat,lpOut,addr szitem1
			; Alignment
			.if szitem3
				invoke strcat,lpOut,addr szColon
				invoke strcat,lpOut,addr szitem3
			.endif
			; Size
			invoke strcat,lpOut,addr szComma
			mov		ebx,nAlign
			call	AlignIt
			invoke BinToDec,addr szTemp,nsize
			invoke strcat,lpOut,addr szTemp
			; Itsms
			invoke strcat,lpOut,addr szout
			mov		eax,esi
			jmp		Ex
		.else
			invoke strcmpi,addr szitem1,addr szUnion
			.if !eax
				; Sub union. Sub unions can not have an alignment but will inherit parent alignment
				.if !szitem2
					; Anonymus
					invoke ParseStruct,NULL,addr nsize,addr szout,1,nAlign
				.else
					; Named
					invoke ParseStruct,addr szitem2,addr nsize,addr szout,1,nAlign
				.endif
				invoke strcat,lpOut,addr szout
				mov		szout,0
				jmp		Nxt
			.else
				invoke strcmpi,addr szitem1,addr szStruct
				.if !eax
					; Sub struct. Sub structures can not have an alignment but will inherit parent alignment
					.if !szitem2
						; Anonymus
						invoke ParseStruct,NULL,addr nsize,addr szout,0,nAlign
					.else
						; Named
						invoke ParseStruct,addr szitem2,addr nsize,addr szout,0,nAlign
					.endif
					invoke strcat,lpOut,addr szout
					mov		szout,0
					jmp		Nxt
				.else
					invoke strcmpi,addr szitem1,addr szEnds
					.if !eax
						; Anonymus ends
						.if nUnion
							mov		eax,nUnion
							add		nsize,eax
						.endif
						mov		eax,nsize
						mov		edx,lpSize
						add		[edx],eax
						mov		eax,esi
						jmp		Ex
					.else
						invoke strcmpi,addr szitem2,addr szEnds
						.if !eax
							; Named ends
							.if nUnion
								mov		eax,nUnion
								add		nsize,eax
							.endif
							mov		eax,nsize
							mov		edx,lpSize
							add		[edx],eax
							mov		eax,esi
							jmp		Ex
						.elseif szitem1 && szitem2
							; Item
							invoke FindTypeSize,addr szitem2
							.if !eax
								invoke FindTypeSize,addr szitem1
								.if eax
									invoke strcpy,addr szitem2,addr szitem1
									mov		szitem1,0
									mov		eax,TRUE
								.endif
							.endif
							.if eax
								mov		ebx,eax
								invoke strcat,lpOut,addr szComma
								invoke strcat,lpOut,addr szCrLf
								.if lpszName
									invoke strcat,lpOut,lpszName
									invoke strcat,lpOut,addr szDot
								.endif
								invoke strcat,lpOut,addr szitem1
								; Array
								mov		eax,dword ptr szitem4
								and		eax,5F5F5Fh
								.if eax=='PUD'
									mov		al,szitem3
									.if al>='0' && al<='9'
										invoke DecToBin,addr szitem3
									.else
										invoke FindConstSize,addr szitem3
									.endif
									.if eax
										push	eax
										invoke BinToDec,addr szTemp,eax
										invoke strcat,lpOut,addr szLPA
										invoke strcat,lpOut,addr szTemp
										invoke strcat,lpOut,addr szRPA
										pop		eax
										mul		ebx
										mov		ebx,eax
									.endif
								.endif
								invoke strcat,lpOut,addr szColon
								invoke strcat,lpOut,addr szitem2
								invoke strcat,lpOut,addr szComma
								.if nUnion
									mov		edx,lpSize
									mov		eax,[edx]
								.else
									call	AlignIt
									mov		eax,nsize
									mov		edx,lpSize
									add		eax,[edx]
								.endif
								invoke BinToDec,addr szTemp,eax
								invoke strcat,lpOut,addr szTemp
								.if nUnion
									.if ebx>nUnion
										mov		nUnion,ebx
									.endif
								.else
									add		nsize,ebx
								.endif
								jmp		Nxt
							.endif
						.endif
					.endif
				.endif
			.endif
		.endif
	.endif
	inc		nErr
	xor		eax,eax
  Ex:
	ret

AlignIt:
	mov		ecx,nAlign
	.if ecx==4
		; DWord align
		.if ebx==4
			test	nsize,3
			.if !ZERO?
				shr		nsize,2
				inc		nsize
				shl		nsize,2
			.endif
		.endif
	.elseif ecx==2
		; Word align
		.if ebx==2 || ebx==4
			test	nsize,1
			.if !ZERO?
				shr		nsize,1
				inc		nsize
				shl		nsize,1
			.endif
		.endif
	.endif
	retn

SkipWhiteSpace:
	.while byte ptr [esi]==VK_SPACE
		inc		esi
	.endw
	retn

SkipCrLf:
	call	SkipWhiteSpace
	.if byte ptr [esi]==VK_RETURN
		inc		esi
		.if byte ptr [esi]==0Ah
			inc		esi
			jmp		SkipCrLf
		.endif
	.endif
	retn

SkipToEol:
	.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
		inc		esi
	.endw
	retn

GetItem:
	call	SkipWhiteSpace
	.while byte ptr [esi]!=VK_SPACE && byte ptr [esi]!=VK_RETURN && byte ptr [esi]
		mov		al,[esi]
		mov		[ebx],al
		inc		esi
		inc		ebx
	.endw
	mov		byte ptr [ebx],0
	retn

ParseStruct endp

ResultProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		; Set edit box font
		invoke SendDlgItemMessage,hWin,IDC_EDTRESULT,WM_SETFONT,hEditFont,FALSE
		; Set edit box text
		mov		eax,offset szOutput
		.if nErr
			mov		eax,offset szError
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTRESULT,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				; Exit
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.endif
		.endif
	.elseif eax==WM_CLOSE
		; End the dialog
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ResultProc endp

ParseMasmStruct proc uses ebx esi edi
	LOCAL	hWin:HWND

	mov		hWin,0
	; Get the struct text
	invoke GetWindowText,hEdt,addr szInput,sizeof szInput
	.if eax
		mov		nErr,0
		mov		szOutput,0
		mov		esi,offset szInput
		invoke PreParse,esi
		invoke ParseStruct,NULL,addr nSize,addr szOutput,0,1
		.if fShowResult
			; Show result
			invoke DialogBoxParam,hInstance,IDD_DLGRESULT,NULL,addr ResultProc,NULL
			mov		hWin,eax
		.endif
	.endif
	ret

ParseMasmStruct endp

FromInc proc uses ebx esi edi,lpFileName:DWORD,lpTypeStart:DWORD,lpTypeEnd:DWORD
	LOCAL	hMemInc:HGLOBAL
	LOCAL	hMemTxt:HGLOBAL
	LOCAL	lentypestart:DWORD
	LOCAL	lentypeend:DWORD
	LOCAL	lpword1:DWORD
	LOCAL	len1:DWORD
	LOCAL	lpword2:DWORD
	LOCAL	len2:DWORD
	LOCAL	lpstart:DWORD
	LOCAL	lenstart:DWORD
	LOCAL	lpend:DWORD
	LOCAL	nfound:DWORD

	mov		nfound,0
	mov		fShowResult,FALSE
	invoke strlen,lpTypeStart
	mov		lentypestart,eax
	invoke strlen,lpTypeEnd
	mov		lentypeend,eax
	; Read the inc file
	invoke ReadTheFile,lpFileName
	mov		hMemInc,eax
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,512*1024
	mov		hMemTxt,eax
	mov		esi,hMemInc
	invoke PreParse,esi
;	invoke SetWindowText,hEdt,esi
;	ret
  @@:
	call	FindStart
	.if eax
		call	FindEnd
		.if eax
			mov		eax,lpend
			sub		eax,lpstart
			inc		eax
			invoke lstrcpyn,addr szInput,lpstart,eax
			invoke SetWindowText,hEdt,addr szInput
			mov		szCrLf,0
			invoke ParseMasmStruct
			mov		szCrLf,0Dh
			.if !nErr
				invoke strcat,addr szOutput,addr szCrLf
				invoke strcat,hMemTxt,addr szOutput
				inc		nfound
				.if byte ptr [esi]
					jmp		@b
				.endif
			.else
				; Error
				invoke MessageBox,hWnd,addr szError,addr szError,MB_OK
			.endif
		.else
			; Error
			invoke MessageBox,hWnd,addr szError,addr szError,MB_OK
		.endif
	.endif
	invoke SetWindowText,hEdt,hMemTxt
	; Free the inc memory
	invoke GlobalFree,hMemInc
	; Free the txt memory
	invoke GlobalFree,hMemTxt
PrintDec nfound
	ret

FindEnd:
	call	SkipWhiteSpace
	call	GetWord
	.if edx!=esi
		mov		lpword1,edx
		mov		eax,esi
		sub		eax,edx
		mov		len1,eax
		call	GetWord
		.if edx!=esi
			mov		lpword2,edx
			mov		eax,esi
			sub		eax,edx
			mov		len2,eax
			mov		edx,lpTypeEnd
			mov		edi,lentypeend
			mov		ebx,lpword2
			mov		eax,len2
			call	Compare
			.if eax
				mov		edx,lpstart
				mov		edi,lenstart
				mov		ebx,lpword1
				mov		eax,len1
				call	CompareCase
				.if eax
					; End found
					call	SkipToEol
					call	SkipCrLf
					mov		eax,esi
					mov		lpend,eax
					mov		eax,TRUE
					retn
				.else
					call	SkipToEol
					call	SkipCrLf
					.if byte ptr [esi]
						jmp		FindEnd
					.endif
				.endif
			.else
				call	SkipToEol
				call	SkipCrLf
				.if byte ptr [esi]
					jmp		FindEnd
				.endif
			.endif
		.else
			call	SkipToEol
			call	SkipCrLf
			.if byte ptr [esi]
				jmp		FindEnd
			.endif
		.endif
	.else
		call	SkipToEol
		call	SkipCrLf
		.if byte ptr [esi]
			jmp		FindEnd
		.endif
	.endif
	; End not found
	xor		eax,eax
	retn

FindStart:
	call	SkipWhiteSpace
	call	GetWord
	.if edx!=esi
		mov		lpword1,edx
		mov		eax,esi
		sub		eax,edx
		mov		len1,eax
		call	GetWord
		.if edx!=esi
			mov		lpword2,edx
			mov		eax,esi
			sub		eax,edx
			mov		len2,eax
			mov		edx,lpTypeStart
			mov		ebx,lpword2
			mov		edi,lentypestart
			call	Compare
			.if eax
				; Start found
				mov		eax,lpword1
				mov		lpstart,eax
				mov		eax,len1
				mov		lenstart,eax
				call	SkipToEol
				call	SkipCrLf
				mov		eax,TRUE
				retn
			.else
				call	SkipToEol
				call	SkipCrLf
				.if byte ptr [esi]
					jmp		FindStart
				.endif
			.endif
		.else
			call	SkipToEol
			call	SkipCrLf
			.if byte ptr [esi]
				jmp		FindStart
			.endif
		.endif
	.else
		call	SkipToEol
		call	SkipCrLf
		.if byte ptr [esi]
			jmp		FindStart
		.endif
	.endif
	; Start not found
	xor		eax,eax
	retn

CompareCase:
	.if edi==eax
		xor		ecx,ecx
		.while ecx<edi
			mov		al,[ebx+ecx]
			.break .if al!=[edx+ecx]
			inc		ecx
		.endw
		xor		eax,eax
		.if ecx==edi
			inc		eax
		.endif
	.else
		xor		eax,eax
	.endif
	retn

Compare:
	.if edi==eax
		xor		ecx,ecx
		.while ecx<edi
			mov		al,[ebx+ecx]
			.if al>='A' && al<='Z'
				or		al,20h
			.endif
			.break .if al!=[edx+ecx]
			inc		ecx
		.endw
		xor		eax,eax
		.if ecx==edi
			inc		eax
		.endif
	.else
		xor		eax,eax
	.endif
	retn

GetWord:
	call	SkipWhiteSpace
	mov		edx,esi
GetWord1:
	mov		al,[esi]
	.if (al>='0' && al<='9') || (al>='A' && al<='Z') || (al>='a' && al<='z')
		inc		esi
		jmp		GetWord1
	.endif
	retn

SkipWhiteSpace:
	.while byte ptr [esi]==VK_SPACE
		inc		esi
	.endw
	retn

SkipCrLf:
	call	SkipWhiteSpace
	.if byte ptr [esi]==VK_RETURN
		inc		esi
		.if byte ptr [esi]==0Ah
			inc		esi
			jmp		SkipCrLf
		.endif
	.endif
	retn

SkipToEol:
	.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
		inc		esi
	.endw
	retn

FromInc endp