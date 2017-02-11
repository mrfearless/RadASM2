
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
	include masm32.inc
	include Advapi32.inc
;	include Version.inc
	include Comctl32.inc
	include shell32.inc
;	include ComDlg32.inc
	include Gdi32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
	includelib masm32.lib
	includelib Advapi32.lib
;	includelib Version.lib
	includelib Comctl32.lib
	includelib shell32.lib
;	includelib ComDlg32.lib
	includelib Gdi32.lib

;#########################################################################
;		RadASM RADToolBar Include

	include \RadASM\Masm\Inc\radasm.inc

;#########################################################################
;		VKim's Debug

	include \masm32\include\debug.inc
	includelib \masm32\lib\debug.lib

	DBGWIN_DEBUG_ON = 1		; include debug info into the program
	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################
;		Prototypes

	DLLProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL				PROTO :DWORD, :DWORD
	ReadToolBar				PROTO
	SubProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	LoadToolBar				PROTO
	SaveToolBar				PROTO
	LoadDefToolBar			PROTO
	SaveDefToolBar			PROTO
	UpdateToolbar			PROTO
	ResetToolbar			PROTO

	TBChangeIcon 			PROTO :DWORD,:DWORD,:DWORD
	TBLoadIcon				PROTO :DWORD,:DWORD,:DWORD
	Parsestring 			PROTO :DWORD,:DWORD
	UpdateIcon				PROTO :DWORD,:DWORD
	GetIniKey				PROTO :DWORD,:DWORD
	UpdateToolTips			PROTO
	UpdateIniKey			PROTO
	FixPath					PROTO :DWORD
	InsertPath				PROTO :DWORD,:DWORD,:DWORD
	GetIniFile				PROTO


;#########################################################################
;		Structures

	RADTBBUTTON STRUCT
		TBB		TBBUTTON	<>
		szNAME	BYTE		80 DUP (?)
	RADTBBUTTON ends

	ADDINOPT struct
		lpStr	dd ?	;Pointer to CheckBox text
		nAnd	dd ?	;Option AND value
		nOr		dd ?	;Option OR value
	ADDINOPT ends

.data
	SubKey				db 				"Software\KetilO\RadAsm\toolbar",0
	tbvalue				db				"Toolbar",0
	tbdefvalue			db				"DefToolbar",0
	
	AddInString1		db				"Enable custom ToolBar",0
	AddInString2		db				"Use phoenity buttons",0
	AddInString3		db				"Use grayed images",0
	szExtractIcons		db				"Extract tool icons", 0
	szUseIconFiles		db				"Use tool icon files",0
	AddinOpt			ADDINOPT		<offset AddInString1,01h,01h>
						ADDINOPT		<offset AddInString2,04h,04h>
						ADDINOPT		<offset AddInString3,02h,02h>
						ADDINOPT		<offset szExtractIcons,18h,08h>
						ADDINOPT		<offset szUseIconFiles,18h,10h>
						ADDINOPT		<0,0,0>

.data?

	hInstance			dd ?	;Dll's module handle
	lpHandles			dd ?	;Pointer to handles struct
	lpProc				dd ?	;Pointer to proc struct
	lpData				dd ?	;Pointer to data struct

	AppClosing			dd				?
	TBTextBuffer		WORD			80 dup (?)
	tbrbtns				RADTBBUTTON		256 dup (<>)
	nTotalBtns			dd				?
	hToolBar			dd				?
	OldhWinProc			dd				?
	hNewIml				dd				?
	hNewImlGray			dd				?
	hOldIml				dd				?

;######################################################################

	LOCALE_SYSTEM_DEFAULT	 	equ 2048
	REQUEST_DESCRIPTION			equ 1
	REQUEST_PATH				equ 4
	UserBtnID1					equ 29991
	UserBtnID2					equ 29992

.data
	IniSection					db "MenuTools", 0
	IniKeyDef					db "?", 0
	EditFlag					dd FALSE
	Icon1File					db "\BCIconA.ICO", 0
	Icon2File					db "\BCIconB.ICO", 0

.data?
	fOption						dd ?	;fOption is a value read from ini file
	Button1Def					dd ?	;default image index for button1
	Button2Def					dd ?	;default image index for button2
	IniKey1						db ?, ?
	IniKey2						db ?, ?
	IcoPath						db MAX_PATH DUP(?)
	FileDesc1					db MAX_PATH DUP(?)
	FileDesc2					db MAX_PATH DUP(?)
	lpIniAsmFile				dd ?

