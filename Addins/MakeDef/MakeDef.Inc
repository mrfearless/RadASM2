;############################################################################

	include windows.inc

	include kernel32.inc
	include user32.inc
	include masm32.inc

	includelib kernel32.lib
	includelib user32.lib
	includelib masm32.lib

	include \RadASM\MASM\Inc\radasm.inc

;############################################################################

	DLLProc					PROTO 	:DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL				PROTO 	:DWORD, :DWORD
	BuildDefFile			PROTO
	CheckForDef				PROTO
	CheckForProc			PROTO	:DWORD
	GetProcName				PROTO	:DWORD
	RemoveExportName		PROTO	:DWORD
	BuildGoAsmDefFile		PROTO
	BuildMASMDefFile		PROTO
	RemoveAllExports		PROTO
	VerifyProc				PROTO	:DWORD
	WriteExportName			PROTO	:DWORD
	RebuildExportList		PROTO
	CleanExportSection		PROTO
	WriteExportList			PROTO
	CopyString				PROTO	:DWORD,:DWORD
	ParseCboString			PROTO	:DWORD
	BuildGoAsmDefOut		PROTO
	BuildMASMDefOut			PROTO

	ADDINOPT struct
		lpStr			dd ?
		nAnd			dd ?
		nOr				dd ?
	ADDINOPT ends

	PROPERTIES struct
		nSize			dd ?
		Owner			dd ?
		nType			db ?
	PROPERTIES ends

	RefreshID		EQU		5
	pDefFile		EQU		offset buff+0*1024
	pExString		EQU		offset buff+1*1024
	pLineString		EQU		offset buff+2*1024
	pProcName		EQU		offset buff+3*1024
	pTempBuffer		EQU		offset buff+4*1024
	pFullProc		EQU		offset buff+5*1024

;############################################################################
;		VKim's Debug

;	include \masm32\include\debug.inc
;	includelib \masm32\lib\debug.lib
;
;	DBGWIN_DEBUG_ON = 1 ; include debug info into the program
;	DBGWIN_EXT_INFO = 1 ; include extra debug info into the program

.data
	szAddProc		DB		"Add export",0
	szRemProc		DB		"Remove export",0
	szRemAll		DB		"Remove all exports",0
	szVerify		DB		"Are you sure ?",0
	; ##########################################################
	; The following two variables are interdependant do not change the order
	szExports		DB		"Exports",0,2Ch
	szExpCbo		DB		"exports,0",0
	; ##########################################################
	szFiles			DB		"Files",0
	szMakeFiles		DB		"MakeFiles",0
	szDefFind		DB		";",0
	szdw2a			DB		"%lu",0
	szSix			DB		"6",0
	szSeven			DB		"7",0
	szAsmMASM		DB		"masm",0
	szAsmGOASM		DB		"goasm",0

	MExportHdr		DB		"EXPORTS",0Dh,0Ah,0
	GExportHdr		DB		"/Export %s",0
	MDllHdr			DB		"LIBRARY %s",0Dh,0Ah,0

	MOutExportHdr	DB		"EXPORTS",0
	MOutDllHdr		DB		"LIBRARY %s",0

	nCbItem			DD		0

;############################################################################

	szOutput		db 'Write to Output window',0
	szFile			db 'Write to def file',0
	AddinOpt		ADDINOPT <offset szOutput,3,1>
					ADDINOPT <offset szFile,3,2>
					ADDINOPT <0,0,0>

.data?

	hInstance		DD		?
	lpHandles		DD		?
	lpProcs			DD		?
	lpData			DD		?

	AddInID1		DD		?
	AddInID2		DD		?
	AddInID3		DD		?
	hSubMenu		DD		?
	hPrpLst			DD		?
	Options			DD		?
	hPrpCbo			DD		?
	hPrpTbr			DD		?

	pRapFile		DD		?
	MemDis			DD		?
	fDllProj		DD		?
	iniKey			DB		16 DUP (?)

	buff			DB 6*1024 DUP (?)
