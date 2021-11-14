include windows.inc
include kernel32.inc
include user32.inc

includelib kernel32.lib
includelib user32.lib

include masm32.inc
includelib masm32.lib

;Debug
IFDEF DEBUG32
include Debug.Inc
includelib Debug.lib
ENDIF

include RadAsm.inc

PROPERTIES	struct
	nSize	dd ?
	Owner	dd ?
	nType	db ?
PROPERTIES ends

.const

szskiplinefirstword			db	10,6,'option',
								10,7,'include',
								10,10,'includelib',
								10,6,'invoke',
								0,0,0

szword1						db	10,6,'method',
								11,6,'object',
								0,0,0

szinmethod					db	10,9,'methodend',
								0,0,0

szinobject					db	10,9,'objectend',
								0,0,0

szword2						db	10,4,'proc',
								11,6,'struct',
								11,5,'struc',
								11,5,'union',
								12,6,'record',
								13,3,'equ',
								14,5,'macro',
								0,0,0

szdatatypes					db	10,2,'DB',
								10,2,'DW',
								10,2,'DD',
								10.2,'DQ',
								10,2,'DF',
								10,2,'DT',
								11,4,'BYTE',
								11,5,'SBYTE',
								11,4,'WORD',
								11,5,'SWORD'
							db	11,5,'FWORD',
								11,5,'DWORD',
								11,6,'SDWORD',
								11,5,'QWORD',
								11,5,'REAL4',
								11,5,'REAL8',
								11,6,'REAL10',
								11,5,'TBYTE',
								0,0,0

szinprocparam				db	10,7,'private',
								10,6,'public',
								10,6,'export',
								10,4,'uses',
								10,3,'eax',
								10,3,'ebx',
								10,3,'ecx',
								10,3,'edx',
								10,3,'esi',
								10,3,'edi',
								10,3,'ebp',
								10,3,'esp'
							db	10,5,'frame',
								10,3,'rax',
								10,3,'rbx',
								10,3,'rcx',
								10,3,'rdx',
								10,3,'rsi',
								10,3,'rdi',
								10,3,'rbp',
								10,3,'rsp'
							db	10,5,'r8',
								10,3,'r9',
								10,3,'r10',
								10,3,'r11',
								10,3,'r12',
								10,3,'r13',
								10,3,'r14',
								10,3,'r15'
							db	10,1,'c',
								10,7,'stdcall',
								10,6,'pascal',
								10,7,'fortran',
								10,5,'basic',
								10,7,'syscall',
								0,0,0

szinproc					db	10,5,'local',
								11,4,'endp',
								0,0,0

szinstruct					db	10,4,'ends',
								11,6,'struct',
								11,5,'struc',
								11,5,'union',
								0,0,0

szinmacro					db	10,4,'endm',
								0,0,0

szdword						db	'DWORD',0
szptr						db	'PTR ',0
szproto						db	'PROTO',0

szdataconv					db	'DB',0,'BYTE',0
							db	'DW',0,'WORD',0
							db	'DD',0,'DWORD',0
							db	'DQ',0,'QWORD',0
							db	'DT',0,'TBYTE',0
							db	'DF',0,'FWORD',0
							db	'DD',0,'REAL4',0
							db	'DQ',0,'REAL8',0
							db	'DT',0,'REAL10',0
							db	'DB',0,'SBYTE',0
							db	'DW',0,'SWORD',0
							db	'DD',0,'SDWORD',0
							db	0,0

szproc						db	'proc',0
szequ						db	'equ',0
szequ2						db	'=',0
szmacro						db	'macro',0
szstruct					db	'struct',0
szunion						db	'union',0
szstruc						db	'struc',0
szrecord					db	'record',0
szmethod					db	'method',0
szobject					db	'object',0

szcomment					db	'comment',0
szstring					db	'"',"'",0,0
szadd						db	'+',0
szcolon						db	':',0

.data?

buffer						db	16384 dup(?)
buffer1						db	16384 dup(?)
lpHandles					dd	?
lpProcs						dd	?
lpData						dd	?
lpFunSt						dd	?
lpFunEn						dd	?
lpFunPos					dd	?
