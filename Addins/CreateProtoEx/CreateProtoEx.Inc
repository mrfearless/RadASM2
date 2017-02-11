
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
;	include Comctl32.inc
;	include shell32.inc
	include ComDlg32.inc
;	include Gdi32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
;	includelib Comctl32.lib
;	includelib shell32.lib
	includelib ComDlg32.lib
;	includelib Gdi32.lib

;#########################################################################
;		RadASM Add In Include

	include ..\RadAsm.inc

;#########################################################################
;		VKim's Debug

	include masm32.inc
	include debug.inc
	includelib debug.lib
;
;	DBGWIN_DEBUG_ON = 1		; include debug info into the program
;	DBGWIN_EXT_INFO = 0		; include extra debug info into the program

;#########################################################################

o$	TEXTEQU	<OFFSET>
a$	TEXTEQU	<ADDR>
b$  TEXTEQU <BYTE PTR>
w$  TEXTEQU <WORD PTR>
d$  TEXTEQU <DWORD PTR>
s$  TEXTEQU <SIZEOF>


m2m MACRO a1:REQ, a2:REQ
	push a2
	pop a1
ENDM

$eax macro arg
	mov eax, arg
	exitm <eax>
endm


$invoke macro api:REQ, args:VARARG
  IFB <arg>
    invoke api
  ELSE
    invoke api, args
  ENDIF
  exitm <eax>
ENDM

CTXT macro Text
	local szText
	.data
	szText byte Text, 0
	.code
	exitm <offset szText>	
endm

; ---------------------
; literal string MACRO
; ---------------------
literal MACRO quoted_text:VARARG
LOCAL local_text
.data
  local_text db quoted_text,0
.code
EXITM <local_text>
ENDM
; --------------------------------
; string address in INVOKE format
; --------------------------------
sadd MACRO quoted_text:VARARG
	EXITM <ADDR literal(quoted_text)>
ENDM


;#########################################################################
;		Prototypes

include Prototypes.inc

;#########################################################################


	PROPERTIES struct
		nSize			dd ?
		Owner			dd ?
		nType			db ?
	PROPERTIES ends




;CreateProtoEx.dlg
IDD_DLGPROTO					equ 1000
IDC_LSTPROTO					equ 1001
IDC_CANCEL						equ 1001
IDC_SENDTOOUTPUT				equ 1002
IDC_GRP1						equ 1003
IDC_PROTOTOFILE					equ 1004
IDC_EDT1						equ 1005
IDC_OPENFILENAME				equ 1006
IDC_STC1						equ 1007
IDC_SELECTALL					equ 1008

;CreateProtoEx.Rc

;Res\CreateProtoVer.rc
VERINF1							equ 1


	
.data

	szAppName			db	'CreateProtoEx',0
	szCreateProtos		db	'Create '
	szProtos			db	'Protos',0
	szEnabled			db	'Enabled',0
	szFileName			db	'FileName',0
	szDefault			db	"0",0	; 0 == OFF / 1 == ON
	szProto				db	VK_TAB,'PROTO',0
	szDWORD				db 'DWORD ',0
	szLPA				db '(',0
	szRPA				db ');',0
	szCRLF				db 0Dh,0Ah,0
	ofnFilter			db	"*.*",0,0
	
.data?

	hInstance			dd 	?	;Dll's module handle
	lpHandles			dd 	?	;Pointer to handles struct
	lpProc				dd 	?	;Pointer to proc struct
	lpData				dd 	?	;Pointer to data struct
	hOut				dd 	?	;Handle of output window
	IDAddIn				dd 	?	;Unique ID for this AddIn
	fRunning			dd	?	;Flag to Tell us to Run Before Compiling
	hWnd				dd	?
	szFileToSaveTo		db	56 dup (?)
	dummy				dd	?
	ALIGN 4
	ofn					OPENFILENAME	<?>
.code

;#########################################################################
;		Output Window procs

TextOutput proc lpszStr

   pushad
   
   push  lpszStr
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpTextOut
   
   popad	
   ret

TextOutput endp

;#########################################################################

clrOutput proc

   pushad
   
   mov   eax,lpProc
   call  [eax].ADDINPROCS.lpClearOut
   
   popad	
   ret

clrOutput endp

;#########################################################################

HexOutput proc val:DWORD
	
	pushad
	
	push  val
	mov   eax,lpProc
	call  [eax].ADDINPROCS.lpHexOut
	
	popad
	ret
	
HexOutput endp
