;######################################################################

.386
.model flat, stdcall
option casemap:none

;######################################################################

include		windows.inc

include		kernel32.inc
include		user32.inc
include		shell32.inc

includelib	kernel32.lib
includelib	user32.lib
includelib	shell32.lib

include		c:\radasm\masm\inc\radasm.inc

include		strings.asm

;######################################################################

RunAsmVars				PROTO
Shell					PROTO	:DWORD,:DWORD

ADDINOPT struct
	lpStr		dd ?
	nAnd		dd ?
	nOr			dd ?
ADDINOPT ends

;######################################################################

.data
	lpData		dd 0
	strAVPath	db "\asmvars\asmvars.exe ", 0
	strIniSect	db "Files", 0
	strKey		db "1", 0
	strMenuText	db "AsmVars", 0
	strFILE		db " FILE: ",0
	strQuote	db '"', 0
	strOption	db "Enable AsmVars",0
	AddinOpt	ADDINOPT <offset strOption,1,1>
				ADDINOPT <0,0,0>

.data?
	sat			SECURITY_ATTRIBUTES <?>
	StartupInfo	STARTUPINFO <?>
	ProcessInfo	PROCESS_INFORMATION <?>
	hInstance	dd ?
	lpProcs		dd ?
	lpHandles	dd ?
	hSubMenu	dd ?
	AsmVarsID	dd ?

.code

;######################################################################

DllEntry	PROC hInst :DWORD, reason :DWORD, reserved1 :DWORD
    mov eax, hInst
    mov hInstance, eax
    xor eax, eax
    inc eax
    ret
DllEntry	ENDP

InstallDll	PROC hWin :DWORD, fOpt :DWORD
	mov eax,fOpt
	or eax,eax
	jz @f
		invoke SendMessage, hWin, AIM_GETPROCS, 0, 0
		mov lpProcs, eax
		invoke SendMessage, hWin, AIM_GETDATA, 0, 0
		mov lpData, eax
		mov ecx, 4
		add ecx, [eax].ADDINDATA.fMaximized
		push ecx
		invoke SendMessage, hWin, AIM_GETMENUID, 0, 0
		mov AsmVarsID, eax
		invoke SendMessage, hWin, AIM_GETHANDLES, 0, 0
		mov lpHandles, eax
		push [eax].ADDINHANDLES.hMenu
		call GetSubMenu
		mov hSubMenu, eax
		invoke AppendMenu, eax, MF_STRING, AsmVarsID, offset strMenuText
		mov eax, RAM_COMMAND or RAM_INITMENUPOPUP or RAM_CLOSE
  @@:
	mov ecx,RAM_ADDINSLOADED
	xor edx,edx
	ret
InstallDll	ENDP

GetOptions proc
	mov eax,offset AddinOpt
	ret
GetOptions endp

DllProc	PROC hWin :DWORD, uMsg :DWORD, wParam :DWORD, lParam :DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	mnui:MENUITEMINFO

	cmp uMsg, AIM_COMMAND
	jnz @F
		mov eax, wParam
		cmp AsmVarsID, eax
		jnz _end
			invoke RunAsmVars
			xor eax, eax
			inc eax
			ret
	@@:
	cmp uMsg, AIM_CLOSE
	jnz @F
		mov edx,lpHandles
		mov eax,[edx].ADDINHANDLES.hMenu
		invoke DeleteMenu,eax,AsmVarsID,MF_BYCOMMAND
		jmp _end
	@@:
	cmp uMsg, AIM_INITMENUPOPUP
	jnz @F
		mov eax, lpData
		mov eax, [eax].ADDINDATA.fProject
		xor eax, 1
		or eax, MF_BYCOMMAND
		invoke EnableMenuItem, hSubMenu, AsmVarsID, eax
		jmp _end
	@@:
	cmp uMsg, AIM_ADDINSLOADED
	jnz _end
		push sizeof buffer/2
		lea eax,buffer
		push eax
		push 2000
		push offset strMenuText
		mov eax,lpProcs
		call [eax].ADDINPROCS.lpGetLangString
		or eax,eax
		jz _end
			mov mnui.cbSize,sizeof mnui
			mov mnui.fMask,MIIM_TYPE
			mov mnui.fType,MFT_STRING
			lea eax,buffer
			mov mnui.dwTypeData,eax
			;Insert our menuitem
			mov edx,[lpHandles]
			invoke SetMenuItemInfoW,(ADDINHANDLES ptr [edx]).hMenu,AsmVarsID,FALSE,addr mnui
	_end:
	xor eax, eax
	ret
DllProc	ENDP

ParseFile proc uses esi edi, lpMem:DWORD

	mov esi, lpMem
	mov edi, esi
	.while byte ptr [esi]
		call IsLineFILE
		.if ZERO?
			;Skip FILE:
			add esi, 7
			;Copy file name
			call CopyToSpc
			;Skip LINE:
			add esi,6
			mov byte ptr [edi], '('
			inc edi
			;Copy line number
			call CopyToSpc
			mov word ptr [edi], ' )'
			inc edi
			inc edi
		.endif
		call CopyLine
	.endw
	mov byte ptr [edi], 0
	ret

CopyToSpc:
	mov al, [esi]
	inc esi
	cmp al, ' '
	jz @f
	mov [edi], al
	inc edi
	or al, al
	jnz CopyToSpc
  @@:
	retn

IsLineFILE:
	push esi
	push edi
	mov edi, offset strFILE-1
	dec esi
  @@:
	inc esi
	inc edi
	mov al, [edi]
	or al, al
	jz @f
	cmp al, [esi]
	jz @b
  @@:
	pop edi
	pop esi
	retn

CopyLine:
	mov al, [esi]
	mov [edi], al
	inc esi
	inc edi
	cmp al, 0Ah
	jz @f
	or al, al
	jnz CopyLine
  @@:
	retn

ParseFile endp

RunAsmVars	PROC uses ebx

	LOCAL Info				:DWORD
	LOCAL InfoH				:DWORD
	LOCAL LocalBuffer[256]	:BYTE
	LOCAL Buffer2[256]		:BYTE

	invoke GetCursor
	push eax
	invoke LoadCursor, NULL, IDC_WAIT
	invoke SetCursor, eax
	invoke GlobalAlloc, GMEM_MOVEABLE or GMEM_ZEROINIT, 64*1024
	mov InfoH, eax
	invoke GlobalLock, eax
	mov Info, eax
	mov ebx, lpData
	invoke lstrcpy, ADDR Buffer2, ADDR strQuote
	invoke lstrcat, ADDR Buffer2, [ebx].ADDINDATA.lpProjectPath
	invoke GetPrivateProfileString, offset strIniSect, offset strKey, NULL, ADDR LocalBuffer, 256, [ebx].ADDINDATA.lpProject
	invoke lstrcat, ADDR Buffer2, ADDR LocalBuffer
	lea eax, Buffer2
	inc eax
	invoke GetShortPathName, eax, eax, 255
	invoke lstrcat, ADDR Buffer2, ADDR strQuote
	invoke lstrcpy, ADDR LocalBuffer, [ebx].ADDINDATA.lpAddIn
	invoke GetShortPathName, ADDR LocalBuffer, ADDR LocalBuffer, 256
	invoke lstrcat, ADDR LocalBuffer, offset strAVPath
	invoke lstrcat, ADDR LocalBuffer, ADDR Buffer2
	invoke Shell, ADDR LocalBuffer, Info
	invoke ParseFile, Info
	mov ebx, lpProcs
	push 2
	call [ebx].ADDINPROCS.lpOutputSelect
	call [ebx].ADDINPROCS.lpClearOut
	push Info
	call [ebx].ADDINPROCS.lpTextOut
	invoke GlobalUnlock, InfoH
	invoke GlobalFree, InfoH
	mov		ebx, lpData
	.if [ebx].ADDINDATA.nRadASMVer >= 2013
		;RadASM 2.0.1.3
		;Enable dblclick in output window
		mov [ebx].ADDINDATA.AsmFlag, TRUE
	.endif
	pop eax
	invoke SetCursor, eax
	ret
RunAsmVars	ENDP

Shell	PROC CommandLine :DWORD, lpMem :DWORD

	LOCAL ExitCode	:DWORD
	LOCAL hRead		:DWORD
	LOCAL hWrite	:DWORD
	LOCAL bytesRead	:DWORD

	mov sat.nLength, sizeof SECURITY_ATTRIBUTES
	mov sat.lpSecurityDescriptor, NULL
	mov sat.bInheritHandle, TRUE
	invoke CreatePipe,addr hRead,addr hWrite,offset sat,64*1024
	test eax, eax
	jz _exit
	mov StartupInfo.cb, sizeof STARTUPINFO
	invoke GetStartupInfo,offset StartupInfo
	mov eax, hRead
	mov StartupInfo.hStdInput, eax
	mov eax, hWrite
	mov StartupInfo.hStdOutput, eax
	mov StartupInfo.hStdError, eax
	mov StartupInfo.dwFlags, STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES
	mov StartupInfo.wShowWindow, SW_HIDE
	invoke CreateProcess, NULL, CommandLine, NULL, NULL, TRUE, NULL, NULL, NULL, offset StartupInfo, offset ProcessInfo
	test eax, eax
	jz _close
	@@:
	invoke Sleep, 1
	invoke GetExitCodeProcess, ProcessInfo.hProcess, ADDR ExitCode
	cmp ExitCode, STILL_ACTIVE
	jz @b
	invoke ReadFile, hRead, lpMem, 64*1024, ADDR bytesRead, NULL
	_close:
	invoke CloseHandle, hWrite
	invoke CloseHandle, hRead
	_exit:
	ret
Shell	ENDP
;######################################################################
end DllEntry