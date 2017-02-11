;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include ToolWin.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

AddViewMenu proc ID:DWORD
	LOCAL	hMnu:DWORD
	LOCAL	mii:MENUITEMINFO

	mov		edx,2		;View menu
	;Adjust topmost popup if maximized.
	mov		eax,lpData
	mov		eax,[eax].ADDINDATA.fMaximized
	.if eax
		inc		edx
	.endif
	;Get handle of menu
	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hMenu
	;Get handle of View popup
	invoke GetSubMenu,eax,edx
	mov		hMnu,eax
	mov		mii.cbSize,sizeof mii
	mov		mii.fMask,MIIM_ID
	invoke GetMenuItemInfo,hMnu,ID,FALSE,addr mii
	.if !eax
		;The menuitem did not exist. Add our menuitem
		mov		mii.cbSize,sizeof mii
		mov		mii.fMask,MIIM_DATA or MIIM_ID or MIIM_TYPE
		mov		mii.fType,MFT_STRING
		mov		eax,ID
		mov		mii.wID,eax
		mov		mii.dwTypeData,offset szView
		invoke InsertMenuItem,hMnu,IDM_VIEW_STATUSBAR,FALSE,addr mii
		xor		eax,eax
	.endif
	ret

AddViewMenu endp

ToolProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	.if uMsg==WM_SIZE
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,100
		invoke MoveWindow,hEdit,0,0,eax,rect.bottom,TRUE
		mov		eax,rect.right
		sub		eax,95
		invoke MoveWindow,hBtn,eax,5,90,20,TRUE
	.elseif uMsg==WM_COMMAND
		.if wParam==1000
			;Call tool message
			push	0
			push	TLM_HIDE	;TLM_HIDE is a xor function
			push	hTool
			mov		eax,[lpProc]	
			call	[eax].ADDINPROCS.lpToolMessage
			xor		eax,eax
			jmp		Ex
		.endif
	.endif
	invoke CallWindowProc,OldToolProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

ToolProc endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx,hWin:DWORD,fOpt:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax

	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax

	invoke AddViewMenu,IDM_VIEW_TOOL1
	mov		edx,lpHandles
	mov		edx,[edx].ADDINHANDLES.hTl1
	.if eax
		;IDM_VIEW_TOOL1 was not free, try IDM_VIEW_TOOL2
		invoke AddViewMenu,IDM_VIEW_TOOL2
		mov		edx,lpHandles
		mov		edx,[edx].ADDINHANDLES.hTl2
	.endif
	.if !eax
		;Save handle of tool window
		mov		hTool,edx
		invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szEdit,0,
				WS_VSCROLL or WS_CHILD or WS_VISIBLE or ES_MULTILINE,
				0,0,0,0,hTool,0,hInstance,0
		mov		hEdit,eax
		invoke CreateWindowEx,0,addr szButton,addr szHide,
				WS_CHILD or WS_VISIBLE,
				0,0,0,0,hTool,1000,hInstance,0
		mov		hBtn,eax
		;Subclass
		invoke SetWindowLong,hTool,GWL_WNDPROC,offset ToolProc
		mov		OldToolProc,eax
		invoke SendMessage,hTool,WM_SIZE,0,0
		; Messages to hook into
		mov		eax,RAM_COMMAND
	.endif
	; ECX and EDX must be null before we return
	xor		ecx,ecx
	xor		edx,edx
	ret 

InstallDll Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov		eax,uMsg
	.IF eax==AIM_CLOSE
	.ENDIF
	mov		eax,FALSE
	ret

DllProc Endp

;#########################################################################

End DllEntry
