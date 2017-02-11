
;#########################################################################
;Include files

include windows.inc
include kernel32.inc
include user32.inc

;#########################################################################
;Libraries

includelib kernel32.lib
includelib user32.lib

;#########################################################################
;RadASM Add In Include

include ..\radasm.inc

;#########################################################################
;VKim's Debug

;include debug.inc
;include masm32.inc
;includelib debug.lib

REM_BASE				equ WM_USER+1000
REM_GETUNDO				equ REM_BASE+89		;wParam=nSize, lParam=lpMem
REM_SETUNDO				equ REM_BASE+90		;wParam=nSize, lParam=lpMem

IDM_EDIT_EMPTY_UNDO		equ 41022

RAUNDO struct
	rpPrev		dd ?						;Relative pointer to previous
	undoid		dd ?						;Undo ID
	cp			dd ?						;Character position
	cb			dd ?						;Size in bytes
	fun			db ?						;Function
RAUNDO ends

UNDOSAVE struct
	pfid		dd ?						;Project fileid
	dft			dd ?						;Dos file time
	nsize		dd ?						;Size of undo memory
	hmem		dd ?						;Handle of undo memory
UNDOSAVE ends

.const

szUndo				db 'undo',0

.data?

hInstance			dd ?					;Dll's module handle
lpHandles			dd ?					;Pointer to handles struct
lpProc				dd ?					;Pointer to proc struct
lpData				dd ?					;Pointer to data struct
usFileName			db MAX_PATH dup(?)
us					UNDOSAVE 2048 dup (<>)
