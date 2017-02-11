
;Default colors
DEFBCKCOLOR				equ 00C0F0F0h
DEFTXTCOLOR				equ 00000000h
DEFSELBCKCOLOR			equ 00800000h
DEFSELTXTCOLOR			equ 00FFFFFFh
DEFCMNTCOLOR			equ 02008000h
DEFSTRCOLOR				equ 00A00000h
DEFOPRCOLOR				equ 000000A0h
DEFHILITE1				equ 00F0C0C0h
DEFHILITE2				equ 00C0F0C0h
DEFHILITE3				equ 00C0C0F0h
DEFSELBARCOLOR			equ 00C0C0C0h
DEFSELBARPEN			equ 00808080h
DEFLNRCOLOR				equ 00800000h
DEFNUMCOLOR				equ 00808080h
DEFCMNTBCK				equ 00C0F0F0h
DEFSTRBCK				equ 00C0F0F0h
DEFNUMBCK				equ 00C0F0F0h
DEFOPRBCK				equ 00C0F0F0h
DEFCHANGEDCLR			equ 0000F0F0h
DEFCHANGESAVEDCLR		equ 0000F000h

;Window styles
STYLE_NOSPLITT			equ 0001h			;No splitt button
STYLE_NOLINENUMBER		equ 0002h			;No linenumber button
STYLE_NOCOLLAPSE		equ 0004h			;No expand/collapse buttons
STYLE_NOHSCROLL			equ 0008h			;No horizontal scrollbar
STYLE_NOVSCROLL			equ 0010h			;No vertical scrollbar
STYLE_NOHILITE			equ 0020h			;No color hiliting
STYLE_NOSIZEGRIP		equ 0040h			;No size grip
STYLE_NODBLCLICK		equ 0080h			;No action on double clicks
STYLE_READONLY			equ 0100h			;Text is locked
STYLE_NODIVIDERLINE		equ 0200h			;Blocks are not divided by line
STYLE_NOBACKBUFFER		equ 0400h			;Drawing directly to screen DC
STYLE_NOSTATE			equ 0800h			;No state indicator
STYLE_DRAGDROP			equ 1000h			;Drag & Drop support, app must load ole
STYLE_SCROLLTIP			equ 2000h			;Scrollbar tooltip
STYLE_HILITECOMMENT		equ 4000h			;Comments are hilited
STYLE_AUTOSIZELINENUM	equ 8000h			;Line number column autosizes

;Styles used with REM_SETSTYLEEX message
;Styles used with REM_SETSTYLEEX message
STYLEEX_LOCK			equ 0001h			;Show lock button
STYLEEX_BLOCKGUIDE		equ 0002h			;Show block guiders
STILEEX_LINECHANGED		equ 0004h			;Show line changed state

;Edit modes
MODE_NORMAL				equ 0				;Normal
MODE_BLOCK				equ 1				;Block select
MODE_OVERWRITE			equ 2				;Overwrite

;REM_COMMAND commands
CMD_LEFT				equ 1
CMD_RIGHT				equ 2
CMD_LINE_UP				equ 3
CMD_LINE_DOWN			equ 4
CMD_PAGE_UP				equ 5
CMD_PAGE_DOWN			equ 6
CMD_HOME				equ 7
CMD_END					equ 8
CMD_INSERT				equ 9
CMD_DELETE				equ 10
CMD_BACKSPACE			equ 11
;REM_COMMAND modifyers
CMD_ALT					equ 256
CMD_CTRL				equ 512
CMD_SHIFT				equ 1024

;Private edit messages
REM_RAINIT				equ WM_USER+9999	;wParam=0, lParam=pointer to controls DIALOG struct
REM_BASE				equ WM_USER+1000
REM_SETHILITEWORDS		equ REM_BASE+0		;wParam=Color, lParam=lpszWords
REM_SETFONT				equ REM_BASE+1		;wParam=nLineSpacing, lParam=lpRAFONT
REM_GETFONT				equ REM_BASE+2		;wParam=0, lParam=lpRAFONT
REM_SETCOLOR			equ REM_BASE+3		;wParam=0, lParam=lpRACOLOR
REM_GETCOLOR			equ REM_BASE+4		;wParam=0, lParam=lpRACOLOR
REM_SETHILITELINE		equ REM_BASE+5		;wParam=Line, lParam=Color
REM_GETHILITELINE		equ REM_BASE+6		;wParam=Line, lParam=0
REM_SETBOOKMARK			equ REM_BASE+7		;wParam=Line, lParam=Type
REM_GETBOOKMARK			equ REM_BASE+8		;wParam=Line, lParam=0
REM_CLRBOOKMARKS		equ REM_BASE+9		;wParam=0, lParam=Type
REM_NXTBOOKMARK			equ REM_BASE+10		;wParam=Line, lParam=Type
REM_PRVBOOKMARK			equ REM_BASE+11		;wParam=Line, lParam=Type
REM_FINDBOOKMARK		equ REM_BASE+12		;wParam=BmID, lParam=0
REM_SETBLOCKS			equ REM_BASE+13		;wParam=[lpLINERANGE], lParam=0
REM_ISLINE				equ REM_BASE+14		;wParam=Line, lParam=lpszDef
REM_GETWORD				equ REM_BASE+15		;wParam=BuffSize, lParam=lpBuff
REM_COLLAPSE			equ REM_BASE+16		;wParam=Line, lParam=0
REM_COLLAPSEALL			equ REM_BASE+17		;wParam=0, lParam=0
REM_EXPAND				equ REM_BASE+18		;wParam=Line, lParam=0
REM_EXPANDALL			equ REM_BASE+19		;wParam=0, lParam=0
REM_LOCKLINE			equ REM_BASE+20		;wParam=Line, lParam=TRUE/FALSE
REM_ISLINELOCKED		equ REM_BASE+21		;wParam=Line, lParam=0
REM_HIDELINE			equ REM_BASE+22		;wParam=Line, lParam=TRUE/FALSE
REM_ISLINEHIDDEN		equ REM_BASE+23		;wParam=Line, lParam=0
REM_AUTOINDENT			equ REM_BASE+24		;wParam=0, lParam=TRUE/FALSE
REM_TABWIDTH			equ REM_BASE+25		;wParam=nChars, lParam=TRUE/FALSE (Expand tabs)
REM_SELBARWIDTH			equ REM_BASE+26		;wParam=nWidth, lParam=0
REM_LINENUMBERWIDTH		equ REM_BASE+27		;wParam=nWidth, lParam=0
REM_MOUSEWHEEL			equ REM_BASE+28		;wParam=nLines, lParam=0
REM_SUBCLASS			equ REM_BASE+29		;wParam=0, lParam=lpWndProc
REM_SETSPLIT			equ REM_BASE+30		;wParam=nSplit, lParam=0
REM_GETSPLIT			equ REM_BASE+31		;wParam=0, lParam=0
REM_VCENTER				equ REM_BASE+32		;wParam=0, lParam=0
REM_REPAINT				equ REM_BASE+33		;wParam=0, lParam=TRUE/FALSE (Paint Now)
REM_BMCALLBACK			equ REM_BASE+34		;wParam=0, lParam=lpBmProc
REM_READONLY			equ REM_BASE+35		;wParam=0, lParam=TRUE/FALSE
REM_INVALIDATELINE		equ REM_BASE+36		;wParam=Line, lParam=0
REM_SETPAGESIZE			equ REM_BASE+37		;wParam=nLines, lParam=0
REM_GETPAGESIZE			equ REM_BASE+38		;wParam=0, lParam=0
REM_GETCHARTAB			equ REM_BASE+39		;wParam=nChar, lParam=0
REM_SETCHARTAB			equ REM_BASE+40		;wParam=nChar, lParam=nValue
REM_SETCOMMENTBLOCKS	equ REM_BASE+41		;wParam=lpStart, lParam=lpEnd
REM_SETWORDGROUP		equ REM_BASE+42		;wParam=0, lParam=nGroup (0-15)
REM_GETWORDGROUP		equ REM_BASE+43		;wParam=0, lParam=0
REM_SETBMID				equ REM_BASE+44		;wParam=nLine, lParam=nBmID
REM_GETBMID				equ REM_BASE+45		;wParam=nLine, lParam=0
REM_ISCHARPOS			equ REM_BASE+46		;wParam=CP, lParam=0, returns 1 if comment block, 2 if comment, 3 if string
REM_HIDELINES			equ REM_BASE+47		;wParam=nLine, lParam=nLines
REM_SETDIVIDERLINE		equ REM_BASE+48		;wParam=nLine, lParam=TRUE/FALSE
REM_ISINBLOCK			equ REM_BASE+49		;wParam=nLine, lParam=lpRABLOCKDEF
REM_TRIMSPACE			equ REM_BASE+50		;wParam=nLine, lParam=fLeft
REM_SAVESEL				equ REM_BASE+51		;wParam=0, lParam=0
REM_RESTORESEL			equ REM_BASE+52		;wParam=0, lParam=0
REM_GETCURSORWORD		equ REM_BASE+53		;wParam=BuffSize, lParam=lpBuff, Returns line number
REM_SETSEGMENTBLOCK		equ REM_BASE+54		;wParam=nLine, lParam=TRUE/FALSE
REM_GETMODE				equ REM_BASE+55		;wParam=0, lParam=0
REM_SETMODE				equ REM_BASE+56		;wParam=nMode, lParam=0
REM_GETBLOCK			equ REM_BASE+57		;wParam=0, lParam=lpBLOCKRANGE
REM_SETBLOCK			equ REM_BASE+58		;wParam=0, lParam=lpBLOCKRANGE
REM_BLOCKINSERT			equ REM_BASE+59		;wParam=0, lParam=lpText
REM_LOCKUNDOID			equ REM_BASE+60		;wParam=TRUE/FALSE, lParam=0
REM_ADDBLOCKDEF			equ REM_BASE+61		;wParam=0, lParam=lpRABLOCKDEF
REM_CONVERT				equ REM_BASE+62		;wParam=nType, lParam=0
REM_BRACKETMATCH		equ REM_BASE+63		;wParam=0, lParam=lpDef {[(,}]),_
REM_COMMAND				equ REM_BASE+64		;wParam=nCommand, lParam=0
REM_CASEWORD			equ REM_BASE+65		;wParam=cp, lParam=lpWord
REM_GETBLOCKEND			equ REM_BASE+66		;wParam=Line, lParam=0
REM_SETLOCK				equ REM_BASE+67		;wParam=TRUE/FALSE, lParam=0
REM_GETLOCK				equ REM_BASE+68		;wParam=0, lParam=0
REM_GETWORDFROMPOS		equ REM_BASE+69		;wParam=cp, lParam=lpBuff
REM_SETNOBLOCKLINE		equ REM_BASE+70		;wParam=Line, lParam=TRUE/FALSE
REM_ISLINENOBLOCK		equ REM_BASE+71		;wParam=Line, lParam=0
REM_SETALTHILITELINE	equ REM_BASE+72		;wParam=Line, lParam=TRUE/FALSE
REM_ISLINEALTHILITE		equ REM_BASE+73		;wParam=Line, lParam=0
REM_SETCURSORWORDTYPE	equ REM_BASE+74		;wParam=nType, lParam=0
REM_SETBREAKPOINT		equ REM_BASE+75		;wParam=nLine, lParam=TRUE/FALSE
REM_NEXTBREAKPOINT		equ REM_BASE+76		;wParam=nLine, lParam=0
REM_GETLINESTATE		equ REM_BASE+77		;wParam=nLine, lParam=0
REM_SETERROR			equ REM_BASE+78		;wParam=nLine, lParam=nErrID
REM_GETERROR			equ REM_BASE+79		;wParam=nLine, lParam=0
REM_NEXTERROR			equ REM_BASE+80		;wParam=nLine, lParam=0
REM_CHARTABINIT			equ REM_BASE+81		;wParam=0, lParam=0
REM_LINEREDTEXT			equ REM_BASE+82		;wParam=nLine, lParam=TRUE/FALSE
REM_SETSTYLEEX			equ REM_BASE+83		;wParam=nStyleEx, lParam=0
REM_GETUNICODE			equ REM_BASE+84		;wParam=0, lParam=0
REM_SETUNICODE			equ REM_BASE+85		;wParam=TRUE/FALSE, lParam=0
REM_SETCHANGEDSTATE		equ REM_BASE+86		;wParam=TRUE/FALSE, lParam=0
REM_SETTOOLTIP			equ REM_BASE+87		;wParam=n (1-6), lParam=lpText
REM_HILITEACTIVELINE	equ REM_BASE+88		;wParam=0, lParam=nColor

;Convert types
CONVERT_TABTOSPACE		equ 0
CONVERT_SPACETOTAB		equ 1
CONVERT_UPPERCASE		equ 2
CONVERT_LOWERCASE		equ 3

;Line hiliting
STATE_HILITEOFF			equ 0
STATE_HILITE1			equ 1
STATE_HILITE2			equ 2
STATE_HILITE3			equ 3
STATE_HILITEMASK		equ 3

;Bookmarks
STATE_BMOFF				equ 00h
STATE_BM1				equ 10h
STATE_BM2				equ 20h
STATE_BM3				equ 30h
STATE_BM4				equ 40h
STATE_BM5				equ 50h
STATE_BM6				equ 60h
STATE_BM7				equ 70h
STATE_BM8				equ 80h
STATE_BMMASK			equ 0F0h

;Line states
STATE_LOCKED			equ 00100h
STATE_HIDDEN			equ 00200h
STATE_COMMENT			equ 00400h
STATE_DIVIDERLINE		equ 00800h
STATE_SEGMENTBLOCK		equ 01000h
STATE_NOBLOCK			equ 02000h
STATE_ALTHILITE			equ 04000h
STATE_BREAKPOINT		equ 08000h
STATE_BLOCKSTART		equ 10000h
STATE_BLOCK				equ 20000h
STATE_BLOCKEND			equ 40000h
STATE_REDTEXT			equ 80000h
STATE_COMMENTNEST		equ 00100000h
STATE_CHANGED			equ 00200000h
STATE_CHANGESAVED		equ 00400000h
STATE_GARBAGE			equ 80000000h

;Character table types
CT_NONE					equ 0
CT_CHAR					equ 1
CT_OPER					equ 2
CT_HICHAR				equ 3
CT_CMNTCHAR				equ 4
CT_STRING				equ 5
CT_CMNTDBLCHAR			equ 6
CT_CMNTINITCHAR			equ 7

; Find
FR_IGNOREWHITESPACE		equ 8000000h

RAFONT struct
	hFont		dd ?						;Code edit normal
	hIFont		dd ?						;Code edit italics
	hLnrFont	dd ?						;Line numbers
RAFONT ends

RACOLOR struct
	bckcol		dd ?						;Back color
	txtcol		dd ?						;Text color
	selbckcol	dd ?						;Sel back color
	seltxtcol	dd ?						;Sel text color
	cmntcol		dd ?						;Comment color
	strcol		dd ?						;String color
	oprcol		dd ?						;Operator color
	hicol1		dd ?						;Line hilite 1
	hicol2		dd ?						;Line hilite 2
	hicol3		dd ?						;Line hilite 3
	selbarbck	dd ?						;Selection bar
	selbarpen	dd ?						;Selection bar pen
	lnrcol		dd ?						;Line numbers color
	numcol		dd ?						;Numbers & hex color
	cmntback	dd ?						;Comment back color
	strback		dd ?						;String back color
	numback		dd ?						;Numbers & hex back color
	oprback		dd ?						;Operator back color
	changed		dd ?						;Line changed indicator
	changesaved	dd ?						;Line saved chane indicator
RACOLOR ends

RASELCHANGE struct
	nmhdr		NMHDR <?>
	chrg		CHARRANGE <?>				;Current selection
	seltyp		dw ?						;SEL_TEXT or SEL_OBJECT
	line		dd ?						;Line number
	cpLine		dd ?						;Character position of first character
	lpLine		dd ?						;Pointer to line
	nlines		dd ?						;Total number of lines
	nhidden		dd ?						;Total number of hidden lines
	fchanged	dd ?						;TRUE if changed since last
	npage		dd ?						;Page number
	nWordGroup	dd ?						;Hilite word group(0-15)
RASELCHANGE ends

BD_NONESTING			equ 01h				;Set to true for non nested blocks
BD_DIVIDERLINE			equ 02h				;Draws a divider line
BD_INCLUDELAST			equ 04h				;lpszEnd line is also collapsed
BD_LOOKAHEAD			equ 08h				;Look 500 lines ahead for the ending
BD_SEGMENTBLOCK			equ 10h				;Segment block, collapse till next segmentblock
BD_COMMENTBLOCK			equ 20h				;Comment block
BD_NOBLOCK				equ 40h				;
BD_ALTHILITE			equ 80h				;Adds 1 to the current word group for syntax coloring.

RABLOCKDEF struct
	lpszStart	dd ?						;Block start
	lpszEnd		dd ?						;Block end
	lpszNot1	dd ?						;Dont hide line containing this or set to NULL
	lpszNot2	dd ?						;Dont hide line containing this or set to NULL
	flag		dd ?						;High word is WordGroup(0-15)
RABLOCKDEF ends

LINERANGE struct
	lnMin		dd ?						;Starting line
	lnMax		dd ?						;Ending line
LINERANGE ends

BLOCKRANGE struct
	lnMin		dd ?						;Starting line
	clMin		dd ?						;Starting column
	lnMax		dd ?						;Ending line
	clMax		dd ?						;Ending column
BLOCKRANGE ends

RAFONTINFO struct
	charset		dd ?		;Character set
	fDBCS		dd ?		;Use double byte characters
	fntwt		dd ?		;Font width
	fntht		dd ?		;Font height
	spcwt		dd ?		;Space width
	tabwt		dd ?		;Tab width
	italic		dd ?		;Height shift
	monospace	dd ?		;Font is monospaced
	linespace	dd ?		;Extra line spacing
RAFONTINFO ends

RABRUSH struct
	hBrBck		dd ?		;Back color brush
	hBrSelBck	dd ?		;Sel back color brush
	hBrHilite1	dd ?		;Line hilite 1
	hBrHilite2	dd ?		;Line hilite 2
	hBrHilite3	dd ?		;Line hilite 3
	hBrSelBar	dd ?		;Selection bar
	hPenSelbar	dd ?		;Selection bar pen
RABRUSH ends

RAEDT struct
	hwnd		dd ?		;Handle of edit a or b
	hvscroll	dd ?		;Handle of scroll bar
	cpxmax		dd ?		;Last cursor pos x
	cpy			dd ?		;Scroll position
	cp			dd ?		;Character position
	rc			RECT <?>	;Edit a or b rect
	topyp		dd ?		;First visible lines Y position
	topln		dd ?		;First visible lines linenumber
	topcp		dd ?		;First visible lines character position
RAEDT ends

RAEDIT struct
	hwnd		dd ?		;Handle of main window
	fstyle		dd ?		;Window style
	ID			dd ?		;Window ID
	hpar		dd ?		;Handle of parent window
	edta		RAEDT <>
	edtb		RAEDT <>
	hhscroll	dd ?		;Handle of horizontal scrollbar
	hgrip		dd ?		;Handle of sizegrip
	hnogrip		dd ?		;Handle of nosizegrip
	hsbtn		dd ?		;Handle of splitt button
	hlin		dd ?		;Handle of linenumber button
	hexp		dd ?		;Handle of expand button
	hcol		dd ?		;Handle of collapse button
	hlock		dd ?		;Handle of lock button
	hsta		dd ?		;Handle of state window
	htt			dd ?		;Handle of tooltip
	fresize		dd ?		;Resize in action flag
	fsplitt		dd ?		;Splitt factor
	nsplitt		dd ?		;Splitt height

	hHeap		dd 3 dup(?)	;Handle of heap
	hLine		dd ?		;Handle of line pointer mem
	cbLine		dd ?		;Size of line pointer mem
	rpLine		dd ?		;Relative pointer into line pointer mem
	rpLineFree	dd ?		;Pointer to free line pointer
	hChars		dd ?		;Handle of character mem
	cbChars		dd ?		;Size of character mem
	rpChars		dd ?		;Relative pointer into character mem
	rpCharsFree	dd ?		;Relative pointer to free character
	hUndo		dd ?		;Handle of undo memory
	cbUndo		dd ?		;Size of undo memory
	rpUndo		dd ?		;Relative pointer to free (last)
	line		dd ?		;Linenumber
	cpLine		dd ?		;Character position for start of line

	rc			RECT <?>	;Main rect
	selbarwt	dd ?		;Width of selection bar
	nlinenrwt	dd ?		;Initial width of linenumber bar
	linenrwt	dd ?		;Width of linenumber bar
	nScroll		dd ?		;Mouse wheel scroll lines
	nPageBreak	dd ?		;Page break
	cpMin		dd ?		;Selection min
	cpMax		dd ?		;Selection max
	fOvr		dd ?		;Insert / Overwrite
	nHidden		dd ?		;Number of hidden lines
	cpx			dd ?		;Scroll position
	focus		dd ?		;Handle of edit having focus
	fCaretHide	dd ?		;Caret is hidden
	fChanged	dd ?		;Content changed
	fHideSel	dd ?		;Hide selection
	fIndent		dd ?		;Auto indent
	clr			RACOLOR <?>
	br			RABRUSH <?>
	nTab		dd ?		;Tab size
	fnt			RAFONT <?>
	fntinfo		RAFONTINFO <?>
	lpBmCB		dd ?		;Bookmark paint callback
	nchange		dd ?		;Used by EN_SELCHANGE
	nlastchange	dd ?		;Used by EN_SELCHANGE
	nWordGroup	dd ?		;Hilite word group
	fExpandTab	dd ?		;TRUE/FALSE Epand tabs to spaces
	savesel		CHARRANGE <?>
	htlt		dd ?		;Scroll tooltip
	nMode		dd ?		;Block selection
	blrg		BLOCKRANGE <?>
	lockundoid	dd ?
	ccmntblocks	dd ?
	cpbrst		dd ?
	cpbren		dd ?
	cpselbar	dd ?
	fLock		dd ?
	nCursorWordType	dd ?
	fstyleex	dd ?
	funicode	dd ?
RAEDIT ends

.const

szRAEditClass	db 'RAEdit',0
szEditClassName	db 'RAEditChild',0

