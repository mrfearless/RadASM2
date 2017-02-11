
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

;#########################################################################
;		RAEdit messages

	REM_BASE			equ WM_USER+1000
	REM_GETWORD			equ REM_BASE+15		;wParam=BuffSize, lParam=lpBuff

;#########################################################################
;		Resource identifiers

	IDD_DLGDBLCLK		equ 1000
	IDC_BTNEXIT			equ 1001
	IDC_EDT1			equ 1002

	ADDINOPT struct
		lpStr			dd ?
		nAnd			dd ?
		nOr				dd ?
	ADDINOPT ends

.data

	szDblClk			db 'DblClk test',0
	szAddinOption		db 'Enable DblClk test',0
	AddinOpt			ADDINOPT <offset szAddinOption,1,1>
						ADDINOPT <0,0,0>


.data?

	hInstance			dd ?	;Dll's module handle
	lpHandles			dd ?	;Pointer to handles struct
	lpProc				dd ?	;Pointer to proc struct
	lpData				dd ?	;Pointer to data struct
	hDlg				dd ?	;Handle of our dialog
	IDAddIn				dd ?	;Unique ID for this AddIn

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
