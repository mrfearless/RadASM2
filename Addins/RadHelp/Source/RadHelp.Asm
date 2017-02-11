;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

KeywordBufferLen equ 128

;#########################################################################
;		Include file

include RadHelp.inc
include KeywordCache.asm
include OpenHelp.asm
include ChangeSettings.asm

.data?
; Added for JimmyCliff
DefLibrary		DB	256 DUP (?)

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD

	push fOpt
	pop Options

	mov	ebx,hWin

	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov	lpHandles,eax

	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov	lpProc,eax

	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov	lpData,eax
	
	xor eax,eax
	.if Options & fEnable
		; Add the RadHelp options item to the Option menu
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov IDAddIn,eax
		mov eax,lpHandles
		mov eax,(ADDINHANDLES ptr [eax]).hMenu
		invoke GetSubMenu,eax,8	;Option
		invoke AppendMenu,eax,MF_STRING,IDAddIn,CTEXT("RadHelp options")
		
		; Initialize the keyword cache
		invoke OpenCache
		
		; Hook into these messages
		mov	eax,RAM_COMMAND OR RAM_CLOSE OR RAM_MENUREBUILD
	.endif
	
	; ECX and EDX must be null before we return
	xor ecx, ecx
	xor edx, edx
	ret 

InstallDll Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

LOCAL kwbuf[KeywordBufferLen]:BYTE
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from
	; handling the message

	mov	eax, uMsg
	.if eax == AIM_COMMAND
		mov eax,wParam
		movzx edx,ax
		shr eax, 16
		.if edx == IDAddIn && eax == BN_CLICKED
			mov eax,lpHandles
			mov eax,(ADDINHANDLES ptr [eax]).hWnd
			invoke DialogBoxParam,hInstance,1000,eax,addr SettingsProc,0
			
		.elseif edx==IDM_HELPF1
			
			invoke GetKeyword,addr kwbuf
			.if eax
				invoke FindKeyword,addr kwbuf
				.if eax
					invoke OpenHelp,addr kwbuf,eax
					ret
				.endif
		; Added for JimmyCliff
			.else
				mov eax,lpData
				mov eax,[eax+ADDINDATA.lpIniAsmFile]
				mov pIniFile,eax
				invoke GetPrivateProfileString,addr szRadHelp,CTEXT("default"),addr DefLibrary,addr DefLibrary,256,pIniFile
				test eax,eax
				jz @EXIT
				mov DWORD PTR kwbuf,0
				invoke OpenHelp,addr kwbuf,addr DefLibrary
				ret
			.endif
		.ENDIF

	.ELSEIF eax==AIM_CLOSE
		.if IDAddIn
			mov eax,lpHandles
			invoke DeleteMenu,(ADDINHANDLES ptr [eax]).hMenu,IDAddIn,MF_BYCOMMAND
			mov IDAddIn,0
		.endif

	.ELSEIF eax==AIM_MENUREBUILD
		invoke CloseCache
		invoke OpenCache

;	.ELSEIF eax==AIM_TBRTOOLTIP
;		;
;	.ELSEIF eax==AIM_PROJECTCLOSE
;		;
;	.ELSEIF eax==AIM_PROJECTOPENED
;		;
	.endif

	@EXIT:
	mov eax,FALSE
	ret
DllProc Endp

GetOptions proc 
	
	.data
		AddinOptions	ADDINOPT <CTEXT("Enable addin"),fEnable,fEnable>
						ADDINOPT <CTEXT("Hide error messages"),fHideErrs,fHideErrs>
						ADDINOPT <CTEXT("F1 pass-thru on errors"),fPassThru,fPassThru>
						ADDINOPT <0,0,0>
		
	.code
	mov eax,offset AddinOptions

	ret

GetOptions endp

;#########################################################################

; This code is still mostly the same
GetKeyword proc uses esi edi pbuffer:dword
	
LOCAL trg:TEXTRANGE
LOCAL chr:byte
LOCAL hEdt:dword
	
	;Clear buffer
	mov eax,pbuffer
	mov	byte ptr [eax],0
	
	;Note!
	;hEdit is NULL if no edit window is open
	;or if the topmost mdi child is not an edit window.
	;Get handle of topmost edit window
	mov		eax,[lpHandles]
	mov		eax,(ADDINHANDLES ptr [eax]).hEdit
	.if eax
		mov		hEdt,eax
		;Get selection
		invoke SendMessage,hEdt,EM_EXGETSEL,0,addr trg.chrg
		;Get size
		mov		eax,trg.chrg.cpMax
		sub		eax,trg.chrg.cpMin
		.if eax
			;There is a selection in the edit window
			;If more than KeywordBufferLen chars in selection, dont bother
			.if eax <= KeywordBufferLen
				invoke SendMessage,hEdt,EM_GETSELTEXT,0,pbuffer
			.endif
		.else
			;No selection, let RadASM get word under caret
			push	hEdt
			mov		eax,[lpProc]
			mov		eax,(ADDINPROCS ptr [eax]).lpGetWordFromPos
			call	eax
			mov esi,eax
			mov edi,pbuffer
			;On return eax contains pointer to word
			;The word will be a null string if caret is on white space
			;Check character before keyword
			; Get start of word
			inc trg.chrg.cpMin ; Hack to fix when the caret is just after the "."
			invoke SendMessage,hEdt,EM_FINDWORDBREAK,WB_MOVEWORDLEFT,trg.chrg.cpMin
			; Set up the textrange
			mov trg.chrg.cpMax,eax
			.if eax
				dec eax
			.endif
			mov trg.chrg.cpMin,eax
			lea edx,chr
			mov trg.lpstrText,edx
			; Get the character
			invoke SendMessage,hEdt,EM_GETTEXTRANGE,0,addr trg
			.if chr=="."
				mov byte ptr [edi],"."
				inc edi
			.endif
		@@:	lodsb
			stosb
			test al,al
			jnz @B
		.endif
	.endif
	
	invoke ltrim,pbuffer,pbuffer
	
	invoke lcase,pbuffer
	
	mov eax,pbuffer
	.if byte ptr [eax]==0
		xor eax,eax
	.endif
	ret

GetKeyword endp


End DllEntry
