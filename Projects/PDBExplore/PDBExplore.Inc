include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include comctl32.inc
include comdlg32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib comdlg32.lib

include masm32.inc
include \RadASM\masm\inc\debug.inc
includelib masm32.lib
includelib \RadASM\masm\lib\debug.lib

;Debug.dlg
IDD_MAIN				equ 1000
IDC_REDDEBUG			equ 1001

;Child.dlg
IDD_DLGCHILD			equ 1100
IDC_EDTFILE				equ 1001
IDC_BTNBROWSE			equ 1003
IDC_BTNPREVIOUS			equ 1002
IDC_BTNNEXT				equ 1004
IDC_STCSTREAM			equ 1005
IDC_BTNSAVE				equ 1006

;#########################################################################

STREAM struct
	dBytes				DWORD ?
	hmem				HGLOBAL ?
STREAM ends

.const

szRichEditDLL			db 'riched20.dll',0
szClassName				db 'PDBEXPLORE',0
Courier_New_10			LOGFONT <-13,0,0,0,400,0,0,0,0,3,2,1,49,"Courier New">

szCRLF					db 0Dh,0Ah,0
szNULL					db 0
szPDBFilterString		db 'PDB Files (*.pdb)',0,'*.pdb',0
						db 'All Files (*.*)',0,'*.*',0,0
szSaving				db 0Dh,0Ah,'Saving stream to:',0Dh,0Ah,0
; Format strings
szPage					db 'Page : %lu',0Dh,0Ah,0
szStream				db 'Stream : %d',0Dh,0Ah,0
szCurrentStream			db 'Stream %d of %d',0
szWrite					db 'Stream.%.3lu'

.data?

hInstance				HINSTANCE ?
CommandLine				dd ?
hRichEdDLL				HMODULE ?
hWnd					HWND ?
hEdt					HWND ?
hCldDlg					HWND ?
hFont					HFONT ?
nStreams				DWORD ?
nCurrentStream			DWORD ?
stream					STREAM 32 dup(<>)

;#########################################################################
