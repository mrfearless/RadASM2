
.code

LoadFile proc lpFileName:DWORD
	LOCAL	fSH:DWORD
	LOCAL	hFile:DWORD
	LOCAL	FileSize:DWORD

	invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,addr fSH
		mov		FileSize,eax
		inc		eax
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov     hSrcMem,eax
		invoke GlobalLock,hSrcMem
		invoke ReadFile,hFile,hSrcMem,FileSize,addr fSH,NULL
		invoke CloseHandle,hFile
		mov		eax,FileSize
	.else
		mov		eax,0
	.endif
	ret

LoadFile endp

LoadEdit proc hEdt:HWND
	LOCAL	nChars:DWORD

	invoke SendMessage,hEdt,WM_GETTEXTLENGTH,0,0
	inc		eax
	mov		nChars,eax
	push	nChars
	inc		eax
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
	mov		hSrcMem,eax
	invoke GlobalLock,hSrcMem
	invoke SendMessage,hEdt,WM_GETTEXT,nChars,hSrcMem
	pop		eax
	ret

LoadEdit endp

SearchMem proc uses ebx ecx edx esi edi,hMem:DWORD,lpFind:DWORD,fMCase:DWORD,fWWord:DWORD,fWhiteSpage:DWORD
	LOCAL	pOld:DWORD
	LOCAL	prev:DWORD

	mov		cl,byte ptr fWWord
	mov		ch,byte ptr fMCase
	mov		edi,hMem
	dec		edi
	mov		pOld,edi
	mov		esi,lpFind
	mov		prev,1
  Nx:
	xor		edx,edx
	inc		pOld
	dec		edx
	mov		edi,pOld
  Mr:
	inc		edx
  Mr1:
	mov		al,[edi+edx]
	.if al==0Ah
		inc		edi
		mov		al,[edi+edx]
	.endif
	mov		ah,[esi+edx]
	.if fWhiteSpage
		.if (ah==VK_SPACE || ah==VK_TAB) && (al==VK_SPACE || al==VK_TAB)
			.while byte ptr [edi+edx]==VK_SPACE || byte ptr [edi+edx]==VK_TAB
				inc		edi
			.endw
			.while byte ptr [esi+edx]==VK_SPACE || byte ptr [esi+edx]==VK_TAB
				dec		edi
				inc		edx
			.endw
			jmp		Mr1
		.else
			movzx	ebx,ah
			add		ebx,lpCharTab
			movzx	ebx,byte ptr [ebx]
			.if (prev!=1 || ebx!=1) && (al==VK_SPACE || al==VK_TAB)
				;Ignore whitespace if this or previous was a non character
				mov		prev,ebx
				.while byte ptr [edi+edx]==VK_SPACE || byte ptr [edi+edx]==VK_TAB
					inc		edi
				.endw
				jmp		Mr1
			.endif
			mov		prev,ebx
		.endif
		.if al==VK_TAB
			mov		al,VK_SPACE
		.endif
	.endif
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

CheckLoadedEnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

    invoke GetWindowLong,hWin,GWL_ID
    .if eax>=ID_FIRSTCHILD && eax<=ID_LASTCHILD
		invoke GetWindowLong,hWin,0
		.if eax==ID_EDIT || eax==ID_EDITTXT
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke lstrcmpi,lParam,addr buffer
			.if !eax
				invoke GetWindowLong,hWin,GWL_USERDATA
				mov		hFound,eax
				xor		eax,eax
				ret
			.endif
		.endif
	.endif
	mov		eax,TRUE
	ret

CheckLoadedEnumProc endp

CheckLoadedDlgEnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

    invoke GetWindowLong,hWin,GWL_ID
    .if eax>=ID_FIRSTCHILD &&  eax<=ID_LASTCHILD
		invoke GetWindowLong,hWin,0
		.if eax==ID_DIALOG
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke lstrcmpi,lParam,addr buffer
			.if !eax
				mov		eax,hWin
				mov		hFound,eax
				mov		eax,FALSE
				ret
			.endif
		.endif
	.endif
	mov		eax,TRUE
	ret

CheckLoadedDlgEnumProc endp

SpcSkip proc

	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,09h
	je		@b
	cmp		al,' '
	je		@b
	ret

SpcSkip endp

LineSkip proc

	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	or		al,al
	je		@f
	cmp		al,0Dh
	jne		@b
	inc		esi
	mov		al,[esi]
	cmp		al,0Ah
	jne		@f
	inc		esi
  @@:
	ret

LineSkip endp

IsCodeFile proc uses esi,lpFileName:DWORD
	LOCAL	buffer[32]:BYTE

	mov		esi,lpFileName
	invoke strlen,esi
	mov		ecx,eax
	.while ecx
		dec		ecx
		.if byte ptr [esi+ecx]=='.'
			invoke strcpy,addr buffer,addr [esi+ecx]
			invoke strcat,addr buffer,addr szPoint
			invoke iniInStr,addr szCodeFiles,addr buffer
			inc		eax
			.break
		.endif
	.endw
	ret

IsCodeFile endp

Scan proc uses esi,FileNo:DWORD,fMCase:DWORD,fWWord:DWORD,fWhiteSpace:DWORD
	LOCAL	lpf:DWORD

	invoke GetFileNameFromID,FileNo
	.if eax
		mov		esi,eax
		invoke IsCodeFile,esi
		.if eax
			invoke strcpy,addr FileName,addr ProjectPath
			invoke strcat,addr FileName,esi
			invoke GetFullPathName,addr FileName,sizeof FileName,addr FileName,addr lpf
			mov		hFound,0
			invoke EnumChildWindows,hClient,addr CheckLoadedEnumProc,addr FileName
			mov		eax,hFound
			.if !eax
				invoke LoadFile,addr FileName
			.else
				invoke LoadEdit,hFound
			.endif
			.if eax
				invoke SearchMem,hSrcMem,addr FindBufferFixed,fMCase,fWWord,fWhiteSpace
				.if eax
					invoke ProjectOpenFile,TRUE
					mov		eax,TRUE
				.endif
			.endif
			push	eax
			.if hSrcMem
				invoke GlobalUnlock,hSrcMem
				invoke GlobalFree,hSrcMem
				mov		hSrcMem,0
			.endif
			pop		eax
		.else
			mov		eax,FALSE
		.endif
	.endif
	ret

Scan endp

GetMainFile proc lpFileExt:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	nMiss:DWORD
	LOCAL	iNbr:DWORD

	mov		word ptr buffer,'0'
   	invoke GetPrivateProfileString,addr iniMakeFile,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
	.if eax
		invoke strlen,addr buffer
		lea		eax,buffer[eax-3]
		invoke strcpy,eax,lpFileExt
		invoke strcpy,addr buffer1,addr ProjectPath
		invoke strcat,addr buffer1,addr buffer
		invoke strcpy,offset AltFileName,addr buffer1
		mov		nMiss,0
		mov		iNbr,PRO_START_FILE
		.while nMiss<PRO_MAX_MISS
			invoke GetFileNameFromID,iNbr
			.if eax
				mov		nMiss,0
				invoke lstrcmpi,addr buffer,eax
				.break .if !eax
			.else
				inc		nMiss
			.endif
			mov		eax,TRUE
			inc iNbr
		.endw
		.if eax
			xor		eax,eax
			xor		edx,edx
			mov		ecx,offset AltFileName
			ret
		.endif
		mov		hFound,0
		invoke EnumChildWindows,hClient,addr CheckLoadedEnumProc,addr buffer1
		.if !hFound
			invoke LoadFile,addr buffer1
		.else
			invoke LoadEdit,hFound
		.endif
		mov		eax,hSrcMem
		mov		ecx,offset AltFileName
		mov		edx,hFound
	.else
		invoke MessageBox,hWnd,0,addr AppName,MB_OK
		xor		eax,eax
		xor		ecx,ecx
		xor		edx,edx
	.endif
	ret

GetMainFile endp

ProFindCopyLine proc uses ecx esi edi,lpSrc:DWORD,lpDest:DWORD

	mov		esi,lpSrc
	mov		edi,lpDest
	dec		esi
	dec		edi
	xor		ecx,ecx
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	mov		[edi],al
	or		al,al
	je		@f
	inc		ecx
	cmp		al,0Dh
	jne		@b
	inc		esi
	mov		al,[esi]
	cmp		al,0Ah
	jne		@f
	inc		ecx
  @@:
	mov		al,0
	mov		[edi],al
	mov		eax,ecx
	ret

ProFindCopyLine endp

ProFind proc uses ebx esi edi,lpFind:DWORD
	LOCAL	buffer1[16]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	buffer3[512]:BYTE
	LOCAL	lpMSt:DWORD
	LOCAL	fMC:DWORD
	LOCAL	fWW:DWORD

	mov		ebx,lpFind
	assume ebx:ptr PROFIND
	mov		eax,[ebx].nFun
	.if eax==1
		.if hSrcMem
			invoke GlobalUnlock,hSrcMem
			invoke GlobalFree,hSrcMem
			mov		hSrcMem,0
		.endif
		mov		[ebx].hMem,0
	.elseif !eax
		;Scan file
		mov		[ebx].pLine,-1
		mov		eax,[ebx].hMem
		.if !eax
			call RDFile
		.endif
		.if eax
			call ScanFile
		.endif
	.endif
	ret

  RDFile:
	invoke GetFileNameFromID,[ebx].nFile
	.if eax
		mov		[ebx].nMiss,0
		invoke strcpy,addr buffer2,eax
		invoke GetFileImg,addr buffer2
		.if eax==2 || eax==3
			invoke strcpy,addr FileName,addr ProjectPath
			invoke strcat,addr FileName,addr buffer2
			invoke GetFullPathName,addr FileName,sizeof FileName,addr FileName,addr hFound
			mov		hFound,0
			invoke EnumChildWindows,hClient,addr CheckLoadedEnumProc,addr FileName
			.if !hFound
				invoke LoadFile,addr FileName
			.else
				invoke LoadEdit,hFound
			.endif
			mov		eax,hSrcMem
			mov		[ebx].hMem,eax
		.else
			mov		eax,FALSE
		.endif
	.else
		inc		[ebx].nMiss
	.endif
	retn

  GetFind:
	invoke iniGetItem,addr buffer3,addr buffer2
	mov		edx,TRUE
	mov		al,buffer2
	or		al,al
	je		GFEx
	invoke iniGetItem,addr buffer3,addr buffer1
	mov		edx,TRUE
	mov		al,buffer1
	or		al,al
	je		GFEx
	.if al=='0'
		mov		fMC,FALSE
		mov		fWW,FALSE
	.elseif al=='1'
		mov		fMC,TRUE
		mov		fWW,FALSE
	.elseif al=='2'
		mov		fMC,FALSE
		mov		fWW,TRUE
	.else
		mov		fMC,TRUE
		mov		fWW,TRUE
	.endif
	mov		edx,FALSE
  GFEx:
	mov		eax,edx
	retn

  ScanNot:
	push	ecx
	push	edx
	xor		edx,edx
	mov		ecx,esi
	.if [ebx].lpNot
		mov		edi,[ebx].lpNot
		dec		edi
	  SNNx:
		inc		edi
		mov		ah,[edi]
		or		ah,ah
		je		SNEx		;Char is not found
		mov		esi,ecx
	  SNNx1:
		dec		esi
		cmp		esi,[ebx].lpLine
		jl		SNNx
		mov		al,[esi]
		cmp		al,ah
		jne		SNNx1
		;Char is found
		inc		edx
	.endif
  SNEx:
	mov		esi,ecx
	mov		eax,edx
	pop		edx
	pop		ecx
	retn

  ScanFile:
	mov		eax,[ebx].hMem
	add		eax,[ebx].pFile
	mov		[ebx].pMem,eax
	mov		lpMSt,eax
	mov		[ebx].pLine,-1
  SFNx:
	m2m		[ebx].pMem,lpMSt
	invoke strcpy,addr buffer3,[ebx].lpFind
	mov		esi,[ebx].lpLine
	invoke ProFindCopyLine,lpMSt,esi
	or		eax,eax
	jne		@f
	mov		[ebx].pLine,-1
	jmp		SFEx				;Not found
  @@:
	add		lpMSt,eax
	add		[ebx].pFile,eax
  SFNx1:
	call GetFind
	or		eax,eax
	jne		SFEx				;Found
	dec		esi
	inc		esi
	mov		[ebx].pLine,-1
	invoke SearchMem,esi,addr buffer2,fMC,fWW,FALSE
	.if eax
		mov		esi,eax
		sub		eax,[ebx].lpLine
		mov		[ebx].pLine,eax
		call ScanNot
		or		eax,eax
		jne		SFNx
		jmp		SFNx1
	.endif
	jmp		SFNx
  SFEx:
	retn
	assume ebx:nothing

ProFind endp

ProScan proc lpFind:DWORD,lpNot:DWORD
	LOCAL	iNbr:DWORD
	LOCAL	pf:PROFIND
	LOCAL	chrg:CHARRANGE

	mov		iNbr,PRO_START_FILE
	m2m		pf.lpFind,lpFind
	m2m		pf.lpNot,lpNot
	mov		pf.lpLine,offset LineTxt
	mov		pf.nMiss,0
  Nx:
	mov		pf.nFun,0
	mov		pf.hMem,0
	m2m		pf.nFile,iNbr
	mov		pf.pFile,0
	mov		pf.pMem,0
	mov		pf.pLine,0
	invoke ProFind,addr pf
	;Free mem
	mov		pf.nFun,1
	invoke ProFind,addr pf
	.if pf.pLine==-1
		inc		iNbr
		.if pf.nMiss==PRO_MAX_MISS
			.if iNbr<PRO_START_OBJ
				mov		pf.nMiss,0
				mov		iNbr,PRO_START_OBJ
				jmp		Nx
			.endif
		.else
			jmp		Nx
		.endif
		;Not found
		mov		eax,FALSE
		ret
	.endif
	invoke GetFileNameFromID,iNbr
	push	eax
	invoke strcpy,addr FileName,addr ProjectPath
	pop		eax
	invoke strcat,addr FileName,eax
	invoke ProjectOpenFile,TRUE
	.if !hFound
		mov		pf.nFun,0
		mov		pf.hMem,0
		m2m		pf.nFile,iNbr
		mov		pf.pFile,0
		mov		pf.pMem,0
		mov		pf.pLine,0
		invoke ProFind,addr pf
		;Free mem
		mov		pf.nFun,1
		invoke ProFind,addr pf
	.endif
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,pf.pFile
	.if eax
		dec		eax
	.endif
	invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
	mov		chrg.cpMin,eax
	mov		chrg.cpMax,eax
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
	invoke VerticalCenter,hEdit,REM_VCENTER
	mov		eax,TRUE
	ret

ProScan endp

ProGetWord proc uses edx esi,lpWord:DWORD

	mov		esi,lpWord
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,' '
	je		@b
	cmp		al,VK_TAB
	je		@b
	cmp		al,':'
	je		@b
	mov		edx,esi
  @@:
	inc		esi
	movzx	eax,byte ptr [esi]
	add		eax,lpCharTab
	mov		al,[eax]
	dec		al
	je		@b
  @@:
	mov		al,0
	mov		[esi],al
	mov		eax,edx
	ret

ProGetWord endp

ScanWord proc uses esi,lpWord:DWORD,lpLine:DWORD
	LOCAL	buffer2[64]:BYTE
	LOCAL	nMiss:DWORD
	LOCAL	iNbr:DWORD
	LOCAL	hMem:DWORD
	LOCAL	lpMSt:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	fRet:DWORD
	LOCAL	fEdit:DWORD
	LOCAL	fTLink:DWORD
	LOCAL	val:DWORD
	LOCAL	fFirst:DWORD
	LOCAL	lPos:DWORD
	LOCAL	nInx:DWORD
	LOCAL	lpData:DWORD

	mov		fRet,FALSE
	mov		hMem,0
	mov		lpData,0
	mov		eax,-1
	.if lpLine
		invoke strcpy,addr buffer2,addr szCmntChar
		invoke strcat,addr buffer2,addr szSeeFind
		invoke iniInStr,lpLine,addr buffer2
	.endif
	mov		fTLink,FALSE
	.if eax!=-1
		mov		fTLink,TRUE
	.elseif hEdit
		.if !hParseDll
			mov		esi,offset tempbuff
			mov		eax,offset szCPCode
			call	GetDef
			.if byte ptr szCPCode2
				mov		eax,offset szCPCode2
				call	GetDef
			.endif
			mov		eax,offset szCPMacro
			call	GetDef
			mov		eax,offset szCPStruct
			call	GetDef
			.if byte ptr szCPStruct2
				mov		eax,offset szCPStruct2
				call	GetDef
			.endif
			mov		eax,offset szCPConst
			call	GetDef
			mov		eax,offset szCPLabel
			call	GetDef
			mov		eax,offset szCPLocal
			call	GetDef
			mov		lpData,esi
			mov		eax,offset szCPData
			call	GetDef
		.endif
		;Prepare label
		invoke strcpy,addr prnbuff,lpWord
		invoke strlen,addr prnbuff
		mov		word ptr prnbuff[eax],':'
		invoke LoadEdit,hEdit
		m2m		hMem,hSrcMem
		.if	!fProcInSBar
			invoke FindProcPos,hEdit
		.endif
		mov		eax,ProcPos
		.if eax
			add		eax,hMem
			mov		lpMSt,eax
			.if hParseDll
				invoke GetProcAddress,hParseDll,offset szFindLocal
				.if eax
					push	lpCharTab
					push	lpWord
					push	lpMSt
					push	offset szProcName
					push	hMem
					call	eax
					.if eax
						sub		eax,hMem
						mov		chrg.cpMin,eax
						mov		chrg.cpMax,eax
						invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
						xor		eax,eax
						inc		eax
						ret
					.endif
				.endif
			.else
				call	ScanTheFile
				.if eax
					mov		eax,lpMSt
					sub		eax,hMem
					mov		chrg.cpMin,eax
					mov		chrg.cpMax,eax
					invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
					xor		eax,eax
					inc		eax
					ret
				.endif
			.endif
		.endif
	.endif
	mov		lpData,0
	mov		nMiss,0
	mov		iNbr,PRO_START_FILE
	.if !fTLink && fProject
		call	TestAny
		.if eax
			mov		iNbr,eax
		.else
			jmp		Ex
		.endif
	.endif
  Strt:
	.if fProject
		invoke GetFileNameFromID,iNbr
		.if eax
			invoke strcpy,addr buffer2,eax
			mov		nMiss,0
			invoke GetFileImg,addr buffer2
			.if (eax==2 && !fTLink) || (eax==3 && !fTLink) || (eax==8 && fTLink)
				invoke strcpy,addr FileName,addr ProjectPath
				invoke strcat,addr FileName,addr buffer2
				invoke GetFullPathName,addr FileName,sizeof FileName,addr FileName,addr val
				mov		hFound,0
				invoke EnumChildWindows,hClient,addr CheckLoadedEnumProc,addr FileName
				.if !hFound
					invoke LoadFile,addr FileName
					mov		fEdit,FALSE
				.else
					invoke LoadEdit,hFound
					m2m		fEdit,hFound
				.endif
			.else
				xor		eax,eax
			.endif
		.else
			inc		nMiss
		.endif
	.else
		invoke GetWindowText,hMdiCld,addr FileName,sizeof FileName
		invoke LoadEdit,hEdit
		m2m		fEdit,hEdit
		mov		eax,TRUE
	.endif
	.if eax
		m2m		hMem,hSrcMem
		m2m		lpMSt,hSrcMem
		.if hParseDll && !fTLink
			invoke GetProcAddress,hParseDll,offset szFindInFile
			.if eax
				push	lpCharTab
				push	lpWord
				push	lpWord
				push	hSrcMem
				push	nInx
				call	eax
				.if eax==-1
					xor		eax,eax
				.else
					mov		lpMSt,edx
					mov		eax,TRUE
				.endif
			.else
				call	ScanTheFile
			.endif
		.else
			call	ScanTheFile
		.endif
		.if eax
			invoke ProjectOpenFile,TRUE
			.if !fEdit
				jmp		Strt
			.endif
			mov		eax,lpMSt
			sub		eax,hMem
			mov		chrg.cpMin,eax
			mov		chrg.cpMax,eax
			invoke SendMessage,fEdit,EM_EXSETSEL,0,addr chrg
			xor		eax,eax
			inc		eax
			mov		fRet,eax
		.endif
	.endif
	.if !eax && fProject && fTLink
		inc		iNbr
		.if nMiss==PRO_MAX_MISS
			.if iNbr<PRO_START_OBJ
				mov		nMiss,0
				mov		iNbr,PRO_START_OBJ
				jmp		Strt
			.endif
		.else
			jmp		Strt
		.endif
	.endif
	invoke SetFocus,hEdit
  Ex:
	mov		eax,fRet
	ret

GetDef:
	invoke strcpy,addr iniBuffer,eax
	invoke iniGetItem,addr iniBuffer,addr buffer2
  GetDef1:
	invoke iniGetItem,addr iniBuffer,addr buffer2
	.if buffer2
		lea		eax,buffer2
		.if word ptr [eax]==' $'
			add		eax,2
			mov		dl,TRUE
		.else
			invoke strlen,addr buffer2
			.if word ptr buffer2[eax-2]=='$ '
				mov		buffer2[eax-2],0
			.endif
			lea		eax,buffer2
			xor		dl,dl
		.endif
		mov		[esi],dl
		inc		esi
		invoke strcpy,esi,eax
		lea		esi,[esi+63]
		jmp		GetDef1
	.endif
	mov		dword ptr [esi],0
	retn

ScanTheFile:
	invoke DestroyCmntBlock,lpMSt
	dec		lpMSt
  Nx:
	inc		lpMSt
	invoke SearchMem,lpMSt,lpWord,TRUE,TRUE,FALSE
	.if eax
		mov		lpMSt,eax
		.if !fTLink
			mov		edx,eax
			mov		ecx,dword ptr szCmntChar
			.while edx>hSrcMem 
				.break .if byte ptr [edx-1]==0Dh || byte ptr [edx-1]==0Ah
				dec		edx
				.if (!ch && cl==byte ptr [edx]) || cx==word ptr [edx] || byte ptr [edx]=='"' || byte ptr [edx]=="'"
					jmp		Nx
				.endif
			.endw
			mov		eax,lpMSt
			sub		eax,edx
			mov		lPos,eax
			invoke ProFindCopyLine,edx,addr LineTxt
			.if nAsm==nBCET
				invoke SearchMem,offset LineTxt,offset szDeclare,FALSE,TRUE,FALSE
				or		eax,eax
				jne		Nx
			.endif
			mov		esi,offset tempbuff
			.while byte ptr [esi+1]
				call	TestLine
				or		eax,eax
				jne		@f
				add		esi,64
				.break .if esi==lpData
			.endw
			call	TestData
			or		eax,eax
			jne		@f
			jmp		Nx
		.endif
	.endif
  @@:
	push	eax
	invoke GlobalUnlock,hSrcMem
	invoke GlobalFree,hSrcMem
	mov		hSrcMem,0
	pop		eax
	retn

TestLine:
	movzx	eax,byte ptr [esi]
	mov		fFirst,eax
	lea		eax,[esi+1]
	.if word ptr [eax]==':'
		;Label
		invoke SearchMem,addr LineTxt,addr prnbuff,FALSE,FALSE,FALSE
		or		eax,eax
		je		@f
		inc		eax
		jmp		TestLine1
	.endif
	invoke SearchMem,addr LineTxt,eax,FALSE,TRUE,FALSE
	or		eax,eax
	je		@f
	.if eax>offset LineTxt
		mov		dl,[eax-1]
		.if dl!=' ' && dl!=VK_TAB && dl!=','
			xor		eax,eax
			retn
		.endif
	.endif
  TestLine1:
	mov		edx,eax
	sub		edx,offset LineTxt
	.if (fFirst && edx<=lPos) || (!fFirst && edx>=lPos)
		xor		eax,eax
	.endif
  @@:
	retn

Compare:
	push	ecx
	push	edx
	mov		ecx,lpWord
	lea		edx,[edx+sizeof PROPERTIES]
	.while TRUE
		mov		al,[ecx]
		mov		ah,[edx]
		.if !al && (ah=='[' || ah==':' || !ah)
			mov		eax,TRUE
			jmp		@f
		.endif
		.if al!=ah
			.break
		.endif
		inc		ecx
		inc		edx
	.endw
	xor		eax,eax
  @@:
	pop		edx
	pop		ecx
	retn

TestData:
	mov		edx,lpWordList
	.while [edx].PROPERTIES.nSize
		.if [edx].PROPERTIES.nType=='d'
			mov		eax,[edx].PROPERTIES.Owner
			.if eax==iNbr
				call	Compare
				.if eax
					mov		nInx,1
					retn
				.endif
			.endif
		.endif
		mov		eax,[edx].PROPERTIES.nSize
		lea		edx,[edx+eax+sizeof PROPERTIES]
	.endw
	xor		eax,eax
	retn

TestAny:
	mov		edx,lpWordList
	add		edx,rpProjectWordList
	.while [edx].PROPERTIES.nSize
		call	Compare
		.if eax
			movzx	eax,[edx].PROPERTIES.nType
			.if eax=='p'
				mov		nInx,0
			.elseif eax=='c'
				mov		nInx,1
			.elseif eax=='d'
				mov		nInx,2
			.elseif eax=='m'
				mov		nInx,3
			.elseif eax=='l'
				mov		nInx,4
			.elseif eax=='s'
				mov		nInx,5
			.elseif eax==10
				mov		nInx,6
			.elseif eax==11
				mov		nInx,7
			.endif
			mov		eax,[edx].PROPERTIES.Owner
			retn
		.endif
		mov		eax,[edx].PROPERTIES.nSize
		lea		edx,[edx+eax+sizeof PROPERTIES]
	.endw
	xor		eax,eax
	retn

ScanWord endp

FindLineNo proc uses esi edx,lpMEn:DWORD

	xor		edx,edx
	mov		esi,hSrcMem
  Nx:
	mov		al,[esi]
	cmp		al,0Dh
	jne		@f
	inc		edx
  @@:
	inc		esi
	cmp		esi,lpMEn
	jl		Nx
	mov		eax,edx
	ret

FindLineNo endp

ScanProject proc uses ebx,lpWord:DWORD
	LOCAL	buffer2[256]:BYTE
	LOCAL	nMiss:DWORD
	LOCAL	iNbr:DWORD
	LOCAL	lpMSt:DWORD

	invoke OutputSelect,1
	invoke OutputClear
	invoke strcpy,addr buffer2,offset szScanning
	invoke strcat,addr buffer2,lpWord
	invoke TextToOutput,addr buffer2
	invoke TextToOutput,offset szNULL
	mov		nMiss,0
	mov		iNbr,PRO_START_FILE
  Strt:
	.if fProject
		invoke GetFileNameFromID,iNbr
		.if eax
			invoke strcpy,addr buffer2,eax
			mov		nMiss,0
			invoke GetFileImg,addr buffer2
			.if eax==2 || eax==3
				invoke strcpy,addr FileName,addr ProjectPath
				invoke strcat,addr FileName,addr buffer2
				mov		hFound,0
				invoke EnumChildWindows,hClient,addr CheckLoadedEnumProc,addr FileName
				.if !hFound
					invoke LoadFile,addr FileName
				.else
					invoke LoadEdit,hFound
				.endif
				mov		eax,hSrcMem
				.if eax
					mov		lpMSt,eax
					.while TRUE
						invoke SearchMem,lpMSt,lpWord,TRUE,TRUE,FALSE
					  .break .if !eax
						mov		lpMSt,eax
						invoke strcpy,offset LineTxt,addr buffer2
						mov		ebx,offset LineTxt
						invoke strlen,ebx
						add		ebx,eax
						mov		byte ptr [ebx],'('
						inc		ebx
						invoke FindLineNo,lpMSt
						inc		eax
						invoke BinToDec,eax,ebx
						invoke strlen,ebx
						add		ebx,eax
						mov		word ptr [ebx],')'
						inc		lpMSt
						invoke TextToOutput,offset LineTxt
						mov		AsmFlag,TRUE
					.endw
					invoke GlobalUnlock,hSrcMem
					invoke GlobalFree,hSrcMem
					mov		hSrcMem,0
				.endif
			.endif
		.else
			inc		nMiss
		.endif
		inc		iNbr
		.if nMiss>=PRO_MAX_MISS
			.if iNbr<PRO_START_OBJ
				mov		nMiss,0
				mov		iNbr,PRO_START_OBJ
				jmp		Strt
			.endif
		.else
			jmp		Strt
		.endif
	.endif
	ret

ScanProject endp

SetPropertyCbo proc nSel:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[16]:BYTE
	LOCAL	nInx:DWORD

	invoke ShowWindow,hPrpTxtMulti,SW_HIDE
	invoke ShowWindow,hPrpTxt,SW_HIDE
	invoke ShowWindow,hTxtBtn,SW_HIDE
	invoke ShowWindow,hTxtLst,SW_HIDE
	invoke strcpy,addr buffer,addr PrpCboItems
  @@:
	invoke iniGetItem,addr buffer,addr buffer1
	mov		al,buffer1[0]
	.if al
		invoke SendMessage,hPrpCboCode,CB_ADDSTRING,0,addr buffer1
		mov		nInx,eax
		invoke iniGetItem,addr buffer,addr buffer1
		invoke DecToBin,addr buffer1
		invoke SendMessage,hPrpCboCode,CB_SETITEMDATA,nInx,eax
		jmp		@b
	.endif
	invoke SendMessage,hPrpCboCode,CB_SETCURSEL,nSel,0
	ret

SetPropertyCbo endp

CopyWord proc

  @@:
	mov		al,[esi]
	cmp		al,' '
	je		@f
	cmp		al,09h
	je		@f
	cmp		al,0Dh
	je		@f
	cmp		al,0Ah
	je		@f
	cmp		al,','
	je		@f
	cmp		al,';'
	je		@f
	cmp		al,'('
	je		@f
	.if nAsm==nHLA || nAsm==nFP
		cmp		al,':'
		je		@f
	.endif
	cmp		al,'"'
	je		@f
	cmp		al,"'"
	je		@f
	cmp		al,00h
	je		@f
	mov		[edi],al
	inc		esi
	inc		edi
	jmp		@b
  @@:
	ret

CopyWord endp

CopyStr proc

  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	mov		al,[esi]
	cmp		al,ah
	je		@f
	cmp		al,0Dh
	je		@f
	cmp		al,00h
	jne		@b
  @@:
	cmp		al,ah
	jne		@f
	inc		esi
  @@:
	mov		[edi],ah
	inc		edi
	ret

CopyStr endp

GetFileMem proc lpFileName:DWORD

	invoke strcpy,addr FileName,lpFileName
	mov		hFound,0
	invoke EnumChildWindows,hClient,addr CheckLoadedEnumProc,addr FileName
	mov		eax,hFound
	.if eax
		invoke LoadEdit,hFound
	.else
		invoke LoadFile,addr FileName
	.endif
	ret

GetFileMem endp

SetPropList proc uses ebx esi edi,nTpe:DWORD,iNbr:DWORD

	mov		eax,nTpe
	.if !eax
		mov		ebx,'p'
	.elseif eax==1
		mov		ebx,'c'
	.elseif eax==2
		mov		ebx,'d'
	.elseif eax==3
		mov		ebx,'m'
	.elseif eax==4
		mov		ebx,'l'
	.elseif eax==5
		mov		ebx,'s'
	.elseif eax>=10
		mov		ebx,eax
	.endif
	mov		esi,lpWordList
	add		esi,rpProjectWordList
	.if iNbr
		.while [esi].PROPERTIES.nSize
			mov		eax,iNbr
			.if bl==[esi].PROPERTIES.nType && eax==[esi].PROPERTIES.Owner
				invoke SendMessage,hPrpLstCode,LB_ADDSTRING,0,addr [esi+sizeof PROPERTIES]
				mov		edx,esi
				sub		edx,lpWordList
				invoke SendMessage,hPrpLstCode,LB_SETITEMDATA,eax,edx
			.endif
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
	.else
		;All files
		.while [esi].PROPERTIES.nSize
			.if bl==[esi].PROPERTIES.nType
				invoke SendMessage,hPrpLstCode,LB_ADDSTRING,0,addr [esi+sizeof PROPERTIES]
				mov		edx,esi
				sub		edx,lpWordList
				invoke SendMessage,hPrpLstCode,LB_SETITEMDATA,eax,edx
			.endif
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
	.endif
  Ex:
	ret

SetPropList endp

SetWordList proc lpFileName:DWORD,iNbr:DWORD

	.if ApiWordLocal
		invoke GetFileMem,lpFileName
		.if eax
			invoke ParseFile,iNbr
		.endif
		invoke GlobalUnlock,hSrcMem
		invoke GlobalFree,hSrcMem
		mov		hSrcMem,0
	.endif
	ret

SetWordList endp

SetOpenProperty proc hWin:HWND,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	iNbr:DWORD

    invoke GetWindowLong,hWin,GWL_ID
    .if eax>=ID_FIRSTCHILD &&  eax<=ID_LASTCHILD
		invoke GetWindowLong,hWin,0
		.if eax==ID_EDIT
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke GetFileImg,addr buffer
			.if eax==2 || eax==3
				invoke GetWindowLong,hWin,16
				.if !eax
					mov		eax,hWin
					neg		eax
				.endif
				mov		iNbr,eax
				.if lParam==-1
					invoke GetWindowLong,hWin,12
					.if eax
						invoke DeleteProperties,iNbr
						invoke SetWordList,addr buffer,iNbr
						;Reset changed since last property update
						invoke SetWindowLong,hWin,12,FALSE
						inc		nUpdated
					.endif
				.elseif lParam==-2
					invoke SetWindowLong,hWin,12,TRUE
				.else
					invoke SetPropList,lParam,iNbr
				.endif
			.endif
		.endif
	.endif
	mov		eax,TRUE
 	ret

SetOpenProperty endp

RefreshProperty proc uses ebx esi
	LOCAL	buffer[256]:BYTE

	mov		nUpdated,0
	invoke GetCursor
	push	eax
	invoke LoadCursor,0,IDC_WAIT
	invoke SetCursor,eax
	mov		eax,rpProjectWordList
	mov		rpWordListPos,eax
	add		eax,lpWordList
	mov		[eax].PROPERTIES.nSize,0
	.if fProject
		;All project files
		mov		esi,hMemPro
		.while byte ptr [esi]
			invoke DecToBin,esi
			mov		ebx,eax
			.while byte ptr [esi]!='='
				inc		esi
			.endw
			inc		esi
			.if byte ptr [esi] && eax
				invoke GetFileImg,esi
				.if eax==2 || eax==3
					invoke strcpy,addr buffer,offset ProjectPath
					invoke strcat,addr buffer,esi
					invoke SetWordList,addr buffer,ebx
					inc		nUpdated
				.endif
			.endif
			invoke strlen,esi
			add		esi,eax
			inc		esi
		.endw
	.else
		;All open files
		invoke EnumChildWindows,hClient,addr SetOpenProperty,-1
	.endif
	.if nUpdated
		invoke FixUnknown
		invoke CompactWordList
	.endif
	pop		eax
	invoke SetCursor,eax
	ret

RefreshProperty endp

SetProperty proc nTpe:DWORD,nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	tvi:TV_ITEMEX
	LOCAL	iNbr:DWORD

	invoke SendMessage,hPrpTbrCode,TB_CHECKBUTTON,fProperty,TRUE
	.if ShowProperties
		invoke GetCursor
		push	eax
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke SendMessage,hPrpLstCode,WM_SETREDRAW,FALSE,0
		invoke SendMessage,hPrpLstCode,LB_GETCURSEL,0,0
		push	eax
		invoke SendMessage,hPrpLstCode,LB_GETTOPINDEX,0,0
		push	eax
		invoke SendMessage,hPrpLstCode,LB_RESETCONTENT,0,0
		invoke SendMessage,hPrpLstCode,LB_SETITEMHEIGHT,0,lbHt
		invoke SendMessage,hPrpCboCode,CB_RESETCONTENT,0,0
		invoke SetPropertyCbo,nInx
		.if fProperty==1
			;Single open file
			.if hEdit
				invoke GetWindowText,hMdiCld,addr buffer,sizeof buffer
				invoke GetFileImg,addr buffer
				.if eax==2 || eax==3
					invoke GetWindowLong,hMdiCld,16
					.if !eax
						mov		eax,hMdiCld
						neg		eax
					.endif
					mov		iNbr,eax
					invoke SetPropList,nTpe,iNbr
				.endif
			.endif
		.elseif fProperty==2
			;All open files
			invoke EnumChildWindows,hClient,addr SetOpenProperty,nInx
		.elseif fProperty==3 && fProject
			;Selected project file
			invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_CARET,hPbrTrv
			.if eax
				mov		tvi.hItem,eax
				mov		tvi.imask,TVIF_PARAM or TVIF_TEXT
				lea		eax,buffer2
				mov		tvi.pszText,eax
				mov		tvi.cchTextMax,sizeof buffer2
				invoke SendMessage,hPbrTrv,TVM_GETITEM,0,addr tvi
				.if tvi.lParam
					invoke GetFileImg,addr buffer2
					.if eax==2 || eax==3
						invoke SetPropList,nTpe,tvi.lParam
					.endif
				.endif
			.endif
		.elseif fProperty==4 && fProject
			;All project files
			invoke SetPropList,nTpe,0
		.endif
		pop		eax
		invoke SendMessage,hPrpLstCode,LB_SETTOPINDEX,eax,0
		pop		eax
		invoke SendMessage,hPrpLstCode,LB_SETCURSEL,eax,0
		invoke SendMessage,hPrpLstCode,WM_SETREDRAW,TRUE,0
		pop		eax
		invoke SetCursor,eax
	.endif
	ret

SetProperty endp

FindCodeName proc uses esi edi,lpSrc:DWORD,lpName:DWORD,lpMSt:DWORD,nInx:DWORD
	LOCAL	mSt:DWORD
	LOCAL	buffer[64]:BYTE

	mov		eax,lpMSt
	mov		mSt,eax
  Nx:
	mov		eax,lpSrc
	.if word ptr [eax]==' $'
		;$-
		add		eax,2
	.else
		;-$
		mov		esi,lpSrc
		lea		edi,buffer
	  @@:
		mov		al,[esi]
		.if al==' '
			mov		al,0
		.endif
		mov		[edi],al
		inc		esi
		inc		edi
		or		al,al
		jne		@b
		lea		eax,buffer
	.endif
	.if word ptr [eax]==':' || word ptr [eax]=='=:'
		invoke SearchMem,lpMSt,eax,FALSE,FALSE,FALSE
	.else
		invoke SearchMem,lpMSt,eax,FALSE,TRUE,FALSE
	.endif
	.if eax
		inc		eax
		mov		esi,lpMSt
		mov		lpMSt,eax
		dec		eax
		.while eax>esi && byte ptr [eax]!=0Dh
			dec		eax
		.endw
		.if byte ptr [eax]==0Dh
			inc		eax
		.endif
		mov		edx,offset prnbuff
		.while byte ptr [eax] && byte ptr [eax]!=0Dh
			mov		cl,[eax]
			.if eax<lpMSt
				.if cl==';' || cl=='"' || cl=="'"
					jmp		Nx
				.endif
			.endif
			mov		[edx],cl
			inc		eax
			inc		edx
		.endw
		mov		byte ptr [edx],0
		.if nAsm==nBCET && nInx==0
			invoke SearchMem,offset prnbuff,offset szDeclare,FALSE,TRUE,FALSE
			or		eax,eax
			jne		Nx
		.endif
		invoke SearchMem,offset prnbuff,lpName,TRUE,TRUE,FALSE
		or		eax,eax
		je		Nx
		invoke FindLineNo,lpMSt
		ret
	.endif
	mov		eax,-1
	ret

FindCodeName endp

;Double click in property listbox
FindPropList proc hWin:HWND,lpFind1:DWORD,lpFind2:DWORD
	LOCAL	nInx:DWORD
	LOCAL	nLine:DWORD
	LOCAL	buffer[256]:BYTE

	mov		nLine,-1
	invoke SendMessage,hPrpCboCode,CB_GETCURSEL,0,0
	mov		nInx,eax
	.if eax==CB_ERR
		invoke MessageBox,hWnd,CTEXT("Combo error"),addr AppName,MB_OK
		ret
	.endif
	invoke SendMessage,hPrpCboCode,CB_GETITEMDATA,nInx,0
	mov		nInx,eax
	invoke LoadEdit,hWin
	.if hParseDll
		invoke GetProcAddress,hParseDll,offset szFindInFile
		.if eax
			push	lpCharTab
			push	lpFind2
			push	lpFind1
			push	hSrcMem
			push	nInx
			call	eax
			mov		nLine,eax
		.endif
	.else
		.if nInx==0
			invoke strcpy,addr buffer,addr szCPCode
			call	TestIt
			.if nLine!=-1 || !byte ptr szCPCode2
				jmp		Ex
			.endif
			invoke strcpy,addr buffer,addr szCPCode2
		.elseif nInx==1
			invoke strcpy,addr buffer,addr szCPConst
		.elseif nInx==2
			invoke strcpy,addr buffer,addr szCPData
		.elseif nInx==3
			invoke strcpy,addr buffer,addr szCPMacro
		.elseif nInx==4
			invoke strcpy,addr buffer,addr szCPLabel
		.elseif nInx==5
			invoke strcpy,addr buffer,addr szCPStruct
			call	TestIt
			.if nLine!=-1 || !byte ptr szCPStruct2
				jmp		Ex
			.endif
			invoke strcpy,addr buffer,addr szCPStruct2
		.elseif nInx==10
			invoke strcpy,addr buffer,addr szCP0
		.elseif nInx==11
			invoke strcpy,addr buffer,addr szCP1
		.elseif nInx==12
			invoke strcpy,addr buffer,addr szCP2
		.elseif nInx==13
			invoke strcpy,addr buffer,addr szCP3
		.endif
		call	TestIt
	.endif
  Ex:
	invoke GlobalUnlock,hSrcMem
	invoke GlobalFree,hSrcMem
	mov		hSrcMem,0
	mov		eax,nLine
	ret

TestIt:
	invoke iniGetItem,addr buffer,addr szSrcEnd
  @@:
	invoke iniGetItem,addr buffer,addr szSrc
	.if byte ptr szSrc
		invoke FindCodeName,addr szSrc,lpFind1,hSrcMem,nInx
		mov		nLine,eax
		inc		eax
		je		@b
	.elseif nInx==2
		mov		word ptr buffer,' $'
		mov		ecx,lpFind2
		lea		edx,buffer[2]
	  @@:
		mov		al,[ecx]
		.if al==':' || al==' ' || al==','
			xor		al,al
		.endif
		mov		[edx],al
		inc		ecx
		inc		edx
		or		al,al
		jne		@b
		invoke FindCodeName,addr buffer,lpFind1,hSrcMem,nInx
		mov		nLine,eax
	.endif
	retn

FindPropList endp

