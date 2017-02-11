#Include "FontBuilder.Inc"
#Include "C:\RadASM\GoAsm\Inc\RadAsm.inc"

ADDINOPT struct
	lpStr			dd ?
	nAnd			dd ?
	nOr				dd ?
ADDINOPT ends

.data
	hInstance		DD		0
	lpHandles		DD		0
	lpProcs			DD		0
	lpData			DD		0

	Options			DD		0

	hSubMenu		DD		0
	AddInID			DD		0

	MASMFontFmt		DB		"%s LOGFONT <%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,",22h,"%s",22h,3Eh,0
	FASMFontFmt		DB		"%s LOGFONT %i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,",22h,"%s",22h,0
	HLAFontFmt		DB		"%s :w.LOGFONT:=w.LOGFONT:[%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,strToBA(",22h,"%s",22h,",w.LF_FACESIZE)];",0

	NameFmt			DB		"%s_%u",0

	strMenuText		DB		"Font builder",0
	strAppName		DB		"FontBuilder",0

	AddinOpt		ADDINOPT <0,0,0>

	NASMFontFmt		DB		"%s:",13,10,"ISTRUC LOGFONT",13,10,\
							"AT LOGFONT.lfHeight, dd %i",13,10,\
							"AT LOGFONT.lfWidth, dd %i",13,10,\
							"AT LOGFONT.lfEscapement, dd %i",13,10,\
							"AT LOGFONT.lfOrientation, dd %i",13,10,\
							"AT LOGFONT.lfWeight, dd %i",13,10,\
							"AT LOGFONT.lfItalic, db %i",13,10,\
							"AT LOGFONT.lfUnderline, db %i",13,10,\
							"AT LOGFONT.lfStrikeOut, db %i",13,10,\
							"AT LOGFONT.lfCharSet, db %i",13,10,\
							"AT LOGFONT.lfOutPrecision, db %i",13,10,\
							"AT LOGFONT.lfClipPrecision, db %i",13,10,\
							"AT LOGFONT.lfQuality, db %i",13,10,\
							"AT LOGFONT.lfPitchAndFamily, db %i",13,10,\
							"AT LOGFONT.lfFaceName, db ",27h,"%s",27h,13,10,\
							"IEND",0

.code

GetOptions:
	mov eax,offset AddinOpt
	ret

DllEntryPoint	FRAME hInst, reason, reserved1
    mov eax,[hInst]
    mov [hInstance], eax
    xor eax, eax
    inc eax
    ret
ENDF

InstallDll FRAME hWin, fOpt

	invoke SendMessage, [hWin], AIM_GETHANDLES, 0, 0
	mov	[lpHandles], eax
	invoke SendMessage, [hWin], AIM_GETPROCS, 0, 0
	mov [lpProcs], eax
	invoke SendMessage, [hWin], AIM_GETDATA, 0, 0
	mov [lpData], eax
	mov eax,[fOpt]
	mov [Options],eax

	invoke SendMessage, [hWin], AIM_GETMENUID, 0, 0
	mov [AddInID], eax

	; Add an item to the menu
	mov ecx,[lpData]
	mov ecx,[ecx+ADDINDATA.fMaximized]
	add ecx,4
	mov eax,[lpHandles]
	mov eax,[eax+ADDINHANDLES.hMenu]
	invoke GetSubMenu,eax,ecx
	mov [hSubMenu],eax
	invoke AppendMenu,eax,MF_STRING + MF_ENABLED,[AddInID],offset strMenuText

	mov eax,RAM_COMMAND + RAM_CLOSE + RAM_INITMENUPOPUP
	mov ecx,RAM_ADDINSLOADED
	xor edx,edx
	ret
ENDF

DllProc	FRAME hWin, uMsg, wParam, lParam
	LOCAL buffer[256]	:B
	LOCAL mii			:MENUITEMINFO

	cmp D[uMsg], AIM_COMMAND
	jnz >.INITMENUPOPUP
		mov eax, [wParam]
		cmp [AddInID], eax
		jnz >>.ExitMsgLoop
			mov eax,[lpHandles]
			mov eax,[eax+ADDINHANDLES.hWnd]
			invoke ChooseFontDialog,eax
			mov eax,TRUE
			ret

	.INITMENUPOPUP
	cmp D[uMsg], AIM_INITMENUPOPUP
	jnz >.AIMCLOSE
		mov eax, [lpData]
		mov eax, [eax+ADDINDATA.fProject]
		xor eax, 1
		or eax, MF_BYCOMMAND
		invoke EnableMenuItem, [hSubMenu], [AddInID], eax
		jmp >>.ExitMsgLoop

	.AIMCLOSE
	cmp D[uMsg], AIM_CLOSE
	jnz >.AIMADDINSLOADED
		invoke DeleteMenu,[hSubMenu],[AddInID],MF_BYCOMMAND
		jmp >.ExitMsgLoop

	.AIMADDINSLOADED
	cmp D[uMsg], AIM_ADDINSLOADED
	jnz >.ExitMsgLoop
		push	128;sizeof buffer/2
		lea		eax,buffer
		push	eax
		push	2000
		push	offset strAppName
		mov		eax,[lpProcs]
		call	[eax+ADDINPROCS.lpGetLangString]
		or		eax,eax
		je >.ExitMsgLoop
			mov		D[mii.cbSize],sizeof MENUITEMINFO
			mov		D[mii.fMask],MIIM_TYPE
			mov		D[mii.fType],MFT_STRING
			lea		eax,buffer
			mov		[mii.dwTypeData],eax
			mov		edx,[lpHandles]
			invoke SetMenuItemInfoW,[edx+ADDINHANDLES.hMenu],[AddInID],FALSE,addr mii
	.ExitMsgLoop
	xor eax, eax
	ret
ENDF

ChooseFontDialog FRAME hwnd
	uses edi,ebx
	LOCAL cf			:CHOOSEFONT
	LOCAL lf			:LOGFONT
	LOCAL szName[256]	:B
	LOCAL buffer[256]	:B

	mov B[szName],0
	mov B[buffer],0

	lea edi,cf
	mov ecx,SIZEOF CHOOSEFONT
	mov al,0
	rep stosb
	
	lea edi,lf
	mov ecx,SIZEOF LOGFONT
	mov al,0
	rep stosb

	mov D[cf.lStructSize],SIZEOF CHOOSEFONT
	mov D[cf.hDC],NULL
	lea eax,lf
	mov [cf.lpLogFont],eax
	mov D[cf.nSizeMin],NULL
	mov D[cf.nSizeMax],NULL
	mov D[cf.Flags],CF_SCREENFONTS + CF_EFFECTS + CF_INITTOLOGFONTSTRUCT
	mov D[cf.hwndOwner],NULL
	mov eax,[hInstance]
	mov [cf.hInstance],eax
	invoke ChooseFont,offset cf
	or eax,eax
	jz >>.exit

	mov eax,[cf.iPointSize]
	xor edx,edx
	mov ecx,10
	div ecx
	or eax,eax
	jns >
		neg eax
	:
	push eax
	push offset lf.lfFaceName
	push offset NameFmt
	lea eax,szName
	push eax
	call wsprintf
	add esp,16

	invoke lstrlen,offset szName
	mov ecx,eax
	lea edi,szName
	mov al," "
	; Replace spaces with underscores
	:
	repne scasb
	or ecx,ecx
	jz >
	mov B[edi-1],"_"
	jmp <
	:

	push offset lf.lfFaceName
	movsx eax,B[lf.lfPitchAndFamily]
	push eax
	movsx eax,B[lf.lfQuality]
	push eax
	movsx eax,B[lf.lfClipPrecision]
	push eax
	movsx eax,B[lf.lfOutPrecision]
	push eax
	movsx eax,B[lf.lfCharSet]
	push eax
	movsx eax,B[lf.lfStrikeOut]
	push eax
	movsx eax,B[lf.lfUnderline]
	push eax
	movsx eax,B[lf.lfItalic]
	push eax
	push [lf.lfWeight]
	push [lf.lfOrientation]
	push [lf.lfEscapement]
	push [lf.lfWidth]
	push [lf.lfHeight]
	lea eax,szName
	push eax

	; Push the format string depending on the assembler
	mov ebx,[lpData]
	add ebx,ADDINDATA.szAssembler
	invoke lstrcmpi,ebx,"masm"
	or eax,eax
	jnz >
		push offset MASMFontFmt
		jmp >.done
	:
	invoke lstrcmpi,ebx,"goasm"
	or eax,eax
	jnz >
		push offset MASMFontFmt
		jmp >.done
	:
	invoke lstrcmpi,ebx,"hla"
	or eax,eax
	jnz >
		push offset HLAFontFmt
		jmp >.done
	:
	invoke lstrcmpi,ebx,"fasm"
	or eax,eax
	jnz >
		push offset FASMFontFmt
		jmp >.done
	:
	invoke lstrcmpi,ebx,"nasm"
	or eax,eax
	jnz >
		push offset NASMFontFmt
		jmp >.done
	:
	invoke lstrcmpi,ebx,"tasm"
	or eax,eax
	jnz >
		push offset MASMFontFmt
		jmp >.done
	:
	;default
	push offset MASMFontFmt
	.done

	lea eax,buffer
	push eax
	call wsprintf
	add esp,68

	mov eax,[lpHandles]
	invoke SendMessage,[eax+ADDINHANDLES.hEdit],EM_REPLACESEL,TRUE,offset buffer

	.exit
	RET
ENDF
