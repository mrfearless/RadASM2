;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include DblClk.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntry Endp

AddMenu proc

	.if IDAddIn
		mov		edx,6		;Tools menu
		;Adjust topmost popup if maximized.
		mov		eax,lpData
		add		edx,[eax].ADDINDATA.fMaximized
		;Get handle of Tools popup
		mov		eax,lpHandles
		invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,edx
		;Add our menuitem
		invoke AppendMenu,eax,MF_STRING,IDAddIn,addr szDblClk
	.endif
	ret

AddMenu endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD
	mov	ebx,hWin

	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov	lpHandles,eax

	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov	lpProc,eax

	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0
	mov	lpData,eax

	; If Option (fOpt) = 0 then exit
	mov eax,fOpt
	test eax,eax
	je @F
		; Allocate a new menu id
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov IDAddIn,eax
		; Add menu item
		invoke AddMenu
		; Messages to hook into
		mov	eax, RAM_COMMAND or RAM_OUTPUTDBLCLK or RAM_MENUREBUILD or RAM_CLOSE

	@@:
	; ECX and EDX must be null before we return
	xor ecx, ecx
	xor edx, edx
	ret 

InstallDll Endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

DialogProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hDlg,eax
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if eax==BN_CLICKED
			.if edx==IDC_BTNEXIT
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
		mov		hDlg,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DialogProc endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from
	LOCAL	buffer[32]:BYTE

	mov	eax, uMsg
	.IF eax == AIM_COMMAND
		mov eax,wParam
		movzx edx,ax
		shr eax, 16
		.IF edx == IDAddIn && eax == BN_CLICKED
			; Your addin has been selected
			.if hDlg
				invoke SetFocus,hDlg
			.else
				invoke CreateDialogParam,hInstance,IDD_DLGDBLCLK,hWin,offset DialogProc,NULL
			.endif
		.ENDIF
	.ELSEIF eax==AIM_OUTPUTDBLCLK
		; Get dblclicked word
		invoke SendMessage,hWin,REM_GETWORD,sizeof buffer,addr buffer
		; Is the word something I can use?
		invoke lstrlen,addr buffer
		.if eax==5 && buffer=='A'
			.if hDlg
				invoke SetFocus,hDlg
			.else
				invoke CreateDialogParam,hInstance,IDD_DLGDBLCLK,hWin,offset DialogProc,NULL
			.endif
			invoke SetDlgItemText,hDlg,IDC_EDT1,addr buffer
			; Returne TRUE to prevent RadASM from doing default action
			mov eax,TRUE
			jmp Ex
		.endif
	.ELSEIF eax==AIM_MENUREBUILD
		; Add menu item
		invoke AddMenu
	.ELSEIF eax==AIM_CLOSE
		;Now is the time to destroy and undo things
		.if hDlg
			;Close the dialog
			invoke SendMessage,hDlg,WM_CLOSE,0,0
			mov		hDlg,0
		.endif
		.if IDAddIn
			;Remove menu item
			mov		edx,6		;Tools menu
			;Adjust topmost popup if maximized.
			mov		eax,lpData
			add		edx,[eax].ADDINDATA.fMaximized
			;Get handle of Tools popup
			mov		eax,lpHandles
			invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,edx
			invoke DeleteMenu,eax,IDAddIn,MF_BYCOMMAND
			mov		IDAddIn,0
		.endif
	.ENDIF
	mov eax,FALSE
  Ex:
	ret
DllProc Endp

;#########################################################################

End DllEntry
