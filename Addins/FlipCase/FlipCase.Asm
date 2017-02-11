;### SEE - NOTE1: ###
.386
.model flat,stdcall
option casemap:none

include \radasm\masm\inc\RadASM.inc
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include Comctl32.inc
include shell32.inc
include comdlg32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib comdlg32.lib

OutProc1	PROTO	:DWORD,:DWORD,:DWORD,:DWORD
OutProc2	PROTO	:DWORD,:DWORD,:DWORD,:DWORD
OutProc3	PROTO	:DWORD,:DWORD,:DWORD,:DWORD
hexOut		PROTO	:DWORD
ShowOut		PROTO	:DWORD
ShowToolBox	PROTO	:DWORD
OutputText	PROTO	:DWORD

;DIALOG struct
;	hwnd		dd ?				;Set to TRUE
;	partype		dd ?				;Dialog=1, Controls=0
;	oldproc		dd ?				;Set to NULL
;	hpar		dd ?				;Set to NULL
;	hcld		dd ?				;Set to NULL
;	style		dd ?				;Set to desired style
;	exstyle		dd ?				;Set to desired ex style
;	x			dd ?				;X position in pixels
;	y			dd ?				;Y position in pixels
;	ccx			dd ?				;Width in pixels
;	ccy			dd ?				;Height in pixels
;	caption		db 241 dup(?)		;Caption max 240 char
;	ntype		dd ?				;Follows ToolBox buttons Dialog=0, Edit=1, Static=2, GroupBox=3
;	spare1		dd ?				;Set to NULL
;	tab			dd ?				;Tab index, Dialog=0, First index=0
;	id			dd ?				;Dialog / Controls ID
;	idname		db 32 dup(?)		;ID Name, max 31 chars
;	undo		dd ?				;Set to NULL
;	himg		dd ?				;Set to NULL
;DIALOG ends

ADDINOPT struct
	lpStr		dd ?
	nAnd		dd ?
	nOr			dd ?
ADDINOPT ends

.const

IDM_VIEW_OUTPUTWINDOW		equ 42003
IDM_MAKE_ASSEMBLE			equ 20002
IDM_MAKE_LINK				equ 20003
IDM_MAKE_BUILD				equ 20004
IDM_MAKE_GO					equ 20005
ID_EDIT						equ 65501
ID_DIALOG					equ 65502
ID_EDITTXT					equ 65503

.data

FTAsm						db '.asm',0
FTObj						db '.obj',0
szFlipCase					db 'Flip Case',0
nMenuID						dd -1		;Retrived menu ID
szPageBreak					db 'Page Break',0
nMenuPageBreakID			dd -1		;Retrived menu ID
Pattern						dd '----'	;Page break pattern
nPattern					dd 20		;20*4=80
szUntitled					db '(Untitled)',0
szRad						db 'Rad',0
szAutoShowOutput			db 'Auto Show Output',0
szAutoHideOutput			db 'Auto Hide Output',0
szAutoShowToolBox			db 'Auto Show ToolBox',0
szCreateTemp				db 'Create Temp',0
szException					db 'No Exception Handler',0
szCompileTime				db 'Compile time',0
szAppName					db 'FlipCase',0

AddinOpt					ADDINOPT <offset szFlipCase,1,1>
							ADDINOPT <offset szPageBreak,16,16>
							ADDINOPT <offset szAutoShowOutput,32,32>
							ADDINOPT <offset szAutoHideOutput,2,2>
							ADDINOPT <offset szAutoShowToolBox,4,4>
							ADDINOPT <offset szCreateTemp,8,8>
							ADDINOPT <offset szException,64,64>
							ADDINOPT <offset szCompileTime,128,128>
							ADDINOPT <0,0,0>
BeginTick					DD		0
;buffer						DB		32 DUP (?)
fmt							DB		"Total compile time %u ms",0

.data?

hInstance       			dd ?	;Dll's module handle
lpHStruct					dd ?	;Pointer to handles struct
lpPStruct					dd ?	;Pointer to proc struct
lpDStruct					dd ?	;Pointer to data struct
hWnd						dd ?	;Handle of mdi frame
hOut						dd ?	;Handle of output static container window
hOutREd						dd ?	;Handle of output rich edit window
OldOutProc1					dd ?	;Old richedit output windows WndProc
OldOutProc2					dd ?	;Old richedit output windows WndProc
OldOutProc3					dd ?	;Old richedit output windows WndProc
nTicks						dd ?	;Timer ticks down counter
fOption						dd ?	;fOption is a value read from ini and passed to the dll
fStayVisible				dd ?	;If TRUE output stays visible
hToolBox					dd ?	;Handle of ToolBox
nHideToolBox				dd ?	;Delay for the hiding of the ToolBox

include ExceptionHandler.asm

.code
;### SEE - NOTE2: ###

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

    push    hInst
    pop     hInstance
	invoke InitHyperLinkClass
    mov     eax,TRUE
    ret

DllEntry Endp

;fOpt is a value read from ini and passed to the dll
;Use for option settings
InstallDll proc hWin:DWORD,fOpt:DWORD
	LOCAL	mnui:MENUITEMINFO

	;Handle of RadASM's main window
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
	;Save for later use
	mov		fOption,eax
	;Check Flip Case option
	test	fOption,1
	.if !ZERO?
		;Allocate a new menu id
		invoke SendMessage,hWin,AIM_GETMENUID,0,0
		mov		nMenuID,eax
		mov		mnui.cbSize,sizeof mnui
		mov		mnui.fMask,MIIM_ID or MIIM_TYPE
		mov		mnui.fType,MFT_STRING
		mov		eax,nMenuID
		mov		mnui.wID,eax
		mov		mnui.dwTypeData,offset szFlipCase
		mov		mnui.cch,10
		;Insert our menuitem
		mov		edx,[lpHStruct]
		invoke InsertMenuItem,(ADDINHANDLES ptr [edx]).hMenu,43505,FALSE,addr mnui
	.endif
	;Check Page Break option
	test	fOption,16
	.if !ZERO?
		;Allocate a new menu id
		invoke SendMessage,hWin,AIM_GETMENUID,0,0
		mov		nMenuPageBreakID,eax
		mov		mnui.cbSize,sizeof mnui
		mov		mnui.fMask,MIIM_ID or MIIM_TYPE
		mov		mnui.fType,MFT_STRING
		mov		eax,nMenuPageBreakID
		mov		mnui.wID,eax
		mov		mnui.dwTypeData,offset szPageBreak
		mov		mnui.cch,11
		;Insert our menuitem
		mov		edx,[lpHStruct]
		invoke InsertMenuItem,(ADDINHANDLES ptr [edx]).hMenu,44019,FALSE,addr mnui
	.endif
	;Get handle of Output static container window
	mov		edx,[lpHStruct]
	mov		eax,(ADDINHANDLES ptr [edx]).hOut
	mov		hOut,eax
	;Get handle of ToolBox static container window
	mov		eax,(ADDINHANDLES ptr [edx]).hTlb
	mov		hToolBox,eax
	;Check if Auto Show/Hide output option selected
	test	fOption,2
	.if !ZERO?
		invoke ShowOut,TRUE
		invoke ShowOut,FALSE
		;Hook into Output1 WndProc
		mov		eax,[lpHStruct]
		invoke SetWindowLong,(ADDINHANDLES ptr [eax]).hOut1,GWL_WNDPROC,offset OutProc1
		mov		OldOutProc1,eax
		;Hook into Output2 WndProc
		mov		eax,[lpHStruct]
		invoke SetWindowLong,(ADDINHANDLES ptr [eax]).hOut2,GWL_WNDPROC,offset OutProc2
		mov		OldOutProc2,eax
		;Hook into Output3 WndProc
		mov		eax,[lpHStruct]
		invoke SetWindowLong,(ADDINHANDLES ptr [eax]).hOut3,GWL_WNDPROC,offset OutProc3
		mov		OldOutProc3,eax
	.endif
	;Return value tells RadASM wich messages you are hooking into
	;Hook into AIM_COMMAND and AIM_CLOSE
	mov		eax,RAM_COMMAND or RAM_CLOSE
	test	fOption,2
	.if !ZERO?
		;Hook into AIM_TIMER
		or		eax,RAM_TIMER
	.endif
	test	fOption,4
	.if !ZERO?
		push	eax
		invoke ShowToolBox,FALSE
		pop		eax
		;Hook into AIM_TIMER
		or		eax,RAM_TIMER
		;Hook into AIM_MDIACTIVATE
		or		eax,RAM_MDIACTIVATE
	.endif
	test	fOption,16
	.if !ZERO?
		;Hook into AIM_INITMENUPOPUP
		or		eax,RAM_INITMENUPOPUP
	.endif

	test	fOption,64
	.if ZERO?
		push	eax
		invoke SetUnhandledExceptionFilter,OFFSET FinalHandler
		invoke InitHyperLinkClass
		pop		eax
	.endif
	test	fOption,128
	.if !ZERO?
		or		eax,RAM_MAKEDONE or RAM_MAKEBEGIN
	.endif
	;Note!
	;Also set ecx and edx to NULL in case more than 32 hooks are
	;needed in the future.
	mov		ecx,RAM_UNHOOK or RAM_ADDINSLOADED
	xor		edx,edx
    ret

InstallDll endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

UnHook proc hWin:HWND,lpProc:DWORD,lpOldProc:DWORD

	;Let the next in the chain unhook me
	push	RAM_UNHOOK
	push	lpOldProc
	push	lpProc
	push	AIM_UNHOOK
	push	hWin
	mov		eax,lpPStruct
	call	[eax].ADDINPROCS.lpDllProc
	invoke GetWindowLong,hWin,GWL_WNDPROC
	.if eax==lpProc
		;Last in chain, just unhook
		invoke SetWindowLong,hWin,GWL_WNDPROC,lpOldProc
	.endif
	ret

UnHook endp

;This proc handles messages sent from RadASM to our dll
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hEdt:HWND
	LOCAL	chrg:CHARRANGE
	LOCAL	hMem:DWORD
	LOCAL	fEnable:DWORD
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	hTab:HWND
	LOCAL	tci:TC_ITEM
	LOCAL	mnui:MENUITEMINFO

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		;Return TRUE to prevent RadASM and other dll's from
		;processing command.
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==IDM_VIEW_OUTPUTWINDOW
			push	ebx
			;Call tool message
			push	0
			push	15				;TLM_GET_STRUCT
			push	hOut
			mov		eax,[lpPStruct]	
			call	(ADDINPROCS ptr [eax]).lpToolMessage
			mov		ebx,eax
			mov		edx,[ebx+16]	;.Position
			mov		ecx,[ebx+12]	;.Docked
			mov		eax,fOption
			and		eax,2
			.if eax && edx==4 && ecx
				;Option set, docked and pos is TL_BOTTOM
				mov		eax,[ebx+8]	;.Visible
				.if !eax
					mov		fStayVisible,FALSE
					invoke ShowOut,TRUE
					mov		fStayVisible,TRUE
				.else
					mov		fStayVisible,FALSE
					invoke ShowOut,FALSE
				.endif
				pop		ebx
				mov		eax,TRUE
				ret
			.endif
			pop		ebx
		.elseif eax==nMenuID
			;Note!
			;hEdit is NULL if no edit window is open
			;or if the topmost mdi child is not an edit window.
			;In this case it is not nececary to test for this
			;as the menuitem is grayed if this is not true.
			;Get handle of topmost edit window
			mov		eax,[lpHStruct]
			mov		eax,(ADDINHANDLES ptr [eax]).hEdit
			mov		hEdt,eax
			;Get selection
			invoke SendMessage,hEdt,EM_EXGETSEL,0,addr chrg
			;Get size
			mov		eax,chrg.cpMax
			sub		eax,chrg.cpMin
			;Allow room for terminating zero
			inc		eax
			;Allocate memory for the selected text
			invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,eax
			mov     hMem,eax
			invoke GlobalLock,hMem
			;Get the selected text
			invoke SendMessage,hEdt,EM_GETSELTEXT,0,hMem
			push	edi
			;Do the flip case
			mov		edi,hMem
		  @@:
			mov		al,[edi]
			.if al>='A' && al<='Z'
				or		byte ptr [edi],20h
			.elseif al>='a' && al<='z'
				and		byte ptr [edi],5Fh
			.endif
			inc		edi
			or		al,al
			jne		@b
			pop		edi
			;Replace selected text
			invoke SendMessage,hEdt,EM_REPLACESEL,TRUE,hMem
			;Restore selection
			invoke SendMessage,hEdt,EM_EXSETSEL,0,addr chrg
			;Free the memory
			invoke GlobalUnlock,hMem
			invoke GlobalFree,hMem
			;Returning TRUE when executing private commands speeds up things
			mov		eax,TRUE
			ret
		.elseif eax==nMenuPageBreakID
			;Note!
			;hEdit is NULL if no edit window is open
			;or if the topmost mdi child is not an edit window.
			;In this case it is not nececary to test for this
			;as the menuitem is grayed if this is not true.
			;Create page break
			push	edi
			lea		edi,buffer
			mov		al,';'
			stosb
			mov		eax,Pattern
			mov		ecx,nPattern
			rep stosd
			mov		eax,0Dh
			stosw
			pop		edi
			;Get handle of topmost edit window
			mov		eax,[lpHStruct]
			mov		eax,(ADDINHANDLES ptr [eax]).hEdit
			mov		hEdt,eax
			;Get selection
			invoke SendMessage,hEdt,EM_EXGETSEL,0,addr chrg
			invoke SendMessage,hEdt,EM_LINEFROMCHAR,chrg.cpMin,0
			invoke SendMessage,hEdt,EM_LINEINDEX,eax,0
			mov		chrg.cpMin,eax
			mov		chrg.cpMax,eax
			invoke SendMessage,hEdt,EM_EXSETSEL,0,addr chrg
			invoke SendMessage,hEdt,EM_REPLACESEL,TRUE,addr buffer
		.elseif eax==IDM_MAKE_ASSEMBLE || eax==IDM_MAKE_LINK || eax==IDM_MAKE_BUILD || eax==IDM_MAKE_GO
			;Check if option is selected
			test	fOption,8
			je		@f
			;Check if there is a topmost edit window
			mov		eax,lpHStruct
			mov		edx,[eax].ADDINHANDLES.hEdit
			.if edx
				;Check modify state
				invoke SendMessage,edx,EM_GETMODIFY,0,0
				.if eax
					;Check mdi child window caption
					mov		eax,lpHStruct
					mov		edx,[eax].ADDINHANDLES.hMdiCld
					invoke GetWindowText,edx,addr buffer,sizeof buffer
					invoke lstrcmp,addr buffer,offset szUntitled
					.if !eax
						;Get a temp filename, could just as well have been a fixed filename as the
						;ensure unike is lost when changing from .tmp to .asm
						invoke GetTempPath,sizeof buffer1,addr buffer1
						invoke GetTempFileName,addr buffer1,offset szRad,0,addr buffer
						invoke lstrlen,addr buffer
						;Change from .tmp to .asm
						lea		edx,[buffer+eax-3]
						mov		dword ptr [edx],'msa'
						mov		eax,lpDStruct
						mov		edx,[eax].ADDINDATA.lpFile
						invoke lstrcpy,edx,addr buffer
						;Set new mdi child window caption
						mov		eax,lpHStruct
						mov		edx,[eax].ADDINHANDLES.hMdiCld
						invoke SetWindowText,edx,addr buffer
						;Change the tab caption
						invoke lstrlen,addr buffer
						;Get the filename
						lea		eax,[buffer+eax]
						.while byte ptr [eax-1]!='\'
							dec		eax
						.endw
						mov		tci.pszText,eax
						mov		tci.imask,TCIF_TEXT
						;Set the caption
						mov		eax,lpHStruct
						mov		eax,[eax].ADDINHANDLES.hTab
						mov		hTab,eax
						invoke SendMessage,hTab,TCM_GETCURSEL,0,0
						mov		edx,eax
						invoke SendMessage,hTab,TCM_SETITEM,edx,addr tci
					.endif
				.endif
			.endif
		  @@:
		.endif
	.elseif eax==AIM_INITMENUPOPUP
		;Always return FALSE
		;Enable/Gray Page Break menuitem
		mov		edx,MF_GRAYED
		;Check if there is a topmost edit window
		mov		eax,[lpHStruct]
		mov		eax,(ADDINHANDLES ptr [eax]).hEdit
		.if eax
			mov		edx,MF_ENABLED
		.endif
		;Enable/disable the menuitem
		mov		eax,[lpHStruct]
		invoke EnableMenuItem,(ADDINHANDLES ptr [eax]).hMenu,nMenuPageBreakID,edx
	.elseif eax==AIM_CLOSE
		;Always return FALSE
		;Now is the time to kill timers, free memory, destroy windows, unhook, delete menuitems and delete toolbar buttons
		mov		eax,lpHStruct
		mov		eax,[eax].ADDINHANDLES.hMenu
		push	eax
		invoke DeleteMenu,eax,nMenuID,MF_BYCOMMAND
		mov		nMenuID,-1
		pop		eax
		invoke DeleteMenu,eax,nMenuPageBreakID,MF_BYCOMMAND
		mov		nMenuPageBreakID,-1
		.if OldOutProc1
			;UnHook Output1 WndProc
			mov		eax,lpHStruct
			invoke UnHook,[eax].ADDINHANDLES.hOut1,offset OutProc1,OldOutProc1
			mov		OldOutProc1,0
		.endif
		.if OldOutProc2
			;UnHook Output2 WndProc
			mov		eax,lpHStruct
			invoke UnHook,[eax].ADDINHANDLES.hOut2,offset OutProc2,OldOutProc2
			mov		OldOutProc2,0
		.endif
		.if OldOutProc3
			;UnHook Output3 WndProc
			mov		eax,lpHStruct
			invoke UnHook,[eax].ADDINHANDLES.hOut3,offset OutProc3,OldOutProc3
			mov		OldOutProc3,0
		.endif
	.elseif eax==AIM_UNHOOK
		mov		edx,lpHStruct
		mov		eax,hWin
		.if eax==[edx].ADDINHANDLES.hOut1
			mov		eax,wParam
			.if eax==OldOutProc1
				;Remove the hook from the chain
				mov		eax,lParam
				mov		OldOutProc1,eax
				mov		eax,TRUE
				jmp		Ex
			.endif
		.elseif eax==[edx].ADDINHANDLES.hOut2
			mov		eax,wParam
			.if eax==OldOutProc2
				;Remove the hook from the chain
				mov		eax,lParam
				mov		OldOutProc2,eax
				mov		eax,TRUE
				jmp		Ex
			.endif
		.elseif eax==[edx].ADDINHANDLES.hOut3
			mov		eax,wParam
			.if eax==OldOutProc3
				;Remove the hook from the chain
				mov		eax,lParam
				mov		OldOutProc3,eax
				mov		eax,TRUE
				jmp		Ex
			.endif
		.endif
	.elseif eax==AIM_MAKEBEGIN
		;Always return FALSE
		;hWin		handle of mdi client
		;lParam		pointer to make string
		invoke GetTickCount
		mov		BeginTick,eax
	.elseif eax==AIM_MAKEDONE
		;Always return FALSE
		;hWin		handle of mdi client
		;lParam		TRUE if errors occured
		invoke GetTickCount
		sub		eax,BeginTick
		invoke wsprintf,addr buffer,offset fmt,eax
		invoke OutputText,addr buffer
;	.elseif eax==AIM_COMMANDDONE
;		;Always return FALSE
;		;hWin		handle of mdi client
;	.elseif eax==AIM_PROJECTCLOSE
;		;Return TRUE to prevent project from closing
;		;Here is the place to save project related stuff
;	.elseif eax==AIM_PROJECTCLOSED
;		;Always return FALSE
;		;Here is the place to destroy project related stuff
;	.elseif eax==AIM_CLIENTMOUSEMOVE
;		;Always return FALSE
;		;hWin		handle of mdi client
	.elseif eax==AIM_TIMER
		;Always return FALSE
		;hWin		handle of mdi frame
		invoke GetCapture
		.if !eax
			;The timer ticks every 100 ms
			.if nTicks
				;Check if Output has focus
				invoke GetFocus
				invoke GetParent,eax
				;Get handle of Output richedit window
				mov		edx,[lpHStruct]
				mov		edx,(ADDINHANDLES ptr [edx]).hOutREd
				.if eax==edx
					mov		nTicks,20
					xor		eax,eax
					ret
				.endif
				dec		nTicks
				.if !nTicks
					;Timeout, hide Output
					push	0
					push	15						;TLM_GET_STRUCT
					push	hOut
					mov		eax,[lpPStruct]	
					call	(ADDINPROCS ptr [eax]).lpToolMessage
					mov		edx,[eax+8]				;.Visible
					.if edx
						mov		edx,[eax+12]		;.Docked
						.if edx
							mov		edx,[eax+16]	;.Position
							.if edx==4				;TL_BOTTOM
								;Check if cursor is within output big rect
								add		eax,48
								invoke CopyRect,addr rect,eax
								add		rect.bottom,20
								invoke GetCursorPos,addr pt
								invoke ClientToScreen,hWin,addr rect.left
								invoke ClientToScreen,hWin,addr rect.right
								mov		eax,pt.x
								.if eax>rect.left && eax<rect.right
									mov		eax,pt.y
									.if eax>rect.top && eax<rect.bottom
										;Cursor is within big rect, don't hide
										mov		nTicks,20
										xor		eax,eax
										ret
									.endif
								.endif
								invoke ShowOut,FALSE
								mov		nTicks,0
							.endif
						.endif
					.endif
				.endif
			.else
				mov		eax,fOption
				and		eax,32
				.if eax
					;Show output if cursor on statusbar
					invoke GetCursorPos,addr pt
					invoke WindowFromPoint,pt.x,pt.y
					mov		edx,lpHStruct
					mov		edx,(ADDINHANDLES ptr [edx]).hStatus
					.if eax==edx
						push	0
						push	15						;TLM_GET_STRUCT
						push	hOut
						mov		eax,[lpPStruct]	
						call	(ADDINPROCS ptr [eax]).lpToolMessage
						add		eax,48					;.BigRect
						invoke CopyRect,addr rect,eax
						invoke ClientToScreen,hWin,addr rect.left
						invoke ClientToScreen,hWin,addr rect.right
						add		rect.left,44
						mov		eax,pt.x
						.if eax>rect.left && eax<rect.right
							invoke ShowOut,TRUE
						.endif
					.endif
				.endif
			.endif
			.if nHideToolBox
				dec		nHideToolBox
				.if !nHideToolBox
					invoke ShowToolBox,FALSE
				.endif
			.endif
		.endif
;	.elseif eax==AIM_CTLDBLCLK
;		;Always return false
;		;hWin		handle of mdi child window
;		;wParam		handle of control
;		;lParam		pointer to control struct
;	.elseif eax==AIM_CREATENEWDLG
;		;Always return false
;		;hWin		handle of mdi child window
;		;wParam		handle of dialog
;		;lParam		pointer to FileName
;	.elseif eax==AIM_CONTEXTMENU
;		;Return TRUE to prevent RadASM from showing contextmenu
;	.elseif eax==AIM_PROJECTOPENED
;		;Always return false
;		;hWin		handle of mdi frame
;		;lParam		pointer to ProjectFile
;		;Added by NEMO
;		mov		eax,[lpDStruct]
;		mov		edx,(ADDINDATA ptr [eax]).lpProject
;		push	ebx
;		mov		ebx,(ADDINDATA ptr [eax]).lpFile
;		invoke lstrcpy,ebx,edx
;		invoke lstrlen,ebx
;		mov		dword ptr [ebx+eax-4],4D53412Eh
;		invoke GetFileAttributes,ebx
;		pop ebx
;		.if eax!=-1
;			;Open the file
;			push	TRUE
;			mov		eax,[lpPStruct]
;			mov		eax,(ADDINPROCS ptr [eax]).lpOpenProjectFile
;			call	eax
;		.endif
;	.elseif eax==AIM_MENUREBUILD
;		;Always return false
;		;hWin		handle of menu
;	.elseif eax==AIM_EDITOPEN
;		;Always return false
;		;hWin		handle of mdi child window
;		;wParam		handle of RAEdit
;	.elseif eax==AIM_EDITCLOSE
;		;Return TRUE to prevent mdi from closing
;		;hWin		handle of mdi child window
;		;wParam		handle of RicEdit
;	.elseif eax==AIM_EDITCLOSED
;		;Always return false
;		;hWin		handle of mdi child window
;		;wParam		handle of RicEdit
;	.elseif eax==AIM_EDITSAVE
;		;Return TRUE to prevent saveing
;		;hWin		handle of mdi child window
;		;wParam		handle of RicEdit
;		;lParam		pointer to FileName
;	.elseif eax==AIM_EDITSAVED
;		;Always return FALSE
;		;hWin		handle of mdi child window
;		;wParam		handle of RicEdit
;		;lParam		pointer to FileName
;	.elseif eax==AIM_TBRTOOLTIP
;		;Return FALSE or pointer to tooltip text
;		;hWin		handle of mdi frame
;		;wParam		ToolBar button ID
;		mov		eax,wParam
;		.if eax==MyTbrID
;			mov		eax,offset szMyToolTipText
;			ret
;		.endif
	.elseif eax==AIM_MDIACTIVATE
		;Always return FALSE
		;hWin		handle of mdi child
		;wParam		hwndChildDeact child being deactivated 
		;lParam		hwndChildAct child being activated
		;Added by NEMO
		;Get ID of RichEdit or dialog
		invoke GetWindowLong,hWin,0
		.if eax==ID_DIALOG
			mov		eax,hWin
			.if eax==lParam
				;MDI child is beeing activated
				mov		nHideToolBox,0
				;Show the toolbox
				invoke ShowToolBox,TRUE
			.elseif eax==wParam
				;MDI child is beeing deactivated
				;Delay the hiding a little
				mov		nHideToolBox,1
			.endif
		.endif
;	.elseif eax==AIM_EDITSELCHANGE
;		;Always return FALSE
;		;hWin		handle of mdi child window
;		;wParam		handle of RicEdit
;		;lParam		ID_EDIT or ID_EDITTXT
;	.elseif eax==AIM_PROJECTADDNEW
;		;Always return FALSE
;		;hWin		handle of mdi frame
;		;lParam		pointer to filename
;	.elseif eax==AIM_PROJECTREMOVE
;		;Always return FALSE
;		;hWin		handle of mdi frame
;		;lParam		pointer to filename
;	.elseif eax==AIM_DLGMNUSELECT
;		;Always return FALSE
;		;hWin		handle of mdi child
;		;wParam		handle of dialog
;		;lParam		poiner to menu structures
;	.elseif eax==AIM_RCUPDATE
;		;Always return FALSE
;		;hWin		dialog window handle
;		;wParam		1=Resource,2=VersionInfo
;		;lParam		pointer to rc text
;	.elseif eax==AIM_CREATENEWCTL
;		;Always return FALSE
;		;hWin		handle of mdi child
;		;wParam		handle of dialog
;		;lParam		poiner to control structure
;	.elseif eax==AIM_TOOLSHOW
;		;Always return FALSE
;		;hWin		handle of tool window
;		;wParam		Show (TRUE/FALSE)
;		;lParam		Toolwindow ID
;	.elseif eax==AIM_SETSTYLE
;		;Return TRUE to prevent RadASM from showing xStyle / xExStyle dialog
;		;hWin		Handle of property listbox
;		;wParam		Pointer to DIALOG struct
;		;lParam		TRUE if ExStyle
;		mov		eax,wParam
;		;Just flip the style to indicate something has happened
;		.if lParam
;			xor		[eax].DIALOG.exstyle,200h
;		.else
;			xor		[eax].DIALOG.style,1h
;		.endif
;		;Update the control
;		push	[eax].DIALOG.hwnd
;		mov		eax,lpPStruct
;		call	[eax].ADDINPROCS.lpUpdateCtl
;		mov		eax,TRUE
;		ret
	.elseif eax==AIM_ADDINSLOADED
		push	sizeof buffer/2
		lea		eax,buffer
		push	eax
		push	2000
		push	offset szAppName
		mov		eax,lpPStruct
		call	[eax].ADDINPROCS.lpGetLangString
		.if eax
			mov		mnui.cbSize,sizeof mnui
			mov		mnui.fMask,MIIM_TYPE
			mov		mnui.fType,MFT_STRING
			lea		eax,buffer
			mov		mnui.dwTypeData,eax
			;Insert our menuitem
			mov		edx,[lpHStruct]
			invoke SetMenuItemInfoW,(ADDINHANDLES ptr [edx]).hMenu,nMenuID,FALSE,addr mnui
		.endif
		push	sizeof buffer/2
		lea		eax,buffer
		push	eax
		push	2001
		push	offset szAppName
		mov		eax,lpPStruct
		call	[eax].ADDINPROCS.lpGetLangString
		.if eax
			mov		mnui.cbSize,sizeof mnui
			mov		mnui.fMask,MIIM_TYPE
			mov		mnui.fType,MFT_STRING
			lea		eax,buffer
			mov		mnui.dwTypeData,eax
			;Insert our menuitem
			mov		edx,[lpHStruct]
			invoke SetMenuItemInfoW,(ADDINHANDLES ptr [edx]).hMenu,nMenuPageBreakID,FALSE,addr mnui
		.endif
	.endif
	xor		eax,eax
  Ex:
	ret

DllProc endp

;Hook into Output WndProc
OutProc1 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		nTicks,20
	mov		eax,uMsg
	.if eax==EM_REPLACESEL || eax==WM_PASTE || eax==EM_STREAMIN || eax==EM_STREAMOUT
		invoke ShowOut,TRUE
	.endif
	invoke CallWindowProc,OldOutProc1,hWin,uMsg,wParam,lParam
	ret

OutProc1 endp

;Hook into Output WndProc
OutProc2 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		nTicks,20
	mov		eax,uMsg
	.if eax==EM_REPLACESEL || eax==WM_PASTE || eax==EM_STREAMIN || eax==EM_STREAMOUT
		invoke ShowOut,TRUE
	.endif
	invoke CallWindowProc,OldOutProc2,hWin,uMsg,wParam,lParam
	ret

OutProc2 endp

;Hook into Output WndProc
OutProc3 proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		nTicks,20
	mov		eax,uMsg
	.if eax==EM_REPLACESEL || eax==WM_PASTE || eax==EM_STREAMIN || eax==EM_STREAMOUT
		invoke ShowOut,TRUE
	.endif
	invoke CallWindowProc,OldOutProc3,hWin,uMsg,wParam,lParam
	ret

OutProc3 endp

;Show or hide Output window
ShowOut proc fShow:DWORD

	;Call tool message
	push	0
	push	15						;TLM_GET_STRUCT
	push	hOut
	mov		eax,[lpPStruct]	
	call	(ADDINPROCS ptr [eax]).lpToolMessage
	mov		edx,[eax+8]				;.Visible
	.if edx!=fShow && !fStayVisible
		mov		edx,[eax+12]		;.Docked
		.if edx
			mov		edx,[eax+16]	;.Position
			.if edx==4				;TL_BOTTOM
				;Save focus
				invoke GetFocus
				push	eax
				;Call tool message
				push	0
				push	5			;TLM_HIDE is a xor function
				push	hOut
				mov		eax,[lpPStruct]	
				call	(ADDINPROCS ptr [eax]).lpToolMessage
				;Restore focus
				pop		eax
				invoke SetFocus,eax
			.endif
		.endif
	.endif
	ret

ShowOut endp

;Show or hide ToolBox
ShowToolBox proc fShow:DWORD

	;Call tool message
	push	0
	push	15						;TLM_GET_STRUCT
	push	hToolBox
	mov		eax,[lpPStruct]	
	call	(ADDINPROCS ptr [eax]).lpToolMessage
	mov		edx,[eax+8]				;.Visible
	.if edx!=fShow
		mov		edx,[eax+12]		;.Docked
		.if edx
			;Save focus
			invoke GetFocus
			push	eax
			;Call tool message
			push	0
			push	5			;TLM_HIDE is a xor function
			push	hToolBox
			mov		eax,[lpPStruct]	
			call	(ADDINPROCS ptr [eax]).lpToolMessage
			.if fShow
				invoke InvalidateRect,hWnd,NULL,FALSE
			.endif
			;Restore focus
			pop		eax
			invoke SetFocus,eax
		.endif
	.endif
	ret

ShowToolBox endp

;Used for debuging
hexOut proc val:DWORD
	
	pushad
	push	val
	mov		eax,[lpPStruct]
	call	(ADDINPROCS ptr [eax]).lpHexOut
	popad
	ret

hexOut endp

OutputText proc lpString:DWORD

	pushad
	push  lpString
	mov   eax,lpPStruct
	call  [eax].ADDINPROCS.lpTextOut
	popad
	ret

OutputText endp

End DllEntry
