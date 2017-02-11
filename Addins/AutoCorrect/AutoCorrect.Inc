;				invoke wsprintf,offset buf,offset fmat,eax
;				invoke MessageBox,0,offset buf,0,MB_OK

;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
	include Comctl32.inc
;	include shell32.inc
;	include ComDlg32.inc
	include Gdi32.inc
	include Stdlib.Inc
	include masm32.inc				; InString()
	
	include \RadASM\Masm\Inc\RAEdit.inc
;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
	includelib Comctl32.lib
;	includelib shell32.lib
;	includelib ComDlg32.lib
	includelib Gdi32.lib
	includelib Stdlib.lib
	includelib masm32.lib

;#########################################################################
;		RadASM Add In Include

	include \RadASM\Masm\Inc\radasm.inc

;#########################################################################
;		VKim's Debug

	include \RadASM\masm\inc\debug.inc
	includelib \RadASM\masm\lib\debug.lib

	DBGWIN_DEBUG_ON = 1		; include debug info into the program
	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################
;		Prototypes

	DLLProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL				PROTO :DWORD, :DWORD
	
	TextOutput				PROTO :DWORD
	clrOutput				PROTO 
	HexOutput				PROTO :DWORD

	AddMenu                 	PROTO
	AutoCorrectDlg          	PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	DealWithBeforeSpace     	PROTO	:DWORD
	InsertColumn            	PROTO
	LoadListFromFile        	PROTO	:DWORD
	RAEditProc              	PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	SaveProcedure           	PROTO
	LoadStringsToMem		PROTO	:DWORD,:DWORD
	MultilineDlg			PROTO	:HWND,:UINT,:WPARAM,:LPARAM


;#########################################################################
;		Macros


;#########################################################################

BLOCKRANGE struct
	lnMin		dd ?			;Starting line
	clMin		dd ?			;Starting column
	lnMax		dd ?			;Ending line
	clMax		dd ?			;Ending column
BLOCKRANGE ends

RABRUSH struct
	hBrBck		dd ?			;Back color brush
	hBrSelBck	dd ?			;Sel back color brush
	hBrHilite1	dd ?			;Line hilite 1
	hBrHilite2	dd ?			;Line hilite 2
	hBrHilite3	dd ?			;Line hilite 3
	hBrSelBar	dd ?			;Selection bar
	hPenSelbar	dd ?			;Selection bar pen
RABRUSH ends

RAFONT struct
	hFont		dd ?			;Code edit normal
	hIFont		dd ?			;Code edit italics
	hLnrFont	dd ?			;Line numbers
RAFONT ends

RACOLOR struct
	bckcol		dd ?			;Back color
	txtcol		dd ?			;Text color
	selbckcol	dd ?			;Sel back color
	seltxtcol	dd ?			;Sel text color
	cmntcol		dd ?			;Comment color
	strcol		dd ?			;String color
	oprcol		dd ?			;Operator color
	hicol1		dd ?			;Line hilite 1
	hicol2		dd ?			;Line hilite 2
	hicol3		dd ?			;Line hilite 3
	selbarbck	dd ?			;Selection bar
	selbarpen	dd ?			;Selection bar pen
	lnrcol		dd ?			;Line numbers color
	numcol		dd ?			;Numbers & hex color
RACOLOR ends

RAFONTINFO struct
	charset		dd ?			;Character set
	fDBCS		dd ?			;Use double byte characters
	fntwt		dd ?			;Font width
	fntht		dd ?			;Font height
	spcwt		dd ?			;Space width
	tabwt		dd ?			;Tab width
	italic		dd ?			;Height shift
	monospace	dd ?			;Font is monospaced
	linespace	dd ?			;Extra line spacing
RAFONTINFO ends

RAEDT struct
	hwnd		dd ?			;Handle of edit a or b
	hvscroll	dd ?			;Handle of scroll bar
	cpxmax		dd ?			;Last cursor pos x
	cpy			dd ?			;Scroll position
	cp			dd ?			;Character position
	rc			RECT <?>		;Edit a or b rect
	topyp		dd ?			;First visible lines Y position
	topln		dd ?			;First visible lines linenumber
	topcp		dd ?			;First visible lines character position
RAEDT ends

EDIT struct
	hwnd		dd ?			;Handle of main window
	fstyle		dd ?			;Window style
	ID			dd ?			;Window ID
	hpar		dd ?			;Handle of parent window
	edta		RAEDT <>
	edtb		RAEDT <>
	hhscroll	dd ?			;Handle of horizontal scrollbar
	hgrip		dd ?			;Handle of sizegrip
	hnogrip		dd ?			;Handle of nosizegrip
	hsbtn		dd ?			;Handle of splitt button
	hlin		dd ?			;Handle of linenumber button
	hexp		dd ?			;Handle of expand button
	hcol		dd ?			;Handle of collapse button
	hsta		dd ?			;Handle of state window
	htt			dd ?			;Handle of tooltip
	fresize		dd ?			;Resize in action flag
	fsplitt		dd ?			;Splitt factor
	nsplitt		dd ?			;Splitt height

	hHeap		dd 3 dup(?)		;Handle of heap
	hLine		dd ?			;Handle of line pointer mem
	cbLine		dd ?			;Size of line pointer mem
	rpLine		dd ?			;Relative pointer into line pointer mem
	rpLineFree	dd ?			;Pointer to free line pointer
	hChars		dd ?			;Handle of character mem
	cbChars		dd ?			;Size of character mem
	rpChars		dd ?			;Relative pointer into character mem
	rpCharsFree	dd ?			;Relative pointer to free character
	hUndo		dd ?			;Handle of undo memory
	cbUndo		dd ?			;Size of undo memory
	rpUndo		dd ?			;Relative pointer to free (last)
	line		dd ?			;Linenumber
	cpLine		dd ?			;Character position for start of line

	rc			RECT <?>		;Main rect
	selbarwt	dd ?			;Width of selection bar
	nlinenrwt	dd ?			;Initial width of linenumber bar
	linenrwt	dd ?			;Width of linenumber bar
	nScroll		dd ?			;Mouse wheel scroll lines
	nPageBreak	dd ?			;Page break
	cpMin		dd ?			;Selection min
	cpMax		dd ?			;Selection max
	fOvr		dd ?			;Insert / Overwrite
	nHidden		dd ?			;Number of hidden lines
	cpx			dd ?			;Scroll position
	focus		dd ?			;Handle of edit having focus
	fCaretHide	dd ?			;Caret is hidden
	fChanged	dd ?			;Content changed
	fHideSel	dd ?			;Hide selection
	fIndent		dd ?			;Auto indent
	clr			RACOLOR <?>
	br			RABRUSH <?>
	nTab		dd ?			;Tab size
	fnt			RAFONT <?>
	fntinfo		RAFONTINFO <?>
	lpBmCB		dd ?			;Bookmark paint callback
	nchange		dd ?			;Used by EN_SELCHANGE
	nlastchange	dd ?			;Used by EN_SELCHANGE
	nWordGroup	dd ?			;Hilite word group
	fExpandTab	dd ?			;TRUE/FALSE Epand tabs to spaces
	savesel		CHARRANGE <?>
	htlt		dd ?			;Scroll tooltip
	nMode		dd ?			;Block selection
	blrg		BLOCKRANGE <?>
	lockundoid	dd ?
	ccmntblocks	dd ?
EDIT ends



.const

ID_EDIT 						= 65501
MAX_STRING 						= 500
DIVSIGN 						= 255		; isim 01 description 01 yol+isim 01 gibi ayraç(.dat)

DLG_CORRECT						equ 1000
GRP_1							equ 1006
EDT_OLD							equ 1001
EDT_NEW							equ 1002
STC_1							equ 1003
STC_2							equ 1004
BTN_CHANGE						equ 1007
BTN_DELETE						equ 1008
BTN_OK							equ 1009
BTN_CANCEL						equ 1010
LSV_LIST						equ 1005
BTN_MULTI						equ 1011

DLG_MULT						equ 2000
EDT_MULTI						equ 2001
BTN_MULTOK						equ 2002
BTN_MULTCAN						equ 2003

.data

;fmat		db "string:%s_",0
;fmat		db "eax:%d",0
;fmat		db "sztmpMulti:%s, sztmpMulti_length:%d, countSPTB:%d",0
;fmat		db "AL=%c",0
;fmat		db "%d and %d",0

OldListWndProc        dd 0

bMult			dd 0					; if caret in first line 0
szMenuString 	db "Auto Correct List",0
BackSlash		db "\",0
DataFileName 	db "AutoCorrect.dat",0
emptystring  	db 0
divstring 		db 0FFh,0
ismulti			dd 0
listIndex 		dd 0
szTilde			db '~',0
cpos			dd 0
countSPTB		dd 0						; length of szSpacesnTabs
szCRLF			db 13,10,0
text 			db MAX_STRING dup(0)
sztmpMulti		db MAX_STRING dup(0)		; for indent

lvi 	LV_ITEM <LVIF_TEXT,0,0,LVIS_FOCUSED,0,offset text,MAX_STRING,0,0>
lvc 	LV_COLUMN <>
lvnmhdr	NMHDR <hList>

.data?

hInstance		dd ?	;Dll's module handle
lpHandles		dd ?	;Pointer to handles struct
lpProc			dd ?	;Pointer to proc struct
lpData			dd ?	;Pointer to data struct
hOut			dd ?	;Handle of output window
IDAddIn			dd ?	;Unique ID for this AddIn

startofw		dd ?
pszOlds			dd ?
pszNews			dd ?
pszMulti		dd ?

g_hDlgAuto		dd ?		
hFile			dd ?	; .dat
fileSize		dd ?
pMemory			dd ?
SizeRW 			dd ?	; writefile için
recure 			dd ?	; column sign
indice			dd ?
tmpIndice		dd ?
AddrTableOld	dd 100 dup(?)		; 100 items in listv.
AddrTableNew	dd 100 dup(?)		;  "   "    "   "
DataFullName 	db MAX_PATH  dup(?)
szSpacesnTabs	db 200 dup(?)
hList			dd ?
hEdt1			dd ?
OldEditProc1	dd ?
hEdt2			dd ?
OldEditProc2	dd ?
szLine			db 300 dup(?)
tempBuffer		db 500 dup(?)
;buf				db 300 dup(?)

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
