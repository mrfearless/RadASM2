.data?

sztemp		dw 1024 dup(?)

.code

ConvertFile proc uses esi edi,lpFileName:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	.if hIniMem
		invoke GlobalFree,hIniMem
		mov		hIniMem,0
	.endif
	mov		eax,lpFileName
	.if fNT && byte ptr [eax]
		invoke CreateFile,lpFileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke GetFileSize,hFile,NULL
			push	eax
			inc		eax
			inc		eax
			invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov		hIniMem,eax
			mov		esi,eax
			mov		edi,eax
			pop		edx
			invoke ReadFile,hFile,esi,edx,addr nBytes,NULL
			invoke CloseHandle,hFile
			mov		nBytes,0
			.if word ptr [esi]==0FEFFh
				add		esi,2
			.endif
		  Next:
			.while word ptr [esi]
				.while word ptr [esi]==VK_SPACE || word ptr [esi]==VK_TAB || word ptr [esi]==0Dh || word ptr [esi]==0Ah
					add		esi,2
				.endw
				.if word ptr [esi]==';'
					call	SkipLine
					jmp		Next
				.endif
				.if word ptr [esi]=='['
					.if nBytes
						xor		ax,ax
						mov		[edi],ax
						add		edi,2
					.endif
					inc		nBytes
					call	GetApp
					jmp		Next
				.elseif word ptr [esi]
					call	GetKey
					jmp		Next
				.endif
			.endw
			xor		ax,ax
			mov		[edi],ax
			mov		[edi+2],ax
			mov		[edi+4],ax
		.endif
	.endif
	ret

GetApp:
	add		esi,2
	.while word ptr [esi]!=']'
		mov		ax,[esi]
		mov		[edi],ax
		add		esi,2
		add		edi,2
	.endw
	xor		ax,ax
	mov		[edi],ax
	add		esi,2
	add		edi,2
	retn

GetKey:
	.while word ptr [esi]!='='
		mov		ax,[esi]
		mov		[edi],ax
		add		esi,2
		add		edi,2
	.endw
	xor		ax,ax
	mov		[edi],ax
	add		esi,2
	add		edi,2
	.while word ptr [esi]!=0Dh
		mov		ax,[esi]
		mov		[edi],ax
		add		esi,2
		add		edi,2
	.endw
	xor		ax,ax
	mov		[edi],ax
	add		esi,2
	add		edi,2
	retn

SkipLine:
	.while word ptr [esi]!=0Ah && word ptr [esi]
		add		esi,2
	.endw
	retn

ConvertFile endp

GetLangString proc uses esi,lpAppKey:DWORD,lpKey:DWORD,lpStr:DWORD,nCC:DWORD

	mov		esi,hIniMem
	.if esi
		call	FindApp
		.if !eax
			call	FindKey
			.if !eax
				invoke lstrcpynW,lpStr,esi,nCC
				invoke lstrlenW,esi
			.else
				xor		eax,eax
			.endif
		.else
			xor		eax,eax
		.endif
	.else
		xor		eax,eax
	.endif
	ret

FindKey:
	.if word ptr [esi]
		invoke lstrcmpiW,esi,lpKey
		.if eax
			invoke lstrlenW,esi
			lea		esi,[esi+eax*2+2]
			invoke lstrlenW,esi
			lea		esi,[esi+eax*2+2]
			jmp		FindKey
		.endif
		invoke lstrlenW,esi
		lea		esi,[esi+eax*2+2]
		xor		eax,eax
	.else
		xor		eax,eax
		inc		eax
	.endif
	retn

FindApp:
	invoke lstrcmpiW,esi,lpAppKey
	.if eax
		.while word ptr [esi]
			invoke lstrlenW,esi
			lea		esi,[esi+eax*2+2]
		.endw
		add		esi,2
		.if word ptr [esi]
			jmp		FindApp
		.endif
		xor		eax,eax
		inc		eax
	.else
		invoke lstrlenW,esi
		lea		esi,[esi+eax*2+2]
		xor		eax,eax
	.endif
	retn

GetLangString endp

ConvID proc ID:DWORD,lpBuff:DWORD
	LOCAL	buffer[16]:BYTE

	.if sdword ptr ID>65535
		invoke lstrlen,ID
		invoke MultiByteToWideChar,CP_ACP,0,ID,eax,lpBuff,64
	.else
		invoke BinToDec,ID,addr buffer
		invoke lstrlen,addr buffer
		invoke MultiByteToWideChar,CP_ACP,0,addr buffer,eax,lpBuff,16
	.endif
	mov		edx,lpBuff
	mov		word ptr [edx+eax*2],0
	ret

ConvID endp

GetLangStringA proc lpAppKey:DWORD,nID:DWORD,lpStr:DWORD,nCC:DWORD
	LOCAL	buffW1[32]:WORD
	LOCAL	buffW2[16]:WORD

	invoke lstrlen,lpAppKey
	mov		edx,eax
	invoke MultiByteToWideChar,CP_ACP,0,lpAppKey,edx,addr buffW1,32
	mov		buffW1[eax*2],0
	invoke ConvID,nID,addr buffW2
	invoke GetLangString,addr buffW1,addr buffW2,lpStr,nCC
	ret

GetLangStringA endp

DlgEnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	bufferW[16]:WORD

	invoke GetParent,hWin
	.if eax==hLngDlg
		invoke GetWindowLong,hWin,GWL_ID
		mov		edx,eax
		invoke ConvID,edx,addr bufferW
		invoke GetLangString,lParam,addr bufferW,offset sztemp,sizeof sztemp/2
		.if eax
			invoke SendMessageW,hWin,WM_SETTEXT,0,offset sztemp
		.endif
		.if hFontIde
			invoke SendMessage,hWin,WM_SETFONT,hFontIde,TRUE
		.endif
		invoke GetWinSize,hWin,FALSE
	.endif
	mov		eax,TRUE
	ret

DlgEnumProc endp

SetLanguage proc hWin:DWORD,ID:DWORD,fNoSize:DWORD
	LOCAL	bufferW[64]:WORD

	mov		eax,fNoSize
	mov		fLngNoSize,eax
	mov		eax,hWin
	mov		hLngDlg,eax
	invoke ConvID,ID,addr bufferW
	lea		edx,bufferW
	invoke GetLangString,edx,edx,offset sztemp,sizeof sztemp/2
	.if eax
		invoke SendMessageW,hWin,WM_SETTEXT,0,offset sztemp
	.endif
	invoke GetWinSize,hWin,TRUE
	invoke EnumChildWindows,hWin,addr DlgEnumProc,addr bufferW
	invoke InvalidateRect,hWin,NULL,TRUE
	ret

SetLanguage endp

UpdateMenu proc hMnu:DWORD,ID:DWORD
	LOCAL	nPos:DWORD
	LOCAL	mii:MENUITEMINFO
	LOCAL	bufferW1[16]:WORD
	LOCAL	bufferW2[16]:WORD

	mov		eax,hMnu
	call	GetMenuItems
	ret

GetMenuItems:
	push	hMnu
	push	nPos
	mov		hMnu,eax
	mov		nPos,0
  @@:
	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_DATA or MIIM_ID or MIIM_SUBMENU or MIIM_TYPE
	mov		eax,offset sztemp
	mov		word ptr [eax],0
	mov		mii.dwTypeData,eax
	mov		mii.cch,sizeof sztemp/2
	invoke GetMenuItemInfoW,hMnu,nPos,TRUE,addr mii
	.if eax
		mov		edx,mii.wID
		.if edx
			invoke ConvID,edx,addr bufferW2
			invoke ConvID,ID,addr bufferW1
			invoke GetLangString,addr bufferW1,addr bufferW2,offset sztemp,sizeof sztemp/2
			.if eax
				invoke SetMenuItemInfoW,hMnu,nPos,TRUE,addr mii
			.endif
		.endif
		mov		eax,mii.hSubMenu
		.if eax
			call	GetMenuItems
		.endif
		inc		nPos
		jmp		@b
	.endif
	pop		nPos
	pop		hMnu
	retn

UpdateMenu endp

GetToolBarTooltip proc hWin:HWND,ID:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	bufferW[16]:WORD

	;Toolbar tooltip
	invoke DllProc,hWin,AIM_TBRTOOLTIP,ID,0,RAM_TBRTOOLTIP
	.if fNT
		.if !eax
			invoke LoadStringW,hInstance,ID,addr buffer,sizeof buffer/2
			.if eax
				invoke ConvID,ID,addr bufferW
				invoke GetLangString,addr szStringsW,addr bufferW,offset sztemp,sizeof sztemp/2
				.if !eax
					invoke lstrcpyW,offset sztemp,addr buffer
				.endif
				mov		eax,offset sztemp
			.endif
		.else
			.if edx!=123456
				push	eax
				invoke strlen,eax
				mov		edx,eax
				pop		eax
				invoke MultiByteToWideChar,CP_ACP,0,eax,edx,offset sztemp,sizeof sztemp/2
				mov		word ptr sztemp[eax*2],0
				mov		eax,offset sztemp
			.endif
		.endif
	.else
		.if !eax
			invoke LoadString,hInstance,ID,offset sztemp,sizeof sztemp
			mov		eax,offset sztemp
		.endif
	.endif
	ret

GetToolBarTooltip endp

ModalDialog proc hInst:DWORD,ID:DWORD,hOwner:HWND,lpProc:DWORD,lParam:DWORD

	.if fNT
		invoke DialogBoxParamW,hInst,ID,hOwner,lpProc,lParam
	.else
		invoke DialogBoxParam,hInst,ID,hOwner,lpProc,lParam
	.endif
	ret

ModalDialog endp

ModelessDialog proc hInst:DWORD,ID:DWORD,hOwner:HWND,lpProc:DWORD,lParam:DWORD

	.if fNT
		invoke CreateDialogParamW,hInst,ID,hOwner,lpProc,lParam
	.else
		invoke CreateDialogParam,hInst,ID,hOwner,lpProc,lParam
	.endif
	ret

ModelessDialog endp
