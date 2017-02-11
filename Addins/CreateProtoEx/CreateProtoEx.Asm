;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include CreateProtoEx.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

AddMenu proc nID:DWORD,lpText:DWORD

	mov		edx,6
	;Adjust topmost popup if maximized
	mov		eax,[lpData]
	.if [eax].ADDINDATA.fMaximized
		inc		edx
	.endif
	;Get handle of Tools popup
	mov		eax,[lpHandles]
	invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,edx
	;Add our menuitem
	invoke AppendMenu,eax,MF_STRING,nID,lpText
	ret

AddMenu endp


LoadSettingsFromProjectFile proc uses ebx esi

	mov ebx, lpData
	.if [ebx].ADDINDATA.fProject
		mov fRunning,0
		invoke GetPrivateProfileString,o$ szProtos,o$ szEnabled,o$ szDefault,o$ fRunning,4,[ebx].ADDINDATA.lpProject
		sub fRunning, 30h
		mov edx, MF_BYCOMMAND
		.IF fRunning == 1
			or edx, MF_CHECKED
			push edx
			invoke GetPrivateProfileString,o$ szProtos,o$ szFileName,o$ szDefault,o$ szFileToSaveTo,56,[ebx].ADDINDATA.lpProject
			pop edx
		.ENDIF
		mov eax, lpHandles
		invoke CheckMenuItem,[eax].ADDINHANDLES.hMenu,IDAddIn,edx
	.endif
	ret
LoadSettingsFromProjectFile endp

SaveSettingsToProjectFile proc uses ebx

	mov ebx, lpData
	.if [ebx].ADDINDATA.fProject
		add fRunning,30h
		invoke WritePrivateProfileString,o$ szProtos,o$ szEnabled,o$ fRunning,[ebx].ADDINDATA.lpProject
		invoke WritePrivateProfileString,o$ szProtos,o$ szFileName,o$ szFileToSaveTo,[ebx].ADDINDATA.lpProject
		sub fRunning, 30h
		mov edx, MF_BYCOMMAND
		.IF fRunning == 1
			or edx, MF_CHECKED
		.ENDIF
		mov eax, lpHandles
		invoke CheckMenuItem,[eax].ADDINHANDLES.hMenu,IDAddIn,edx
	.endif
	ret
SaveSettingsToProjectFile endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD
	mov	ebx,hWin

	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov		lpHandles,eax

	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax

	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax

	; Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov		IDAddIn,eax
	invoke AddMenu,IDAddIn,addr szCreateProtos

	; Messages to hook into
	mov		eax,RAM_COMMAND OR RAM_CLOSE OR RAM_MENUREBUILD or RAM_MAKEBEGIN or RAM_PROJECTOPENED or RAM_PROJECTCLOSED
	mov		ecx,RAM_ADDINSLOADED

	; EDX must be null before we return
	xor		edx,edx
	ret

InstallDll Endp

ProtoProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		;Language translate the dialog
		push	FALSE
		push	offset szAppName
		push	hWin
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpSetLanguage
		m2m hWnd, hWin
		mov eax, fRunning
		invoke SendDlgItemMessage,hWin,IDC_PROTOTOFILE,BM_SETCHECK,fRunning,0
		invoke SetDlgItemText,hWin,IDC_EDT1,o$ szFileToSaveTo
		invoke LoadIntoLstBox
		
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_SENDTOOUTPUT
				invoke SendToOutput
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_CANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_PROTOTOFILE
				invoke SendDlgItemMessage,hWin,IDC_PROTOTOFILE,BM_GETCHECK,0,0
				mov fRunning,eax
				.IF eax == BST_CHECKED
					invoke GetDlgItemText,hWin,IDC_EDT1,o$ szFileToSaveTo,56
					.IF eax == 0
						mov eax, BN_CLICKED
						shl eax, 16
						add eax, IDC_OPENFILENAME
						invoke SendMessage,hWin,WM_COMMAND,eax,0
					.ENDIF 
				.ENDIF
			
			.elseif eax==IDC_SELECTALL
				invoke SendDlgItemMessage,hWin,IDC_LSTPROTO,LB_GETCOUNT,0,0
				invoke SendDlgItemMessage,hWin,IDC_LSTPROTO,LB_SELITEMRANGE,TRUE,eax
			
			.elseif eax==IDC_OPENFILENAME
				mov ofn.lStructSize, s$ ofn
				m2m ofn.hwndOwner, hWin
				;m2m ofn.hInstance, hInstance
				mov ofn.lpstrFilter, o$ ofnFilter
				lea eax, buffer
				mov d$[buffer],0
				mov ofn.lpstrFile,eax 
				mov ofn.nMaxFile,256
				mov edx, lpData
				mov ofn.lpstrInitialDir, $eax([edx].ADDINDATA.lpProjectPath)
				mov ofn.Flags,OFN_EXPLORER+OFN_LONGNAMES+OFN_PATHMUSTEXIST
				invoke GetOpenFileName,o$ ofn
				.IF eax != 0
					lea eax, buffer
					add ax, ofn.nFileOffset
					invoke lstrcpy,o$ szFileToSaveTo, eax
					invoke SetDlgItemText,hWin,IDC_EDT1,o$ szFileToSaveTo
				.ELSE
					invoke SendDlgItemMessage,hWin,IDC_PROTOTOFILE,BM_SETCHECK,BST_UNCHECKED,0
					mov fRunning,0
				.ENDIF
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke SaveSettingsToProjectFile
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

ProtoProc endp

CreateProtoLine proc uses esi edi,lpProperty:DWORD,lpOut:DWORD,fCRLF:DWORD

	mov		esi,lpProperty
	lea		esi,[esi+sizeof PROPERTIES]
	mov		edi,lpOut
	mov		edx,lpData
	mov		eax,[edx].ADDINDATA.nAsm
	.if eax==nMASM || eax==nTASM
		invoke lstrcpy,edi,esi
		invoke lstrlen,edi
		lea		edi,[edi+eax]
		.while eax<32
			mov		byte ptr [edi],' '
			inc		edi
			inc		eax
		.endw
		invoke lstrcpy,edi,addr szProto
		invoke lstrlen,edi
		lea		edi,[edi+eax]
		;Point to proc parameters
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		mov		ah,VK_TAB
		.while byte ptr [esi]
			.if byte ptr [esi]==':'
				mov		[edi],ah
				inc		edi
				.while byte ptr [esi] && byte ptr [esi]!=','
					mov		al,[esi]
					mov		[edi],al
					inc		esi
					inc		edi
				.endw
				mov		ah,','
			.else
				inc		esi
			.endif
		.endw
		.if fCRLF
			mov		dword ptr [edi],0A0Dh
		.else
			mov		byte ptr [edi],0
		.endif
	.elseif eax==nCPP
		push	esi
		;Point to proc parameters
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		;Point to locals
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		;Point to return type
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		.if byte ptr [esi]
			invoke lstrcpy,edi,esi
			invoke lstrlen,edi
			mov		word ptr [edi+eax],' '
		.else
			invoke lstrcpy,edi,addr szDWORD
		.endif
		pop		esi
		invoke lstrcat,edi,esi
		invoke lstrcat,edi,addr szLPA
		invoke lstrlen,edi
		lea		edi,[edi+eax]
		;Point to proc parameters
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		.while byte ptr [esi]
			push	esi
			.while byte ptr [esi] && byte ptr [esi]!=':' && byte ptr [esi]!=','
				inc		esi
			.endw
			.if byte ptr [esi]==':'
				inc		esi
				.while byte ptr [esi] && byte ptr [esi]!=','
					mov		al,[esi]
					mov		[edi],al
					inc		esi
					inc		edi
				.endw
				mov		byte ptr [edi],0
			.else
				invoke lstrcpy,edi,addr szDWORD
				invoke lstrlen,edi
				lea		edi,[edi+eax]
			.endif
			mov		word ptr [edi],' '
			inc		edi
			pop		esi
			.while byte ptr [esi] && byte ptr [esi]!=':' && byte ptr [esi]!=','
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.while byte ptr [esi] && byte ptr [esi]!=','
				inc		esi
			.endw
			.if byte ptr [esi]==','
				inc		esi
				mov		word ptr [edi],','
				inc		edi
			.else
				mov		byte ptr [edi],0
			.endif
		.endw
		invoke lstrcat,edi,addr szRPA
		.if fCRLF
			invoke lstrcat,edi,addr szCRLF
		.else
		.endif
	.endif
	ret

CreateProtoLine endp

SaveToFile proc uses edi esi ebx
	LOCAL path[256]:BYTE
	LOCAL hFile:DWORD
	LOCAL buffer[256]:BYTE
	
	mov eax, lpData
	mov eax, [eax].ADDINDATA.lpProjectPath
	mov d$ [path],0
	invoke lstrcat,a$ path, eax
	invoke lstrcat,a$ path, o$ szFileToSaveTo
	invoke CreateFile,a$ path,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,0
	mov hFile, eax
	mov		edx,lpData
	.if [edx].ADDINDATA.fProject
		;A project is loaded, dump the procs
		;Get pointer to word list
		mov		esi,[edx].ADDINDATA.lpWordList
		;Skip the words loaded from .api files
		add		esi,[edx].ADDINDATA.rpProjectWordList
		;Loop trough the word list
		.while [esi].PROPERTIES.nSize
			;Check if it is a proc
			.if [esi].PROPERTIES.nType=='p'
				invoke CreateProtoLine,esi,addr buffer,TRUE
				invoke lstrlen,a$ buffer
				invoke WriteFile,hFile,a$ buffer,eax,o$ dummy,0
			.endif
			;Move to next word
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
		;invoke SendDlgItemMessage,hWnd,IDC_LSTPROTO,LB_SETCARETINDEX,0,0
	.endif
	invoke CloseHandle, hFile
	ret
SaveToFile endp


LoadIntoLstBox proc uses esi

		mov		edx,lpData
		.if [edx].ADDINDATA.fProject
			;A project is loaded, dump the procs
			;Get pointer to word list
			mov		esi,[edx].ADDINDATA.lpWordList
			;Skip the words loaded from .api files
			add		esi,[edx].ADDINDATA.rpProjectWordList
			;Loop trough the word list
			.while [esi].PROPERTIES.nSize
				;Check if it is a proc
				.if [esi].PROPERTIES.nType=='p'
					;Point to the proc name
					lea		eax,[esi+sizeof PROPERTIES]
					invoke SendDlgItemMessage,hWnd,IDC_LSTPROTO,LB_ADDSTRING,0,eax
					;Save the pointer
					invoke SendDlgItemMessage,hWnd,IDC_LSTPROTO,LB_SETITEMDATA,eax,esi
				.endif
				;Move to next word
				mov		eax,[esi].PROPERTIES.nSize
				lea		esi,[esi+eax+sizeof PROPERTIES]
			.endw
			invoke SendDlgItemMessage,hWnd,IDC_LSTPROTO,LB_SETCARETINDEX,0,0
		.endif
		ret
LoadIntoLstBox endp

SendToOutput proc uses edi esi ebx
	LOCAL buffer[256]:BYTE
	
	invoke clrOutput
	push	ebx
	push	edi
	xor		ebx,ebx
	.while TRUE
		invoke SendDlgItemMessage,hWnd,IDC_LSTPROTO,LB_GETSEL,ebx,0
		.break .if eax==LB_ERR
		.if eax
			invoke SendDlgItemMessage,hWnd,IDC_LSTPROTO,LB_GETITEMDATA,ebx,0
			mov		esi,eax
			invoke CreateProtoLine,esi,addr buffer,FALSE
			invoke TextOutput,addr buffer
		.endif
		inc		ebx
	.endw
	pop		edi
	pop		ebx
	ret
SendToOutput endp


; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	mnui:MENUITEMINFO

	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if edx==IDAddIn && eax==BN_CLICKED
			push	NULL
			push	offset ProtoProc
			push	hWin
			push	IDD_DLGPROTO
			push	hInstance
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpModalDialog
		.endif
	.elseif eax==AIM_CLOSE
		;Remove all menu items
		mov		eax,lpHandles
		invoke DeleteMenu,[eax].ADDINHANDLES.hMenu,IDAddIn,MF_BYCOMMAND
		invoke SaveSettingsToProjectFile
	.elseif eax==AIM_MENUREBUILD
		invoke AddMenu,IDAddIn,addr szCreateProtos
		call	Translate
	.elseif eax==AIM_ADDINSLOADED
		call	Translate
	.elseif eax==AIM_MAKEBEGIN
		.IF fRunning == 1
			invoke SaveToFile
		.ENDIF
	.elseif eax==AIM_PROJECTOPENED
		; See if we're on AutoLoad
		invoke LoadSettingsFromProjectFile
	.elseif eax==AIM_PROJECTCLOSED
		invoke SaveSettingsToProjectFile
		mov fRunning,0
	.endif

	mov eax,FALSE
	ret

Translate:
	;Language translate menu item
	push	sizeof buffer/2
	lea		eax,buffer
	push	eax
	push	2000
	push	offset szAppName
	mov		eax,lpProc
	call	[eax].ADDINPROCS.lpGetLangString
	.if eax
		mov		mnui.cbSize,sizeof mnui
		mov		mnui.fMask,MIIM_TYPE
		mov		mnui.fType,MFT_STRING
		lea		eax,buffer
		mov		mnui.dwTypeData,eax
		;Insert our menuitem
		mov		edx,[lpHandles]
		invoke SetMenuItemInfoW,(ADDINHANDLES ptr [edx]).hMenu,IDAddIn,FALSE,addr mnui
	.endif
	retn

DllProc Endp

;#########################################################################

End DllEntry
