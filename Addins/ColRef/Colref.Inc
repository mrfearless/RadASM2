.486

.model flat,stdcall
option casemap:none

include windows.inc
;include shell32.inc
include user32.inc
include kernel32.inc
include \radasm\masm\inc\radasm.inc
include comdlg32.inc
include masm32.inc
include \masm32\macros\macros.asm
include gdi32.inc
include comctl32.inc

;includelib shell32.lib
includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib
includelib masm32.lib
includelib gdi32.lib
includelib comctl32.lib

;############################################################################
;		VKim's Debug

	include \masm32\include\debug.inc
	includelib \masm32\lib\debug.lib

;	DBGWIN_DEBUG_ON = 1 ; include debug info into the program
;	DBGWIN_EXT_INFO = 1 ; include extra debug info into the program

; PROTOTYPES ======================================
AddMenu					PROTO
ColorDlg				PROTO	:DWORD,:DWORD,:DWORD
Colors					PROTO	:dword
DlgProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM
DllEntry				PROTO	:HINSTANCE,:DWORD,:DWORD
DllProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM
GetOptions				PROTO
InstallDll				PROTO	:DWORD,:DWORD
InstallHook				PROTO
MouseProc				PROTO	:DWORD,:DWORD,:DWORD
PicBtnProc				PROTO	:DWORD,:DWORD,:DWORD,:DWORD
UninstallHook			PROTO
Edit4Proc				PROTO	:DWORD,:DWORD,:DWORD,:DWORD
SaveCustColors			PROTO
LoadCustColors			PROTO
CCHookProc				PROTO	:DWORD,:DWORD,:DWORD,:DWORD
ParseInput				PROTO	:DWORD
SelectToDialog			PROTO	:dword

ADDINOPT struct
	lpStr				dd ?
	nAnd				dd ?
	nOr					dd ?
ADDINOPT ends

; Read-only data ==================================
.const
IDR_BITMAP				equ 2001
IDR_ICON				equ 2002
IDR_PICCUR				equ 2003

ID_DLG					equ 1000
IDC_EDT1				equ 1021
IDC_EDT2				equ 1022
IDC_EDT3				equ 1023
IDC_BTN1				equ 1001
IDC_BTN2				equ 1002
IDC_BTN3				equ 1003
IDC_BTN5				equ 105
IDC_STC4				equ 1007
IDC_STC5				equ 1008
IDC_STC6				equ 1009
IDC_SHP1				equ 720
IDC_SHP2				equ 710
IDC_SHP3				equ 702
IDC_SHP4				equ 721
IDC_SHP5				equ 709
IDC_BTN4				equ 104

WM_MOUSEHOOK			equ WM_USER+9

; Initialized data ================================
.data
szColref				db 'Colref', 0
szAppTitle				db 'Color reference',0
szColrefToolTip			db 'Color reference',0
szDefColor				db '00FFFFFF',0
szTemplate				db 'COLORREFDLG',0

mytbbutton				TBBUTTON <?,?,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,NULL,NULL>
myaddbitmap				TBADDBITMAP <NULL,?>; <HINST_COMMCTRL,IDB_STD_SMALL_COLOR>;

szEnableColRef			db "Enable color reference",0
szDisableColorFlashing 	db "Disable color flashing",0
szDisableBlueDialof		db "Disable blue dialog",0
AddinOpt				ADDINOPT <offset szEnableColRef,1,1>
						ADDINOPT <offset szDisableColorFlashing,2,2>
						ADDINOPT <offset szDisableBlueDialof,4,4>
						ADDINOPT <0,0,0>
						
; Non-initialized data ============================
.data?
hInstance				dd ?	;Dll's module handle
lpDStruct				dd ?	;Pointer to data struct
IDColref				dd ?	;Returned menu ID
lpHStruct				dd ? 	;Pointer to RA's handles structure
lpPStruct				dd ? 	;Pointer to RA's proc structure
szString				dd ?
colref					dd 16 dup (?)
hHook					dd ?
OldWndProc				dd ?
hPic					dd ?
CustColor				dd 16 dup (?)
hBrush					dd	?
hCCDlg					dd	?
pCHOOSECOLOR			dd	?
InitColor				dd	?
fOption					dd ?
dlgpos					POINT <?>
Dialogcolor				dd ?
Dcolor					dd ?