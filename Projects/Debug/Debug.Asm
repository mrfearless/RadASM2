.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include Debug.inc
include Misc.asm
include DebugPdb.asm
include DbgHelp.asm

.code


;########################################################################

Dump proc uses ebx esi edi,lpData:DWORD
	LOCAL	dbgbuffer[256]:BYTE
	LOCAL	buffer[256]:BYTE

	mov		ebx,lpData
	invoke ReadProcessMemory,dbghand,ebx,addr dbgbuffer,256,0
	.if eax
		lea		esi,dbgbuffer
		xor		edx,edx
		.while edx<16
			push	edx
			invoke DumpLine,ebx,esi,16
			add		esi,16
			add		ebx,16
			pop		edx
			inc		edx
		.endw
		mov		dword ptr buffer,0A0Dh
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr buffer
		xor		eax,eax
		inc		eax
	.else
		.while TRUE
			invoke ReadProcessMemory,dbghand,ebx,addr dbgbuffer,1,0
			.break .if !eax
			invoke DumpLine,ebx,addr dbgbuffer,16
			add		ebx,16
		.endw
		xor		eax,eax
	.endif
	ret

Dump endp

PrintSourceByte proc Address:DWORD,SourceByte:DWORD
	LOCAL	buffer[256]:BYTE

	invoke wsprintf,addr buffer,addr szSourceByte,Address,SourceByte
	invoke PutString,addr buffer
	ret

PrintSourceByte endp

SetBreakPointsAll proc uses ebx edi

	mov		edi,offset dbgline
	xor		ebx,ebx
	.while ebx<inxline
		invoke ReadProcessMemory,dbghand,[edi].DEBUGLINE.Address,addr [edi].DEBUGLINE.SourceByte,1,0
		movzx		eax,[edi].DEBUGLINE.SourceByte
		invoke PrintSourceByte,[edi].DEBUGLINE.Address,eax
		invoke WriteProcessMemory,dbghand,[edi].DEBUGLINE.Address,addr szBP,1,0
		add		edi,sizeof DEBUGLINE
		inc		ebx
	.endw
	ret

SetBreakPointsAll endp

RestoreSourceByte proc uses ebx edi,Address:DWORD

	mov		edi,offset dbgline
	mov		eax,Address
	xor		ebx,ebx
	.while ebx<inxline
		.if eax==[edi].DEBUGLINE.Address
			movzx		eax,[edi].DEBUGLINE.SourceByte
			invoke PrintSourceByte,[edi].DEBUGLINE.Address,eax
			invoke WriteProcessMemory,dbghand,Address,addr [edi].DEBUGLINE.SourceByte,1,0
			.break
		.endif
		add		edi,sizeof DEBUGLINE
		inc		ebx
	.endw
	ret

RestoreSourceByte endp

Debug proc lpFileName:DWORD
	LOCAL	sinfo:STARTUPINFO
	LOCAL	de:DEBUG_EVENT
	LOCAL	fContinue:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	Old:BYTE
	LOCAL	context:CONTEXT

	invoke RtlZeroMemory,addr sinfo,sizeof STARTUPINFO
	mov		sinfo.cb,SizeOf STARTUPINFO
	mov		sinfo.dwFlags,STARTF_USESHOWWINDOW
	mov		sinfo.wShowWindow,SW_NORMAL
	;Create process
	invoke CreateProcess,NULL,lpFileName,NULL,NULL,FALSE,NORMAL_PRIORITY_CLASS Or DEBUG_PROCESS Or DEBUG_ONLY_THIS_PROCESS,NULL,NULL,addr sinfo,addr pinfo
	.if eax
		invoke WaitForSingleObject,pinfo.hProcess,10
		invoke OpenProcess,PROCESS_ALL_ACCESS,TRUE,pinfo.dwProcessId
		mov		dbghand,eax
		invoke DbgHelp,pinfo.hProcess
;		mov		edx,offset dbgsource
;		xor		ecx,ecx
;		.while ecx<inxsource
;			push	ecx
;			push	edx
;			invoke PutString,addr [edx].DEBUGSOURCE.FileName
;			pop		edx
;			pop		ecx
;			add		edx,sizeof DEBUGSOURCE
;			inc		ecx
;		.endw
;		mov		edx,offset dbgline
;		xor		ecx,ecx
;		.while ecx<inxline
;			push	ecx
;			push	edx
;			PrintHex [edx].DEBUGLINE.Address
;			pop		edx
;			pop		ecx
;			add		edx,sizeof DEBUGLINE
;			inc		ecx
;		.endw
;		mov		dbgdump,400000h
;		.while eax
;			invoke Dump,dbgdump
;			.if eax
;				add		dbgdump,256
;			.endif
;		.endw
		invoke SetBreakPointsAll
		mov		eax,pinfo.hThread
		mov		threadcontext,eax
		.while TRUE
			invoke WaitForDebugEvent,addr de,INFINITE
			mov		fContinue,DBG_CONTINUE
			mov		eax,de.dwDebugEventCode
			.if eax==EXCEPTION_DEBUG_EVENT
				invoke PutString,addr szEXCEPTION_DEBUG_EVENT
				mov		eax,de.u.Exception.pExceptionRecord.ExceptionCode
				.if eax==EXCEPTION_BREAKPOINT
					.if de.u.Exception.pExceptionRecord.ExceptionAddress<800000h
						invoke PutString,addr szEXCEPTION_BREAKPOINT
;						PrintHex de.u.Exception.pExceptionRecord.ExceptionAddress
						invoke RestoreSourceByte,de.u.Exception.pExceptionRecord.ExceptionAddress
						mov		context.ContextFlags,CONTEXT_CONTROL
						invoke GetThreadContext,threadcontext,addr context
						mov		eax,de.u.Exception.pExceptionRecord.ExceptionAddress
						mov		context.regEip,eax
						invoke SetThreadContext,threadcontext,addr context
						invoke SuspendThread,threadcontext
					.else
						invoke PutString,addr szEXCEPTION_BREAKPOINT
						mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
					.endif
				.elseif eax==EXCEPTION_ACCESS_VIOLATION
					invoke PutString,addr szEXCEPTION_ACCESS_VIOLATION
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.elseif eax==EXCEPTION_FLT_DIVIDE_BY_ZERO
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.elseif eax==EXCEPTION_INT_DIVIDE_BY_ZERO
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.elseif eax==EXCEPTION_DATATYPE_MISALIGNMENT
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.elseif eax==EXCEPTION_SINGLE_STEP
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.elseif eax==DBG_CONTROL_C
				.else
					invoke ReadProcessMemory,dbghand,de.u.Exception.pExceptionRecord.ExceptionAddress,addr Old,1,0
					movzx		eax,Old
					invoke PrintSourceByte,de.u.Exception.pExceptionRecord.ExceptionAddress,eax
					mov		fContinue,DBG_EXCEPTION_NOT_HANDLED
				.endif
			.elseif eax==CREATE_PROCESS_DEBUG_EVENT
				invoke PutString,addr szCREATE_PROCESS_DEBUG_EVENT
			.elseif eax==CREATE_THREAD_DEBUG_EVENT
				invoke PutString,addr szCREATE_THREAD_DEBUG_EVENT
			.elseif eax==EXIT_THREAD_DEBUG_EVENT
				invoke PutString,addr szEXIT_THREAD_DEBUG_EVENT
			.elseif eax==EXIT_PROCESS_DEBUG_EVENT
				invoke PutString,addr szEXIT_PROCESS_DEBUG_EVENT
				invoke ContinueDebugEvent,de.dwProcessId,de.dwThreadId,DBG_CONTINUE
				.break
			.elseif eax==LOAD_DLL_DEBUG_EVENT
				mov		buffer,0
				;invoke GetModuleFileName,de.LoadDll.lpBaseOfDll,addr buffer,256
				invoke PutString,addr szLOAD_DLL_DEBUG_EVENT
				;invoke PutString,addr buffer
			.elseif eax==UNLOAD_DLL_DEBUG_EVENT
				mov		buffer,0
				;invoke GetModuleFileName,de.UnloadDll.lpBaseOfDll,addr buffer,256
				invoke PutString,addr szUNLOAD_DLL_DEBUG_EVENT
				;invoke PutString,addr buffer
			.elseif eax==OUTPUT_DEBUG_STRING_EVENT
				invoke PutString,addr szOUTPUT_DEBUG_STRING_EVENT
;				nln=de.DebugString.nDebugStringLength
;				If nln>255 Then
;					nln=255
;				EndIf
;				lret=ReadProcessMemory(dbghand,de.DebugString.lpDebugStringData,@buffer,nln,0)
;				PutString(@buffer)
			.elseif eax==RIP_EVENT
				invoke PutString,addr szRIP_EVENT
			.endif
			invoke ContinueDebugEvent,de.dwProcessId,de.dwThreadId,fContinue
		.endw
	.endif
	invoke CloseHandle,pinfo.hThread
	invoke CloseHandle,pinfo.hProcess
	invoke CloseHandle,dbghand
	invoke CloseHandle,hDbgThread
	mov		hDbgThread,0
	ret

Debug endp

CldDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tid:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hCldDlg,eax
		invoke SetCurrentStream
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWnd,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNBROWSE
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,offset szPDBFilterString
				mov		buffer[0],0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.lpstrDefExt,NULL
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
					invoke CloseStreams
					invoke OpenPdbFile,addr buffer
					invoke SetCurrentStream
					invoke DumpStream,offset stream,0
				.endif
			.elseif eax==IDC_BTNPREVIOUS
				.if nCurrentStream
					dec		nCurrentStream
					invoke SetCurrentStream
					mov		eax,nCurrentStream
					mov		edx,offset stream
					lea		edx,[edx+eax*sizeof STREAM]
					invoke DumpStream,edx,eax
				.endif
			.elseif eax==IDC_BTNNEXT
				mov		eax,nCurrentStream
				inc		eax
				.if eax<nStreams
					inc		nCurrentStream
					invoke SetCurrentStream
					mov		eax,nCurrentStream
					mov		edx,offset stream
					lea		edx,[edx+eax*sizeof STREAM]
					invoke DumpStream,edx,eax
				.endif
			.elseif eax==IDC_BTNSAVE
				.if nStreams
					invoke SaveStream,nCurrentStream
				.endif
			.elseif eax==IDC_BTNDEBUG
				invoke CreateThread,NULL,0,addr Debug,addr szFileName,NULL,addr tid
				mov		hDbgThread,eax
;				invoke DbgHelp,0
			.elseif eax==IDC_BTNDEBUGNEXT
				.if hDbgThread
					invoke ResumeThread,threadcontext
				.endif
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

CldDlgProc endp

DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	cldrect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_REDDEBUG
		mov		hEdt,eax
		invoke CreateFontIndirect,addr Courier_New_10
		mov		hFont,eax
		invoke SendMessage,hEdt,WM_SETFONT,hFont,FALSE
		invoke SendMessage,hEdt,EM_EXLIMITTEXT,0,1024*1024
		invoke CreateDialogParam,hInstance,IDD_DLGCHILD,hWin,addr CldDlgProc,0
	.elseif eax==WM_SIZE
		; Move and size the rich edit control
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.bottom
		sub		eax,70
		invoke MoveWindow,hEdt,0,0,rect.right,eax,TRUE
		; Move the cild dialog
		invoke GetClientRect,hCldDlg,addr cldrect
		mov		eax,rect.bottom
		sub		eax,65
		mov		edx,rect.right
		sub		edx,cldrect.right
		invoke MoveWindow,hCldDlg,edx,eax,cldrect.right,cldrect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke CloseStreams
		invoke DeleteObject,hFont
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
	invoke LoadLibrary,addr RichEditDLL
	.if eax
		mov		hRichEdDLL,eax
		invoke LoadLibrary,addr DbgHelpDLL
		.if eax
			mov		hDbgHelpDLL,eax
			invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
			invoke FreeLibrary,hDbgHelpDLL
		.endif
		invoke FreeLibrary,hRichEdDLL
	.endif
	invoke ExitProcess,0

end start
