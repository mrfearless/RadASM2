
DrawingRect			PROTO :DWORD,:DWORD,:DWORD
UpdateCtl			PROTO :DWORD

.const

DLGVER			equ 102
MaxMem			equ 128*1024*3
WS_ALWAYS		equ WS_CHILD or WS_VISIBLE or WS_CLIPSIBLINGS or WS_CLIPCHILDREN

.data

DlgX				dd 10
DlgY				dd 10
szICODLG			db '#100',0

;Control names
DlgID				db 'IDD_DLG',0
EdtID				db 'IDC_EDT',0
StcID				db 'IDC_STC',0
GrbID				db 'IDC_GRP',0
BtnID				db 'IDC_BTN',0
ChkID				db 'IDC_CHK',0
RbtID				db 'IDC_RBN',0
CboID				db 'IDC_CBO',0
LstID				db 'IDC_LST',0
ScbID				db 'IDC_SCB',0
TabID				db 'IDC_TAB',0
PrbID				db 'IDC_PGB',0
TrvID				db 'IDC_TRV',0
LsvID				db 'IDC_LSV',0
TrbID				db 'IDC_TRB',0
UdnID				db 'IDC_UDN',0
IcoID				db 'IDC_IMG',0
TbrID				db 'IDC_TBR',0
SbrID				db 'IDC_SBR',0
DtpID				db 'IDC_DTP',0
MviID				db 'IDC_MVI',0
RedID				db 'IDC_RED',0
UdcID				db 'IDC_UDC',0
CbeID				db 'IDC_CBE',0
ShpID				db 'IDC_SHP',0
IpaID				db 'IDC_IPA',0
AniID				db 'IDC_ANI',0
HotID				db 'IDC_HOT',0
PgrID				db 'IDC_PGR',0
RebID				db 'IDC_REB',0
HdrID				db 'IDC_HDR',0
LnkID				db 'IDC_LNK',0

;Control caption
LnkCAP				db '<a></a>',0

;Resource type
DlgRC				db 'DIALOGEX',0
ConRC				db 'CONTROL',0

szMnu				db '  &File  ,	&Edit  ,  &Help  ',0
PrAll				db '(Name),(ID),Left,Top,Width,Height,Caption,Border,SysMenu,MaxButton,MinButton,Enabled,Visible,Clipping,ScrollBar,Default,Auto,Alignment,Mnemonic,WordWrap,MultiLine,Type,Locked,Child,SizeBorder,TabStop,Font,Menu,Class,Notify,AutoScroll,WantCr,'
					db 'Sort,Flat,(StartID),TabIndex,Format,SizeGrip,Group,Icon,UseTabs,StartupPos,Orientation,SetBuddy,MultiSelect,HideSel,TopMost,xExStyle,xStyle,IntegralHgt,Image,Buttons,PopUp,OwnerDraw,Transp,Timer,AutoPlay,WeekNum,AviClip,AutoSize,ToolTip,Wrap,'
					db 'Divider,DragDrop,'
					db 'Smooth,Ellipsis,Language,HasStrings,(HelpID)'
					db 1024 dup(0)
NO_OF_PR			equ 32+32+5

				;0-Dialog
ctltypes			dd 0
					dd offset DlgEditClass
					dd 0	;Not used
					dd WS_VISIBLE or WS_CAPTION or WS_MAXIMIZEBOX or WS_MINIMIZEBOX or WS_SYSMENU or WS_SIZEBOX
					dd 0	;ExStyle
					dd offset DlgID
					dd offset DlgID
					dd offset DlgRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111111111111100000000110111000b
					;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
					dd 00100000010000111000100000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 300
					dd 100
				;1-Edit
					dd 1
					dd offset szEdit
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or ES_LEFT
					dd WS_EX_CLIENTEDGE
					dd offset EdtID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111111000111100100111001000011b
					;  NILTWHCBSMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000001011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;2-Static
					dd 2
					dd offset szStatic
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or SS_LEFT
					dd 0	;ExStyle
					dd offset StcID
					dd offset StcID
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111111000111000111000000000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 01000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;3-GroupBox
					dd 3
					dd offset szButton
					dd 0;2	;Not used
					dd WS_VISIBLE or WS_CHILD or BS_GROUPBOX
					dd 0	;ExStyle
					dd offset GrbID
					dd offset GrbID
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111111000111000000000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;4-Pushbutton
					dd 4
					dd offset szButton
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or BS_PUSHBUTTON
					dd 0	;ExStyle
					dd offset BtnID
					dd offset BtnID
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111111000111010100110001000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000010000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 80
					dd 21
				;5-CheckBox
					dd 5
					dd offset szButton
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or BS_AUTOCHECKBOX
					dd 0	;ExStyle
					dd offset ChkID
					dd offset ChkID
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111110000111001100100001000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010010000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;6-RadioButton
					dd 6
					dd offset szButton
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or BS_AUTORADIOBUTTON
					dd 0	;ExStyle
					dd offset RbtID
					dd offset RbtID
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111110000111001100100001000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010010000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;7-ComboBox
					dd 7
					dd offset szComboBox
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or CBS_DROPDOWNLIST
					dd 0	;ExStyle
					dd offset CboID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111100000010001000010b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 10010000000000011100010000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00010000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;8-ListBox
					dd 8
					dd offset szListBox
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or LBS_NOTIFY
					dd WS_EX_CLIENTEDGE
					dd offset LstID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111100000000001000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 10010000100010011100010000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00010000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;9-HScrollBar
					dd 9
					dd offset szScrollBar
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or SBS_HORZ
					dd 0	;ExStyle
					dd offset ScbID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 16
				;10-VScrollBar
					dd 10
					dd offset szScrollBar
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or SBS_VERT
					dd 0	;ExStyle
					dd offset ScbID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 16
					dd 100
				;11-TabControl
					dd 11
					dd offset szTabControl
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or TCS_FOCUSNEVER
					dd 0	;ExStyle
					dd offset TabID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111000100100001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011001000000001000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 150
					dd 100
				;12-ProgressBar
					dd 12
					dd offset szProgressBar
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD
					dd 0	;ExStyle
					dd offset PrbID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111000000000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000001000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 10000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 16
				;13-TreeView
					dd 13
					dd offset szTreeView
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or TVS_HASLINES or TVS_LINESATROOT or TVS_HASBUTTONS
					dd WS_EX_CLIENTEDGE
					dd offset TrvID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000010001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000001011001000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;14-ListViev
					dd 14
					dd offset szListView
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or LVS_LIST
					dd WS_EX_CLIENTEDGE
					dd offset LsvID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000100010001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 10010000000001011000010000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;15-TrackBar
					dd 15
					dd offset szTrackBar
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD
					dd 0	;ExStyle
					dd offset TrbID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 28
				;16-UpDown
					dd 16
					dd offset szUpDown
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD
					dd 0	;ExStyle
					dd offset UdnID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111001100000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000001100011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 16
					dd 21
				;17-Image
					dd 17
					dd offset szStatic
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or SS_ICON or SS_CENTERIMAGE
					dd 0	;ExStyle
					dd offset IcoID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000100010000000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011010000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;18-ToolBar
					dd 18
					dd offset szToolBar
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or CCS_TOP
					dd 0	;ExStyle
					dd offset TbrID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111000100000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 01010000000000011000000000011110b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 28
				;19-StatusBar
					dd 19
					dd offset szStatusBar
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or CCS_BOTTOM
					dd 0	;ExStyle
					dd offset SbrID
					dd offset SbrID
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111110000111000100000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010100000000011000000000010000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 28
				;20-DateTimePicker
					dd 20
					dd offset szDateTime
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or 4
					dd 0	;ExStyle
					dd offset DtpID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111000000010001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00011000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;21-MonthView
					dd 21
					dd offset szMonthView
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD
					dd WS_EX_CLIENTEDGE	;ExStyle
					dd offset MviID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000010011000000001000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 165
					dd 160
				;22-RichEdit
					dd 22
					dd offset RichEditClass
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP
					dd WS_EX_CLIENTEDGE	;ExStyle
					dd offset RedID
					dd offset RedID
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111111000111100000101001000011b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000001011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;23-UserDefinedControl
					dd 23
					dd offset szStatic
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD
					dd 0	;ExStyle
					dd offset UdcID
					dd offset szUserControl
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111111000101100000000101001000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;24-ComboBoxEx
					dd 24
					dd offset szComboBoxEx
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP or CBS_DROPDOWNLIST
					dd 0	;ExStyle
					dd offset CbeID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111100000111000000010001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;25-Static Rect & Line
					dd 25
					dd offset szStatic
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or SS_BLACKRECT
					dd 0	;ExStyle
					dd offset ShpID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000010000000100b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;26-IP Address
					dd 26
					dd offset szIPAddress
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP
					dd 0	;ExStyle
					dd offset IpaID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;27-Animate
					dd 27
					dd offset szAnimate
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD
					dd 0	;ExStyle
					dd offset AniID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000100000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000001110100000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 100
				;28-HotKey
					dd 28
					dd offset szHotKey
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or WS_TABSTOP
					dd 0	;ExStyle
					dd offset HotID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;29-HPager
					dd 29
					dd offset szPager
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or PGS_HORZ
					dd 0	;ExStyle
					dd offset PgrID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;30-VPager
					dd 30
					dd offset szPager
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or PGS_VERT
					dd 0	;ExStyle
					dd offset PgrID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 21
					dd 100
				;31-ReBar
					dd 31
					dd offset szReBar
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD
					dd 0	;ExStyle
					dd offset RebID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;32-Header
					dd 32
					dd offset szHeader
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or HDS_BUTTONS
					dd 0	;ExStyle
					dd offset HdrID
					dd offset szNULL
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111101000111000000000000000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011001000000000001b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
				;33-Syslink
					dd 33
					dd offset szSyslink
					dd 0	;Not used
					dd WS_VISIBLE or WS_CHILD or LWS_TRANSPARENT
					dd 0	;ExStyle
					dd offset LnkID
					dd offset LnkCAP
					dd offset ConRC
					dd 0	;nMethod
					dd 0	;Methods
					dd 11111111000111000000000001000000b
					;  NILTWHCBCMMEVCSDAAMWMTLCSTFMCNAW
					dd 00010000000000011000000000000000b
					;  SFSTFSGIUSOSMHTxxIIBPOTTAWAATWDD
					dd 00000000000000000000000000000000b
					;  SELHH
					dd 00000000000000000000000000000000b
					;
					dd 100
					dd 21
CustTypes			TYPES 32 dup(<0>)

szNOTStyle			db 'NOT ',0
dwNOTStyle			dd WS_VISIBLE

					align 4
dlgdata				dd WS_VISIBLE or WS_CAPTION or DS_SETFONT		;style
					dd 00000000h									;exstyle
					dw 0000h										;cdit
					dw 0006h										;x
					dw 0006h										;y
					dw 0060h										;cx
					dw 0040h										;cy
					dw 0000h										;menu
					dw 0000h										;class
					dw 0000h										;caption
dlgps				dw 0											;point size
dlgfn				dw 33 dup(0)									;face name

.data?

ToolBoxID			dd ?
hSizeing			dd 8 dup(?)
hMultiSel			dd ?
fNoMouseUp			dd ?
CtlRect				RECT <?>
fSizeing			dd ?
fMoveing			dd ?
fDrawing			dd ?
fMultiSel			dd ?
ParPt				POINT <?>
hReSize				dd ?
MousePtDown			POINT <?>
OldSizeingProc		dd ?
dlgpaste			DIALOG MAXMULSEL dup(<?>)
SizeRect			RECT MAXMULSEL dup(<?>)
MnuRight			dd ?
MnuPtx				dd ?
MnuHigh				dd ?
MnuTrack			dd ?
MnuInx				dd ?

hScrDC				dd ?
hWinDC				dd ?
hWinRgn				dd ?
hComDC				dd ?
hWinBmp				dd ?
hOldRgn				dd ?
fNoParent			dd ?
dfntwt				dd ?
dfntht				dd ?
hGridBr				dd ?

.code

CaptureWin proc hWin:HWND
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	Ht:DWORD
	LOCAL	Wt:DWORD
	LOCAL	hCld:HWND

	.if !hComDC
		m2m		hCld,hWin
		invoke GetParent,hWin
		mov		hWin,eax
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		mov		Wt,eax
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		Ht,eax
		invoke GetWindowDC,hWin
		mov    hWinDC,eax
		invoke CreateCompatibleDC,hWinDC
		mov    hComDC,eax
		invoke CreateCompatibleBitmap,hWinDC,Wt,Ht
		mov		hWinBmp,eax
		invoke SelectObject,hComDC,hWinBmp
		invoke BitBlt,hComDC,0,0,Wt,Ht,hWinDC,0,0,SRCCOPY
		invoke GetDC,0
		mov		hScrDC,eax
		.if fNoParent
			invoke GetWindowRect,hCld,addr rect
		.endif
		invoke GetClientRect,hMdiCld,addr rect1
		invoke ClientToScreen,hMdiCld,addr rect1.left
		invoke ClientToScreen,hMdiCld,addr rect1.right
		mov		eax,rect1.left
		.if eax>rect.left
			mov		rect.left,eax
		.endif
		mov		eax,rect1.top
		.if eax>rect.top
			mov		rect.top,eax
		.endif
		mov		eax,rect1.right
		.if eax<rect.right
			mov		rect.right,eax
		.endif
		mov		eax,rect1.bottom
		.if eax<rect.bottom
			mov		rect.bottom,eax
		.endif
		invoke CreateRectRgn,rect.left,rect.top,rect.right,rect.bottom
		mov		hWinRgn,eax
		invoke SelectObject,hScrDC,hWinRgn
		mov		hOldRgn,eax
	.endif
	ret

CaptureWin endp

PaintWin proc hWin:HWND
	LOCAL	hDC:HDC
	LOCAL	rect:RECT

	.if hComDC
		invoke GetParent,hWin
		mov		hWin,eax
		invoke GetWindowDC,hWin
		mov		hDC,eax
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		mov		rect.right,eax
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		rect.bottom,eax
		invoke BitBlt,hDC,0,0,rect.right,rect.bottom,hComDC,0,0,SRCCOPY
		invoke ReleaseDC,hWin,hDC
		invoke UpdateWindow,hWin
	.endif
	ret

PaintWin endp

DestroyWin proc

	.if hComDC
		invoke DeleteDC,hWinDC
		invoke DeleteDC,hComDC
		invoke DeleteObject,hWinBmp
		invoke SelectObject,hScrDC,hOldRgn
		invoke DeleteObject,hWinRgn
		invoke ReleaseDC,0,hScrDC
		mov		hComDC,0
	.endif
	ret

DestroyWin endp

DlgDrawRect proc uses esi edi,hWin:HWND,lpRect:DWORD,nFun:DWORD,nInx:DWORD
	LOCAL	ht:DWORD
	LOCAL	wt:DWORD
	LOCAL	rect:RECT

	invoke CopyRect,addr rect,lpRect
	lea		esi,rect
	assume esi:ptr RECT
	add		[esi].right,1
	mov		eax,[esi].right
	sub		eax,[esi].left
	jns		@f
	mov		eax,[esi].right
	xchg	eax,[esi].left
	mov		[esi].right,eax
	sub		eax,[esi].left
	dec		[esi].left
	inc		[esi].right
	inc		eax
  @@:
	mov		wt,eax
	add		[esi].bottom,1
	mov		eax,[esi].bottom
	sub		eax,[esi].top
	jns		@f
	mov		eax,[esi].bottom
	xchg	eax,[esi].top
	mov		[esi].bottom,eax
	sub		eax,[esi].top
	dec		[esi].top
	inc		[esi].bottom
	inc		eax
  @@:
	mov		ht,eax
	dec		[esi].right
	dec		[esi].bottom
	mov		edi,nInx
	shl		edi,4
	add		edi,offset hRect
	.if nFun==0
		.if nInx==0
			invoke CaptureWin,hWin
		.endif
		invoke GetStockObject,BLACK_BRUSH
		mov edx,eax
		invoke FrameRect,hScrDC,addr rect,edx
	.elseif nFun==1
		.if nInx==0
			invoke PaintWin,hWin
		.endif
		invoke GetStockObject,BLACK_BRUSH
		mov edx,eax
		invoke FrameRect,hScrDC,addr rect,edx
	.elseif nFun==2
		.if nInx==0
			invoke PaintWin,hWin
			invoke DestroyWin
		.endif
	.endif
	assume esi:nothing
	ret

DlgDrawRect endp

GetFreeDlg proc hDlgMem:DWORD

	mov		eax,hDlgMem
	add		eax,sizeof DLGHEAD
	sub		eax,sizeof DIALOG
  @@:
	add		eax,sizeof DIALOG
	cmp		(DIALOG ptr [eax]).hwnd,0
	jne		@b
	ret

GetFreeDlg endp

GetFreeID proc uses esi edi

	invoke GetWindowLong,hMdiCld,4
	.if eax
		mov		esi,eax
		assume esi:ptr DLGHEAD
		mov		eax,[esi].ctlid
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
		sub		esi,sizeof DIALOG
		mov		edi,esi
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		cmp		eax,[esi].id
		jne		@b
		mov		esi,edi
		inc		eax
		jmp		@b
	  @@:
		assume esi:nothing
	.endif
	ret

GetFreeID endp

IsFreeID proc uses esi,nID:DWORD

	invoke GetWindowLong,hMdiCld,4
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
		sub		esi,sizeof DIALOG
		mov		eax,nID
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		cmp		eax,[esi].id
		jne		@b
		mov		eax,0
	  @@:
		assume esi:nothing
	.endif
	.if eax
		;ID is free
		mov		eax,TRUE
	.else
		mov		eax,FALSE
	.endif
	ret

IsFreeID endp

GetFreeTab proc uses esi edi
	LOCAL	nTab:DWORD

	invoke GetWindowLong,hMdiCld,4
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
		mov		edi,esi
		mov		nTab,0
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		mov		eax,nTab
		cmp		eax,[esi].tab
		jne		@b
		mov		esi,edi
		inc		nTab
		jmp		@b
	  @@:
		mov		eax,nTab
	.endif
	ret

GetFreeTab endp

;0 1 2 3 4 5 6 7
;0 1 2 5 3 4 6 7
;if new>old
;	if t>old and t<=new then t=t-1
;0 1 2 3 4 5 6 7
;0 2 3 1 4 5 6 7
;if new<old
;	if t<old and t>=new then t=t+1
SetNewTab proc uses esi edi,hCtl:HWND,nTab:DWORD
	LOCAL	nOld:DWORD

	invoke GetWindowLong,hCtl,GWL_USERDATA
	.if eax
		mov		esi,eax
		invoke GetFreeTab
		.if eax<=nTab
			.if eax
				dec		eax
			.endif
			mov		nTab,eax
		.endif
		m2m		nOld,(DIALOG ptr [esi]).tab
		mov		edi,esi
		invoke GetWindowLong,hMdiCld,4
		.if eax
			mov		esi,eax
			add		esi,sizeof DLGHEAD
			assume esi:ptr DIALOG
		  @@:
			add		esi,sizeof DIALOG
			cmp		[esi].hwnd,0
			je		@f
			cmp		[esi].hwnd,-1
			je		@b
			mov		eax,nTab
			.if eax>nOld
				mov		eax,[esi].tab
				.if eax>nOld && eax<=nTab
					dec		[esi].tab
				.endif
			.else
				mov		eax,[esi].tab
				.if eax<nOld && eax>=nTab
					inc		[esi].tab
				.endif
			.endif
			jmp		@b
		  @@:
			m2m		(DIALOG ptr [edi]).tab,nTab
			assume esi:nothing
		.endif
	.endif
	ret

SetNewTab endp

InsertTab proc uses esi,nTab:DWORD

	invoke GetWindowLong,hMdiCld,4
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		mov		eax,nTab
		.if eax<=[esi].tab
			inc		[esi].tab
		.endif
		jmp		@b
	  @@:
	.endif
	ret

InsertTab endp

DeleteTab proc uses esi,nTab:DWORD

	invoke GetWindowLong,hMdiCld,4
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		mov		eax,nTab
		.if eax<[esi].tab
			dec		[esi].tab
		.endif
		jmp		@b
	  @@:
	.endif
	ret

DeleteTab endp

FindTab proc uses esi,nTab:DWORD,hWin:HWND
	LOCAL	hCtl:HWND

	mov		hCtl,0
	invoke GetWindowLong,hWin,4
	.if eax
		mov		esi,eax
		add		esi,sizeof DLGHEAD
		assume esi:ptr DIALOG
	  @@:
		add		esi,sizeof DIALOG
		cmp		[esi].hwnd,0
		je		@f
		cmp		[esi].hwnd,-1
		je		@b
		mov		eax,nTab
		cmp		eax,[esi].tab
		jne		@b
		m2m		hCtl,[esi].hwnd
	  @@:
	.endif
	mov		eax,hCtl
	ret

FindTab endp

UpdateDialog proc uses esi,hDlg:HWND
	LOCAL	hCtl:HWND

	invoke GetWindowLong,hDlg,GWL_USERDATA
	mov		esi,eax
	push	esi
  @@:
	mov		eax,(DIALOG ptr [esi]).hwnd
	.if eax
		.if eax!=-1
			mov		hCtl,eax
			invoke SetWindowLong,hCtl,GWL_USERDATA,esi
		.endif
		add		esi,sizeof DIALOG
		jmp		@b
	.endif
	pop		esi
  @@:
	mov		eax,(DIALOG ptr [esi]).hwnd
	.if eax
		.if eax!=-1
			mov		hCtl,eax
			invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		.endif
		add		esi,sizeof DIALOG
		jmp		@b
	.endif
	mov		esi,offset hSizeing
	.while esi<offset hSizeing+8*4
		.if dword ptr [esi]
			invoke SetWindowPos,dword ptr [esi],HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		.endif
		add		esi,4
	.endw
	ret

UpdateDialog endp

FindParent proc hWin:HWND

  @@:
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		eax,(DIALOG ptr [eax]).ntype
	.if !eax
		mov		eax,hWin
		ret
	.endif
	invoke GetParent,hWin
	mov		hWin,eax
	jmp		@b

FindParent endp

FetchParent proc hWin:HWND

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		eax,(DIALOG ptr [eax]).hpar
	ret

FetchParent endp

GetTypePtr proc nType:DWORD

	push	edx
	mov		eax,size TYPES
	mov		edx,nType
	mul		edx
	add		eax,offset ctltypes
	pop		edx
	ret

GetTypePtr endp

SetChanged proc fChanged:DWORD,hWin:HWND
	LOCAL	hDC:HDC
	LOCAL	hBr:DWORD
	LOCAL	rect:RECT

	.if !hWin
		m2m		hWin,hMdiCld
	.endif
	invoke GetWindowLong,hWin,4
	.if eax
		.if fChanged==2
			m2m		fChanged,(DLGHEAD ptr [eax]).changed
		.else
			m2m		(DLGHEAD ptr [eax]).changed,fChanged
		.endif
		invoke GetDC,hWin
		mov		hDC,eax
		.if fChanged
			mov		eax,0FF00h
		.else
			invoke GetWindowLong,hWin,8
			.if eax
				mov		eax,0FFh
			.else
				mov		eax,radcol.dialogedit
			.endif
		.endif
		invoke CreateSolidBrush,eax
		mov		hBr,eax
		mov		rect.left,1
		mov		rect.top,1
		mov		rect.right,6
		mov		rect.bottom,6
		invoke FillRect,hDC,addr rect,hBr
		invoke ReleaseDC,hWin,hDC
		invoke DeleteObject,hBr
	.endif
	ret

SetChanged endp

UpdateSize proc uses esi,hWin:HWND,x:DWORD,y:DWORD,ccx:DWORD,ccy:DWORD
	LOCAL	fChanged:DWORD

	mov		fChanged,FALSE
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		esi,eax
	assume esi:ptr DIALOG
	;Posotion & Size
	mov		eax,[esi].x
	.if eax!=x
		mov		fChanged,TRUE
	.endif
	mov		eax,[esi].y
	.if eax!=y
		mov		fChanged,TRUE
	.endif
	mov		eax,[esi].ccx
	.if eax!=ccx
		mov		fChanged,TRUE
	.endif
	mov		eax,[esi].ccy
	.if eax!=ccy
		mov		fChanged,TRUE
	.endif
	m2m		[esi].x,x
	m2m		[esi].y,y
	m2m		[esi].ccx,ccx
	m2m		[esi].ccy,ccy
	.if fChanged
		invoke SetChanged,TRUE,0
	.endif
	assume esi:nothing
	ret

UpdateSize endp

DestroySizeingRect proc uses edi

	mov		edi,offset hSizeing
	invoke GetParent,[edi]
	push	eax
	mov		ecx,8
  @@:
	mov		eax,[edi]
	.if eax
		push	ecx
		invoke DestroyWindow,eax
		pop		ecx
	.endif
	xor		eax,eax
	mov		[edi],eax
	add		edi,4
	loop	@b
	pop		eax
	invoke UpdateWindow,eax
	mov		hReSize,0
	invoke PropertyList,0
	invoke SendMessage,hMdiCld,WM_LBUTTONDOWN,0,0
	ret

DestroySizeingRect endp

DialogTltSize proc uses esi,ccx:DWORD,ccy:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	pt:POINT
	LOCAL	hDC:HDC
	LOCAL	len:DWORD
	LOCAL	hOldFont:DWORD

	.if fShowSizePos
		invoke GetCursorPos,addr mpt
		add		mpt.y,15
		add		mpt.x,15
		lea		esi,buffer
		mov		al,' '
		mov		[esi],al
		inc		esi
		invoke BinToDec,ccx,esi
		invoke strlen,esi
		add		esi,eax
		mov		al,','
		mov		[esi],al
		inc		esi
		mov		al,' '
		mov		[esi],al
		inc		esi
		invoke BinToDec,ccy,esi
		invoke strlen,esi
		add		esi,eax
		mov		eax,'  '
		mov		[esi],eax
		invoke GetDC,hTlt
		mov		hDC,eax
		invoke SelectObject,hDC,hLBFont
		mov		hOldFont,eax
		invoke strlen,addr buffer
		mov		len,eax
		invoke GetTextExtentPoint32,hDC,addr buffer,len,addr pt
		invoke SelectObject,hDC,hOldFont
		invoke ReleaseDC,hTlt,hDC
		add		pt.y,3
		invoke MoveWindow,hTlt,mpt.x,mpt.y,pt.x,pt.y,TRUE
		invoke ShowWindow,hTlt,SW_SHOWNA
		invoke SetWindowText,hTlt,addr buffer
	.endif
	ret

DialogTltSize endp

SizeX proc nInc:DWORD

	.if fSnapToGrid
		xor		edx,edx
		idiv	Gridcx
		imul	Gridcx
		add		eax,nInc
	.endif
	ret

SizeX endp

SizeY proc nInc:DWORD

	.if fSnapToGrid
		xor		edx,edx
		idiv	Gridcy
		imul	Gridcy
		add		eax,nInc
	.endif
	ret

SizeY endp

SizeingProc proc uses edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nInx:DWORD
	LOCAL	pt:POINT
	LOCAL	parpt:POINT
	LOCAL	fChanged:DWORD

	.if uMsg>=WM_MOUSEFIRST && uMsg<=WM_MOUSELAST
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		nInx,eax
		shr		nInx,16
		and		eax,0FFFFh
		.if eax
			invoke LoadCursor,0,eax
			invoke SetCursor,eax
			mov		eax,uMsg
			.if eax==WM_LBUTTONDOWN
				.if fSizeing==FALSE
					mov		fSizeing,TRUE
					invoke SetCapture,hWin
					invoke PropertyList,0
					mov		eax,lParam
					and		eax,0FFFFh
					cwde
					mov		MousePtDown.x,eax
					mov		eax,lParam
					shr		eax,16
					cwde
					mov		MousePtDown.y,eax
					mov		ParPt.x,0
					mov		ParPt.y,0
					invoke ClientToScreen,hDialog,addr ParPt
					invoke GetWindowRect,hReSize,addr CtlRect
					invoke GetWindowLong,hReSize,GWL_USERDATA
					mov		edi,eax
					assume edi:ptr DIALOG
					mov		eax,[edi].ntype
					.if eax==7 || eax==24
						mov		eax,[edi].ccy
						add		eax,CtlRect.top
						mov		CtlRect.bottom,eax
					.endif
					invoke CopyRect,addr SizeRect,addr CtlRect
					invoke DlgDrawRect,hReSize,addr SizeRect,0,0
				.endif
			.elseif eax==WM_LBUTTONUP
				.if fSizeing
					mov		fSizeing,FALSE
					invoke ReleaseCapture
					invoke DlgDrawRect,hReSize,addr SizeRect,2,0
					mov		eax,SizeRect.left
					sub		SizeRect.right,eax
					mov		eax,SizeRect.top
					sub		SizeRect.bottom,eax
					mov		eax,ParPt.x
					sub		SizeRect.left,eax
					mov		eax,ParPt.y
					sub		SizeRect.top,eax
					invoke GetWindowLong,hReSize,GWL_USERDATA
					mov		edi,eax
					assume edi:ptr DIALOG
					mov		fChanged,FALSE
					mov		eax,[edi].ntype
					.if eax
						mov		eax,SizeRect.left
						.if eax!=[edi].x
							mov		[edi].x,eax
							mov		fChanged,TRUE
						.endif
						mov		eax,SizeRect.top
						.if eax!=[edi].y
							mov		[edi].y,eax
							mov		fChanged,TRUE
						.endif
					.endif
					mov		eax,SizeRect.right
					.if eax!=[edi].ccx
						mov		[edi].ccx,eax
						mov		fChanged,TRUE
					.endif
					mov		eax,SizeRect.bottom
					.if eax!=[edi].ccy
						mov		[edi].ccy,eax
						mov		fChanged,TRUE
					.endif
					assume edi:nothing
					.if fChanged
						invoke UpdateCtl,hReSize
						mov		hReSize,eax
					.else
						invoke PropertyList,hReSize
					.endif
					invoke ShowWindow,hTlt,SW_HIDE
				.endif
			.elseif eax==WM_MOUSEMOVE
				.if fSizeing
					mov		parpt.x,0
					mov		parpt.y,0
					invoke ClientToScreen,hDialog,addr parpt
					invoke CopyRect,addr SizeRect,addr CtlRect
					mov		eax,lParam
					and		eax,0FFFFh
					cwde
					sub		eax,MousePtDown.x
					mov		pt.x,eax
					mov		eax,lParam
					shr		eax,16
					cwde
					sub		eax,MousePtDown.y
					mov		pt.y,eax
					mov		eax,nInx
					.if eax==0
						mov		eax,pt.x
						add		SizeRect.left,eax
						mov		eax,SizeRect.left
						sub		eax,parpt.x
						invoke SizeX,0
						add		eax,parpt.x
						mov		SizeRect.left,eax
						mov		eax,pt.y
						add		SizeRect.top,eax
						mov		eax,SizeRect.top
						sub		eax,parpt.y
						invoke SizeY,0
						add		eax,parpt.y
						mov		SizeRect.top,eax
					.elseif eax==1
						mov		eax,pt.y
						add		SizeRect.top,eax
						mov		eax,SizeRect.top
						sub		eax,parpt.y
						invoke SizeY,0
						add		eax,parpt.y
						mov		SizeRect.top,eax
					.elseif eax==2
						mov		eax,pt.x
						add		SizeRect.right,eax
						mov		eax,SizeRect.right
						sub		eax,SizeRect.left
						invoke SizeX,1
						add		eax,SizeRect.left
						mov		SizeRect.right,eax
						mov		eax,pt.y
						add		SizeRect.top,eax
						mov		eax,SizeRect.top
						sub		eax,parpt.y
						invoke SizeY,0
						add		eax,parpt.y
						mov		SizeRect.top,eax
					.elseif eax==3
						mov		eax,pt.x
						add		SizeRect.left,eax
						mov		eax,SizeRect.left
						sub		eax,parpt.x
						invoke SizeX,0
						add		eax,parpt.x
						mov		SizeRect.left,eax
					.elseif eax==4
						mov		eax,pt.x
						add		SizeRect.right,eax
						mov		eax,SizeRect.right
						sub		eax,SizeRect.left
						invoke SizeX,1
						add		eax,SizeRect.left
						mov		SizeRect.right,eax
					.elseif eax==5
						mov		eax,pt.x
						add		SizeRect.left,eax
						mov		eax,SizeRect.left
						sub		eax,parpt.x
						invoke SizeX,0
						add		eax,parpt.x
						mov		SizeRect.left,eax
						mov		eax,pt.y
						add		SizeRect.bottom,eax
						mov		eax,SizeRect.bottom
						sub		eax,SizeRect.top
						invoke SizeY,1
						add		eax,SizeRect.top
						mov		SizeRect.bottom,eax
					.elseif eax==6
						mov		eax,pt.y
						add		SizeRect.bottom,eax
						mov		eax,SizeRect.bottom
						sub		eax,SizeRect.top
						invoke SizeY,1
						add		eax,SizeRect.top
						mov		SizeRect.bottom,eax
					.elseif eax==7
						mov		eax,pt.x
						add		SizeRect.right,eax
						mov		eax,SizeRect.right
						sub		eax,SizeRect.left
						invoke SizeX,1
						add		eax,SizeRect.left
						mov		SizeRect.right,eax
						mov		eax,pt.y
						add		SizeRect.bottom,eax
						mov		eax,SizeRect.bottom
						sub		eax,SizeRect.top
						invoke SizeY,1
						add		eax,SizeRect.top
						mov		SizeRect.bottom,eax
					.endif
					invoke DlgDrawRect,hReSize,addr SizeRect,1,0
					mov		eax,SizeRect.right
					sub		eax,SizeRect.left
					mov		pt.x,eax
					mov		eax,SizeRect.bottom
					sub		eax,SizeRect.top
					mov		pt.y,eax
					invoke DialogTltSize,pt.x,pt.y
				.endif
			.endif
			xor		eax,eax
			ret
		.endif
	.endif
	invoke CallWindowProc,OldSizeingProc,hWin,uMsg,wParam,lParam
	ret

SizeingProc endp

DrawSizeingItem proc uses edi,xP:DWORD,yP:DWORD,nInx:DWORD,hCur:DWORD,hPar:DWORD,fLocked:DWORD
	LOCAL	hWin:HWND

	mov		eax,nInx
	shl		eax,2
	mov		edi,offset hSizeing
	add		edi,eax
	mov		eax,[edi]
	.if eax
		invoke DestroyWindow,eax
	.endif
	invoke GetWindowLong,hMdiCld,4
	.if eax!=0 && fLocked==FALSE
		m2m		fLocked,(DLGHEAD ptr [eax]).locked
	.endif
	invoke GetWindowLong,hMdiCld,8
	.if eax
		mov		fLocked,TRUE
	.endif
	.if fLocked
		mov		hCur,NULL
	.endif
	.if hCur
		mov		edx,WS_CHILD or WS_VISIBLE or SS_WHITERECT or WS_BORDER or SS_NOTIFY or WS_CLIPSIBLINGS or WS_CLIPCHILDREN
	.else
		mov		edx,WS_CHILD or WS_VISIBLE or SS_GRAYRECT or WS_BORDER or SS_NOTIFY or WS_CLIPSIBLINGS or WS_CLIPCHILDREN
	.endif
	invoke CreateWindowEx,0,addr szStatic,0,edx,xP,yP,6,6,hPar,0,hInstance,0
	mov		hWin,eax
	mov		[edi],eax
	mov		eax,nInx
	shl		eax,16
	or		eax,hCur
	invoke SetWindowLong,hWin,GWL_USERDATA,eax
	invoke SetWindowLong,hWin,GWL_WNDPROC,offset SizeingProc
	mov		OldSizeingProc,eax
	invoke SetWindowPos,hWin,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	ret

DrawSizeingItem endp

DrawMultiSelItem proc xP:DWORD,yP:DWORD,hPar:HWND,fLocked:DWORD,hPrv:HWND
	LOCAL	hWin:HWND

	.if !fLocked
		mov		edx,WS_CHILD or WS_CLIPSIBLINGS or WS_VISIBLE or SS_WHITERECT or WS_BORDER
	.else
		mov		edx,WS_CHILD or WS_CLIPSIBLINGS or WS_VISIBLE or SS_GRAYRECT or WS_BORDER
	.endif
	invoke CreateWindowEx,0,addr szStatic,0,edx,xP,yP,6,6,hPar,0,hInstance,0
	mov		hWin,eax
	invoke SetWindowLong,hWin,GWL_USERDATA,hPrv
	invoke SetWindowPos,hWin,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	mov		eax,hWin
	ret

DrawMultiSelItem endp

DestroyMultiSel proc hSel:HWND

	.if hSel
		invoke GetParent,hSel
		push	eax
		mov		eax,8
		.while eax
			push	eax
			invoke GetWindowLong,hSel,GWL_USERDATA
			push	eax
			invoke DestroyWindow,hSel
			pop		hSel
			pop		eax
			dec		eax
		.endw
		pop		eax
	.endif
	mov		eax,hSel
	ret

DestroyMultiSel endp

MultiSelRect proc uses ebx,hWin:HWND,fLocked:DWORD
	LOCAL	rect:RECT
	LOCAL	ctlrect:RECT
	LOCAL	pt:POINT
	LOCAL	hSel:HWND

	mov		hSel,0
	mov		ebx,hMultiSel
	.while ebx
		invoke GetParent,ebx
		.if eax==hWin
			invoke DestroyMultiSel,ebx
			mov		ebx,eax
			.if hSel
				invoke SetWindowLong,hSel,GWL_USERDATA,ebx
			.else
				mov		hMultiSel,ebx
			.endif
			xor		ebx,ebx
		.else
			mov		ecx,8
			.while ecx
				push	ecx
				mov		hSel,ebx
				invoke GetWindowLong,ebx,GWL_USERDATA
				mov		ebx,eax
				pop		ecx
				dec		ecx
			.endw
		.endif
	.endw
	mov		ParPt.x,0
	mov		ParPt.y,0
	invoke ClientToScreen,hWin,addr ParPt
	invoke GetWindowRect,hWin,addr rect
	invoke CopyRect,addr CtlRect,addr rect
	mov		eax,ParPt.x
	sub		rect.left,eax
	sub		rect.right,eax
	mov		eax,ParPt.y
	sub		rect.top,eax
	sub		rect.bottom,eax
	invoke CopyRect,addr ctlrect,addr rect
	sub		rect.right,6
	sub		rect.bottom,6
	mov		eax,rect.right
	sub		eax,rect.left
	shr		eax,1
	add		eax,rect.left
	mov		pt.x,eax

	mov		eax,rect.bottom
	sub		eax,rect.top
	shr		eax,1
	add		eax,rect.top
	mov		pt.y,eax
	invoke DrawMultiSelItem,rect.left,rect.top,hWin,fLocked,hMultiSel
	invoke DrawMultiSelItem,pt.x,rect.top,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.right,rect.top,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.left,pt.y,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.right,pt.y,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.left,rect.bottom,hWin,fLocked,eax
	invoke DrawMultiSelItem,pt.x,rect.bottom,hWin,fLocked,eax
	invoke DrawMultiSelItem,rect.right,rect.bottom,hWin,fLocked,eax
	mov		hMultiSel,eax
	invoke SendMessage,hMdiCld,WM_LBUTTONDOWN,0,0
	ret

MultiSelRect endp

SizeingRect proc uses esi,hWin:HWND,fLocked:DWORD
	LOCAL	fDlg:DWORD
	LOCAL	rect:RECT
	LOCAL	ctlrect:RECT
	LOCAL	pt:POINT
	LOCAL	hPar:HWND

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		esi,eax
	.if fLocked!=99
		.while hMultiSel
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
		.endw
		m2m		hReSize,hWin
	.endif
	mov		fDlg,FALSE
	mov		eax,(DIALOG ptr [esi]).ntype
	.if !eax
		mov		fDlg,TRUE
	.elseif eax==18 || eax==19
		test	[esi].DIALOG.style,CCS_NORESIZE
		.if ZERO?
			mov		fLocked,TRUE
		.endif
	.endif
	invoke FetchParent,hWin
	mov		hPar,eax
	mov		ParPt.x,0
	mov		ParPt.y,0
	invoke ClientToScreen,hPar,addr ParPt
	invoke GetWindowRect,hWin,addr rect
	mov		eax,(DIALOG ptr [esi]).ntype
	.if eax==7 || eax==8 || eax==24
		mov		eax,(DIALOG ptr [esi]).ccy
		add		eax,rect.top
		mov		rect.bottom,eax
	.endif
	invoke CopyRect,addr CtlRect,addr rect
	mov		eax,ParPt.x
	sub		rect.left,eax
	sub		rect.right,eax
	mov		eax,ParPt.y
	sub		rect.top,eax
	sub		rect.bottom,eax
	invoke CopyRect,addr ctlrect,addr rect
	sub		rect.left,6
	sub		rect.top,6
	mov		eax,rect.right
	sub		eax,rect.left
	shr		eax,1
	add		eax,rect.left
	mov		pt.x,eax
	mov		eax,rect.bottom
	sub		eax,rect.top
	shr		eax,1
	add		eax,rect.top
	mov		pt.y,eax
	.if fLocked!=99
		.if fDlg
			invoke DrawSizeingItem,rect.left,rect.top,0,0,hPar,fLocked
			invoke DrawSizeingItem,pt.x,rect.top,1,0,hPar,fLocked
			invoke DrawSizeingItem,rect.right,rect.top,2,0,hPar,fLocked
			invoke DrawSizeingItem,rect.left,pt.y,3,0,hPar,fLocked
			invoke DrawSizeingItem,rect.left,rect.bottom,5,0,hPar,fLocked
		.else
			invoke DrawSizeingItem,rect.left,rect.top,0,IDC_SIZENWSE,hPar,fLocked
			invoke DrawSizeingItem,pt.x,rect.top,1,IDC_SIZENS,hPar,fLocked
			invoke DrawSizeingItem,rect.right,rect.top,2,IDC_SIZENESW,hPar,fLocked
			invoke DrawSizeingItem,rect.left,pt.y,3,IDC_SIZEWE,hPar,fLocked
			invoke DrawSizeingItem,rect.left,rect.bottom,5,IDC_SIZENESW,hPar,fLocked
		.endif
		invoke DrawSizeingItem,rect.right,pt.y,4,IDC_SIZEWE,hPar,fLocked
		invoke DrawSizeingItem,pt.x,rect.bottom,6,IDC_SIZENS,hPar,fLocked
		invoke DrawSizeingItem,rect.right,rect.bottom,7,IDC_SIZENWSE,hPar,fLocked
	.endif
	mov		eax,ctlrect.left
	sub		ctlrect.right,eax
	mov		eax,ctlrect.top
	sub		ctlrect.bottom,eax
	.if !fDlg
		invoke UpdateSize,hWin,ctlrect.left,ctlrect.top,ctlrect.right,ctlrect.bottom
	.endif
	.if fLocked!=99
		invoke PropertyList,hWin
		invoke SendMessage,hMdiCld,WM_LBUTTONDOWN,0,0
	.endif
	ret

SizeingRect endp

UpdateSizeingRect proc hWin:HWND,fReadOnly:DWORD

	.if hReSize
		push	hReSize
		invoke DestroySizeingRect
		pop		eax
		.if fReadOnly
			invoke SizeingRect,eax,TRUE
		.else
			invoke SizeingRect,eax,FALSE
		.endif
	.endif
	invoke SendMessage,hWin,WM_PAINT,0,0
	ret

UpdateSizeingRect endp

SnapToGrid proc uses edi,hWin:HWND,lpRect:DWORD
	LOCAL	hPar:HWND

	.if fSnapToGrid
		mov		edi,lpRect
		invoke FetchParent,hWin
		mov		hPar,eax
		mov		ParPt.x,0
		mov		ParPt.y,0
		invoke ClientToScreen,hPar,addr ParPt
		mov		eax,(RECT ptr [edi]).left
		sub		eax,ParPt.x
		xor		edx,edx
		idiv	Gridcx
		imul	Gridcx
		add		eax,ParPt.x
		xchg	(RECT ptr [edi]).left,eax
		sub		eax,(RECT ptr [edi]).left
		sub		(RECT ptr [edi]).right,eax

		mov		eax,(RECT ptr [edi]).top
		sub		eax,ParPt.y
		xor		edx,edx
		idiv	Gridcy
		imul	Gridcy
		add		eax,ParPt.y
		xchg	(RECT ptr [edi]).top,eax
		sub		eax,(RECT ptr [edi]).top
		sub		(RECT ptr [edi]).bottom,eax
	.endif
	ret

SnapToGrid endp

MoveingRect proc uses esi edi,hWin:HWND,lParam:LPARAM,nFun:DWORD,nInx:DWORD
	LOCAL	pt:POINT
	LOCAL	ptold:POINT
	LOCAL	hPar:HWND

	invoke GetWindowRect,hWin,addr CtlRect
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		esi,eax
	mov		eax,(DIALOG ptr [esi]).ntype
	.if eax==7 || eax==24
		mov		eax,(DIALOG ptr [esi]).ccy
		add		eax,CtlRect.top
		mov		CtlRect.bottom,eax
	.endif
	mov		eax,lParam
	and		eax,0FFFFh
	cwde
	mov		pt.x,eax
	mov		eax,lParam
	shr		eax,16
	cwde
	mov		pt.y,eax
	mov		edi,nInx
	shl		edi,4
	add		edi,offset SizeRect
	.if nFun==0
		mov		eax,(DIALOG ptr [esi]).ntype
		.if eax
			mov		fMoveing,TRUE
			mov		eax,pt.x
			mov		MousePtDown.x,eax
			mov		eax,pt.y
			mov		MousePtDown.y,eax
			invoke DlgDrawRect,hWin,addr CtlRect,0,nInx
			invoke CopyRect,edi,addr CtlRect
		.endif
	.elseif nFun==1
		mov		eax,pt.x
		sub		eax,MousePtDown.x
		mov		pt.x,eax
		mov		eax,pt.y
		sub		eax,MousePtDown.y
		mov		pt.y,eax
		m2m		ptold.x,(RECT ptr [edi]).left
		m2m		ptold.y,(RECT ptr [edi]).top
		invoke CopyRect,edi,addr CtlRect
		mov		eax,pt.x
		add		(RECT ptr [edi]).left,eax
		add		(RECT ptr [edi]).right,eax
		mov		eax,pt.y
		add		(RECT ptr [edi]).top,eax
		add		(RECT ptr [edi]).bottom,eax
		invoke SnapToGrid,hWin,edi
		mov		eax,(RECT ptr [edi]).left
		mov		edx,(RECT ptr [edi]).top
;		.if eax!=ptold.x || edx!=ptold.y
			invoke DlgDrawRect,hWin,edi,1,nInx
;		.endif
		invoke FetchParent,hWin
		mov		hPar,eax
		mov		ParPt.x,0
		mov		ParPt.y,0
		invoke ClientToScreen,hPar,addr ParPt
		mov		eax,(RECT ptr [edi]).left
		sub		eax,ParPt.x
		mov		ParPt.x,eax
		mov		eax,(RECT ptr [edi]).top
		sub		eax,ParPt.y
		mov		ParPt.y,eax
	.elseif nFun==2
		invoke DlgDrawRect,hWin,edi,2,nInx
		invoke ShowWindow,hTlt,SW_HIDE
		invoke FetchParent,hWin
		mov		hPar,eax
		mov		ParPt.x,0
		mov		ParPt.y,0
		invoke ClientToScreen,hPar,addr ParPt
		mov		eax,(RECT ptr [edi]).left
		sub		eax,ParPt.x
		mov		pt.x,eax
		mov		eax,(RECT ptr [edi]).top
		sub		eax,ParPt.y
		mov		pt.y,eax
		mov		fMoveing,FALSE
		invoke ReleaseCapture
		invoke SetWindowPos,hWin,0,pt.x,pt.y,0,0,SWP_NOZORDER or SWP_NOSIZE
	.endif
	ret

MoveingRect endp

CtlMultiSelect proc hWin:HWND,lParam:LPARAM

	.if hReSize
		invoke GetWindowLong,hReSize,GWL_USERDATA
		mov		eax,(DIALOG ptr [eax]).ntype
		.if eax && eax!=18 && eax!=19
			mov		eax,hReSize
			.if eax!=hWin
				push	eax
				invoke DestroySizeingRect
				pop		eax
				invoke MultiSelRect,eax,TRUE
				invoke MultiSelRect,hWin,FALSE
			.endif
		.endif
		xor		eax,eax
		ret
	.endif
	.if hMultiSel
		invoke GetParent,hMultiSel
		.if eax==hWin
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
			invoke GetParent,eax
			push	eax
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
			pop		eax
			.if hMultiSel
				invoke MultiSelRect,eax,FALSE
			.else
				mov		fNoMouseUp,TRUE
				invoke SizeingRect,eax,FALSE
			.endif
			xor		eax,eax
			ret
		.else
			push	eax
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
			pop		eax
			invoke MultiSelRect,eax,TRUE
		.endif
	.endif
	invoke MultiSelRect,hWin,FALSE
	ret

CtlMultiSelect endp

GetAccelString proc uses ebx esi edi,nAccel:DWORD,lpBuff:DWORD

	mov		edi,lpBuff
	mov		byte ptr [edi],0
	mov		esi,offset szAclKeys
	mov		ebx,nAccel
	.while byte ptr [esi+1]
		.if bl==[esi]
			test	bh,HOTKEYF_ALT
			.if !ZERO?
				invoke strcat,edi,addr szAlt
			.endif
			test	bh,HOTKEYF_CONTROL
			.if !ZERO?
				invoke strcat,edi,addr szCtrl
			.endif
			test	bh,HOTKEYF_SHIFT
			.if !ZERO?
				invoke strcat,edi,addr szShift
			.endif
			invoke strcat,edi,addr [esi+1]
			.break
		.endif
		inc		esi
		invoke strlen,esi
		lea		esi,[esi+eax+1]
	.endw
	ret

GetAccelString endp

GetMnuPopup proc uses ebx esi,hWin:HWND,lpFileName:DWORD
	LOCAL	hMnu[8]:DWORD
	LOCAL	buffer[256]:BYTE

	invoke GetFileImg,lpFileName
	.if eax==6
		invoke RtlZeroMemory,addr hMnu,sizeof hMnu
		invoke strcpy,addr buffer,addr FileName
;		invoke GetParent,hWin
;		mov		edx,eax
;		invoke GetWindowText,edx,addr FileName,sizeof FileName
;		.if !eax
;			invoke strcpy,addr FileName,addr buffer
;			xor		eax,eax
;			jmp		Ex
;		.endif
;		invoke iniRStripStr,addr FileName,'\'
;		invoke strcat,addr FileName,addr szBackSlash
		invoke strcpy,addr FileName,addr ProjectPath
		invoke strcat,addr FileName,lpFileName
		invoke CreateMnu,3
		.if eax
			mov		esi,eax
			push	esi
			add		esi,sizeof MNUHEAD
			mov		edx,MnuInx
			inc		edx
		  @@:
			mov		eax,(MNUITEM ptr [esi]).itemflag
			.if eax
				mov		eax,(MNUITEM ptr [esi]).level
				.if !eax
					dec		edx
					.if !edx
					  Nx:
						add		esi,sizeof MNUITEM
						mov		eax,(MNUITEM ptr [esi]).level
						.if eax
							dec		eax
							lea		ebx,[hMnu+eax*4]
							mov		eax,[ebx]
							.if !eax
								invoke CreatePopupMenu
								mov		[ebx],eax
							.endif
							mov		al,(MNUITEM ptr [esi]).itemcaption
							.if al=='-'
								invoke AppendMenu,[ebx],MF_SEPARATOR,0,0
							.else
								invoke strcpy,addr buffer,addr (MNUITEM ptr [esi]).itemcaption
								lea		edx,buffer
								.while byte ptr [edx]
									.if word ptr [edx]=='t\'
										mov		word ptr [edx],0920h
									.endif
									inc		edx
								.endw
								.if [esi].MNUITEM.shortcut
									invoke strlen,addr buffer
									mov		dword ptr buffer[eax],0920h
									add		eax,2
									mov		edx,[esi].MNUITEM.shortcut
									invoke GetAccelString,edx,addr buffer[eax]
								.endif
								add		esi,sizeof MNUITEM
								mov		eax,(MNUITEM ptr [esi]).level
								sub		esi,sizeof MNUITEM
								mov		edx,(MNUITEM ptr [esi]).level
								.if eax>edx
									invoke CreatePopupMenu
									mov		[ebx+4],eax
									invoke AppendMenu,[ebx],MF_STRING or MF_POPUP,[ebx+4],addr buffer;(MNUITEM ptr [esi]).itemcaption
								.elseif eax==edx
									invoke AppendMenu,[ebx],MF_STRING,(MNUITEM ptr [esi]).itemid,addr buffer;(MNUITEM ptr [esi]).itemcaption
								.elseif eax
									invoke AppendMenu,[ebx],MF_STRING,(MNUITEM ptr [esi]).itemid,addr buffer;(MNUITEM ptr [esi]).itemcaption
									mov		dword ptr [ebx],0
								.else
									invoke AppendMenu,[ebx],MF_STRING,(MNUITEM ptr [esi]).itemid,addr buffer;(MNUITEM ptr [esi]).itemcaption
								.endif
							.endif
							jmp		Nx
						.endif
					.endif
				.endif
				add		esi,sizeof MNUITEM
				jmp		@b
			.endif
			pop		esi
			invoke GlobalUnlock,esi
			invoke GlobalFree,esi
			mov		eax,hMnu
		.endif
	.else
		xor		eax,eax
	.endif
  Ex:
	ret

GetMnuPopup endp

CtlProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	lpOldProc:DWORD
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	ws:DWORD
	LOCAL	wsex:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	fShift:DWORD
	LOCAL	fControl:DWORD
	LOCAL	hCtl:HWND

	mov		nInx,0
	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		esi,eax
	m2m		lpOldProc,(DIALOG ptr [esi]).oldproc
	mov		eax,uMsg
	.if eax==WM_NCLBUTTONDOWN || eax==WM_NCLBUTTONDBLCLK || eax==WM_NCMOUSEMOVE || eax==WM_NCLBUTTONUP
		mov		eax,lParam
		and		eax,0FFFFh
		cwde
		mov		rect1.left,eax
		add		eax,100
		mov		rect1.right,eax
		mov		eax,lParam
		shr		eax,16
		cwde
		mov		rect1.top,eax
		add		eax,100
		mov		rect1.bottom,eax
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		ws,eax
		invoke GetWindowLong,hWin,GWL_EXSTYLE
		mov		wsex,eax
		invoke AdjustWindowRectEx,addr rect1,ws,0,wsex
		m2m		pt.x,rect1.left
		m2m		pt.y,rect1.top
		invoke GetWindowRect,hWin,addr rect
		mov		eax,(DIALOG ptr [esi]).ntype
		.if eax==7 || eax==24
			mov		eax,(DIALOG ptr [esi]).ccy
			add		eax,rect.top
			mov		rect.bottom,eax
		.endif
		mov		eax,rect.left
		sub		pt.x,eax
		mov		eax,rect.top
		sub		pt.y,eax
		mov		eax,pt.y
		shl		eax,16
		and		pt.x,0FFFFh
		add		eax,pt.x
		mov		lParam,eax
	.endif
	mov		eax,(DIALOG ptr [esi]).ntype
	.if !eax && !fDrawing
		mov		eax,uMsg
		.if eax==WM_NCLBUTTONDOWN || eax==WM_LBUTTONDOWN
			.if !MnuTrack
				invoke SendMessage,hWin,WM_NCPAINT,0,0
				.if MnuHigh
					mov		eax,MnuHigh
					and		eax,0FFFFh
					mov		pt.x,eax
					mov		eax,MnuHigh
					shr		eax,16
					mov		pt.y,eax
					invoke GetWindowRect,hWin,addr rect
					mov		eax,rect.left
					add		pt.x,eax
					mov		eax,rect.top
					add		pt.y,eax
					sub		esi,sizeof DLGHEAD
					invoke GetMnuPopup,hWin,addr (DLGHEAD ptr [esi]).menuid
					mov		MnuTrack,eax
					.if eax
						push	MnuInx
						invoke TrackPopupMenu,MnuTrack,TPM_LEFTALIGN or TPM_LEFTBUTTON,pt.x,pt.y,0,hWin,0
						invoke DestroyMenu,MnuTrack
						mov		MnuTrack,0
						invoke ReleaseCapture
						invoke SendMessage,hWin,WM_NCMOUSEMOVE,wParam,lParam
						invoke SendMessage,hWin,WM_NCPAINT,0,0
						pop		eax
						.if eax==MnuInx
							mov		MnuPtx,-1
						.endif
					.endif
					jmp		Ex
				.endif
			.else
				invoke DestroyMenu,MnuTrack
				mov		MnuTrack,0
				jmp		Ex
			.endif
		.elseif eax==WM_NCMOUSEMOVE || eax==WM_MOUSEMOVE
			.if !MnuTrack
				invoke GetCursorPos,addr pt
				invoke ScreenToClient,hWin,addr pt
				mov		MnuPtx,-1
				mov		eax,pt.x
				mov		edx,pt.y
				neg		edx
				.if edx>1 && edx<18 && eax<MnuRight
					mov		MnuPtx,eax
					invoke SendMessage,hWin,WM_NCPAINT,0,0
					invoke SetCapture,hWin
				.elseif MnuHigh
					invoke SendMessage,hWin,WM_NCPAINT,0,0
					invoke GetCapture
					.if eax==hWin
						invoke ReleaseCapture
					.endif
				.else
					invoke GetCapture
					.if eax==hWin
						invoke ReleaseCapture
					.endif
				.endif
			.else
				invoke DestroyMenu,MnuTrack
				xor		eax,eax
				mov		MnuTrack,eax
			.endif
		.elseif eax==WM_COMMAND && !lParam
			sub		esi,sizeof DLGHEAD
			invoke GetFileImg,addr (DLGHEAD ptr [esi]).menuid
			.if eax==6
				invoke strcpy,addr buffer,addr FileName
				invoke strcpy,addr FileName,addr ProjectPath
				invoke strcat,addr FileName,addr (DLGHEAD ptr [esi]).menuid
;				invoke GetFileAttributes,addr FileName
;				inc		eax
;				je		Ex
				invoke CreateMnu,3
				mov		esi,eax
				invoke strcpy,addr FileName,addr buffer
				.if esi
					push	esi
					add		esi,sizeof MNUHEAD
					sub		esi,sizeof MNUITEM
					mov		eax,wParam
				  @@:
					add		esi,sizeof MNUITEM
					.if [esi].MNUITEM.itemflag
						cmp		eax,[esi].MNUITEM.itemid
						jne		@b
						invoke DllProc,hMdiCld,AIM_DLGMNUSELECT,hWin,esi,RAM_DLGMNUSELECT
					.endif
					pop		esi
					invoke GlobalUnlock,esi
					invoke GlobalFree,esi
				.endif
			.endif
			jmp		Ex
		.endif
	.endif
	mov		eax,uMsg
	.if eax==WM_MOUSEMOVE || eax==WM_NCMOUSEMOVE
		invoke GetCursorPos,addr pt
		invoke FindParent,hWin
		invoke GetParent,eax
		invoke GetWindowLong,eax,4
		.if eax
			add		eax,sizeof DLGHEAD
			mov		edx,(DIALOG ptr [eax]).hwnd
			invoke ScreenToClient,edx,addr pt
			invoke BinToDec,pt.x,offset szPos+5
			invoke strlen,offset szPos
			mov		byte ptr szPos[eax],','
			inc		eax
			invoke BinToDec,pt.y,addr szPos[eax]
			invoke SendMessage,hStatus,SB_SETTEXT,0,offset szPos
		.endif
		mov		eax,hWin
		.if fCodeTooltip && eax!=infoshowhwnd
			mov		infoshowhwnd,eax
			push	edi
			mov		edi,offset szCtlText
			mov		edx,[esi].DIALOG.ntype
			.while edx
				inc		edi
				.if byte ptr [edi]==','
					inc		edi
					dec		edx
				.endif
			.endw
			mov		edx,offset tempbuff
			.while byte ptr [edi]!=',' && byte ptr [edi]
				mov		al,[edi]
				mov		[edx],al
				inc		edi
				inc		edx
			.endw
			mov		word ptr [edx],','
			pop		edi
			invoke strcat,offset tempbuff,addr [esi].DIALOG.idname
			invoke strlen,offset tempbuff
			mov		byte ptr tempbuff[eax],','
			inc		eax
			invoke BinToDec,[esi].DIALOG.id,addr tempbuff[eax]
			invoke SendMessage,hInfEdt,WM_SETTEXT,0,offset tempbuff
		.endif
	.endif
	mov		eax,uMsg
	.if eax==WM_RBUTTONDOWN
		mov		eax,lParam
		cwde
		mov		pt.x,eax
		mov		eax,lParam
		shr		eax,16
		cwde
		mov		pt.y,eax
		invoke ClientToScreen,hWin,addr pt
		mov		eax,pt.y
		shl		eax,16
		mov		ax,word ptr pt.x
		invoke SendMessage,hMdiCld,WM_CONTEXTMENU,hWin,eax
	.elseif eax==WM_NCRBUTTONDOWN
		invoke SendMessage,hMdiCld,WM_CONTEXTMENU,hWin,lParam
	.elseif eax==WM_LBUTTONDBLCLK || eax==WM_NCLBUTTONDBLCLK
		invoke DllProc,hMdiCld,AIM_CTLDBLCLK,hWin,esi,RAM_CTLDBLCLK
	.elseif eax==WM_SETCURSOR
		.if ToolBoxID
			invoke LoadCursor,NULL,IDC_CROSS
		.else
			invoke LoadCursor,NULL,IDC_ARROW
		.endif
		invoke SetCursor,eax
	.elseif eax==WM_LBUTTONDOWN || eax==WM_NCLBUTTONDOWN
		invoke SetFocus,hMdiCld
		invoke UpdateWindow,hMdiCld
		invoke GetWindowLong,hWin,GWL_USERDATA
		or		eax,eax
		je		Ex
		.if ToolBoxID
			;Is readOnly
			invoke GetWindowLong,hMdiCld,8
			.if !eax
				;Draw outline of new control
				invoke DrawingRect,hWin,lParam,0
			.endif
		.elseif !fMoveing
			;Select control
			;Shift key
			invoke GetAsyncKeyState,VK_SHIFT
			and		eax,8000h
			mov		fShift,eax
			;Control key
			invoke GetAsyncKeyState,VK_CONTROL
			and		eax,8000h
			mov		fControl,eax
			.if !fControl && !fShift && !fMultiSel
				mov		eax,hMultiSel
				.if eax
				  @@:
					push	eax
					invoke GetParent,eax
					.if eax==hWin
						pop		eax
						jmp		@f
					.endif
					pop		eax
					mov		ecx,8
					.while ecx
						push	ecx
						invoke GetWindowLong,eax,GWL_USERDATA
						pop		ecx
						dec		ecx
					.endw
					or		eax,eax
					jne		@b
				.endif
				.while hMultiSel
					invoke GetParent,hMultiSel
					invoke PostMessage,eax,WM_PAINT,0,0
					invoke DestroyMultiSel,hMultiSel
					mov		hMultiSel,eax
					.if !eax
						invoke PostMessage,hWin,uMsg,wParam,lParam
						jmp		Ex
					.endif
				.endw
			  @@:
				.if hMultiSel
					invoke SetCapture,hWin
					mov		eax,hMultiSel
				  @@:
					push	eax
					invoke GetParent,eax
					invoke MoveingRect,eax,lParam,0,nInx
					inc		nInx
					mov		ecx,8
					pop		eax
					.while ecx
						push	ecx
						invoke GetWindowLong,eax,GWL_USERDATA
						pop		ecx
						dec		ecx
					.endw
					or		eax,eax
					jne		@b
				.else
					invoke GetWindowLong,hMdiCld,8	;ReadOnly
					push	eax
					invoke GetWindowLong,hMdiCld,4
					pop		edx
					.if eax
						mov		eax,(DLGHEAD ptr [eax]).locked
						.if !eax && !edx
							.if hReSize
								invoke DestroySizeingRect
							.endif
							mov		eax,(DIALOG ptr [esi]).ntype
							.if eax
								mov		edx,(DIALOG ptr [esi]).style
								and		edx,CCS_NORESIZE
								.if !edx && (eax==18 || eax==19)
								.else
									invoke SetCapture,hWin
									invoke MoveingRect,hWin,lParam,0,0
									invoke MoveingRect,hWin,lParam,1,0
									invoke DialogTltSize,ParPt.x,ParPt.y
								.endif
							.endif
						.endif
					.endif
				.endif
			.else
				invoke GetWindowLong,hWin,GWL_USERDATA
				mov		edx,(DIALOG ptr [eax]).style
				and		edx,CCS_NORESIZE
				mov		eax,(DIALOG ptr [eax]).ntype
				.if fShift && !fControl
					.if !eax || eax==3
						;Draw multisel rect
						invoke DrawingRect,hWin,lParam,0
						mov		fMultiSel,TRUE
					.endif
				.elseif !fShift && fControl
					.if eax
						.if !edx && (eax==18 || eax==19)
						.else
							invoke CtlMultiSelect,hWin,lParam
						.endif
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_MOUSEMOVE || eax==WM_NCMOUSEMOVE
		.if ToolBoxID
			invoke DrawingRect,hWin,lParam,1
		.elseif fMoveing
			.if hMultiSel
				mov		eax,hMultiSel
			  @@:
				push	eax
				invoke GetParent,eax
				push	eax
				invoke MoveingRect,eax,lParam,1,nInx
				pop		eax
				.if eax==hWin
					invoke DialogTltSize,ParPt.x,ParPt.y
				.endif
				inc		nInx
				mov		ecx,8
				pop		eax
				.while ecx
					push	ecx
					invoke GetWindowLong,eax,GWL_USERDATA
					pop		ecx
					dec		ecx
				.endw
				or		eax,eax
				jne		@b
			.else
				invoke MoveingRect,hWin,lParam,1,0
				invoke DialogTltSize,ParPt.x,ParPt.y
			.endif
		.else
			.if fDrawing
				invoke DrawingRect,hWin,lParam,1
			.endif
		.endif
	.elseif eax==WM_LBUTTONUP || eax==WM_NCLBUTTONUP
		.if !fNoMouseUp
			.if fMoveing
				.if hMultiSel
					mov		eax,hMultiSel
					.while eax
						push	eax
						invoke GetParent,eax
						push	eax
						invoke MoveingRect,eax,lParam,2,nInx
						pop		eax
						invoke SizeingRect,eax,99
						inc		nInx
						mov		ecx,8
						pop		eax
						.while ecx
							push	ecx
							invoke GetWindowLong,eax,GWL_USERDATA
							pop		ecx
							dec		ecx
						.endw
					.endw
				.else
					invoke SetFocus,hWnd
					invoke MoveingRect,hWin,lParam,2,0
					invoke SizeingRect,hWin,FALSE
				.endif
				invoke ReleaseCapture
				mov		fMoveing,0
			.elseif fDrawing
				push	ToolBoxID
				invoke DrawingRect,hWin,lParam,2
				pop		eax
				.if !eax
					.if hReSize
						invoke DestroySizeingRect
					.endif
					.while hMultiSel
						invoke DestroyMultiSel,hMultiSel
						mov		hMultiSel,eax
					.endw
					.if SizeRect.right>80000000h
						m2m		SizeRect.right,SizeRect.left
						mov		SizeRect.left,0
					.endif
					mov		eax,SizeRect.left
					add		SizeRect.right,eax
					.if SizeRect.bottom>80000000h
						m2m		SizeRect.bottom,SizeRect.top
						mov		SizeRect.top,0
					.endif
					mov		eax,SizeRect.top
					add		SizeRect.bottom,eax
					mov		eax,TRUE
					.while eax
						add		esi,sizeof DIALOG
						mov		eax,(DIALOG ptr [esi]).hwnd
						.if eax && eax!=-1
							mov		eax,(DIALOG ptr [esi]).x
							mov		ecx,eax
							add		ecx,(DIALOG ptr [esi]).ccx
							.if (eax>=SizeRect.left && eax<=SizeRect.right) || (ecx>=SizeRect.left && ecx<=SizeRect.right) || (SizeRect.left>=eax && SizeRect.right<=ecx)
								mov		eax,(DIALOG ptr [esi]).y
								mov		ecx,eax
								add		ecx,(DIALOG ptr [esi]).ccy
								.if (eax>=SizeRect.top && eax<=SizeRect.bottom) || (ecx>=SizeRect.top && ecx<=SizeRect.bottom) || (SizeRect.top>=eax && SizeRect.bottom<=ecx)
									mov		eax,(DIALOG ptr [esi]).ntype
									.if eax!=18 && eax!=19
										mov		eax,(DIALOG ptr [esi]).hwnd
										invoke CtlMultiSelect,eax,lParam
										inc		nInx
									.endif
								.endif
							.endif
							mov		eax,TRUE
						.endif
					.endw
					.if nInx==1 && hMultiSel
						invoke GetParent,hMultiSel
						invoke SizeingRect,eax,FALSE
					.endif
				.endif
			.else
				.if !hMultiSel
					invoke SizeingRect,hWin,FALSE
				.endif
			.endif
		.else
			mov		fNoMouseUp,FALSE
		.endif
		mov		fMultiSel,FALSE
	.elseif eax==WM_SYSCOMMAND
	.elseif eax==WM_MOUSEWHEEL
		invoke GetParent,hWin
		invoke PostMessage,eax,uMsg,wParam,lParam
	.elseif eax==WM_SIZE
		mov		eax,(DIALOG ptr [esi]).ntype
		.if !eax
			invoke GetClientRect,hWin,addr rect
			sub		esi,sizeof DLGHEAD
			mov		eax,(DLGHEAD ptr [esi]).htlb
			.if eax
				mov		hCtl,eax
				invoke GetWindowLong,eax,GWL_STYLE
				test	eax,CCS_NORESIZE
				.if ZERO?
					invoke MoveWindow,hCtl,0,0,0,0,TRUE
				.endif
			.endif
			mov		eax,(DLGHEAD ptr [esi]).hstb
			.if eax
				mov		hCtl,eax
				invoke GetWindowLong,eax,GWL_STYLE
				test	eax,CCS_NORESIZE
				.if ZERO?
					invoke MoveWindow,hCtl,0,0,0,0,TRUE
				.endif
			.endif
		.elseif [esi].DIALOG.hdmy
			invoke GetClientRect,hWin,addr rect
			invoke MoveWindow,[esi].DIALOG.hdmy,0,0,rect.right,rect.bottom,TRUE
		.endif
		jmp		ExDef
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,(NMHDR ptr [edx]).code
		.if eax==PGN_CALCSIZE
			mov		eax,[edx].NMPGCALCSIZE.dwFlag
			.if eax==PGF_CALCHEIGHT
				mov		[edx].NMPGCALCSIZE.iHeight,2048
			.else
				mov		[edx].NMPGCALCSIZE.iWidth,2048
			.endif
		.endif
	.elseif eax==WM_PAINT
		.if hTabSet
			invoke InvalidateRect,hTabSet,NULL,TRUE
		.endif
		jmp		ExDef
;	.elseif eax==WM_ERASEBKGND
;;PrintHex eax
;invoke ValidateRect,hWin,NULL
;		xor		eax,eax
;		inc		eax
;		ret
	.else
  ExDef:
		invoke CallWindowProc,lpOldProc,hWin,uMsg,wParam,lParam
		ret
	.endif
  Ex:
	xor		eax,eax
	ret

CtlProc endp

CtlDummyProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	ptp:POINT
	LOCAL	hPar:HWND

	mov		eax,uMsg
	.if eax>=WM_MOUSEFIRST && eax<=WM_MOUSELAST
		mov		edx,lParam
		movzx	eax,dx
		mov		pt.x,eax
		shr		edx,16
		mov		pt.y,edx
		invoke ClientToScreen,hWin,addr pt
		invoke GetParent,hWin
		mov		hPar,eax
		mov		ptp.x,0
		mov		ptp.y,0
		invoke ClientToScreen,hPar,addr ptp
		mov		eax,pt.x
		sub		eax,ptp.x
		mov		edx,pt.y
		sub		edx,ptp.y
		shl		edx,16
		or		edx,eax
		invoke PostMessage,hPar,uMsg,wParam,edx
	.elseif eax==WM_SETCURSOR
	.else
		invoke GetWindowLong,hWin,GWL_USERDATA
		invoke CallWindowProc,eax,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor		eax,eax
	ret


CtlDummyProc endp

CtlEnumProc proc hWin:HWND,lParam:LPARAM

	.if lParam
		invoke SetWindowLong,hWin,GWL_WNDPROC,offset CtlDummyProc
		invoke SetWindowLong,hWin,GWL_USERDATA,eax
	.else
		invoke GetWindowLong,hWin,GWL_STYLE
		or		eax,WS_DISABLED
		invoke SetWindowLong,hWin,GWL_STYLE,eax
	.endif
	mov		eax,TRUE
	ret

CtlEnumProc endp

MakeDlgFont proc uses esi,lpMem:DWORD
	LOCAL	lf:LOGFONT

	mov		esi,lpMem
	invoke RtlZeroMemory,addr lf,size lf
	mov		eax,[esi].DLGHEAD.fontht
	mov		lf.lfHeight,eax
	mov		lf.lfWeight,400
	mov		al,[esi].DLGHEAD.charset
	mov		lf.lfCharSet,al
	mov		al,[esi].DLGHEAD.italic
	mov		lf.lfItalic,al
	movzx	eax,[esi].DLGHEAD.weight
	mov		lf.lfWeight,eax
	invoke strcpy,addr lf.lfFaceName,addr [esi].DLGHEAD.font
	invoke CreateFontIndirect,addr lf
	mov		[esi].DLGHEAD.hfont,eax
	ret

MakeDlgFont endp

DeConvertCaption proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	mov		edi,lpDest
	mov		esi,lpSource
	xor		ecx,ecx
	.while byte ptr [esi] && ecx<MaxCap-3
		mov		al,[esi]
		.if al==0Dh
			mov		word ptr [edi],'r\'
			add		edi,2
			add		ecx,2
		.elseif al==0Ah
			mov		word ptr [edi],'n\'
			add		edi,2
			add		ecx,2
		.elseif al==09h
			mov		word ptr [edi],'t\'
			add		edi,2
			add		ecx,2
		.elseif al==08h
			mov		word ptr [edi],'a\'
			add		edi,2
			add		ecx,2
		.else
			mov		[edi],al
			inc		edi
			inc		ecx
		.endif
		inc		esi
	.endw
	mov		byte ptr [edi],0
	ret

DeConvertCaption endp

ConvertCaption proc uses esi edi,lpDest:DWORD,lpSource:DWORD

	mov		edi,lpDest
	mov		esi,lpSource
	.while byte ptr [esi]
		mov		ax,[esi]
		.if ax=='a\'
			add		esi,2
			mov		byte ptr [edi],08h
			inc		edi
		.elseif ax=='n\'
			add		esi,2
			mov		byte ptr [edi],0Ah
			inc		edi
		.elseif ax=='r\'
			add		esi,2
			mov		byte ptr [edi],VK_RETURN
			inc		edi
		.elseif ax=='t\'
			add		esi,2
			mov		byte ptr [edi],VK_TAB
			inc		edi
		.elseif ax=='x\'
			add		esi,2
			mov		byte ptr [edi],0
			inc		edi
		.else
			mov		[edi],al
			inc		esi
			inc		edi
		.endif
	.endw
	mov		byte ptr [edi],0
	ret

ConvertCaption endp

DesignDummyProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	rect:RECT
	LOCAL	hDlg:HWND
	LOCAL	buffer[16]:BYTE
	LOCAL	pt:POINT
	LOCAL	hMem:DWORD

	mov		eax,uMsg
	.if eax>=WM_MOUSEFIRST && eax<=WM_MOUSELAST
		invoke GetWindowLong,hWin,GWL_ID
		.if eax==123456789
			.if  uMsg==WM_LBUTTONDOWN
				mov		eax,lParam
				movsx	eax,ax
				mov		pt.x,eax
				mov		eax,lParam
				shr		eax,16
				movsx	eax,ax
				mov		pt.y,eax
				invoke ClientToScreen,hWin,addr pt
				invoke GetParent,hWin
				invoke GetWindowLong,eax,4
				push	ebx
				mov		ebx,eax
				add		ebx,sizeof DLGHEAD
				invoke ScreenToClient,[ebx].DIALOG.hwnd,addr pt
				mov		hDlg,0
				mov		ecx,pt.x
				mov		edx,pt.y
				push	ebx
				add		ebx,sizeof DIALOG
				.while [ebx].DIALOG.hwnd
					.if [ebx].DIALOG.hwnd!=-1
						mov		eax,[ebx].DIALOG.x
						add		eax,[ebx].DIALOG.ccx
						.if ecx>=[ebx].DIALOG.x && ecx<eax
							mov		eax,[ebx].DIALOG.y
							add		eax,[ebx].DIALOG.ccy
							.if edx>=[ebx].DIALOG.y && edx<eax
								mov		eax,[ebx].DIALOG.hwnd
								mov		hDlg,eax
								mov		hMem,ebx
							.endif
						.endif
					.endif
					add		ebx,sizeof DIALOG
				.endw
				pop		ebx
				.if !hDlg
					mov		eax,[ebx].DIALOG.hwnd
					mov		hDlg,eax
					mov		hMem,ebx
				.endif
				.if hDlg
					.while hMultiSel
						invoke GetParent,hMultiSel
						invoke DestroyMultiSel,hMultiSel
						mov		hMultiSel,eax
					.endw
					mov		fMultiSel,FALSE
					invoke DestroySizeingRect
					invoke SizeingRect,hDlg,FALSE
					mov		ebx,hMem
					.if ![ebx].DIALOG.ntype
						invoke DestroyWindow,hTabSet
						pop		ebx
						xor		eax,eax
						mov		hTabSet,eax
						ret
					.else
						test	wParam,MK_CONTROL
						.if ZERO?
							invoke SetNewTab,hDlg,nTabSet
							invoke UpdateCtl,hDlg
						.else
							mov		eax,[ebx].DIALOG.tab
							mov		nTabSet,eax
						.endif
						inc		nTabSet
					.endif
				.endif
				pop		ebx
			.else
				invoke GetParent,hWin
				invoke PostMessage,eax,uMsg,wParam,lParam
			.endif
		.else
			invoke GetParent,hWin
			invoke PostMessage,eax,uMsg,wParam,lParam
		.endif
		xor		eax,eax
	.elseif eax==WM_PAINT
		invoke GetWindowLong,hWin,GWL_ID
		.if eax==123456789
			invoke BeginPaint,hWin,addr ps
			push	ebx
			invoke GetParent,hWin
			invoke GetWindowLong,eax,4
			mov		ebx,eax
			add		ebx,sizeof DLGHEAD
			mov		eax,[ebx].DIALOG.hwnd
			mov		hDlg,eax
			add		ebx,sizeof DIALOG
			.while [ebx].DIALOG.hwnd
				.if [ebx].DIALOG.hwnd!=-1
					.if [ebx].DIALOG.hcld
						invoke UpdateWindow,[ebx].DIALOG.hcld
					.endif
					mov		eax,[ebx].DIALOG.x
					mov		rect.left,eax
					add		eax,22
					mov		rect.right,eax
					mov		eax,[ebx].DIALOG.y
					mov		rect.top,eax
					add		eax,18
					mov		rect.bottom,eax
					invoke ClientToScreen,hDlg,addr rect.left
					invoke ClientToScreen,hDlg,addr rect.right
					invoke ScreenToClient,hWin,addr rect.left
					invoke ScreenToClient,hWin,addr rect.right
					invoke GetStockObject,BLACK_BRUSH
					invoke FillRect,ps.hdc,addr rect,eax
					invoke BinToDec,[ebx].DIALOG.tab,addr buffer
					invoke SetTextColor,ps.hdc,0FFFFFFh
					invoke SetBkMode,ps.hdc,TRANSPARENT
					invoke SendMessage,hTlt,WM_GETFONT,0,0
					invoke SelectObject,ps.hdc,eax
					push	eax
					invoke DrawText,ps.hdc,addr buffer,-1,addr rect,DT_CENTER or DT_VCENTER or DT_SINGLELINE
					pop		eax
					invoke SelectObject,ps.hdc,eax
				.endif
				add		ebx,sizeof DIALOG
			.endw
			invoke EndPaint,hWin,addr ps
			pop		ebx
			xor		eax,eax
		.else
			jmp		ExDef
		.endif
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,GWL_ID
		.if eax==123456789
			mov		hTabSet,0
			mov		nTabSet,0
		.endif
		jmp		ExDef
	.else
  ExDef:
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

DesignDummyProc endp

CreateCtl proc uses esi edi,lpDlgCtl:DWORD
	LOCAL	hCtl:HWND
	LOCAL	hCld:HWND
	LOCAL	hTmp:DWORD
	LOCAL	ws:DWORD
	LOCAL	wsex:DWORD
	LOCAL	tci:TC_ITEM
	LOCAL	lvi:LV_ITEM
	LOCAL	tpe:DWORD
	LOCAL	lpclass:DWORD
	LOCAL	tbb:TBBUTTON
	LOCAL	tbab:TBADDBITMAP
	LOCAL	hMdi:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	rect:RECT
	LOCAL	val:DWORD
	LOCAL	cbei:COMBOBOXEXITEM
	LOCAL	hFnt:DWORD
	LOCAL	rbbi:REBARBANDINFO
	LOCAL	hdi:HD_ITEM

	mov		edi,lpDlgCtl
	assume edi:ptr DIALOG
	m2m		tpe,[edi].ntype
	invoke GetTypePtr,tpe
	mov		esi,eax
	m2m		lpclass,(TYPES ptr [esi]).lpclass
	m2m		ws,[edi].style
	or		ws,WS_ALWAYS
	.if !tpe
		and		ws,-1 xor (WS_POPUP or WS_DISABLED or WS_MINIMIZE or WS_MAXIMIZE or WS_VISIBLE)
		mov		eax,[edi].hpar
		mov		hMdi,eax
		mov		edx,edi
		sub		edx,sizeof DLGHEAD
		invoke MakeDlgFont,edx
		mov		hFnt,eax
	.else
		and		ws,-1 xor (WS_POPUP or WS_DISABLED or WS_MINIMIZE or WS_MAXIMIZE)
		mov		eax,[edi].hpar
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		edx,eax
		mov		eax,(DIALOG ptr [edx]).hpar
		mov		hMdi,eax
		sub		edx,sizeof DLGHEAD
		mov		eax,[edx].DLGHEAD.hfont
		mov		hFnt,eax
		.if tpe==2
			or		ws,SS_NOTIFY
		.elseif tpe==14
			or		ws,LVS_SHAREIMAGELISTS
		.elseif tpe==16
			and		ws,-1 xor UDS_AUTOBUDDY
		.endif
	.endif
	invoke ConvertCaption,addr buffer,addr [edi].caption
	mov		eax,[edi].exstyle
	and		eax,000777FDh
	and		eax,-1 xor WS_EX_MDICHILD
	mov		wsex,eax
	mov		eax,tpe
	.if eax==0
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,0,0,0,0,
		[edi].hpar,NULL,hInstance,0
		mov		hCtl,eax
	.elseif eax==1
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.elseif eax==3
		invoke CreateWindowEx,0,addr szStatic,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
	.elseif eax==11
		invoke CreateWindowEx,0,addr szStatic,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		or		ws,WS_DISABLED
		invoke CreateWindowEx,wsex,lpclass,addr [edi].caption,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
		mov		eax,[edi].style
		and		eax,TCS_VERTICAL
	.elseif eax==17
		mov		edx,ws
		and		edx,WS_BORDER or SS_SUNKEN
		or		edx,WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS
		invoke CreateWindowEx,wsex,addr szStatic,NULL,edx,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke GetWindowRect,hCtl,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		push	eax
		invoke GetClientRect,hCtl,addr rect
		pop		eax
		sub		eax,rect.right
		mov		val,eax
		invoke strcpy,addr buffer,offset ProjectPath
		invoke strcat,addr buffer,addr [edi].caption
		invoke GetFileImg,addr [edi].caption
		.if eax==30 || eax==31
			.if eax==30
				mov		edx,IMAGE_BITMAP
				push	edx
				invoke LoadImage,NULL,addr buffer,edx,NULL,NULL,LR_LOADFROMFILE
			.else
				mov		edx,IMAGE_ICON
				push	edx
				invoke LoadImage,NULL,addr buffer,edx,NULL,NULL,LR_LOADFROMFILE or LR_DEFAULTSIZE
			.endif
			mov		[edi].himg,eax
			.if eax
				mov		edx,0
			.else
				pop		edx
				mov		edx,offset szICODLG
			.endif
		.else
			mov		edx,offset szICODLG
		.endif
		mov		ecx,ws
		and		ecx,-1 xor (WS_BORDER or SS_SUNKEN or SS_NOTIFY)
		or		ecx,WS_CLIPSIBLINGS or WS_CLIPCHILDREN
		invoke CreateWindowEx,0,lpclass,edx,
		ecx,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
		.if [edi].himg
			pop		edx
			invoke SendMessage,hCld,STM_SETIMAGE,edx,[edi].himg
		.endif
		mov		eax,[edi].style
		and		eax,SS_CENTERIMAGE
		.if !eax
			invoke GetWindowRect,hCld,addr rect
			mov		eax,rect.right
			sub		eax,rect.left
			mov		edx,rect.bottom
			sub		edx,rect.top
			.if eax && edx
				add		eax,val
				add		edx,val
				mov		[edi].ccx,eax
				mov		[edi].ccy,edx
				invoke MoveWindow,hCtl,[edi].x,[edi].y,[edi].ccx,[edi].ccy,TRUE
			.endif
		.else
			invoke InvalidateRect,hCtl,NULL,TRUE
		.endif
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.elseif eax==23
		and		ws,0FFFF0000h
		or		ws,SS_LEFT or SS_NOTIFY
		invoke CreateWindowEx,wsex,addr szStatic,addr [edi].caption,
		ws,[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.elseif eax==25
		and		ws,-1 xor SS_NOTIFY
		invoke CreateWindowEx,0,addr szStatic,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		invoke CreateWindowEx,wsex,lpclass,NULL,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
	.elseif eax==26
		or		ws,WS_DISABLED
		invoke CreateWindowEx,0,addr szStatic,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		invoke CreateWindowEx,wsex,lpclass,NULL,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
	.elseif eax==27
		invoke CreateWindowEx,0,addr szStatic,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		invoke CreateWindowEx,wsex,lpclass,NULL,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
	.elseif eax==29 || eax==30
		invoke CreateWindowEx,0,addr szStatic,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke CreateWindowEx,wsex,lpclass,addr [edi].caption,
		ws,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
	.elseif eax==31
		or		ws,4
		invoke CreateWindowEx,wsex,lpclass,addr [edi].caption,
		ws,[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		mov		rbbi.cbSize,sizeof REBARBANDINFO
		mov		rbbi.fMask,RBBIM_STYLE or RBBIM_CHILD or RBBIM_SIZE or RBBIM_CHILDSIZE
		mov		rbbi.fStyle,RBBS_GRIPPERALWAYS or RBBS_CHILDEDGE
		invoke CreateWindowEx,0,addr szStatic,addr [edi].idname,
		WS_CHILD or WS_VISIBLE or SS_LEFT or WS_CLIPSIBLINGS,
		0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		rbbi.hwndChild,eax
		invoke SendMessage,eax,WM_SETFONT,hFnt,0
		mov		eax,[edi].ccx
		mov		rbbi.lx,eax
		mov		eax,[edi].ccx
		mov		rbbi.cxMinChild,eax
		mov		eax,[edi].ccy
		mov		rbbi.cyMinChild,eax
		invoke SendMessage,hCtl,RB_INSERTBAND,0,addr rbbi
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.elseif eax==33
		invoke CreateWindowEx,0,addr szStatic,NULL,
		WS_CHILD or WS_VISIBLE or SS_LEFT or SS_NOTIFY or WS_CLIPSIBLINGS,
		[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		mov		eax,ws
		or		eax,WS_DISABLED
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		eax,0,0,[edi].ccx,[edi].ccy,
		hCtl,0,hInstance,0
		mov		hCld,eax
		mov		[edi].hcld,eax
	.else
		invoke CreateWindowEx,wsex,lpclass,addr buffer,
		ws,[edi].x,[edi].y,[edi].ccx,[edi].ccy,
		[edi].hpar,0,hInstance,0
		mov		hCtl,eax
		invoke SetWindowPos,hCtl,HWND_TOP,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
	.endif
	m2m		[edi].hwnd,hCtl
	invoke SetWindowLong,hCtl,GWL_USERDATA,edi
	invoke SetWindowLong,hCtl,GWL_WNDPROC,offset CtlProc
	mov		[edi].oldproc,eax
	mov		eax,tpe
	.if eax==0
		invoke SetWindowPos,hCtl,HWND_TOP,DlgX,DlgY,[edi].ccx,[edi].ccy,SWP_SHOWWINDOW
	.elseif eax==7
		invoke SendMessage,hCtl,CB_ADDSTRING,0,addr [edi].idname
		invoke SendMessage,hCtl,CB_SETCURSEL,0,0
		invoke EnumChildWindows,hCtl,addr CtlEnumProc,0
	.elseif eax==8
		invoke SendMessage,hCtl,LB_ADDSTRING,0,addr [edi].idname
		invoke SendMessage,hCtl,LB_ADDSTRING,0,addr [edi].idname
	.elseif eax==11
		mov		tci.imask,TCIF_TEXT
		lea		eax,[edi].idname
		mov		tci.pszText,eax
		mov		tci.cchTextMax,6
		invoke SendMessage,hCld,TCM_INSERTITEM,0,addr tci
		invoke SendMessage,hCld,TCM_INSERTITEM,1,addr tci
	.elseif eax==12
		invoke SendMessage,hCtl,PBM_STEPIT,0,0
		invoke SendMessage,hCtl,PBM_STEPIT,0,0
		invoke SendMessage,hCtl,PBM_STEPIT,0,0
	.elseif eax==13
		invoke SendMessage,hCtl,TVM_SETIMAGELIST,0,hTbrIml
		invoke Do_TreeViewAddNode,hCtl,TVI_ROOT,NULL,addr [edi].idname,IML_START+0,IML_START+0,0
		mov		hTmp,eax
		invoke Do_TreeViewAddNode,hCtl,hTmp,NULL,addr [edi].idname,IML_START+1,IML_START+1,1
		mov		edx,eax
		push	eax
		invoke Do_TreeViewAddNode,hCtl,edx,NULL,addr [edi].idname,IML_START+2,IML_START+2,2
		pop		eax
		invoke SendMessage,hCtl,TVM_EXPAND,TVE_EXPAND,eax
		invoke SendMessage,hCtl,TVM_EXPAND,TVE_EXPAND,hTmp
	.elseif eax==14
		invoke SendMessage,hCtl,LVM_SETCOLUMNWIDTH,-1,LVSCW_AUTOSIZE
		invoke SendMessage,hCtl,LVM_SETIMAGELIST,LVSIL_SMALL,hTbrIml
		mov		lvi.imask,LVIF_TEXT or LVIF_IMAGE
		mov		lvi.iItem,0
		mov		lvi.iSubItem,0
		lea		eax,[edi].idname
		mov		lvi.pszText,eax
		mov		lvi.cchTextMax,13
		mov		lvi.iImage,IML_START+0
		invoke SendMessage,hCtl,LVM_INSERTITEM,0,addr lvi
		mov		lvi.iItem,1
		mov		lvi.iImage,IML_START+1
		invoke SendMessage,hCtl,LVM_INSERTITEM,0,addr lvi
		mov		lvi.iItem,2
		mov		lvi.iImage,IML_START+2
		invoke SendMessage,hCtl,LVM_INSERTITEM,0,addr lvi
	.elseif eax==18
		invoke SendMessage,hCtl,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
		invoke SendMessage,hCtl,TB_SETBUTTONSIZE,0,00100010h
		invoke SendMessage,hCtl,TB_SETBITMAPSIZE,0,00100010h
		mov		tbab.hInst,HINST_COMMCTRL
		mov		tbab.nID,IDB_STD_SMALL_COLOR
		invoke SendMessage,hCtl,TB_ADDBITMAP,12,addr tbab
		mov		tbb.fsState,TBSTATE_ENABLED
		mov		tbb.dwData,0
		mov		tbb.iString,0
		mov		tbb.iBitmap,0
		mov		tbb.idCommand,0
		mov		tbb.fsStyle,TBSTYLE_SEP
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,0
		mov		tbb.idCommand,1
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,1
		mov		tbb.idCommand,2
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,2
		mov		tbb.idCommand,3
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,0
		mov		tbb.idCommand,0
		mov		tbb.fsStyle,TBSTYLE_SEP
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,3
		mov		tbb.idCommand,4
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,4
		mov		tbb.idCommand,5
		mov		tbb.fsStyle,TBSTYLE_BUTTON
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		mov		tbb.iBitmap,0
		mov		tbb.idCommand,0
		mov		tbb.fsStyle,TBSTYLE_SEP
		invoke SendMessage,hCtl,TB_ADDBUTTONS,1,addr tbb
		invoke GetWindowLong,hMdi,4
		.if eax
			m2m		(DLGHEAD ptr [eax]).htlb,hCtl
		.endif
	.elseif eax==19
		invoke GetWindowLong,hMdi,4
		.if eax
			m2m		(DLGHEAD ptr [eax]).hstb,hCtl
		.endif
	.elseif eax==20
		invoke EnumChildWindows,hCtl,addr CtlEnumProc,0
	.elseif eax==24
		invoke SendMessage,hCtl,CBEM_SETIMAGELIST,0,hTbrIml
		mov		cbei._mask,CBEIF_IMAGE or CBEIF_TEXT or CBEIF_SELECTEDIMAGE
		mov		cbei.iItem,0
		lea		eax,[edi].idname
		mov		cbei.pszText,eax
		mov		cbei.cchTextMax,32
		mov		cbei.iImage,IML_START+0
		mov		cbei.iSelectedImage,IML_START+0
		invoke SendMessage,hCtl,CBEM_INSERTITEM,0,addr cbei
		mov		cbei.iItem,1
		mov		cbei.iImage,IML_START+1
		mov		cbei.iSelectedImage,IML_START+1
		invoke SendMessage,hCtl,CBEM_INSERTITEM,0,addr cbei
		invoke SendMessage,hCtl,CB_SETCURSEL,0,0
		invoke EnumChildWindows,hCtl,addr CtlEnumProc,TRUE
	.elseif eax==26
		invoke SendMessage,[edi].hcld,IPM_SETADDRESS,0,080818283h
	.elseif eax==27
		mov		al,[edi].caption
		.if al
			invoke strcpy,addr buffer,offset ProjectPath
			invoke strcat,addr buffer,addr [edi].caption
			invoke SendMessage,[edi].hcld,ACM_OPEN,0,addr buffer
		.endif
	.elseif eax==28
		invoke SendMessage,hCtl,HKM_SETHOTKEY,(HOTKEYF_CONTROL shl 8) or VK_A,0
	.elseif eax==29 || eax==30
		invoke CreateWindowEx,0,addr szStatic,addr [edi].idname,
		WS_CHILD or WS_VISIBLE or SS_LEFT or WS_CLIPSIBLINGS,
		0,0,[edi].ccx,[edi].ccy,
		hCld,0,hInstance,0
		push	eax
		invoke SendMessage,eax,WM_SETFONT,hFnt,0
		pop		eax
		invoke SendMessage,hCld,PGM_SETCHILD,0,eax
		invoke SendMessage,hCld,PGM_SETBUTTONSIZE,0,10
		invoke SendMessage,hCld,PGM_SETPOS,0,1
		invoke EnumChildWindows,hCtl,addr CtlEnumProc,TRUE
	.elseif tpe==32
		mov		hdi.imask,HDI_TEXT or HDI_WIDTH or HDI_FORMAT
		mov		hdi.lxy,100
		lea		eax,[edi].idname
		mov		hdi.pszText,eax
		mov		hdi.fmt,HDF_STRING
		invoke SendMessage,hCtl,HDM_INSERTITEM,0,addr hdi
	.elseif eax>=NoOfButtons
		call	MakeDummy
		invoke SendMessage,hCtl,WM_USER+9999,0,edi
	.endif
	mov		eax,[edi].hcld
	.if !eax
		mov		eax,[edi].hwnd
	.endif
	invoke SendMessage,eax,WM_SETFONT,hFnt,0
	invoke SetChanged,TRUE,hMdi
	mov		eax,hCtl
	ret

MakeDummy:
	invoke CreateWindowEx,WS_EX_TRANSPARENT,addr DlgEditDummyClass,NULL,WS_CHILD or WS_VISIBLE,0,0,0,0,hCtl,NULL,hInstance,0
	mov		[edi].hdmy,eax
	invoke SetWindowPos,eax,HWND_TOP,0,0,[edi].ccx,[edi].ccy,0
	retn
	assume edi:nothing

CreateCtl endp

CreateNewCtl proc uses esi edi,hOwner:DWORD,nType:DWORD,x:DWORD,y:DWORD,ccx:DWORD,ccy:DWORD

	invoke GetWindowLong,hMdiCld,4
	.if eax
		invoke GetFreeDlg,eax
		mov		edi,eax
		invoke GetTypePtr,nType
		mov		esi,eax
		;Set default ctl data
		mov		(DIALOG ptr [edi]).hdmy,0
		m2m		(DIALOG ptr [edi]).hpar,hOwner
		m2m		(DIALOG ptr [edi]).ntype,nType
		m2m		(DIALOG ptr [edi]).ntypeid,(TYPES ptr [esi]).ID
		m2m		(DIALOG ptr [edi]).style,(TYPES ptr [esi]).style
		m2m		(DIALOG ptr [edi]).exstyle,(TYPES ptr [esi]).exstyle
		m2m		(DIALOG ptr [edi]).x,x
		m2m		(DIALOG ptr [edi]).y,y
		mov		eax,ccx
		.if sdword ptr eax<0
			neg		eax
		.endif
		.if eax<=2
			mov		eax,(TYPES ptr [esi]).wt
			mov		(DIALOG ptr [edi]).ccx,eax
		.else
			m2m		(DIALOG ptr [edi]).ccx,ccx
		.endif
		mov		eax,ccy
		.if sdword ptr eax<0
			neg		eax
		.endif
		.if eax<=2
			mov		eax,(TYPES ptr [esi]).ht
			mov		(DIALOG ptr [edi]).ccy,eax
		.else
			m2m		(DIALOG ptr [edi]).ccy,ccy
		.endif
		invoke lstrcpyn,addr (DIALOG ptr [edi]).idname,(TYPES ptr [esi]).lpidname,32
		invoke lstrcpyn,addr (DIALOG ptr [edi]).caption,(TYPES ptr [esi]).lpcaption,MaxCap
		.if !nType
			m2m		(DIALOG ptr [edi]).id,DlgIDN
			;Set default DLGHEAD info
			mov		esi,edi
			sub		esi,sizeof DLGHEAD
			assume esi:ptr DLGHEAD
			mov		[esi].ver,DLGVER
			m2m		[esi].ctlid,CtrlIDN
			mov		[esi].class,0
			mov		[esi].menuid,0
			invoke strcpy,addr [esi].font,addr lfntdlg.lfFaceName
			invoke GetDC,hWnd
			push	eax
			invoke GetDeviceCaps,eax,LOGPIXELSY
			mov		ecx,eax
			mov		eax,lfntdlg.lfHeight
			.if sdword ptr eax<0
				neg		eax
			.endif
			mov		edx,72
			mul		edx
			div		ecx
			mov		[esi].fontsize,eax
			pop		eax
			invoke ReleaseDC,hWnd,eax
			mov		eax,lfntdlg.lfHeight
			mov		[esi].fontht,eax
			movzx	eax,lfntdlg.lfCharSet
			mov		[esi].charset,al
			movzx	eax,lfntdlg.lfItalic
			mov		[esi].italic,al
			mov		eax,lfntdlg.lfWeight
			mov		[esi].weight,ax
		.else
			invoke GetFreeID
			mov		(DIALOG ptr [edi]).id,eax
			invoke GetFreeTab
			mov		(DIALOG ptr [edi]).tab,eax
		.endif
		assume esi:nothing
		invoke DllProc,hMdiCld,AIM_CREATENEWCTL,hDialog,edi,RAM_CREATENEWCTL
		invoke CreateCtl,edi
	.endif
	ret

CreateNewCtl endp

CopyCtl proc uses esi edi ebx
	LOCAL	hCtl:HWND

	.if hReSize
		invoke GetWindowLong,hReSize,GWL_USERDATA
		.if eax
			mov		esi,eax
			mov		edi,offset dlgpaste
			mov		ecx,sizeof DIALOG
			rep	movsb
			xor		eax,eax
			stosd
		.endif
	.elseif hMultiSel
		mov		edi,offset dlgpaste
		mov		ebx,hMultiSel
		.while ebx
			invoke GetParent,ebx
			mov		hCtl,eax
			mov		eax,8
			.while eax
				push	eax
				invoke GetWindowLong,ebx,GWL_USERDATA
				mov		ebx,eax
				pop		eax
				dec		eax
			.endw
			invoke GetWindowLong,hCtl,GWL_USERDATA
			.if eax
				mov		esi,eax
				mov		ecx,sizeof DIALOG
				rep	movsb
			.endif
		.endw
		xor		eax,eax
		stosd
	.endif
	invoke SendMessage,hMdiCld,WM_LBUTTONDOWN,0,0
	invoke ToolBarStatus
	ret

CopyCtl endp

PasteCtl proc uses esi edi
	LOCAL	hCtl:HWND
	LOCAL	hPar:HWND
	LOCAL	px:DWORD
	LOCAL	py:DWORD
	LOCAL	nbr:DWORD

	mov		nbr,0
	mov		esi,offset dlgpaste
	assume esi:ptr DIALOG
	mov		px,9999
	mov		py,9999
	push	esi
  @@:
	mov		eax,[esi].hwnd
	.if eax
		mov		eax,[esi].x
		.if (px<80000000 && eax<80000000 && eax<px) || (px>80000000 && eax>80000000 && eax<px) || (px<80000000 && eax>80000000)
			mov		px,eax
		.endif
		mov		eax,[esi].y
		.if (py<80000000 && eax<80000000 && eax<py) || (py>80000000 && eax>80000000 && eax<py) || (py<80000000 && eax>80000000)
			mov		py,eax
		.endif
		add		esi,sizeof DIALOG
		jmp		@b
	.endif
	pop		esi
  @@:
	mov		eax,[esi].hwnd
	.if eax
		invoke GetWindowLong,hMdiCld,4
		.if eax
			push	eax
			mov		edx,eax
			mov		edx,[edx].DLGHEAD.ctlid
			add		eax,sizeof DLGHEAD
			m2m		hPar,(DIALOG ptr [eax]).hwnd
			m2m		[esi].hpar,hPar
			mov		[esi].id,edx
			invoke IsFreeID,edx
			.if eax==FALSE
				invoke GetFreeID
				mov		[esi].id,eax
			.endif
			pop		eax
			invoke GetFreeDlg,eax
			mov		edi,eax
			push	esi
			push	eax
			mov		ecx,sizeof DIALOG
			rep	movsb
			pop		esi
			mov		eax,px
			sub		[esi].x,eax
			mov		eax,py
			sub		[esi].y,eax
			mov		[esi].himg,0
			invoke GetTypePtr,[esi].ntype
			invoke lstrcpyn,addr [esi].idname,(TYPES ptr [eax]).lpidname,32
			invoke DllProc,hMdiCld,AIM_CREATENEWCTL,hDialog,esi,RAM_CREATENEWCTL
			invoke CreateCtl,esi
			mov		hCtl,eax
			mov		[esi].tab,-1
			invoke GetFreeTab
			mov		[esi].tab,eax
			invoke SizeingRect,hCtl,FALSE
			invoke SetChanged,TRUE,0
			pop		esi
			m2m		[esi].hwnd,hCtl
			add		esi,sizeof DIALOG
			inc		nbr
			jmp		@b
		.endif
	.endif
	.if nbr>1
		invoke DestroySizeingRect
		mov		esi,offset dlgpaste
		.while nbr
			.if hMultiSel
				invoke GetParent,hMultiSel
				push	eax
				invoke DestroyMultiSel,hMultiSel
				mov		hMultiSel,eax
				pop		eax
				invoke MultiSelRect,eax,TRUE
			.endif
			mov		eax,[esi].hwnd
			invoke MultiSelRect,eax,FALSE
			add		esi,sizeof DIALOG
			dec		nbr
		.endw
	.endif
	assume esi:nothing
	ret

PasteCtl endp

DeleteCtl proc uses esi
	LOCAL	hCtl:HWND

	.if hReSize
		invoke GetWindowLong,hReSize,GWL_USERDATA
		.if eax
			mov		esi,eax
			assume esi:ptr DIALOG
			mov		eax,[esi].ntype
			;Don't delete DialogBox
			.if eax
				invoke GetWindowLong,hMdiCld,4
				mov		edx,eax
				mov		eax,(DLGHEAD ptr [edx]).undo
				mov		[esi].undo,eax
				mov		(DLGHEAD ptr [edx]).undo,esi
				mov		[esi].hwnd,-1
				invoke DeleteTab,[esi].tab
				mov		eax,[esi].himg
				.if eax
					invoke DeleteObject,eax
					mov		[esi].himg,0
				.endif
				.if [esi].hcld
					invoke GetStockObject,SYSTEM_FONT
					invoke SendMessage,[esi].hcld,WM_SETFONT,eax,0
					invoke DestroyWindow,[esi].hcld
				.endif
				invoke GetStockObject,SYSTEM_FONT
				invoke SendMessage,hReSize,WM_SETFONT,eax,0
				invoke DestroyWindow,hReSize
				invoke DestroySizeingRect
				invoke SetChanged,TRUE,0
				invoke SizeingRect,hDialog,FALSE
			.endif
			assume esi:nothing
		.endif
	.elseif hMultiSel
		.while hMultiSel
			invoke GetParent,hMultiSel
			mov		hCtl,eax
			mov		eax,8
			.while eax
				push	eax
				invoke GetWindowLong,hMultiSel,GWL_USERDATA
				push	eax
				invoke DestroyWindow,hMultiSel
				pop		eax
				mov		hMultiSel,eax
				pop		eax
				dec		eax
			.endw
			invoke GetWindowLong,hCtl,GWL_USERDATA
			.if eax
				mov		esi,eax
				assume esi:ptr DIALOG
				mov		eax,[esi].ntype
				;Don't delete DialogBox
				.if eax
					invoke GetWindowLong,hMdiCld,4
					push	(DLGHEAD ptr [eax]).undo
					mov		(DLGHEAD ptr [eax]).undo,esi
					mov		[esi].hwnd,-1
					pop		[esi].undo
					invoke DeleteTab,[esi].tab
					mov		eax,[esi].himg
					.if eax
						invoke DeleteObject,eax
						mov		[esi].himg,0
					.endif
					.if [esi].hcld
						invoke GetStockObject,SYSTEM_FONT
						invoke SendMessage,[esi].hcld,WM_SETFONT,eax,0
						invoke DestroyWindow,[esi].hcld
					.endif
					invoke GetStockObject,SYSTEM_FONT
					invoke SendMessage,hCtl,WM_SETFONT,eax,0
					invoke DestroyWindow,hCtl
				.endif
				assume esi:nothing
			.endif
		.endw
		invoke SetChanged,TRUE,0
		invoke SizeingRect,hDialog,FALSE
	.endif
	invoke SendMessage,hMdiCld,WM_LBUTTONDOWN,0,0
	ret

DeleteCtl endp

UndoCtl proc uses esi
	LOCAL	hCtl:HWND
	LOCAL	nTab:DWORD

	invoke GetWindowLong,hMdiCld,4
	.if eax
		mov		esi,eax
		mov		eax,(DLGHEAD ptr[esi]).undo
		.if eax
			m2m		(DLGHEAD ptr[esi]).undo,(DIALOG ptr [eax]).undo
			mov		(DIALOG ptr [eax]).undo,0
			mov		esi,eax
			mov		eax,(DIALOG ptr [esi]).id
			invoke IsFreeID,eax
			.if eax==FALSE
				invoke GetFreeID
				mov		(DIALOG ptr [esi]).id,eax
			.endif
			invoke CreateCtl,esi
			mov		hCtl,eax
			invoke GetWindowLong,hCtl,GWL_USERDATA
			mov		esi,eax
			m2m		nTab,(DIALOG ptr [esi]).tab
			invoke InsertTab,nTab
			m2m		(DIALOG ptr [esi]).tab,nTab
			invoke SizeingRect,hCtl,FALSE
		.endif
	.endif
	ret

UndoCtl endp

AlignSizeCtl proc uses esi ebx,nFun:DWORD
	LOCAL	xp:DWORD
	LOCAL	yp:DWORD
	LOCAL	wt:DWORD
	LOCAL	ht:DWORD
	LOCAL	hCtl:HWND
	LOCAL	fChanged:DWORD
	LOCAL	xpmin:DWORD
	LOCAL	ypmin:DWORD
	LOCAL	xpmax:DWORD
	LOCAL	ypmax:DWORD
	LOCAL	rect:RECT

	mov		ebx,hMultiSel
	.if ebx
		mov		eax,nFun
		.if eax==IDM_FORMAT_CENTER_HOR || eax==IDM_FORMAT_CENTER_VER
			mov		xpmin,99999
			mov		ypmin,99999
			mov		xpmax,-99999
			mov		ypmax,-99999
			.while ebx
				invoke GetParent,ebx
				invoke GetWindowLong,eax,GWL_USERDATA
				mov		esi,eax
				assume esi:ptr DIALOG
				mov		eax,[esi].x
				.if sdword ptr eax<xpmin
					mov		xpmin,eax
				.endif
				add		eax,[esi].ccx
				.if sdword ptr eax>xpmax
					mov		xpmax,eax
				.endif
				mov		eax,[esi].y
				.if sdword ptr eax<ypmin
					mov		ypmin,eax
				.endif
				add		eax,[esi].ccy
				.if sdword ptr eax>ypmax
					mov		ypmax,eax
				.endif
				mov		ecx,8
				.while ecx
					push	ecx
					invoke GetWindowLong,ebx,GWL_USERDATA
					mov		ebx,eax
					pop		ecx
					dec		ecx
				.endw
			.endw
			mov		ebx,hMultiSel
			invoke GetParent,ebx
			invoke GetParent,eax
			mov		edx,eax
			invoke GetClientRect,edx,addr rect
			mov		eax,xpmax
			sub		eax,xpmin
			mov		edx,rect.right
			sub		edx,eax
			shr		edx,1
			sub		xpmin,edx
			mov		eax,ypmax
			sub		eax,ypmin
			mov		edx,rect.bottom
			sub		edx,eax
			shr		edx,1
			sub		ypmin,edx
			.while ebx
				mov		fChanged,FALSE
				invoke GetParent,ebx
				mov		hCtl,eax
				invoke GetWindowLong,hCtl,GWL_USERDATA
				mov		esi,eax
				mov		eax,nFun
				.if eax==IDM_FORMAT_CENTER_VER
					mov		eax,ypmin
					.if eax
						sub		[esi].y,eax
						inc		fChanged
					.endif
				.elseif eax==IDM_FORMAT_CENTER_HOR
					mov		eax,xpmin
					.if eax
						sub		[esi].x,eax
						inc		fChanged
					.endif
				.endif
				call	SnapGrid
				call	ChangeIt
				mov		ecx,8
				.while ecx
					push	ecx
					invoke GetWindowLong,ebx,GWL_USERDATA
					mov		ebx,eax
					pop		ecx
					dec		ecx
				.endw
			.endw
		.else
			invoke GetParent,ebx
			invoke GetWindowLong,eax,GWL_USERDATA
			mov		esi,eax
			assume esi:ptr DIALOG
			mov		eax,[esi].x
			mov		xp,eax
			mov		eax,[esi].y
			mov		yp,eax
			mov		eax,[esi].ccx
			mov		wt,eax
			mov		eax,[esi].ccy
			mov		ht,eax
			.while ebx
				mov		fChanged,FALSE
				invoke GetParent,ebx
				mov		hCtl,eax
				invoke GetWindowLong,hCtl,GWL_USERDATA
				mov		esi,eax
				mov		eax,nFun
				.if eax==IDM_FORMAT_ALIGN_LEFT
					mov		eax,xp
					.if eax!=[esi].x
						mov		[esi].x,eax
						inc		fChanged
					.endif
				.elseif eax==IDM_FORMAT_ALIGN_CENTER
					mov		eax,wt
					shr		eax,1
					add		eax,xp
					mov		edx,[esi].ccx
					shr		edx,1
					add		edx,[esi].x
					sub		eax,edx
					.if eax
						add		[esi].x,eax
						inc		fChanged
					.endif
				.elseif eax==IDM_FORMAT_ALIGN_RIGHT
					mov		eax,xp
					add		eax,wt
					sub		eax,[esi].ccx
					.if eax!=[esi].x
						mov		[esi].x,eax
						inc		fChanged
					.endif
				.elseif eax==IDM_FORMAT_ALIGN_TOP
					mov		eax,yp
					.if eax!=[esi].y
						mov		[esi].y,eax
						inc		fChanged
					.endif
				.elseif eax==IDM_FORMAT_ALIGN_MIDDLE
					mov		eax,ht
					shr		eax,1
					add		eax,yp
					mov		edx,[esi].ccy
					shr		edx,1
					add		edx,[esi].y
					sub		eax,edx
					.if eax
						add		[esi].y,eax
						inc		fChanged
					.endif
				.elseif eax==IDM_FORMAT_ALIGN_BOTTOM
					mov		eax,yp
					add		eax,ht
					sub		eax,[esi].ccy
					.if eax!=[esi].y
						mov		[esi].y,eax
						inc		fChanged
					.endif
				.elseif eax==IDM_FORMAT_SIZE_WIDTH
					mov		eax,wt
					.if eax!=[esi].ccx
						mov		[esi].ccx,eax
						inc		fChanged
					.endif
				.elseif eax==IDM_FORMAT_SIZE_HEIGHT
					mov		eax,ht
					.if eax!=[esi].ccy
						mov		[esi].ccy,eax
						inc		fChanged
					.endif
				.elseif eax==IDM_FORMAT_SIZE_BOTH
					mov		eax,wt
					.if eax!=[esi].ccx
						mov		[esi].ccx,eax
						inc		fChanged
					.endif
					mov		eax,ht
					.if eax!=[esi].ccy
						mov		[esi].ccy,eax
						inc		fChanged
					.endif
				.endif
				call	SnapGrid
				call	ChangeIt
				mov		ecx,8
				.while ecx
					push	ecx
					.if ecx==8
						mov		eax,[esi].ccx
						sub		eax,6
						mov		edx,[esi].ccy
						sub		edx,6
					.elseif ecx==7
						mov		eax,[esi].ccx
						shr		eax,1
						sub		eax,3
						mov		edx,[esi].ccy
						sub		edx,6
					.elseif ecx==6
						xor		eax,eax
						mov		edx,[esi].ccy
						sub		edx,6
					.elseif ecx==5
						mov		eax,[esi].ccx
						sub		eax,6


						mov		edx,[esi].ccy
						shr		edx,1
						sub		edx,3
					.elseif ecx==4
						xor		eax,eax
						mov		edx,[esi].ccy
						shr		edx,1
						sub		edx,3
					.elseif ecx==3
						mov		eax,[esi].ccx
						sub		eax,6
						xor		edx,edx
					.elseif ecx==2
						mov		eax,[esi].ccx
						shr		eax,1
						sub		eax,3
						xor		edx,edx
					.elseif ecx==1
						xor		eax,eax
						xor		edx,edx
					.endif
					invoke MoveWindow,ebx,eax,edx,6,6,TRUE
					invoke GetWindowLong,ebx,GWL_USERDATA
					mov		ebx,eax
					pop		ecx
					dec		ecx
				.endw
			.endw
		.endif
	.elseif hReSize
		;Single select
		mov		eax,nFun
		.if eax==IDM_FORMAT_CENTER_HOR || eax==IDM_FORMAT_CENTER_VER
			mov		eax,hReSize
			mov		hCtl,eax
			invoke GetWindowLong,hCtl,GWL_USERDATA
			mov		esi,eax
			assume esi:ptr DIALOG
			mov		eax,[esi].x
			mov		xpmin,eax
			mov		eax,[esi].y
			mov		ypmin,eax
			mov		eax,[esi].ccx
			add		eax,[esi].x
			mov		xpmax,eax
			mov		eax,[esi].ccy
			add		eax,[esi].y
			mov		ypmax,eax
			invoke GetParent,hCtl
			mov		edx,eax
			invoke GetClientRect,edx,addr rect
			mov		eax,xpmax
			sub		eax,xpmin
			mov		edx,rect.right
			sub		edx,eax
			shr		edx,1
			sub		xpmin,edx
			mov		eax,ypmax
			sub		eax,ypmin
			mov		edx,rect.bottom
			sub		edx,eax
			shr		edx,1
			sub		ypmin,edx
			mov		eax,nFun
			.if eax==IDM_FORMAT_CENTER_VER
				mov		eax,ypmin
				.if eax
					sub		[esi].y,eax
					inc		fChanged
				.endif
			.elseif eax==IDM_FORMAT_CENTER_HOR
				mov		eax,xpmin
				.if eax
					sub		[esi].x,eax
					inc		fChanged
				.endif
			.endif
			call	SnapGrid
			call	ChangeIt
			invoke DestroySizeingRect
			invoke SizeingRect,hCtl,FALSE
		.endif
	.endif
	ret

ChangeIt:
	.if fChanged
		invoke MoveWindow,hCtl,[esi].x,[esi].y,[esi].ccx,[esi].ccy,TRUE
		mov		eax,[esi].hcld
		.if eax
			invoke MoveWindow,eax,0,0,[esi].ccx,[esi].ccy,TRUE
		.endif
		invoke SetChanged,TRUE,hMdiCld
	.endif
	retn

SnapGrid:
	.if fSnapToGrid
		mov		eax,[esi].x
		xor		edx,edx
		idiv	Gridcx
		imul	Gridcx
		.if eax!=[esi].x
			mov		[esi].x,eax
			inc		fChanged
		.endif
		mov		eax,[esi].ccx
		add		eax,[esi].x
		xor		edx,edx
		idiv	Gridcx
		imul	Gridcx
		sub		eax,[esi].x
		inc		eax
		.if eax!=[esi].ccx
			mov		[esi].ccx,eax
			inc		fChanged
		.endif
		mov		eax,[esi].y
		xor		edx,edx
		idiv	Gridcy
		imul	Gridcy
		.if eax!=[esi].y
			mov		[esi].y,eax
			inc		fChanged
		.endif
		mov		eax,[esi].ccy
		add		eax,[esi].y
		xor		edx,edx
		idiv	Gridcy
		imul	Gridcy
		sub		eax,[esi].y
		inc		eax
		.if eax!=[esi].ccy
			mov		[esi].ccy,eax
			inc		fChanged
		.endif
	.endif
	retn

AlignSizeCtl endp

UpdateCtl proc uses esi,hCtl:DWORD
	LOCAL	ws:DWORD

	invoke GetWindowLong,hCtl,GWL_USERDATA
	mov		esi,eax
	assume esi:ptr DIALOG
	.if [esi].ntype
		mov		eax,[esi].himg
		.if eax
			invoke DeleteObject,eax
			mov		[esi].himg,0
		.endif
		.if [esi].hcld
			invoke GetStockObject,SYSTEM_FONT
			invoke SendMessage,[esi].hcld,WM_SETFONT,eax,0
			invoke DestroyWindow,[esi].hcld
		.endif
		invoke GetStockObject,SYSTEM_FONT
		invoke SendMessage,hCtl,WM_SETFONT,eax,0
		invoke DestroyWindow,hCtl
		invoke CreateCtl,esi
		mov		hCtl,eax
	  @@:
		add		esi,sizeof DIALOG
		mov		eax,[esi].hwnd
		cmp		eax,-1
		je		@b
		.if eax
			invoke SetWindowPos,hCtl,eax,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE
		.endif
	.else
		push	[esi].style
		pop		ws
		or		ws,WS_ALWAYS
		and		ws,-1 xor (WS_POPUP or WS_DISABLED or WS_MINIMIZE or WS_MAXIMIZE)
		invoke SetWindowLong,hCtl,GWL_STYLE,ws
		invoke SetWindowLong,hCtl,GWL_EXSTYLE,[esi].exstyle
		invoke SetWindowText,hCtl,addr [esi].caption
		invoke SetWindowPos,hCtl,0,0,0,[esi].ccx,[esi].ccy,SWP_NOMOVE or SWP_NOZORDER or SWP_FRAMECHANGED
	.endif
	invoke UpdateWindow,hCtl
	.if !fSizeing
		invoke SizeingRect,hCtl,FALSE
	.else
		m2m		hReSize,hCtl
	.endif
	invoke SetChanged,TRUE,0
	mov		eax,hCtl
	assume esi:nothing
	ret

UpdateCtl endp

MoveMultiSel proc uses esi,x:DWORD,y:DWORD

	mov		eax,hMultiSel
	.while eax
		push	eax
		invoke GetParent,eax
		push	eax
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		esi,eax
		.if x
			mov		eax,(DIALOG ptr [esi]).x
			add		eax,x
			xor		edx,edx
			idiv	x
			imul	x
			mov		(DIALOG ptr [esi]).x,eax
		.endif
		.if y
			mov		eax,(DIALOG ptr [esi]).y
			add		eax,y
			xor		edx,edx
			idiv	y
			imul	y
			mov		(DIALOG ptr [esi]).y,eax
		.endif
		pop		eax
		invoke MoveWindow,eax,(DIALOG ptr [esi]).x,(DIALOG ptr [esi]).y,(DIALOG ptr [esi]).ccx,(DIALOG ptr [esi]).ccy,TRUE
		mov		ecx,8
		pop		eax
		.while ecx
			push	ecx
			invoke GetWindowLong,eax,GWL_USERDATA
			pop		ecx
			dec		ecx
		.endw
	.endw
	invoke SetChanged,TRUE,0
	ret

MoveMultiSel endp

SendToBack proc uses esi edi,hCtl:HWND
	LOCAL	buffer[512]:BYTE
	LOCAL	lpSt:DWORD
	LOCAL	lpFirst:DWORD

	invoke GetWindowLong,hDialog,GWL_USERDATA
	add		eax,sizeof DIALOG
	mov		lpFirst,eax
	invoke GetWindowLong,hCtl,GWL_USERDATA
	mov		lpSt,eax
	mov		esi,eax
	lea		edi,buffer
	mov		ecx,sizeof DIALOG
	rep movsb
	mov		esi,lpSt
  @@:
	mov		edi,esi
	mov		ecx,sizeof DIALOG
	sub		esi,ecx
	mov		eax,(DIALOG ptr [esi]).undo
	.if eax<=lpSt && eax
		add		(DIALOG ptr [esi]).undo,sizeof DIALOG
	.endif
	rep movsb
	sub		esi,sizeof DIALOG
	cmp		esi,lpFirst
	jge		@b
	lea		esi,buffer
	mov		edi,lpFirst
	mov		ecx,sizeof DIALOG
	rep movsb
	invoke UpdateDialog,hDialog
	invoke GetWindowLong,hMdiCld,4
	mov		esi,eax
	mov		eax,(DLGHEAD ptr [esi]).undo
	.if eax<=lpSt && eax
		add		(DLGHEAD ptr [esi]).undo,sizeof DIALOG
	.endif
	invoke SetChanged,TRUE,0
	ret

SendToBack endp

BringToFront proc uses esi edi,hCtl:HWND
	LOCAL	buffer[512]:BYTE
	LOCAL	lpSt:DWORD

	invoke GetWindowLong,hCtl,GWL_USERDATA
	mov		lpSt,eax
	mov		esi,eax
	lea		edi,buffer
	mov		ecx,sizeof DIALOG
	rep movsb
	mov		edi,esi
	sub		edi,sizeof DIALOG
  @@:
	mov		eax,(DIALOG ptr [esi]).undo
	.if eax>lpSt
		sub		(DIALOG ptr [esi]).undo,sizeof DIALOG
	.endif
	mov		ecx,sizeof DIALOG
	rep movsb
	mov		eax,dword ptr [esi]
	or		eax,eax
	jne		@b
	lea		esi,buffer
	mov		ecx,sizeof DIALOG
	rep movsb
	invoke UpdateDialog,hDialog
	invoke GetWindowLong,hMdiCld,4
	mov		esi,eax
	mov		eax,(DLGHEAD ptr [esi]).undo
	.if eax>lpSt
		sub		(DLGHEAD ptr [esi]).undo,sizeof DIALOG
	.endif
	invoke SetChanged,TRUE,0
	ret

BringToFront endp

DrawingRect proc hWin:HWND,lParam:LPARAM,nFun:DWORD
	LOCAL	pt:POINT
	LOCAL	hPar:DWORD

	mov		eax,lParam
	and		eax,0FFFFh
	cwde
	mov		pt.x,eax
	mov		eax,lParam
	shr		eax,16
	cwde
	mov		pt.y,eax
	.if fSnapToGrid
		mov		eax,pt.x
		xor		edx,edx
		idiv	Gridcx
		imul	Gridcx
		mov		pt.x,eax
		mov		eax,pt.y
		xor		edx,edx
		idiv	Gridcy
		imul	Gridcy
		mov		pt.y,eax
	.endif
	.if nFun==0
		invoke FindParent,hWin
		mov		hPar,eax
		mov		fDrawing,TRUE
		invoke SetCapture,hWin
		invoke ClientToScreen,hWin,addr pt
		mov		eax,pt.x
		mov		MousePtDown.x,eax
		mov		CtlRect.left,eax
		mov		CtlRect.right,eax
		mov		eax,pt.y
		mov		MousePtDown.y,eax
		mov		CtlRect.top,eax
		mov		CtlRect.bottom,eax
		mov		fNoParent,TRUE
		invoke DlgDrawRect,hWin,addr CtlRect,0,0
		mov		fNoParent,FALSE
		invoke CopyRect,addr SizeRect,addr CtlRect
	.elseif nFun==1
		invoke LoadCursor,0,IDC_CROSS
		invoke SetCursor,eax
		.if fDrawing
			.if fSnapToGrid
				inc		pt.x
				inc		pt.y
			.endif
			invoke ClientToScreen,hWin,addr pt
			mov		eax,pt.x
			sub		eax,MousePtDown.x
			mov		pt.x,eax
			mov		eax,pt.y
			sub		eax,MousePtDown.y
			mov		pt.y,eax
			invoke CopyRect,addr SizeRect,addr CtlRect
			mov		eax,pt.x
			add		SizeRect.right,eax
			mov		eax,pt.y
			add		SizeRect.bottom,eax
			invoke DlgDrawRect,hWin,addr SizeRect,1,0
			invoke DialogTltSize,pt.x,pt.y
		.endif
	.elseif nFun==2
		invoke FindParent,hWin

		mov		hPar,eax
		mov		fDrawing,FALSE
		invoke DlgDrawRect,hWin,addr SizeRect,2,0
		mov		ParPt.x,0
		mov		ParPt.y,0
		invoke ClientToScreen,hPar,addr ParPt
		mov		eax,ParPt.x
		sub		SizeRect.left,eax
		sub		SizeRect.right,eax
		mov		eax,ParPt.y
		sub		SizeRect.top,eax
		sub		SizeRect.bottom,eax
		mov		eax,SizeRect.left
		.if sdword ptr eax>SizeRect.right
			xchg	eax,SizeRect.right
			mov		SizeRect.left,eax
		.endif
		sub		SizeRect.right,eax
		mov		eax,SizeRect.top
		.if sdword ptr eax>SizeRect.bottom
			xchg	eax,SizeRect.bottom
			mov		SizeRect.top,eax
		.endif
		sub		SizeRect.bottom,eax
		invoke ReleaseCapture
		mov		eax,ToolBoxID
		.if eax>=1 && eax<nButtons
			invoke CreateNewCtl,hPar,eax,SizeRect.left,SizeRect.top,SizeRect.right,SizeRect.bottom
			.if eax
				invoke SizeingRect,eax,FALSE
			.endif
			invoke ToolBoxReset
		.endif
		invoke ShowWindow,hTlt,SW_HIDE
	.endif
	ret

DrawingRect endp

GetMnuString proc uses esi edi,hWin:HWND,lpFileName:DWORD,lpBuff:DWORD
	LOCAL	buffer[256]:BYTE

	invoke GetFileImg,lpFileName
	.if eax==6
		invoke strcpy,addr buffer,addr FileName
;		invoke GetParent,hWin
;		mov		edx,eax
;		invoke GetWindowText,edx,addr FileName,sizeof FileName
;		.if !eax
;			invoke strcpy,addr FileName,addr buffer
;			jmp		Ex
;		.endif
;		invoke iniRStripStr,addr FileName,'\'
;		invoke strcat,addr FileName,addr szBackSlash
		invoke strcpy,addr FileName,addr ProjectPath
		invoke strcat,addr FileName,lpFileName
		invoke CreateMnu,3
		.if eax
			mov		esi,eax
			push	esi
			mov		edi,lpBuff
			mov		byte ptr [edi],0
			add		esi,sizeof MNUHEAD
		  @@:
			mov		eax,(MNUITEM ptr [esi]).itemflag
			.if eax
				mov		eax,(MNUITEM ptr [esi]).level
				.if !eax
					.if edi!=lpBuff
						mov		byte ptr [edi],','
						inc		edi
					.endif
					mov		byte ptr [edi],' '
					inc		edi
					mov		byte ptr [edi],' '
					inc		edi
					invoke strcpy,edi,addr (MNUITEM ptr [esi]).itemcaption
					invoke strlen,edi
					add		edi,eax
					mov		byte ptr [edi],' '
					inc		edi
					mov		byte ptr [edi],' '
					inc		edi
					mov		byte ptr [edi],0
				.endif
				add		esi,sizeof MNUITEM
				jmp		@b
			.endif
			pop		esi
			invoke GlobalUnlock,esi
			invoke GlobalFree,esi
			invoke strcpy,addr FileName,addr buffer
		.else
			invoke strcpy,addr FileName,addr buffer
			invoke strcpy,lpBuff,addr szMnu
		.endif
	.else
  Ex:
		invoke strcpy,lpBuff,addr szMnu
	.endif
	ret

GetMnuString endp

MakeGridBrush proc uses ebx edi
	LOCAL	hDC:HDC
	LOCAL	bicx:DWORD
	LOCAL	bicy:DWORD
	LOCAL	hBit:DWORD
	LOCAL	bi:BITMAPINFO
	LOCAL	pBits:DWORD
;	LOCAL	nCol:DWORD

	.if hGridBr
		invoke DeleteObject,hGridBr
	.endif
	invoke CreateCompatibleDC,NULL
	mov		hDC,eax
	mov		eax,Gridcx
	mov		bicx,eax
	.while bicx<8
		add		bicx,eax
	.endw
	mov		eax,Gridcy
	mov		bicy,eax
	.while bicy<8
		add		bicy,eax
	.endw
	mov		bi.bmiHeader.biSize,sizeof BITMAPINFOHEADER
	m2m		bi.bmiHeader.biWidth,bicx
	m2m		bi.bmiHeader.biHeight,bicy
	mov		bi.bmiHeader.biPlanes,1
	mov		bi.bmiHeader.biBitCount,32
	mov		bi.bmiHeader.biCompression,BI_RGB
	mov		bi.bmiHeader.biXPelsPerMeter,0
	mov		bi.bmiHeader.biYPelsPerMeter,0
	mov		bi.bmiHeader.biClrUsed,0
	mov		bi.bmiHeader.biClrImportant,0
	mov		bi.bmiColors.rgbBlue,0
	mov		bi.bmiColors.rgbGreen,0
	mov		bi.bmiColors.rgbRed,0
	mov		bi.bmiColors.rgbReserved,0
	invoke CreateDIBSection,hDC,addr bi,DIB_RGB_COLORS,addr pBits,0,0
	mov		hBit,eax
	invoke GetSysColor,COLOR_BTNFACE
	xchg	al,ah	;ABDC
	ror		eax,16	;DCAB
	xchg	al,ah	;DCBA
	ror		eax,8	;ADCB
	mov		edx,bi.bmiHeader.biWidth
	mov		ecx,bi.bmiHeader.biHeight
	imul	ecx,edx						; total pixel count
	mov		edi,pBits
	shl		edx,2						; bytes per line
	rep stosd							; fill bitmap with COLOR_BTNFACE
	mov		ecx,Gridcy
	sub		edi,edx						; start on last line
	imul	ecx,edx
	shr		edx,2						; pixels per line
	mov		ebx,GridColor
	xchg	bl,bh	;ABDC
	ror		ebx,16	;DCAB
	xchg	bl,bh	;DCBA
	ror		ebx,8	;ADCB
	.if fGridLine
		push	edi
		.while edi>pBits
			mov		eax,edx
		@@:	dec		eax							; next horizontal dot in grid
			mov		dword ptr [edi+eax*4],ebx	; pixel for grid dot
			jne		@b
			sub		edi,ecx
		.endw
		pop		edi
		lea		ecx,[edx*4]
		.while edi>pBits
			sub		edi,ecx
			mov		eax,edx
		@@:	mov		dword ptr [edi+eax*4],ebx	; pixel for grid dot
			sub		eax,Gridcx					; next horizontal dot in grid
			jns		@b
		.endw
	.else
		.while edi>pBits
			mov		eax,edx
		@@:	sub		eax,Gridcx					; next horizontal dot in grid
			mov		dword ptr [edi+eax*4],ebx	; pixel for grid dot
			jg		@b
			sub		edi,ecx
		.endw
	.endif
	invoke CreatePatternBrush,hBit
	mov		hGridBr,eax
	invoke DeleteObject,hBit
	invoke DeleteDC,hDC
	ret

MakeGridBrush endp

EditDlgProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	rect:RECT
	LOCAL	rect1:RECT
	LOCAL	ws:DWORD
	LOCAL	wsex:DWORD
	LOCAL	ps:PAINTSTRUCT
	LOCAL	ptW:POINT
	LOCAL	buffer[512]:BYTE
	LOCAL	buffer1[64]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	nInx:DWORD

	mov		eax,uMsg
	.if eax==WM_NCCALCSIZE
		.if wParam==TRUE
			invoke GetWindowLong,hWin,GWL_USERDATA
			sub		eax,sizeof DLGHEAD
			mov		esi,eax
			mov		al,(DLGHEAD ptr [esi]).menuid
			.if al
				mov		esi,lParam
				add		(RECT ptr [esi]).top,19
			.endif
		.endif
	.elseif eax==WM_NCPAINT
		mov		MnuHigh,0
		invoke GetWindowLong,hWin,GWL_USERDATA
		sub		eax,sizeof DLGHEAD
		mov		esi,eax
		mov		al,(DLGHEAD ptr [esi]).menuid
		.if al
			mov		nInx,0
			invoke GetMnuString,hWin,addr (DLGHEAD ptr [esi]).menuid,addr buffer
			invoke GetWindowDC,hWin
			mov		hDC,eax
			invoke CreateCompatibleDC,hDC
			mov		mDC,eax
			invoke SetBkMode,mDC,TRANSPARENT
			invoke SetTextColor,mDC,0h
			invoke GetWindowRect,hWin,addr rect
			invoke CopyRect,addr rect1,addr rect
			invoke GetWindowLong,hWin,GWL_STYLE
			mov		ws,eax
			invoke GetWindowLong,hWin,GWL_EXSTYLE
			mov		wsex,eax
			invoke AdjustWindowRectEx,addr rect1,ws,FALSE,wsex
			mov		eax,rect.top
			sub		eax,rect1.top
			mov		rect.top,eax
			add		eax,19
			mov		rect.bottom,eax
			mov		eax,rect.left
			sub		rect.right,eax
			sub		eax,rect1.left
			mov		rect.left,eax
			sub		rect.right,eax

			mov		rect1.left,0
			mov		rect1.top,0
			mov		eax,rect.right
			sub		eax,rect.left
			mov		rect1.right,eax
			mov		edx,rect.bottom
			sub		edx,rect.top
			mov		rect1.bottom,edx
			invoke CreateCompatibleBitmap,hDC,eax,edx
			invoke SelectObject,mDC,eax
			push	eax
			invoke GetStockObject,DEFAULT_GUI_FONT
			invoke SelectObject,mDC,eax
			push	eax
			invoke FillRect,mDC,addr rect1,COLOR_BTNFACE+1
			push	rect1.right
		  @@:
			invoke iniGetItem,addr buffer,addr buffer1
			mov		al,buffer1
			.if al
				lea		esi,buffer1
				call	DrawMnu
				inc		nInx
				jmp		@b
			.endif
			pop		rect1.right
			invoke BitBlt,hDC,rect.left,rect.top,rect1.right,rect1.bottom,mDC,0,0,SRCCOPY
			pop		eax
			invoke SelectObject,mDC,eax
			pop		eax
			invoke SelectObject,mDC,eax
			invoke DeleteObject,eax
			invoke DeleteDC,mDC
			invoke ReleaseDC,hWin,hDC
		.endif
	.elseif eax==WM_PAINT
		invoke BeginPaint,hWin,addr ps
		invoke GetClientRect,hWin,addr rect
		.if fGrid
			mov		eax,hGridBr
		.else
			mov		eax,COLOR_BTNFACE+1
		.endif
		invoke FillRect,ps.hdc,addr rect,eax
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
		ret
	.elseif eax==WM_MOUSEWHEEL
		invoke GetParent,hWin
		invoke PostMessage,eax,uMsg,wParam,lParam
		xor		eax,eax
		ret
	.endif
	invoke	DefWindowProc,hWin,uMsg,wParam,lParam
	ret

  DrawMnu:

	push	esi
	push	edi
	lea		edi,buffer2
	dec		esi
  @@:
	inc		esi
	mov		al,[esi]
	cmp		al,'&'
	je		@b
	mov		[edi],al
	inc		edi
	or		al,al
	jne		@b
	pop		edi
	lea		esi,buffer2
	invoke strlen,esi
	mov		ebx,eax
	invoke GetTextExtentPoint32,mDC,esi,ebx,addr ptW
	pop		esi

	mov		eax,ptW.x
	add		eax,rect1.left
	mov		rect1.right,eax

	mov		eax,rect1.left
	xor		edx,edx
	.if eax<MnuPtx
		add		eax,ptW.x
		.if eax>MnuPtx
			inc		edx
		.endif
	.endif
	.if edx
		mov		eax,rect1.bottom
		add		eax,rect.top
		dec		eax
		shl		eax,16
		add		eax,rect1.left
		add		eax,rect.left
		dec		eax
		mov		MnuHigh,eax
		m2m		MnuInx,nInx
		invoke GetSystemMetrics,SM_SWAPBUTTON
		.if eax
			mov		eax,VK_RBUTTON
		.else
			mov		eax,VK_LBUTTON
		.endif
		invoke GetAsyncKeyState,eax
		and		eax,8000h
		.if eax
			mov		eax,BDR_SUNKENOUTER
		.else
			mov		eax,BDR_RAISEDINNER
		.endif
		dec		rect1.bottom
		invoke DrawEdge,mDC,addr rect1,eax,BF_RECT
		inc		rect1.bottom
	.endif
	invoke strlen,esi
	mov		ebx,eax
	add		rect1.top,2
	invoke DrawText,mDC,esi,ebx,addr rect1,DT_VCENTER
	sub		rect1.top,2
	mov		eax,rect1.right
	mov		rect1.left,eax
	mov		MnuRight,eax
	retn

EditDlgProc endp

SaveHexVal proc pVal:DWORD,fComma:DWORD

	push	esi
	push	edi
	mov		al,'0'
	stosb
	mov		al,'x'
	stosb
	mov		eax,pVal
	invoke hexEax
	invoke strcpy,edi,addr strHex
	pop		edi
	pop		esi
	add		edi,10
	.if fComma
		mov		al,','
		stosb
	.endif
	ret

SaveHexVal endp

SaveVal proc pVal:DWORD,fComma:DWORD
	LOCAL	buffer[16]:BYTE

	push	esi
	push	edi
	invoke BinToDec,pVal,addr buffer
	invoke strcpy,edi,addr buffer
	invoke strlen,addr buffer
	pop		edi
	pop		esi
	add		edi,eax
	.if fComma
		mov		al,','
		stosb
	.endif
	ret

SaveVal endp

SaveStr proc uses ecx esi edi,lpDest:DWORD,lpSrc:DWORD

	mov		esi,lpSrc
	mov		edi,lpDest
	dec		esi
	dec		edi
	mov		ecx,-1
  @@:
	inc		ecx
	inc		esi
	inc		edi
	mov		al,[esi]
	mov		[edi],al
	or		al,al
	jne		@b
	mov		eax,ecx
	ret

SaveStr endp

SaveCtlSize proc uses ebx edx esi
	LOCAL	rect:RECT
	LOCAL	bux:DWORD
	LOCAL	buy:DWORD

	assume esi:ptr DIALOG
	mov		eax,[esi].ntype
	.if eax==0
		invoke GetClientRect,[esi].hwnd,addr rect
		sub		esi,sizeof DLGHEAD
		mov		al,(DLGHEAD ptr [esi]).class
		.if al
			mov		al,(DLGHEAD ptr [esi]).menuid
			.if al
				add		rect.bottom,19
			.endif
		.endif
		add		esi,sizeof DLGHEAD
	.else
		m2m		rect.right,[esi].ccx
		m2m		rect.bottom,[esi].ccy
	.endif
	invoke GetDialogBaseUnits
	mov		edx,eax
	and		eax,0FFFFh
	mov		bux,eax
	shr		edx,16
	mov		buy,edx

	mov		eax,[esi].x
	shl		eax,2
	mov		ebx,dfntwt
	imul	ebx
	cdq
	mov		ebx,bux
	idiv	ebx
	cdq
	mov		ebx,fntwt

	idiv	ebx
	invoke SaveVal,eax,TRUE

	mov		eax,[esi].y
	shl		eax,3
	mov		ebx,dfntht
	mul		ebx
	cdq
	mov		ebx,buy
	idiv	ebx

	cdq
	mov		ebx,fntht
	idiv	ebx
	invoke SaveVal,eax,TRUE

	mov		eax,rect.right
	shl		eax,2+9
	mov		ebx,dfntwt
	mul		ebx
	xor		edx,edx
	mov		ebx,bux
	idiv	ebx

	xor		edx,edx
	mov		ebx,fntwt
	idiv	ebx
	shr		eax,9
	invoke SaveVal,eax,TRUE

	mov		eax,rect.bottom
	shl		eax,3+9
	mov		ebx,dfntht
	mul		ebx
	xor		edx,edx
	mov		ebx,buy
	idiv	ebx
	xor		edx,edx
	mov		ebx,fntht
	idiv	ebx
	shr		eax,9
	invoke SaveVal,eax,FALSE
	assume esi:nothing
	ret

SaveCtlSize endp

SaveType proc uses edx esi edi

	invoke GetTypePtr,[esi].DIALOG.ntype
	mov		edx,eax
	invoke SaveStr,edi,[edx].TYPES.lprc
	ret

SaveType endp

SaveName proc uses esi edi
	LOCAL	buffer[16]:BYTE

	assume esi:ptr DIALOG
	mov		al,[esi].idname
	.if al
		invoke SaveStr,edi,addr [esi].idname
	.else
		invoke BinToDec,[esi].id,addr buffer
		invoke SaveStr,edi,addr buffer
	.endif
	assume esi:nothing
	ret

SaveName endp

SaveDefine proc
	LOCAL	buffer[16]:BYTE

	assume esi:ptr DIALOG
	;Is ctl deleted
	mov		eax,[esi].hwnd
	.if eax!=-1
		mov		al,[esi].idname
		.if al && [esi].id
			invoke SaveStr,edi,addr szDEFINE
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveStr,edi,addr [esi].idname
			add		edi,eax
			mov		al,' '
			stosb
			invoke BinToDec,[esi].id,addr buffer
			invoke SaveStr,edi,addr buffer
			add		edi,eax
			mov		ax,0A0Dh
			stosw
		.endif
	.endif
	assume esi:nothing
	ret

SaveDefine endp

SaveCaption proc

	assume esi:ptr DIALOG
	mov		al,22h
	stosb
	invoke SaveStr,edi,addr [esi].caption
	add		edi,eax
	mov		al,22h
	stosb
	assume esi:nothing
	ret

SaveCaption endp

SaveUDCClass proc

	assume esi:ptr DIALOG
	mov		al,22h
	stosb
	invoke SaveStr,edi,addr [esi].class
	add		edi,eax
	mov		al,22h
	stosb
	assume esi:nothing
	ret

SaveUDCClass endp

SaveClass proc
	LOCAL	lpclass:DWORD

	assume esi:ptr DIALOG
	invoke GetTypePtr,[esi].ntype
	m2m		lpclass,(TYPES ptr [eax]).lpclass
	mov		al,22h
	stosb
	invoke SaveStr,edi,lpclass
	add		edi,eax
	mov		al,22h
	stosb
	assume esi:nothing
	ret

SaveClass endp

SaveDlgClass proc

	mov		al,(DLGHEAD ptr [esi]).class
	.if al
		invoke SaveStr,edi,addr szCLASS
		add		edi,eax
		mov		al,' '
		stosb
		mov		al,22h
		stosb
		invoke SaveStr,edi,addr (DLGHEAD ptr [esi]).class
		add		edi,eax
		mov		al,22h
		stosb
		mov		ax,0A0Dh
		stosw
	.endif
	ret

SaveDlgClass endp

SaveDlgFont proc
	LOCAL	buffer[256]:BYTE
	LOCAL	val:DWORD

	mov		al,(DLGHEAD ptr [esi]).font
	.if al
		invoke SaveStr,edi,addr szFONT
		add		edi,eax
		mov		al,' '
		stosb
		m2m		val,(DLGHEAD ptr [esi]).fontsize
		invoke BinToDec,val,addr buffer
		invoke SaveStr,edi,addr buffer
		add		edi,eax
		mov		al,','
		stosb
		mov		al,22h
		stosb
		invoke SaveStr,edi,addr (DLGHEAD ptr [esi]).font
		add		edi,eax
		mov		al,22h
		stosb
		.if !fLimittedFont
			mov		al,','
			stosb
			movzx	edx,(DLGHEAD ptr [esi]).weight
			invoke BinToDec,edx,addr buffer
			invoke SaveStr,edi,addr buffer
			add		edi,eax
			mov		al,','
			stosb
			movzx	edx,(DLGHEAD ptr [esi]).italic
			invoke BinToDec,edx,addr buffer
			invoke SaveStr,edi,addr buffer
			add		edi,eax
			movzx	edx,(DLGHEAD ptr [esi]).charset
			.if edx
				mov		al,','
				stosb
				invoke BinToDec,edx,addr buffer
				invoke SaveStr,edi,addr buffer
				add		edi,eax
			.endif
		.endif
		mov		ax,0A0Dh
		stosw
	.endif
	ret

SaveDlgFont endp

SaveDlgMenu proc
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[64]:BYTE

	mov		al,(DLGHEAD ptr [esi]).menuid
	.if al
		invoke SaveStr,edi,addr szMENU
		add		edi,eax
		mov		al,' '
		stosb
		invoke GetFileImg,addr (DLGHEAD ptr [esi]).menuid
		.if eax==6
			mov		buffer1,0
			invoke strcpy,addr buffer,addr FileName
			invoke strcpy,addr FileName,addr ProjectPath
			invoke strcat,addr FileName,addr (DLGHEAD ptr [esi]).menuid
			invoke CreateMnu,3
			.if eax
				push	edi
				mov		edi,eax
				movzx	edx,(MNUHEAD ptr [edi]).menuid
				.if edx
					invoke BinToDec,edx,addr buffer1
				.else
					invoke strcpy,addr buffer1,addr (MNUHEAD ptr [edi]).menuname
				.endif
				invoke GlobalUnlock,edi
				invoke GlobalFree,edi
				pop		edi
			.endif
			invoke strcpy,addr FileName,addr buffer
			invoke SaveStr,edi,addr buffer1
		.else
			invoke SaveStr,edi,addr (DLGHEAD ptr [esi]).menuid
		.endif
		add		edi,eax
		mov		ax,0A0Dh
		stosw
	.endif
	ret

SaveDlgMenu endp

SaveCtl proc uses esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	buffer3[256]:BYTE
	LOCAL	nInx:DWORD

	assume esi:ptr DIALOG
	;Is ctl deleted
	mov		eax,[esi].hwnd
	.if eax!=-1
		mov		eax,[esi].ntype
		.if eax==0
			;Dialog
			invoke SaveName
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveType
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveCtlSize
			mov		eax,0A0Dh
			stosw
			mov		al,[esi].caption
			.if al
				invoke SaveStr,edi,addr szCAPTION
				add		edi,eax
				mov		al,20h
				stosb
				invoke SaveCaption
				mov		ax,0A0Dh
				stosw
			.endif
			;These are stored in DLGHEAD
			sub		esi,sizeof DLGHEAD
			invoke SaveDlgFont
			invoke SaveDlgClass
			.if !al
				invoke SaveDlgMenu
			.endif
			add		esi,sizeof DLGHEAD
			invoke SaveStr,edi,addr szSTYLE
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveHexVal,[esi].style,FALSE
			mov		ax,0A0Dh
			stosw
			invoke SaveStr,edi,addr szEXSTYLE
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveHexVal,[esi].exstyle,FALSE
			mov		ax,0A0Dh
			stosw
			invoke SaveStr,edi,addr szBEGIN
			add		edi,eax
			mov		ax,0A0Dh
			stosw
		.elseif eax==23
			;UserDefinedControl
			mov		ax,'  '
			stosw
			invoke SaveType
			add		edi,eax
			mov		al,' '
			stosb
			;Caption
			invoke SaveCaption
			mov		al,','
			stosb
			invoke SaveName
			add		edi,eax
			mov		al,','
			stosb
			;Class
			invoke SaveUDCClass
			mov		al,','
			stosb
			mov		eax,[esi].style
			and		eax,dwNOTStyle
			xor		eax,dwNOTStyle
			.if eax
				push	eax
				invoke SaveStr,edi,addr szNOTStyle
				add		edi,eax
				pop		eax
				invoke SaveHexVal,eax,FALSE
				mov		al,'|'
				stosb
			.endif
			invoke SaveHexVal,[esi].style,TRUE
			invoke SaveCtlSize
			mov		al,','
			stosb
			invoke SaveHexVal,[esi].exstyle,FALSE
			mov		ax,0A0Dh
			stosw
		.else
			;Control
			push	eax
			mov		ax,'  '
			stosw
			invoke SaveType
			add		edi,eax
			mov		al,' '
			stosb
			pop		eax
			.if eax==17 || eax==27
				mov		nInx,1
				.while eax
					invoke BinToDec,nInx,addr buffer
					invoke GetPrivateProfileString,addr iniResource,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
					.if eax
						invoke iniGetItem,addr buffer,addr buffer1
						invoke iniGetItem,addr buffer,addr buffer2
						invoke iniGetItem,addr buffer,addr buffer3
						invoke lstrcmpi,addr buffer,addr [esi].caption
						.if !eax
							mov		al,22h
							stosb
							mov		al,buffer2
							.if al=='0'
								invoke strcpy,edi,addr buffer1
							.else
								mov		al,'#'
								stosb
								invoke strcpy,edi,addr buffer2
							.endif
							invoke strlen,edi
							add		edi,eax
							mov		al,22h
							stosb
							xor		eax,eax
						.endif
					.else
						invoke SaveCaption
						xor		eax,eax
					.endif
					inc		nInx
				.endw
			.else
				invoke SaveCaption
			.endif
			mov		al,','
			stosb
			invoke SaveName
			add		edi,eax
			mov		al,','
			stosb
			invoke SaveClass
			mov		al,','
			stosb
			mov		eax,[esi].style
			and		eax,dwNOTStyle
			xor		eax,dwNOTStyle
			.if eax
				push	eax
				invoke SaveStr,edi,addr szNOTStyle
				add		edi,eax
				pop		eax
				invoke SaveHexVal,eax,FALSE
				mov		al,'|'
				stosb
			.endif
			invoke SaveHexVal,[esi].style,TRUE
			invoke SaveCtlSize
			mov		al,','
			stosb
			invoke SaveHexVal,[esi].exstyle,FALSE
			mov		ax,0A0Dh
			stosw
		.endif
	.endif
	mov		eax,edi
	assume esi:nothing
	ret

SaveCtl endp

TestProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetClientRect,hWin,addr rect
		m2m		fntwt,rect.right
		m2m		fntht,rect.bottom
		invoke SendMessage,hWin,WM_CLOSE,0,0
	.elseif eax==WM_CLOSE
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TestProc endp

ExportDialog proc uses esi edi,hWin:HWND,fFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hRdMem:DWORD
	LOCAL	hWrMem:DWORD
	LOCAL	nTab:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	invoke GetWindowLong,hWin,4
	mov		hRdMem,eax
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*100
	mov		hWrMem,eax
	invoke GlobalLock,hWrMem
	mov		esi,hRdMem
	mov		dlgps,10
	mov		dlgfn,0
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hWin,offset TestProc,0
	m2m		dfntwt,fntwt
	m2m		dfntht,fntht
	mov		eax,[esi].DLGHEAD.fontsize
	mov		dlgps,ax
	pushad
	lea		esi,[esi].DLGHEAD.font
	mov		edi,offset dlgfn
	invoke GetACP
	invoke MultiByteToWideChar,eax,0,esi,32,edi,32
;	xor		eax,eax
;	mov		ecx,32
;  @@:
;	lodsb
;	stosw
;	loop	@b
	popad
	invoke CreateDialogIndirectParam,hInstance,offset dlgdata,hWin,offset TestProc,0
	mov		edi,hWrMem
	add		esi,sizeof DLGHEAD
  @@:
	invoke SaveDefine
	add		esi,size DIALOG
	mov		eax,[esi]
	or		eax,eax
	jne		@b
	mov		esi,hRdMem
	add		esi,sizeof DLGHEAD
	invoke SaveCtl
	mov		edi,eax
	add		esi,sizeof DIALOG
	mov		nTab,0
  @@:
	invoke FindTab,nTab,hWin
	.if eax
		invoke GetWindowLong,eax,GWL_USERDATA
		mov		esi,eax
		invoke SaveCtl
		mov		edi,eax
		inc		nTab
		jmp		@b
	.endif
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		eax,0A0Dh
	stosd
	.if fFile
		invoke strcpy,addr buffer,addr ProjectPath
		invoke strlen,addr buffer
		lea		edi,buffer
		add		edi,eax
		mov		al,'R'
		stosb
		mov		al,'e'
		stosb
		mov		al,'s'
		stosb
		mov		al,'\'
		stosb
		invoke strlen,addr FileName
		mov		esi,offset FileName
		add		esi,eax
	  @@:
		dec		esi
		mov		al,[esi]
		cmp		al,'\'
		jne		@b
		inc		esi
		xor		edx,edx
	  @@:
		mov		al,[esi]
		.if al=='.'
			mov		edx,edi
		.endif
		mov		[edi],al
		inc		esi
		inc		edi
		or		al,al
		jne		@b
		.if edx
			mov		edi,edx
		.endif
	  @@:
		mov		al,'D'
		stosb
		mov		al,'l'
		stosb
		mov		al,'g'
		stosb
		mov		al,'.'
		stosb
		mov		al,'r'
		stosb
		mov		al,'c'
		stosb
		mov		al,0
		stosb
		invoke CreateFile,addr buffer,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strlen,hWrMem
			mov		nBytes,eax
			invoke WriteFile,hFile,hWrMem,nBytes,addr nBytes,NULL
			invoke CloseHandle,hFile
			inc		fResChanged
			invoke DllProc,hWnd,AIM_RCSAVED,1,addr buffer,RAM_RCSAVED
		.else
			invoke strcpy,addr LineTxt,addr SaveFileFail
			invoke strcat,addr LineTxt,addr buffer
			invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		.endif
	.else
		invoke OutputSelect,2
		invoke OutputClear
		invoke ShowOutput
		invoke TextToOutput,hWrMem
		invoke SetFocus,hOutREd
	.endif
	invoke GlobalUnlock,hWrMem
	invoke GlobalFree,hWrMem
	ret

ExportDialog endp

CompactDlgFile proc uses ecx esi edi,lpData:DWORD

	mov		esi,lpData
	mov		edi,esi
	add		esi,sizeof DIALOG
  @@:
	mov		dword ptr [edi],0
	mov		eax,[esi]
	.if eax
		mov		ecx,sizeof DIALOG
		rep movsb
		jmp		@b
	.endif
	ret

CompactDlgFile endp

SaveDlgFile proc uses esi,hWin:HWND,lpData:DWORD,fSaveAs:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	hFile:DWORD

	invoke GetWindowText,hWin,addr FileName,255
	invoke strcmp,addr NewFile,addr FileName
	.if !eax || fSaveAs
		invoke RtlZeroMemory,addr ofn,sizeof ofn
		mov		ofn.lStructSize,sizeof ofn
		m2m		ofn.hwndOwner,hWnd
		m2m		ofn.hInstance,hInstance
		mov		ofn.lpstrFilter,offset DLGFilterString
		mov		ofn.lpstrFile,offset FileName
		mov		byte ptr [FileName],0
		mov		ofn.nMaxFile,sizeof FileName
		mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
		mov		ofn.lpstrDefExt, offset DefDlgExt
		invoke GetSaveFileName,addr ofn
		.if !eax
			mov		eax,TRUE
			ret
		.endif
	.else
		invoke BackupEdit,addr FileName,1
	.endif
	invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		mov		esi,lpData
		mov		(DLGHEAD ptr [esi]).undo,0
		add		esi,sizeof DLGHEAD
	  @@:
		mov		eax,(DIALOG ptr [esi]).hwnd
		.if eax==-1
			invoke CompactDlgFile,esi
		.else
			add		esi,sizeof DIALOG
		.endif
		mov		eax,(DIALOG ptr [esi]).hwnd
		or		eax,eax
		jne		@b
		mov		eax,esi
		sub		eax,lpData
		mov		nBytes,eax
		mov		eax,lpData
		add		eax,sizeof DLGHEAD
		mov		eax,(DIALOG ptr [eax]).hwnd
		invoke UpdateDialog,eax
		invoke WriteFile,hFile,lpData,nBytes,addr nBytes,NULL
		invoke DllProc,hWin,AIM_DIALOGSAVE,hFile,0,RAM_DIALOGSAVE
		invoke CloseHandle,hFile
		mov		esi,lpData
		.if !fSaveAs
			invoke SetChanged,FALSE,hWin
		.endif
		.if fSaveRcFile
			invoke ExportDialog,hWin,TRUE
		.endif
		invoke UpdateFileTime,hWin
		xor		eax,eax
	.else
		invoke strcpy,addr LineTxt,addr SaveFileFail
		invoke strcat,addr LineTxt,addr FileName
		invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

SaveDlgFile endp

SaveDialog proc hWin:HWND,fSaveAs:DWORD
	LOCAL	hRdMem:DWORD

	invoke GetWindowLong,hWin,4
	mov		hRdMem,eax
	.if hRdMem
		mov		eax,(DLGHEAD ptr [eax]).changed
		.if eax || fSaveAs
			invoke SaveDlgFile,hWin,hRdMem,fSaveAs
		.endif
	.endif
	ret

SaveDialog endp

ConvertDialog proc uses esi edi,ver:DWORD,hMem:DWORD
	LOCAL	hMemNew:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MaxMem
	invoke GlobalLock,eax
	mov		hMemNew,eax
	mov		edi,eax
	mov		esi,hMem
	.if ver==100
		call ConvFrom100
	.elseif ver==101
		call ConvFrom101
	.endif
	invoke GlobalUnlock,hMem
	invoke GlobalFree,hMem
	mov		eax,hMemNew
	ret

ConvFrom100:
	mov		dword ptr [esi],DLGVER
	mov		ecx,sizeof DLGHEAD
	rep movsb
	mov		eax,[esi].DIALOG100.hwnd
	.while eax
		m2m		[edi].DIALOG.hwnd,[esi].DIALOG100.hwnd
		mov		[edi].DIALOG.hdmy,0
		m2m		[edi].DIALOG.oldproc,[esi].DIALOG100.oldproc
		m2m		[edi].DIALOG.hpar,[esi].DIALOG100.hpar
		m2m		[edi].DIALOG.hcld,[esi].DIALOG100.hcld
		m2m		[edi].DIALOG.style,[esi].DIALOG100.style
		m2m		[edi].DIALOG.exstyle,[esi].DIALOG100.exstyle
		m2m		[edi].DIALOG.x,[esi].DIALOG100.x
		m2m		[edi].DIALOG.y,[esi].DIALOG100.y
		m2m		[edi].DIALOG.ccx,[esi].DIALOG100.ccx
		m2m		[edi].DIALOG.ccy,[esi].DIALOG100.ccy
		m2m		[edi].DIALOG.ntype,[esi].DIALOG100.ntype
		m2m		[edi].DIALOG.tab,[esi].DIALOG100.tab
		m2m		[edi].DIALOG.id,[esi].DIALOG100.id
		invoke strcpy,addr [edi].DIALOG.idname,addr [esi].DIALOG100.idname
		m2m		[edi].DIALOG.undo,[esi].DIALOG100.undo
		m2m		[edi].DIALOG.himg,[esi].DIALOG100.himg
		add		esi,sizeof DIALOG100
		add		edi,sizeof DIALOG
		mov		eax,[esi].DIALOG100.hwnd
	.endw
	retn

ConvFrom101:
	mov		dword ptr [esi],DLGVER
	mov		ecx,sizeof DLGHEAD
	rep movsb
	mov		eax,[esi].DIALOG101.hwnd
	.while eax
		m2m		[edi].DIALOG.hwnd,[esi].DIALOG101.hwnd
		mov		[edi].DIALOG.hdmy,0
		m2m		[edi].DIALOG.oldproc,[esi].DIALOG101.oldproc
		m2m		[edi].DIALOG.hpar,[esi].DIALOG101.hpar
		m2m		[edi].DIALOG.hcld,[esi].DIALOG101.hcld
		m2m		[edi].DIALOG.style,[esi].DIALOG101.style
		m2m		[edi].DIALOG.exstyle,[esi].DIALOG101.exstyle
		m2m		[edi].DIALOG.x,[esi].DIALOG101.x
		m2m		[edi].DIALOG.y,[esi].DIALOG101.y
		m2m		[edi].DIALOG.ccx,[esi].DIALOG101.ccx
		m2m		[edi].DIALOG.ccy,[esi].DIALOG101.ccy
		.if [esi].DIALOG101.ntype==23
			mov		[edi].DIALOG.caption,0
			invoke strcpy,addr [edi].DIALOG.class,addr [esi].DIALOG100.caption
		.else
			mov		[edi].DIALOG.class,0
			invoke strcpy,addr [edi].DIALOG.caption,addr [esi].DIALOG101.caption
		.endif
		m2m		[edi].DIALOG.ntype,[esi].DIALOG101.ntype
		m2m		[edi].DIALOG.tab,[esi].DIALOG101.tab
		m2m		[edi].DIALOG.id,[esi].DIALOG101.id
		invoke strcpy,addr [edi].DIALOG.idname,addr [esi].DIALOG101.idname
		m2m		[edi].DIALOG.undo,[esi].DIALOG101.undo
		m2m		[edi].DIALOG.himg,[esi].DIALOG101.himg
		add		esi,sizeof DIALOG101
		add		edi,sizeof DIALOG
		mov		eax,[esi].DIALOG101.hwnd
	.endw
	retn

ConvertDialog endp

GetType proc uses ebx esi,lpDlg:DWORD

	mov		esi,lpDlg
	mov		eax,[esi].DIALOG.ntypeid
	.if eax
		mov		ebx,offset ctltypes
		mov		ecx,nButtons
		xor		ecx,ecx
		.while ecx<nButtons
			.if eax==[ebx].TYPES.ID
				mov		[esi].DIALOG.ntype,ecx
				xor		eax,eax
				.break
			.endif
			add		ebx,sizeof TYPES
			inc		ecx
		.endw
		.if eax
			mov		[esi].DIALOG.ntype,2
			mov		[esi].DIALOG.ntypeid,2
			invoke TextToOutput,CTEXT("Unknown control type!")
			invoke TextToOutput,addr [esi].DIALOG.idname
			invoke TextToOutput,addr [esi].DIALOG.caption
		.endif
	.else
		mov		eax,[esi].DIALOG.ntype
		mov		[esi].DIALOG.ntypeid,eax
		xor		eax,eax
	.endif
	ret

GetType endp

CreateNewDialog proc uses esi,fNew:DWORD,hWin:HWND
	LOCAL	hDlg:HWND
	LOCAL	hMem:DWORD
	LOCAL	hFile:DWORD
	LOCAL	lpFN:DWORD
	LOCAL	dwRead:DWORD

	assume esi:ptr DIALOG
	mov		eax,hWin
	mov		hMdiCld,eax
	mov		hEdit,0
	mov		hDialog,0
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,MaxMem
	mov		hMem,eax
	invoke GlobalLock,hMem
	invoke SetWindowLong,hWin,4,hMem
	.if fNew==1
;		mov		lpFN,offset NewFile
;		invoke CreateNewCtl,hWin,0,DlgX,DlgY,300,200
;		mov		hDlg,eax
	.elseif fNew==2
		mov		lpFN,offset FileName
		invoke CreateNewCtl,hWin,0,DlgX,DlgY,300,200
		mov		hDlg,eax
		mov		hDialog,eax
		inc		fResChanged
	.else
		mov		lpFN,offset FileName
		invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke ReadFile,hFile,hMem,MaxMem-4,addr dwRead,NULL
			invoke CloseHandle,hFile
		.else
			invoke SetChanged,FALSE,hWin
			invoke SendMessage,hWin,WM_CLOSE,0,0
			invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
			ret
		.endif
		;Create dlg
		mov		esi,hMem
		mov		eax,(DLGHEAD ptr [esi]).ver
		.if eax<DLGVER
			invoke ConvertDialog,eax,hMem
			mov		hMem,eax
			mov		esi,eax
			invoke SetWindowLong,hWin,4,hMem
		.elseif eax>DLGVER
			invoke SetChanged,FALSE,hWin
			invoke SendMessage,hWin,WM_CLOSE,0,0
			invoke MessageBox,hWnd,addr OpenFileFail,addr AppName,MB_OK or MB_ICONERROR
			ret
		.endif
		xor		eax,eax
		mov		(DLGHEAD ptr [esi]).hmnu,eax
		mov		(DLGHEAD ptr [esi]).htlb,eax
		mov		(DLGHEAD ptr [esi]).hstb,eax
		mov		(DLGHEAD ptr [esi]).hfont,eax
		add		esi,sizeof DLGHEAD
		m2m		[esi].hpar,hWin
		mov		[esi].hdmy,eax
		mov		[esi].hcld,eax
		mov		[esi].himg,eax
		invoke CreateCtl,esi
		mov		hDlg,eax
		mov		hDialog,eax
		;Create ctl's
		add		esi,sizeof DIALOG
		.while [esi].hwnd
			xor		eax,eax
			m2m		[esi].hpar,hDlg
			mov		[esi].hdmy,eax
			mov		[esi].hcld,eax
			mov		[esi].himg,eax
			invoke GetType,esi
			invoke CreateCtl,esi
			add		esi,sizeof DIALOG
		.endw
	.endif
	invoke SetWindowLong,hDlg,GWL_ID,ID_DIALOG
	invoke SetWindowLong,hWin,GWL_USERDATA,hDlg
	invoke SetWindowText,hWin,lpFN
	invoke TabToolAdd,hWin,lpFN
	.if fNew==2
		invoke DllProc,hWin,AIM_CREATENEWDLG,hDlg,addr FileName,RAM_CREATENEWDLG
		invoke SaveDialog,hWin,FALSE
	.endif
	invoke DllProc,hWin,AIM_DIALOGOPEN,hMem,0,RAM_DIALOGOPEN
	invoke GetFileAttributes,addr FileName
	and		eax,FILE_ATTRIBUTE_READONLY
	invoke SetWindowLong,hWin,8,eax
	invoke SetChanged,FALSE,hWin
	invoke SendMessage,hDlg,WM_NCACTIVATE,1,0
	invoke ToolBarStatus
	invoke SizeingRect,hDlg,FALSE
	.if hFullScreen
		invoke ShowWindow,hFullScreen,SW_HIDE
	.endif
	assume esi:nothing
	ret

CreateNewDialog endp

CreateDlg proc fNew:DWORD

	m2m		fNewDialog,fNew
	invoke MakeMdiCldWin,addr DialogCldClassName,ID_DIALOG
	invoke CreateNewDialog,fNew,eax
	ret

CreateDlg endp

