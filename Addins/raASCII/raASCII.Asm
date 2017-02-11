;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include raASCII.inc
include ASCII.asm

.code

AddMenu proc
	LOCAL	nMnu:DWORD
	LOCAL	hMnu:DWORD

	.if IDAddIn
		mov		nMnu,6
		;Adjust topmost popup if maximized.
		mov		eax,[lpData]
		mov		eax,(ADDINDATA ptr [eax]).fMaximized
		.if eax
			inc		nMnu
		.endif
		;Get handle of menu
		mov		eax,[lpHandles]
		mov		eax,(ADDINHANDLES ptr [eax]).hMenu
		;Get handle of Tools popup
		invoke GetSubMenu,eax,nMnu		;Tools menu
		mov		hMnu,eax
		;Add our menuitem
		invoke AppendMenu,hMnu,MF_STRING,IDAddIn,addr szMenuName
	.endif
	ret

AddMenu endp

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD
	mov	ebx,hWin

	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov	lpHandles,eax

	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov	lpProc,eax

	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov	lpData,eax

	; Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov IDAddIn,eax
	invoke AddMenu
	
	; Messages to hook into
	mov	eax, RAM_COMMAND OR RAM_CLOSE OR RAM_MENUREBUILD OR RAM_TBRTOOLTIP OR RAM_PROJECTOPENED OR RAM_PROJECTCLOSE

	; ECX and EDX must be null before we return
	xor ecx, ecx
	xor edx, edx
	ret 

InstallDll Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov	eax, uMsg
	.if eax == AIM_COMMAND
		mov eax,wParam
		movzx edx,ax
		shr eax, 16
		.IF edx == IDAddIn && eax == BN_CLICKED
			invoke InitCommonControls
			mov eax,lpHandles
			mov eax,[eax].ADDINHANDLES.hWnd
			invoke CreateDialogParam,hInstance,IDD_DLG1,eax,addr DlgProc,NULL
			mov eax,TRUE
			ret
		.ENDIF
	.ELSEIF eax==AIM_CLOSE
		mov edx,lpHandles
		mov eax,[edx].ADDINHANDLES.hMenu
		invoke DeleteMenu,eax,IDAddIn,MF_BYCOMMAND
		mov IDAddIn,0
	.ELSEIF eax==AIM_MENUREBUILD
		invoke AddMenu
	.ELSEIF eax==AIM_TBRTOOLTIP
		;
	.ELSEIF eax==AIM_PROJECTCLOSE
		;
	.ELSEIF eax==AIM_PROJECTOPENED
		;
	.endif

	mov eax,FALSE
	ret
DllProc Endp

;#########################################################################

End DllEntry
