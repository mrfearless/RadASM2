#Include "D:\RadASM\GoAsm\Inc\RadAsm.inc"

wsprintf = wsprintfA
SendMessage = SendMessageA

.data
	hInstance		DD		0
	lpProcs			DD		0

	BeginTick		DD		0
	buffer			DB		32 DUP (?)
	fmt				DB		"Total compile time %u ms",0

.code

DllEntryPoint	FRAME hInst, reason, reserved1
    mov eax,[hInst]
    mov [hInstance], eax
    xor eax, eax
    inc eax
    ret
ENDF

InstallDll	FRAME hWin, fOpt

	invoke SendMessage, [hWin], AIM_GETPROCS, 0, 0
	mov [lpProcs], eax
	xor ecx,ecx
	xor edx,edx
	mov eax, RAM_MAKEDONE | RAM_MAKEBEGIN
	ret
ENDF

DllProc	FRAME hWin, uMsg, wParam, lParam

	cmp D[uMsg], AIM_MAKEBEGIN
	jnz >.AIM_MAKEDONE
		invoke GetTickCount
		mov [BeginTick],eax
		xor eax, eax
		ret

	.AIM_MAKEDONE
	cmp D[uMsg], AIM_MAKEDONE
	jnz >.ExitMsgLoop
		invoke GetTickCount
		sub eax,[BeginTick]
		invoke wsprintf,offset buffer,offset fmt,eax
		add esp,12
		invoke OutputText,offset buffer

	.ExitMsgLoop
	xor eax, eax
	ret
ENDF

OutputText FRAME pString

	pushad
	push  [pString]
	mov   eax,[lpProcs]
	call  [eax+ADDINPROCS.lpTextOut]
	popad
	ret

ENDF