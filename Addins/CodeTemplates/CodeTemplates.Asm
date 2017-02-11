;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    CodeTemplates Addin by drizz        ;;
;;    CodeComplete used as a reference    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.686
.model flat,stdcall
option casemap:none
assume fs:nothing
;-
WIN32_LEAN_AND_MEAN EQU <>;; *my* projects compile faster :P :P :P
include windows.inc
;-
include kernel32.inc
includelib kernel32.lib
include gdi32.inc
includelib gdi32.lib
include user32.inc
includelib user32.lib
;-
include stdlib.inc
includelib stdlib.lib
;-
include Rad\RadAsm.inc ; *slightly edited*
ID_EDIT equ 65501; from where is this?? 
include Rad\RAEdit.inc
;-

BLOCKRANGE struct
	lnMin		dd ?			;Starting line
	clMin		dd ?			;Starting column
	lnMax		dd ?			;Ending line
	clMax		dd ?			;Ending column
BLOCKRANGE ends

RABRUSH struct
	hBrBck		dd ?			;Back color brush
	hBrSelBck	dd ?			;Sel back color brush
	hBrHilite1	dd ?			;Line hilite 1
	hBrHilite2	dd ?			;Line hilite 2
	hBrHilite3	dd ?			;Line hilite 3
	hBrSelBar	dd ?			;Selection bar
	hPenSelbar	dd ?			;Selection bar pen
RABRUSH ends

RAFONT struct
	hFont		dd ?			;Code edit normal
	hIFont		dd ?			;Code edit italics
	hLnrFont	dd ?			;Line numbers
RAFONT ends

RACOLOR struct
	bckcol		dd ?			;Back color
	txtcol		dd ?			;Text color
	selbckcol	dd ?			;Sel back color
	seltxtcol	dd ?			;Sel text color
	cmntcol		dd ?			;Comment color
	strcol		dd ?			;String color
	oprcol		dd ?			;Operator color
	hicol1		dd ?			;Line hilite 1
	hicol2		dd ?			;Line hilite 2
	hicol3		dd ?			;Line hilite 3
	selbarbck	dd ?			;Selection bar
	selbarpen	dd ?			;Selection bar pen
	lnrcol		dd ?			;Line numbers color
	numcol		dd ?			;Numbers & hex color
RACOLOR ends

RAFONTINFO struct
	charset		dd ?			;Character set
	fDBCS		dd ?			;Use double byte characters
	fntwt		dd ?			;Font width
	fntht		dd ?			;Font height
	spcwt		dd ?			;Space width
	tabwt		dd ?			;Tab width
	italic		dd ?			;Height shift
	monospace	dd ?			;Font is monospaced
	linespace	dd ?			;Extra line spacing
RAFONTINFO ends

RAEDT struct
	hwnd		dd ?			;Handle of edit a or b
	hvscroll	dd ?			;Handle of scroll bar
	cpxmax		dd ?			;Last cursor pos x
	cpy			dd ?			;Scroll position
	cp			dd ?			;Character position
	rc			RECT <?>		;Edit a or b rect
	topyp		dd ?			;First visible lines Y position
	topln		dd ?			;First visible lines linenumber
	topcp		dd ?			;First visible lines character position
RAEDT ends

EDIT struct
	hwnd		dd ?			;Handle of main window
	fstyle		dd ?			;Window style
	ID			dd ?			;Window ID
	hpar		dd ?			;Handle of parent window
	edta		RAEDT <>
	edtb		RAEDT <>
	hhscroll	dd ?			;Handle of horizontal scrollbar
	hgrip		dd ?			;Handle of sizegrip
	hnogrip		dd ?			;Handle of nosizegrip
	hsbtn		dd ?			;Handle of splitt button
	hlin		dd ?			;Handle of linenumber button
	hexp		dd ?			;Handle of expand button
	hcol		dd ?			;Handle of collapse button
	hsta		dd ?			;Handle of state window
	htt			dd ?			;Handle of tooltip
	fresize		dd ?			;Resize in action flag
	fsplitt		dd ?			;Splitt factor
	nsplitt		dd ?			;Splitt height

	hHeap		dd 3 dup(?)		;Handle of heap
	hLine		dd ?			;Handle of line pointer mem
	cbLine		dd ?			;Size of line pointer mem
	rpLine		dd ?			;Relative pointer into line pointer mem
	rpLineFree	dd ?			;Pointer to free line pointer
	hChars		dd ?			;Handle of character mem
	cbChars		dd ?			;Size of character mem
	rpChars		dd ?			;Relative pointer into character mem
	rpCharsFree	dd ?			;Relative pointer to free character
	hUndo		dd ?			;Handle of undo memory
	cbUndo		dd ?			;Size of undo memory
	rpUndo		dd ?			;Relative pointer to free (last)
	line		dd ?			;Linenumber
	cpLine		dd ?			;Character position for start of line

	rc			RECT <?>		;Main rect
	selbarwt	dd ?			;Width of selection bar
	nlinenrwt	dd ?			;Initial width of linenumber bar
	linenrwt	dd ?			;Width of linenumber bar
	nScroll		dd ?			;Mouse wheel scroll lines
	nPageBreak	dd ?			;Page break
	cpMin		dd ?			;Selection min
	cpMax		dd ?			;Selection max
	fOvr		dd ?			;Insert / Overwrite
	nHidden		dd ?			;Number of hidden lines
	cpx			dd ?			;Scroll position
	focus		dd ?			;Handle of edit having focus
	fCaretHide	dd ?			;Caret is hidden
	fChanged	dd ?			;Content changed
	fHideSel	dd ?			;Hide selection
	fIndent		dd ?			;Auto indent
	clr			RACOLOR <?>
	br			RABRUSH <?>
	nTab		dd ?			;Tab size
	fnt			RAFONT <?>
	fntinfo		RAFONTINFO <?>
	lpBmCB		dd ?			;Bookmark paint callback
	nchange		dd ?			;Used by EN_SELCHANGE
	nlastchange	dd ?			;Used by EN_SELCHANGE
	nWordGroup	dd ?			;Hilite word group
	fExpandTab	dd ?			;TRUE/FALSE Epand tabs to spaces
	savesel		CHARRANGE <?>
	htlt		dd ?			;Scroll tooltip
	nMode		dd ?			;Block selection
	blrg		BLOCKRANGE <?>
	lockundoid	dd ?
	ccmntblocks	dd ?
EDIT ends

.data?
dd? hInstance,pAddinHandles,pAddinProcs,pAddinData,hEdt1,OldEditProc1,hEdt2,OldEditProc2,nAsm

include CodeTemplates.inc

.code

TextOutput proc lpszStr
   pushad
   mov eax,pAddinProcs
   invoke [eax].ADDINPROCS.lpTextOut,lpszStr
   popad
   ret
TextOutput endp

RAEditProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov eax,uMsg
	.if eax==WM_KEYDOWN
		mov edx,wParam
		.if edx == VK_J
			invoke GetKeyState,VK_CONTROL
			and eax,80h
			.if !zero?
				invoke CtLbPopup
				return 0
			.endif
		.endif
	.endif
	invoke CallWindowProc,OldEditProc1,hWnd,uMsg,wParam,lParam
	ret
RAEditProc endp

; The addin initalization proc
; Return hooks in eax:=<0>,edx:=<0>,ecx:=<0>
; fOpt is a value read from ini and passed to the dll
; Use for option settings
InstallDll proc EXPORT hWin:DWORD,fOpt:DWORD
	mov pAddinHandles,AddInMsg(hWin,AIM_GETHANDLES); Get handles
	mov pAddinProcs,AddInMsg(hWin,AIM_GETPROCS); Get procs
	mov pAddinData,AddInMsg(hWin,AIM_GETDATA); Get data
	;mov nEditsOpened,0
	; messages to hook into
	mov eax,AddInHook(AIM_PROJECTOPENED,AIM_PROJECTCLOSED,AIM_MDIACTIVATE,AIM_CLOSE)
	mov ecx,RAM_UNHOOK
	mov edx,RAM_NULL
	ret
InstallDll Endp

UnHook proc hWin:HWND,lpThisProc:DWORD,lpOldProc:DWORD

	invoke GetWindowLong,hWin,GWL_WNDPROC
	.if eax==lpThisProc
		;Last in chain, just unhook
		invoke SetWindowLong,hWin,GWL_WNDPROC,lpOldProc
	.else
		;Let the next in the chain unhook me
		push	RAM_UNHOOK
		push	lpOldProc
		push	lpThisProc
		push	AIM_UNHOOK
		push	hWin
		mov		eax,pAddinProcs
		call	[eax].ADDINPROCS.lpDllProc
	.endif
	ret

UnHook endp

; This proc handles messages sent from RadASM to our dll
; Return TRUE to prevent RadASM and other dll's from
; processing command.
DllProc proc EXPORT hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other dll's from
	; processing command.
	mov eax,uMsg
	.if eax==AIM_MDIACTIVATE
		;A new mdi window is selected
		.if hWnd
			invoke GetWindowLong,hWnd,0                     ;Get editor type
			.if eax==ID_EDIT
				mov		eax,wParam
				.if eax==hWnd
					.if OldEditProc1
						;Unsubclass the RAEdit windows
						invoke UnHook,hEdt1,offset RAEditProc,OldEditProc1
						invoke UnHook,hEdt2,offset RAEditProc,OldEditProc2
						xor eax, eax
						mov OldEditProc1,eax				;Set as unhooked
						mov OldEditProc2,eax				;Set as unhooked
					.endif
				.else
					;Subclass the RAEdit child windows
					invoke GetWindowLong,lParam,GWL_USERDATA
					invoke GetWindowLong,eax,0
					mov		edx,[eax].EDIT.edta.hwnd
					mov		hEdt1,edx
					mov		edx,[eax].EDIT.edtb.hwnd
					mov		hEdt2,edx
					invoke SetWindowLong,hEdt1,GWL_WNDPROC,offset RAEditProc
					mov OldEditProc1,eax
					invoke SetWindowLong,hEdt2,GWL_WNDPROC,offset RAEditProc
					mov OldEditProc2,eax
				.endif
			.endif
		.endif
	.elseif eax==AIM_UNHOOK
		mov		eax,hWnd
		mov		ecx,wParam
		mov		edx,lParam
		.if eax==hEdt1 && ecx==OldEditProc1
			;Remove the hook from the chain
			mov		OldEditProc1,edx
			mov		eax,TRUE
			ret
		.elseif eax==hEdt2 && ecx==OldEditProc2
			;Remove the hook from the chain
			mov		OldEditProc2,edx
			mov		eax,TRUE
			ret
		.endif
	.elseif eax==AIM_CLOSE
		;Undo subclassing
		.if OldEditProc1
			invoke UnHook,hEdt1,offset RAEditProc,OldEditProc1
			mov		OldEditProc1,0
		.endif
		.if OldEditProc2
			invoke UnHook,hEdt2,offset RAEditProc,OldEditProc2
			mov		OldEditProc2,0
		.endif
	.elseif eax==AIM_PROJECTOPENED
		;invoke TextOutput,T('AIM_PROJECTOPENED')
		invoke CtLbCreate
	.elseif eax==AIM_PROJECTCLOSED
		;invoke TextOutput,T('AIM_PROJECTCLOSED')
		invoke CtLbDestroy
	.endif
	return FALSE

DllProc Endp

DllEntry proc hinstDLL:DWORD,fdwReason:DWORD,pvReserved:DWORD
	.if fdwReason == DLL_PROCESS_ATTACH
		m2mr hInstance,hinstDLL
	.endif
	mov eax,TRUE
	ret
DllEntry Endp

End DllEntry
