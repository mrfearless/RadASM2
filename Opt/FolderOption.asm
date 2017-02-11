
IDD_PATHOPTION		equ 2300
IDC_UDC1			equ 10001
IDC_UDC2			equ 10002
IDC_UDC3			equ 10003
IDC_UDC4			equ 10004
IDC_UDC5			equ 10005
IDC_UDC6			equ 10006
IDC_UDC7			equ 10007
IDC_UDC8			equ 10008
IDC_UDC9			equ 10009
IDC_UDC10			equ 10010
IDC_UDC11			equ 10011

IDC_STC				equ 1001
IDC_EDT				equ 1002
IDC_BTN				equ 1003

UDCM_INIT			equ WM_USER+1
UDCM_UPDATE			equ WM_USER+2

.data

hUse				dd 0
UdcClassName		db 'UDCCLASS',0
szBtnText			db '...',0
szBrowse			db 'Browse For Folder',0
szDir				db 'App ($A):',0
					db '$A',0
					db 'Addins ($D):',0
					db '$D',0
					db 'Binary ($B):',0
					db '$B',0
					db 'Help ($H):',0
					db '$H',0
					db 'Include ($I):',0
					db '$I',0
					db 'Library ($L):',0
					db '$L',0
					db 'Macro ($M):',0
					db '$M',0
					db 'Projects ($P):',0
					db '$P',0
					db 'Sniplets ($S):',0
					db '$S',0
					db 'Templates ($T):',0
					db '$T',0
					db 'Debug ($E):',0
					db '$E',0


.data?

pidl				dd ?
bri					BROWSEINFO <?>

;#########################################################################

.code

BrowseFolder proc hWin:HWND,nID:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		bri.pidlRoot,0
	mov		bri.pszDisplayName,0
;	mov		eax,offset szBrowse
	xor		eax,eax
	mov		bri.lpszTitle,eax
	mov		bri.ulFlags,BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT 
	mov		bri.lpfn,BrowseCallbackProc
	; get path   
	invoke SendDlgItemMessage,hWin,nID,WM_GETTEXT,sizeof buffer,addr buffer
	lea		eax,buffer
	mov		bri.lParam,eax 
	mov		bri.iImage,0
	invoke SHBrowseForFolder,offset bri
	.if !eax
		jmp		GetOut
	.endif      
	mov		pidl,eax
	invoke SHGetPathFromIDList,pidl,addr buffer
	; set new path back to edit
	invoke SendDlgItemMessage,hWin,nID,WM_SETTEXT,0,addr buffer
  GetOut:
	ret

BrowseFolder endp

;--------------------------------------------------------------------------------
; set initial folder in browser
BrowseCallbackProc proc hwnd:DWORD,uMsg:UINT,lParam:LPARAM,lpData:DWORD

	mov eax,uMsg
	.if eax==BFFM_INITIALIZED
		invoke PostMessage,hwnd,BFFM_SETSELECTION,TRUE,lpData
		invoke PostMessage,hwnd,BFFM_SETSTATUSTEXT,0,addr szBrowse
	.endif
	xor eax, eax
	ret

BrowseCallbackProc endp

;--------------------------------------------------------------------------------

PathOptionProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hFnt:DWORD
	LOCAL	ID:DWORD
	LOCAL	lpDir:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetLanguage,hWin,IDD_PATHOPTION,FALSE
		invoke GetDlgItem,hWin,IDUSE
		mov		hUse,eax
		invoke SendMessage,hUse,WM_GETFONT,0,0
		mov		hFnt,eax
		mov		ID,IDC_UDC1
		mov		lpDir,offset szDir
		.while ID<=IDC_UDC11
			invoke SendDlgItemMessage,hWin,ID,UDCM_INIT,hFnt,lpDir
			invoke strlen,lpDir
			inc		eax
			add		lpDir,eax
			invoke strlen,lpDir
			inc		eax
			add		lpDir,eax
			inc		ID
		.endw
		invoke EnableWindow,hUse,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDOK
				invoke IsWindowEnabled,hUse
				.if eax
					call Update
				.endif
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDUSE
				call Update
				invoke EnableWindow,hUse,FALSE
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

  Update:
	mov		ID,IDC_UDC1
	mov		lpDir,offset szDir
	.while ID<=IDC_UDC11
		invoke strlen,lpDir
		inc		eax
		add		lpDir,eax
		invoke SendDlgItemMessage,hWin,ID,UDCM_UPDATE,0,lpDir
		invoke strlen,lpDir
		inc		eax
		add		lpDir,eax
		inc		ID
	.endw
	invoke iniReadPaths,NULL
	retn

PathOptionProc endp

UdcProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_CREATE
		invoke CreateWindowEx,0,addr szStatic,NULL,WS_VISIBLE or WS_CHILD,0,0,0,0,hWin,IDC_STC,hInstance,0
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szEdit,NULL,WS_VISIBLE or WS_CHILD or WS_TABSTOP or ES_AUTOHSCROLL,0,0,0,0,hWin,IDC_EDT,hInstance,0
		invoke CreateWindowEx,0,addr szButton,addr szBtnText,WS_VISIBLE or WS_CHILD or WS_TABSTOP,0,0,0,0,hWin,IDC_BTN,hInstance,0
	.elseif eax==UDCM_INIT
		invoke SendDlgItemMessage,hWin,IDC_STC,WM_SETFONT,wParam,TRUE
		invoke SendDlgItemMessage,hWin,IDC_STC,WM_SETTEXT,0,lParam
		invoke SendDlgItemMessage,hWin,IDC_EDT,WM_SETFONT,wParam,TRUE
		invoke SendDlgItemMessage,hWin,IDC_EDT,EM_LIMITTEXT,MAX_PATH-1,0
		invoke strlen,lParam
		inc		eax
		add		lParam,eax
		invoke GetPrivateProfileString,addr iniPaths,lParam,addr szNULL,addr buffer,128,addr iniAsmFile
		invoke SendDlgItemMessage,hWin,IDC_EDT,WM_SETTEXT,0,addr buffer
	.elseif eax==UDCM_UPDATE
		invoke SendDlgItemMessage,hWin,IDC_EDT,WM_GETTEXT,MAX_PATH,addr buffer
		invoke WritePrivateProfileString,addr iniPaths,lParam,addr buffer,addr iniAsmFile
	.elseif eax==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		invoke GetDlgItem,hWin,IDC_STC
		mov		edx,rect.right
		shr		edx,2
		add		edx,16
		push	edx
		invoke MoveWindow,eax,0,0,edx,rect.bottom,TRUE
		invoke GetDlgItem,hWin,IDC_EDT
		mov		edx,rect.right
		pop		ecx
		sub		edx,ecx
		dec		edx
		sub		edx,rect.bottom
		invoke MoveWindow,eax,ecx,0,edx,rect.bottom,TRUE
		invoke GetDlgItem,hWin,IDC_BTN
		mov		edx,rect.right
		sub		edx,rect.bottom
		invoke MoveWindow,eax,edx,0,rect.bottom,rect.bottom,TRUE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED && eax==IDC_BTN
			invoke BrowseFolder,hWin,IDC_EDT
;			invoke GetDlgItemText,hWin,IDC_EDT,addr buffer,MAX_PATH
;			invoke BrowseForFolder,hWin,addr buffer,addr szBrowse,addr buffer
;			.if eax
;				invoke SetDlgItemText,hWin,IDC_EDT,addr buffer
;			.endif
		.elseif edx==EN_CHANGE
			invoke EnableWindow,hUse,TRUE
		.endif
	.elseif eax==WM_SETFOCUS
		invoke GetDlgItem,hWin,IDC_BTN
		invoke SetFocus,eax
	.endif
	invoke DefWindowProc,hWin,uMsg,wParam,lParam
	ret

UdcProc endp

