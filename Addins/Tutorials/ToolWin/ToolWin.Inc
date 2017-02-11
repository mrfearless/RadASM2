
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
;	include Comctl32.inc
;	include shell32.inc
;	include ComDlg32.inc
;	include Gdi32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
;	includelib Comctl32.lib
;	includelib shell32.lib
;	includelib ComDlg32.lib
;	includelib Gdi32.lib

;#########################################################################
;		RadASM Add In Include

	include ..\..\RadAsm.inc

;#########################################################################
;		VKim's Debug

	include masm32.inc
	include \RadASM\Masm\Inc\Debug.Inc
	includelib masm32.lib
	includelib \RadASM\Masm\Lib\Debug.lib

	DBGWIN_DEBUG_ON = 1		; include debug info into the program
	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################
;		Prototypes

	DLLProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL				PROTO :DWORD, :DWORD
	
	TextOutput				PROTO :DWORD
	clrOutput				PROTO 
	HexOutput				PROTO :DWORD

;#########################################################################
;		Menu id's for addin toolwindows (View popup)
	IDM_VIEW_TOOL1			equ 42009
	IDM_VIEW_TOOL2			equ 42010
	IDM_VIEW_STATUSBAR		equ 42007

;#########################################################################
;		Tool messages.
	TLM_INIT			equ	1
	TLM_CREATE			equ	2

	TLM_DOCKING			equ	4
	TLM_HIDE			equ	5
	TLM_MOUSEMOVE		equ	6
	TLM_LBUTTONDOWN		equ	7
	TLM_LBUTTONUP		equ	8
	TLM_PAINT			equ	9
	TLM_SIZE			equ	10
	TLM_REDRAW			equ	11
	TLM_CAPTION			equ	12
	TLM_ADJUSTRECT		equ	13
	TLM_GET_VISIBLE		equ	14
	TLM_GET_STRUCT		equ	15
	TLM_MINIMIZE		equ	16

;#########################################################################
;		Docking positions.
	TL_LEFT				equ	1
	TL_TOP				equ	2
	TL_RIGHT			equ	3
	TL_BOTTOM			equ	4

;#########################################################################
;		Tool structure.
	TOOL struct
		ID					dd ?
		Caption				dd ?
		Visible				dd ?
		Docked				dd ?
		Position			dd ?
		IsChild				dd ?
		dWidth				dd ?
		dHeight				dd ?
		fr					RECT <> ;Floating
		dr					RECT <> ;Docked
		wr					RECT <> ;Child window
		rr					RECT <> ;Resize
		tr					RECT <> ;Top
		cr					RECT <> ;Caption
		br					RECT <> ;Close button
		dFocus				dd ?
		dCurFlag			dd ?
		hWin				dd ?
		hCld				dd ?
		lpfnOldCldWndProc	dd ?
	TOOL ends

.data

	szView			db 'Addin tool',0
	szEdit			db 'Edit',0
	szButton		db 'Button',0
	szHide			db 'Hide',0

.data?

	hInstance			dd ?	;Dll's module handle
	lpHandles			dd ?	;Pointer to handles struct
	lpProc				dd ?	;Pointer to proc struct
	lpData				dd ?	;Pointer to data struct
	hTool				dd ?	;Handle of tool window
	OldToolProc			dd ?
	hEdit				dd ?
	hBtn				dd ?

.code

;#########################################################################
;		Output Window procs

TextOutput proc lpszStr

   pushad
   
   push  lpszStr
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpTextOut
   
   popad	
   ret

TextOutput endp

;#########################################################################

clrOutput proc

   pushad
   
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpClearOut
   
   popad	
   ret

clrOutput endp

;#########################################################################

HexOutput proc val:DWORD
	
	pushad
	
	push  val
	mov   eax,lpProc
	call  [eax].ADDINPROCS.lpHexOut
	
	popad
	ret
	
HexOutput endp
