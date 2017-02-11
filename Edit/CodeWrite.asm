
.data

iniCodeMacro	db 'CodeMacro',0

.data?

MAC struct
	lpWord		dd ?
	lpBefore	dd ?
	lpAfter		dd ?
MAC ends

fCodeMacro		dd ?
szCodeLine		db 8192 dup(?)
MacPtr			dd 257 dup(?)
MacData			dd 4096 dup(?)

.code

FixMac proc uses esi edi,lpMacro:DWORD

	mov		esi,lpMacro
	mov		edi,lpMacro
	dec		esi
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		eax,dword ptr [esi]
	and		eax,0FFFFFFh
	.if eax=='}C{'
		mov		al,0Dh
		add		esi,2
	.elseif eax=='}S{'
		mov		al,' '
		add		esi,2
	.elseif eax=='}T{'
		mov		al,09h
		add		esi,2
	.elseif eax=='}I{'
		mov		al,01h
		add		esi,2
	.elseif eax=='}${'
		mov		al,02h
		add		esi,2
	.endif
	mov		[edi],al
	or		al,al
	jne		@b
	ret

FixMac endp

InitMac proc uses edi
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[16]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	lpMacPtr:DWORD
	LOCAL	lpMacData:DWORD

	invoke RtlZeroMemory,addr MacData,sizeof MacData
	invoke RtlZeroMemory,addr MacPtr,sizeof MacPtr
	mov		eax,offset MacPtr
	mov		lpMacPtr,eax
	mov		eax,offset MacData
	mov		lpMacData,eax
	mov		nInx,1
	.while nInx<256
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniCodeMacro,addr buffer1,addr szNULL,addr buffer,256,addr iniAsmFile
		.if eax
			mov		edi,lpMacPtr
			mov		eax,lpMacData
			mov		[edi],eax
			mov		edi,eax
			add		lpMacPtr,4
			add		lpMacData,sizeof MAC
			invoke iniGetItem,addr buffer,addr buffer2
			invoke strcpy,lpMacData,addr buffer2
			mov		eax,lpMacData
			mov		(MAC ptr [edi]).lpWord,eax
			invoke strlen,addr buffer2
			inc		eax
			add		lpMacData,eax
			invoke iniGetItem,addr buffer,addr buffer2
			invoke FixMac,addr buffer2
			invoke strcpy,lpMacData,addr buffer2
			mov		eax,lpMacData
			mov		(MAC ptr [edi]).lpBefore,eax
			invoke strlen,addr buffer2
			inc		eax
			add		lpMacData,eax
			invoke iniGetItem,addr buffer,addr buffer2
			invoke FixMac,addr buffer2
			invoke strcpy,lpMacData,addr buffer2
			mov		eax,lpMacData
			mov		(MAC ptr [edi]).lpAfter,eax
			invoke strlen,addr buffer2
			inc		eax
			add		lpMacData,eax
		.endif
		inc		nInx
	.endw
	ret

InitMac endp

CodeLine proc hWin:HWND,nLn:DWORD

	mov		szCodeLine,0
	.if CodeWriteMacro
		mov		word ptr szCodeLine,sizeof szCodeLine-1
		invoke SendMessage,hWin,EM_GETLINE,nLn,offset szCodeLine
		mov		byte ptr szCodeLine[eax],0
	.endif
	ret

CodeLine endp

CodeMacro proc uses ebx esi edi,hWin:HWND,nLn:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	lpMacPtr:DWORD

	.if CodeWriteMacro
		mov		eax,offset MacPtr
		mov		lpMacPtr,eax
		mov		esi,offset szCodeLine
		dec		esi
	  @@:
		inc		esi
		mov		al,[esi]
		cmp		al,09h
		je		@b
		cmp		al,20h
		je		@b
		.if !al
			invoke CodeLine,hWin,nLn
			.while TRUE
				mov		edx,lpMacPtr
				mov		edx,[edx]
			  .break .if !edx
				mov		edx,[edx].MAC.lpWord
				.if word ptr [edx]==' $'
					add		edx,2
				.endif
				invoke SearchMem,addr szCodeLine,edx,FALSE,TRUE,FALSE
				.if eax
					push	eax
					invoke SendMessage,hWin,EM_LINEINDEX,nLn,0
					pop		edx
					sub		edx,offset szCodeLine
					add		edx,eax
					invoke SendMessage,hWin,REM_ISCHARPOS,edx,0
					.if !eax
						call	MacGetIndent
						call	MacGetName
						mov		edx,lpMacPtr
						mov		edx,[edx]
						mov		ebx,[edx].MAC.lpAfter
						call	MacDoMac
						invoke SendMessage,hWin,REM_LOCKUNDOID,TRUE,0
						invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
						invoke SendMessage,hWin,EM_REPLACESEL,TRUE,addr buffer
						invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
						mov		edx,lpMacPtr
						mov		edx,[edx]
						mov		ebx,[edx].MAC.lpBefore
						call	MacDoMac
						invoke SendMessage,hWin,EM_REPLACESEL,TRUE,addr buffer
						invoke SendMessage,hWin,REM_LOCKUNDOID,FALSE,0
					  .break
					.endif
				.endif
				add		lpMacPtr,4
			.endw
		.endif
	.endif
	ret

MacDoMac:
	lea		edi,buffer
	dec		ebx
  Nx:
	inc		ebx
	mov		al,[ebx]
	;Indent
	lea		esi,buffer1
	.if al==02h
		;Name
		lea		esi,buffer2
		mov		al,01h
	.endif
	.if al==01h
		dec		esi
		dec		edi
	  @@:
		inc		esi
		inc		edi
		mov		al,[esi]
		mov		[edi],al
		or		al,al
		jne		@b
		jmp		Nx
	.endif
	.if al==VK_TAB && TabToSpc
		mov		ecx,TabSize
		mov		al,' '
		dec		ecx
		rep stosb
	.endif
	mov		[edi],al
	inc		edi
	or		al,al
	jne		Nx
	retn

MacGetIndent:
	mov		esi,offset szCodeLine
	;Get Indent
	lea		edi,buffer1
	dec		esi
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	mov		[edi],al
	cmp		al,09h
	je		@b
	cmp		al,20h
	je		@b
	mov		al,0
	mov		[edi],al
	retn

MacGetName:
	;Get Name
	mov		edx,lpMacPtr
	mov		edx,[edx]
	mov		edx,[edx].MAC.lpWord
	lea		edi,buffer2
	dec		esi
	dec		edi
	mov		ax,word ptr [edx]
	.if ax!=' $'
	  @@:
		inc		esi
		mov		al,[esi]
		.if al!=' ' && al!=VK_TAB && al
			jmp		@b
		.endif
		dec		esi
	  @@:
		inc		esi
		mov		al,[esi]
		.if al==' ' || al==VK_TAB
			jmp		@b
		.endif
		dec		esi
	.endif
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	mov		[edi],al
	cmp		al,09h
	je		@f
	cmp		al,20h
	je		@f
	or		al,al
	jne		@b
  @@:
	mov		al,0
	mov		[edi],al
	retn

CodeMacro endp
