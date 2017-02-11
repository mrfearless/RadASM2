include \radasm\masm\inc\RadASM.inc
include windows.inc
include kernel32.inc
include user32.inc
includelib user32.lib
includelib kernel32.lib

MNUHEAD struct
	menuname		db 32 dup(?)
	menuid			dw ?
	dummy			dw ?
	startid			dw ?
	version			dw ?
MNUHEAD ends

MNUITEM struct
	itemflag		dd ?
	itemname		db 32 dup(?)
	itemid			dd ?
	itemcaption		db 64 dup(?)
	level			dd ?
	dummy			dd ?
	flag			dd ?
	shortcut		dd ?
MNUITEM ends

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
	charset			db ?				;Set to NULL
	italic			db ?
	weight			dw ?
DLGHEAD ends

MaxCap				equ 241

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

PROFIND struct
	nFun		dd ?	;0=Find, 1=Free memory
	hMem		dd ?	;Memory handle. NULL if nFile is used.
	nFile		dd ?	;Project file ID.
	pMem		dd ?	;Returned pointer to found line in file
	pFile		dd ?	;Set / returned position in file.
	lpFind		dd ?	;Pointer to find what string.
	lpNot		dd ?	;Pointer to NOT string. Typical ;'"
	lpLine		dd ?	;Pointer to line buffer.
	pLine		dd ?	;Returned position into line buffer. -1 if not found.
	nMiss		dd ?	;Number of invalid Project file ID's.
PROFIND ends

ADDINOPT struct
	lpStr		dd ?
	nAnd		dd ?
	nOr			dd ?
ADDINOPT ends

.const

ID_DIALOG					equ	65502
ID_FIRSTCHILD				equ 65001
ID_LASTCHILD				equ 65499

IDD_DLGOPTION				equ 100
IDC_TAB1					equ 101
IDUSE						equ 10

IDD_TABOPT1					equ 200
IDC_CHKADDDLG				equ 201
IDC_CHKADDMNU				equ 202
IDC_CHKADDRES				equ 203
IDC_CHKADDFILE				equ 205
IDC_CHKADDFOLDER			equ 206

IDC_CHKADDACLRC				equ 210
IDC_CHKADDRESRC				equ 208
IDC_CHKADDSTRRC				equ 207
IDC_CHKADDVERRC				equ 204
IDC_CHKADDLNGRC				equ 209

IDD_TABOPT2					equ 300
IDC_CHKCTLCLK				equ 301
IDC_CHKMNUSEL				equ 302
IDC_CHKCTLNME				equ 303
IDC_CHKMODBUILD				equ 304

IDD_TABOPT3					equ 400

IDD_TABOPT4					equ 500

.data

szReallyRad					db 'ReallyRad',0
szCodeWrite					db 'ReallyRad - CodeWrite',0

TabTitle1					db 'Main RC',0
szAddDlg					db 'AddDlg',0
szAddMnu					db 'AddMnu',0
szAddRes					db 'AddRes',0
szAddFile					db 'AddFile',0
szAddFolder					db 'AddFolder',0

szAddAclRc					db 'AddAclRc',0
szAddResRc					db 'AddResRc',0
szAddStrRc					db 'AddStrRc',0
szAddVerRc					db 'AddVerRc',0
szAddLngRc					db 'AddLngRc',0

TabTitle2					db 'Goto Code',0
szCtlClk					db 'CtlClk',0
szMnuSel					db 'MnuSel',0
szCtlNme					db 'CtlNme',0
szModBuild					db 'ModBuild',0

TabTitle3					db 'Add Module',0

TabTitle4					db 'Code Write',0

szDef						db '#define',0
szBmp						db 'BITMAP',0
szCur						db 'CURSOR',0
szIco						db 'ICON',0
szImg						db 'IMAGE',0
szMid						db 'MIDI',0
szWav						db 'WAVE',0
szAvi						db 'AVI',0
szRcd						db 'RCDATA',0
szMan						db 'MANIFEST',0

szVer						db 'VERSIONINFO',0
szFileVer					db 'FILEVERSION',0
szProdVer					db 'PRODUCTVERSION',0
szFileOs					db 'FILEOS',0
szFileType					db 'FILETYPE',0
szBlock						db 'BLOCK',0
szValue						db 'VALUE',0
szBegin						db 'BEGIN',0
szEnd						db 'END',0

szRC						db 'rc',0
							db 0Dh,0Ah
szInc						db '#include',0
szRes						db ' "Res/',0
szDlg						db 'Dlg.rc"',0Dh,0Ah,0
szMnu						db 'Mnu.rc"',0Dh,0Ah,0
szStrRc						db 'Str.rc"',0Dh,0Ah,0
szResRc						db 'Res.rc"',0Dh,0Ah,0
szVerRc						db 'Ver.rc"',0Dh,0Ah,0
szAclRc						db 'Acl.rc"',0Dh,0Ah,0
szLngRc						db 'Lng.rc"',0Dh,0Ah,0
szNot						db ";'",22h,0
szNULL						db 0
szFiles						db 'Files',0
szNewer						db ' is newer than source.',0
FTAsm						db '.asm',0
FTObj						db '.obj',0

binDecade           		dd 3B9ACA00h
                    		dd 05F5E100h
                    		dd 00989680h
                    		dd 000F4240h
                    		dd 000186A0h
                    		dd 00002710h
                    		dd 000003E8h
                    		dd 00000064h
                    		dd 0000000Ah
                    		dd 00000001h

AddinOpt					ADDINOPT <offset szReallyRad,1,1>
							ADDINOPT <0,0,0>

.data?

hInstance       			dd ?	;Dll's module handle
lpHStruct					dd ?	;Pointer to handles struct
lpPStruct					dd ?	;Pointer to proc struct
lpDStruct					dd ?	;Pointer to data struct
OptMenuID					dd ?	;ReallyRad Options
ModMenuID					dd ?	;ReallyRad Options

hWnd						HWND ?
hDlg						HWND ?
hTab						HWND ?
hTabDlg						HWND 4 dup(?)
WhichTabChosen				dd ?

hFound						dd ?

lpIniFile					dd ?
fAddDlg						dd ?
fAddMnu						dd ?
fAddRes						dd ?
fAddStrRc					dd ?
fAddResRc					dd ?
fAddVerRc					dd ?
fAddAclRc					dd ?
fAddLngRc					dd ?
fAddFile					dd ?
fAddFolder					dd ?
fCtlClk						dd ?
fMnuSel						dd ?
fCtlNme						dd ?
fModBuild					dd ?
