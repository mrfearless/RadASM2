;#########################################################################
;	Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;	Include file

include OpenWatcom.inc

.code

;#########################################################################
;	Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD
	
	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx,hWin:DWORD, fOpt:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	; Messages to hook into
	mov		eax,RAM_EDITOPEN
	; ECX and EDX must be null before we return
	xor 	ecx,ecx
	xor 	edx,edx
	ret

InstallDll Endp

DecToBin proc lpStr:DWORD
	LOCAL	fNeg:DWORD

    push    ebx
    push    esi
    mov     esi,lpStr
    mov		fNeg,FALSE
    mov		al,[esi]
    .if al=='-'
		inc		esi
		mov		fNeg,TRUE
    .endif
    xor     eax,eax
  @@:
    cmp     byte ptr [esi],30h
    jb      @f
    cmp     byte ptr [esi],3Ah
    jnb     @f
    mov     ebx,eax
    shl     eax,2
    add     eax,ebx
    shl     eax,1
    xor     ebx,ebx
    mov     bl,[esi]
    sub     bl,30h
    add     eax,ebx
    inc     esi
    jmp     @b
  @@:
	.if fNeg
		neg		eax
	.endif
    pop     esi
    pop     ebx
    ret

DecToBin endp

DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==AIM_EDITOPEN
		push	esi
		invoke GetCommandLine
		mov		esi,eax
		invoke lstrlen,esi
		.if eax
			.while byte ptr [esi+eax-1]>='0' && byte ptr [esi+eax-1]<='9' && eax
				dec		eax
			.endw
			lea		esi,[esi+eax]
			.if byte ptr [esi]>='0' && byte ptr [esi]<='9'
				mov		byte ptr [esi-1],0
				invoke DecToBin,addr [esi]
				invoke SendMessage,wParam,EM_LINEINDEX,eax,0
				ret
			.endif
		.endif
		pop		esi
	.endif
	mov		eax,FALSE
	ret

DllProc Endp

;#########################################################################

End DllEntry
