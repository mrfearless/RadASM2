
include windows.inc
include user32.inc
include kernel32.inc
include shell32.inc
include comctl32.inc
include gdi32.inc

includelib user32.lib
includelib kernel32.lib
includelib shell32.lib
includelib comctl32.lib
includelib gdi32.lib

WinMain				PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc				PROTO :DWORD,:DWORD,:DWORD,:DWORD

.const

IDI_MAINICO			equ 100
IDC_VSPLITCUR		equ 150
IDB_TRVBITMAP		equ 200

;TreeViewDir.dlg
IDC_TRV				equ 1001
IDC_RED				equ 1002

IMG_DISKETTE		equ 0
IMG_DRIVE			equ 1
IMG_CD				equ 2
IMG_FOLDER			equ 3
IMG_FILE			equ 4

;TreeViewDir.mnu
IDM_FILE_EXIT		equ 10001
IDM_HELP_ABOUT		equ 10002

.data

RichEditDLL			db 'riched20.dll',0
ClassName			db 'DLGCLASS',0
MenuName			db 'TreeViewDir',0
DlgName				db 'TreeViewDir',0
AppName				db 'TreeViewDir',0
AboutMsg			db 'MASM32 RadASM TreeViewDir',13,10,'Copyright © MASM32 2001',0
OpenFileFail        db 'Cannot open the file',0
szNULL				db 0
szStatic			db 'Static',0
szBS				db '\',0
szAPA				db '*.*',0
szCRLF				db 0Dh,0Ah,0

.data?

hRichEdDLL			dd ?
hInstance			dd ?
CommandLine			dd ?
hIcon				dd ?
hACur				dd ?
hSCur				dd ?
hWnd				HWND ?
hREd				HWND ?
hTrv				HWND ?
hStc				HWND ?
hIml				HWND ?
szRoot				db MAX_PATH dup(?)
FileName			db MAX_PATH dup(?)
fResize				dd ?
wfd					WIN32_FIND_DATA <?>
