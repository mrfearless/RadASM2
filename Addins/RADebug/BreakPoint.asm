
ID_EDIT							equ	65501

.code

GetFileIDFromProjectFileID proc uses ebx edi,ProjectFileID:DWORD

	push	ProjectFileID
	mov		eax,lpProc
	call	[eax].ADDINPROCS.lpGetFileNameFromID
	.if eax
		mov		edi,eax
		mov		ebx,dbg.hMemSource
		xor		ecx,ecx
		.while ecx<dbg.inxsource
			push	ecx
			invoke strcmpi,edi,addr [ebx].DEBUGSOURCE.FileName
			.if !eax
				pop		eax
				ret
			.endif
			pop		ecx
			inc		ecx
			add		ebx,sizeof DEBUGSOURCE
		.endw
	.endif
	mov		eax,-1
	ret

GetFileIDFromProjectFileID endp

UnsavedFiles proc
	LOCAL	hTab:HWND
	LOCAL	nInx:DWORD
	LOCAL	tci:TCITEM
	LOCAL	hREd:HWND
	LOCAL	Unsaved:DWORD

	mov		Unsaved,0
	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hTab
	mov		hTab,eax
	mov		tci.imask,TCIF_PARAM
	mov		nInx,0
	.while TRUE
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.break .if !eax
		invoke GetWindowLong,tci.lParam,0
		.if eax==ID_EDIT
			invoke GetWindowLong,tci.lParam,GWL_USERDATA
			mov		hREd,eax
			invoke SendMessage,hREd,EM_GETMODIFY,0,0
			.if eax
				inc		Unsaved
			.endif
		.endif
		inc		nInx
	.endw
	mov		eax,Unsaved
	ret

UnsavedFiles endp

NewerFiles proc
	LOCAL	hTab:HWND
	LOCAL	nInx:DWORD
	LOCAL	tci:TCITEM
	LOCAL	hREd:HWND
	LOCAL	hFile:HANDLE
	LOCAL	ftexe:FILETIME
	LOCAL	ftsource:FILETIME
	LOCAL	Newer:DWORD

	mov		Newer,0
	invoke CreateFile,addr szExeName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileTime,hFile,NULL,NULL,addr ftexe
		invoke CloseHandle,hFile
		mov		eax,lpHandles
		mov		eax,[eax].ADDINHANDLES.hTab
		mov		hTab,eax
		mov		tci.imask,TCIF_PARAM
		mov		nInx,0
		.while TRUE
			invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
			.break .if !eax
			invoke GetWindowLong,tci.lParam,0
			.if eax==ID_EDIT
				mov		eax,lpData
				invoke strcpy,addr szTempName,[eax].ADDINDATA.lpProjectPath
				invoke GetWindowLong,tci.lParam,16
				push	eax
				mov		eax,lpProc
				call	[eax].ADDINPROCS.lpGetFileNameFromID
				invoke strcat,addr szTempName,eax
				invoke CreateFile,addr szTempName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
				.if eax!=INVALID_HANDLE_VALUE
					mov		hFile,eax
					invoke GetFileTime,hFile,NULL,NULL,addr ftsource
					invoke CloseHandle,hFile
					mov		eax,ftexe.dwLowDateTime
					sub		eax,ftsource.dwLowDateTime
					mov		eax,ftexe.dwHighDateTime
					sbb		eax,ftsource.dwHighDateTime
					.if CARRY?
						inc		Newer
					.endif
				.endif
			.endif
			inc		nInx
		.endw
	.else
		; File not found
		mov		Newer,-1
	.endif
	mov		eax,Newer
	ret

NewerFiles endp

LockFiles proc fLock:DWORD
	LOCAL	hTab:HWND
	LOCAL	nInx:DWORD
	LOCAL	tci:TCITEM
	LOCAL	hREd:HWND

	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hTab
	mov		hTab,eax
	mov		tci.imask,TCIF_PARAM
	mov		nInx,0
	.while TRUE
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.break .if !eax
		invoke GetWindowLong,tci.lParam,0
		.if eax==ID_EDIT
			invoke GetWindowLong,tci.lParam,GWL_USERDATA
			mov		hREd,eax
			invoke SendMessage,hREd,REM_READONLY,0,fLock
		.endif
		inc		nInx
	.endw
	ret

LockFiles endp

AnyBreakPoints proc uses esi

	mov		esi,offset breakpoint
	mov		ecx,512
	xor		eax,eax
	.while ecx
		.if [esi].BREAKPOINT.ProjectFileID
			inc		eax
			ret
		.endif
		inc		ecx
		add		esi,sizeof BREAKPOINT
	.endw
	ret

AnyBreakPoints endp

ClearBreakpoints proc
	LOCAL	hTab:HWND
	LOCAL	nInx:DWORD
	LOCAL	tci:TCITEM
	LOCAL	hREd:HWND
	LOCAL	nLine:DWORD

	invoke RtlZeroMemory,offset breakpoint,sizeof breakpoint
	mov		eax,lpData
	invoke WritePrivateProfileSection,addr szRADebugBP,addr szBPNULL,[eax].ADDINDATA.lpProject
	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hTab
	mov		hTab,eax
	mov		tci.imask,TCIF_PARAM
	mov		nInx,0
	.while TRUE
		invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
		.break .if !eax
		invoke GetWindowLong,tci.lParam,0
		.if eax==ID_EDIT
			invoke GetWindowLong,tci.lParam,GWL_USERDATA
			mov		hREd,eax
			mov		nLine,-1
			.while TRUE
				invoke SendMessage,hREd,REM_NEXTBREAKPOINT,nLine,0
				.break .if eax==-1
				mov		nLine,eax
				invoke SendMessage,hREd,REM_SETBREAKPOINT,nLine,FALSE
			.endw
		.endif
		inc		nInx
	.endw
	ret

ClearBreakpoints endp

ToggleBreakpoint proc
	LOCAL	hREd:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	nLine:DWORD

	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hMdiCld
	invoke GetWindowLong,eax,0
	.if eax==ID_EDIT
		mov		eax,lpHandles
		mov		eax,[eax].ADDINHANDLES.hEdit
		mov		hREd,eax
		invoke SendMessage,hREd,EM_EXGETSEL,0,addr chrg
		invoke SendMessage,hREd,EM_EXLINEFROMCHAR,0,chrg.cpMin
		mov		nLine,eax
		invoke SendMessage,hREd,REM_GETLINESTATE,nLine,0
		and		eax,STATE_BREAKPOINT
		xor		eax,STATE_BREAKPOINT
		invoke SendMessage,hREd,REM_SETBREAKPOINT,nLine,eax
	.endif
	ret

ToggleBreakpoint endp

SaveBreakPoints proc uses ebx
	LOCAL	hREd:HWND
	LOCAL	nInx:DWORD
	LOCAL	nLine:DWORD
	LOCAL	buffer[1024]:BYTE
	LOCAL	szbp[8]:BYTE

	mov		eax,lpHandles
	invoke GetWindowLong,[eax].ADDINHANDLES.hMdiCld,0
	.if eax==ID_EDIT
		mov		eax,lpHandles
		mov		eax,[eax].ADDINHANDLES.hEdit
		mov		hREd,eax
		mov		eax,lpHandles
		invoke GetWindowLong,[eax].ADDINHANDLES.hMdiCld,16
		mov		nInx,eax
		mov		dword ptr buffer,0
		mov		nLine,-1
		mov		ebx,128
		.while ebx
			invoke SendMessage,hREd,REM_NEXTBREAKPOINT,nLine,0
			.break .if eax==-1
			mov		nLine,eax
			invoke wsprintf,addr szbp,addr szCommaBP,nLine
			invoke strcat,addr buffer,addr szbp
			dec		ebx
		.endw
		invoke wsprintf,addr szbp,addr szCommaBP,nInx
		mov		eax,lpData
		invoke WritePrivateProfileString,addr szRADebugBP,addr szbp[1],addr buffer[1],[eax].ADDINDATA.lpProject
	.endif
	ret

SaveBreakPoints endp

LoadBreakPoints proc uses esi
	LOCAL	hREd:HWND
	LOCAL	nInx:DWORD
	LOCAL	nLine:DWORD
	LOCAL	buffer[1024]:BYTE
	LOCAL	szbp[8]:BYTE

	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hMdiCld
	invoke GetWindowLong,eax,0
	.if eax==ID_EDIT
		mov		eax,lpHandles
		mov		eax,[eax].ADDINHANDLES.hEdit
		mov		hREd,eax
		mov		eax,lpHandles
		invoke GetWindowLong,[eax].ADDINHANDLES.hMdiCld,16
		mov		nInx,eax
		invoke wsprintf,addr szbp,addr szCommaBP,nInx
		mov		eax,lpData
		invoke GetPrivateProfileString,addr szRADebugBP,addr szbp[1],addr szNULL,addr buffer,sizeof buffer,[eax].ADDINDATA.lpProject
		lea		esi,buffer
		.while byte ptr [esi]
			mov		edx,esi
			.while byte ptr [esi]!=',' && byte ptr [esi]
				inc		esi
			.endw
			.if byte ptr [esi]==','
				mov		byte ptr [esi],0
				inc		esi
			.endif
			.if esi!=edx
				invoke DecToBin,edx
				invoke SendMessage,hREd,REM_SETBREAKPOINT,eax,TRUE
			.endif
		.endw
	.endif
	ret

LoadBreakPoints endp

LoadAllBreakPoints proc uses esi edi
	LOCAL	hMem:HGLOBAL
	LOCAL	ProjectFileID:DWORD
	LOCAL	nCount:DWORD

	invoke RtlZeroMemory,offset breakpoint,sizeof breakpoint
	invoke GlobalAlloc,GMEM_FIXED,32768
	.if eax
		mov		hMem,eax
		mov		eax,lpData
		invoke GetPrivateProfileSection,addr szRADebugBP,hMem,32768,[eax].ADDINDATA.lpProject
		mov		nCount,512
		mov		esi,hMem
		mov		edi,offset breakpoint
		.while byte ptr [esi] && nCount
			call	GetBP
		.endw
	.endif
	ret

GetBP:
	mov		edx,esi
	.while byte ptr [esi]!='='
		inc		esi
	.endw
	mov		byte ptr [esi],0
	inc		esi
	invoke DecToBin,edx
	mov		ProjectFileID,eax
	.while byte ptr [esi] && nCount
		mov		edx,esi
		.while byte ptr [esi]!=',' && byte ptr [esi]
			inc		esi
		.endw
		.if byte ptr [esi]==','
			mov		byte ptr [esi],0
			inc		esi
		.endif
		.if esi!=edx
			invoke DecToBin,edx
			mov		[edi].BREAKPOINT.LineNumber,eax
			mov		eax,ProjectFileID
			mov		[edi].BREAKPOINT.ProjectFileID,eax
			add		edi,sizeof BREAKPOINT
			dec		nCount
		.endif
	.endw
	inc		esi
	retn

LoadAllBreakPoints endp
