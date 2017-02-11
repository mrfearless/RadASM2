;######################################################################

.386
.model flat, stdcall
option casemap:none

;######################################################################

include		windows.inc

include		kernel32.inc
include		user32.inc

include		C:\RadASM\Masm\Inc\RadAsm.inc

includelib	kernel32.lib
includelib	user32.lib

;######################################################################

.data
	strPath		db "Project Timer", 0
	strIni		db "PTimer", 0
	strMsg		db "You have worked on this project for ", 0
	strHours	db "h : ", 0
	strMinutes	db " min", 0

.data?
	hInstance	dd ?
	hData		dd ?
	hHandles	dd ?
	SetupID		dd ?
	nTicks		dd ?
	strBuffer	db 128 dup(?)

.code
;######################################################################

DllEntry	PROC hInst :DWORD, Reason :DWORD, Reserved1 :DWORD
	mov eax, hInst
	mov hInstance, eax
	xor eax, eax
	inc eax
	ret
DllEntry	ENDP

InstallDll	PROC hWin :DWORD, fOpt :DWORD

	LOCAL hSubMenu	:DWORD

	;===================
	; INJECT MENU ITEMS
	;===================
	xor eax, eax

	push eax
	push eax
	push AIM_GETHANDLES
	push hWin

	push eax
	push eax
	push AIM_GETMENUID
	push hWin

	push eax
	push eax
	push AIM_GETDATA
	push hWin

	call SendMessage
	mov hData, eax
	call SendMessage
	mov SetupID, eax
	call SendMessage
	mov hHandles, eax
	ASSUME eax : PTR ADDINHANDLES
	invoke GetSubMenu, [eax].hMenu, 4
	mov hSubMenu, eax
	ASSUME eax : NOTHING
	invoke InsertMenu, hSubMenu, 16, MF_STRING or MF_BYPOSITION, SetupID, offset strPath
	invoke InsertMenu, hSubMenu, 16, MF_SEPARATOR or MF_BYPOSITION, 0, 0

	;========
	; RETURN
	;========
	mov eax, RAM_COMMAND or RAM_INITMENUPOPUP or RAM_PROJECTOPENED or AIM_PROJECTCLOSE
	ret
InstallDll	ENDP

num2str	PROC USES esi edi ebx, lpString :DWORD, Number :DWORD

	;//CONVERT NUMBER TO STRING
	mov edi, lpString
	mov ebx, 10
	mov ecx, edi
	mov eax, Number
	@@:
		xor edx, edx
		div ebx
		add edx, 48
		mov BYTE PTR [edi], dl
		inc edi
	test eax, eax
	jnz @B
	sub edi, ecx
	xchg ecx, edi

	mov ebx, edi
	inc ebx
	dec ecx
	jz _num2str_end

	;//REVERSE THE STRING
	mov esi, edi
	add ebx, ecx
	add esi, ecx
	@@:
		mov al, BYTE PTR [esi]
		xchg BYTE PTR[edi], al
		mov BYTE PTR [esi], al
	dec esi
	inc edi
	cmp esi, edi
	jg @B

	_num2str_end:
	mov BYTE PTR [ebx], 0
	mov eax, lpString
	ret

num2str	ENDP

strvalA	PROC lpString :DWORD

	mov edx, lpString
	xor ecx, ecx
	xor eax, eax

	@@:
		mov cl, BYTE PTR [edx]
		test ecx, ecx
		jz @F
			lea eax, [eax*4+eax-24]
			inc edx
			lea eax, [eax*2+ecx]
		jmp @B
	@@:
	ret

strvalA	ENDP

DllProc PROC hWin :DWORD, uMsg :DWORD, wParam :DWORD, lParam :DWORD
	mov eax, uMsg
	.if eax == AIM_COMMAND
		;=============
		; AIM_COMMAND
		;=============
		mov eax, wParam
		.if eax == SetupID
			;===================
			; MENU ITEM CLICK
			;===================
			invoke lstrcpy, offset strBuffer, offset strMsg
			mov edx, hData
			ASSUME edx : PTR ADDINDATA
			push nTicks
			invoke GetPrivateProfileInt, offset strIni, offset strIni, 0, [edx].lpProject
			push eax
			invoke GetTickCount
			sub eax, nTicks
			pop ecx
			add eax, ecx
			pop nTicks
			mov ecx, 1000 * 60 
			xor edx, edx
			div ecx
			mov ecx, 60
			xor edx, edx
			div ecx
			push edx
			invoke num2str, offset strBuffer + 36, eax
			invoke lstrlen, offset strBuffer
			add eax, offset strBuffer
			invoke lstrcat, eax, offset strHours
			invoke lstrlen, offset strBuffer
			add eax, offset strBuffer
			pop edx
			invoke num2str, eax, edx
			invoke lstrlen, offset strBuffer
			add eax, offset strBuffer
			invoke lstrcat, eax, offset strMinutes
			invoke MessageBox, 0, offset strBuffer, offset strPath, MB_OK or MB_ICONINFORMATION
			xor eax, eax
			inc eax
			ret
		.endif
	.elseif eax == AIM_INITMENUPOPUP
		;===================
		; AIM_INITMENUPOPUP
		;===================
		mov eax, hData
		ASSUME eax : PTR ADDINDATA
		mov ecx, [eax].fProject
		and ecx, 1
		xor ecx, 1
		mov eax, hHandles
		ASSUME eax : PTR ADDINHANDLES
		invoke EnableMenuItem, [eax].hMenu, SetupID, ecx
		ASSUME eax : NOTHING
	.elseif eax == AIM_PROJECTOPENED
		invoke GetTickCount
		mov nTicks, eax
		xor eax, eax
		ret
	.elseif eax == AIM_PROJECTCLOSE
		invoke GetTickCount
		sub nTicks, eax
		neg nTicks
		mov edx, hData
		ASSUME edx : PTR ADDINDATA
		invoke GetPrivateProfileInt, offset strIni, offset strIni, 0, [edx].lpProject
		add eax, nTicks
		invoke num2str, offset strBuffer, eax
		mov edx, hData
		invoke WritePrivateProfileString, offset strIni, offset strIni, offset strBuffer, [edx].lpProject
		ASSUME edx : NOTHING
		xor eax, eax
		ret
	.endif
	xor eax, eax
	ret
DllProc	ENDP
;######################################################################
end DllEntry