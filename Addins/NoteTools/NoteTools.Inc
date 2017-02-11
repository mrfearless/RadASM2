
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
	include masm32.inc
;	include Comctl32.inc
;	include shell32.inc
;	include ComDlg32.inc
;	include Gdi32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
	includelib masm32.lib
;	includelib Comctl32.lib
;	includelib shell32.lib
;	includelib ComDlg32.lib
;	includelib Gdi32.lib

;#########################################################################
;		RadASM Add In Include

	include \RadASM\Masm\Inc\radasm.inc

;#########################################################################
;		VKim's Debug

	include \masm32\include\debug.inc
	includelib \masm32\lib\debug.lib

	DBGWIN_DEBUG_ON = 1		; include debug info into the program
	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################
;		Prototypes

	DLLProc					PROTO 	:DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL				PROTO 	:DWORD, :DWORD
	CreateToolTip			PROTO
	GetItemName				PROTO	:DWORD
	DlgProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	GetIniText				PROTO	:DWORD
	SetIniText				PROTO	:DWORD
	ListBoxSubClass			PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	CreateBuffer			PROTO

ADDINOPT struct
	lpStr	dd ?	;Pointer to CheckBox text
	nAnd	dd ?	;Option AND value
	nOr		dd ?	;Option OR value
ADDINOPT ends

.const
	TTM_UPDATE 			equ WM_USER + 29

.data
	szToolTipClass		db "tooltips_class32",0
	szMenuText			db "Edit comment",0
	szCmtFileExt		db ".cmt",0
	szDefault			db "No entry",0
	szAppName			db "RadInfo",0
	AddInString					BYTE		"Enable Notetools",0
	AddInString2				BYTE		"Enable tipcolors for notes",0
	AddInString3				BYTE		"Enable tip titles",0
	AddInString4				BYTE		"Enable global tipcolors",0
	AddinOpt					ADDINOPT	<OFFSET AddInString,1,1>
								ADDINOPT	<OFFSET AddInString2,2,2>
								ADDINOPT	<OFFSET AddInString3,4,4>
								ADDINOPT	<OFFSET AddInString4,8,8>
								ADDINOPT	<0,0,0>
.data?

	hInstance			dd ?	;Dll's module handle
	lpHandles			dd ?	;Pointer to handles struct
	lpProc				dd ?	;Pointer to proc struct
	lpData				dd ?	;Pointer to data struct
	IDAddIn				dd ?	;Unique ID for this AddIn
	hPrpLst				dd ?
	hToolTip			dd ?
	hSubMenu			dd ?
	hEditDlg			dd ?
	EditText			db 16 DUP(?)
	CmtStr				db 128 DUP(?)
	CmtFile				db MAX_PATH DUP (?)
	Options				dd ?
	OldLBProc			dd ?
	OldItem				dd ?
	pProcName			dd ?
	hHeap				dd ?
	DefTipColor			dd ?
	