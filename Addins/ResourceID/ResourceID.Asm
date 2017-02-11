;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include ResourceID.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

InstallDll proc uses ebx,hWin:DWORD,fOpt:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0
	mov		lpData,eax
	;If version less than 2210, don't hook anything.
	xor		ecx,ecx
	cmp		[eax].ADDINDATA.nRadASMVer,2210
	jl		@f
	;Messages to hook into
	mov		ecx,RAM_RCSAVED
  @@:
	xor		eax,eax
	xor		edx,edx
	ret 

InstallDll Endp

ExportFileName proc uses esi,lpFile:DWORD

	mov		esi,lpFile
	invoke lstrlen,esi
	.while eax
		.break .if byte ptr [esi+eax-1]=='\'
		dec		eax
	.endw
	lea		esi,[esi+eax]
	mov		eax,lpData
	mov		eax,[eax].ADDINDATA.nAsm
	.if eax==6 || eax==7
		; hla, cpp
		mov		word ptr [edi],'//'
		add		edi,2
	.elseif eax==8
		; bcet
		mov		byte ptr [edi],"'"
		inc		edi
	.else
		; masm, tasm, fasm, nasm, goasm, other
		mov		byte ptr [edi],';'
		inc		edi
	.endif
	.while byte ptr [esi]
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		word ptr [edi],0A0Dh
	add		edi,2
	ret

ExportFileName endp

ExportLine proc
	LOCAL	nChars:DWORD

	mov		nChars,0
	mov		eax,lpData
	mov		eax,[eax].ADDINDATA.nAsm
	.if eax==6
		; hla
		; Skip #define
		.while byte ptr [esi]!=' ' && byte ptr [esi]!=VK_TAB && byte ptr [esi]
			inc		esi
		.endw
		; Skip whitespace
		.while byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		; Copy name
		.while byte ptr [esi]!=' ' && byte ptr [esi]!=VK_TAB && byte ptr [esi]
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
			inc		nChars
		.endw
		mov		ecx,31
		sub		ecx,nChars
		.while sdword ptr ecx>0
			mov		byte ptr [edi],' '
			inc		edi
			dec		ecx
		.endw
		mov		dword ptr [edi],' =: '
		add		edi,4
		; Skip whitespace
		.while byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		; Copy ID
		.while byte ptr [esi]!=' ' && byte ptr [esi]!=VK_TAB && byte ptr [esi]!=VK_RETURN && byte ptr [esi]
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
		mov		byte ptr [edi],';'
		inc		edi
	.elseif eax==7
		; cpp
		.while byte ptr [esi] && byte ptr [esi]!=0Dh
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
	.elseif eax==8
		;bcet
		.while byte ptr [esi] && byte ptr [esi]!=0Dh
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
	.else
		; masm, tasm, fasm, nasm, goasm, other
		; Skip #define
		.while byte ptr [esi]!=' ' && byte ptr [esi]!=VK_TAB && byte ptr [esi]
			inc		esi
		.endw
		; Skip whitespace
		.while byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		; Copy name
		.while byte ptr [esi]!=' ' && byte ptr [esi]!=VK_TAB && byte ptr [esi]
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
			inc		nChars
		.endw
		mov		ecx,31
		sub		ecx,nChars
		.while sdword ptr ecx>0
			mov		byte ptr [edi],' '
			inc		edi
			dec		ecx
		.endw
		mov		dword ptr [edi],'uqe '
		add		edi,4
		mov		byte ptr [edi],' '
		inc		edi
		; Skip whitespace
		.while byte ptr [esi]==' ' || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		; Copy ID
		.while byte ptr [esi]!=' ' && byte ptr [esi]!=VK_TAB && byte ptr [esi]!=VK_RETURN && byte ptr [esi]
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
		.endw
	.endif
	mov		word ptr [edi],0A0Dh
	add		edi,2
	ret

ExportLine endp

ExportFile proc uses esi edi,lpMem:DWORD,lpFile:DWORD
	LOCAL	hFile:DWORD
	LOCAL	hMem:DWORD
	LOCAL	dwRead:DWORD

	invoke CreateFile,lpFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		push	eax
		inc		eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		hMem,eax
		pop		edx
		invoke ReadFile,hFile,hMem,edx,addr dwRead,NULL
		invoke CloseHandle,hFile
		mov		edi,lpMem
		invoke lstrlen,edi
		lea		edi,[edi+eax]
		mov		esi,hMem
	  @@:
		push	FALSE	;Whitespace
		push	TRUE	;Whole word
		push	FALSE	;Match case
		push	offset Define
		push	esi
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpSearchMem
		.if eax
			mov		esi,eax
			.if dwRead
				invoke ExportFileName,lpFile
				mov		dwRead,0
			.endif
			invoke ExportLine
			jmp		@b
		.endif
		invoke GlobalFree,hMem
	.endif
	ret

ExportFile endp

FindFiles proc lpMem:DWORD,lpPath:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hwfd:DWORD

	invoke lstrcpy,addr buffer,lpPath
	invoke lstrcat,addr buffer,addr FileSearch
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		;Save returned handle
		mov		hwfd,eax
	  Next:
		invoke lstrcpy,addr buffer,lpPath
		invoke lstrcat,addr buffer,addr wfd.cFileName
		invoke ExportFile,lpMem,addr buffer
		;Any more matches?
		invoke FindNextFile,hwfd,addr wfd
		or		eax,eax
		jne		Next
		;No more matches, close handle
		invoke FindClose,hwfd
	.endif
	ret

FindFiles endp

Export proc hOpen:HWND,lpFile:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hMem:DWORD
	LOCAL	hFile:DWORD
	LOCAL	dwWrite:DWORD
	LOCAL	chrg:CHARRANGE

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov		hMem,eax
	mov		eax,lpData
	invoke lstrcpy,addr buffer,[eax].ADDINDATA.lpProjectPath
	invoke FindFiles,hMem,addr buffer
	invoke lstrcat,addr buffer,addr ResPath
	invoke FindFiles,hMem,addr buffer
	invoke lstrlen,hMem
	.if eax
		.if hOpen
			invoke GetWindowLong,hOpen,GWL_USERDATA
			mov		hOpen,eax
			mov		chrg.cpMin,0
			mov		chrg.cpMax,-1
			invoke SendMessage,hOpen,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hOpen,EM_REPLACESEL,TRUE,hMem
		.else
			push	eax
			invoke CreateFile,lpFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
			mov		hFile,eax
			pop		edx
			invoke WriteFile,hFile,hMem,edx,addr dwWrite,NULL
			invoke CloseHandle,hFile
		.endif
	.endif
	invoke GlobalFree,hMem
	ret

Export endp

CheckLoadedEnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

    invoke GetWindowLong,hWin,GWL_ID
    .if eax>=ID_FIRSTCHILD &&  eax<=ID_LASTCHILD
		invoke GetWindowLong,hWin,0
		.if eax==ID_EDIT
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

CheckLoadedEnumProc endp

DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==AIM_RCSAVED
		mov		eax,lpData
		.if [eax].ADDINDATA.fProject
			invoke lstrcpy,addr buffer,[eax].ADDINDATA.lpProjectPath
			invoke lstrcat,addr buffer,addr FileName
			mov		eax,lpData
			invoke lstrcat,addr buffer,[eax].ADDINDATA.lpDefHdrExt
;			lea eax,buffer
;			push eax
;			mov eax,lpProc
;			call [eax].ADDINPROCS.lpTextOut
			invoke GetFileAttributes,addr buffer
			.if eax!=INVALID_HANDLE_VALUE
;				invoke MessageBox,hWin,addr buffer,addr buffer,MB_OK
				mov		hFound,0
				mov		edx,lpHandles
				invoke EnumChildWindows,[edx].ADDINHANDLES.hClient,addr CheckLoadedEnumProc,addr buffer
				invoke Export,hFound,addr buffer
				mov		eax,lpProc
				call	[eax].ADDINPROCS.lpRefreshProperty
			.endif
		.endif
	.endif
	mov		eax,FALSE
	ret

DllProc Endp

;#########################################################################

End DllEntry
