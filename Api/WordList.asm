
WRDMEM		equ	256*1024

.code

ClearWordList proc

	invoke RtlZeroMemory,lpWordList,WordListSize
	mov		eax,lpWordList
	xor		eax,eax
	mov		rpProjectWordList,eax
	mov		rpWordListPos,eax
	ret

ClearWordList endp

AddWordToWordList proc uses	esi	edi,nType:DWORD,nOwner:DWORD,lpszStr:DWORD,nParts:DWORD

	mov		eax,rpWordListPos
	add		eax,16384
	mov		edi,WordListSize
	.if	eax>edi
		add		edi,WRDMEM
		invoke xGlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,edi
		push	eax
		invoke GlobalLock,eax
		push	eax
		push	edi
		mov		esi,lpWordList
		mov		edi,eax
		mov		ecx,WordListSize
		shr		ecx,2
		rep movsd
		pop		edi
		invoke GlobalUnlock,hWordList
		invoke GlobalFree,hWordList
		pop		eax
		mov		lpWordList,eax
		pop		eax
		mov		hWordList,eax
		mov		WordListSize,edi
	.endif
	mov		edi,lpWordList
	add		edi,rpWordListPos
	xor		ecx,ecx
	mov		esi,lpszStr
	.if	esi
		mov		edx,nParts
		.while edx
			mov		al,[esi]
			.if	al==0Dh || al==0Ah
				dec		esi
				xor		al,al
;			.elseif	al==':'	&& nType=='S'
;				mov		al,VK_TAB
			.endif
			mov		[edi+ecx+sizeof	PROPERTIES],al
			.if	!al
				dec		edx
			.endif
			inc		esi
			inc		ecx
		.endw
		mov		eax,nOwner
		mov		[edi].PROPERTIES.Owner,eax
		mov		eax,nType
		mov		[edi].PROPERTIES.nType,al
		mov		[edi].PROPERTIES.nSize,ecx
		lea		edi,[edi+ecx+sizeof	PROPERTIES]
		mov		[edi].PROPERTIES.nSize,0
		sub		edi,lpWordList
		mov		rpWordListPos,edi
		dec		ecx
	.endif
	mov		eax,ecx
	ret

AddWordToWordList endp

AddFileToWordList proc uses	esi,nType:DWORD,nOwner:DWORD,lpFileName:DWORD,nParts:DWORD
	LOCAL	hFile:DWORD
	LOCAL	hList:DWORD
	LOCAL	nBytes:DWORD

	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if	eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,addr nBytes
		mov		nBytes,eax
		inc		eax
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		hList,eax
		invoke ReadFile,hFile,hList,nBytes,addr	nBytes,FALSE
		invoke CloseHandle,hFile
		mov		esi,hList
		mov		al,[esi]
		or		al,al
		je		Ex
		dec		esi
	  Nx:
		inc		esi
		mov		ax,[esi]
		.if al==';' || ax=='//'
			call	SkipToEol
			mov		al,[esi]
		.endif
		cmp		al,0Dh
		je		Nx
		cmp		al,0Ah
		je		Nx
		.if	al
			.if	nParts>1
				call	ZeroTerminateParts
			.endif
			invoke AddWordToWordList,nType,nOwner,esi,nParts
			add		esi,eax
			or		eax,eax
			jne		Nx
		.endif
	  Ex:
		mov		eax,rpWordListPos
		mov		rpProjectWordList,eax
		invoke GlobalFree,hList
	.else
		invoke strcpy,addr	LineTxt,addr OpenFileFail
		invoke strcat,addr	LineTxt,lpFileName
		invoke MessageBox,NULL,addr	LineTxt,addr AppName,MB_OK or MB_ICONERROR
	.endif
	ret

ZeroTerminateParts:
	push	esi
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	or		al,al
	je		@f
	cmp		al,0Dh
	je		@f
	cmp		al,0Ah
	je		@f
	.if al=='('
		mov		al,','
	.endif
	cmp		al,','
	jne		@b
	xor		al,al
	mov		[esi],al
  @@:
	pop		esi
	retn

SkipToEol:
	.while byte ptr [esi] && byte ptr [esi]!=0Dh
		inc		esi
	.endw
	retn

AddFileToWordList endp

