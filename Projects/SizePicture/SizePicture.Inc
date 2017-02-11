
include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include Comdlg32.inc
include gdi32.inc
include shell32.inc
include gdiplus.inc
include gdiplus_structs.inc

includelib kernel32.lib
includelib user32.lib
includelib Comctl32.lib
includelib Comdlg32.lib
includelib gdi32.lib
includelib shell32.lib
includelib gdiplus.lib

include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

;Res\SizePictureRes.rc
IDB_BLACK						equ 100

;SizePicture.dlg
IDD_DIALOG1						equ 101
IDC_IMG1						equ 1001
IDC_EDTSOURCE					equ 1002
IDC_BTNSOURCE					equ 1003
IDC_BTNDEST						equ 1004
IDC_EDTDEST						equ 1005
IDC_EDTINDEX					equ 1006
IDC_BTNCONVERT					equ 1007
IDC_STCSIZE						equ 1008
IDC_UDNRES						equ 1009

;SizePicture.mnu
IDR_MENU						equ 10000
IDM_FILE_OPEN					equ 10001
IDM_FILE_SAVE					equ 10002
IDM_FILE_EXIT					equ 10003

.const

;#########################################################################

JPGFilterString					db 'Picture (*.jpg)',0,'*.jpg',0,0
DefJpgExt						db 'jpg',0
szBrowseSource					db 'Browse For Source Folder',0
szBrowseDestination				db 'Browse For Destination Folder',0
szBackSlash						db '\',0
szJPG							db '*.*',0
szFmt							db '\Img%d.jpg',0
szFmtSize						db 'Converted picture size %d x %d',0
szConvert						db 'Convert',0
szPause							db 'Pause',0
szResume						db 'Resume',0
szStop							db 'Stop',0
szExit							db 'Exit',0
ptsize							POINT <480,270>
								POINT <640,426>
								POINT <640,480>
								POINT <800,600>
								POINT <0,0>

.data?

hInstance						HINSTANCE ?
hDlg							HWND ?
OpenFileName					db MAX_PATH dup(?)
SaveFileName					db MAX_PATH dup(?)
SourcePath						db MAX_PATH dup(?)
DestPath						db MAX_PATH dup(?)
Temp							db MAX_PATH dup(?)
PIXWT							dd ?
PIXHT							dd ?
Inx								dd ?
pidl							dd ?
bri								BROWSEINFO <?>
wfd								WIN32_FIND_DATA <?>
hThread							dd ?
fCancel							dd ?

;#########################################################################
