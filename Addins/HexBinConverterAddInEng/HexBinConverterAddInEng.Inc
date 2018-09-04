; _______________________________________________________________________________
; include files

	include windows.inc
	include kernel32.inc
	include user32.inc
	include Comctl32.inc	;ImageList_AddMasked proc
	include Gdi32.inc		;DeleteObject proc
	include shlwapi.inc		;StrToInt proc

; _______________________________________________________________________________
; library files

	includelib kernel32.lib
	includelib user32.lib
	includelib Comctl32.lib
	includelib Gdi32.lib

; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
; RadASM Addin include file

	include C:\masm32\RadASM\Masm\Inc\radasm.inc

; _______________________________________________________________________________
; VKim's Debug

	include C:\masm32\RadASM\masm\inc\debug.inc
	includelib C:\masm32\RadASM\masm\lib\debug.lib

	DBGWIN_DEBUG_ON = 1		; include debug info into the program
	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

; _______________________________________________________________________________
; Prototypes

	DLLProc			PROTO	:DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL		PROTO	:DWORD, :DWORD
	
	TextOutput		PROTO	:DWORD
	clrOutput		PROTO 
	HexOutput		PROTO	:DWORD
	
	EditAFKontrolu	PROTO	:HWND,:UINT,:WPARAM,:LPARAM	;edtHEX için subclassing fonk.
	EditIkiKontrolu	PROTO	:DWORD,:DWORD,:DWORD,:DWORD	;edtBIN için subclassing fonk.
	HexOlarakAl		PROTO	:DWORD,:DWORD				;edite girilen deðeri hex olarak alan fonk. proto.
	Iki2OnA			PROTO	:DWORD,:DWORD				;ikilk deðeri onaltýlýk deðere çevirir
	OnA2Iki			PROTO	:DWORD						;onaltýlýk deðeri ikilik deðere çevirir

; _______________________________________________________________________________
; constant variables
.const
	pencere			equ 101
	edtHEX			equ 1004
	edtDEC			equ 1005
	edtBIN			equ 1006
	edtBIN2			equ 1007
	btnKAPAT		equ 1008
	btnYARDIM		equ 1009
	lblBITS			equ 1012
	
	ikon			equ 5001
	ikonBMP			equ 5002
	
	;We define "options" which will be shown at Addin Manager
	;Last struct must be '0'
	AddinOpt			ADDINOPT <offset szOptStr1,1,1>
						ADDINOPT <0,0,0>
; _______________________________________________________________________________
; variables - predefined
.data
	szCnvrtAddin	db '[SCT]HEX.BIN Converter',0
	szCnvrtAddinTp	db '[SCT]HEX.BIN Converter',0
	szMailto		db 'mailto:',0
	szSubject		db '?subject=',0
	szAppName		db '[SCT]HEX.BIN Converter',0
	szOptStr1		db 'Enable HEX.BIN Converter',0
	mytbbutton		TBBUTTON <?,?,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,NULL,NULL>
	myaddbitmap		TBADDBITMAP <NULL,?>; <HINST_COMMCTRL,IDB_STD_SMALL_COLOR>
	formatX			db "%08X",0					;edtHEX'e "00000000" içerisinde hex deðerini yazdýrýr
	formats			db "%li",0					;long signed integer (–2,147,483,648 - 2,147,483,647)
	format0			db "%032u",0
	formatubits		db "%lu bit",0
	msgBaslik		db "About",0
	msgYardim		db "Hex.Bin Converter v1.0",13,10,13,10
					db "This small utility can convert 32-bit hexadecimal ",13,10
					db "and binary numbers. It is important to know how to ",13,10
					db "convert numbers between their bases. During ",13,10
					db "learning assembly, this is an important issue.",13,10
					db "This utility has its source codes included.Please check it out.",13,10,13,10
					db "For questions and bug report:",13,10
					db "E-MAIL:",9,"bluedevil@sctzine.com",13,10
					db "WEB:",9,"http://www.sctzine.com",13,10
					db "FORUM:",9,"http://masm32.com/board/index.php?board=24.0",13,10
					db "DATE:",9,"28.08.2018",13,10,13,10
					db "Thanks to:",13,10
					db "KetilO, mrfearless, errorinside, mrstop",13,10,13,10
					db "BlueDeviL",13,10
					db "[SCT]",0

; _______________________________________________________________________________
; variables - not defines
.data?

	hInstance		dd ?	;Dll's module handle
	lpHandles		dd ?	;Pointer to handles struct
	lpProc			dd ?	;Pointer to proc struct
	lpData			dd ?	;Pointer to data struct
	hOut			dd ?	;Handle of output window
	IDAddIn			dd ?	;Unique ID for this AddIn
	fOption			dd ?
	hDlg			dd ?
	hDlgWnd			DWORD ?
	szBuff			BYTE 128 dup(?)
	hEdt 			DWORD ? ;handle to topmost edit window
	EskiPenIslemi	dd ?

	CikanDeger		dd 8 dup(?)
	CikanDeger2		dd 8 dup(?)
	CikanDeger3		dd 8 dup(?)
	
	tampon1			dd 8 dup(?)
	tampon2			dd 20h dup(?)
	tampon3			dd 0Ah dup(?)
	tampon4			dd ?
	
	tampon1E		dd 8 dup(?)
	tampon2E		dd 0Ah dup(?)
	tampon3E		dd 0Bh dup(?)
	
	kntrlBAYRAK		DWORD ?
.code

; _______________________________________________________________________________
; output windows procedures

TextOutput proc lpszStr

   pushad
   
   push  lpszStr
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpTextOut
   
   popad	
   ret

TextOutput endp


clrOutput proc

   pushad
   
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpClearOut
   
   popad	
   ret

clrOutput endp

HexOutput proc val:DWORD
	
	pushad
	
	push  val
	mov   eax,lpProc
	call  [eax].ADDINPROCS.lpHexOut
	
	popad
	ret
	
HexOutput endp
