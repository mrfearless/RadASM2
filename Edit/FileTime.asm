
FILENOTIFYPATH struct
	nCount		dd ?
	path		db MAX_PATH dup(?)
FILENOTIFYPATH ends

FILENOTIFY struct
	hThread		dd ?
	lpPath		dd ?
	nCount		dd ?
	lpHandle	dd ?
	lpPtrPth	dd ?
FILENOTIFY ends

.data

fn						FILENOTIFY <0,fnpath,0,fnhandle,fnptrpth>

.data?

fnpath					FILENOTIFYPATH MAXIMUM_WAIT_OBJECTS dup(<?>)
fnhandle				dd MAXIMUM_WAIT_OBJECTS dup(?)
fnptrpth				dd MAXIMUM_WAIT_OBJECTS dup(?)

.code

UpdateFileTime proc hWin:HWND
	LOCAL	hFile:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	filet:FILETIME

	invoke GetWindowText,hWin,addr buffer,sizeof buffer
	invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileTime,hFile,NULL,NULL,addr filet
		invoke CloseHandle,hFile
		invoke GetWindowLong,hWin,28
		mov		edx,filet.dwLowDateTime
		mov		[eax].RADMEM.ft.dwLowDateTime,edx
		mov		edx,filet.dwHighDateTime
		mov		[eax].RADMEM.ft.dwHighDateTime,edx
	.endif
	ret

UpdateFileTime endp

ThreadProc proc uses ebx esi edi,Param:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	filet1:FILETIME
	LOCAL	filet2:FILETIME
	LOCAL	nInx:DWORD
	LOCAL	tci:TC_ITEM

	mov		esi,fn.lpPath
	mov		edi,fn.lpHandle
	mov		ebx,fn.lpPtrPth
	.while [esi].FILENOTIFYPATH.path
		.if [esi].FILENOTIFYPATH.nCount
			invoke FindFirstChangeNotification,addr [esi].FILENOTIFYPATH.path,FALSE,FILE_NOTIFY_CHANGE_LAST_WRITE 
			mov		[edi],eax
			lea		eax,[esi].FILENOTIFYPATH.path
			mov		[ebx],eax
			add		edi,4
			add		ebx,4
			inc		fn.nCount
		.endif
		add		esi,sizeof FILENOTIFYPATH
	.endw
	.while TRUE
		; Wait for notification.
		invoke WaitForMultipleObjects,fn.nCount,fn.lpHandle,FALSE,INFINITE
		.if eax<MAXIMUM_WAIT_OBJECTS
			mov		esi,fn.lpPtrPth
			lea		esi,[esi+eax*4]
			mov		edi,fn.lpHandle
			lea		edi,[edi+eax*4]
			mov		nInx,-1
			mov		tci.imask,TCIF_PARAM
			.while TRUE
				inc		nInx
				invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
				.break .if !eax
				invoke GetWindowLong,tci.lParam,0
				.if eax>=ID_EDIT && eax<=ID_EDITHEX
					invoke GetWindowText,tci.lParam,addr buffer,sizeof buffer
					invoke strlen,addr buffer
					.while eax
						.if byte ptr buffer[eax]=='\'
							mov		byte ptr buffer[eax],0
							.break
						.endif
						dec		eax
					.endw
					invoke lstrcmpi,addr buffer,[esi]
					.if !eax
						invoke GetWindowLong,tci.lParam,28
						.if eax
							push	eax
							mov		edx,[eax].RADMEM.ft.dwLowDateTime
							mov		filet1.dwLowDateTime,edx
							mov		edx,[eax].RADMEM.ft.dwHighDateTime
							mov		filet1.dwHighDateTime,edx
							invoke UpdateFileTime,tci.lParam
							pop		eax
							mov		edx,[eax].RADMEM.ft.dwLowDateTime
							mov		filet2.dwLowDateTime,edx
							mov		edx,[eax].RADMEM.ft.dwHighDateTime
							mov		filet2.dwHighDateTime,edx
							invoke CompareFileTime,addr filet1,addr filet2
							.if sdword ptr eax!=0
								invoke GetWindowLong,tci.lParam,28
								.if eax
									mov		[eax].RADMEM.changed,TRUE
								.endif
							.endif
						.endif
					.endif
				.endif
			.endw
			invoke FindNextChangeNotification,[edi]
			.break .if !eax
		.else
			.break
		.endif
	.endw
	xor		eax,eax
	ret

ThreadProc ENDP

CloseNotify proc uses esi

	mov		esi,fn.lpHandle
	.while fn.nCount
		invoke FindCloseChangeNotification,[esi]
		mov		dword ptr [esi],0
		add		esi,4
		dec		fn.nCount
	.endw
	.if fn.hThread
		invoke CloseHandle,fn.hThread
		mov		fn.hThread,0
	.endif
	ret

CloseNotify endp

SetNotify proc uses esi
	LOCAL	ThreadID:DWORD
	LOCAL	nCount:DWORD

	invoke CloseNotify
	.if fChangeNotify
		xor		eax,eax
		mov		nCount,eax
		mov		esi,fn.lpPath
		.while [esi].FILENOTIFYPATH.path && nCount<MAXIMUM_WAIT_OBJECTS
			.if [esi].FILENOTIFYPATH.nCount
				inc		eax
				.break
			.endif
			add		esi,sizeof FILENOTIFYPATH
			inc		nCount
		.endw
		.if eax
			invoke CreateThread,NULL,NULL,addr ThreadProc,0,NORMAL_PRIORITY_CLASS,addr ThreadID
			mov		fn.hThread,eax
		.endif
	.endif
	ret

SetNotify endp

AddPath proc uses esi edi,hWin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	nCount:DWORD

	invoke GetWindowText,hWin,addr buffer,sizeof buffer
	invoke UpdateFileTime,hWin
	invoke strlen,addr buffer
	.while eax
		.if byte ptr buffer[eax]=='\'
			mov		byte ptr buffer[eax],0
			.break
		.endif
		dec		eax
	.endw
	invoke GetFileAttributes,addr buffer
	.if eax!=INVALID_HANDLE_VALUE
		xor		edi,edi
		mov		nCount,edi
		mov		esi,fn.lpPath
		.while [esi].FILENOTIFYPATH.path && nCount<MAXIMUM_WAIT_OBJECTS
			.if [esi].FILENOTIFYPATH.nCount
				invoke lstrcmpi,addr [esi].FILENOTIFYPATH.path,addr buffer
				or		eax,eax
				je		Found
			.elseif !edi
				;First empty
				mov		edi,esi
			.endif
			add		esi,sizeof FILENOTIFYPATH
			inc		nCount
		.endw
		.if edi
			mov		esi,edi
		.endif
		.if nCount<MAXIMUM_WAIT_OBJECTS || edi
			invoke strcpy,addr [esi].FILENOTIFYPATH.path,addr buffer
		  Found:
			inc		[esi].FILENOTIFYPATH.nCount
			.if [esi].FILENOTIFYPATH.nCount==1
				; A new path has been added
				invoke SetNotify
			.endif
		.endif
	.endif
	ret

AddPath endp

DelPath proc uses esi,hWin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke GetWindowText,hWin,addr buffer,sizeof buffer
	invoke strlen,addr buffer
	.while eax
		.if byte ptr buffer[eax]=='\'
			mov		byte ptr buffer[eax],0
			.break
		.endif
		dec		eax
	.endw
	invoke GetFileAttributes,addr buffer
	.if eax!=INVALID_HANDLE_VALUE
		mov		esi,fn.lpPath
		.while [esi].FILENOTIFYPATH.path
			.if [esi].FILENOTIFYPATH.nCount
				invoke lstrcmpi,addr [esi].FILENOTIFYPATH.path,addr buffer
				or		eax,eax
				je		Found
			.endif
			add		esi,sizeof FILENOTIFYPATH
		.endw
	.endif
	ret
  Found:
	dec		[esi].FILENOTIFYPATH.nCount
	.if ![esi].FILENOTIFYPATH.nCount
		; A path has been removed
		invoke SetNotify
	.endif
	ret

DelPath endp

