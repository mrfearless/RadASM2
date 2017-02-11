lstrcat	equ <strcatA>
lstrcpy	equ <strcpyA>
lstrlen	equ <strlenA>

strcatA					PROTO	:DWORD,:DWORD
strcpyA					PROTO	:DWORD,:DWORD
strlenA					PROTO	:DWORD

.code
;==========================================================================

strlenA	PROC Buffer	:DWORD

	mov eax, Buffer
	dec eax
	xor edx, edx
	@@:
		inc eax 
		cmp BYTE PTR [eax], dl
		jnz @B
	sub eax, Buffer
	ret

strlenA	ENDP

strcpyA	PROC lpDestination :DWORD, lpSource :DWORD

	mov edx, lpDestination
	mov eax, lpSource
	@@:
		mov cl, BYTE PTR [eax]
		inc eax
		mov BYTE PTR [edx], cl
		inc edx
		test cl, cl
		jnz @B
	ret

strcpyA	ENDP

strcatA	PROC lpDestination :DWORD, lpSource :DWORD

	mov eax, lpDestination
	dec eax
	xor edx, edx
	@@:
		inc eax 
		cmp BYTE PTR [eax], dl
		jnz @B
	mov edx, lpSource
	@@:
		mov cl, BYTE PTR [edx]
		inc edx
		mov BYTE PTR [eax], cl
		inc eax
		test cl, cl
		jnz @B
	ret

strcatA	ENDP