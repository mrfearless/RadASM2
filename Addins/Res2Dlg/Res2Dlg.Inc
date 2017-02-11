;#########################################################################

	include windows.inc
	include kernel32.inc
	include user32.inc
	include Comctl32.inc
	include shell32.inc
	include gdi32.inc
	include masm32.inc
	include comdlg32.inc
	include ole32.inc
	include oleaut32.inc
	
	includelib kernel32.lib
	includelib user32.lib
	includelib Comctl32.lib
	includelib shell32.lib
	includelib gdi32.lib
	includelib masm32.lib
	includelib comdlg32.lib
	includelib ole32.lib
	includelib oleaut32.lib
	
	include \RadASM\masm\inc\RadASM.inc

;#########################################################################

	DlgProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	SetUpListView			PROTO
	GetResources			PROTO
	LVAddItem				PROTO	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
	SaveDlgResource			PROTO	:DWORD,:DWORD,:DWORD
	FindClassIndex			PROTO	:DWORD
	ExtractDialogFromMemory	PROTO	:DWORD,:DWORD
	ReadDlgXHeader			PROTO	:DWORD
	ReadDlgNHeader			PROTO	:DWORD
	SnapToGrid				PROTO
	OpenFileForWrite		PROTO	:DWORD,:DWORD
	AddToStringTable		PROTO	:DWORD,:DWORD
	GetStringTableCnt		PROTO
	SaveBitmap				PROTO	:DWORD,:DWORD,:DWORD
	SaveBmpResource			PROTO	:DWORD,:DWORD
	ShowBmpPreview			PROTO	:DWORD,:DWORD,:DWORD,:DWORD
	ResPreviewSubProc		PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	BuildDlgFile			PROTO	:DWORD
	GetSystemSizes			PROTO
	EnumChildProc			PROTO	:HWND,:LPARAM
	ResetScrollBar			PROTO
	CreateMemDialog			PROTO	:DWORD,:DWORD
	ShowDlgPreview			PROTO	:DWORD,:DWORD,:DWORD
	LoadResourceImage		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
	LoadResourceIcon		PROTO	:DWORD,:DWORD,:DWORD
	ShowIconPreview			PROTO	:DWORD,:DWORD,:DWORD
	SaveIconResource		PROTO	:DWORD,:DWORD
	SaveDataResource		PROTO	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
	SaveStringResource		PROTO	:DWORD,:DWORD
	ShowTextPreview			PROTO	:DWORD
	PECheckCompress			PROTO	:DWORD
	MapFile					PROTO	:DWORD
	SaveCursorResource		PROTO	:DWORD,:DWORD,:DWORD
	ShowCursorPreview		PROTO	:DWORD,:DWORD,:DWORD
	cpystr					PROTO	:DWORD,:DWORD
	GetNextIniEntry			PROTO	:DWORD
	SaveAniResource			PROTO	:DWORD,:DWORD,:DWORD
	ShowImgPreview			PROTO	:DWORD,:DWORD,:DWORD
	GetIconSize				PROTO	:DWORD,:DWORD
	GetCursorSize			PROTO	:DWORD,:DWORD
	ShowDefaultPreview		PROTO	:DWORD,:DWORD,:DWORD,:DWORD



;;#########################################################################
;
;	include \RadASM\masm\inc\debug.inc
;	includelib \RadASM\masm\lib\debug.lib
;
;	DBGWIN_DEBUG_ON = 1 ; include debug info into the program
;	DBGWIN_EXT_INFO = 0 ; include extra debug info into the program


GRPICONDIR Struct
	idReserved		WORD	?;	Reserved (must be 0)
	idType			WORD	?;	Resource type (1 for icons)
	idCount			WORD	?;	How many images?
;   GRPICONDIRENTRY   idEntries[1]; // The entries for each image
GRPICONDIR ends

GRPICONDIRENTRY struct
	bWidth			BYTE	?;	Width, in pixels, of the image
	bHeight			BYTE	?;	Height, in pixels, of the image
	bColorCount		BYTE	?;	Number of colors in image (0 if >=8bpp)
	bReserved		BYTE	?;	Reserved
	wPlanes			WORD	?;	Color Planes
	wBitCount		WORD	?;	Bits per pixel
	dwBytesInRes	DWORD	?;	how many bytes in this resource?
	nID				WORD	?;	the ID
GRPICONDIRENTRY ends

ICONDIR struct
	idReserved		WORD	?;	// Reserved (must be 0)
	idType			WORD	?;	// Resource Type (1 for icons)
	idCount			WORD	?;	// How many images?
;    ICONDIRENTRY   idEntries[1]; // An entry for each image (idCount of 'em)
ICONDIR ENDS

ICONDIRENTRY struct
	bWidth			BYTE	?;	// Width, in pixels, of the image
	bHeight			BYTE	?;	// Height, in pixels, of the image
	bColorCount		BYTE	?;	// Number of colors in image (0 if >=8bpp)
	bReserved		BYTE	?;	// Reserved ( must be 0)
	wPlanes			WORD	?;	// Color Planes
	wBitCount		WORD	?;	// Bits per pixel
	dwBytesInRes	DWORD	?;	// How many bytes in this resource?
	dwImageOffset	DWORD	?;	// Where in the file is this image?
ICONDIRENTRY ENDS

CURSORDIRENTRY struct
	wWidth			WORD	?
	wHeight			WORD	?
	wPlanes			WORD	?
	wBitCount		WORD	?
	dwBytesInRes	DWORD	?
	nID				WORD	?
CURSORDIRENTRY ends

CURSORHEADER struct
	idReserved		WORD	?;	Reserved (must be 0)
	idType			WORD	?;	Resource type (1 for icons)
	idCount			WORD	?;	How many images?
	bWidth			BYTE	?;	Width, in pixels, of the image
	bHeight			BYTE	?;	Height, in pixels, of the image
	wPlanes			WORD	?
	HotSpot			POINTS	<?>
	dwBytesInRes	DWORD	?
CURSORHEADER ends

ResHdr Struct
	DVersion		DWORD		?
	Discard			WORD		?
	Language		WORD		?
	Version			DWORD		?
	User			DWORD		?
ResHdr ends

DLGTEMPLATEEX Struct
	dlgVer					WORD		?
	signature				WORD		?
	helpID					DWORD		?
	exStyle					DWORD		?
	style					DWORD		?
	cDlgItems				WORD		?
	x						WORD		?
	y						WORD		?
	lx						WORD		?
	ly						WORD		?
; ####################################################
; The following are adapted for use
; They will point to null terminated Unicode Strings
	pmenu					DWORD		?	; Name
	pmenuord				DWORD		?	; Ordinal
	pwindowClass			DWORD		?	; Name
	pwindowClassord			DWORD		?	; Ordinal
	ptitle					DWORD		?	; Name
; ####################################################
	pointsize				WORD		?
	weight					WORD		?
	bItalic					WORD		?
; ####################################################
; The following is adapted for use
; It will point to null terminated Unicode String
	pfont					DWORD		?	; Font Name
; ####################################################
DLGTEMPLATEEX ends

SYSMETRIC Struct
	CXEDGE					DWORD		?
	CYEDGE					DWORD		?
	CXSIZEFRAME				DWORD		?
	CYSIZEFRAME				DWORD		?
	CYCAPTION				DWORD		?
	CYSMCAPTION				DWORD		?
SYSMETRIC ends

DLGTEMPLATEEX_FONT Struct
	pointsize				WORD		?
	weight					WORD		?
	bItalic					WORD		?
;; ####################################################
; The following is adapted for use
; It will point to null terminated Unicode String
	pfont					DWORD		?	; Font Name
; ####################################################
DLGTEMPLATEEX_FONT ends

DLGITEMTEMPLATEEX Struct
	helpID			DWORD		?
	exStyle			DWORD		?
	style			DWORD		?
	x				WORD		?
	y				WORD		?
	lx				WORD		?
	ly				WORD		?
	id				WORD		?
	pwindowClassOrd DWORD		?
	pwindowClass	DWORD		?	; text pointer or ordinal
	ptitle			DWORD		?	; text pointer or ordinal
	extracount		WORD		?
DLGITEMTEMPLATEEX ends

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
	spare1			dd ?				;Set to NULL
DLGHEAD ends

MaxCap				equ 241

DIALOG struct
	hwnd			dd ?				;Set to TRUE
	partype			dd ?				;Dialog=1, Controls=0
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

ADDINOPT struct
	lpStr	dd ?	;Pointer to CheckBox text
	nAnd	dd ?	;Option AND value
	nOr		dd ?	;Option OR value
ADDINOPT ends

MNUHEAD struct
 menuname	db 32 dup(?)
 menuid		dd ?
 startid		dd ?
MNUHEAD ends

MNUITEM struct
 itemflag		dd ?
 itemname	db 32 dup(?)
 itemid		dd ?
 itemcaption	db 64 dup(?)
 level		dd ?
 checked		dd ?
 grayed		dd ?
 shortcut		dd ?
MNUITEM ends

.const
	IDD_DIALOG1				equ					500
	RT_MANIFEST				equ					24
	RT_MESSAGETABLE			equ					11
	RT_LVIMAGE				equ					2110

;	RT_DLGINCLUDE			equ					17
	LOCALE_SYSTEM_DEFAULT	equ					2048

	MaxClass				equ					64
	MaxFont					equ					64
	MaxMenu					equ					64
	
	dlgButton				equ					00080h
	dlgEdit					equ					00081h
	dlgStatic				equ					00082h
	dlgListbox				equ					00083h
	dlgScrollbar			equ					00084h
	dlgCombobox				equ					00085h
	
	ICO_DIALOG				equ					0
	ICO_BITMAP				equ					1
	ICO_ACCEL				equ					2
	ICO_ICON				equ					3
	ICO_TOOL				equ					4
	ICO_ANI					equ					5
	ICO_MENU				equ					6
	ICO_TEXT				equ					7
	ICO_CURSOR				equ					8
	ICO_FONT				equ					9
	ICO_BINARY				equ					10
	ICO_IMAGE				equ					11
	ICO_MANIFEST			equ					12
	ICO_SOUND				equ					13

	ICO_LAST				equ					ICO_SOUND

.data
	Tahoma10				LOGFONT				<-13,0,0,0,900,FALSE,FALSE,0,0,0,0,0,0,"Tahoma">
	szOpenCaption			BYTE				"Open file",0
	szExeFilterStr			BYTE				"Executable files (*.exe,*.dll)",0,"*.exe;*.dll",0,0
	szDefExeExt				BYTE				"EXE",0
	szDefFont				BYTE				"SYSTEM",0
	DlgName					BYTE				"IDD_DLG",0

	szStringSect			BYTE				"StringTable",0
	szResourceSect			BYTE				"Resource",0

	szStringFormat			BYTE				22H,",%d,%s",22H,0
	szResFormat				BYTE				22H,",%d,%d,%s",22H,0

	szColumn0				BYTE				"Reource Name",0
	szColumn1				BYTE				"Type",0
	szColumn2				BYTE				"Size",0
	hLibForRes				DWORD				INVALID_HANDLE_VALUE
	hDisplayDialog			DWORD				INVALID_HANDLE_VALUE
	hResBmp					DWORD				INVALID_HANDLE_VALUE
	hResIcon				DWORD				INVALID_HANDLE_VALUE

	szRT_ACCELERATOR		BYTE				"RT_ACCELERATOR",0
	szRT_ANICURSOR			BYTE				"RT_ANICURSOR",0
	szRT_ANIICON			BYTE				"RT_ANIICON",0
	szRT_AVI				BYTE				"AVI",0
	szRT_BITMAP				BYTE				"RT_BITMAP",0
;	szRT_CURSOR				BYTE				"RT_CURSOR",0
	szRT_DIALOG				BYTE				"RT_DIALOG",0
	szRT_DLGINCLUDE			BYTE				"RT_DLGINCLUDE",0
	szRT_FONT				BYTE				"RT_FONT",0
	szRT_FONTDIR			BYTE				"RT_FONTDIR",0
	szRT_GROUP_CURSOR		BYTE				"RT_GROUP_CURSOR",0
	szRT_GROUP_ICON			BYTE				"RT_GROUP_ICON",0
	szRT_HTML				BYTE				"HTML",0
;	szRT_ICON				BYTE				"RT_ICON",0
	szRT_IMAGE				BYTE				"IMAGE",0
	szRT_MANIFEST			BYTE				"RT_MANIFEST",0
	szRT_MENU				BYTE				"RT_MENU",0
	szRT_MESSAGETABLE		BYTE				"RT_MESSAGETABLE",0
	szRT_PLUGPLAY			BYTE				"RT_PLUGPLAY",0
	szRT_RCDATA				BYTE				"RT_RCDATA",0
	szRT_STRING				BYTE				"RT_STRING",0
	szRT_VERSION			BYTE				"RT_VERSION",0
	szRT_VXD				BYTE				"VXD",0

	szBytes					BYTE				" Bytes",0
;	szIcons					BYTE				" Icons(s)",0

	szDLGFilterStr			BYTE				"Dialog files (*.dlg)",0,"*.dlg",0,0
	szDefDLGExt				BYTE				"DLG",0

	szIcoFilterStr			BYTE				"Icon files (*.ico)",0,"*.ico",0,0
	szDefIcoExt				BYTE				"ICO",0

	szBMPFilterStr			BYTE				"Bitmap files (*.bmp)",0,"*.bmp",0,0
	szDefBMPExt				BYTE				"BMP",0

	szAnyFilterStr			BYTE				"All files (*.*)",0,"*.*",0,0
	szDefAnyExt				BYTE				"dat",0

	szAniCurFilterStr		BYTE				"Ani Icon/Cursor files (*.ani)",0,"*.ani",0,0
	szDefAniCurExt			BYTE				"ANI",0

	szTxtFilterStr			BYTE				"Text files (*.txt)",0,"*.txt",0,0
	szTxtCurExt				BYTE				"TXT",0

	szCurFilterStr			BYTE				"Cursor files (*.cur)",0,"*.cur",0,0
	szDefCurExt				BYTE				"CUR",0
	
	szImgFilterStr			BYTE				"JPG files (*.jpg)",0,"*.jpg",0,0
	szDefImgExt				BYTE				"JPG",0
	
	szGifFilterStr			BYTE				"GIF files (*.gif)",0,"*.gif",0,0
	szDefGifExt				BYTE				"GIF",0
	
	szAviFilterStr			BYTE				"AVI files (*.avi)",0,"*.avi",0,0
	szDefAviExt				BYTE				"AVI",0

	szFntFilterStr			BYTE				"TrueType fonts (*.ttf)",0,"*.ttf",0,0
	szDefFntExt				BYTE				"TTF",0

	ALIGN 16
	DlgXTemplate			DLGTEMPLATEEX		<0>
	DlgXItemTemplate		DLGITEMTEMPLATEEX	<0>

	DlgNTemplate			DLGTEMPLATE			<0>
	DlgNItemTemplate		DLGITEMTEMPLATE		<0>

	SystemMetric			SYSMETRIC			<0>

	GridX					DWORD				3
	GridY					DWORD				3

	ButtonClass				BYTE				"Button",0
	ComboBoxClass			BYTE				"ComboBox",0
	EditClass				BYTE				"Edit",0
	ListBoxClass			BYTE				"ListBox",0
	StaticClass				BYTE				"Static",0
	ScrollBarClass			BYTE				"ScrollBar",0
	
	szResource				BYTE				".rsrc",0
	
	szCustClassErr			BYTE				"This window uses an application defined class",13,10,\
												"It cannot be previewed using this program. It",13,10,\
												"can still be exported to RadASM however",0
	szResourceError			BYTE				"The resorce type of this dialog was not found",13,10,\
												"if this was due to a file alignment problem it",13,10,\
												"may not effect the export to RadSM.",0
	szNoLoad				BYTE				"This file uses an unrecognized format, it may",13,10,\
												"be compressed or encrypted",0
	szSaveRap				BYTE				"Add this entry to the current project file ?",0
	szNoPreview				BYTE				"There is currently no preview for this resource type",13,10,\
												"However it can be saved",0
	Shit					BYTE				"SysIPAddress32",0
	szNoHandle				BYTE				"Res2Dlg could not obtain a handle to this file",13,10,\
												"continuing will cause a GPF if the file is compressed",13,10,\
												"would you like to continue ?",0
.data?
	hInstance				DWORD				?
	hListView				DWORD				?
	hDlg					DWORD				?
	hLVIml					DWORD				?

	hDlgFile				DWORD				?
	DlgHdr					DLGHEAD				<?>
	DlgItem					DIALOG				<?>
	
	rct						RECT				<?>

	ResName					BYTE				64	DUP(?)

	hCURSOR					DWORD				?
	iCaption				DWORD				?

	ClassIndex				DWORD				?

	szmenu					BYTE				MaxMenu DUP (?)
	szwindowClass			BYTE				MaxClass DUP (?)
	sztitle					BYTE				MaxCap DUP (?)
	szFont					BYTE				MaxFont DUP (?)

	ofwFilePath				BYTE				MAX_PATH DUP (?)
	ADDTOY					DWORD				?
	ADDTOX					DWORD				?
	DBUX					DWORD				?
	DBUY					DWORD				?

	vScroll					DWORD				?
	hScroll					DWORD				?

	hPrevBox				DWORD				?
	NextItemPos				DWORD				?
	ResItemClass			BYTE				MaxClass DUP(?)
	ResItemTitle			BYTE				240	DUP(?)
	
	DlgID					DWORD				?
	DLGFRAME				DWORD				?

	hMapFile				DWORD				?
	pMapFile				DWORD				?

.code

;#########################################################################

