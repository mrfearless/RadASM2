
.code

PutString proc lpString:DWORD

	invoke SetFocus,hEdt
	invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,lpString
	invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szCRLF
	invoke SendMessage,hEdt,EM_SCROLLCARET,0,0
	ret

PutString endp

HexByte proc

	mov		ah,al
	shr		al,4
	and		ah,0Fh
	.if al<=9
		add		al,30h
	.else
		add		al,41h-0Ah
	.endif
	.if ah<=9
		add		ah,30h
	.else
		add		ah,41h-0Ah
	.endif
	ret

HexByte endp

DumpLine proc uses ebx esi edi,nAdr:DWORD,lpData:DWORD,nBytes:DWORD
	LOCAL	buffer[256]:BYTE

	mov		ebx,nAdr
	mov		esi,lpData
	lea		edi,buffer
	xor		ecx,ecx
	.while ecx<4
		rol		ebx,8
		mov		eax,ebx
		invoke HexByte
		mov		[edi],ax
		inc		edi
		inc		edi
		inc		ecx
	.endw
	mov		byte ptr [edi],' '
	inc		edi
	xor		ecx,ecx
	.while ecx<nBytes
		mov		al,[esi+ecx]
		invoke HexByte
		mov		[edi],ax
		inc		edi
		inc		edi
		.if ecx==7
			mov		byte ptr [edi],'-'
		.else
			mov		byte ptr [edi],' '
		.endif
		inc		edi
		inc		ecx
	.endw
	mov		ecx,16
	sub		ecx,nBytes
	.while ecx
		mov		dword ptr [edi],'   '
		add		edi,3
		dec		ecx
	.endw
	xor		ecx,ecx
	.while ecx<nBytes
		mov		al,[esi+ecx]
		.if al<20h || al>=80h
			mov		al,'.'
		.endif
		mov		[edi],al
		inc		edi
		inc		ecx
	.endw
	mov		dword ptr [edi],0A0Dh
	invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr buffer
	ret

DumpLine endp

SetCurrentStream proc
	LOCAL	buffer[256]:BYTE

	invoke wsprintf,addr buffer,addr szCurrentStream,nCurrentStream,nStreams
	invoke SetDlgItemText,hCldDlg,IDC_STCSTREAM,addr buffer
	ret

SetCurrentStream endp
