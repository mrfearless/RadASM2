include windows.inc
include kernel32.inc
include user32.inc
;include gdi32.inc
;include Comctl32.inc

includelib kernel32.lib
includelib user32.lib
;includelib gdi32.lib
;includelib Comctl32.lib

;Debug
include masm32.inc
include Debug.Inc
includelib masm32.lib
includelib Debug.lib

include ..\RadAsm.inc

PROPERTIES	struct
	nSize	dd ?
	Owner	dd ?
	nType	db ?
PROPERTIES ends

.const

szDefine					db '#define',0
szTypedef					db 'typedef',0
szStruct					db 'struct',0
szUnion						db 'union',0
szStatic					db 'static',0
szConst						db 'const',0
szFar						db 'far',0

;Skip
szUnaligned					db 'unaligned',0
szInclude					db '#include',0
szInline					db 'inline',0
szClass						db 'class',0
szEnum						db 'enum',0
szExtern					db 'extern',0
szIfdef						db '#ifdef',0
szIfndef					db '#ifndef',0
szIf						db '#if',0
szElif						db '#elif',0
szElse						db '#else',0
szEndif						db '#endif',0
szPragma					db '#pragma',0
szNew						db 'new',0
szUndef						db '#undef',0
szError						db '#error',0
szDECLARE_INTERFACE			db 'DECLARE_INTERFACE',0
szDECLARE_INTERFACE_		db 'DECLARE_INTERFACE_',0
szDECLARE_MAPI_INTERFACE_	db 'DECLARE_MAPI_INTERFACE_',0

szColon						db ':',0

.data?

buffer						db 16384 dup(?)
buffer1						db 16384 dup(?)
buffer2						db 16384 dup(?)
lpHandles					dd ?
lpProcs						dd ?
lpData						dd ?
lpFunSt						dd ?
lpFunEn						dd ?
lpFunPos					dd ?
