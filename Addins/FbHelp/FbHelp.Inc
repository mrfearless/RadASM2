
include windows.inc
include kernel32.inc
include user32.inc
include dbghelp.inc

includelib kernel32.lib
includelib user32.lib

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

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
	szName					BYTE 128 dup(?)
	nSize					DWORD ?
DATATYPE ends

SOURCEFILE struct DWORD
	ModBase					QWORD ?
	FileName				DWORD ?
SOURCEFILE ends

SRCCODEINFO struct DWORD
	SizeOfStruct            DWORD ?
	Key                     PVOID ?
	ModBase                 QWORD ?
	Obj         			BYTE MAX_PATH+1 dup(?)
	FileName				BYTE MAX_PATH+1 dup(?)
	LineNumber              DWORD ?
	Address                 DWORD ?
SRCCODEINFO ends

SYMBOL_INFO struct QWORD
	SizeOfStruct			DWORD ?
	TypeIndex				DWORD ?
	Reserved				QWORD 2 dup(?)
	Index					DWORD ?
	nSize					DWORD ?
	ModBase					QWORD ?
	Flags					DWORD ?
	Value					QWORD ?
	Address					QWORD ?
	Register				DWORD ?
	Scope					DWORD ?
	Tag						DWORD ?
	NameLen					DWORD ?
	MaxNameLen				DWORD ?
	szName					BYTE ?
SYMBOL_INFO ends

.const

szSecStab					db '.stab',0
szSecStabstr				db '.stabstr',0
szfmtdword					db ',%d',0

.data?

hInstance					HMODULE ?	;Dll's module handle
hProcessDbg					HANDLE ?
hMemFile					HGLOBAL ?
nHeaders					DWORD ?
rpstab						DWORD ?
rpstabs						DWORD ?
source						BYTE 8192 dup(?)
datatype					DATATYPE 256 dup(<>)
syminf						SYMBOL_INFO <>
szname						db 8192 dup(?)
