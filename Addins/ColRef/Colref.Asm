;#################################################################
; COLORREF By minor28
; Some minor stuff by Donkey
;#################################################################

include Colref.inc

.code
include ChooseColor.asm

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntry Endp

InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD
	mov	ebx,hWin

	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov	lpHStruct,eax
	
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov	lpPStruct,eax
	
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov	lpDStruct,eax
	
	; Disable colref.dll
	mov eax,fOpt
	mov fOption,eax
	xor eax, eax
	xor ecx, ecx
	test fOption,1
	je @exit
	
	test fOption,4
	jne @F
	mov Dialogcolor,00FF8080h ;Blue color
	jmp @Brush
@@:	
	mov Dialogcolor,00C8D0D4h ;Standard color
@Brush:
	invoke CreateSolidBrush,Dialogcolor
	mov hBrush,eax

	;Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov IDColref,eax
	;toolbar button will have the same id as our menuitem
	mov mytbbutton.idCommand,eax 
	call AddMenu

	mov ebx,[lpHStruct] 
	mov ebx,(ADDINHANDLES ptr [ebx]).hToolBar 
	invoke SendMessage,ebx,TB_GETIMAGELIST,0,0 
	push eax 
	invoke LoadBitmap,hInstance,IDR_BITMAP 
	pop edx 
	push eax 
	invoke ImageList_AddMasked,edx,eax,808080h 
	mov   mytbbutton.iBitmap,eax 
	pop eax 
	invoke DeleteObject,eax 
	invoke SendMessage,ebx,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0 
	invoke SendMessage,ebx,TB_INSERTBUTTON,-1,offset mytbbutton 

	invoke LoadCustColors

	; Tell RadASM messages we want to hook
	mov eax, AddInHook(AIM_COMMAND,AIM_CLOSE)
	or	eax, AddInHook(AIM_MENUREBUILD,AIM_TBRTOOLTIP,AIM_PROJECTOPENED,AIM_PROJECTCLOSE)
	mov ecx, RAM_ADDINSLOADED
@exit:
	; EDX must be null before we return
	xor edx, edx
	ret 

InstallDll Endp

GetOptions proc
	mov		eax,offset AddinOpt
	ret
GetOptions endp

DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL color:dword
	LOCAL buffer[256]:BYTE
	LOCAL	mii:MENUITEMINFO

	; This proc handles messages sent from RadASM to our dll
	mov	eax, uMsg
	.if eax == AIM_COMMAND
		; Return TRUE to prevent RadASM and other DLL's from
		mov ecx, wParam
		and ecx, 0FFFFh
		.if ecx==IDColref
			mov eax,lpHStruct
			mov eax,[eax].ADDINHANDLES.hEdit
			push eax
			mov eax,[lpPStruct]
			mov eax,(ADDINPROCS ptr [eax]).lpGetWordFromPos
			call	eax
			invoke ParseInput,eax
			mov InitColor,eax
			invoke ColorDlg,NULL,hInstance,CC_FULLOPEN or CC_RGBINIT or CC_ENABLEHOOK or CC_ENABLETEMPLATE
			mov eax,TRUE
			ret
		.endif
		
	.ELSEIF eax==AIM_CLOSE
		invoke PostMessage,hCCDlg,WM_COMMAND,IDABORT,NULL
		invoke DeleteObject,hBrush
		mov edx,lpHStruct
		invoke DeleteMenu,[edx].ADDINHANDLES.hMenu,IDColref,MF_BYCOMMAND
		mov edx,lpHStruct
		invoke SendMessage,[edx].ADDINHANDLES.hToolBar,TB_COMMANDTOINDEX,IDColref,0
		mov edx,lpHStruct
		invoke SendMessage,[edx].ADDINHANDLES.hToolBar,TB_DELETEBUTTON,eax,0
		
	.ELSEIF eax==AIM_MENUREBUILD
		call AddMenu
		call UpdateMenu
		
	.ELSEIF eax==AIM_TBRTOOLTIP
		mov		eax,wParam
		.if eax==IDColref
			push sizeof buffer/2
			lea eax,buffer
			push eax
			push 4000
			push offset szColref
			mov eax,lpPStruct
			call [eax].ADDINPROCS.lpGetLangString
			.if !eax
				mov eax,offset szColrefToolTip
			.else
				lea eax,buffer
				;To tell RadASM it's unicode
				mov edx,123456
			.endif
			ret
		.endif
		
	.ELSEIF eax==AIM_PROJECTCLOSE
		invoke SaveCustColors
		
	.ELSEIF eax==AIM_PROJECTOPENED
		invoke LoadCustColors
		
	.elseif eax==AIM_ADDINSLOADED
		call UpdateMenu

	.endif
	mov eax,FALSE
	ret

UpdateMenu:
	;Update menu text
	push	sizeof buffer/2
	lea		eax,buffer
	push	eax
	push	2000
	push	offset szColref
	mov		eax,lpPStruct
	call	[eax].ADDINPROCS.lpGetLangString
	.if eax
		mov		mii.cbSize,sizeof MENUITEMINFO
		mov		mii.fMask,MIIM_TYPE
		mov		mii.fType,MFT_STRING
		lea		eax,buffer
		mov		mii.dwTypeData,eax
		mov		edx,lpHStruct
		invoke SetMenuItemInfoW,[edx].ADDINHANDLES.hMenu,IDColref,FALSE,addr mii
	.endif
	retn

DllProc Endp

AddMenu proc
	LOCAL nMnu:DWORD
	LOCAL hMnu:DWORD

	.if IDColref
		mov	nMnu,6
		;Adjust topmost popup if maximized
		mov	eax,[lpDStruct]
		mov	eax,(ADDINDATA ptr [eax]).fMaximized
		.if eax
			inc	nMnu
		.endif

		;Get handle of menu
		mov	eax,[lpHStruct]
		mov	eax,(ADDINHANDLES ptr [eax]).hMenu

		;Get handle of Tools popup
		invoke GetSubMenu,eax,nMnu		;Tools menu
		mov		hMnu,eax

		;Add our menuitem
		invoke AppendMenu,hMnu,MF_STRING,IDColref,addr szColref
	.endif
	ret
AddMenu endp

Colors proc color:dword
	;show color references in editboxes

	xor eax,eax
    mov al,byte ptr [color + 2]
    push eax
    mov al,byte ptr [color + 1]
    push eax
    mov al,byte ptr color
    push eax
	invoke wsprintf,addr colref,SADD('%ld,%ld,%ld')
	invoke SetDlgItemText,hCCDlg,IDC_EDT1,addr colref

	invoke wsprintf,addr colref,SADD('%.8lXh'),color
	invoke SetDlgItemText,hCCDlg,IDC_EDT2,addr colref

	invoke wsprintf,addr colref,SADD('%ld'),color
	invoke SetDlgItemText,hCCDlg,IDC_EDT3,addr colref

	ret
Colors endp

ColorDlg proc hWin:DWORD, instance:DWORD, Flags:DWORD
	;Common dialog process
	LOCAL ccl:CHOOSECOLOR
	LOCAL crv[16]:DWORD

	lea edi,crv[0]
	mov ecx,16
	mov eax,0FFFFFFh
	rep stosd

	mov ccl.lStructSize,sizeof CHOOSECOLOR
	push hWin
	pop ccl.hwndOwner 
	push instance
	pop ccl.hInstance
	mov eax,InitColor
	mov ccl.rgbResult,eax

	; address of 16 item DWORD array
	mov ccl.lpCustColors,OFFSET CustColor
	push Flags
	pop ccl.Flags
	mov ccl.lCustData,0
	mov ccl.lpfnHook,OFFSET CCHookProc
	mov ccl.lpTemplateName,OFFSET szTemplate

	invoke ChooseColor,addr ccl

	;Is the colordialog canceled
	.if eax!= 0
		mov eax,ccl.rgbResult
	.else
		mov eax,-1
	.endif
	invoke SaveCustColors
	ret
ColorDlg endp

MouseProc proc nCode:DWORD,wParam:DWORD,lParam:DWORD
		
	invoke CallNextHookEx,hHook,nCode,wParam,lParam
	invoke PostMessage,hCCDlg,WM_MOUSEHOOK,0,0
	xor eax,eax
	ret
MouseProc endp

InstallHook proc
	
	invoke SetWindowsHookEx,WH_MOUSE,addr MouseProc,hInstance,NULL
	mov hHook,eax
	ret 
InstallHook endp

UninstallHook proc
	invoke UnhookWindowsHookEx,hHook
	ret
UninstallHook endp

ParseInput proc InputMask:DWORD
	LOCAL buffer[256]:BYTE
	
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

LoadCustColors proc uses edi
	LOCAL RetString[16]	:BYTE
	LOCAL iniString[16]	:BYTE
	LOCAL RapFile		:DWORD
	LOCAL RadFile		:DWORD

	mov eax,lpDStruct
	mov edi,[eax].ADDINDATA.lpProject
	mov RapFile,edi
	mov edi,[eax].ADDINDATA.lpIniFile
	mov RadFile,edi

	mov edi,OFFSET CustColor

	mov word ptr iniString,'X'
	invoke GetPrivateProfileInt,OFFSET szColref,ADDR iniString,10,RadFile
	mov dlgpos.x,eax
	mov word ptr iniString,'Y'
	invoke GetPrivateProfileInt,OFFSET szColref,ADDR iniString,10,RadFile
	mov dlgpos.y,eax
	mov ecx,0
	.WHILE ecx < 8
		push ecx
		invoke dw2a,ecx,ADDR iniString
		invoke GetPrivateProfileString,OFFSET szColref,ADDR iniString,OFFSET szDefColor,ADDR RetString,16,RadFile
		invoke htodw,ADDR RetString
		pop ecx
		mov [edi+ecx*4],eax
		inc ecx
	.ENDW

	mov eax,RapFile
	mov eax,[eax]
	.IF al == 0
		RET
	.ENDIF

	mov edi,OFFSET CustColor + 32
	mov ecx,0
	.WHILE ecx < 8
		push ecx
		invoke dw2a,ecx,ADDR iniString
		invoke GetPrivateProfileString,OFFSET szColref,ADDR iniString,OFFSET szDefColor,ADDR RetString,16,RapFile
		invoke htodw,ADDR RetString
		pop ecx
		mov [edi+ecx*4],eax
		inc ecx
	.ENDW

	ret

LoadCustColors ENDP

SaveCustColors proc uses esi edi
	LOCAL RetString[16]	:BYTE
	LOCAL iniString[16]		:BYTE
	LOCAL RapFile			:DWORD
	LOCAL RadFile			:DWORD

	mov eax,lpDStruct
	mov edi,[eax].ADDINDATA.lpProject
	mov RapFile,edi
	mov edi,[eax].ADDINDATA.lpIniFile
	mov RadFile,edi

	mov word ptr iniString,'X'
	invoke dw2a,dlgpos.x,ADDR RetString
	invoke WritePrivateProfileString,OFFSET szColref,ADDR iniString,ADDR RetString,RadFile
	mov word ptr iniString,'Y'
	invoke dw2a,dlgpos.y,ADDR RetString
	invoke WritePrivateProfileString,OFFSET szColref,ADDR iniString,ADDR RetString,RadFile
	mov edi,OFFSET CustColor
	mov ecx,0
	.WHILE ecx < 8
		push ecx
		mov esi,[edi+ecx*4]
		invoke dw2a,ecx,ADDR iniString
		invoke dw2hex,esi,ADDR RetString
		invoke WritePrivateProfileString,OFFSET szColref,ADDR iniString,ADDR RetString,RadFile
		pop ecx
		inc ecx
	.ENDW

	mov eax,RapFile
	mov eax,[eax]
	.IF al == 0
		RET
	.ENDIF

	mov edi,OFFSET CustColor + 32
	mov ecx,0
	.WHILE ecx < 8
		push ecx
		mov esi,[edi+ecx*4]
		invoke dw2a,ecx,ADDR iniString
		invoke dw2hex,esi,ADDR RetString
		invoke WritePrivateProfileString,OFFSET szColref,ADDR iniString,ADDR RetString,RapFile
		pop ecx
		inc ecx
	.ENDW

	ret
SaveCustColors ENDP

SelectToDialog proc color:dword

	mov eax,color
	movzx eax,al
	invoke SetDlgItemInt,hCCDlg,706,eax,NULL
	mov eax,color
	mov al,ah
	movzx eax,al
	invoke SetDlgItemInt,hCCDlg,707,eax,NULL
	mov eax,color
	bswap eax
	mov al,ah
	movzx eax,al
	invoke SetDlgItemInt,hCCDlg,708,eax,NULL
	ret
SelectToDialog ENDP

End DllEntry
