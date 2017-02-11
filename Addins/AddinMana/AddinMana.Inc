
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
	include gdi32.inc
	include version.inc
	include shell32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
	includelib Gdi32.lib
	includelib version.lib
	includelib shell32.lib

;#########################################################################
;		RadASM Add In Include

	include \RadASM\Masm\Inc\radasm.inc

;#########################################################################
;		VKim's Debug

	include masm32.inc
	includelib masm32.lib
	include \RadASM\masm\inc\debug.inc
	includelib \RadASM\masm\lib\debug.lib

	DBGWIN_DEBUG_ON = 1		; include debug info into the program
	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################
;		Prototypes

	DLLProc				PROTO :DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL			PROTO :DWORD, :DWORD

	TextOutput			PROTO :DWORD
	clrOutput			PROTO 
	HexOutput			PROTO :DWORD

	ADDIN struct
		hDLL			dd ?
		fhook1			dd ?
		fhook2			dd ?
		fOpt			dd ?
		lpDllProc		dd ?
		inx				dd ?
	ADDIN ends

	ADDINSTATE struct
		fInst			dd ?
		fOpt			dd ?
		fOptInit		dd ?
		nIniInx			dd ?
		hAddin			dd ?
		lpAddin			dd ?
		lpAddinOpt		dd ?
	ADDINSTATE ends

	ADDINOPT struct
		lpStr			dd ?
		nAnd			dd ?
		nOr				dd ?
	ADDINOPT ends

	MAX_ADDIN			equ 64

	;AddinMana.dlg
	IDD_DLGADDINMANA	equ 1000
	IDC_LSTADDINS		equ 1031
	IDC_BTNAPPLY		equ 10
	IDCANCEL			equ 2
	IDOK				equ 1
	IDC_BTNINSTALL		equ 1032
	IDC_BTNUNINSTALL	equ 1033
	IDC_BTNHELP			equ 1008

	IDC_CHK1			equ 1011
	IDC_CHK2			equ 1012
	IDC_CHK3			equ 1013
	IDC_CHK4			equ 1014
	IDC_CHK5			equ 1015
	IDC_CHK6			equ 1016
	IDC_CHK7			equ 1017
	IDC_CHK8			equ 1018
	IDC_CHK9			equ 1019
	IDC_CHK10			equ 1020
	IDC_CHK11			equ 1021
	IDC_CHK12			equ 1022
	IDC_CHK13			equ 1023
	IDC_CHK14			equ 1024
	IDC_CHK15			equ 1025
	IDC_CHK16			equ 1026

	IDC_STCDESC			equ 1041
	IDC_STCAUTHOR		equ 1042
	IDC_STCVERSION		equ 1043
	IDC_STCDATE			equ 1044

.data

	szShellLib			db  'shell32',0
	szShellEx			db  'ShellExecuteA',0
	szOpen				db 'Open',0
	szHelp				db '\Help\',0
	szAppName			db 'AddinMana',0
	szAddinMana			db 'Addin Manager',0
	szBS				db '\',0
	szDll				db '\*.dll',0
	szInstallDll		db 'InstallDll',0
	szInstallDllEx		db 'InstallDllEx',0
	szDllProc			db 'DllProc',0
	szGetOptions		db 'GetOptions',0
	szAddins			db 'Addins',0
	szNULL				db 0
	AddinOpt			ADDINOPT <offset szAddinMana,1,1>
						ADDINOPT <0,0,0>

	szVarTrans			db '\VarFileInfo\Translation',0
	szFileDescription	db 'FileDescription',0
	szLegalCopyright	db 'LegalCopyright',0
	szFileVersion		db 'FileVersion',0
	szFileStringFormat	db '\StringFileInfo\%04x%04x\%s',0
	szDateFormat		db '%u.%02u.%02u', 0
	szNA				db 'N/A',0

.data?

	hInstance			dd ?	;Dll's module handle
	lpHandles			dd ?	;Pointer to handles struct
	lpProc				dd ?	;Pointer to proc struct
	lpData				dd ?	;Pointer to data struct
	IDAddIn				dd ?	;Unique ID for this AddIn
	ais					ADDINSTATE MAX_ADDIN dup(<?>)
	help				db MAX_PATH dup(?)
	nHelp				dd ?

.code

;#########################################################################
;		Output Window procs

TextOutput proc lpszStr

	pushad
	push  lpszStr
	mov   eax,lpProc
	call  [eax].ADDINPROCS.lpTextOut
	popad	
	ret

TextOutput endp

;#########################################################################

clrOutput proc

	pushad
	mov   eax,lpProc
	call  [eax].ADDINPROCS.lpClearOut
	popad	
	ret

clrOutput endp

;#########################################################################

HexOutput proc val:DWORD
	
	pushad
	push  val
	mov   eax,lpProc
	call  [eax].ADDINPROCS.lpHexOut
	popad
	ret
	
HexOutput endp
