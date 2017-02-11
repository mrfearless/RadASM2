
;#########################################################################
; Include files
include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc
include comctl32.inc
include version.inc
include dbghelp.inc
include RAEdit.inc

;#########################################################################
; Libraries
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib
includelib comctl32.lib
includelib version.lib

;#########################################################################
; RadASM AddIn Include
include ..\RadAsm.inc

;#########################################################################
; VKim's Debug
include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

;#########################################################################
; Prototypes

DLLProc							PROTO :DWORD, :DWORD, :DWORD, :DWORD
InstallDLL						PROTO :DWORD, :DWORD
CalculateIt						PROTO :DWORD

;#########################################################################
; Constants

;DoNotDebug.dlg
IDD_DLGDONOTDEBUG				equ 1000
IDC_LSTDONOTDEBUG				equ 1001
IDC_LSTDEBUG					equ 1002
IDC_BTNDONOTDEBUG				equ 1003
IDC_BTNDEBUG					equ 1004
IDC_BTNDONOTDEBUGALL			equ 1005
IDC_BTNDEBUGALL					equ 1006

; RadASM menu items
IDM_EDIT_TOGGLEBP				equ 41013
IDM_EDIT_CLEARBP				equ 41014
IDM_VIEW_OUTPUTWINDOW			equ 42003
IDM_VIEW_TOOL1					equ 42009
IDM_VIEW_TOOL2					equ 42010
IDM_VIEW_STATUSBAR				equ 42007

; Debug tabs
IDC_DBGTAB						equ 1000
IDC_DBGREG						equ 1001
IDC_DBGFPU						equ 1002
IDC_DBGMMX						equ 1003
IDC_DBGWATCH					equ 1004

TLM_HIDE						equ	5
;TLM_CAPTION						equ	12
TLM_GET_VISIBLE					equ	14
TLM_GET_STRUCT					equ	15

; Debug functions
FUNC_RUN						equ 1
FUNC_STEPINTO					equ 2
FUNC_STEPOVER					equ 3
FUNC_RUNTOCARET					equ 4
FUNC_STOP						equ 5
FUNC_BREAK						equ 6

; Format items
FMT_NAME						equ 1
FMT_TYPE						equ 2
FMT_ADDRESS						equ 4
FMT_SIZE						equ 8
FMT_HEX							equ 16
FMT_DEC							equ 32
FMT_SZ							equ 64

ERR_NOTFOUND					equ 1
ERR_INDEX						equ 2
ERR_SYNTAX						equ 3

;#########################################################################
; Structures

TOOL struct
	ID						dd ?
	Caption					dd ?
	Visible					dd ?
	Docked					dd ?
	Position				dd ?
	IsChild					dd ?
	dWidth					dd ?
	dHeight					dd ?	;+28
	fr						RECT <> ;Floating
	dr						RECT <> ;Docked
	wr						RECT <> ;Child window
	rr						RECT <> ;Resize
	tr						RECT <> ;Top
	cr						RECT <> ;Caption
	br						RECT <> ;Close button
	dFocus					dd ?
	dCurFlag				dd ?
	hWin					dd ?
	hCld					dd ?
	lpfnOldCldWndProc		dd ?
TOOL ends

; Breakpoints
BREAKPOINT struct
	ProjectFileID			DWORD ?					; Project file id
	LineNumber				DWORD ?					; Line number, zero based
BREAKPOINT ends

; RadASM properties
PROPERTIES struct
	nSize					DWORD ?					; Size of property, excluding size of PROPERTIES struct
	Owner					DWORD ?					; Project file ID or handle of window if file is open.
	nType					BYTE ?					; Type d,p,S,s,T
PROPERTIES ends

; Source files
DEBUGSOURCE struct
	FileID					WORD ?					; The id of the file
	ProjectFileID			DWORD ?					; Project file id
	FileName				BYTE MAX_PATH dup(?)	; Filename
DEBUGSOURCE ends

; Line numbers
DEBUGLINE struct
	LineNumber              DWORD ?					; Line number, 1 based
	Address                 DWORD ?					; Address
	FileID					WORD ?					; ID of file containing line (DEBUGSOURCE)
	NoDebug					BYTE ?					; Line shold not be debugged
	BreakPoint				BYTE ?					; There is a breakpoint on this line
DEBUGLINE ends

; Datatypes
DEBUGTYPE struct
	szName					db 64 dup(?)			; Name of type
	nSize					DWORD ?					; Size in bytes
DEBUGTYPE ends

; Symbols
DEBUGSYMBOL struct
	szName					db 64 dup(?)			; Name of proc / global var
	Address                 DWORD ?					; Adress
	nSize					DWORD ?					; Size in bytes
	nArray					DWORD ?					; Number of elements
	lpType					DWORD ?					; PROC: pointer to szParam + szLocals, GLOBAL: pointer to szArray + szDatatype
	nType					WORD ?					; PROC: 'p', GLOBAL: 'd'
	NoDebug					WORD ?					; PROC should not be debugged
DEBUGSYMBOL ends

; Variables. Global, parameters and locals
DEBUGVAR struct
	nSize					DWORD ?					; Size in bytes
	nArray					DWORD ?					; Followed by szName and szArray+Type 'MyVar',0,'[256]:BYTE',0
	nOfs					DWORD ?					; Offset for proc parameter or local
DEBUGVAR ends

; Threads
DEBUGTHREAD struct
	htread					HANDLE ?				; Thread handle
	threadid				DWORD ?					; Thread ID
	lpline					DWORD ?					; Pointer to line
	address					DWORD ?					; Address
	suspended				DWORD ?					; TRUE if suspended
	isdebugged				DWORD ?					; The thread is debugged
DEBUGTHREAD ends

; Holds important data while debugging
DEBUG struct
	hDbgThread				HANDLE ?				; Thread that runs the debugger
	pinfo					PROCESS_INFORMATION <>	; Process information
	hdbghand				HANDLE ?				; Handle to read / write process memory
	hdbgfile				HANDLE ?				; File handle
	prevline				DWORD ?					; Previous hilited line
	prevhwnd				DWORD ?					; Previous hilited line window handle
	lpthread				DWORD ?					; Pointer to current thread
	thread					DEBUGTHREAD 64 dup(<>)	; Threads
	context					CONTEXT <>				; Context
	prevcontext				CONTEXT <>				; Previous Context
	inxsource				DWORD ?					; Index to next free DEBUGSOURCE
	hMemSource				HGLOBAL ?				; Handle to memory containing DEBUGSOURCE structures
	inxtype					DWORD ?					; Index to next free DEBUGTYPE
	hMemType				HGLOBAL ?				; Handle to memory containing DEBUGTYPE structures
	inxsymbol				DWORD ?					; Index to next free DEBUGSYMBOL
	hMemSymbol				HGLOBAL ?				; Handle to memory containing DEBUGSYMBOL structures
	lpvar					DWORD ?					; Pointer to next free var
	hMemVar					HGLOBAL ?				; Variables definitions
	inxline					DWORD ?					; Index to next free DEBUGLINE
	hMemLine				HGLOBAL ?				; Handle to memory containing DEBUGLINE structures
	hMemNoBP				HGLOBAL ?				; Copy of code with no breakpoints
	hMemBP					HGLOBAL ?				; Copy of code with all breakpoints set
	minadr					DWORD ?					; Lowest address
	maxadr					DWORD ?					; Highest address
	maxproc					DWORD ?					; Highest proc address
	lpProc					DWORD ?					; Current proc
	lpStepOver				DWORD ?					; Proc to return to
	func					DWORD ?					; Current debug function
	fHandled				DWORD ?					; Set to TRUE when a breakpoint is reached
	pt						POINT <>				; Used by tooltip
	nErrors					DWORD ?					; Number of errors while parsing
DEBUG ends

; Predefined datatypes
DATATYPE struct
	lpszType				DWORD ?					; The datatype
	lpszConvertType			DWORD ?					; The datatype it shoukd be converted to. DD, DW and DB is converted
	nSize					WORD ?					; Size in bytes
	fSigned					WORD ?					; TRUE if signed
DATATYPE ends

; Current variable. Used by tooltip and immediate
VAR struct
	szName					BYTE 256 dup(?)			; Variable name MyVar
	szArray					BYTE 256 dup(?)			; Array size and type [256]:BYTE
	nType					DWORD ?					; Proc=99
	nArray					DWORD ?					; Array size (1 based index)
	nSize					DWORD ?					; Size in bytes
	fPtr					DWORD ?					; Not used yet
	nOfs					DWORD ?					; Offset from ebp for local and parameter
	ProjectFileID			DWORD ?					; ProjectFileID for locals
	Address					DWORD ?					; Address
	nInx					DWORD ?					; Current index, used by immediate
	IsSZ					DWORD ?					; Show as ZString, used by immediate
	Value					DWORD ?					; Current value, used by immediate and tooltip
	szValue					BYTE 256 dup(?)			; Current ZString value, used by immediate
	lpFormat				DWORD ?					; Pointer to format string
	nFormat					DWORD ?					; Format flags
	nErr					DWORD ?					; Error
VAR ends

; Register. Used by tooltip and immediate
REG struct
	szName					BYTE 16 dup(?)			; Name of register
	nSize					DWORD ?					; Size in bytes
	nOfs					DWORD ?					; Offset into CONTEXT
REG ends

.const

;#########################################################################

szAppName						db 'RADebug',0

; Text and predefined structures

; Registers
reg32							REG 10 dup(<'EAX',4,CONTEXT.regEax>,
										   <'EBX',4,CONTEXT.regEbx>,
										   <'ECX',4,CONTEXT.regEcx>,
										   <'EDX',4,CONTEXT.regEdx>,
										   <'ESI',4,CONTEXT.regEsi>,
										   <'EDI',4,CONTEXT.regEdi>,
										   <'EBP',4,CONTEXT.regEbp>,
										   <'ESP',4,CONTEXT.regEsp>,
										   <'EIP',4,CONTEXT.regEip>,
										   <'EFL',4,CONTEXT.regFlag>)
reg16							REG 4  dup(<'AX',2,CONTEXT.regEax>,
										   <'BX',2,CONTEXT.regEbx>,
										   <'CX',2,CONTEXT.regEcx>,
										   <'DX',2,CONTEXT.regEdx>)
reg8							REG 9 dup(<'AL',1,CONTEXT.regEax>,
										   <'AH',3,CONTEXT.regEax>,
										   <'BL',1,CONTEXT.regEbx>,
										   <'BH',3,CONTEXT.regEbx>,
										   <'CL',1,CONTEXT.regEcx>,
										   <'CH',3,CONTEXT.regEcx>,
										   <'DL',1,CONTEXT.regEdx>,
										   <'DH',3,CONTEXT.regEdx>,
										   <,0,0>)

; Predefined datatypes
szBYTE							db 'BYTE',0
szSBYTE							db 'SBYTE',0
szDB							db 'DB',0
szWORD							db 'WORD',0
szSWORD							db 'SWORD',0
szDW							db 'DW',0
szDWORD							db 'DWORD',0
szSDWORD						db 'SDWORD',0
szDD							db 'DD',0
szQWORD							db 'QWORD',0
szDQ							db 'DQ',0
szREAL4							db 'REAL4',0
szREAL8							db 'REAL8',0
szTBYTE							db 'TBYTE',0
szDT							db 'DT',0
								db 0

datatype						DATATYPE 1 dup (<szBYTE,szBYTE,1,0>,
												<szSBYTE,szSBYTE,1,1>,
												<szDB,szBYTE,1,0>,
												<szWORD,szWORD,2,0>,
												<szSWORD,szSWORD,2,1>,
												<szDW,szWORD,2,0>,
												<szDWORD,szDWORD,4,0>,
												<szSDWORD,szSDWORD,4,1>,
												<szDD,szDWORD,4,0>)
datatype2						DATATYPE 1	dup(<szQWORD,szQWORD,8,0>,
												<szDQ,szQWORD,8,0>,
												<szREAL4,szREAL4,4,0>,
												<szREAL8,szREAL8,8,0>,
												<szTBYTE,szTBYTE,10,0>,
												<szDT,szTBYTE,10,0>,
												<0,0,0,0>)

; The dbghelp dll
; Masm and VC6 C/C++
DbgHelpDLL						db 'DbgHelp.dll',0
; FreePASCAL
FpHelpDLL						db 'Addins\FpHelp.dll',0
; FreeBASIC
FbHelpDLL						db 'Addins\FbHelp.dll',0

; Debug events
szEXCEPTION_DEBUG_EVENT			db 'EXCEPTION_DEBUG_EVENT',0
szEXCEPTION_BREAKPOINT			db 'EXCEPTION_BREAKPOINT',0
szEXCEPTION_ACCESS_VIOLATION	db 'EXCEPTION_ACCESS_VIOLATION',0
szEXCEPTION_FLT_DIVIDE_BY_ZERO	db 'EXCEPTION_FLT_DIVIDE_BY_ZERO',0
szEXCEPTION_INT_DIVIDE_BY_ZERO	db 'EXCEPTION_INT_DIVIDE_BY_ZERO',0
szCREATE_PROCESS_DEBUG_EVENT	db 'CREATE_PROCESS_DEBUG_EVENT',0
szCREATE_THREAD_DEBUG_EVENT		db 'CREATE_THREAD_DEBUG_EVENT',0
szEXIT_THREAD_DEBUG_EVENT		db 'EXIT_THREAD_DEBUG_EVENT',0
szEXIT_PROCESS_DEBUG_EVENT		db 'EXIT_PROCESS_DEBUG_EVENT',0
szLOAD_DLL_DEBUG_EVENT			db 'LOAD_DLL_DEBUG_EVENT',0
szUNLOAD_DLL_DEBUG_EVENT		db 'UNLOAD_DLL_DEBUG_EVENT',0
szOUTPUT_DEBUG_STRING_EVENT		db 'OUTPUT_DEBUG_STRING_EVENT',0
szRIP_EVENT						db 'RIP_EVENT',0

; Debug events formatting
szEventString					db '%s %s',0
szEventDec						db '%s %d',0

; Some useful text constants
szCR							db 0Dh,0
szNULL							db 0
szSpace							db ' ',0
szComma							db ',',0
szColon							db ':',0
szImmPrompt						db '>',0

; Debug startup texts
szDebug							db 'Debug',0
szDebuggingStarted				db '** Debugging started **',0
szDebugStopped					db 0Dh,'** Debugging ended **',0
szUnhanfledBreakpoints			db 'There are %u unhandled breakpoint(s).',0
szUnsavedFiles					db 'There are %u unsaved file(s).',0
szNewerFiles					db '%u source files are newer than the exe.',0
szExeNotFound					db 'Could not open:',0Dh,'%s',0
szNoDebugInfoMasm				db 'No debug info found.',0Dh,'Use the /Zd, /Zi and /DEBUG command line options.',0
szNoDebugInfoFp					db 'No debug info found.',0Dh,'Use the -g command line option.',0

; Breakpoint save / load
szRADebugBP						db 'RADebugBP',0
szBPNULL						db 0,0
szCommaBP						db ',%u',0

; Debug menu items
DebugMenu						db 'Deb&ug',0
MenuItems						db 'Toggle &Breakpoint',VK_TAB,'Ctrl+T',0,
								   '&Clear Breakpoints',VK_TAB,'Ctrl+Shift+T',0,
								   '-',0,
								   '&Run',VK_TAB,'Shift+F7',0,
								   'Brea&k',VK_TAB,'Ctrl+Alt+F7',0,
								   '&Stop',VK_TAB,'Alt+F7',0,
								   '-',0,
								   'Step &Into',VK_TAB,'F7',0,
								   'Step &Over',VK_TAB,'Ctrl+F7',0,
								   'Run &To Caret',VK_TAB,'Ctrl+Shift+F7',0,
								   'Do not Debug',0,0
szView							db 'Debug Window',0

; Project file save / load
szMakeFiles						db 'MakeFiles',0
szMakeFilesExeKey				db '5',0
szMakeFilesObjKey				db '3',0
szNoDebug						db 'NoDebug',0

; RADebug options
szShowDbgHelp					db 'Show DbgHelp output',0
szShowDebugEvents				db 'Show debug events',0
szPinOutput						db 'Pin output window',0
szOutput2						db 'Show register window',0
AddinOpt						ADDINOPT 5 dup(<offset szShowDbgHelp,1,1>,
											   <offset szShowDebugEvents,2,2>,
											   <offset szPinOutput,4,4>,
											   <offset szOutput2,8,8>,
											   <0,0,0>)

; Tooltip window class
sztooltips_class32				db 'tooltips_class32',0
szTabControl					db 'SysTabControl32',0
szTabs							db 'Reg',0,'Fpu',0,'MMX',0,'Watch',0,0

; Tooltip / immediate window formatting
szReg32							db 'REGISTER %s Hex %08Xh Dec %u',0
szReg16							db 'REGISTER %s Hex %04Xh Dec %u',0
szReg8							db 'REGISTER %s Hex %02Xh Dec %u',0
szProc							db 'PROC %s Size %u',0
szData							db 'GLOBAL %s%s Address %08Xh Size %u',0
szData32						db 'GLOBAL %s%s Address %08Xh Size %u Hex %08Xh Dec %d',0
szData16						db 'GLOBAL %s%s Address %08Xh Size %u Hex %04Xh Dec %d',0
szData8							db 'GLOBAL %s%s Address %08Xh Size %u Hex %02Xh Dec %d',0
szDataSZ						db 'GLOBAL %s%s Address %08Xh Size %u ZString "%s"',0
szDataS							db 'GLOBAL %s%s Address %08Xh Size %u String "%s"',0
szParam							db 'PARAM %s%s Address %08Xh Size %u',0
szParam32						db 'PARAM %s%s Address %08Xh Size %u Hex %08Xh Dec %d',0
szParam16						db 'PARAM %s%s Address %08Xh Size %u Hex %04Xh Dec %d',0
szParam8						db 'PARAM %s%s Address %08Xh Size %u Hex %02Xh Dec %d',0
szLocal							db 'LOCAL %s%s Address %08Xh Size %u',0
szLocal32						db 'LOCAL %s%s Address %08Xh Size %u Hex %08Xh Dec %d',0
szLocal16						db 'LOCAL %s%s Address %08Xh Size %u Hex %04Xh Dec %d',0
szLocal8						db 'LOCAL %s%s Address %08Xh Size %u Hex %02Xh Dec %d',0
szLocalSZ						db 'LOCAL %s%s Address %08Xh Size %u ZString "%s"',0
szLocalS						db 'LOCAL %s%s Address %08Xh Size %u String "%s"',0
szValue							db 'Hex %08Xh Dec %d',0

szType							db 'Type: %s Size: %u',0

; Errors
szErrSyntaxError				db 'Syntax error: %s',0
szErrVariableNotFound			db 'Variable not found: %s',0
szErrIndexOutOfRange			db 'Index out of range: %s',0
szErrUnknownCommand				db 'Unknown command.',0

szErrConstant					db 'Could not evaluate expression: %s',0
szErrArray						db 'Could not evaluate array size: %s',0
szErrType						db 'Could not find datatype: %s',0
szErrorParsing					db 'WARNING!',0Dh,'There was %d error(s) while parsing.',0Dh,'Variables, parameters and locals are disabled.',0

; Ansi / Widechar
szA								db 'A',0
szW								db 'W',0

;#########################################################################
; Globals

.data?

hInstance						HINSTANCE ?						; Dll's module handle
hDbgHelpDLL						HMODULE ?						; Handle of DbgHelp.dll
hTip							HWND ?							; Tooltip
fOptions						dd ?							; Options for RADebug
lpHandles						dd ?							; Pointer to handles struct
lpProc							dd ?							; Pointer to proc struct
lpData							dd ?							; Pointer to data struct
hMnu							HMENU ?							; Debug popup menu
IDAddIn							dd 32 dup(?)					; Unique ID's for this AddIn
hOut1							HWND ?							; Handle of output window #1
hOut2							HWND ?							; Handle of output window #2
hOut3							HWND ?							; Handle of output window #3
szTempName						db MAX_PATH dup(?)				; Temporary path
szExeName						db MAX_PATH dup(?)				; Path to exe to be debugged
szObjName						db MAX_PATH dup(?)				; Path to obj to be debugged
szSourceName					db MAX_PATH dup(?)				; Path to a source file
breakpoint						BREAKPOINT 512 dup(<>)			; Breakpoints
lpOldOutProc3					dd ?							; Immediate window callback
dbg								DEBUG <>						; Holds info while debugging
var								VAR <>							; Current variable info
fNoDebugInfo					dd ?							; No debug info found
outbuffer						db 1024 dup(?)					; Buffer for wsprintf
nRadASMVer						dd ?							; RadASM version
nAsm							dd ?							; Assembler / Compiler
fCaseSensitive					dd ?
szWatchList						db 512 dup(?)					; List of variables to watch
mFunc							dd ?
nError							dd ?
szError							db 256 dup(?)
nID								dd ?
hTool							HWND ?							; Handle of debug tool window
lpOldToolProc					dd ?
lpOldToolCaption				dd ?
hDbgTab							HWND ?
nDbgSel							dd ?
hDbgReg							HWND ?
hDbgFpu							HWND ?
hDbgMmx							HWND ?
hDbgWatch						HWND ?
