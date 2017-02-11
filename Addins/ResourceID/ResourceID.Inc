
;#########################################################################
; Include files

include windows.inc
include kernel32.inc
include user32.inc

;#########################################################################
; Libraries

includelib kernel32.lib
includelib user32.lib

;#########################################################################
; RadASM Add In Include

include \RadASM\Masm\Inc\radasm.inc

ID_EDIT					equ	65501
ID_FIRSTCHILD			equ 65001
ID_LASTCHILD			equ 65499

.const

FileName			db 'rsrc.',4 dup(0)
FileSearch			db '*.rc',0
ResPath				db 'Res\',0
Define				db '#define',0

.data?

hInstance			dd ?	;Dll's module handle
lpHandles			dd ?	;Pointer to handles struct
lpProc				dd ?	;Pointer to proc struct
lpData				dd ?	;Pointer to data struct
hFound				dd ?
