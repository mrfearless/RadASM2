.386
.model flat,stdcall
option casemap:none

include DlgToWin.inc
include CreateWin.asm

.code

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

    push    hInst
    pop     hInstance
    mov     eax,TRUE
    ret

DllEntry Endp

AddMenu proc
	LOCAL	nMnu:DWORD
	LOCAL	hMnu:DWORD

	.if nMenuID
		mov		nMnu,6
		;Adjust topmost popup if maximized.
		mov		eax,[lpDStruct]
		mov		eax,(ADDINDATA ptr [eax]).fMaximized
		.if eax
			inc		nMnu
		.endif
		;Get handle of menu
		mov		eax,[lpHStruct]
		mov		eax,(ADDINHANDLES ptr [eax]).hMenu
		;Get handle of Tools popup
		invoke GetSubMenu,eax,nMnu		;Tools menu
		mov		hMnu,eax
		;Add our menuitem
		invoke AppendMenu,hMnu,MF_STRING,nMenuID,addr szDlgToWin
	.endif
	ret

AddMenu endp

;fOpt is a value read from ini and passed to the dll
;Use for option settings
InstallDll proc hWin:DWORD,fOpt:DWORD

	mov		eax,hWin
	mov		hWnd,eax
	;Get pointer to handles struct
	invoke SendMessage,hWin,AIM_GETHANDLES,0,0
	mov		lpHStruct,eax
	;Get pointer to proc struct
	invoke SendMessage,hWin,AIM_GETPROCS,0,0
	mov		lpPStruct,eax
	;Get pointer to data struct
	invoke SendMessage,hWin,AIM_GETDATA,0,0
	mov		lpDStruct,eax
	;Check if option selected
	mov		eax,fOpt
	and		eax,1
	.if eax
		;Allocate a new menu id
		invoke SendMessage,hWin,AIM_GETMENUID,0,0
		mov		nMenuID,eax
		invoke AddMenu
		mov		eax,RAM_COMMAND or RAM_INITMENUPOPUP or RAM_MENUREBUILD or RAM_CLOSE
	.endif
	;On return eax must contain what msg the dll are hooking into
	;Note!
	;Also set ecx and edx to NULL in case more than 32 hooks are
	;needed in the future.
	xor		ecx,ecx
	xor		edx,edx
    ret

InstallDll endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

;This proc handles messages sent from RadASM to our dll
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hEdt:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	hMem:DWORD
	LOCAL	fEnable:DWORD
	LOCAL	pt:POINT
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_COMMAND
		;Return TRUE to prevent RadASM and other dll's from
		;processing command.
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==nMenuID
			invoke DialogBoxParam,hInstance,IDD_DLGCODEWRITE,hWin,offset CodeWriteProc,0
			;Returning TRUE when executing private commands speeds up things
			mov		eax,TRUE
			ret
		.endif
	.elseif eax==WM_INITMENUPOPUP
		;Always return FALSE
		;Enable/gray menuitem
		;Check if there is a topmost dialog edit window
		mov		eax,[lpHStruct]
		mov		eax,(ADDINHANDLES ptr [eax]).hDialog
		.if eax
			mov		edx,MF_ENABLED
		.else
			mov		edx,MF_GRAYED
		.endif
		;Enable/disable the menuitem
		mov		eax,[lpHStruct]
		mov		eax,(ADDINHANDLES ptr [eax]).hMenu
		invoke EnableMenuItem,eax,nMenuID,edx
	.elseif eax==AIM_MENUREBUILD
		invoke AddMenu
	.elseif eax==AIM_CLOSE
		;Always return FALSE
		;Now is the time to kill timers, free memory, destroy windows, unhook, delete menuitems and delete toolbar buttons
		mov		eax,lpHStruct
		mov		eax,[eax].ADDINHANDLES.hMenu
		invoke DeleteMenu,eax,nMenuID,MF_BYCOMMAND
		mov		nMenuID,0
	.endif
	xor		eax,eax
	ret

DllProc endp

;Used for debuging
hexOut proc val:DWORD
	
	pushad
	push	val
	mov		eax,[lpPStruct]
	mov		eax,(ADDINPROCS ptr [eax]).lpHexOut
	call	eax
	popad
	ret

hexOut endp

End DllEntry
