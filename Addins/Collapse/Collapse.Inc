
;#########################################################################
;		Include files

include windows.inc
include kernel32.inc
include user32.inc

;#########################################################################
;		Libraries

includelib kernel32.lib
includelib user32.lib

;#########################################################################
;		vkim Debug
include masm32.inc
include Debug.Inc
;includelib masm32.lib
includelib Debug.lib

;#########################################################################
;		RadASM Add In Include

include \RadASM\Masm\Inc\radasm.inc

;#########################################################################

REM_BASE			equ WM_USER+1000
REM_NXTBOOKMARK		equ REM_BASE+10		;wParam=Line, lParam=Type
REM_PRVBOOKMARK		equ REM_BASE+11		;wParam=Line, lParam=Type
REM_ISLINE			equ REM_BASE+14		;wParam=Line, lParam=lpszDef
REM_COLLAPSE		equ REM_BASE+16		;wParam=Line, lParam=lpRABLOCKDEF
REM_EXPAND			equ REM_BASE+18		;wParam=Line, lParam=0

RABLOCKDEF struct
	lpszStart	dd ?					;Block start
	lpszEnd		dd ?					;Block end
	lpszNot1	dd ?					;Dont hide line containing this or set to NULL
	lpszNot2	dd ?					;Dont hide line containing this or set to NULL
	flag		dd ?					;
RABLOCKDEF ends

.const

szCollapse			db 'Collapse',0
szNULL				db 0

.data?

hInstance			dd ?				;Dll's module handle
lpHandles			dd ?				;Pointer to handles struct
lpProc				dd ?				;Pointer to proc struct
lpData				dd ?				;Pointer to data struct
hOut				dd ?				;Handle of output window
IDAddIn				dd ?				;Unique ID for this AddIn
szKey				db 16 dup(?)
buffer				db 8192 dup(?)

