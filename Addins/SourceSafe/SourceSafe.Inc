
;#########################################################################
;	Include files

include windows.inc
include kernel32.inc
include user32.inc
include shell32.inc

;#########################################################################
;	Libraries

includelib kernel32.lib
includelib user32.lib
includelib shell32.lib

;#########################################################################
;	RadASM Add In Include

include \RadASM\Masm\Inc\radasm.inc

;#########################################################################
;	VKim's Debug

include masm32.inc
include debug.inc
includelib debug.lib

DBGWIN_DEBUG_ON = 1		; include debug info into the program
DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################
;		Prototypes

DLLProc				PROTO :DWORD, :DWORD, :DWORD, :DWORD
InstallDLL			PROTO :DWORD, :DWORD

IDD_DLGADDFILES		equ 1000
IDC_LSTFILES		equ 1001
IDC_EDTGROUP		equ 1002

IDD_DLGGETFILES		equ 1100
IDD_DLGCHECKIN		equ 1200
IDC_CHKCHECKOUT		equ 1002

REM_BASE			equ WM_USER+1000
REM_READONLY		equ REM_BASE+35		;wParam=0, lParam=TRUE/FALSE
ID_EDIT				equ	65501
ID_DIALOG			equ	65502
ID_EDITTXT			equ	65503
ID_EDITHEX			equ	65504
ID_FIRSTCHILD		equ 65001
ID_LASTCHILD		equ 65499
IDM_FILE_SAVEALLFILES	equ 40009

DLGHEAD struct
	ver				dd ?				;Set to 101
	changed			dd ?				;Set to FALSE
	class			db 32 dup(?)		;Set to Null string
	menuid			db 32 dup(?)		;Set to Null string
	font			db 32 dup(?)		;Set to "MS Sans Serif"
	fontsize		dd ?				;Set to 8
	fontht			dd ?				;Set to -10
	undo			dd ?				;Set to NULL
	ctlid			dd ?				;Set to 1001
	hmnu			dd ?				;Set to NULL
	htlb			dd ?				;Set to NULL
	hstb			dd ?				;Set to NULL
	locked			dd ?				;Set to TRUE or FALSE
	hfont			dd ?				;Set to NULL
	carset			db ?				;Set to NULL
	italic			db ?
	weight			dw ?
DLGHEAD ends

KEYBDINPUT struct
	dwType		DD ?
	wVk			DW ?
	wScan		DW ?
	dwFlags 	DD ?
	time		DD ?
	dwExtraInfo	DD ?
	padding		DD 2 DUP (?)
KEYBDINPUT ends

.const

szNULL				db 0
szBS				db '\',0

szSourceSafe		db 'SourceSafe',0
szPath				db 'Path',0
szUserName			db 'UserName',0
szPassWord			db 'PassWord',0
szProject			db 'Project',0

szMnuRunSS			db 'Run SourceSafe',0
szMnuAddFiles		db 'Add Files to SourceSafe',0
szMnuCheckIn		db 'Check In',0
szMnuCheckOut		db 'Check Out',0
szMnuUndoCheckOut	db 'Undo Check Out',0
szMnuGetLatest		db 'Get Latest Version',0

szRoot				db '$/',0
szError				db 'Error',0
szDuplicate			db 'Duplicate filename',0Dh,0Ah,'%s',0Dh,0Ah,'Rename file and try again.',0
szDebug				db 'Debug mode',0
szNotExist			db 'does not exist',0
szNoFiles			db 'No files found checked out by',0
szNoDifference		db 'No differences.',0
szChanged			db '%s',0Dh,0Ah,0Dh,0Ah,'The file is changed.',0Dh,0Ah,'Undo checkout and loose changes?',0
szAddNew			db '%s',0Dh,0Ah,0Dh,0Ah,'Add file to Source Safe?',0
szRemoveFile		db '%s',0Dh,0Ah,0Dh,0Ah,'Remove file from Source Safe?',0

.data

szCP				db 'SS Cp "%s" "-y%s,%s"',0
szCreate			db 'SS Create "%s" "-y%s,%s" -c-',0
szWorkFolder		db 'SS Workfold "-y%s,%s"',0
szAdd				db 'SS Add "%s" "-y%s,%s" -c- -i-Y',0
szDel				db 'SS Delete "%s" "-y%s,%s" -i-Y',0
szGet				db 'SS Get "%s" "-y%s,%s"',0
szCheckInKeepOut	db 'SS CheckIn "%s" "-y%s,%s" -c- -k',0
szCheckIn			db 'SS CheckIn "%s" "-y%s,%s" -c-',0
szCheckOut			db 'SS CheckOut "%s" "-y%s,%s" -c-',0
szUndoCheckOut		db 'SS Undocheckout "%s" "-y%s,%s" -i-Y',0
szDifference		db 'SS Diff "%s" "-y%s,%s" -b',0
szStatus			db 'SS Status "%s" -u -p "-y%s,%s"',0
szStatusNoP			db 'SS Status "%s" -u "-y%s,%s"',0
szProperties		db 'SS Properties "%s" "-y%s,%s"',0
szRename			db 'SS Rename "%s" "%s" "-y%s,%s"',0
szRunSSEXP			db 'SSEXP',0
szRun				db '"-y%s,%s"',0

AddinOpt			ADDINOPT <offset szDebug,1,1>
					ADDINOPT <0,0,0>

.data?

hInstance			dd ?	;Dll's module handle
lpHandles			dd ?	;Pointer to handles struct
lpProc				dd ?	;Pointer to proc struct
lpData				dd ?	;Pointer to data struct
hOut				dd ?	;Handle of output window
IDRunSS				dd ?
IDAddFiles			dd ?
IDSeparator			dd ?
IDCheckIn			dd ?
IDCheckOut			dd ?
IDUndoCheckOut		dd ?
IDGetLatest			dd ?
UserName			db 128 dup(?)
PassWord			db 128 dup(?)
Project				db 128 dup(?)
Path				db MAX_PATH dup(?)
FileName			db MAX_PATH dup(?)
TempPath			db MAX_PATH dup(?)
sat					SECURITY_ATTRIBUTES <>
sinf				STARTUPINFO <>
pinf				PROCESS_INFORMATION <>
nFileID				dd ?
hFound				dd ?
fChanged			dd ?
nFileType			dd ?
fOption				dd ?
Result				db 2048 dup(?)
hRead				dd ?
hWrite				dd ?
fNoRead				dd ?
