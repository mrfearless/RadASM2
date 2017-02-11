; Path Explore Plus-Plus - RadASM AddIn
;
; Coded by Milos Tziotas
;	Web :	http://tziotas.cjb.net
;			http://darklight-software.cjb.net
;   Mail:   tziotas@gmx.net
;	ICQ :   71895226
;
; I was inspired by PthExpPlus. If I was able to recompile the program
; I would simply make changes I wanted to :) Well I coulnd't make it
; compile on my PC!! :)
;                           This version is compatible with PthExpPlus.
;######################################################################

.386
.model flat, stdcall
option casemap:none

;######################################################################

include		windows.inc

include		kernel32.inc
include		user32.inc
include		shell32.inc

include		..\RadAsm.inc

includelib	kernel32.lib
includelib	user32.lib
includelib	shell32.lib

;######################################################################

SETUP_DIALOG					equ 1000
SETUP_COMMAND_OK				equ 1001
SETUP_LIST_FILES				equ 1002
SETUP_COMMAND_CANCEL			equ 1003
SETUP_COMMAND_ADD				equ 1004
SETUP_COMMAND_REMOVE			equ 1005
SETUP_EDIT_ADD					equ 1006
SETUP_CHECK_AUTODELETE			equ 1007
SETUP_CHECK_PROMPT				equ 1008

SetupProc		PROTO :DWORD,:DWORD,:DWORD,:DWORD
EnumFileTypes	PROTO :DWORD,:DWORD
AddToList		PROTO :DWORD,:DWORD
AddToString		PROTO :DWORD,:DWORD
DeleteFiles		PROTO :DWORD,:DWORD

;######################################################################

	ADDINOPT struct
		lpStr			dd ?
		nAnd			dd ?
		nOr				dd ?
	ADDINOPT ends

.data
	strPath		db "Path Explore", 0
	strSetup	db "Set Minor Files", 0
	strDelete	db "Delete Minor Files", 0
	strConfirm	db "Are you sure you want to delete", 13, 10, 0
	strMinorIni	db "MinorFiles", 0
	strAutoIni	db "AutoDelete", 0
	strAskIni	db "AskMe", 0
	strIniDef	db "*.obj;*.exp;*.res;", 0
	strAppName	db 'PthExpl++',0
	strEnable	db 'Enable',0

	AddinOpt	ADDINOPT <offset strEnable,1,1>
				ADDINOPT <0,0,0>

.data?
	strDefault	db 256 dup(?)
	Buffer		db MAX_PATH dup(?)
	hInstance	dd ?
	hData		dd ?
	hHandles	dd ?
	hProcs		dd ?
	ExploreID	dd ?
	SetupID		dd ?
	DeleteID	dd ?
	AutoDelete	dd ?
	fBuild		dd ?
	hSubMenu	dd ?

.code
;######################################################################

DllEntry	PROC hInst :DWORD, Reason :DWORD, Reserved1 :DWORD
	mov eax, hInst
	mov hInstance, eax
	xor eax, eax
	inc eax
	ret
DllEntry	ENDP

InstallDll	PROC hWin :DWORD, fOpt :DWORD

	xor ecx,ecx
	mov eax,fOpt
	or eax,eax
	jz @f
	;===================
	; INJECT MENU ITEMS
	;===================
	xor eax, eax
	push eax
	push eax
	push AIM_GETHANDLES
	push hWin
	push eax
	push eax
	push AIM_GETMENUID
	push hWin
	push eax
	push eax
	push AIM_GETMENUID
	push hWin
	push eax
	push eax
	push AIM_GETMENUID
	push hWin
	push eax
	push eax
	push AIM_GETDATA
	push hWin
	push eax
	push eax
	push AIM_GETPROCS
	push hWin

	call SendMessage
	mov hProcs, eax
	call SendMessage
	mov hData, eax
	call SendMessage
	mov ExploreID, eax
	call SendMessage
	mov DeleteID, eax
	call SendMessage
	mov SetupID, eax
	call SendMessage
	mov hHandles, eax
	mov ecx,hData
	mov ecx,[ecx].ADDINDATA.fMaximized
	add ecx,4
	ASSUME eax : PTR ADDINHANDLES
	invoke GetSubMenu, [eax].hMenu, ecx
	mov hSubMenu, eax
	ASSUME eax : NOTHING
	invoke InsertMenu, hSubMenu, 13, MF_STRING or MF_BYPOSITION, ExploreID, offset strPath
	invoke InsertMenu, hSubMenu, 13, MF_SEPARATOR or MF_BYPOSITION, 123, 0
	invoke InsertMenu, hSubMenu, 13, MF_STRING or MF_BYPOSITION, DeleteID, offset strDelete
	invoke InsertMenu, hSubMenu, 13, MF_STRING or MF_BYPOSITION, SetupID, offset strSetup
	invoke InsertMenu, hSubMenu, 13, MF_SEPARATOR or MF_BYPOSITION, 124, 0
	;========
	; RETURN
	;========
	mov eax, RAM_COMMAND or RAM_INITMENUPOPUP or RAM_MAKEBEGIN or RAM_MAKEDONE or RAM_PROJECTOPENED or RAM_CLOSE
	mov ecx, RAM_ADDINSLOADED
  @@:
	xor edx,edx
	ret
InstallDll	ENDP

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

Rotate proc lpBuff:DWORD

	mov		eax,lpBuff
	.while byte ptr [eax]
		mov		dl,[eax+1]
		mov		[eax],dl
		inc		eax
	.endw
	ret

Rotate endp

DllProc PROC hWin :DWORD, uMsg :DWORD, wParam :DWORD, lParam :DWORD
	LOCAL	mnui:MENUITEMINFO
	LOCAL	buffer[32]:BYTE

	mov eax, uMsg
	.if eax == AIM_COMMAND
		;=============
		; AIM_COMMAND
		;=============
		mov eax, wParam
		.if eax == ExploreID
			;=========
			; EXPLORE
			;=========
			xor ecx, ecx
			mov eax, hData
			ASSUME eax : PTR ADDINDATA
			mov edx, [eax].lpProjectPath
			cmp ecx, [eax].fProject
			jnz @F
				mov edx, [eax].lpPro
			@@:
			ASSUME eax : NOTHING
			invoke ShellExecute, hWin, NULL, edx, NULL, NULL, SW_SHOWDEFAULT
			xor eax, eax
			inc eax
			ret
		.elseif eax == SetupID
			;===================
			; MINOR FILES SETUP
			;===================
;			invoke DialogBoxParamW, hInstance, SETUP_DIALOG, hWin, SetupProc, NULL
			push NULL
			push offset SetupProc
			push hWin
			push SETUP_DIALOG
			push hInstance
			mov eax,hProcs
			call [eax].ADDINPROCS.lpModalDialog
			xor eax, eax
			inc eax
			ret
		.elseif eax == DeleteID
			;====================
			; DELETE MINOR FILES
			;====================
			_DelWithConfirm:
			invoke lstrcpy, offset Buffer, offset strConfirm
			invoke EnumFileTypes, AddToString, offset Buffer
			invoke MessageBox, hWin, offset Buffer, offset strDelete, MB_YESNO or MB_ICONQUESTION or MB_APPLMODAL
			cmp eax, IDYES
			jnz @F
				_DelNoConfirm:
				invoke EnumFileTypes, DeleteFiles, NULL
			@@:
			xor eax, eax
			inc eax
			ret
		.endif
	.elseif eax == AIM_INITMENUPOPUP
		;===================
		; AIM_INITMENUPOPUP
		;===================
		mov eax, hData
		ASSUME eax : PTR ADDINDATA
		mov ecx, [eax].fProject
		and ecx, 1
		xor ecx, 1
		mov eax, hHandles
		ASSUME eax : PTR ADDINHANDLES
		push eax
		push ecx
		invoke EnableMenuItem, [eax].hMenu, DeleteID, ecx
		pop ecx
		pop eax
		invoke EnableMenuItem, [eax].hMenu, SetupID, ecx
		ASSUME eax : NOTHING
	.elseif eax == AIM_MAKEBEGIN
		;===============
		; AIM_MAKEBEGIN
		;===============
		invoke RtlZeroMemory,addr buffer,sizeof buffer
		invoke lstrcpyn,addr buffer,lParam,sizeof buffer
		.while TRUE
			mov eax,dword ptr buffer
			shl eax,8
			shr eax,8
			.break .if eax=='3,2' || !eax
			invoke Rotate,addr buffer
		.endw
		mov fBuild, eax
	.elseif eax == AIM_MAKEDONE
		;==============
		; AIM_MAKEDONE
		;==============
		xor eax, eax
		cmp fBuild, eax
		jz @F
		mov edx, hData
		ASSUME edx : PTR ADDINDATA
		invoke GetPrivateProfileInt, offset strMinorIni + 5, offset strAutoIni, 0, [edx].lpProject
		mov ecx, eax
		xor eax, eax
		cmp eax, ecx
		jz @F
			mov edx, hData
			invoke GetPrivateProfileInt, offset strMinorIni + 5, offset strAskIni, 0, [edx].lpProject
			mov ecx, eax
			ASSUME edx : NOTHING
			xor eax, eax
			cmp eax, ecx
			jz _DelNoConfirm
			jmp _DelWithConfirm
		@@:
	.elseif eax == AIM_PROJECTOPENED
		mov eax, hData
		ASSUME eax : PTR ADDINDATA
		invoke GetPrivateProfileString,offset strMinorIni,offset strMinorIni,offset strIniDef,offset strDefault,sizeof strDefault,[eax].lpIniAsmFile
		ASSUME eax : NOTHING
	.elseif eax == AIM_CLOSE
		invoke DeleteMenu,hSubMenu,ExploreID,MF_BYCOMMAND
		invoke DeleteMenu,hSubMenu,SetupID,MF_BYCOMMAND
		invoke DeleteMenu,hSubMenu,DeleteID,MF_BYCOMMAND
		invoke DeleteMenu,hSubMenu,123,MF_BYCOMMAND
		invoke DeleteMenu,hSubMenu,124,MF_BYCOMMAND
	.elseif eax==AIM_ADDINSLOADED
		push	sizeof Buffer/2
		lea		eax,Buffer
		push	eax
		push	2000
		push	offset strAppName
		mov		eax,hProcs
		call	[eax].ADDINPROCS.lpGetLangString
		.if eax
			mov		mnui.cbSize,sizeof mnui
			mov		mnui.fMask,MIIM_TYPE
			mov		mnui.fType,MFT_STRING
			lea		eax,Buffer
			mov		mnui.dwTypeData,eax
			;Insert our menuitem
			mov		edx,[hHandles]
			invoke SetMenuItemInfoW,(ADDINHANDLES ptr [edx]).hMenu,ExploreID,FALSE,addr mnui
		.endif
		push	sizeof Buffer/2
		lea		eax,Buffer
		push	eax
		push	2001
		push	offset strAppName
		mov		eax,hProcs
		call	[eax].ADDINPROCS.lpGetLangString
		.if eax
			mov		mnui.cbSize,sizeof mnui
			mov		mnui.fMask,MIIM_TYPE
			mov		mnui.fType,MFT_STRING
			lea		eax,Buffer
			mov		mnui.dwTypeData,eax
			;Insert our menuitem
			mov		edx,[hHandles]
			invoke SetMenuItemInfoW,(ADDINHANDLES ptr [edx]).hMenu,SetupID,FALSE,addr mnui
		.endif
		push	sizeof Buffer/2
		lea		eax,Buffer
		push	eax
		push	2002
		push	offset strAppName
		mov		eax,hProcs
		call	[eax].ADDINPROCS.lpGetLangString
		.if eax
			mov		mnui.cbSize,sizeof mnui
			mov		mnui.fMask,MIIM_TYPE
			mov		mnui.fType,MFT_STRING
			lea		eax,Buffer
			mov		mnui.dwTypeData,eax
			;Insert our menuitem
			mov		edx,[hHandles]
			invoke SetMenuItemInfoW,(ADDINHANDLES ptr [edx]).hMenu,DeleteID,FALSE,addr mnui
		.endif
	.endif
	xor eax, eax
	ret
DllProc	ENDP

SetupProc	PROC hWin :DWORD, uMsg :DWORD, wParam :DWORD, lParam :DWORD

	LOCAL hList				:DWORD
	LOCAL LocalBuffer[256]	:BYTE

	mov eax, uMsg
	.if eax == WM_INITDIALOG
		;===================
		; INITIALIZE DIALOG
		;===================
		invoke GetDlgItem, hWin, SETUP_LIST_FILES
		invoke EnumFileTypes, AddToList, eax
		invoke GetDlgItem, hWin, SETUP_EDIT_ADD
		invoke SendMessage, eax, EM_SETLIMITTEXT, 255, 0

		mov eax, hData
		ASSUME eax : PTR ADDINDATA
		invoke GetPrivateProfileInt, offset strMinorIni + 5, offset strAutoIni, 0, [eax].lpProject
		ASSUME eax : NOTHING
		test eax, eax
		jz @F
			invoke GetDlgItem, hWin, SETUP_CHECK_AUTODELETE
			invoke SendMessage, eax, BM_SETCHECK, BST_CHECKED, 0
		@@:
		mov eax, hData
		ASSUME eax : PTR ADDINDATA
		invoke GetPrivateProfileInt, offset strMinorIni + 5, offset strAskIni, 0, [eax].lpProject
		ASSUME eax : NOTHING
		test eax, eax
		jz @F
			invoke GetDlgItem, hWin, SETUP_CHECK_PROMPT
			invoke SendMessage, eax, BM_SETCHECK, BST_CHECKED, 0
		@@:
		push	FALSE
		push	offset strAppName
		push	hWin
		mov		eax,hProcs
		call	[eax].ADDINPROCS.lpSetLanguage
	.elseif eax == WM_COMMAND
		;==================
		; COMMAND MESSAGES
		;==================
		mov eax, wParam
		.if eax == SETUP_COMMAND_CANCEL
			;================
			; BUTTON: CANCEL
			;================
			jmp _close
		.elseif eax == SETUP_COMMAND_OK
			;============
			; BUTTON: OK
			;============
			invoke GetDlgItem, hWin, SETUP_CHECK_AUTODELETE
			invoke SendMessage, eax, BM_GETCHECK, 0, 0
			mov Buffer[0], '0'
			mov Buffer[1], 0
			test eax, eax
			jz @F
				inc Buffer[0]
			@@:
			mov eax, hData
			ASSUME eax : PTR ADDINDATA
			invoke WritePrivateProfileString, offset strMinorIni + 5, offset strAutoIni, offset Buffer, [eax].lpProject
			ASSUME eax : NOTHING
			invoke GetDlgItem, hWin, SETUP_CHECK_PROMPT
			invoke SendMessage, eax, BM_GETCHECK, 0, 0
			mov Buffer[0], '0'
			test eax, eax
			jz @F
				inc Buffer[0]
			@@:
			mov eax, hData
			ASSUME eax : PTR ADDINDATA
			invoke WritePrivateProfileString, offset strMinorIni + 5, offset strAskIni, offset Buffer, [eax].lpProject
			ASSUME eax : NOTHING
			invoke GetDlgItem, hWin, SETUP_LIST_FILES
			mov hList, eax
			xor eax, eax
			mov Buffer, al
			invoke SendMessage, hList, LB_GETCOUNT, eax, eax
			test eax, eax
			jz _write
			mov ecx, eax
			@@:
			dec ecx
			push ecx
				invoke SendMessage, hList, LB_GETTEXT, ecx, ADDR LocalBuffer
				invoke lstrcat, offset Buffer, ADDR LocalBuffer
				invoke lstrlen, offset Buffer
				add eax, offset Buffer
				mov WORD PTR [eax], ';'
			pop ecx
			test ecx, ecx
			jnz @B
			_write:
			mov eax, hData
			ASSUME eax : PTR ADDINDATA
			invoke WritePrivateProfileString, offset strMinorIni + 5, offset strMinorIni, offset Buffer, [eax].lpProject
			ASSUME eax : NOTHING
			jmp _close
		.elseif eax == SETUP_COMMAND_ADD
			;=============
			; BUTTON: ADD
			;=============
			invoke GetDlgItemText, hWin, SETUP_EDIT_ADD, offset Buffer, 256
			test eax, eax
			jz @F
				invoke GetDlgItem, hWin, SETUP_LIST_FILES
				invoke SendMessage, eax, LB_ADDSTRING, 0, offset Buffer
				mov Buffer, 0
				invoke SetDlgItemText, hWin, SETUP_EDIT_ADD, offset Buffer
			@@:
		.elseif eax == SETUP_COMMAND_REMOVE
			;================
			; BUTTON: REMOVE
			;================
			invoke GetDlgItem, hWin, SETUP_LIST_FILES
			push eax
			invoke SendMessage, eax, LB_GETCURSEL, 0, 0
			pop ecx
			invoke SendMessage, ecx, LB_DELETESTRING, eax, 0
		.endif
	.elseif eax == WM_CLOSE
		;==============
		; CLOSE DIALOG
		;==============
		_close:
		invoke EndDialog, hWin, 0
	.else
		xor eax, eax
		ret
	.endif
	xor eax, eax
	inc eax
	ret
SetupProc	ENDP

EnumFileTypes	PROC hCallback :DWORD, User :DWORD

	LOCAL LocalBuffer[256]	:BYTE

	mov edx, hData
	ASSUME edx : PTR ADDINDATA
	invoke GetPrivateProfileString, offset strMinorIni + 5, offset strMinorIni, offset strDefault, ADDR LocalBuffer, 256, [edx].lpProject
	ASSUME edx : NOTHING
	test eax, eax
	jz _close
	mov ecx, eax
	lea eax, LocalBuffer
	mov edx, eax
	add ecx, eax
	_loop:
		cmp BYTE PTR [eax], ';'
		jnz @F
			mov BYTE PTR [eax], 0
			pushad
			push User
			push edx
			call hCallback
			popad
			mov edx, eax
			inc edx
		@@:
		inc eax
	cmp eax, ecx
	jl _loop
	_close:
	ret
EnumFileTypes	ENDP

AddToList	PROC lpString :DWORD, User :DWORD
	invoke SendMessage, User, LB_ADDSTRING, 0, lpString
	ret
AddToList	ENDP

AddToString	PROC lpString :DWORD, User :DWORD
	invoke lstrcat, User, lpString
	invoke lstrlen, eax
	add eax, User
	mov WORD PTR [eax], ' '
	ret
AddToString ENDP

DeleteFiles PROC lpString :DWORD, User :DWORD

	LOCAL FindData			:WIN32_FIND_DATA
	LOCAL hFind				:DWORD

	mov edx, hData
	invoke lstrcpy, offset Buffer, [edx].ADDINDATA.lpProjectPath
;	invoke lstrlen, offset Buffer
;	mov WORD PTR [offset Buffer + eax], '\'
	invoke lstrcat, offset Buffer, lpString
	invoke FindFirstFile, offset Buffer, ADDR FindData
	cmp eax, -1
	jz _exit
		mov hFind, eax
	@@:
		mov edx, hData
		invoke lstrcpy, offset Buffer, [edx].ADDINDATA.lpProjectPath
		invoke lstrlen,offset Buffer
		push	eax
		mov		ecx,lpString
		.while byte ptr [ecx]
			mov		dl,[ecx]
			mov		Buffer[eax],dl
			inc		ecx
			inc		eax
			.break .if dl=='\'
			xor		dl,dl
		.endw
		pop		ecx
		.if !dl
			mov		eax,ecx
		.endif
		mov		byte ptr Buffer[eax],0
		invoke lstrcat, offset Buffer, ADDR FindData.cFileName
		invoke DeleteFile, Offset Buffer
		invoke FindNextFile, hFind, ADDR FindData
		test eax, eax
		jnz @B
	invoke FindClose, hFind
	_exit:
	ret
DeleteFiles	ENDP
;######################################################################
end DllEntry