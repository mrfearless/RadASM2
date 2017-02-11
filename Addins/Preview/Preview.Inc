
;#########################################################################
;	Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
	include gdi32.inc
	include comctl32.inc

;#########################################################################
;	Libraries

	includelib kernel32.lib
	includelib user32.lib
	includelib gdi32.lib
	includelib comctl32.lib

;#########################################################################
;	RadASM Add In Include

	include \RadASM\Masm\Inc\radasm.inc

;#########################################################################
;	VKim's Debug

	include masm32.inc
	include debug.inc
	includelib debug.lib

	DBGWIN_DEBUG_ON = 1					;include debug info into the program
	DBGWIN_EXT_INFO = 0					;include extra debug info into the program

TYPES struct
	ID				dd ?
	lpclass			dd ?
	notused			dd ?
	style			dd ?
	exstyle			dd ?
	lpidname		dd ?
	lpcaption		dd ?
	lprc			dd ?
	nmethod			dd ?
	methods			dd ?
	flist			dd 4 dup(?)
	wt				dd ?
	ht				dd ?
TYPES ends

DLGHEAD struct
	ver				dd ?				;Set to 101
	changed			dd ?				;Set to FALSE
	class			db 32 dup(?)		;Set to Null string
	menuid			db 32 dup(?)		;Set to Null string
	font			db 32 dup(?)		;Set to "MS Sans Serif"
	fontsize		dd ?				;Set to 8
	fontht			dd ?				;Set to -10
	undo			dd ?				;Set to NULL
	ctlid			dd ?				;Set to 1001
	hmnu			dd ?				;Set to NULL
	htlb			dd ?				;Set to NULL
	hstb			dd ?				;Set to NULL
	locked			dd ?				;Set to TRUE or FALSE
	hfont			dd ?				;Set to NULL
	carset			db ?				;Set to NULL
	italic			db ?
	weight			dw ?
DLGHEAD ends

MaxCap				equ 241

DIALOG struct
	hwnd			dd ?				;Set to TRUE
	hdmy			dd ?				;Transparent dummy window
	oldproc			dd ?				;Set to NULL
	hpar			dd ?				;Set to NULL
	hcld			dd ?				;Set to NULL
	style			dd ?				;Set to desired style
	exstyle			dd ?				;Set to desired ex style
	x				dd ?				;X position in pixels
	y				dd ?				;Y position in pixels
	ccx				dd ?				;Width in pixels
	ccy				dd ?				;Height in pixels
	caption			db MaxCap dup(?)	;Caption max 240+1 char
	ntype			dd ?				;Follows ToolBox buttons Dialog=0, Edit=1, Static=2, GroupBox=3
	ntypeid			dd ?				;Set to NULL
	tab				dd ?				;Tab index, Dialog=0, First index=0
	id				dd ?				;Dialog / Controls ID
	idname			db 32 dup(?)		;ID Name, max 31 chars
	undo			dd ?				;Set to NULL
	himg			dd ?				;Set to NULL
	class			db 32 dup(?)		;Class fur UDC
DIALOG ends

MyDLGTEMPLATE struct
	style			DWORD	?
	dwExtendedStyle	DWORD	?
	cdit			WORD	?
	x				WORD	?
	y				WORD	?
	lx				WORD	?
	ly				WORD	?
MyDLGTEMPLATE ends

MyDLGITEMTEMPLATE struct
	style			DWORD	?
	dwExtendedStyle	DWORD	?
	x				WORD	?
	y				WORD	?
	lx				WORD	?
	cy				WORD	?
	id				WORD	?
MyDLGITEMTEMPLATE ends

.const

	szAppName			db 'Preview',0
	szPreview			db 'Preview dialog',0

.data

						align 4
	dlgdata				dd 00000000h	;style
						dd 00000000h	;exstyle
						dw 0000h		;cdit
						dw 0006h		;x
						dw 0006h		;y
						dw 0060h		;cx
						dw 0040h		;cy
						dw 0000h		;menu
						dw 0000h		;class
						dw 0000h		;caption
	dlgps				dw 0			;point size
	dlgfn				dw 32 dup(0)	;face name
						dw 0
						dw 0

.data?

	hInstance			dd ?			;Dll's module handle
	lpHandles			dd ?			;Pointer to handles struct
	lpProc				dd ?			;Pointer to proc struct
	lpData				dd ?			;Pointer to data struct
	IDAddIn				dd ?			;Unique ID for this AddIn
	szBuff				dw 64 dup(?)
	lpDlgMem			dd ?
	dfntwt				dd ?
	dfntht				dd ?
	fntwt				dd ?
	fntht				dd ?
	hMnu				dd ?
	hDlg				dd ?
	hGoTo				dd ?
