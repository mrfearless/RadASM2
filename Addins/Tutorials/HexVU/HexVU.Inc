
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
;	include Comctl32.inc
;	include shell32.inc
	include ComDlg32.inc
	include Gdi32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
;	includelib Comctl32.lib
;	includelib shell32.lib
	includelib ComDlg32.lib
	includelib Gdi32.lib

;#########################################################################
;		RadASM Add In Include

	include ..\..\RadAsm.inc

;#########################################################################
;		VKim's Debug

	include \RadASM\masm\inc\debug.inc
	includelib \RadASM\masm\lib\debug.lib

	DBGWIN_DEBUG_ON = 1		; include debug info into the program
	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################
;		Prototypes

	DLLProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL				PROTO :DWORD, :DWORD
	TextOutput				PROTO :DWORD
	clrOutput				PROTO 
	HexOutput				PROTO :DWORD

	fntwt					equ 7
	fntht					equ 15
	barwt					equ 14
	addrxp					equ 17
	dataxp					equ 79
	asciixp					equ 416
	line1xp					equ 75
	line2xp					equ 411
	coladdr					equ 800000h
	coldata					equ 0
	colascii				equ 8000h

.data

	szMenuItem			db 'Open As &Hex',0
	szMdiChild			db 'HexVUMdiChild',0
	szHexChild			db 'HexVUChild',0
	szOpenAsHex			db 'Open As Hex',0
	szALLFilterString	db 'All Files (*.*)',0,'*.*',0,0
	lfnt				LOGFONT <-12,0,0,0,400,0,0,0,0,0,0,0,0,'Courier New'>

.data?

	hInstance			dd ?	;Dll's module handle
	hRAInstance			dd ?	;RadASM instance handle
	lpHandles			dd ?	;Pointer to handles struct
	lpProc				dd ?	;Pointer to proc struct
	lpData				dd ?	;Pointer to data struct
	hOut				dd ?	;Handle of output window
	IDAddIn				dd ?	;Unique ID for this AddIn
	hFont				dd ?	;Font for hex control
	hPen				dd ?
	hBrBar				dd ?
	hBrBack				dd ?
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
