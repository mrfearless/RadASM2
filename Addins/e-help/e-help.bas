'***********************************************************************************************
' e-help for radasm         elisabeth (c) 2003
'***********************************************************************************************

#COMPILE DLL "c:\asm\addins\e-help.dll"

#INCLUDE "win32api.inc"
#INCLUDE "richedit.inc"
#INCLUDE "radasm.inc"

#RESOURCE "e-help.pbr"


GLOBAL hdllinst AS DWORD                              'dll instance handle
GLOBAL hhook    AS DWORD                              'hookhandle
GLOBAL whh      AS DWORD                              'handle winhelp
GLOBAL hhh      AS DWORD                              'handle htmlhelp
GLOBAL foption  AS LONG                               'option
GLOBAL char     AS LONG                               'comment character

GLOBAL h AS ADDINHANDLES PTR
GLOBAL p AS ADDINPROCS   PTR
GLOBAL d AS ADDINDATA    PTR

GLOBAL oldeditproc AS LONG

GLOBAL ini$                                           'current .ini file (incl. path)
GLOBAL rap$                                           'current .rap file
GLOBAL et$                                            'current error text

GLOBAL ass$                                           'current assembler help file
GLOBAL op$                                            'current opcode help file
GLOBAL win$                                           'win32api.hlp
GLOBAL msdn$                                          'msdn help file
GLOBAL sdk$                                           'sdk help file (incl. viewer)
GLOBAL rc$                                            'resource compiler help file
GLOBAL rad$                                           'radasm help file

GLOBAL kass$                                          'assembler keywords
GLOBAL kop$                                           'opcode keywords
GLOBAL krc$                                           'rc keywords

GLOBAL helpmin AS LONG                                'lowest help menu id
GLOBAL helpmax AS LONG                                'highest help menu id
GLOBAL help$()                                        'array for .hlp files (incl. path)


GLOBAL o() AS addinopt                                'arrange addinopts in memmory
GLOBAL t1 AS ASCIIZ * 20                              'must all be global, otherwise addin
GLOBAL t2 AS ASCIIZ * 20                              'manager cannot use it
GLOBAL t3 AS ASCIIZ * 20
GLOBAL t4 AS ASCIIZ * 20
GLOBAL t5 AS ASCIIZ * 20
GLOBAL t6 AS ASCIIZ * 20
GLOBAL t7 AS ASCIIZ * 20
GLOBAL t8 AS ASCIIZ * 20
GLOBAL t9 AS ASCIIZ * 20
GLOBAL t10 AS ASCIIZ * 20

GLOBAL cpos AS LONG                                   'comment position


TYPE HHkey DWORD
  cbStruct      AS LONG
  fReserved     AS LONG
  pszKeywords   AS ASCIIZ PTR
  pszUrl        AS LONG
  pszMsgText    AS LONG
  pszMsgTitle   AS LONG
  pszWindow     AS LONG
  fIndexOnFail  AS LONG
END TYPE


DECLARE FUNCTION HtmlHelp LIB "hhctrl.ocx" ALIAS "HtmlHelpA" ( BYVAL hwndCaller AS LONG, pszFile AS ASCIIZ, BYVAL uCommand AS LONG, BYVAL dwData AS LONG ) AS LONG


'***********************************************************************************************
'***********************************************************************************************


FUNCTION LIBMAIN(BYVAL hInstance   AS LONG, _
                 BYVAL fwdReason   AS LONG, _
                 BYVAL lpvReserved AS LONG) EXPORT AS LONG
'**********************************************************************************************
' dll entry
'***********************************************************************************************

  SELECT CASE fwdReason

    CASE %DLL_PROCESS_ATTACH

      hdllinst=hInstance

      LOCAL s$
      OPEN "c:\temp\edllhook.hdl" FOR BINARY AS #1
        GET$ #1,LOF(1),s$
        hhook=VAL(s$)
      CLOSE #1                                        'power basic doesn´t allow for shared data
                                                      'so we have to do it this way

      LIBMAIN = 1                       'success!
      EXIT FUNCTION

    CASE %DLL_PROCESS_DETACH
      LIBMAIN = 1                       'success!
      EXIT FUNCTION
    CASE %DLL_THREAD_ATTACH
      hdllinst=hInstance
      LIBMAIN = 1                       'success!
      EXIT FUNCTION
    CASE %DLL_THREAD_DETACH
      LIBMAIN = 1                       'success!
      EXIT FUNCTION
  END SELECT


END FUNCTION


'***********************************************************************************************


FUNCTION InstallDll ALIAS "InstallDll" (BYVAL hWin AS DWORD, BYVAL fOpt AS DWORD) EXPORT AS LONG
'***********************************************************************************************
' install callback from radasm
'***********************************************************************************************

  h=sendmessage(hwin,%AIM_GETHANDLES,0,0)
  p=sendmessage(hwin,%AIM_GETPROCS,0,0)
  d=sendmessage(hwin,%AIM_GETDATA,0,0)

  foption=fopt

  IF (foption AND 3) THEN
    FUNCTION = %RAM_OUTPUTDBLCLK OR %RAM_COMMAND OR %RAM_PROJECTOPENED OR %RAM_MENUREBUILD OR _
               %RAM_EDITOPEN                          'returned in eax
  ELSE
    FUNCTION = %RAM_OUTPUTDBLCLK OR %RAM_COMMAND OR %RAM_PROJECTOPENED OR %RAM_MENUREBUILD
  END IF

  IF (foption AND 1) THEN char=9                      'tab
  IF (foption AND 2) THEN char=11                     'ctrl+k
  IF (foption AND 4) THEN cpos=40                     'comment pos = 40
  IF (foption AND 8) THEN cpos=50                     'comment pos = 50
  IF (foption AND 16) THEN cpos=60                    'comment pos = 60

 !  mov ecx,0                          ;return 0 in ecx
 !  mov edx,0                          ;return 0 in edx


END FUNCTION


'***********************************************************************************************


FUNCTION GetOptions ALIAS "GetOptions" EXPORT AS LONG
'***********************************************************************************************
' options for addin manager
'***********************************************************************************************
DIM o(1 TO 11)                                        '11 addinopts in a row

  t1="Disable Comment"
  t2="<Tab> = Comment"
  t3="<Ctrl+K> = Commment"
  t4="Comment Pos. = 40"
  t5="Comment Pos. = 50"
  t6="Comment Pos. = 60"
  t7="MSDN Help"
  t8="SDK Help"
  t9="WIN32 = F1"
  t10="MSDN/SDK = F1"

  o(1).lpStr=VARPTR(t1)   : o(1).nAnd=3    : o(1).nOr=0    'first one
  o(2).lpStr=VARPTR(t2)   : o(2).nAnd=3    : o(2).nOr=1    'second one
  o(3).lpStr=VARPTR(t3)   : o(3).nAnd=3    : o(3).nOr=2    'third
  o(4).lpStr=VARPTR(t4)   : o(4).nAnd=28   : o(4).nOr=4    '...
  o(5).lpStr=VARPTR(t5)   : o(5).nAnd=28   : o(5).nOr=8
  o(6).lpStr=VARPTR(t6)   : o(6).nAnd=28   : o(6).nOr=16
  o(7).lpStr=VARPTR(t7)   : o(7).nAnd=96   : o(7).nOr=32
  o(8).lpStr=VARPTR(t8)   : o(8).nAnd=96   : o(8).nOr=64
  o(9).lpStr=VARPTR(t9)   : o(9).nAnd=384  : o(9).nOr=128
  o(10).lpStr=VARPTR(t10) : o(10).nAnd=384 : o(10).nOr=256
'***********************************************************************************************
' not absolutly necessary, because dim o(1 to 11) initializes all elements to zero
'***********************************************************************************************
  o(11).lpStr=0           : o(11).nAnd=0   : o(11).nOr=0    'last


  FUNCTION=VARPTR(o(1).lpStr)                         'return address of first element


END FUNCTION


'***********************************************************************************************


SUB sethook
'*********************************************************************************************
' set mouse hook
'***********************************************************************************************
LOCAL n     AS LONG


  FOR n=1 TO 100                                      'wait for winhelp to start
    whh = findwindow("MS_WINHELP"+CHR$(0),BYVAL %null)
    IF whh<>0 THEN EXIT FOR
    SLEEP 50
  NEXT n

  IF whh<>0 THEN
    hhook = SetWindowsHookEx(%WH_MOUSE, CODEPTR(hook), hdllinst, getwindowthreadprocessid(whh, BYVAL %null))
  END IF

  OPEN "c:\temp\edllhook.hdl" FOR BINARY AS #1
    PUT$ #1,STR$(hhook)                               'store hookhandle for next instance
  CLOSE #1


END SUB


'***********************************************************************************************


FUNCTION hook ALIAS "hook" (BYVAL iCode AS INTEGER, BYVAL wParam AS LONG, BYREF lParam AS MOUSEHOOKSTRUCT) EXPORT AS LONG
'**********************************************************************************************
' hook procedure: winhelp mousehook
'**********************************************************************************************
STATIC ms AS INTEGER


  IF ((iCode < 0) OR (iCode <> %HC_ACTION)) THEN
    FUNCTION = CallNextHookEx(hhook, iCode, wParam, lParam)
    EXIT FUNCTION
  END IF

  IF wParam = %WM_MOUSEWHEEL THEN

    ms = ms + LOWRD(lParam.dwExtraInfo)

    WHILE  ms >= 40
      CALL keybd_event(17,29,0,0)                     '^
      CALL keybd_event(38,72,0,0)                     'up
      CALL keybd_event(38,72,%KEYEVENTF_KEYUP,0)
      CALL keybd_event(17,29,%KEYEVENTF_KEYUP,0)

      ms = ms - 40
    WEND

    WHILE ms <= -40
      CALL keybd_event(17,29,0,0)                     '^
      CALL keybd_event(40,80,0,0)                     'down
      CALL keybd_event(40,80,%KEYEVENTF_KEYUP,0)
      CALL keybd_event(17,29,%KEYEVENTF_KEYUP,0)

      ms = ms + 40
    WEND


    FUNCTION = 1
    EXIT FUNCTION

  END IF


  FUNCTION = CallNextHookEx(hhook, iCode, wParam, lParam)


END FUNCTION


'**********************************************************************************************


SUB gethelpfiles
'***********************************************************************************************
' load path + filename of .hlp helpfiles in array, whose index is the
' corresponding menu identifier
'***********************************************************************************************
LOCAL hsubmenu AS DWORD
LOCAL n        AS LONG
LOCAL i        AS LONG
LOCAL id       AS LONG
LOCAL s        AS ASCIIZ * 512


  IF @d.fMaximized THEN
    hsubmenu=getsubmenu(@h.hMenu,11)
  ELSE
    hsubmenu=getsubmenu(@h.hMenu,10)
  END IF


    helpmin=getmenuitemid(hsubmenu,2)                 'first helpfile (position=zerobased)
    n=getmenuitemcount(hsubmenu)                      'items count (incl. separator, not
                                                      'zerobased !!)

    REDIM help$(helpmin:helpmin+n-3)

    FOR i=2 TO n-1                                    'scan all items
      id=getmenuitemid(hsubmenu,i)                    'get menuitemid
      IF id>20000 THEN                                'if not separator
        CALL getprivateprofilestring("MenuHelp",STR$(i-1)," ",s,512,ini$+CHR$(0))
        s=UCASE$(s)                                   'get corresponding string from .ini file
        IF RIGHT$(s,4)=".HLP" THEN                    'if it is a .hlp file
          help$(id)=PARSE$(s,-1)                      'get path+filename into array
          CALL expandpath(help$(id))                  'expand path
          helpmax=id                                  'set last helpfile id
        ELSE
          help$(id)=""                                'if it is not a .hlp file, set nullstring
        END IF
      END IF
    NEXT i


END SUB


'***********************************************************************************************


SUB expandpath(d$)
'***********************************************************************************************
' expand radasm shortcuts ($...) to full path
'***********************************************************************************************
LOCAL sb    AS ASCIIZ PTR
LOCAL sd    AS ASCIIZ PTR
LOCAL sh    AS ASCIIZ PTR
LOCAL sr    AS ASCIIZ PTR
LOCAL sa    AS ASCIIZ PTR


  sr=@d.lpLoadPath                                    'pointer to radasm path
  sa=@d.lpApp                                         'Pointer to App path
  sb=@d.lpBin                                         'Pointer to Binary path
  sd=@d.lpAddIn                                       'Pointer to AddIn path
  sh=@d.lpHlp                                         'Pointer to Help path


  REPLACE "$B" WITH @sb IN d$                         'order of replacement is important !!!
  REPLACE "$D" WITH @sd IN d$                         'because "$B" or other might be specified
  REPLACE "$H" WITH @sh IN d$                         'using "$A" or "$R"
  REPLACE "$R" WITH @sr IN d$
  REPLACE "$A" WITH @sa IN d$


END SUB


'***********************************************************************************************


SUB init
'***********************************************************************************************
' initialize variables for current project
'***********************************************************************************************
LOCAL s     AS ASCIIZ * 4096
LOCAL p     AS ASCIIZ PTR



  p=@d.lpIniAsmFile
  ini$=@p                                             'ini$=path+filename of assembler .ini file

  p=@d.lpProject
  rap$=@p                                            'rap$=path+filename of project file

  CALL getprivateprofilestring("Error","Text"," ",s,512,BYCOPY ini$)
  et$=s                                               'path + filename of errortext
  CALL expandpath(et$)

  OPEN et$ FOR BINARY AS #1
    SEEK #1, 1
    GET$ #1, LOF(1), et$                              'errortext
  CLOSE #1

  CALL getprivateprofilestring("HelpFiles","1"," ",s,512,ini$+CHR$(0))
  ass$=s                                              'assembler help
  CALL expandpath(ass$)

  CALL getprivateprofilestring("HelpFiles","2"," ",s,512,ini$+CHR$(0))
  op$=s                                               'opcodes help
  CALL expandpath(op$)

  CALL getprivateprofilestring("HelpFiles","3"," ",s,512,ini$+CHR$(0))
  win$=s                                              'win32api.hlp
  CALL expandpath(win$)

  CALL getprivateprofilestring("HelpFiles","4"," ",s,512,ini$+CHR$(0))
  msdn$=s                                             'msdn help
  CALL expandpath(msdn$)

  CALL getprivateprofilestring("HelpFiles","5"," ",s,512,ini$+CHR$(0))
  rc$=s                                               'rc help
  CALL expandpath(rc$)

  CALL getprivateprofilestring("HelpFiles","6"," ",s,512,ini$+CHR$(0))
  rad$=s                                              'radasm help
  CALL expandpath(rad$)

  CALL getprivateprofilestring("HelpFiles","7"," ",s,512,ini$+CHR$(0))
  sdk$=s                                              'sdk help
  CALL expandpath(sdk$)


  CALL getprivateprofilestring("KeyWords","C1"," ",s,4096,ini$+CHR$(0))
  kop$=" "+UCASE$(s)                                  'opcode keywords
  CALL getprivateprofilestring("KeyWords","C2"," ",s,4096,ini$+CHR$(0))
  kop$=kop$+" "+UCASE$(s)                             'opcode keywords
  CALL getprivateprofilestring("KeyWords","C3"," ",s,4096,ini$+CHR$(0))
  kop$=kop$+" "+UCASE$(s)                             'opcode keywords
  CALL getprivateprofilestring("KeyWords","C4"," ",s,4096,ini$+CHR$(0))
  kop$=kop$+" "+UCASE$(s)+" "                         'opcode keywords


  CALL getprivateprofilestring("KeyWords","C10"," ",s,4096,ini$+CHR$(0))
  krc$=" "+UCASE$(s)+" "                              'rc keywords


  CALL getprivateprofilestring("KeyWords","C5"," ",s,4096,ini$+CHR$(0))
  kass$=" "+UCASE$(s)                                 'assembler keywords
  CALL getprivateprofilestring("KeyWords","C6"," ",s,4096,ini$+CHR$(0))
  kass$=kass$+" "+UCASE$(s)                           'assembler keywords
  CALL getprivateprofilestring("KeyWords","C7"," ",s,4096,ini$+CHR$(0))
  kass$=kass$+" "+UCASE$(s)                           'assembler keywords
  CALL getprivateprofilestring("KeyWords","C8"," ",s,4096,ini$+CHR$(0))
  kass$=kass$+" "+UCASE$(s)                           'assembler keywords
  CALL getprivateprofilestring("KeyWords","C9"," ",s,4096,ini$+CHR$(0))
  kass$=kass$+" "+UCASE$(s)+" "                       'assembler keywords


END SUB


'***********************************************************************************************


FUNCTION window AS LONG
'***********************************************************************************************
' get type of current window, 1=edit code, 2=edit text, 0=other
'***********************************************************************************************
LOCAL hedit AS DWORD
LOCAL id    AS LONG

  hedit=@h.hEdit                                      'handle of raedit (not raeditchild !!!,
                                                      'which is the actual edit control)

  IF hedit=getparent(getfocus) THEN                   'if raeditchild has focus
    id=getwindowlong(getparent(hedit),0)              'mdi (=parent) tells, what kind of edit

    IF id=%id_edit THEN
      FUNCTION=1
    ELSEIF id=%id_edittxt THEN
      FUNCTION=2
    END IF
  ELSE
    FUNCTION=0
  END IF


END FUNCTION


'***********************************************************************************************


FUNCTION errline AS LONG
'***********************************************************************************************
' is caret on error line ?  return %true if so, otherwise return false
'***********************************************************************************************
LOCAL hedit AS DWORD
LOCAL c1     AS charrange
LOCAL li     AS LONG

  hedit=@h.hEdit                                      'handle of raedit (not raeditchild !!!,


  CALL sendmessage(hedit, %EM_EXGETSEL,0,VARPTR(c1))
  li = sendmessage(hedit, %EM_EXLINEFROMCHAR,0,c1.cpmin)

  IF sendmessage(hedit, %REM_GETHILITELINE, li, 0)=1 THEN
    FUNCTION=%true
  ELSE
    FUNCTION=%false
  END IF


END FUNCTION


'***********************************************************************************************


FUNCTION getkeyword AS STRING
'***********************************************************************************************
' get and return keyword from code edit control, if no keyword specified, return ""
'***********************************************************************************************
LOCAL hedit AS DWORD
LOCAL n     AS LONG
LOCAL a     AS LONG
LOCAL e     AS LONG
LOCAL li    AS LONG                                   'linenumber
LOCAL c     AS charrange
LOCAL s     AS ASCIIZ * 256                           'string
LOCAL k$                                              'keyword


  hedit=@h.hEdit                                      'handle of raedit (not raeditchild !!!,

  CALL sendmessage(hedit, %EM_EXGETSEL,0,VARPTR(c))
  li = sendmessage(hedit, %EM_EXLINEFROMCHAR,0,c.cpmin)
  n  = sendmessage(hedit, %EM_LINEINDEX,li,0)
  n  = c.cpmin-n+1

  s=CHR$(255)                                         'first word = max. chars to be copied
  CALL sendmessage(hedit, %EM_GETLINE,li,VARPTR(s))
  k$=s

  e=INSTR(n,k$,ANY " =.,;:()[]'"+CHR$(34)+CHR$(13)+$TAB)   'end (using separator to the right)
  IF e<=0 THEN e=LEN(k$)+1
  a=INSTR(n-LEN(k$)-2,k$,ANY " =,;:()[]'"+CHR$(34)+$TAB)+1 'begin (using separator to the left)
  IF a<=0 THEN a=1

  k$=UCASE$(MID$(k$,a,e-a))                           'keyword

  IF k$<>"" AND k$<>CHR$(255) THEN                    'must not be "" or chr$(255)
    FUNCTION=k$
  ELSE
    FUNCTION=""
  END IF


END FUNCTION


'***********************************************************************************************


SUB helpchain(s AS ASCIIZ)
'***********************************************************************************************
' show help for given keyword
'***********************************************************************************************
LOCAL t    AS ASCIIZ * 512


  CALL getwindowtext(@h.hWnd,t,512)                   'get caption of mdi frame

  whh = findwindow("MS_WINHELP"+CHR$(0),BYVAL %null)  'is winhelp already running ?

  IF INSTR(UCASE$(t),".RC]")>0 THEN                   'if .rc file
    IF INSTR(krc$," "+s+" ")>0 THEN
      CALL showhelp(rc$,s)
    ELSE
      IF (foption AND 128) THEN                       'WIN32 = F1
        CALL showhelp(win$,s)
      ELSEIF (foption AND 256) THEN                   'MSDN/SDK = F1
        IF (foption AND 32) THEN                      'msdn help
          CALL showhelp(msdn$,s)
        ELSEIF (foption AND 64) THEN                  'sdk help
          CALL showhelp(sdk$,s)
        END IF
      END IF
    END IF
  ELSE                                                'otherwise
    IF INSTR(kass$," "+s+" ")>0 THEN
      CALL showhelp(ass$,s)
    ELSEIF INSTR(kop$," "+s+" ")>0 THEN
      CALL showhelp(op$,s)
    ELSE
      IF (foption AND 128) THEN                       'WIN32 = F1
        CALL showhelp(win$,s)
      ELSEIF (foption AND 256) THEN                   'MSDN/SDK = F1
        IF (foption AND 32) THEN                      'msdn help
          CALL showhelp(msdn$,s)
        ELSEIF (foption AND 64) THEN                  'sdk help
          CALL showhelp(sdk$,s)
        END IF
      END IF
    END IF
  END IF

  IF whh=0 THEN sethook                               'hook if there was no hook and if a .hlp
                                                      'was invoked
                                                                                                            '
END SUB


'***********************************************************************************************


SUB showhelp(helpfile$, s AS ASCIIZ)
'***********************************************************************************************
' allow for different types of help files
'***********************************************************************************************
LOCAL key AS HHkey
LOCAL res AS LONG                                     'dummy
LOCAL s1$


  s1$=UCASE$(PARSE$(helpfile$,".",-1))
  SELECT CASE s1$
    CASE "HLP"
      CALL winhelp(0, helpfile$+CHR$(0),%HELP_partialKEY,VARPTR(s))

    CASE "COL","CHM"
      whh=1                                           'set flag (hook only .hlp files)

      key.cbStruct    = SIZEOF(key)
      key.fReserved   = %FALSE
      key.pszKeywords = VARPTR(s)
      key.pszUrl      = 0
      key.pszMsgText  = 0
      key.pszMsgTitle = 0
      key.pszWindow   = 0
      key.fIndexOnFail =%FALSE

      IF iswindow(hhh) THEN
        CALL HtmlHelp (0, helpfile$+CHR$(0), &H0d, VARPTR(key))
      ELSE
        hhh=HtmlHelp (0, helpfile$+CHR$(0), 0, 0)
        CALL HtmlHelp (0, helpfile$+CHR$(0), &H0d, VARPTR(key))
      END IF

    CASE "1033"
      whh=1                                           'set flag (hook only .hlp files)
      res=SHELL(sdk$+" /filterquery /keyword "+CHR$(34)+"K$"+s+CHR$(34),1)

  END SELECT


END SUB


'***********************************************************************************************


SUB showerr(er$,text$,nerr AS LONG)
'***********************************************************************************************
' show error for given error string (er$), display error message, if there is one (text$)
' nerr=0 -> only 1 error for this line, nerr>0 there are more than 1 errors reported for this
' line
'***********************************************************************************************
LOCAL i AS LONG
LOCAL n AS LONG
LOCAL c$


  c$=LEFT$(er$,1)
  SELECT CASE c$                                      'who caused an error
    CASE "R"
      c$=" RC "
      i=3
    CASE "L"
      c$=" Linker "
      i=2
    CASE "A"
      c$=" Assembler "
      i=2
  END SELECT

  SELECT CASE MID$(er$,i,1)                           'what kind of error
    CASE "1"
      c$=c$+"fatal Error "
    CASE "2"
      c$=c$+"Error "
    CASE >"2"
      c$=c$+"Warning "
  END SELECT


'***********************************************************************************************
'
'***********************************************************************************************
  i=INSTR(et$,er$)                                    'look for description using error number
  IF i>0 THEN                                         'if there is a description for this number
    IF text$<>"" THEN                                 'if there is an error message text
      er$=UCASE$(EXTRACT$(text$,":"))                 'make header out of it
      IF INSTR(text$,":")>0 THEN er$=er$+":"+REMAIN$(text$,":")
      er$=er$+$CRLF+$CRLF                             'do some formatting
    ELSE                                              'otherwise use standart header
      i=INSTR(i+1,et$," ")
      er$=UCASE$(LTRIM$(EXTRACT$(i,et$,ANY ":"+CHR$(13)+CHR$(10))))+$CRLF+$CRLF
    END IF                                            'do some formatting

    i=INSTR(i,et$,CHR$(13)+CHR$(10))                  'get description using error number
    n=INSTR(i+2,et$,CHR$(13)+CHR$(10)+CHR$(13)+CHR$(10))
    er$=er$+MID$(et$,i+2,n-i-2)
  ELSE
    er$="No further Information for this Error Number"
  END IF


  IF nerr=0 THEN                                      'only 1 error
    CALL messagebox(getfocus,er$+CHR$(0), c$+CHR$(0), _
         %MB_Iconexclamation OR %MB_Applmodal)        'show error description

  ELSE                                                'more than 1 error
    c$=" ["+LTRIM$(STR$(nerr))+"] "+c$
    er$=er$+$CRLF+$CRLF+$CRLF+"There are more Errors reported for this Line."_
           +$CRLF+"Show next Error ?"

    IF messagebox(getfocus,er$+CHR$(0), c$+CHR$(0), _
       %MB_Iconexclamation OR %MB_Applmodal OR %MB_OkCancel)=%IDOK THEN

      nerr=nerr+1                                     'show next error
    ELSE
      nerr=0                                          'cancel
    END IF
  END IF


END SUB


'***********************************************************************************************


SUB finderr
'***********************************************************************************************
' find error(s) in output#1 for current code edit line
'***********************************************************************************************
LOCAL hedit AS DWORD
LOCAL hout1 AS DWORD
LOCAL a     AS LONG
LOCAL e     AS LONG
LOCAL li    AS LONG
LOCAL c     AS charrange
LOCAL s     AS ASCIIZ * 4096                          'string
LOCAL cerr  AS LONG                                   'count of errors for current line
LOCAL nerr  AS LONG                                   'current number of error for current line
LOCAL er$
LOCAL text$


  hedit=@h.hEdit                                      'handle of raedit (not raeditchild !!!,
  hout1=@h.hOut1                                      'handle of output#1

  CALL getwindowtext(hout1,s,4096)                    'text contents of output#1

  CALL sendmessage(hedit, %EM_EXGETSEL,0,VARPTR(c))
  li = sendmessage(hedit, %EM_EXLINEFROMCHAR,0,c.cpmin)
  li=li+1                                             'zerobased to base=1 (linenumber)

'***********************************************************************************************
' error reports in output#1 should have the following format
' <filename> (<linenumber>): error <errornumber> : <text>
' eg. test.rc (6): error RC2237 : numeric value expected at MOVEABLE
'***********************************************************************************************

  cerr=TALLY(s,"("+LTRIM$(STR$(li))+")")              'find number of errors for current line


  IF cerr=0 THEN                                      'if no error
    CALL messagebox(getfocus,"No Error found for this Line !"," RadAsm", _
         %MB_Iconexclamation OR %MB_Applmodal)
  ELSE
    IF cerr=1 THEN                                    'only 1 error
      nerr=0
    ELSE
      nerr=1                                          'more than 1 error, start with first one
    END IF
    a=1                                               'search start position (must not be "0")

    DO
      a=INSTR(a,s,"("+LTRIM$(STR$(li))+")")           'find "(<linenumber>)" in output#1, start
      a=INSTR(a,s,":")+1                              'at previous position to get next occurence
      e=INSTR(a,s,":")
      er$=MID$(s,a,e-a)
      er$=PARSE$(TRIM$(er$)," ",-1)                   'get error number
      text$=TRIM$(EXTRACT$(e+1,s,$CR))                'get error message

      CALL showerr(er$,text$,nerr)                    'show error
      IF nerr=0 THEN EXIT LOOP                        'cancel
      IF nerr>cerr THEN
        nerr=1                                        'wrap around
        a=1                                           'reset search start position
      END IF
    LOOP
  END IF


END SUB


'***********************************************************************************************


SUB radasmhelp
'***********************************************************************************************
' show radasmhelp
'***********************************************************************************************

  ShellExecute BYVAL %NULL, "open", rad$+CHR$(0), BYVAL %NULL, BYVAL %NULL, %SW_SHOWNORMAL


END SUB


'***********************************************************************************************


FUNCTION DllProc ALIAS "DllProc" (BYVAL hWin AS DWORD, BYVAL Msg AS DWORD, BYVAL wParam AS DWORD, BYVAL lParam AS DWORD) EXPORT AS LONG
'***********************************************************************************************
' This proc handles messages sent form RadASM to our DLL
' return %true to prevent RadASM and DLL's from processing this message
' normal exit: function=0
' goto done  : function=%true
'***********************************************************************************************
LOCAL p     AS ASCIIZ PTR                             'string pointer
LOCAL s     AS ASCIIZ * 2048                          'string
LOCAL res   AS LONG                                   'dummy
LOCAL hedit AS DWORD                                  'handle of edit control container


SELECT CASE msg

  CASE %AIM_EDITOPEN
    IF getwindowlong(hwin,0)=%ID_EDIT THEN
      hedit=GetWindowLong(hWin,%GWL_USERDATA)
      oldeditproc=SendMessage(hedit,%REM_SUBCLASS,0,CODEPTR(EditProc))
    END IF


  CASE %AIM_PROJECTOPENED
    CALL init                                         'initialize variables
    CALL gethelpfiles                                 'get .hlp files in help menu


  CASE %AIM_MENUREBUILD
    CALL gethelpfiles                                 'get .hlp files in help menu


  CASE %AIM_OUTPUTDBLCLK                              'Get dblclicked word
    CALL sendmessage(hWin, %REM_GETWORD ,SIZEOF(s),VARPTR(s))
    s=UCASE$(s)                                       'uppercase, check if it is an error number
    IF TALLY(LEFT$(s,1),ANY "ALR")=1 AND TALLY(RIGHT$(s,4),ANY "0123456789")=4 THEN
      CALL showerr(UCASE$(s),"",0)
      GOTO done
    END IF


  CASE %AIM_COMMAND                                   'hwin=mdi frame

    SELECT CASE LOWRD(wparam)
      CASE 41902                                      'F1
        IF window=1 THEN                              'if code window is active
          IF errline THEN                             'if current line is an error line
            CALL finderr                              'find and show corresponding error
            GOTO done
          END IF

          s=getkeyword                                'otherwise get keyword
          IF s<>"" THEN
            CALL helpchain(s)                         'and show help, if there is a keyword
            GOTO done
          END IF
        END IF

        CALL radasmhelp                               'if no keyword, show radasm help
        GOTO done


      CASE 41903                                      '^F1
        IF window=1 THEN                              'if code window is active
          s=getkeyword                                'get keyword
          IF s<>"" THEN
            IF (foption AND 256) THEN                 'MSDN/SDK = F1 -> WIN32 = Ctrl+F1
              CALL showhelp(win$,s)
            ELSEIF (foption AND 128) THEN             'WIN32 = F1 -> MSDN/SDK = Ctrl+F1
              IF (foption AND 32) THEN                'msdn help
                CALL showhelp(msdn$,s)
              ELSEIF (foption AND 64) THEN            'sdk help
                CALL showhelp(sdk$,s)
              END IF
            END IF
          END IF
        END IF
        GOTO done


      CASE helpmin TO helpmax
        IF help$(LOWRD(wparam))<>"" THEN
          whh = findwindow("MS_WINHELP"+CHR$(0),BYVAL %null)  'is winhelp already running ?
          s=help$(LOWRD(wparam))
          REPLACE ".HLP" WITH ".CNT" IN s             'look for a .cnt (contents) file
          IF DIR$(s)="" THEN                          'if not available, show init screen
            CALL winhelp(0, help$(LOWRD(wparam))+CHR$(0), %Help_Contents,0)
          ELSE                                        'if available show contents
            CALL winhelp(0, help$(LOWRD(wparam))+CHR$(0), %Help_Finder,0)
          END IF
          IF whh=0 THEN sethook                       'hook, if not already hooked
          GOTO done
        END IF


'     case ...

      CASE ELSE


  END SELECT


END SELECT


FUNCTION = 0                                          'allow addin or radasm further processing
EXIT FUNCTION


done:                                                 'don´t process any further (addins + radsam)
FUNCTION=%true


END FUNCTION


'***********************************************************************************************


FUNCTION comment(s AS ASCIIZ) AS LONG
'***********************************************************************************************
' edit line for comment: insert comment character if not yet there, bring comment to right
' position if already there, set caret after comment character
'***********************************************************************************************
LOCAL t     AS ASCIIZ * 256
LOCAL n     AS LONG                                   'current comment position
LOCAL k     AS LONG                                   'should be comment position
LOCAL flag  AS LONG
LOCAL d1$
LOCAL d2$
LOCAL co$                                             'comment character(s)


  CALL getwindowtext(@h.hWnd,t,255)                   'get caption of mdi frame
  IF INSTR(UCASE$(t),".RC]")>0 THEN                   'if .rc file
    flag=1
    n = INSTR(s,"//")                                 'rc
    k=cpos+15
    co$="//"
  ELSE                                                'otherwise
    flag=0
    n = INSTR(s,";")                                  'asm
    k=cpos
    co$=";"
  END IF


  SELECT CASE n
    CASE k                                            'comment is in correct position
      EXIT SELECT
    CASE 0                                            'there is no comment in this line
      IF LEN(s)>= k-1 THEN                            'if code text is too long
        s=s+" "+co$                                   'just append comment
      ELSE
        IF LEFT$(s,1)=CHR$(255) THEN                  'if line was an empty line
          s=SPACE$(k-2)+" "+co$+$CRLF                 'add cr+lf
        ELSE                                          'otherwise
          s=LEFT$(s+REPEAT$(k-2," "),k-2)+" "+co$     'add comment in right position
        END IF
      END IF
    CASE ELSE                                         'there, but wrong position
        d1$=RTRIM$(MID$(s,1,n-1))                     'everthing before the comment character
        d2$=RTRIM$(MID$(s,n))                         'comment

        IF LEN (d1$)>=k-1 THEN                        'if code text is too long...
          s=d1$+" "+d2$                               'just append comment
        ELSE                                          'if there is enough space
          s=LEFT$(d1$+REPEAT$(k-2," "),k-2)+" "+d2$   'put it together with comment in right pos
        END IF
  END SELECT


  IF flag=0 THEN
    FUNCTION=INSTR(s,co$)                             'return caret position (asm)
  ELSE
    FUNCTION=INSTR(s,co$)+1                           'return caret position (rc)
  END IF


END FUNCTION


'***********************************************************************************************


FUNCTION EditProc(BYVAL hWin AS DWORD, BYVAL uMsg AS DWORD, BYVAL wParam AS DWORD, BYVAL lParam AS DWORD) AS LONG
'***********************************************************************************************
' subclass of radasm edit
'***********************************************************************************************
LOCAL n     AS LONG
LOCAL i     AS LONG
LOCAL li    AS LONG                                   'linenumber
LOCAL c     AS charrange
LOCAL s     AS ASCIIZ * 256                           'string
LOCAL d$


  IF umsg=%WM_Char THEN
    IF wparam=char THEN                               'if comment character
      IF iswindowvisible(@h.hlbu) OR iswindowvisible(@h.hlbs) OR iswindowvisible(@h.hlb) THEN
                                                      'pass when listbox visible
      ELSEIF iswindowvisible(@h.hTlt) THEN
        GOTO editdone                                 'don´t pass if tooltip visible
      ELSE
        CALL sendmessage(@h.hedit, %EM_EXGETSEL,0,VARPTR(c))
        IF c.cpmin=c.cpmax THEN                       'comment if there is no selection only

          li = sendmessage(@h.hedit, %EM_EXLINEFROMCHAR,0,c.cpmin)
          n  = sendmessage(@h.hedit, %EM_LINEINDEX,li,0) 'position start of line

          s=CHR$(255)                                 'first word = max. chars to be copied
          CALL sendmessage(@h.hedit, %EM_GETLINE,li,VARPTR(s))
          c.cpmin=n                                   'get current line into s, prepare selection
          c.cpmax=n+LEN(s)                            'for current line

          n=comment(s)                                'edit line, n = caret position in this line

          CALL sendmessage(@h.hedit, %EM_HIDESELECTION,1,0)
          CALL sendmessage(@h.hedit, %EM_EXSETSEL,0,VARPTR(c)) 'select line
          CALL sendmessage(@h.hedit, %EM_REPLACESEL,%true,VARPTR(s)) 'replace text
          CALL sendmessage(@h.hedit, %EM_HIDESELECTION,0,0)

          c.cpmin=c.cpmin+n
          c.cpmax=c.cpmin
          CALL sendmessage(@h.hedit, %EM_EXSETSEL,0,VARPTR(c)) 'set caret

'***********************************************************************************************
' caret is not shown in the right place because "tab" is not passed to oldeditproc. so to
' let raedit show the caret in the right position send <esc>
'***********************************************************************************************
          CALL keybd_event(17,29,%KEYEVENTF_KEYUP,0)
          CALL keybd_event(27,1,0,0)                  'esc
          CALL keybd_event(27,1,%KEYEVENTF_KEYUP,0)

          GOTO editdone                               'done

        ELSE
          GOTO editdone                               'done
        END IF
      END IF
    END IF
  END IF


  FUNCTION = CallWindowProc(OldEditProc,hWin,uMsg,wParam,lParam)
  EXIT FUNCTION


editdone:
  FUNCTION=%true


END FUNCTION


'***********************************************************************************************
'***********************************************************************************************
