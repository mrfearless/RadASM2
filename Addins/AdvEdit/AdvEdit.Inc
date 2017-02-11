
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

	include \RadASM\Masm\Inc\radasm.inc

;#########################################################################
;		VKim's Debug

	include \RadASM\masm\inc\debug.inc
	includelib \RadASM\masm\lib\debug.lib

	DBGWIN_DEBUG_ON = 1		; include debug info into the program
	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################
;		Prototypes

	DLLProc				PROTO :DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL			PROTO :DWORD, :DWORD
	
	TextOutput			PROTO :DWORD
	clrOutput			PROTO 
	HexOutput			PROTO :DWORD

.const

szAppName				db 'AdvEdit',0
EditMenu				db '&Advanced',0
MenuItems				db 'Get current &Path',0
						db 'Copy &All',0
						db '&Copy current line',0
						db '&Delete current line',0
						db '&Select current line',0
						db 'Delete to start of line',VK_TAB,'Ctrl+Shift+Backspace',0
						db 'Delete to end of line',VK_TAB,'Ctrl+Shift+Delete',0
						db 'Delete to start of word',VK_TAB,'Ctrl+Backspace',0
						db 'Delete to end of word',VK_TAB,'Ctrl+Delete',0
						db 0

.data?

	hInstance			dd ?			;Dll's module handle
	lpHandles			dd ?			;Pointer to handles struct
	lpProc				dd ?			;Pointer to proc struct
	lpData				dd ?			;Pointer to data struct
	hOut				dd ?			;Handle of output window
	hMnu				dd ?
	IDAddIn				dd 32 dup(?)	;Unique ID's for this AddIn

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
