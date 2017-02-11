.const

SettingsLoadIni proto :dword,:dword


;Settings.dlg
IDD_FILESDLG					equ 1000
IDC_INILIST						equ 1002
IDC_STC1						equ 1003
IDC_GRP1						equ 1004
IDC_STC4						equ 1001
IDC_GRP							equ 1006
IDC_STC2						equ 1007
IDC_STC3						equ 1008
IDC_STC5						equ 1009
IDC_STC7						equ 1010
IDC_HELPFILE					equ 1011
IDC_STC6						equ 1012
IDC_STC8						equ 1013
IDC_STC9						equ 1014
IDC_STC10						equ 1015
IDC_STC11						equ 1016
IDC_STC12						equ 1017
IDC_STC13						equ 1018
IDC_STC14						equ 1019
IDC_LISTFILE					equ 1020
IDC_LISTNAME					equ 1021
IDC_LISTDESCR					equ 1022
IDC_BROWSE						equ 1023
IDC_OK							equ 1024
IDC_APPLY						equ 1025
IDC_CANCEL						equ 1026
IDC_STC15						equ 1027
IDC_REVERT						equ 1028
IDC_FILELIST					equ 1005

.data?
szCurrentIni db MAX_PATH dup (?)
bUnsaved dd ?
bIgnoreChange dd ?

.code

KwlInfo struct
	pBaseFn dd ?
	pCompleteFn dd ?
	pName dd ?
	pDescr dd ?
	pFile dd ?
KwlInfo ends

SettingsGetKwlInfo proc uses esi edi ebx pKwl:dword
	
LOCAL pMem:dword
LOCAL buf1[MAX_PATH]:dword
LOCAL hFile:dword
LOCAL hMapping:dword
LOCAL pMapping:dword
LOCAL MappingSize:dword

	invoke GlobalAlloc,GMEM_FIXED,MAX_PATH*2 ; That should be big enough to store all this stuff
	mov pMem,eax

	mov eax,lpData
	invoke lstrcpy,addr buf1,(ADDINDATA ptr [eax]).lpAddIn
	invoke PathAppend,addr buf1,pKwl
	invoke CreateFile,addr buf1,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0
	mov hFile,eax
	invoke GetFileSize,hFile,0
	.if eax>1024
		mov eax,1024
	.endif
	mov MappingSize,eax
	invoke CreateFileMapping,hFile,0,PAGE_READONLY,0,MappingSize,0
	mov hMapping,eax
	invoke MapViewOfFile,hMapping,FILE_MAP_READ,0,0,MappingSize
	mov pMapping,eax
	
	mov ebx,pMem
	assume ebx:ptr KwlInfo
	lea edi,[ebx+sizeof KwlInfo]
	
	; Copy full name to buffer
	mov [ebx].pCompleteFn,edi
	lea esi,buf1
@@:	mov al,[esi]
	inc esi
	mov [edi],al
	inc edi
	cmp al,0
	jne @B
	
	; Copy base name to buffer
	mov [ebx].pBaseFn,edi
	invoke PathFindExtension,pKwl
	mov esi,pKwl
	sub eax,esi
	mov ecx,eax
	rep movsb
	mov byte ptr [edi],0
	inc edi
	
	; Copy kwl name to buffer
	mov [ebx].pName,edi
	mov esi,pMapping
@@:
	mov al,[esi]
	inc esi
	mov [edi],al
	inc edi
	cmp al,13
	jne @B
	mov byte ptr [edi-1],0
	inc esi ; Skip Lf
	
	; Copy kwl description to buffer
	mov [ebx].pDescr,edi
@@:
	mov al,[esi]
	inc esi
	mov [edi],al
	inc edi
	cmp al,13
	jne @B
	mov byte ptr [edi-1],0
	
	; Store position of filename buffer
	mov [ebx].pFile,edi
	
	assume ebx:nothing
	
	invoke UnmapViewOfFile,pMapping
	invoke CloseHandle,hMapping
	invoke CloseHandle,hFile
	
	mov eax,pMem
	ret

SettingsGetKwlInfo endp

InitFileList proc hDlg:dword
	
LOCAL hList:dword
LOCAL buf1[MAX_PATH]:BYTE
LOCAL wfd:WIN32_FIND_DATA
LOCAL hFind:dword
LOCAL lvi:LV_ITEM
LOCAL lvc:LV_COLUMN
LOCAL itemid:dword
LOCAL rc:RECT

	invoke GetDlgItem,hDlg,IDC_FILELIST
	mov hList,eax

	; Enable checkbox and tooltip styles
	invoke SendMessage,hList,LVM_SETEXTENDEDLISTVIEWSTYLE,LVS_EX_CHECKBOXES+LVS_EX_INFOTIP,LVS_EX_CHECKBOXES+LVS_EX_INFOTIP
	
	; Enable the automatic tooltips
	invoke SendMessage,hList,LVM_GETTOOLTIPS,0,0
	push eax
	invoke SendMessage,eax,TTM_SETDELAYTIME,TTDT_AUTOMATIC,1
	pop eax
	invoke SendMessage,eax,TTM_SETDELAYTIME,TTDT_AUTOPOP,5000
	
	; Set the column width to the correct value
	invoke GetClientRect,hList,addr lvc ; RECT.right == LV_COLUMN.cx :)
	mov lvc.imask,LVCF_WIDTH
	sub lvc.lx,20
	invoke SendMessage,hList,LVM_INSERTCOLUMN,0,addr lvc
	
	
	mov lvi.imask,LVIF_TEXT or LVIF_PARAM
	mov lvi.iItem,1000
	mov lvi.iSubItem,0
	
	.data?
		DefaultFilename db MAX_PATH dup (?)
	.data
		szDefaultBaseFn db "default",0
		szDefaultCompleteFn db "(No associated keywordlist)",0
		szDefaultName db "Default",0
		szDefaultDescr db "If a keyword is not in any other selected lists, it will match this list.",0
		DefaultKwlInfo KwlInfo <offset szDefaultBaseFn,offset szDefaultCompleteFn,offset szDefaultName,offset szDefaultDescr,offset DefaultFilename>
	.code
	mov lvi.pszText,CTEXT("(default)")
	mov lvi.lParam,offset DefaultKwlInfo
	invoke SendMessage,hList,LVM_INSERTITEM,0,addr lvi
	
	lea eax,wfd.cFileName
	mov lvi.pszText,eax

	mov eax,lpData
	mov eax,(ADDINDATA ptr [eax]).lpAddIn
	invoke PathCpy,addr buf1,eax
	invoke lstrcat,addr buf1,CTEXT("\*.kwl")
	invoke FindFirstFile,addr buf1,addr wfd
	mov hFind,eax
	cmp eax,INVALID_HANDLE_VALUE
	je Die

AddNextFile:
	invoke SettingsGetKwlInfo,addr wfd.cFileName
	mov lvi.lParam,eax
	invoke SendMessage,hList,LVM_INSERTITEM,0,addr lvi
	mov itemid,eax
	cmp eax,-1
	je Die
	invoke FindNextFile,hFind,addr wfd
	test eax,eax
	jnz AddNextFile
	invoke FindClose,hFind
	
Die:
	ret
InitFileList endp

InitIniList proc uses esi hDlg:dword
LOCAL hList:dword
LOCAL buf1[128]:BYTE
	
	lea esi,buf1

	invoke GetDlgItem,hDlg,IDC_INILIST
	mov hList,eax
	invoke SendMessage,hList,CB_ADDSTRING,0,CTEXT("RadASM.ini - Global default settings")
	.if eax==CB_ERR
		invoke GetErrDescription,0
	.endif
	invoke SendMessage,hList,CB_SETCURSEL,eax,0
	
	.data
	szAssembler db "Assembler",0
	.code
	mov eax,lpData
	invoke GetPrivateProfileString,addr szAssembler,addr szAssembler,addr szAssembler,esi,sizeof buf1,(ADDINDATA ptr [eax]).lpIniFile
	
	invoke StrLen,esi
	mov edi,esi
	add esi,eax
	inc esi
NextIni:
	invoke lstrcpy,addr [esi-1],CTEXT(".ini - Assembler-specific setting")
@@:	
	mov al,[esi]
	dec esi
	cmp esi,edi
	je @f
	cmp al,","
	jne @b
	add esi,2
@@:
	invoke SendMessage,hList,CB_ADDSTRING,0,esi
	cmp esi,edi
	jne NextIni	
	
	ret

InitIniList endp

ChangeIniFile proc hDlg:dword
	
LOCAL buf1[128]:BYTE
LOCAL hIniList:dword
LOCAL Sel:dword
	
	invoke GetDlgItem,hDlg,IDC_INILIST
	mov hIniList,eax	

	; Get current ini filename into szCurrentIni
	mov eax,lpData
	invoke lstrcpy,addr szCurrentIni,(ADDINDATA ptr [eax]).lpLoadPath
	invoke SendMessage,hIniList,CB_GETCURSEL,0,0
	mov Sel,eax
	invoke SendMessage,hIniList,CB_GETLBTEXT,Sel,addr buf1
	invoke StrStr,addr buf1,CTEXT(".ini - ")
	add eax,4
	mov byte ptr [eax],0
	invoke PathAppend,addr szCurrentIni,addr buf1
	
	; Enable/disable the revert button as appropriate
	invoke GetDlgItem,hDlg,IDC_REVERT
	invoke EnableWindow,eax,Sel
	
	; Load the settings from the new .ini file
	invoke SettingsLoadIni,hDlg,addr szCurrentIni	

	ret

ChangeIniFile endp

SettingsLoadIni proc uses esi edi ebx hDlg:dword,pIniFilename:dword
LOCAL buf1[256]:BYTE
LOCAL lvi:LV_ITEM
LOCAL hList:dword
LOCAL lfi:LVFINDINFO

	lea esi,buf1
	
	invoke GetDlgItem,hDlg,IDC_FILELIST
	mov hList,eax
	
	; Clear all checkboxes
	mov lvi.stateMask,LVIS_STATEIMAGEMASK
	mov lvi.state,(1 shl 12) ; Unchecked
	invoke SendMessage,hList,LVM_SETITEMSTATE,-1,addr lvi

	; Get list of enabled keywordfiles and set the checkbox for each file if it's enabled
	; (String constants defined in KeywordCache.asm)
	invoke GetPrivateProfileString,addr szRadHelp,addr szKwLists,addr szQ,esi,sizeof buf1,pIniFilename
	xor eax,eax
	.if byte ptr [esi]!="?" ; Only if there are RadASM settings in the ini, else return 0
		mov lfi.flags,LVFI_STRING
		
		mov lvi.state,(2 shl 12) ; Checked
		mov lvi.iSubItem,0
		
		invoke StrLen,esi
		mov edi,esi
		add esi,eax
		inc esi
		.if eax>=7
			; Default category is always the last one in the ini. It's not handled correctly by the loop, so handle it here.
			.if dword ptr [esi-8]=="afed" && dword ptr [esi-4]=="tlu"
				invoke SendMessage,hList,LVM_SETITEMSTATE,0,addr lvi
				sub esi,7
			.endif
		.endif
		
	NextIni:
		lea ebx,[esi-1]
		mov dword ptr [ebx],"lwk."
		mov dword ptr [ebx+4],0
	@@:	
		mov al,[esi]
		dec esi
		cmp esi,edi
		je @f
		cmp al,","
		jne @b
		add esi,2
	@@:
		mov lfi.psz,esi
		invoke SendMessage,hList,LVM_FINDITEM,-1,addr lfi
		.if eax!=-1
			mov edx,eax
			invoke SendMessage,hList,LVM_SETITEMSTATE,edx,addr lvi ; Set the checkbox to checked
		.endif
		cmp esi,edi
		jne NextIni
			
		; Loop through all the items in the listview to update the path of the helpfile associated with each item
		invoke SendMessage,hList,LVM_GETITEMCOUNT,0,0
		dec eax
		.if ZERO?
			ret
		.endif
		mov lvi.iItem,eax
		mov lvi.imask,LVIF_PARAM
	
	@@:
		invoke SendMessage,hList,LVM_GETITEM,0,addr lvi
		mov ebx,lvi.lParam
		.if ebx
			invoke GetPrivateProfileString,addr szRadHelp,[ebx+KwlInfo.pBaseFn],CTEXT("?"),[ebx+KwlInfo.pFile],MAX_PATH,pIniFilename
			mov eax,(KwlInfo ptr [ebx]).pFile
			.if byte ptr [eax]=="?"
				mov byte ptr [eax],0
			.endif
		.endif
		dec lvi.iItem
		jns @B
		
		mov eax,TRUE
	.else ; Zero all the filename entries
		invoke SendMessage,hList,LVM_GETITEMCOUNT,0,0
		dec eax
		.if ZERO?
			ret
		.endif
		mov lvi.iItem,eax
		mov lvi.imask,LVIF_PARAM
	@@:
		invoke SendMessage,hList,LVM_GETITEM,0,addr lvi
		mov eax,lvi.lParam
		.if eax
			mov eax,(KwlInfo ptr [eax]).pFile
			mov byte ptr [eax],0
		.endif
		dec lvi.iItem
		jns @B
		mov eax,FALSE
	.endif
	
	
	ret

SettingsLoadIni endp

SaveChanges proc hDlg:dword

LOCAL lvi:LVITEM
LOCAL buf1[256]:BYTE
LOCAL hList:dword

	.if szCurrentIni==0
		ret
	.endif

	invoke GetDlgItem,hDlg,IDC_FILELIST
	mov hList,eax
	
	mov lvi.state,0
	mov lvi.stateMask,LVIS_SELECTED
	invoke SendMessage,hList,LVM_SETITEMSTATE,-1,addr lvi
	
	invoke SendMessage,hList,LVM_GETITEMCOUNT,0,0
	dec eax
	.if SIGN?
		ret
	.endif
	mov lvi.iItem,eax
	mov lvi.imask,LVIF_PARAM + LVIF_STATE 
	mov lvi.stateMask,-1;LVIS_STATEIMAGEMASK
	mov lvi.state,-1
	
	lea eax,buf1
	mov word ptr [eax],0

	; Loop through all the items in the listview 

	assume ebx:ptr KwlInfo
@@:
	invoke SendMessage,hList,LVM_GETITEM,0,addr lvi
	.if eax
		mov ebx,lvi.lParam
		.if ebx
			; Write the helpfile filename to the ini
			invoke WritePrivateProfileString,addr szRadHelp,[ebx].pBaseFn,[ebx].pFile,addr szCurrentIni
			
			; lvi.state should already be ok, but is always 0!?
			invoke SendMessage,hList,LVM_GETITEMSTATE,lvi.iItem,-1
			shr eax,13
			.if !CARRY?
			;.if lvi.state & (2 shl 12) ; If it's checked add it to the list of selected keywordfiles
				invoke lstrcat,addr buf1,CTEXT(",")
				invoke lstrcat,addr buf1,[ebx].pBaseFn
			.endif
		.endif
	.endif
	dec lvi.iItem
	jns @B
	; Write list of selected keywordfiles
	lea edi,buf1
	inc edi
	invoke lcase,addr buf1
	invoke WritePrivateProfileString,addr szRadHelp,addr szKwLists,edi,addr szCurrentIni
	
	; Re-open the cachefile in case things changed
	invoke CloseCache
	invoke OpenCache

	assume ebx:nothing

	ret

SaveChanges endp

SettingsProc proc uses esi edi ebx hWnd:dword,uMsg:dword,wParam:dword,lParam:dword
	
LOCAL buf1[MAX_PATH]:BYTE
LOCAL ofn:OPENFILENAME

	mov	eax,uMsg
	.if eax==WM_INITDIALOG
		mov bUnsaved,FALSE
		mov bIgnoreChange,TRUE
		invoke InitFileList,hWnd
		invoke InitIniList,hWnd
		invoke ChangeIniFile,hWnd
		mov bIgnoreChange,FALSE
	.elseif eax==WM_NOTIFY
		mov edi,lParam
		assume edi:ptr NMLISTVIEW
		.if [edi].hdr.idFrom==IDC_FILELIST
			.if [edi].hdr.code==LVN_ITEMCHANGED
				.if [edi].uChanged==LVIF_STATE
					mov eax,[edi].uNewState
					xor eax,[edi].uOldState ; Get changed bits
					.if eax & LVIS_SELECTED ; Selection changed
						.if [edi].uNewState & LVIS_SELECTED ; This item was selected
							mov ebx,(NMLISTVIEW ptr [edi]).lParam
							assume ebx:ptr KwlInfo
							invoke SendDlgItemMessage,hWnd,IDC_LISTFILE,WM_SETTEXT,0,[ebx].pCompleteFn
							invoke SendDlgItemMessage,hWnd,IDC_LISTNAME,WM_SETTEXT,0,[ebx].pName
							invoke SendDlgItemMessage,hWnd,IDC_LISTDESCR,WM_SETTEXT,0,[ebx].pDescr
							mov bIgnoreChange,TRUE
							invoke SendDlgItemMessage,hWnd,IDC_HELPFILE,WM_SETTEXT,0,[ebx].pFile
							mov bIgnoreChange,FALSE
							
							assume ebx:nothing
						.else ; This item was deselected, store the filename
							mov ebx,(NMLISTVIEW ptr [edi]).lParam
							assume ebx:ptr KwlInfo
							invoke SendDlgItemMessage,hWnd,IDC_HELPFILE,WM_GETTEXT,MAX_PATH,[ebx].pFile
							assume ebx:nothing
						.endif
					.elseif eax & LVIS_STATEIMAGEMASK ; Checkbox changed
						.if !bIgnoreChange
							mov bUnsaved,TRUE
							invoke GetDlgItem,hWnd,IDC_APPLY
							invoke EnableWindow,eax,bUnsaved
						.endif
					.endif
				.endif
			.endif
		.endif
		
		assume edi:nothing
		
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov 	edx,eax
		and		eax,0FFFFh
		shr 	edx,16
		.if eax==IDC_CANCEL
			invoke SendMessage,hWnd,WM_CLOSE,0,0
			
		.elseif eax==IDC_BROWSE
			.data
				szHelpfileFilter db "All useable files (*.hlp,*.chm,*.col,*.301,*.exe)",0,"*.hlp;*.chm;*.col;*.301;*.exe",0,"Old WinHelp files (*.hlp)",0,"*.hlp",0,"HtmlHelp files (*.chm, *.col)",0,"*.chm;*.col",0,"HtmlHelp 2 files (*.301)",0,"*.301",0,"Executable files (*.exe)",0,"*.exe",0,"All Files (*.*)",0,"*.*",0,0
				szOpenTitle db "Open helpfile",0
			.code
			lea edx,ofn
			mov ecx,sizeof ofn
		@@:	mov byte ptr [edx],0
			inc edx
			dec ecx
			jnz @B
			
			mov ofn.lStructSize,sizeof OPENFILENAME
			push hWnd
			pop ofn.hwndOwner
			push hInstance
			pop ofn.hInstance
			mov ofn.lpstrFilter,offset szHelpfileFilter
			lea edx,buf1
			mov byte ptr [edx],0
			mov ofn.lpstrFile,edx
			mov ofn.nMaxFile,sizeof buf1
			mov ofn.lpstrTitle,offset szOpenTitle
			mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_LONGNAMES
			
			invoke GetOpenFileName,addr ofn
			.if eax
				invoke SendDlgItemMessage,hWnd,IDC_HELPFILE,WM_SETTEXT,0,addr buf1
			.endif
			
		.elseif eax==IDC_OK
			.if bUnsaved
				invoke SaveChanges,hWnd
			.endif
			invoke EndDialog,hWnd,0
			
		.elseif eax==IDC_APPLY
			mov bUnsaved,FALSE
			invoke GetDlgItem,hWnd,IDC_APPLY
			invoke EnableWindow,eax,bUnsaved
			invoke SaveChanges,hWnd
			
		.elseif eax==IDC_HELPFILE
			.if edx==EN_CHANGE && !bIgnoreChange
				mov bUnsaved,TRUE
				invoke GetDlgItem,hWnd,IDC_APPLY
				invoke EnableWindow,eax,bUnsaved
			.endif
			
		.elseif eax==IDC_INILIST
			.if edx==CBN_SELCHANGE
				.if bUnsaved
					.data
						szUnsaved db "Do you want to save the changes to this ini file?",0
					.code
					invoke MessageBox,hWnd,addr szUnsaved,CTEXT("Save changes?"),MB_YESNO
					.if eax==IDYES
						invoke SaveChanges,hWnd
					.endif
				.endif
				
				invoke ChangeIniFile,hWnd
				.if !eax ; If there are no settings in the ini, ask if the user wants to load them from RadASM.ini
					.data
						szCopyIniData 	db "This ini file contains no RadHelp settings. Currently, the settings from",13,10
										db "RadASM.ini are used for this assembler.",13,10
										db 13,10
										db "To create a unique configuration for this assembler, the data from",13,10
										db "RadASM.ini can be loaded to this ini file. Alternatively, you may edit the",13,10
										db "default configuration in RadASM.ini directly.",13,10
										db 13,10
										db "Do you want to load the RadHelp settings from RadASM.ini so you can",13,10
										db "create an assembler-specific configuration?",0
					.code
					invoke MessageBox,hWnd,addr szCopyIniData,CTEXT("Create new assembler-specific config?"),MB_YESNOCANCEL
					.if eax==IDYES 
						mov eax,lpData
						invoke SettingsLoadIni,hWnd,(ADDINDATA ptr [eax]).lpIniFile
					.else
						invoke SendDlgItemMessage,hWnd,IDC_INILIST,CB_SETCURSEL,0,0
						invoke ChangeIniFile,hWnd
					.endif
				.endif
			.endif
			
		.elseif eax==IDC_REVERT
			.data
				szDeleteAsmConfig	db "Are you sure you want to immediately delete this assembler-specific configuration",13,10
									db "and use the configuration in RadASM.ini for this assembler?",0
			.code
			invoke MessageBox,hWnd,addr szDeleteAsmConfig,CTEXT("Delete assembler-specific config?"),MB_YESNOCANCEL
			.if eax==IDYES
				; Delete the RadHelp section from the ini
				invoke WritePrivateProfileString,addr szRadHelp,0,0,addr szCurrentIni
				invoke SendDlgItemMessage,hWnd,IDC_INILIST,CB_SETCURSEL,0,0
				invoke ChangeIniFile,hWnd
			.endif
			
		.endif
	.elseif eax==WM_CLOSE
		.if bUnsaved
			invoke MessageBox,hWnd,addr szUnsaved,CTEXT("Save changes?"),MB_YESNOCANCEL
			.if eax!=IDCANCEL
				.if eax==IDYES
					invoke SaveChanges,hWnd
				.endif
				invoke EndDialog,hWnd,0
			.endif
		.else
			invoke EndDialog,hWnd,0
		.endif
	.else
		mov eax,FALSE
		ret
	.endif
	mov eax,TRUE
	ret
	
SettingsProc endp