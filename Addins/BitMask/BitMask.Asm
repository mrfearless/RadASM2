; This was originally an idea by Delight in his BitMe program
; The original program can be found in the MAIN forum
;
; UpdateIcon routine by Milos Tziotas
;
; I have rewritten the whole program for clarity and adaptive output
;
; Edgar Hansen (Donkey)
;
;#########################################################################
;		Compiler directives

	.486
	.model flat, stdcall
	option casemap:none

;#########################################################################
;		Include files

	include \masm32\include\windows.inc

	include \masm32\include\shell32.inc
	include \masm32\include\user32.inc
	include \masm32\include\kernel32.inc
	include \masm32\include\masm32.inc
	include	\radasm\masm\inc\RadASM.inc
	include \masm32\include\gdi32.inc
	include \masm32\include\comctl32.inc

;#########################################################################
;		Libraries

	includelib \masm32\lib\shell32.lib
	includelib \masm32\lib\user32.lib
	includelib \masm32\lib\kernel32.lib
	includelib \masm32\lib\masm32.lib
	includelib \masm32\lib\gdi32.lib
	includelib \masm32\lib\comctl32.lib

;#########################################################################
;		Prototypes
	DlgProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	DllEntry				PROTO	:DWORD,:DWORD,:DWORD
	DllProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM
	InstallDll				PROTO	:DWORD,:DWORD
	SetText					PROTO
	OutputText				PROTO	:DWORD
	StripSpaces				PROTO	:DWORD
	UpdateIcon				PROTO	:DWORD
	NotTheMask				PROTO
	ResetTheMask			PROTO
	SetTheMask				PROTO	:DWORD
	HexWndProc				PROTO	:DWORD,:DWORD,:DWORD,:DWORD
	GetHexValue				PROTO
	ParseInput				PROTO	:DWORD

;#########################################################################
;		Declarations

ADDINOPT struct
	lpStr	dd ?	;Pointer to CheckBox text
	nAnd	dd ?	;Option AND value
	nOr		dd ?	;Option OR value
ADDINOPT ends

ICO_BITMASK						equ 100

.data
	szAppName					BYTE		"BitMask",0
	MaskValue					DWORD		0
	BitmaskTip					BYTE		"Bit mask generator",0
	szHexSuffix					BYTE		"h",0
	AddInString					BYTE		"Enable Bitmask",0
	AddinOpt					ADDINOPT	<OFFSET AddInString,1,1>
								ADDINOPT	<0,0,0>
.data?
	hInstance					HINSTANCE	?
	hDlg						HANDLE		?

	lpHStruct					DWORD		?	;Pointer to handles struct
	lpDStruct					DWORD		?	;Pointer to data struct
	lpPStruct					DWORD		?
	hToolBar					DWORD		?	;Handle of ToolBar
	fOption						DWORD		?	;fOption is a value read from ini file
	hEdit						DWORD		?
	BitMaskID					DWORD		?
	OldHexWndProc				DWORD		?
	hTextEntry					DWORD		?
	ImageID						DWORD		?
	szBuff						BYTE		64 dup(?)
	
;#########################################################################
;		Initialization

.code

DllEntry	PROC hInst:DWORD, reason:DWORD, reserved1 :DWORD
    mov eax, hInst
    mov hInstance, eax
    xor eax, eax
    inc eax
    ret
DllEntry	ENDP

DllProc	PROC hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; Always return false so other plugins can process the commands

	mov eax, uMsg
	.if eax == AIM_COMMAND
		mov eax, wParam
		movzx eax, ax
		cmp eax, BitMaskID
		jne @F
			mov eax,lpHStruct
			mov eax,[eax].ADDINHANDLES.hWnd
			invoke DialogBoxParam,hInstance,101,eax,addr DlgProc,NULL
			mov MaskValue,0
			mov eax,TRUE
			ret
		@@:
	.elseif eax == AIM_TBRTOOLTIP
		mov eax, wParam
		.if eax==BitMaskID
			push sizeof szBuff/2
			push offset szBuff
			push 4000
			push offset szAppName
			mov eax,lpPStruct
			call [eax].ADDINPROCS.lpGetLangString
			.if !eax
				mov eax,offset BitmaskTip
			.else
				mov eax,offset szBuff
				;To tell RadASM it's unicode
				mov edx,123456
			.endif
			ret
		.endif
	.elseif eax == AIM_CLOSE
		invoke SendMessage,hToolBar,TB_COMMANDTOINDEX,BitMaskID,0
		invoke SendMessage,hToolBar,TB_DELETEBUTTON,eax,0
		invoke SendMessage,hToolBar,TB_GETIMAGELIST,0,0
		invoke ImageList_Remove,eax,ImageID
	.endif

	xor eax, eax
	ret
DllProc	ENDP

InstallDll	PROC hWin:DWORD, fOpt:DWORD
	LOCAL TBB		:TBBUTTON

	;Get pointer to handles struct
	invoke SendMessage, hWin, AIM_GETHANDLES, 0, 0
	mov	lpHStruct, eax
	mov edx,[eax].ADDINHANDLES.hToolBar
	mov hToolBar, edx
	invoke SendMessage,hWin,AIM_GETPROCS,0,0
	mov	lpPStruct,eax

	invoke SendMessage, hWin, AIM_GETMENUID, 0, 0
	mov BitMaskID, eax

	;Get pointer to data struct
	invoke SendMessage, hWin, AIM_GETDATA, 0, 0
	mov lpDStruct, eax

	invoke LoadIcon,hInstance,ICO_BITMASK
	invoke UpdateIcon,eax
	mov eax,ImageID
	mov TBB.iBitmap,eax
	mov eax,BitMaskID
	mov TBB.idCommand,eax
	mov TBB.fsState,TBSTATE_ENABLED
	mov TBB.fsStyle,TBSTYLE_BUTTON
	mov TBB.dwData,0
	mov TBB.iString,NULL
	;Add a button to the toolbar
	invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR TBB

	mov eax, fOpt
	mov fOption, eax
	mov eax,RAM_COMMAND or RAM_TBRTOOLTIP or RAM_CLOSE
	xor ecx,ecx
	xor edx,edx
	ret
InstallDll	ENDP

DlgProc proc uses ebx esi edi hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL IDFrom				:DWORD
	LOCAL buffer[16]			:BYTE
	LOCAL szHexString[16]		:BYTE

	.IF uMsg == WM_COMMAND
		mov eax,wParam
		movzx eax,ax
		mov IDFrom,eax
		mov eax, wParam
		shr eax, 16
		.IF (IDFrom > 104 && IDFrom < 137) && eax == BN_CLICKED
			invoke SendDlgItemMessage,hDlg,IDFrom,BM_GETCHECK,0,0
			mov edi,IDFrom
			sub edi,105
			mov edx,MaskValue
			.IF eax == BST_CHECKED
				mov eax,edi
				bts edx,eax
			.ELSEIF eax == BST_UNCHECKED
				mov eax,edi
				btr edx,eax
			.endif
			mov MaskValue,edx
			invoke SetText
		.ELSEIF (IDFrom == 139 || IDFrom == 140) && eax == BN_CLICKED
			mov eax,IDFrom
			sub eax,2
			mov IDFrom,eax
			invoke SendDlgItemMessage,hDlg,IDFrom,WM_GETTEXT,15,ADDR buffer
			.IF IDFrom == 137
				lea edx,szHexString
				mov eax,"0"
				mov [edx],eax
				invoke szCatStr,ADDR szHexString,ADDR buffer
				invoke szCatStr,ADDR szHexString,ADDR szHexSuffix
				invoke StripSpaces,ADDR szHexString
				invoke OutputText,addr szHexString
			.ELSE
				invoke OutputText,addr buffer
			.ENDIF
		.ELSEIF IDFrom == 142 && eax == BN_CLICKED
			invoke NotTheMask
		.ELSEIF IDFrom == 143 && eax == BN_CLICKED
			invoke ResetTheMask
		.ELSEIF IDFrom == 151 && eax == BN_CLICKED
			invoke GetHexValue
		.ELSEIF (IDFrom == 149 || IDFrom == 150) && eax == BN_CLICKED
			invoke SendDlgItemMessage,hDlg,149,BM_GETCHECK,0,0
			.IF eax == BST_CHECKED
				invoke GetWindowLong,hTextEntry,GWL_STYLE
				and eax,0FFFFDFFFh
				invoke SetWindowLong,hTextEntry,GWL_STYLE,eax
				invoke SetWindowLong,hTextEntry,GWL_WNDPROC,offset HexWndProc
				lea eax,buffer
				mov [eax],DWORD PTR 0
				invoke SendMessage,hTextEntry,WM_SETTEXT,0,ADDR buffer
				invoke SendMessage,hTextEntry,EM_LIMITTEXT,8,0
			.ELSE
				invoke GetWindowLong,hTextEntry,GWL_STYLE
				or eax,8192
				invoke SetWindowLong,hTextEntry,GWL_STYLE,eax
				invoke SetWindowLong,hTextEntry,GWL_WNDPROC,OldHexWndProc
				lea eax,buffer
				mov [eax],DWORD PTR 0
				invoke SendMessage,hTextEntry,WM_SETTEXT,0,ADDR buffer
				invoke SendMessage,hTextEntry,EM_LIMITTEXT,10,0
			.ENDIF
		.ENDIF

	.ELSEIF uMsg == WM_INITDIALOG
		mov eax,hWnd
		mov hDlg,eax
		push TRUE
		push offset szAppName
		push hWnd
		mov eax,lpPStruct
		call [eax].ADDINPROCS.lpSetLanguage
		
		mov eax,lpHStruct
		mov eax,[eax].ADDINHANDLES.hEdit
		mov hEdit,eax

		push hEdit
		mov eax,[lpPStruct]
		mov eax,(ADDINPROCS ptr [eax]).lpGetWordFromPos
		call eax
		invoke ParseInput,eax
		invoke SetTheMask,eax

		invoke SendDlgItemMessage,hDlg,149,BM_SETCHECK,BST_CHECKED,0
		invoke GetDlgItem,hDlg,148
		mov hTextEntry,eax
		invoke SetWindowLong,hTextEntry,GWL_WNDPROC,offset HexWndProc
		mov OldHexWndProc,eax
		invoke SendMessage,hTextEntry,EM_LIMITTEXT,8,0

	.ELSEIF uMsg == WM_CLOSE
		invoke EndDialog,hWnd,0

	.ELSE
		mov eax,FALSE
		ret

	.ENDIF

	mov eax, TRUE
	ret
DlgProc endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

SetText proc
	LOCAL buffer[16]		:BYTE
	LOCAL Hexbuffer[16]		:BYTE

	invoke dw2hex,MaskValue,ADDR buffer
	lea edi,buffer
	lea edx,Hexbuffer
	xor ecx,ecx
	.WHILE ecx<8
		mov ax,[edi+ecx]
		mov [edx],ax
		mov al," "
		mov [edx+2],al
		add ecx,2
		add edx,3
	.ENDW
	xor eax,eax
	mov [edx-1],eax
	invoke SendDlgItemMessage,hDlg,137,WM_SETTEXT,0,ADDR Hexbuffer

	invoke dw2a,MaskValue,ADDR buffer
	invoke SendDlgItemMessage,hDlg,138,WM_SETTEXT,0,ADDR buffer
	ret
SetText endp

ParseInput proc InputMask:DWORD
	LOCAL buffer[256]			:BYTE

	invoke lstrcpy,ADDR buffer,InputMask
	lea eax,buffer
	mov InputMask,eax

	mov edx,InputMask
	mov al,[edx]
	.IF al >= "0" && al <= "9"
		invoke StrLen,InputMask
		mov edx,InputMask
		add edx,eax
		sub edx,1
		mov al,[edx]
		.IF al == "h" || al == "H"
			mov [edx],BYTE PTR 0
			mov edx,InputMask
			invoke htodw,edx
			ret
		.endif
		invoke atodw,InputMask
	.ELSE
		xor eax,eax
	.ENDIF
	ret
ParseInput endp

OutputText proc pszStr:DWORD
	pushad
	mov eax,lpHStruct
	mov eax,[eax].ADDINHANDLES.hEdit
	mov hEdit,eax
	.IF hEdit != NULL
		invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,pszStr
	.else
		push 2
		mov	eax,[lpPStruct]
		call	(ADDINPROCS ptr [eax]).lpOutputSelect
		push pszStr
		mov	eax,[lpPStruct]
		call	(ADDINPROCS ptr [eax]).lpTextOut
	.endif
	popad
	ret
OutputText endp

SetTheMask proc MValue:DWORD
	mov eax,MValue
	mov MaskValue,eax

	mov ecx,0
	.WHILE ecx < 32
		push ecx
		bt MaskValue,ecx
		jnc @F
			mov edi,ecx
			add edi,105
			Invoke SendDlgItemMessage,hDlg,edi,BM_SETCHECK,BST_CHECKED,0
			jmp NextBit
		@@:
			mov edi,ecx
			add edi,105
			Invoke SendDlgItemMessage,hDlg,edi,BM_SETCHECK,BST_UNCHECKED,0
		NextBit:
		pop ecx
		inc ecx
	.endw
	; update the text
	invoke SetText
	ret
SetTheMask endp

NotTheMask proc
	xor MaskValue,0FFFFFFFFh
	mov ecx,0
	.WHILE ecx < 32
		push ecx
		bt MaskValue,ecx
		jnc @F
			mov edi,ecx
			add edi,105
			Invoke SendDlgItemMessage,hDlg,edi,BM_SETCHECK,BST_CHECKED,0
			jmp NextBit
		@@:
			mov edi,ecx
			add edi,105
			Invoke SendDlgItemMessage,hDlg,edi,BM_SETCHECK,BST_UNCHECKED,0
		NextBit:
		pop ecx
		inc ecx
	.endw
	; update the text
	invoke SetText
	ret
NotTheMask endp

ResetTheMask proc
	mov MaskValue,0
	mov ecx,0
	.WHILE ecx < 32
		push ecx
		mov edi,ecx
		add edi,105
		Invoke SendDlgItemMessage,hDlg,edi,BM_SETCHECK,BST_UNCHECKED,0
		pop ecx
		inc ecx
	.endw
	; update the text
	invoke SetText
	ret
ResetTheMask endp

StripSpaces proc uses edi edx eax lpszSTRING:DWORD
	LOCAL TempString[35]	:BYTE

	lea edi,TempString
	mov edx,lpszSTRING
	mov ecx,edx
	add ecx,35
	.WHILE edx < ecx
		mov al,[edx]
		.IF al != " "
			mov [edi],al
			inc edi
		.ENDIF
		inc edx
	.endw

	invoke lstrcpy,lpszSTRING,ADDR TempString
	ret
StripSpaces endp

UpdateIcon	PROC uses ebx,hICON :DWORD
	LOCAL myDC		:DWORD
	LOCAL hBmp		:DWORD
	LOCAL PrevBmp	:DWORD

	invoke GetDC,hToolBar
	mov ebx,eax
	invoke CreateCompatibleDC,ebx
	mov myDC,eax
	invoke CreateCompatibleBitmap,ebx,16,16
	mov hBmp,eax
	invoke SelectObject,myDC,eax
	mov PrevBmp,eax
	invoke DeleteDC,ebx

	invoke GetSysColor,COLOR_BTNFACE
	push eax
	invoke CreateSolidBrush,eax
	invoke SelectObject,myDC,eax
	push eax
	invoke CreateRectRgn,0,0,16,16
	push eax
	invoke PaintRgn,myDC,eax
	invoke DrawIconEx,myDC,0,0,hICON,16,16,0,NULL,DI_NORMAL
	pop eax
	;Region
	invoke DeleteObject,eax
	pop eax
	invoke SelectObject,myDC,eax
	;Brush
	invoke DeleteObject,eax
	invoke SelectObject,myDC,PrevBmp
	invoke DeleteDC,myDC
	invoke SendMessage,hToolBar,TB_GETIMAGELIST,0,0
	pop edx
	invoke ImageList_AddMasked,eax,hBmp,edx
	mov ImageID,eax
	invoke DestroyIcon,hICON
	invoke DeleteObject,hBmp
	ret
UpdateIcon	ENDP

HexWndProc PROC uses ebx esi edi hHexEdit:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL StartSel			:DWORD
	LOCAL EndSel			:DWORD

	.if uMsg==WM_CHAR
		mov eax,wParam
		.if (al>="0" && al<="9") || (al<="F" && al>="A") || (al <= "f" && al >= "a") || al==VK_BACK || al == VK_DELETE
			invoke CallWindowProc,OldHexWndProc,hHexEdit,uMsg,eax,lParam
			ret
		.endif
	.else
		invoke CallWindowProc,OldHexWndProc,hHexEdit,uMsg,wParam,lParam
		ret
	.endif
	xor eax,eax
	ret
HexWndProc endp

GetHexValue proc
	LOCAL buffer[16]		:BYTE
	invoke SendDlgItemMessage,hDlg,149,BM_GETCHECK,0,0
	.IF eax == BST_CHECKED
		invoke SendDlgItemMessage,hDlg,148,WM_GETTEXT,15,ADDR buffer
		invoke htodw,ADDR buffer
	.ELSE
		invoke SendDlgItemMessage,hDlg,148,WM_GETTEXT,15,ADDR buffer
		invoke atodw,ADDR buffer
	.ENDIF
	invoke SetTheMask,eax
	ret
GetHexValue endp

end DllEntry
