SBLASTPANE		equ 350

.data?

OldStatusProc	dd ?

.code

StatusProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_LBUTTONUP
		mov		eax,lParam
		and		eax,0FFFFh
		.if eax>SBLASTPANE
			invoke SendMessage,hWnd,WM_COMMAND,IDM_VIEW_OUTPUTWINDOW,0
		.endif
	.endif
	invoke CallWindowProc,OldStatusProc,hWin,uMsg,wParam,lParam
	ret

StatusProc endp

DoStatus proc
	LOCAL	sbParts[4]:DWORD

	.if winSbr
		mov		eax,WS_CHILD or WS_VISIBLE or SBS_SIZEGRIP
	.else
		mov		eax,WS_CHILD or SBS_SIZEGRIP
	.endif
	invoke CreateStatusWindow,eax,NULL,hWnd,200
	mov		hStatus,eax
	invoke SetWindowLong,hStatus,GWL_WNDPROC,offset StatusProc
	mov		OldStatusProc,eax
	mov [sbParts+0],225				; pixels from left
	mov [sbParts+4],250				; pixels from left
	mov [sbParts+8],SBLASTPANE		; pixels from left
	mov [sbParts+12],-1				; last part
	invoke SendMessage,hStatus,SB_SETPARTS,4,addr sbParts
	ret

DoStatus endp

hexSbr proc hex:DWORD,tbrNo:DWORD

	pushad
	mov     eax,hex
	invoke hexEax
	invoke SendMessage,hStatus,SB_SETTEXT,tbrNo,addr strHex
	popad
	ret

hexSbr endp

hexEax proc

	pushad
	mov     edi,offset strHex+7
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	call    hexNibble
	popad
	ret

  hexNibble:
	push    eax
	and     eax,0fh
	cmp     eax,0ah
	jb      hexNibble1
	add     eax,07h
  hexNibble1:
	add     eax,30h
	mov     [edi],al
	dec     edi
	pop     eax
	shr     eax,4
	ret
	
hexEax endp
