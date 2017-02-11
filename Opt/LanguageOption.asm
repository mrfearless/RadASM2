IDD_DLGLANGUAGE		equ 5400
IDC_LSTLANGOPT		equ 5402
IDC_TRBLANGOPT		equ 5404
IDC_BTNLANGOPTAPPLY	equ 10

.const

szAnyLng			db '*.lng',0
szLang				dw 'L','a','n','g',0
szNone				dw '(','N','o','n','e',')',0

.data?

irect				RECT <?>

.code

LanguageOptionProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hwfd:DWORD
	LOCAL	val:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	hIniMem
		mov		hIniMem,0
		invoke GetWindowRect,hWin,addr irect
		xor		ebx,ebx
		mov		val,256
		invoke SendDlgItemMessageW,hWin,IDC_LSTLANGOPT,LB_SETTABSTOPS,1,addr val
		invoke SendDlgItemMessageW,hWin,IDC_LSTLANGOPT,LB_ADDSTRING,0,addr szNone
		invoke strcpy,addr buffer,addr AppPath
		invoke strcat,addr buffer,addr szLangPath
		invoke strcat,addr buffer,addr szAnyLng
		invoke FindFirstFile,addr buffer,addr wfd
		.if eax!=INVALID_HANDLE_VALUE
			;Save returned handle
			mov		hwfd,eax
		  Next:
			invoke strcpy,addr buffer,addr AppPath
			invoke strcat,addr buffer,addr szLangPath
			invoke strcat,addr buffer,addr wfd.cFileName
			invoke strlen,addr buffer
			mov		edx,eax
			invoke MultiByteToWideChar,CP_ACP,0,addr buffer,edx,addr iniBuffer,sizeof iniBuffer/2
			mov		word ptr iniBuffer[eax*2],0
			invoke ConvertFile,addr buffer
			mov		word ptr buffer,0
			invoke GetLangString,addr szLang,addr szLang,addr buffer,sizeof buffer/2
			invoke lstrcatW,addr buffer,addr szTab
			invoke strlen,addr wfd.cFileName
			mov		edx,eax
			invoke MultiByteToWideChar,CP_ACP,0,addr wfd.cFileName,edx,addr iniBuffer,sizeof iniBuffer/2
			mov		word ptr iniBuffer[eax*2],0
			invoke lstrcatW,addr buffer,addr iniBuffer
			invoke SendDlgItemMessageW,hWin,IDC_LSTLANGOPT,LB_ADDSTRING,0,addr buffer
			push	eax
			invoke iniInStr,addr lngFile,addr wfd.cFileName
			pop		edx
			.if eax!=-1
				mov		ebx,edx
			.elseif  edx<=ebx
				inc		ebx
			.endif
			invoke GlobalFree,hIniMem
			mov		hIniMem,0
			invoke FindNextFile,hwfd,addr wfd
			or		eax,eax
			jne		Next
			;No more matches, close find
			invoke FindClose,hwfd
		.endif
		invoke SendDlgItemMessage,hWin,IDC_LSTLANGOPT,LB_SETCURSEL,ebx,0
		invoke SendDlgItemMessage,hWin,IDC_TRBLANGOPT,TBM_SETRANGEMIN,FALSE,24
		invoke SendDlgItemMessage,hWin,IDC_TRBLANGOPT,TBM_SETRANGEMAX,FALSE,48
		invoke SendDlgItemMessage,hWin,IDC_TRBLANGOPT,TBM_SETPOS,TRUE,nLngSize
		pop		hIniMem
		invoke SetLanguage,hWin,IDD_DLGLANGUAGE,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetDlgItem,hWin,IDC_BTNLANGOPTAPPLY
				invoke IsWindowEnabled,eax
				.if eax
					call	UpdateLang
				.endif
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNLANGOPTAPPLY
				call	UpdateLang
				invoke EndDialog,hWin,NULL
				invoke ModalDialog,hInstance,IDD_DLGLANGUAGE,hWnd,addr LanguageOptionProc,0
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.elseif edx==LBN_SELCHANGE
			invoke GetDlgItem,hWin,IDC_BTNLANGOPTAPPLY
			invoke EnableWindow,eax,TRUE
		.endif
	.elseif eax==WM_HSCROLL
		invoke GetDlgItem,hWin,IDC_BTNLANGOPTAPPLY
		invoke EnableWindow,eax,TRUE
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

UpdateLang:
	invoke SendDlgItemMessage,hWin,IDC_TRBLANGOPT,TBM_GETPOS,0,0
	mov		nLngSize,eax
	invoke SendDlgItemMessage,hWin,IDC_LSTLANGOPT,LB_GETCURSEL,0,0
	mov		edx,eax
	invoke SendDlgItemMessageW,hWin,IDC_LSTLANGOPT,LB_GETTEXT,edx,addr buffer
	lea		ebx,buffer
	.while word ptr [ebx] && word ptr [ebx]!=VK_TAB
		add		ebx,2
	.endw
	.if word ptr [ebx]
		add		ebx,2
		invoke lstrlenW,ebx
		mov		edx,eax
		invoke WideCharToMultiByte,CP_ACP,0,ebx,edx,addr buffer,sizeof buffer,NULL,NULL
		mov		buffer[eax],0
		invoke strcpy,addr lngFile,addr AppPath
		invoke strcat,addr lngFile,addr szLangPath
		invoke strcat,addr lngFile,addr buffer
		invoke ConvertFile,addr lngFile
	.else
		mov		buffer,0
		mov		lngFile,0
		.if hIniMem
			invoke GlobalFree,hIniMem
			mov		hIniMem,0
		.endif
	.endif
	invoke WritePrivateProfileString,addr iniWindow,addr szLanguage,addr buffer,offset iniFile
	invoke BinToDec,nLngSize,addr buffer
	invoke WritePrivateProfileString,addr iniWindow,addr iniMagnify,addr buffer,offset iniFile
	invoke DllProc,hWnd,AIM_ADDINSLOADED,0,0,RAM_ADDINSLOADED
	invoke DllProc,hWnd,AIM_LANGUAGECHANGE,0,0,RAM_LANGUAGECHANGE
	invoke iniAddMenu
	invoke iniDisMenu
	invoke UpdateMenu,hToolMenu,998
	invoke UpdateMenu,hMenu,999
	invoke DrawMenuBar,hWnd
	retn

LanguageOptionProc endp