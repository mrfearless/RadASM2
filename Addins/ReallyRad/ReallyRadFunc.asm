.code

BinToDec proc val:DWORD,lpBuff:DWORD

	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		edi,lpBuff
	mov		esi,offset binDecade
	mov		eax,val
	.if eax>80000000h
		neg		eax
		mov		byte ptr [edi],'-'
		inc		edi
	.endif
	xor		edx,edx
	mov		ecx,9
  BinToDec1:
	mov		bl,2fh
  @@:
	inc		bl
	sub		eax,dword ptr [esi]
	jnb		@b
	add		eax,dword ptr [esi]
	mov		[edi],bl
	add		esi,4
	cmp		bl,30h
	jz		@f
	mov		edx,1
  @@:
	add		edi,edx
	loop	BinToDec1
	add		al,30h
	mov		[edi],ax
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	pop		ebx
	ret

BinToDec endp

AddResFolder proc
	LOCAL	buffer[256]:BYTE

	.if fAddFolder
		mov		eax,[lpDStruct]
		mov		eax,[eax].ADDINDATA.lpProjectPath
		invoke lstrcpy,addr buffer,eax
		invoke lstrlen,addr buffer
		mov		dword ptr buffer[eax],'seR'
		invoke CreateDirectory,addr buffer,NULL
	.endif
	ret

AddResFolder endp

AddProjectFile proc lpFile:DWORD

	.if fAddFile && lpFile
		invoke GetFileAttributes,lpFile
		.if eax==-1
			invoke CreateFile,lpFile,GENERIC_READ,FILE_SHARE_READ,NULL,CREATE_NEW,FILE_ATTRIBUTE_NORMAL,NULL
			invoke CloseHandle,eax
		.endif
		push	FALSE
		push	TRUE
		push	lpFile
		mov		eax,[lpPStruct]
		call	[eax].ADDINPROCS.lpAddProjectFile
	.endif
	ret

AddProjectFile endp

FindCommand proc lpCmnd:DWORD,fID:DWORD
	LOCAL	buffer[256]:BYTE

;	mov		word ptr buffer,'=='
;	mov		dword ptr buffer[2],',0,'
	mov		byte ptr buffer,'='
	mov		dword ptr buffer[1],',0,'
	invoke lstrcat,addr buffer,lpCmnd
	invoke lstrlen,addr buffer
	.if fID
		mov		edx,'2,'					;Whole Word
	.else
		mov		edx,'3,'					;Whole Word & Match Case
	.endif
	mov		dword ptr buffer[eax],edx
	push	offset szNot
	lea		eax,buffer
	push	eax
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpProScan
	or		eax,eax
	jne		@f
	mov		dword ptr buffer,'pmc'
	mov		dword ptr buffer[3],',2,'		;Whole Word
	invoke lstrcat,addr buffer,lpCmnd
	invoke lstrlen,addr buffer
	.if fID
		mov		edx,'2,'					;Whole Word
	.else
		mov		edx,'3,'					;Whole Word & Match Case
	.endif
	mov		dword ptr buffer[eax],edx
	push	offset szNot
	lea		eax,buffer
	push	eax
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpProScan
	or		eax,eax
	jne		@f
	invoke lstrcpy,addr buffer,lpCmnd
	invoke lstrlen,addr buffer
	.if fID
		mov		edx,'2,'					;Whole Word
	.else
		mov		edx,'3,'					;Whole Word & Match Case
	.endif
	mov		dword ptr buffer[eax],edx
	push	offset szNULL
	lea		eax,buffer
	push	eax
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpProScan
  @@:
	ret

FindCommand endp

IncludeFile proc uses ebx esi,lpStr:DWORD,fAtTop:DWORD
	LOCAL	hMem:DWORD
	LOCAL	hMem1:DWORD
	LOCAL	lpFile:DWORD
	LOCAL	hWin:HWND
	LOCAL	lpMSt:DWORD
	LOCAL	hFile:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	fFound:DWORD

	invoke AddResFolder
	mov		fFound,FALSE
	mov		ebx,[lpPStruct]
	push	offset szRC
	call	[ebx].ADDINPROCS.lpGetMainFile
	.if !eax
		invoke AddProjectFile,ecx
		push	offset szRC
		call	[ebx].ADDINPROCS.lpGetMainFile
	.endif
	.if eax
		mov		hMem1,eax
		mov		lpMSt,eax
		mov		lpFile,ecx
		mov		hWin,edx
		mov		esi,lpStr
		add		esi,2
		invoke lstrlen,esi
		lea		esi,[esi+eax-2]
		mov		byte ptr [esi],0
		push	TRUE
		push	FALSE
		mov		eax,lpStr
		add		eax,2
		push	eax
		push	lpMSt
		call	[ebx].ADDINPROCS.lpSearchMem
		mov		byte ptr [esi],0Dh
		or		eax,eax
		jne		Ex
	  Nx:
		push	TRUE
		push	FALSE
		push	offset szInc
		push	lpMSt
		call	[ebx].ADDINPROCS.lpSearchMem
		.if eax
			mov		fFound,TRUE
			mov		lpMSt,eax
			.if !fAtTop
				inc		eax
				mov		lpMSt,eax
				jmp		Nx
			.endif
		.endif
		mov		esi,lpMSt
		.if hWin
			.if fFound && !fAtTop
				mov		al,[esi]
				.while al && al!=0Dh
					inc		esi
					mov		al,[esi]
				.endw
				.if al
					inc		esi
					add		lpStr,2
				.endif
			.else
				add		lpStr,2
			.endif
			sub		esi,hMem1
			mov		chrg.cpMin,esi
			mov		chrg.cpMax,esi
			invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hWin,EM_REPLACESEL,TRUE,lpStr
		.else
			invoke lstrlen,hMem1
			add		eax,1024
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov		hMem,eax
			invoke GlobalLock,eax
			.if fFound && !fAtTop
				mov		al,[esi]
				.while al && al!=0Ah
					inc		esi
					mov		al,[esi]
				.endw
				.if al
					inc		esi
					add		lpStr,2
				.endif
			.else
				add		lpStr,2
			.endif
			mov		eax,esi
			sub		eax,hMem1
			inc		eax
			invoke lstrcpyn,hMem,hMem1,eax
			invoke lstrcat,hMem,lpStr
			invoke lstrcat,hMem,esi
			push	1
			push	lpFile
			mov		eax,[lpPStruct]
			call	[eax].ADDINPROCS.lpBackupEdit
			invoke CreateFile,lpFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
			.if eax!=INVALID_HANDLE_VALUE
				mov		hFile,eax
				invoke lstrlen,hMem
				mov		edx,eax
				invoke WriteFile,hFile,hMem,edx,addr lpMSt,NULL
				invoke CloseHandle,hFile
			.endif
			invoke GlobalUnlock,hMem
			invoke GlobalFree,hMem
		.endif
	  Ex:
		invoke GlobalUnlock,hMem1
		invoke GlobalFree,hMem1
	.endif
	ret

IncludeFile endp

DeleteLine proc uses esi edi,hMem:DWORD,lpMSt:DWORD,lpMin:DWORD

	mov		esi,lpMSt
	inc		esi
  @@:
	dec		esi
	.if esi>=hMem
		mov		al,[esi]
		cmp		al,0Ah
		je		@f
		cmp		al,0Dh
		jne		@b
	.endif
  @@:
	mov		edi,esi
	inc		edi
	.if edi<lpMin
		mov		lpMin,edi
	.endif
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
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		@b
	mov		[edi],al
	mov		eax,lpMin
	ret

DeleteLine endp

DeleteDef proc hMem:DWORD,lpNme:DWORD,lpMin:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[1024]:BYTE
	LOCAL	pf:PROFIND

	invoke lstrcpy,addr buffer,offset szDef
	invoke lstrlen,offset szDef
	mov		dword ptr buffer[eax],',2,'		;Whole Word
	invoke lstrcat,addr buffer,lpNme
	invoke lstrlen,addr buffer
	mov		dword ptr buffer[eax],'3,'		;Whole Word & Match Case
	mov		pf.nFun,0
	mov		eax,hMem
	mov		pf.hMem,eax
	mov		pf.nFile,0
	mov		pf.pMem,0
	mov		pf.pFile,0
	lea		eax,buffer
	mov		pf.lpFind,eax
	mov		pf.lpNot,offset szNot
	lea		eax,buffer1
	mov		pf.lpLine,eax
	mov		pf.pLine,0
	lea		eax,pf
	push	eax
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpProFind
	.if pf.pLine!=-1
		invoke DeleteLine,hMem,pf.pMem,lpMin
		mov		lpMin,eax
	.endif
	mov		eax,lpMin
	ret

DeleteDef endp

DeleteRes proc hMem:DWORD,lpRes:DWORD,lpMin:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[1024]:BYTE
	LOCAL	pf:PROFIND

  Nx:
	invoke lstrcpy,addr buffer,lpRes
	invoke lstrlen,lpRes
	mov		dword ptr buffer[eax],'2,'		;Whole Word
	mov		pf.nFun,0
	mov		eax,hMem
	mov		pf.hMem,eax
	mov		pf.nFile,0
	mov		pf.pMem,0
	mov		pf.pFile,0
	lea		eax,buffer
	mov		pf.lpFind,eax
	mov		pf.lpNot,offset szNot
	lea		eax,buffer1
	mov		pf.lpLine,eax
	mov		pf.pLine,0
	lea		eax,pf
	push	eax
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpProFind
	.if pf.pLine!=-1
		invoke DeleteLine,hMem,pf.pMem,lpMin
		mov		lpMin,eax
		lea		edx,buffer1
		dec		edx
	  @@:
		inc		edx
		mov		al,[edx]
		cmp		al,09h
		je		@b
		cmp		al,' '
		je		@b
		dec		edx
	  @@:
		inc		edx
		mov		al,[edx]
		or		al,al
		je		@f
		cmp		al,09h
		je		@f
		cmp		al,' '
		je		@f
		cmp		al,0Dh
		jne		@b
	  @@:
		mov		byte ptr [edx],0
		invoke DeleteDef,hMem,addr buffer1,lpMin
		mov		lpMin,eax
		jmp		Nx
	.endif
	mov		eax,lpMin
	ret

DeleteRes endp

AddResources proc hMem1:DWORD
	LOCAL	hMem:DWORD
	LOCAL	lpFile:DWORD
	LOCAL	hWin:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	lpMin:DWORD
	LOCAL	hMem2:DWORD
	LOCAL	hFile:DWORD
	LOCAL	val:DWORD

	invoke AddResFolder
	push	offset szRC
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpGetMainFile
	.if !eax
		invoke AddProjectFile,ecx
		push	offset szRC
		mov		eax,[lpPStruct]
		call	[eax].ADDINPROCS.lpGetMainFile
	.endif
	.if eax
		mov		hMem,eax
		mov		lpFile,ecx
		mov		hWin,edx
		mov		lpMin,-1
		invoke DeleteRes,hMem,offset szBmp,lpMin
		mov		lpMin,eax
		invoke DeleteRes,hMem,offset szCur,lpMin
		mov		lpMin,eax
		invoke DeleteRes,hMem,offset szIco,lpMin
		mov		lpMin,eax
		invoke DeleteRes,hMem,offset szImg,lpMin
		mov		lpMin,eax
		invoke DeleteRes,hMem,offset szMid,lpMin
		mov		lpMin,eax
		invoke DeleteRes,hMem,offset szWav,lpMin
		mov		lpMin,eax
		invoke DeleteRes,hMem,offset szAvi,lpMin
		mov		lpMin,eax
		invoke DeleteRes,hMem,offset szRcd,lpMin
		mov		lpMin,eax
		invoke DeleteRes,hMem,offset szMan,lpMin
		mov		lpMin,eax
		.if hWin
			invoke SendMessage,hWin,EM_HIDESELECTION,TRUE,FALSE
			mov		chrg.cpMin,0
			mov		chrg.cpMax,-1
			invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hWin,EM_REPLACESEL,TRUE,hMem
			mov		eax,lpMin
			.if eax==-1
				mov		eax,hMem
			.endif
			sub		eax,hMem
			mov		chrg.cpMin,eax
			mov		chrg.cpMax,eax
			invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hWin,EM_REPLACESEL,TRUE,hMem1
			invoke SendMessage,hWin,EM_HIDESELECTION,FALSE,FALSE
		.else
			invoke lstrlen,hMem
			push	eax
			invoke lstrlen,hMem1
			pop		edx
			add		eax,edx
			inc		eax
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov		hMem2,eax
			invoke GlobalLock,eax
			mov		eax,lpMin
			.if eax==-1
				mov		eax,hMem
				mov		lpMin,eax
			.endif
			sub		eax,hMem
			inc		eax
			invoke lstrcpyn,hMem2,hMem,eax
			invoke lstrcat,hMem2,hMem1
			invoke lstrcat,hMem2,lpMin
			push	1
			push	lpFile
			mov		eax,[lpPStruct]
			call	[eax].ADDINPROCS.lpBackupEdit
			invoke CreateFile,lpFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
			.if eax!=INVALID_HANDLE_VALUE
				mov		hFile,eax
				invoke lstrlen,hMem2
				mov		edx,eax
				invoke WriteFile,hFile,hMem2,edx,addr val,NULL
				invoke CloseHandle,hFile
			.endif
			invoke GlobalUnlock,hMem2
			invoke GlobalFree,hMem2
		.endif
		invoke GlobalUnlock,hMem
		invoke GlobalFree,hMem
	.endif
	ret

AddResources endp

AddStringTable proc uses esi edi,hMem1:DWORD

	ret

AddStringTable endp

DelVer proc lpMem:DWORD,lpVer:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[1024]:BYTE
	LOCAL	lpMin:DWORD
	LOCAL	pf:PROFIND

	invoke lstrcpy,addr buffer,lpVer
	invoke lstrlen,lpVer
	mov		dword ptr buffer[eax],'2,'		;Whole Word
	mov		pf.nFun,0
	mov		eax,lpMem
	mov		pf.hMem,eax
	mov		pf.nFile,0
	mov		pf.pMem,0
	mov		pf.pFile,0
	lea		eax,buffer
	mov		pf.lpFind,eax
	mov		pf.lpNot,offset szNot
	lea		eax,buffer1
	mov		pf.lpLine,eax
	mov		pf.pLine,0
	lea		eax,pf
	push	eax
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpProFind
	.if pf.pLine!=-1
		invoke DeleteLine,lpMem,pf.pMem,lpMin
	.endif
	ret

DelVer endp

IsLine proc uses esi edi,lpMem:DWORD,lpStr:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[1024]:BYTE
	LOCAL	buffer2[1024]:BYTE
	LOCAL	pf:PROFIND

	mov		esi,lpMem
	lea		edi,buffer2
	dec		esi
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	mov		[edi],al
	or		al,al
	je		@f
	cmp		al,0Dh
	jne		@b
  @@:
	.if al
		inc		esi
		mov		al,[esi]
		.if al==0Ah
			inc		esi
		.endif
	.endif
	mov		al,0
	mov		[edi],al
	invoke lstrcpy,addr buffer,lpStr
	invoke lstrlen,lpStr
	mov		dword ptr buffer[eax],'2,'		;Whole Word
	mov		pf.nFun,0
	lea		eax,buffer2
	mov		pf.hMem,eax
	mov		pf.nFile,0
	mov		pf.pMem,0
	mov		pf.pFile,0
	lea		eax,buffer
	mov		pf.lpFind,eax
	mov		pf.lpNot,offset szNot
	lea		eax,buffer1
	mov		pf.lpLine,eax
	mov		pf.pLine,0
	lea		eax,pf
	push	eax
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpProFind
	xor		eax,eax
	.if pf.pLine!=-1
		mov		eax,TRUE
	.endif
	mov		edx,esi
	ret

IsLine endp

AddVersioninfo proc uses esi edi,hMem1:DWORD
	LOCAL	hMem:DWORD
	LOCAL	lpFile:DWORD
	LOCAL	hWin:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	lpMin:DWORD
	LOCAL	hMem2:DWORD
	LOCAL	hFile:DWORD
	LOCAL	val:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[1024]:BYTE
	LOCAL	pf:PROFIND
	LOCAL	nBegin:DWORD

	invoke AddResFolder
	push	offset szRC
	mov		eax,[lpPStruct]
	call	[eax].ADDINPROCS.lpGetMainFile
	.if !eax
		invoke AddProjectFile,ecx
		push	offset szRC
		mov		eax,[lpPStruct]
		call	[eax].ADDINPROCS.lpGetMainFile
	.endif
	.if eax
		mov		hMem,eax
		mov		lpFile,ecx
		mov		hWin,edx
		mov		lpMin,-1
		invoke lstrcpy,addr buffer,offset szVer
		invoke lstrlen,offset szVer
		mov		dword ptr buffer[eax],'2,'		;Whole Word
		mov		pf.nFun,0
		mov		eax,hMem
		mov		pf.hMem,eax
		mov		pf.nFile,0
		mov		pf.pMem,0
		mov		pf.pFile,0
		lea		eax,buffer
		mov		pf.lpFind,eax
		mov		pf.lpNot,offset szNot
		lea		eax,buffer1
		mov		pf.lpLine,eax
		mov		pf.pLine,0
		lea		eax,pf
		push	eax
		mov		eax,[lpPStruct]
		call	[eax].ADDINPROCS.lpProFind
		.if pf.pLine!=-1
			invoke DeleteLine,hMem,pf.pMem,lpMin
			mov		lpMin,eax
			invoke DelVer,lpMin,offset szFileVer
			invoke DelVer,lpMin,offset szProdVer
			invoke DelVer,lpMin,offset szFileOs
			invoke DelVer,lpMin,offset szFileType
			mov		nBegin,0
			mov		esi,lpMin
			mov		edi,esi
		  @@:
			invoke IsLine,esi,offset szBegin
			cmp		edx,esi
			je		@f
			.if eax
				mov		esi,edx
				inc		nBegin
				jmp		@b
			.endif
			invoke IsLine,esi,offset szBlock
			.if eax
				mov		esi,edx
				jmp		@b
			.endif
			invoke IsLine,esi,offset szValue
			.if eax
				mov		esi,edx
				jmp		@b
			.endif
			invoke IsLine,esi,offset szEnd
			.if eax
				mov		esi,edx
				dec		nBegin
				jne		@b
			.endif
		  @@:
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
			or		al,al
			jne		@b
			lea		edx,buffer1
			dec		edx
		  @@:
			inc		edx
			mov		al,[edx]
			cmp		al,09h
			je		@b
			cmp		al,' '
			je		@b
			dec		edx
		  @@:
			inc		edx
			mov		al,[edx]
			or		al,al
			je		@f
			cmp		al,09h
			je		@f
			cmp		al,' '
			je		@f
			cmp		al,0Dh
			jne		@b
		  @@:
			mov		byte ptr [edx],0
			invoke DeleteDef,hMem,addr buffer1,lpMin
			mov		lpMin,eax
		.endif
		.if hWin
			invoke SendMessage,hWin,EM_HIDESELECTION,TRUE,FALSE
			mov		chrg.cpMin,0
			mov		chrg.cpMax,-1
			invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hWin,EM_REPLACESEL,TRUE,hMem
			mov		eax,lpMin
			.if eax==-1
				invoke lstrlen,hMem
				add		eax,hMem
			.endif
			sub		eax,hMem
			mov		chrg.cpMin,eax
			mov		chrg.cpMax,eax
			invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hWin,EM_REPLACESEL,TRUE,hMem1
			invoke SendMessage,hWin,EM_HIDESELECTION,FALSE,FALSE
		.else
			invoke lstrlen,hMem
			push	eax
			invoke lstrlen,hMem1
			pop		edx
			add		eax,edx
			inc		eax
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov		hMem2,eax
			invoke GlobalLock,eax
			mov		eax,lpMin
			.if eax==-1
				invoke lstrlen,hMem
				add		eax,hMem
				mov		lpMin,eax
			.endif
			sub		eax,hMem
			inc		eax
			invoke lstrcpyn,hMem2,hMem,eax
			invoke lstrcat,hMem2,hMem1
			invoke lstrcat,hMem2,lpMin
			push	1
			push	lpFile
			mov		eax,[lpPStruct]
			call	[eax].ADDINPROCS.lpBackupEdit
			invoke CreateFile,lpFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
			.if eax!=INVALID_HANDLE_VALUE
				mov		hFile,eax
				invoke lstrlen,hMem2
				mov		edx,eax
				invoke WriteFile,hFile,hMem2,edx,addr val,NULL
				invoke CloseHandle,hFile
			.endif
			invoke GlobalUnlock,hMem2
			invoke GlobalFree,hMem2
		.endif
		invoke GlobalUnlock,hMem
		invoke GlobalFree,hMem
	.endif
	ret

AddVersioninfo endp

WinEnumProc proc hWin:DWORD,lParam:DWORD
	LOCAL	buffer[256]:BYTE

	invoke GetWindowLong,hWin,GWL_ID
	.if eax>=ID_FIRSTCHILD &&  eax<=ID_LASTCHILD
		invoke GetWindowLong,hWin,0
		.if eax==ID_DIALOG
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke lstrcmpi,addr buffer,lParam
			.if !eax
				mov		eax,hWin
				mov		hFound,eax
				xor		eax,eax
				ret
			.endif
		.endif
	.endif
	mov		eax,TRUE
	ret

WinEnumProc endp

GetCtlNames proc uses esi edi
	LOCAL	hMem:DWORD
	LOCAL	hMem1:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	iNbr:DWORD
	LOCAL	nMiss:DWORD
	LOCAL	hFile:DWORD

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,32768
	invoke GlobalLock,eax
	mov		hMem,eax
	mov		edi,eax
	mov		iNbr,1
	mov		nMiss,0
  @@:
	invoke BinToDec,iNbr,addr buffer1
	mov		eax,lpDStruct
	mov		eax,[eax].ADDINDATA.lpProject
	invoke GetPrivateProfileString,offset szFiles,addr buffer1,addr szNULL,addr buffer1,sizeof buffer1,eax
	.if eax
		lea		eax,buffer1
		push	eax
		mov		eax,lpPStruct
		call	[eax].ADDINPROCS.lpGetFileType
		.if eax==5
			mov		edx,lpDStruct
			mov		edx,[edx].ADDINDATA.lpProjectPath
			invoke lstrcpy,addr buffer,edx
			invoke lstrcat,addr buffer,addr buffer1
			mov		edx,lpHStruct
			mov		edx,[edx].ADDINHANDLES.hClient
			mov		hFound,0
			invoke EnumChildWindows,edx,addr WinEnumProc,addr buffer
			.if hFound
				invoke GetWindowLong,hFound,4
				mov		esi,eax
				add		esi,sizeof DLGHEAD
				mov		eax,[esi].DIALOG.hwnd
				.while eax
					call CopyName
					add		esi,sizeof DIALOG
					mov		eax,[esi].DIALOG.hwnd
				.endw
			.else
				invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
				.if eax!=INVALID_HANDLE_VALUE
					mov		hFile,eax
					invoke GetFileSize,hFile,addr nMiss
					push	eax
					add		eax,512
					invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
					invoke GlobalLock,eax
					mov		hMem1,eax
					pop		edx
					invoke ReadFile,hFile,hMem1,edx,addr nMiss,NULL
					invoke CloseHandle,hFile
					mov		esi,hMem1
					add		esi,sizeof DLGHEAD
					mov		eax,[esi].DIALOG.hwnd
					.while eax
						call CopyName
						add		esi,sizeof DIALOG
						mov		eax,[esi].DIALOG.hwnd
					.endw
					invoke GlobalUnlock,hMem1
					invoke GlobalFree,hMem1
				.endif
			.endif
		.endif
		mov		nMiss,0
	.else
		inc		nMiss
	.endif
	inc		iNbr
	.if nMiss<=10
		jmp		@b
	.endif
	mov		eax,hMem
	ret

CopyName:
	mov		al,[esi].DIALOG.idname
	.if al
		invoke lstrcpy,edi,addr [esi].DIALOG.idname
		invoke lstrlen,edi
		add		edi,eax
		inc		edi
	.endif
	retn

GetCtlNames endp

GetUniqueName proc uses esi,lpCtl:DWORD
	LOCAL	hMem:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	nID:DWORD

	mov		edx,lpCtl
	invoke lstrcpy,addr buffer1,addr [edx].DIALOG.idname
	invoke GetCtlNames
	mov		hMem,eax
	mov		nID,1
  Nx:
	invoke lstrcpy,addr buffer,addr buffer1
	invoke lstrlen,addr buffer
	invoke BinToDec,nID,addr buffer[eax]
	inc		nID
	mov		esi,hMem
  @@:
	mov		al,[esi]
	.if al
		invoke lstrcmp,addr buffer,esi
		or		eax,eax
		je		Nx
		invoke lstrlen,esi
		add		esi,eax
		inc		esi
		jmp		@b
	.endif
	mov		edx,lpCtl
	invoke lstrcpy,addr [edx].DIALOG.idname,addr buffer
	invoke GlobalUnlock,hMem
	invoke GlobalFree,hMem
	ret

GetUniqueName endp
