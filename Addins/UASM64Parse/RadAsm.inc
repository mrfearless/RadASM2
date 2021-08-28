;include file for building RadASM addins

RadASM_Version			equ 2210

;Assemblers
nMASM					equ 1
nTASM					equ 2
nFASM					equ 3
nGOASM					equ 4
nNASM					equ 5
nHLA					equ 6
nCPP					equ 7
nBCET					equ 8
nFP						equ 9
nOTHER					equ 99

;Messages to RadASM's mdi frame
AIM_GETHANDLES			equ WM_USER+50			;returns a poiner to a struct containing all useful handles:see structures below
AIM_GETPROCS			equ WM_USER+51			;returns a poiner to a struct containing some procs in RadASM:see structures below
AIM_GETDATA				equ WM_USER+52			;returns a poiner to a struct comtaining data pointers:see structures below
AIM_GETMENUID			equ WM_USER+53			;Returns a free menu id. If you need more than one just send the message again.

;Messages from RadASM to DllProc procedure
;Hook flag in eax
AIM_COMMAND				equ WM_COMMAND			;hWnd=Handle of mdi frame, wParam & lParam=as for WM_COMMAND
AIM_MAKEBEGIN			equ WM_USER+100			;hWnd=Handle of mdi frame, wParam=0, lParam=pointer to string containing commands
AIM_MAKEDONE			equ WM_USER+101			;hWnd=Handle of mdi frame, wParam=0, lParam=exit code
AIM_CLOSE				equ WM_CLOSE			;hWnd=Handle of mdi frame, wParam & lParam=as for WM_CLOSE
AIM_INITMENUPOPUP		equ WM_INITMENUPOPUP	;hWnd=Handle of mdi frame, wParam & lParam=as for WM_INITMENUPOPUP
AIM_COMMANDDONE			equ WM_USER+102			;hWnd=Handle of mdi frame, wParam & lParam=as for WM_COMMAND
AIM_PROJECTCLOSE		equ WM_USER+103			;hWnd=Handle of mdi frame, wParam=0, lParam=0
AIM_PROJECTCLOSED		equ WM_USER+104			;hWnd=Handle of mdi frame, wParam=0, lParam=0
AIM_CLIENTMOUSEMOVE		equ WM_USER+105			;hWnd=handle of client, wParam & lParam=as for WM_MOUSEMOVE
AIM_TIMER				equ WM_USER+106			;as for a TimerProc
AIM_CTLDBLCLK			equ WM_USER+107			;hWnd=handle of mdi child, wParam=handle of control, lParam=pointer to DIALOG structure
AIM_CREATENEWDLG		equ WM_USER+108			;hWnd=handle of mdi child, wParam=handle of dialog, lParam=pointer to filename
AIM_CONTEXTMENU			equ WM_USER+109			;hWnd=Handle of mdi frame, wParam & lParam=as for WM_CONTEXTMENU
AIM_PROJECTOPENED		equ WM_USER+110			;hWnd=handle of mdi frame, wParam=0, lParam=pointer to filename
AIM_MENUREBUILD			equ WM_USER+111			;hWnd=handle of menu, wParam=0, lParam=0
AIM_EDITOPEN			equ WM_USER+112			;hWnd=handle of mdi child, wParam=handle of edit, lParam=ID_EDIT or ID_EDITTXT
AIM_EDITCLOSE			equ WM_USER+113			;hWnd=handle of mdi child, wParam=handle of edit, lParam=ID_EDIT or ID_EDITTXT
AIM_EDITCLOSED			equ WM_USER+114			;hWnd=handle of mdi child, wParam=handle of edit, lParam=ID_EDIT or ID_EDITTXT
AIM_EDITSAVE			equ WM_USER+115			;hWnd=handle of mdi child, wParam=handle of edit, lParam=pointer to filename
AIM_EDITSAVED			equ WM_USER+116			;hWnd=handle of mdi child, wParam=handle of edit, lParam=pointer to filename
AIM_TBRTOOLTIP			equ WM_USER+117			;hWnd=handle of mdi frame, wParam=ID, lParam=0
AIM_MDIACTIVATE			equ WM_USER+118			;hWnd=handle of mdi child, wParam & lParam=same as for WM_MDIACTIVATE
AIM_EDITSELCHANGE		equ WM_USER+119			;hWnd=handle of mdi child, wParam=handle of edit, lParam=ID
AIM_PROJECTADDNEW		equ WM_USER+120			;hWnd=handle of mdi frame, wParam=type, lParam=pointer to filename
AIM_PROJECTREMOVE		equ WM_USER+121			;hWnd=handle of mdi frame, wParam=ProjectFileID, lParam=pointer to filename
AIM_DLGMNUSELECT		equ WM_USER+122			;hWnd=handle of mdi child, wParam=handle of dialog, lParam=pointer to MENUITEM structure
AIM_RCUPDATE			equ WM_USER+123			;hWnd=handle of dialog,wParam=type,lParam=pointer to memory
AIM_CREATENEWCTL		equ WM_USER+124			;hWnd=handle of mdi child, wParam=handle of dialog, lParam=pointer to DIALOG structure
AIM_TOOLSHOW			equ WM_USER+125			;hWnd=handle of tool,wParam=visible,lParam=ID
AIM_SETSTYLE			equ WM_USER+126			;hWnd=handle of property listbox, wParam=Pointer to DIALOG struct. lParam=TRUE if ExStyle
AIM_OUTPUTDBLCLK		equ WM_USER+127			;hWnd=handle of output, wParam & lParam=same as for WM_LBUTTONDBLCLK
AIM_CODEINFO			equ WM_USER+128			;hWnd=handle of mdi child, wParam=ID, lParam=pointer to word
;Hook flag in ecx
AIM_MODULEBUILD			equ WM_USER+129			;hWnd=handle of mdi frame,wParam=lpFileName(no ext), lParam=0
AIM_DIALOGOPEN			equ WM_USER+130			;hWnd=handle of mdi child,wParam=lpDlgMem, lParam=0
AIM_DIALOGSAVE			equ WM_USER+131			;hWnd=handle of mdi child,wParam=hFile, lParam=0
AIM_UNHOOK				equ WM_USER+132			;hWnd=handle of window to unhook,wParam=proc to unhook, lParam=previous proc
AIM_ADDINSLOADED		equ WM_USER+133			;hWnd=handle of mdi frame,wParam=0, lParam=0
AIM_LANGUAGECHANGE		equ WM_USER+134			;hWnd=handle of mdi frame,wParam=0, lParam=0
AIM_PROJECTOPEN			equ WM_USER+135			;hWnd=handle of mdi frame, wParam=0, lParam=pointer to filename
AIM_PROJECTRENAME		equ WM_USER+136			;hWnd=handle of mdi frame, wParam=pointer to old filename, lParam=pointer to new filename
AIM_EDITKEYDOWN			equ WM_USER+137			;hWnd=handle of edit window, wParam and lParam as WM_KEYDOWN
AIM_EDITCHAR			equ WM_USER+138			;hWnd=handle of edit window, wParam and lParam as WM_CHAR
AIM_PREPARSE			equ WM_USER+139			;hWnd=handle of mdi frame, wParam=project file number,lParam=pointer to file content
AIM_PARSEDONE			equ WM_USER+140			;hWnd=handle of mdi frame, wParam=project file number,lParam=pointer to file content
AIM_IMPORTED			equ WM_USER+141			;hWnd=handle of mdi frame, wParam=project file,lParam=string of zero terminated file names
AIM_RCSAVED				equ WM_USER+142			;hWnd=handle of mdi frame, wParam=nType,lParam=string of zero terminated file name
AIM_EDITMOUSEMOVE		equ WM_USER+143			;hWnd=handle of edit window, wParam and lParam as WM_MOUSEMOVE

;Return values (eax) from InstallDll procedure which tell RadASM which messages to send to your DllProc procedure,can be OR'ed
RAM_COMMAND				equ 00000001h			;AIM_COOMAND equ WM_COMMAND
RAM_COMMANDDONE			equ 00000002h			;AIM_COMMANDDONE
RAM_CLOSE				equ 00000004h			;AIM_CLOSE equ WM_CLOSE			
RAM_INITMENUPOPUP		equ 00000008h			;AIM_INITMENUPOPUP equ WM_INITMENUPOPUP	
RAM_MAKEBEGIN			equ 00000010h			;AIM_MAKEBEGIN		
RAM_MAKEDONE			equ 00000020h			;AIM_MAKEDONE		
RAM_PROJECTCLOSE		equ 00000040h			;AIM_PROJECTCLOSE	
RAM_PROJECTCLOSED		equ 00000080h			;AIM_PROJECTCLOSED
RAM_CLIENTMOUSEMOVE		equ 00000100h			;AIM_CLIENTMOUSEMOVE 
RAM_TIMER				equ 00000200h			;AIM_TIMER			
RAM_CTLDBLCLK			equ 00000400h			;AIM_CTLDBLCLK		
RAM_CREATENEWDLG		equ 00000800h			;AIM_CREATENEWDLG	
RAM_CONTEXTMENU			equ 00001000h			;AIM_CONTEXTMENU	    
RAM_PROJECTOPENED		equ 00002000h			;AIM_PROJECTOPENED
RAM_MENUREBUILD			equ 00004000h			;AIM_MENUREBUILD
RAM_EDITOPEN			equ 00008000h			;AIM_EDITOPEN
RAM_EDITCLOSE			equ 00010000h			;AIM_EDITCLOSE
RAM_EDITCLOSED			equ 00020000h			;AIM_EDITCLOSED
RAM_EDITSAVE			equ 00040000h			;AIM_EDITSAVE
RAM_EDITSAVED			equ 00080000h			;AIM_EDITSAVED
RAM_TBRTOOLTIP			equ 00100000h			;AIM_TBRTOOLTIP
RAM_MDIACTIVATE			equ 00200000h			;AIM_MDIACTIVATE
RAM_EDITSELCHANGE		equ 00400000h			;AIM_EDITSELCHANGE
RAM_PROJECTADDNEW		equ 00800000h			;AIM_PROJECTADDNEW
RAM_PROJECTREMOVE		equ 01000000h			;AIM_PROJECTREMOVE
RAM_DLGMNUSELECT		equ 02000000h			;AIM_DLGMNUSELECT
RAM_RCUPDATE			equ 04000000h			;AIM_RCUPDATE
RAM_CREATENEWCTL		equ 08000000h			;AIM_CREATENEWCTL
RAM_TOOLSHOW			equ 10000000h			;AIM_TOOLSHOW
RAM_SETSTYLE			equ 20000000h			;AIM_SETSTYLE
RAM_OUTPUTDBLCLK		equ 40000000h			;AIM_OUTPUTDBLCLK
RAM_CODEINFO			equ 80000000h			;AIM_CODEINFO

;Return values (ecx) from InstallDll procedure which tell RadASM which messages to send to your DllProc procedure,can be OR'ed
RAM_MODULEBUILD			equ 00000001h			;AIM_MODULEBUILD
RAM_DIALOGOPEN			equ 00000002h			;AIM_DIALOGOPEN
RAM_DIALOGSAVE			equ 00000004h			;AIM_DIALOGSAVE
RAM_UNHOOK				equ 00000008h			;AIM_UNHOOK
RAM_ADDINSLOADED		equ 00000010h			;AIM_ADDINSLOADED
RAM_LANGUAGECHANGE		equ 00000020h			;AIM_LANGUAGECHANGE
RAM_PROJECTOPEN			equ 00000040h			;AIM_PROJECTOPEN
RAM_PROJECTRENAME		equ 00000080h			;AIM_PROJECTRENAME
RAM_EDITKEYDOWN			equ 00000100h			;AIM_EDITKEYDOWN
RAM_EDITCHAR			equ 00000200h			;AIM_EDITCHAR
RAM_PREPARSE			equ 00000400h			;AIM_PREPARSE
RAM_PARSEDONE			equ 00000800h			;AIM_PARSEDONE
RAM_IMPORTED			equ 00001000h			;AIM_IMPORTED
RAM_RCSAVED				equ 00002000h			;AIM_RCSAVED
RAM_EDITMOUSEMOVE		equ 00004000h			;AIM_EDITMOUSEMOVE

;Structure pointed to on return from AIM_GETHANDLES 
ADDINHANDLES struct
	hWnd				dd 0					;Handle of mdi Frame
	hMenu				dd 0					;Handle of mdi Frame Menu
	hToolBar			dd 0					;Handle of mdi Frame ToolBar
	hStatus				dd 0					;Handle of mdi Frame StatusBar
	hClient				dd 0					;Handle of mdi client
	hMdiCld				dd 0					;Handle of topmost mdi Child window
	hEdit				dd 0					;Handle of topmost mdi Child RAEdit window
	hDialog				dd 0					;Handle of topmost mdi Child DialogBox window
	hSearch				dd 0					;Handle of search / replace dialog
	hGoTo				dd 0					;Handle of goto dialog
	hOut				dd 0					;Handle of output Static container
	hPbr				dd 0					;Handle of project Static container
	hTlb				dd 0					;Handle of toolbox Static container
	hPrp				dd 0					;Handle of properties Static container
	hPrpCbo				dd 0					;Handle of properties ComboBox
	hPrpLst				dd 0					;Handle of properties ListBox
	hPrpTxt				dd 0					;Handle of properties item Edit control
	hTxtLst				dd 0					;Handle of properties item ListBox
	hTxtBtn				dd 0					;Handle of properties item Button
	hLB					dd 0					;Handle of Api ListBox (CodeComplete). Same as hLBU or hLBS
	hTlt				dd 0					;Handle of Api Static (ToolTip)
	hInst				dd 0					;RadASM instance
	hToolMenu			dd 0					;Handle of RightClick Menu in project, properties and output window
	hTab				dd 0					;Handle of tab window
	hPbrTrv				dd 0					;Handle of project browser TreeView
	hPrpTbr				dd 0					;Handle of properties ToolBar
	hPbrTbr				dd 0					;Handle of project / file browser ToolBar
	hFileTrv			dd 0					;Handle of file browser TreeView
	hOutREd				dd 0					;Handle of active output RAEdit window
	hOut1				dd 0					;Handle of output#1 RAEdit window
	hOut2				dd 0					;Handle of output#2 RAEdit window
	hOut3				dd 0					;Handle of output#3 RAEdit window
	hOutBtn1			dd 0					;Handle of output button #1
	hOutBtn2			dd 0					;Handle of output button #2
	hOutBtn3			dd 0					;Handle of output button #3
	hDivider			dd 0					;Handle of divider line
	hSniplet			dd 0					;Handle of sniplet dialog
	hToolTip			dd 0					;Handle of toolbox button tooltip
	hLBU				dd 0					;Handle of unsorted listbox
	hLBS				dd 0					;Handle of sorted listbox
	hInf				dd 0					;Handle of infotool static container
	hInfEdt				dd 0					;Handle of infotool edit control
	hTl1				dd 0					;Handle of tool#1 static container
	hTl2				dd 0					;Handle of tool#2 static container
	hHexEd				dd 0					;Handle of topmost mdi Child RAHexEd window
	hAccel				dd 0					;RadASM Accelerators
	hTbrIml				dd 0					;Imagelist for the toolbars
	hTypeIml			dd 0					;Imagelist for the intellisense listboxes
	hPrpTxtMulti		dd 0					;Handle of properties item multiline Edit control
	hLBFont				dd 0					;Api listboxes
	hTTFont				dd 0					;Api tooltip
	hFont				dd 3 dup(0)				;Code edit Normal,Italic,Linenumber
	hFontTxt			dd 0					;Text edit
	hFontHex			dd 0					;Hex edit
	hFullScreen			dd 0					;Handle of fullscreen editing popup
	hFound				dd 0					;Handle of found mdi child
ADDINHANDLES ends

;Structure pointed to on return from AIM_GETPROCS
ADDINPROCS struct
	lpTextOut			dd 0					;Pointer to proc handeling text to output window. Push pointer to text before calling.
	lpHexOut			dd 0					;Pointer to proc handeling hex to output window. Use for debug. Push val before calling.
	lpClearOut			dd 0					;Pointer to proc clearing output
	lpAddProjectFile	dd 0					;lpFileName,fUpdateTree,fModule
	lpOpenProjectFile	dd 0					;Give error msg TRUE/FALSE, set lpFile to file to open
	lpToolMessage		dd 0					;Handle, message, lParam
	lpGetWordFromPos	dd 0					;Handle of RAEdit, returns pointer to word
	lpProFind			dd 0					;Pointer to a PROFIND struct
	lpGetWord			dd 0					;lpWord, returns pointer to word
	lpRemoveProjectPath	dd 0					;lpFileName, lpBuff, returns pointer to filename
	lpGetMainFile		dd 0					;lpFileExt
	lpSearchMem			dd 0					;hMem,lpFind,fMCase,fWWord
	lpProScan			dd 0					;lpFind,lpNot
	lpBackupEdit		dd 0					;lpFileName,1
	lpGetFileType		dd 0					;lpFileName
	lpOutputSelect		dd 0					;(1,2 or 3)
	lpUpdateCtl			dd 0					;Handle of control
	lpShowBreakPoint	dd 0					;Breakpoint ID (0-255)
	lpUpdateVerInf		dd 0					;TRUE to export to output, FALSE to update rc file
	lpCloseProject		dd 0					;No parameters
	lpOpenProject		dd 0					;Parameter TRUE/FALSE, FALSE=Show open file dialog, TRUE=lpFileName set to project file
	lpExportDialog		dd 0					;Handle of mdi child, Save to rc file TRUE/FALSE 
	lpDllProc			dd 0					;hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM,fHookFun:DWORD
	lpSetPropertyCbo	dd 0					;Index of selected
	lpAddTab			dd 0					;hMdiChild,lpFileName
	lpDelTab			dd 0					;hMdiChild
	lpSelTab			dd 0					;hMdiChild
	lpUpdateAll			dd 0					;Command (IDM_FILE_SAVEALLFILES, IDM_FILE_OPENFILE, IDM_FILE_CLOSEFILE, IDM_OPTION_COLORS, IDM_OPTION_FONT, IDM_OPTION_EDIT, WM_PAINT, IDM_FORMAT_SHOWGRID, FIND_OPEN_FILENAME(51000), IS_FILE_CHANGED(51001))
	lpGetFileNameFromID	dd 0					;nProjectFileID
	lpMenuRebuild		dd 0					;No parameters
	lpUpdateMRU			dd 0					;No parameters
	lpUpdateResource	dd 0					;TRUE to export to output, FALSE to update rc file
	lpUpdateStringTable	dd 0					;TRUE to export to output, FALSE to update rc file
	lpUpdateAccelerator	dd 0					;TRUE to export to output, FALSE to update rc file
	lpGetProjectFiles	dd 0					;Update project treeview, TRUE to auto open files
	lpToolBarStatus		dd 0					;Updates toolbar button status
	lpUpdateLanguage	dd 0					;TRUE to export to output, FALSE to update rc file
	lpGetLangString		dd 0					;lpApp,lpKey,lpStr,nCC
	lpSetLanguage		dd 0					;hWin,lpApp,fNoResize
	lpModalDialog		dd 0					;DialogBoxParam
	lpModelessDialog	dd 0					;CreateDialogParam
	lpUpdateSizeingRect	dd 0					;hWin, fReadOnly
	lpSaveEdit			dd 0					;hMdiCld
	lpSaveDialog		dd 0					;hMdiCld,FALSE
	lpSaveHexEdit		dd 0					;hMdiCld
	lpSetTextLink		dd 0					;nType (1-3)
	lpScanWord			dd 0					;lpWord, lpLine
	lpAddWordToWordList	dd 0					;nType,nOwner,pWords,nParts
	lpRefreshProperty	dd 0					;
ADDINPROCS ends

;Structure pointed to on return from AIM_GETDATA
ADDINDATA struct
	nRadASMVer			dd 0					;Version
	fMaximized			dd 0					;If TRUE top menu popups+1
	lpIniFile			dd 0					;Pointer to radasm.ini file
	lpProject			dd 0					;Pointer to project file
	lpProjectPath		dd 0					;Pointer to project path. Includes ending '\'
	lpFile				dd 0					;Pointer to FileName buffer
	lpApp				dd 0					;Pointer to App path
	lpBin				dd 0					;Pointer to Binary path
	lpAddIn				dd 0					;Pointer to AddIn path
	lpHlp				dd 0					;Pointer to Help path
	lpIncl				dd 0					;Pointer to Include path
	lpLib				dd 0					;Pointer to Library path
	lpPro				dd 0					;Pointer to Projects path
	lpSnp				dd 0					;Pointer to Snipplets path
	lpTpl				dd 0					;Pointer to Templates path
	lpMac				dd 0					;Pointer to Keyboard Macro path
	lpIniAsmFile		dd 0					;Pointer to masm/fasm/tasm ini file
	fProject			dd 0					;If TRUE a project is loaded
	lpLoadPath			dd 0					;Pointer to path where radasm was loaded
	lpCtlTypes			dd 0					;Pointer to TYPES struct (dialog edit)
	fResChanged			dd 0					;If TRUE resources are changed since last compile
	lpBreakPoint		dd 0					;Pointer to 256 breakpoint structs
	fResProject			dd 0					;If TRUE project has resource file.
	lpBreakPointVar		dd 0					;Pointer to breakpoint variables
	AsmFlag				dd 0					;If TRUE dblclicks in output window opens file.
	lpCharTab			dd 0					;Pointer to RAEdit's character table
	szAssembler			db 16 dup(0)
	lpPrpCboItems		dd 0					;Comma separated string containing property combo items
	fEditMax			dd 0					;If TRUE open mdi child maximized
	lpProjectFiles		dd 0					;Pointer to memory block containing project files
	hWordList			dd 0					;Handle of wordlist memory
	lpWordList			dd 0					;Pointer to wordlist memory
	rpProjectWordList	dd 0					;Relative pointer into lpWordList, points to project code properties
	rpWordListPos		dd 0					;Relative pointer into lpWordList, points to free
	lpAddins			dd 0					;Pointer to addins structure
	rpStructList		dd 0					;Relative pointer into lpWordList, points to structures
	lpszAppName			dd 0					;Pointer to AppName string
	lpDbg				dd 0					;Pointer to Debug path
	lpCurPro			dd 0					;Pointer to Current Project path
	lpszAclKeys			dd 0					;Pointer to accelerator definitions
	UserBtnID			dd 0					;Pointer to first user button ID
	nAsm				dd 0					;Current assembler(nMASM, nTASM....)
	fNT					dd 0					;TRUE if on NT platform
	lpRABlockdef		dd 0					;Pointer to block defs
	TabSize				dd 0					;Number of space chars in a tab char
	ShowApiList			dd 0					;If TRUE RadASM will show listbox on api's and procs.
	ShowApiStruct		dd 0					;If TRUE RadASM will show listbox on structure items.
	ShowApiToolTip		dd 0					;If TRUE RadASM will show tooltip on api's and procs.
	fLB					dd 0					;RadASM is showing the listbox.
	fTlt				dd 0					;RadASM is showing the tooltip.
	lpSRCFilterString	dd 0
	lpDefSrcExt			dd 0      
	lpHDRFilterString	dd 0
	lpDefHdrExt			dd 0      
	lpMODFilterString	dd 0
	lpDefModExt			dd 0      
ADDINDATA ends

;Addin options
ADDINOPT struct
	lpStr				dd ?					;Pointer to description string
	nAnd				dd ?					;AND value
	nOr					dd ?					;OR value
ADDINOPT ends

;Macro returns the value for given hooks
;(This macro will need to be expanded when hooks > 32)
AddInHook MACRO hks:VARARG
	LOCAL val
	val = 0
	FOR hk,<&hks>
		IFIDN <AIM_COMMAND>,<hk>
			val = val OR RAM_COMMAND
		ELSEIFIDN <AIM_COMMANDDONE>,<hk>
			val = val OR RAM_COMMANDDONE
		ELSEIFIDN <AIM_CLOSE>,<hk>
			val = val OR RAM_CLOSE
		ELSEIFIDN <AIM_INITMENUPOPUP>,<hk>
			val = val OR RAM_INITMENUPOPUP
		ELSEIFIDN <AIM_MAKEBEGIN>,<hk>
			val = val OR RAM_MAKEBEGIN
		ELSEIFIDN <AIM_MAKEDONE>,<hk>
			val = val OR RAM_MAKEDONE
		ELSEIFIDN <AIM_PROJECTCLOSE>,<hk>
			val = val OR RAM_PROJECTCLOSE
		ELSEIFIDN <AIM_PROJECTCLOSED>,<hk>
			val = val OR RAM_PROJECTCLOSED
		ELSEIFIDN <AIM_CLIENTMOUSEMOVE>,<hk>
			val = val OR RAM_CLIENTMOUSEMOVE
		ELSEIFIDN <AIM_TIMER>,<hk>
			val = val OR RAM_TIMER
		ELSEIFIDN <AIM_CTLDBLCLK>,<hk>
			val = val OR RAM_CTLDBLCLK
		ELSEIFIDN <AIM_CREATENEWDLG>,<hk>
			val = val OR RAM_CREATENEWDLG
		ELSEIFIDN <AIM_CONTEXTMENU>,<hk>
			val = val OR RAM_CONTEXTMENU
		ELSEIFIDN <AIM_PROJECTOPENED>,<hk>
			val = val OR RAM_PROJECTOPENED
		ELSEIFIDN <AIM_MENUREBUILD>,<hk>
			val = val OR RAM_MENUREBUILD
		ELSEIFIDN <AIM_EDITOPEN>,<hk>
			val = val OR RAM_EDITOPEN
		ELSEIFIDN <AIM_EDITCLOSE>,<hk>
			val = val OR RAM_EDITCLOSE
		ELSEIFIDN <AIM_EDITCLOSED>,<hk>
			val = val OR RAM_EDITCLOSED
		ELSEIFIDN <AIM_EDITSAVE>,<hk>
			val = val OR RAM_EDITSAVE
		ELSEIFIDN <AIM_EDITSAVED>,<hk>
			val = val OR RAM_EDITSAVED
		ELSEIFIDN <AIM_TBRTOOLTIP>,<hk>
			val = val OR RAM_TBRTOOLTIP
		ELSEIFIDN <AIM_MDIACTIVATE>,<hk>
			val = val OR RAM_MDIACTIVATE
		ELSEIFIDN <AIM_EDITSELCHANGE>,<hk>
			val = val OR RAM_EDITSELCHANGE
		ELSEIFIDN <AIM_PROJECTADDNEW>,<hk>
			val = val OR RAM_PROJECTADDNEW
		ELSEIFIDN <AIM_PROJECTREMOVE>,<hk>
			val = val OR RAM_PROJECTREMOVE
		ELSEIFIDN <AIM_DLGMNUSELECT>,<hk>
			val = val OR RAM_DLGMNUSELECT
		ELSEIFIDN <AIM_RCUPDATE>,<hk>
			val = val OR RAM_RCUPDATE
		ELSEIFIDN <AIM_CREATENEWCTL>,<hk>
			val = val OR RAM_CREATENEWCTL
		ELSEIFIDN <AIM_TOOLSHOW>,<hk>
			val = val OR RAM_TOOLSHOW
		ELSEIFIDN <AIM_SETSTYLE>,<hk>
			val = val OR RAM_SETSTYLE
		ELSEIFIDN <AIM_OUTPUTDBLCLK>,<hk>
			val = val OR RAM_OUTPUTDBLCLK
		ELSEIFIDN <AIM_CODEINFO>,<hk>
			val = val OR RAM_CODEINFO
;;		ELSEIFIDN <>,<hk>
;;			val = val OR 
		ENDIF
	ENDM
	EXITM %val
ENDM
