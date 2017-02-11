
IDD_LANGUAGE		equ 5000
IDC_CBOLANG			equ 5001
IDC_CBOSUBLANG		equ 5002

.const

szLngRc				db 'Lng.rc',0

.data?

nLang				dd ?
nSubLang			dd ?

.code

LanguageEditExport proc fOut:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[64]:BYTE
	LOCAL	hWrMem:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024
	mov     hWrMem,eax
	invoke GlobalLock,hWrMem
	mov		edi,hWrMem
	invoke GetPrivateProfileString,addr szLanguage,addr szLanguage,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
	.if eax
		invoke SaveStr,edi,addr szLanguage
		add		edi,eax
		mov		al,' '
		stosb
		invoke strcpy,edi,addr buffer
		invoke strlen,edi
		add		edi,eax
		mov		al,','
		stosb
		invoke GetPrivateProfileString,addr szLanguage,addr szSubLang,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		invoke strcpy,edi,addr buffer
		invoke strlen,edi
		add		edi,eax
		mov		ax,0A0Dh
		stosw
	.endif
	.if fOut
		invoke OutputSelect,2
		invoke OutputClear
		invoke ShowOutput
		invoke TextToOutput,hWrMem
	.else
		mov		word ptr buffer,'0'
		invoke GetPrivateProfileString,addr iniMakeFile,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		invoke strlen,addr buffer
		sub		eax,4
		mov		byte ptr buffer[eax],0
		invoke strcpy,addr buffer1,addr ProjectPath
		invoke strcat,addr buffer1,addr szRes
		invoke strcat,addr buffer1,addr buffer
		invoke strcat,addr buffer1,addr szLngRc
		invoke GetFileAttributes,addr buffer1
		.if eax==-1
			invoke DllProc,hWnd,AIM_PROJECTADDNEW,-5,addr ProjectFile,RAM_PROJECTADDNEW
		.endif
		invoke CreateFile,addr buffer1,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strlen,hWrMem
			mov		nBytes,eax
			invoke WriteFile,hFile,hWrMem,nBytes,addr nBytes,NULL
			invoke CloseHandle,hFile
			inc		fResChanged
			invoke DllProc,hWnd,AIM_RCSAVED,7,addr buffer1,RAM_RCSAVED
		.endif
	.endif
	invoke GlobalUnlock,hWrMem
	invoke GlobalFree,hWrMem
	ret

LanguageEditExport endp

LanguageInit proc

	invoke GetPrivateProfileInt,addr szLanguage,addr szLanguage,0,addr ProjectFile
	mov		nLang,eax
	invoke GetPrivateProfileInt,addr szLanguage,addr szSubLang,0,addr ProjectFile
	mov		nSubLang,eax
	ret

LanguageInit endp

LanguageSave proc
	LOCAL	buffer[64]:BYTE

	invoke BinToDec,nLang,addr buffer
	invoke WritePrivateProfileString,addr szLanguage,addr szLanguage,addr buffer,addr ProjectFile
	invoke BinToDec,nSubLang,addr buffer
	invoke WritePrivateProfileString,addr szLanguage,addr szSubLang,addr buffer,addr ProjectFile
	ret

LanguageSave endp

LanguageProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[64]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		call	GetLang
		invoke SetLanguage,hWin,IDD_LANGUAGE,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendDlgItemMessage,hWin,IDC_CBOLANG,CB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_CBOLANG,CB_GETITEMDATA,eax,0
				mov		nLang,eax
				invoke SendDlgItemMessage,hWin,IDC_CBOSUBLANG,CB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_CBOSUBLANG,CB_GETITEMDATA,eax,0
				mov		nSubLang,eax
				invoke SendMessage,hWin,WM_CLOSE,NULL,TRUE
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,FALSE
			.endif
		.elseif edx==CBN_SELCHANGE
			.if eax==IDC_CBOLANG
				invoke SendDlgItemMessage,hWin,IDC_CBOLANG,CB_GETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_CBOLANG,CB_GETITEMDATA,eax,0
				mov		nLang,eax
				mov		nSubLang,0
				.if eax
					mov		nSubLang,1
				.endif
				call	GetLang
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,lParam
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

GetLang:
	invoke SendDlgItemMessage,hWin,IDC_CBOLANG,CB_RESETCONTENT,0,0
	invoke SendDlgItemMessage,hWin,IDC_CBOSUBLANG,CB_RESETCONTENT,0,0
	mov		nInx,0
	.while nInx<100
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr szLanguage,addr buffer,NULL,addr prnbuff,sizeof prnbuff,addr iniFile
		.if eax
			invoke iniGetItem,addr prnbuff,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_CBOLANG,CB_ADDSTRING,0,addr buffer
			push	eax
			invoke iniGetItem,addr prnbuff,addr buffer
			invoke VerinfoGetVal,addr buffer
			pop		edx
			.if eax==nLang
				pushad
				invoke SendDlgItemMessage,hWin,IDC_CBOLANG,CB_SETCURSEL,edx,0
				.while prnbuff
					invoke iniGetItem,addr prnbuff,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_CBOSUBLANG,CB_ADDSTRING,0,addr buffer
					push	eax
					invoke iniGetItem,addr prnbuff,addr buffer
					invoke VerinfoGetVal,addr buffer
					pop		edx
					.if eax==nSubLang
						pushad
						invoke SendDlgItemMessage,hWin,IDC_CBOSUBLANG,CB_SETCURSEL,edx,0
						popad
					.endif
					invoke SendDlgItemMessage,hWin,IDC_CBOSUBLANG,CB_SETITEMDATA,edx,eax
				.endw
				popad
			.endif
			invoke SendDlgItemMessage,hWin,IDC_CBOLANG,CB_SETITEMDATA,edx,eax
		.endif
		inc		nInx
	.endw
	retn

LanguageProc endp
