.data

szMyProc4		db 'MyProc4',0

.code
































MyProc4 proc uses ebx,abc:DWORD,Param:DWORD
	LOCAL	aa:BYTE
	LOCAL	bb:WORD
	LOCAL	cc:BYTE
	LOCAL	ddd:DWORD
	LOCAL	eee:BYTE
	LOCAL	s[256]:BYTE
	LOCAL	fff:BYTE
	LOCAL	rc:RECT
	LOCAL	ggg:WORD
	LOCAL	hhh:tbyte

	mov		Param,2345
	ret

MyProc4 endp

