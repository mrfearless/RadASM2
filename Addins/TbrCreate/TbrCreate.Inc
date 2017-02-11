
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include ComDlg32.inc
include gdi32.inc
include shlwapi.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib ComDlg32.lib
includelib gdi32.lib
includelib shlwapi.lib

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

DlgProc			PROTO	:HWND,:UINT,:WPARAM,:LPARAM

m2m MACRO M1, M2
	push M2
	pop  M1
ENDM

;#########################################################################

.const

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

IDB_MNUARROW							equ 500

IDD_DIALOG1								equ 1000
IDC_EDTM								equ 1002
IDC_BTNM								equ 1003
IDC_BTNB								equ 1004
IDC_EDTB								equ 1005
IDC_EDTT								equ 1006
IDC_EDTIDT								equ 1007
IDC_LSTT								equ 1008
IDC_STCB								equ 1009
IDC_LSTM								equ 1010
IDC_BTNU								equ 1011
IDC_BTND								equ 1012
IDC_BTNEXPORT							equ 1022
IDC_BTNEXPORTFB							equ 1035
IDC_CANCEL								equ 1023
IDC_BTNADDBTN							equ 1014
IDC_BTNDEL								equ 1015
IDC_BTNINSBTN							equ 1001
IDC_BTNADDSEP							equ 1016
IDC_BTNINSSEP							equ 1017
IDC_BTNOPEN								equ 1013
IDC_BTNSAVE								equ 1018
IDC_CHKFLAT								equ 1019
IDC_CHKWRAP								equ 1020
IDC_CHKNODIVIDER						equ 1036
IDC_CHKTIP								equ 1021
IDC_EDTOUT								equ 1024
IDC_EDTIDTN								equ 1026
IDC_EDTTN								equ 1027
IDC_BTNNEW								equ 1028
IDC_CHKLIST								equ 1029
IDC_CHKCHECK							equ 1030
IDC_CHKGROUP							equ 1031
IDC_EDTBN								equ 1034
IDC_EDTBNBR								equ 1025
IDC_EDTBTNSIZE							equ 1032
IDC_UDN1								equ 1033
;#########################################################################

.data

szAppTitle				db 'Toolbar Creator - ',0
RichEditDLL				db 'riched20.dll',0
szFont					db 'Courier New',0
BMPFilterString     	db 'Bitmap (*.bmp)',0,'*.bmp',0,0
DefBmpExt				db 'bmp',0
MNUFilterString     	db 'Menu (*.mnu)',0,'*.mnu',0,0
DefMnuExt				db 'mnu',0
TBRFilterString     	db 'Toolbar (*.tbr)',0,'*.tbr',0,0
DefTbrExt				db 'tbr',0
szUntitled				db '(Untitled)',0
szToolBar				db 'ToolbarWindow32',0
szID					db 'IDC_TBB',0
szSep					db '-',0
szNULL					db 0
szBS					db '\',0
iniTbr					db 'Tbr',0
iniBmp					db 'Bmp',0
iniMnu					db 'Mnu',0
iniSize					db 'Size',0

szIDB					db 'IDB_STD_SMALL_COLOR',0
szHINSTC				db 'HINST_COMMCTRL',0
szHINST					db 'hInst',0
szCONST					db '.const',0Dh,0Ah,0Dh,0Ah,0
szCODE					db '.code',0Dh,0Ah,0Dh,0Ah,0
szEQU					db 'equ ',0
szCRLF					db 0Dh,0Ah,0
szTBRBTNS				db 'tbrbtns',9,9,9,9,9,9,9,0
szTBBUTTON				db 'TBBUTTON <',0
szTBSTE					db 'TBSTATE_ENABLED',0
szTBSTS					db 'TBSTYLE_SEP',0
szTBSTB					db 'TBSTYLE_BUTTON',0
szTBSTC					db ' or TBSTYLE_CHECK',0
szTBSTG					db ' or TBSTYLE_GROUP',0

szTBSTF					db ' or TBSTYLE_FLAT',0
szTBSTW					db ' or TBSTYLE_WRAPABLE',0
szTBSTND				db ' or CCS_NODIVIDER',0
szTBSTT					db ' or TBSTYLE_TOOLTIPS',0
szTBSTL					db ' or TBSTYLE_LIST',0
szNBTNS					db 'ntbrbtns',0

szDATA					db '.data',0Dh,0Ah
						db 0Dh,0Ah
						db "szToolBarClass					db 'ToolbarWindow32',0",0Dh,0Ah,0Dh,0Ah,0

szDOTBRC1				db 'DoToolBar proc hInst:DWORD,hOwner:HWND',0Dh,0Ah
						db '	LOCAL	tbab:TBADDBITMAP',0Dh,0Ah
						db '	LOCAL	hToolBar:HWND',0Dh,0Ah
						db 0Dh,0Ah
						db '	;Create the toolbar',0Dh,0Ah
						db '	invoke CreateWindowEx,0,addr szToolBarClass,0,WS_CHILD or WS_VISIBLE',0
szDOTBRC2				db ',0,0,0,0,hOwner,',0
szDOTBRC3				db ',hInst,0',0Dh,0Ah
						db '	mov		hToolBar,eax',0Dh,0Ah,0

szDOTBRNC1				db 'DoToolBar proc hInst:DWORD,hToolBar:HWND',0Dh,0Ah
						db '	LOCAL	tbab:TBADDBITMAP',0Dh,0Ah
						db 0Dh,0Ah,0

szDOTBR1				db '	;Set toolbar struct size',0Dh,0Ah
						db '	invoke SendMessage,hToolBar,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0',0Dh,0Ah
						db '	;Set toolbar bitmap',0Dh,0Ah
						db '	push	',0
szSBM					db 0Dh,0Ah
						db '	pop		tbab.hInst',0Dh,0Ah
						db '	mov		tbab.nID,',0
szDOTBR2				db 0Dh,0Ah
						db '	invoke SendMessage,hToolBar,TB_ADDBITMAP,',0
szDOTBR3				db ',addr tbab',0Dh,0Ah
						db '	;Set toolbar buttons',0Dh,0Ah
						db '	invoke SendMessage,hToolBar,TB_ADDBUTTONS,ntbrbtns,addr tbrbtns',0Dh,0Ah
						db '	mov		eax,hToolBar',0Dh,0Ah
						db '	ret',0Dh,0Ah
						db 0Dh,0Ah
						db 'DoToolBar endp',0Dh,0Ah,0

szFBDATA				db 'CONST szToolBarClass="ToolbarWindow32"',0Dh,0Ah,0Dh,0Ah,0

szFBDEFINE				db '#define ',0
szFBTBRBTNS				db '	dim tbrbtn',0
szFBTBBUTTON			db ' as TBBUTTON=(',0

szFBDOTBRC1				db 'function DoToolBar(ByVal hInst as HINSTANCE,ByVal hOwner as HWND) as HWND',0Dh,0Ah
						db '	dim tbab as TBADDBITMAP',0Dh,0Ah
						db '	dim hToolBar as HWND',0Dh,0Ah,0
szFBDOTBRC2				db "	'Create the toolbar",0Dh,0Ah
						db '	hToolBar=CreateWindowEx(0,@szToolBarClass,0,WS_CHILD or WS_VISIBLE',0
szFBDOTBRC3				db ',hInst,0)',0Dh,0Ah,0

szFBDOTBRNC1			db 'function DoToolBar(ByVal hInst as HINSTANCE,ByVal hToolBar as HWND) as HWND',0Dh,0Ah
						db '	dim tbab as TBADDBITMAP',0Dh,0Ah,0


szFBDOTBR1				db "	'Set toolbar struct size",0Dh,0Ah
						db '	SendMessage(hToolBar,TB_BUTTONSTRUCTSIZE,sizeof(TBBUTTON),0)',0Dh,0Ah
						db "	'Set toolbar bitmap",0Dh,0Ah
						db '	tbab.hInst=',0
szFBSBM					db 0Dh,0Ah
						db '	tbab.nID=',0
szFBDOTBR2				db 0Dh,0Ah
						db '	SendMessage(hToolBar,TB_ADDBITMAP,',0
szFBDOTBR3				db ',@tbab)',0Dh,0Ah
						db "	'Set toolbar buttons",0Dh,0Ah
						db '	SendMessage(hToolBar,TB_ADDBUTTONS,',0
szFBDOTBR4				db ',@tbrbtn1)',0Dh,0Ah
						db '	return hToolBar',0Dh,0Ah
						db 0Dh,0Ah
						db 'end function',0Dh,0Ah,0

;#########################################################################

.data?

hInstance				dd ?
CommandLine				dd ?
hRichEdDLL				dd ?
FileName				db MAX_PATH dup (?)
hWnd					dd ?
hBmp					dd ?
hBmpInst				dd ?
hStc					dd ?
hTbr					dd ?
hMTbr					dd ?
hLBMTbr					dd ?
ProjectPath				db MAX_PATH dup (?)

OldStcProc				dd ?
hFont					dd ?
nBtns					dd ?

;#########################################################################
