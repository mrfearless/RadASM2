
SOURCEFILE struct DWORD
	ModBase					QWORD ?
	FileName				DWORD ?
SOURCEFILE ends

SRCCODEINFO struct DWORD
	SizeOfStruct            DWORD ?
	Key                     PVOID ?
	ModBase                 QWORD ?
	Obj         			BYTE MAX_PATH+1 dup(?)
	FileName				BYTE MAX_PATH+1 dup(?)
	LineNumber              DWORD ?
	Address                 DWORD ?
SRCCODEINFO ends

SYMBOL_INFO struct QWORD
	SizeOfStruct			DWORD ?
	TypeIndex				DWORD ?
	Reserved				QWORD 2 dup(?)
	Index					DWORD ?
	nSize					DWORD ?
	ModBase					QWORD ?
	Flags					DWORD ?
	Value					QWORD ?
	Address					QWORD ?
	Register				DWORD ?
	Scope					DWORD ?
	Tag						DWORD ?
	NameLen					DWORD ?
	MaxNameLen				DWORD ?
	szName					BYTE ?
SYMBOL_INFO ends

.const

szSymInitialize					db 'SymInitialize',0
szSymLoadModule					db 'SymLoadModule',0
szSymGetModuleInfo				db 'SymGetModuleInfo',0
szSymEnumerateSymbols			db 'SymEnumerateSymbols',0
szSymEnumTypes					db 'SymEnumTypes',0
szSymEnumSourceFiles			db 'SymEnumSourceFiles',0
szSymEnumSourceLines			db 'SymEnumSourceLines',0
szSymFromAddr					db 'SymFromAddr',0
szSymUnloadModule				db 'SymUnloadModule',0
szSymCleanup					db 'SymCleanup',0
szSymSetContext					db 'SymSetContext',0
szSymEnumTypesByName			db 'SymEnumTypesByName',0

szVersionInfo					db '\StringFileInfo\040904B0\FileVersion',0
szVersion						db '%s version %s',0
szSymOk							db 'Symbols OK',0
szSymbol						db 'Name: %s Adress: %X Size %u',0
szSourceFile					db 'FileName: %s',0
szSourceLine					db 'FileName: %s Adress: %X Line %u',0
szSymLoadModuleFailed			db 'SymLoadModule failed.',0
szSymInitializeFailed			db 'SymInitialize failed.',0
szFinal							db 'DbgHelp found %u source files containing %u lines and %u symbols.',0Dh,0
szDbgHelpFail					db 'Could not find %s.',0

CombSort_Const					REAL4 1.3

.data?

dwModuleBase					DWORD ?
im								IMAGEHLP_MODULE <>
nErrors							DWORD ?

.code

CombSort PROC uses ebx esi edi,lpArr:DWORD,count:DWORD
	LOCAL	Gap:DWORD
	LOCAL	eFlag:DWORD

	mov		eax,count
	mov		Gap,eax
	mov		ebx,lpArr
	dec		count
  @Loop1:
	fild	Gap								; load integer memory operand to divide
	fdiv	CombSort_Const					; divide number by 1.3
	fistp	Gap								; store result back in integer memory operand
	dec		Gap
	jnz		@F
	mov		Gap,1
  @@:
	mov		eFlag,0
	mov		esi,count
	sub		esi,Gap
	xor		ecx,ecx							; low value index
  @Loop2:
	mov 	edx,ecx
	add 	edx,Gap							; high value index
	;Get offsets to row data
	push	edx
	mov		edx,[ebx+edx*4]
	mov		edi,[ebx+ecx*4]
	;Get cell data
	mov		eax,[edi].DEBUGLINE.Address
	sub		eax,[edx].DEBUGLINE.Address
	pop		edx
	cmp		eax,0
	jle 	@F
	mov 	eax,[ebx+ecx*4]					; lower value
	mov 	edi,[ebx+edx*4]					; higher value
	mov 	[ebx+edx*4],eax
	mov 	[ebx+ecx*4],edi
	inc 	eFlag
  @@:
	inc 	ecx
	cmp 	ecx,esi
	jle 	@Loop2
	cmp 	eFlag,0
	jg		@Loop1
	cmp 	Gap,1
	jg		@Loop1
	ret

CombSort ENDP

SortLinesByAddress proc uses ebx esi edi
	LOCAL	hMemIndex:HGLOBAL
	LOCAL	hMemLinesSorted:HGLOBAL

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,128*1024*4
	mov		hMemIndex,eax
	; Allocate memory for DEBUGLINE, max 128K lines
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,128*1024*sizeof DEBUGLINE
	mov		hMemLinesSorted,eax
	mov		ebx,dbg.inxline
	mov		edi,hMemIndex
	mov		eax,dbg.hMemLine
	.while ebx
		mov		[edi],eax
		lea		eax,[eax+sizeof DEBUGLINE]
		lea		edi,[edi+4]
		dec		ebx
	.endw
	invoke CombSort,hMemIndex,dbg.inxline
	mov		ebx,dbg.inxline
	mov		esi,hMemIndex
	mov		edi,hMemLinesSorted
	.while ebx
		mov		eax,[esi]
		invoke RtlMoveMemory,edi,eax,sizeof DEBUGLINE
		lea		edi,[edi+sizeof DEBUGLINE]
		lea		esi,[esi+4]
		dec		ebx
	.endw
	lea		esi,[edi-sizeof DEBUGLINE]
	mov		eax,[esi].DEBUGLINE.Address
	.if eax<dbg.maxproc
		invoke RtlMoveMemory,edi,esi,sizeof DEBUGLINE
		mov		eax,dbg.maxproc
		inc		eax
		mov		[edi].DEBUGLINE.Address,eax
		inc		[edi].DEBUGLINE.LineNumber
		inc		dbg.inxline
	.endif
	invoke GlobalFree,hMemIndex
	invoke GlobalFree,dbg.hMemLine
	mov		eax,hMemLinesSorted
	mov		dbg.hMemLine,eax
	ret

SortLinesByAddress endp

GetDbgHelpVersion proc lpDll:DWORD
	LOCAL	buffer[2048]:BYTE
	LOCAL	lpbuff:DWORD
	LOCAL	lpsize:DWORD

	invoke GetFileVersionInfo,lpDll,NULL,sizeof buffer,addr buffer
	.if eax
		invoke VerQueryValue,addr buffer,addr szVersionInfo,addr lpbuff,addr lpsize
		.if eax
			mov		eax,lpbuff
			invoke wsprintf,addr buffer,addr szVersion,lpDll,eax
			invoke PutString,addr buffer
		.endif
	.endif
	ret

GetDbgHelpVersion endp

FindWord proc uses esi,lpWord:DWORD,fCase:DWORD

	mov		edx,lpData
	;Get pointer to word list
	mov		esi,[edx].ADDINDATA.lpWordList
	;Skip the words loaded from .api files
	add		esi,[edx].ADDINDATA.rpProjectWordList
	;Loop trough the word list
	.while [esi].PROPERTIES.nSize
		call	TestWord
		.if eax
			mov		eax,esi
			jmp		Ex			
		.endif
		;Move to next word
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
	xor		eax,eax
  Ex:
	ret

TestWord:
	lea		ecx,[esi+sizeof PROPERTIES]
	mov		edx,lpWord
	.if [esi].PROPERTIES.nType=='p'
		.if fCase
			invoke strcmp,ecx,edx
		.else
			invoke strcmpi,ecx,edx
		.endif
		.if !eax
			inc		eax
			retn
		.endif
		xor		eax,eax
	.elseif [esi].PROPERTIES.nType=='d'
		.while TRUE
			mov		al,[ecx]
			mov		ah,[edx]
			.if !ah
				.if al!='[' && al!=':'
					xor		eax,eax
				.endif
				retn
			.else
				.if !fCase
					.if al>='a' && al<='z'
						and		al,5Fh
					.endif
					.if ah>='a' && ah<='z'
						and		ah,5Fh
					.endif
				.endif
				.if al!=ah
					xor		eax,eax
					retn
				.endif
			.endif
			inc		ecx
			inc		edx
		.endw
	.endif
	xor		eax,eax
	retn

FindWord endp

AddPredefinedTypes proc uses ebx esi edi

	; Datatypes
	mov		esi,offset datatype
	.while [esi].DATATYPE.lpszType
		mov		eax,dbg.inxtype
		mov		edx,sizeof DEBUGTYPE
		mul		edx
		mov		edi,dbg.hMemType
		lea		edi,[edi+eax]
		invoke strcpy,addr [edi].DEBUGTYPE.szName,[esi].DATATYPE.lpszType
		movzx	eax,[esi].DATATYPE.nSize
		mov		[edi].DEBUGTYPE.nSize,eax
		inc		dbg.inxtype
		lea		esi,[esi+sizeof DATATYPE]
	.endw
	ret

AddPredefinedTypes endp

AddConstants proc uses ebx esi edi
	LOCAL	lpszName:DWORD
	LOCAL	buffer[256]:BYTE

	; Constants from RadASM, case sensitive
	mov		edx,lpData
	;Get pointer to word list
	mov		esi,[edx].ADDINDATA.lpWordList
	; Loop trough the word list
	.while [esi].PROPERTIES.nSize
		.if [esi].PROPERTIES.nType=='c' || [esi].PROPERTIES.nType=='R'
			; Found
			push	esi
			lea		edi,[esi+sizeof PROPERTIES]
			mov		lpszName,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			mov		eax,[edi]
			and		eax,0FF5F5F5Fh
			.if eax==' UQE'
				lea		edi,[edi+4]
			.endif
			invoke strcpy,addr buffer,edi
			lea		esi,buffer
			mov		nError,0
			invoke CalculateIt,0
			.if !nError
				push	eax
				mov		eax,dbg.inxtype
				mov		edx,sizeof DEBUGTYPE
				mul		edx
				mov		edi,dbg.hMemType
				lea		edi,[edi+eax]
				invoke strcpy,addr [edi].DEBUGTYPE.szName,lpszName
				pop		eax
				mov		[edi].DEBUGTYPE.nSize,eax
				inc		dbg.inxtype
;			.else
;				invoke wsprintf,addr outbuffer,addr szErrConstant,addr buffer
;				invoke PutString,addr outbuffer
			.endif
			pop		esi
		.endif
		;Move to next word
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
  Ex:
	ret

AddConstants endp

AddVar proc uses ebx esi edi,lpName:DWORD,nSize:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	lpArray:DWORD
	LOCAL	lpType:DWORD
	LOCAL	fErrArray:DWORD
	LOCAL	fErrType:DWORD

	mov		lpArray,0
	mov		lpType,0
	mov		fErrArray,0
	mov		fErrType,0
	mov		esi,lpName
	lea		edi,buffer
	.while TRUE
		mov		al,[esi]
		.if al=='['
			mov		byte ptr [edi],0
			inc		edi
			mov		lpArray,edi
			mov		[edi],al
			inc		edi
		.elseif al==':'
			mov		byte ptr [edi],0
			inc		edi
			mov		lpType,edi
			mov		[edi],al
			inc		edi
		.elseif al
			mov		[edi],al
			inc		edi
		.else
			xor		eax,eax
			mov		[edi],ax
			.break
		.endif
		inc		esi
	.endw
	mov		edi,dbg.lpvar
	; Add name
	invoke strcpy,addr [edi+sizeof DEBUGVAR],addr buffer
	invoke strlen,addr buffer
	lea		ebx,[eax+1]
	.if lpArray
		invoke strcpy,addr [edi+ebx+sizeof DEBUGVAR],lpArray
		invoke strlen,lpArray
		lea		ebx,[ebx+eax]
		add		eax,lpArray
		mov		byte ptr [eax-1],0
	.endif
	.if lpType
		mov		eax,lpType
		inc		eax
		invoke GetPredefinedDatatype,eax
		.if eax
			push	eax
			invoke strcpy,addr [edi+ebx+sizeof DEBUGVAR],addr szColon
			pop		eax
			invoke strcat,addr [edi+ebx+sizeof DEBUGVAR],eax
		.else
			invoke strcpy,addr [edi+ebx+sizeof DEBUGVAR],lpType
		.endif
		invoke strlen,addr [edi+ebx+sizeof DEBUGVAR]
		lea		ebx,[ebx+eax]
	.endif
	inc		ebx
	mov		eax,lpArray
	.if eax
		push	ebx
		lea		ebx,[eax+1]
		invoke DoMath,ebx
		.if eax
			lea		ebx,[ebx+eax]
			mov		eax,var.Value
			.if nAsm==nFP || nAsm==nBCET
				inc		eax
				.while byte ptr [ebx]==';'
					push	eax
					inc		ebx
					invoke DoMath,ebx
					.if !eax
						mov		fErrArray,TRUE
						pop		edx
						.break
					.endif
					lea		ebx,[ebx+eax]
					mov		eax,var.Value
					inc		eax
					pop		edx
					mul		edx
				.endw
			.elseif nAsm==nCPP
				.while byte ptr [ebx]==';'
					push	eax
					inc		ebx
					invoke DoMath,ebx
					.if !eax
						mov		fErrArray,TRUE
						pop		edx
						.break
					.endif
					lea		ebx,[ebx+eax]
					mov		eax,var.Value
					pop		edx
					mul		edx
				.endw
			.endif
		.else
			mov		fErrArray,TRUE
		.endif
		pop		ebx
	.else
		mov		eax,1
	.endif
	mov		[edi].DEBUGVAR.nArray,eax
	.if nSize
		mov		eax,nSize
		.if [edi].DEBUGVAR.nArray>1 && nAsm==nCPP
			xor		edx,edx
			mov		ecx,[edi].DEBUGVAR.nArray
			div		ecx
		.endif
		mov		[edi].DEBUGVAR.nSize,eax
	.elseif lpType
		mov		eax,lpType
		invoke FindTypeSize,addr [eax+1]
		.if !edx
			xor		eax,eax
			mov		fErrType,TRUE
		.endif
		mov		[edi].DEBUGVAR.nSize,eax
	.endif
	.if fErrArray
		invoke strlen,addr [edi+sizeof DEBUGVAR]
		invoke strcat,addr buffer,addr [edi+eax+1+sizeof DEBUGVAR]
		invoke wsprintf,addr outbuffer,addr szErrArray,addr buffer
		invoke PutString,addr outbuffer
		inc		dbg.nErrors
	.elseif fErrType
		invoke strlen,addr [edi+sizeof DEBUGVAR]
		invoke strcat,addr buffer,addr [edi+eax+1+sizeof DEBUGVAR]
		invoke wsprintf,addr outbuffer,addr szErrType,addr buffer
		invoke PutString,addr outbuffer
		inc		dbg.nErrors
	.endif
	mov		eax,[edi].DEBUGVAR.nSize
	lea		edi,[edi+ebx+sizeof DEBUGVAR]
	mov		dbg.lpvar,edi
	ret

AddVar endp

AddVarList proc uses ebx esi edi,lpList:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	nOfs:DWORD

	mov		nOfs,0
	mov		esi,lpList
	.while byte ptr [esi]
		mov		ebx,dbg.lpvar
		lea		edi,buffer
		.while TRUE
			mov		al,[esi]
			.if !al
				mov		[edi],al
				invoke AddVar,addr buffer,0
				.break
			.elseif al==','
				mov		byte ptr [edi],0
				invoke AddVar,addr buffer,0
				inc		esi
				.break
			.else
				mov		[edi],al
				inc		esi
				inc		edi
			.endif
		.endw
		mov		eax,[ebx].DEBUGVAR.nSize
		mov		ecx,nOfs
		mov		edx,[ebx].DEBUGVAR.nArray
		.if  !(eax & 3) && (ecx & 3)
			; DWord align
			shr		ecx,2
			inc		ecx
			shl		ecx,2
		.elseif !(eax & 1) && (ecx & 1)
			; Word align
			shr		ecx,1
			inc		ecx
			shl		ecx,1
		.endif
		mul		edx
		add		eax,ecx
		mov		nOfs,eax
		mov		[ebx].DEBUGVAR.nOfs,eax
	.endw
	mov		eax,dbg.lpvar
	lea		eax,[eax+sizeof DEBUGVAR+2]
	mov		dbg.lpvar,eax
	ret

AddVarList endp

AddVarListFp proc uses ebx esi edi,lpList:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	flocal:DWORD

	mov		flocal,0
	mov		esi,lpList
	.while byte ptr [esi]
		mov		ebx,dbg.lpvar
		lea		edi,buffer
		.while TRUE
			mov		al,[esi]
			.if !al
				mov		[edi],al
				.break
			.elseif al==','
				mov		byte ptr [edi],0
				inc		esi
				.break
			.else
				mov		[edi],al
				inc		esi
				inc		edi
			.endif
		.endw
		invoke DecToBin,esi
		.while byte ptr [esi]
			.if byte ptr [esi]==','
				inc		esi
				.break
			.endif
			inc		esi
		.endw
		push	eax
		.if !flocal && sdword ptr eax<0
			inc		flocal
			mov		eax,dbg.lpvar
			lea		eax,[eax+sizeof DEBUGVAR+2]
			mov		dbg.lpvar,eax
			mov		ebx,dbg.lpvar
		.endif
		invoke AddVar,addr buffer,0
		pop		eax
		mov		[ebx].DEBUGVAR.nOfs,eax
	.endw
	mov		eax,dbg.lpvar
	lea		eax,[eax+sizeof DEBUGVAR+2]
	mov		dbg.lpvar,eax
	ret

AddVarListFp endp

EnumTypesCallback proc uses ebx esi edi,pSymInfo:DWORD,SymbolSize:DWORD,UserContext:DWORD

	mov		esi,pSymInfo
	.if fOptions & 1
		invoke wsprintf,addr outbuffer,addr szType,addr [esi].SYMBOL_INFO.szName,[esi].SYMBOL_INFO.nSize
		invoke PutString,addr outbuffer
	.endif
	mov		eax,dbg.inxtype
	mov		edx,sizeof DEBUGTYPE
	mul		edx
	mov		edi,dbg.hMemType
	lea		edi,[edi+eax]
	invoke strcpyn,addr [edi].DEBUGTYPE.szName,addr [esi].SYMBOL_INFO.szName,sizeof DEBUGTYPE.szName
	mov		eax,[esi].SYMBOL_INFO.nSize
	.if !eax
		invoke FindTypeSize,addr [edi].DEBUGTYPE.szName
	.endif
	mov		[edi].DEBUGTYPE.nSize,eax
	inc		dbg.inxtype
	mov		eax,TRUE
	ret

EnumTypesCallback endp

EnumerateSymbolsCallback proc uses ebx esi edi,SymbolName:DWORD,SymbolAddress:DWORD,SymbolSize:DWORD,UserContext:DWORD
	LOCAL	buffer[512]:BYTE

	.if SymbolSize
		mov		eax,dbg.inxsymbol
		mov		edx,sizeof DEBUGSYMBOL
		mul		edx
		mov		edi,dbg.hMemSymbol
		lea		edi,[edi+eax]
		mov		eax,SymbolAddress
		mov		[edi].DEBUGSYMBOL.Address,eax
		mov		eax,SymbolSize
		mov		[edi].DEBUGSYMBOL.nSize,eax
		invoke strcpyn,addr [edi].DEBUGSYMBOL.szName,SymbolName,sizeof DEBUGSYMBOL.szName
		invoke FindWord,SymbolName,fCaseSensitive
		.if eax
			mov		esi,eax
			movzx	edx,[esi].PROPERTIES.nType
			mov		[edi].DEBUGSYMBOL.nType,dx
			.if edx=='p'
				; Proc
				invoke strcpyn,addr [edi].DEBUGSYMBOL.szName,addr [esi+sizeof PROPERTIES],sizeof DEBUGSYMBOL.szName
				mov		eax,dbg.lpvar
				mov		[edi].DEBUGSYMBOL.lpType,eax
				.if nAsm==nFP || nAsm==nBCET
					; Point to parameters / locals
					mov		esi,SymbolName
					invoke strlen,esi
					lea		esi,[esi+eax+1]
					invoke AddVarListFp,esi
				.else
					; Point to parameters
					invoke strlen,addr [esi+sizeof PROPERTIES]
					lea		esi,[esi+eax+1+sizeof PROPERTIES]
					invoke AddVarList,esi
					; Point to locals
					invoke strlen,esi
					lea		esi,[esi+eax+1]
					invoke AddVarList,esi
					mov		eax,SymbolAddress
					add		eax,SymbolSize
					.if eax>dbg.maxproc
						mov		dbg.maxproc,eax
					.endif
				.endif
			.elseif edx=='d'
				; Variable
				.if nAsm==nFP || nAsm==nBCET
					.if [edi].DEBUGSYMBOL.nSize==-1
						mov		[edi].DEBUGSYMBOL.nSize,0
					.endif
					lea		edx,[esi+sizeof PROPERTIES]
					lea		ecx,[edi].DEBUGSYMBOL.szName
					.while byte ptr [edx]!=':' && byte ptr [edx]!='['
						mov		al,[edx]
						mov		[ecx],al
						inc		edx
						inc		ecx
					.endw
					mov		byte ptr [ecx],0
					mov		eax,dbg.lpvar
					mov		[edi].DEBUGSYMBOL.lpType,eax
					invoke AddVar,addr [esi+sizeof PROPERTIES],[edi].DEBUGSYMBOL.nSize
					mov		[edi].DEBUGSYMBOL.nSize,eax
				.else
					.if [edi].DEBUGSYMBOL.nSize==-1
						mov		[edi].DEBUGSYMBOL.nSize,0
					.endif
					lea		edx,[esi+sizeof PROPERTIES]
					lea		ecx,[edi].DEBUGSYMBOL.szName
					.while byte ptr [edx]!=':' && byte ptr [edx]!='['
						mov		al,[edx]
						mov		[ecx],al
						inc		edx
						inc		ecx
					.endw
					mov		byte ptr [ecx],0
					mov		eax,dbg.lpvar
					mov		[edi].DEBUGSYMBOL.lpType,eax
					invoke AddVar,addr [esi+sizeof PROPERTIES],[edi].DEBUGSYMBOL.nSize
					mov		[edi].DEBUGSYMBOL.nSize,eax
				.endif
			.endif
			.if fOptions & 1
				invoke wsprintf,addr buffer,addr szSymbol,addr [edi].DEBUGSYMBOL.szName,[edi].DEBUGSYMBOL.Address,[edi].DEBUGSYMBOL.nSize
				invoke PutString,addr buffer
			.endif
		.endif
		inc		dbg.inxsymbol
	.endif
	mov		eax,TRUE
	ret

EnumerateSymbolsCallback endp

EnumSourceFilesCallback proc uses ebx esi edi,pSourceFile:DWORD,UserContext:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	fn:DWORD

	mov		ebx,pSourceFile
	.if fOptions & 1
		invoke wsprintf,addr buffer,addr szSourceFile,[ebx].SOURCEFILE.FileName
		invoke PutString,addr buffer
	.endif
	invoke GetFullPathName,[ebx].SOURCEFILE.FileName,sizeof buffer,addr buffer,addr fn
	mov		eax,dbg.inxsource
	mov		edx,sizeof DEBUGSOURCE
	mul		edx
	mov		edi,dbg.hMemSource
	lea		edi,[edi+eax]
	mov		eax,dbg.inxsource
	mov		[edi].DEBUGSOURCE.FileID,ax
	invoke strcpy,addr [edi].DEBUGSOURCE.FileName,addr buffer
	inc		dbg.inxsource
	mov		eax,TRUE
	ret

EnumSourceFilesCallback endp

EnumLinesCallback proc uses ebx esi edi,pLineInfo:DWORD,UserContext:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	fn:DWORD

	mov		ebx,pLineInfo
	.if fOptions & 1
		invoke wsprintf,addr buffer,addr szSourceLine,addr [ebx].SRCCODEINFO.FileName,[ebx].SRCCODEINFO.Address,[ebx].SRCCODEINFO.LineNumber
		invoke PutString,addr buffer
	.endif
	invoke GetFullPathName,addr [ebx].SRCCODEINFO.FileName,sizeof buffer,addr buffer,addr fn
	; Find source file
	xor		ecx,ecx
	.while ecx<dbg.inxsource
		push	ecx
		mov		eax,ecx
		mov		edx,sizeof DEBUGSOURCE
		mul		edx
		mov		esi,dbg.hMemSource
		lea		esi,[esi+eax]
		invoke strcmpi,addr [esi].DEBUGSOURCE.FileName,addr buffer
		.if !eax
			mov		eax,dbg.inxline
			mov		edx,sizeof DEBUGLINE
			mul		edx
			mov		edi,dbg.hMemLine
			lea		edi,[edi+eax]
			mov		ax,[esi].DEBUGSOURCE.FileID
			mov		[edi].DEBUGLINE.FileID,ax
			mov		eax,[ebx].SRCCODEINFO.LineNumber
			mov		[edi].DEBUGLINE.LineNumber,eax
			mov		eax,[ebx].SRCCODEINFO.Address
			mov		[edi].DEBUGLINE.Address,eax
			inc		dbg.inxline
			pop		ecx
			.break
		.endif
		pop		ecx
		inc		ecx
	.endw
	mov		eax,TRUE
	ret

EnumLinesCallback endp

DbgHelp proc uses ebx esi edi,lpDll:DWORD,hProcess:DWORD,lpFileName:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke LoadLibrary,lpDll
	.if eax
		mov		hDbgHelpDLL,eax
		invoke GetDbgHelpVersion,lpDll
		; Allocate memory for DEBUGTYPE, max 16K types
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16*1024*sizeof DEBUGTYPE
		mov		dbg.hMemType,eax
		; Allocate memory for DEBUGSYMBOL, max 16K symbols
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16*1024*sizeof DEBUGSYMBOL
		mov		dbg.hMemSymbol,eax
		; Allocate memory for DEBUGSOURCE, max 512 sources
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,512*sizeof DEBUGSOURCE
		mov		dbg.hMemSource,eax
		; Allocate memory for DEBUGLINE, max 128K lines
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,128*1024*sizeof DEBUGLINE
		mov		dbg.hMemLine,eax
		; Allocate memory for var definitions
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
		mov		dbg.hMemVar,eax
		mov		dbg.lpvar,eax
		; Zero the indexes
		mov		dbg.inxtype,0
		mov		dbg.inxsymbol,0
		mov		dbg.inxsource,0
		mov		dbg.inxline,0
		invoke GetProcAddress,hDbgHelpDLL,addr szSymInitialize
		.if eax
			mov		ebx,eax
			push	FALSE
			push	NULL
			push	hProcess
			call	ebx
		.endif
		.if eax
			invoke GetProcAddress,hDbgHelpDLL,addr szSymLoadModule
			.if eax
				mov		ebx,eax
				push	0
				push	0
				push	0
				push	lpFileName
				push	0
				push	hProcess
				call	ebx
			.endif
			.if eax
				mov		dwModuleBase,eax
				mov		im.SizeOfStruct,sizeof IMAGEHLP_MODULE
				mov		im.SymType1,SymNone
				invoke GetProcAddress,hDbgHelpDLL,addr szSymGetModuleInfo
				.if eax
					mov		ebx,eax
					lea		eax,im
					push	eax
					push	dwModuleBase
					push	hProcess
					call	ebx
				.endif
				.if im.SymType1==SymPdb
					invoke AddPredefinedTypes
					invoke GetProcAddress,hDbgHelpDLL,addr szSymEnumTypes
					.if eax
						mov		ebx,eax
						push	0
						push	offset EnumTypesCallback
						push	0
						push	dwModuleBase
						push	hProcess
						call	ebx
					.endif
					invoke AddConstants
					invoke GetProcAddress,hDbgHelpDLL,addr szSymEnumerateSymbols
					.if eax
						mov		ebx,eax
						.if fOptions & 1
							invoke PutString,addr szSymOk
						.endif
						push	0
						push	offset EnumerateSymbolsCallback
						push	dwModuleBase
						push	hProcess
						call	ebx
					.endif
					invoke GetProcAddress,hDbgHelpDLL,addr szSymEnumSourceFiles
					.if eax
						mov		ebx,eax
						.if fOptions & 1
							invoke PutString,addr szSymEnumSourceFiles
						.endif
						push	0
						push	offset EnumSourceFilesCallback
						push	0
						push	0
						push	dwModuleBase
						push	hProcess
						call	ebx
					.endif
					invoke GetProcAddress,hDbgHelpDLL,addr szSymEnumSourceLines
					.if eax
						mov		ebx,eax
						.if fOptions & 1
							invoke PutString,addr szSymEnumSourceLines
						.endif
						push	0
						push	offset EnumLinesCallback
						push	0
						push	0
						push	0
						push	0
						push	0
						push	dwModuleBase
						push	hProcess
						call	ebx
						.if dbg.inxline
							invoke SortLinesByAddress
						.endif
					.endif
				.endif
				invoke GetProcAddress,hDbgHelpDLL,addr szSymUnloadModule
				.if eax
					mov		ebx,eax
					push	dwModuleBase
					push	hProcess
					call	ebx
				.endif
				invoke GetProcAddress,hDbgHelpDLL,addr szSymCleanup
				.if eax
					mov		ebx,eax
					push	hProcess
					call	ebx
				.endif
			.else
				invoke PutString,addr szSymLoadModuleFailed
			.endif
		.else
			invoke PutString,addr szSymInitializeFailed
		.endif
		invoke FreeLibrary,hDbgHelpDLL
		mov		hDbgHelpDLL,0
	.else
		invoke wsprintf,addr outbuffer,addr szDbgHelpFail,lpDll
		invoke PutString,addr outbuffer
	.endif
	ret

DbgHelp endp
