
;#########################################################################
;		Include files

include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
;include shell32.inc
;include ComDlg32.inc
include Gdi32.inc

;#########################################################################
;		Libraries

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
;includelib shell32.lib
;includelib ComDlg32.lib
includelib Gdi32.lib

;#########################################################################
;		RadASM Add In Include

include ..\radasm.inc

;#########################################################################
;		VKim's Debug

include masm32.inc
include \RadASM\masm\inc\debug.inc
includelib masm32.lib
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

IDD_DLGSTYLEMANA	equ 1000
IDC_LSTSTYLE		equ 1001
IDC_EDTDWORD		equ 1002
IDC_BTNUPDATE		equ 1003

RSM_ADDITEM			equ WM_USER+0			;wParam=0, lParam=lpString, Returns nothing
RSM_DELITEM			equ WM_USER+1			;wParam=Index, lParam=0, Returns nothing
RSM_GETITEM			equ WM_USER+2			;wParam=Index, lParam=0, Returns pointer to string or NULL
RSM_GETCOUNT		equ WM_USER+3			;wParam=0, lParam=0, Returns count
RSM_CLEAR			equ WM_USER+4			;wParam=0, lParam=0, Returns nothing
RSM_SETCURSEL		equ WM_USER+5			;wParam=Index, lParam=0, Returns nothing
RSM_GETCURSEL		equ WM_USER+6			;wParam=0, lParam=0, Returns Index
RSM_GETTOPINDEX		equ WM_USER+7			;wParam=0, lParam=0, Returns TopIndex
RSM_SETTOPINDEX		equ WM_USER+8			;wParam=TopIndex, lParam=0, Returns nothing
RSM_GETITEMRECT		equ WM_USER+9			;wParam=Index, lParam=lpRECT, Returns nothing
RSM_SETVISIBLE		equ WM_USER+10			;wParam=0, lParam=0, Returns nothing
RSM_SETSTYLEVAL		equ WM_USER+11			;wParam=o, lParam=lpDIALOG, Returns nothing
RSM_GETSTYLEVAL		equ WM_USER+12			;wParam=0, lParam=0, Returns Style
RSM_GETCOLOR		equ WM_USER+13			;wParam=0, lParam=lpRS_COLOR, Returns nothing
RSM_SETCOLOR		equ WM_USER+14			;wParam=0, lParam=lpRS_COLOR, Returns nothing
RSM_UPDATESTYLEVAL	equ WM_USER+14			;wParam=0, lParam=lpDIALOG, Returns nothing

RASTYLE struct
	style		dd ?
	backcolor	dd ?
	textcolor	dd ?
	hfont		dd ?
	hboldfont	dd ?
	fredraw		dd ?
	itemheight	dd ?
	cursel		dd ?
	count		dd ?
	topindex	dd ?
	hmem		dd ?
	lpmem		dd ?
	cbsize		dd ?
	lpdialog	dd ?
	ntype		dd ?
	styleval	dd ?
	G1Visible	dd ?
	G2Visible	dd ?
RASTYLE ends

RS_COLOR struct
	back	dd ?
	text	dd ?
RS_COLOR ends

TYPES struct
	style1			db 8 dup(?)
	style2			db 8 dup(?)
	style3			db 8 dup(?)
TYPES ends

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
DIALOG ends

DLGC_CODE			equ DLGC_WANTCHARS or DLGC_WANTARROWS;DLGC_WANTALLKEYS

.const

iniStyle			db 'StyleMana',0
iniStyleLeft		db 'Left',0
iniStyleTop			db 'Top',0
inifmt				db '%d',0

szClassName			db 'RAStyle',0
szWindowStyles		db 'Window styles',0
szExWindowStyles	db 'Extended Window styles',0
szControlStyles		db 'Control styles',0

types				TYPES <'WS_','DS_',>			;Dialog	
					TYPES <'WS_','ES_',>			;Edit
					TYPES <'WS_','SS_',>			;Static
					TYPES <'WS_','BS_',>			;GroupBox
					TYPES <'WS_','BS_',>			;Button
					TYPES <'WS_','BS_',>			;CheckBox
					TYPES <'WS_','BS_',>			;RadioButton
					TYPES <'WS_','CBS_',>			;ComboBox
					TYPES <'WS_','LBS_',>			;ListBox
					TYPES <'WS_','SBS_',>			;H-ScrollBar
					TYPES <'WS_','SBS_',>			;V-ScrollBar
					TYPES <'WS_','TCS_',>			;Tab control
					TYPES <'WS_','PBS_',>			;Progress bar
					TYPES <'WS_','TVS_',>			;Tree view
					TYPES <'WS_','LVS_',>			;List view
					TYPES <'WS_','TBS_',>			;Track bar
					TYPES <'WS_','UDS_',>			;UpDown
					TYPES <'WS_','SS_',>			;Image
					TYPES <'WS_','TBSTYLE','CCS_'>	;ToolBar
					TYPES <'WS_','SBARS_','CCS_'>	;Status bar
					TYPES <'WS_','DTS_',>			;DateTimp picker
					TYPES <'WS_','MCS_',>			;Month view
					TYPES <'WS_','ES_',>			;Rich edit
					TYPES <'WS_',,>					;User defined
					TYPES <'WS_',,>					;ComboBoxEx
					TYPES <'WS_','SS_',>			;Shape
					TYPES <'WS_',,>					;IPAddress
					TYPES <'WS_','ACS_',>			;Animate
					TYPES <'WS_',,>					;Hotkey
					TYPES <'WS_','PGS_',>			;H-Pager
					TYPES <'WS_','PGS_',>			;V-Pager
					TYPES <'WS_','RBS_',>			;ReBar
					TYPES <'WS_','HDS_',>			;Header
					TYPES <'WS_','LWS_',>			;Syslink
					TYPES <'WS_',,>					;Custom controls
					TYPES <,,>

extypes				TYPES <'WS_',,>					;Dialog	
					TYPES <'WS_',,>					;Edit
					TYPES <'WS_',,>					;Static
					TYPES <'WS_',,>					;GroupBox
					TYPES <'WS_',,>					;Button
					TYPES <'WS_',,>					;CheckBox
					TYPES <'WS_',,>					;RadioButton
					TYPES <'WS_',,>					;ComboBox
					TYPES <'WS_',,>					;ListBox
					TYPES <'WS_',,>					;H-ScrollBar
					TYPES <'WS_',,>					;V-ScrollBar
					TYPES <'WS_',,>					;Tab control
					TYPES <'WS_',,>					;Progress bar
					TYPES <'WS_',,>					;Tree view
					TYPES <'WS_',,>					;List view
					TYPES <'WS_',,>					;Track bar
					TYPES <'WS_',,>					;UpDown
					TYPES <'WS_',,>					;Image
					TYPES <'WS_',,>					;ToolBar
					TYPES <'WS_',,>					;Status bar
					TYPES <'WS_',,>					;DateTimp picker
					TYPES <'WS_',,>					;Month view
					TYPES <'WS_',,>					;Rich edit
					TYPES <'WS_',,>					;User defined
					TYPES <'WS_',,>					;ComboBoxEx
					TYPES <'WS_',,>					;Shape
					TYPES <'WS_',,>					;IPAddress
					TYPES <'WS_',,>					;Animate
					TYPES <'WS_',,>					;Hotkey
					TYPES <'WS_',,>					;H-Pager
					TYPES <'WS_',,>					;V-Pager
					TYPES <'WS_',,>					;ReBar
					TYPES <'WS_',,>					;Header
					TYPES <'WS_',,>					;Syslink
					TYPES <'WS_',,>					;Custom controls
					TYPES <,,>

.data?

hInstance			dd ?	;Dll's module handle
lpHandles			dd ?	;Pointer to handles struct
lpProc				dd ?	;Pointer to proc struct
lpData				dd ?	;Pointer to data struct
hOut				dd ?	;Handle of output window
hIml				dd ?
hBr					dd ?
left				dd ?
top					dd ?
fex					dd ?
lpOldHexEditProc	dd ?

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
