
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include comdlg32.inc
include shell32.inc
include gdi32.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib comdlg32.lib
includelib shell32.lib
includelib gdi32.lib

;Debug
include masm32.inc
include \RadASM\Masm\Inc\Debug.Inc
includelib masm32.lib
includelib \RadASM\Masm\Lib\Debug.lib

DlgProc							PROTO	:HWND,:UINT,:WPARAM,:LPARAM
IDD_DIALOG1						equ 101
IDC_TBR1						equ 1001
IDC_TBR2						equ 1004
IDC_TBR3						equ 1003
IDC_LST1						equ 1003
IDC_EDT1						equ 1004
IDC_BTN1						equ 1005
IDC_EDT2						equ 1006
IDC_BTN2						equ 1007
IDC_BTN3						equ 1008
IDC_BTN4						equ 1012
IDC_TRBLANGOPT					equ 1002

;#########################################################################

IDI_MDIICO						equ 100
IDB_MDITBR						equ 101
IDB_PROWIZ						equ 103
IDB_TOOLBOX						equ 104
IDB_CUSTCTL						equ 106
IDC_SPLICURV					equ 150
IDC_SPLICURH					equ 151

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

IDM_OPTION_EDIT					equ 48003
IDM_OPTION_COLORS				equ 48001
IDM_OPTION_PRNCOLORS			equ 48015
IDM_OPTION_DIALOG				equ 48004
IDM_OPTION_FONTS				equ 44014
IDM_OPTION_ACCEL				equ 48017
IDM_OPTION_FILEASS				equ 44021
IDM_OPTION_FILEBROWSER			equ 48012
IDM_OPTION_EXTERNALFILE			equ 48013
IDM_OPTION_SNIPLET				equ 48005
IDM_OPTION_PATHS				equ 48006
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
IDM_PROMNU_AUTOLOAD				equ 50004
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

IDM_USERBTN1					equ 29991
IDM_USERBTN2					equ 29992

.const

tbrbtns							TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <24,IDM_FILE_PRINT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <6,IDM_FILE_NEWFILE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <7,IDM_FILE_OPENFILE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <8,IDM_FILE_SAVEFILE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <14,IDM_FILE_SAVEALLFILES,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <0,IDM_EDIT_CUT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <1,IDM_EDIT_COPY,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <2,IDM_EDIT_PASTE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <3,IDM_EDIT_UNDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <4,IDM_EDIT_REDO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <5,IDM_EDIT_DELETE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <12,IDM_EDIT_FIND,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <13,IDM_EDIT_REPLACE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <20,IDM_EDIT_TOGGLEBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <21,IDM_EDIT_NEXTBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <22,IDM_EDIT_PREVIOUSBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <23,IDM_EDIT_CLEARBM,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <26,IDM_FORMAT_INDENT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <25,IDM_FORMAT_OUTDENT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <27,IDM_FORMAT_COMMENT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <28,IDM_FORMAT_UNCOMMENT,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <9,IDM_VIEW_OUTPUTWINDOW,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
								TBBUTTON <10,IDM_VIEW_PROJECTBROWSER,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
								TBBUTTON <11,IDM_VIEW_TOOLBOX,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
								TBBUTTON <19,IDM_VIEW_PROPERTIES,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <15,IDM_MAKE_ASSEMBLE,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <16,IDM_MAKE_BUILD,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <17,IDM_MAKE_RUN,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <18,IDM_MAKE_GO,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <39,IDM_USERBTN1,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <40,IDM_USERBTN2,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
ntbrbtns						equ 43

pbrtbrbtns						TBBUTTON <10,11,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
								TBBUTTON <36,12,TBSTATE_ENABLED,TBSTYLE_BUTTON or	TBSTYLE_CHECK,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <34,13,TBSTATE_ENABLED	or TBSTATE_CHECKED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
								TBBUTTON <15,14,TBSTATE_ENABLED	or TBSTATE_CHECKED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
								TBBUTTON <35,15,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <37,16,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
								TBBUTTON <38,17,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
npbrtbrbtns						equ	9

prptbrbtns						TBBUTTON <29,1,TBSTATE_ENABLED or TBSTATE_CHECKED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
								TBBUTTON <30,2,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
								TBBUTTON <31,3,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
								TBBUTTON <32,4,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
								TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
								TBBUTTON <33,5,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
nprptbrbtns						equ 6


;#########################################################################

dialogs							dd 102
								db '[102] Find..',0
								dd 103
								db '[103] Goto Line',0
								dd 150
								db '[150] Project Wizard',0
								dd 151
								db '[151] Project Wizard - Type & Name',0
								dd 152
								db '[152] Project Wizard - Template',0
								dd 153
								db '[153] Project Wizard - Files & Folders',0
								dd 154
								db '[154] Project Wizard - Make',0
								dd 155
								db '[155] Project Wizard - Import',0

								dd 2000
								db '[2000] Create Template',0
								dd 2200
								db '[2200] Sniplet Options',0
								dd 2300
								db '[2300] Paths Setup',0
								dd 2500
								db '[2500] Menu Editor',0
								dd 2600
								db '[2600] Dialog Editor Options',0
								dd 2700
								db '[2700] Project Options',0
								dd 2800
								db '[2800] Code Editor Options',0
								dd 2900
								db '[2900] Version Info',0

								dd 3000
								db "[3000] Export ID Equ's To Output",0
								dd 3100
								db '[3100] Sniplet Browser',0
								dd 3200
								db '[3200] Make Menu,Tools Menu,Help Menu,Macro Menu,Macro Add',0
								dd 3300
								db '[3300] Dialog Styles',0
								dd 3400
								db '[3400] RadASM Macro Recorder',0
								dd 3500
								db '[3500] Printer option',0
								dd 3600
								db '[3600] Resource',0
								dd 3700
								db '[3700] String table',0
								dd 3800
								db '[3800] Add breakpoint variable',0
								dd 3900
								db '[3900] Tool Windows Options',0

								dd 4000
								db '[4000] File Browser Option',0
								dd 4100
								db '[4100] External File Option',0
								dd 4200
								db '[4200] Colors & KeyWords',0
								dd 4300
								db '[4300] Find ...',0
								dd 4400
								db '[4400] Main Project Files',0
								dd 4500
								db '[4500] Project Groups',0
								dd 4600
								db '[4600] Menu Accelerators',0
								dd 4700
								db '[4700] Accelerators',0
								dd 4800
								db '[4800] Scan Project',0
								dd 4900
								db '[4900] About',0

								dd 5000
								db '[5000] Language',0
								dd 5100
								db '[5100] Font options',0
								dd 5200
								db '[5200] Block Insert',0
								dd 5300
								db '[5300] File Association',0
								dd 5400
								db '[5400] Language Option',0
								dd 5500
								db '[5500] Programming Languages',0
								dd 5600
								db '[5600] Custom Controls',0
								dd 6000
								db '[6000] Environment Variables',0

								dd 997
								db '[997] ToolBars',0
								dd 998
								db '[998] Context Menus',0
								dd 999
								db '[999] Main Menu',0
								dd 0
								db 0

szRadLNG						db 'RadASM language pack',0
szRAEditDLL						db 'RAEdit.dll',0
szRAEditErr						db 'RAEdit.dll not found!',0
szRAGridDLL						db 'RAGrid.dll',0
szRAGridErr						db 'RAGrid.dll not found!',0
szSaveChanges					db 'Save changes?',0
szCouldNotSave					db 'Could not save the file!',0
szNULL							db 0
szRadLNGIni						db 'RadLNG.ini',0
szRadLNGFile					db 'RadENG.lng',0
szFilter						db 'Language Files (*.lng)',0,'*.lng',0
								db 'All Files (*.*)',0,'*.*',0,0
szLeftBr						db '[',0
szRightBr						db ']',0
szEqu							db '=',0
szCrLf							db 0Dh,0Ah,0
szComma							db ',',0
szDivider						db ';--------------------------------------------------------------------------------',0Dh,0Ah,0
szIniLang						db '[Lang]',0Dh,0Ah,'Lang=English (Default)',0Dh,0Ah,0
szLang							db 'Lang',0
szFont							db 'Font',0
szSize							db 'Size',0
szUDCCLASS						db 'UDCCLASS',0
szStrings						db '[Strings]',0Dh,0Ah,0
szStringsW						dw 'S','t','r','i','n','g','s',0
szEmptyW						dw '(','E','m','p','t','y',')',0
szAddins						db '[AddinMana]',0Dh,0Ah
								db 'AddinMana=RadASM Addin Manager',0Dh,0Ah
								db '1=OK',0Dh,0Ah
								db '2=Cancel',0Dh,0Ah
								db '10=Apply',0Dh,0Ah
								db '1032=Install',0Dh,0Ah
								db '1033=Uninstall',0Dh,0Ah
								db '1008=Help',0Dh,0Ah
								db '1001=Addins:',0Dh,0Ah
								db '1002=Options',0Dh,0Ah
								db '1003=Info',0Dh,0Ah
								db '1004=Description:',0Dh,0Ah
								db '1005=Author:',0Dh,0Ah
								db '1006=Version:',0Dh,0Ah
								db '1007=Date:',0Dh,0Ah
								db '2000=Addin Manager',0Dh,0Ah
								db '3000=Enable',0Dh,0Ah
								db 0
								db '[FlipCase]',0Dh,0Ah
								db '2000=Flip Case',0Dh,0Ah
								db '2001=Page Break',0Dh,0Ah
								db '3000=Flip Case',0Dh,0Ah
								db '3001=Page Break',0Dh,0Ah
								db '3002=Auto Show Output',0Dh,0Ah
								db '3003=Auto Hide Output',0Dh,0Ah
								db '3004=Auto Show ToolBox',0Dh,0Ah
								db '3005=Create Temp',0Dh,0Ah
								db '3006=No Exception Handler',0Dh,0Ah
								db '3007=Compile time',0Dh,0Ah
								db 0
								db '[PthExpl++]',0Dh,0Ah
								db 'PthExpl++=Set Minor Files',0Dh,0Ah
								db '1001=OK',0Dh,0Ah
								db '1003=Cancel',0Dh,0Ah
								db '1004=<< Add',0Dh,0Ah
								db '1005=Remove >>',0Dh,0Ah
								db '1007=Auto delete',0Dh,0Ah
								db '1008=Ask me first',0Dh,0Ah
								db '2000=Path Explore',0Dh,0Ah
								db '2001=Set Minor Files',0Dh,0Ah
								db '2002=Delete Minor Files',0Dh,0Ah
								db '3000=Enable',0Dh,0Ah
								db 0
								db '[FontBuilder]',0Dh,0Ah
								db '2000=Font Builder',0Dh,0Ah
								db 0
								db '[ProjectZip]',0Dh,0Ah
								db 'ProjectZip=RadASM project zipper',0Dh,0Ah
								db '2=Exit',0Dh,0Ah
								db '1002=Zip && E-Mail',0Dh,0Ah
								db '1004=Zip',0Dh,0Ah
								db '1007=Select all',0Dh,0Ah
								db '1009=Zip To:',0Dh,0Ah
								db '1010=Current:',0Dh,0Ah
								db '2000=Project Zipper',0Dh,0Ah
								db '3000=Enable Project zipper',0Dh,0Ah
								db '3001=Add date to zipname',0Dh,0Ah
								db 0
								db '[AsmVars]',0Dh,0Ah
								db '2000=AsmVars',0Dh,0Ah
								db '3000=Enable AsmVars',0Dh,0Ah
								db 0
								db '[asciiTab]',0Dh,0Ah
								db 'asciiTab=Esc to exit',0Dh,0Ah
								db '2000=Ascii Table',0Dh,0Ah
								db '3000=Enable Ascii Table',0Dh,0Ah
								db '4000=Ascii Table',0Dh,0Ah
								db 0
								db '[CreateProto]',0Dh,0Ah
								db 'CreateProto=Create Proto',0Dh,0Ah
								db '1=OK',0Dh,0Ah
								db '2=Cancel',0Dh,0Ah
								db '2000=Create Proto',0Dh,0Ah
								db 0
								db '[CreateProtoEx]',0Dh,0Ah
								db 'CreateProtoEx=Create Proto',0Dh,0Ah
								db '1008=Select All',0Dh,0Ah
								db '1002=Send To Output Window',0Dh,0Ah
								db '1001=Done',0Dh,0Ah
								db '1003=Create Proto in File',0Dh,0Ah
								db '1004=Enable File Creation',0Dh,0Ah
								db '1007=Creates a file of the function prototypes at every build, overwriting the old one.',0Dh,0Ah
								db '2000=Create Proto',0Dh,0Ah
								db 0
								db '[RadFavs]',0Dh,0Ah
								db '2000=Favourites',0Dh,0Ah
								db '2001=Add to favourites',0Dh,0Ah
								db '2002=Manage favourites',0Dh,0Ah
								db '[RadFavs#1]',0Dh,0Ah
								db 'RadFavs#1=Add to favourites',0Dh,0Ah
								db '1001=Label',0Dh,0Ah
								db '1003=Path',0Dh,0Ah
								db '1=OK',0Dh,0Ah
								db '2=Cancel',0Dh,0Ah
								db '[RadFavs#2]',0Dh,0Ah
								db 'RadFavs#2=Manage favourites',0Dh,0Ah
								db '1107=Label',0Dh,0Ah
								db '1108=Update',0Dh,0Ah
								db '1103=Info',0Dh,0Ah
								db '1=OK',0Dh,0Ah
								db '2=Cancel',0Dh,0Ah
								db 0
								db '[AlexMenu]',0Dh,0Ah
								db '3000=Default menu',0Dh,0Ah
								db '3001=Cool menu',0Dh,0Ah
								db '3002=Cool bar white',0Dh,0Ah
								db '3003=Cool bar blue',0Dh,0Ah
								db '3004=Cool bar green',0Dh,0Ah
								db '3005=Cool bar red',0Dh,0Ah
								db '3006=Cool body white',0Dh,0Ah
								db '3007=Cool body blue',0Dh,0Ah
								db '3008=Cool body green',0Dh,0Ah
								db '3009=Cool body red',0Dh,0Ah
								db 0
								db '[BitMask]',0Dh,0Ah
								db 'BitMask=BitMask',0Dh,0Ah
								db '141=Byte 3 (high order)',0Dh,0Ah
								db '102=Byte 2',0Dh,0Ah
								db '103=Byte 1',0Dh,0Ah
								db '104=Byte 0 (low order)',0Dh,0Ah
								db '139=Output',0Dh,0Ah
								db '140=Output',0Dh,0Ah
								db '151=Use',0Dh,0Ah
								db '142=NOT',0Dh,0Ah
								db '143=RESET',0Dh,0Ah
								db '149=Hexadecimal',0Dh,0Ah
								db '150=Decimal',0Dh,0Ah
								db '3000=Enable Bitmask',0Dh,0Ah
								db '4000=Bit mask generator',0Dh,0Ah
								db 0
								db '[Colref]',0Dh,0Ah
								db 'Colref=Color',0Dh,0Ah
								db '740=Basic colors',0Dh,0Ah
								db '741=Custom colors',0Dh,0Ah
								db '730=Color',0Dh,0Ah
								db '731=Solid',0Dh,0Ah
								db '723=Hue:',0Dh,0Ah
								db '724=Sat:',0Dh,0Ah
								db '725=Lum:',0Dh,0Ah
								db '726=Red:',0Dh,0Ah
								db '727=Green:',0Dh,0Ah
								db '728=Blue:',0Dh,0Ah
								db '1007=RGB (red,green,blue): ',0Dh,0Ah
								db '1008=HEX value: ',0Dh,0Ah
								db '1009=DEC value: ',0Dh,0Ah
								db '719=&Define Custom Colors >>',0Dh,0Ah
								db '1=OK',0Dh,0Ah
								db '2=Cancel',0Dh,0Ah
								db '105=Capture',0Dh,0Ah
								db '104=Color Ref',0Dh,0Ah
								db '712=&Add to Custom Colors',0Dh,0Ah
								db '1038=Help',0Dh,0Ah
								db '1001=Insert',0Dh,0Ah
								db '1002=Insert',0Dh,0Ah
								db '1003=Insert',0Dh,0Ah
								db '2000=Colref',0Dh,0Ah
								db '3000=Enable color reference',0Dh,0Ah
								db '3001=Disable color flashing',0Dh,0Ah
								db '3002=Disable blue dialog',0Dh,0Ah
								db '4000=Color reference',0Dh,0Ah
								db 0
								db '[Preview]',0Dh,0Ah
								db '4000=Preview dialog',0Dh,0Ah
								db 0
								db '[RadToolBar]',0Dh,0Ah
								db '3000=Enable custom ToolBar',0Dh,0Ah
								db '3001=Use phoenity buttons',0Dh,0Ah
								db '3002=Use grayed images',0Dh,0Ah
								db '3003=Extract tool icons',0Dh,0Ah
								db '3004=Use tool icon files',0Dh,0Ah
								db 0
								db '[RADbg]',0Dh,0Ah
								db 'RADbg=RadASM debug',0Dh,0Ah
								db '1004=Hex',0Dh,0Ah
								db '1005=Dec',0Dh,0Ah
								db '1006=Bin',0Dh,0Ah
								db '1002=Clear',0Dh,0Ah
								db '1001=Terminate',0Dh,0Ah
								db '1=OK',0Dh,0Ah
								db '3000=Show debug dialog',0Dh,0Ah
								db '3001=Int 3 debug',0Dh,0Ah
								db '3002=Result to output',0Dh,0Ah
								db 0
								db '[ReallyRad]',0Dh,0Ah
								db 'ReallyRad=ReallyRad Options',0Dh,0Ah
								db '201=Auto add dialog',0Dh,0Ah
								db '202=Auto add menu',0Dh,0Ah
								db '203=Auto update resource',0Dh,0Ah
								db '207=Auto update string table',0Dh,0Ah
								db '205=Auto add main RC file',0Dh,0Ah
								db '206=Auto create Res folder',0Dh,0Ah
								db '204=Auto update versioninfo',0Dh,0Ah
								db '208=Auto update resources',0Dh,0Ah
								db '301=Control double click',0Dh,0Ah
								db '302=Dialog menu select',0Dh,0Ah
								db '303=Unique control names',0Dh,0Ah
								db '304=Check module build time',0Dh,0Ah
								db '1=OK',0Dh,0Ah
								db '2=Cancel',0Dh,0Ah
								db '10=Apply',0Dh,0Ah
								db '2000=ReallyRad',0Dh,0Ah
								db '2001=ReallyRad - CodeWrite',0Dh,0Ah
								db '3000=Enable ReallyRad',0Dh,0Ah
								db '[ReallyRad#2]',0Dh,0Ah
								db 'ReallyRad#2=ReallyRad - CodeWrite',0Dh,0Ah
								db '9006=Module Name:',0Dh,0Ah
								db '9007=Template:',0Dh,0Ah
								db '9008=Proc name',0Dh,0Ah
								db '1=OK',0Dh,0Ah
								db '2=Cancel',0Dh,0Ah
								db 0
								db '[StyleMana]',0Dh,0Ah
								db 'StyleMana=Style manager',0Dh,0Ah
								db '1004=&DWORD:',0Dh,0Ah
								db '1003=Update',0Dh,0Ah
								db '2=Close',0Dh,0Ah
								db 0
								db '[RADebug]',0Dh,0Ah
								db 'RADebug=Do not debug',0Dh,0Ah
								db '1007=Do not debug:',0Dh,0Ah
								db '1008=Debug:',0Dh,0Ah
								db '1=OK',0Dh,0Ah
								db '2=Cancel',0Dh,0Ah
								db '2000=Deb&ug:',0Dh,0Ah
								db '2001=Toggle &Breakpoint	Ctrl+T',0Dh,0Ah
								db '2002=&Clear Breakpoints	Ctrl+Shift+T',0Dh,0Ah
								db '2003=&Run	Shift+F7',0Dh,0Ah
								db '2004=Brea&k	Ctrl+Alt+F7',0Dh,0Ah
								db '2005=&Stop	Alt+F7',0Dh,0Ah
								db '2006=Step &Into	F7',0Dh,0Ah
								db '2007=Step &Over	Ctrl+F7',0Dh,0Ah
								db '2008=Run &To Caret	Ctrl+Shift+F7',0Dh,0Ah
								db '2009=Do not Debug',0Dh,0Ah
								db '2010=Debug Window',0Dh,0Ah
								db 0,0

szWiz1							db 'Project Wizard - Type & Name',0
szWiz2							db 'Project Wizard - Template',0
szWiz3							db 'Project Wizard - Files & Folders',0
szWiz4							db 'Project Wizard - Make',0

.data

lfnt							LOGFONT <-11,0,0,0,0,0,0,0,0,0,0,0,0,'MS Sans Serif'>

.data?

hInstance						dd ?
hRAEdit							dd ?
hRAGrid							dd ?
hIcon							dd ?
hDlg							HWND ?
hEdt							HWND ?
lngIni							db MAX_PATH dup(?)
lngFile							db MAX_PATH dup(?)
szText							db 1024 dup(?)
ofn								OPENFILENAME <?>
hLngFont						dd ?
nSize							dd ?
hLngDlg							dd ?
hIniMem							dd ?

;#########################################################################
