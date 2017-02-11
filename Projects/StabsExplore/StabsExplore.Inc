
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include shell32.inc
include gdi32.inc
include comdlg32.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib shell32.lib
includelib gdi32.lib
includelib comdlg32.lib

;#########################################################################
; VKim's Debug

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

;#########################################################################

IDD_DIALOG1						equ 101
IDC_EDT1						equ 1001

IDD_DLGCHILD					equ 1100
IDC_EDTFILE						equ 1001
IDC_BTNBROWSE					equ 1003
IDC_BTNPREVIOUS					equ 1002
IDC_BTNNEXT						equ 1004
IDC_STCSECTION					equ 1005
IDC_BTNDUMPSECTION				equ 1006
IDC_BTNDUMPSTABS				equ 1007
IDC_BTNDUMPPROCS				equ 1008
IDC_BTNDUMPGLOBALS				equ 1009
IDC_BTNTYPES					equ 1010
IDC_BTNLIMES					equ 1011

SECTIONHEADER struct
	sName					BYTE 8 dup(?)
	VirtualSize				DWORD ?
	VirtualAddress			DWORD ?
	SizeOfRawData			DWORD ?
	PointerToRawData		DWORD ?
	PointerToRelocations	DWORD ?
	PointerToLinenumbers	DWORD ?
	NumberOfRelocations		WORD ?
	NumberOfLinenumbers		WORD ?
	Characteristics			DWORD ?
SECTIONHEADER ends

STAB struct
	stabs					DWORD ?
	code					WORD ?
	nline					WORD ?
	ad						DWORD ?
STAB ends

DATATYPE struct
	szname					BYTE 64 dup(?)
	nsize					DWORD ?
DATATYPE ends

.const

szRichEditDLL			db 'riched20.dll',0
szOBJFilterString		db 'EXE Files (*.exe)',0,'*.exe',0,0

; Font
Courier_New_9 			LOGFONT <-12,0,0,0,400,0,0,0,0,3,2,1,49,"Courier New">
szNULL					db 0
szCrLf					db 0Dh,0Ah,0
szAlign					db '                ',0

szStabsHeader			db 'Section Header:',0Dh,0Ah
						db '------------------------------',0Dh,0Ah
						db 'NumberOfSections         %04Xh',0Dh,0Ah,0
szStab					db '%s        %08Xh',0Dh,0Ah,0

szSectionHeader			db 'Section Header:',0Dh,0Ah
						db '------------------------------',0Dh,0Ah
						db 'Name                 %s',0Dh,0Ah
						db 'VirtualSize          %08Xh',0Dh,0Ah
						db 'VirtualAddress       %08Xh',0Dh,0Ah
						db 'SizeOfRawData        %08Xh',0Dh,0Ah
						db 'PointerToRawData     %08Xh',0Dh,0Ah
						db 'PointerToRelocations %08Xh',0Dh,0Ah
						db 'PointerToLinenumbers %08Xh',0Dh,0Ah
						db 'NumberOfRelocations  %04Xh',0Dh,0Ah
						db 'NumberOfLinenumbers  %04Xh',0Dh,0Ah
						db 'Characteristics      %08Xh',0Dh,0Ah,0Dh,0Ah,0

szSecStab				db '.stab',0
szSecStabstr			db '.stabstr',0
szFmtStab				db 'Stabs: %4u Code: %3u Line: %5u Address: %08Xh Str: %s',0Dh,0Ah,0
szFmtFile				db 'File: %s',0Dh,0Ah,0
szFmtProc				db 'Proc: %-50s Line: %5u Address: %08Xh Size: %5u',0Dh,0Ah,0
szFmtParam				db 'Parameters: %s',0Dh,0Ah,0
szFmtLocal				db 'Locals: %s',0Dh,0Ah,0
szFmtGlobal				db 'Global: %-50s Address: %08Xh Size: %5u',0Dh,0Ah,0
szFmtArray				db '[%u..%u]',0
szFmtLine				db 'File: %-50s Line: %5u Address: %08Xh',0Dh,0Ah,0
szFmtType				db 'Type: %-50s Size: %5u',0Dh,0Ah,0

;#########################################################################

.data?

hInstance				DWORD ?
hRichEdDLL				HMODULE ?
hWnd					HWND ?
hCldDlg					HWND ?
hEdt					HWND ?
hStc					HWND ?
hEditFont				HFONT ?
szOutput				BYTE 2048 dup(?)
szSection				BYTE 16 dup(?)
hMemFile				HGLOBAL ?
nHeaders				DWORD ?
nHeader					DWORD ?
SectionHeader			SECTIONHEADER 96 dup(<>)
rpstab					DWORD ?
rpstabs					DWORD ?
datatype				DATATYPE 256 dup(<>)

;#########################################################################
