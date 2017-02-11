.data
	szClrClass			db				"AG_CUST_CLR_CLASS",0
	szLblClass			db				"AG_CUST_LBL_CLASS",0
	szFontName			db				"MS Sans Serif",0
	szSysColor			db				"SysColor",0
	szSysBrush			db				"SysBrush",0
	szCaption			db				"Caption",0
	szGColorMenu		db				"GColor",0
	CustColors 			COLORREF 		16 dup (0FFFFFFh)
	SetRGBColor			db 				"commdlg_SetRGBColor",0
	
.data?
		
	hFont				HFONT			?
	hDialog				HWND			?
	hHex				HWND			?
	wHex				DWORD			?
	cxC					DWORD			?
	cyC					DWORD			?
	lx					DWORD			?
	ly					DWORD			?
	rcTemp				RECT			<>
	SETRGBSTRING		DWORD			?
;#########################################################################
;		Macros

RGB MACRO red,green,blue
	xor eax,eax
	mov ah,byte ptr blue
	shl eax,8
	mov ah,byte ptr green
	mov al,byte ptr red
ENDM

CTEXT MACRO Text
LOCAL szText

	.DATA
	szText BYTE Text, 0
	.CODE
	ExitM < Offset szText >
ENDM

m2m MACRO M1, M2
	PUSH M2
	POP M1
ENDM

LOWORD MACRO DoubleWord	
	MOV	eax,DoubleWord
	AND	eax,0FFFFh		
ENDM

;-----------	Returns HEX string without leading zeros	-----------
formhex$ MACRO DDValue

LOCAL resstr
LOCAL rvstring
LOCAL _loop
LOCAL _notnull
LOCAL _ecxz
LOCAL _zero
LOCAL _exit

.data
	resstr db 12 dup (0)
	rvstring db 12 dup (0)
	align 4
.code
	push esi
	push edi
	push ebx
	push ecx
	
	lea esi,rvstring
	lea edi,resstr
	invoke dw2hex,DDValue,esi	;get formatted hex string - 8 characters length, with leading zeros
	xor ecx,ecx
_loop:
	movzx ebx,byte ptr [esi]
	test ebx,ebx				;exit on terninated null
	jz _exit
	cmp ebx,48					;check leadin zeros
	jne _notnull				;not zero - copy the character to result string
	jecxz _ecxz					;jump over leadin zeros if no other character has been found before
_notnull:
	inc ecx						;increase counter - from here we accept all zeros
	mov [edi],ebx
	inc edi
_ecxz:
	inc esi
	jmp _loop
_zero:
	inc ecx						;just increase counter and store "0" in result string
	lea edi,resstr
	mov ebx,48
	mov [edi],ebx	
_exit:
	jecxz _zero					;the number is zero - so we must return "0"
	pop ecx
	pop ebx
	pop edi
	pop esi
	EXITM <ADDR resstr>
ENDM
	