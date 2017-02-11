.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include RadLNG.inc

.code

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax

	invoke LoadLibrary,addr szRAEditDLL
	.if eax
		mov		hRAEdit,eax
		invoke LoadLibrary,addr szRAGridDLL
		.if eax
			mov		hRAGrid,eax
			invoke InitCommonControls
			invoke DialogBoxParamW,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
			invoke FreeLibrary,hRAGrid
		.else
			invoke MessageBox,NULL,addr szRAGridErr,addr szRadLNG,MB_ICONERROR or MB_OK
		.endif
		invoke FreeLibrary,hRAEdit
	.else
		invoke MessageBox,NULL,addr szRAEditErr,addr szRadLNG,MB_ICONERROR or MB_OK
	.endif
	invoke ExitProcess,0

;########################################################################

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
	LOCAL	buffer[16]:BYTE

	invoke BinToDec,Value,addr buffer
	invoke lstrlen,lpDest
	mov		edi,lpDest
	add		edi,eax
	invoke lstrcpy,edi,addr buffer
	.if fComma
		invoke lstrlen,lpDest
		mov		edi,lpDest
		add		edi,eax
		mov		word ptr [edi],','
	.endif
	ret

PutItem endp

DoToolBar proc hInst:DWORD,hToolBar:HWND,pbtn:DWORD,nbtn:DWORD
	LOCAL	tbab:TBADDBITMAP

	;Unicode
	invoke SendMessage,hToolBar,TB_SETUNICODEFORMAT,TRUE,0
	;Set toolbar struct size
	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar buttons
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,nbtn,pbtn
	;Set toolbar bitmap
	push	hInst
	pop		tbab.hInst
	mov		tbab.nID,IDB_MDITBR
	invoke SendMessage,hToolBar,TB_ADDBITMAP,nbtn,addr tbab
	mov		eax,hToolBar
	ret

DoToolBar endp

GetWinSize proc hWin:HWND,fDialog:DWORD
	LOCAL	rect:RECT
	LOCAL	nClass:DWORD

	invoke GetClassLong,hWin,GCW_ATOM
	mov		nClass,eax
	invoke GetWindowRect,hWin,addr rect
	.if !fDialog
		invoke GetParent,hWin
		mov		edx,eax
		push	eax
		invoke ScreenToClient,edx,addr rect.left
		pop		edx
		invoke ScreenToClient,edx,addr rect.right
	.endif
	mov		ecx,nSize
	mov		eax,rect.left
	mul		ecx
	shr		eax,5
	mov		rect.left,eax
	mov		eax,rect.top
	mul		ecx
	shr		eax,5
	mov		rect.top,eax
	mov		eax,rect.right
	mul		ecx
	shr		eax,5
	mov		rect.right,eax
	mov		eax,rect.bottom
	mul		ecx
	shr		eax,5
	mov		rect.bottom,eax

	mov		eax,rect.right
	sub		eax,rect.left
	mov		edx,rect.bottom
	sub		edx,rect.top
	.if nClass==0000C01Ch
		add		edx,200
	.endif
	mov		ecx,SWP_NOZORDER
	.if fDialog
		mov		ecx,SWP_NOMOVE or SWP_NOZORDER
	.endif
	invoke SetWindowPos,hWin,0,rect.left,rect.top,eax,edx,ecx
	ret

GetWinSize endp

ConvertID proc ID:DWORD,lpBuffW:DWORD
	LOCAL	bufferA[8]:BYTE

	invoke BinToDec,ID,addr bufferA
	invoke lstrlen,addr bufferA
	mov		edx,eax
	invoke MultiByteToWideChar,CP_ACP,0,addr bufferA,edx,lpBuffW,8
	mov		edx,lpBuffW
	mov		word ptr [edx+eax*2],0
	ret

ConvertID endp

ConvertStr proc lpBuffA:DWORD,lpBuffW:DWORD

	invoke lstrlen,lpBuffA
	mov		edx,eax
	invoke MultiByteToWideChar,CP_ACP,0,lpBuffA,edx,lpBuffW,128
	mov		edx,lpBuffW
	mov		word ptr [edx+eax*2],0
	ret

ConvertStr endp

ConvertFile proc uses esi edi
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	.if hIniMem
		invoke GlobalFree,hIniMem
		mov		hIniMem,0
	.endif
	invoke CreateFile,offset lngFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		push	eax
		inc		eax
		inc		eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		hIniMem,eax
		mov		esi,eax
		mov		edi,eax
		pop		edx
		invoke ReadFile,hFile,esi,edx,addr nBytes,NULL
		invoke CloseHandle,hFile
		mov		nBytes,0
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

FindString proc uses esi,lpApp,lpKey,lpStr,nCB

	mov		esi,hIniMem
	.if esi
		call	FindApp
		.if !eax
			call	FindKey
			.if !eax
				invoke lstrcpyW,lpStr,esi
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
	invoke lstrcmpiW,esi,lpApp
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

FindString endp

DlgEnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	bufferW[8]:WORD

	invoke GetParent,hWin
	.if eax==hLngDlg
		invoke GetWindowLong,hWin,GWL_ID
		mov		edx,eax
		invoke ConvertID,edx,addr bufferW
		invoke FindString,lParam,addr bufferW,offset szText,sizeof szText/2
		.if eax
			invoke SendMessageW,hWin,WM_SETTEXT,0,offset szText
		.endif
		.if hLngFont
			invoke SendMessage,hWin,WM_SETFONT,hLngFont,TRUE
		.endif
		invoke GetWinSize,hWin,FALSE
	.endif
	mov		eax,TRUE
	ret

DlgEnumProc endp

UpdateMenu proc hMnu:DWORD,lpID:DWORD
	LOCAL	nPos:DWORD
	LOCAL	mii:MENUITEMINFO
	LOCAL	bufferW[8]:WORD

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
	mov		eax,offset szText
	mov		word ptr [eax],0
	mov		mii.dwTypeData,eax
	mov		mii.cch,sizeof szText/2
	invoke GetMenuItemInfoW,hMnu,nPos,TRUE,addr mii
	.if eax
		mov		edx,mii.wID
		.if edx
			invoke ConvertID,edx,addr bufferW
			invoke FindString,lpID,addr bufferW,offset szText,sizeof szText/2
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

ChildDlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	bufferW[8]:WORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ChildDlgProc endp

TestDlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	bufferW[8]:WORD
	LOCAL	hCld:HWND

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hLngDlg,eax
		invoke ConvertID,lParam,addr bufferW
		mov		eax,lParam
		.if eax>=151 && eax<=154
			invoke ConvertID,150,addr bufferW
			invoke FindString,addr bufferW,addr bufferW,offset szText,sizeof szText/2
			.if eax
				invoke SendMessageW,hWin,WM_SETTEXT,0,offset szText
			.endif
			invoke GetWinSize,hWin,TRUE
			invoke EnumChildWindows,hWin,addr DlgEnumProc,addr bufferW
			push	hLngDlg
			invoke CreateDialogParamW,hInstance,lParam,hWin,offset ChildDlgProc,lParam
			mov		hCld,eax
			mov		hLngDlg,eax
			invoke ConvertID,lParam,addr bufferW
			invoke GetWinSize,hCld,FALSE
			invoke ShowWindow,hCld,SW_SHOWNA
			invoke EnumChildWindows,hWin,addr DlgEnumProc,addr bufferW
			pop		hLngDlg
		.elseif eax==998 || eax==999
			invoke GetMenu,hWin
			.if eax
				mov		edx,eax
				invoke UpdateMenu,edx,addr bufferW
				invoke DrawMenuBar,hWin
			.endif
		.elseif eax==997
			;Set the toolbar buttons
			invoke GetDlgItem,hWin,IDC_TBR1
			invoke DoToolBar,hInstance,eax,offset tbrbtns,ntbrbtns
			invoke GetDlgItem,hWin,IDC_TBR2
			invoke DoToolBar,hInstance,eax,offset pbrtbrbtns,npbrtbrbtns
			invoke GetDlgItem,hWin,IDC_TBR3
			invoke DoToolBar,hInstance,eax,offset prptbrbtns,nprptbrbtns
		.else
			invoke FindString,addr bufferW,addr bufferW,offset szText,sizeof szText/2
			.if eax
				invoke SendMessageW,hWin,WM_SETTEXT,0,offset szText
			.endif
			invoke GetWinSize,hWin,TRUE
			invoke EnumChildWindows,hWin,addr DlgEnumProc,addr bufferW
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_LBUTTONDOWN
		invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,(NMHDR ptr [edx]).code
		.if eax==TTN_NEEDTEXTW
			;Toolbar tooltip
			mov		edx,lParam
			invoke LoadStringW,hInstance,(NMHDR ptr [edx]).idFrom,addr buffer,sizeof buffer
			.if eax
				mov		edx,lParam
				invoke ConvertID,(NMHDR ptr [edx]).idFrom,addr bufferW
				invoke FindString,addr szStringsW,addr bufferW,offset szText,sizeof szText/2
				.if eax
					mov		eax,offset szText
				.else
					lea		eax,buffer
				.endif
			.endif
			mov		edx,lParam
			mov		(TOOLTIPTEXT ptr [edx]).lpszText,eax
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TestDlgProc endp

DumpEnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	buffer[8]:BYTE

	invoke GetParent,hWin
	.if eax==lParam
		mov		dword ptr szText,0
		invoke SendMessageW,hWin,WM_GETTEXT,sizeof szText/2,offset szText
		mov		eax,dword ptr szText
		.if eax && eax!='0' && eax!=2E002Eh
			invoke GetWindowLong,hWin,GWL_ID
			.if eax!=-1
				mov		edx,eax
				invoke BinToDec,edx,addr buffer
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr buffer
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szEqu
				invoke SendMessageW,hEdt,EM_REPLACESEL,FALSE,offset szText
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szCrLf
			.endif
		.endif
	.endif
	mov		eax,TRUE
	ret

DumpEnumProc endp

DumpDlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[8]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke BinToDec,lParam,addr buffer
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szLeftBr
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr buffer
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szRightBr
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szCrLf
		.if lParam==151
			invoke ConvertStr,addr szWiz1,addr szText
		.elseif lParam==152
			invoke ConvertStr,addr szWiz2,addr szText
		.elseif lParam==153
			invoke ConvertStr,addr szWiz3,addr szText
		.elseif lParam==154
			invoke ConvertStr,addr szWiz4,addr szText
		.else
			invoke SendMessageW,hWin,WM_GETTEXT,sizeof szText/2,offset szText
		.endif
		.if szText
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr buffer
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szEqu
			invoke SendMessageW,hEdt,EM_REPLACESEL,FALSE,offset szText
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szCrLf
		.endif
		invoke EnumChildWindows,hWin,addr DumpEnumProc,hWin
		invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DumpDlgProc endp

DumpMenu proc ID:DWORD
	LOCAL	hMnu:DWORD
	LOCAL	nPos:DWORD
	LOCAL	mii:MENUITEMINFO
	LOCAL	buffer[256]:BYTE

	invoke LoadMenu,hInstance,ID
	.if eax
		push	eax
		invoke BinToDec,ID,addr buffer
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szLeftBr
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr buffer
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szRightBr
		invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szCrLf
		pop		eax
		push	eax
		call	GetMenuItems
		pop		eax
		invoke DestroyMenu,eax
	.endif
	ret

GetMenuItems:
	push	hMnu
	push	nPos
	mov		hMnu,eax
	mov		nPos,0
  @@:
	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_DATA or MIIM_ID or MIIM_SUBMENU or MIIM_TYPE
	mov		eax,offset szText
	mov		word ptr [eax],0
	mov		mii.dwTypeData,eax
	mov		mii.cch,sizeof szText/2
	invoke GetMenuItemInfoW,hMnu,nPos,TRUE,addr mii
	.if eax
		invoke lstrcmp,addr szText,addr szEmptyW
		.if eax
			mov		edx,mii.wID
			.if edx
				invoke BinToDec,edx,addr buffer
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr buffer
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szEqu
				invoke SendMessageW,hEdt,EM_REPLACESEL,FALSE,offset szText
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szCrLf
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

DumpMenu endp

DumpStrings proc
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	mov		nInx,0
	invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr szStrings
	.while nInx<65536
		invoke LoadStringW,hInstance,nInx,addr szText,sizeof szText/2
		.if eax
			invoke BinToDec,nInx,addr buffer
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,addr buffer
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szEqu
			invoke SendMessageW,hEdt,EM_REPLACESEL,FALSE,offset szText
			invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szCrLf
		.endif
		inc		nInx
	.endw
	ret

DumpStrings endp

ReadTheFile proc
	LOCAL	hFile:DWORD
	LOCAL	hMem:DWORD
	LOCAL	nBytes:DWORD

	invoke CreateFile,offset lngFile,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		push	eax
		inc		eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		hMem,eax
		pop		edx
		invoke ReadFile,hFile,hMem,edx,addr nBytes,NULL
		.if eax
			invoke SendMessageW,hEdt,WM_SETTEXT,0,hMem
		.endif
		invoke CloseHandle,hFile
		invoke GlobalFree,hMem
		invoke ConvertFile
		invoke SendMessageW,hEdt,EM_SETMODIFY,FALSE,0
	.endif
	ret

ReadTheFile endp

SaveTheFile proc
	LOCAL	hFile:DWORD
	LOCAL	hMem:DWORD
	LOCAL	nBytes:DWORD

	invoke CreateFile,offset lngFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke SendMessageW,hEdt,WM_GETTEXTLENGTH,0,0
		push	eax
		inc		eax
		push	eax
		shl		eax,1
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
		mov		hMem,eax
		pop		edx
		invoke SendMessageW,hEdt,WM_GETTEXT,edx,hMem
		invoke SendMessageW,hEdt,EM_SETMODIFY,FALSE,0
		pop		edx
		shl		edx,1
		invoke WriteFile,hFile,hMem,edx,addr nBytes,NULL
		invoke CloseHandle,hFile
		invoke GlobalFree,hMem
		invoke ConvertFile
		invoke WritePrivateProfileString,addr szLang,addr szLang,addr lngFile,addr lngIni
		xor		eax,eax
	.else
		invoke MessageBox,hDlg,addr szCouldNotSave,addr szRadLNG,MB_OK
		mov		eax,TRUE
	.endif
	ret

SaveTheFile endp

UdcProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	invoke DefWindowProc,hWin,uMsg,wParam,lParam
	ret

UdcProc endp

DlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	buffer[256]:BYTE
	LOCAL	bufferW[8]:WORD
	LOCAL	cf:CHOOSEFONT
    LOCAL	hDC:HDC

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hDlg,eax
		invoke LoadIcon,hInstance,100
		mov		hIcon,eax
		invoke SendMessage,hWin,WM_SETICON,ICON_SMALL,eax
		;Folder User control
		mov		wc.cbSize,sizeof WNDCLASSEX
		mov		wc.style,CS_HREDRAW or CS_VREDRAW
		mov		wc.lpfnWndProc,offset UdcProc
		mov		wc.cbClsExtra,NULL
		mov		wc.cbWndExtra,NULL
		push	hInstance
		pop		wc.hInstance
		mov		wc.hbrBackground,NULL
		mov		wc.lpszMenuName,NULL
		mov		wc.lpszClassName,offset szUDCCLASS
		invoke LoadIcon,NULL,IDI_APPLICATION
		mov		wc.hIcon,eax
		mov		wc.hIconSm,eax
		invoke LoadCursor,NULL,IDC_ARROW
		mov		wc.hCursor,eax
		invoke RegisterClassEx,addr wc
		invoke GetDlgItem,hWin,IDC_EDT1
		mov		hEdt,eax
		mov		esi,offset dialogs
		.while dword ptr [esi]
			invoke SendDlgItemMessage,hWin,IDC_LST1,LB_ADDSTRING,0,addr [esi+4]
			invoke SendDlgItemMessage,hWin,IDC_LST1,LB_SETITEMDATA,eax,dword ptr [esi]
			invoke lstrlen,addr [esi+4]
			lea		esi,[esi+eax+4+1]
		.endw
		invoke GetModuleFileName,0,offset lngFile,sizeof lngFile
		invoke lstrlen,offset lngFile
		.while eax && lngFile[eax]!='\'
			dec		eax
		.endw
		mov		byte ptr lngFile[eax+1],0
		invoke lstrcpy,addr lngIni,addr lngFile
		invoke lstrcat,addr lngIni,offset szRadLNGIni
		invoke GetPrivateProfileString,addr szLang,addr szFont,addr szNULL,addr buffer,sizeof buffer,addr lngIni
		.if eax
			;Face name
			invoke GetItem,addr buffer,addr lfnt.lfFaceName
			;Size
			invoke GetItem,addr buffer,addr bufferW
			invoke DecToBin,addr bufferW
			mov		lfnt.lfHeight,eax
			;Weight
			invoke GetItem,addr buffer,addr bufferW
			invoke DecToBin,addr bufferW
			mov		lfnt.lfWeight,eax
			;Char set
			invoke GetItem,addr buffer,addr bufferW
			invoke DecToBin,addr bufferW
			mov		lfnt.lfCharSet,al
		.endif
		;Create font used by Text Editor and test dialogs
		invoke CreateFontIndirect,addr lfnt
		mov		hLngFont,eax
		invoke GetPrivateProfileInt,addr szLang,addr szSize,32,addr lngIni
		mov		nSize,eax
		invoke SendMessage,hEdt,WM_SETFONT,hLngFont,FALSE
		invoke GetPrivateProfileString,addr szLang,addr szLang,addr szNULL,addr lngFile,sizeof lngFile,addr lngIni
		.if !eax
			invoke lstrcpy,addr lngFile,offset szRadLNGFile
		.endif
		invoke ReadTheFile
		invoke SendDlgItemMessage,hWin,IDC_EDT2,WM_SETTEXT,0,offset lngFile
		invoke SendDlgItemMessage,hWin,IDC_TRBLANGOPT,TBM_SETRANGEMIN,FALSE,24
		invoke SendDlgItemMessage,hWin,IDC_TRBLANGOPT,TBM_SETRANGEMAX,FALSE,48
		invoke SendDlgItemMessage,hWin,IDC_TRBLANGOPT,TBM_SETPOS,TRUE,nSize
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_BTN1
				invoke SendMessageW,hEdt,EM_GETMODIFY,0,0
				.if eax
					invoke MessageBox,hWin,addr szSaveChanges,addr szRadLNG,MB_ICONQUESTION or MB_YESNOCANCEL
					.if eax==IDYES
						invoke SaveTheFile
						.if eax
							mov		eax,TRUE
							ret
						.endif
					.elseif eax==IDCANCEL
						mov		eax,TRUE
						ret
					.endif
				.endif
				invoke SendMessage,hEdt,WM_SETTEXT,0,offset szNULL
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szDivider
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szIniLang
				invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szDivider
				mov		nInx,0
				.while TRUE
					invoke SendDlgItemMessageW,hWin,IDC_LST1,LB_GETITEMDATA,nInx,0
					.break .if eax==LB_ERR
					.if eax==998 || eax==999
						invoke DumpMenu,eax
					.elseif eax==997
						invoke DumpStrings
					.else
						invoke DialogBoxParam,hInstance,eax,hWin,offset DumpDlgProc,eax
					.endif
					invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szDivider
					inc		nInx
				.endw
				mov		esi,offset szAddins
				.while byte ptr [esi]
					invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,esi
					invoke SendMessage,hEdt,EM_REPLACESEL,FALSE,offset szDivider
					invoke lstrlen,esi
					lea		esi,[esi+eax+1]
				.endw
			.elseif eax==IDC_BTN2
				mov		ofn.lStructSize,sizeof OPENFILENAME
				mov		eax,hWin
				mov		ofn.hwndOwner,eax
				mov		eax,hInstance
				mov		ofn.hInstance,eax
				mov		ofn.lpstrFilter,offset szFilter
				mov		ofn.lpstrCustomFilter,NULL
				mov		ofn.nMaxCustFilter,0
				mov		ofn.nFilterIndex,0
				mov		ofn.lpstrFile,offset lngFile
				mov		ofn.nMaxFile,sizeof lngFile
				mov		ofn.lpstrFileTitle,NULL
				mov		ofn.nMaxFileTitle,0
				mov		ofn.lpstrInitialDir,NULL
				mov		ofn.lpstrTitle,NULL
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				mov		ofn.nFileOffset,0
				mov		ofn.nFileExtension,0
				mov		ofn.lpstrDefExt,0
				mov		ofn.lCustData,0
				mov		ofn.lpfnHook,0
				mov		ofn.lpTemplateName,0
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SendDlgItemMessage,hWin,IDC_EDT2,WM_SETTEXT,0,offset lngFile
					invoke ReadTheFile
				.endif
			.elseif eax==IDC_BTN3
				invoke SaveTheFile
			.elseif eax==IDC_BTN4
				invoke RtlZeroMemory,addr cf,sizeof cf
				mov		cf.lStructSize,sizeof CHOOSEFONT
				invoke GetDC,hWin
				mov		hDC, eax
				mov		cf.hDC,eax
				mov		eax,hWin
				mov		cf.hWndOwner,eax
				mov		cf.lpLogFont,offset lfnt
				mov		cf.iPointSize,0
				mov		cf.Flags,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT
				mov		cf.rgbColors,0
				mov		cf.lCustData,0
				mov		cf.lpfnHook,0
				mov		cf.lpTemplateName,0
				mov		cf.hInstance,0
				mov		cf.lpszStyle,0
				mov		cf.nFontType,0
				mov		cf.Alignment,0
				mov		cf.nSizeMin,0
				mov		cf.nSizeMax,0
				invoke ChooseFont,addr cf
				.if eax
					;Create font used by Text Editor and test dialogs
					invoke DeleteObject,hLngFont
					invoke CreateFontIndirect,addr lfnt
					mov		hLngFont,eax
					invoke SendMessage,hEdt,WM_SETFONT,hLngFont,TRUE
					invoke lstrcpy,addr buffer,addr lfnt.lfFaceName
					invoke lstrcat,addr buffer,addr szComma
					mov		edx,lfnt.lfHeight
					invoke PutItem,edx,addr buffer,TRUE
					mov		edx,lfnt.lfWeight
					invoke PutItem,edx,addr buffer,TRUE
					movzx	edx,lfnt.lfCharSet
					invoke PutItem,edx,addr buffer,FALSE
					invoke WritePrivateProfileString,addr szLang,addr szFont,addr buffer,addr lngIni
				.endif
				invoke ReleaseDC,hWin,hDC
			.endif
		.elseif edx==EN_CHANGE && eax==IDC_EDT2
			invoke SendDlgItemMessage,hWin,IDC_EDT2,WM_GETTEXT,sizeof lngFile,offset lngFile
		.elseif edx==LBN_DBLCLK
			invoke SendDlgItemMessage,hWin,IDC_LST1,LB_GETCURSEL,0,0
			invoke SendDlgItemMessage,hWin,IDC_LST1,LB_GETITEMDATA,eax,0
			.if eax>=151 && eax<=154
				invoke DialogBoxParamW,hInstance,150,hWin,offset TestDlgProc,eax
			.else
				invoke DialogBoxParamW,hInstance,eax,hWin,offset TestDlgProc,eax
			.endif
		.endif
	.elseif eax==WM_HSCROLL
		invoke SendDlgItemMessage,hWin,IDC_TRBLANGOPT,TBM_GETPOS,0,0
		mov		nSize,eax
		invoke BinToDec,nSize,addr buffer
		invoke WritePrivateProfileString,addr szLang,addr szSize,addr buffer,addr lngIni
	.elseif eax==WM_CLOSE
		invoke SendMessageW,hEdt,EM_GETMODIFY,0,0
		.if eax
			invoke MessageBox,hWin,addr szSaveChanges,addr szRadLNG,MB_ICONQUESTION or MB_YESNOCANCEL
			.if eax==IDYES
				invoke SaveTheFile
				.if eax
					xor		eax,eax
					ret
				.endif
			.elseif eax==IDCANCEL
				xor		eax,eax
				ret
			.endif
		.endif
		.if hIniMem
			invoke GlobalFree,hIniMem
		.endif
		invoke DestroyIcon,hIcon
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

end start
