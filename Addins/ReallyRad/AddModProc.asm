
AddModProc				PROTO :HWND,:UINT,:WPARAM,:LPARAM

.const

IDD_DLGMODPROC					equ 9000
IDOK							equ 1
IDCANCEL						equ 2
IDC_EDTMN						equ 9001
IDC_CBOPN						equ 9005
IDC_BTNMN						equ 9002
IDC_BTNTP						equ 9004
IDC_EDTPT						equ 9003
szProcName						db 'ReallyRad#2',0

.code

AddModProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	TRUE
		push	offset szProcName
		push	hWin
		mov		eax,lpPStruct
		call	[eax].ADDINPROCS.lpSetLanguage
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==IDC_BTNMN
			.elseif eax==IDC_BTNTP
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

AddModProc endp
