include BitMask.inc

.code

DialogProc proc hwnd:HWND,umsg:UINT,wParam:WPARAM,lParam:LPARAM

LOCAL dwID:DWORD
LOCAL dwEdit:DWORD
LOCAL hEdit:HWND
LOCAL szBuffer[12]:BYTE

	.if umsg==WM_INITDIALOG
		push edi
		lea edi,edits
		assume edi: ptr EDITSUBCLS
		invoke GetDlgItem,hwnd,IDC_EDIT_DEST
		mov hEdit,eax
		mov [edi].hWnd,eax
		invoke SetWindowLong,hEdit,GWL_WNDPROC,addr EditProc
		mov [edi].lpOldProc,eax
		add edi,sizeof EDITSUBCLS
		invoke GetDlgItem,hwnd,IDC_EDIT_SRC
		mov hEdit,eax
		mov [edi].hWnd,eax
		invoke SetWindowLong,hEdit,GWL_WNDPROC,addr EditProc
		mov [edi].lpOldProc,eax
		assume edi: nothing
		pop edi
		invoke SendDlgItemMessage,hwnd,IDC_RADIOBUTTON_HEX,BM_SETCHECK,BST_CHECKED,0
		mov wOutput,IDC_RADIOBUTTON_HEX
	.elseif umsg==WM_COMMAND
		mov eax,wParam
		mov edx,eax
		shr edx,16
		.if dx==BN_CLICKED
			mov CatchUpdate,FALSE
			and eax,0FFFFFFh
			mov dwID,eax
			.if (dwID >= IDC_STATIC1002 && dwID <= IDC_STATIC1065)
				invoke GetDlgItemInt,hwnd,dwID,NULL,NULL
				xor eax,1
				invoke SetDlgItemInt,hwnd,dwID,eax,FALSE
				mov eax,dwID
				.if eax < IDC_STATIC1034
					mov dwEdit,IDC_EDIT_DEST
					sub eax,IDC_STATIC1002
					btc flDest,eax
					mov eax,flDest
				.else
					mov dwEdit,IDC_EDIT_SRC
					sub eax,IDC_STATIC1034
					btc flSrc,eax
					mov eax,flSrc
				.endif
				.if wOutput==IDC_RADIOBUTTON_DEC
					invoke SetDlgItemInt,hwnd,dwEdit,eax,FALSE
				.else
					invoke SetDlgItemText,hwnd,dwEdit,formhex$(eax)
				.endif
				invoke SendDlgItemMessage,hwnd,dwEdit,WM_GETTEXTLENGTH,0,0
				invoke SendDlgItemMessage,hwnd,dwEdit,EM_SETSEL,eax,eax
			.elseif dwID==IDC_RADIOBUTTON_DEC
				invoke SendDlgItemMessage,hwnd,IDC_RADIOBUTTON_DEC,BM_GETCHECK,0,0
				.if eax==BST_CHECKED
					.if wOutput==IDC_RADIOBUTTON_HEX
						mov wOutput,IDC_RADIOBUTTON_DEC
						invoke SetDlgItemInt,hwnd,IDC_EDIT_DEST,flDest,FALSE
						invoke SetDlgItemInt,hwnd,IDC_EDIT_SRC,flSrc,FALSE
						invoke SetDlgItemInt,hwnd,IDC_EDIT_RES,flRes,FALSE
					.endif
				.endif
			.elseif dwID==IDC_RADIOBUTTON_HEX
				invoke SendDlgItemMessage,hwnd,IDC_RADIOBUTTON_HEX,BM_GETCHECK,0,0
				.if eax==BST_CHECKED
					.if wOutput==IDC_RADIOBUTTON_DEC
						mov wOutput,IDC_RADIOBUTTON_HEX
						invoke SetDlgItemText,hwnd,IDC_EDIT_DEST,formhex$(flDest)
						invoke SetDlgItemText,hwnd,IDC_EDIT_SRC,formhex$(flSrc)
						invoke SetDlgItemText,hwnd,IDC_EDIT_RES,formhex$(flRes)
					.endif
				.endif
			.elseif dwID==IDC_BUTTON_RESET
				invoke ResetValues,hwnd
			.elseif dwID==IDC_BUTTON_AND
				mov eax,flDest
				and eax,flSrc
				mov flRes,eax
				.if wOutput==IDC_RADIOBUTTON_DEC
					invoke SetDlgItemInt,hwnd,IDC_EDIT_RES,eax,FALSE
				.else
					invoke SetDlgItemText,hwnd,IDC_EDIT_RES,formhex$(eax)
				.endif
				invoke ParseNumber,hwnd,IDC_EDIT_RES
			.elseif dwID==IDC_BUTTON_OR
				mov eax,flDest
				or eax,flSrc
				mov flRes,eax
				.if wOutput==IDC_RADIOBUTTON_DEC
					invoke SetDlgItemInt,hwnd,IDC_EDIT_RES,eax,FALSE
				.else
					invoke SetDlgItemText,hwnd,IDC_EDIT_RES,formhex$(eax)
				.endif
				invoke ParseNumber,hwnd,IDC_EDIT_RES
			.elseif dwID==IDC_BUTTON_NOT
				mov eax,flDest
				not eax
				mov flRes,eax
				.if wOutput==IDC_RADIOBUTTON_DEC
					invoke SetDlgItemInt,hwnd,IDC_EDIT_RES,eax,FALSE
				.else
					invoke SetDlgItemText,hwnd,IDC_EDIT_RES,formhex$(eax)
				.endif
				invoke ParseNumber,hwnd,IDC_EDIT_RES
			.elseif dwID==IDC_BUTTON_XOR
				mov eax,flDest
				xor eax,flSrc
				mov flRes,eax
				.if wOutput==IDC_RADIOBUTTON_DEC
					invoke SetDlgItemInt,hwnd,IDC_EDIT_RES,eax,FALSE
				.else
					invoke SetDlgItemText,hwnd,IDC_EDIT_RES,formhex$(eax)
				.endif
				invoke ParseNumber,hwnd,IDC_EDIT_RES
			.else
				mov eax,FALSE
				ret
			.endif
		.elseif dx==EN_CHANGE
			mov edx,wParam
			and edx,0FFFFh
			mov dwID,edx
			invoke SendDlgItemMessage,hwnd,dwID,WM_GETTEXTLENGTH,0,0
			.if eax==0
				invoke SetDlgItemText,hwnd,dwID,CTEXT("0")
				invoke SendDlgItemMessage,hwnd,dwID,EM_SETSEL,0,-1
				mov eax,TRUE
				Ret
			.endif
			.if CatchUpdate
				invoke GetDlgItemText,hwnd,dwID,addr szBuffer,11
				.if wOutput==IDC_RADIOBUTTON_HEX
					invoke htodw,addr szBuffer
				.else
					invoke ustr2dw,addr szBuffer
				.endif
				.if dwID==IDC_EDIT_DEST
					mov flDest,eax
				.elseif dwID==IDC_EDIT_SRC
					mov flSrc,eax
				.endif
				invoke ParseNumber,hwnd,dwID
			.endif
		.else
			mov eax,FALSE
			ret
		.endif
	.elseif umsg==WM_CLOSE
		invoke ResetValues,hwnd
		invoke EndDialog,hwnd,NULL
	.else
		mov eax,FALSE
		ret
	.endif	
	mov eax,TRUE
	Ret
DialogProc EndP

EditProc proc hwnd:HWND,umsg:UINT,wParam:WPARAM,lParam:LPARAM

LOCAL OldProc:DWORD
LOCAL dwStart:DWORD
LOCAL dwEnd:DWORD
LOCAL dwLimit:DWORD
LOCAL bContinue		:BOOL

	mov bContinue,FALSE
	invoke OldEditProc,hwnd
	mov OldProc,eax
	.if umsg==WM_CHAR
		mov eax,wParam
		.if wOutput==IDC_RADIOBUTTON_DEC && (al>=30h && al<=39h)
			mov bContinue,TRUE
			mov dwLimit,10
		.elseif wOutput==IDC_RADIOBUTTON_HEX && ((al>=30h && al<=39h)||(al>=41h && al<=46h)||(al>=61h && al<=66h))
			mov bContinue,TRUE
			mov dwLimit,8
		.elseif al==VK_BACK
			invoke CallWindowProc,OldProc,hwnd,umsg,wParam,lParam
			ret
		.endif
		.if bContinue
			invoke SendMessage,hwnd,WM_GETTEXTLENGTH,0,0
			.if eax<dwLimit
				invoke CallWindowProc,OldProc,hwnd,umsg,wParam,lParam
				ret
			.else
				invoke SendMessage,hwnd,EM_GETSEL,addr dwStart,addr dwEnd
				mov eax,dwStart
				mov ecx,dwEnd
				.if eax != ecx
					invoke CallWindowProc,OldProc,hwnd,umsg,wParam,lParam
					ret
				.endif
			.endif
		.endif
	.elseif umsg==WM_KEYDOWN
		mov CatchUpdate,TRUE
		invoke CallWindowProc,OldProc,hwnd,umsg,wParam,lParam
		ret
	.else
		invoke CallWindowProc,OldProc,hwnd,umsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	Ret
EditProc EndP

OldEditProc proc hwnd:HWND

	push edi
	push ecx
	push edx
	mov edx,hwnd
	mov ecx,sizeof EDITSUBCLS
	lea edi,edits
	assume edi: ptr EDITSUBCLS
	.if ([edi].hWnd==edx)
		mov eax,[edi].lpOldProc
	.else
		mov eax,[edi+ecx].lpOldProc
	.endif
	assume edi: nothing
	pop edx
	pop ecx
	pop edi
	Ret
OldEditProc EndP

ResetValues proc hwnd:HWND
	
LOCAL cnt:DWORD
LOCAL dwID:DWORD

	push ecx
	mov flDest,0
	mov flSrc,0
	mov flRes,0
	invoke SetDlgItemInt,hwnd,IDC_EDIT_DEST,0,FALSE
	invoke SetDlgItemInt,hwnd,IDC_EDIT_SRC,0,FALSE
	invoke SetDlgItemInt,hwnd,IDC_EDIT_RES,0,FALSE
	mov cnt,32
	_loop:
	push cnt
	pop dwID
	add dwID,1001
	invoke SetDlgItemInt,hwnd,dwID,0,FALSE
	add dwID,32
	invoke SetDlgItemInt,hwnd,dwID,0,FALSE
	add dwID,32
	invoke SetDlgItemInt,hwnd,dwID,0,FALSE
	dec cnt
	cmp cnt,0
	jne _loop
	pop ecx
	ret

ResetValues endp

ParseNumber proc hwnd:HWND,dwID:DWORD
	
LOCAL szBuffer[36]:BYTE
LOCAL dwStatic:DWORD
LOCAL dwCounter:DWORD

	.if dwID==IDC_EDIT_DEST
		invoke dw2bin_ex,flDest,addr szBuffer
		mov dwStatic,IDC_STATIC1033
	.elseif dwID==IDC_EDIT_SRC
		invoke dw2bin_ex,flSrc,addr szBuffer
		mov dwStatic,IDC_STATIC1065
	.elseif dwID==IDC_EDIT_RES
		invoke dw2bin_ex,flRes,addr szBuffer
		mov dwStatic,IDC_STATIC1097
	.endif
	
	push esi
	push ebx
	lea esi,szBuffer
	mov dwCounter,32
	_loop:
	movzx ebx,byte ptr [esi]
	sub ebx,48
	invoke SetDlgItemInt,hwnd,dwStatic,ebx,FALSE
	inc esi
	dec dwStatic
	dec dwCounter
	cmp dwCounter,0
	jne _loop
	
	pop ebx
	pop esi
	ret

ParseNumber endp
