
include ..\RadASM.inc
include windows.inc
include kernel32.inc
include user32.inc

includelib user32.lib
includelib kernel32.lib
include masm32.inc
include debug.inc
includelib masm32.lib
includelib debug.lib

DlgProc		PROTO	:DWORD,:DWORD,:DWORD,:DWORD

ADDINOPT struct
	lpStr	dd ?
	nAnd	dd ?
	nOr		dd ?
ADDINOPT ends

RADBG struct
	_err	dd ?
	_edi	dd ?
	_esi	dd ?
	_ebp	dd ?
	_esp	dd ?
	_ebx	dd ?
	_edx	dd ?
	_ecx	dd ?
	_eax	dd ?
	_efl	dd ?
	_eip	dd ?
	_var	dd ?
	nid		dd ?
RADBG ends

IDD_DLG1		equ 1000
IDC_BTN1		equ 1001
IDC_BTN2		equ 1002
IDC_EDT1		equ 1003
IDC_RBN1		equ 1004
IDC_RBN2		equ 1005
IDC_RBN3		equ 1006

.const

szRegs			db 'efl eax ebx ecx edx esi edi ebp esp eip var err ',0
szFlags			db '    xxxxxxxx xxxxxxxx xxxxODIT SZxAxPxC',0Dh,0Ah,0
szCRLF			db 0Dh,0Ah,0
szLPA			db '(',0
szRPA			db ')',0
szDialogDbg		db 'Show debug dialog',0
szInt3Dbg		db 'Int 3 debug',0
szOutputDbg		db 'Result to output',0
szAppName		db 'RADbg',0

.data

winX			dd 100
winY			dd 100
AddinOpt		ADDINOPT <offset szDialogDbg,1,0>
				ADDINOPT <offset szInt3Dbg,1,1>
				ADDINOPT <offset szOutputDbg,16,16>
				ADDINOPT <0,0,0>

.data?

hInstance		dd ?	;Dll's module handle
hWnd			dd ?	;Handle of mdi frame
lpHStruct		dd ?	;Pointer to handles struct
lpPStruct		dd ?	;Pointer to proc struct
lpDStruct		dd ?	;Pointer to data struct
lpRegs			dd ?
RbnID			dd ?
fInt3			dd ?	;TRUE if int 3 debugging
fOut			dd ?	;TRUE if output to RadASM output window#1