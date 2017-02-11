
.const

RADMEM struct
	ft				FILETIME <?>
	changed			dd ?
RADMEM ends

binDecade	dd 3B9ACA00h
			dd 05F5E100h
			dd 00989680h
			dd 000F4240h
			dd 000186A0h
			dd 00002710h
			dd 000003E8h
			dd 00000064h
			dd 0000000Ah
			dd 00000001h
szFiles		db 'Files',0
szRADbg		db 'RADbg ',0
szInt3		db 'int 3',0
szHlaInt3	db 'int (3',0
szFBInt3	db 'asm int 3',0

.data?

szNULL		db ?
FileName	db 256 dup(?)
Files		db 16384 dup(?)

.code

DwToAscii proc pDW:DWORD,lpStr:DWORD

    push    ebx
    push    ecx
    push    edx
    push    esi
    push    edi
    mov     edi,lpStr
    mov     esi,offset binDecade
    mov     eax,pDW
	.if sdword ptr eax<0
		neg		eax
		mov		byte ptr [edi],'-'
		inc		edi
	.endif
    mov     edx,0
    mov     ecx,9
DwToAscii1:
    mov     bl,2fh
  @@:
    inc     bl
    sub     eax,dword ptr [esi]
    jnb     @b
    add     eax,dword ptr [esi]
    mov     [edi],bl
    add     esi,4
    cmp     bl,30h
    jz      @f
    mov     edx,1
  @@:
    add     edi,edx
    loop    DwToAscii1
    add     al,30h
    mov     [edi],al
    inc     edi
    mov     byte ptr [edi],0
    pop     edi
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    ret

DwToAscii endp

DwToHex proc pDW:DWORD,lpHex:DWORD

	mov		edx,lpHex
	mov		ecx,8
	mov		eax,pDW
  @@:
	rol		eax,4
	push	eax
	call	HexOut
	pop		eax
	dec		ecx
	jne		@b
	mov		byte ptr [edx],0
	ret

HexOut:
	and		al,0Fh
	.if al>9
		add		al,'A'-10
	.else
		add		al,'0'
	.endif
	mov		[edx],al
	inc		edx
	retn

DwToHex endp

DwToBin proc pDW:DWORD,lpBin:DWORD

	mov		edx,lpBin
	mov		ecx,32
	mov		eax,pDW
  @@:
	rol		eax,1
	push	eax
	call	BinOut
	mov		eax,ecx
	and		eax,7
	dec		eax
	.if ZERO?
		mov		word ptr [edx],' '
		inc		edx
	.endif
	pop		eax
	dec		ecx
	jne		@b
	mov		byte ptr [edx],0
	ret

BinOut:
	and		al,01h
	or		al,'0'
	mov		[edx],al
	inc		edx
	retn

DwToBin endp

;Set state to not processed
ResetBreakPoints proc

	mov		edx,lpDStruct
	mov		edx,[edx].ADDINDATA.lpBreakPoint
	mov		ecx,256
	.while ecx
		.if dword ptr [edx]
			mov		dword ptr [edx+8],3
		.endif
		add		edx,12
		dec		ecx
	.endw
	ret

ResetBreakPoints endp

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
		mov		[eax].RADMEM.changed,FALSE
	.endif
	ret

UpdateFileTime endp

;Process the breakpoints in a file
ProcessFile proc uses ecx esi edi,nID:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hFile:DWORD
	LOCAL	hRdMem:DWORD
	LOCAL	hWrMem:DWORD
	LOCAL	rdbytes:DWORD
	LOCAL	nBP:DWORD
	LOCAL	hWin:HWND

	mov		hWin,0
	mov		edx,nID
	.if sdword ptr edx<0
		and		edx,3FFh
		invoke DwToAscii,edx,addr buffer
		mov		edx,lpDStruct
		mov		edx,[edx].ADDINDATA.lpProject
		invoke GetPrivateProfileString,offset szFiles,addr buffer,offset szNULL,addr buffer,sizeof buffer,edx
		.if eax
			mov		edx,lpDStruct
			mov		edx,[edx].ADDINDATA.lpProjectPath
			invoke lstrcpy,offset FileName,edx
			invoke lstrcat,offset FileName,addr buffer
			xor		eax,eax
			inc		eax
		.endif
	.else
		invoke GetParent,edx
		.if eax
			mov		hWin,eax
			mov		edx,eax
			invoke GetWindowText,edx,offset FileName,sizeof FileName
			xor		eax,eax
			inc		eax
		.endif
	.endif
	.if eax
		invoke CreateFile,offset FileName,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke GetFileSize,hFile,NULL
			push	eax
			inc		eax
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			invoke GlobalLock,eax
			mov		hRdMem,eax
			pop		edx
			push	edx
			invoke ReadFile,hFile,hRdMem,edx,addr rdbytes,NULL
			invoke CloseHandle,hFile
			pop		eax
			add		eax,4096
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			invoke GlobalLock,eax
			mov		hWrMem,eax
			mov		esi,hRdMem
			mov		edi,hWrMem
			xor		ecx,ecx
		  @@:
			call GetNextBP
			mov		nBP,eax
			.while ecx<edx
				call CopyLine
				or		eax,eax
				je		@f
				inc		ecx
			.endw
			call InsertBP
			jmp		@b
		  @@:
			invoke CreateFile,offset FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
			mov		hFile,eax
			mov		edx,edi
			sub		edx,hWrMem
			dec		edx
			invoke WriteFile,hFile,hWrMem,edx,addr rdbytes,NULL
			invoke CloseHandle,hFile
			.if hWin
				invoke UpdateFileTime,hWin
			.endif
			invoke GlobalUnlock,hWrMem
			invoke GlobalFree,hWrMem
			mov		eax,hRdMem
		.endif
	.endif
	mov		edx,hWin
	ret

InsertBP:
	push	ecx
	.if fInt3
		mov		eax,lpDStruct
		.if [eax].ADDINDATA.nAsm==nHLA
			invoke lstrcpy,edi,offset szHlaInt3
		.elseif [eax].ADDINDATA.nAsm==nBCET
			invoke lstrcpy,edi,offset szFBInt3
		.else
			invoke lstrcpy,edi,offset szInt3
		.endif
	.else
		invoke lstrcpy,edi,offset szRADbg
		invoke lstrlen,edi
		add		edi,eax
		mov		eax,lpDStruct
		.if [eax].ADDINDATA.nAsm==nHLA || [eax].ADDINDATA.nAsm==nGOASM
			mov		byte ptr [edi],'('
			inc		edi
		.endif
		invoke DwToAscii,nBP,edi
		invoke lstrlen,edi
		add		edi,eax
		mov		byte ptr [edi],','
		inc		edi
		invoke DwToAscii,hWnd,edi
		invoke lstrlen,edi
		add		edi,eax
		mov		byte ptr [edi],','
		inc		edi
		push	esi
		mov		esi,lpDStruct
		mov		esi,[esi].ADDINDATA.lpBreakPointVar
		mov		edx,nBP
		inc		edx
		.while dword ptr [esi]
			.if edx==dword ptr [esi]
				add		esi,4
				invoke lstrcpy,edi,esi
				jmp		@f
			.endif
			add		esi,4
			push	edx
			add		esi,4
			invoke lstrlen,esi
			add		esi,eax
			inc		esi
			pop		edx
		.endw
		mov		word ptr [edi],'0'
	  @@:
		pop		esi
	.endif
	invoke lstrlen,edi
	add		edi,eax
	mov		eax,lpDStruct
	.if [eax].ADDINDATA.nAsm==nHLA
		mov		word ptr [edi],';)'
		add		edi,2
	.elseif [eax].ADDINDATA.nAsm==nGOASM
		mov		byte ptr [edi],')'
		add		edi,1
	.endif
	mov		dword ptr [edi],0A0Dh
	add		edi,2
	pop		ecx
	retn

CopyLine:
	xor		eax,eax
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	je		@f
	cmp		al,0Ah
	jne		@b
  @@:
	retn

GetNextBP:
	push	ecx
	push	esi
	push	edi
	mov		esi,lpDStruct
	mov		esi,[esi].ADDINDATA.lpBreakPoint
	push	esi
	mov		edx,-1
	xor		edi,edi
	mov		eax,nID
	mov		ecx,256
  GetNextBP1:
	cmp		eax,[esi]
	jne		@f
	cmp		dword ptr [esi+8],3
	jne		@f
	cmp		edx,[esi+4]
	jb		@f
	mov		edx,[esi+4]
	mov		edi,esi
  @@:
	add		esi,12
	dec		ecx
	jne		GetNextBP1
	pop		eax
	.if edi
		push	edx
		mov		dword ptr [edi+8],2
		sub		eax,edi
		neg		eax
		xor		edx,edx
		mov		ecx,12
		div		ecx
		pop		edx
	.else
		xor		eax,eax
		dec		eax
	.endif
	pop		edi
	pop		esi
	pop		ecx
	retn

ProcessFile endp

;Process all files with breakpoints
ProcessFiles proc uses esi edi

	mov		edi,offset Files
	mov		ecx,sizeof Files
	xor		al,al
	rep stosb
	mov		edi,offset Files
	invoke ResetBreakPoints
	mov		esi,lpDStruct
	mov		esi,[esi].ADDINDATA.lpBreakPoint
	mov		ecx,256
	.while ecx
		.if dword ptr [esi] && dword ptr [esi+8]==3
			push	ecx
			invoke ProcessFile,[esi]
			stosd
			mov		eax,edx
			stosd
			invoke lstrcpy,edi,offset FileName
			invoke lstrlen,edi
			inc		eax
			add		edi,eax
			pop		ecx
		.endif
		add		esi,12
		dec		ecx
	.endw
	ret

ProcessFiles endp

RestoreFiles proc uses ebx esi edi
	LOCAL	hFile:DWORD
	LOCAL	rdbytes:DWORD

	mov		esi,offset Files
	mov		ebx,[esi]
	.while ebx
		add		esi,4
		push	[esi]
		add		esi,4
		invoke CreateFile,esi,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
		mov		hFile,eax
		invoke lstrlen,ebx
		mov		edx,eax
		invoke WriteFile,hFile,ebx,edx,addr rdbytes,NULL
		invoke CloseHandle,hFile
		pop		eax
		.if eax
			invoke UpdateFileTime,eax
		.endif
		invoke GlobalUnlock,ebx
		invoke GlobalFree,ebx
		invoke lstrlen,esi
		inc		eax
		add		esi,eax
		mov		ebx,[esi]
	.endw
	mov		edi,offset Files
	mov		ecx,sizeof Files
	xor		al,al
	rep stosb
	ret

RestoreFiles endp
