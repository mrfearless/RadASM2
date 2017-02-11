.386
.model flat,stdcall
option casemap:none

include \radasm\masm\inc\radasm.inc
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include comctl32.inc
include masm32.inc

includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib masm32.lib

DllProc			PROTO :DWORD,:DWORD,:DWORD,:DWORD
DlgProc			PROTO :DWORD,:DWORD,:DWORD,:DWORD
hexOut			PROTO :DWORD
textOut			PROTO :DWORD
revBuf			PROTO :DWORD,:DWORD,:DWORD

ADDINOPT struct
	lpStr			dd ?
	nAnd			dd ?
	nOr				dd ?
ADDINOPT ends

.const

IDD_DLG			equ 1000
IDBMP_TBBMP 	equ 2000
IDI_ICON		equ 2001
MAXBYTES		equ 254

.data

szAsciiToolTip	BYTE "Ascii Table",0
szAsciiMenu		BYTE "Ascii Table",0
szOption		BYTE "Enable Ascii Table",0
szAppName		BYTE "asciiTab",0
szfrmt			BYTE "%1.1X%1.1X",0
szEMFilename	BYTE "\asciitab.emf",0
szerr			BYTE "Get EMF returned NULL",0
szModfail		BYTE "GetModuleHandle returned NULL",0
szBuffull		BYTE "The Buffer can only hold 250 bytes",0
szBuf			BYTE "H"				;this line combines with the next one to make one buffer
				BYTE MAXBYTES dup(NULL)
				BYTE ?
mytbbutton		TBBUTTON <?,?,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,NULL,NULL>
myaddbitmap		TBADDBITMAP <NULL,?>; <HINST_COMMCTRL,IDB_STD_SMALL_COLOR>;
AddinOpt		ADDINOPT <offset szOption,1,1>
				ADDINOPT <0,0,0>

.data?

szDummy 		BYTE 25 dup (?) ;dummy for anything else
szrevBuf 		BYTE MAXBYTES+2 dup(?) ;buffer to hold reversed output
szBuff			BYTE 128 dup(?)
szEMFpathname	BYTE 100 dup (?) ;Enhanced metafile filename
X_div			DWORD ?	;calculated factors
Y_div			DWORD ?	;
nBytes 			DWORD ? ;keep track of bytes output
hEMF 			DWORD ?	;handle to our EMF
hEdt 			DWORD ? ;handle to topmost edit window
hDlgwnd			DWORD ?
AsciiMenuID		DWORD ?	;our menu ID obtained from RA

hInstance		DWORD ? ;our dll's module Handle
lpHStruct		DWORD ? ;Pointer to RA's handles structure
lpPStruct		DWORD ? ;Pointer to RA's proc structure
lpDStruct		DWORD ? ;Pointer to RA's data structure
