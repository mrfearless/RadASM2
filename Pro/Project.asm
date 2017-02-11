
Do_ProjectTool			PROTO
Do_TreeView				PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

GetProject				PROTO
ProjectDblClick			PROTO :DWORD,:DWORD
ProSetPos				PROTO :DWORD
GroupGetProjectFiles	PROTO
GroupUpdateTrv			PROTO :DWORD
GroupExpandAll			PROTO :DWORD,:DWORD
GroupFindItem			PROTO :HWND,:DWORD,:DWORD,:DWORD

.const

pbrtbrbtns			TBBUTTON <10,11,TBSTATE_ENABLED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
					TBBUTTON <34,13,TBSTATE_ENABLED	or TBSTATE_CHECKED or TBSTATE_HIDDEN,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
					TBBUTTON <0,0,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <36,12,TBSTATE_ENABLED or TBSTATE_HIDDEN,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
					TBBUTTON <10,18,TBSTATE_ENABLED or TBSTATE_HIDDEN,TBSTYLE_BUTTON,0,0>
					TBBUTTON <15,14,TBSTATE_ENABLED	or TBSTATE_CHECKED,TBSTYLE_BUTTON or TBSTYLE_CHECK,0,0>
					TBBUTTON <35,15,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <0,1,TBSTATE_ENABLED,TBSTYLE_SEP,0,0>
					TBBUTTON <37,16,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
					TBBUTTON <38,17,TBSTATE_ENABLED,TBSTYLE_BUTTON,0,0>
npbrtbrbtns			equ	10

.data

szDefGroup			db 'Added files,Assembly,Resources,Misc,Modules',0
iniEnv				db 'Environment',0

.data?

szGroupBuff			db 4096	dup(?)
szGroups			db 4096	dup(?)
OldTreeViewProc		dd ?
hRoot				dd ?
fNoGroups			dd ?

.code

GetFileNameFromID proc uses	esi,nInx:DWORD
	LOCAL	buffer[16]:BYTE

	mov		esi,hMemPro
	.if	esi
		invoke BinToDec,nInx,addr buffer
	  Nxt:
		.if	byte ptr [esi]
			lea		edx,buffer
			xor		ecx,ecx
			dec		ecx
		  @@:
			inc		ecx
			.if	byte ptr [esi+ecx]=='='	&& !byte ptr [edx+ecx]
				lea		eax,[esi+ecx+1]
				.if	!byte ptr [eax]
					xor		eax,eax
				.endif
				jmp		Ex
			.endif
			mov		al,[esi+ecx]
			cmp		al,[edx+ecx]
			je		@b
			.while byte	ptr	[esi]
				inc		esi
			.endw
			inc		esi
			jmp		Nxt
		.endif
	.endif
	xor		eax,eax
  Ex:
	ret

GetFileNameFromID endp

FileTrvAddNode proc	hPar:DWORD,lpPth:DWORD,nImg:DWORD
	LOCAL	tvins:TV_INSERTSTRUCT

	mov		eax,hPar
	mov		tvins.hParent,eax
	;Saveing hPar simplifies building path
	;when user selects an item
	mov		tvins.item.lParam,eax
	mov		tvins.hInsertAfter,0
	mov		tvins.item._mask,TVIF_TEXT or TVIF_PARAM or	TVIF_IMAGE or TVIF_SELECTEDIMAGE
	mov		eax,lpPth
	mov		tvins.item.pszText,eax
	mov		eax,nImg
	add		eax,IML_START
	mov		tvins.item.iImage,eax
	mov		tvins.item.iSelectedImage,eax
	invoke SendMessage,hFileTrv,TVM_INSERTITEM,0,addr tvins
	ret

FileTrvAddNode endp

FileTrvDir proc	lpPth:DWORD,lpSel:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hwfd:DWORD
	LOCAL	nInx:DWORD

	;Make the path local
	invoke strcpy,addr	buffer,lpPth
	;Check if path ends	with '\'. If not add.
	invoke strlen,addr	buffer
	dec		eax
	.if	byte ptr buffer[eax]!='\'
		invoke strcat,addr	buffer,addr	szBackSlash
	.endif
	;Add '*.*'
	invoke strcat,addr	buffer,addr	szAPA
	;Find first	match, if any
	invoke FindFirstFile,addr buffer,addr wfd
	.if	eax!=INVALID_HANDLE_VALUE
		;Save returned handle
		mov		hwfd,eax
	  Next:
		;Check if found	is a dir
		mov		eax,wfd.dwFileAttributes
		and		eax,FILE_ATTRIBUTE_DIRECTORY
		.if	eax
			;Do	not	include	'.'	and	'..'
			mov		ax,word ptr wfd.cFileName
			.if	ax!='.' && ax!='..' && lpSel==NULL
				mov		word ptr buffer,'D'
				invoke strcat,addr	buffer,addr	wfd.cFileName
				invoke SendMessage,hLBS,LB_ADDSTRING,0,addr	buffer
				mov		nInx,eax
				invoke SendMessage,hLBS,LB_SETITEMDATA,nInx,0
			.endif
		.else
			;Add file
			.if lpSel==NULL
				;Some file filtering could be done here
				mov		eax,fFileBrowser
				.if	eax
					push	esi
					lea		esi,wfd.cFileName
					invoke strlen,esi
					add		esi,eax
					.while eax
						dec		esi
					  .break .if byte ptr [esi]=='.'
						dec		eax
					.endw
					.if	eax
						invoke strcpy,addr	buffer,esi
						invoke strlen,esi
						mov		word ptr buffer[eax],'.'
						invoke iniInStr,offset FileFilter,addr buffer
						.if	eax!=-1
							mov		eax,FALSE
						.endif
					.else
						mov		eax,TRUE
					.endif
					pop		esi
				.endif
				.if	!eax
					mov		word ptr buffer,'F'
					invoke strcat,addr buffer,addr wfd.cFileName
					invoke SendMessage,hLBS,LB_ADDSTRING,0,addr	buffer
					mov		nInx,eax
					invoke GetFileImg,addr wfd.cFileName
					.if	eax>=30
						mov		eax,7
					.endif
					invoke SendMessage,hLBS,LB_SETITEMDATA,nInx,eax
				.endif
			.else
				mov		ecx,lpSel
				lea		edx,wfd.cFileName
				dec		ecx
				dec		edx
			  @@:
				inc		ecx
				inc		edx
				mov		al,[ecx]
				or		al,al
				je		@f
				mov		ah,[edx]
				.if al>='a' && al<='z'
					and		al,5Fh
				.endif
				.if ah>='a' && ah<='z'
					and		ah,5Fh
				.endif
				sub		al,ah
				je		@b
			  @@:
				.if !al
					invoke SendMessage,hLBS,LB_ADDSTRING,0,addr wfd.cFileName
				.endif
			.endif
		.endif
		;Any more matches?
		invoke FindNextFile,hwfd,addr wfd
		or		eax,eax
		jne		Next
		;No	more matches, close	handle
		invoke FindClose,hwfd
	.endif
	ret

FileTrvDir endp

FileDir	proc lpPath:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hPar:DWORD

	;Fill ListBox with dir info
	invoke SendMessage,hLBS,LB_RESETCONTENT,0,0
	invoke FileTrvDir,lpPath,NULL
	invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
	invoke SendMessage,hFileTrv,TVM_DELETEITEM,0,eax
	;Add root to TreeViev
	invoke FileTrvAddNode,0,lpPath,11;IMG_DRIVE
	;Save returned root	node
	mov		hPar,eax
	mov		nInx,0
	.while TRUE
		invoke SendMessage,hLBS,LB_GETTEXT,nInx,addr buffer
	  .break .if eax==LB_ERR
		invoke SendMessage,hLBS,LB_GETITEMDATA,nInx,0
		invoke FileTrvAddNode,hPar,addr	buffer[1],eax
		inc		nInx
	.endw
	invoke SendMessage,hLBS,LB_RESETCONTENT,0,0
	;Expand	the	root node
	invoke SendMessage,hFileTrv,TVM_EXPAND,TVE_EXPAND,hPar
	ret

FileDir	endp

FileGetPath	proc lpPath:DWORD
	LOCAL	tvi:TV_ITEMEX

	invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_ROOT,hFileTrv
	.if	eax
		mov		tvi.hItem,eax
		mov		tvi.imask,TVIF_TEXT
		mov		eax,lpPath
		mov		tvi.pszText,eax
		mov		tvi.cchTextMax,MAX_PATH
		invoke SendMessage,hFileTrv,TVM_GETITEM,0,addr tvi
		.if	eax
			invoke strcat,lpPath,offset szBackSlash
			mov		eax,tvi.hItem
		.endif
	.endif
	ret

FileGetPath	endp

FileGetName	proc
	LOCAL	tvi:TV_ITEMEX
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke FileGetPath,offset FileToCopy
	.if	eax
		invoke SendMessage,hFileTrv,TVM_GETNEXTITEM,TVGN_CARET,hFileTrv
		.if	eax
			mov		tvi.hItem,eax
			mov		tvi.imask,TVIF_TEXT
			lea		eax,buffer
			mov		tvi.pszText,eax
			mov		tvi.cchTextMax,sizeof buffer
			invoke SendMessage,hFileTrv,TVM_GETITEM,0,addr tvi
			.if	eax
				invoke strcpy,offset NameToCopy,addr buffer
				invoke strcat,offset FileToCopy,addr buffer
			.else
				mov		FileToCopy,0
			.endif
		.else
			mov		FileToCopy,0
		.endif
	.else
		mov		FileToCopy,0
	.endif
	ret

FileGetName	endp

SetTextLink	proc nType:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	chrg:CHARRANGE

	invoke BinToDec,8,addr buffer
	invoke GetPrivateProfileString,addr	iniMakeFile,addr buffer,addr szNULL,addr buffer,128,addr ProjectFile
	invoke strcpy,addr FileName,addr ProjectPath
	invoke strcat,addr FileName,addr buffer
	invoke GetFileAttributes,addr FileName
	.if	eax==-1
		invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if	eax!=INVALID_HANDLE_VALUE
			invoke CloseHandle,eax
			invoke AddProjectFile,addr FileName,TRUE,FALSE
		.else
			jmp		Ex
		.endif
	.endif
	invoke BinToDec,nType,addr buffer
	invoke GetPrivateProfileInt,addr szTLink,addr buffer,1,addr	ProjectFile
	mov		nInx,eax
	push	edi
	invoke strcpy,addr buffer1,addr szCmntChar
	invoke strcat,addr buffer1,addr szCross
	invoke strcat,addr buffer1,addr szSee
	invoke strcpy,addr buffer2,addr szCR
	invoke strcat,addr buffer2,addr szCross
	invoke strcat,addr buffer2,addr szSpc
	mov		edi,offset szBug
	.if	nType==2
		mov		edi,offset szNote
	.elseif	nType==3
		mov		edi,offset szToDo
	.endif
	push	edi
	invoke strcat,addr	buffer1,edi
	pop		edi
	invoke strcat,addr	buffer2,edi
	invoke BinToDec,nInx,addr buffer
	invoke strcat,addr	buffer1,addr buffer
	invoke strcat,addr	buffer1,addr szColon
	invoke strcat,addr	buffer1,addr szSpc
	invoke strcat,addr	buffer1,addr szCross
	invoke strcat,addr	buffer1,addr szCR
	invoke strcat,addr	buffer2,addr buffer
	invoke strcat,addr	buffer2,addr szColon
	invoke strcat,addr	buffer2,addr szSpc
	invoke strcat,addr	buffer2,addr szCross
	invoke strcat,addr	buffer2,addr szCR
	invoke SendMessage,hEdit,EM_EXGETSEL,0,addr	chrg
	invoke SendMessage,hEdit,EM_EXLINEFROMCHAR,0,chrg.cpMin
	invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
	mov		chrg.cpMin,eax
	mov		chrg.cpMax,eax
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr	chrg
	invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr buffer1
	invoke ProjectOpenFile,TRUE
	mov		chrg.cpMin,-1
	mov		chrg.cpMax,-1
	invoke SendMessage,hEdit,EM_EXSETSEL,0,addr	chrg
	invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,addr buffer2
	invoke BinToDec,nType,addr buffer
	inc		nInx
	invoke BinToDec,nInx,addr buffer1
	invoke WritePrivateProfileString,addr szTLink,addr buffer,addr buffer1,addr	ProjectFile
	pop		edi
  Ex:
	ret

SetTextLink	endp

UpdateMRU proc uses	ebx esi
	LOCAL	buffer[256]:BYTE

	mov		ebx,offset tempbuff[1024]
	.if	byte ptr ProjectFile
		mov		dword ptr [ebx],' 1&'
		invoke strcat,ebx,addr ProjectDescr
		invoke strlen,ebx
		.if	eax>26
			mov		eax,23
			mov		dword ptr [ebx+eax],'...'
		.endif
		mov		dword ptr buffer,',P,'
		invoke strcat,ebx,addr buffer
		invoke strcat,ebx,addr ProjectFile
		invoke strlen,ebx
		lea		ebx,[ebx+eax+1]
	.endif
	mov		dword ptr [ebx],0
	mov		esi,1
	.while esi<10
		invoke BinToDec,esi,addr buffer
		invoke GetPrivateProfileString,addr	iniMRUPro,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr iniFile
		invoke strcpy,addr tempbuff,addr buffer
		invoke iniGetItem,addr buffer,addr iniBuffer
		invoke iniGetItem,addr buffer,addr iniBuffer
		movzx	eax,buffer
		.if	eax
			invoke GetFileAttributes,addr buffer
			.if	eax!=-1
				invoke lstrcmpi,addr buffer,addr ProjectFile
				.if	!eax
					dec		eax
				.else
					xor		eax,eax
				.endif
			.endif
		.else
			dec		eax
		.endif
		.if	eax!=-1
			invoke strcpy,ebx,offset tempbuff
			invoke strlen,ebx
			lea		ebx,[ebx+eax+1]
			mov		dword ptr [ebx],0
		.endif
		inc		esi
	.endw
	mov		ebx,offset tempbuff[1024]
	mov		esi,1
	.while esi<10
		invoke BinToDec,esi,addr buffer
		.if	byte ptr [ebx]
			mov		al,buffer
			mov		[ebx+1],al
			invoke WritePrivateProfileString,addr iniMRUPro,addr buffer,ebx,addr iniFile
			invoke strlen,ebx
			lea		ebx,[ebx+eax+1]
		.else
			invoke WritePrivateProfileString,addr iniMRUPro,addr buffer,addr szNULL,addr iniFile
		.endif
		inc		esi
	.endw
	ret

UpdateMRU endp

OpenProject	proc fFile:DWORD
	LOCAL	buffer[256]:BYTE

	mov		eax,fFile
	.if	!eax
		invoke RtlZeroMemory,addr ofn,sizeof ofn
		mov		ofn.lStructSize,sizeof ofn
		push	hWnd
		pop		ofn.hwndOwner
		push	hInstance
		pop		ofn.hInstance
		mov		ofn.lpstrFilter,offset PROFilterString
		mov		ofn.lpstrFile,offset FileName
		mov		byte ptr [FileName],0
		mov		ofn.nMaxFile,sizeof	FileName
		mov		ofn.lpstrDefExt,offset DefProExt
		mov		ofn.lpstrInitialDir,offset Pro
		mov		ofn.Flags,OFN_FILEMUSTEXIST	or OFN_HIDEREADONLY	or OFN_PATHMUSTEXIST
		invoke GetOpenFileName,addr	ofn
	.endif
	.if	eax
		invoke UpdateWindow,hWnd
		invoke strcpy,addr buffer,addr FileName
		invoke CloseProject
		.if	!eax
			invoke UpdateWindow,hWnd
			invoke strcpy,addr FileName,addr buffer
			invoke GetProject
		.else
			.if	hEdit
				invoke SetFocus,hEdit
			.endif
		.endif
	.else
		.if	hEdit
			invoke SetFocus,hEdit
		.endif
	.endif
	ret

OpenProject	endp

SetMakeMenu	proc uses edi
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer2[64]:BYTE

	.if	fProject
		invoke GetPrivateProfileString,addr	iniMakeDef,addr	iniMakeDefMenu,addr	szNULL,addr	buffer,sizeof buffer,addr ProjectFile
		mov		edi,offset MenuData
	  @@:
		push	edi
		mov		al,(MENU ptr [edi]).param
		.if	al=='M'
			push	eax
			invoke iniGetItem,addr buffer,addr buffer2
			mov		al,buffer2[0]
			.if	al=='1'
				invoke EnableMenuItem,hMenu,(MENU ptr [edi]).mnuid,MF_BYCOMMAND	or MF_ENABLED
				invoke SendMessage,hToolBar,TB_ENABLEBUTTON,(MENU ptr [edi]).mnuid,TRUE
			.else
				invoke EnableMenuItem,hMenu,(MENU ptr [edi]).mnuid,MF_BYCOMMAND	or MF_GRAYED
				invoke SendMessage,hToolBar,TB_ENABLEBUTTON,(MENU ptr [edi]).mnuid,FALSE
			.endif
			pop		eax
		.endif
		pop		edi
		add		edi,size MENU
		or		al,al
		jne		@b
	.endif
	ret

SetMakeMenu	endp

ResetEnvironment	proc uses esi edi

	mov		edi,hEnv
	.if	edi
		.while byte	ptr	[edi]
			mov		esi,edi
			invoke strlen,esi
			inc		eax
			add		esi,eax
			invoke SetEnvironmentVariable,edi,esi
			invoke strlen,esi
			inc		eax
			add		esi,eax
			mov		edi,esi
		.endw
		invoke GlobalUnlock,hEnv
		invoke GlobalFree,hEnv
		xor		eax,eax
		mov		hEnv,eax
	.endif
	ret

ResetEnvironment	endp

SetEnvironment proc uses	edi
	LOCAL	lpEnv:DWORD
	LOCAL	buffer[64]:BYTE

	;Environment
	invoke ResetEnvironment
	invoke GetEnvironmentStrings
	mov		lpEnv,eax
	xor		edx,edx
	.while eax
		inc		edx
		push	edx
		invoke BinToDec,edx,addr buffer
		invoke GetPrivateProfileString,addr	iniEnv,addr	buffer,addr	szNULL,addr	iniBuffer,sizeof iniBuffer,addr	iniAsmFile
		.if	eax
			invoke iniGetItem,addr iniBuffer,addr buffer
			invoke strlen,addr iniBuffer
			.if	eax
				dec		eax
			.endif
			mov		byte ptr prnbuff[2048],0
			.if	byte ptr iniBuffer[eax]==';'
				invoke GetEnvironmentVariable,addr buffer,addr prnbuff[2048],1024
				invoke iniInStr,addr prnbuff[2048],addr	iniBuffer
				inc		eax
				.if	!eax
					invoke strcpy,addr	prnbuff,addr iniBuffer
					.if	byte ptr prnbuff[2048]
						invoke strcat,addr	prnbuff,addr prnbuff[2048]
					.else
						invoke strlen,addr	prnbuff
						dec		eax
						mov		byte ptr prnbuff[eax],0
					.endif
					invoke SetEnvironmentVariable,addr buffer,addr prnbuff
				.endif
			.else
				invoke SetEnvironmentVariable,addr buffer,addr iniBuffer
			.endif
			.if	!hEnv
				invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,16384
				mov		hEnv,eax
				mov		edi,eax
			.endif
			invoke strcpy,edi,addr	buffer
			invoke strlen,edi
			inc		eax
			add		edi,eax
			invoke strcpy,edi,addr	prnbuff[2048]
			invoke strlen,edi
			inc		eax
			add		edi,eax
			xor		eax,eax
			inc		eax
		.endif
		pop		edx
	.endw
	invoke FreeEnvironmentStrings,lpEnv
	ret

SetEnvironment endp

SetAssembler proc uses esi edi,lpAssembler:DWORD
	LOCAL	fErr:DWORD
	LOCAL	buffer[64]:BYTE

	invoke SendMessage,hClient,WM_MDIGETACTIVE,0,addr fMaximized
	.if hParseDll
		invoke FreeLibrary,hParseDll
		mov		hParseDll,0
	.endif
	mov		edx,lpAssembler
	.if	!byte ptr [edx]
		mov		eax,'msam'
		mov		dword ptr [edx],eax
		mov		byte ptr [edx+4],0
	.endif
	xor		eax,eax
	mov		dword ptr szAssembler,eax
	invoke strcpy,addr szAssembler,lpAssembler
	mov		eax,dword ptr szAssembler
	and		eax,5F5F5F5Fh
	.if eax=='MSAM'
		mov		eax,nMASM
	.elseif eax=='MSAT'
		mov		eax,nTASM
	.elseif eax=='MSAF'
		mov		eax,nFASM
	.elseif eax=='SAOG'
		mov		eax,nGOASM
	.elseif eax=='MSAN'
		mov		eax,nNASM
	.elseif eax=='ALH'
		mov		eax,nHLA
	.elseif eax=='PPC'
		mov		eax,nCPP
	.elseif eax=='TECB'
		mov		eax,nBCET
	.elseif eax=='PF'
		mov		eax,nFP
	.else
		mov		eax,nOTHER
	.endif
	mov		nAsm,eax
	invoke iniReadPaths,lpAssembler
	invoke strcpy,addr szIniApi,addr iniApi
	.if fProject
		invoke GetPrivateProfileString,addr	ProjectType,addr iniApi,addr iniApi,addr szIniApi,128,addr iniAsmFile
	.endif
	invoke GetPrivateProfileInt,addr szIniCode,addr ininAsm,0,addr iniAsmFile
	.if eax
		mov		nAsm,eax
	.endif
	invoke GetPrivateProfileString,addr	iniProjectGroup,addr iniProjectGroup,addr szDefGroup,addr szGroups,sizeof szGroups,addr iniAsmFile
	invoke GetPrivateProfileString,addr	szIniCode,addr iniParseDll,addr szNULL,addr buffer,sizeof buffer,addr iniAsmFile
	.if eax
		invoke strcpy,offset tempbuff,offset AddIn
		invoke strcat,offset tempbuff,offset szBackSlash
		invoke strcat,offset tempbuff,addr buffer
		invoke LoadLibrary,offset tempbuff
		.if eax
			mov		hParseDll,eax
			invoke GetProcAddress,eax,offset szInstallDll
			.if eax
				push	0
				push	hWnd
				call	eax
			.endif
		.endif
	.endif
	invoke iniSetCodeBlocks
	invoke SetEnvironment
	invoke iniAddMenu
	invoke iniDisMenu
	invoke iniSetF1Help
	invoke InitMac
	invoke ApplyFonts,FALSE
	mov		esi,offset tempbuff[512]
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniSkip,addr szNULL,addr szCPSkip,sizeof szCPSkip,addr iniAsmFile
	mov		edi,offset szCPSkip
	call	TestCode
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniCode,addr szNULL,addr szCPCode,sizeof szCPCode,addr iniAsmFile
	mov		edi,offset szCPCode
	call	TestCode
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniCode2,addr szNULL,addr szCPCode2,sizeof szCPCode2,addr iniAsmFile
	mov		edi,offset szCPCode2
	call	TestCode
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniLabel,addr szNULL,addr szCPLabel,sizeof szCPLabel,addr iniAsmFile
	mov		edi,offset szCPLocal
	call	TestCode
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniLocal,addr szNULL,addr szCPLocal,sizeof szCPLocal,addr iniAsmFile
	mov		edi,offset szCPLocal
	call	TestCode
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniConst,addr szNULL,addr szCPConst,sizeof	szCPConst,addr iniAsmFile
	mov		edi,offset szCPConst
	call	TestCode
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniData,addr szNULL,addr szCPData,sizeof szCPData,addr iniAsmFile
	mov		edi,offset szCPData
	call	TestCode
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniMacro,addr szNULL,addr szCPMacro,sizeof	szCPMacro,addr iniAsmFile
	mov		edi,offset szCPMacro
	call	TestCode
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniStruct,addr	szNULL,addr	szCPStruct,sizeof szCPStruct,addr iniAsmFile
	mov		edi,offset szCPStruct
	call	TestCode
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniStruct2,addr szNULL,addr szCPStruct2,sizeof szCPStruct2,addr iniAsmFile
	mov		edi,offset szCPCode2
	call	TestCode
	invoke strcpy,addr PrpCboItems,addr DefPrpCboItems
	invoke GetPrivateProfileString,addr	szIniCode,addr szIniOther,addr	szNULL,addr	prnbuff,256,addr iniAsmFile
	invoke strcat,addr PrpCboItems,addr szComma
	invoke strcat,addr PrpCboItems,addr prnbuff
	mov		edi,offset szCP0
	.while edi<offset szCP0+256*4
		invoke iniGetItem,addr prnbuff,addr buffer
		.break .if !buffer
		invoke GetPrivateProfileString,addr	szIniCode,addr buffer,addr szNULL,edi,256,addr iniAsmFile
		invoke iniGetItem,addr prnbuff,addr buffer
		add		edi,256
	.endw
	invoke GetCodeDefs
	invoke iniGetCharTab
	invoke ClearWordList
	invoke ApiCallLoad
	invoke ApiConstLoad
	invoke ApiWordLoad
	invoke ApiMessageLoad
	mov		eax,rpWordListPos
	mov		rpStructList,eax
	invoke ApiStructLoad
	invoke ApiTypeLoad
	invoke ApiArrayLoad
	mov		eax,rpWordListPos
	mov		rpProjectWordList,eax
	;Load the words	to be hilited
	invoke FillHiliteInfo
	invoke SetBlockDef
	invoke UpdateEditColors
	invoke SetPropertyCbo,0
	ret

TestCode:
	mov		fErr,0
	invoke strcpy,offset tempbuff,edi
	invoke iniGetItem,offset tempbuff,esi
	.if	word ptr [esi]=='$-' ||	word ptr [esi]=='-$' ||	(!byte ptr [esi] &&	tempbuff) || (byte ptr [esi] &&	!tempbuff)
		invoke TextToOutput,offset szErrorIn
		invoke TextToOutput,offset iniAsmFile
		invoke TextToOutput,offset szIniCode
		invoke TextToOutput,edi
		mov		byte ptr [edi],0
	.endif
	retn

SetAssembler endp

DeleteProject proc
	LOCAL	sfo:SHFILEOPSTRUCT
	LOCAL	buffer[MAX_PATH]:BYTE

	invoke strcpy,addr	buffer,addr	ProjectPath
	invoke strlen,addr	buffer
	mov		byte ptr buffer[eax-1],0
	invoke CloseProject
	mov		eax,hWnd
	mov		sfo.hwnd,eax
	mov		sfo.wFunc,FO_DELETE
	lea		eax,buffer
	mov		sfo.pFrom,eax
	mov		sfo.pTo,NULL
	mov		sfo.fFlags,FOF_NOERRORUI or	FOF_SILENT or FOF_ALLOWUNDO
	mov		sfo.fAnyOperationsAborted,0
	lea		eax,szDeleteProject
	mov		sfo.lpszProgressTitle,eax
	mov		sfo.hNameMappings,NULL
	invoke SHFileOperation,ADDR	sfo
	.if	!sfo.fAnyOperationsAborted
		invoke UpdateMRU
		invoke iniAddMenu
		invoke iniDisMenu
	.endif
	ret

DeleteProject endp

TestSection proc uses esi edi,lpSection:DWORD,lpdwMax:DWORD
	LOCAL	hMem:HGLOBAL

	mov		edi,lpdwMax
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,32*1024
	mov		hMem,eax
	invoke GetPrivateProfileSection,lpSection,hMem,32*1024-1,addr ProjectFile
	mov		esi,hMem
	.while byte ptr [esi]
		invoke strlen,esi
		.if eax>[edi]
			mov		[edi],eax
		.endif
		lea		esi,[esi+eax+1]
	.endw
	invoke GlobalFree,hMem
	ret

TestSection endp

GetProject proc	uses edi
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[16]:BYTE
	LOCAL	nMax:DWORD

	xor		eax,eax
	mov		fResChanged,eax
	mov		fResProject,eax
	mov		nMax,eax
	invoke strcpy,addr ProjectFile,addr FileName 
	invoke GetFileAttributes,addr ProjectFile
	mov		edx,offset OpenFileFail
	.if	eax!=-1
		; Test project file
		invoke TestSection,addr iniProject,addr nMax
		invoke TestSection,addr iniMakeFile,addr nMax
		invoke TestSection,addr iniProjectFiles,addr nMax
		invoke TestSection,addr iniProjectSize,addr nMax
		.if nMax>127
			mov		edx,offset ProjectFileFail
			jmp		Err
		.endif
		invoke TestSection,addr iniMakeDef,addr nMax
		invoke TestSection,addr iniWinFind,addr nMax
		.if nMax>255
			mov		edx,offset ProjectFileFail
			jmp		Err
		.endif
		mov		fProExp,1
		invoke DllProc,hWnd,AIM_PROJECTOPEN,0,addr ProjectFile,RAM_PROJECTOPEN
		.if eax
			ret
		.endif
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		invoke SHAddToRecentDocs,SHARD_PATH,addr FileName
		invoke strlen,addr FileName
		mov		ecx,eax
		dec		ecx
		mov		edi,offset FileName
		add		edi,ecx
	  @@:
		cmp		byte ptr [edi],"\"
		je		@f
		dec		edi
		loop	@b
	  @@:
		inc		edi
		mov		byte ptr [edi],0
		invoke strcpy,addr ProjectPath,addr FileName
		dec		edi
		mov		byte ptr [edi],0
		invoke strcpy,addr CurPro,addr FileName
		invoke GetPrivateProfileString,addr	iniProject,addr	iniAssembler,addr szNULL,addr buffer,sizeof	buffer,addr	ProjectFile
		invoke GetPrivateProfileString,addr	iniProject,addr	iniProjectBackup,addr szNULL,addr BackupPath,255,addr ProjectFile
		invoke iniFixPath,addr BackupPath,addr ProjectPath,addr	iniFolderP
		invoke GetPrivateProfileString,addr	iniProject,addr	iniProjectType,addr	szNULL,addr	ProjectType,64,addr	ProjectFile
		invoke GetPrivateProfileString,addr	iniProject,addr	iniProjectDescription,addr szNULL,addr ProjectDescr,128,addr ProjectFile
		invoke UpdateMRU
		mov		fProject,TRUE
		invoke SetAssembler,addr buffer
		invoke GetPrivateProfileInt,addr iniProject,addr iniProjectGroup,1,addr	ProjectFile
		and		eax,1
		mov		fGroup,eax
		invoke SendMessage,hPbrTbr,TB_CHECKBUTTON,12,eax
		invoke GetPrivateProfileInt,addr iniProject,addr iniProjectGroupExpand,1,addr ProjectFile
		and		eax,1
		mov		fGroupExpand,eax
		invoke LoadBookMarks
		invoke GetProjectFiles,TRUE
		.if !eax
			invoke strlen,addr buffer
			lea		eax,[buffer+eax]
			mov		dword ptr [eax],' - '
			invoke GetPrivateProfileInt,addr iniProject,addr iniDebug,0,addr ProjectFile
			mov		fDebug,eax
			.if	eax
				invoke strcat,addr buffer,addr iniDebug
			.else
				invoke strcat,addr buffer,addr iniRelease
			.endif
			invoke SendMessage,hStatus,SB_SETTEXT,2,addr buffer
			invoke strcpy,addr buffer,addr DisplayName
			invoke strlen,addr buffer
			push	edi
			lea		edi,buffer
			add		edi,eax
			mov		eax,00202D20h
			mov		[edi],eax
			pop		edi
			invoke strcat,addr buffer,addr ProjectDescr
			invoke SetWindowText,hWnd,addr buffer
			mov		fProject,TRUE
			invoke SetPath,addr ProjectPath
			invoke SetMakeMenu
			invoke RefreshProperty
			mov		fProperty,4
			invoke SetProperty,0,0
			invoke GroupCollapseAll,hPbrTrv,hRoot
			.if	hMdiCld
				invoke ProSetTrv,hMdiCld
			.else
				invoke SendMessage,hPbrTrv,TVM_SELECTITEM,TVGN_CARET,hRoot
			.endif
	
			invoke GetPrivateProfileString,addr iniGroupExpand,addr iniGroupExpand,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
			xor		edi,edi
		  @@:
			invoke iniGetItem,addr buffer,addr buffer1
			.if buffer1
				invoke DecToBin,addr buffer1
				mov		groupstate[edi*4],eax
				lea		edi,[edi+1]
				jmp		@b
			.endif
			xor		edi,edi
			invoke SetGroupState,hPbrTrv,hRoot
			invoke EnableProjectBrowser,TRUE
			invoke DllProc,hWnd,AIM_PROJECTOPENED,0,addr ProjectFile,RAM_PROJECTOPENED
			invoke LoadCursor,0,IDC_ARROW
			invoke SetCursor,eax
			mov		eax,FALSE
		.else
			mov		eax,TRUE
		.endif
	.else
Err:
		invoke strcpy,addr LineTxt,edx
		invoke strcat,addr LineTxt,addr ProjectFile
		invoke MessageBox,hWnd,addr	LineTxt,addr AppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

GetProject endp

GetFileImg proc	uses esi,lpFileNme:DWORD
	LOCAL ftp:DWORD

	mov		ftp,7
	mov		esi,offset DefSrcExt-1
	call	TestFile
	.if	eax!=-1
		mov		ftp,3
	.else
		mov		esi,offset DefHdrExt-1
		call	TestFile
		.if	eax!=-1
			mov		ftp,2
		.else
			invoke iniInStr,lpFileNme,addr FTDlg
			.if	eax!=-1
				mov		ftp,5
			.else
				invoke iniInStr,lpFileNme,addr FTMnu
				.if	eax!=-1
					mov		ftp,6
				.else
					invoke iniInStr,lpFileNme,addr FTRc
					.if	eax!=-1
						mov		ftp,4
					.else
						invoke iniInStr,lpFileNme,addr FTTxt
						.if	eax!=-1
							mov		ftp,8
						.else
							invoke iniInStr,lpFileNme,addr FTObj
							.if	eax!=-1
								mov		ftp,9
							.else
								invoke iniInStr,lpFileNme,addr FTRap
								.if	eax!=-1
									mov		ftp,32
								.else
									invoke iniInStr,lpFileNme,addr FTBmp
									.if	eax!=-1
										mov		ftp,30
									.else
										invoke iniInStr,lpFileNme,addr FTIco
										.if	eax!=-1
											mov		ftp,31
										.else
											invoke iniInStr,lpFileNme,addr FTExe
											.if	eax!=-1
												mov		ftp,33
											.else
												invoke iniInStr,lpFileNme,addr FTBat
												.if	eax!=-1
													mov		ftp,34
												.else
													invoke iniInStr,lpFileNme,addr FTDll
													.if	eax!=-1
														mov		ftp,35
													.else
														invoke iniInStr,lpFileNme,addr FTRes
														.if	eax!=-1
															mov		ftp,36
														.endif
													.endif
												.endif
											.endif
										.endif
									.endif
								.endif
							.endif
						.endif
					.endif
				.endif
			.endif
		.endif
	.endif
	mov		eax,ftp
	ret

TestFile:
	invoke iniInStr,lpFileNme,esi
	.if	eax==-1
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		.if byte ptr [esi]
			jmp		TestFile
		.endif
		mov		eax,-1
	.endif
	retn

GetFileImg endp

ProGetGroup	proc iNbr:DWORD,ftp:DWORD
	LOCAL	buffer[8]:BYTE
	LOCAL	buffer1[8]:BYTE

	invoke BinToDec,iNbr,addr buffer
	invoke GetPrivateProfileInt,addr iniProjectGroup,addr buffer,0,addr	ProjectFile
	.if	!eax
		.if	fNoGroups
			mov		eax,ftp
			.if	eax==3 || eax==2
				;Asm
				mov		eax,2
			.elseif	eax==4 || eax==5 ||	eax==6
				;Res
				mov		eax,3
			.elseif	eax==1 || eax==10
				;Mod
				mov		eax,5
			.else
				;Mis
				mov		eax,4
			.endif
		.else
			mov		eax,1
		.endif
		push	eax
		mov		edx,eax
		invoke BinToDec,edx,addr buffer1
		invoke WritePrivateProfileString,addr iniProjectGroup,addr buffer,addr buffer1,addr	ProjectFile
		pop		eax
	.endif
	ret

ProGetGroup	endp

ResFileExist proc
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[4]:BYTE

	invoke strcpy,addr buffer,offset ProjectPath
	invoke strlen,addr buffer
	mov		edx,eax
	mov		word ptr buffer1,'4'
	invoke GetPrivateProfileString,offset iniMakeFile,addr buffer1,offset szNULL,addr buffer[edx],128,offset ProjectFile
	invoke GetFileAttributes,addr buffer
	.if	eax==-1
		xor		eax,eax
	.endif
	ret

ResFileExist endp

GetProjectFiles	proc uses esi edi,fAutoOpen:DWORD
	LOCAL	buffer1[16]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	buffer4[256]:BYTE
	LOCAL	iNbr:DWORD
	LOCAL	tci:TC_ITEM

	invoke GetFileAttributes,addr ProjectFile
	.if	eax!=-1
		invoke SendMessage,hPbrTrv,WM_SETREDRAW,FALSE,NULL
		mov		esi,offset szGroupBuff
		invoke RtlZeroMemory,esi,sizeof	szGroupBuff
		mov		edi,offset groupgrp
		invoke RtlZeroMemory,edi,sizeof	groupgrp
		invoke GetPrivateProfileString,addr	iniProjectGroup,addr iniProjectGroup,addr szNULL,addr prnbuff,sizeof szGroups,addr ProjectFile
		.if	!eax
			mov		fNoGroups,TRUE
			invoke WritePrivateProfileString,addr iniProjectGroup,addr iniProjectGroup,addr	szGroups,addr ProjectFile
			invoke strcpy,offset prnbuff,offset szGroups
		.endif
		mov		iNbr,0
		.while byte	ptr	prnbuff && iNbr<64
			invoke iniGetItem,offset prnbuff,esi
			mov		[edi].PROGROUP.lpszGrp,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			lea		edi,[edi+sizeof	PROGROUP]
			inc		iNbr
		.endw
		mov		word ptr buffer1,'1'
		invoke GetPrivateProfileString,addr	iniMakeFile,addr buffer1,addr szNULL,addr buffer4,128,addr ProjectFile
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,32*1024
		mov		hMemPro,eax
		invoke GetPrivateProfileSection,addr iniProjectFiles,hMemPro,32*1024-1,addr	ProjectFile
		mov		esi,hMemPro
		invoke GetPrivateProfileSection,addr iniAutoLoad,offset tempbuff,sizeof tempbuff,addr ProjectFile
		invoke iniInStr,offset tempbuff,addr iniAutoLoad
		.if eax==-1
			mov		iNbr,0
			mov		tempbuff,0
			.while iNbr<2048
				invoke BinToDec,iNbr,addr buffer1
				invoke GetPrivateProfileInt,addr iniAutoLoad,addr buffer1,0,addr ProjectFile
				.if eax
					invoke iniPutItem,iNbr,offset tempbuff,TRUE
				.endif
				inc		iNbr
			.endw
			invoke WritePrivateProfileSection,addr iniAutoLoad,offset szNULL,addr ProjectFile
			invoke strlen,offset tempbuff
			mov		tempbuff[eax-1],0
			invoke WritePrivateProfileString,addr iniAutoLoad,addr iniAutoLoad,offset tempbuff,addr ProjectFile
		.endif
	  Nxt:
		.if	 byte ptr [esi]
			invoke DecToBin,esi
			.while byte	ptr	[esi] && byte ptr [esi]!='='
				inc		esi
			.endw
			inc		esi
			.if	byte ptr [esi] && eax
				mov		iNbr,eax
				invoke BinToDec,iNbr,addr buffer1
				invoke lstrcpyn,addr buffer2,esi,128
				;See if	it is main RC file
				invoke lstrcmpi,addr buffer2,addr buffer4
				.if	!eax
					mov		fResProject,TRUE
				.endif
			.endif
			invoke strlen,esi
			add		esi,eax
			inc		esi
			jmp		Nxt
		.endif
		.if fGroup
			mov		edi,offset szGroupGroupBuff
			mov		esi,offset szGroupBuff
			mov		ecx,sizeof szGroupGroupBuff
			rep		movsb
		.else
			mov		szGroupGroupBuff,0
		.endif
		invoke GroupGetProjectFiles
		invoke GroupUpdateTrv,hPbrTrv
		.if fGroupExpand
			invoke GroupExpandAll,hPbrTrv,0
			mov		fExpand,1
		.else
			mov		fExpand,0
			invoke GroupCollapseAll,hPbrTrv,0
		.endif
		invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
		mov		hRoot,eax
		invoke SendMessage,hPbrTrv,WM_SETREDRAW,TRUE,NULL
		.if	fAutoOpen
			invoke GetPrivateProfileString,addr iniAutoLoad,addr iniAutoLoad,offset szNULL,offset tempbuff,sizeof tempbuff,addr ProjectFile
			.while byte ptr tempbuff
				invoke iniGetItem,offset tempbuff,addr buffer4
				invoke DecToBin,addr buffer4
				invoke GetFileNameFromID,eax
				.if eax
					push	eax
					invoke strcpy,addr FileName,addr ProjectPath
					pop		eax
					invoke strcat,addr FileName,eax
					invoke ProjectOpenFile,TRUE
				.endif
			.endw
			.if	hMdiCld
				invoke SendMessage,hTab,TCM_SETCURSEL,0,0
				mov		tci.imask,TCIF_PARAM
				invoke SendMessage,hTab,TCM_GETITEM,0,addr tci
				invoke TabToolSel,tci.lParam
				invoke SendMessage,hPbrTrv,TVM_SELECTITEM,TVGN_CARET,hRoot
				invoke ProSetTrv,hMdiCld
			.endif
		.endif
		mov		fNoGroups,FALSE
		invoke SendMessage,hPbrTbr,TB_CHECKBUTTON,12,fGroup
		xor		eax,eax
		ret
	.else
		invoke strcpy,addr LineTxt,addr OpenFileFail
		invoke strcat,addr LineTxt,addr ProjectFile
		invoke MessageBox,hWnd,addr	LineTxt,addr AppName,MB_OK or MB_ICONERROR
	.endif
	mov		eax,TRUE
	ret

GetProjectFiles	 endp

CloseProject proc uses esi edi
	LOCAL	tci:TC_ITEM
	LOCAL	nInx:DWORD

	.if	fProject
		invoke DllProc,hWnd,AIM_PROJECTCLOSE,0,0,RAM_PROJECTCLOSE
		.if	eax
			ret
		.endif
		invoke RtlZeroMemory,offset hNoSave,sizeof hNoSave
		mov		fCancelSave,0
		invoke UpdateAll,QUERY_SAVE
		mov		eax,fCancelSave
		.if eax
			ret
		.endif
		mov		nInx,0
		mov		tempbuff,0
		mov		tci.imask,TCIF_PARAM
		.while TRUE
			invoke SendMessage,hTab,TCM_GETITEM,nInx,addr tci
			.break .if !eax
			invoke GetWindowLong,tci.lParam,16
			.if eax
				invoke iniPutItem,eax,offset tempbuff,TRUE
			.endif
			inc		nInx
		.endw
		invoke strlen,offset tempbuff
		mov		tempbuff[eax-1],0
		invoke ClearErrorBookMarks
		mov		esi,offset hNoSave
		.while dword ptr [esi]
			invoke GetWindowLong,[esi],0
			.if eax==ID_EDIT || eax==ID_EDITTXT || eax==ID_EDITHEX
				invoke GetWindowLong,[esi],GWL_USERDATA
				invoke SendMessage,eax,EM_SETMODIFY,0,0
			.elseif eax==ID_DIALOG
				invoke GetWindowLong,[esi],4
				mov		(DLGHEAD ptr [eax]).changed,0
			.endif
			lea		esi,[esi+4]
		.endw
		invoke SendMessage,hWnd,WM_COMMAND,IDM_FILE_SAVEALLFILES,0
		invoke SendMessage,hWnd,WM_COMMAND,IDM_WINDOW_CLOSEALL,0
		.if	hMdiCld==0
			invoke WritePrivateProfileString,addr iniAutoLoad,addr iniAutoLoad,offset tempbuff,addr ProjectFile
			xor		edi,edi
			invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
			invoke GetGroupState,hPbrTrv,eax
			xor		esi,esi
			mov		tempbuff,0
			.while esi<edi
				mov		eax,groupstate[esi*4]
				.if eax
					mov		eax,1
				.endif
				invoke iniPutItem,eax,offset tempbuff,TRUE
				inc		esi
			.endw
			invoke iniPutItem,0,offset tempbuff,FALSE
			invoke WritePrivateProfileString,addr iniGroupExpand,addr iniGroupExpand,offset tempbuff,addr ProjectFile
			invoke SetWindowText,hWnd,addr DisplayName
			invoke SendMessage,hPbrTrv,TVM_DELETEITEM,0,hRoot
			invoke UpdateWindow,hPbrTrv
			invoke SendMessage,hPrpCboCode,CB_RESETCONTENT,0,0
			invoke SendMessage,hPrpLstCode,LB_RESETCONTENT,0,0
			invoke UpdateWindow,hPrpLstCode
			invoke SaveBookMarks
			invoke UpdateMRU
			mov		fProject,FALSE
			mov		ProjectFile,0
			mov		CurPro,0
			mov		fDebug,FALSE
			invoke GetPrivateProfileString,addr	iniAssembler,addr iniAssembler,addr	szNULL,addr	iniBuffer,128,addr iniFile
			invoke iniGetItem,addr iniBuffer,addr tempbuff
			invoke SetAssembler,addr tempbuff
			invoke SendMessage,hStatus,SB_SETTEXT,2,addr szAssembler
			invoke PropSetOwner,TRUE
			mov		fProperty,1
			invoke SendMessage,hPrpTbrCode,TB_CHECKBUTTON,1,TRUE
			invoke SetPath,addr	Pro
			.if	hMemPro
				invoke GlobalFree,hMemPro
				mov		hMemPro,0
			.endif
			xor		eax,eax
			mov		fResChanged,eax
			mov		fResProject,eax
			invoke DllProc,hWnd,AIM_PROJECTCLOSED,0,0,RAM_PROJECTCLOSED
			xor		eax,eax
			mov		TplFileName,al
			ret
		.endif
	.else
		mov		fDebug,FALSE
		invoke GetPrivateProfileString,addr	iniAssembler,addr iniAssembler,addr	szNULL,addr	iniBuffer,128,addr iniFile
		invoke iniGetItem,addr iniBuffer,addr tempbuff
		invoke SetAssembler,addr tempbuff
		invoke SendMessage,hStatus,SB_SETTEXT,2,addr szAssembler
		invoke PropSetOwner,TRUE
		mov		fProperty,1
		invoke SendMessage,hPrpTbrCode,TB_CHECKBUTTON,1,TRUE
		invoke SendMessage,hPrpCboCode,CB_RESETCONTENT,0,0
		invoke SendMessage,hPrpLstCode,LB_RESETCONTENT,0,0
		.if	hMemPro
			invoke GlobalFree,hMemPro
			mov		hMemPro,0
		.endif

		xor		eax,eax
		mov		fResChanged,eax
		mov		fResProject,eax
		ret
	.endif
	mov		eax,TRUE
	ret

CloseProject endp

RemovePath proc	uses esi edi,lpszFileName:DWORD,lpPath:DWORD,lpBuff:DWORD

	add		lpBuff,21
	invoke strcpy,lpBuff,lpszFileName
	mov		edi,lpBuff
	mov		esi,lpPath
	dec		esi
	dec		edi
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	.if	al>='a'	&& al<='z'
		and		al,5Fh
	.endif
	mov		ah,[edi]
	.if	ah>='a'	&& ah<='z'
		and		ah,5Fh
	.endif
	cmp		al,ah
	je		@b
	.if	al
	  @@:
		dec		esi
		dec		edi
		mov		al,[esi]
		cmp		al,'\'
		jne		@b
		inc		esi
		inc		edi
	.endif
  @@:
	mov		al,[esi]
	inc		esi
	.if	al=='\'
		dec		edi
		mov		[edi],al
		dec		edi
		dec		edi
		mov		word ptr [edi],'..'
		jmp		@b
	.elseif	al
		jmp		@b
	.endif
	mov		eax,edi
	ret

RemovePath endp

RemoveProjectPath proc lpszFileName:DWORD,lpBuff:DWORD

	invoke RemovePath,lpszFileName,offset ProjectPath,lpBuff
	ret

RemoveProjectPath endp

AddProjectFile proc	uses esi edi,lpszFileName:DWORD,fTree:DWORD,fModule:DWORD
	LOCAL	buffer[256+32]:BYTE
	LOCAL	buffer1[8]:BYTE
	LOCAL	buffer2[8]:BYTE
	LOCAL	nMiss:DWORD
	LOCAL	iNbr:DWORD
	LOCAL	iFree:DWORD
	LOCAL	lpFileName:DWORD
	LOCAL	tvi:TVITEM

	invoke GetFileAttributes,addr ProjectFile
	.if	eax!=-1
		;Remove	ProjectPath
		invoke RemovePath,lpszFileName,offset ProjectPath,addr buffer
		mov		lpFileName,eax
		;Find free iNbr
		mov		iFree,0
		mov		nMiss,0
		.if	fModule
			mov		iNbr,PRO_START_OBJ
		.else
			mov		iNbr,PRO_START_FILE
		.endif
	  @@:
		invoke GetFileNameFromID,iNbr
		.if	eax
			mov		nMiss,0
			invoke lstrcmpi,lpFileName,eax
			.if	!eax
				;The file exists in	the	project.
				jmp		ExErr
			.endif
		.else
			inc		nMiss
			.if	!iFree
				m2m		iFree,iNbr
			.endif
		.endif
		inc		iNbr
		cmp		nMiss,PRO_MAX_MISS
		jne		@b
		invoke BinToDec,iFree,addr buffer1
		invoke WritePrivateProfileString,addr iniProjectFiles,addr buffer1,lpFileName,addr ProjectFile
		.if	!hMemPro
			invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,32*1024
			mov		hMemPro,eax
		.endif
		invoke GetPrivateProfileSection,addr iniProjectFiles,hMemPro,32*1024-1,addr	ProjectFile
		.if	fTree
			.if fGroup
				invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_CARET,0
				mov		tvi.hItem,eax
				mov		tvi._mask,TVIF_PARAM
				invoke SendMessage,hPbrTrv,TVM_GETITEM,0,addr tvi
				.if sdword ptr tvi.lParam>0
					invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_PARENT,tvi.hItem
					mov		tvi.hItem,eax
					mov		tvi._mask,TVIF_PARAM
					invoke SendMessage,hPbrTrv,TVM_GETITEM,0,addr tvi
					.if sdword ptr tvi.lParam>0
						xor		edx,edx
					.else
						mov		edx,tvi.lParam
						neg		edx
					.endif
				.else
					mov		edx,tvi.lParam
					neg		edx
				.endif
				invoke BinToDec,edx,addr buffer2
				invoke WritePrivateProfileString,addr iniProjectGroup,addr buffer1,addr buffer2,addr ProjectFile
				invoke SendMessage,hPbrTrv,WM_SETREDRAW,FALSE,0
				invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
				xor		edi,edi
				invoke GetGroupState,hPbrTrv,eax
				invoke GroupGetProjectFiles
				invoke GroupUpdateTrv,hPbrTrv
				invoke GroupCollapseAll,hPbrTrv,0
				invoke SendMessage,hPbrTrv,WM_SETREDRAW,TRUE,0
				invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
				xor		edi,edi
				invoke SetGroupState,hPbrTrv,eax
			.else
				invoke GroupGetProjectFiles
				invoke GroupUpdateTrv,hPbrTrv
			.endif
		.endif
		invoke strcpy,offset FileName,offset ProjectPath
		invoke strcat,offset FileName,lpFileName
		mov		eax,FALSE
		ret
	.endif
  ExErr:
	mov		eax,TRUE
	ret

AddProjectFile endp

ProAddNew proc hWin:HWND,lParam:LPARAM
	LOCAL	lpf:DWORD

	invoke RtlZeroMemory,addr ofn,sizeof ofn
	mov		ofn.lStructSize,sizeof ofn
	m2m		ofn.hwndOwner,hWin
	m2m		ofn.hInstance,hInstance
	mov		ofn.lpstrInitialDir,offset ProjectPath
	.if	lParam==0
		;Source
		mov		ofn.lpstrFilter,offset SRCFilterString
		mov		ofn.lpstrDefExt,offset DefSrcExt
		mov		ofn.lpstrTitle,offset AddNewFile
	.elseif	lParam==1
		;Dialog
		mov		ofn.lpstrFilter,offset DLGFilterString
		mov		ofn.lpstrDefExt,offset DefDlgExt
		mov		ofn.lpstrTitle,offset AddNewDialog
	.elseif	lParam==2
		;Menu
		mov		ofn.lpstrFilter,offset MNUFilterString
		mov		ofn.lpstrDefExt,offset DefMnuExt
		mov		ofn.lpstrTitle,offset AddNewMenu
	.elseif	lParam==3
		;Header
		mov		ofn.lpstrFilter,offset HDRFilterString
		mov		ofn.lpstrDefExt,offset DefHdrExt
		mov		ofn.lpstrTitle,offset AddNewFile
	.elseif	lParam==4
		;Resource
		mov		ofn.lpstrFilter,offset RCFilterString
		mov		ofn.lpstrDefExt,offset DefRcExt
		mov		ofn.lpstrTitle,offset AddNewFile
	.elseif	lParam==5
		;Text
		mov		ofn.lpstrFilter,offset TXTFilterString
		mov		ofn.lpstrDefExt,offset DefTxtExt
		mov		ofn.lpstrTitle,offset AddNewFile
	.elseif	lParam==6
		;Module
		mov		ofn.lpstrFilter,offset MODFilterString
		mov		ofn.lpstrDefExt,offset DefModExt
		mov		ofn.lpstrTitle,offset AddNewModule
	.elseif	lParam==7
		;Any file
		mov		ofn.lpstrFilter,offset ANYFilterString
		mov		ofn.lpstrDefExt,NULL
		mov		ofn.lpstrTitle,offset AddNewFile
	.endif
	mov		ofn.lpstrFile,offset FileName
	mov		byte ptr [FileName],0
	mov		ofn.nMaxFile,sizeof	FileName
	mov		ofn.Flags,OFN_OVERWRITEPROMPT or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	invoke GetSaveFileName,addr	ofn
	.if	eax!=0
		invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if	eax!=INVALID_HANDLE_VALUE
			invoke CloseHandle,eax
			.if	lParam==6
				invoke AddProjectFile,addr FileName,TRUE,TRUE
			.else
				invoke AddProjectFile,addr FileName,TRUE,FALSE
			.endif
			invoke GetFullPathName,addr	FileName,sizeof FileName,addr FileName,addr lpf
			.if	lParam==1
				invoke CreateDlg,2
			.elseif	lParam==2
				invoke CreateMnu,2
			.else
				invoke OpenEditFile
			.endif
			invoke DllProc,hWnd,AIM_PROJECTADDNEW,lParam,addr FileName,RAM_PROJECTADDNEW
		.else
			invoke strcpy,addr	LineTxt,addr SaveFileFail
			invoke strcat,addr	LineTxt,addr FileName
			invoke MessageBox,hWnd,addr	LineTxt,addr AppName,MB_OK or MB_ICONERROR
			.if	hEdit
				invoke SetFocus,hEdit
			.endif
		.endif
	.else
		.if	hEdit
			invoke SetFocus,hEdit
		.endif
	.endif
	ret

ProAddNew endp

ProAddExist	proc  uses esi,hWin:HWND,lParam:LPARAM
	LOCAL	lpf:DWORD

	invoke RtlZeroMemory,addr ofn,sizeof ofn
	mov		ofn.lStructSize,sizeof ofn
	m2m		ofn.hwndOwner,hWin
	m2m		ofn.hInstance,hInstance
	mov		ofn.lpstrInitialDir,offset ProjectPath
	.if	lParam==0
		mov		ofn.lpstrFilter,offset ALLFilterString
		mov		ofn.lpstrDefExt,NULL
		mov		ofn.lpstrTitle,offset AddExistFile
	.elseif	lParam==1
		mov		ofn.lpstrFilter,offset DLGFilterString
		mov		ofn.lpstrDefExt,NULL
		mov		ofn.lpstrTitle,offset AddExistDialog
	.elseif	lParam==2
		mov		ofn.lpstrFilter,offset MNUFilterString
		mov		ofn.lpstrDefExt,NULL
		mov		ofn.lpstrTitle,offset AddExistMenu
	.elseif	lParam==3
		mov		ofn.lpstrFilter,offset OBJFilterString
		mov		ofn.lpstrDefExt,NULL
		mov		ofn.lpstrTitle,offset AddExistObj
	.elseif	lParam==4
		mov		ofn.lpstrFilter,offset MODFilterString
		mov		ofn.lpstrDefExt,NULL
		mov		ofn.lpstrTitle,offset AddExistModule
	.endif
	.if lParam==5
		invoke RtlZeroMemory,offset tempbuff,sizeof tempbuff
		invoke GetWindowText,hMdiCld,offset tempbuff,MAX_PATH
		mov		lParam,0
		mov		eax,TRUE
	.else
		mov		ofn.lpstrFile,offset tempbuff
		mov		byte ptr [tempbuff],0
		mov		ofn.nMaxFile,sizeof	tempbuff
		mov		ofn.Flags,OFN_FILEMUSTEXIST	or OFN_HIDEREADONLY	or OFN_PATHMUSTEXIST or	OFN_ALLOWMULTISELECT or	OFN_EXPLORER
		invoke GetOpenFileName,addr	ofn
	.endif
	.if	eax
		mov		nUpdated,0
		mov		esi,offset tempbuff
		invoke strlen,esi
		add		esi,eax
		inc		esi
		.if	!byte ptr [esi]
			;Add single	file
			invoke strcpy,offset FileName,offset tempbuff
			call	AddFile
		.else
			;Add multiple files
			.while byte	ptr	[esi]
				invoke strcpy,offset FileName,offset tempbuff
				invoke strcat,offset FileName,offset szBackSlash
				invoke strcat,offset FileName,esi
				invoke strlen,esi
				add		esi,eax
				inc		esi
				call	AddFile
			.endw
		.endif
		.if nUpdated
			invoke FixUnknown
			invoke CompactWordList
		.endif
	.else
		.if	hEdit
			invoke SetFocus,hEdit
		.endif
	.endif
	ret

AddFile:
	.if	lParam==4
		invoke AddProjectFile,addr FileName,TRUE,TRUE
	.else
		invoke AddProjectFile,addr FileName,TRUE,FALSE
	.endif
	invoke GetFullPathName,addr	FileName,sizeof FileName,addr FileName,addr lpf
	.if	lParam==0 || lParam==4
		invoke OpenEditFile
		invoke SetWindowLong,hMdiCld,12,TRUE
		invoke SetOpenProperty,hMdiCld,-1
	.elseif	lParam==1
		invoke CreateDlg,0
	.elseif	lParam==2
		.if	!byte ptr [esi]
			invoke CreateMnu,0
		.endif
	.endif
	invoke DllProc,hWnd,AIM_PROJECTADDNEW,lParam,addr FileName,RAM_PROJECTADDNEW
	retn

ProAddExist	endp

ProRemoveFile proc lpszFileName:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	nMiss:DWORD
	LOCAL	iNbr:DWORD

	invoke GetFileAttributes,addr ProjectFile
	.if	eax!=-1
		;Find the files	iNbr
		mov		nMiss,0
		mov		iNbr,PRO_START_FILE
	  @@:
		invoke GetFileNameFromID,iNbr
		.if	eax
			push	eax
			invoke strcpy,addr buffer,offset ProjectPath
			pop		eax
			invoke strcat,addr buffer,eax
			invoke GetFullPathName,addr buffer,sizeof buffer,addr buffer,addr nMiss
			mov		nMiss,0
			invoke lstrcmpi,lpszFileName,addr buffer
			or		eax,eax
			je		@f
		.else
			inc		nMiss
		.endif
		inc		iNbr
		.if	nMiss==PRO_MAX_MISS
			.if	iNbr<PRO_START_OBJ
				mov		nMiss,0
				mov		iNbr,PRO_START_OBJ
				jmp		@b
			.endif
		.else
			jmp		@b
		.endif
		mov		eax,TRUE
		ret
	  @@:
		invoke BinToDec,iNbr,addr buffer
		invoke WritePrivateProfileString,addr iniProjectFiles,addr buffer,addr	szNULL,addr	ProjectFile
		invoke WritePrivateProfileString,addr iniProjectGroup,addr buffer,addr	szNULL,addr	ProjectFile
		invoke WritePrivateProfileString,addr iniProjectSize,addr buffer,addr szNULL,addr ProjectFile
		invoke GetPrivateProfileSection,addr iniProjectFiles,hMemPro,32*1024-1,addr	ProjectFile
		invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_CARET,hRoot
		invoke SendMessage,hPbrTrv,TVM_DELETEITEM,0,eax
		.if	hEdit
			invoke SetFocus,hEdit
		.endif
		mov		eax,FALSE
		ret
	.endif
	.if	hEdit
		invoke SetFocus,hEdit
	.endif
	mov		eax,TRUE
	ret

ProRemoveFile endp

;########################################################################

ToolProjectSize	proc lParam:LPARAM
	LOCAL	wt:DWORD
	LOCAL	ht:DWORD

	mov		eax,lParam
	and		eax,0FFFFh
	mov		wt,eax
	mov		eax,lParam
	shr		eax,16
	sub		eax,26
	.if	sdword ptr eax<0
		mov		eax,0
	.endif
	mov		ht,eax
	invoke MoveWindow,hPbrTrv,0,26,wt,ht,TRUE
	invoke MoveWindow,hFileTrv,0,26,wt,ht,TRUE
	ret

ToolProjectSize	endp

Do_ImageList proc phInst:HINSTANCE,pidBmp:DWORD,nSize:DWORD,nImg:DWORD,fMap:DWORD,fBack:DWORD,fFore:DWORD
	LOCAL	lhIml:DWORD
	LOCAL	cm[2]:COLORMAP

	invoke ImageList_Create,nSize,nSize,ILC_COLOR8 or ILC_MASK,nImg,0
	mov		lhIml,eax
	.if	fMap
		mov		cm.From,0FFFFFFh
		m2m		cm.To,fBack
		mov		cm[sizeof COLORMAP].From,0h
		m2m		cm[sizeof COLORMAP].To,fFore
		invoke CreateMappedBitmap,phInst,pidBmp,NULL,addr cm,fMap
	.else
		invoke LoadBitmap,phInst,pidBmp
	.endif
	push	eax
	invoke ImageList_AddMasked,lhIml,eax,fBack
	pop		eax
	invoke DeleteObject,eax
	mov		eax,lhIml
	ret

Do_ImageList endp

TreeViewProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if	eax==WM_LBUTTONDBLCLK
		invoke CallWindowProc,OldTreeViewProc,hWin,uMsg,wParam,lParam
		push	eax
		invoke SendMessage,hWnd,WM_TOOLDBLCLICK,hWin,lParam
		pop		eax
		ret
	.elseif	eax==WM_CHAR
		.if	wParam==VK_RETURN
			invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_CARET,0
			mov		dword ptr rect,eax
			invoke SendMessage,hWin,TVM_GETITEMRECT,TRUE,addr rect
			mov		eax,rect.top
			shl		eax,16
			add		eax,rect.left
			invoke SendMessage,hWnd,WM_TOOLDBLCLICK,hWin,eax
			xor		eax,eax
			ret
		.endif
	.elseif	eax==WM_RBUTTONDOWN
		invoke SendMessage,hWnd,WM_TOOLRCLICK,hWin,lParam
	.elseif	eax==WM_SETFOCUS
		mov		eax, hPbr
		call	GetToolPtr
		mov		(TOOL ptr [edx]).dFocus,TRUE
		invoke ToolMsg,hPbr,TLM_CAPTION,0
	.elseif	eax==WM_KILLFOCUS
		mov		eax, hPbr
		call	GetToolPtr
		mov		(TOOL ptr [edx]).dFocus,FALSE
		invoke ToolMsg,hPbr,TLM_CAPTION,0
	.elseif eax==WM_DROPFILES
		xor		ebx,ebx
	  @@:
		invoke DragQueryFile,wParam,ebx,addr buffer,sizeof buffer
		.if eax
			invoke iniInStr,addr buffer,addr FTRap
			.if eax==-1
				invoke GetFileAttributes,addr buffer
				test	eax,FILE_ATTRIBUTE_DIRECTORY
				.if ZERO?
					invoke AddProjectFile,addr buffer,TRUE,FALSE
				.endif
				inc		ebx
				jmp		@b
			.endif
		.endif
	.endif
	invoke CallWindowProc,OldTreeViewProc,hWin,uMsg,wParam,lParam
	ret

TreeViewProc endp

FileTreeViewProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	lpht:TV_HITTESTINFO
	LOCAL	lptvi:TV_ITEMEX
	LOCAL	hTvi:HWND
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if	eax==WM_LBUTTONDBLCLK
		invoke CallWindowProc,OldTreeViewProc,hWin,uMsg,wParam,lParam
		push	eax
		mov		eax,lParam
		and		eax,0FFFFh
		mov		lpht.pt.x,eax
		mov		eax,lParam
		shr		eax,16
		mov		lpht.pt.y,eax
		invoke SendMessage,hWin,TVM_HITTEST,0,addr lpht
		.if	eax
			mov		hTvi,eax
			mov		eax,lpht.flags
			and		eax,TVHT_ONITEM
			.if	eax
				m2m		lptvi.hItem,lpht.hItem
				mov		lptvi.imask,TVIF_PARAM or TVIF_TEXT	or TVIF_IMAGE
				lea		eax,buffer
				mov		lptvi.pszText,eax
				mov		lptvi.cchTextMax,sizeof	buffer
				invoke SendMessage,hWin,TVM_GETITEM,0,addr lptvi
				.if	lptvi.lParam
					.if	lptvi.iImage==IML_START+0
						invoke strlen,offset FilePath
						.if byte ptr FilePath[eax-1]!='\'
							invoke strcat,offset FilePath,offset szBackSlash
						.endif
						invoke strcat,offset FilePath,addr	buffer
						invoke FileDir,offset FilePath
					.elseif	lptvi.iImage<IML_START+11
						invoke strcpy,offset FileName,offset FilePath
						invoke strlen,offset FilePath
						.if byte ptr FileName[eax-1]!='\'
							invoke strcat,offset FileName,offset szBackSlash
						.endif
						invoke strcat,offset FileName,addr	buffer
						mov		fFileBrowserOpen,TRUE
						invoke ProjectOpenFile,TRUE
						mov		fFileBrowserOpen,FALSE
						invoke AddRecentFile,offset	FileName
					.endif
				.endif
			.endif
		.endif
		pop		eax
		ret
	.elseif	eax==WM_KEYDOWN
		.if	wParam==VK_DELETE
			invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_CARET,0
			.if eax
				mov		lptvi.hItem,eax
				mov		lptvi.imask,TVIF_IMAGE
				invoke SendMessage,hWin,TVM_GETITEM,0,addr lptvi
				mov		eax,lptvi.iImage
				.if eax>1 && eax<11
					invoke SendMessage,hWnd,WM_COMMAND,IDM_FILE_DELETE,0
				.endif
			.endif
		.endif
	.elseif	eax==WM_CHAR
		.if	wParam==VK_RETURN
			invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_CARET,0
			mov		dword ptr rect,eax
			invoke SendMessage,hWin,TVM_GETITEMRECT,TRUE,addr rect
			mov		eax,rect.top
			shl		eax,16
			add		eax,rect.left
			invoke SendMessage,hWin,WM_LBUTTONDBLCLK,0,eax
			xor		eax,eax
			ret
		.elseif	wParam=='\'
			invoke iniRStripStr,offset FilePath,'\'
			invoke strlen,offset FilePath
			.if byte ptr FilePath[eax-1]==':'
				invoke strcat,offset FilePath,offset szBackSlash
			.endif
			invoke FileDir,offset FilePath
			xor		eax,eax
			ret
		.endif
	.elseif	eax==WM_RBUTTONDOWN
		invoke SendMessage,hWnd,WM_TOOLRCLICK,hWin,lParam
	.elseif	eax==WM_SETFOCUS
		mov		eax, hPbr
		call	GetToolPtr
		mov		(TOOL ptr [edx]).dFocus,TRUE
		invoke ToolMsg,hPbr,TLM_CAPTION,0
	.elseif	eax==WM_KILLFOCUS
		mov		eax, hPbr
		call	GetToolPtr
		mov		(TOOL ptr [edx]).dFocus,FALSE
		invoke ToolMsg,hPbr,TLM_CAPTION,0
	.endif
	invoke CallWindowProc,OldTreeViewProc,hWin,uMsg,wParam,lParam
	ret

FileTreeViewProc endp

Do_TreeView	proc phInst:HINSTANCE,phOwner:DWORD,pID_TV:DWORD,phIml:DWORD,fEdit:DWORD,fDropFiles:DWORD
	LOCAL	lhTrv:DWORD

	mov		eax,WS_CHILD or	WS_VISIBLE or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or	\
			TVS_HASLINES or	TVS_HASBUTTONS or TVS_SHOWSELALWAYS
	.if	fEdit
		or		eax,TVS_EDITLABELS
	.endif
	mov		edx,WS_EX_CLIENTEDGE
	.if fDropFiles
		or		edx,WS_EX_ACCEPTFILES
	.endif
	invoke CreateWindowEx,edx,addr	szTreeView,NULL,eax,0,0,0,0,phOwner,NULL,phInst,NULL
	mov		lhTrv,eax
	invoke SendMessage,lhTrv,TVM_SETIMAGELIST,0,phIml
	mov		eax,radcol.project
	.if	eax!=0FFFFFFh
		invoke SendMessage,lhTrv,TVM_SETBKCOLOR,0,eax
	.endif
	invoke SendMessage,lhTrv,WM_SETFONT,hLBFont,FALSE
	mov		eax,lhTrv
	ret

Do_TreeView	endp

Do_ProjectTool proc
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	sTool:DOCKING
	LOCAL	hWin:HWND

	mov		sTool.ID,1
	mov		sTool.Caption,offset szProjectCaption
	invoke strcpy,addr	buffer,addr	Project
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.Visible,eax
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.Docked,eax
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.Position,eax
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.IsChild,eax
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.DockWidth,eax
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.DockHeight,eax
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.FloatRect.left,eax
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.FloatRect.top,eax
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.FloatRect.right,eax
	invoke iniGetItem,addr buffer,addr buffer2
	invoke DecToBin,addr	buffer2
	mov		sTool.FloatRect.bottom,eax
	invoke CreateWindowEx,0,addr szToolCldClass,NULL,
			WS_CHILD or	WS_VISIBLE or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,
			0,0,0,0,hWnd,0,hInstance,0
	mov		hWin,eax
	invoke Do_TreeView,hInstance,hWin,0,hTbrIml,TRUE,TRUE
	mov		hPbrTrv,eax
	invoke SetWindowLong,hPbrTrv,GWL_WNDPROC,offset TreeViewProc
	mov		OldTreeViewProc,eax
	invoke Do_TreeView,hInstance,hWin,0,hTbrIml,TRUE,FALSE
	mov		hFileTrv,eax
	invoke SetWindowLong,hFileTrv,GWL_WNDPROC,offset FileTreeViewProc
	invoke ShowWindow,hPbrTrv,SW_HIDE
	;Create	the	toolbar
	invoke CreateWindowEx,0,addr szToolBar,0,WS_CHILD or WS_VISIBLE	or TBSTYLE_TOOLTIPS or TBSTYLE_FLAT	or CCS_NODIVIDER or	CCS_NORESIZE,0,1,200,24,hWin,0,hInstance,0
	mov		hPbrTbr,eax
	.if fNT
		;Unicode
		invoke SendMessage,hPbrTbr,TB_SETUNICODEFORMAT,TRUE,0
	.endif
	;Set toolbar images
	invoke SendMessage,hPbrTbr,TB_SETIMAGELIST,0,hTbrIml
	;Set toolbar struct	size
	invoke SendMessage,hPbrTbr,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
	;Set toolbar buttons
	invoke SendMessage,hPbrTbr,TB_ADDBUTTONS,npbrtbrbtns,addr pbrtbrbtns

	invoke ToolMessage,hWin,TLM_CREATE,addr	sTool
	mov		eax,hWin
	ret

Do_ProjectTool endp

Do_TreeViewAddNode proc	hWin:HWND,lhPar:DWORD,lhInsAfter:DWORD,pszText:DWORD,pidSel:DWORD,pidNosel:DWORD,lParam:LPARAM
	LOCAL	tvins:TV_INSERTSTRUCT

	m2m		tvins.hParent,lhPar
	m2m		tvins.hInsertAfter,lhInsAfter
	m2m		tvins.item.lParam,lParam
	mov		tvins.item._mask,TVIF_TEXT or TVIF_IMAGE or	TVIF_SELECTEDIMAGE or TVIF_PARAM
	m2m		tvins.item.pszText,pszText
	m2m		tvins.item.iImage,pidSel
	m2m		tvins.item.iSelectedImage,pidNosel
	invoke SendMessage,hWin,TVM_INSERTITEM,0,addr tvins
	ret

Do_TreeViewAddNode endp

GetSelected	proc uses ebx,lpTvi:DWORD,lpBuff:DWORD,bSize:DWORD

	mov		ebx,lpTvi
	assume ebx:ptr TV_ITEMEX
	mov		[ebx].lParam,0
	mov		eax,lpBuff
	mov		byte ptr [eax],0
	invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_CARET,hPbrTrv
	.if	eax
		mov		[ebx].hItem,eax
		mov		[ebx].imask,TVIF_PARAM or TVIF_TEXT
		m2m		[ebx].pszText,lpBuff
		mov		eax,bSize
		mov		[ebx].cchTextMax,eax
		invoke SendMessage,hPbrTrv,TVM_GETITEM,0,ebx
	.endif
	mov		eax,[ebx].lParam
	assume ebx:nothing
	ret

GetSelected	endp

ProjectDblClick	proc hWin:HWND,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	lpht:TV_HITTESTINFO
	LOCAL	lptvi:TV_ITEMEX
	LOCAL	hTvi:HWND

	mov		eax,lParam
	and		eax,0FFFFh
	mov		lpht.pt.x,eax
	mov		eax,lParam
	shr		eax,16
	mov		lpht.pt.y,eax
	invoke SendMessage,hWin,TVM_HITTEST,0,addr lpht
	.if	eax
		mov		hTvi,eax
		mov		eax,lpht.flags
		and		eax,TVHT_ONITEM
		.if	eax
			m2m		lptvi.hItem,lpht.hItem
			mov		lptvi.imask,TVIF_PARAM or TVIF_TEXT
			lea		eax,buffer
			mov		lptvi.pszText,eax
			mov		lptvi.cchTextMax,sizeof	buffer
			invoke SendMessage,hWin,TVM_GETITEM,0,addr lptvi
			.if	sdword ptr lptvi.lParam>0
				invoke strcpy,addr FileName,addr ProjectPath
				lea		edx,buffer
				call	TestFileName
				invoke strcat,addr	FileName,edx
				invoke ProjectOpenFile,TRUE
			.endif
		.endif
	.endif
	ret

TestFileName:
	mov		eax,[edx]
	and		eax,0FFFFFFh
	.if	eax=='\..'
		push	edx
		invoke strlen,addr	FileName
		lea		edx,FileName[eax]
		dec		edx
		dec		edx
		.while byte	ptr	[edx]!='\' && edx>=offset FileName
			mov		byte ptr [edx],0
			dec		edx
		.endw
		pop		edx
		add		edx,3
		jmp		TestFileName
	.endif
	retn

ProjectDblClick	endp

ProjectRClick proc hWin:HWND,lParam:LPARAM
	LOCAL	lpht:TV_HITTESTINFO
	LOCAL	hTvi:HWND

	mov		eax,lParam
	and		eax,0FFFFh
	mov		lpht.pt.x,eax
	mov		eax,lParam
	shr		eax,16
	mov		lpht.pt.y,eax
	invoke SendMessage,hWin,TVM_HITTEST,0,addr lpht
	.if	eax
		mov		hTvi,eax
		mov		eax,lpht.flags
		and		eax,TVHT_ONITEM
		.if	eax
			invoke SendMessage,hWin,TVM_SELECTITEM,TVGN_CARET,hTvi
		.endif
	.endif
	ret

ProjectRClick endp

ProSavePos proc	hWin:HWND
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[128]:BYTE
	LOCAL	iNbr:DWORD
	LOCAL	rect:RECT
	LOCAL	pt:POINT
	LOCAL	val:DWORD
	LOCAL	chrg:CHARRANGE

	invoke GetFileAttributes,addr ProjectFile
	.if	eax!=-1
		;Get Pfoject file ID
		invoke GetWindowLong,hWin,16
		.if	eax
			mov		iNbr,eax
			invoke BinToDec,iNbr,addr buffer1
			;Get FileName
			invoke GetWindowText,hWin,addr FileName,sizeof FileName
			invoke IsIconic,hWin
			.if	!eax
				invoke IsZoomed,hWin
			.endif
			.if	eax
				xor		eax,eax
				mov		rect.left,eax
				mov		rect.top,eax
				mov		rect.right,eax
				mov		rect.bottom,eax
				invoke ProSetPos,addr rect
			.else
				mov		pt.x,0
				mov		pt.y,0
				invoke ClientToScreen,hClient,addr pt
				invoke GetWindowRect,hWin,addr rect
				mov		eax,pt.x
				sub		rect.left,eax
				sub		rect.right,eax
				mov		eax,pt.y
				sub		rect.top,eax
				sub		rect.bottom,eax
				mov		eax,rect.right
				sub		eax,rect.left
				mov		rect.right,eax
				mov		eax,rect.bottom
				sub		eax,rect.top
				mov		rect.bottom,eax
			.endif
			mov		buffer2,0
			invoke iniPutItem,rect.left,addr buffer2,TRUE
			invoke iniPutItem,rect.top,addr	buffer2,TRUE
			invoke iniPutItem,rect.right,addr buffer2,TRUE
			invoke GetWindowLong,hWin,0
			.if	eax==ID_EDIT ||	eax==ID_EDITTXT
				invoke iniPutItem,rect.bottom,addr buffer2,TRUE
				;Get handle	of RAEdit
				invoke GetWindowLong,hWin,GWL_USERDATA
				mov		val,eax
				invoke SendMessage,val,EM_EXGETSEL,0,addr chrg
				invoke iniPutItem,chrg.cpMin,addr buffer2,FALSE
			.else
				invoke iniPutItem,rect.bottom,addr buffer2,FALSE
			.endif
			invoke WritePrivateProfileString,addr iniProjectSize,addr buffer1,addr buffer2,addr	ProjectFile
		.endif
	.endif
	ret

ProSavePos endp

ProSetTrv proc hWin:HWND

	invoke GetWindowLong,hWin,16
	invoke GroupFindItem,hPbrTrv,0,0,eax
	.if eax
		invoke SendMessage,hPbrTrv,TVM_SELECTITEM,TVGN_CARET,eax
	.endif
	ret

ProSetTrv endp

ProSetPos proc lpRect
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	nMiss:DWORD
	LOCAL	iNbr:DWORD
	LOCAL	lp:DWORD
	LOCAL	tp:DWORD
	LOCAL	wt:DWORD
	LOCAL	ht:DWORD
	LOCAL	lpf:DWORD

	.if	fProject
		invoke GetFileAttributes,addr ProjectFile
		.if	eax!=-1
			mov		nMiss,0
			mov		iNbr,PRO_START_FILE
		  @@:
			invoke GetFileNameFromID,iNbr
			.if	eax
				mov		nMiss,0
				push	eax
				invoke strcpy,addr buffer,addr	ProjectPath
				pop		eax
				invoke strcat,addr buffer,eax
				invoke GetFullPathName,addr	buffer,sizeof buffer,addr buffer,addr lpf
				invoke iniInStr,addr FileName,addr buffer
				.if	eax!=-1
					invoke BinToDec,iNbr,addr buffer1
					invoke GetPrivateProfileString,addr	iniProjectSize,addr	buffer1,addr szNULL,addr buffer2,64,addr ProjectFile
					mov		al,buffer2[0]
					.if	al && SaveSize
						invoke iniGetItem,addr buffer2,addr	buffer1
						invoke DecToBin,addr	buffer1
						.if	sdword ptr eax<0
							xor		eax,eax
						.endif
						mov		lp,eax
						invoke iniGetItem,addr buffer2,addr	buffer1
						invoke DecToBin,addr	buffer1
						.if	sdword ptr eax<0
							xor		eax,eax
						.endif
						mov		tp,eax
						invoke iniGetItem,addr buffer2,addr	buffer1
						invoke DecToBin,addr buffer1
						.if	sdword ptr eax<0
							xor		eax,eax
						.endif
						mov		wt,eax
						invoke iniGetItem,addr buffer2,addr	buffer1
						invoke DecToBin,addr	buffer1
						.if	sdword ptr eax<0
							xor		eax,eax
						.endif
						mov		ht,eax
						mov		edx,lpRect
						assume edx:ptr RECT
						mov		eax,lp
						mov		[edx].left,eax
						mov		eax,tp
						mov		[edx].top,eax
						mov		eax,wt
						mov		[edx].right,eax
						mov		eax,ht
						mov		[edx].bottom,eax
						assume edx:nothing
						invoke iniGetItem,addr buffer2,addr	buffer1
						invoke DecToBin,addr buffer1
						mov		REdPos,eax
					.endif
					mov		eax,iNbr
					ret
				.endif
			.else
				inc		nMiss
			.endif
			inc		iNbr
			.if	nMiss==PRO_MAX_MISS
				.if	iNbr<PRO_START_OBJ
					mov		nMiss,0
					mov		iNbr,PRO_START_OBJ
					jmp		@b
				.endif
			.else
				jmp		@b
			.endif
		.endif
	.endif
	xor		eax,eax
	ret

ProSetPos endp

ProjectOpenFile	proc fErr:DWORD
	LOCAL	fd:WIN32_FIND_DATA
	LOCAL	buffer[256]:BYTE
	LOCAL	fb[256]:BYTE

	mov		eax,offset FileName
	.while byte ptr [eax]
		.if byte ptr [eax]=='/'
			mov		byte ptr [eax],'\'
		.endif
		inc		eax
	.endw
	invoke GetFullPathName,offset FileName,sizeof FileName,offset FileName,addr fb
	mov		fb,0
  @@:
	invoke FindFirstFile,offset FileName,addr fd
	invoke FindClose,eax
	invoke strcpy,addr buffer,addr szBackSlash
	invoke strcat,addr buffer,addr fd.cFileName
	invoke strcat,addr buffer,addr fb
	invoke strcpy,addr fb,addr buffer
	invoke strlen,addr FileName
	.while byte ptr FileName[eax]!='\' && eax
		dec		eax
	.endw
	.if eax
		mov		FileName[eax],0
		.if FileName[eax-1]!=':' && FileName[eax-1]!='\'
			jmp		@b
		.endif
	.endif
	invoke strcat,addr FileName,addr fb
	mov		hFound,0
	invoke UpdateAll,IDM_FILE_OPENFILE
	.if	!hFound
;		.if	fErr
;			invoke OpenEditFile
;		.else
			invoke GetFileAttributes,addr FileName
			test	eax,FILE_ATTRIBUTE_DIRECTORY
			.if ZERO?
				invoke OpenEditFile
			.endif
;		.endif
	.else
		invoke IsIconic,hFound
		.if	eax
			invoke ShowWindow,hFound,SW_RESTORE
		.endif
		invoke GetWindowLong,hFound,GWL_USERDATA
		invoke SetFocus,eax
		mov		eax,FALSE
	.endif
	ret

ProjectOpenFile	endp
