
;Column structure
COLUMN struct
	colwt			dd ?			;Column width.
	lpszhdrtext		dd ?			;Pointer to header text.
	halign			dd ?			;Header text alignment.
	calign			dd ?			;Column text alignment.
	ctype			dd ?			;Column data type.
	ctextmax		dd ?			;Max text lenght for TYPE_EDITTEXT and TYPE_EDITLONG.
	lpszformat		dd ?			;Format string for TYPE_EDITLONG.
	himl			dd ?			;Handle of image list. For the image columns and combobox only.
	hdrflag			dd ?			;Header flags.
	colxp			dd ?			;Column position. Internally used.
	edthwnd			dd ?			;Column control handle. Internally used.
	lParam			dd ?			;User defined 32 bit value.
COLUMN ends

ROWCOLOR struct
	backcolor		dd ?
	textcolor		dd ?
ROWCOLOR ends

;Notifications
GRIDNOTIFY struct
	nmhdr			NMHDR <?>
	col				dd ?			;Column
	row				dd ?			;Row
	hwnd			dd ?			;Handle of column edit control
	lpdata			dd ?			;Pointer to data
	fcancel			dd ?			;Set to TRUE to cancel operation
GRIDNOTIFY ends

GN_HEADERCLICK		equ 1			;User clicked header
GN_BUTTONCLICK		equ 2			;Sendt when user clicks the button in a button cell
GN_CHECKCLICK		equ 3			;Sendt when user double clicks the checkbox in a checkbox cell
GN_IMAGECLICK		equ 4			;Sendt when user double clicks the image in an image cell
GN_BEFORESELCHANGE	equ 5			;Sendt when user request a selection change
GN_AFTERSELCHANGE	equ 6			;Sendt after a selection change
GN_BEFOREEDIT		equ 7			;Sendt before the cell edit control shows
GN_AFTEREDIT		equ 8			;Sendt when the cell edit control is about to close
GN_BEFOREUPDATE		equ 9			;Sendt before a cell updates grid data
GN_AFTERUPDATE		equ 10			;Sendt after grid data has been updated
GN_USERCONVERT		equ 11			;Sendt when user cell needs to be converted.

;Messages
GM_ADDCOL			equ WM_USER+1	;wParam=0, lParam=lpCOLUMN
GM_ADDROW			equ WM_USER+2	;wParam=0, lParam=lpROWDATA (can be NULL)
GM_INSROW			equ WM_USER+3	;wParam=nRow, lParam=lpROWDATA (can be NULL)
GM_DELROW			equ WM_USER+4	;wParam=nRow, lParam=0
GM_MOVEROW			equ WM_USER+5	;wParam=nFromRow, lParam=nToRow
GM_COMBOADDSTRING	equ WM_USER+6	;wParam=nCol, lParam=lpszString
GM_COMBOCLEAR		equ WM_USER+7	;wParam=nCol, lParam=0
GM_GETCURSEL		equ WM_USER+8	;wParam=0, lParam=0
GM_SETCURSEL		equ WM_USER+9	;wParam=nCol, lParam=nRow
GM_GETCURCOL		equ WM_USER+10	;wParam=0, lParam=0
GM_SETCURCOL		equ WM_USER+11	;wParam=nCol, lParam=0
GM_GETCURROW		equ WM_USER+12	;wParam=0, lParam=0
GM_SETCURROW		equ WM_USER+13	;wParam=nRow, lParam=0
GM_GETCOLCOUNT		equ WM_USER+14	;wParam=0, lParam=0
GM_GETROWCOUNT		equ WM_USER+15	;wParam=0, lParam=0
GM_GETCELLDATA		equ WM_USER+16	;wParam=nRowCol, lParam=lpData
GM_SETCELLDATA		equ WM_USER+17	;wParam=nRowCol, lParam=lpData
GM_GETCELLRECT		equ WM_USER+18	;wParam=nRowCol, lParam=lpRECT
GM_SCROLLCELL		equ WM_USER+19	;wParam=0, lParam=0
GM_GETBACKCOLOR		equ WM_USER+20	;wParam=0, lParam=0
GM_SETBACKCOLOR		equ WM_USER+21	;wParam=nColor, lParam=0
GM_GETGRIDCOLOR		equ WM_USER+22	;wParam=0, lParam=0
GM_SETGRIDCOLOR		equ WM_USER+23	;wParam=nColor, lParam=0
GM_GETTEXTCOLOR		equ WM_USER+24	;wParam=0, lParam=0
GM_SETTEXTCOLOR		equ WM_USER+25	;wParam=nColor, lParam=0
GM_ENTEREDIT		equ WM_USER+26	;wParam=nCol, lParam=nRow
GM_ENDEDIT			equ WM_USER+27	;wParam=nRowCol, lParam=fCancel
GM_GETCOLWIDTH		equ WM_USER+28	;wParam=nCol, lParam=0
GM_SETCOLWIDTH		equ WM_USER+29	;wParam=nCol, lParam=nWidth
GM_GETHDRHEIGHT		equ WM_USER+30	;wParam=0, lParam=0
GM_SETHDRHEIGHT		equ WM_USER+31	;wParam=0, lParam=nHeight
GM_GETROWHEIGHT		equ WM_USER+32	;wParam=0, lParam=0
GM_SETROWHEIGHT		equ WM_USER+33	;wParam=0, lParam=nHeight
GM_RESETCONTENT		equ WM_USER+34	;wParam=0, lParam=0
GM_COLUMNSORT		equ WM_USER+35	;wParam=nCol, lParam=0=Ascending, 1=Descending, 2=Invert
GM_GETHDRTEXT		equ WM_USER+36	;wParam=nCol, lParam=lpBuffer
GM_SETHDRTEXT		equ WM_USER+37	;wParam=nCol, lParam=lpszText
GM_GETCOLFORMAT		equ WM_USER+38	;wParam=nCol, lParam=lpBuffer
GM_SETCOLFORMAT		equ WM_USER+39	;wParam=nCol, lParam=lpszText
GM_CELLCONVERT		equ WM_USER+40	;wParam=nRowCol, lParam=lpBuffer
GM_RESETCOLUMNS		equ WM_USER+41	;wParam=0, lParam=0
GM_GETROWCOLOR		equ WM_USER+42	;wParam=nRow, lParam=lpROWCOLOR
GM_SETROWCOLOR		equ WM_USER+43	;wParam=nRow, lParam=lpROWCOLOR
GM_GETCOLDATA		equ WM_USER+44	;wParam=nCol, lParam=lpCOLUMN

;Column alignment
ALIGN_LEFT			equ 0
ALIGN_CENTER		equ 1
ALIGN_RIGHT			equ 2

;Column types
TYPE_EDITTEXT		equ 0			;String
TYPE_EDITLONG		equ 1			;Long
TYPE_CHECKBOX		equ 2			;Long
TYPE_COMBOBOX		equ 3			;Long
TYPE_HOTKEY			equ 4			;Long
TYPE_BUTTON			equ 5			;String
TYPE_IMAGE			equ 6			;Long
TYPE_DATE			equ 7			;Long
TYPE_TIME			equ 8			;Long
TYPE_USER			equ 9			;0=String, 1 to 512 bytes binary data
TYPE_EDITBUTTON		equ 10			;String

;Column sorting
SORT_ASCENDING		equ 0
SORT_DESCENDING		equ 1
SORT_INVERT			equ 2

;Window styles
STYLE_NOSEL			equ 01h
STYLE_NOFOCUS		equ 02h
STYLE_HGRIDLINES	equ 04h
STYLE_VGRIDLINES	equ 08h
STYLE_GRIDFRAME		equ 10h

