'include file for building RadASM plugins

' hierarchy of edit windows:
' - mdi             = mdi window for edit control
'   - raedit        = frame for edit controls (1x edit, 1x line numbers)
'     - raeditchild = edit control





'Code / text editor Mdi child data.
'
'Retrived by GetWindowLong.
'GWL_USERDATA=hEdit
'GWL_ID>=ID_FIRSTCHILD
'0=ID_EDIT (65501) or ID_EDITTXT (65503)
'4=
'8=
'12=
'16=Project file ID
'20=OverWrite


'structure for addin options
TYPE addinopt                                         'udt for options in addin manager
  lpStr AS ASCIIZ PTR                                 'pointer to description string
  nAnd  AS DWORD                                      'used for option settings
  nOr   AS DWORD                                      'used for option settings
END TYPE


%ID_FIRSTCHILD     = 65001
%ID_LASTCHILD      = 65499
%ID_EDIT           = 65501
%ID_DIALOG         = 65502
%ID_EDITTXT        = 65503
%ID_EDITSPLIT      = 65504


'raedit private messages
%REM_RAINIT          = %WM_USER+9999     'wParam=0, lParam=pointer to controls DIALOG struct
%REM_BASE            = %WM_USER+1000
%REM_SETHILITEWORDS  = %REM_BASE+0       'wParam=Color, lParam=lpszWords
%REM_SETFONT         = %REM_BASE+1       'wParam=nLineSpacing, lParam=lpRAFONT
%REM_GETFONT         = %REM_BASE+2       'wParam=0, lParam=lpRAFONT
%REM_SETCOLOR        = %REM_BASE+3       'wParam=0, lParam=lpRACOLOR
%REM_GETCOLOR        = %REM_BASE+4       'wParam=0, lParam=lpRACOLOR
%REM_SETHILITELINE   = %REM_BASE+5       'wParam=Line, lParam=HighlightColor (1,2 or 3)
%REM_GETHILITELINE   = %REM_BASE+6       'wParam=Line, lParam=0, return=0(no highlighting),1,2,3
%REM_SETBOOKMARK     = %REM_BASE+7       'wParam=Line, lParam=Type
%REM_GETBOOKMARK     = %REM_BASE+8       'wParam=Line, lParam=0
%REM_CLRBOOKMARKS    = %REM_BASE+9       'wParam=0, lParam=Type
%REM_NXTBOOKMARK     = %REM_BASE+10      'wParam=Line, lParam=Type
%REM_PRVBOOKMARK     = %REM_BASE+11      'wParam=Line, lParam=Type
%REM_FINDBOOKMARK    = %REM_BASE+12      'wParam=BmID, lParam=0
%REM_SETBLOCKS       = %REM_BASE+13      'wParam=[lpLINERANGE], lParam=lpRABLOCKDEF
%REM_ISLINE          = %REM_BASE+14      'wParam=Line, lParam=lpszDef
%REM_GETWORD         = %REM_BASE+15      'wParam=BuffSize, lParam=lpBuff
%REM_COLLAPSE        = %REM_BASE+16      'wParam=Line, lParam=lpRABLOCKDEF
%REM_COLLAPSEALL     = %REM_BASE+17      'wParam=0, lParam=lpRABLOCKDEF
%REM_EXPAND          = %REM_BASE+18      'wParam=Line, lParam=0
%REM_EXPANDALL       = %REM_BASE+19      'wParam=0, lParam=0
%REM_LOCKLINE        = %REM_BASE+20      'wParam=Line, lParam=TRUE/FALSE
%REM_ISLINELOCKED    = %REM_BASE+21      'wParam=Line, lParam=0
%REM_HIDELINE        = %REM_BASE+22      'wParam=Line, lParam=TRUE/FALSE
%REM_ISLINEHIDDEN    = %REM_BASE+23      'wParam=Line, lParam=0
%REM_AUTOINDENT      = %REM_BASE+24      'wParam=0, lParam=TRUE/FALSE
%REM_TABWIDTH        = %REM_BASE+25      'wParam=nChars, lParam=TRUE/FALSE (Expand tabs)
%REM_SELBARWIDTH     = %REM_BASE+26      'wParam=nWidth, lParam=0
%REM_LINENUMBERWIDTH = %REM_BASE+27      'wParam=nWidth, lParam=0
%REM_MOUSEWHEEL      = %REM_BASE+28      'wParam=nLines, lParam=0
%REM_SUBCLASS        = %REM_BASE+29      'wParam=0, lParam=lpWndProc
%REM_SETSPLIT        = %REM_BASE+30      'wParam=nSplit, lParam=0
%REM_GETSPLIT        = %REM_BASE+31      'wParam=0, lParam=0
%REM_VCENTER         = %REM_BASE+32      'wParam=0, lParam=0
%REM_REPAINT         = %REM_BASE+33      'wParam=0, lParam=TRUE/FALSE (Paint Now)
%REM_BMCALLBACK      = %REM_BASE+34      'wParam=0, lParam=lpBmProc
%REM_READONLY        = %REM_BASE+35      'wParam=0, lParam=TRUE/FALSE
%REM_INVALIDATELINE  = %REM_BASE+36      'wParam=Line, lParam=0
%REM_SETPAGESIZE     = %REM_BASE+37      'wParam=nLines, lParam=0
%REM_GETPAGESIZE     = %REM_BASE+38      'wParam=0, lParam=0
%REM_GETCHARTAB      = %REM_BASE+39      'wParam=nChar, lParam=0
%REM_SETCHARTAB      = %REM_BASE+40      'wParam=nChar, lParam=nValue
%REM_SETCOMMENTBLOCKS= %REM_BASE+41      'wParam=lpStart, lParam=lpEnd
%REM_SETWORDGROUP    = %REM_BASE+42      'wParam=0, lParam=nGroup (0-15)
%REM_GETWORDGROUP    = %REM_BASE+43      'wParam=0, lParam=0
%REM_SETBMID         = %REM_BASE+44      'wParam=nLine, lParam=nBmID
%REM_GETBMID         = %REM_BASE+45      'wParam=nLine, lParam=0
%REM_ISCHARPOS       = %REM_BASE+46      'wParam=CP, lParam=0, returns 1 if comment block, 2 if comment, 3 if string
%REM_HIDELINES       = %REM_BASE+47      'wParam=nLine, lParam=nLines
%REM_SETDIVIDERLINE  = %REM_BASE+48      'wParam=nLine, lParam=TRUE/FALSE
%REM_ISINBLOCK       = %REM_BASE+49      'wParam=nLine, lParam=lpRABLOCKDEF
%REM_TRIMSPACE       = %REM_BASE+50      'wParam=nLine, lParam=fLeft
%REM_SAVESEL         = %REM_BASE+51      'wParam=0, lParam=0
%REM_RESTORESEL      = %REM_BASE+52      'wParam=0, lParam=0
%REM_GETCURSORWORD   = %REM_BASE+53      'wParam=BuffSize, lParam=lpBuff





'Messages to RadASM's mdi frame
%AIM_GETHANDLES      = %WM_USER+50  'returns a poiner to a struct containing all useful handles:see structures below
%AIM_GETPROCS        = %WM_USER+51  'returns a poiner to a struct containing some procs in RadASM:see structures below
%AIM_GETDATA         = %WM_USER+52  'returns a poiner to a struct comtaining data pointers:see structures below
%AIM_GETMENUID       = %WM_USER+53  'Returns a free menu id. If you need more than one just send the message again.

'Messages from RadASM to DllProc procedure
%AIM_COMMAND         = %WM_COMMAND      'hWnd=Handle of mdi frame, wParam & lParam=as for %WM_COMMAND
%AIM_MAKEBEGIN       = %WM_USER+100       'hWnd=Handle of mdi frame, wParam=0, lParam=pointer to string containing commands
%AIM_MAKEDONE        = %WM_USER+101       'hWnd=Handle of mdi frame, wParam=0, lParam=exit code
%AIM_CLOSE           = %WM_CLOSE      'hWnd=Handle of mdi frame, wParam & lParam=as for %WM_CLOSE
%AIM_INITMENUPOPUP   = %WM_INITMENUPOPUP  'hWnd=Handle of mdi frame, wParam & lParam=as for %WM_INITMENUPOPUP
%AIM_COMMANDDONE     = %WM_USER+102       'hWnd=Handle of mdi frame, wParam & lParam=as for %WM_COMMAND
%AIM_PROJECTCLOSE    = %WM_USER+103       'hWnd=Handle of mdi frame, wParam=0, lParam=0
%AIM_PROJECTCLOSED   = %WM_USER+104       'hWnd=Handle of mdi frame, wParam=0, lParam=0
%AIM_CLIENTMOUSEMOVE = %WM_USER+105       'hWnd=handle of client, wParam & lParam=as for %WM_MOUSEMOVE
%AIM_TIMER           = %WM_USER+106       'as for a TimerProc
%AIM_CTLDBLCLK       = %WM_USER+107       'hWnd=handle of mdi child, wParam=handle of control, lParam=pointer to DIALOG structure
%AIM_CREATENEWDLG    = %WM_USER+108       'hWnd=handle of mdi child, wParam=handle of dialog, lParam=pointer to filename
%AIM_CONTEXTMENU     = %WM_USER+109       'hWnd=Handle of mdi frame, wParam & lParam=as for %WM_CONTEXTMENU
%AIM_PROJECTOPENED   = %WM_USER+110       'hWnd=handle of mdi frame, wParam=0, lParam=pointer to filename
%AIM_MENUREBUILD     = %WM_USER+111       'hWnd=handle of menu, wParam=0, lParam=0
%AIM_EDITOPEN        = %WM_USER+112       'hWnd=handle of mdi child, wParam=handle of edit, lParam=ID_EDIT or ID_EDITTXT
%AIM_EDITCLOSE       = %WM_USER+113       'hWnd=handle of mdi child, wParam=handle of edit, lParam=ID_EDIT or ID_EDITTXT
%AIM_EDITCLOSED      = %WM_USER+114       'hWnd=handle of mdi child, wParam=handle of edit, lParam=ID_EDIT or ID_EDITTXT
%AIM_EDITSAVE        = %WM_USER+115       'hWnd=handle of mdi child, wParam=handle of edit, lParam=pointer to filename
%AIM_EDITSAVED       = %WM_USER+116       'hWnd=handle of mdi child, wParam=handle of edit, lParam=pointer to filename
%AIM_TBRTOOLTIP      = %WM_USER+117       'hWnd=handle of mdi frame, wParam=ID, lParam=0
%AIM_MDIACTIVATE     = %WM_USER+118       'hWnd=handle of mdi child, wParam & lParam=same as for %WM_MDIACTIVATE
%AIM_EDITSELCHANGE   = %WM_USER+119       'hWnd=handle of mdi child, wParam=handle of edit, lParam=ID
%AIM_PROJECTADDNEW   = %WM_USER+120       'hWnd=handle of mdi frame, wParam=type, lParam=pointer to filename
%AIM_PROJECTREMOVE   = %WM_USER+121       'hWnd=handle of mdi frame, wParam=0, lParam=pointer to filename
%AIM_DLGMNUSELECT    = %WM_USER+122       'hWnd=handle of mdi child, wParam=handle of dialog, lParam=pointer to MENUITEM structure
%AIM_RCUPDATE        = %WM_USER+123       'hWnd=handle of dialog,wParam=type,lParam=pointer to memory
%AIM_CREATENEWCTL    = %WM_USER+124       'hWnd=handle of mdi child, wParam=handle of dialog, lParam=pointer to DIALOG structure
%AIM_TOOLSHOW        = %WM_USER+125       'hWnd=handle of tool,wParam=visible,lParam=ID
%AIM_SETSTYLE        = %WM_USER+126       'hWnd=handle of property listbox, wParam=Pointer to DIALOG struct. lParam=TRUE if ExStyle
%AIM_OUTPUTDBLCLK    = %WM_USER+127       'hWnd=handle of output, wParam & lParam=same as for %WM_LBUTTONDBLCLK
%AIM_CODEINFO        = %WM_USER+128       'hWnd=handle of mdi child, wParam=ID, lParam=pointer to word
%AIM_MODULEBUILD     = %WM_USER+129       'hWnd=handle of mdi frame,wParam=0 , lParam=0


'Return values from InstallDll procedure which tell RadASM which messages to send to your DllProc procedure,can be OR'ed
%RAM_COMMAND         = &H00000001   '%AIM_COOMAND = %WM_COMMAND
%RAM_COMMANDDONE     = &H00000002   '%AIM_COMMANDDONE
%RAM_CLOSE           = &H00000004   '%AIM_CLOSE = %WM_CLOSE
%RAM_INITMENUPOPUP   = &H00000008   '%AIM_INITMENUPOPUP = %WM_INITMENUPOPUP
%RAM_MAKEBEGIN       = &H00000010   '%AIM_MAKEBEGIN
%RAM_MAKEDONE        = &H00000020   '%AIM_MAKEDONE
%RAM_PROJECTCLOSE    = &H00000040   '%AIM_PROJECTCLOSE
%RAM_PROJECTCLOSED   = &H00000080   '%AIM_PROJECTCLOSED
%RAM_CLIENTMOUSEMOVE = &H00000100   '%AIM_CLIENTMOUSEMOVE
%RAM_TIMER           = &H00000200   '%AIM_TIMER
%RAM_CTLDBLCLK       = &H00000400   '%AIM_CTLDBLCLK
%RAM_CREATENEWDLG    = &H00000800   '%AIM_CREATENEWDLG
%RAM_CONTEXTMENU     = &H00001000   '%AIM_CONTEXTMENU
%RAM_PROJECTOPENED   = &H00002000   '%AIM_PROJECTOPENED
%RAM_MENUREBUILD     = &H00004000   '%AIM_MENUREBUILD
%RAM_EDITOPEN        = &H00008000   '%AIM_EDITOPEN
%RAM_EDITCLOSE       = &H00010000   '%AIM_EDITCLOSE
%RAM_EDITCLOSED      = &H00020000   '%AIM_EDITCLOSED
%RAM_EDITSAVE        = &H00040000   '%AIM_EDITSAVE
%RAM_EDITSAVED       = &H00080000   '%AIM_EDITSAVED
%RAM_TBRTOOLTIP      = &H00100000   '%AIM_TBRTOOLTIP
%RAM_MDIACTIVATE     = &H00200000   '%AIM_MDIACTIVATE
%RAM_EDITSELCHANGE   = &H00400000   '%AIM_EDITSELCHANGE
%RAM_PROJECTADDNEW   = &H00800000   '%AIM_PROJECTADDNEW
%RAM_PROJECTREMOVE   = &H01000000   '%AIM_PROJECTREMOVE
%RAM_DLGMNUSELECT    = &H02000000   '%AIM_DLGMNUSELECT
%RAM_RCUPDATE        = &H04000000   '%AIM_RCUPDATE
%RAM_CREATENEWCTL    = &H08000000   '%AIM_CREATENEWCTL
%RAM_TOOLSHOW        = &H010000000  '%AIM_TOOLSHOW
%RAM_SETSTYLE        = &H020000000  '%AIM_SETSTYLE
%RAM_OUTPUTDBLCLK    = &H040000000  '%AIM_OUTPUTDBLCLK
%RAM_CODEINFO        = &H080000000  '%AIM_CODEINFO

'Returned in ecx
%RAM_MODULEBUILD     = &H00000001   '%AIM_MODULEBUILD


'Structure pointed to on return from %AIM_GETHANDLES
 TYPE ADDINHANDLES      'struct
  hWnd        AS DWORD  'Handle of mdi Frame
  hMenu       AS DWORD  'Handle of mdi Frame Menu
  hToolBar    AS DWORD  'Handle of mdi Frame ToolBar
  hStatus     AS DWORD  'Handle of mdi Frame StatusBar
  hClient     AS DWORD  'Handle of mdi client
  hMdiCld     AS DWORD  'Handle of topmost mdi Child window
  hEdit       AS DWORD  'Handle of topmost mdi Child RAEdit window
  hDialog     AS DWORD  'Handle of topmost mdi Child DialogBox window
  hSearch     AS DWORD  'Handle of search / replace dialog
  hGoTo       AS DWORD  'Handle of goto dialog
  hOut        AS DWORD  'Handle of output Static container
  hPbr        AS DWORD  'Handle of project Static container
  hTlb        AS DWORD  'Handle of toolbox Static container
  hPrp        AS DWORD  'Handle of properties Static container
  hPrpCbo     AS DWORD  'Handle of properties ComboBox
  hPrpLst     AS DWORD  'Handle of properties ListBox
  hPrpTxt     AS DWORD  'Handle of properties item Edit control
  hTxtLst     AS DWORD  'Handle of properties item ListBox
  hTxtBtn     AS DWORD  'Handle of properties item Button
  hLB         AS DWORD  'Handle of Api ListBox (CodeComplete). Same as hLBU or hLBS
  hTlt        AS DWORD  'Handle of Api Static (ToolTip)
  hInst       AS DWORD  'RadASM instance
  hToolMenu   AS DWORD  'Handle of RightClick Menu in project, properties and output window
  hTab        AS DWORD  'Handle of tab window
  hPbrTrv     AS DWORD  'Handle of project browser TreeView
  hPrpTbr     AS DWORD  'Handle of properties ToolBar
  hPbrTbr     AS DWORD  'Handle of project / file browser ToolBar
  hFileTrv    AS DWORD  'Handle of file browser TreeView
  hOutREd     AS DWORD  'Handle of active output RAEdit window
  hOut1       AS DWORD  'Handle of output#1 RAEdit window
  hOut2       AS DWORD  'Handle of output#2 RAEdit window
  hOut3       AS DWORD  'Handle of output#3 RAEdit window
  hOutBtn1    AS DWORD  'Handle of output button #1
  hOutBtn2    AS DWORD  'Handle of output button #2
  hOutBtn3    AS DWORD  'Handle of output button #3
  hDivider    AS DWORD  'Handle of divider line
  hSniplet    AS DWORD  'Handle of sniplet dialog
  hToolTip    AS DWORD  'Handle of toolbox button tooltip
  hLBU        AS DWORD  'Handle of unsorted listbox
  hLBS        AS DWORD  'Handle of sorted listbox
  hInf        AS DWORD  'Handle of infotool static container
  hInfEdt     AS DWORD  'Handle of infotool edit control
  hTl1        AS DWORD  'Handle of tool#1 static container
  hTl2        AS DWORD  'Handle of tool#2 static container
  hAccel      AS DWORD  'RadASM Accelerators
  hAccelTools AS DWORD  'Menu Make, Tools, Macro & Help Accelerators
END TYPE                'ADDINHANDLES ends

'Structure pointed to on return from %AIM_GETPROCS
TYPE ADDINPROCS                 'struct
  lpTextOut           AS DWORD  'Pointer to proc handeling text to output window. Push pointer to text before calling.
  lpHexOut            AS DWORD  'Pointer to proc handeling hex to output window. Use for debug. Push val before calling.
  lpClearOut          AS DWORD  'Pointer to proc clearing output
  lpAddProjectFile    AS DWORD  'lpFileName,fUpdateTree,fModule
  lpOpenProjectFile   AS DWORD  'Give error msg TRUE/FALSE, set lpFile to file to open
  lpToolMessage       AS DWORD  'Handle, message, lParam
  lpGetWordFromPos    AS DWORD  'Handle of RAEdit, returns pointer to word
  lpProFind           AS DWORD  'Pointer to a PROFIND struct
  lpGetWord           AS DWORD  'lpWord, returns pointer to word
  lpRemoveProjectPath AS DWORD  'lpFileName, lpBuff, returns pointer to filename
  lpGetMainFile       AS DWORD  'lpFileExt
  lpSearchMem         AS DWORD  'hMem,lpFind,fMCase,fWWord
  lpProScan           AS DWORD  'lpFind,lpNot
  lpBackupEdit        AS DWORD  'lpFileName,1
  lpGetFileType       AS DWORD  'lpFileName
  lpOutputSelect      AS DWORD  '(1,2 or 3)
  lpUpdateCtl         AS DWORD  'Handle of control
  lpShowBreakPoint    AS DWORD  'Breakpoint ID (0-255)
  lpUpdateVerInf      AS DWORD  'TRUE to export to output, FALSE to update rc file
  lpCloseProject      AS DWORD  'No parameters
  lpOpenProject       AS DWORD  'Parameter TRUE/FALSE, FALSE=Show open file dialog, TRUE=lpFileName set to project file
  lpExportDialog      AS DWORD  'Handle of mdi child, Save to rc file TRUE/FALSE
  lpDllProc           AS DWORD  'hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM,fHookFun:DWORD
  lpSetPropertyCbo    AS DWORD  'Index of selected
  lpAddTab            AS DWORD  'hMdiChild,lpFileName
  lpDelTab            AS DWORD  'hMdiChild
  lpSelTab            AS DWORD  'hMdiChild
  lpUpdateAll         AS DWORD  'Command (IDM_FILE_SAVEALLFILES, IDM_FILE_OPENFILE, IDM_FILE_CLOSEFILE, IDM_OPTION_COLORS, IDM_OPTION_FONT, IDM_OPTION_EDIT, %WM_PAINT, IDM_FORMAT_SHOWGRID)
  lpGetFileNameFromID AS DWORD  'nProjectFileID
  lpMenuRebuild       AS DWORD  'No parameters
  lpUpdateMRU         AS DWORD  'No parameters
  lpUpdateResource    AS DWORD  'TRUE to export to output, FALSE to update rc file
  lpUpdateStringTable AS DWORD  'TRUE to export to output, FALSE to update rc file
END TYPE                        'ADDINPROCS ends

'Structure pointed to on return from %AIM_GETDATA
TYPE ADDINDATA                'struct
  nRadASMVer        AS DWORD  'Version
  fMaximized        AS DWORD  'If TRUE top menu popups+1
  lpIniFile         AS DWORD  'Pointer to radasm.ini file
  lpProject         AS DWORD  'Pointer to project file (incl. path)
  lpProjectPath     AS DWORD  'Pointer to project path. Includes ending '\'
  lpFile            AS DWORD  'Pointer to FileName buffer
  lpApp             AS DWORD  'Pointer to App path (without ending "\")
  lpBin             AS DWORD  'Pointer to Binary path (without ending "\")
  lpAddIn           AS DWORD  'Pointer to AddIn path (without ending "\")
  lpHlp             AS DWORD  'Pointer to Help path (without ending "\")
  lpIncl            AS DWORD  'Pointer to Include path (without ending "\")
  lpLib             AS DWORD  'Pointer to Library path (without ending "\")
  lpPro             AS DWORD  'Pointer to Projects path (without ending "\")
  lpSnp             AS DWORD  'Pointer to Snipplets path (without ending "\")
  lpTpl             AS DWORD  'Pointer to Templates path (without ending "\")
  lpMac             AS DWORD  'Pointer to Keyboard Macro path (without ending "\")
  lpIniAsmFile      AS DWORD  'Pointer to masm/fasm/tasm ini file
  fProject          AS DWORD  'If TRUE a project is loaded
  lpLoadPath        AS DWORD  'Pointer to path where radasm was loaded
  lpCtlTypes        AS DWORD  'Pointer to TYPES struct (dialog edit)
  fResChanged       AS DWORD  'If TRUE resources are changed since last compile
  lpBreakPoint      AS DWORD  'Pointer to 256 breakpoint structs
  fResProject       AS DWORD  'If TRUE project has resource file.
  lpBreakPointVar   AS DWORD  'Pointer to breakpoint variables
  AsmFlag           AS DWORD  'If TRUE dblclicks in output window opens file.
  lpCharTab         AS DWORD  'Pointer to RAEdit's character table
  szAssembler       AS ASCIIZ * 16  'db 16 dup(0)
  lpPrpCboItems     AS DWORD  'Comma separated string containing property combo items
  fEditMax          AS DWORD  'If TRUE open mdi child maximized
  lpProjectFiles    AS DWORD  'Pointer to memory block containing project files
  hWordList         AS DWORD  'Handle of wordlist memory
  lpWordList        AS DWORD  'Pointer to wordlist memory
  rpProjectWordList AS DWORD  'Relative pointer into lpWordList, points to project code properties
  rpWordListPos     AS DWORD  'Relative pointer into lpWordList, points to free
  lpAddins          AS DWORD  'Pointer to addins structure
END TYPE                      'ADDINDATA ends

'Macro returns the value for given hooks
'(This macro will need to be expanded when hooks > 32)
'AddInHook MACRO hks:VARARG
'  LOCAL VAL
'  VAL = &H0
'  FOR hk,<&hks>
'    IFIDN <%AIM_COMMAND>,<hk>
'      VAL = VAL OR %RAM_COMMAND
'    ELSEIFIDN <%AIM_COMMANDDONE>,<hk>
'      VAL = VAL OR %RAM_COMMANDDONE
'    ELSEIFIDN <%AIM_CLOSE>,<hk>
'      VAL = VAL OR %RAM_CLOSE
'    ELSEIFIDN <%AIM_INITMENUPOPUP>,<hk>
'      VAL = VAL OR %RAM_INITMENUPOPUP
'    ELSEIFIDN <%AIM_MAKEBEGIN>,<hk>
'      VAL = VAL OR %RAM_MAKEBEGIN
'    ELSEIFIDN <%AIM_MAKEDONE>,<hk>
'      VAL = VAL OR %RAM_MAKEDONE
'    ELSEIFIDN <%AIM_PROJECTCLOSE>,<hk>
'      VAL = VAL OR %RAM_PROJECTCLOSE
'    ELSEIFIDN <%AIM_PROJECTCLOSED>,<hk>
'      VAL = VAL OR %RAM_PROJECTCLOSED
'    ELSEIFIDN <%AIM_CLIENTMOUSEMOVE>,<hk>
'      VAL = VAL OR %RAM_CLIENTMOUSEMOVE
'    ELSEIFIDN <%AIM_TIMER>,<hk>
'      VAL = VAL OR %RAM_TIMER
'    ELSEIFIDN <%AIM_CTLDBLCLK>,<hk>
'      VAL = VAL OR %RAM_CTLDBLCLK
'    ELSEIFIDN <%AIM_CREATENEWDLG>,<hk>
'      VAL = VAL OR %RAM_CREATENEWDLG
'    ELSEIFIDN <%AIM_CONTEXTMENU>,<hk>
'      VAL = VAL OR %RAM_CONTEXTMENU
'    ELSEIFIDN <%AIM_PROJECTOPENED>,<hk>
'      VAL = VAL OR %RAM_PROJECTOPENED
'    ELSEIFIDN <%AIM_MENUREBUILD>,<hk>
'      VAL = VAL OR %RAM_MENUREBUILD
'    ELSEIFIDN <%AIM_EDITOPEN>,<hk>
'      VAL = VAL OR %RAM_EDITOPEN
'    ELSEIFIDN <%AIM_EDITCLOSE>,<hk>
'      VAL = VAL OR %RAM_EDITCLOSE
'    ELSEIFIDN <%AIM_EDITCLOSED>,<hk>
'      VAL = VAL OR %RAM_EDITCLOSED
'    ELSEIFIDN <%AIM_EDITSAVE>,<hk>
'      VAL = VAL OR %RAM_EDITSAVE
'    ELSEIFIDN <%AIM_EDITSAVED>,<hk>
'      VAL = VAL OR %RAM_EDITSAVED
'    ELSEIFIDN <%AIM_TBRTOOLTIP>,<hk>
'      VAL = VAL OR %RAM_TBRTOOLTIP
'    ELSEIFIDN <%AIM_MDIACTIVATE>,<hk>
'      VAL = VAL OR %RAM_MDIACTIVATE
'    ELSEIFIDN <%AIM_EDITSELCHANGE>,<hk>
'      VAL = VAL OR %RAM_EDITSELCHANGE
'    ELSEIFIDN <%AIM_PROJECTADDNEW>,<hk>
'      VAL = VAL OR %RAM_PROJECTADDNEW
'    ELSEIFIDN <%AIM_PROJECTREMOVE>,<hk>
'      VAL = VAL OR %RAM_PROJECTREMOVE
'    ELSEIFIDN <%AIM_DLGMNUSELECT>,<hk>
'      VAL = VAL OR %RAM_DLGMNUSELECT
'    ELSEIFIDN <%AIM_RCUPDATE>,<hk>
'      VAL = VAL OR %RAM_RCUPDATE
'    ELSEIFIDN <%AIM_CREATENEWCTL>,<hk>
'      VAL = VAL OR %RAM_CREATENEWCTL
'    ELSEIFIDN <%AIM_TOOLSHOW>,<hk>
'      VAL = VAL OR %RAM_TOOLSHOW
'    ELSEIFIDN <%AIM_SETSTYLE>,<hk>
'      VAL = VAL OR %RAM_SETSTYLE
'    ELSEIFIDN <%AIM_OUTPUTDBLCLK>,<hk>
'      VAL = VAL OR %RAM_OUTPUTDBLCLK
'    ELSEIFIDN <%AIM_CODEINFO>,<hk>
'      VAL = VAL OR %RAM_CODEINFO
''    ELSEIFIDN <>,<hk>
''      val = val OR
'    ENDIF
'  ENDM
'  EXITM %val
'ENDM

'### NOTE1: ###
'
'_____________________________________________________________________________
'
'You must copy your addin to C:\RadASM\AddIns
'and edit RadASM.ini and add your addin to:
'
'[AddIns]
';FlipCase,x (1=Flip case, 2=Auto Show/Hide Output,
';4=Auto Show/Hide ToolBox, 8=Save temp file, 16=PageBreak, 32 Output mouse show, 63=All)
'1=FlipCase.dll,63
'2=MyAddin.dll,1
'_____________________________________________________________________________
'
'  ;Shows how to output text
'
'  mov     eax,[lpDStruct]
'  push  (ADDINDATA ptr [eax]).lpProjectPath
'  mov     eax,[lpPStruct]
'  call  (ADDINPROCS ptr [eax]).lpTextOut
'
'
'  ;Shows how to output eax as hex
'
'  push  eax
'  mov     eax,[lpPStruct]
'  call  (ADDINPROCS ptr [eax]).lpHexOut
'
'
'  ;Shows how to clear output
'
'  mov     eax,[lpPStruct]
'  call  (ADDINPROCS ptr [eax]).lpClearOut
'
'
'  ;Shows how to add a project file
'
'  push  TRUE  ;FALSE if not to add to TreeView
'  push  offset szFileName
'  mov     eax,[lpPStruct]
'  call  (ADDINPROCS ptr [eax]).lpAddProjectFile
'
'
'  ;Shows how to open or bring to front a file
'
'  ;Copy project path to lpFile
'  mov     eax,[lpDStruct]
'  mov     edx,(ADDINDATA ptr [eax]).lpFile
'  mov     eax,(ADDINDATA ptr [eax]).lpProjectPath
'  invoke lstrcpy,edx,eax
'  ;Add project path and MyFile to lpFile
'  mov     eax,[lpDStruct]
'  mov     edx,(ADDINDATA ptr [eax]).lpFile
'  invoke lstrcat,edx,addr MyFile
'  ;Open the file
'  mov     eax,[lpPStruct]
'  call  (ADDINPROCS ptr [eax]).lpOpenProjectFile
'_____________________________________________________________________________
'
'Tool messages.
'
'TLM_INIT      equ   1
'TLM_CREATE      equ   2
'
'TLM_DOCKING       equ   4
'TLM_HIDE      equ   5
'TLM_MOUSEMOVE     equ   6
'TLM_LBUTTONDOWN     equ   7
'TLM_LBUTTONUP     equ   8
'TLM_PAINT       equ   9
'TLM_SIZE      equ   10
'TLM_REDRAW      equ   11
'TLM_CAPTION       equ   12
'TLM_ADJUSTRECT    equ   13
'TLM_GET_VISIBLE     equ   14
'TLM_GET_STRUCT    equ   15
'TLM_MINIMIZE    equ   16
'
'Docking positions.
'
'TL_LEFT         equ   1
'TL_TOP        equ   2
'TL_RIGHT      equ   3
'TL_BOTTOM       equ   4
'
'
'Tool structure.
'
'TOOL struct
'  ID          dd ?
'  Caption         dd ?
'  Visible         dd ?
'  Docked        dd ?
'  Position      dd ?
'  IsChild         dd ?
'  dWidth        dd ?
'  dHeight         dd ?
'  fr          RECT <> ;Floating
'  dr          RECT <> ;Docked
'  wr          RECT <> ;Child window
'  rr          RECT <> ;Resize
'  tr          RECT <> ;Top
'  cr          RECT <> ;Caption
'  br          RECT <> ;Close button
'  dFocus        dd ?
'  dCurFlag      dd ?
'  hWin        dd ?
'  hCld        dd ?
'  lpfnOldCldWndProc   dd ?
'TOOL ends
'_____________________________________________________________________________
'
'Dialogbox editor.
'
'DLGHEAD struct
'  ver       dd ?        ;Set to 100
'  changed     dd ?        ;Set to FALSE
'  class     db 32 dup(?)    ;Set to Null string
'  menuid    db 32 dup(?)    ;Set to Null string
'  font    db 32 dup(?)    ;Set to "MS Sans Serif"
'  fontsize  dd ?        ;Set to 8
'  fontht    dd ?        ;Set to -10
'  undo    dd ?        ;Set to NULL
'  ctlid     dd ?        ;Set to 1001
'  hmnu    dd ?        ;Set to NULL
'  htlb    dd ?        ;Set to NULL
'  hstb    dd ?        ;Set to NULL
'  locked    dd ?        ;Set to TRUE or FALSE
'  spare1    dd ?        ;Set to NULL
'  spare2    dd ?        ;Set to NULL
'DLGHEAD ends

'DIALOG struct
'  hwnd    dd ?        ;Set to TRUE
'  partype     dd ?        ;Dialog=1, Controls=0
'  oldproc     dd ?        ;Set to NULL
'  hpar    dd ?        ;Set to NULL
'  hcld    dd ?        ;Set to NULL
'  style     dd ?        ;Set to desired style
'  exstyle     dd ?        ;Set to desired ex style
'  x       dd ?        ;X position in pixels
'  y       dd ?        ;Y position in pixels
'  ccx       dd ?        ;Width in pixels
'  ccy       dd ?        ;Height in pixels
'  caption     db MaxCap dup(?)  ;Caption max 240 char + terminating zero
'  ntype     dd ?        ;Follows ToolBox buttons Dialog=0, Edit=1, Static=2, GroupBox=3
'  spare1    dd ?        ;Set to NULL
'  tab       dd ?        ;Tab index, Dialog=0, First index=0
'  id      dd ?        ;Dialog / Controls ID
'  idname    db 32 dup(?)    ;ID Name, max 31 chars
'  undo    dd ?        ;Set to NULL
'  himg    dd ?        ;Set to NULL
'DIALOG ends
'
'Dialog editor Mdi child data.
'
'Retrived by GetWindowLong.
'GWL_USERDATA=hDialog
'GWL_ID>=ID_FIRSTCHILD
'0=ID_DIALOG (65502)
'4=hMem
'8=ReadOnly
'16=Project file ID
'20=ScrollX
'24=ScrollY
'____________________________________________________________________________
'
'Code / text editor Mdi child data.
'
'Retrived by GetWindowLong.
'GWL_USERDATA=hEdit
'GWL_ID>=ID_FIRSTCHILD
'0=ID_EDIT (65501) or ID_EDITTXT (65503)
'4=
'8=
'12=
'16=Project file ID
'20=OverWrite
'____________________________________________________________________________
'
'Resorces
'
'MENUFILE            equ 0
'MENUEDIT            equ 1
'MENUVIEW            equ 2
'MENUFORMAT            equ 3
'MENUPROJECT             equ 4
'MENUMAKE            equ 5
'MENUTOOL            equ 6
'MENUWINDOW            equ 7
'MENUOPTIONS             equ 8
'MENUMACRO             equ 9
'MENUHELP            equ 10
'
'ID_FIRSTCHILD           equ 65001
'ID_LASTCHILD          equ 65499
'ID_EDIT               equ 65501
'ID_DIALOG             equ 65502
'ID_EDITTXT            equ 65503
'ID_EDITSPLIT          equ 65504
'
'IDOK              equ 1
'IDCANCEL            equ 2
'IDUSE               equ 10
'IDI_MDIICO            equ 100
'IDB_MDITBR            equ 101
'IDB_MDITV             equ 102
'IDB_PROWIZ            equ 103
'IDB_TOOLBOX             equ 104
'IDB_MNUARROW          equ 105
'IDB_SPLASH            equ 106
'
'IDC_SPLICURV          equ 150
'IDC_SPLICURH          equ 151
'
'IDR_MDIMENU             equ 999
'IDM_FILE_NEWPROJECT         equ 40001
'IDM_FILE_OPENPROJECT      equ 40002
'IDM_FILE_CLOSEPROJECT       equ 40003
'IDM_FILE_NEWFILE        equ 40004
'IDM_FILE_OPENFILE         equ 40005
'IDM_FILE_CLOSEFILE        equ 40006
'IDM_FILE_SAVEFILE         equ 40007
'IDM_FILE_SAVEFILEAS         equ 40008
'IDM_FILE_SAVEALLFILES       equ 40009
'IDM_FILE_EXIT           equ 40010
'
'IDM_EDIT_UNDO           equ 41001
'IDM_EDIT_REDO           equ 41002
'IDM_EDIT_CUT          equ 41003
'IDM_EDIT_COPY           equ 41004
'IDM_EDIT_PASTE          equ 41005
'IDM_EDIT_DELETE           equ 41006
'IDM_EDIT_SELECTALL        equ 41007
'IDM_EDIT_FIND           equ 41008
'IDM_EDIT_FINDNEXT         equ 41009
'IDM_EDIT_FINDPREVIOUS       equ 41010
'IDM_EDIT_REPLACE        equ 41011
'IDM_EDIT_GOTOLINE         equ 41012
'IDM_EDIT_FINDWORD         equ 41101
'IDM_EDIT_FINDPROC         equ 41102
'IDM_EDIT_RETURN           equ 41103
'IDM_EDIT_NEXTBM           equ 41105
'IDM_EDIT_PREVIOUSBM         equ 41106
'IDM_EDIT_TOGGLEBM         equ 41104
'IDM_EDIT_CLEARBM        equ 41107
'IDM_EDIT_GOTOBM0        equ 41200
'IDM_EDIT_GOTOBM1        equ 41201
'IDM_EDIT_GOTOBM2        equ 41202
'IDM_EDIT_GOTOBM3        equ 41203
'IDM_EDIT_GOTOBM4        equ 41204
'IDM_EDIT_GOTOBM5        equ 41205
'IDM_EDIT_GOTOBM6        equ 41206
'IDM_EDIT_GOTOBM7        equ 41207
'IDM_EDIT_GOTOBM8        equ 41208
'IDM_EDIT_GOTOBM9        equ 41209
'IDM_EDIT_GOTOBMM0         equ 41300
'IDM_EDIT_GOTOBMM1         equ 41301
'IDM_EDIT_GOTOBMM2         equ 41302
'IDM_EDIT_GOTOBMM3         equ 41303
'IDM_EDIT_GOTOBMM4         equ 41304
'IDM_EDIT_GOTOBMM5         equ 41305
'IDM_EDIT_GOTOBMM6         equ 41306
'IDM_EDIT_GOTOBMM7         equ 41307
'IDM_EDIT_GOTOBMM8         equ 41308
'IDM_EDIT_GOTOBMM9         equ 41309
'
'IDM_VIEW_TOOLBAR        equ 42001
'IDM_VIEW_TOOLBOX        equ 42002
'IDM_VIEW_OUTPUTWINDOW       equ 42003
'IDM_VIEW_PROJECTBROWSER       equ 42004
'IDM_VIEW_PROPERTIES         equ 42005
'IDM_VIEW_STATUSBAR        equ 42006
'
'IDM_FORMAT_INDENT         equ 43001
'IDM_FORMAT_OUTDENT        equ 43002
'IDM_FORMAT_COMMENT        equ 43003
'IDM_FORMAT_UNCOMMENT      equ 43004
'IDM_FORMAT_SPCTOTAB         equ 43501
'IDM_FORMAT_TABTOSPC         equ 43502
'IDM_FORMAT_UCASE        equ 43503
'IDM_FORMAT_LCASE        equ 43504
'IDM_FORMAT_LOCKCONTROLS       equ 43005
'IDM_FORMAT_SENDTOBACK       equ 43006
'IDM_FORMAT_BRINGTOFRONT       equ 43007
'IDM_FORMAT_SHOWGRID         equ 43008
'
'IDM_PROJECT_ADDNEWASM       equ 44101
'IDM_PROJECT_ADDNEWINC       equ 44102
'IDM_PROJECT_ADDNEWRC      equ 44103
'IDM_PROJECT_ADDNEWTXT       equ 44104
'IDM_PROJECT_ADDNEWDIALOG    equ 44105
'IDM_PROJECT_ADDNEWMENU      equ 44106
'IDM_PROJECT_ADDEXISTINGFILE     equ 44201
'IDM_PROJECT_ADDEXISTINGDIALOG   equ 44202
'IDM_PROJECT_ADDEXISTINGMENU     equ 44203
'IDM_PROJECT_ADDEXISTINGVERINF   equ 44204
'IDM_PROJECT_ADDEXISTINGOBJ    equ 44205
'IDM_PROJECT_VERINF        equ 44002
'IDM_PROJECT_EXPORTTOOUTPUT    equ 44003
'IDM_PROJECT_REMOVE        equ 44004
'IDM_PROJECT_TEMPLATE      equ 44005
'IDM_PROJECT_OPTIONS         equ 44006
'IDM_TLINK_NOTE          equ 44701
'IDM_TLINK_BUG           equ 44702
'IDM_TLINK_TODO          equ 44703
'IDM_PROJECT_REFRESH         equ 44008
'
'IDM_TOOLS_SNIPLETS        equ 46001
'IDM_TOOLS_EXPORT        equ 46002
'
'IDM_WINDOW_SPLIT        equ 47009
'IDM_WINDOW_CLOSE        equ 47001
'IDM_WINDOW_CLOSEALL         equ 47002
'IDM_WINDOW_NEXTWINDOW       equ 47003
'IDM_WINDOW_PREVIOUS         equ 47004
'IDM_WINDOW_TILEHOR        equ 47005
'IDM_WINDOW_TILEVER        equ 47006
'IDM_WINDOW_CASCADE        equ 47007
'IDM_WINDOW_ARRANGEICONS       equ 47008
'
'IDM_OPTION_COLORS         equ 48001
'IDM_OPTION_FONT           equ 48002
'IDM_OPTION_EDIT           equ 48003
'IDM_OPTION_DIALOG         equ 48004
'IDM_OPTION_SNIPLET        equ 48005
'IDM_OPTION_PATHS        equ 48006
'IDM_OPTION_TOOLMNU        equ 48007
'IDM_OPTION_HELPMNU        equ 48008
'
'IDM_HELP_ABOUT          equ 49001
'
'IDM_MAKE_ASSEMBLE         equ 20002
'IDM_MAKE_BUILD          equ 20004
'IDM_MAKE_GO             equ 20005
'IDM_MAKE_RUN          equ 20006
'
'IDM_HELPF1            equ 41902
'IDM_HELPCF1             equ 41903
'IDM_HELPSF1             equ 41904
'IDM_HELPCSF1          equ 41905
