;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include Collapse.inc

.code

BinToDec proc dwVal:DWORD,lpAscii:DWORD

    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:      
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

BinToDec endp

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

GetItem proc lpSource:DWORD,lpDest:DWORD

	push	esi
	push	edi
	mov		esi,lpSource
	mov		edi,lpDest
  @@:
	mov		al,[esi]
	cmp		al,','
	jz		@f
	or		al,al
	jz		@f
	mov		[edi],al
	inc		esi
	inc		edi
	jmp		@b
  @@:
	or		al,al
	jz		@f
	inc		esi
	mov		al,0
  @@:
	mov		[edi],al
	mov		eax,edi
	sub		eax,lpDest
	push	eax
	mov		edi,lpSource
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jnz		@b
	pop		eax
	pop		edi
	pop		esi
	ret

GetItem endp

PutItem proc uses edi,Value:DWORD,lpDest:DWORD,fComma:DWORD
	LOCAL	buff[16]:BYTE

	mov		buff,0
	.if Value
		invoke BinToDec,Value,addr buff
	.endif
	invoke lstrlen,lpDest
	mov		edi,lpDest
	add		edi,eax
	invoke lstrcpy,edi,addr buff
	.if fComma
		invoke lstrlen,addr buff
		add		edi,eax
		mov		word ptr [edi],','
	.endif
	ret

PutItem endp

CollapseBlock proc uses esi,hWin:HWND,nLine:DWORD

	mov		esi,lpData
	mov		esi,[esi].ADDINDATA.lpRABlockdef
	.while [esi].RABLOCKDEF.lpszStart
		invoke SendMessage,hWin,REM_ISLINE,nLine,[esi].RABLOCKDEF.lpszStart
		.if eax!=-1
			invoke SendMessage,hWin,REM_COLLAPSE,nLine,esi
		  .break
		.endif
		add		esi,sizeof RABLOCKDEF
	.endw
	ret

CollapseBlock endp

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
	.if eax>=2201
		mov		eax,RAM_EDITOPEN or RAM_EDITCLOSE
	.else
		;Don't hook anything
		xor		eax,eax
	.endif
	; ECX and EDX must be null before we return
	xor		ecx,ecx
	xor		edx,edx
	ret 

InstallDll Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov		eax,uMsg
	.if eax==AIM_EDITCLOSE
		;Get project FileID
		invoke GetWindowLong,hWin,16
		.if eax
			mov		buffer,0
			invoke BinToDec,eax,addr szKey
			push	ebx
			push	esi
			push	edi
			mov		ebx,-1
			xor		edi,edi
		  @@:
			shl		edi,1
			and		edi,7FFFFFFFh
			.if !edi
				.if ebx!=-1
					invoke PutItem,esi,addr buffer,TRUE
				.else
					invoke SendMessage,wParam,EM_GETLINECOUNT,0,0
					mov		ebx,eax
				.endif
				xor		esi,esi
				inc		edi
			.endif
			invoke SendMessage,wParam,REM_PRVBOOKMARK,ebx,1
			push	eax
			invoke SendMessage,wParam,REM_PRVBOOKMARK,ebx,2
			pop		edx
			or		esi,edi
			.if sdword ptr edx>=eax
				mov		eax,edx
				xor		esi,edi
			.endif
			mov		ebx,eax
			cmp		ebx,-1
			jne		@b
			invoke PutItem,esi,addr buffer,FALSE
			pop		edi
			pop		esi
			pop		ebx
			mov		eax,lpData
			mov		eax,[eax].ADDINDATA.lpProject
			invoke WritePrivateProfileString,addr szCollapse,addr szKey,addr buffer,eax
		.endif
	.elseif eax==AIM_EDITOPEN
		;Get project FileID
		invoke GetWindowLong,hWin,16
		.if eax
			invoke BinToDec,eax,addr szKey
			mov		eax,lpData
			mov		eax,[eax].ADDINDATA.lpProject
			invoke GetPrivateProfileString,addr szCollapse,addr szKey,addr szNULL,addr buffer,sizeof buffer,eax
			.if eax
				push	ebx
				invoke SendMessage,wParam,EM_GETLINECOUNT,0,0
				invoke SendMessage,wParam,REM_PRVBOOKMARK,eax,1
				mov		ebx,eax
				.while byte ptr buffer
					invoke GetItem,addr buffer,addr szKey
					invoke DecToBin,addr szKey
					xor		ecx,ecx
					.while ecx<31
						shr		eax,1
						push	eax
						push	ecx
						.if CARRY?
							invoke CollapseBlock,wParam,ebx
						.endif
						invoke SendMessage,wParam,REM_PRVBOOKMARK,ebx,1
						mov		ebx,eax
						pop		ecx
						pop		eax
						inc		ecx
						cmp		ebx,-1
						je		@f
					.endw
				.endw
			  @@:
				pop		ebx
			.endif
		.endif
	.endif
	mov		eax,FALSE
	ret

DllProc Endp

;#########################################################################

End DllEntry
