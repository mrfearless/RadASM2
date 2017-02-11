
IDD_DLGOPTIONFILEASS	equ 5300
IDC_CHKRAP				equ 5301
IDC_CHKASM				equ 5302
IDC_CHKINC				equ 5303
IDC_CHKDLG				equ 5304
IDC_CHKMNU				equ 5305
IDC_CHKRC				equ 5306
IDC_BTNREMOVEASS		equ 5307

.const

szOpen					db '\Open',0
CmdFmt0					db 'Shell',0
CmdFmt1					db '\Command',0
CmdFmt2					db ' "%1"',0

.code

RegisterFileExtension PROC uses ebx,pFileExt:DWORD,pCmd:DWORD,pCmdLine:DWORD,fDel:DWORD
	LOCAL	hClassKey:DWORD
	LOCAL	hCmdKey:DWORD
	LOCAL	Disposition:DWORD
	LOCAL	szExt[16]:BYTE
	LOCAL	szCmd[260]:BYTE

	; Set to NULL for API calls
	xor		ebx,ebx
	; Be sure the extension starts with .
	mov		eax,[pFileExt]
	mov		al,[eax]
	cmp		al,2EH
	je @f
		lea		eax,szExt
		mov		byte ptr [eax],2EH
		inc		eax
		jmp		C1
	@@:
		lea		eax,szExt
	C1:
	invoke lstrcpy,eax,[pFileExt]
	invoke RegCreateKeyEx,HKEY_CLASSES_ROOT,addr szExt,ebx,ebx,REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,ebx,ADDR hClassKey,ADDR Disposition
	invoke lstrcpy,ADDR szCmd,ADDR CmdFmt0
	invoke lstrcat,ADDR szCmd,[pCmd]
	invoke lstrcat,ADDR szCmd,ADDR CmdFmt1
	.if !fDel
		invoke RegCreateKeyEx,[hClassKey],ADDR szCmd,ebx,ebx,REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,ebx,ADDR hCmdKey,ADDR Disposition
		invoke lstrlen,[pCmdLine]
		inc		eax
		invoke RegSetValueEx,[hCmdKey],ebx,ebx,REG_SZ,[pCmdLine],eax
		invoke RegCloseKey,[hCmdKey]
	.else
		invoke RegDeleteKey,[hClassKey],addr szCmd
		invoke lstrcpy,ADDR szCmd,ADDR CmdFmt0
		invoke lstrcat,ADDR szCmd,[pCmd]
		invoke RegDeleteKey,[hClassKey],addr szCmd
		invoke lstrcpy,ADDR szCmd,ADDR CmdFmt0
		invoke RegDeleteKey,[hClassKey],addr szCmd
		invoke RegDeleteKey,HKEY_CLASSES_ROOT,addr szExt
	.endif
	invoke RegCloseKey,[hClassKey]
	xor eax,eax
	ret

RegisterFileExtension ENDP

FileAssDialogProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[8]:BYTE
	LOCAL	fDel:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke CheckDlgButton,hWin,IDC_CHKRAP,BST_CHECKED
		invoke SetLanguage,hWin,IDD_DLGOPTIONFILEASS,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetModuleFileName,0,addr buffer,sizeof buffer
				invoke strcat,addr buffer,offset CmdFmt2
				mov		fDel,FALSE
				call	Update
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNREMOVEASS
				invoke GetModuleFileName,0,addr buffer,sizeof buffer
				invoke strcat,addr buffer,offset CmdFmt2
				mov		fDel,TRUE
				call	Update
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Update:
	mov		dword ptr buffer1[4],0
	mov		edx,IDC_CHKRAP
	mov		eax,'par.'
	call	Register
	mov		edx,IDC_CHKASM
	mov		eax,'msa.'
	call	Register
	mov		edx,IDC_CHKINC
	mov		eax,'cni.'
	call	Register
	mov		edx,IDC_CHKDLG
	mov		eax,'gld.'
	call	Register
	mov		edx,IDC_CHKMNU
	mov		eax,'unm.'
	call	Register
	mov		edx,IDC_CHKRC
	mov		eax,'cr.'
	call	Register
	retn

Register:
	mov		dword ptr buffer1,eax
	invoke IsDlgButtonChecked,hWin,edx
	.if eax
		invoke RegisterFileExtension,addr buffer1,addr szOpen,addr buffer,fDel
	.endif
	retn

FileAssDialogProc endp
