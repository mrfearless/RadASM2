;#########################################################################

;	include files
;	~~~~~~~~~~~~~
	include windows.inc
	include gdi32.inc
	include user32.inc
	include kernel32.inc
	include comctl32.inc
	include comdlg32.inc
	include shell32.inc
	include shlwapi.inc
	include ole32.inc
	include advapi32.inc
	include wininet.inc

;	libraries
;	~~~~~~~~~
	includelib gdi32.lib
	includelib user32.lib
	includelib kernel32.lib
	includelib comctl32.lib
	includelib comdlg32.lib
	includelib shell32.lib
	includelib shlwapi.lib
	includelib ole32.lib
	includelib advapi32.lib
	includelib wininet.lib

	include Addins\RadAsm.inc
	include Inc\RAEdit.inc
	include Inc\RAHexEd.inc
	include Inc\RAGrid.inc

	include \RadASM\Masm\Inc\RADbg.inc
	include masm32.inc
	include Debug.Inc
	includelib masm32.lib
	includelib Debug.lib

;#########################################################################

;Local prototypes
ApiConstList					PROTO :DWORD,:DWORD
CreateMnu						PROTO :DWORD
Do_ImageList					PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ProjectOpenFile					PROTO :DWORD
GetFileImg						PROTO :DWORD
PropertyList					PROTO :DWORD
ToolBarStatus					PROTO
CreateDlg						PROTO :DWORD
hexOut							PROTO :DWORD
Do_TreeViewAddNode				PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ToolBoxReset					PROTO
WinMain							PROTO :DWORD,:DWORD,:DWORD,:DWORD
DllProc							PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
HexEditProc						PROTO :DWORD,:DWORD,:DWORD,:DWORD
EditProc						PROTO :DWORD,:DWORD,:DWORD,:DWORD
EditTxtProc						PROTO :DWORD,:DWORD,:DWORD,:DWORD
ListBoxProc						PROTO :DWORD,:DWORD,:DWORD,:DWORD
MakeMdiCldWin					PROTO :DWORD,:DWORD
hexEax							PROTO
UpdateAll						PROTO :DWORD

OpenEditFile					PROTO
SaveEdit						PROTO :DWORD
SaveHexEdit						PROTO :DWORD
SaveEditAs						PROTO :DWORD
BackupEdit						PROTO :DWORD,:DWORD
lstr							PROTO :DWORD,:DWORD,:DWORD
OptColorProc					PROTO :HWND,:UINT,:WPARAM,:LPARAM
OptColorSave					PROTO :DWORD
iniRead							PROTO
iniWinSaveFont					PROTO
iniWinSavePos					PROTO
iniWinSave						PROTO
iniEditSave						PROTO
iniDialogSave					PROTO
iniColSave						PROTO
iniGetAppPath					PROTO :DWORD
iniInStr						PROTO :DWORD,:DWORD
iniRStripStr					PROTO :DWORD,:DWORD
DecToBin						PROTO :DWORD
BinToDec						PROTO :DWORD,:DWORD
iniGetItem						PROTO :DWORD,:DWORD
iniPutItem						PROTO :DWORD,:DWORD,:DWORD
iniToolSave						PROTO :DWORD,:DWORD
iniFixPath						PROTO :DWORD,:DWORD,:DWORD
ParseBuffer						PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CloseProject					PROTO
GetProject						PROTO
SetFormat						PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
Do_OutputTool					PROTO
OutPutMake						PROTO :DWORD,:DWORD
OutputClear						PROTO

ProAddNew						PROTO :DWORD,:DWORD
ProAddExist						PROTO :DWORD,:DWORD
ProRemove						PROTO :DWORD,:DWORD
AddProjectFile					PROTO :DWORD,:DWORD,:DWORD
ProRemoveFile					PROTO :DWORD
TextToOutput					PROTO :DWORD
GetLine							PROTO :DWORD
IsLineInvoke					PROTO :DWORD,:DWORD
IsLineApi						PROTO
ApiListBox						PROTO :DWORD
ApiToolTip						PROTO :DWORD
HideApiToolTip					PROTO :DWORD
GetWordFromPos					PROTO :DWORD
GetWord							PROTO
ProWizShow						PROTO :DWORD
MnuSetCbo						PROTO :DWORD,:DWORD
VerticalCenter					PROTO :DWORD,:DWORD
TabToolAdd						PROTO :DWORD,:DWORD
TabToolSel						PROTO :DWORD
TabToolDel						PROTO :DWORD
ProSetTrv						PROTO :DWORD
LoadEdit						PROTO :DWORD
SearchMem						PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
ProFind							PROTO :DWORD
ProGetWord						PROTO :DWORD
LineNo							PROTO :DWORD
GetPrnCaps						PROTO
RefreshProperty					PROTO
SetProperty						PROTO :DWORD,:DWORD
SetOpenProperty					PROTO :DWORD,:DWORD
PropSetOwner					PROTO :DWORD
RemovePath						PROTO :DWORD,:DWORD,:DWORD
CopyWord						PROTO
SpcSkip							PROTO
FileTrvDir						PROTO :DWORD,:DWORD
FileDir							PROTO :DWORD
FileGetPath						PROTO :DWORD
FileGetName						PROTO
OpenProject						PROTO :DWORD
iniPathFix						PROTO :DWORD
GetProjectFiles					PROTO :DWORD
OutputSelect					PROTO :DWORD
MoveWin							PROTO :DWORD,:DWORD
SaveWinPos						PROTO :DWORD,:DWORD
EditChildProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD
FindProcPos						PROTO :DWORD
TabToolSetSel					PROTO :DWORD
ShowOutput						PROTO
SetMakeMenu						PROTO
GetFileNameFromID				PROTO :DWORD
IsLineStruct					PROTO
PropListSetPos					PROTO
TreeView_DeleteAllItems			PROTO :DWORD
FindProcArgs					PROTO :DWORD,:DWORD
GetAccelString					PROTO :DWORD,:DWORD
ConvertShortcut					PROTO :DWORD
ToolPropertySize				PROTO :DWORD
TabToolUpdate					PROTO :DWORD,:DWORD
SetPropertyCbo					PROTO :DWORD
GroupTVBeginDrag				PROTO :HWND,:HWND,:LPARAM
GroupTVEndDrag					PROTO :HWND
GroupExpandAll					PROTO :HWND,:DWORD
GroupCollapseAll				PROTO :HWND,:DWORD
GroupGetExpand					PROTO :HWND
GroupUpdateGroup				PROTO :HWND
GroupSaveGroups					PROTO :HWND
GroupGetGroups					PROTO :HWND
GetGroupState					PROTO :HWND,:DWORD
SetGroupState					PROTO :HWND,:DWORD

;wsprintfA						PROTO C :DWORD,:VARARG
wsprintf						equ <wsprintfA>

;#########################################################################

;Help
HH_AKLINK struct
	cbStruct		dd ?	;As Integer
	fReserved		dd ?	;As Boolean
	pszKeywords		dd ?	;As ZString Ptr
	pszUrl			dd ?	;As ZString Ptr
	pszMsgText		dd ?	;As ZString Ptr
	pszMsgTitle		dd ?	;As ZString Ptr
	pszWindow		dd ?	;As ZString Ptr
	fIndexOnFail	dd ?	;As Boolean
HH_AKLINK ends

HH_DISPLAY_TOPIC	equ 0000h
HH_KEYWORD_LOOKUP	equ 000Dh

;RadASM
RADCOLOR struct
	output			dd ?
	outputtext		dd ?
	project			dd ?
	projecttext		dd ?
	properties		dd ?
	propertiestext	dd ?
	info			dd ?
	infotext		dd ?
	dialogedit		dd ?
	keywords		dd 16 dup(?)
RADCOLOR ends

RADMEM struct
	ft				FILETIME <?>
	changed			dd ?
RADMEM ends

FONTS struct
	hFontCode		dd ?
	hFontTxt		dd ?
	hFontHex		dd ?
	hFontLnr		dd ?
	hFontDlg		dd ?
	hFontTool		dd ?
	hFontPrn		dd ?
	hFontIde		dd ?
FONTS ends

;#########################################################################
;Menu
MENU struct
	cmnd			db MAX_PATH dup(?)
	param			db ?
	scut			dd ?
	mnuid			dd ?
	ncalls			dd ?
	hSub			dd ?
MENU ends

;Hilighting
WORDINFO struct
	WordLen			dd ?				;the length of the word: used as a quick comparison
	pszWord			dd ?				;pointer to the word
	pColor			dd ?				;point to the dword that contains the color used to hilite the word
	NextLink		dd ?				;point to the next WORDINFO structure
WORDINFO ends

tagACCEL struct
	fVirt			db ?
	dummy			db ?
	key				dw ?
	cmd				dw ?
tagACCEL ends

PROFIND struct
	nFun			dd ?				;0=Find, 1=Free memory
	hMem			dd ?				;Memory handle. NULL if nFile is used.
	nFile			dd ?				;Project file ID.
	pMem			dd ?				;Returned pointer to found line in file
	pFile			dd ?				;Set / returned position in file.
	lpFind			dd ?				;Pointer to find what string. 1=MC,2=WW,3=MC & WW
	lpNot			dd ?				;Pointer to NOT string. Typical ;'"
	lpLine			dd ?				;Pointer to line buffer.
	pLine			dd ?				;Returned position into line buffer. -1 if not found.
	nMiss			dd ?				;Number of invalid Project file ID's.
PROFIND ends

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

DIALOG101 struct
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
DIALOG101 ends

DIALOG100 struct
	hwnd			dd ?
	partype			dd ?
	oldproc			dd ?
	hpar			dd ?
	hcld			dd ?
	style			dd ?
	exstyle			dd ?
	x				dd ?
	y				dd ?
	ccx				dd ?
	ccy				dd ?
	caption			db 32 dup(?)
	ntype			dd ?
	nsubtype		dd ?
	tab				dd ?
	id				dd ?
	idname			db 32 dup(?)
	undo			dd ?
	himg			dd ?
DIALOG100 ends

TYPES struct
	ID				dd ?
	lpclass			dd ?
	notused			dd ?
	style			dd ?
	exstyle			dd ?
	lpidname		dd ?
	lpcaption		dd ?
	lprc			dd ?
	nmethod			dd ?
	methods			dd ?
	flist			dd 4 dup(?)
	wt				dd ?
	ht				dd ?
TYPES ends

PROPERTIES	struct
	nSize			dd ?
	Owner			dd ?
	nType			db ?
PROPERTIES ends

ADDIN struct
	hDLL			dd ?
	fhook1			dd ?
	fhook2			dd ?
	fOpt			dd ?
	lpDllProc		dd ?
	inx				dd ?
ADDIN ends

SCRNSIZE struct
	ccx				dd ?
	fmax			dd ?
	rect			RECT <?>
SCRNSIZE ends

PROGROUP struct
	hGrp			dd ?
	lpszGrp			dd ?
PROGROUP ends

PROFILE struct
	lpszFile		dd ?
	iNbr			dd ?
	nGrp			dd ?
PROFILE ends

;#########################################################################

	; Local macros
	szText MACRO Name, Text:VARARG
		LOCAL lbl
		  jmp lbl
			Name db Text,0
		  lbl:
	ENDM

	m2m MACRO M1, M2
		push M2
		pop  M1
	ENDM

	return MACRO arg
		mov eax, arg
		ret
	ENDM

	CTEXT MACRO text:VARARG
		LOCAL TxtName

		.data
		TxtName BYTE text,0
		.code

		EXITM <OFFSET TxtName>
	ENDM

;#########################################################################

.const
ONLINE_HELP_MSDN                EQU 0
ONLINE_HELP_GOOGLE              EQU 1


IML_START						equ 46
IMG_ARROW						equ 42

MAX_ADDIN						equ 64
PRO_START_FILE					equ 1
PRO_START_OBJ					equ 1001
PRO_MAX_MISS					equ 10

MENUFILE						equ 0
MENUEDIT						equ 1
MENUVIEW						equ 2
MENUFORMAT						equ 3
MENUPROJECT						equ 4
MENUMAKE						equ 5
MENUTOOL						equ 6
MENUWINDOW						equ 7
MENUOPTIONS						equ 8
MENUMACRO						equ 9
MENUHELP						equ 10

ID_EDIT							equ	65501
ID_DIALOG						equ	65502
ID_EDITTXT						equ	65503
ID_EDITHEX						equ	65504
ID_FIRSTCHILD					equ 65001
ID_LASTCHILD					equ 65499

;Resorces

IDOK							equ 1
IDCANCEL						equ 2
IDUSE							equ 10
IDI_MDIICO						equ 100
IDB_MDITBR						equ 101
IDB_TYPES						equ 102
IDB_PROWIZ						equ 103
IDB_TOOLBOX						equ 104
IDB_CUSTCTL						equ 106
IDC_SPLICURV					equ 150
IDC_SPLICURH					equ 151

IDD_GOTODLG						equ 103
IDC_LINENO						equ 1008

IDR_MAINACCEL					equ 105

FIND_OPEN_FILENAME				equ 51000
IS_FILE_CHANGED					equ 51001
QUERY_SAVE						equ 51002

IDR_MDIMENU						equ 999
IDM_FILE_NEWPROJECT				equ 40001
IDM_FILE_OPENPROJECT			equ 40002
IDM_FILE_CLOSEPROJECT			equ 40003
IDM_FILE_DELETEPROJECT			equ 40013
IDM_FILE_NEWFILE				equ 40004
IDM_FILE_OPENFILE				equ 40005
IDM_FILE_OPENHEX				equ 40014
IDM_FILE_REOPENFILE				equ 41021
IDM_FILE_CLOSEFILE				equ 40006
IDM_FILE_SAVEFILE				equ 40007
IDM_FILE_SAVEFILEAS				equ 40008
IDM_FILE_SAVEALLFILES			equ 40009
IDM_FILE_RECENT					equ 40990
IDM_FILE_PAGESETUP				equ 40010
IDM_FILE_PRINT					equ 40011
IDM_FILE_EXIT					equ 40012

IDM_EDIT_UNDO					equ 41001
IDM_EDIT_REDO					equ 41002
IDM_EDIT_EMPTY_UNDO				equ 41022
IDM_EDIT_CUT					equ 41003
IDM_EDIT_COPY					equ 41004
IDM_EDIT_PASTE					equ 41005
IDM_EDIT_DELETE					equ 41006
IDM_EDIT_SELECTALL				equ 41007
IDM_EDIT_FIND					equ 41008
IDM_EDIT_FINDNEXT				equ 41009
IDM_EDIT_FINDPREVIOUS			equ 41010
IDM_EDIT_REPLACE				equ 41011
IDM_EDIT_GOTOLINE				equ 41012
IDM_EDIT_EXPANDBLOCK			equ 41018
IDM_EDIT_FINDWORD				equ 41101
IDM_EDIT_FIND_NEXT_WORD			equ 41020
IDM_EDIT_FIND_PREV_WORD			equ 44023
IDM_EDIT_FINDPROC				equ 41102
IDM_EDIT_RETURN					equ 41103
IDM_EDIT_BOOKMARK				equ 44016
IDM_EDIT_NEXTBM					equ 41105
IDM_EDIT_PREVIOUSBM				equ 41106
IDM_EDIT_TOGGLEBM				equ 41104
IDM_EDIT_CLEARBM				equ 41107

IDM_EDIT_GOTOBM					equ 41990
IDM_EDIT_GOTOBM0				equ 41300
IDM_EDIT_GOTOBM1				equ 41301
IDM_EDIT_GOTOBM2				equ 41302
IDM_EDIT_GOTOBM3				equ 41303
IDM_EDIT_GOTOBM4				equ 41304
IDM_EDIT_GOTOBM5				equ 41305
IDM_EDIT_GOTOBM6				equ 41306
IDM_EDIT_GOTOBM7				equ 41307
IDM_EDIT_GOTOBM8				equ 41308
IDM_EDIT_GOTOBM9				equ 41309

IDM_TAB1						equ 41401
IDM_TAB2						equ 41402
IDM_TAB3						equ 41403
IDM_TAB4						equ 41404
IDM_TAB5						equ 41405
IDM_TAB6						equ 41406
IDM_TAB7						equ 41407
IDM_TAB8						equ 41408
IDM_TAB9						equ 41409
IDM_TAB10						equ 41410

IDM_EDIT_BREAKPOINT				equ 44017
IDM_EDIT_TOGGLEBP				equ 41013
IDM_EDIT_CLEARBP				equ 41014
IDM_EDIT_ADDVAR					equ 41015

IDM_EDIT_ERROR					equ 44018
IDM_EDIT_NEXTERROR				equ 41016
IDM_EDIT_CLEARERRORS			equ 41017
IDM_EDIT_BLOCK					equ 44019
IDM_EDIT_BLOCKMODE				equ 44015
IDM_EDIT_BLOCK_INSERT			equ 44020
IDM_EDIT_HIDEBLOCK				equ 43009
IDM_EDIT_OPEN					equ 41019

IDM_VIEW_TOOLBAR				equ 42001
IDM_VIEW_TOOLBOX				equ 42002
IDM_VIEW_OUTPUTWINDOW			equ 42003
IDM_VIEW_PROJECTBROWSER			equ 42004
IDM_VIEW_PROPERTIES				equ 42005
IDM_VIEW_TABTOOL				equ 42006
IDM_VIEW_INFOTOOL				equ 42008
IDM_VIEW_TOOL1					equ 42009
IDM_VIEW_TOOL2					equ 42010
IDM_VIEW_STATUSBAR				equ 42007
IDM_VIEW_FULLSCREEN				equ 44026

IDM_FORMAT_INDENT				equ 43001
IDM_FORMAT_OUTDENT				equ 43002
IDM_FORMAT_COMMENT				equ 43003
IDM_FORMAT_UNCOMMENT			equ 43004
IDM_FORMAT_CONVERT				equ 43990
IDM_FORMAT_SPCTOTAB				equ 43501
IDM_FORMAT_TABTOSPC				equ 43502
IDM_FORMAT_UCASE				equ 43503
IDM_FORMAT_LCASE				equ 43504
IDM_FORMAT_TRIM					equ 43505
IDM_FORMAT_LOCKCONTROLS			equ 43005
IDM_FORMAT_SENDTOBACK			equ 43006
IDM_FORMAT_BRINGTOFRONT			equ 43007
IDM_FORMAT_SHOWGRID				equ 43008
IDM_FORMAT_ALIGN				equ 43991
IDM_FORMAT_ALIGN_LEFT			equ 43901
IDM_FORMAT_ALIGN_CENTER			equ 43902
IDM_FORMAT_ALIGN_RIGHT			equ 43903
IDM_FORMAT_ALIGN_TOP			equ 43904
IDM_FORMAT_ALIGN_MIDDLE			equ 43905
IDM_FORMAT_ALIGN_BOTTOM			equ 43906
IDM_FORMAT_SIZE					equ 43992
IDM_FORMAT_SIZE_WIDTH			equ 43911
IDM_FORMAT_SIZE_HEIGHT			equ 43912
IDM_FORMAT_SIZE_BOTH			equ 43913
IDM_FORMAT_CENTER				equ 44028
IDM_FORMAT_CENTER_HOR			equ 44029
IDM_FORMAT_CENTER_VER			equ 44030
IDM_FORMAT_TABINDEX				equ 44031

IDM_PROJECT_ADDNEW				equ 44990
IDM_PROJECT_ADDEXISTING			equ 44991
IDM_PROJECT_ADDNEWASM			equ 44101
IDM_PROJECT_ADDNEWINC			equ 44102
IDM_PROJECT_ADDNEWRC			equ 44103
IDM_PROJECT_ADDNEWTXT			equ 44104
IDM_PROJECT_ADDNEWDIALOG		equ 44105
IDM_PROJECT_ADDNEWMENU			equ 44106
IDM_PROJECT_ADDNEWMODULE		equ 44107
IDM_PROJECT_ADDNEWFILE			equ 44108
IDM_PROJECT_ADDEXISTINGFILE		equ 44201
IDM_PROJECT_ADDEXISTINGDIALOG	equ 44202
IDM_PROJECT_ADDEXISTINGMENU		equ 44203
IDM_PROJECT_ADDEXISTINGOBJ		equ 44205
IDM_PROJECT_ADDEXISTINGMODULE	equ 44206
IDM_PROJECT_ADDEXISTINGOPEN		equ 44033
IDM_PROJECT_ACCELERATOR			equ 44011
IDM_PROJECT_RESOURCE			equ 44001
IDM_PROJECT_STRINGTABLE			equ 44007
IDM_PROJECT_VERINF				equ 44002
IDM_PROJECT_LANGUAGE			equ 44013
IDM_PROJECT_GROUPS				equ 44010
IDM_PROJECT_SET_ASSEMBLER		equ 44992
IDM_PROJECT_EXPORTTOOUTPUT		equ 44003
IDM_PROJECT_REMOVE				equ 44004
IDM_PROJECT_TEMPLATE			equ 44005
IDM_PROJECT_OPTIONS				equ 44006
IDM_PROJECT_MAINFILES			equ 44009
IDM_PROJECT_TLINK				equ 44993
IDM_TLINK_NOTE					equ 44701
IDM_TLINK_BUG					equ 44702
IDM_TLINK_TODO					equ 44703
IDM_PROJECT_REFRESH				equ 44008
IDM_PROJECT_SCANPROJECT			equ 44012

IDM_TOOLS_SNIPLETS				equ 46001
IDM_TOOLS_EXPORT				equ 46002

IDM_WINDOW_SPLIT				equ 47009
IDM_WINDOW_CLOSE				equ 47001
IDM_WINDOW_CLOSEALL				equ 47002
IDM_WINDOW_NEXTWINDOW			equ 47003
IDM_WINDOW_PREVIOUS				equ 47004
IDM_WINDOW_EDIT					equ 47013
IDM_WINDOW_PROJECT				equ 47014
IDM_WINDOW_PROPERTY				equ 47015
IDM_WINDOW_OUTPUT				equ 47016
IDM_WINDOW_TILEHOR				equ 47005
IDM_WINDOW_TILEVER				equ 47006
IDM_WINDOW_CASCADE				equ 47007
IDM_WINDOW_ARRANGEICONS			equ 47008
IDM_WINDOW_MAXIMIZE				equ 47010
IDM_WINDOW_RESTORE				equ 47011
IDM_WINDOW_MINIMIZE				equ 47012
IDM_WINDOW_CLOSEALLBUT			equ 44032

IDM_OPTION_LANGUAGE				equ 44022
IDM_OPTION_PROGLANGUAGE			equ 44024
IDM_OPTION_EDIT					equ 48003
IDM_OPTION_COLORS				equ 48001
IDM_OPTION_PRNCOLORS			equ 48015
IDM_OPTION_DIALOG				equ 48004
IDM_OPTION_CUSTCTRL				equ 44025
IDM_OPTION_FONTS				equ 44014
IDM_OPTION_ACCEL				equ 48017
IDM_OPTION_FILEASS				equ 44021
IDM_OPTION_FILEBROWSER			equ 48012
IDM_OPTION_EXTERNALFILE			equ 48013
IDM_OPTION_SNIPLET				equ 48005
IDM_OPTION_PATHS				equ 48006
IDM_OPTION_ENVIRONMENT			equ 44027
IDM_OPTION_TOOLWINDOWS			equ 48011
IDM_OPTION_MAKEMNU				equ 48007
IDM_OPTION_TOOLMNU				equ 48008
IDM_OPTION_HELPMNU				equ 48009

IDM_MACRO_RECORD				equ 46301
IDM_MACRO_MANAGE				equ 46303

IDM_HELP_ABOUT					equ 49001

IDM_MAKE_COMPILERC				equ 20001
IDM_MAKE_ASSEMBLE				equ 20002
IDM_MAKE_BUILD					equ 20004
IDM_MAKE_GO						equ 20005
IDM_MAKE_RUN					equ 20006

IDM_HELPF1						equ	41902
IDM_HELPCF1						equ	41903
IDM_HELPSF1						equ	41904
IDM_HELPCSF1					equ	41905

IDR_PROMENU						equ 998
IDM_PROMNU_FILEPROP				equ 50001
IDM_PROMNU_REMOVE				equ 50002
IDM_PROMNU_RENAME				equ 50024
IDM_PROMNU_LOCK					equ 50003
IDM_PROMNU_COPY					equ 50014

IDM_OUTPUT_OPEN					equ 50005
IDM_OUTPUT_SAVE					equ 50006
IDM_OUTPUT_UNDO					equ 50007
IDM_OUTPUT_REDO					equ 50008
IDM_OUTPUT_CUT					equ 50101
IDM_OUTPUT_COPY					equ 50102
IDM_OUTPUT_PASTE				equ 50103
IDM_OUTPUT_DELETE				equ 50104
IDM_OUTPUT_CLEAR				equ 50105
IDM_OUTPUT_COPYALL				equ 50106
IDM_OUTPUT_CUTALL				equ 50107

IDM_FILE_CUT					equ 50009
IDM_FILE_COPY					equ 50010
IDM_FILE_PASTE					equ 50011
IDM_FILE_DELETE					equ 50012
IDM_FILE_RENAME					equ 50013
IDM_FILE_COPYNAME				equ 50015
IDM_FILE_EXPLORE				equ 50023

IDM_PROPERTY_GOTO				equ 50016
IDM_PROPERTY_SCAN				equ 50021
IDM_PROPERTY_FIND				equ 50018
IDM_PROPERTY_FINDNEXT			equ 50019
IDM_PROPERTY_FINDPREV			equ 50020
IDM_PROPERTY_COPY				equ 50017
IDM_PROPERTY_PROTO				equ 50022

IDM_GROUPEXPAND					equ 50025
IDM_GROUPCOLLAPSE				equ 50026
IDM_GROUPADD					equ 50029
IDM_GROUPDELETE					equ 50028
IDM_GROUPEDIT					equ 50027

IDM_USERBTN1					equ 29991
IDM_USERBTN2					equ 29992

MAXMULSEL						equ 256

PGM_FIRST						equ 1400h
PGM_SETCHILD					equ PGM_FIRST+1
PGM_RECALCSIZE					equ PGM_FIRST+2
PGM_FORWARDMOUSE				equ PGM_FIRST+3
PGM_SETBKCOLOR					equ PGM_FIRST+4
PGM_GETBKCOLOR					equ PGM_FIRST+5
PGM_SETBORDER					equ PGM_FIRST+6
PGM_GETBORDER					equ PGM_FIRST+7
PGM_SETPOS						equ PGM_FIRST+8
PGM_GETPOS						equ PGM_FIRST+9
PGM_SETBUTTONSIZE				equ PGM_FIRST+10
PGM_GETBUTTONSIZE				equ PGM_FIRST+11
PGM_GETBUTTONSTATE				equ PGM_FIRST+12
PGM_GETDROPTARGET				equ CCM_GETDROPTARGET


iniVerNme						db 'Nme',0
iniVerID						db 'ID',0

szHdrKey						db 'Key',0
szHdrCtrl						db 'Ctrl',0
szHdrShift						db 'Shift',0
szHdrAlt						db 'Alt',0

szAclKeys						db 00h,'(None)',0
								db 41h,'A',0
								db 42h,'B',0
								db 43h,'C',0
								db 44h,'D',0
								db 45h,'E',0
								db 46h,'F',0
								db 47h,'G',0
								db 48h,'H',0
								db 49h,'I',0
								db 4Ah,'J',0
								db 4Bh,'K',0
								db 4Ch,'L',0
								db 4Dh,'M',0
								db 4Eh,'N',0
								db 4Fh,'O',0
								db 50h,'P',0
								db 51h,'Q',0
								db 52h,'R',0
								db 53h,'S',0
								db 54h,'T',0
								db 55h,'U',0
								db 56h,'V',0
								db 57h,'W',0
								db 58h,'X',0
								db 59h,'Y',0
								db 5Ah,'Z',0
								db 30h,'0',0
								db 31h,'1',0
								db 32h,'2',0
								db 33h,'3',0
								db 34h,'4',0
								db 35h,'5',0
								db 36h,'6',0
								db 37h,'7',0
								db 38h,'8',0
								db 39h,'9',0
								db 70h,'F1',0
								db 71h,'F2',0
								db 72h,'F3',0
								db 73h,'F4',0
								db 74h,'F5',0
								db 75h,'F6',0
								db 76h,'F7',0
								db 77h,'F8',0
								db 78h,'F9',0
								db 79h,'F10',0
								db 7Ah,'F11',0
								db 7Bh,'F12',0
								db 60h,'Num0',0
								db 61h,'Num1',0
								db 62h,'Num2',0
								db 63h,'Num3',0
								db 64h,'Num4',0
								db 65h,'Num5',0
								db 66h,'Num6',0
								db 67h,'Num7',0
								db 68h,'Num8',0
								db 69h,'Num9',0
								db 08h,'Back',0
								db 1Bh,'Esc',0
								db 09h,'Tab',0
								db 0Dh,'Return',0
								db 27h,'Ins',0
								db 2Eh,'Del',0
								db 24h,'Home',0
								db 23h,'End',0
								db 21h,'PgUp',0
								db 22h,'PgDn',0
								db 25h,'Left',0
								db 26h,'Up',0
								db 27h,'Right',0
								db 28h,'Down',0
								db 512 dup(0)

szRADebug						db 'RADebug.dll',0
szRADebugParam					db ',12,1',0
szDragProp						db 'DragProp.dll',0

;#########################################################################

.data

szLangPath						db '\Language\',0
szRes							db 'Res\',0
SplashClassName					db 'RadSplashClass',0
FullScreenClassName				db 'FullScreenClass',0
MdiClassName					db 'RadASMClass',0
EditCldClassName				db 'MdiEditChild',0
DialogCldClassName				db 'MdiDialogChild',0
HexEdCldClassName				db 'MdiHexEdChild',0
RAEditClass						db 'RAEDIT',0
RAHexEdClass					db 'RAHEXEDIT',0
RichEditClass					db 'RichEdit20A',0 ;RichEdit50W
DlgEditClass					db 'DlgEdit',0
DlgEditDummyClass				db 'DlgEditDummy',0
ToolTipsClassName				db 'Tooltips_class32',0

mdiCl							db 'MDICLIENT',0
szEdit							db 'Edit',0
szStatic						db 'Static',0
szButton						db 'Button',0
szComboBox						db 'ComboBox',0
szListBox						db 'ListBox',0
szScrollBar						db 'ScrollBar',0
szTabControl					db 'SysTabControl32',0
szProgressBar					db 'msctls_progress32',0
szTreeView						db 'SysTreeView32',0
szListView						db 'SysListView32',0
szTrackBar						db 'msctls_trackbar32',0
szUpDown						db 'msctls_updown32',0
szToolBar						db 'ToolbarWindow32',0
szStatusBar						db 'msctls_statusbar32',0
szDateTime						db 'SysDateTimePick32',0
szMonthView						db 'SysMonthCal32',0
szUserControl					db 'UDCCLASS',0
szComboBoxEx					db 'ComboBoxEx32',0
szIPAddress						db 'SysIPAddress32',0
szAnimate						db 'SysAnimate32',0
szHotKey						db 'msctls_hotkey32',0
szPager							db 'SysPager',0
szReBar							db 'ReBarWindow32',0
szHeader						db 'SysHeader32',0
szSyslink						db 'SysLink',0

szCtlText						db 'Dialog,EditText,Static,GroupBox,Button,CheckBox,RadioButton,ComboBox,ListBox,HScroll,VScroll,TabStrip,ProgressBar,TreeView,ListView,TrackBar,UpDown,Image,ToolBar,StatusBar,DatePicker,'
								db 'MonthView,RichEdit,UserDefinedControl,ImageCombo,Shape,IPAddress,Animate,HotKey,HPager,VPager,ReBar,Header,SysLink',0
								db 512 dup(0)

RichEditDLL						db 'riched20.dll',0 ;msftedit.dll
RAEditDLL						db 'RAEdit.dll',0
RAHexEdDLL						db 'RAHexEd.dll',0
RAGridDLL						db 'RAGrid.dll',0

;Find dialog
szReplace						db 'Replace..',0
szSearchFinished				db 'Region searched.',0
;Resource
szHdrType						db 'Type',0
szHdrName						db 'Name',0
szHdrID							db 'ID',0
szHdrFile						db 'File',0
;Stringtable
szHdrString						db 'String',0
;Accel option
szHdrCaption					db 'Caption',0
;Groups
szHdrGroup						db 'Groups',0
;Import
szImpCpy						db 'Copy file',0
szImpAdd						db 'Add file',0
szImpMain						db 'Main file',0
szImpFile						db 'File name',0
;Errors
NoRichEdit						db 'Cannot find riched20.dll',0
NoRAEdit						db 'Cannot find RAEdit.dll',0
NoRAHexEd						db 'Cannot find RAHexEd.dll',0
NoRAGrid						db 'Cannot find RAGrid.dll',0
szGlobalFail					db 'GlobalAlloc failed.',0
szHeapFail						db 'HeapAlloc failed.',0
szMnuErr						db 'Menu skipped a level.',0
szDuplicateAccel				db 'Duplicate accelerator(s)',0
txtUF							db 'Unrecognized file type',0Dh,0
szFolderErr1					db 0Dh,0Dh,'Could not create the folder.',0
szFolderErr2					db 0Dh,0Dh,'Folder exists. Create the project anyway?',0
szFileErr						db 0Dh,0Dh,'File exists. Overwrite the file?',0
szFileDelErr					db 0Dh,'Could not delete the file ',0
szNotFound						db 'File not found:',0
;Messages
szRestart						db 'Changes will take place the',0Dh,0Ah,'next time you start RadASM.',0
szDeleteProject					db 'Deleting project',0
szFinished						db 0Dh,'Make finished.',0
szErrors						db 0Dh,'Make error(s) occured.',0
szTerminated					db 0Dh,'Terminated by user.',0Dh,0
szExec							db 'Executing:',0
;Tool captions
szProjectCaption				db 'Project',0
szProperty						db 'Properties',0
szInfoCaption					db 'Info',0
szOutPutCaption					db 'Output',0

ALLFilterString					db 'Assembly Files (*.asm)',0,'*.asm',0
								db 'Include Files (*.inc)',0,'*.inc',0
								db 'Resource Files (*.rc)',0,'*.rc',0
								db 'Text Files (*.txt)',0,'*.txt',0
								db 'All Files (*.*)',0,'*.*',0,0
								db 256 dup (0)
ANYFilterString					db 'All Files (*.*)',0,'*.*',0,0
RCFilterString					db 'Resource (*.rc)',0,'*.rc',0,0
DefRcExt						db 'rc',0
DLGFilterString					db 'Dialog (*.dlg)',0,'*.dlg',0,0
DefDlgExt						db 'dlg',0
MNUFilterString					db 'Menu (*.mnu)',0,'*.mnu',0,0
DefMnuExt						db 'mnu',0
OBJFilterString					db 'Object (*.obj)',0,'*.obj',0,0
TPLFilterString					db 'Template (*.tpl)',0,'*.tpl',0,0
DefTplExt						db 'tpl',0
PROFilterString					db 'Project (*.rap)',0,'*.rap',0,0
DefProExt						db 'rap',0
TXTFilterString					db 'Text (*.txt)',0,'*.txt',0,0
DefTxtExt						db 'txt',0

BMPFilterString					db 'Bitmap (*.bmp)',0,'*.bmp',0,0
ICOFilterString					db 'Icon (*.ico)',0,'*.ico',0,0
CURFilterString					db 'Cursor (*.cur)',0,'*.cur',0,0
IMGFilterString					db 'Image (*.bmp, *.png, *.gif, *.jpg)',0,'*.bmp;*.png;*.gif;*.jpg',0,0
MIDFilterString					db 'Midi (*.mid)',0,'*.mid',0,0
WAVFilterString					db 'Wave (*.wav)',0,'*.wav',0,0
AVIFilterString					db 'Avi clip (*.avi)',0,'*.avi',0,0
RCDFilterString					db 'RC data (*.*)',0,'*.*',0,0
XMLFilterString					db 'XML file (*.xml)',0,'*.xml',0,0
FNTFilterString					db 'Font (*.fon, *.ttc, *.ttf)',0,'*.fon;*.ttc;*.ttf',0,0
ANIFilterString					db 'Ani Cursor (*.ani)',0,'*.ani',0,0
HTMLFilterString				db 'HTML (*.htm, *.html)',0,'*.htm;*.html',0,0
INIFilterString					db 'Inifile (*.ini)',0,'*.ini',0,0
DLLFilterString					db 'CustomControl (*.dll)',0,'*.dll',0,0

szFilterTools					db 'Commands (*.com, *.exe, *.cmd)',0,'*.com;*.exe;*.cmd',0
								db 'All Files (*.*)',0,'*.*',0,0
szFilterHelp					db 'Help (*.hlp, *.chm)',0,'*.hlp;*.chm',0
								db 'All Files (*.*)',0,'*.*',0,0
szFilterMacro					db 'Macro (*.kbm)',0,'*.kbm',0
								db 'All Files (*.*)',0,'*.*',0,0


LanguagePack					db 0Dh,0Dh,'Yoy need to download and install the appropriate programming language pack.',0
NoLanguagePack					db 'Yoy need to download and install at least one programming language pack.',0
OpenFileFail					db 'Cannot open the file',0Dh,0
SaveFileFail					db 'Cannot save the file',0Dh,0
ProjectFileFail					db 'Project file corrupted',0Dh,0
szCopyOf						db 'Copy Of ',0
szFileExist						db 'File exists.',0Dh,'Overwrite?',0
szCouldNotCopy					db 'Could not copy file.',0
szCouldNotDelete				db 'Could not delete file.',0
WannaSave						db 'Want to save changes to',0Dh,0
								db '\'
NewFile							db '(Untitled)',0
AddNewFile						db 'Add New File',0
AddExistFile					db 'Add Existing File',0
AddNewDialog					db 'Add New Dialog',0
AddExistDialog					db 'Add Existing Dialog',0
AddNewMenu						db 'Add New Menu',0
AddExistMenu					db 'Add Existing Menu',0
AddExistObj						db 'Add Existing Object file',0
AddNewModule					db 'Add New Module',0
AddExistModule					db 'Add Existing Module',0
SelectMenu						db 'Select a Menu',0
SelectImage						db 'Select an Image',0

Replacements					db ' Replacements made',0
AllFiles						db 'All project files searched',0
Remove							db 'Remove ',0
Remove2							db ' from project?',0
szCrLf							db 0Dh,0Ah,0
szChanged						db 'File is changed outside editor',0Dh,0Ah,0
szReopenFile					db 0Dh,0Ah,0Dh,0Ah,'Reopen the file?',0

szScanning						db 'Scanning: ',0
szLibrary						db 'library',0

szLine							db 'Ln: ',10 dup(0)
szChar							db ' Char: ',10 dup(0)
szPage							db ' Pg: ',10 dup(0)
szSize							db ' Size: ',10 dup(0)
szSel							db ' Sel: ',10 dup(0)
szPos							db 'Pos: ',32 dup(0)
szBin							db ' Bin: ',0
strHex							db	16 dup(0)
CreatePipeError					db 'Error during pipe creation',0
CreateProcessError				db 'Error during process creation',0Dh,0
szErrorIn						db 'Error in:',0

szNULL							db 0,0
szSpace							db ' ',0
szComma							db ',',0
szBackSlash						db '\',0
szPoint							db '.',0
szPipe							db '|',0
szLPA							db '(',0
szRPA							db ')',0
szTab							db VK_TAB,0,0,0
szAPA							db '*.*',0
szINS							db 'INS',0

szLBFont						db 'MS Sans Serif',0
szCNFont						db 'Courier New',0
szTTFont						db 'Tahoma',0

;Hilite operators
szOperand						db "/,'!|+-*&<>=(){}[]^:",'"',0
DatePic							db "yyyy'-'MM'-'dd' '",0
TimePic							db "hh':'mm':'ss' - '",0

;FileTypes
FTRc							db '.rc',0
FTDlg							db '.dlg',0
FTMnu							db '.mnu',0
FTRap							db '.rap',0
FTTxt							db '.txt',0
FTObj							db '.obj',0
FTIni							db '.ini',0
FTRes							db '.res',0
FTBmp							db '.bmp',0
FTIco							db '.ico',0
FTExe							db '.exe',0
FTBat							db '.bat',0
FTHlp							db '.hlp',0
FTDll							db '.dll',0

szDeclare						db 'Declare',0
szCAPTION						db 'CAPTION',0
szCLASS							db 'CLASS',0
szSTYLE							db 'STYLE',0
szEXSTYLE						db 'EXSTYLE',0
szFONT							db 'FONT',0
szMENU							db 'MENU',0
szMENUEX						db 'MENUEX',0
szPOPUP							db 'POPUP',0
szMENUITEM						db 'MENUITEM',0
;szCHECKED						db 'CHECKED',0
;szGRAYED						db 'GRAYED',0
;szHELP							db 'HELP',0
;szINACTIVE						db 'INACTIVE',0
;szSEPARATOR					db 'SEPARATOR',0
szBEGIN							db 'BEGIN',0
szEND							db 'END',0
szDEFINE						db '#define',0
szVERSIONINFO					db 'VERSIONINFO',0
szFILEVERSION					db 'FILEVERSION',0
szPRODUCTVERSION				db 'PRODUCTVERSION',0
szFILEOS						db 'FILEOS',0
szFILETYPE						db 'FILETYPE',0
szBLOCK							db 'BLOCK',0
szVALUE							db 'VALUE',0
szDISCARDABLE					db 'DISCARDABLE',0
szACCELERATOR					db 'ACCELERATORS',0
szVIRTKEY						db 'VIRTKEY',0
szNOINVERT						db 'NOINVERT',0
szSHIFT							db 'SHIFT',0
szCONTROL						db 'CONTROL',0
szALT							db 'ALT',0
szLanguage						db 'LANGUAGE',0
szSubLang						db 'SubLang',0
szPROTO							db 'PROTO',0
szCR							db 0Dh,0

;Text link
szTLink							db 'TLink',0
szCross							db '###',0
szSpc							db ' ',0
szColon							db ':',0
szSee							db ' SEE - ',0
szBug							db 'BUG',0
szNote							db 'NOTE',0
szToDo							db 'TODO',0
szSeeFind						db '### SEE - ',0
szCtrl							db 'Ctrl+',0
szShift							db 'Shift+',0
szAlt							db 'Alt+',0

szInstallDll					db 'InstallDll',0
szInstallDllEx					db 'InstallDllEx',0
szDllProc						db 'DllProc',0
nAddInMenuID					dd 30000

;Do not insert or move, just add
lpTextOut						dd offset TextToOutput
lpHexOut						dd offset hexOut
lpClearOut						dd offset OutputClear
lpAddProjectFile				dd offset AddProjectFile
lpOpenProjectFile				dd offset ProjectOpenFile
lpToolMessage					dd offset ToolMessage
lpGetWordFromPos				dd offset GetWordFromPos
lpProFind						dd offset ProFind
lpGetWord						dd offset ProGetWord
lpRemoveProjectPath				dd offset RemoveProjectPath
lpGetMainFile					dd offset GetMainFile
lpSearchMem						dd offset SearchMem
lpProScan						dd offset ProScan
lpBackupEdit					dd offset BackupEdit
lpGetFileType					dd offset GetFileImg
lpOutputSelect					dd offset OutputSelect
lpUpdateCtl						dd offset UpdateCtl
lpShowBreakPoint				dd offset ShowBreakPoint
lpUpdateVerInf					dd offset VerinfoExport
lpCloseProject					dd offset CloseProject
lpOpenProject					dd offset OpenProject
lpExportDialog					dd offset ExportDialog
lpDllProc						dd offset DllProc
lpSetPropertyCbo				dd offset SetPropertyCbo
lpAddTab						dd offset TabToolAdd
lpDelTab						dd offset TabToolDel
lpSelTab						dd offset TabToolSet
lpUpdateAll						dd offset UpdateAll
lpGetFileNameFromID				dd offset GetFileNameFromID
lpMenuRebuild					dd offset iniAddMenu
lpUpdateMRU						dd offset UpdateMRU
lpUpdateResource				dd offset ResourceExport
lpUpdateStringTable				dd offset StringTableExport
lpUpdateAccelerator				dd offset AccelEditExport
lpGetProjectFiles				dd offset GetProjectFiles
lpToolBarStatus					dd offset ToolBarStatus
lpUpdateLanguage				dd offset LanguageEditExport
lpGetLangString					dd offset GetLangStringA
lpSetLanguage					dd offset SetLanguage
lpModalDialog					dd offset ModalDialog
lpModelessDialog				dd offset ModelessDialog
lpUpdateSizeingRect				dd offset UpdateSizeingRect
lpSaveEdit						dd offset SaveEdit
lpSaveDialog					dd offset SaveDialog
lpSaveHexEdit					dd offset SaveHexEdit
lpSetTextLink					dd offset SetTextLink
lpScanWord						dd offset ScanWord
lpAddWordToWordList				dd offset AddWordToWordList
lpRefreshProperty				dd offset RefreshProperty
;Do not insert or move, just add

AppName							db 'RadASM version 2.2.2.4',0
DisplayName						db 'RadASM',0
AboutMsg						db 'RadASM (C) KetilO 2001-2009',13,10,13,10,'radasmide@hotmail.com',0
AboutUrl1						db 'http://radasm.cherrytree.at/',0
AboutUrl2						db 'http://www.oby.ro/rad_asm',0

;Do not insert or move, just add
nRadASMVer						dd 2223
fMaximized						dd 0
lpIniFile						dd offset iniFile
lpProject						dd offset ProjectFile
lpProjectPath					dd offset ProjectPath
lpFile							dd offset FileName
lpApp							dd offset App
lpBin							dd offset Bin
lpAddIn							dd offset AddIn
lpHlp							dd offset Hlp
lpIncl							dd offset Incl
lpLib							dd offset Lib
lpPro							dd offset Pro
lpSnp							dd offset Snp
lpTpl							dd offset Tpl
lpMac							dd offset Mac
lpIniAsmFile					dd offset iniAsmFile
fProject						dd 0
lpLoadPath						dd offset AppPath
lpCtlTypes						dd offset ctltypes
fResChanged						dd 0
lpBreakPoint					dd offset BreakPoint
fResProject						dd 0
lpBreakPointVar					dd offset BreakPointVar
AsmFlag							dd 0
lpCharTab						dd 0
szAssembler						db 16 dup(0)
lpPrpCboItems					dd offset PrpCboItems
EditMax							dd 0
hMemPro							dd 0
hWordList						dd 0
lpWordList						dd 0
rpProjectWordList				dd 0
rpWordListPos					dd 0
lpAddins						dd offset hAddins
rpStructList					dd 0
lpszAppName						dd offset AppName
lpDbg							dd offset Dbg
lpCurPro						dd offset CurPro
lpszAclKeys						dd offset szAclKeys
UserBtnID						dd 0
nAsm							dd 0
fNT								dd 0
lpRABlockDef					dd offset rablkdef
TabSize							dd 0
ShowApiList						dd 0
ShowApiStruct					dd 0
ShowApiToolTip					dd 0
fLB								dd 0
fTlt							dd 0
lpSRCFilterString				dd offset SRCFilterString
lpDefSrcExt						dd offset DefSrcExt      
lpHDRFilterString				dd offset HDRFilterString
lpDefHdrExt						dd offset DefHdrExt      
lpMODFilterString				dd offset MODFilterString
lpDefModExt						dd offset DefModExt      
;Do not insert or move, just add

iniPaths						db 'Paths',0
iniFolderA						db '$A',0
iniFolderB						db '$B',0
iniFolderC						db '$C',0
iniFolderD						db '$D',0
iniFolderE						db '$E',0
iniFolderH						db '$H',0
iniFolderI						db '$I',0
iniFolderL						db '$L',0
iniFolderM						db '$M',0
iniFolderP						db '$P',0
iniFolderR						db '$R',0
iniFolderS						db '$S',0
iniFolderT						db '$T',0

iniEdit							db 'Edit',0
iniEditFont						db 'Font',0
iniEditFontHeight				db 'FontHeight',0
iniEditFontWeight				db 'FontWeight',0
iniEditFontItalic				db 'FontItalic',0
iniEditFontCharSet				db 'FontCharSet',0
iniLnrFont						db 'LnrFont',0
iniLnrFontHeight				db 'LnrFontHeight',0

iniEditTxtFont					db 'TxtFont',0
iniEditTxtFontHeight			db 'TxtFontHeight',0
iniEditTxtFontWeight			db 'TxtFontWeight',0
iniEditTxtFontItalic			db 'TxtFontItalic',0
iniEditTxtFontCharSet			db 'TxtFontCharSet',0

iniEditHexFont					db 'HexFont',0
iniEditHexFontHeight			db 'HexFontHeight',0
iniEditHexFontWeight			db 'HexFontWeight',0
iniEditHexFontItalic			db 'HexFontItalic',0
iniEditHexFontCharSet			db 'HexFontCharSet',0

iniEditDlgFont					db 'DlgFont',0
iniEditDlgFontHeight			db 'DlgFontHeight',0
iniEditDlgFontWeight			db 'DlgFontWeight',0
iniEditDlgFontItalic			db 'DlgFontItalic',0
iniEditDlgFontCharSet			db 'DlgFontCharSet',0

iniEditToolFont					db 'ToolFont',0
iniEditToolFontHeight			db 'ToolFontHeight',0
iniEditToolFontWeight			db 'ToolFontWeight',0
iniEditToolFontItalic			db 'ToolFontItalic',0
iniEditToolFontCharSet			db 'ToolFontCharSet',0

iniEditPrnFont					db 'PrnFont',0
iniEditPrnFontHeight			db 'PrnFontHeight',0
iniEditPrnFontWeight			db 'PrnFontWeight',0
iniEditPrnFontCharSet			db 'PrnFontCharSet',0
iniEditPrnPage					db 'PrnPage',0
iniEditPrnOption				db 'PrnOption',0
iniEditPrnColor					db 'PrnColor',0
iniEditTabSize					db 'TabSize',0
iniEditBackup					db 'Backup',0
iniEditAutoSave					db 'AutoSave',0
iniEditThreadBuild				db 'ThreadBuild',0
iniEditChangeNotify				db 'ChangeNotify',0
iniEditMinimize					db 'MinimizeOnBuild',0
iniEditAutoIndent				db 'AutoIndent',0
iniEditApiList					db 'ApiList',0
iniEditApiToolTip				db 'ApiToolTip',0
iniEditProperties				db 'Properties',0
iniEditMouseWheel				db 'MouseWheel',0
iniEditSaveSize					db 'SaveSize',0
iniEditMaximize					db 'Maximize',0
iniEditApiConst					db 'ApiConst',0
iniEditCodeWrite				db 'CodeWrite',0
iniEditTabToSpc					db 'TabToSpc',0
iniEditApiStruct				db 'ApiStruct',0
iniEditApiWordConv				db 'ApiWordConv',0
iniEditApiWordLocal				db 'ApiWordLocal',0
iniEditApiShiftSpace			db 'ApiShiftSpace',0
iniEditProcsToApi				db 'ProcsToApi',0
iniEditEnterOnTab				db 'EnterOnTab',0
iniEditProcInSBar				db 'ProcInSBar',0
iniEditCodeFiles				db 'CodeFiles',0
iniEditLnrWidth					db 'LnrWidth',0
iniEditLnrOnOpen				db 'LnrOnOpen',0
iniEditOpenCollapsed			db 'OpenCollapsed',0
iniPageSize						db 'PageSize',0
iniEditLnSpc					db 'LnSpc',0
iniEditAutoBrackets				db 'AutoBrackets',0
iniEditCodeTooltip				db 'CodeTooltip',0
iniHiliteLine					db 'HiliteLine',0
iniHiliteCmnt					db 'HiliteCmnt',0

iniFileBrowser					db 'FileBrowser',0
iniFileBrowserFilter			db 'Filter',0
fFileBrowser					dd 1
nFileBrowser					db '0',0
fFileBrowserOpen				dd 0

;Dialog
iniDialog						db 'Dialog',0
iniDialogGrid					db 'Grid',0
iniDialogGridcx					db 'GridX',0
iniDialogGridcy					db 'GridY',0
iniDialogSnapToGrid				db 'SnapToGrid',0
iniDialogGridLine				db 'GridLine',0
iniDialogGridColor				db 'GridColor',0
iniDialogShowSize				db 'ShowSize',0
iniDialogSaveRC					db 'SaveRC',0
iniDialogSimpleProperty			db 'SimpleProperty',0
iniDialogLimittedFont			db 'LimittedFont',0
iniDialogDlgID					db 'DlgID',0
iniDialogCtrlID					db 'CtrlID',0

iniMenuMake						db 'MenuMake',0

iniColor						db 'Color',0
iniVersion						db 'Version',0
iniUseColor						db 'UseColor',0
iniUseDivLine					db 'DivLine',0
iniNoFlicker					db 'NoFlicker',0

iniCustColors					db 'CustColors',0
iniKeyWords						db 'KeyWords',0
szSetHiliteWords				db 'SetHiliteWords',0
szSetBlockDef					db 'SetBlockDef',0

;Project file
iniProject						db 'Project',0
iniProjectType					db 'Type',0
iniProjectDescription			db 'Description',0
iniProjectBackup				db 'Backup',0
iniProjectFiles					db 'Files',0
iniProjectSize					db 'Size',0
iniAutoLoad						db 'AutoLoad',0
iniGroupExpand					db 'GroupExpand',0
iniProjectBookMark				db 'BookMark',0
iniProjectBreakPoint			db 'BreakPoint',0
iniProjectGroup					db 'Group',0
iniProjectGroupExpand			db 'GroupExpand',0
iniMakeDef						db 'MakeDef',0
iniMakeDefNoPro					db 'MakeDefNoProject',0
iniMakeDefMenu					db 'Menu',0
iniMakeFile						db 'MakeFiles',0
iniResource						db 'Resource',0

iniOpen							db 'Open',0

iniEditCmntBlock				db 'CmntBlock',0
iniEditCmntChar					db 'CmntChar',0
szDefCmntChar					db ';',0
iniCodeBlock					db 'CodeBlock',0
iniEditBraceMatch				db 'BraceMatch',0

;Pro find
szIniSkip						db 'Skip',0
szIniCode						db 'Code',0
szIniCode2						db 'Code2',0
szIniLocal						db 'Local',0
szIniConst						db 'Const',0
szIniData						db 'Data',0
szIniMacro						db 'Macro',0
szIniStruct						db 'Struct',0
szIniStruct2					db 'Struct2',0
szIniLabel						db 'Label',0
szIniOther						db 'Other',0
DefPrpCboItems					db 'code,0,constants,1,data,2,macros,3,labels,4,structures,5',0
szSrcPtr						db 'ptr',0

iniColors						dd offset racol.bckcol
								dd 00C0F0F0h
								db 'Back',0
								dd offset racol.txtcol
								dd 00000000h
								db 'Fore',0
								dd offset racol.selbckcol
								dd 00800000h
								db 'SelBack',0
								dd offset racol.seltxtcol
								dd 00FFFFFFh
								db 'SelText',0
								dd offset racol.cmntcol
								dd 02008000h
								db 'Cmnt',0
								dd offset racol.strcol
								dd 00A00000h
								db 'Str',0
								dd offset racol.numcol
								dd 00808080h
								db 'Num',0
								dd offset racol.oprcol
								dd 000000A0h
								db 'Oper',0
								dd offset racol.hicol1
								dd 00F0C0C0h
								db 'HiLine1',0
								dd offset racol.hicol2
								dd 00C0F0C0h
								db 'HiLine2',0
								dd offset racol.hicol3
								dd 00C0C0F0h
								db 'HiLine3',0
								dd offset racol.selbarbck
								dd 00C0C0C0h
								db 'Bar',0
								dd offset racol.selbarpen
								dd 00808080h
								db 'BarPen',0
								dd offset racol.lnrcol
								dd 00800000h
								db 'LnrFontColor',0
								dd offset radcol.output
								dd 00C0F0F0h
								db 'Output',0
								dd offset radcol.outputtext
								dd 0
								db 'Outputtext',0
								dd offset radcol.project
								dd 00C0F0F0h
								db 'Project',0
								dd offset radcol.projecttext
								dd 0
								db 'Projecttext',0
								dd offset radcol.properties
								dd 00C0F0F0h
								db 'Property',0
								dd offset radcol.propertiestext
								dd 0
								db 'Propertytext',0
								dd offset radcol.info
								dd 00C0F0F0h
								db 'Info',0
								dd offset radcol.infotext
								dd 0
								db 'Infotext',0
								dd offset radcol.dialogedit
								dd 00C0F0F0h
								db 'Dialog',0

iniColorsBack					dd offset racol.cmntback
								dd 00C0F0F0h
								db 'CmntBack',0
								dd offset racol.strback
								dd 00C0F0F0h
								db 'StrBack',0
								dd offset racol.numback
								dd 00C0F0F0h
								db 'NumBack',0
								dd offset racol.oprback
								dd 00C0F0F0h
								db 'OperBack',0
								dd 0

szStringsW						dw 'S','t','r','i','n','g','s',0

szhhctrl						db 'hhctrl.ocx',0
szHtmlHelpA						db 'HtmlHelpA',0

; fearless Added 01/03/2017 - allow F1/CTRL+F1 search online for keyword. CTRL+ALT+G is for google, CTRL+ALT+M is for MSDN.
szGoogleHomeAddress             DB "http://www.google.com",0
szMSDNHomeAddress               DB "http://msdn.microsoft.com",0
szGoogleSearchUrl               DB "https://www.google.com/search?q=",0
szMSDNSearchUrl                 DB "https://social.msdn.microsoft.com/search/en-us/?query=",0
szWebOpeningUrl                 DB "Opening url: ",0
szWebSearchingFor               DB "Online search for: ",0
szWebSearchCRLF                 DB 13,10,0
szWebSearchKeyword              DB MAX_PATH DUP (0)
szWebSearchInfo                 DB MAX_PATH DUP (0)
szShellOpen                     DB "Open",0 
OnlineHelpProvider              DD 0
OnlineHelpUseF1                 DD 0
; ---

szPropertyDescriptionText       DB "Property Description",0

;#########################################################################

.data?

;Handeles
hAddins							ADDIN MAX_ADDIN dup(<?>)
;Do not insert or move, just add
hWnd							dd ?
hMenu							dd ?
hToolBar						dd ?
hStatus							dd ?
hClient							dd ?
hMdiCld							dd ?
hEdit							dd ?
hDialog							dd ?
hSearch							dd ?	;handle to the search/replace dialog box
hGoTo							dd ?
hOut							dd ?
hPbr							dd ?
hTlb							dd ?
hPrp							dd ?
hPrpCbo							dd ?
hPrpLst							dd ?
hPrpTxt							dd ?
hTxtLst							dd ?
hTxtBtn							dd ?
hLB								dd ?
hTlt							dd ?
hInstance						dd ?
hToolMenu						dd ?
hTab							dd ?
hPbrTrv							dd ?
hPrpTbrCode						dd ?
hPbrTbr							dd ?
hFileTrv						dd ?
hOutREd							dd ?
hOut1							dd ?
hOut2							dd ?
hOut3							dd ?
hOutBtn1						dd ?
hOutBtn2						dd ?
hOutBtn3						dd ?
hDivider						dd ?
hSniplet						dd ?
hToolTip						dd ?
hLBU							dd ?
hLBS							dd ?
hInf							dd ?
hInfEdt							dd ?
hTl1							dd ?
hTl2							dd ?
hHexEd							dd ?
hAccel							dd ?
hTbrIml							dd ?
hTypeIml						dd ?
hPrpTxtMulti					dd ?
hLBFont							dd ?
hTTFont							dd ?
hFont							dd 3 dup(?) ;Normal,Italic,Linenumber
hFontTxt						dd ?
hFontHex						dd ?
hFullScreen						dd ?
hFound							dd ?
hPrpTxtDesc						dd ?
;Do not insert or move, just add

ofn								OPENFILENAME <?>
icex							INITCOMMONCONTROLSEX <?>  ;structure for DateTimePicker

;Menu
fAutoLoadPro					dd ?
ProMenuID						dd ?
MenuID							dd ?
MenuPtr							dd ?
MenuData						db 128*(sizeof MENU) dup(?)

;Edit
TabToSpc						dd ?
Backup							dd ?
AutoSave						dd ?
AutoIndent						dd ?
ShowProperties					dd ?
MouseWheel						dd ?
SaveSize						dd ?
ApiConst						dd ?
CodeWriteMacro					dd ?
ApiWordConv						dd ?
ApiWordLocal					dd ?
ApiShiftSpace					dd ?
SingleInstance					dd ?
HiliteLine						dd ?
HiliteCmnt						dd ?
fAutoRefresh					dd ?
fEnterOnTab						dd ?
fProcInSBar						dd ?
fOpenCollapsed					dd ?
fCodeTooltip					dd ?
fChangeNotify					dd ?
fMinimize						dd ?
nLnSpc							dd ?
fAutoBrackets					dd ?

szTltSel						dd 64 dup(?)
szApiEnd						db 2 dup(?)
szCodeFiles						db 64 dup(?)
LnrOnOpen						dd ?
nPageSize						dd ?

;Dialog
fGrid							dd ?
Gridcx							dd ?
Gridcy							dd ?
GridColor						dd ?
fGridLine						dd ?
fSnapToGrid						dd ?
fShowSizePos					dd ?
fSaveRcFile						dd ?
fSimpleProperty					dd ?
fLimittedFont					dd ?
DlgIDN							dd ?
CtrlIDN							dd ?

;Print
PrnPageNumber					dd ?
PrnHeading						dd ?
PrnTime							dd ?
PrnProDes						dd ?
PrnUseColors					dd ?
PrnColors						dd 5+16 dup(?)

Line							dd ?
Col								dd ?
nPage							dd ?
cpLine							dd ?

mdis							MDICREATESTRUCT <?>
ToolBox							db 64 dup(?)
Project							db 64 dup(?)
Output							db 64 dup(?)
Property						db 64 dup(?)
TabTool							db 64 dup(?)
InfoTool						db 64 dup(?)
Tool1							db 64 dup(?)
Tool2							db 64 dup(?)
Clipping						db 64 dup(?)
fDivider						dd ?
fMultiLine						dd ?
fRightCaption					dd ?

;Project
ProjectType						db 64 dup(?)
ProjectDescr					db 128 dup(?)
fDebug							dd ?
fGroup							dd ?
fGroupExpand					dd ?
fExpand							dd ?

iniBuffer						db MAX_PATH dup(?)

;Files
ProjectFile						db MAX_PATH dup(?)
iniFile							db MAX_PATH dup(?)
iniAsmFile						db MAX_PATH dup(?)
lngFile							db MAX_PATH dup(?)
FileName						db MAX_PATH dup(?)
AltFileName						db MAX_PATH dup(?)

;Paths
AppPath							db MAX_PATH dup(?)
App								db MAX_PATH dup(?)
Bin								db MAX_PATH dup(?)
CurPro							db MAX_PATH dup(?)
AddIn							db MAX_PATH dup(?)
Dbg								db MAX_PATH dup(?)
Hlp								db MAX_PATH dup(?)
Incl							db MAX_PATH dup(?)
Lib								db MAX_PATH dup(?)
Mac								db MAX_PATH dup(?)
Pro								db MAX_PATH dup(?)
Snp								db MAX_PATH dup(?)
Tpl								db MAX_PATH dup(?)

ProjectPath						db MAX_PATH dup(?)
BackupPath						db MAX_PATH dup(?)
FilePath						db MAX_PATH dup(?)
FilePaths						db 10*MAX_PATH dup(?)
FileFilter						db 256 dup(?)

;Color
fUseHighLight					dd ?
fUseDivLine						dd ?
fNoFlicker						dd ?

racol							RACOLOR <?>
radcol							RADCOLOR <?>
backcol							dd 20 dup(?)
CustColors						dd 16 dup(?)
lpcc							CHOOSECOLOR <?>

;Font
fntwt							dd ?
fntht							dd ?
prnOrientation					dd ?
prnInches						dd ?

;Handeles
hRichEdit						dd ?
hRAEdit							dd ?
hRAHexEd						dd ?
hRAGrid							dd ?
hMainHeap						dd ?
hBoxIml							dd ?
hIcon							dd ?
hCursor							dd ?
hSplitCurV						dd ?
hSplitCurH						dd ?
hBrTlt							dd ?
hBrPrp							dd ?
hBrInfo							dd ?
hBrDlg							dd ?

ASMSyntaxArray					dd 256 dup(?)
OldHexEditProc					dd ?
OldEditProc						dd ?
OldClientProc					dd ?
OldListBoxProc					dd ?

;Template file types
szFTTxt							db 256 dup(?)
szFTBin							db 256 dup(?)

;Sniplets
fSelectAll						dd ?
nCopyTo							dd ?
fClose							dd ?
fExpanded						dd ?
SnipLeft						dd ?
SnipTop							dd ?
SnipWidth						dd ?
SnipHeight						dd ?
SnipSplit						dd ?

;KeyHelp
nF1								dd ?
F1								db 256 dup(?)
nCF1							dd ?
CF1								db 256 dup(?)
nSF1							dd ?
SF1								db 256 dup(?)
nCSF1							dd ?
CSF1							db 256 dup(?)

;MDI Window
winX							dd ?
winY							dd ?
winWt							dd ?
winHt							dd ?
winM							dd ?
winT							dd ?
winTbr							dd ?
winSbr							dd ?

PosFindLeft						dd ?
PosFindTop						dd ?
PosGotoLeft						dd ?
PosGotoTop						dd ?
PosProWizLeft					dd ?
PosProWizTop					dd ?
PosProOptLeft					dd ?
PosProOptTop					dd ?
PosProOptWt						dd ?

tlti							TOOLINFO <>

txtrng							TEXTRANGE <>
mpt								POINT <>

;Code complete
szInvoke						db 256 dup(?)
szInclude						db 32 dup(?)
szIncludeSt						db 32 dup(?)
szIncludeEn						db 32 dup(?)
szIncludeLib					db 32 dup(?)
szIncludeLibSt					db 32 dup(?)
szIncludeLibEn					db 32 dup(?)
;Comment block
CmntBlockStart					db 32 dup(?)
CmntBlockEnd					db 32 dup(?)
szCmntChar						db 8 dup(?)

;Find/Replace
FindBuffer						db 256 dup(?)
FindBufferFixed					db 256 dup(?)
ReplaceBuffer					db 256 dup(?)
ReplaceBufferFixed				db 256 dup(?)
uFlags							dd ?
fFind							dd ?
fReplaceAll						dd ?
findchrg						CHARRANGE <>
findtext						FINDTEXTEX <>
fProSearch						dd ?
ProFileNo						dd ?
fMatchCase						dd ?
fWholeWord						dd ?
fIgnoreWhiteSpace				dd ?
fProjectSearch					dd ?
fSearchUp						dd ?
fSearchAll						dd ?
hSrcMem							dd ?
nUpdated						dd ?

;Properties
hPrpCboCode						dd ?
hPrpCboDlg						dd ?
hPrpLstCode						dd ?
hPrpLstDlg						dd ?
lbHt							dd ?
lbTp							dd ?


;Misc
CommandLine						dd ?
fApi							dd ?
fInc							dd ?
fLib							dd ?
fLBConst						dd ?
fLBStruct						dd ?
fLBWord							dd ?
fLBType							dd ?
fTltLine						dd ?
fEatChar						dd ?
lptrApi							dd ?
LineSt							dd ?
LineEn							dd ?
REdPos							dd ?
ProcPos							dd ?
szProcName						db 64 dup(?)
fLocal							dd ?
fProperty						dd ?

WordListSize					dd ?

;16 positions
RetPos							dd 17*2 dup(?)
nMaxChar						dd ?

;32 bookmarks
iBookMark						dd ?
iErrorBookMark					dd ?
BookMark						dd 33*3 dup(?)
BreakPoint						dd 256*3 dup(?)
ErrorBookMark					dd 128*3 dup(?)
BreakPointVar					db 2048 dup(?)
nMaxLine						dd ?
LastLine						dd ?
LastCol							dd ?

MdiID							dd ?

;Splash
hSplash							dd ?
SplashBmp						db 256 dup(?)
Splashtc						dd ?

;Error
fErrBookMark					dd ?

;Code properties
PrpCboItems						db 256 dup(?)
szCPSkip						db 256 dup(?)
szCPCode						db 256 dup(?)
szCPCode2						db 256 dup(?)
szCPLabel						db 256 dup(?)
szCPLocal						db 256 dup(?)
szCPConst						db 256 dup(?)
szCPData						db 256 dup(?)
szCPMacro						db 256 dup(?)
szCPStruct						db 256 dup(?)
szCPStruct2						db 256 dup(?)
szCP0							db 256 dup(?)
szCP1							db 256 dup(?)
szCP2							db 256 dup(?)
szCP3							db 256 dup(?)

;Pro find
szSrcEnd						db 64 dup(?)
szSrc							db 192 dup(?)

OldHtWt							dd ?
nLineTick						dd ?

;Code blocks
MAXBLOCKDEF						equ 24
rablkdefstr						db 2048 dup(?)
rablkdef						RABLOCKDEF MAXBLOCKDEF dup(<?>)
								dd ?

mdirect							RECT <?>
psd								PAGESETUPDLG <?>
pd								PRINTDLG <?>
cpd								COPYDATASTRUCT <?>
wfd								WIN32_FIND_DATA <?>
hEnv							dd ?
LineStart						dd ?
LinePos							dd ?
tempbuff						db 16384 dup(?)
								dd ?
LineTxt							db 16384 dup(?)
								dd ?
LineWord						db 256 dup(?)
								dd ?
prnbuff							db 16384 dup(?)
								dd ?
FileToCopy						db MAX_PATH dup(?)
NameToCopy						db MAX_PATH dup(?)
FileCutFlag						dd ?
nLastLine						dd ?
RecentFiles						db 10*256 dup(?)
infoshowcp						dd ?
infoshowpt						POINT <?>
infoshowhwnd					dd ?
szLbString						db 64 dup(?)
hMnuRecent						dd ?
hMnuAsm							dd ?
hMnuDlg							dd ?
hDivLine						dd ?
SRCFilterString					db 128 dup(?)
DefSrcExt						db 32 dup(?)
HDRFilterString					db 128 dup(?)
DefHdrExt						db 32 dup(?)
MODFilterString					db 128 dup(?)
DefModExt						db 32 dup(?)
scrnsize						SCRNSIZE <?>
hFontIde						dd ?
nLngSize						dd ?
hLngDlg							dd ?
fLngNoSize						dd ?
hIniMem							dd ?
osvi							OSVERSIONINFO <?>
lbItehHeight					dd ?
fNewDialog						dd ?
hTabSet							dd ?
nTabSet							dd ?
fProExp							dd ?
szaccept						db 16384 dup(?)
sztempaccept					db 8192 dup(?)
IsDragging						dd ?
groupgrp						PROGROUP 64 dup(<>)
lpOldTabProc					dd ?
tabinx							dd ?
fCancelSave						dd ?
hNoSave							dd 128 dup(?)
hHtmlOcx 						HMODULE ?
pHtmlHelpProc 					dd ?
hHHwin							HWND ?
hhaklink						HH_AKLINK <>
groupstate						dd 128 dup(?)
