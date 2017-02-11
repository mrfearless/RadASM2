
StartRecordMacro	PROTO lpszFilename:DWORD,uFlags:DWORD,vStopKey:DWORD
StartPlayMacro		PROTO lpszFilename:DWORD,uFlags:DWORD,vStopKey:DWORD

.const

IDD_DLG_RECORD	equ 3400

.data

szMac			db '\Macro',0
szMacExt		db '.kbm',0

.data?

hHook			dd ?
bPaused			dd ?
hMacFile		dd ?
event			EVENTMSG <?>
dwCount			dd ?
lhWnd			dd ?
_ShowApiList	dd ?

.code

MacroRecord proc
	LOCAL	hFile:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[16]:BYTE
	LOCAL	buffer1[256]:BYTE

	mov		nInx,1
	.while nInx
		invoke BinToDec,nInx,addr buffer
		invoke strcpy,addr buffer1,addr Mac
		invoke strcat,addr buffer1,offset szMac
		invoke strcat,addr buffer1,addr buffer
		invoke strcat,addr buffer1,offset szMacExt
		invoke GetFileAttributes,addr buffer1
		.if eax==-1
			invoke StartRecordMacro,addr buffer1,NULL,NULL
			invoke CreateFile,addr buffer1,GENERIC_READ,FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
			.if eax!=INVALID_HANDLE_VALUE
				mov		hFile,eax
				invoke GetFileSize,hFile,NULL
				push	eax
				invoke CloseHandle,hFile
				pop		eax
				.if eax
					invoke strcpy,addr buffer1,offset szMac+1
					invoke strcat,addr buffer1,addr buffer
					invoke strcat,addr buffer1,offset szMacExt
					invoke ModalDialog,hInstance,IDD_DLGOPTMNU,hWnd,addr MenuOptionProc,addr buffer1
				.endif
			.endif
			mov		nInx,0
		.else
			inc		nInx
		.endif
	.endw
	ret

MacroRecord endp

MacroPlay proc lpMacFile:DWORD
	LOCAL	buffer[256]:BYTE

	push	ShowApiList
	pop		_ShowApiList
	mov		ShowApiList,FALSE
	invoke GetKeyboardState,addr buffer
	lea		eax,buffer
	mov		byte ptr [eax+VK_CONTROL],0
	mov		byte ptr [eax+VK_SHIFT],0
	mov		byte ptr [eax+VK_MENU],0
	invoke SetKeyboardState,addr buffer
	invoke strcpy,addr buffer,offset Mac
	invoke strcat,addr buffer,offset szBackSlash
	invoke strcat,addr buffer,lpMacFile
	invoke StartPlayMacro,addr buffer,NULL,NULL
	ret

MacroPlay endp

DialogProc proc hDlg:DWORD,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	local	buf:DWORD				;buffer for return value

	pushad							;preserve all registers
	mov		buf,TRUE				;default TRUE return value
	mov		eax,uMsg				;use of eax is faster & shorter
	.if eax==WM_INITDIALOG
		invoke SetFocus,hEdit
		invoke SetLanguage,hDlg,IDD_DLG_RECORD,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax				;HIWORD has the action
		shr		edx,16
		and		eax,0ffffh			;LOWORD has the ID
		.if edx == BN_CLICKED		;ButtonClick
			.if eax == IDOK
				call	_Unhook
				call	_CloseHandle
				invoke EndDialog,hDlg,IDOK
			.elseif eax == IDCANCEL
				;We could use here EndDialog too, but for a clean
				;shutdown we send the WM_CLOSE message to ourselfes.
				call	_Unhook
				call	_CloseHandle
				invoke EndDialog, hDlg, NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
		;Do here whatever it needs to close the app, especially 
		;freeing up all dynamic allocated memory, and then end.
		invoke EndDialog,hDlg,NULL
	.else		;we exit from all not handled messages with FALSE
		dec		buf					;TRUE = 1
	.endif
	popad
	mov		eax,buf
	ret

DialogProc	endp

JournalRecordProc proc uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	local	dwBytes:DWORD

	mov		eax,uMsg
	.IF sdword ptr eax<0			;If code is less than zero, the 
									;hook procedure must pass the 
									;message to the CallNextHookEx 
									;function without further 
									;processing and should return 
									;the value returned by 
									;CallNextHookEx.
		invoke	CallNextHookEx,hHook,uMsg,wParam,lParam
		jmp		@F
	.ELSEIF eax==HC_ACTION			;The lParam parameter points to 
									;an EVENTMSG structure containing 
									;information about a message 
									;removed from the system queue. 
									;The hook procedure must record 
									;the contents of the structure by 
									;copying them to a buffer or file.
		.IF !bPaused
			mov		edx,lParam
			assume edx:ptr EVENTMSG
			mov		eax,[edx].message
			.if eax==WM_KEYDOWN || eax==WM_KEYUP || eax==WM_CHAR
				.if eax==WM_KEYDOWN || eax==WM_KEYUP
					mov		eax,[edx].paramL
					movzx	eax,ah
					and		[edx].paramH,0FFFFFF00h
					or		[edx].paramH,eax
				.endif
				invoke WriteFile,hMacFile,lParam,sizeof event,addr dwBytes,NULL
			.endif
		.ENDIF                       
	.ELSEIF eax==HC_SYSMODALOFF		;A system-modal dialog box has 
									;been destroyed. The hook 
									;procedure must resume recording.
		mov		bPaused,FALSE
	.ELSEIF eax==HC_SYSMODALON		;A system-modal dialog box is 
									;being displayed. Until the 
									;dialog box is destroyed, the 
									;hook procedure must stop 
									;recording.
		mov		bPaused,TRUE
	.else
		mov		eax,TRUE
		jmp		@F
	.ENDIF
	xor		eax,eax
  @@:
	assume edx:nothing
	ret

JournalRecordProc	endp

JournalPlaybackProc	proc uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL	dwBytes:DWORD

	mov		eax,uMsg
	.if sdword ptr eax<0			;If code is less than zero, the 
									;hook procedure must pass the 
									;message to the CallNextHookEx 
									;function without further 
									;processing and should return 
									;the value returned by 
									;CallNextHookEx.
		invoke CallNextHookEx,hHook,uMsg,wParam,lParam
		jmp		@F
	.elseif eax==HC_SYSMODALON		;A system-modal dialog box is 
									;being displayed. Until the 
									;dialog box is destroyed, the 
									;hook procedure must stop playing 
									;back messages.
		mov		bPaused,TRUE
	.elseif eax==HC_SYSMODALOFF		;A system-modal dialog 
									;box has been destroyed. 
									;The hook procedure must 
									;resume playing back the 
									;messages.
		mov		bPaused,FALSE
	.elseif eax==HC_SKIP			;The hook procedure must 
									;prepare to copy the next 
									;mouse or keyboard 
									;message to the EVENTMSG 
									;structure pointed to by 
									;lParam. Upon receiving 
									;the HC_GETNEXT code, the 
									;hook procedure must copy 
									;the message to the 
									;structure.  
		mov		bPaused,FALSE
		invoke	ReadFile,hMacFile,addr event,sizeof event,addr dwBytes,NULL
		.if dwBytes!=sizeof event
			call	_CloseHandle
			call	_Unhook
			push	_ShowApiList
			pop		ShowApiList
		.endif
	.elseif eax==HC_NOREMOVE		;An application has called 
									;the PeekMessage function 
									;with wRemoveMsg set to 
									;PM_NOREMOVE, indicating 
									;that the message is not 
									;removed from the message 
									;queue after PeekMessage 
									;processing.
  @@L1:
  		.if !bPaused
			dec		dwCount
			.if CARRY?
				call	_CloseHandle
				call	_Unhook
				push	_ShowApiList
				pop		ShowApiList
			.else
				invoke	GetTickCount
				mov		event.time,eax
;invoke GetFocus
;m2m		event.hwnd,eax
				invoke	RtlMoveMemory,lParam,offset event,sizeof EVENTMSG
			.endif
		.endif
	.elseif eax==HC_GETNEXT			;The hook procedure must 
									;copy the current mouse 
									;or keyboard message to 
									;the EVENTMSG structure 
									;pointed to by the lParam 
									;parameter.
		jmp		@@L1
	.else
		mov		eax,TRUE
		jmp		@F
	.endif
	xor		eax,eax
  @@:
	ret

JournalPlaybackProc	endp

_Record:
	invoke SetWindowsHookEx,WH_JOURNALRECORD,offset JournalRecordProc,hInstance,NULL
	mov		hHook,eax
	retn

_Playback:
	invoke SetWindowsHookEx,WH_JOURNALPLAYBACK,offset JournalPlaybackProc,hInstance,NULL
	mov		hHook,eax
	retn

_Unhook:
	.if hHook
		invoke	UnhookWindowsHookEx,hHook
		mov		hHook,0
	.endif
	retn

_CloseHandle:
	.if hMacFile
		invoke CloseHandle,hMacFile
		mov		hMacFile,0
	.endif
	retn

StartRecordMacro proc lpMacFilename:DWORD,hWin:HWND,vStopKey:DWORD
	LOCAL	buf:DWORD

	pushad
	fldz
	fistp	buf
	call	_Unhook
	call	_CloseHandle
	invoke	CreateFile,lpMacFilename,GENERIC_WRITE,FILE_SHARE_WRITE,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,NULL
	.if eax==INVALID_HANDLE_VALUE
		jmp		@F
	.endif
	mov		hMacFile,eax
	push	hWin
	pop		lhWnd
	call	_Record
	.if hHook
		invoke	ModalDialog,hInstance,IDD_DLG_RECORD,NULL,offset DialogProc,NULL
		mov		buf,eax
	.else
		call	_CloseHandle
	.endif
  @@:
	popad
	push	buf
	pop		eax
	ret

StartRecordMacro	endp

StartPlayMacro proc lpMacFilename:DWORD,hWin:HWND,vStopKey:DWORD
	LOCAL	buf:DWORD

	pushad
	fldz
	fistp	buf
	call	_Unhook
	call	_CloseHandle
	invoke CreateFile,lpMacFilename,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE, NULL
	.if eax==INVALID_HANDLE_VALUE
		jmp		@F
	.endif
	mov		hMacFile,eax
	invoke	GetFileSize,hMacFile,NULL
	mov		dwCount,eax
	fild	dwCount
	mov		dwCount,sizeof EVENTMSG
	fidiv	dwCount
	fistp	dwCount
	sub		dwCount,2
	jle		@F
	push	hWin
	pop		lhWnd
	call	_Playback
	.if hHook
		mov		buf,eax
	.endif
  @@:
	popad
	push	buf
	pop		eax
	ret

StartPlayMacro	endp
