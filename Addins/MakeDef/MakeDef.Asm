;############################################################################
; MAKEDEF
; By Donkey 2003
;############################################################################
	.486
	.model flat,stdcall
	option casemap:none

;############################################################################

	include MakeDef.Inc

;############################################################################

.code

DllEntry PROC hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	
	mov eax, hInst
	mov hInstance, eax
	mov eax,TRUE
	ret
	
DllEntry ENDP

InstallDll PROC hWin:DWORD, fOpt:DWORD

	invoke RtlZeroMemory,offset buff,sizeof buff
	mov fDllProj,0
	invoke SendMessage, hWin, AIM_GETHANDLES, 0, 0
	mov	lpHandles, eax
	invoke SendMessage, hWin, AIM_GETPROCS, 0, 0
	mov lpProcs, eax
	invoke SendMessage, hWin, AIM_GETDATA, 0, 0
	mov lpData, eax
	mov eax,fOpt
	mov Options,eax

	mov eax,lpHandles
	mov ecx,[eax].ADDINHANDLES.hPrpLst
	mov hPrpLst,ecx
	mov ecx,[eax].ADDINHANDLES.hPrpCbo
	mov hPrpCbo,ecx
	mov ecx,[eax].ADDINHANDLES.hPrpTbr
	mov hPrpTbr,ecx

	mov eax,lpData
	mov ecx,[eax].ADDINDATA.lpProject
	mov pRapFile,ecx
	mov ecx,[eax].ADDINDATA.nRadASMVer
	.IF eax < 2027
		mov Options,0
	.ENDIF

	.IF Options!=0
		invoke SendMessage, hWin, AIM_GETMENUID, 0, 0
		mov AddInID1, eax
		invoke SendMessage, hWin, AIM_GETMENUID, 0, 0
		mov AddInID2, eax
		invoke SendMessage, hWin, AIM_GETMENUID, 0, 0
		mov AddInID3, eax
		mov eax, lpHandles
		invoke GetSubMenu,[eax].ADDINHANDLES.hToolMenu,4
		mov hSubMenu,eax
		invoke AppendMenu,hSubMenu,MF_SEPARATOR,AddInID3,NULL
		invoke AppendMenu,hSubMenu,MF_STRING OR MF_GRAYED,AddInID1,OFFSET szAddProc
		invoke AppendMenu,hSubMenu,MF_STRING OR MF_GRAYED,AddInID2,OFFSET szRemAll
		mov eax, RAM_COMMAND OR RAM_PROJECTOPENED OR RAM_CONTEXTMENU OR RAM_MAKEBEGIN OR RAM_PROJECTCLOSE OR RAM_CLOSE
	.ELSE
		mov eax,NULL
	.ENDIF
	xor ecx,ecx
	xor edx,edx
	ret
InstallDll ENDP

GetOptions proc

	mov eax,offset AddinOpt
	ret
GetOptions endp

DllProc	PROC uses edi esi ebx edx hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
	LOCAL pt		:POINT

	cmp fDllProj,0
	jz PROJECTOPENED

	cmp MemDis,TRUE
	jz @@AllDone

	MAKEBEGIN:
	cmp uMsg, AIM_MAKEBEGIN
	jnz COMMAND
		.IF Options !=1
			invoke CleanExportSection
			.IF eax != 0FFFFh
				invoke BuildDefFile
			.ENDIF
		.ENDIF
		jmp @@AllDone

	COMMAND:
	cmp uMsg, AIM_COMMAND
	jnz CONTEXTMENU
		mov eax, wParam
		movzx eax,ax
		cmp eax,AddInID1
		jnz @@AddinID2
			mov eax,pProcName
			mov eax,[eax]
			.IF al != 0
				invoke GetMenuString,hSubMenu,AddInID1,pExString,64,MF_BYCOMMAND
				mov eax,pExString
				mov al,[eax]
				.IF al != "R"
					invoke WriteExportName,pProcName
				.ELSE
					invoke RemoveExportName,pProcName
					invoke RebuildExportList
					invoke SendMessage,hPrpCbo,CB_GETCURSEL,0,0
					.IF eax == nCbItem
						invoke WriteExportList
					.ENDIF
				.ENDIF
			.ENDIF
			mov eax,TRUE
			ret

		@@AddinID2:
		cmp eax,AddInID2
		jnz @@Refresh
			invoke RemoveAllExports
			invoke SendMessage,hPrpCbo,CB_GETCURSEL,0,0
			.IF eax == nCbItem
				invoke WriteExportList
			.ENDIF
			mov eax,TRUE
			ret

		@@Refresh:
		cmp eax,RefreshID
		jnz @@Notify
			invoke SendMessage,hPrpCbo,CB_GETCURSEL,0,0
			.IF eax == nCbItem
				invoke CleanExportSection
				invoke WriteExportList
			.ELSEIF eax == 0
				invoke CleanExportSection
				.IF eax != 0FFFFh
					invoke BuildDefFile
				.ENDIF
			.ENDIF
			jmp @@AllDone

		@@Notify:
		cmp eax,0
		jnz @@AllDone
			mov eax,hPrpCbo
			cmp eax,lParam
			jnz @@AllDone
				mov eax,wParam
				clc
				shr eax,16
				cmp eax,CBN_CLOSEUP
				jnz @@AllDone
					mov eax,lpHandles
					invoke SendMessage,hPrpCbo,CB_GETCURSEL,0,0
					.IF eax==nCbItem
						invoke WriteExportList
					.ENDIF
					jmp @@AllDone

	CONTEXTMENU:
	cmp uMsg, AIM_CONTEXTMENU
	jnz PROJECTOPENED
		invoke GetCursorPos,ADDR pt
		invoke WindowFromPoint,pt.x,pt.y
		; Make sure that this is the properties listbox
		cmp eax,hPrpLst
		jne @@AllDone
		; Check to see if a project is loaded
		mov eax,lpData
		mov eax,[eax].ADDINDATA.fProject
		.IF eax==TRUE
			invoke SendMessage,hPrpCbo,CB_GETCURSEL,0,0
			.IF eax == 0 ; Is the .code list being displayed
				invoke EnableMenuItem, hSubMenu, AddInID1, MF_BYCOMMAND OR MF_ENABLED
				invoke EnableMenuItem, hSubMenu, AddInID2, MF_BYCOMMAND OR MF_ENABLED
				; Get the proc name before the menu appears
				invoke GetProcName,pProcName
				invoke CheckForProc,pProcName
				.IF eax == TRUE
					invoke ModifyMenu,hSubMenu,AddInID1,MF_BYCOMMAND OR MF_STRING,AddInID1,OFFSET szRemProc
				.ELSE
					invoke ModifyMenu,hSubMenu,AddInID1,MF_BYCOMMAND OR MF_STRING,AddInID1,OFFSET szAddProc
				.ENDIF
			.ELSEIF eax == nCbItem ; Is the Exports list being displayed
				invoke EnableMenuItem, hSubMenu, AddInID1, MF_BYCOMMAND OR MF_ENABLED
				invoke EnableMenuItem, hSubMenu, AddInID2, MF_BYCOMMAND OR MF_ENABLED
				invoke ModifyMenu,hSubMenu,AddInID1,MF_BYCOMMAND OR MF_STRING,AddInID1,OFFSET szRemProc
				invoke GetProcName,pProcName
			.ELSE
				invoke EnableMenuItem, hSubMenu, AddInID1, MF_BYCOMMAND OR MF_GRAYED
				invoke EnableMenuItem, hSubMenu, AddInID2, MF_BYCOMMAND OR MF_GRAYED
			.ENDIF
		.ENDIF
		jmp @@AllDone

	PROJECTCLOSE:
	cmp uMsg, AIM_PROJECTCLOSE
	jnz PROJECTOPENED
		invoke CleanExportSection
		invoke RtlZeroMemory,offset buff,sizeof buff
		mov fDllProj,0
		jmp @@AllDone

	PROJECTOPENED:
	cmp uMsg, AIM_PROJECTOPENED
	jnz CLOSE
		; Check to see if there is a DEF file
		invoke CheckForDef
		.IF eax == TRUE
			invoke EnableMenuItem, hSubMenu, AddInID1, MF_BYCOMMAND OR MF_ENABLED
			invoke EnableMenuItem, hSubMenu, AddInID2, MF_BYCOMMAND OR MF_ENABLED
		.ELSE
			invoke EnableMenuItem, hSubMenu, AddInID1, MF_BYCOMMAND OR MF_GRAYED
			invoke EnableMenuItem, hSubMenu, AddInID2, MF_BYCOMMAND OR MF_GRAYED
		.ENDIF
		jmp @@AllDone

	CLOSE:
	cmp uMsg, AIM_CLOSE
	jnz @@AllDone
		invoke DeleteMenu,hSubMenu,AddInID1,MF_BYCOMMAND
		invoke DeleteMenu,hSubMenu,AddInID2,MF_BYCOMMAND
		invoke DeleteMenu,hSubMenu,AddInID3,MF_BYCOMMAND

	@@AllDone:
	xor eax, eax
	ret
DllProc	ENDP

BuildDefFile PROC

	mov eax,lpData
	add eax,ADDINDATA.szAssembler

	invoke lstrcmpi,eax,OFFSET szAsmMASM
	.IF eax == 0
		.IF Options == 1
			invoke BuildMASMDefOut
		.ELSE
			invoke BuildMASMDefFile
		.ENDIF
		jmp @@AllDone
	.ENDIF

	mov eax,lpData
	add eax,ADDINDATA.szAssembler

	invoke lstrcmpi,eax,OFFSET szAsmGOASM
	.IF eax == 0
		.IF Options==1
			invoke BuildGoAsmDefOut
		.ELSE
			invoke BuildGoAsmDefFile
		.ENDIF
		jmp @@AllDone
	.ENDIF

	@@AllDone:
	RET
BuildDefFile ENDP

CheckForDef PROC
	LOCAL buffer[64]			:BYTE
	LOCAL lpPrpCboItems[256] 	:DWORD

	; File type 6 is the def file

	invoke GetPrivateProfileString,OFFSET szMakeFiles,OFFSET szSix,OFFSET szDefFind,pDefFile,64,pRapFile

	mov fDllProj,FALSE
	xor ecx,ecx
	xor eax,eax
	.REPEAT
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke GetPrivateProfileString,OFFSET szFiles,OFFSET iniKey,OFFSET szDefFind,ADDR buffer,64,pRapFile
		invoke lstrcmpi,ADDR buffer,pDefFile
		pop ecx
		cmp eax,0
		jnz @F
			mov fDllProj,TRUE
			jmp @@AllDone
		@@:
		cmp ecx,16
			jz @@AllDone ; break at 16 files
		lea eax,buffer
		mov eax,[eax]
	.UNTIL al == ";"

	@@AllDone:

	.IF fDllProj && !nCbItem
		invoke SendMessage,hPrpCbo,CB_RESETCONTENT,0,0
		mov eax,lpData
		invoke lstrcat,[eax].ADDINDATA.lpPrpCboItems,OFFSET szExpCbo-1
		push 0
		mov eax,lpProcs
		call [eax].ADDINPROCS.lpSetPropertyCbo
		invoke SendMessage,hPrpCbo,CB_GETCOUNT,0,0
		dec eax
		mov nCbItem,eax

	.ELSEIF !fDllProj && nCbItem
		invoke SendMessage,hPrpCbo,CB_RESETCONTENT,0,0
		mov eax,lpData
		mov eax,[eax].ADDINDATA.lpPrpCboItems
		invoke ParseCboString,eax
		push 0
		mov eax,lpProcs
		call [eax].ADDINPROCS.lpSetPropertyCbo
		mov nCbItem,NULL

	.ELSEIF fDllProj && nCbItem
		invoke SendMessage,hPrpCbo,CB_RESETCONTENT,0,0
		push 0
		mov eax,lpProcs
		call [eax].ADDINPROCS.lpSetPropertyCbo
		invoke SendMessage,hPrpCbo,CB_GETCOUNT,0,0
		dec eax
		mov nCbItem,eax

	.ENDIF

	mov eax,fDllProj
	RET
CheckForDef ENDP

ParseCboString PROC uses esi eax pCboString:DWORD
	LOCAL buffer[128]	:BYTE
	LOCAL tmpbuffer[128]	:BYTE
	LOCAL ptmpbuffer	:DWORD
	; This will strip out the ,Export,0 from the combo string
	; I made it this complex so that other items can be added
	; after it and won't be truncated. No heap memory is used
	; as this proc is used in the heap error trap.

	lea eax,tmpbuffer
	mov ptmpbuffer,eax

	invoke CopyString,ptmpbuffer,pCboString

	invoke InString,1,ptmpbuffer,OFFSET szExpCbo
	.IF eax == 0
		ret
	.ENDIF
	push eax
	invoke lstrcpyn,ADDR buffer,ptmpbuffer,eax
	pop eax
	add eax,ptmpbuffer
	add eax,9
	invoke lstrcat,ADDR buffer,eax

	invoke StrLen,ADDR buffer
	lea esi,buffer
	add esi,eax
	dec esi
	mov al,[esi]
	cmp al,","
	jnz @F
		mov [esi],BYTE PTR 0
		mov [esi+1],BYTE PTR 0
	@@:
	invoke CopyString,pCboString,ADDR buffer

	ret

ParseCboString ENDP

CheckForProc PROC lpProcName:DWORD
	LOCAL Found			:DWORD

	mov Found,FALSE
	xor ecx,ecx
	.REPEAT
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke GetPrivateProfileString,OFFSET szExports,OFFSET iniKey,OFFSET szDefFind,pExString,64,pRapFile
		invoke lstrcmp,pExString,lpProcName
		pop ecx
		cmp eax,0
		jne @F
			mov Found,TRUE
			jmp @@AllDone
		@@:
		mov eax,pExString
		mov eax,[eax]
	.UNTIL al == ";"

	@@AllDone:
	mov eax,Found
	RET
CheckForProc ENDP

GetProcName PROC uses edi ecx lpProcName:DWORD
	LOCAL pt			:POINT
	LOCAL Found			:DWORD

	invoke RtlZeroMemory,lpProcName,64

	mov Found,-1
	; Get the current cursor position
	invoke GetCursorPos,ADDR pt
	invoke ScreenToClient,hPrpLst,ADDR pt
	; Make an lParam from the POINT structure
	mov eax,pt.y
	shl eax,16 ; We only care about Y
	invoke SendMessage,hPrpLst,LB_ITEMFROMPOINT,0,eax
	; Check the high order word without trashing eax
	mov ecx,eax
	clc
	shr ecx,16
	cmp ecx,0
	; If there is no item we're done
	jne @@AllDone
	movzx eax,ax
	invoke SendMessage,hPrpLst,LB_GETTEXT,eax,lpProcName
	; Truncate the name at the first tab
	mov edi,lpProcName
	dec edi
	@@:
	inc edi
	mov al,[edi]
	or al,al
	je @F
	cmp al,9
	jne @B
	@@:
	mov [edi],BYTE PTR 0
	; the proc name is now in lpbuffer return 0
	mov Found,0
	@@AllDone:
	mov eax,Found
	RET
GetProcName ENDP

RemoveExportName PROC uses edi esi ebx ecx lpProcName:DWORD
	LOCAL buffer[64]	:BYTE
	LOCAL Found			:DWORD

	mov Found,FALSE
	xor ecx,ecx
	.REPEAT
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke GetPrivateProfileString,OFFSET szExports,OFFSET iniKey,OFFSET szDefFind,ADDR buffer,64,pRapFile
		invoke lstrcmp,ADDR buffer,lpProcName
		pop ecx
		cmp eax,0
		jne @F
			mov Found,TRUE
			invoke dw2a,ecx,OFFSET iniKey
			invoke WritePrivateProfileString,OFFSET szExports,OFFSET iniKey,NULL,pRapFile
			jmp @@AllDone
		@@:
		lea eax,buffer
		mov al,[eax]
	.UNTIL al == ";"

	@@AllDone:
	RET
RemoveExportName ENDP

RemoveAllExports PROC

	invoke MessageBox,NULL,OFFSET szVerify,NULL,MB_OKCANCEL
	.IF eax != IDCANCEL
		invoke WritePrivateProfileSection,OFFSET szExports,NULL,pRapFile
	.ENDIF

	RET
RemoveAllExports ENDP

WriteExportName PROC uses edi edx ecx lpProcName:DWORD

	; Scan for next empty rap file entry
	xor ecx,ecx
	@@:
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke GetPrivateProfileString,OFFSET szExports,OFFSET iniKey,OFFSET szDefFind,pTempBuffer,64,pRapFile
		pop ecx
		cmp eax,1
		jz @@AllDone
	jmp @B

	@@AllDone:
	invoke WritePrivateProfileString,OFFSET szExports,OFFSET iniKey,lpProcName,pRapFile

	RET
WriteExportName ENDP

BuildMASMDefFile PROC uses edi ecx
	LOCAL DllFile[64]		:BYTE
	LOCAL hFile				:DWORD
	LOCAL br				:DWORD

	; MASM Syntax
	
	invoke GetPrivateProfileString,OFFSET szMakeFiles,OFFSET szSeven,OFFSET szDefFind,ADDR DllFile,64,pRapFile

	mov eax,lpData
	mov eax,[eax].ADDINDATA.lpProjectPath
	invoke lstrcpy,pTempBuffer,eax
	invoke lstrcat,pTempBuffer,pDefFile
	invoke  CreateFile,pTempBuffer,GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,NULL
	mov hFile,eax
	invoke SetEndOfFile,hFile

	invoke wsprintf,pExString,Offset MDllHdr,ADDR DllFile
	invoke StrLen,pExString
	mov ecx,eax
	invoke WriteFile,hFile,pExString,ecx,ADDR br,NULL
	invoke WriteFile,hFile,OFFSET MExportHdr,9,ADDR br,NULL

	xor ecx,ecx
	.REPEAT
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke GetPrivateProfileString,OFFSET szExports,OFFSET iniKey,OFFSET szDefFind,pExString,64,pRapFile
		mov eax,pExString
		mov al,[eax]
		.IF al != ";"
			mov edi,pExString
			dec edi
			mov [edi],BYTE PTR 9
			invoke StrLen,edi
			push eax
			add eax,edi
			mov [eax],BYTE PTR 0dh
			mov [eax+1],BYTE PTR 0ah
			mov [eax+2],BYTE PTR 00h
			pop eax
			add eax,2
			mov ecx,eax
			invoke WriteFile,hFile,edi,ecx,ADDR br,NULL
		.ENDIF
		pop ecx
		mov eax,pExString
		mov al,[eax]
	.UNTIL al == ";"

	invoke CloseHandle,hFile
	

	RET
BuildMASMDefFile ENDP

BuildGoAsmDefFile PROC uses edi ecx
	LOCAL hFile				:DWORD
	LOCAL br				:DWORD

	; GoAsm Syntax

	mov eax,lpData
	mov eax,[eax].ADDINDATA.lpProjectPath
	invoke lstrcpy,pTempBuffer,eax
	invoke lstrcat,pTempBuffer,pDefFile
	invoke  CreateFile,pTempBuffer,GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,NULL
	mov hFile,eax
	invoke SetEndOfFile,hFile

	xor ecx,ecx
	.REPEAT
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke GetPrivateProfileString,OFFSET szExports,OFFSET iniKey,OFFSET szDefFind,pExString,64,pRapFile
		mov eax,pExString
		mov al,[eax]
		.IF al != ";"
			invoke wsprintf,pLineString,OFFSET GExportHdr,pExString
			invoke StrLen,pLineString
			mov edi,pLineString
			add edi,eax
			mov [edi],BYTE PTR 0Dh
			mov [edi+1],BYTE PTR 0Ah
			mov [edi+2],BYTE PTR 0
			add eax,2
			mov ecx,eax
			invoke WriteFile,hFile,pLineString,ecx,ADDR br,NULL
		.ENDIF
		pop ecx
		mov eax,pExString
		mov al,[eax]
	.UNTIL al == ";"

	invoke CloseHandle,hFile

	RET
BuildGoAsmDefFile ENDP

VerifyProc PROC uses ecx esi lpProcName:DWORD

	mov		edx,lpData
	.if [edx].ADDINDATA.fProject
		;A project is loaded, test the procs
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
				push	eax
				invoke lstrcmp,eax,lpProcName
				or		eax,eax
				pop		eax
				je		@@FOUND
			.endif
			;Move to next word
			mov		eax,[esi].PROPERTIES.nSize
			lea		esi,[esi+eax+sizeof PROPERTIES]
		.endw
	.endif

	@@NOTFOUND:
	mov eax,-1
	jmp @@AllDone

	@@FOUND:
	;Return relative pointer in edx
	mov		edx,lpData
	sub		esi,[edx].ADDINDATA.lpWordList
	mov		edx,esi
	@@AllDone:
	
	RET
VerifyProc ENDP

RebuildExportList PROC
	LOCAL pNext				:DWORD
	LOCAL ccCopied			:DWORD
	LOCAL hVirtMem			:DWORD
	LOCAL pVirtMem			:DWORD

	invoke SetLastError,0
	invoke GlobalAlloc,GMEM_MOVEABLE+GMEM_ZEROINIT,32768
	mov hVirtMem,eax
	.IF eax == 0
		mov MemDis,TRUE
		invoke GetLastError
		invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM,NULL,eax,NULL,pTempBuffer,128,NULL
		invoke MessageBox,NULL,pTempBuffer,NULL,MB_OK
		ret
	.endif
	invoke GlobalLock,hVirtMem
	mov pVirtMem,eax

	invoke GetPrivateProfileSection,OFFSET szExports,pVirtMem,32767,pRapFile
	mov ccCopied,eax
	cmp eax,0
	je @@AllDone
	invoke WritePrivateProfileSection,OFFSET szExports,NULL,pRapFile

	mov edi,pVirtMem
	add ccCopied,edi
	dec ccCopied

	@@:
		inc edi
		mov al,[edi]
		cmp al,0
		je @@AllDone
		cmp al,"="
		jne @B
	inc edi
	mov pNext,edi

	xor ecx,ecx
	.WHILE edi < ccCopied
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke WritePrivateProfileString,OFFSET szExports,OFFSET iniKey,pNext,pRapFile
		pop ecx
		@@:
		inc edi
		cmp edi,ccCopied
		jg @@AllDone
		mov al,[edi]
		cmp al,"="
		jne @B
		inc edi
		mov pNext,edi
	.ENDW

	@@AllDone:

	invoke GlobalUnlock,hVirtMem
	invoke GlobalFree,hVirtMem

	RET
RebuildExportList ENDP

CleanExportSection PROC
	LOCAL hVirtMem			:DWORD
	LOCAL pVirtMem			:DWORD

	invoke SetLastError,0
	invoke GlobalAlloc,GMEM_MOVEABLE+GMEM_ZEROINIT,32768
	mov hVirtMem,eax
	.IF eax == 0
		mov MemDis,TRUE
		invoke GetLastError
		invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM,NULL,eax,NULL,pTempBuffer,128,NULL
		invoke MessageBox,NULL,pTempBuffer,NULL,MB_OK
		ret
	.endif
	invoke GlobalLock,hVirtMem
	mov pVirtMem,eax

	invoke GetPrivateProfileSection,OFFSET szExports,pVirtMem,64,pRapFile
	.IF eax < 3 ; a return value of 3 is the minimum acceptable(1=a)
		invoke GlobalUnlock,hVirtMem
		invoke GlobalFree,hVirtMem
		mov eax,0FFFFh
		RET
	.ENDIF

	xor ecx,ecx
	@@Repeat:
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke GetPrivateProfileString,OFFSET szExports,OFFSET iniKey,OFFSET szDefFind,pVirtMem,64,pRapFile
		mov eax,pVirtMem
		mov al,[eax]
		pop ecx
		cmp al,";"
		je @@AllDone
		invoke VerifyProc,pVirtMem
		.IF eax == -1
			invoke RemoveExportName,pVirtMem
		.ENDIF
	jmp @@Repeat

	@@AllDone:
		invoke RebuildExportList

	invoke GlobalUnlock,hVirtMem
	invoke GlobalFree,hVirtMem

	RET
CleanExportSection ENDP

WriteExportList PROC uses edi
	LOCAL hVirtMem			:DWORD
	LOCAL pVirtMem			:DWORD
	LOCAL ccCopied			:DWORD
	LOCAL pNext				:DWORD

	invoke SetLastError,0
	invoke GlobalAlloc,GMEM_MOVEABLE+GMEM_ZEROINIT,32768
	mov hVirtMem,eax
	.IF eax == 0
		mov MemDis,TRUE
		invoke GetLastError
		invoke FormatMessage,FORMAT_MESSAGE_FROM_SYSTEM,NULL,eax,NULL,pTempBuffer,128,NULL
		invoke MessageBox,NULL,pTempBuffer,NULL,MB_OK
		ret
	.endif
	invoke GlobalLock,hVirtMem
	mov pVirtMem,eax

	invoke SendMessage,hPrpLst,LB_RESETCONTENT,0,0

	invoke GetPrivateProfileSection,OFFSET szExports,pVirtMem,32767,pRapFile
	mov ccCopied,eax
	.IF eax < 3 ; a return value of 3 is the minimum acceptable(1=a)
		invoke GlobalUnlock,hVirtMem
		invoke GlobalFree,hVirtMem
		mov eax,0FFFFh
		RET
	.ENDIF

	mov edi,pVirtMem
	add ccCopied,edi
	dec ccCopied

	@@:
		inc edi
		mov al,[edi]
		cmp al,0
		je @@AllDone
		cmp al,"="
		jne @B
	inc edi
	mov pNext,edi

	.WHILE edi < ccCopied
		invoke VerifyProc,pNext
		.IF eax != -1
			push edx
			invoke SendMessage,hPrpLst,LB_ADDSTRING,0,eax
			pop edx
			invoke SendMessage,hPrpLst,LB_SETITEMDATA,eax,edx
		.ENDIF
		@@:
		inc edi
		cmp edi,ccCopied
		jg @@AllDone
		mov al,[edi]
		cmp al,"="
		jne @B
		inc edi
		mov pNext,edi
	.ENDW

	@@AllDone:

	mov eax,lpHandles
	invoke ShowWindow,[eax].ADDINHANDLES.hTxtLst,SW_HIDE
	mov eax,lpHandles
	invoke ShowWindow,[eax].ADDINHANDLES.hTxtBtn,SW_HIDE

	invoke GlobalUnlock,hVirtMem
	invoke GlobalFree,hVirtMem

	ret
WriteExportList ENDP

CopyString PROC uses esi edi ecx Dest:DWORD,Source:DWORD
	invoke StrLen,Source
	push eax		;save String length
	clc
	shr  eax,2		;eax = eax / 4
	inc eax
	mov ecx,eax
	mov esi,Source
	mov edi,Dest

	@@:
		mov eax, [esi]
		add esi, 4
		mov [edi], eax
		add edi, 4
		dec ecx
	jnz @B

	pop eax			;load String length
	add eax,Dest	;return a pointer to the null terminator
	ret
CopyString ENDP

BuildMASMDefOut PROC uses edi ecx
	LOCAL DllFile[64]		:BYTE
	LOCAL OutProc			:DWORD

	; MASM Syntax

	mov eax,lpProcs
	mov eax,[eax].ADDINPROCS.lpTextOut
	mov OutProc,eax

	mov eax,lpProcs
	mov eax,[eax].ADDINPROCS.lpClearOut
	call eax

	invoke GetPrivateProfileString,OFFSET szMakeFiles,OFFSET szSeven,OFFSET szDefFind,ADDR DllFile,64,pRapFile

	invoke wsprintf,pExString,Offset MOutDllHdr,ADDR DllFile
	push pExString
	call OutProc
	push OFFSET MOutExportHdr
	call OutProc

	xor ecx,ecx
	.REPEAT
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke GetPrivateProfileString,OFFSET szExports,OFFSET iniKey,OFFSET szDefFind,pExString,64,pRapFile
		mov eax,pExString
		mov al,[eax]
		.IF al != ";"
			mov edi,pExString
			dec edi
			mov [edi],BYTE PTR 9
			push edi
			call OutProc
		.ENDIF
		pop ecx
		mov eax,pExString
		mov al,[eax]
	.UNTIL al == ";"

	RET
BuildMASMDefOut ENDP

BuildGoAsmDefOut PROC uses edi ecx
	LOCAL OutProc			:DWORD

	; GoAsm Syntax

	mov eax,lpProcs
	mov eax,[eax].ADDINPROCS.lpTextOut
	mov OutProc,eax

	mov eax,lpProcs
	mov eax,[eax].ADDINPROCS.lpClearOut
	call eax

	xor ecx,ecx
	.REPEAT
		inc ecx
		push ecx
		invoke dw2a,ecx,OFFSET iniKey
		invoke GetPrivateProfileString,OFFSET szExports,OFFSET iniKey,OFFSET szDefFind,pExString,64,pRapFile
		mov eax,pExString
		mov al,[eax]
		.IF al != ";"
			invoke wsprintf,pLineString,OFFSET GExportHdr,pExString
			push pLineString
			call OutProc
		.ENDIF
		pop ecx
		mov eax,pExString
		mov al,[eax]
	.UNTIL al == ";"

	RET
BuildGoAsmDefOut ENDP

End DllEntry
