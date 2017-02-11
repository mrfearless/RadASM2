
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc
	include masm32.inc
	include shell32.inc
	include shlwapi.inc
	include gdi32.inc
	include Comdlg32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib
	includelib masm32.lib
	includelib shell32.lib
	includelib shlwapi.lib
	includelib gdi32.lib
	includelib Comdlg32.lib
	
;#########################################################################
;		RadASM Add In Include

	include \Programming\RadASM\Masm\Inc\radasm.inc

;#########################################################################
;		Prototypes

	DLLProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL				PROTO :DWORD, :DWORD
	GetKeyword PROTO :DWORD
	
	TextOutput				PROTO :DWORD
	clrOutput				PROTO 
	HexOutput				PROTO :DWORD

IDM_HELPF1						equ 41902

.data
	szRadHelp			db "RadHelp",0
	szKwCacheFile		db "KeywordCacheFile",0
	szKwLists			db "KeywordLists",0
	szQ					db "?",0

.data?

	hInstance			dd ?	;Dll's module handle
	lpHandles			dd ?	;Pointer to handles struct
	lpProc				dd ?	;Pointer to proc struct
	lpData				dd ?	;Pointer to data struct
	hOut				dd ?	;Handle of output window
	IDAddIn				dd ?	;Unique ID for this AddIn
	Options				dd ?
	
	fEnable equ 1
	fHideErrs equ 2
	fHasDefault equ 4
	fPassThru equ 8

.code

;#########################################################################
;		Output Window procs

TextOutput proc lpszStr:dword

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

HH_AKLINK struct
	cbStruct		DWORD ?
	fReserved		BOOL ?
	pszKeywords 	LPCSTR ?
	pszUrl			LPCSTR ?
	pszMsgText		LPCSTR ?
	pszMsgTitle 	LPCSTR ?
	pszWindow		LPCSTR ?
	fIndexOnFail	BOOL ?
HH_AKLINK ends

HH_DISPLAY_TOPIC	equ  0000H
HH_KEYWORD_LOOKUP  	equ  000DH

ADDINOPT struct
	lpStr	dd ?	;Pointer to CheckBox text
	nAnd	dd ?	;Option AND value
	nOr		dd ?	;Option OR value
ADDINOPT ends

CTEXT MACRO y:VARARG
	LOCAL sym

CONST segment
	IFIDNI <y>,<>
		sym db 0
	ELSE
		sym db y,0
	ENDIF
CONST ends

	EXITM <OFFSET sym>
ENDM
	
Msg MACRO y:VARARG

	.if !(Options & fHideErrs)
		pusha
		invoke MessageBox,0,CTEXT(y),0,0
		popa
	.endif

endm
	
.code

strcmp proc uses esi edi lpStr1:DWORD,lpStr2:DWORD

    xor	ecx,ecx
    mov	esi,lpStr1
    dec	ecx
    mov	edi,lpStr2
  @@:
    inc	ecx
    mov	al,[esi+ecx]
    sub	al,[edi+ecx]
    jne	@f
    cmp	al,[esi+ecx]
    jne	@b
  @@:
	movsx	eax,al
    ret

strcmp endp
