
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
IDC_BTNDUMPSYMBOLS				equ 1007
IDC_BTNDUMPPROCS				equ 1008
IDC_BTNDUMPGLOBALS				equ 1009
IDC_BTNDUMPLINE					equ 1010

IMAGE_SYM_UNDEFINED				equ 0
IMAGE_SYM_ABSOLUTE				equ -1
IMAGE_SYM_DEBUG					equ -2
EXTERNAL						equ 2
STATIC							equ 3
FUNCTION						equ 101

COFFHEADER struct
	Machine					WORD ?
	NumberOfSections		WORD ?
	TimeDateStamp			DWORD ?
	PointerToSymbolTable	DWORD ?
	NumberOfSymbols			DWORD ?
	SizeOfOptionalHeader	WORD ?
	Characteristics			WORD ?
COFFHEADER ends

COFFSECTIONHEADER struct
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
COFFSECTIONHEADER ends

COFFLINENUMBERS struct
	union
		SymbolTableIndex	DWORD ?
		VirtualAddress		DWORD ?
	ends
	Linenumber				WORD ?
COFFLINENUMBERS ends

COFFSYMBOL struct
	union
		szShortName			BYTE 8 dup(?)
		Zeroes				DWORD ?
		nOffset				DWORD 2 dup(?)
	ends
	Value					DWORD ?
	SectionNumber			WORD ?
	nType					WORD ?
	StorageClass			BYTE ?
	NumberOfAuxSymbols		BYTE ?
COFFSYMBOL ends

;Function Definitions
;StorageClass=2, nType=20h, SectionNumber>0
COFFAUX1 struct
	TagIndex				DWORD ?
	TotalSize				DWORD ?
	PointerToLinenumber		DWORD ?
	PointerToNextFunction	DWORD ?
	Unused					WORD ?
COFFAUX1 ends

;.bf and .ef Symbols
;StorageClass=101 (.bf and .ef)
COFFAUX2 struct
	Unused					BYTE 4 dup(?)
	Linenumber				WORD ?
	Unused2					BYTE 6 dup(?)
	PointerToNextFunction	DWORD ?
	Unused3					BYTE 2 dup(?)
COFFAUX2 ends

;Weak Externals
;StorageClass=2, SectionNumber=0, Value=0
COFFAUX3 struct
	TagIndex				DWORD ?
	Characteristics			DWORD ?
	Unused					BYTE 10 dup(?)
COFFAUX3 ends

;Files
;StorageClass=103, szShortName=.file
COFFAUX4 struct
	FileName				BYTE 18 dup(?)
COFFAUX4 ends

;Section Definitions
;StorageClass=3, szShortName=.text or .drectve etc.
COFFAUX5 struct
	nLength					DWORD ?
	NumberOfRelocations		WORD ?
	NumberOfLinenumbers		WORD ?
	CheckSum				DWORD ?
	Number					WORD ?
	Selection				BYTE ?
	Unused					BYTE 3 dup(?)
COFFAUX5 ends

DBGPROC struct
	szFile					BYTE MAX_PATH dup(?)
	szName					BYTE 256 dup(?)
	bfad					DWORD ?
	bfln					DWORD ?
	lfln					DWORD ?
	lfad					DWORD ?
	efln					DWORD ?
	efad					DWORD ?
DBGPROC ends

.const

szRichEditDLL			db 'riched20.dll',0
szOBJFilterString		db 'OBJ Files (*.obj)',0,'*.obj',0,0
;szOBJFilterString		db 'OBJ Files (*.obj)',0,'*.obj',0,'EXE Files (*.exe)',0,'*.exe',0,0

; Font
Courier_New_9 			LOGFONT <-12,0,0,0,400,0,0,0,0,3,2,1,49,"Courier New">
szNULL					db 0
szCrLf					db 0Dh,0Ah,0

szCoffHeader			db 'COFF Header:',0Dh,0Ah
						db '------------------------------',0Dh,0Ah
						db 'Machine              %04Xh',0Dh,0Ah
						db 'NumberOfSections     %04Xh',0Dh,0Ah
						db 'TimeDateStamp        %08Xh',0Dh,0Ah
						db 'PointerToSymbolTable %08Xh',0Dh,0Ah
						db 'NumberOfSymbols      %08Xh',0Dh,0Ah
						db 'SizeOfOptionalHeader %04Xh',0Dh,0Ah
						db 'Characteristics      %04Xh',0Dh,0Ah,0

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

szCoffSymbol			db 'Name:%s Value:%08Xh SectionNumber:%04Xh Type:%04Xh StorageClass:%02Xh NumberOfAuxSymbols:%02Xh',0Dh,0Ah,0
szCoffProc				db 'File:%s Name:%s bfad:%08Xh  bfln:%u efad:%08Xh  efln:%u',0Dh,0Ah,0
szCoffGlobal			db 'Name:%s Address:%08Xh',0Dh,0Ah,0
szCoffLinenumber		db 'Address:%08Xh Line:%u',0Dh,0Ah,0

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
nCoffHeaders			DWORD ?
nCoffHeader				DWORD ?
SectionHeader			COFFSECTIONHEADER 96 dup(<>)

;#########################################################################
