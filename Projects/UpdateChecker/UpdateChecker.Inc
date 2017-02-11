
;#########################################################################
; Include files

include windows.inc
include kernel32.inc
include user32.inc
include wininet.inc
include Comctl32.inc
include shell32.inc
include zlib\zlibstat.inc

;#########################################################################
; Libraries

includelib kernel32.lib
includelib user32.lib
includelib wininet.lib
includelib Comctl32.lib
includelib shell32.lib
includelib zlib\zlibstat.lib

;#########################################################################
; VKim's Debug

include debug.inc
includelib debug.lib
include masm32.inc

DBGWIN_DEBUG_ON = 1			; include debug info into the program
DBGWIN_EXT_INFO = 0			; include extra debug info into the program

IDD_DLGCHECK_UPDATE				equ 8000
IDC_EDTVERSION					equ 1001
IDC_CHKGETIDE					equ 1002
IDC_CHKGETASM					equ 1003
IDC_CHKGETHLL					equ 1004
IDC_CHKGETLNG					equ 1005
IDC_CHKGETHLP					equ 1010
IDC_BTNDOWNLOAD					equ 1008
IDC_EDTDLPATH					equ 1006
IDC_BTNDLPATH					equ 1007
IDC_BTNUPDATE					equ 1009

IDD_DLGDOWNLOAD					equ 8100
IDC_STCDOWNLOADING				equ 1001
IDC_STCFILESIZE					equ 1003
IDC_PGB1						equ 1002

.const

szMenuCheck						db 'Check for Updates',0
szBackSlash						db '\',0
szTemp							db '\RadASM_Update',0
szAllFiles						db '\*.*',0
szCRLF							db 13,10,0
AppName							db 'UpdateChecker',0
szDone							db 'Done!',13,10,0
szClose							db 'Close',0

szFmtVersion					db 'Your current version:',9,'%s',13,10,'Version at sourceforge:',9,'%s',0
szUrlVersion					db 'https://fbedit.svn.sourceforge.net/svnroot/fbedit/RadASM/ReleaseVersion.txt',0
szUrlFile						db 'https://fbedit.svn.sourceforge.net/svnroot/fbedit/RadASM/ReleaseMake/',0

szDownloading					db 'Downloading: ',0
szFmtFilesize					db 'Filesize: %d bytes',0
szIDEFile						db 'RadASMIDE.zip',0
szASMFile						db 'Assembly.zip',0
szHLLFile						db 'HighLevel.zip',0
szLNGFile						db 'Language.zip',0
szHLPFile						db 'RAHelp.zip',0
szFmtDownloaded					db 'Downloded %s %s',13,10,0
szSuccess						db 'successfully.',0

szINetErr1						db 'InternetOpen failed.',0
szINetErr2						db 'InternetOpenUrl failed.',0
szINetErr3						db 'HttpQueryInfo failed',0
szINetErr4						db 'InternetReadFile failed',0
szINetErr5						db 'CreateFile failed',0
szINetErr6						db 'Canceled.',0
szFmtErrNotEmpty				db 'The folder %s exists and is not empty.',13,10,'All files in the folder will be moved to Recycle Bin.',13,10,13,10,'Continue?',0

szAppPath						db 'C:\RadASM',0
szVersion						db 'RadASM version 2.2.1.8g',0

.data?

hInstance						dd ?
szDLFileName					db MAX_PATH dup(?)
szDLPath						db MAX_PATH dup(?)
hDLThread						dd ?
nDLThread						dd ?
fDLCancel						dd ?
nDLErrors						dd ?
tempbuff						db 2048 dup(?)
bri								BROWSEINFO <>
