
include ..\RadASM.inc
include windows.inc
include kernel32.inc
include user32.inc
include comdlg32.inc

includelib user32.lib
includelib kernel32.lib
includelib comdlg32.lib

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

hexOut		PROTO	:DWORD

ADDINOPT struct
	lpStr		dd ?
	nAnd		dd ?
	nOr			dd ?
ADDINOPT ends

MaxCap		equ 241

DLGHEAD struct
	ver			dd ?
	changed		dd ?
	class		db 32 dup(?)
	menuid		db 32 dup(?)
	font		db 32 dup(?)
	fontsize	dd ?
	fontht		dd ?
	undo		dd ?
	ctlid		dd ?
	hmnu		dd ?
	htlb		dd ?
	hstb		dd ?
	locked		dd ?
	spare1		dd ?
	spare2		dd ?
DLGHEAD ends

DIALOG struct
	hwnd			dd ?				;Set to TRUE
	hdmy			dd ?				;Transparent dummy window
	oldproc			dd ?				;Set to NULL
	hpar			dd ?				;Set to NULL
	hcld			dd ?				;Set to NULL
	style			dd ?				;Set to desired style
	exstyle			dd ?				;Set to desired ex style
	x				dd ?				;X position in pixels
	y				dd ?				;Y position in pixels
	ccx				dd ?				;Width in pixels
	ccy				dd ?				;Height in pixels
	caption			db MaxCap dup(?)	;Caption max 240+1 char
	ntype			dd ?				;Follows ToolBox buttons Dialog=0, Edit=1, Static=2, GroupBox=3
	ntypeid			dd ?				;Set to NULL
	tab				dd ?				;Tab index, Dialog=0, First index=0
	id				dd ?				;Dialog / Controls ID
	idname			db 32 dup(?)		;ID Name, max 31 chars
	undo			dd ?				;Set to NULL
	himg			dd ?				;Set to NULL
	class			db 32 dup(?)		;Class fur UDC
DIALOG ends

MNUHEAD struct
	menuname	db 32 dup(?)
	menuid		dd ?
	startid		dd ?
MNUHEAD ends

MNUITEM struct
	itemflag	dd ?
	itemname	db 32 dup(?)
	itemid		dd ?
	itemcaption	db 64 dup(?)
	level		dd ?
	checked		dd ?
	grayed		dd ?
	shortcut	dd ?
MNUITEM ends

.const

IDD_DLGCODEWRITE			equ 1000
IDC_CBOEXPORT				equ 1001
IDC_EDTTEMPLATE				equ 1002
IDC_BTNTEMPLATE				equ 1003
IDC_EDTMENU					equ 1004
IDC_BTNMENU					equ 1005
IDC_EDTPROC					equ 1006

.data

szDlgToWin					db 'Dialog to window',0
szRad						db 'Template (*.rad)',0,'*.rad',0,0
szMnu						db 'Menu (*.mnu)',0,'*.mnu',0,0
szNotFound					db 'The template file was not found.',0Dh,0
szExport					db "Template,ID equ's,Classes,Names,Captions,Window,Controls,Commands",0
szProc						db 'WndProc',0
szClass						db 'szWinClass,WinClass,szEdit,Edit,szStatic,Static,szButton,Button,szCombo,ComboBox,szList,ListBox,szScroll,ScrollBar,'
							db 'szSysTab,SysTabControl32,szProgress,msctls_progress32,szTreeView,SysTreeView32,'
							db 'szListView,SysListView32,szTrackBar,msctls_trackbar32,szUpDown,msctls_updown32,'
							db 'szToolBar,ToolbarWindow32,szStatusBar,msctls_statusbar32,szDateTime,SysDateTimePick32,'
							db 'szMonthCal,SysMonthCal32,szRichEdit,RichEdit20A,szUdcClass,UDCCLASS,szComboBoxEx,ComboBoxEx32,'
							db 'szIPAdress,SysIPAddress32,szAnimate,SysAnimate32,szHotkey,msctls_hotkey32,szPager,SysPager,szRebar,ReBarWindow32,'
							db 'szHeader,SysHeader32,szRAEdit,RAEdit,szRAHexEd,RAHexEd,szRAGrid,RAGrid,szWebBrowser,WEB_BROWSER,'
							;Add more custom controls here
							db 'szCustUnknown,Unknown',0
nClass						db 0,1,2,3,3,3,3,4,5,6
							db 6,7,8,9,10,11,12,2,13,14
							db 15,16,17,18,19,2,20,21,22,23
							db 23,24,25,26,27,28,29,30,31,32
							db 33,34,35,36,37,38,39,40,41,42
							db 43,44,45,46,47,48,49,50,51,52
szCaption					db ',szMenuName,szWinCap,szWinName,szEditCap,szEditName,szStaticCap,szStaticName,szGroupCap,szGroupName,szButtonCap,szButtonName,'
							db 'szCheckCap,szCheckName,szRadioCap,szRadioName,szComboCap,szComboName,szListCap,szListName,szVScrollCap,szVScrollName,'
							db 'szHScrollCap,szHScrollName,szTabCap,szTabName,szProgressCap,szProgressName,szTreeViewCap,szTreeViewName,'
							db 'szListViewCap,szListViewName,szTrackBarCap,szTrackBarName,szUpDownCap,szUpDownName,szIconCap,szIconName,'
							db 'szToolBarCap,szToolBarName,szStatusBarCap,szStatusBarName,szDatePickCap,szDatePickName,szMonthViewCap,szMonthViewName,'
							db 'szRichEditCap,szRichEditName,szUdcCap,szUdcName,szCbExCap,szCbExName,szShpCap,szShpName,szIPCap,szIPName,szAniCap,szAniName,'
							db 'szHotCap,szHotName,szHPagerCap,szHPagerName,szVPagerCap,szVPagerName,szRebarCap,szRebarName,szHdrCap,szHdrName,'
							db 'szRAEditCap,szRAEditName,szRAHexEdCap,szRAHexEdName,szRAGridCap,szRAGridName,szWebBrowserCap,szWebBrowserName,'
							;Add more custom controls here
							db 'szCustUnknownCap,szCustUnknownName',0

;This table translates the custom controls unique ID to a fixed number
CustClassTranslate			dd 260,33		;RAEdit
							dd 261,34		;RAHexEd
							dd 280,35		;RAGrid
							dd 258,36		;Web browser
							;Add more custom controls here
							dd 0,37			;Update 37 if more custom controls added

;ID
szCmdDefCtlID				db '[*DEFCTLID*]',0
szCmdDefMnuID				db '[*DEFMNUID*]',0
;Class
szCmdDefWinClass			db '[*DEFWINCLASS*]',0
szCmdDefCtlClass			db '[*DEFCTLCLASS*]',0
;Name
szCmdDefCtlName				db '[*DEFCTLNAME*]',0
szCmdDefMnuName				db '[*DEFMNUNAME*]',0
;Caption
szCmdDefCtlCaption			db '[*DEFCTLCAPTION*]',0
;Create
szCmdCreateWin				db '[*CREATEWIN*]',0
szCmdCreateCtl				db '[*CREATECTL*]',0
;Command
szCmdCommand				db '[*COMMAND*]',0
;Get
szCmdGetWinName				db '[*GETWINNAME*]',0
szCmdGetProcName			db '[*GETPROCNAME*]',0
szCmdGetMnuName				db '[*GETMNUNAME*]',0

szVerErr					db 'Only dialogs with ver 1.0.2',0Dh,'can be converted.',0

AddinOpt					ADDINOPT <offset szDlgToWin,1,1>
							ADDINOPT <0,0,0>

;#################################################################################

szCreateWindow				db 'invoke CreateWindowEx,',0
szIf						db '.if eax==',0
szElseIf					db '.elseif eax==',0
szEndIf						db '.endif',0
szAddr						db 'addr ',0
szhWin						db 'hWin',0
szhInst						db 'hInst',0
szhInstance					db 'hInstance',0
szOffset					db 'offset ',0

szIniApp					db 'CodeMake',0
szNULL						db 0

.data?

hInstance       			dd ?	;Dll's module handle
lpHStruct					dd ?	;Pointer to handles struct
lpPStruct					dd ?	;Pointer to proc struct
lpDStruct					dd ?	;Pointer to data struct
hWnd						dd ?	;Handle of mdi frame
nMenuID						dd ?	;Retrived menu ID

fClass						dd ?,?
sClass						db 32 dup(?)
sClassName					db 32 dup(?)
sCaption					db 32 dup(?)
nCaption					dd 64 dup(?)
sName						db 32 dup(?)

szTemplateFile				dd 256 dup(?)
szMenuFile					dd 256 dup(?)
szProcName					dd 256 dup(?)
