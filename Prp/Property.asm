;.686
;.MMX
;.XMM
;
;DEBUG32 EQU 1
;
;IFDEF DEBUG32
;    PRESERVEXMMREGS equ 1
;    includelib M:\Masm32\lib\Debug32.lib
;    DBG32LIB equ 1
;    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
;    include M:\Masm32\include\debug32.inc
;ENDIF


.const

tbrbtns					TBBUTTON <29,1,TBSTATE_ENABLED or TBSTATE_CHECKED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <30,2,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <31,3,0,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <32,4,0,TBSTYLE_BUTTON or TBSTYLE_CHECK or TBSTYLE_GROUP,0,0>
						TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
						TBBUTTON <33,5,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
ntbrbtns				equ 6

NumID					equ 1
NumPosL					equ 2
NumPosT					equ 3
NumSizeW				equ 4
NumSizeH				equ 5
NumStartID				equ 6
NumTab					equ 7

StrNme					equ 100
StrCap					equ 101
StrCapMulti				equ 102

IDD_PROPERTY			equ 3300
IDC_EDTSTYLE			equ 3301
IDC_BTNLEFT				equ 3302
IDC_BTNRIGHT			equ 3303
IDC_BTNSET				equ 3304
IDC_STCWARN				equ 3305
IDC_STCTXT				equ 3306

; Property IDs
Property_NumID          EQU 1
Property_Left           EQU 2
Property_Top            EQU 3
Property_Width          EQU 4
Property_Height         EQU 5
Property_StartID        EQU 6
Property_TabIndex       EQU 7

Property_Name           EQU 100
Property_Caption        EQU 101
Property_MultiCaption   EQU 102

Property_SysMenu        EQU 200
Property_MaxButton      EQU 201
Property_MinButton      EQU 202
Property_Enabled        EQU 203
Property_Visible        EQU 204
Property_Default        EQU 205
Property_Auto           EQU 206
Property_AutoPlay       EQU 206
Property_AutoSize       EQU 206
Property_Mnemonic       EQU 207
Property_WordWrap       EQU 208
Property_MultiLine      EQU 209
Property_MultiSelect    EQU 209
Property_Locked         EQU 210
Property_Child          EQU 211
Property_SizeBorder     EQU 212
Property_SizeGrip       EQU 212
Property_TabStop        EQU 213
Property_Notify         EQU 214
Property_WantCR         EQU 215
Property_SortList       EQU 216
Property_Flat           EQU 217
Property_Group          EQU 218

Property_UseTabs        EQU 220
Property_SetBuddy       EQU 221
Property_HideSelection  EQU 222
Property_TopMost        EQU 223
Property_IntegralHeight EQU 224
Property_Buttons        EQU 225
Property_PopUp          EQU 226
Property_OwnerDrawBtn   EQU 227
Property_OwnerDrawLsv   EQU 227
Property_Transparent    EQU 228
Property_Timer          EQU 229
Property_WeekNum        EQU 230
Property_ToolTip        EQU 231
Property_WrapToolbar    EQU 232
Property_DividerToolbar EQU 233
Property_DragDrop       EQU 234
Property_ProgressSmooth EQU 235
Property_HasStrings     EQU 236

Property_Clipping       EQU 300
Property_ScrollBar      EQU 301
Property_Alignment      EQU 302
Property_AutoScroll     EQU 303
Property_Format         EQU 304
Property_StartupPos     EQU 305
Property_Orientation    EQU 306
Property_SortListview   EQU 307
Property_OwnerDrawCbo   EQU 308
Property_Ellipsis       EQU 309

Property_Border         EQU 400
Property_Type           EQU 401

Property_Font           EQU 1000
Property_Class          EQU 1001
Property_Menu           EQU 1002
Property_xExStyle       EQU 1003
Property_xStyle         EQU 1004
Property_Image          EQU 1005
Property_AviClip        EQU 1006

Property_CustomControl  EQU 65535




.data

; Property Descriptions
szProperty_Null           DB 0,0,0,0
szProperty_NumID          DB "Specifies the numeric id used to identify the control.",0
szProperty_Left           DB "Specifies the distance between the left edge of a control and its parent.",0
szProperty_Top            DB "Specifies the distance between the top edge of a control and its parent.",0
szProperty_Width          DB "Specifies the width of a control on the screen.",0
szProperty_Height         DB "Specifies the height of a control on the screen.",0
szProperty_StartID        DB "Specifies the start index of numeric control ids when adding controls to a dialog.",0
szProperty_TabIndex       DB "Specifies the tab order of a control on a dialog.",0

szProperty_Name           DB "Specifies the text name used to reference a control in code.",0
szProperty_Caption        DB "Specifies the text displayed in a control or dialog/window title.",0
szProperty_MultiCaption   DB "Specifies the text displayed in a control.",0

szProperty_SysMenu        DB "Specifies whether the window has a window menu on its title bar. The WS_CAPTION style must also be specified.",0
szProperty_MaxButton      DB "Specifies whether a dialog/window has a Maximize button.",0
szProperty_MinButton      DB "Specifies whether a dialog/window has a Minimize button.",0
szProperty_Enabled        DB "Specifies whether a control can respond to input/interaction.",0
szProperty_Visible        DB "Specifies whether a control or window is visible or hidden.",0
szProperty_Default        DB "Specifies which command button or control responds to the ENTER key being pressed when there are two or more command buttons on an active dialog.",0
szProperty_Auto           DB "Specifies automatic state of checkbox or radio control, where the system auto toggles display of the checkbox or radio mark.",0
szProperty_AutoPlay       DB "Specifies if the media file associated with the control is automatically played.",0
szProperty_AutoSize       DB "Specifies whether a control is automatically resized to fit its contents.",0
szProperty_Mnemonic       DB "Specifies whether a mnemonic is supported. The input focus is moved to the control associated with the mnemonic whenever the user either presses the key that corresponds to the mnemonic or presses the key and the ALT key in combination.",0
szProperty_WordWrap       DB "Specifies whether text is wrapped around the edges of the control to display within the bounds of the control.",0
szProperty_MultiLine      DB "Specified whether text displays on a single line or multiple lines within a control.",0
szProperty_MultiSelect    DB "Specifies whether a user can make multiple selections in a control or just a single selection.",0
szProperty_Locked         DB "Specifies whether the control is locked and prevented from being moved in design mode.",0
szProperty_Child          DB "Specifies whether a window/control is a child of another window/control. A window with this style cannot have a menu bar. This style cannot be used with the WS_POPUP style.",0
szProperty_SizeBorder     DB "Specifies whether a window is resizable by user at runtime.",0
szProperty_SizeGrip       DB "Specifies whether a statusbar shows a sizing grip to indicate that the associated window can be resized by the user.",0
szProperty_TabStop        DB "Specifies whether a user can use the TAB key to move the focus to a control.",0
szProperty_Notify         DB "Specifies if the control will notify the parent of any supported interactions, for example mouse clicks etc.",0
szProperty_WantCR         DB "Specifies if the control will process carriage returns (Enter/Return key)",0
szProperty_SortList       DB "Specifies if the listbox items are sorted.",0
szProperty_Flat           DB " ",0
szProperty_Group          DB "Specifies whether the control is the first control of a group of controls. The group consists of this first control and all controls defined after it, up to the next control with the WS_GROUP style.",0

szProperty_UseTabs        DB " ",0
szProperty_SetBuddy       DB " ",0
szProperty_HideSelection  DB "Specifies if the selected text or item is not displayed as selectied/highlighted when the control loses focus.",0
szProperty_TopMost        DB "Specifies if the window/control is set as the topmost window - the highest window in the z-order.",0
szProperty_IntegralHeight DB "Specifies that the size of the list box is exactly the size specified by the application when it created the list box. Normally, the system sizes a list box so that the list box does not display partial items.",0
szProperty_Buttons        DB "Specified if the treeview control shows +/- buttons before nodes.",0
szProperty_PopUp          DB "Specifies whether the window/control is a pop-up window. This style cannot be used with the WS_CHILD style.",0
szProperty_OwnerDrawBtn   DB "Specifies if the drawing of the control is handled automatically by the system or is owner drawn and managed by user code.",0
szProperty_OwnerDrawLsv   DB "Specifies if the drawing of the control is handled automatically by the system or is owner drawn and managed by user code.",0
szProperty_Transparent    DB "Specifies if the animation control uses transparent background.",0
szProperty_Timer          DB "Specifies if the animation control uses a timer.",0
szProperty_WeekNum        DB "Specifies if the week number is displayed in the monthview control.",0
szProperty_ToolTip        DB "Specifies whether the control displays tooltips when the mouse hovers over specific parts of a control, depending on the control: toolbar buttons in a toolbar, tabs in a tab control, etc",0
szProperty_WrapToolbar    DB "Specifies whether the toolbar control wraps buttons so they are always all displayed on screen on the toolbar.",0
szProperty_DividerToolbar DB "Specifies whether the toolbar control shows a divider line.",0
szProperty_DragDrop       DB " ",0
szProperty_ProgressSmooth DB "Specifies the type of progress bar used, a smooth filled bar, or an incremental stepped one.",0
szProperty_HasStrings     DB "Specifies that a list box contains items consisting of strings. The list box maintains the memory and addresses for the strings so that the application can use the LB_GETTEXT message to retrieve the text for a particular item.",0

szProperty_Clipping       DB "Specifies if clipping is used. Clip children excludes the area occupied by child windows when drawing occurs within the parent window. Clip siblings clips all other overlapping child windows out of the region of the child window to be updated.",0
szProperty_ScrollBar      DB "Specifies if the window/control includes a scrollbar: horizontal, vertical, both or none.",0
szProperty_Alignment      DB "Specifies the alignment and positioning of text displayed in the control.",0
szProperty_AutoScroll     DB "Specifies if the control automatically handles scrolling. Depending on the control this could be scrolling text into view in an edit control or items in a listbox.",0
szProperty_Format         DB "Specifies the format of the date time in the datetime picker control.",0
szProperty_StartupPos     DB "Specifies the intital starting location of the window/dialog.",0
szProperty_Orientation    DB "Specifies the angle of the hyperlink text displayed.",0
szProperty_SortListview   DB "Specifies if the listview items are sorted.",0
szProperty_OwnerDrawCbo   DB "Specifies if the drawing of the control is handled automatically by the system or is owner drawn and managed by user code.",0
szProperty_Ellipsis       DB "Specified if the control uses ellipsis. An ellipsis (…) is displayed for text that doesn’t fit in the display of the window/control.",0

szProperty_Border         DB "Specifies the type of border/frame for the window/control. For dialogs and windows specifying certain frames may result in changes to the overall type of window that is created.",0
szProperty_Type           DB "Specifies the sub-type of the control or additional style settings for a controll. Certain controls have different types associated with them, supporting varied usages.",0

szProperty_Font           DB "Specifies the font family and size used by a dialog.",0
szProperty_Class          DB "Specifies the class used as basis to create the window/control.",0
szProperty_Menu           DB "Specifies if the window uses a menu and sets the associated menu resource to use with this window.",0
szProperty_xExStyle       DB "The extended style flags used in the window/control's creation.",0
szProperty_xStyle         DB "The style flags used in the window/control's creation. Note, changing different properties in the properties list will change the style flags.",0
szProperty_Image          DB "The specified image filename to load into the control.",0
szProperty_AviClip        DB "The specified avi movie clip filename to load into the control.",0

szStyle				db 'Style',0
szExStyle			db 'ExStyle',0

szFalse				db 'False',0
szTrue				db 'True',0
;False/True Styles
SysMDlg				dd -1 xor WS_SYSMENU,0
					dd -1 xor WS_SYSMENU,WS_SYSMENU
MaxBDlg				dd -1 xor WS_MAXIMIZEBOX,0
					dd -1 xor WS_MAXIMIZEBOX,WS_MAXIMIZEBOX
MinBDlg				dd -1 xor WS_MINIMIZEBOX,0
					dd -1 xor WS_MINIMIZEBOX,WS_MINIMIZEBOX
EnabAll				dd -1 xor WS_DISABLED,WS_DISABLED
					dd -1 xor WS_DISABLED,0
VisiAll				dd -1 xor WS_VISIBLE,0
					dd -1 xor WS_VISIBLE,WS_VISIBLE
DefaBtn				dd -1 xor BS_DEFPUSHBUTTON,0
					dd -1 xor BS_DEFPUSHBUTTON,BS_DEFPUSHBUTTON
AutoChk				dd -1 xor (BS_AUTOCHECKBOX or BS_CHECKBOX),BS_CHECKBOX
					dd -1 xor (BS_AUTOCHECKBOX or BS_CHECKBOX),BS_AUTOCHECKBOX
AutoRbt				dd -1 xor (BS_AUTORADIOBUTTON or BS_RADIOBUTTON),BS_RADIOBUTTON
					dd -1 xor (BS_AUTORADIOBUTTON or BS_RADIOBUTTON),BS_AUTORADIOBUTTON
AutoCbo				dd -1 xor CBS_AUTOHSCROLL,0
					dd -1 xor CBS_AUTOHSCROLL,CBS_AUTOHSCROLL
AutoSpn				dd -1 xor UDS_AUTOBUDDY,0
					dd -1 xor UDS_AUTOBUDDY,UDS_AUTOBUDDY
AutoTbr				dd -1 xor CCS_NORESIZE,CCS_NORESIZE 
					dd -1 xor CCS_NORESIZE,0
AutoAni				dd -1 xor ACS_AUTOPLAY,0
					dd -1 xor ACS_AUTOPLAY,ACS_AUTOPLAY
MnemStc				dd -1 xor SS_NOPREFIX,SS_NOPREFIX
					dd -1 xor SS_NOPREFIX,0
WordStc				dd -1 xor (SS_LEFTNOWORDWRAP or SS_CENTER or SS_RIGHT),SS_LEFTNOWORDWRAP
					dd -1 xor (SS_LEFTNOWORDWRAP or SS_CENTER or SS_RIGHT),0
MultEdt				dd -1 xor ES_MULTILINE,0
					dd -1 xor ES_MULTILINE,ES_MULTILINE
MultBtn				dd -1 xor BS_MULTILINE,0
					dd -1 xor BS_MULTILINE,BS_MULTILINE
MultTab				dd -1 xor TCS_MULTILINE,0
					dd -1 xor TCS_MULTILINE,TCS_MULTILINE
MultLst				dd -1 xor (LBS_MULTIPLESEL or LBS_EXTENDEDSEL),0
					dd -1 xor (LBS_MULTIPLESEL or LBS_EXTENDEDSEL),LBS_MULTIPLESEL or LBS_EXTENDEDSEL
MultMvi				dd -1 xor MCS_MULTISELECT,0
					dd -1 xor MCS_MULTISELECT,MCS_MULTISELECT
LockEdt				dd -1 xor ES_READONLY,0
					dd -1 xor ES_READONLY,ES_READONLY
ChilAll				dd -1 xor WS_CHILD,0
					dd -1 xor WS_CHILD,WS_CHILD
SizeDlg				dd -1 xor WS_SIZEBOX,0
					dd -1 xor WS_SIZEBOX,WS_SIZEBOX
SizeSbr				dd -1 xor SBARS_SIZEGRIP,0
					dd -1 xor SBARS_SIZEGRIP,SBARS_SIZEGRIP
TabSAll				dd -1 xor WS_TABSTOP,0
					dd -1 xor WS_TABSTOP,WS_TABSTOP
NotiStc				dd -1 xor SS_NOTIFY,0
					dd -1 xor SS_NOTIFY,SS_NOTIFY
NotiBtn				dd -1 xor BS_NOTIFY,0
					dd -1 xor BS_NOTIFY,BS_NOTIFY
NotiLst				dd -1 xor LBS_NOTIFY,0
					dd -1 xor LBS_NOTIFY,LBS_NOTIFY
WantEdt				dd -1 xor ES_WANTRETURN,0
					dd -1 xor ES_WANTRETURN,ES_WANTRETURN
SortCbo				dd -1 xor CBS_SORT,0
					dd -1 xor CBS_SORT,CBS_SORT
SortLst				dd -1 xor LBS_SORT,0
					dd -1 xor LBS_SORT,LBS_SORT
FlatTbr				dd -1 xor TBSTYLE_FLAT,0
					dd -1 xor TBSTYLE_FLAT,TBSTYLE_FLAT
GrouAll				dd -1 xor WS_GROUP,0
					dd -1 xor WS_GROUP,WS_GROUP
UseTLst				dd -1 xor LBS_USETABSTOPS,0
					dd -1 xor LBS_USETABSTOPS,LBS_USETABSTOPS
SetBUdn				dd -1 xor UDS_SETBUDDYINT,0
					dd -1 xor UDS_SETBUDDYINT,UDS_SETBUDDYINT
HideEdt				dd -1 xor ES_NOHIDESEL,ES_NOHIDESEL
					dd -1 xor ES_NOHIDESEL,0
HideTrv				dd -1 xor TVS_SHOWSELALWAYS,TVS_SHOWSELALWAYS
					dd -1 xor TVS_SHOWSELALWAYS,0
HideLsv				dd -1 xor LVS_SHOWSELALWAYS,LVS_SHOWSELALWAYS
					dd -1 xor LVS_SHOWSELALWAYS,0
IntHtCbo			dd -1 xor CBS_NOINTEGRALHEIGHT,CBS_NOINTEGRALHEIGHT
					dd -1 xor CBS_NOINTEGRALHEIGHT,0
IntHtLst			dd -1 xor LBS_NOINTEGRALHEIGHT,LBS_NOINTEGRALHEIGHT
					dd -1 xor LBS_NOINTEGRALHEIGHT,0
ButtTab				dd -1 xor TCS_BUTTONS,0
					dd -1 xor TCS_BUTTONS,TCS_BUTTONS
ButtTrv				dd -1 xor TVS_HASBUTTONS,0
					dd -1 xor TVS_HASBUTTONS,TVS_HASBUTTONS
ButtHdr				dd -1 xor HDS_BUTTONS,0
					dd -1 xor HDS_BUTTONS,HDS_BUTTONS
PopUAll				dd -1 xor WS_POPUP,0
					dd -1 xor WS_POPUP,WS_POPUP
OwneBtn				dd -1 xor BS_OWNERDRAW,0
					dd -1 xor BS_OWNERDRAW,BS_OWNERDRAW
OwneLsv				dd -1 xor LVS_OWNERDRAWFIXED,0
					dd -1 xor LVS_OWNERDRAWFIXED,LVS_OWNERDRAWFIXED
TranAni				dd -1 xor ACS_TRANSPARENT,0
					dd -1 xor ACS_TRANSPARENT,ACS_TRANSPARENT
TimeAni				dd -1 xor ACS_TIMER,0
					dd -1 xor ACS_TIMER,ACS_TIMER
WeekMvi				dd -1 xor MCS_WEEKNUMBERS,0
					dd -1 xor MCS_WEEKNUMBERS,MCS_WEEKNUMBERS
ToolTbr				dd -1 xor TBSTYLE_TOOLTIPS,0
					dd -1 xor TBSTYLE_TOOLTIPS,TBSTYLE_TOOLTIPS
ToolTab				dd -1 xor TCS_TOOLTIPS,0
					dd -1 xor TCS_TOOLTIPS,TCS_TOOLTIPS
WrapTbr				dd -1 xor TBSTYLE_WRAPABLE,0
					dd -1 xor TBSTYLE_WRAPABLE,TBSTYLE_WRAPABLE
DiviTbr				dd -1 xor CCS_NODIVIDER,CCS_NODIVIDER
					dd -1 xor CCS_NODIVIDER,0
DragHdr				dd -1 xor HDS_DRAGDROP,0
					dd -1 xor HDS_DRAGDROP,HDS_DRAGDROP
SmooPgb				dd -1 xor PBS_SMOOTH,0
					dd -1 xor PBS_SMOOTH,PBS_SMOOTH
HasStcb				dd -1 xor CBS_HASSTRINGS,0
					dd -1 xor CBS_HASSTRINGS,CBS_HASSTRINGS
HasStlb				dd -1 xor LBS_HASSTRINGS,0
					dd -1 xor LBS_HASSTRINGS,LBS_HASSTRINGS

;False/True ExStyles
TopMost				dd -1 xor WS_EX_TOPMOST,0
					dd -1 xor WS_EX_TOPMOST,WS_EX_TOPMOST

;Multi styles
ClipAll				db 'None,Children,Siblings,Both',0
					dd -1 xor (WS_CLIPCHILDREN or WS_CLIPSIBLINGS),0
					dd -1,0
					dd -1 xor (WS_CLIPCHILDREN or WS_CLIPSIBLINGS),WS_CLIPCHILDREN
					dd -1,0
					dd -1 xor (WS_CLIPCHILDREN or WS_CLIPSIBLINGS),WS_CLIPSIBLINGS
					dd -1,0
					dd -1 xor (WS_CLIPCHILDREN or WS_CLIPSIBLINGS),WS_CLIPCHILDREN or WS_CLIPSIBLINGS
					dd -1,0
ScroAll				db 'None,Horizontal,Vertical,Both',0
					dd -1 xor (WS_HSCROLL or WS_VSCROLL),0
					dd -1,0
					dd -1 xor (WS_HSCROLL or WS_VSCROLL),WS_HSCROLL
					dd -1,0
					dd -1 xor (WS_HSCROLL or WS_VSCROLL),WS_VSCROLL
					dd -1,0
					dd -1 xor (WS_HSCROLL or WS_VSCROLL),WS_HSCROLL or WS_VSCROLL
					dd -1,0
AligStc				db 'TopLeft,TopCenter,TopRight,CenterLeft,CenterCenter,CenterRight',0
					dd -1 xor (SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),0
					dd -1,0
					dd -1 xor (SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_CENTER
					dd -1,0
					dd -1 xor (SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_RIGHT
					dd -1,0
					dd -1 xor (SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_CENTERIMAGE
					dd -1,0
					dd -1 xor (SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_CENTER or SS_CENTERIMAGE
					dd -1,0
					dd -1 xor (SS_CENTER or SS_RIGHT or SS_CENTERIMAGE),SS_RIGHT or SS_CENTERIMAGE
					dd -1,0
AligEdt				db 'Left,Center,Right',0
					dd -1 xor (ES_CENTER or ES_RIGHT),0
					dd -1,0
					dd -1 xor (ES_CENTER or ES_RIGHT),ES_CENTER
					dd -1,0
					dd -1 xor (ES_CENTER or ES_RIGHT),ES_RIGHT
					dd -1,0
AligBtn				db 'Default,TopLeft,TopCenter,TopRight,CenterLeft,CenterCenter,CenterRight,BottomLeft,BottomCenter,BottomRight',0
					dd -1 xor (BS_CENTER or BS_VCENTER),0
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_TOP or BS_LEFT
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_CENTER or BS_TOP
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_TOP or BS_RIGHT
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_LEFT or BS_VCENTER
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_CENTER or BS_VCENTER
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_RIGHT or BS_VCENTER
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_BOTTOM or BS_LEFT
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_CENTER or BS_BOTTOM
					dd -1,0
					dd -1 xor (BS_CENTER or BS_VCENTER),BS_BOTTOM or BS_RIGHT
					dd -1,0
AligChk				db 'Left,Right',0
					dd -1 xor (BS_LEFTTEXT),0
					dd -1,0
					dd -1 xor (BS_LEFTTEXT),BS_LEFTTEXT
					dd -1,0
AligTab				db 'Left,Top,Right,Bottom',0
					dd -1 xor (TCS_BOTTOM or TCS_VERTICAL),TCS_VERTICAL
					dd -1,0
					dd -1 xor (TCS_BOTTOM or TCS_VERTICAL),0
					dd -1,0
					dd -1 xor (TCS_BOTTOM or TCS_VERTICAL),TCS_BOTTOM or TCS_VERTICAL
					dd -1,0
					dd -1 xor (TCS_BOTTOM or TCS_VERTICAL),TCS_BOTTOM
					dd -1,0
AligLsv				db 'Left,Top',0
					dd -1 xor LVS_ALIGNLEFT,LVS_ALIGNLEFT
					dd -1,0
					dd -1 xor LVS_ALIGNLEFT,0
					dd -1,0
AligSpn				db 'None,Left,Right',0
					dd -1 xor (UDS_ALIGNLEFT or UDS_ALIGNRIGHT),0
					dd -1,0
					dd -1 xor (UDS_ALIGNLEFT or UDS_ALIGNRIGHT),UDS_ALIGNLEFT
					dd -1,0
					dd -1 xor (UDS_ALIGNLEFT or UDS_ALIGNRIGHT),UDS_ALIGNRIGHT
					dd -1,0
AligIco				db 'AutoSize,Center',0
					dd -1 xor SS_CENTERIMAGE,0
					dd -1,0
					dd -1 xor SS_CENTERIMAGE,SS_CENTERIMAGE
					dd -1,0
AligTbr				db 'Left,Top,Right,Bottom',0
					dd -1 xor (CCS_VERT or CCS_BOTTOM or CCS_TOP),CCS_TOP or CCS_VERT
					dd -1,0
					dd -1 xor (CCS_VERT or CCS_BOTTOM or CCS_TOP),CCS_TOP
					dd -1,0
					dd -1 xor (CCS_VERT or CCS_BOTTOM or CCS_TOP),CCS_BOTTOM or CCS_VERT
					dd -1,0
					dd -1 xor (CCS_VERT or CCS_BOTTOM or CCS_TOP),CCS_BOTTOM
					dd -1,0
AligAni				db 'AutoSize,Center',0
					dd -1 xor ACS_CENTER,0
					dd -1,0
					dd -1 xor ACS_CENTER,ACS_CENTER
					dd -1,0
BordDlg				db 'Flat,Boarder,Dialog,Tool,ModalFrame',0
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME),0
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),0
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME),WS_BORDER
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),0
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME),WS_BORDER or WS_DLGFRAME
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),0
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME),WS_BORDER or WS_DLGFRAME
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),WS_EX_TOOLWINDOW
					dd -1 xor (WS_DLGFRAME or WS_BORDER or DS_MODALFRAME),WS_BORDER or WS_DLGFRAME or DS_MODALFRAME
					dd -1 xor (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME),WS_EX_DLGMODALFRAME
BordAll				db 'Flat,Boarder,Raised,Sunken,3D-Look,Edge',0
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor WS_BORDER,WS_BORDER
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_DLGMODALFRAME
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_STATICEDGE
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_CLIENTEDGE
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_CLIENTEDGE or WS_EX_DLGMODALFRAME
BordStc				db 'Flat,Boarder,Raised,Sunken,3D-Look,Edge',0
					dd -1 xor (WS_BORDER or SS_SUNKEN),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),0
					dd -1 xor (WS_BORDER or SS_SUNKEN),WS_BORDER
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),0
					dd -1 xor (WS_BORDER or SS_SUNKEN),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),WS_EX_DLGMODALFRAME
					dd -1 xor (WS_BORDER or SS_SUNKEN),SS_SUNKEN
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),0
					dd -1 xor (WS_BORDER or SS_SUNKEN),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),WS_EX_CLIENTEDGE
					dd -1 xor WS_BORDER,0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE),WS_EX_CLIENTEDGE or WS_EX_DLGMODALFRAME
BordBtn				db 'Flat,Boarder,Raised,Sunken,3D-Look,Edge',0
					dd -1 xor (WS_BORDER or BS_FLAT),BS_FLAT
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor (WS_BORDER or BS_FLAT),WS_BORDER or BS_FLAT
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor (WS_BORDER or BS_FLAT),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_DLGMODALFRAME
					dd -1 xor (WS_BORDER or BS_FLAT),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_STATICEDGE
					dd -1 xor (WS_BORDER or BS_FLAT),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),0
					dd -1 xor (WS_BORDER or BS_FLAT),0
					dd -1 xor (WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE or WS_EX_STATICEDGE),WS_EX_DLGMODALFRAME or WS_EX_CLIENTEDGE
TypeEdt				db 'Normal,Upper,Lower,Number,Password',0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),0
					dd -1,0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),ES_UPPERCASE
					dd -1,0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),ES_LOWERCASE
					dd -1,0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),ES_NUMBER
					dd -1,0
					dd -1 xor (ES_UPPERCASE or ES_LOWERCASE or ES_PASSWORD or ES_NUMBER),ES_PASSWORD
					dd -1,0
TypeBtn				db 'Text,Bitmap,Icon',0
					dd -1 xor (BS_BITMAP or BS_ICON),0
					dd -1,0
					dd -1 xor (BS_BITMAP or BS_ICON),BS_BITMAP
					dd -1,0
					dd -1 xor (BS_BITMAP or BS_ICON),BS_ICON
					dd -1,0
TypeCbo				db 'DropDownCombo,DropDownList,SimpleCombo',0
					dd -1 xor (CBS_DROPDOWN or CBS_DROPDOWNLIST or CBS_SIMPLE),CBS_DROPDOWN
					dd -1,0
					dd -1 xor (CBS_DROPDOWN or CBS_DROPDOWNLIST or CBS_SIMPLE),CBS_DROPDOWNLIST
					dd -1,0
					dd -1 xor (CBS_DROPDOWN or CBS_DROPDOWNLIST or CBS_SIMPLE),CBS_SIMPLE
					dd -1,0
TypeTrv				db 'NoLines,Lines,LinesAtRoot',0
					dd -1 xor (TVS_HASLINES or TVS_LINESATROOT),0
					dd -1,0
					dd -1 xor (TVS_HASLINES or TVS_LINESATROOT),TVS_HASLINES
					dd -1,0
					dd -1 xor (TVS_HASLINES or TVS_LINESATROOT),TVS_HASLINES or TVS_LINESATROOT
					dd -1,0
TypeLsv				db 'Icon,List,Report,SmallIcon',0
					dd -1 xor LVS_TYPEMASK,LVS_ICON
					dd -1,0
					dd -1 xor LVS_TYPEMASK,LVS_LIST
					dd -1,0
					dd -1 xor LVS_TYPEMASK,LVS_REPORT
					dd -1,0
					dd -1 xor LVS_TYPEMASK,LVS_SMALLICON
					dd -1,0
TypeImg				db 'Bitmap,Icon',0
					dd -1 xor (SS_BITMAP or SS_ICON),SS_BITMAP
					dd -1,0
					dd -1 xor (SS_BITMAP or SS_ICON),SS_ICON
					dd -1,0
TypeDtp				db 'Normal,UpDown,CheckBox,Both',0
					dd -1 xor 03h,00h
					dd -1,0
					dd -1 xor 03h,01h
					dd -1,0
					dd -1 xor 03h,02h
					dd -1,0
					dd -1 xor 03h,03h
					dd -1,0
TypeStc				db 'BlackRect,GrayRect,WhiteRect,HollowRect,BlackFrame,GrayFrame,WhiteFrame,EtchedFrame,H-Line,V-Line',0
					dd -1 xor 1Fh,SS_BLACKRECT
					dd -1,0
					dd -1 xor 1Fh,SS_GRAYRECT
					dd -1,0
					dd -1 xor 1Fh,SS_WHITERECT
					dd -1,0
					dd -1 xor 1Fh,SS_OWNERDRAW
					dd -1,0
					dd -1 xor 1Fh,SS_BLACKFRAME
					dd -1,0
					dd -1 xor 1Fh,SS_GRAYFRAME
					dd -1,0
					dd -1 xor 1Fh,SS_WHITEFRAME
					dd -1,0
					dd -1 xor 1Fh,SS_ETCHEDFRAME
					dd -1,0
					dd -1 xor 1Fh,SS_ETCHEDHORZ
					dd -1,0
					dd -1 xor 1Fh,SS_ETCHEDVERT
					dd -1,0
AutoEdt				db 'None,Horizontal,Vertical,Both',0
					dd -1 xor (ES_AUTOHSCROLL or ES_AUTOVSCROLL),0
					dd -1,0
					dd -1 xor (ES_AUTOHSCROLL or ES_AUTOVSCROLL),ES_AUTOHSCROLL
					dd -1,0
					dd -1 xor (ES_AUTOHSCROLL or ES_AUTOVSCROLL),ES_AUTOVSCROLL
					dd -1,0
					dd -1 xor (ES_AUTOHSCROLL or ES_AUTOVSCROLL),ES_AUTOHSCROLL or ES_AUTOVSCROLL
					dd -1,0
FormDtp				db 'Short,Medium,Long,Time',0
					dd -1 xor 0Ch,00h
					dd -1,0
					dd -1 xor 0Ch,0Ch
					dd -1,0
					dd -1 xor 0Ch,04h
					dd -1,0
					dd -1 xor 0Ch,08h
					dd -1,0
StarDlg				db 'Normal,CenterScreen,CenterMouse',0
					dd -1 xor (DS_CENTER or DS_CENTERMOUSE),0
					dd -1,0
					dd -1 xor (DS_CENTER or DS_CENTERMOUSE),DS_CENTER
					dd -1,0
					dd -1 xor (DS_CENTER or DS_CENTERMOUSE),DS_CENTERMOUSE
					dd -1,0
OrieUdn				db 'Vertical,Horizontal',0
					dd -1 xor UDS_HORZ,0
					dd -1,0
					dd -1 xor UDS_HORZ,UDS_HORZ
					dd -1,0
OriePgb				db 'Horizontal,Vertical',0
					dd -1 xor PBS_VERTICAL,0
					dd -1,0
					dd -1 xor PBS_VERTICAL,PBS_VERTICAL
					dd -1,0
SortLsv				db 'None,Ascending,Descending',0
					dd -1 xor (LVS_SORTASCENDING or LVS_SORTDESCENDING),0
					dd -1,0
					dd -1 xor (LVS_SORTASCENDING or LVS_SORTDESCENDING),LVS_SORTASCENDING
					dd -1,0
					dd -1 xor (LVS_SORTASCENDING or LVS_SORTDESCENDING),LVS_SORTDESCENDING
					dd -1,0
OwneCbo				db 'None,Fixed,Variable',0
					dd -1 xor (CBS_OWNERDRAWFIXED or CBS_OWNERDRAWVARIABLE),0
					dd -1,0
					dd -1 xor (CBS_OWNERDRAWFIXED or CBS_OWNERDRAWVARIABLE),CBS_OWNERDRAWFIXED
					dd -1,0
					dd -1 xor (CBS_OWNERDRAWFIXED or CBS_OWNERDRAWVARIABLE),CBS_OWNERDRAWVARIABLE
					dd -1,0
ElliStc				db 'None,EndEllipsis,PathEllipsis,WordEllipsis',0
					dd -1 xor SS_ELLIPSISMASK,0
					dd -1,0
					dd -1 xor SS_ELLIPSISMASK,SS_ENDELLIPSIS
					dd -1,0
					dd -1 xor SS_ELLIPSISMASK,SS_PATHELLIPSIS
					dd -1,0
					dd -1 xor SS_ELLIPSISMASK,SS_WORDELLIPSIS
					dd -1,0






szPropErr			db 'Invalid property value.',0
StyleWarn			db 'WARNING!!',0Dh,'Some styles can make RadASM  unstable. Save before use.',0
StyleEx				dd 0
StyleOfs			dd 0
StyleTxt			dd 0
StylePos			dd 0
szStyleExTxt		db ',,,,'
					db ',,,,'
					db ',,,,WS_EX_LAYERED'
					db ',WS_EX_APPWINDOW,WS_EX_STATICEDGE,WS_EX_CONTROLPARENT,'
					db ',WS_EX_LEFTSCROLLBAR,WS_EX_RTLREADING,WS_EX_RIGHT,'
					db ',WS_EX_CONTEXTHELP,WS_EX_CLIENTEDGE,WS_EX_WINDOWEDGE,'
					db 'WS_EX_TOOLWINDOW,WS_EX_MDICHILD,WS_EX_TRANSPARENT,WS_EX_ACCEPTFILES,'
					db 'WS_EX_TOPMOST,WS_EX_NOPARENTNOTIFY,,WS_EX_DLGMODALFRAME',0
szStyleTxt			db 'WS_POPUP,WS_CHILD,WS_MINIMIZE,WS_VISIBLE,'
					db 'WS_DISABLED,WS_CLIPSIBLINGS,WS_CLIPCHILDREN,WS_MAXIMIZE,'
					db 'WS_BORDER,WS_DLGFRAME,WS_VSCROLL,WS_HSCROLL,'
					db 'WS_SYSMENU,WS_THICKFRAME,WS_GROUP,WS_TABSTOP',0




.data?

lbtxtbuffer				db 4096 dup(?)
lbbuffer				db 4096 dup(?)
OldPropListCodeProc		dd ?
OldPropListDlgProc		dd ?
OldPropTxtLstProc		dd ?
OldPropEditProc			dd ?
OldPropEditMultiProc	dd ?
OldPropCboProc			dd ?
OldPropTxtBtnProc		dd ?

.code

;----------------------------------------------------------------------
; Get custom control's property text description
;----------------------------------------------------------------------
PropCustCtrlGetTxtDesc PROC USES EBX dwLabelID:DWORD
    LOCAL dwType:DWORD
    LOCAL lpszPropertyDesc:DWORD
    LOCAL lpProperties:DWORD
    LOCAL dwLenProperties:DWORD
    LOCAL lpPropBlock:DWORD
    LOCAL nPropCount:DWORD
    
    mov ebx, dwLabelID
    mov eax, dword ptr [ebx]
    mov dwType, eax
    mov eax, dword ptr [ebx+4]
    mov lpProperties, eax

    .IF eax != 0
        mov eax, dwType
        .IF eax == 1 || eax == 2 || eax == 3
            lea eax, szProperty_Null
        .ELSEIF eax == 4 || eax == 5
            ; get property description after block of properties
            mov eax, lpProperties
            add eax, 16d

        .ELSEIF eax == 6
            ; get property description after properties string and block of properties
            Invoke strlen, lpProperties
            .IF eax == 0
                lea eax, szProperty_Null
            .ELSE
                mov dwLenProperties, eax
                add eax, lpProperties
                inc eax
                mov lpPropBlock, eax
                
                mov nPropCount, 1
                mov ebx, lpProperties
                movzx eax, byte ptr [ebx]
                .WHILE al != 0 && (ebx < lpPropBlock)
                    .IF al == ','
                        inc nPropCount
                    .ENDIF
                    inc ebx
                    movzx eax, byte ptr [ebx]
                .ENDW
                
                ; count of , indicates how many properties * 16 + lpPropBlock = pointer to property description
                ; start with propcount of 1, as if string is empty then there would be no properties anyhow.
                mov eax, nPropCount
                mov ebx, 16d
                mul ebx
                add eax, lpPropBlock
            .ENDIF
        .ELSE
            lea eax, szProperty_Null
        .ENDIF
    .ELSE
        lea eax, szProperty_Null
    .ENDIF
    ret

PropCustCtrlGetTxtDesc ENDP


;----------------------------------------------------------------------
; Set property text description
;----------------------------------------------------------------------
PropSetTxtDesc PROC dwLabelID:DWORD

    mov eax, dwLabelID
    .IF eax == 0 || eax == -1
        ;lea eax, szProperty_Null
        ret
    .ELSEIF eax == Property_NumID
        lea eax, szProperty_NumID
    .ELSEIF eax == Property_Left
        lea eax, szProperty_Left
    .ELSEIF eax == Property_Top
        lea eax, szProperty_Top
    .ELSEIF eax == Property_Width
        lea eax, szProperty_Width
    .ELSEIF eax == Property_Height
        lea eax, szProperty_Height
    .ELSEIF eax == Property_StartID
        lea eax, szProperty_StartID
    .ELSEIF eax == Property_TabIndex
        lea eax, szProperty_TabIndex
    
    .ELSEIF eax == Property_Name
        lea eax, szProperty_Name
    .ELSEIF eax == Property_Caption
        lea eax, szProperty_Caption
    .ELSEIF eax == Property_MultiCaption
        lea eax, szProperty_MultiCaption

    .ELSEIF eax == Property_SysMenu
        lea eax, szProperty_SysMenu
    .ELSEIF eax == Property_MaxButton
        lea eax, szProperty_MaxButton
    .ELSEIF eax == Property_MinButton
        lea eax, szProperty_MinButton
    .ELSEIF eax == Property_Enabled
        lea eax, szProperty_Enabled
    .ELSEIF eax == Property_Visible
        lea eax, szProperty_Visible
    .ELSEIF eax == Property_Default
        lea eax, szProperty_Default
    .ELSEIF eax == Property_Auto
        lea eax, szProperty_Auto
    .ELSEIF eax == Property_AutoPlay
        lea eax, szProperty_AutoPlay
    .ELSEIF eax == Property_AutoSize
        lea eax, szProperty_AutoSize
    .ELSEIF eax == Property_Mnemonic
        lea eax, szProperty_Mnemonic
    .ELSEIF eax == Property_WordWrap
        lea eax, szProperty_WordWrap
    .ELSEIF eax == Property_MultiLine
        lea eax, szProperty_MultiLine
    .ELSEIF eax == Property_MultiSelect
        lea eax, szProperty_MultiSelect
    .ELSEIF eax == Property_Locked
        lea eax, szProperty_Locked
    .ELSEIF eax == Property_Child
        lea eax, szProperty_Child
    .ELSEIF eax == Property_SizeBorder
        lea eax, szProperty_SizeBorder
    .ELSEIF eax == Property_SizeGrip
        lea eax, szProperty_SizeGrip
    .ELSEIF eax == Property_TabStop
        lea eax, szProperty_TabStop
    .ELSEIF eax == Property_Notify
        lea eax, szProperty_Notify
    .ELSEIF eax == Property_WantCR
        lea eax, szProperty_WantCR
    .ELSEIF eax == Property_SortList
        lea eax, szProperty_SortList
    .ELSEIF eax == Property_Flat
        lea eax, szProperty_Flat
    .ELSEIF eax == Property_Group
        lea eax, szProperty_Group

    .ELSEIF eax == Property_UseTabs
        lea eax, szProperty_UseTabs
    .ELSEIF eax == Property_SetBuddy
        lea eax, szProperty_SetBuddy
    .ELSEIF eax == Property_HideSelection
        lea eax, szProperty_HideSelection
    .ELSEIF eax == Property_TopMost
        lea eax, szProperty_TopMost
    .ELSEIF eax == Property_IntegralHeight
        lea eax, szProperty_IntegralHeight
    .ELSEIF eax == Property_Buttons
        lea eax, szProperty_Buttons
    .ELSEIF eax == Property_PopUp
        lea eax, szProperty_PopUp
    .ELSEIF eax == Property_OwnerDrawBtn
        lea eax, szProperty_OwnerDrawBtn
    .ELSEIF eax == Property_OwnerDrawLsv
        lea eax, szProperty_OwnerDrawLsv
    .ELSEIF eax == Property_Transparent
        lea eax, szProperty_Transparent
    .ELSEIF eax == Property_Timer
        lea eax, szProperty_Timer
    .ELSEIF eax == Property_WeekNum
        lea eax, szProperty_WeekNum
    .ELSEIF eax == Property_ToolTip
        lea eax, szProperty_ToolTip
    .ELSEIF eax == Property_WrapToolbar
        lea eax, szProperty_WrapToolbar
    .ELSEIF eax == Property_DividerToolbar
        lea eax, szProperty_DividerToolbar
    .ELSEIF eax == Property_DragDrop
        lea eax, szProperty_DragDrop
    .ELSEIF eax == Property_ProgressSmooth
        lea eax, szProperty_ProgressSmooth
    .ELSEIF eax == Property_HasStrings
        lea eax, szProperty_HasStrings
    
    .ELSEIF eax == Property_Clipping
        lea eax, szProperty_Clipping
    .ELSEIF eax == Property_ScrollBar
        lea eax, szProperty_ScrollBar
    .ELSEIF eax == Property_Alignment
        lea eax, szProperty_Alignment
    .ELSEIF eax == Property_AutoScroll
        lea eax, szProperty_AutoScroll
    .ELSEIF eax == Property_Format
        lea eax, szProperty_Format
    .ELSEIF eax == Property_StartupPos
        lea eax, szProperty_StartupPos
    .ELSEIF eax == Property_Orientation
        lea eax, szProperty_Orientation
    .ELSEIF eax == Property_SortListview
        lea eax, szProperty_SortListview
    .ELSEIF eax == Property_OwnerDrawCbo
        lea eax, szProperty_OwnerDrawCbo
    .ELSEIF eax == Property_Ellipsis
        lea eax, szProperty_Ellipsis

    .ELSEIF eax == Property_Border
        lea eax, szProperty_Border
    .ELSEIF eax == Property_Type
        lea eax, szProperty_Type
    
    .ELSEIF eax == Property_Font
        lea eax, szProperty_Font
    .ELSEIF eax == Property_Class
        lea eax, szProperty_Class
    .ELSEIF eax == Property_Menu
        lea eax, szProperty_Menu
    .ELSEIF eax == Property_xExStyle
        lea eax, szProperty_xExStyle
    .ELSEIF eax == Property_xStyle
        lea eax, szProperty_xStyle
    .ELSEIF eax == Property_Image 
        lea eax, szProperty_Image
    .ELSEIF eax == Property_AviClip
        lea eax, szProperty_AviClip
    .ELSEIF eax >= Property_CustomControl
        Invoke PropCustCtrlGetTxtDesc, dwLabelID
    .ELSE
        lea eax, szProperty_Null
    .ENDIF

    .IF eax != 0
        Invoke SendMessage, hPrpTxtDesc, WM_SETTEXT, 0, eax
    .ENDIF
    xor eax, eax
    ret

PropSetTxtDesc ENDP



SetPrpFocus proc

	invoke GetFocus
	xor		edx,edx
	.if eax==hPrpLst || eax==hTxtLst || eax==hTxtBtn || eax==hPrpCbo || eax==hPrpTxt || eax==hPrpTxtMulti
		inc		edx
	.endif
	push	edx
	mov		eax,hPrp
	call    GetToolPtr
	pop		eax
	.if eax!=[edx].TOOL.dFocus
		mov     [edx].TOOL.dFocus,eax
		invoke ToolMsg,hPrp,TLM_CAPTION,0
	.endif
	ret

SetPrpFocus endp

GetCustProp proc nType:DWORD,nProp:DWORD
	invoke GetTypePtr,nType
	mov		edx,nProp
	sub		edx,[eax].TYPES.nmethod
	mov		eax,[eax].TYPES.methods
	.if eax
		lea		eax,[eax+edx*8]
	.endif
	ret

GetCustProp endp

PropertyStyleTxt proc uses ebx,hWin:HWND,lpBuff:DWORD
	LOCAL	buffer[1024]:BYTE
	LOCAL	buffer1[64]:BYTE

	.if StyleEx
		invoke strcpy,addr buffer,addr szStyleExTxt
		mov		eax,StyleOfs
		mov		eax,(DIALOG ptr [eax]).exstyle
	.else
		mov		edx,offset szStyle
		call	GetStyle
		invoke strcpy,addr buffer,addr szStyleTxt
		invoke strcat,addr buffer,ebx
		mov		eax,StyleOfs
		mov		eax,(DIALOG ptr [eax]).style
	.endif
	mov		ecx,32
	mov		edx,lpBuff
	.while ecx
		mov		byte ptr [edx],'0'
		shl		eax,1
		jnc		@f
		mov		byte ptr [edx],'1'
	  @@:
		inc		edx
		dec		ecx
	.endw
	mov		byte ptr [edx],0
	invoke SetDlgItemText,hWin,IDC_EDTSTYLE,lpBuff
	mov		eax,StylePos
	inc		eax
	invoke SendDlgItemMessage,hWin,IDC_EDTSTYLE,EM_SETSEL,StylePos,eax
	mov		eax,StylePos
	inc		eax
	.while eax
		push	eax
		invoke iniGetItem,addr buffer,addr buffer1
		pop		eax
		dec		eax
	.endw
	invoke SetDlgItemText,hWin,IDC_STCTXT,addr buffer1
	ret

GetStyle:
	push	edx
	mov		eax,StyleOfs
	mov		edx,(DIALOG ptr [eax]).ntype
	invoke BinToDec,edx,addr buffer1
	pop		edx
	invoke GetPrivateProfileString,edx,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr iniFile
	mov		eax,16
	lea		ebx,buffer[sizeof buffer-1]
	.while eax
		push	eax
		invoke iniGetItem,addr buffer,addr buffer1
		invoke strlen,addr buffer1
		sub		ebx,eax
		.while eax
			dec		eax
			mov		dl,buffer1[eax]
			mov		[ebx+eax],dl
		.endw
		dec		ebx
		mov		byte ptr [ebx],','
		pop		eax
		dec		eax
	.endw
	retn

PropertyStyleTxt endp

PropertyDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	hCtl:HWND
	LOCAL	rect:RECT
	LOCAL	prect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetLanguage,hWin,IDD_PROPERTY,FALSE
		invoke SendMessageW,hWin,WM_GETTEXT,sizeof buffer,addr buffer
		invoke iniGetItemW,addr buffer,addr buffer1
		.if StyleEx
			invoke iniGetItemW,addr buffer,addr buffer1
		.endif
		invoke SendMessageW,hWin,WM_SETTEXT,0,addr buffer1
		mov		StylePos,0
		invoke GetWindowRect,hPrp,addr prect
		invoke GetWindowRect,hWin,addr rect
		;width
		mov		eax,rect.left
		sub		rect.right,eax
		;height
		mov		eax,rect.top
		sub		rect.bottom,eax
		;left
		mov		eax,prect.right
		sub		eax,rect.right		;width
		jnc		@f
		xor		eax,eax
	  @@:
		mov		rect.left,eax
		;Top
		mov		eax,rect.top
		sub		eax,95
		jnc		@f
		xor		eax,eax
	  @@:
		mov		rect.top,eax
		invoke MoveWindow,hWin,rect.left,rect.top,rect.right,rect.bottom,TRUE
		invoke SetDlgItemText,hWin,IDC_STCWARN,addr StyleWarn
		invoke PropertyStyleTxt,hWin,addr buffer
		invoke GetDlgItem,hWin,IDC_BTNLEFT
		mov		hCtl,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+0,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		invoke GetDlgItem,hWin,IDC_BTNRIGHT
		mov		hCtl,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+1,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
		invoke GetDlgItem,hWin,IDC_BTNSET
		mov		hCtl,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+2,ILD_NORMAL
		invoke SendMessage,hCtl,BM_SETIMAGE,IMAGE_ICON,eax
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNLEFT
				dec		StylePos
				and		StylePos,31
				mov		eax,StylePos
				inc		eax
				invoke SendDlgItemMessage,hWin,IDC_EDTSTYLE,EM_SETSEL,StylePos,eax
				invoke PropertyStyleTxt,hWin,addr buffer
			.elseif eax==IDC_BTNRIGHT
				inc		StylePos
				and		StylePos,31
				mov		eax,StylePos
				inc		eax
				invoke SendDlgItemMessage,hWin,IDC_EDTSTYLE,EM_SETSEL,StylePos,eax
				invoke PropertyStyleTxt,hWin,addr buffer
			.elseif eax==IDC_BTNSET
				mov		ecx,StylePos
				mov		eax,80000000h
				shr		eax,cl
				mov		ecx,StyleOfs
				.if StyleEx
;					and		eax,000777FDh
					xor		(DIALOG ptr [ecx]).exstyle,eax
				.else
					and		eax,0FFFFFFFFh
					xor		(DIALOG ptr [ecx]).style,eax
				.endif
				.if eax
					invoke GetWindowLong,hPrpLst,GWL_USERDATA
					mov		hCtl,eax
					invoke UpdateCtl,hCtl
					invoke PropertyStyleTxt,hWin,addr buffer
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

PropertyDlgProc endp

UpdateCbo proc uses esi,lpData:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[1024]:BYTE
	LOCAL	buffer2[64]:BYTE

	invoke SendMessage,hPrpCboDlg,CB_RESETCONTENT,0,0
	mov		esi,lpData
	add		esi,sizeof DLGHEAD
	assume esi:ptr DIALOG
  @@:
	mov		eax,[esi].hwnd
	.if eax
		.if eax!=-1
			mov		al,[esi].idname
			.if al
				invoke strcpy,addr buffer,addr [esi].idname
			.else
				invoke BinToDec,[esi].id,addr buffer
			.endif
			invoke strcpy,addr buffer1,addr szCtlText
			mov		eax,[esi].ntype
			inc		eax
			.while eax
				push	eax
				invoke iniGetItem,addr buffer1,addr buffer2
				pop		eax
				dec		eax
			.endw
			push	esi
			invoke strlen,addr buffer
			lea		esi,buffer
			add		esi,eax
			mov		al,' '
			mov		[esi],al
			inc		esi
			invoke strcpy,esi,addr buffer2
			pop		esi
			invoke SendMessage,hPrpCboDlg,CB_ADDSTRING,0,addr buffer
			mov		nInx,eax
			invoke SendMessage,hPrpCboDlg,CB_SETITEMDATA,nInx,[esi].hwnd
		.endif
		add		esi,sizeof DIALOG
		jmp		@b
	.endif
	assume esi:nothing
	ret

UpdateCbo endp

SetCbo proc hCtl:DWORD
	LOCAL	nInx:DWORD

	invoke SendMessage,hPrpCboDlg,CB_GETCOUNT,0,0
	mov		nInx,eax
  @@:
	.if nInx
		dec		nInx
		invoke SendMessage,hPrpCboDlg,CB_GETITEMDATA,nInx,0
		.if eax==hCtl
			invoke SendMessage,hPrpCboDlg,CB_SETCURSEL,nInx,0
		.endif
		jmp		@b
	.endif
	ret

SetCbo endp

PropCboProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_COMMAND
		mov		eax,wParam
		shr		eax,16
		.if eax==CBN_SELCHANGE
			invoke SendMessage,hWin,CB_GETCURSEL,0,0
			.if hDialog
				invoke SendMessage,hWin,CB_GETITEMDATA,eax,0
				invoke SizeingRect,eax,FALSE
			.else
				push	eax
				invoke SendMessage,hWin,CB_GETITEMDATA,eax,0
				pop		edx
				.if eax<=5 || (eax>=10 && eax<=13)
					invoke SetProperty,eax,edx
				.endif
				invoke SetFocus,hPrpLst
			.endif
		.endif
	.elseif eax==WM_SETFOCUS || eax==WM_KILLFOCUS
		invoke SetPrpFocus
	.endif
	invoke CallWindowProc,OldPropCboProc,hWin,uMsg,wParam,lParam
	ret

PropCboProc endp

PropListSetTxt proc uses esi,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[512]:BYTE

	invoke SendMessage,hWin,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		invoke SendMessage,hWin,LB_GETTEXT,nInx,addr buffer
		lea		esi,buffer
	  @@:
		mov		al,[esi]
		inc		esi
		cmp		al,09h
		jne		@b
		invoke SendMessage,hWin,LB_GETITEMDATA,nInx,0
		.if eax==StrCap || eax==StrCapMulti || eax==1005 || eax==1006
			invoke SendMessage,hPrpTxt,EM_LIMITTEXT,MaxCap-1,0
			invoke SendMessage,hPrpTxtMulti,EM_LIMITTEXT,MaxCap-1,0
		.else
			invoke SendMessage,hPrpTxt,EM_LIMITTEXT,31,0
		.endif
		invoke SetWindowText,hPrpTxt,esi
	.endif
	ret

PropListSetTxt endp

PropListSetPos proc
	LOCAL	rect:RECT
	LOCAL	nInx:DWORD
	LOCAL	lbid:DWORD

	invoke ShowWindow,hPrpTxtMulti,SW_HIDE
	invoke ShowWindow,hPrpTxt,SW_HIDE
	invoke ShowWindow,hTxtBtn,SW_HIDE
	invoke GetWindowLong,hMdiCld,8
	or		eax,eax
	jne		Ex
	invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		invoke SendMessage,hPrpLst,LB_GETTEXT,nInx,addr lbtxtbuffer
		mov		ecx,offset lbtxtbuffer
		mov		edx,offset szLbString
		.while byte ptr [ecx]!=VK_TAB
			mov		al,[ecx]
			mov		[edx],al
			inc		ecx
			inc		edx
		.endw
		mov		byte ptr [edx],0
		invoke SendMessage,hPrpLst,LB_GETITEMRECT,nInx,addr rect
		invoke SendMessage,hPrpLst,LB_GETITEMDATA,nInx,0
		mov		lbid,eax
		
		;PrintText 'PropListSetPos'
		;PrintDec lbid
		Invoke PropSetTxtDesc, lbid
		
		
		mov eax, lbid
		invoke SetWindowLong,hTxtBtn,GWL_USERDATA,eax
		mov		eax,lbid
		.if (eax>=200 && eax<=499) || eax==1000 || eax==1003 || eax==1004 || eax>65535
			mov		eax,lbHt
			sub		rect.right,eax
			mov		eax,rect.right
			sub		eax,rect.left
			mov		edx,lbTp
			add		edx,32
			sub		edx,lbHt
			.if eax<edx
				mov		rect.right,edx
			.endif
			invoke SetWindowPos,hTxtBtn,HWND_TOP,rect.right,rect.top,lbHt,lbHt,0
			invoke ShowWindow,hTxtBtn,SW_SHOWNOACTIVATE
		.else
			invoke PropListSetTxt,hPrpLst
			.if lbid==1002 || lbid==1005 || lbid==1006 || lbid==StrCapMulti
				mov		edx,lbHt
				dec		edx
				sub		rect.right,edx
				invoke SetWindowPos,hTxtBtn,HWND_TOP,rect.right,rect.top,lbHt,lbHt,0
				invoke ShowWindow,hTxtBtn,SW_SHOWNOACTIVATE
			.endif
			mov		edx,lbTp
			inc		edx
			mov		rect.left,edx
			sub		rect.right,edx
			mov		eax,lbHt
			dec		eax
			invoke SetWindowPos,hPrpTxt,HWND_TOP,rect.left,rect.top,rect.right,eax,0
			invoke ShowWindow,hPrpTxt,SW_SHOWNOACTIVATE
			invoke SendMessage,hPrpTxt,EM_GETRECT,0,addr rect
			mov		rect.left,1
			mov		eax,lbHt
			dec		eax
			mov		rect.bottom,eax
			invoke SendMessage,hPrpTxt,EM_SETRECT,0,addr rect
		.endif
		mov		eax,hPrp
		call    GetToolPtr
		mov     (TOOL ptr [edx]).dFocus,TRUE
		invoke ToolMsg,hPrp,TLM_CAPTION,0
		xor		eax,eax
	.endif
  Ex:
	ret

PropListSetPos endp

TxtLstFalseTrue proc uses esi,CtlVal:DWORD,lpVal:DWORD

	invoke SendMessage,hTxtLst,LB_RESETCONTENT,0,0
	invoke SendMessage,hTxtLst,LB_ADDSTRING,0,addr szFalse
	mov		eax,lpVal
	invoke SendMessage,hTxtLst,LB_SETITEMDATA,0,eax
	invoke SendMessage,hTxtLst,LB_ADDSTRING,0,addr szTrue
	mov		eax,lpVal
	add		eax,8
	invoke SendMessage,hTxtLst,LB_SETITEMDATA,1,eax
	mov		esi,lpVal
	mov		eax,[esi]
	xor		eax,-1
	and		eax,CtlVal
	.if eax==[esi+4]
		invoke SendMessage,hTxtLst,LB_SETCURSEL,0,0
	.else
		invoke SendMessage,hTxtLst,LB_SETCURSEL,1,0
	.endif
	ret

TxtLstFalseTrue endp

TxtLstMulti proc uses esi,CtlValSt:DWORD,CtlValExSt:DWORD,lpVal:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[64]:BYTE
	LOCAL	nInx:DWORD

	invoke SendMessage,hTxtLst,LB_RESETCONTENT,0,0
	invoke strcpy,addr buffer,lpVal
	invoke strlen,lpVal
	add		lpVal,eax
	inc		lpVal
 @@:
	invoke iniGetItem,addr buffer,addr buffer1
	invoke SendMessage,hTxtLst,LB_ADDSTRING,0,addr buffer1
	mov		nInx,eax
	invoke SendMessage,hTxtLst,LB_SETITEMDATA,nInx,lpVal
	mov		esi,lpVal
	mov		eax,[esi]
	xor		eax,-1
	and		eax,CtlValSt
	.if eax==[esi+4]
		mov		eax,[esi+8]
		xor		eax,-1
		and		eax,CtlValExSt
		.if eax==[esi+12]
			invoke SendMessage,hTxtLst,LB_SETCURSEL,nInx,0
		.endif
	.endif
	add		lpVal,16
	mov		al,buffer[0]
	or		al,al
	jne		@b
	ret

TxtLstMulti endp

PropTxtLstCode proc uses esi edi
	LOCAL	nInx:DWORD

	invoke SendMessage,hTxtLst,LB_RESETCONTENT,0,0
	invoke SendMessage,hPrpLstCode,LB_GETCOUNT,0,0
	.if eax
		invoke SendMessage,hPrpLstCode,LB_GETCURSEL,0,0
		mov		nInx,eax
		invoke SendMessage,hPrpLstCode,LB_GETITEMDATA,nInx,0
		mov		esi,lpWordList
		lea		esi,[esi+eax]
		.if [esi].PROPERTIES.nType!='l'
			invoke strlen,addr [esi+sizeof PROPERTIES]
			lea		esi,[esi+eax+sizeof PROPERTIES+1]
		  Nx:
			mov		edi,offset tempbuff
		  @@:
			mov		al,[esi]
			.if al==VK_TAB
				mov		al,':'
			.endif
			mov		[edi],al
			or		al,al
			je		En
			inc		esi
			inc		edi
			cmp		al,','
			jne		@b
			mov		al,0
			mov		[edi],al
			.if tempbuff
				invoke SendMessage,hTxtLst,LB_ADDSTRING,0,addr tempbuff
			.endif
			jmp		Nx
		  En:
			.if tempbuff
				invoke SendMessage,hTxtLst,LB_ADDSTRING,0,addr tempbuff
			.endif
		.endif
	.endif
	invoke SendMessage,hTxtLst,LB_GETCOUNT,0,0
	ret

PropTxtLstCode endp

PropTxtLst proc uses esi,hCtl:DWORD,lbid:DWORD
	LOCAL	nType:DWORD

	invoke GetWindowLong,hCtl,GWL_USERDATA
	mov		esi,eax
	assume esi:ptr DIALOG
	m2m		nType,[esi].ntype
	invoke SetWindowLong,hTxtLst,GWL_USERDATA,hCtl
	mov		eax,lbid
	.if eax==200
		invoke TxtLstFalseTrue,[esi].style,addr SysMDlg
	.elseif eax==201
		invoke TxtLstFalseTrue,[esi].style,addr MaxBDlg
	.elseif eax==202
		invoke TxtLstFalseTrue,[esi].style,addr MinBDlg
	.elseif eax==203
		invoke TxtLstFalseTrue,[esi].style,addr EnabAll
	.elseif eax==204
		invoke TxtLstFalseTrue,[esi].style,addr VisiAll
	.elseif eax==205
		invoke TxtLstFalseTrue,[esi].style,addr DefaBtn
	.elseif eax==206
		.if nType==5
			invoke TxtLstFalseTrue,[esi].style,addr AutoChk
		.elseif nType==6
			invoke TxtLstFalseTrue,[esi].style,addr AutoRbt
		.elseif nType==16
			invoke TxtLstFalseTrue,[esi].style,addr AutoSpn
		.elseif nType==18 || nType==19
			invoke TxtLstFalseTrue,[esi].style,addr AutoTbr
		.elseif nType==27
			invoke TxtLstFalseTrue,[esi].style,addr AutoAni
		.endif
	.elseif eax==207
		invoke TxtLstFalseTrue,[esi].style,addr MnemStc
	.elseif eax==208
		invoke TxtLstFalseTrue,[esi].style,addr WordStc
	.elseif eax==209
		.if nType==1 || nType==22
			invoke TxtLstFalseTrue,[esi].style,addr MultEdt
		.elseif nType==4 || nType==5 || nType==6
			invoke TxtLstFalseTrue,[esi].style,addr MultBtn
		.elseif nType==8
			invoke TxtLstFalseTrue,[esi].style,addr MultLst
		.elseif nType==11
			invoke TxtLstFalseTrue,[esi].style,addr MultTab
		.elseif nType==21
			invoke TxtLstFalseTrue,[esi].style,addr MultMvi
		.endif
	.elseif eax==210
		invoke TxtLstFalseTrue,[esi].style,addr LockEdt
	.elseif eax==211


		invoke TxtLstFalseTrue,[esi].style,addr ChilAll
	.elseif eax==212
		.if nType==0
			invoke TxtLstFalseTrue,[esi].style,addr SizeDlg
		.elseif nType==19
			invoke TxtLstFalseTrue,[esi].style,addr SizeSbr
		.endif
	.elseif eax==213
		invoke TxtLstFalseTrue,[esi].style,addr TabSAll
	.elseif eax==214
		.if nType==2 || nType==17 || nType==25
			invoke TxtLstFalseTrue,[esi].style,addr NotiStc
		.elseif nType==4 || nType==5 || nType==6
			invoke TxtLstFalseTrue,[esi].style,addr NotiBtn
		.elseif nType==8
			invoke TxtLstFalseTrue,[esi].style,addr NotiLst
		.endif
	.elseif eax==215
		invoke TxtLstFalseTrue,[esi].style,addr WantEdt
	.elseif eax==216
		.if nType==7
			invoke TxtLstFalseTrue,[esi].style,addr SortCbo
		.elseif nType==8
			invoke TxtLstFalseTrue,[esi].style,addr SortLst
		.endif
	.elseif eax==217
		invoke TxtLstFalseTrue,[esi].style,addr FlatTbr
	.elseif eax==218
		invoke TxtLstFalseTrue,[esi].style,addr GrouAll
	.elseif eax==220
		invoke TxtLstFalseTrue,[esi].style,addr UseTLst
	.elseif eax==221
		invoke TxtLstFalseTrue,[esi].style,addr SetBUdn
	.elseif eax==222
		.if nType==1 || nType==22
			invoke TxtLstFalseTrue,[esi].style,addr HideEdt
		.elseif nType==13
			invoke TxtLstFalseTrue,[esi].style,addr HideTrv
		.elseif nType==14
			invoke TxtLstFalseTrue,[esi].style,addr HideLsv
		.endif
	.elseif eax==223
		invoke TxtLstFalseTrue,[esi].exstyle,addr TopMost
	.elseif eax==224
		.if nType==7
			invoke TxtLstFalseTrue,[esi].style,addr IntHtCbo
		.elseif nType==8
			invoke TxtLstFalseTrue,[esi].style,addr IntHtLst
		.endif
	.elseif eax==225
		.if nType==11
			invoke TxtLstFalseTrue,[esi].style,addr ButtTab
		.elseif nType==13
			invoke TxtLstFalseTrue,[esi].style,addr ButtTrv
		.elseif nType==32
			invoke TxtLstFalseTrue,[esi].style,addr ButtHdr
		.endif
	.elseif eax==226
		invoke TxtLstFalseTrue,[esi].style,addr PopUAll
	.elseif eax==227
		.if nType==14
			invoke TxtLstFalseTrue,[esi].style,addr OwneLsv
		.else
			invoke TxtLstFalseTrue,[esi].style,addr OwneBtn
		.endif
	.elseif eax==228
		invoke TxtLstFalseTrue,[esi].style,addr TranAni
	.elseif eax==229
		invoke TxtLstFalseTrue,[esi].style,addr TimeAni
	.elseif eax==230
		invoke TxtLstFalseTrue,[esi].style,addr WeekMvi
	.elseif eax==231
		.if nType==11
			invoke TxtLstFalseTrue,[esi].style,addr ToolTab
		.else
			invoke TxtLstFalseTrue,[esi].style,addr ToolTbr
		.endif
	.elseif eax==232
		invoke TxtLstFalseTrue,[esi].style,addr WrapTbr
	.elseif eax==233
		invoke TxtLstFalseTrue,[esi].style,addr DiviTbr
	.elseif eax==234
		invoke TxtLstFalseTrue,[esi].style,addr DragHdr
	.elseif eax==235
		invoke TxtLstFalseTrue,[esi].style,addr SmooPgb
	.elseif eax==236
		.if nType==7
			invoke TxtLstFalseTrue,[esi].style,addr HasStcb
		.elseif nType==8
			invoke TxtLstFalseTrue,[esi].style,addr HasStlb
		.endif
	.elseif eax==300
		invoke TxtLstMulti,[esi].style,[esi].exstyle,addr ClipAll
	.elseif eax==301
		invoke TxtLstMulti,[esi].style,[esi].exstyle,addr ScroAll
	.elseif eax==302
		.if nType==1
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligEdt
		.elseif nType==2
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligStc
		.elseif nType==4
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligBtn
		.elseif nType==5 || nType==6
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligChk
		.elseif nType==11
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligTab
		.elseif nType==14
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligLsv
		.elseif nType==16
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligSpn
		.elseif nType==17
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligIco
		.elseif nType==18 || nType==19
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligTbr
		.elseif nType==27
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AligAni
		.endif
	.elseif eax==303
		.if nType==7
			invoke TxtLstFalseTrue,[esi].style,addr AutoCbo
		.else
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr AutoEdt
		.endif
	.elseif eax==304
		invoke TxtLstMulti,[esi].style,[esi].exstyle,addr FormDtp
	.elseif eax==305
		invoke TxtLstMulti,[esi].style,[esi].exstyle,addr StarDlg
	.elseif eax==306
		.if nType==12
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr OriePgb
		.elseif nType==16
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr OrieUdn
		.endif
	.elseif eax==307
		invoke TxtLstMulti,[esi].style,[esi].exstyle,addr SortLsv
	.elseif eax==308
		invoke TxtLstMulti,[esi].style,[esi].exstyle,addr OwneCbo
	.elseif eax==309
		invoke TxtLstMulti,[esi].style,[esi].exstyle,addr ElliStc
	.elseif eax==400
		mov		eax,nType
		.if eax==0
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr BordDlg
		.elseif eax==2 || eax==17 || eax==25
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr BordStc
		.elseif eax==3 || eax==4
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr BordBtn
		.else
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr BordAll
		.endif
	.elseif eax==401
		mov		eax,nType
		.if eax==1
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeEdt
		.elseif eax==4
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeBtn
		.elseif eax==7 || eax==24
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeCbo
		.elseif eax==13
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeTrv
		.elseif eax==14
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeLsv
		.elseif eax==17
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeImg
		.elseif eax==20
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeDtp
		.elseif eax==25
			invoke TxtLstMulti,[esi].style,[esi].exstyle,addr TypeStc
		.endif
	.elseif eax>65535
		mov		edx,[eax+4]
		.if dword ptr [eax]==1 || dword ptr [eax]==4 ; added type 4 for property descriptions
			invoke TxtLstFalseTrue,[esi].style,edx
		.elseif dword ptr [eax]==2 || dword ptr [eax]==5 ; added type 5 for property descriptions
			invoke TxtLstFalseTrue,[esi].exstyle,edx
		.elseif dword ptr [eax]==3 || dword ptr [eax]==6 ; added type 6 for property descriptions
			invoke TxtLstMulti,[esi].style,[esi].exstyle,edx
		.endif
		
		
	.endif
	assume esi:nothing
	ret

PropTxtLst endp

SetTxtLstPos proc lpRect:DWORD
	LOCAL	rect:RECT
	LOCAL	lbht:DWORD
	LOCAL	ht:DWORD

	invoke GetDesktopWindow
	mov		edx,eax
	invoke GetClientRect,edx,addr rect
	mov		eax,rect.bottom
	mov		ht,eax
	invoke CopyRect,addr rect,lpRect
	invoke ClientToScreen,hPrpLst,addr rect
	invoke SendMessage,hTxtLst,LB_GETITEMHEIGHT,0,0
	push	eax
	invoke SendMessage,hTxtLst,LB_GETCOUNT,0,0
	.if eax>8
		mov		eax,8
	.endif
	pop		edx
	mul		edx
	add		eax,2
	mov		lbht,eax
	add		eax,rect.top
	.if eax>ht
		mov		eax,lbht
		inc		eax
		add		eax,lbHt
		sub		rect.top,eax
	.endif
	invoke SetWindowPos,hTxtLst,HWND_TOP,rect.left,rect.top,rect.right,lbht,0
	invoke ShowWindow,hTxtLst,SW_SHOW;NOACTIVATE
	invoke SetFocus,hTxtLst
	ret

SetTxtLstPos endp

ProtoFindProc proc uses esi,lpProc:DWORD

	mov		esi,lpWordList
  @@:
	.if [esi].PROPERTIES.nType=='p'
		lea		eax,[esi+sizeof	PROPERTIES]
		invoke strcmp,lpProc,eax
		.if !eax
			lea		eax,[esi+sizeof	PROPERTIES]
			jmp		Ex
		.endif
	.endif
	mov		ecx,[esi].PROPERTIES.nSize
	lea		esi,[esi+ecx+sizeof	PROPERTIES]
	mov		eax,[esi].PROPERTIES.nSize
	or		eax,eax
	jne		@b
  Ex:
	ret

ProtoFindProc endp

PropListCodeProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	hEdt:DWORD
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==WM_LBUTTONDBLCLK
		invoke ShowWindow,hTxtBtn,SW_HIDE
		invoke ShowWindow,hTxtLst,SW_HIDE
		invoke SendMessage,hWin,LB_GETCOUNT,0,0
		.if eax && ShowProperties
			invoke SendMessage,hWin,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				mov		nInx,eax
				mov		edx,hEdit
				mov		hEdt,edx
				.if edx
					invoke SendMessage,edx,EM_EXGETSEL,0,addr chrg
				.endif
				invoke SendMessage,hWin,LB_GETTEXT,nInx,addr lbbuffer
				xor		eax,eax
				.while lbbuffer[eax]
					.if byte ptr lbbuffer[eax]==':' || byte ptr lbbuffer[eax]=='['
						mov		byte ptr lbbuffer[eax],0
						.break
					.endif
					inc		eax
				.endw
				invoke SendMessage,hWin,LB_GETITEMDATA,nInx,0
				mov		esi,lpWordList
				lea		esi,[esi+eax]
				invoke strlen,addr [esi+sizeof PROPERTIES]
				lea		edi,[esi+eax+sizeof PROPERTIES+1]
				mov		FileName,0
				mov		eax,[esi].PROPERTIES.Owner
				.if sdword ptr eax>0
					invoke GetFileNameFromID,eax
					.if eax
						push	eax
						invoke strcpy,addr FileName,addr ProjectPath
						pop		eax
						invoke strcat,addr FileName,eax
					.endif
				.else
					neg		eax
					invoke GetWindowText,eax,addr FileName,sizeof FileName
				.endif
				invoke ProjectOpenFile,TRUE
				invoke FindPropList,hEdit,addr lbbuffer,edi
				.if eax!=-1
					invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
					invoke SendMessage,hEdit,EM_SETSEL,eax,eax
					invoke SetFocus,hPrp
					invoke VerticalCenter,hEdit,REM_VCENTER
					invoke SetFocus,hEdit
					.if hEdt
						invoke PushRet,hEdt,chrg.cpMin
					.endif
				.endif
			.endif
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_CHAR
		.if wParam==VK_RETURN
			invoke SendMessage,hWin,WM_LBUTTONDBLCLK,0,0
		.endif
	.elseif eax==WM_LBUTTONUP
		invoke ShowWindow,hTxtBtn,SW_HIDE
		invoke ShowWindow,hTxtLst,SW_HIDE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		shr		eax,16
		.if eax==BN_CLICKED
			invoke DllProc,hWnd,AIM_COMMAND,wParam,lParam,RAM_COMMAND
			.if eax
				xor		eax,eax
				ret
			.endif
			mov		eax,wParam
			.if eax==1
				invoke IsWindowVisible,hTxtLst
				.if eax
					invoke ShowWindow,hTxtLst,SW_HIDE
					invoke SetFocus,hWin
				.else
					invoke SendMessage,hWin,LB_GETCURSEL,0,0
					.if eax!=LB_ERR
						mov		nInx,eax
						invoke PropTxtLstCode
						.if eax
							invoke SendMessage,hWin,LB_GETITEMRECT,nInx,addr rect
							mov		eax,lbHt
							add		rect.top,eax
							invoke SetTxtLstPos,addr rect
							invoke SendMessage,hTxtLst,LB_SETCURSEL,0,0
						.endif
					.endif
				.endif
			.endif
			invoke DllProc,hWnd,AIM_COMMANDDONE,wParam,lParam,RAM_COMMANDDONE
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_CTLCOLORLISTBOX
		invoke SetTextColor,wParam,radcol.propertiestext
		invoke SetBkColor,wParam,radcol.properties
		mov		eax,hBrPrp
		jmp		Ex
	.elseif eax==WM_CTLCOLOREDIT
		invoke SetTextColor,wParam,radcol.propertiestext
		invoke SetBkColor,wParam,radcol.properties
		mov		eax,hBrPrp
		jmp		Ex
	.elseif eax==WM_CONTEXTMENU
		mov		eax,hWin
		.if eax==hPrpLstCode
			invoke DllProc,hWnd,AIM_CONTEXTMENU,wParam,lParam,RAM_CONTEXTMENU
			.if eax
				xor		eax,eax
				ret
			.endif
			invoke GetWindowRect,hWin,addr rect
			mov		eax,lParam
			shr		eax,16
			cwde
			mov		edx,eax
			mov		eax,lParam
			cwde
			sub		eax,rect.left
			sub		edx,rect.top
			shl		edx,16
			mov		dx,ax
			invoke SendMessage,hWin,WM_LBUTTONDOWN,0,edx
			invoke SendMessage,hWin,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				mov		eax,lParam
				cwde
				mov		pt.x,eax
				mov		eax,lParam
				shr		eax,16
				cwde
				mov		pt.y,eax
				invoke GetSubMenu,hToolMenu,4
				mov		esi,eax
				mov		edi,MF_GRAYED
				.if hEdit
					mov		edi,MF_ENABLED
				.endif
				invoke EnableMenuItem,esi,IDM_PROPERTY_COPY,edi
				invoke EnableMenuItem,esi,IDM_PROPERTY_FIND,edi
				invoke EnableMenuItem,esi,IDM_PROPERTY_FINDNEXT,edi
				invoke EnableMenuItem,esi,IDM_PROPERTY_FINDPREV,edi
				mov		edi,MF_GRAYED
				.if fProject
					mov		edi,MF_ENABLED
				.endif
				invoke EnableMenuItem,esi,IDM_PROPERTY_SCAN,edi
				invoke SendMessage,hPrpCbo,CB_GETCURSEL,0,0
				mov		edi,MF_GRAYED
				.if !eax
					mov		edi,MF_ENABLED
				.endif
				invoke EnableMenuItem,esi,IDM_PROPERTY_PROTO,edi
				invoke TrackPopupMenu,esi,TPM_LEFTALIGN or TPM_RIGHTBUTTON,pt.x,pt.y,0,hWnd,0
			.endif
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_SETFOCUS || eax==WM_KILLFOCUS
	    invoke ShowWindow,hPrpLstDlg,SW_HIDE
	    invoke ShowWindow,hPrpLst,SW_HIDE
	    invoke ShowWindow,hPrpTxtDesc,SW_HIDE
		invoke SetPrpFocus
	.elseif eax==WM_VSCROLL || eax==WM_MOUSEWHEEL
		invoke ShowWindow,hTxtBtn,SW_HIDE
		invoke ShowWindow,hTxtLst,SW_HIDE
	.endif
	invoke CallWindowProc,OldPropListCodeProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

PropListCodeProc endp

PropListDlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	rect:RECT
	LOCAL	hCtl:DWORD
	LOCAL	lbid:DWORD
	LOCAL	lf:LOGFONT
	LOCAL	hFnt:DWORD

	assume esi:ptr DIALOG
	mov		eax,uMsg
	.if eax==WM_LBUTTONDBLCLK
		invoke GetWindowLong,hMdiCld,8
		or		eax,eax
		jne		ExErr
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		cmp		eax,LB_ERR
		je		ExErr
		mov		nInx,eax
		invoke SendMessage,hWin,LB_GETITEMDATA,nInx,0
		cmp		eax,LB_ERR
		je		ExErr
		mov		lbid,eax
		.if (eax>=200 && eax<=499) || eax>65535
			invoke GetWindowLong,hWin,GWL_USERDATA
			mov		hCtl,eax
			invoke PropTxtLst,hCtl,lbid
			invoke SendMessage,hTxtLst,LB_GETCURSEL,0,0
			inc		eax
			mov		nInx,eax
			invoke SendMessage,hTxtLst,LB_GETCOUNT,0,0
			.if eax==nInx
				mov		nInx,0
			.endif
			invoke SendMessage,hTxtLst,LB_SETCURSEL,nInx,0
			invoke SendMessage,hTxtLst,WM_LBUTTONUP,0,0
		.elseif eax==1000 || eax==1002 || eax==1003 || eax==1004 || eax==1005 || eax==1006 || eax==StrCapMulti
			invoke SendMessage,hWin,WM_COMMAND,1,0
		.else
			invoke PropListSetPos
			invoke ShowWindow,hPrpTxt,SW_SHOW
			invoke SetFocus,hPrpTxt
			invoke SendMessage,hPrpTxt,EM_SETSEL,0,-1
		.endif
	  ExErr:
		xor		eax,eax
		ret
	.elseif eax==WM_LBUTTONDOWN
		invoke ShowWindow,hTxtLst,SW_HIDE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		movzx	eax,ax
		.if edx==BN_CLICKED && eax==1
			invoke GetWindowLong,hMdiCld,8
			or		eax,eax
			jne		ExErr
			invoke GetWindowLong,hTxtLst,GWL_STYLE
			and		eax,WS_VISIBLE
			.if eax
				invoke ShowWindow,hTxtLst,SW_HIDE
			.else
				invoke SendMessage,hWin,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke GetWindowLong,hWin,GWL_USERDATA
					mov		hCtl,eax
					invoke SendMessage,hWin,LB_GETITEMDATA,nInx,0
					mov		lbid,eax
					.if lbid==StrCapMulti
						invoke SendMessage,hWin,LB_GETITEMRECT,nInx,addr rect
						mov		eax,lbHt
						add		rect.top,eax
						mov		eax,lbTp
						inc		eax
						add		rect.left,eax
						mov		eax,rect.left
						sub		rect.right,eax
						invoke GetWindowLong,hCtl,GWL_USERDATA
						mov		esi,eax
						invoke ConvertCaption,addr lbtxtbuffer,addr (DIALOG ptr [esi]).caption
						invoke SetWindowText,hPrpTxtMulti,addr lbtxtbuffer
						mov		eax,lbHt
						shl		eax,3
						invoke SetWindowPos,hPrpTxtMulti,HWND_TOP,rect.left,rect.top,rect.right,eax,0
						invoke ShowWindow,hPrpTxtMulti,SW_SHOWNA
						invoke SetFocus,hPrpTxtMulti
						jmp		Ex
					.elseif lbid==1000
						invoke RtlZeroMemory,addr lf,sizeof lf
						invoke GetWindowLong,hCtl,GWL_USERDATA
						mov		esi,eax
						sub		esi,sizeof DLGHEAD
						invoke strcpy,addr lf.lfFaceName,addr (DLGHEAD ptr [esi]).font
						m2m		lf.lfHeight,(DLGHEAD ptr [esi]).fontht
						mov		al,(DLGHEAD ptr [esi]).charset
						mov		lf.lfCharSet,al
						mov		al,(DLGHEAD ptr [esi]).italic
						mov		lf.lfItalic,al
						movzx	eax,(DLGHEAD ptr [esi]).weight
						mov		lf.lfWeight,eax
						invoke FontChoose,hWin,addr lf,CF_SCREENFONTS or CF_INITTOLOGFONTSTRUCT,0
						.if eax
							mov		(DLGHEAD ptr [esi]).fontsize,eax
							mov		al,lf.lfCharSet
							mov		(DLGHEAD ptr [esi]).charset,al
							mov		al,lf.lfItalic
							mov		(DLGHEAD ptr [esi]).italic,al
							mov		eax,lf.lfWeight
							mov		(DLGHEAD ptr [esi]).weight,ax
							m2m		(DLGHEAD ptr [esi]).fontht,lf.lfHeight
							invoke strcpy,addr (DLGHEAD ptr [esi]).font,addr lf.lfFaceName
							mov		eax,(DLGHEAD ptr [esi]).hfont
							invoke DeleteObject,eax
							invoke MakeDlgFont,esi
							mov		hFnt,eax
							add		esi,sizeof DLGHEAD
							.while TRUE
								mov		eax,[esi].hwnd
							  .break .if !eax
								.if eax!=-1
									mov		eax,[esi].hcld
									.if !eax
										mov		eax,[esi].hwnd
									.endif
									invoke SendMessage,eax,WM_SETFONT,hFnt,TRUE
									mov		eax,[esi].hcld
									.if eax
										mov		eax,[esi].hwnd
										invoke InvalidateRect,eax,NULL,TRUE
									.endif
								.endif
								add		esi,sizeof DIALOG
							.endw
							invoke PropertyList,hCtl
							invoke SetChanged,TRUE,0
						.endif
					.elseif lbid==1002
						invoke RtlZeroMemory,addr ofn,sizeof ofn
						mov		ofn.lStructSize,sizeof ofn
						m2m		ofn.hwndOwner,hWin
						m2m		ofn.hInstance,hInstance
						mov		ofn.lpstrInitialDir,offset ProjectPath
						mov		ofn.lpstrFilter,offset MNUFilterString
						mov		ofn.lpstrTitle,offset SelectMenu
						invoke GetWindowLong,hCtl,GWL_USERDATA
						mov		esi,eax
						sub		esi,sizeof DLGHEAD
						invoke GetFileImg,addr (DLGHEAD ptr [esi]).menuid
						.if eax==6
							invoke strcpy,addr FileName,addr (DLGHEAD ptr [esi]).menuid
						.else
							mov		byte ptr [FileName],0
						.endif
						mov		ofn.lpstrFile,offset FileName
						mov		ofn.nMaxFile,sizeof FileName
						mov		ofn.Flags,OFN_PATHMUSTEXIST
						invoke GetOpenFileName,addr ofn
						.if eax!=0
							invoke GetFileAttributes,addr FileName
							.if eax!=-1
								invoke RemovePath,addr FileName,offset ProjectPath,addr lbbuffer
								invoke lstrcpyn,addr (DLGHEAD ptr [esi]).menuid,eax,32
								invoke UpdateCtl,hCtl
								invoke SendMessage,hWin,LB_SETCURSEL,nInx,0
								invoke PropListSetPos
								.if !eax
									invoke PropListSetTxt,hWin
								.endif
							.endif
						.endif
					.elseif lbid==1005
						invoke RtlZeroMemory,addr ofn,sizeof ofn
						mov		ofn.lStructSize,sizeof ofn
						m2m		ofn.hwndOwner,hWin
						m2m		ofn.hInstance,hInstance
						mov		ofn.lpstrInitialDir,offset ProjectPath
						mov		ofn.lpstrTitle,offset SelectImage
						invoke GetWindowLong,hCtl,GWL_USERDATA
						mov		esi,eax
						mov		eax,[esi].DIALOG.style
						and		eax,0Fh
						.if eax==3
							mov		ofn.lpstrFilter,offset ICOFilterString
						.else
							mov		ofn.lpstrFilter,offset BMPFilterString
						.endif
						invoke GetFileImg,addr (DIALOG ptr [esi]).caption
						.if eax==30 || eax==31
							invoke strcpy,addr FileName,addr (DIALOG ptr [esi]).caption
						.else
							mov		byte ptr [FileName],0
						.endif
						mov		ofn.lpstrFile,offset FileName
						mov		ofn.nMaxFile,sizeof FileName
						mov		ofn.Flags,OFN_PATHMUSTEXIST
						invoke GetOpenFileName,addr ofn
						.if eax!=0
							invoke GetFileAttributes,addr FileName
							.if eax!=-1
								invoke RemovePath,addr FileName,offset ProjectPath,addr lbbuffer
								invoke lstrcpyn,addr (DIALOG ptr [esi]).caption,eax,MaxCap
								invoke UpdateCtl,hCtl
								invoke SendMessage,hWin,LB_SETCURSEL,nInx,0
								invoke PropListSetPos
								.if !eax
									invoke PropListSetTxt,hWin
								.endif
							.endif
						.endif
					.elseif lbid==1006
						invoke RtlZeroMemory,addr ofn,sizeof ofn
						mov		ofn.lStructSize,sizeof ofn
						m2m		ofn.hwndOwner,hWin
						m2m		ofn.hInstance,hInstance
						mov		ofn.lpstrInitialDir,offset ProjectPath
						mov		ofn.lpstrTitle,offset SelectImage
						invoke GetWindowLong,hCtl,GWL_USERDATA
						mov		esi,eax
						mov		ofn.lpstrFilter,offset AVIFilterString
						invoke strcpy,addr FileName,addr (DIALOG ptr [esi]).caption
						mov		ofn.lpstrFile,offset FileName
						mov		ofn.nMaxFile,sizeof FileName
						mov		ofn.Flags,OFN_PATHMUSTEXIST
						invoke GetOpenFileName,addr ofn
						.if eax!=0
							invoke GetFileAttributes,addr FileName
							.if eax!=-1
								invoke RemovePath,addr FileName,offset ProjectPath,addr lbbuffer
								invoke lstrcpyn,addr (DIALOG ptr [esi]).caption,eax,MaxCap
								invoke UpdateCtl,hCtl
								invoke SendMessage,hWin,LB_SETCURSEL,nInx,0
								invoke PropListSetPos
								.if !eax
									invoke PropListSetTxt,hWin
								.endif
							.endif
						.endif
					.elseif lbid==1003
						invoke GetWindowLong,hCtl,GWL_USERDATA
						mov		StyleOfs,eax
						mov		StyleTxt,offset szExStyle
						mov		StyleEx,TRUE
						invoke DllProc,hWin,AIM_SETSTYLE,StyleOfs,TRUE,RAM_SETSTYLE
						.if !eax
							invoke ModalDialog,hInstance,IDD_PROPERTY,hWnd,addr PropertyDlgProc,0
						.endif
						invoke SendMessage,hWin,LB_SETCURSEL,nInx,0
					.elseif lbid==1004
						invoke GetWindowLong,hCtl,GWL_USERDATA
						mov		StyleOfs,eax
						mov		StyleTxt,offset szStyle
						mov		StyleEx,FALSE
						invoke DllProc,hWin,AIM_SETSTYLE,StyleOfs,FALSE,RAM_SETSTYLE
						.if !eax
							invoke ModalDialog,hInstance,IDD_PROPERTY,hWnd,addr PropertyDlgProc,0
						.endif
						invoke SendMessage,hWin,LB_SETCURSEL,nInx,0
					.else
						invoke SendMessage,hWin,LB_GETITEMRECT,nInx,addr rect
						mov		eax,lbHt
						add		rect.top,eax
						mov		eax,lbTp
						inc		eax
						add		rect.left,eax
						mov		eax,rect.left
						sub		rect.right,eax
						invoke PropTxtLst,hCtl,lbid
						invoke SetTxtLstPos,addr rect
						jmp		Ex
					.endif
				.endif
			.endif
			invoke SetFocus,hPrp
		.endif
	.elseif eax==WM_CHAR
		.if wParam==VK_RETURN
			invoke SendMessage,hWin,WM_LBUTTONDBLCLK,0,0
		.elseif wParam==VK_TAB
			invoke SetFocus,hMdiCld
			invoke SendMessage,hMdiCld,WM_KEYDOWN,VK_TAB,0
		.endif
	.elseif eax==WM_CTLCOLORLISTBOX
		invoke SetTextColor,wParam,radcol.propertiestext
		invoke SetBkColor,wParam,radcol.properties
		mov		eax,hBrPrp
		ret
	.elseif eax==WM_CTLCOLOREDIT
		invoke SetTextColor,wParam,radcol.propertiestext
		invoke SetBkColor,wParam,radcol.properties
		mov		eax,hBrPrp
		ret
	.elseif eax==WM_SETFOCUS || eax==WM_KILLFOCUS
		invoke SetPrpFocus
	.elseif eax==WM_VSCROLL || eax==WM_MOUSEWHEEL
		invoke ShowWindow,hPrpTxtMulti,SW_HIDE
		invoke ShowWindow,hTxtBtn,SW_HIDE
		invoke ShowWindow,hTxtLst,SW_HIDE
		invoke ShowWindow,hPrpTxt,SW_HIDE
	.endif
	invoke CallWindowProc,OldPropListDlgProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

PropListDlgProc endp

PropEditChkVal proc uses esi,lpTxt:DWORD,nTpe:DWORD,lpfErr:DWORD
	LOCAL buffer[16]:BYTE
	LOCAL val:DWORD

	mov		eax,lpfErr
	mov		dword ptr [eax],FALSE
	invoke DecToBin,lpTxt
	mov		val,eax
	invoke BinToDec,val,addr buffer
	invoke strcmp,lpTxt,addr buffer
	.if eax
		mov		eax,lpfErr
		mov		dword ptr [eax],TRUE
		invoke MessageBox,hWnd,addr szPropErr,addr AppName,MB_OK or MB_ICONERROR
	.endif
	mov		eax,val
	ret

PropEditChkVal endp

PropEditUpdList proc uses esi edi,lpPtr:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	hCtl:DWORD
	LOCAL	lpTxt:DWORD
	LOCAL	fErr:DWORD
	LOCAL	lbid:DWORD
	LOCAL	val:DWORD

	mov		fErr,FALSE
	invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		invoke SendMessage,hPrpLst,LB_SETCURSEL,-1,0
		invoke ShowWindow,hPrpTxtMulti,SW_HIDE
		invoke ShowWindow,hPrpTxt,SW_HIDE
		invoke ShowWindow,hTxtBtn,SW_HIDE
		invoke ShowWindow,hTxtLst,SW_HIDE
		;Get text
		invoke SendMessage,hPrpLst,LB_GETTEXT,nInx,addr buffer
		invoke GetWindowText,hPrpTxt,addr buffer1,sizeof buffer1
		;Find TAB char
		lea		esi,buffer
	  @@:
		mov		al,[esi]
		inc		esi
		cmp		al,09h
		jne		@b
		mov		lpTxt,esi
		;Text changed ?
		invoke strcmp,lpTxt,addr buffer1
		.if eax
			;Get controls hwnd
			invoke GetWindowLong,hPrpLst,GWL_USERDATA
			mov		hCtl,eax
			;and ptr data
			invoke GetWindowLong,hCtl,GWL_USERDATA
			mov		esi,eax
			assume esi:ptr DIALOG
			;Get type
			invoke SendMessage,hPrpLst,LB_GETITEMDATA,nInx,0
			mov		lbid,eax
			;Pos, Size or ID
			.if eax>=NumID && eax<=NumTab
				;Test valid num
				invoke PropEditChkVal,addr buffer1,lbid,addr fErr
				mov		val,eax
			.endif
			.if !fErr
				;What is changed
				mov		eax,dword ptr buffer
				mov		edx,lbid
				mov		ecx,val
				.if edx==NumID
					mov		[esi].id,ecx
				.elseif edx==NumPosL
					mov		[esi].x,ecx
				.elseif edx==NumPosT
					mov		[esi].y,ecx
				.elseif edx==NumSizeW
					mov		[esi].ccx,ecx
				.elseif edx==NumSizeH
					mov		[esi].ccy,ecx
				.elseif edx==NumStartID
					mov		edx,esi
					sub		edx,sizeof DLGHEAD
					mov		(DLGHEAD ptr [edx]).ctlid,ecx
				.elseif edx==NumTab
					invoke SetNewTab,hCtl,ecx
				.elseif edx==StrNme	;Name
					invoke strcpy,addr [esi].idname,addr buffer1
				.elseif edx==StrCap	|| edx==StrCapMulti	;Caption
					invoke strcpy,addr [esi].caption,addr buffer1
				.elseif edx==1005	;Image
					invoke strcpy,addr [esi].caption,addr buffer1
				.elseif edx==1006	;AviClip
					invoke strcpy,addr [esi].caption,addr buffer1
				.elseif edx==1000	;Font
					mov		edx,esi
					sub		edx,sizeof DLGHEAD
					invoke strcpy,addr (DLGHEAD ptr [edx]).font,addr buffer1
				.elseif edx==1001	;Class
					mov		eax,[esi].ntype
					.if eax==0
						mov		edx,esi
						sub		edx,sizeof DLGHEAD
						invoke strcpy,addr (DLGHEAD ptr [edx]).class,addr buffer1
					.elseif eax==23
						invoke strcpy,addr [esi].class,addr buffer1
					.endif
				.elseif edx==1002	;Menu
					mov		edx,esi
					sub		edx,sizeof DLGHEAD
					invoke strcpy,addr (DLGHEAD ptr [edx]).menuid,addr buffer1
				.endif
				mov		eax,lbid
				;Is True/False Style or Multi Style changed
				mov		edi,lpPtr
				.if eax>=200 && eax<=499
					.if eax==223
						mov		eax,[esi].exstyle
						and		eax,[edi]
						or		eax,[edi+4]
						mov		[esi].exstyle,eax
					.else
						mov		eax,[esi].style
						and		eax,[edi]
						or		eax,[edi+4]
						mov		[esi].style,eax
					.endif
					;Is Multi Style changed
					mov		eax,lbid
					.if eax>=300
						mov		eax,[esi].exstyle
						and		eax,[edi+8]
						or		eax,[edi+12]
						mov		[esi].exstyle,eax
					.endif
				.elseif eax>65535
					.if dword ptr [eax]==1 || dword ptr [eax]==4 ; added 4 for property descriptions
						mov		eax,[esi].style
						and		eax,[edi]
						or		eax,[edi+4]
						mov		[esi].style,eax
					.elseif dword ptr [eax]==2 || dword ptr [eax]==5 ; added 5 for property descriptions
						mov		eax,[esi].exstyle
						and		eax,[edi]
						or		eax,[edi+4]
						mov		[esi].exstyle,eax
					.elseif dword ptr [eax]==3 || dword ptr [eax]==6 ; added 6 for property descriptions
						mov		eax,[esi].style
						and		eax,[edi]
						or		eax,[edi+4]
						mov		[esi].style,eax
						mov		eax,[esi].exstyle
						and		eax,[edi+8]
						or		eax,[edi+12]
						mov		[esi].exstyle,eax
					.endif
				.endif
				invoke UpdateCtl,hCtl
				assume esi:nothing
			.endif
		.endif
	.endif
	ret

PropEditUpdList endp

PropEditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hCtl:HWND

	mov		eax,uMsg
	.if eax==WM_SETFOCUS || eax==WM_KILLFOCUS
		.if eax==WM_KILLFOCUS 
			invoke PropEditUpdList,0
		.endif
		invoke SetPrpFocus
	.elseif eax==WM_CHAR
		.if wParam==VK_RETURN || wParam==VK_TAB
			invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
			mov		nInx,eax
			invoke SetFocus,hMdiCld
			invoke SendMessage,hPrpLst,LB_SETCURSEL,nInx,0
			invoke PropListSetPos
			.if wParam==VK_RETURN
				invoke SetFocus,hPrpLst
			.else
				invoke SendMessage,hMdiCld,WM_KEYDOWN,VK_TAB,0
			.endif
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_KEYUP
		invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
		mov		edx,eax
		invoke SendMessage,hPrpLst,LB_GETTEXT,edx,addr buffer
		.if dword ptr buffer=='tpaC'
			push	esi
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke ConvertCaption,addr buffer,addr buffer
			invoke GetWindowLong,hPrpLst,GWL_USERDATA
			mov		hCtl,eax
			invoke GetWindowLong,hCtl,GWL_USERDATA
			.if [eax].DIALOG.ntype==3 || [eax].DIALOG.ntype==33
				mov		edx,[eax].DIALOG.hcld
				mov		hCtl,edx
			.endif
			invoke SetWindowText,hCtl,addr buffer
			invoke SetWindowText,hPrpTxtMulti,addr buffer
			pop		esi
		.endif
	.endif
	invoke CallWindowProc,OldPropEditProc,hWin,uMsg,wParam,lParam
	ret

PropEditProc endp

PropEditMultiProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	hCtl:HWND

	mov		eax,uMsg
	.if eax==WM_SETFOCUS || eax==WM_KILLFOCUS
		mov		edx,lParam
		.if eax==WM_KILLFOCUS
			invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
			push	eax
			invoke PropEditUpdList,0
			pop		eax
			invoke SendMessage,hPrpLst,LB_SETCURSEL,eax,0
			invoke ShowWindow,hTxtBtn,SW_SHOWNA
		.else
			invoke ShowWindow,hPrpTxt,SW_HIDE
		.endif
		invoke SetPrpFocus
	.elseif eax==WM_CHAR
		.if wParam==VK_RETURN
			invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
			mov		nInx,eax
			invoke SetFocus,hMdiCld
			invoke SendMessage,hPrpLst,LB_SETCURSEL,nInx,0
			invoke PropListSetPos
			invoke SetFocus,hPrpLst
			xor		eax,eax
			ret
		.endif
	.elseif eax==WM_KEYUP
		invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
		mov		edx,eax
		invoke SendMessage,hPrpLst,LB_GETTEXT,edx,addr buffer
		.if dword ptr buffer=='tpaC'
			push	esi
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke GetWindowLong,hPrpLst,GWL_USERDATA
			mov		hCtl,eax
			invoke GetWindowLong,hCtl,GWL_USERDATA
			.if [eax].DIALOG.ntype==3
				mov		edx,[eax].DIALOG.hcld
				mov		hCtl,edx
			.endif
			invoke SetWindowText,hCtl,addr buffer
			invoke DeConvertCaption,addr buffer1,addr buffer
			invoke SetWindowText,hPrpTxt,addr buffer1
			pop		esi
		.endif
	.endif
	invoke CallWindowProc,OldPropEditMultiProc,hWin,uMsg,wParam,lParam
	ret

PropEditMultiProc endp

PropTxtLstProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	lbid:DWORD
	LOCAL	buffer[512]:BYTE
	LOCAL	pt:POINT

	mov		eax,uMsg
	.if eax==WM_LBUTTONUP
		invoke CallWindowProc,OldPropTxtLstProc,hWin,uMsg,wParam,lParam
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		.if eax!=LB_ERR
			mov		nInx,eax
			.if  hDialog
				invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
				push	eax
				invoke SendMessage,hWin,LB_GETTEXT,nInx,addr buffer
				invoke SetWindowText,hPrpTxt,addr buffer
				invoke SendMessage,hWin,LB_GETITEMDATA,nInx,0
				mov		lbid,eax
				;PrintText 'PropTxtLstProc'
				;PrintDec lbid
				;Invoke PropSetTxtDesc, lbid
				invoke PropEditUpdList,lbid
				pop		nInx
				invoke SendMessage,hPrpLst,LB_SETCURSEL,nInx,0
				invoke PropListSetPos
				invoke SetFocus,hMdiCld
			.else
				invoke SendMessage,hWin,LB_GETTEXT,nInx,offset FindBuffer
				mov		edx,offset FindBuffer
				.while byte ptr [edx]
					.if byte ptr [edx]==' ' || byte ptr [edx]==',' || byte ptr [edx]==':'
						mov		byte ptr [edx],0
					.else
						inc		edx
					.endif
				.endw
				invoke SendMessage,hPrpLst,WM_LBUTTONDBLCLK,0,0
				push	fMatchCase
				push	fWholeWord
				mov		fMatchCase,TRUE
				mov		fWholeWord,TRUE
				invoke SendMessage,hWnd,WM_COMMAND,IDM_EDIT_FINDNEXT,0
				pop		fWholeWord
				pop		fMatchCase
				invoke SetFocus,hEdit
			.endif
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_MOUSEMOVE
		invoke SendMessage,hWin,LB_GETCURSEL,0,0
		push	eax
		invoke GetCursorPos,addr pt
		invoke LBItemFromPt,hWin,pt.x,pt.y,TRUE
		pop		edx
		.if eax!=edx
			invoke SendMessage,hWin,LB_SETCURSEL,eax,0
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_CHAR
		.if wParam==13
			invoke SendMessage,hWin,WM_LBUTTONUP,0,0
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_ACTIVATE
		mov		eax,wParam
		movzx	eax,ax
		mov		edx,lParam
		.if eax!=WA_INACTIVE
			invoke SendMessage,hWnd,WM_NCACTIVATE,TRUE,0
		.elseif edx!=hWnd
			invoke SendMessage,hWnd,WM_NCACTIVATE,FALSE,0
		.endif
	.elseif eax==WM_SETFOCUS
		;invoke SendMessage,hWnd,WM_NCACTIVATE,TRUE,0
        invoke ShowWindow,hPrpTbrCode,SW_HIDE
		invoke ShowWindow,hPrpCboCode,SW_HIDE		
		invoke ShowWindow,hPrpLstCode,SW_HIDE
		invoke SetPrpFocus
	.elseif eax==WM_KILLFOCUS
		invoke ShowWindow,hWin,SW_HIDE
		invoke SetPrpFocus
		xor		eax,eax
		jmp		Ex
	.endif
	invoke CallWindowProc,OldPropTxtLstProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

PropTxtLstProc endp

ButtonPic proc hWin:HWND,fDown:DWORD
	LOCAL	hDC:HDC
	LOCAL	rect:RECT

	invoke GetWindowLong,hWin,GWL_USERDATA
	.if (eax<1000 || eax>65535) && eax!=StrCapMulti
		invoke GetClientRect,hWin,addr rect
		invoke GetDC,hWin
		mov		hDC,eax
		.if fDown
			invoke DrawFrameControl,hDC,addr rect,DFC_SCROLL,DFCS_SCROLLDOWN or DFCS_PUSHED
		.else
			invoke DrawFrameControl,hDC,addr rect,DFC_SCROLL,DFCS_SCROLLDOWN
		.endif
		invoke ReleaseDC,hWin,hDC
	.endif
	ret

ButtonPic endp

PropTxtBtnProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_PAINT || eax==WM_MOUSEMOVE
		invoke CallWindowProc,OldPropTxtBtnProc,hWin,uMsg,wParam,lParam
		push	eax
		invoke GetCapture
		.if eax==hWin
			invoke	ButtonPic,hWin,TRUE
		.else
			invoke	ButtonPic,hWin,FALSE
		.endif
		pop		eax
		jmp		Ex
	.elseif eax==WM_SETFOCUS || eax==WM_KILLFOCUS
		invoke SetPrpFocus
	.endif
	invoke CallWindowProc,OldPropTxtBtnProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

PropTxtBtnProc endp

ListFalseTrue proc uses esi,CtlVal:DWORD,lpVal:DWORD,lpBuff:DWORD
; invoke ListFalseTrue,[esi].style,[eax+4],edi
	mov		esi,lpVal
	mov		eax,[esi]
	xor		eax,-1
	and		eax,CtlVal
	.if eax==[esi+4]
		invoke strcpy,lpBuff,addr szFalse
	.else
		invoke strcpy,lpBuff,addr szTrue
	.endif
	ret

ListFalseTrue endp

ListMultiStyle proc uses esi,CtlValSt:DWORD,CtlValExSt:DWORD,lpVal:DWORD,lpBuff:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[64]:BYTE

	invoke strcpy,addr buffer,lpVal
	invoke strlen,lpVal
	add		lpVal,eax
	inc		lpVal
 @@:
	invoke iniGetItem,addr buffer,addr buffer1
	mov		esi,lpVal
	mov		eax,[esi]
	xor		eax,-1
	and		eax,CtlValSt
	.if eax==[esi+4]
		mov		eax,[esi+8]
		xor		eax,-1
		and		eax,CtlValExSt
		.if eax==[esi+12]
			invoke strcpy,lpBuff,addr buffer1
			ret
		.endif
	.endif
	add		lpVal,16
	mov		al,buffer[0]
	or		al,al
	jne		@b
	ret

ListMultiStyle endp

PropSetOwner proc fCode:DWORD

	.if fCode
		m2m		hPrpCbo,hPrpCboCode
		m2m		hPrpLst,hPrpLstCode
		invoke ShowWindow,hPrpCboDlg,SW_HIDE
		invoke ShowWindow,hPrpTbrCode,SW_SHOWNA
		invoke ShowWindow,hPrpCboCode,SW_SHOWNA
		invoke ShowWindow,hPrpLstDlg,SW_HIDE
		invoke ShowWindow,hPrpLst,SW_HIDE
		invoke ShowWindow,hPrpTxtDesc,SW_HIDE
		invoke ShowWindow,hPrpLstCode,SW_SHOWNA
		invoke InvalidateRect,hPrp,NULL,TRUE
	.else
		m2m		hPrpCbo,hPrpCboDlg
		m2m		hPrpLst,hPrpLstDlg
		invoke ShowWindow,hPrpTbrCode,SW_HIDE
		invoke ShowWindow,hPrpCboCode,SW_HIDE
		invoke ShowWindow,hPrpCboDlg,SW_SHOWNA
		invoke ShowWindow,hPrpLstCode,SW_HIDE
		invoke ShowWindow,hPrpLstDlg,SW_SHOWNA
		invoke ShowWindow,hPrpLst,SW_SHOWNA
		invoke ShowWindow,hPrpTxtDesc,SW_SHOWNA
		invoke SetParent,hPrpTxtMulti,hPrpLst
	.endif
	invoke SetParent,hTxtBtn,hPrpLst
	invoke SetParent,hPrpTxt,hPrpLst
	ret

PropSetOwner endp

PropertyList proc uses esi edi,hCtl:DWORD
	LOCAL	buffer1[512]:BYTE
	LOCAL	nType:DWORD
	LOCAL   nTypeID:DWORD
	LOCAL	lbid:DWORD
	LOCAL	fList:DWORD
	LOCAL	fList1:DWORD
	LOCAL	fList2:DWORD
	LOCAL	fList3:DWORD
	LOCAL	nInx:DWORD
	LOCAL	tInx:DWORD
	LOCAL   nPr:DWORD
	LOCAL   nLenProperties:DWORD
	LOCAL   ptrProperties:DWORD
	LOCAL   ptrMethods:DWORD
	LOCAL   pos:DWORD

	invoke ToolBarStatus
	invoke PropSetOwner,FALSE
	invoke ShowWindow,hPrpLstCode,SW_HIDE
	invoke ShowWindow,hPrpLstDlg,SW_SHOWNA
	invoke ShowWindow,hPrpLst,SW_SHOWNA
	Invoke ShowWindow,hPrpTxtDesc,SW_SHOWNA
	invoke SendMessage,hPrpCbo,CB_RESETCONTENT,0,0
	invoke ShowWindow,hPrpTxtMulti,SW_HIDE
	invoke ShowWindow,hPrpTxt,SW_HIDE
	invoke ShowWindow,hTxtBtn,SW_HIDE
	invoke ShowWindow,hTxtLst,SW_HIDE
	invoke SendMessage,hPrpLst,LB_GETTOPINDEX,0,0
	mov		tInx,eax
	invoke SendMessage,hPrpLst,WM_SETREDRAW,FALSE,0
	invoke SendMessage,hPrpLst,LB_RESETCONTENT,0,0
	invoke SendMessage,hPrpLst,LB_SETITEMHEIGHT,0,lbHt
	.if hCtl
		invoke GetWindowLong,hCtl,GWL_USERDATA
		or		eax,eax
		je		Ex
		mov		esi,eax
		invoke SetWindowLong,hPrpLst,GWL_USERDATA,hCtl
		assume esi:ptr DIALOG
		mov		eax,[esi].ntype
		mov		nType,eax
		mov		eax,[esi].ntypeid
		mov		nTypeID,eax
		invoke GetTypePtr,nType
		m2m		fList,(TYPES ptr [eax]).flist
		m2m		fList1,(TYPES ptr [eax]).flist+4
		m2m		fList2,(TYPES ptr [eax]).flist+8
		m2m		fList3,(TYPES ptr [eax]).flist+12
		.if fSimpleProperty
			and		fList, 11111110000000000000000000111000b
			and		fList1,00110000000000011010000000000000b
			and		fList2,00000000000000000000000000000000b
			and		fList3,00000000000000000000000000000000b
		.endif
		invoke strcpy,addr prnbuff,addr PrAll
		mov		nInx,0
	  @@:
		mov		dword ptr buffer1,0
		mov		dword ptr buffer1[4],0
		invoke iniGetItem,addr prnbuff,addr buffer1
		mov		al,buffer1[0]
		or		al,al
		je		@f
		shl		fList3,1
		rcl		fList2,1
		rcl		fList1,1
		rcl		fList,1
		.if CARRY?
			invoke strlen,addr buffer1
			lea		edi,buffer1[eax]
			mov		ax,09h
			stosw
			dec		edi
			mov		eax,nType
			mov		edx,nInx
			mov		lbid,0
			.if edx==0		;(Name)
				mov		lbid,StrNme
				invoke strcpy,edi,addr [esi].idname
			.elseif edx==1	;(ID)
				mov		lbid,NumID
				invoke BinToDec,[esi].id,edi
			.elseif edx==2	;Left
				mov		lbid,NumPosL
				invoke BinToDec,[esi].x,edi
			.elseif edx==3	;Top
				mov		lbid,NumPosT
				invoke BinToDec,[esi].y,edi
			.elseif edx==4	;Width
				mov		lbid,NumSizeW
				invoke BinToDec,[esi].ccx,edi
			.elseif edx==5	;Height
				mov		lbid,NumSizeH
				invoke BinToDec,[esi].ccy,edi
			.elseif edx==6	;Caption
				mov		lbid,StrCap
				.if eax==1
					;Edit
					mov		eax,[esi].style
					test	eax,ES_MULTILINE
					.if !ZERO?
						mov		lbid,StrCapMulti
					.endif
				.elseif eax==2
					;Static
					mov		lbid,StrCapMulti
				.elseif eax==4
					;Button
					mov		eax,[esi].style
					test	eax,BS_MULTILINE
					.if !ZERO?
						mov		lbid,StrCapMulti
					.endif
				.elseif eax==22
					;RichEdit
					mov		eax,[esi].style
					test	eax,ES_MULTILINE
					.if !ZERO?
						mov		lbid,StrCapMulti
					.endif
				.endif
				invoke strcpy,edi,addr [esi].caption
			.elseif edx==7	;Border
				mov		lbid,400
				.if eax==0
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr BordDlg,edi
				.elseif eax==2 || eax==17 || eax==25
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr BordStc,edi
				.elseif eax==3 || eax==4
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr BordBtn,edi
				.else
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr BordAll,edi
				.endif
			.elseif edx==8	;SysMenu
				mov		lbid,200
				invoke ListFalseTrue,[esi].style,addr SysMDlg,edi
			.elseif edx==9	;MaxButton
				mov		lbid,201
				invoke ListFalseTrue,[esi].style,addr MaxBDlg,edi
			.elseif edx==10	;MinButton
				mov		lbid,202
				invoke ListFalseTrue,[esi].style,addr MinBDlg,edi
			.elseif edx==11	;Enabled
				mov		lbid,203
				invoke ListFalseTrue,[esi].style,addr EnabAll,edi
			.elseif edx==12	;Visible
				mov		lbid,204
				invoke ListFalseTrue,[esi].style,addr VisiAll,edi
			.elseif edx==13	;Clipping
				mov		lbid,300
				invoke ListMultiStyle,[esi].style,[esi].exstyle,addr ClipAll,edi
			.elseif edx==14	;ScrollBar
				mov		lbid,301
				invoke ListMultiStyle,[esi].style,[esi].exstyle,addr ScroAll,edi
			.elseif edx==15	;Default
				mov		lbid,205
				invoke ListFalseTrue,[esi].style,addr DefaBtn,edi
			.elseif edx==16	;Auto
				mov		lbid,206
				.if eax==5
					invoke ListFalseTrue,[esi].style,addr AutoChk,edi
				.elseif eax==6
					invoke ListFalseTrue,[esi].style,addr AutoRbt,edi
				.elseif eax==16
					invoke ListFalseTrue,[esi].style,addr AutoSpn,edi
				.endif
			.elseif edx==17	;Alignment
				mov		lbid,302
				.if eax==1
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligEdt,edi
				.elseif eax==2
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligStc,edi
				.elseif eax==4
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligBtn,edi
				.elseif eax==5 || eax==6
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligChk,edi
				.elseif eax==11
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligTab,edi
				.elseif eax==14
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligLsv,edi
				.elseif eax==16
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligSpn,edi
				.elseif eax==17
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligIco,edi
				.elseif eax==18 || eax==19
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligTbr,edi
				.elseif eax==27
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AligAni,edi
				.endif
			.elseif edx==18	;Mnemonic
				mov		lbid,207
				invoke ListFalseTrue,[esi].style,addr MnemStc,edi
			.elseif edx==19	;WordWrap
				mov		lbid,208
				invoke ListFalseTrue,[esi].style,addr WordStc,edi
			.elseif edx==20	;MultiLine
				mov		lbid,209
				.if eax==1 || eax==22
					invoke ListFalseTrue,[esi].style,addr MultEdt,edi
				.elseif eax==4 || eax==5 || eax==6
					invoke ListFalseTrue,[esi].style,addr MultBtn,edi
				.elseif eax==11
					invoke ListFalseTrue,[esi].style,addr MultTab,edi
				.endif
			.elseif edx==21	;Type
				mov		lbid,401
				.if eax==1
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr TypeEdt,edi
				.elseif eax==4
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr TypeBtn,edi
				.elseif eax==7 || eax==24
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr TypeCbo,edi
				.elseif eax==13
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr TypeTrv,edi
				.elseif eax==14
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr TypeLsv,edi
				.elseif eax==17
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr TypeImg,edi
				.elseif eax==20
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr TypeDtp,edi
				.elseif eax==25
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr TypeStc,edi
				.endif
			.elseif edx==22	;Locked
				mov		lbid,210
				invoke ListFalseTrue,[esi].style,addr LockEdt,edi
			.elseif edx==23	;Child
				mov		lbid,211
				invoke ListFalseTrue,[esi].style,addr ChilAll,edi
			.elseif edx==24	;SizeBorder
				mov		lbid,212
				.if eax==0
					invoke ListFalseTrue,[esi].style,addr SizeDlg,edi
				.endif
			.elseif edx==25	;TabStop
				mov		lbid,213
				invoke ListFalseTrue,[esi].style,addr TabSAll,edi
			.elseif edx==26	;Font
				mov		lbid,1000
				sub		esi,sizeof DLGHEAD
				invoke strcpy,edi,addr (DLGHEAD ptr [esi]).font
				add		esi,sizeof DLGHEAD
			.elseif edx==27	;Menu
				mov		lbid,1002
				sub		esi,sizeof DLGHEAD
				invoke strcpy,edi,addr (DLGHEAD ptr [esi]).menuid
				add		esi,sizeof DLGHEAD
			.elseif edx==28	;Class
				mov		lbid,1001
				.if eax==0
					sub		esi,sizeof DLGHEAD
					invoke strcpy,edi,addr (DLGHEAD ptr [esi]).class
					add		esi,sizeof DLGHEAD
				.elseif eax==23
					invoke strcpy,edi,addr (DIALOG ptr [esi]).class
				.endif
			.elseif edx==29	;Notify
				mov		lbid,214
				.if eax==2 || eax==17 || eax==25
					invoke ListFalseTrue,[esi].style,addr NotiStc,edi
				.elseif eax==4 || eax==5 || eax==6
					invoke ListFalseTrue,[esi].style,addr NotiBtn,edi
				.elseif eax==8
					invoke ListFalseTrue,[esi].style,addr NotiLst,edi
				.endif
			.elseif edx==30	;AutoScroll
				mov		lbid,303
				.if eax==1 || eax==22
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr AutoEdt,edi
				.elseif eax==7
					invoke ListFalseTrue,[esi].style,addr AutoCbo,edi
				.endif
			.elseif edx==31	;WantCr
				mov		lbid,215
				invoke ListFalseTrue,[esi].style,addr WantEdt,edi
;*****
			.elseif edx==32	;Sort
				mov		lbid,216
				.if eax==7
					invoke ListFalseTrue,[esi].style,addr SortCbo,edi
				.elseif eax==8
					invoke ListFalseTrue,[esi].style,addr SortLst,edi
				.elseif eax==14
					mov		lbid,307
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr SortLsv,edi
				.endif
			.elseif edx==33	;Flat
				mov		lbid,217
				invoke ListFalseTrue,[esi].style,addr FlatTbr,edi
			.elseif edx==34	;(StartID)
				mov		lbid,NumStartID
				sub		esi,sizeof DLGHEAD
				invoke BinToDec,(DLGHEAD ptr [esi]).ctlid,edi
				add		esi,sizeof DLGHEAD
			.elseif edx==35	;Tabindex
				mov		lbid,NumTab
				invoke BinToDec,[esi].tab,edi
			.elseif edx==36	;Format
				mov		lbid,304
				invoke ListMultiStyle,[esi].style,[esi].exstyle,addr FormDtp,edi
			.elseif edx==37	;SizeGrip
				mov		lbid,212
				.if eax==19
					invoke ListFalseTrue,[esi].style,addr SizeSbr,edi
				.endif
			.elseif edx==38	;Group
				mov		lbid,218
				invoke ListFalseTrue,[esi].style,addr GrouAll,edi
			.elseif edx==39	;Icon
			.elseif edx==40	;UseTabs
				mov		lbid,220
				invoke ListFalseTrue,[esi].style,addr UseTLst,edi
			.elseif edx==41	;StartupPos
				mov		lbid,305
				invoke ListMultiStyle,[esi].style,[esi].exstyle,addr StarDlg,edi
			.elseif edx==42	;Orientation
				mov		lbid,306
				.if eax==12
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr OriePgb,edi
				.elseif eax==16
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr OrieUdn,edi
				.endif
			.elseif edx==43	;SetBuddy
				mov		lbid,221
				invoke ListFalseTrue,[esi].style,addr SetBUdn,edi
			.elseif edx==44	;MultiSelect
				mov		lbid,209
				.if eax==8
					invoke ListFalseTrue,[esi].style,addr MultLst,edi
				.elseif eax==21
					invoke ListFalseTrue,[esi].style,addr MultMvi,edi
				.endif
			.elseif edx==45	;HideSelection
				mov		lbid,222
				.if eax==1 || eax==22
					invoke ListFalseTrue,[esi].style,addr HideEdt,edi
				.elseif eax==13
					invoke ListFalseTrue,[esi].style,addr HideTrv,edi
				.elseif eax==14
					invoke ListFalseTrue,[esi].style,addr HideLsv,edi
				.endif
			.elseif edx==46	;TopMost
				mov		lbid,223
				invoke ListFalseTrue,[esi].exstyle,addr TopMost,edi
			.elseif edx==47	;xExStyle
				mov		lbid,1003
				mov		eax,[esi].exstyle
				invoke hexEax
				invoke strcpy,edi,addr strHex
			.elseif edx==48	;xStyle
				mov		lbid,1004
				mov		eax,[esi].style
				invoke hexEax
				invoke strcpy,edi,addr strHex
			.elseif edx==49	;IntegralHgt
				mov		lbid,224
				.if eax==7
					invoke ListFalseTrue,[esi].style,addr IntHtCbo,edi
				.elseif eax==8
					invoke ListFalseTrue,[esi].style,addr IntHtLst,edi
				.endif
			.elseif edx==50	;Image
				mov		lbid,1005
				invoke strcpy,edi,addr [esi].caption
			.elseif edx==51	;Buttons
				mov		lbid,225
				.if eax==11
					invoke ListFalseTrue,[esi].style,addr ButtTab,edi
				.elseif eax==13
					invoke ListFalseTrue,[esi].style,addr ButtTrv,edi
				.elseif eax==32
					invoke ListFalseTrue,[esi].style,addr ButtHdr,edi
				.endif
			.elseif edx==52	;PopUp
				mov		lbid,226
				invoke ListFalseTrue,[esi].style,addr PopUAll,edi
			.elseif edx==53	;OwnerDraw
				.if eax==4
					mov		lbid,227
					invoke ListFalseTrue,[esi].style,addr OwneBtn,edi
				.elseif eax==14
					mov		lbid,227
					invoke ListFalseTrue,[esi].style,addr OwneLsv,edi
				.elseif eax==7 || eax==8
					mov		lbid,308
					invoke ListMultiStyle,[esi].style,[esi].exstyle,addr OwneCbo,edi
				.endif
			.elseif edx==54	;Transparent
				mov		lbid,228
				invoke ListFalseTrue,[esi].style,addr TranAni,edi
			.elseif edx==55	;Timer
				mov		lbid,229
				invoke ListFalseTrue,[esi].style,addr TimeAni,edi
			.elseif edx==56	;AutoPlay
				mov		lbid,206
				.if eax==27
					invoke ListFalseTrue,[esi].style,addr AutoAni,edi
				.endif
			.elseif edx==57	;WeekNum
				mov		lbid,230
				invoke ListFalseTrue,[esi].style,addr WeekMvi,edi
			.elseif edx==58	;AviClip
				mov		lbid,1006
				invoke strcpy,edi,addr [esi].caption
			.elseif edx==59	;AutoSize
				mov		lbid,206
				.if eax==18 || eax==19
					invoke ListFalseTrue,[esi].style,addr AutoTbr,edi
				.endif
			.elseif edx==60	;ToolTip
				mov		lbid,231
				.if eax==11
					invoke ListFalseTrue,[esi].style,addr ToolTab,edi
				.else
					invoke ListFalseTrue,[esi].style,addr ToolTbr,edi
				.endif
			.elseif edx==61	;Wrap
				mov		lbid,232
				invoke ListFalseTrue,[esi].style,addr WrapTbr,edi
			.elseif edx==62	;Divider
				mov		lbid,233
				invoke ListFalseTrue,[esi].style,addr DiviTbr,edi
			.elseif edx==63	;DragDrop
				mov		lbid,234
				invoke ListFalseTrue,[esi].style,addr DragHdr,edi
;*****
			.elseif edx==64	;Smooth
				mov		lbid,235
				invoke ListFalseTrue,[esi].style,addr SmooPgb,edi
			.elseif edx==65	;Ellipsis
				mov		lbid,309
				invoke ListMultiStyle,[esi].style,[esi].exstyle,addr ElliStc,edi
			.elseif edx==66	;Language
			.elseif edx==67	;HasStrings
				mov		lbid,236
				.if eax==7
					invoke ListFalseTrue,[esi].style,addr HasStcb,edi
				.elseif eax==8
					invoke ListFalseTrue,[esi].style,addr HasStlb,edi
				.endif
			.elseif edx==68	;(HelpID)
			.elseif eax>=NoOfButtons
			    ;eax = nType, edx == nInx			
				;Custom properties
				invoke GetCustProp,eax,edx
				mov		lbid,eax
				.if eax
					.if dword ptr [eax]==1 || dword ptr [eax]==4 ; added type 4 for property descriptions
						invoke ListFalseTrue,[esi].style,[eax+4],edi
					.elseif dword ptr [eax]==2 || dword ptr [eax]==5 ; added type 5 for property descriptions
						invoke ListFalseTrue,[esi].exstyle,[eax+4],edi
					.elseif dword ptr [eax]==3 || dword ptr [eax]==6 ; added type 6 for property descriptions
						invoke ListMultiStyle,[esi].style,[esi].exstyle,[eax+4],edi
					.endif
				.endif
			.endif
			invoke SendMessage,hPrpLst,LB_ADDSTRING,0,addr buffer1
			invoke SendMessage,hPrpLst,LB_SETITEMDATA,eax,lbid
		.endif
		inc		nInx
		jmp		@b
	  @@:

	    mov eax, nTypeID
	    .IF eax > 65535

	        mov nPr, 0
	        mov	lbid, 0
            Invoke GetTypePtr,nType
            mov edx, [eax].TYPES.notused
            mov ptrProperties, edx
            
            mov	eax, (TYPES ptr [eax]).methods
            mov ptrMethods, eax
            
            .IF ptrProperties != 0
                Invoke strlen, ptrProperties
                mov nLenProperties, eax
                .IF eax != 0
                    mov pos, 0
                    ;DbgDump ptrProperties, nLenProperties
                    Invoke iniGetItemEx, ptrProperties, Addr buffer1, pos
                    mov pos, eax
                	.WHILE eax != 0
                		mov eax, ptrMethods
                		mov edx, nPr
                		lea		eax,[eax+edx*8]
                		mov	lbid, eax
            			.IF eax
            		        invoke strlen,addr buffer1
            		        lea edi,buffer1[eax]
                			mov ax,09h
                			stosw
                			dec edi				
            			    
            			    mov eax, lbid
            				.if dword ptr [eax]==1 || dword ptr [eax]==4 ; added type 4 for property descriptions
            					invoke ListFalseTrue,[esi].style,[eax+4],edi
            				.elseif dword ptr [eax]==2 || dword ptr [eax]==5 ; added type 5 for property descriptions
            					invoke ListFalseTrue,[esi].exstyle,[eax+4],edi
            				.elseif dword ptr [eax]==3 || dword ptr [eax]==6 ; added type 6 for property descriptions
            					invoke ListMultiStyle,[esi].style,[esi].exstyle,[eax+4],edi
            				.endif
            		        invoke SendMessage,hPrpLst,LB_ADDSTRING,0,addr buffer1
            		        invoke SendMessage,hPrpLst,LB_SETITEMDATA,eax,lbid					
            			.ENDIF        		
                		;PrintDec nPr
                        inc nPr
		                mov	dword ptr buffer1,0
		                mov	dword ptr buffer1[4],0                        
                		Invoke iniGetItemEx, ptrProperties, Addr buffer1, pos
                		mov pos, eax
                	.ENDW
                .ENDIF
            .ENDIF
        .ENDIF

		invoke SendMessage,hPrpLst,LB_SETTOPINDEX,tInx,0
		invoke GetWindowLong,hMdiCld,4
		.if eax
			invoke UpdateCbo,eax
			invoke SetCbo,hCtl
		.endif
		assume esi:nothing
	.else
		push	edx
		mov		eax,hPrp
        call    GetToolPtr
        mov     (TOOL ptr [edx]).dFocus,FALSE
        invoke ToolMsg,hPrp,TLM_CAPTION,0
		pop		edx
	.endif
	invoke SetFocus,hMdiCld
	invoke SendMessage,hPrpLst,LB_FINDSTRING,-1,addr szLbString
	.if eax==LB_ERR
		xor		eax,eax
	.endif
	mov nInx, eax
	invoke SendMessage,hPrpLst,LB_SETCURSEL,eax,0

	invoke SendMessage,hPrpLst,LB_GETITEMDATA,nInx,0
	mov		lbid,eax	
	;PrintText 'PropertyList'
	;PrintDec lbid
	Invoke PropSetTxtDesc, lbid
	
	invoke SendMessage,hPrpLst,WM_SETREDRAW,TRUE,0
  Ex:
	ret

PropertyList endp

Do_Properties proc
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer2[64]:BYTE
    LOCAL   sTool:DOCKING
    LOCAL   hWin:HWND

    mov     sTool.ID,4
    mov     sTool.Caption,offset szProperty
	invoke strcpy,addr buffer,addr Property
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Visible,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Docked,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Position,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.IsChild,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.DockWidth,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.DockHeight,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.left,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.top,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.right,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.bottom,eax

	invoke CreateWindowEx,0,addr szToolCldClass,NULL,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,0,0,0,0,hWnd,0,hInstance,0
	mov		hWin,eax
	invoke CreateWindowEx,0,addr szComboBox,NULL,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or CBS_DROPDOWNLIST or WS_VSCROLL,0,0,0,0,hWin,0,hInstance,0
	mov		hPrpCbo,eax
	mov		hPrpCboCode,eax
	invoke SetWindowLong,hPrpCbo,GWL_WNDPROC,addr PropCboProc
	mov		OldPropCboProc,eax
	invoke SendMessage,hPrpCbo,WM_SETFONT,hLBFont,0
	invoke CreateWindowEx,0,addr szComboBox,NULL,WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or CBS_DROPDOWNLIST or WS_VSCROLL or CBS_SORT,0,0,0,0,hWin,0,hInstance,0
	mov		hPrpCboDlg,eax
	invoke SetWindowLong,hPrpCboDlg,GWL_WNDPROC,addr PropCboProc
	invoke SendMessage,hPrpCboDlg,WM_SETFONT,hLBFont,0
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szListBox,NULL,WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or LBS_USETABSTOPS or LBS_SORT or LBS_OWNERDRAWFIXED or LBS_NOTIFY,0,0,0,0,hWin,0,hInstance,0
	mov		hPrpLst,eax
	mov		hPrpLstCode,eax
	invoke SetWindowLong,hPrpLstCode,GWL_WNDPROC,addr PropListCodeProc
	mov		OldPropListCodeProc,eax
	invoke SendMessage,hPrpLstCode,WM_SETFONT,hLBFont,0
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szListBox,NULL,WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or LBS_USETABSTOPS or LBS_SORT or LBS_OWNERDRAWFIXED or LBS_NOTIFY,0,0,0,0,hWin,0,hInstance,0
	mov		hPrpLstDlg,eax
	invoke SetWindowLong,hPrpLstDlg,GWL_WNDPROC,addr PropListDlgProc
	mov		OldPropListDlgProc,eax
	invoke SendMessage,hPrpLstDlg,WM_SETFONT,hLBFont,0

	invoke CreateWindowEx,0,addr szEdit,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or ES_AUTOHSCROLL or ES_MULTILINE,0,0,0,0,hPrpLst,0,hInstance,0
	mov		hPrpTxt,eax
	invoke SetWindowLong,hPrpTxt,GWL_WNDPROC,addr PropEditProc
	mov		OldPropEditProc,eax
	invoke SendMessage,hPrpTxt,WM_SETFONT,hLBFont,0
	invoke CreateWindowEx,0,addr szEdit,NULL,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_BORDER or ES_AUTOHSCROLL or ES_AUTOVSCROLL or ES_MULTILINE or ES_WANTRETURN,0,0,0,0,hPrpLst,0,hInstance,0
	mov		hPrpTxtMulti,eax
	invoke SetWindowLong,hPrpTxtMulti,GWL_WNDPROC,addr PropEditMultiProc
	mov		OldPropEditMultiProc,eax
	invoke SendMessage,hPrpTxtMulti,WM_SETFONT,hLBFont,0
	invoke CreateWindowEx,0,addr szListBox,NULL,WS_POPUP or WS_VSCROLL or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_BORDER or LBS_HASSTRINGS,0,0,0,0,hPrpLst,0,hInstance,0
	mov		hTxtLst,eax
	invoke SendMessage,hTxtLst,WM_SETFONT,hLBFont,0
	invoke GetDesktopWindow
	invoke SetParent,hTxtLst,eax
	invoke SetWindowLong,hTxtLst,GWL_WNDPROC,addr PropTxtLstProc
	mov		OldPropTxtLstProc,eax
	
	; fearless - add property description box
	invoke CreateWindowEx,0,addr szEdit,Addr szProperty_Null,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_VSCROLL or ES_MULTILINE or ES_READONLY,0,0,0,0,hWin,0,hInstance,0
	mov hPrpTxtDesc, eax
	invoke SendMessage,hTxtLst,WM_SETFONT,hTTFont,0
	
	invoke CreateWindowEx,0,addr szButton,addr szBtnText,WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS,lbTp+1+84,16,16,16,hPrpLst,0,hInstance,0
	mov		hTxtBtn,eax
	invoke SetWindowLong,hTxtBtn,GWL_ID,1
	invoke SetWindowLong,hTxtBtn,GWL_WNDPROC,addr PropTxtBtnProc
	mov		OldPropTxtBtnProc,eax
	;Create the toolbar
	invoke CreateWindowEx,0,addr szToolBar,0,WS_CHILD or WS_VISIBLE or TBSTYLE_TOOLTIPS or TBSTYLE_FLAT or CCS_NODIVIDER or CCS_NORESIZE,0,1,200,24,hWin,0,hInstance,0
	mov		hPrpTbrCode,eax
	.if fNT
		;Unicode
		invoke SendMessage,hPrpTbrCode,TB_SETUNICODEFORMAT,TRUE,0
	.endif
	;Set toolbar images
	invoke SendMessage,hPrpTbrCode,TB_SETIMAGELIST,0,hTbrIml
	;Set toolbar struct size
	invoke SendMessage,hPrpTbrCode,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar buttons
	invoke SendMessage,hPrpTbrCode,TB_ADDBUTTONS,ntbrbtns,addr tbrbtns
	mov		fProperty,1
    invoke ToolMessage,hWin,TLM_CREATE,addr sTool
    mov     eax,hWin
	ret

Do_Properties endp

ToolPropertySize proc lParam:LPARAM
	LOCAL	wt:DWORD
	LOCAL	ht:DWORD
	LOCAL	nInx:DWORD
	LOCAL	rect:RECT
	LOCAL	hDC:HDC
	LOCAL	buffer[64]:BYTE

	invoke GetDC,hWnd
	mov		hDC,eax
	invoke SelectObject,hDC,hLBFont
	push	eax
	;Find widest property text
	mov		lbTp,0
	invoke strcpy,addr prnbuff,addr PrAll
  @@:
	invoke iniGetItem,addr prnbuff,addr buffer
	mov		al,buffer[0]
	or		al,al
	je		@f
	invoke lstrlen,addr buffer
	mov		edx,eax
	invoke GetTextExtentPoint32,hDC,addr buffer,edx,addr rect
	mov		eax,rect.left
	add		eax,3
	.if eax>lbTp
		mov		lbTp,eax
	.endif
	jmp		@b
  @@:
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,hWnd,hDC
	mov		eax,rect.top
	inc		eax
	mov		lbHt,eax
	invoke SendMessage,hPrpLstCode,LB_SETITEMHEIGHT,0,lbHt
	invoke SendMessage,hPrpLstDlg,LB_SETITEMHEIGHT,0,lbHt
	mov		eax,lParam
	.if !eax
		invoke GetClientRect,hPrp,addr rect
		mov		eax,rect.right
		mov		wt,eax
		mov		eax,rect.bottom
		mov		ht,eax
	.else
		and		eax,0FFFFh
		mov		wt,eax
		mov		eax,lParam
		shr		eax,16
		mov		ht,eax
	.endif
	invoke MoveWindow,hPrpCboCode,0,26,wt,150,TRUE
	invoke GetWindowRect,hPrpCboCode,addr rect
	mov		ecx,rect.bottom
	sub		ecx,rect.top
	add		ecx,26+2
	mov		eax,ht
	sub		eax,ecx
	invoke MoveWindow,hPrpLstCode,0,ecx,wt,eax,TRUE

	invoke MoveWindow,hPrpCboDlg,0,0,wt,150,TRUE
	invoke GetWindowRect,hPrpCboDlg,addr rect
	mov		ecx,rect.bottom
	sub		ecx,rect.top
	add		ecx,2
	mov		eax,ht
	sub eax, lbHt
	sub eax, 3
	sub eax, lbHt
	sub eax, 3
	sub		eax,ecx
	invoke MoveWindow,hPrpLstDlg,0,ecx,wt,eax,TRUE
	
	mov	ecx,ht
	sub ecx, lbHt
	sub ecx, 3
	sub ecx, lbHt
	sub ecx, 3
	mov eax, lbHt
	add eax, 3
	add eax, lbHt
	add eax, 3
	dec wt
	dec wt
	invoke MoveWindow,hPrpTxtDesc,0,ecx,wt,eax,TRUE
	
	.if hDialog
		invoke PropSetOwner,FALSE
		invoke PropListSetPos
		.if !eax
			invoke PropListSetTxt,hPrpLst
		.endif
	.else
		invoke PropSetOwner,TRUE
		invoke SendMessage,hPrpLst,LB_GETCURSEL,0,0
		.if eax!=LB_ERR
			mov		nInx,eax
			invoke SendMessage,hPrpLst,LB_GETITEMRECT,nInx,addr rect
			mov		eax,lbHt
			sub		rect.right,eax
			sub		rect.top,1
			invoke SetWindowPos,hTxtBtn,HWND_TOP,rect.right,rect.top,lbHt,lbHt,0
		.endif
	.endif
	ret

ToolPropertySize endp

