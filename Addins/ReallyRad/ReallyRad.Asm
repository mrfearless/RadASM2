.386
.model flat,stdcall
option casemap:none

include ReallyRad.inc
include ReallyRadOpt.asm
include ReallyRadFunc.asm
include AddModProc.asm

.code

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

    push    hInst
    pop     hInstance
    mov     eax,TRUE
    ret

DllEntry Endp

InstallDll proc hWin:DWORD,fOpt:DWORD
	LOCAL	hMnu:DWORD
	LOCAL	mii:MENUITEMINFO

	mov		eax,hWin
	mov		hWnd,eax
	xor		eax,eax
	;fOpt is a value read from ini and passed to the dll
	;Use for option settings
	mov		edx,fOpt
	and		edx,1
	.if edx
		;Get pointer to handles struct
		invoke SendMessage,hWin,AIM_GETHANDLES,0,0
		mov		lpHStruct,eax
		;Get pointer to proc struct
		invoke SendMessage,hWin,AIM_GETPROCS,0,0
		mov		lpPStruct,eax
		;Get pointer to data struct
		invoke SendMessage,hWin,AIM_GETDATA,0,0
		mov		lpDStruct,eax
		;Get ini file
		mov		eax,[eax].ADDINDATA.lpIniAsmFile
		mov		lpIniFile,eax
		;Get options from ini file
		invoke ReadOptions
		;Allocate a new menu id
		invoke SendMessage,hWin,AIM_GETMENUID,0,0
		mov		OptMenuID,eax
		;Get handle of menu
		mov		eax,[lpHStruct]
		mov		eax,(ADDINHANDLES ptr [eax]).hMenu
		;Get handle of Option popup
		;At startup fMaximized is always FALSE
		;so adjusting topmost popups is not necessary.
		invoke GetSubMenu,eax,8		;Option
		mov		hMnu,eax
		;Insert our menuitem
		mov		mii.cbSize,sizeof mii
		mov		mii.fMask,MIIM_ID or MIIM_TYPE
		mov		mii.fType,MFT_STRING
		mov		mii.dwTypeData,offset szReallyRad
		mov		mii.cch,sizeof szReallyRad
		mov		eax,OptMenuID
		mov		mii.wID,eax
		invoke InsertMenuItem,hMnu,-1,TRUE,addr mii

		;Allocate a new menu id
		invoke SendMessage,hWin,AIM_GETMENUID,0,0
		mov		ModMenuID,eax
;		;Get handle of menu
;		mov		eax,[lpHStruct]
;		mov		eax,(ADDINHANDLES ptr [eax]).hToolMenu
;		;Get handle of dialog edit context
;		invoke GetSubMenu,eax,2		;Dialog editor
;		mov		hMnu,eax
;		invoke AppendMenu,hMnu,MF_SEPARATOR,0,0
;		invoke AppendMenu,hMnu,MF_STRING,ModMenuID,offset szCodeWrite

		;Returned value tells RadASM which messages you are hooking into
		;Hook into AIM_COMMAND
		mov		eax,RAM_COMMAND
		;Hook into AIM_CTLDBLCLK
		or		eax,RAM_CTLDBLCLK
		;Hook into AIM_DLGMNUSELECT
		or		eax,RAM_DLGMNUSELECT
		;Hook into AIM_PROJECTADDNEW
		or		eax,RAM_PROJECTADDNEW
		;Hook into AIM_RCUPDATE
		or		eax,RAM_RCUPDATE
		;Hook into AIM_CREATENEWDLG
		or		eax,RAM_CREATENEWDLG
		;Hook into AIM_CREATENEWCTL
		or		eax,RAM_CREATENEWCTL
		;Hook into AIM_CLOSE
		or		eax,RAM_CLOSE
		;Hook into AIM_MODULEBUILD
		mov		ecx,RAM_MODULEBUILD
		;Hook into AIM_ADDINSLOADED
		or		ecx,RAM_ADDINSLOADED
	.else
		xor		ecx,ecx
	.endif
	;Note!
	;Also set ecx and edx to NULL in case more than 32 hooks are
	;needed in the future.
	xor		edx,edx
    ret

InstallDll endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

;This proc handles messages sent from RadASM to our dll
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	lwtasm:FILETIME
	LOCAL	lwtobj:FILETIME
	LOCAL	mii:MENUITEMINFO

	mov		eax,uMsg
	.if eax==AIM_CTLDBLCLK && fCtlClk
		mov		edx,lParam
		mov		al,[edx].DIALOG.idname
		.if al
			invoke FindCommand,addr [edx].DIALOG.idname,FALSE
		.else
			mov		eax,[edx].DIALOG.id
			.if eax && eax!=-1
				invoke BinToDec,[edx].DIALOG.id,addr buffer
				invoke FindCommand,addr buffer,TRUE
			.endif
		.endif
	.elseif eax==AIM_DLGMNUSELECT && fMnuSel
		mov		edx,lParam
		mov		al,[edx].MNUITEM.itemname
		.if al
			invoke FindCommand,addr [edx].MNUITEM.itemname,FALSE
		.else
			mov		eax,[edx].MNUITEM.itemid
			.if eax && eax!=-1
				invoke BinToDec,[edx].MNUITEM.itemid,addr buffer
				invoke FindCommand,addr buffer,TRUE
			.endif
		.endif
	.elseif eax==AIM_COMMAND
		;Return TRUE to prevent RadASM and other dll's from
		;processing command.
		mov		eax,wParam
		and		eax,0FFFFh
		.if eax==OptMenuID
;			invoke DialogBoxParam,hInstance,IDD_DLGOPTION,hWin,addr OptionDlgProc,NULL
			push	NULL
			push	offset OptionDlgProc
			push	hWin
			push	IDD_DLGOPTION
			push	hInstance
			mov		eax,lpPStruct
			call	[eax].ADDINPROCS.lpModalDialog
			mov		eax,TRUE
			ret
		.elseif eax==ModMenuID
;			invoke DialogBoxParam,hInstance,IDD_DLGMODPROC,hWnd,addr AddModProc,NULL
			push	NULL
			push	offset AddModProc
			push	hWin
			push	IDD_DLGMODPROC
			push	hInstance
			mov		eax,lpPStruct
			call	[eax].ADDINPROCS.lpModalDialog
			mov		eax,TRUE
			ret
		.endif
	.elseif eax==AIM_CLOSE
		;Always return FALSE
		;Now is the time to kill timers, free memory, destroy windows, unhook, delete menuitems and delete toolbar buttons
		mov		eax,lpHStruct
		mov		eax,[eax].ADDINHANDLES.hMenu
		invoke DeleteMenu,eax,OptMenuID,MF_BYCOMMAND
		mov		OptMenuID,0
	.elseif eax==AIM_CREATENEWDLG
		invoke AddResFolder
	.elseif eax==AIM_PROJECTADDNEW
		invoke lstrlen,lParam
		mov		edx,lParam
		add		edx,eax
		mov		al,[edx]
		.while al!='\'
			dec		edx
			mov		al,[edx]
		.endw
		inc		edx
		invoke lstrcpy,addr buffer,edx
		invoke lstrlen,addr buffer
		sub		eax,4
		mov		buffer[eax],0
		invoke lstrcpy,addr buffer1,offset szInc-2
		invoke lstrcat,addr buffer1,offset szRes
		invoke lstrcat,addr buffer1,addr buffer
		.if wParam==1 && fAddDlg
			invoke lstrcat,addr buffer1,offset szDlg
			invoke IncludeFile,addr buffer1,FALSE
			mov		eax,lpDStruct
			inc		[eax].ADDINDATA.fResChanged
		.elseif wParam==2 && fAddMnu
			invoke lstrcat,addr buffer1,offset szMnu
			invoke IncludeFile,addr buffer1,FALSE
			mov		eax,lpDStruct
			inc		[eax].ADDINDATA.fResChanged
		.elseif wParam==-1 && fAddStrRc
			invoke lstrcat,addr buffer1,offset szStrRc
			invoke IncludeFile,addr buffer1,FALSE
			mov		eax,lpDStruct
			inc		[eax].ADDINDATA.fResChanged
		.elseif wParam==-2 && fAddResRc
			invoke lstrcat,addr buffer1,offset szResRc
			invoke IncludeFile,addr buffer1,FALSE
			mov		eax,lpDStruct
			inc		[eax].ADDINDATA.fResChanged
		.elseif wParam==-3 && fAddVerRc
			invoke lstrcat,addr buffer1,offset szVerRc
			invoke IncludeFile,addr buffer1,FALSE
			mov		eax,lpDStruct
			inc		[eax].ADDINDATA.fResChanged
		.elseif wParam==-4 && fAddAclRc
			invoke lstrcat,addr buffer1,offset szAclRc
			invoke IncludeFile,addr buffer1,FALSE
			mov		eax,lpDStruct
			inc		[eax].ADDINDATA.fResChanged
		.elseif wParam==-5 && fAddLngRc
			invoke lstrcat,addr buffer1,offset szLngRc
			invoke IncludeFile,addr buffer1,TRUE
			mov		eax,lpDStruct
			inc		[eax].ADDINDATA.fResChanged
		.endif
	.elseif eax==AIM_RCUPDATE
		.if wParam==1 && fAddResRc
			invoke AddResources,lParam
			mov		eax,lpDStruct
			inc		[eax].ADDINDATA.fResChanged
		.elseif wParam==2 && fAddVerRc
			invoke AddVersioninfo,lParam
			mov		eax,lpDStruct
			inc		[eax].ADDINDATA.fResChanged
		.endif
	.elseif eax==AIM_CREATENEWCTL
		.if fCtlNme
			invoke GetUniqueName,lParam
		.endif
	.elseif eax==AIM_MODULEBUILD
		;WARNING. This will work well only if modules are single files.
		.if fModBuild
			push	ebx
			invoke lstrcpy,addr buffer,wParam
			invoke lstrcat,addr buffer,addr FTAsm
			invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
			.if eax!=INVALID_HANDLE_VALUE
				mov		ebx,eax
				invoke GetFileTime,ebx,NULL,NULL,addr lwtasm
				invoke CloseHandle,ebx
				invoke lstrcpy,addr buffer,wParam
				invoke lstrcat,addr buffer,addr FTObj
				invoke lstrlen,addr buffer
				.while byte ptr buffer[eax-1]!='\' && eax
					dec		eax
				.endw
				invoke CreateFile,addr buffer[eax],GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
				.if eax!=INVALID_HANDLE_VALUE
					mov		ebx,eax
					invoke GetFileTime,ebx,NULL,NULL,addr lwtobj
					invoke CloseHandle,ebx
					xor		eax,eax
					mov		edx,lwtobj.dwLowDateTime
					sub		edx,lwtasm.dwLowDateTime
					mov		edx,lwtobj.dwHighDateTime
					sbb		edx,lwtasm.dwHighDateTime
					.if !CARRY?
						;Obj file is newer than asm file
						invoke lstrcat,addr buffer,addr szNewer
						invoke txtOut,addr buffer
						xor		eax,eax
						inc		eax
					.endif
				.else
					xor		eax,eax
				.endif
			.else
				xor		eax,eax
			.endif
			pop		ebx
			ret
		.endif
	.elseif eax==AIM_ADDINSLOADED
		;Update menu text
		mov		eax,OptMenuID
		mov		edx,2000
		call	SetMenuLang
		mov		eax,ModMenuID
		mov		edx,2001
		call	SetMenuLang
	.endif
	xor		eax,eax
	ret

SetMenuLang:
	push	eax
	push	sizeof buffer/2
	lea		eax,buffer
	push	eax
	push	edx
	push	offset szReallyRad
	mov		eax,lpPStruct
	call	[eax].ADDINPROCS.lpGetLangString
	pop		ecx
	.if eax
		mov		mii.cbSize,sizeof MENUITEMINFO
		mov		mii.fMask,MIIM_TYPE
		mov		mii.fType,MFT_STRING
		lea		eax,buffer
		mov		mii.dwTypeData,eax
		mov		edx,lpHStruct
		invoke SetMenuItemInfoW,[edx].ADDINHANDLES.hMenu,ecx,FALSE,addr mii
	.endif
	retn

DllProc endp

End DllEntry
