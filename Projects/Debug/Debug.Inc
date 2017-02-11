
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include comctl32.inc
include comdlg32.inc
include dbghelp.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib dbghelp.lib

include masm32.inc
include \RadASM\masm\inc\debug.inc
includelib masm32.lib
includelib \RadASM\masm\lib\debug.lib

;Debug.dlg
IDD_DIALOG1						equ 101
IDC_REDDEBUG					equ 1001

;Child.dlg
IDD_DLGCHILD					equ 1000
IDC_EDTFILE						equ 1001
IDC_BTNBROWSE					equ 1003
IDC_BTNPREVIOUS					equ 1002
IDC_BTNNEXT						equ 1004
IDC_STCSTREAM					equ 1005
IDC_BTNSAVE						equ 1006
IDC_BTNDEBUG					equ 1007
IDC_BTNDEBUGNEXT				equ 1008

;#########################################################################

STREAM struct
	dBytes				DWORD ?
	hmem				HGLOBAL ?
STREAM ends

.const

RichEditDLL						db 'riched20.dll',0
DbgHelpDLL						db 'DbgHelp.dll',0

szEXCEPTION_DEBUG_EVENT			db 'EXCEPTION_DEBUG_EVENT',0
szEXCEPTION_BREAKPOINT			db 'EXCEPTION_BREAKPOINT',0
szEXCEPTION_ACCESS_VIOLATION	db 'EXCEPTION_ACCESS_VIOLATION',0
szCREATE_PROCESS_DEBUG_EVENT	db 'CREATE_PROCESS_DEBUG_EVENT',0
szCREATE_THREAD_DEBUG_EVENT		db 'CREATE_THREAD_DEBUG_EVENT',0
szEXIT_THREAD_DEBUG_EVENT		db 'EXIT_THREAD_DEBUG_EVENT',0
szEXIT_PROCESS_DEBUG_EVENT		db 'EXIT_PROCESS_DEBUG_EVENT',0
szLOAD_DLL_DEBUG_EVENT			db 'LOAD_DLL_DEBUG_EVENT',0
szUNLOAD_DLL_DEBUG_EVENT		db 'UNLOAD_DLL_DEBUG_EVENT',0
szOUTPUT_DEBUG_STRING_EVENT		db 'OUTPUT_DEBUG_STRING_EVENT',0
szRIP_EVENT						db 'RIP_EVENT',0
szCRLF							db 0Dh,0Ah,0
szNULL							db 0
szPDBFilterString				db 'PDB Files (*.pdb)',0,'*.pdb',0,0
Courier_New_10					LOGFONT <-13,0,0,0,400,0,0,0,0,3,2,1,49,"Courier New">
szPage							db 'Page : %lu',0Dh,0Ah,0
szStream						db 'Stream : %d',0Dh,0Ah,0
szCurrentStream					db 'Stream %d of %d',0
szSaving						db 0Dh,0Ah,'Saving stream to:',0Dh,0Ah,0
szSourceByte					db 'Adress: %X Byte: %X',0

.data

szFileName						db 'TestDebug.exe',0
;szSourceFileName				db 'C:\FbEdit\Projects\Applications\FbEdit\RadASM\Projects\Debug\TestDebug.Asm',0
szBP							db 0CCh

.data?

hInstance			HINSTANCE ?
hRichEdDLL			HMODULE ?
hDbgHelpDLL			HMODULE ?
hWnd				HWND ?
hEdt				HWND ?
hFont				HFONT ?
hCldDlg				HWND ?
hDbgThread			HANDLE ?
pinfo 				PROCESS_INFORMATION <>
dbghand				HANDLE ?
dbgdump				dd ?
nStreams			DWORD ?
nCurrentStream		DWORD ?
stream				STREAM 32 dup(<>)
threadcontext		HANDLE ?

;#########################################################################
