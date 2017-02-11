
.code

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

	mov		ebx,hMemFile
	movzx	eax,[ebx].COFFHEADER.SizeOfOptionalHeader
	lea		ebx,[ebx+eax+sizeof COFFHEADER]
	mov		eax,nCoffHeader
	mov		edx,sizeof COFFSECTIONHEADER
	mul		edx
	lea		ebx,[ebx+eax]
	invoke lstrcpyn,addr buffer,addr [ebx].COFFSECTIONHEADER.sName,9
	movzx	eax,[ebx].COFFSECTIONHEADER.NumberOfRelocations
	movzx	edx,[ebx].COFFSECTIONHEADER.NumberOfLinenumbers
	invoke wsprintf,addr szOutput,addr szSectionHeader,addr buffer,[ebx].COFFSECTIONHEADER.VirtualSize,[ebx].COFFSECTIONHEADER.VirtualAddress,[ebx].COFFSECTIONHEADER.SizeOfRawData,[ebx].COFFSECTIONHEADER.PointerToRawData,[ebx].COFFSECTIONHEADER.PointerToRelocations,[ebx].COFFSECTIONHEADER.PointerToLinenumbers,eax,edx,[ebx].COFFSECTIONHEADER.Characteristics
	invoke SendMessage,hEdt,WM_SETTEXT,0,addr szOutput
	invoke SendMessage,hEdt,EM_SETSEL,-1,-1
	mov		eax,[ebx].COFFSECTIONHEADER.SizeOfRawData
	mov		ebx,[ebx].COFFSECTIONHEADER.PointerToRawData
	add		ebx,hMemFile
	invoke DumpData,ebx,eax
	ret

DumpSection endp

SetSection proc uses ebx esi edi

	mov		ebx,hMemFile
	movzx	eax,[ebx].COFFHEADER.SizeOfOptionalHeader
	lea		ebx,[ebx+eax+sizeof COFFHEADER]
	mov		eax,nCoffHeader
	mov		edx,sizeof COFFSECTIONHEADER
	mul		edx
	lea		ebx,[ebx+eax]
	invoke lstrcpyn,addr szSection,addr [ebx].COFFSECTIONHEADER.sName,9
	invoke SendMessage,hStc,WM_SETTEXT,0,addr szSection
	ret

SetSection endp

DumpSymbol proc
	LOCAL	SectionNumber:DWORD
	LOCAL	nType:DWORD
	LOCAL	StorageClass:DWORD
	LOCAL	NumberOfAuxSymbols:DWORD

	movzx	eax,[esi].COFFSYMBOL.SectionNumber
	mov		SectionNumber,eax
	movzx	eax,[esi].COFFSYMBOL.nType
	mov		nType,eax
	movzx	eax,[esi].COFFSYMBOL.StorageClass
	mov		StorageClass,eax
	movzx	eax,[esi].COFFSYMBOL.NumberOfAuxSymbols
	mov		NumberOfAuxSymbols,eax
	mov		eax,[esi].COFFSYMBOL.Zeroes
	.if !eax
		mov		ecx,hMemFile
		mov		eax,[ecx].COFFHEADER.NumberOfSymbols
		mov		edx,sizeof COFFSYMBOL
		mul		edx
		add		eax,[ecx].COFFHEADER.PointerToSymbolTable
		add		eax,[esi].COFFSYMBOL.nOffset[4]
		add		eax,ecx
	.else
		invoke lstrcpyn,addr szSection,addr [esi].COFFSYMBOL.szShortName,9
		mov		eax,offset szSection
	.endif
	invoke wsprintf,addr szOutput,addr szCoffSymbol,eax,[esi].COFFSYMBOL.Value,SectionNumber,nType,StorageClass,NumberOfAuxSymbols
	invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
	lea		esi,[esi+sizeof COFFSYMBOL]
	inc		ebx
	.if NumberOfAuxSymbols
		.if word ptr SectionNumber==IMAGE_SYM_DEBUG
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr [esi].COFFSYMBOL.szShortName
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szCrLf
		.endif
		mov		eax,NumberOfAuxSymbols
		add		ebx,eax
		mov		edx,sizeof COFFSYMBOL
		mul		edx
		lea		esi,[esi+eax]
	.endif
	ret

DumpSymbol endp

DumpSymbols proc uses ebx esi edi

	invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
	mov		eax,hMemFile
	mov		edi,[eax].COFFHEADER.NumberOfSymbols
	mov		esi,[eax].COFFHEADER.PointerToSymbolTable
	add		esi,eax
	xor		ebx,ebx
	.while ebx<edi
		invoke DumpSymbol
	.endw
	ret

DumpSymbols endp

DumpProc proc
	LOCAL	SectionNumber:DWORD
	LOCAL	nType:DWORD
	LOCAL	StorageClass:DWORD
	LOCAL	NumberOfAuxSymbols:DWORD
	LOCAL	dbgproc:DBGPROC

	movzx	eax,[esi].COFFSYMBOL.SectionNumber
	mov		SectionNumber,eax
	movzx	eax,[esi].COFFSYMBOL.nType
	mov		nType,eax
	movzx	eax,[esi].COFFSYMBOL.StorageClass
	mov		StorageClass,eax
	movzx	eax,[esi].COFFSYMBOL.NumberOfAuxSymbols
	mov		NumberOfAuxSymbols,eax
	.if StorageClass==EXTERNAL && nType==20h && SectionNumber>0
		mov		eax,[esi].COFFSYMBOL.Zeroes
		.if !eax
			mov		ecx,hMemFile
			mov		eax,[ecx].COFFHEADER.NumberOfSymbols
			mov		edx,sizeof COFFSYMBOL
			mul		edx
			add		eax,[ecx].COFFHEADER.PointerToSymbolTable
			add		eax,[esi].COFFSYMBOL.nOffset[4]
			add		eax,hMemFile
		.else
			invoke lstrcpyn,addr szSection,addr [esi].COFFSYMBOL.szShortName,9
			mov		eax,offset szSection
		.endif
		invoke lstrcpy,addr dbgproc.szName,eax
		.while NumberOfAuxSymbols
			lea		esi,[esi+sizeof COFFSYMBOL]
			inc		ebx
			dec		NumberOfAuxSymbols
		.endw
	.elseif StorageClass==FUNCTION || StorageClass==EXTERNAL
		;.bf, .lf and .ef Symbols
		;StorageClass=101 (.bf and .ef)
		mov		eax,[esi].COFFSYMBOL.Zeroes
		.if !eax
			mov		ecx,hMemFile
			mov		eax,[ecx].COFFHEADER.NumberOfSymbols
			mov		edx,sizeof COFFSYMBOL
			mul		edx
			add		eax,[ecx].COFFHEADER.PointerToSymbolTable
			add		eax,[esi].COFFSYMBOL.nOffset[4]
			add		eax,hMemFile
		.else
			invoke lstrcpyn,addr szSection,addr [esi].COFFSYMBOL.szShortName,9
			mov		eax,offset szSection
		.endif
		mov		edx,[esi].COFFSYMBOL.Value
		mov		eax,dword ptr szSection
		and		eax,0FFFFFFh
		.if eax=='fb.'
			mov		dbgproc.bfad,edx
		.elseif eax=='fl.'
			mov		dbgproc.lfad,edx
		.elseif eax=='fe.'
			mov		dbgproc.efad,edx
		.endif
		.if NumberOfAuxSymbols
			lea		esi,[esi+sizeof COFFSYMBOL]
			inc		ebx
			movzx	edx,[esi].COFFAUX2.Linenumber
			mov		eax,dword ptr szSection
			and		eax,0FFFFFFh
			.if eax=='fb.'
				mov		dbgproc.bfln,edx
			.elseif eax=='fe.'
				mov		dbgproc.efln,edx
				invoke wsprintf,addr szOutput,addr szCoffProc,addr dbgproc.szFile,addr dbgproc.szName,dbgproc.bfad,dbgproc.bfln,dbgproc.efad,dbgproc.efln
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
				mov		dbgproc.szName,0
			.endif
		.endif
	.elseif NumberOfAuxSymbols
		.if word ptr SectionNumber==IMAGE_SYM_DEBUG
			; File name
			invoke lstrcpy,addr dbgproc.szFile,addr [esi+sizeof COFFSYMBOL]
		.endif
		mov		eax,NumberOfAuxSymbols
		add		ebx,eax
		mov		edx,sizeof COFFSYMBOL
		mul		edx
		lea		esi,[esi+eax]
	.endif
	ret

DumpProc endp

DumpProcs proc uses ebx esi edi

	invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
	mov		eax,hMemFile
	mov		edi,[eax].COFFHEADER.NumberOfSymbols
	mov		esi,[eax].COFFHEADER.PointerToSymbolTable
	add		esi,eax
	xor		ebx,ebx
	.while ebx<edi
		invoke DumpProc
		lea		esi,[esi+sizeof COFFSYMBOL]
		inc		ebx
	.endw
	ret

DumpProcs endp

DumpGlobals proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	SectionNumber:DWORD
	LOCAL	nType:DWORD
	LOCAL	StorageClass:DWORD
	LOCAL	NumberOfAuxSymbols:DWORD

	invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
	mov		eax,hMemFile
	mov		edi,[eax].COFFHEADER.NumberOfSymbols
	mov		esi,[eax].COFFHEADER.PointerToSymbolTable
	add		esi,eax
	xor		ebx,ebx
	.while ebx<edi
		movzx	eax,[esi].COFFSYMBOL.SectionNumber
		mov		SectionNumber,eax
		movzx	eax,[esi].COFFSYMBOL.nType
		mov		nType,eax
		movzx	eax,[esi].COFFSYMBOL.StorageClass
		mov		StorageClass,eax
		movzx	eax,[esi].COFFSYMBOL.NumberOfAuxSymbols
		mov		NumberOfAuxSymbols,eax
		.if ((StorageClass==STATIC && nType==0) || (StorageClass==2 && nType==2000h)) && NumberOfAuxSymbols==0 && SectionNumber>0
			mov		eax,[esi].COFFSYMBOL.Zeroes
			.if !eax
				mov		ecx,hMemFile
				mov		eax,[ecx].COFFHEADER.NumberOfSymbols
				mov		edx,sizeof COFFSYMBOL
				mul		edx
				add		eax,[ecx].COFFHEADER.PointerToSymbolTable
				add		eax,[esi].COFFSYMBOL.nOffset[4]
				add		eax,ecx
				invoke lstrcpy,addr buffer,eax
			.else
				invoke lstrcpyn,addr buffer,addr [esi].COFFSYMBOL.szShortName,9
			.endif
			invoke wsprintf,addr szOutput,addr szCoffGlobal,addr buffer,[esi].COFFSYMBOL.Value
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
		.endif
		.while NumberOfAuxSymbols
			lea		esi,[esi+sizeof COFFSYMBOL]
			inc		ebx
			dec		NumberOfAuxSymbols
		.endw
		lea		esi,[esi+sizeof COFFSYMBOL]
		inc		ebx
	.endw
	ret

DumpGlobals endp

DumpLinenumbers proc uses ebx esi edi

	invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
	mov		ebx,hMemFile
	movzx	eax,[ebx].COFFHEADER.SizeOfOptionalHeader
	lea		ebx,[ebx+eax+sizeof COFFHEADER]
	mov		eax,nCoffHeader
	mov		edx,sizeof COFFSECTIONHEADER
	mul		edx
	lea		ebx,[ebx+eax]

	movzx	edi,[ebx].COFFSECTIONHEADER.NumberOfLinenumbers
	mov		esi,[ebx].COFFSECTIONHEADER.PointerToLinenumbers
	add		esi,ebx
	sub		esi,2
	sub		esi,18
	xor		ebx,ebx
	.while ebx<edi
		mov		eax,[esi].COFFLINENUMBERS.VirtualAddress
		movzx	edx,[esi].COFFLINENUMBERS.Linenumber
		.if !edx
			push	ebx
			push	esi
			mov		ebx,eax
			mov		edx,hMemFile
			mov		esi,[edx].COFFHEADER.PointerToSymbolTable
			add		esi,edx
			mov		edx,sizeof COFFSYMBOL
			mul		edx
			lea		esi,[esi+eax]
			invoke DumpSymbol
			pop		esi
			pop		ebx
		.else
			invoke wsprintf,addr szOutput,addr szCoffLinenumber,eax,edx
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szOutput
		.endif
		lea		esi,[esi+sizeof COFFLINENUMBERS]
		inc		ebx
	.endw
	ret

DumpLinenumbers endp

ShowCoffHeader proc uses esi
	LOCAL	Machine:DWORD
	LOCAL	NumberOfSections:DWORD
	LOCAL	SizeOfOptionalHeader:DWORD
	LOCAL	Characteristics:DWORD

	mov		esi,hMemFile
	movzx	eax,[esi].COFFHEADER.Machine
	mov		Machine,eax
	movzx	eax,[esi].COFFHEADER.NumberOfSections
	mov		NumberOfSections,eax
	mov		nCoffHeaders,eax
	movzx	eax,[esi].COFFHEADER.SizeOfOptionalHeader
	mov		SizeOfOptionalHeader,eax
	movzx	eax,[esi].COFFHEADER.Characteristics
	mov		Characteristics,eax
	invoke wsprintf,addr szOutput,addr szCoffHeader,Machine,NumberOfSections,[esi].COFFHEADER.TimeDateStamp,[esi].COFFHEADER.PointerToSymbolTable,[esi].COFFHEADER.NumberOfSymbols,SizeOfOptionalHeader,Characteristics
	invoke SetWindowText,hEdt,addr szOutput
	ret

ShowCoffHeader endp

ReadSectionHeaders proc uses ebx esi edi

	mov		esi,hMemFile
	movzx	eax,[esi].COFFHEADER.SizeOfOptionalHeader
	lea		esi,[esi+eax+sizeof COFFHEADER]
	mov		edi,offset SectionHeader
	mov		ebx,nCoffHeaders
	.while ebx
		mov		eax,[esi].COFFSECTIONHEADER.PointerToLinenumbers
		invoke RtlMoveMemory,edi,esi,sizeof COFFSECTIONHEADER
		lea		esi,[esi+sizeof COFFSECTIONHEADER]
		lea		edi,[edi+sizeof COFFSECTIONHEADER]
		dec		ebx
	.endw
	ret

ReadSectionHeaders endp

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

CloseOBJ proc uses esi

	invoke SendMessage,hEdt,WM_SETTEXT,0,addr szNULL
	invoke SendMessage,hStc,WM_SETTEXT,0,addr szNULL
	.if hMemFile
		; Free the file memory
		invoke GlobalFree,hMemFile
		xor		eax,eax
		mov		hMemFile,eax
		mov		nCoffHeader,eax
		mov		nCoffHeaders,eax
	.endif
	ret

CloseOBJ endp

