.486
.model flat,stdcall
option casemap:none

include fphelp.inc

.code

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

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

SymInitialize proc hProcess:HANDLE,UserSearchPath:LPSTR,fInvadeProcess:BOOL

	mov		eax,hProcess
	mov		hProcessDbg,eax
	mov		eax,TRUE
	ret

SymInitialize endp

SymLoadModule proc uses ebx esi,hProcess:HANDLE,hFileOpt:HANDLE,ImageName:LPSTR,ModuleName:LPSTR,BaseOfDll:DWORD,SizeOfDll:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	dwBytesRead:DWORD
	LOCAL	buffer[32]:BYTE

	invoke CreateFile,ImageName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		mov		ebx,eax
		inc		ebx
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,ebx
		mov		hMemFile,eax
		invoke ReadFile,hFile,hMemFile,ebx,addr dwBytesRead,NULL
		invoke CloseHandle,hFile
		mov		esi,hMemFile
		movzx	ebx,word ptr [esi+86h]
		mov		nHeaders,ebx
		lea		esi,[esi+178h]
		.while ebx
			invoke strcpyn,addr buffer,addr [esi].SECTIONHEADER.sName,9
			invoke strcmp,addr buffer,addr szSecStab
			.if !eax
				mov		eax,[esi].SECTIONHEADER.PointerToRawData
				mov		rpstab,eax
			.endif
			invoke strcmp,addr buffer,addr szSecStabstr
			.if !eax
				mov		eax,[esi].SECTIONHEADER.PointerToRawData
				mov		rpstabs,eax
			.endif
			lea		esi,[esi+sizeof SECTIONHEADER]
			dec		ebx
		.endw
		mov		eax,TRUE
	.else
		xor		eax,eax
	.endif
	ret

SymLoadModule endp

SymGetModuleInfo proc uses ebx,hProcess:HANDLE,dwAddr:DWORD,ModuleInfo:DWORD;PIMAGEHLP_MODULE

	mov		ebx,ModuleInfo
	mov		eax,SymPdb
	mov		[ebx].IMAGEHLP_MODULE.SymType1,eax
	mov		eax,TRUE
	ret

SymGetModuleInfo endp

SourceExist proc uses esi,lpName:DWORD

	mov		esi,offset source
	.while byte ptr [esi]
		invoke strcmpi,esi,lpName
		.if !eax
			jmp		Ex
		.endif
		invoke strlen,esi
		lea		esi,[esi+eax+1]
	.endw
	invoke strcpy,esi,lpName
	mov		eax,esi
  Ex:
	ret

SourceExist endp

SymEnumTypes proc uses ebx esi edi,hProcess:HANDLE,BaseOfDll:ULONG64,EnumTypesCallback:DWORD,UserContext:DWORD
	LOCAL	ninx:DWORD
	LOCAL	nsize:DWORD

	invoke RtlZeroMemory,offset datatype,sizeof datatype
	.if rpstab && rpstabs
		mov		esi,rpstab
		add		esi,hMemFile
		movzx	ecx,[esi].STAB.nline
		.while ecx
			push	ecx
			movzx	eax,[esi].STAB.code
			.if eax==128
				xor		eax,eax
				mov		ninx,eax
				mov		nsize,eax
				mov		edi,rpstabs
				add		edi,hMemFile
				add		edi,[esi].STAB.stabs
				invoke lstrcpy,addr szname,edi
				mov		edi,offset szname
				.while byte ptr [edi]
					.if byte ptr [edi]==':'
						mov		byte ptr [edi],0
						inc		edi
						.break
					.endif
					inc		edi
				.endw
				.if word ptr [edi]=='tT'
					add		edi,2
					invoke DecToBin,edi
					mov		ninx,eax
					.while byte ptr [edi]
						.if byte ptr [edi]=='='
							inc		edi
							.if byte ptr [edi]=='s'
								inc		edi
								invoke DecToBin,edi
								mov		nsize,eax
							.endif
							.break
						.endif
						inc		edi
					.endw
				.elseif byte ptr [edi]=='t'
					inc		edi
					invoke DecToBin,edi
					mov		ninx,eax
					.while byte ptr [edi]
						.if byte ptr [edi]=='=' && word ptr [edi+1]=='ra'
							invoke strcpy,addr szname,edi
							.break
						.endif
						inc		edi
					.endw
				.endif
				.if ninx
					invoke RtlZeroMemory,addr syminf,sizeof SYMBOL_INFO
					mov		eax,nsize
					mov		syminf.nSize,eax
					mov		eax,ninx
					mov		syminf.TypeIndex,eax
					mov		edx,sizeof DATATYPE
					mul		edx
					lea		edi,[eax+offset datatype]
					invoke strcpy,addr [edi].DATATYPE.szName,addr szname
					mov		eax,nsize
					mov		[edi].DATATYPE.nSize,eax
					mov		syminf.SizeOfStruct,sizeof SYMBOL_INFO+sizeof szname
					invoke strlen,addr szname
					mov		syminf.NameLen,eax
					mov		syminf.MaxNameLen,sizeof szname+1
					invoke strcpy,addr syminf.szName,addr szname
					push	UserContext
					push	nsize
					push	offset syminf
					call	EnumTypesCallback
				.endif
			.endif
			pop		ecx
			lea		esi,[esi+sizeof STAB]
			dec		ecx
		.endw
	.endif
	mov		eax,TRUE
	ret

SymEnumTypes endp

GetArray proc uses ebx esi edi,lpStab:DWORD,lpName:DWORD

	mov		esi,lpStab
	mov		edi,lpName
	mov		byte ptr [edi],'['
	inc		edi
	.while word ptr [esi]=='ra'
		inc		esi
		call	SkipSemi
		.while byte ptr [esi] && byte ptr [esi]!=';'
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		mov		word ptr [edi],'..'
		add		edi,2
		call	SkipSemi
		.while byte ptr [esi] && byte ptr [esi]!=';'
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		call	SkipSemi
		invoke DecToBin,esi
		mov		edx,sizeof DATATYPE
		mul		edx
		lea		esi,[eax+offset datatype]
		.if [esi].DATATYPE.szName=='='
			mov		byte ptr [edi],';'
			inc		edi
			inc		esi
		.else
			mov		word ptr [edi],':]'
			add		edi,2
			invoke strcpy,edi,addr [esi].DATATYPE.szName
			.break
		.endif
	.endw
	mov		eax,[esi].DATATYPE.nSize
	ret

SkipSemi:
	.while byte ptr [esi] && byte ptr [esi-1]!=';'
		inc		esi
	.endw
	retn

GetArray endp

EnumProcs proc uses ebx esi edi,EnumSymbolsCallback:DWORD,UserContext:DWORD
	LOCAL	fproc:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	nline:DWORD
	LOCAL	nadr:DWORD
	LOCAL	nblock:DWORD

	.if rpstab && rpstabs
		mov		esi,rpstab
		add		esi,hMemFile
		movzx	ecx,[esi].STAB.nline
		mov		fproc,FALSE
		.while ecx
			push	ecx
			movzx	eax,[esi].STAB.code
			mov		edi,rpstabs
			add		edi,hMemFile
			add		edi,[esi].STAB.stabs
			.if eax==40 && !fproc
				mov		ebx,offset szname
				mov		edx,edi
				mov		ecx,1
				.while byte ptr [edx] && byte ptr [edx]!=':'
					inc		ecx
					inc		edx
				.endw
				invoke strcpyn,ebx,edi,ecx
				invoke strlen,ebx
				lea		ebx,[ebx+eax+1]
				lea		edi,[edi+eax]
				xor		eax,eax
				.if byte ptr [edi+1]=='S'
					invoke DecToBin,addr [edi+2]
				.endif
				.if eax
					mov		edx,sizeof DATATYPE
					mul		edx
					lea		edi,[eax+offset datatype]
					.if [edi].DATATYPE.szName=='='
						invoke GetArray,addr [edi].DATATYPE.szName[1],ebx
					.else
						mov		byte ptr [ebx],':'
						inc		ebx
						invoke strcpy,ebx,addr [edi].DATATYPE.szName
						mov		eax,[edi].DATATYPE.nSize
					.endif
					.if !eax
						dec		eax
					.endif
					push	UserContext
					push	eax							; Size
					push	[esi].STAB.ad				; Address
					push	offset szname
					call	EnumSymbolsCallback
				.endif
			.elseif eax==36 && !fproc
				; Proc
				mov		edx,edi
				mov		ecx,1
				.while byte ptr [edx] && byte ptr [edx]!=':'
					inc		ecx
					inc		edx
				.endw
				.if byte ptr [edx+1]=='F'
					mov		nblock,0
					mov		fproc,TRUE
					movzx	eax,[esi].STAB.nline
					mov		nline,eax
					mov		eax,[esi].STAB.ad
					mov		nadr,eax
					mov		ebx,offset szname
					invoke strcpyn,ebx,edi,ecx
					invoke strlen,ebx
					lea		ebx,[ebx+eax+1]
					mov		byte ptr [ebx],0
				.endif
			.elseif eax==160 && fproc
				; Param / Local
				xor		ecx,ecx
				.while byte ptr [edi+ecx]
					.if byte ptr [edi+ecx]==':'
						.if byte ptr [ebx]
							push	ecx
							invoke strlen,ebx
							lea		ebx,[ebx+eax]
							mov		byte ptr [ebx],','
							inc		ebx
							pop		ecx
						.endif
						inc		ecx
						invoke strcpyn,ebx,edi,ecx
						invoke strlen,ebx
						lea		ebx,[ebx+eax]
						lea		edi,[edi+eax]
						xor		eax,eax
						.if byte ptr [edi+1]=='p' || byte ptr [edi+1]=='v'
							invoke DecToBin,addr [edi+2]
						.elseif byte ptr [edi+1]>='0' && byte ptr [edi+1]<='9'
							invoke DecToBin,addr [edi+1]
						.endif
						.if eax
							mov		edx,sizeof DATATYPE
							mul		edx
							lea		edi,[eax+offset datatype]
							mov		byte ptr [ebx],':'
							inc		ebx
							invoke strcpy,ebx,addr [edi].DATATYPE.szName
							invoke strlen,ebx
							lea		ebx,[ebx+eax]
							invoke wsprintf,ebx,addr szfmtdword,[esi].STAB.ad
						.endif
						.break
					.endif
					inc		ecx
				.endw
			.elseif eax==192 && fproc
				; Block start
				inc		nblock
			.elseif eax==224 && fproc
				; Block end
				dec		nblock
				.if !nblock
					mov		fproc,FALSE
					push	UserContext
					push	[esi].STAB.ad				; Size
					push	nadr
					push	offset szname
					call	EnumSymbolsCallback
				.endif
			.endif
			pop		ecx
			lea		esi,[esi+sizeof STAB]
			dec		ecx
		.endw
	.endif
	ret

EnumProcs endp

SymEnumerateSymbols proc hProcess:HANDLE,BaseOfDll:DWORD,EnumSymbolsCallback:DWORD,UserContext:DWORD

	invoke EnumProcs,EnumSymbolsCallback,UserContext
	mov		eax,TRUE
	ret

SymEnumerateSymbols endp

SymEnumSourceFiles proc uses ebx esi edi,hProcess:HANDLE,BaseOfDll:ULONG64,pMask:DWORD,EnumSourcesCallback:DWORD,UserContext:DWORD
	LOCAL	src:SOURCEFILE

	mov		esi,rpstab
	add		esi,hMemFile
	movzx	ebx,[esi].STAB.nline
	mov		dword ptr source,0
	.while ebx
		movzx	eax,[esi].STAB.code
		movzx	edx,[esi].STAB.nline
		mov		edi,rpstabs
		add		edi,hMemFile
		add		edi,[esi].STAB.stabs
		.if eax==100 || eax==132
			invoke SourceExist,edi
			.if eax
				mov		eax,dword ptr BaseOfDll
				mov		dword ptr src.ModBase,eax
				mov		eax,dword ptr BaseOfDll[4]
				mov		dword ptr src.ModBase[4],eax
				mov		src.FileName,edi
				push	UserContext
				lea		eax,src
				push	eax
				call	EnumSourcesCallback
			.endif
		.endif
		lea		esi,[esi+sizeof STAB]
		dec		ebx
	.endw
	mov		eax,TRUE
	ret

SymEnumSourceFiles endp

SymEnumSourceLines proc hProcess:HANDLE,BaseOfDll:ULONG64,Obj:DWORD,File:DWORD,Line:DWORD,Flags:DWORD,EnumLinesCallback:DWORD,UserContext:DWORD
	LOCAL	src:SRCCODEINFO
	LOCAL	procad:DWORD

	mov		esi,rpstab
	add		esi,hMemFile
	movzx	ebx,[esi].STAB.nline
	.while ebx
		movzx	eax,[esi].STAB.code
		.if eax==132
			mov		edi,rpstabs
			add		edi,hMemFile
			add		edi,[esi].STAB.stabs
		.elseif eax==36
			mov		eax,[esi].STAB.ad
			mov		procad,eax
		.elseif eax==68
			mov		src.SizeOfStruct,sizeof SRCCODEINFO
			mov		src.Key,0
			mov		eax,dword ptr BaseOfDll
			mov		dword ptr src.ModBase,eax
			mov		eax,dword ptr BaseOfDll[4]
			mov		dword ptr src.ModBase[4],eax
			mov		src.Obj,0
			invoke strcpy,addr src.FileName,edi
			movzx	eax,[esi].STAB.nline
			mov		src.LineNumber,eax
			mov		eax,[esi].STAB.ad
			add		eax,procad
			mov		src.Address,eax
			movzx	edx,[esi].STAB.nline
			push	UserContext
			lea		eax,src
			push	eax
			call	EnumLinesCallback
		.endif
		lea		esi,[esi+sizeof STAB]
		dec		ebx
	.endw
	mov		eax,TRUE
	ret

SymEnumSourceLines endp

SymUnloadModule proc hProcess:HANDLE,BaseOfDll:DWORD

	invoke GlobalFree,hMemFile
	mov		hMemFile,0
	mov		eax,TRUE
	ret

SymUnloadModule endp

SymCleanup proc hProcess:HANDLE

	mov		eax,TRUE
	ret

SymCleanup endp

End DllEntry
