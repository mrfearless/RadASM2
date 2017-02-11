;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include UndoSave.inc

.code

SaveUndo proc uses ebx esi edi,hWin:HWND,hREd:HWND,pfid:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	ft:FILETIME

	mov		eax,pfid
	mov		edx,sizeof UNDOSAVE
	mul		edx
	mov		edi,offset us
	lea		edi,[edi+eax]
	.if [edi].UNDOSAVE.hmem
		invoke GlobalFree,[edi].UNDOSAVE.hmem
	.endif
	invoke RtlZeroMemory,edi,sizeof UNDOSAVE
	invoke SendMessage,hREd,REM_GETUNDO,1000,0
	.if eax
		mov		[edi].UNDOSAVE.nsize,eax
		mov		eax,pfid
		mov		[edi].UNDOSAVE.pfid,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,[edi].UNDOSAVE.nsize
		mov		[edi].UNDOSAVE.hmem,eax
		invoke SendMessage,hREd,REM_GETUNDO,1000,[edi].UNDOSAVE.hmem
		; Get file time
		mov		eax,lpData
		invoke CreateFile,[eax].ADDINDATA.lpFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		mov		hFile,eax
		invoke GetFileTime,hFile,NULL,NULL,addr ft
		invoke CloseHandle,hFile
		invoke FileTimeToDosDateTime,addr ft,addr [edi].UNDOSAVE.dft+2,addr [edi].UNDOSAVE.dft
	.endif
	ret

SaveUndo endp

LoadUndo proc uses ebx esi edi,hWin:HWND,hREd:HWND,pfid:DWORD
	LOCAL	hFile:HANDLE
	LOCAL	ft:FILETIME
	LOCAL	dft:DWORD


	mov		eax,pfid
	mov		edx,sizeof UNDOSAVE
	mul		edx
	mov		esi,offset us
	lea		esi,[esi+eax]
	.if [esi].UNDOSAVE.hmem
		mov		eax,lpData
		invoke CreateFile,[eax].ADDINDATA.lpFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		mov		hFile,eax
		invoke GetFileTime,hFile,NULL,NULL,addr ft
		invoke CloseHandle,hFile
		invoke FileTimeToDosDateTime,addr ft,addr dft+2,addr dft
		mov		eax,[esi].UNDOSAVE.dft
		.if eax==dft
			invoke SendMessage,hREd,REM_SETUNDO,[esi].UNDOSAVE.nsize,[esi].UNDOSAVE.hmem
		.else
			invoke GlobalFree,[esi].UNDOSAVE.hmem
			invoke RtlZeroMemory,esi,sizeof UNDOSAVE
		.endif
	.endif
	ret

LoadUndo endp

GetUndo proc uses ebx esi edi
	LOCAL	hFile:HANDLE
	LOCAL	nSize:DWORD
	LOCAL	hMem:HGLOBAL
	LOCAL	dwread:DWORD

	invoke CreateFile,addr usFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		mov		nSize,eax
		invoke GlobalAlloc,GMEM_FIXED,nSize
		mov		hMem,eax
		invoke ReadFile,hFile,hMem,nSize,addr dwread,NULL
		invoke CloseHandle,hFile
		mov		esi,hMem
		xor		ebx,ebx
		.while ebx<nSize
			mov		eax,[esi].UNDOSAVE.pfid
			mov		edx,sizeof UNDOSAVE
			mul		edx
			mov		edi,offset us
			lea		edi,[edi+eax]
			mov		eax,[esi].UNDOSAVE.pfid
			mov		[edi].UNDOSAVE.pfid,eax
			mov		eax,[esi].UNDOSAVE.dft
			mov		[edi].UNDOSAVE.dft,eax
			mov		eax,[esi].UNDOSAVE.nsize
			mov		[edi].UNDOSAVE.nsize,eax
			invoke GlobalAlloc,GMEM_FIXED,eax
			mov		[edi].UNDOSAVE.hmem,eax
			invoke RtlMoveMemory,[edi].UNDOSAVE.hmem,addr [esi+sizeof UNDOSAVE],[esi].UNDOSAVE.nsize
			mov		eax,[esi].UNDOSAVE.nsize
			lea		ebx,[ebx+eax+sizeof UNDOSAVE]
			lea		esi,[esi+eax+sizeof UNDOSAVE]
		.endw
		invoke GlobalFree,hMem
	.endif
	ret

GetUndo endp

PutUndo proc uses ebx esi edi
	LOCAL	hFile:HANDLE
	LOCAL	nSize:DWORD
	LOCAL	dwwritten:DWORD

	invoke CreateFile,addr usFileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		xor		ebx,ebx
		mov		esi,offset us
		.while ebx<2048
			.if [esi].UNDOSAVE.hmem
				invoke WriteFile,hFile,esi,sizeof UNDOSAVE,addr dwwritten,NULL
				invoke WriteFile,hFile,[esi].UNDOSAVE.hmem,[esi].UNDOSAVE.nsize,addr dwwritten,NULL
				invoke GlobalFree,[esi].UNDOSAVE.hmem
			.endif
			lea		esi,[esi+sizeof UNDOSAVE]
			inc		ebx
		.endw
		invoke CloseHandle,hFile
		invoke RtlZeroMemory,addr us,sizeof us
	.endif
	ret

PutUndo endp

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
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
	mov		eax,[eax].ADDINDATA.nRadASMVer
	.if eax>=2219
		; Messages to hook into
		mov		eax,RAM_COMMAND OR RAM_EDITOPEN OR RAM_EDITSAVED OR RAM_PROJECTCLOSED OR RAM_PROJECTREMOVE
		mov		ecx,RAM_PROJECTOPEN
	.else
		xor		eax,eax
		xor		ecx,ecx
	.endif
	; EDX must be null before we return
	xor		edx,edx
	ret

InstallDll Endp

DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax, 16
		.if edx==IDM_EDIT_EMPTY_UNDO && eax==BN_CLICKED
			mov		eax,lpHandles
			invoke GetWindowLong,[eax].ADDINHANDLES.hMdiCld,16
			.if eax<2048
				mov		edx,sizeof UNDOSAVE
				mul		edx
				mov		edx,offset us
				lea		edx,[edx+eax]
				.if [edx].UNDOSAVE.hmem
					push	edx
					invoke GlobalFree,[edx].UNDOSAVE.hmem
					pop		edx
					invoke RtlZeroMemory,edx,sizeof UNDOSAVE
				.endif
			.endif
		.endif
	.elseif eax==AIM_EDITOPEN
		mov		eax,lpData
		.if [eax].ADDINDATA.fProject
			invoke GetWindowLong,hWin,16
			.if sdword ptr eax>0
				; Load undo information from ram
				invoke LoadUndo,hWin,wParam,eax
			.endif
		.endif
	.elseif eax==AIM_EDITSAVED
		mov		eax,lpData
		.if [eax].ADDINDATA.fProject
			invoke GetWindowLong,hWin,16
			.if sdword ptr eax>0
				; Save undo information to ram
				invoke SaveUndo,hWin,wParam,eax
			.endif
		.endif
	.elseif eax==AIM_PROJECTOPEN
		; Load undo information from [PROJECTNAME].undo
		invoke lstrcpy,addr usFileName,lParam
		invoke lstrlen,addr usFileName
		invoke lstrcpy,addr usFileName[eax-3],addr szUndo
		invoke GetUndo
	.elseif eax==AIM_PROJECTCLOSED
		; Save undo information to [PROJECTNAME].undo
		invoke PutUndo
	.elseif eax==AIM_PROJECTREMOVE
		; A project file is removed, delete undo information
		mov		eax,wParam
		.if eax<2048
			mov		edx,sizeof UNDOSAVE
			mul		edx
			mov		edx,offset us
			lea		edx,[edx+eax]
			.if [edx].UNDOSAVE.hmem
				push	edx
				invoke GlobalFree,[edx].UNDOSAVE.hmem
				pop		edx
				invoke RtlZeroMemory,edx,sizeof UNDOSAVE
			.endif
		.endif
	.endif
	mov		eax,FALSE
	ret

DllProc Endp

;#########################################################################

end DllEntry
