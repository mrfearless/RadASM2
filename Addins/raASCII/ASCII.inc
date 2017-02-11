
;-------------------------------------------------------------------
;Needed For Debug Window Only
Include masm32.inc
;Include debug.inc
;-------------------------------------------------------------------

;-------------------------------------------------------------------
;Needed For Debug Window Only
IncludeLib masm32.lib
;IncludeLib debug.lib
;-------------------------------------------------------------------

DlgProc proto :DWORD,:DWORD,:DWORD,:DWORD
PaintASCII proto :DWORD
InitRects proto :DWORD
SelectCurrent proto :DWORD,:DWORD
CreateStandardFont proto
CreateArray proto
EraseArray proto
DefineSizes proto :DWORD
TypeSelected proto :DWORD,:DWORD
byt2oct proto :BYTE,:DWORD
InsertChars proto :DWORD
NewFont proto :DWORD
ShowFontData proto :DWORD,:DWORD

ASCIIRECT struct
	index 	DWORD 0
	rc		RECT <0,0,0,0>
ASCIIRECT ends

.const
IDD_DLG1		equ 1001
IDC_GRP_OPTIONS	equ	1002
IDC_RBN_HEX		equ	1004
IDC_RBN_OCT		equ	1005
IDC_RBN_DEC		equ	1006
IDC_RBN_BIN		equ	1007
IDC_EDT_CLIP	equ	1008
IDC_BTN_CLEAR	equ 1009
IDC_BTN_FONT	equ 1012
IDC_BTN_INSERT	equ	1010
IDC_SBR_ASC		equ	1011
IDC_STC_FONT	equ 1013

EE_CHARSET 		equ 0EEh
GB2313_CHARSET 	equ 86h
VIETNAMESE_CHARSET equ 0A3h
THAI_CHARSET 	equ 0DEh

COLOR_BLUE 		equ 0FF0000h
COLOR_BROWN		equ	80h
COLOR_GREEN		equ	8000h

.DATA?
hMem			HLOCAL 	?
rects 			DWORD 	?
dwBottom		DWORD	?
dwRight			DWORD	?
hMFont			HFONT	?
wOutput			WORD	?
hIcon			HICON	?
hCurArrow		HCURSOR ?
hCurHand		HCURSOR ?
rcBig			RECT	<?>

.DATA
szMenuName		db "G_ASCII Table",0
InPaint BOOL FALSE
InMove	BOOL FALSE
UpperBound dd 255
FormatDec db "%d",0
FormatHex db "%02X",0
FormatLongHex db "%003X",0
OctMask db "000b",0
HSfx db 68h,0
OSfx db 6Fh,0
BSfx db 62h,0
Comma db 2Ch,0
RectCurrent dd -1
RectPrev dd -1
m_LogFont	LOGFONT	<>

;-------------------------------------------------------------------
CTEXT MACRO Text
LOCAL szText

	.DATA
	szText BYTE Text, 0
	.CODE
	ExitM < Offset szText >
ENDM

M2M MACRO M1, M2
	PUSH M2
	POP M1
ENDM

;-------------------------------------------------------------------
LOWORD MACRO DoubleWord	;;Retrieves the low WORD from double WORD argument
	MOV	EAX,DoubleWord
	AND	EAX,0FFFFh		;;Set to low word 
ENDM

;-------------------------------------------------------------------
HIWORD MACRO DoubleWord	;;Retrieves the high word from double word 
	MOV	EAX,DoubleWord
	SHR	EAX,16			;;Shift 16 for high word to set to high WORD
ENDM
;-------------------------------------------------------------------
empty$ macro string,bytes
	push edi
	xor eax,eax
	lea edi,string
	mov ecx,bytes
	rep stosb
	pop edi
endm

CADD MACRO quoted_text:VARARG
LOCAL vname,lbl
	jmp lbl
	vname db quoted_text,0
	align 4
	lbl:
	EXITM <ADDR vname>
ENDM