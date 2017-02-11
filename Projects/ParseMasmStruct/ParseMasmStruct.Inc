
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

IDD_DIALOG1				equ 101
IDC_EDT1				equ 1001
IDC_CBO1				equ 1003
IDC_BTNSTRUCT			equ 1004
IDC_BTNUNION			equ 1005

IDD_DLGRESULT			equ 2000
IDC_EDTRESULT			equ 2001

PREDATATYPE struct
	lpName		DWORD ?
	lpConvert	DWORD ?
	nSize		DWORD ?
PREDATATYPE ends

STRUCTSIZE struct
	nSize		DWORD ?
	szName		BYTE ?
STRUCTSIZE ends

COMBOITEM struct
	szName		BYTE 64 dup(?)
	lpItem		DWORD ?
COMBOITEM ends

.const

; Font
Courier_New_9 			LOGFONT <-12,0,0,0,400,0,0,0,0,3,2,1,49,"Courier New">

; Some zstrings
szColon					db ':',0
szComma					db ',',0
szDot					db '.',0
szLPA					db '[',0
szRPA					db ']',0
szFmtDec				db '%u',0

; Files to load
szStructSizeFileName	db 'StructSize.txt',0
szTypeSizeFileName		db 'TypeSize.txt',0
szConstSizeFileName		db 'ConstSize.txt',0
szINCFilterString		db 'INC Files (*.inc)',0,'*.inc',0,0

szStruct				db 'struct',0
szUnion					db 'union',0
szEnds					db 'ends',0
szComment				db 'comment',0

szFirstWord				db 'IFNDEF',0,
						   'IFDEF',0,
						   'ELSE',0,
						   'ENDIF',0,
						   'echo',0,
						   'include',0,
						   'includelib',0,
						   'externdef',0,0

szSecondWord			db 'PROTO',0,
						   'equ',0,
						   'typedef',0,0

szError					db 'Error',0

; Predefined datatypes
szBYTE					db 'BYTE',0
szSBYTE					db 'SBYTE',0
szDB					db 'DB',0
szWORD					db 'WORD',0
szSWORD					db 'SWORD',0
szDW					db 'DW',0
szDWORD					db 'DWORD',0
szSDWORD				db 'SDWORD',0
szDD					db 'DD',0
szQWORD					db 'QWORD',0
szDQ					db 'DQ',0
szTBYTE					db 'TBYTE',0
szDT					db 'DT',0
						db 0

predatatype				PREDATATYPE 14 dup(<szBYTE,szBYTE,1>,
										   <szSBYTE,szSBYTE,1>,
										   <szDB,szBYTE,1>,
										   <szWORD,szWORD,2>,
										   <szSWORD,szSWORD,2>,
										   <szDW,szWORD,2>,
										   <szDWORD,szDWORD,4>,
										   <szSDWORD,szSDWORD,4>,
										   <szDD,szDWORD,4>,
										   <szQWORD,szQWORD,8>,
										   <szDQ,szQWORD,8>,
										   <szTBYTE,szTBYTE,10>,
										   <szDT,szTBYTE,10>,
										   <0,0>)

; Combobox items
ComboItems				COMBOITEM 5 dup(<'RECT (Simple)',szTestStruct1>,
										 <'ACCEL (WORD Alignment)',szTestStruct2>,
										 <'Sub structures',szTestStruct3>,
										 <'Sub unions',szTestStruct4>,
										 <'Alignment',szTestStruct5>,
										 <,0>)

; Predefined structures
szTestStruct1			db 'RECT struct',0Dh,0Ah
						db '	left		DWORD ?',0Dh,0Ah
						db '	top		DWORD ?',0Dh,0Ah
						db '	rignt		DWORD ?',0Dh,0Ah
						db '	bottom		DWORD ?',0Dh,0Ah
						db 'RECT ends',0Dh,0Ah,0

szTestStruct2			db 'ACCEL struct WORD',0Dh,0Ah
						db '	fVirt		BYTE ?',0Dh,0Ah
						db '	key		WORD ?',0Dh,0Ah
						db '	cmd		WORD ?',0Dh,0Ah
						db 'ACCEL ends',0Dh,0Ah,0

szTestStruct3			db 'TEST struct',0Dh,0Ah
						db '	rect		RECT <>',0Dh,0Ah
						db '	nmhdr		NMHDR <>',0Dh,0Ah
						db '	var1		DWORD ?',0Dh,0Ah
						db '	var2		DWORD ?',0Dh,0Ah
						db '	struct TST1',0Dh,0Ah
						db '		var1		DWORD ?',0Dh,0Ah
						db '		var2		DWORD ?',0Dh,0Ah
						db '	ends',0Dh,0Ah
						db '	struct TST2',0Dh,0Ah
						db '		var1		DWORD ?',0Dh,0Ah
						db '		var2		DWORD ?',0Dh,0Ah
						db '	ends',0Dh,0Ah
						db '	var3		DWORD ?',0Dh,0Ah
						db 'TEST ends',0Dh,0Ah,0

szTestStruct4			db 'TEST struct',0Dh,0Ah
						db '	var1		DWORD ?',0Dh,0Ah
						db '	var2		DWORD ?',0Dh,0Ah
						db '	union TST1',0Dh,0Ah
						db '		var1		DWORD ?',0Dh,0Ah
						db '		var2		WORD ?',0Dh,0Ah
						db '		var3		BYTE ?',0Dh,0Ah
						db '	ends',0Dh,0Ah
						db '	union TST2',0Dh,0Ah
						db '		var1		BYTE ?',0Dh,0Ah
						db '		var2		WORD ?',0Dh,0Ah
						db '		var3		DWORD ?',0Dh,0Ah
						db '	ends',0Dh,0Ah
						db '	var3		DWORD ?',0Dh,0Ah
						db 'TEST ends',0Dh,0Ah,0

szTestStruct5			db 'TST struct DWORD',0Dh,0Ah
						db '	a		DWORD ?',0Dh,0Ah
						db '	b		BYTE ?',0Dh,0Ah
						db '	struct TSTSUB',0Dh,0Ah
						db '		a		DWORD ?',0Dh,0Ah
						db '		b		BYTE ?',0Dh,0Ah
						db '	ends',0Dh,0Ah
						db 'TST ends',0Dh,0Ah,0

;#########################################################################
.data

szCrLf					db 0Dh,0Ah,0

.data?

hInstance				HINSTANCE ?
hWnd					HWND ?
hEdt					HWND ?
hMemStructSize			HGLOBAL ?
hMemTypeSize			HGLOBAL ?
hMemConstSize			HGLOBAL ?
hEditFont				HFONT ?
fShowResult				DWORD ?
nErr					DWORD ?
nSize					DWORD ?
szTemp					BYTE 256 dup(?)
szOutput				BYTE 32*1024 dup(?)
szInput					BYTE 32*1024 dup(?)

;#########################################################################
