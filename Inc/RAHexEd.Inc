;RAHexEd, Hex edit control

HEM_BASE				equ WM_USER+1000

;Private messages
HEM_SETFONT				equ HEM_BASE+1		;wParam=nLineSpacing, lParam=lpHEFONT
HEM_GETFONT				equ HEM_BASE+2		;wParam=0, lParam=lpHEFONT
HEM_SETCOLOR			equ HEM_BASE+3		;wParam=0, lParam=lpHECOLOR
HEM_GETCOLOR			equ HEM_BASE+4		;wParam=0, lParam=lpHECOLOR
HEM_VCENTER				equ HEM_BASE+5		;wParam=0, lParam=0
HEM_REPAINT				equ HEM_BASE+6		;wParam=0, lParam=0
HEM_ANYBOOKMARKS		equ HEM_BASE+7		;wParam=0, lParam=0
HEM_TOGGLEBOOKMARK		equ HEM_BASE+8		;wParam=nLine, lParam=0
HEM_CLEARBOOKMARKS		equ HEM_BASE+9		;wParam=0, lParam=0
HEM_NEXTBOOKMARK		equ HEM_BASE+10		;wParam=0, lParam=0
HEM_PREVIOUSBOOKMARK	equ HEM_BASE+11		;wParam=0, lParam=0
HEM_SELBARWIDTH			equ HEM_BASE+12		;wParam=nWidth, lParam=0
HEM_LINENUMBERWIDTH		equ HEM_BASE+13		;wParam=nWidth, lParam=0
HEM_SETSPLIT			equ HEM_BASE+14		;wParam=nSplit, lParam=0
HEM_GETSPLIT			equ HEM_BASE+15		;wParam=0, lParam=0
HEM_GETBYTE				equ HEM_BASE+16		;wParam=cp, lParam=0

FR_HEX					equ 2

HES_NOSPLITT			equ 001h			;No splitt button
HES_NOLINENUMBER		equ 002h			;No linenumber button
HES_NOHSCROLL			equ 004h			;No horizontal scrollbar
HES_NOVSCROLL			equ 008h			;No vertical scrollbar
HES_NOSIZEGRIP			equ 010h			;No size grip
HES_NOSTATE				equ 020h			;No state indicator
HES_NOADDRESS			equ 040h			;No adress field
HES_NOASCII				equ 080h			;No ascii field
HES_NOUPPERCASE			equ 100h			;Hex numbers is lowercase letters
HES_READONLY			equ 200h			;Text is locked

HEFONT struct
	hFont		dd ?		;Code edit normal
	hLnrFont	dd ?		;Line numbers
HEFONT ends

HECOLOR struct
	bckcol		dd ?		;Back color
	adrtxtcol	dd ?		;Text color
	dtatxtcol	dd ?		;Text color
	asctxtcol	dd ?		;Text color
	selbckcol	dd ?		;Sel back color
	sellfbckcol	dd ?		;Sel lost focus back color
	seltxtcol	dd ?		;Sel text color
	selbarbck	dd ?		;Selection bar
	selbarpen	dd ?		;Selection bar pen
	lnrcol		dd ?		;Line numbers color
HECOLOR ends

HESELCHANGE struct
	nmhdr		NMHDR <?>
	chrg		CHARRANGE <?>
	seltyp		dw ?		;SEL_TEXT or SEL_OBJECT
	line		dd ?		;Line number
	nlines		dd ?		;Total number of lines
	fchanged	dd ?		;TRUE if changed since last
HESELCHANGE ends

HEBRUSH struct
	hBrBck			dd ?		;Back color brush
	hBrSelBck		dd ?		;Selected focus back color brush
	hBrLfSelBck		dd ?		;Selected lost focus back color brush
	hBrAscSelBck	dd ?		;Selected lost focus back color brush
	hBrSelBar		dd ?		;Selection bar
	hPenSelbar		dd ?		;Selection bar pen
HEBRUSH ends

HEFONTINFO struct
	fntwt			dd ?		;Font width
	fntht			dd ?		;Font height
	linespace		dd ?		;Extra line spacing
HEFONTINFO ends

HEEDT struct
	hwnd			dd ?		;Handle of edit a or b
	hvscroll		dd ?		;Handle of scroll bar
	nline			dd ?		;Scroll position
	rc				RECT <?>	;Edit a or b rect
HEEDT ends

HEEDIT struct
	hwnd			dd ?		;Handle of main window
	fstyle			dd ?		;Window style
	ID				dd ?		;Window ID
	hpar			dd ?		;Handle of parent window
	edta			HEEDT <>
	edtb			HEEDT <>
	hhscroll		dd ?		;Handle of horizontal scrollbar
	hgrip			dd ?		;Handle of sizegrip
	hnogrip			dd ?		;Handle of nosizegrip
	hsbtn			dd ?		;Handle of splitt button
	hlin			dd ?		;Handle of linenumber button
	hsta			dd ?		;Handle of state window
	htt				dd ?		;Handle of tooltip
	fresize			dd ?		;Resize in action flag
	fsplitt			dd ?		;Splitt factor
	nsplitt			dd ?		;Splitt height

	hmem			dd ?
	nbytes			dd ?
	nsize			dd ?

	hundo			dd ?
	rpundo			dd ?
	cbundo			dd ?

	rc				RECT <?>	;Main rect
	selbarwt		dd ?		;Width of selection bar
	nlinenrwt		dd ?		;Initial width of linenumber bar
	linenrwt		dd ?		;Width of linenumber bar
	cpMin			dd ?		;Selection min
	cpMax			dd ?		;Selection max
	fOvr			dd ?		;Insert / Overwrite
	cpx				dd ?		;Scroll position
	focus			dd ?		;Handle of edit having focus
	fCaretHide		dd ?		;Caret is hidden
	fChanged		dd ?		;Content changed
	fHideSel		dd ?		;Hide selection
	clr				HECOLOR <?>
	br				HEBRUSH <?>
	fnt				HEFONT <?>
	fntinfo			HEFONTINFO <?>
	lpBmCB			dd ?		;Bookmark paint callback
	nchange			dd ?		;Used by EN_SELCHANGE
	nlastchange		dd ?		;Used by EN_SELCHANGE
	addrxp			dd ?
	addrwt			dd ?
	dataxp			dd ?
	datawt			dd ?
	asciixp			dd ?
	asciiwt			dd ?
HEEDIT ends

