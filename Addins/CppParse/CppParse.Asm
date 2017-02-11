.386
.model flat, stdcall
option casemap :none   ; case sensitive

include CppParse.inc

.code

PrintWord proc lpWord:DWORD,l:DWORD

	pushad
	mov		esi,lpWord
	mov		ecx,l
	mov		al,byte ptr [esi+ecx]
	push	eax
	mov		byte ptr [esi+ecx],0
	PrintStringByAddr esi
	pop		eax
	mov		ecx,l
	mov		byte ptr [esi+ecx],al
	popad
	ret

PrintWord endp

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

strcpyn proc uses esi edi,lpDest:DWORD,lpSource:DWORD,len:DWORD

	mov		esi,lpSource
	xor		ecx,ecx
	mov		edi,lpDest
	mov		edx,len
	dec		edx
  @@:
	mov		al,[esi+ecx]
	.if sdword ptr ecx>=edx
		xor		al,al
	.endif
	mov		[edi+ecx],al
	inc		ecx
	or		al,al
	jne		@b
	ret

strcpyn endp

SearchMem proc uses ebx ecx edx esi edi,hMem:DWORD,lpFind:DWORD,fMCase:DWORD,fWWord:DWORD,lpCharTab:DWORD

	mov		cl,byte ptr fWWord
	mov		ch,byte ptr fMCase
	mov		edi,hMem
	dec		edi
	mov		esi,lpFind
  Nx:
	xor		edx,edx
	inc		edi
	dec		edx
  Mr:
	inc		edx
	mov		al,[edi+edx]
	mov		ah,[esi+edx]
	.if ah && al
		cmp		al,ah
		je		Mr
		.if !ch
			;Try other case (upper/lower)
			movzx	ebx,ah
			add		ebx,lpCharTab
			cmp		al,[ebx+256]
			je		Mr
		.endif
		jmp		Nx					;Test next char
	.else
		.if !ah
			or		cl,cl
			je		@f
			;Whole word
			movzx	eax,al
			add		eax,lpCharTab
			mov		al,[eax]
			dec		al
			je		Nx				;Not found yet
			lea		eax,[edi-1]
			.if eax>=hMem
				movzx	eax,byte ptr [eax]
				add		eax,lpCharTab
				mov		al,[eax]
				dec		al
				je		Nx			;Not found yet
			.endif
		  @@:
			mov		eax,edi			;Found, return pos in eax
		.else
			xor		eax,eax			;Not found
		.endif
	.endif
	ret

SearchMem endp

SearchType proc uses esi,lpType:DWORD

	mov		esi,lpData
	mov		esi,[esi].ADDINDATA.lpWordList
	.while [esi].PROPERTIES.nSize
		movzx	eax,[esi].PROPERTIES.nType
		.if eax=='T' || eax=='t' || eax=='S' || eax=='s'
			call	Compare
			je		@f
		.endif
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
  @@:
	ret

Compare:
	lea		edx,[esi+sizeof PROPERTIES]
	mov		ecx,lpType
  @@:
	mov		al,[ecx]
	mov		ah,[edx]
	inc		ecx
	inc		edx
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	.if al>='a' && al<='z'
		and		al,5Fh
	.endif
	sub		al,ah
	jne		@f
	cmp		al,ah
	jne		@b
  @@:
	retn

SearchType endp

IsWord proc lpSrc:DWORD,nLen:DWORD,lpWord:DWORD,lpCharTab:DWORD

	invoke strlen,lpWord
	.if eax==nLen
		push	esi
		push	edi
		mov		esi,lpSrc
		mov		edi,lpWord
		mov		edx,lpCharTab
		xor		ecx,ecx
		xor		eax,eax
		inc		eax
		.while ecx<nLen
			movzx	eax,byte ptr [esi+ecx]
			.if al==[edi+ecx]
				xor		eax,eax
			.else
				movzx	eax,byte ptr [edx+eax+256]
				.if al==[edi+ecx]
					xor		eax,eax
				.else
					.break
				.endif
			.endif
			inc		ecx
		.endw
		pop		edi
		pop		esi
		.if !eax
			inc		eax
		.else
			xor		eax,eax
		.endif
	.else
		xor		eax,eax
	.endif
	ret

IsWord endp

PreParse proc uses esi edi,lpMem:DWORD,lpCharTab
	LOCAL	lnSt:DWORD

	mov		esi,lpMem
	mov		edi,esi
	mov		lnSt,esi
	.while byte ptr [esi]
		mov		edx,esi
		call	SkipSpc
		.if edx!=esi
			.if edi!=lpMem
				movzx	eax,byte ptr [edi-1]
				mov		edx,lpCharTab
				.if byte ptr [edx+eax]==1
					mov		byte ptr [edi],' '
					inc		edi
				.endif
			.endif
		.endif
		movzx	eax,byte ptr [esi]
		mov		edx,lpCharTab
		.if byte ptr [edx+eax]!=1
			.if byte ptr [edi-1]==' '
				dec		edi
			.endif
		.endif
		mov		al,[esi]
		inc		esi
		.if al!=0Ah
			.if al!=0Dh || edi!=lnSt
				mov		[edi],al
				inc		edi
				.if al==0Dh
					mov		lnSt,edi
				.endif
			.endif
		.endif
	.endw
	mov		byte ptr [edi],0
	ret

SkipSpc:
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
		inc		esi
	.endw
	.if word ptr [esi]=='//'
		.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
			inc		esi
		.endw
	.endif
	retn

PreParse endp

SkipScope proc

	xor		eax,eax
	xor		ecx,ecx
SkipScope1:
	mov		al,[esi]
	or		al,al
	je		@f
	inc		esi
	.if al==ah
		dec		ecx
		retn
	.elseif al=='['
		push	eax
		inc		ecx
		mov		ah,']'
		call	SkipScope1
		pop		eax
	.elseif al=='('
		push	eax
		inc		ecx
		mov		ah,')'
		call	SkipScope1
		pop		eax
	.elseif al=='{'
		; Begin / End
		push	eax
		inc		ecx
		mov		ah,'}'
		call	SkipScope1
		pop		eax
	.elseif al=='"' || al=="'"
		; String
		inc		ecx
		.while al!=[esi] && byte ptr [esi]
			inc		esi
		.endw
		.if al==[esi]
			inc		esi
			dec		ecx
		.endif
	.elseif word ptr [esi]=='//'
		; Comment
		.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
			inc		esi
		.endw
		.if byte ptr [esi]==VK_RETURN
			inc		esi
			.if byte ptr [esi]==0Ah
				inc		esi
			.endif
		.endif
	.endif
	or		ecx,ecx
	jne		SkipScope1
  @@:
	ret

SkipScope endp

FindInFile proc uses esi edi,nInx:DWORD,lpMem:DWORD,lpFind1:DWORD,lpFind2:DWORD,lpCharTab:DWORD
	LOCAL	nLine:DWORD
	LOCAL	lpPos:DWORD

	mov		nLine,-1
	mov		esi,lpMem
	.if nInx==0
		; Function
		invoke strcpy,offset buffer1,lpFind2
		mov		edi,offset buffer1
		invoke strlen,edi
		mov		dword ptr [edi+eax],0
		.while byte ptr [edi]
			.if byte ptr [edi]==' ' || byte ptr [edi]==','
				mov		byte ptr [edi],0
			.endif
			inc		edi
		.endw
	  @@:
		invoke SearchMem,esi,lpFind1,TRUE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			mov		edi,eax
			.while byte ptr [edi]
				.if byte ptr [edi]==';'
					inc		esi
					jmp		@b
				.elseif byte ptr [edi]=='{'
					call	CopyLine
					or		edx,edx
					jne		@b
					mov		edi,offset buffer1
					invoke SearchMem,offset buffer,edi,TRUE,TRUE,lpCharTab
					or		eax,eax
					je		@b
					call	GetLineNo
					.break
				.endif
				inc		edi
			.endw
		.endif
	.elseif nInx==1
		; Constant
	  @@:
		invoke SearchMem,esi,offset szDefine,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
		.endif
	.elseif nInx==2
		; Data
	  @@:
		invoke SearchMem,esi,lpFind2,FALSE,TRUE,lpCharTab
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
			or		eax,eax
			je		@b
			call	GetLineNo
		.endif
	.elseif nInx==5
		; Struct
	  @@:
		invoke SearchMem,esi,offset szStruct,FALSE,TRUE,lpCharTab
		.if !eax
			invoke SearchMem,esi,offset szUnion,FALSE,TRUE,lpCharTab
		.endif
		.if eax
			mov		esi,eax
			call	CopyLine
			or		edx,edx
			jne		@b
			mov		esi,lpPos
			.while byte ptr [esi]!='{' && byte ptr [esi]
				inc		esi
			.endw
			.if byte ptr [esi]=='{'
				call	SkipScope
				.if !ecx
					.while byte ptr [esi]!=0Dh
						mov		al,[esi]
						mov		[edi],al
						inc		esi
						inc		edi
					.endw
					mov		byte ptr [edi],0
					invoke SearchMem,offset buffer,lpFind1,TRUE,TRUE,lpCharTab
					or		eax,eax
					je		@b
					mov		esi,lpPos
					call	GetLineNo
				.endif
			.endif
		.endif
	.endif
	mov		eax,nLine
	mov		edx,lpPos
	ret

GetLineStart:
	.while esi>lpMem
		mov		al,[esi]
		.if al=='(' || al=='/' || al=='"' || al=="'"
			inc		edx
		.endif
		.break .if byte ptr [esi-1]==0Dh || byte ptr [esi-1]==0Ah
		dec		esi
	.endw
	mov		lpPos,esi
	retn

CopyLine:
	xor		edx,edx
	call	GetLineStart
	mov		edi,offset buffer
	.while byte ptr [esi]!=0Dh
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		byte ptr [edi],0
	retn

GetLineNo:
	xor		ecx,ecx
	mov		eax,esi
	mov		esi,lpMem
	.while esi<eax
		.if byte ptr [esi]==VK_RETURN
			inc		ecx
		.endif
		inc		esi
		mov		nLine,ecx
	.endw
	retn

FindInFile endp

ParseFile proc uses ebx esi edi,iNbr:DWORD,lpMem:DWORD,lpAddProperty:DWORD,lpCharTab:DWORD
	LOCAL	len:DWORD
	LOCAL	lpFun:DWORD
	LOCAL	lpParamSt:DWORD
	LOCAL	lpParamEn:DWORD
	LOCAL	nNest:DWORD
	LOCAL	lpTemp:DWORD
	LOCAL	fTypedef:DWORD
	LOCAL	lpBegin:DWORD
	LOCAL	lpEnd:DWORD
	LOCAL	lpRet:DWORD
	LOCAL	lenRet:DWORD

	mov		esi,lpMem
	mov		nNest,0
	.while byte ptr [esi]
		mov		fTypedef,0
		call	GetWrd
		.if len
			mov		lpRet,esi
			call	_Skip
			or		eax,eax
			jne		Nxt
			call	_Include
			or		eax,eax
			jne		Nxt
			call	_Constant
			or		eax,eax
			jne		Nxt
			call	_Typedef
			or		eax,eax
			jne		Nxt
			call	_Struct
			or		eax,eax
			jne		Nxt
			call	_Function
			or		eax,eax
			jne		Nxt
			call	_Unknown
		.else
			mov		al,[esi]
			.if al=='"' || al=='{' || al=='('
				call	SkipScope
			.elseif al==VK_RETURN
				inc		esi
				.if byte ptr [esi]==0Ah
					inc		esi
				.endif
			.else
				inc		esi
			.endif
		.endif
	  Nxt:
	.endw
	ret

_Begin:
	mov		eax,esi
	.while byte ptr [esi]!=';' && byte ptr [esi]!='{' && byte ptr [esi]
		inc		esi
	.endw
	.if byte ptr [esi]!='{'
		mov		esi,eax
		xor		eax,eax
	.endif
	retn

GetArray:
	call	SkipSpc
	.if byte ptr [esi]=='['
		mov		ebx,esi
		call	SkipScope
		mov		eax,esi
		sub		eax,ebx
		.if eax==2
			mov		byte ptr [edi],'['
			inc		edi
			call	SkipSpc
			.if byte ptr [esi]=='='
				inc		esi
				call	SkipSpc
				.if byte ptr [esi]=='"' || byte ptr [esi]=="'"
					;szTest[]="Test";
					mov		ebx,esi
					call	SkipScope
					mov		eax,esi
					sub		eax,ebx
					dec		eax
					invoke BinToDec,eax,edi
					invoke strlen,edi
					lea		edi,[edi+eax]
				.endif
			.endif
			mov		byte ptr [edi],']'
			inc		edi
		.else
			.while ebx<esi
				mov		al,[ebx]
				mov		[edi],al
				inc		ebx
				inc		edi
			.endw
		  @@:
			call	SkipSpc
			.if byte ptr [esi]=='['
				mov		byte ptr [edi-1],';'
				lea		ebx,[esi+1]
				call	SkipScope
				.while ebx<esi
					mov		al,[ebx]
					mov		[edi],al
					inc		ebx
					inc		edi
				.endw
				jmp		@b
			.endif
		.endif
	.endif
	retn

_Skip:
;PrintText "Skip"
	invoke IsWord,esi,len,offset szInline,lpCharTab
	or		eax,eax
	jne		SkipSc
	invoke IsWord,esi,len,offset szClass,lpCharTab
	or		eax,eax
	jne		SkipSc
	invoke IsWord,esi,len,offset szEnum,lpCharTab
	or		eax,eax
	jne		SkipSc
	invoke IsWord,esi,len,offset szDECLARE_INTERFACE,lpCharTab
	or		eax,eax
	jne		SkipSc
	invoke IsWord,esi,len,offset szDECLARE_INTERFACE_,lpCharTab
	or		eax,eax
	jne		SkipSc
	invoke IsWord,esi,len,offset szDECLARE_MAPI_INTERFACE_,lpCharTab
	or		eax,eax
	jne		SkipSc
_SkipDf:
	invoke IsWord,esi,len,offset szExtern,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szIfdef,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szIfndef,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szIf,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szElif,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szElse,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szEndif,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szPragma,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szUndef,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szError,lpCharTab
	or		eax,eax
	jne		SkipLn
	invoke IsWord,esi,len,offset szStatic,lpCharTab
	or		eax,eax
	jne		SkipWd
	invoke IsWord,esi,len,offset szConst,lpCharTab
	or		eax,eax
	jne		SkipWd
	xor		eax,eax
	retn
  SkipSc:
	add		esi,len
	call	_Begin
	.if eax
		call	SkipScope
	.endif
	mov		eax,TRUE
	retn
  SkipLn:
	.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
		inc		esi
	.endw
	.if byte ptr [esi]==VK_RETURN
		inc		esi
		.if byte ptr [esi]==0Ah
			inc		esi
		.endif
	.endif
	mov		eax,TRUE
	retn
  SkipWd:
	add		esi,len
	mov		eax,TRUE
	retn

_Typedef:
;PrintText "Typedef"
	; typedef LNG(ULONG);
	invoke IsWord,esi,len,offset szTypedef,lpCharTab
	.if eax
		mov		fTypedef,TRUE
		add		esi,len
		call	GetWrd
		call	_Struct
		.if !eax
			mov		ecx,len
			inc		ecx
			invoke strcpyn,offset buffer,esi,ecx
			add		esi,len
			call	GetWrd
			.if !ecx && byte ptr [esi]=='('
				inc		esi
				call	GetWrd
				.if ecx
					inc		ecx
					invoke strcpyn,offset buffer1,esi,ecx
					add		esi,len
					invoke strlen,offset buffer
					invoke strcpy,addr buffer[eax+1],offset buffer1
					.if lpAddProperty
						push	2
						push	offset buffer
						push	iNbr
						push	't'
						mov		eax,lpAddProperty
						call	eax
					.endif
				.endif
			.endif
		.endif
		mov		eax,TRUE
		retn
	.endif
	xor		eax,eax
	retn

_Struct:
;PrintText "Struct"
	; typedef struct tagHEBMK
	; {
	;	HWND hWin;
	;	UINT nLine;
	; } HEBMK;
	invoke IsWord,esi,len,offset szUnaligned,lpCharTab
	.if eax
		add		esi,len
		call	GetWrd
	.endif
	invoke IsWord,esi,len,offset szStruct,lpCharTab
	.if !eax
		invoke IsWord,esi,len,offset szUnion,lpCharTab
	.endif
	.if eax
		add		esi,len
		call	GetWrd
		.if ecx
			.if !fTypedef
				inc		ecx
				invoke strcpyn,offset buffer,esi,ecx
			.endif
			add		esi,len
			call	_Begin
			.if eax
				push	esi
				call	SkipScope
				mov		edx,esi
				pop		esi
				.if !ecx
					mov		al,[edx]
					push	eax
					push	edx
					mov		byte ptr [edx],0
					mov		edi,offset buffer1
					mov		byte ptr [edi],0
					.while byte ptr [esi]
					  @@:
						call	GetWrd
						mov		ecx,len
						.if ecx
							inc		ecx
							invoke strcpyn,offset buffer2,esi,ecx
							add		esi,len
							call	GetWrd
							.if ecx
								inc		ecx
								invoke strcpyn,edi,esi,ecx
								invoke strlen,edi
								lea		edi,[edi+eax]
								call	GetArray
								mov		word ptr [edi],':'
								inc		edi
								xor		ecx,ecx
								.while buffer2[ecx]
									mov		al,buffer2[ecx]
									.if al>='a' && al<='z'
										and		al,5Fh
									.endif
									mov		[edi],al
									inc		ecx
									inc		edi
								.endw
								mov		word ptr [edi],','
								inc		edi
								add		esi,len
							.endif
						.else
							.if byte ptr [esi]=='('
								call	SkipScope
							.elseif byte ptr [esi]
								inc		esi
							.endif
						.endif
						call	SkipSpc
						.while byte ptr [esi]==';' || byte ptr [esi]==VK_RETURN || byte ptr [esi]==0Ah
							inc		esi
						.endw
					.endw
					pop		esi
					pop		eax
					mov		[esi],al
					dec		edi
					.if byte ptr [edi]==','
						mov		byte ptr [edi],0
						.if fTypedef
							call	GetWrd
							.if ecx
								inc		ecx
								invoke strcpyn,offset buffer,esi,ecx
								add		esi,len
							.endif
						.endif
						invoke strlen,offset buffer
						invoke strcpy,addr buffer[eax+1],offset buffer1
						.if lpAddProperty
							push	2
							push	offset buffer
							push	iNbr
							push	's'
							mov		eax,lpAddProperty
							call	eax
						.endif
						mov		eax,TRUE
					.endif
				.endif
			.endif
		.endif
		mov		eax,TRUE
		retn
	.endif
	xor		eax,eax
	retn

_Constant:
;PrintText "#define"
	; Constant
	; #define MYCONSTANT 0x01
	invoke IsWord,esi,len,offset szDefine,lpCharTab
	.if eax
		add		esi,len
		call	GetWrd
		inc		ecx
		invoke strcpyn,offset buffer,esi,ecx
		invoke IsWord,esi,len,offset szNew,lpCharTab
		.if eax
			jmp		SkipLn
		.endif
		add		esi,len
		call	GetWrd
		invoke strlen,offset buffer
		mov		ecx,len
		inc		ecx
		invoke strcpyn,addr buffer[eax+1],esi,ecx
		add		esi,len
		.if lpAddProperty
			push	2
			push	offset buffer
			push	iNbr
			push	'c'
			mov		eax,lpAddProperty
			call	eax
		.endif
		mov		eax,TRUE
	.endif
	retn

_Include:
;PrintText "#include"
	; Include
	; #include <windows.h>
	; #include "MyInclude.h"
	invoke IsWord,esi,len,offset szInclude,lpCharTab
	.if eax
		add		esi,len
		call	SkipSpc
		.if byte ptr [esi]=='"'
			call	SkipScope
		.elseif byte ptr [esi]=='<'
			.while byte ptr [esi]!='>' && byte ptr [esi]
				inc		esi
			.endw
			.if byte ptr [esi]=='>'
				inc		esi
			.endif
		.endif
		mov		eax,TRUE
	.endif
	retn

_Function:
;PrintText "Function"
	; Function
	; int TestIt()
	; {
	; }
	mov		lpTemp,esi
	xor		edx,edx
	mov		lpFun,edx
	mov		lpParamSt,edx
	inc		edx
	.while byte ptr [esi]!=';' && byte ptr [esi]!='{' && byte ptr [esi]
	  @@:
		push	edx
		call	GetWrd
		pop		edx
		.if ecx
			mov		edi,esi
			add		esi,ecx
			jmp		@b
		.elseif byte ptr [esi]=='('
			mov		lpFun,edi
			mov		lpParamSt,esi
			call	SkipScope
			mov		lpParamEn,esi
			mov		edx,ecx
		.else
			.if byte ptr [esi]==VK_RETURN
				inc		esi
				.if byte ptr [esi]==0Ah
					inc		esi
				.endif
			.else
				jmp		@f
			.endif
		.endif
	.endw
	push	edx
	call	_Begin
	mov		lpBegin,esi
	mov		lpEnd,esi
	pop		edx
	.if eax && lpFun && !edx
		mov		eax,lpTemp
		.if eax<=lpFunPos
			mov		lpFunSt,eax
			mov		lpFunEn,-1
		.endif
		mov		lpTemp,esi
		mov		esi,lpFun
		call	GetWrd
		inc		ecx
		invoke strcpyn,offset buffer,esi,ecx
		invoke strlen,offset buffer
		lea		edi,buffer[eax+1]
		mov		dword ptr [edi],0
		mov		esi,lpParamSt
		inc		esi
		dec		lpParamEn
		.while esi<lpParamEn
			call	GetWrd
			mov		ebx,esi
			add		esi,len
			push	len
			call	GetWrd
			invoke IsWord,esi,len,offset szFar,lpCharTab
			.if eax
				add		esi,len
				pop		eax
				mov		eax,esi
				sub		eax,ebx
				push	eax
				call	GetWrd
			.endif
			.if !len
				push	esi
				xor		edx,edx
				.while byte ptr [esi]=='*'
					inc		edx
					inc		esi
				.endw
				push	edx
				call	GetWrd
				pop		edx
				pop		esi
				add		len,edx
				add		ecx,edx
			.endif
			pop		edx
			.if edx && len
				.while ecx
					mov		al,[esi]
					mov		[edi],al
					inc		esi
					inc		edi
					dec		ecx
				.endw
				mov		byte ptr [edi],':'
				inc		edi
				.while edx
					mov		al,[ebx]
					.if al>='a' && al<='z'
						and		al,5Fh
					.endif
					mov		[edi],al
					inc		ebx
					inc		edi
					dec		edx
				.endw
				call	GetWrd
				.if byte ptr [esi]==','
					inc		esi
					mov		byte ptr [edi],','
					inc		edi
				.endif
			.else
				.break
			.endif
		.endw
		mov		dword ptr [edi],0
		inc		edi
		mov		esi,lpTemp
		call	SkipScope
		.if lpFunEn==-1
			mov		lpFunEn,esi
			.if  esi>=lpFunPos
				ret
			.endif
		.endif
		.if lpAddProperty
			push	esi
			xchg	esi,lpTemp
			.while esi<lpTemp
				call	GetWrd
				invoke IsWord,esi,ecx,offset szStatic,lpCharTab
				.if eax
					add		esi,len
					call	GetWrd
				.endif
				mov		ecx,len
				.if ecx
					inc		ecx
					invoke strcpyn,offset buffer2,esi,ecx
					add		esi,len
					call	GetWrd
					.if ecx
						invoke SearchType,offset buffer2
						.if !eax
						  NxtLocal:
							call	GetWrd
							.if ecx
								inc		ecx
								invoke strcpyn,edi,esi,ecx
								add		edi,len
								add		esi,len
								call	GetArray
								mov		byte ptr [edi],':'
								inc		edi
								xor		ecx,ecx
								.while buffer2[ecx]
									mov		al,buffer2[ecx]
									.if al>='a' && al<='z'
										and		al,5Fh
									.endif
									mov		[edi],al
									inc		ecx
									inc		edi
								.endw
								mov		word ptr [edi],','
								inc		edi
								.if byte ptr [esi]==','
									inc		esi
									jmp		NxtLocal
								.endif
							.endif
						.endif
					.endif
				.endif
				.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
					inc		esi
				.endw
				.if byte ptr [esi]==VK_RETURN
					inc		esi
					.if byte ptr [esi]==0Ah
						inc		esi
					.endif
				.endif
			.endw
			.if byte ptr [edi-1]==','
				mov		dword ptr [edi-1],0
			.else
				mov		dword ptr [edi-1],0
				inc		edi
			.endif
			mov		esi,lpRet
			call	GetWrd
			.while esi<lpFun
				invoke strcpyn,edi,esi,addr [ecx+1]
				add		edi,len
				mov		byte ptr [edi],' '
				inc		edi
				add		esi,len
				call	GetWrd
			.endw
			.if byte ptr [edi-1]==' '
				dec		edi
			.endif
			mov		dword ptr [edi],0
			pop		esi
 			push	4
			push	offset buffer
			push	iNbr
			push	'p'
			mov		eax,lpAddProperty
			call	eax
			xor		ecx,ecx
			mov		edx,lpBegin
			inc		edx
			inc		ecx
			.while ecx
				.break .if !byte ptr [edx]
				.if byte ptr [edx]=='{'
					inc		ecx
				.elseif byte ptr [edx]=='}'
					dec		ecx
				.endif
				inc		edx
			.endw
			mov		lpEnd,edx
			mov		edi,offset buffer
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			mov		eax,lpBegin
			sub		eax,lpMem
			invoke BinToDec,eax,edi
			invoke strlen,edi
			lea		edi,[edi+eax]
			mov		byte ptr [edi],','
			inc		edi
			mov		eax,lpEnd
			sub		eax,lpMem
			invoke BinToDec,eax,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			mov		byte ptr [edi],','
 			push	2
			push	offset buffer
			push	iNbr
			push	'l'
			mov		eax,lpAddProperty
			call	eax
		.endif
		mov		eax,TRUE
		retn
	.endif
  @@:
	mov		esi,lpTemp
	call	GetWrd
	xor		eax,eax
	retn

_Unknown:
;PrintText "Unknown"
	; Datatype
	mov		ecx,len
	inc		ecx
	invoke strcpyn,offset buffer1,esi,ecx
	add		esi,len
	mov		lpTemp,esi
_Unknown1:
	.if byte ptr [esi]==VK_RETURN
		inc		esi
		.if byte ptr [esi]==0Ah
			inc		esi
		.endif
	.endif
	call	GetWrd
	.if ecx
		; Unknown (might be global data)
		; Name
		inc		ecx
		mov		edi,offset buffer
		invoke strcpyn,edi,esi,ecx
		add		esi,len
		add		edi,len
		call	SkipSpc
		.if byte ptr [esi]==VK_RETURN
			inc		esi
			.if byte ptr [esi]==0Ah
				inc		esi
			.endif
		.endif
		call	GetWrd
		mov		al,[esi]
		.if !ecx && al!='('
			call	GetArray
			mov		byte ptr [edi],':'
			inc		edi
			xor		ecx,ecx
			.while buffer1[ecx]
				mov		al,buffer1[ecx]
				.if al>='a' && al<='z'
					and		al,5Fh
				.endif
				mov		[edi],al
				inc		ecx
				inc		edi
			.endw
			mov		byte ptr [edi],0
			inc		edi
			invoke strcpy,edi,offset buffer1
			.if lpAddProperty
				push	2
				push	offset buffer
				push	iNbr
				push	'u'
				mov		eax,lpAddProperty
				call	eax
			.endif
			.if byte ptr [esi]=='='
				inc		esi
			.endif
			.if byte ptr [esi]=='"' || byte ptr [esi]=="'"
				call	SkipScope
			.endif
			.if byte ptr [esi]==','
				inc		esi
				jmp		_Unknown1
			.endif
		.endif
		.while byte ptr [esi]!=';' && byte ptr [esi]
			inc		esi
		.endw
		mov		eax,TRUE
		retn
	.endif
	mov		esi,lpTemp
	xor		eax,eax
	retn

SkipSpc:
	.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
		inc		esi
	.endw
	.if word ptr [esi]=='//'
		.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
			inc		esi
		.endw
	.elseif word ptr [esi]=='*/'
		.while word ptr [esi]!='/*' && byte ptr [esi]
			inc		esi
		.endw
		.if word ptr [esi]=='/*'
			inc		esi
			inc		esi
		.endif
	.endif
	.if byte ptr [esi]=='\'
		inc		esi
		.while byte ptr [esi]!=VK_RETURN && byte ptr [esi]
			inc		esi
		.endw
		.if byte ptr [esi]==VK_RETURN
			inc		esi
			.if byte ptr [esi]==0Ah
				inc		esi
			.endif
			jmp		SkipSpc
		.endif
	.endif
	retn

GetWrd:
	call	SkipSpc
	mov		edx,lpCharTab
	xor		ecx,ecx
	dec		ecx
  @@:
	inc		ecx
	movzx	eax,byte ptr [esi+ecx]
	cmp		byte ptr [eax+edx],1
	je		@b
	cmp		eax,'+'
	je		@b
	cmp		eax,'-'
	je		@b
	cmp		eax,'#'
	je		@b
	.if word ptr [esi+ecx]=='::'
		inc		ecx
		jmp		@b
	.endif
	mov		len,ecx
	retn

ParseFile endp

FindProcPos proc uses esi edi,lpMem:DWORD,lpPos:DWORD,lpCharTab:DWORD

	xor		eax,eax
	mov		lpFunSt,eax
	mov		lpFunEn,eax
	mov		eax,lpPos
	mov		lpFunPos,eax
	invoke ParseFile,0,lpMem,NULL,lpCharTab
	mov		esi,lpFunSt
	.if esi>lpMem
		.while byte ptr [esi-1]!=VK_RETURN && esi>lpMem
			dec		esi
		.endw
		mov		lpFunSt,esi
	.endif
	mov		eax,lpFunPos
	.if eax>=lpFunSt && eax<=lpFunEn
		mov		eax,lpFunSt
	.else
		xor		eax,eax
	.endif
	mov		lpFunPos,0
	ret

FindProcPos endp

FindLocal proc uses esi,hMem:DWORD,lpProcName:DWORD,lpMSt:DWORD,lpWord:DWORD,lpCharTab:DWORD

	mov		esi,lpData
	mov		esi,[esi].ADDINDATA.lpWordList
	.while [esi].PROPERTIES.nSize
		movzx	eax,[esi].PROPERTIES.nType
		.if eax=='p'
			call	Compare
			je		@f
		.endif
		mov		eax,[esi].PROPERTIES.nSize
		lea		esi,[esi+eax+sizeof PROPERTIES]
	.endw
  @@:
	lea		esi,[esi+sizeof PROPERTIES]
	invoke strlen,esi
	lea		esi,[esi+eax+1]
	invoke SearchMem,esi,lpWord,TRUE,TRUE,lpCharTab
	.if !eax
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		invoke SearchMem,esi,lpWord,TRUE,TRUE,lpCharTab
	.endif
	.if eax
		invoke SearchMem,hMem,lpWord,TRUE,TRUE,lpCharTab
	.endif
	ret

Compare:
	lea		edx,[esi+sizeof PROPERTIES]
	mov		ecx,lpProcName
  @@:
	mov		al,[ecx]
	mov		ah,[edx]
	inc		ecx
	inc		edx
	sub		al,ah
	jne		@f
	cmp		al,ah
	jne		@b
  @@:
	retn

FindLocal endp

InstallDll proc uses ebx,hWin:DWORD,fOpt:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax
	;Get pointer to procs struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProcs,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0
	mov		lpData,eax
	ret

InstallDll endp

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	.if reason==DLL_PROCESS_ATTACH
	.elseif reason==DLL_PROCESS_DETACH
	.endif
	mov     eax,TRUE
	ret

DllEntry Endp

End DllEntry
