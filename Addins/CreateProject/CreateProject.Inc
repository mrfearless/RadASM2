include windows.inc
include kernel32.inc
include user32.inc
include Comctl32.inc
include gdi32.inc
include masm32.inc

include \RadASM\masm\Inc\radasm.inc
include \masm32\macros\macros.asm
include \RadASM\masm\Inc\radbg.inc

includelib user32.lib
includelib kernel32.lib
includelib Comctl32.lib
includelib gdi32.lib
includelib masm32.lib

;=====================================
.const
IDD_DLG1								equ 1000

IDC_BTN1								equ 1001
IDC_BTN2								equ 1002

IDC_RBN1								equ 1006
IDC_RBN2								equ 1007
IDC_RBN3								equ 1008
IDC_RBN4								equ 1009

IDC_RBN5								equ 1010
IDC_RBN6								equ 1011
IDC_RBN7								equ 1012
IDC_RBN8								equ 1013
IDC_RBN9								equ 1014

IDC_CHK1								equ 1015
IDC_CHK2								equ 1016
IDC_CHK3								equ 1017
IDC_CHK4								equ 1018

IDC_CHK5								equ 1019
IDC_CHK6								equ 1020
IDC_CHK7								equ 1021
IDC_CHK8								equ 1022

IDC_EDT1								equ 1026
IDC_EDT2								equ 1027
IDC_EDT3								equ 1028

;=====================================
.data
AppType1				db 'Win32 App',0
AppType2				db 'Console App',0
AppType3				db 'Dll Project',0
AppType4				db 'LIB Project',0
AppType5				db 'NMAKE Project',0

Menudef					db '0,0,0,0,0,0,0,0',0
flDialog				bool FALSE 

message1				db 'There is no project workspace created',0Dh,0Ah,0Ah
						db 'Would you like to create a project workspace?',0
message2				db 'Project file "',0
_con					db '" was found in folder, but workspace not loaded',0Dh,0Ah,0Ah
						db 'Would you like to open the project workspace now?',0

;============================
.data?
hInstance               dd ?	;Dll's module handle
lpHStruct               dd ?	;Pointer to handles struct
lpPStruct               dd ?	;Pointer to proc struct
lpDStruct               dd ?	;Pointer to data struct

fOption					dd ?

IDCreateProject			dd ?
hMnu					dd ?
hMenu					dd ?

hWnd					dd ?
hDlg					dd ?
hEdt1					dd ?
hEdt2					dd ?
hEdt3					dd ?

pAppType				dd ?

lpFolder				dd 128 dup (?) ;Project folder name buffer
lpFile					dd 128 dup (?) ;Opend file name without extension buffer
lpFileName				dd 128 dup (?) ;Opend file name with extension buffer
lpRapFile				dd 128 dup (?) ;Project file name buffer
lpDescr 				dd 128 dup (?) ;Project description buffer
lpAsm					dd 5 dup (?) ;Assembler buffer
lpReturnedString		dd 128 dup (?) ;Return string from ini file buffer
lpIniFile				dd 128 dup (?) ;Ini file name buffer
lpMakeFile				dd 128 dup (?) ;Make file name buffer
lpMessage				dd 128 dup (?) ;Message buffer

lfnt					LOGFONT <>
FindData				WIN32_FIND_DATA <>