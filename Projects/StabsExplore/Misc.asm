
.code

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

HexByte proc

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
	ret

HexByte endp

DumpLine proc uses ebx esi edi,nAdr:DWORD,lpData:DWORD,nBytes:DWORD
	LOCAL	buffer[256]:BYTE

	mov		ebx,nAdr
	mov		esi,lpData
	lea		edi,buffer
	xor		ecx,ecx
	.while ecx<4
		rol		ebx,8
		mov		eax,ebx
		invoke HexByte
		mov		[edi],ax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],' '
	inc		edi
	xor		ecx,ecx
	.while ecx<nBytes
		mov		al,[esi+ecx]
		invoke HexByte
		mov		[edi],ax
		inc		edi
		inc		edi
		.if ecx==7
			mov		byte ptr [edi],'-'
		.else
			mov		byte ptr [edi],' '
		.endif
		inc		edi
		inc		ecx
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
	mov		dword ptr [edi],0A0Dh
	invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr buffer
	ret

DumpLine endp

DumpData proc uses ebx esi edi,lpSection:DWORD,nSize:DWORD

	xor		ebx,ebx
	mov		esi,lpSection
	mov		edi,nSize
	.while edi>=16
		invoke DumpLine,ebx,esi,16
		sub		edi,16
		add		ebx,16
		add		esi,16
	.endw
	.if edi
		invoke DumpLine,ebx,esi,edi
	.endif
	ret

DumpData endp

DumpSection proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE

	mov		ebx,offset SectionHeader
	mov		eax,nHeader
	mov		edx,sizeof SECTIONHEADER
	mul		edx
	lea		ebx,[ebx+eax]
	invoke lstrcpyn,addr buffer,addr [ebx].SECTIONHEADER.sName,9
	movzx	eax,[ebx].SECTIONHEADER.NumberOfRelocations
	movzx	edx,[ebx].SECTIONHEADER.NumberOfLinenumbers
	invoke wsprintf,addr szOutput,addr szSectionHeader,addr buffer,[ebx].SECTIONHEADER.VirtualSize,[ebx].SECTIONHEADER.VirtualAddress,[ebx].SECTIONHEADER.SizeOfRawData,[ebx].SECTIONHEADER.PointerToRawData,[ebx].SECTIONHEADER.PointerToRelocations,[ebx].SECTIONHEADER.PointerToLinenumbers,eax,edx,[ebx].SECTIONHEADER.Characteristics
	invoke SendMessage,hEdt,WM_SETTEXT,0,addr szOutput
	invoke SendMessage,hEdt,EM_SETSEL,-1,-1
	mov		eax,[ebx].SECTIONHEADER.SizeOfRawData
	mov		ebx,[ebx].SECTIONHEADER.PointerToRawData
	add		ebx,hMemFile
	invoke DumpData,ebx,eax
	ret

DumpSection endp

SetSection proc uses ebx esi edi

	mov		eax,nHeader
	mov		edx,sizeof SECTIONHEADER
	mul		edx
	add		eax,offset SectionHeader
	invoke lstrcpyn,addr szSection,addr [eax].SECTIONHEADER.sName,9
	invoke SendMessage,hStc,WM_SETTEXT,0,addr szSection
	ret

SetSection endp

DumpStabs proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE

	.if rpstab && rpstabs
		invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
		mov		esi,rpstab
		add		esi,hMemFile
		movzx	ebx,[esi].STAB.nline
		.while ebx
			movzx	eax,[esi].STAB.code
			movzx	edx,[esi].STAB.nline
			mov		edi,rpstabs
			add		edi,hMemFile
			add		edi,[esi].STAB.stabs
			invoke wsprintf,addr szOutput,addr szFmtStab,[esi].STAB.stabs,eax,edx,[esi].STAB.ad,edi
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
			lea		esi,[esi+sizeof STAB]
			dec		ebx
		.endw
	.endif
	ret

DumpStabs endp

GetDatatypes proc
	LOCAL	szname[1024]:BYTE
	LOCAL	buffer[256]:BYTE
	LOCAL	ninx:DWORD
	LOCAL	nsize:DWORD
	LOCAL	arstart:DWORD
	LOCAL	arend:DWORD

	invoke RtlZeroMemory,offset datatype,sizeof datatype
	.if rpstab && rpstabs
		mov		esi,rpstab
		add		esi,hMemFile
		movzx	ebx,[esi].STAB.nline
		.while ebx
			movzx	eax,[esi].STAB.code
			.if eax==128
				xor		eax,eax
				mov		ninx,eax
				mov		nsize,eax
				mov		arstart,eax
				mov		arend,eax
				mov		edi,rpstabs
				add		edi,hMemFile
				add		edi,[esi].STAB.stabs
				invoke lstrcpy,addr szname,edi
				lea		edi,szname
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
						.if byte ptr [edi]=='='
							inc		edi
							.if word ptr [edi]=='ra'
								add		edi,2
								push	edi
								.while byte ptr [edi]
									.if byte ptr [edi]==';'
										inc		edi
										invoke DecToBin,edi
										mov		arstart,eax
										.break
									.endif
									inc		edi
								.endw
								.while byte ptr [edi]
									.if byte ptr [edi]==';'
										inc		edi
										invoke DecToBin,edi
										mov		arend,eax
										.break
									.endif
									inc		edi
								.endw
								pop		edi
								.if !szname
									invoke DecToBin,edi
									mov		edx,sizeof DATATYPE
									mul		edx
									invoke lstrcpy,addr szname,addr [eax+offset datatype].DATATYPE.szname[1]
								.endif
							.endif
							.break
						.endif
						inc		edi
					.endw
				.endif
				.if ninx
					mov		word ptr buffer,':'
					invoke lstrcat,addr buffer,addr szname
					invoke lstrcpy,addr szname,addr buffer
					.if arend
						invoke wsprintf,addr buffer,addr szFmtArray,arstart,arend
						invoke lstrcat,addr buffer,addr szname
						invoke lstrcpy,addr szname,addr buffer
					.endif
					mov		eax,ninx
					mov		edx,sizeof DATATYPE
					mul		edx
					mov		edi,offset datatype
					lea		edi,[edi+eax]
					invoke lstrcpy,addr [edi].DATATYPE.szname,addr szname
					mov		eax,nsize
					mov		[edi].DATATYPE.nsize,eax
				.endif
			.endif
			lea		esi,[esi+sizeof STAB]
			dec		ebx
		.endw
	.endif
	ret

GetDatatypes endp

DumpProcs proc uses ebx esi edi
	LOCAL	szfile[MAX_PATH]:BYTE
	LOCAL	szname[256]:BYTE
	LOCAL	szparam[512]:BYTE
	LOCAL	szlocal[512]:BYTE
	LOCAL	buffer[256]:BYTE
	LOCAL	nline:DWORD
	LOCAL	nadr:DWORD
	LOCAL	nblock:DWORD
	LOCAL	nstart:DWORD
	LOCAL	nend:DWORD

	.if rpstab && rpstabs
		invoke GetDatatypes
		invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
		mov		esi,rpstab
		add		esi,hMemFile
		movzx	ebx,[esi].STAB.nline
		.while ebx
			movzx	eax,[esi].STAB.code
			mov		edi,rpstabs
			add		edi,hMemFile
			add		edi,[esi].STAB.stabs
			.if eax==36
				mov		edx,edi
				.while byte ptr [edx] && byte ptr [edx]!=':'
					inc		edx
				.endw
				.if byte ptr [edx+1]=='F'
					mov		szparam,0
					mov		szlocal,0
					mov		nblock,0
					; Proc
					movzx	eax,[esi].STAB.nline
					mov		nline,eax
					mov		eax,[esi].STAB.ad
					mov		nadr,eax
					invoke lstrcpy,addr szname,edi
					; Get return datatype
					lea		edi,szname
					.while byte ptr [edi]
						.if byte ptr [edi]==':'
							invoke DecToBin,addr [edi+2]
							.if eax
								mov		edx,sizeof DATATYPE
								mul		edx
								lea		eax,[eax+offset datatype]
								invoke lstrcpy,addr [edi],addr [eax].DATATYPE.szname
								.break
							.endif
							mov		byte ptr [edi],0
							.break
						.endif
						inc		edi
					.endw
				.endif
			.elseif eax==132 || eax==130 || eax==100
				; FileName
				invoke lstrcpy,addr szfile,edi
			.elseif eax==160
				; Param / Local
				invoke lstrcpy,addr buffer,edi
				lea		edi,buffer
				.while byte ptr [edi]
					.if byte ptr [edi]==':'
						.if byte ptr [edi+1]=='p' || byte ptr [edi+1]=='v'
							invoke DecToBin,addr [edi+2]
							.if eax
								mov		edx,sizeof DATATYPE
								mul		edx
								lea		eax,[eax+offset datatype]
								invoke lstrcpy,addr [edi],addr [eax].DATATYPE.szname
								lea		edi,szparam
								.if byte ptr [edi]
									invoke lstrlen,edi
									lea		edi,[edi+eax]
									mov		byte ptr [edi],','
									inc		edi
								.endif
								invoke lstrcpy,edi,addr buffer
								.break
							.endif
						.elseif byte ptr [edi+1]>='0' && byte ptr [edi+1]<='9'
							invoke DecToBin,addr [edi+1]
							.if eax
								mov		edx,sizeof DATATYPE
								mul		edx
								lea		eax,[eax+offset datatype]
								invoke lstrcpy,addr [edi],addr [eax].DATATYPE.szname
								lea		edi,szlocal
								.if byte ptr [edi]
									invoke lstrlen,edi
									lea		edi,[edi+eax]
									mov		byte ptr [edi],','
									inc		edi
								.endif
								invoke lstrcpy,edi,addr buffer
								.break
							.endif
						.endif
						mov		byte ptr [edi],0
						.break
					.endif
					inc		edi
				.endw
			.elseif eax==192
				; Block start
				inc		nblock
				mov		eax,[esi].STAB.ad
				mov		nstart,eax
			.elseif eax==224
				; Block end
				dec		nblock
				.if !nblock
					mov		eax,[esi].STAB.ad
					mov		nend,eax
					invoke wsprintf,addr szOutput,addr szFmtFile,addr szfile
					invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
					invoke wsprintf,addr szOutput,addr szFmtProc,addr szname,nline,nadr,nend
					invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
					.if byte ptr szparam
						invoke wsprintf,addr szOutput,addr szFmtParam,addr szparam
						invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
					.endif
					.if byte ptr szlocal
						invoke wsprintf,addr szOutput,addr szFmtLocal,addr szlocal
						invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
					.endif
				.endif
			.endif
			lea		esi,[esi+sizeof STAB]
			dec		ebx
		.endw
	.endif
	ret

DumpProcs endp

DumpGlobals proc uses ebx esi edi
	LOCAL	szname[256]:BYTE

	.if rpstab && rpstabs
		invoke GetDatatypes
		invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
		mov		esi,rpstab
		add		esi,hMemFile
		movzx	ecx,[esi].STAB.nline
		.while ecx
			push	ecx
			movzx	eax,[esi].STAB.code
			.if eax==40
				mov		edi,rpstabs
				add		edi,hMemFile
				add		edi,[esi].STAB.stabs
				lea		ebx,szname
				.while byte ptr [edi] && byte ptr [edi]!=':'
					mov		al,[edi]
					mov		[ebx],al
					inc		edi
					inc		ebx
				.endw
				.if byte ptr [edi+1]=='S'
					invoke DecToBin,addr [edi+2]
					mov		edx,sizeof DATATYPE
					mul		edx
					lea		edi,[eax+offset datatype]
					invoke lstrcpy,ebx,addr [edi].DATATYPE.szname
					invoke wsprintf,addr szOutput,addr szFmtGlobal,addr szname,[esi].STAB.ad,[edi].DATATYPE.nsize
					invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
				.endif
			.endif
			pop		ecx
			lea		esi,[esi+sizeof STAB]
			dec		ecx
		.endw
	.endif
	ret

DumpGlobals endp

DumpLines proc uses ebx esi edi
	LOCAL	szfile[MAX_PATH]:BYTE

	.if rpstab && rpstabs
		invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
		mov		esi,rpstab
		add		esi,hMemFile
		movzx	ecx,[esi].STAB.nline
		.while ecx
			push	ecx
			movzx	eax,[esi].STAB.code
			mov		edi,rpstabs
			add		edi,hMemFile
			add		edi,[esi].STAB.stabs
			.if eax==68
				mov		eax,[esi].STAB.ad
				add		eax,ebx
				movzx	edx,[esi].STAB.nline
				invoke wsprintf,addr szOutput,addr szFmtLine,addr szfile,edx,eax
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
			.elseif eax==132 || eax==100 || eax==130
				.if eax==132 || eax==100
					mov		ebx,[esi].STAB.ad
				.endif
				; FileName
				invoke lstrcpyn,addr szfile,edi,MAX_PATH
			.endif
			pop		ecx
			lea		esi,[esi+sizeof STAB]
			dec		ecx
		.endw
	.endif
	ret

DumpLines endp

DumpTypes proc uses ebx esi edi

	.if rpstab && rpstabs
		invoke GetDatatypes
		invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
		mov		esi,offset datatype
		mov		ecx,256
		.while ecx
			push	ecx
			.if [esi].DATATYPE.szname
				invoke wsprintf,addr szOutput,addr szFmtType,addr [esi].DATATYPE.szname,[esi].DATATYPE.nsize
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
			.endif
			pop		ecx
			lea		esi,[esi+sizeof DATATYPE]
			dec		ecx
		.endw
	.endif
	ret

DumpTypes endp

ShowSectionHeaders proc uses ebx esi edi
	LOCAL	buffer[32]:BYTE

	mov		szOutput,0
	invoke SetWindowText,hEdt,addr szOutput
	mov		esi,hMemFile
	movzx	ebx,word ptr [esi+86h]
	mov		nHeaders,ebx
	invoke wsprintf,addr szOutput,addr szStabsHeader,ebx
	invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
	lea		esi,[esi+178h]
	mov		edi,offset SectionHeader
	.while ebx
		invoke RtlMoveMemory,edi,esi,sizeof SECTIONHEADER
		invoke lstrcpyn,addr buffer,esi,9
		invoke lstrcmp,addr buffer,addr szSecStab
		.if !eax
			mov		eax,[esi].SECTIONHEADER.PointerToRawData
			mov		rpstab,eax
		.endif
		invoke lstrcmp,addr buffer,addr szSecStabstr
		.if !eax
			mov		eax,[esi].SECTIONHEADER.PointerToRawData
			mov		rpstabs,eax
		.endif
		invoke lstrcat,addr buffer,addr szAlign
		invoke lstrcpyn,addr buffer,addr buffer,14
		mov		eax,[esi].SECTIONHEADER.PointerToRawData
		invoke wsprintf,addr szOutput,addr szStab,addr buffer,eax
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
		lea		esi,[esi+sizeof SECTIONHEADER]
		lea		edi,[edi+sizeof SECTIONHEADER]
		dec		ebx
	.endw
	ret

ShowSectionHeaders endp

; File handling
ReadTheFile proc uses ebx esi edi,lpFileName:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	BytesRead:DWORD

	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,0
		mov		ebx,eax
		; Allocate memory for file
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,ebx
		mov		hMemFile,eax
		invoke ReadFile,hFile,hMemFile,ebx,addr BytesRead,NULL
		invoke CloseHandle,hFile
		xor		eax,eax
	.endif
	ret

ReadTheFile endp

CloseEXE proc uses esi

	invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
	invoke SendMessage,hStc,WM_SETTEXT,0,addr szNULL
	.if hMemFile
		; Free the file memory
		invoke GlobalFree,hMemFile
		xor		eax,eax
		mov		hMemFile,eax
		mov		nHeader,eax
		mov		nHeaders,eax
		mov		rpstab,eax
		mov		rpstabs,eax
	.endif
	ret

CloseEXE endp

