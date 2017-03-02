
.data

iniFilename 		db '\RadASM.ini',0

;MDI window
iniWindow			db 'Window',0
iniWinToolBar		db 'ToolBar',0
iniWinStatusBar 	db 'StatusBar',0
iniWinProject		db 'Project',0
iniWinOutput		db 'Output',0
iniWinToolBox		db 'ToolBox',0
iniWinProperty		db 'Property',0
iniWinTabTool		db 'TabTool',0
iniWinInfoTool		db 'InfoTool',0
iniWinTool1			db 'Tool1',0
iniWinTool2			db 'Tool2',0
iniWinClipping		db 'ToolClipping',0
iniWinDivider		db 'Divider',0
iniWinMultiLine		db 'MultiLine',0
iniWinRightCaption	db 'RightCaption',0
iniWinMaximized 	db 'Maximized',0
iniWinTopMost		db 'TopMost',0
iniWinTop			db 'Top',0
iniWinLeft			db 'Left',0
iniWinHeight		db 'Height',0
iniWinWidth 		db 'Width',0
iniWinCCList		db 'CCList',0
iniWinFind			db 'Find',0
iniWinGoto			db 'Goto',0
iniWinProWiz		db 'ProWiz',0
iniWinProOpt		db 'ProOpt',0
iniSplash			db 'Splash',0
iniSplashBmp		db 'Bmp',0
iniSplashnShow		db 'nShow',0
iniSingleInstance	db 'SingleInstance',0
iniAccel			db 'Accel',0
iniVer				db 'Ver',0
iniMagnify			db 'Magnify',0

iniDefLoc			db '10,10',0
iniDefProOpt		db '10,10,301',0

;MRU projects
iniMRUPro			db 'MRU-Projects',0

;Assembler
iniAssembler		db 'Assembler',0
iniRelease			db 'Release',0
iniDebug			db 'Debug',0
ininAsm				db 'nAsm',0

;Templates
iniTemplate			db 'Template',0
iniTemplateTxt		db 'Txt',0
iniTemplateBin		db 'Bin',0

;Addins
iniAddIns			db 'AddIns',0
iniParseDll			db 'ParseDll',0
szMasmParseDll		db 'masmParse.dll',0

;Sniplet
iniSniplet			db 'Sniplet',0
iniSnipletSelAll	db 'SelAll',0
iniSnipletCopyTo	db 'CopyTo',0
iniSnipletClose		db 'Close',0
iniSnipletExpanded	db 'Expanded',0
iniSnipletSplit		db 'Split',0

;Menu
iniMenuTool			db 'MenuTools',0
iniMenuMacro		db 'MenuMacro',0
iniMenuHelp			db 'MenuHelp',0
iniKeyHelp			db 'F1-Help',0
iniKeyHelpF1		db 'F1',0
iniKeyHelpCF1		db 'CF1',0
iniKeyHelpSF1		db 'SF1',0
iniKeyHelpCSF1		db 'CSF1',0

; fearless Added 01/03/2017 - allow CTRL+F1 and CTRL+F2 to search online for keyword. CTRL+F1 is for MSDN, CTRL+F2 is for google, CTRL+ALT+M is for MSDN.
iniOnlineHelp       db 'OnlineHelp',0
iniDefaultProvider  db 'DefaultProvider',0 ; 0 for MSDN, 1 for google
iniF1OnlineHelp     db 'F1',0 ; 0 for FALSE, 1 for TRUE to use F1 to call online help instead.


iniDefCCList		db '200,150',0
iniDefPrnPagemm		db '20990,29690,1000,1000,1000,1000,0',0
iniDefPrnPageInch	db '8500,11000,500,500,500,500,0',0
iniDefPrnOption		db '2,0,1,1,1',0
iniDefPrnColor		db '0,32768,8421504,255,65280,10485760,10485760,10485760,10485760,10485760,10485760,10485760,10485760,10485760,10485760,10485760,10485760,10485760,10485760,10485760,10485760',0
iniDefCodeFiles		db'.asm.inc.rc.tpl.rad.',0
iniDefLnrFont		db 'Terminal',0
iniDefTool			db '0,1,2,0,30,30,100,100,150,200',0
iniDefClipping		db '1,5,3,4,2,6,7,8',0

iniCharTab			db 'CharTab',0

iniRecentFiles		db 'RecentFiles',0

iniError			db 'Error',0
iniErrBookMark		db 'BookMark',0

szGetCharTabPtr		db 'GetCharTabPtr',0

iniDefSrc			db 'Assembly (*.asm),*.asm,asm',0
iniDefHdr			db 'Include (*.inc),*.inc,inc',0
iniDefMod			db 'Module (*.asm),*.asm,asm',0

iniAccept			db 'Accept',0
iniDontAsk			db 'DontAsk',0

; Assembler.ini updates
szMasmCodeData		db '{C},$ db,$ dw,$ dd,$ dq,$ df,$ dt,$ byte,$ word,$ dword,$ qword,$ real4,$ real8,$ tbyte',0
szMasmApiArray		db 'Masm\masmArray.api',0
szCppApiArray		db 'Cpp\cppArray.api',0

; RadASM.ini updates
szTool1Update		db '0,0,3,2,557,239,3,3,531,261',0

.code

UpDateAssemblerIni proc
	LOCAL Version:DWORD
	LOCAL	buffer[32]:BYTE
	LOCAL	nInx:DWORD

	invoke GetPrivateProfileInt,addr iniVersion,addr iniVersion,0,addr iniAsmFile
	mov		Version,eax
	.if eax<2215
		invoke GetPrivateProfileInt,addr iniColor,addr iniColors+8,0,addr iniAsmFile
		invoke BinToDec,eax,addr iniBuffer
		mov		esi,offset iniColorsBack
		.while dword ptr [esi]
			lea		esi,[esi+8]
			invoke WritePrivateProfileString,addr iniColor,esi,addr iniBuffer,addr iniAsmFile
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
		mov		nInx,0
		mov		buffer,'B'
		.while nInx<16
			invoke BinToDec,nInx,addr buffer[1]
			invoke WritePrivateProfileString,addr iniColor,addr buffer,addr iniBuffer,addr iniAsmFile
			inc		nInx
		.endw
	.endif
	mov		eax,nAsm
	.if eax
		mov		edx,nRadASMVer
		.if eax==nMASM
			.if Version<=2217
				invoke WritePrivateProfileString,addr szIniCode,addr szIniData,addr szMasmCodeData,addr iniAsmFile
				invoke WritePrivateProfileString,addr iniApi,addr iniApiArray,addr szMasmApiArray,addr iniAsmFile
			.endif
			.if Version<2218
				invoke WritePrivateProfileString,addr szIniCode,addr iniParseDll,addr szMasmParseDll,addr iniAsmFile
			.endif
		.elseif eax==nCPP
			.if Version<=2217
				invoke WritePrivateProfileString,addr iniApi,addr iniApiArray,addr szCppApiArray,addr iniAsmFile
			.endif
		.endif
		invoke BinToDec,nRadASMVer,addr iniBuffer
		invoke WritePrivateProfileString,addr iniVersion,addr iniVersion,addr iniBuffer,addr iniAsmFile
	.endif
	ret

UpDateAssemblerIni endp

GetRecentFiles proc uses esi
	LOCAL buffer[4]:BYTE

	mov		esi,offset RecentFiles
	mov		dword ptr buffer,'0'
	.while dword ptr buffer<='9'
		invoke GetPrivateProfileString,addr iniRecentFiles,addr buffer,addr szNULL,esi,256,addr iniFile
		.if byte ptr [esi]
			invoke GetFileAttributes,esi
			.if eax!=-1
				add		esi,256
			.endif
		.endif
		mov		dword ptr [esi],0
		inc		byte ptr buffer
	.endw
	ret

GetRecentFiles endp

SaveRecentFiles proc uses esi
	LOCAL buffer[4]:BYTE

	mov		dword ptr buffer,'=0'
	invoke WritePrivateProfileSection,addr iniRecentFiles,addr buffer,addr iniFile
	mov		esi,offset RecentFiles
	mov		dword ptr buffer,'0'
	.while esi<offset RecentFiles+sizeof RecentFiles
		.if byte ptr [esi]
			invoke GetFileAttributes,esi
			.if eax!=-1
				invoke WritePrivateProfileString,addr iniRecentFiles,addr buffer,esi,addr iniFile
				inc		byte ptr buffer
			.endif
		.endif
		add		esi,256
	.endw
	ret

SaveRecentFiles endp

AddRecentFile proc uses esi edi,lpszFile:DWORD

	mov		esi,offset RecentFiles
	xor		eax,eax
	.while eax<10
		push	eax
		invoke lstrcmpi,lpszFile,esi
		.if !eax
			call	DelFile
		.else
			.if byte ptr [esi]
				invoke GetFileAttributes,esi
			.else
				xor		eax,eax
				dec		eax
			.endif
			.if eax==-1
				call	DelFile
			.else
				add		esi,256
			.endif
		.endif
		pop		eax
		inc		eax
	.endw
	call	InsFile
	invoke strcpy,offset RecentFiles,lpszFile
	ret

DelFile:
	push	esi
	mov		edi,esi
	add		esi,256
	.while esi<offset RecentFiles+sizeof RecentFiles
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		byte ptr [edi],0
	pop		esi
	retn

InsFile:
	mov		edi,offset RecentFiles+sizeof RecentFiles-1
	mov		esi,edi
	sub		esi,256
	.while esi>=offset RecentFiles
		mov		al,[esi]
		mov		[edi],al
		dec		esi
		dec		edi
	.endw
	retn

AddRecentFile endp

SetRecentFilesMenu proc uses esi
	LOCAL	nID:DWORD
	LOCAL	buffer[256]:BYTE

	.if byte ptr RecentFiles
		xor		eax,eax
		.while eax<10
			push	eax
			invoke DeleteMenu,hMnuRecent,0,MF_BYPOSITION
			pop		eax
			inc		eax
		.endw
		mov		esi,offset RecentFiles
		mov		nID,21000
		xor		eax,eax
		.while eax<10
			push	eax
			invoke strcpy,addr buffer,esi
			.if byte ptr buffer
				invoke AppendMenu,hMnuRecent,MF_STRING,nID,addr buffer
			.endif
			pop		eax
			inc		nID
			add		esi,256
			inc		eax
		.endw
	.endif
	ret

SetRecentFilesMenu endp

iniGetCharTab proc
	LOCAL nInx:DWORD
	LOCAL buffer[32]:BYTE

	invoke SendMessage,hOut1,REM_CHARTABINIT,0,0
	mov		nInx,0
	.while nInx<16
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr iniCharTab,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr iniAsmFile
		.if eax
			xor		eax,eax
			.while eax<16
				push	eax
				mov		edx,nInx
				shl		edx,4
				or		edx,eax
				mov		al,buffer[eax]
				.if al>='0' && al<='9'
					and		eax,0Fh
					add		edx,lpCharTab
					mov		[edx],al
				.endif
				pop		eax
				inc		eax
			.endw
		.endif
		inc		nInx
	.endw
	ret

iniGetCharTab endp

iniHook proc uses ebx edi
	LOCAL	nInx:DWORD
	LOCAL	buffer1[8]:BYTE
	LOCAL	buffer2[128]:BYTE
	LOCAL	buffer3[128]:BYTE

	mov		nInx,1
	mov		ebx,1
	.while nInx<=MAX_ADDIN
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniAddIns,addr buffer1,addr szNULL,addr buffer2,128,addr iniFile
		.if eax
			mov		ebx,nInx
			invoke iniGetItem,addr buffer2,addr buffer3
			invoke strcmpi,addr buffer3,addr szRADebug
			.if !eax
				; Found
				xor		ebx,ebx
				.break
			.endif
		.endif
		inc		nInx
	.endw
	.if ebx
		invoke strcpy,addr buffer2,addr szRADebug
		invoke strcat,addr buffer2,addr szRADebugParam
		invoke BinToDec,ebx,addr buffer1
		invoke WritePrivateProfileString,addr iniAddIns,addr buffer1,addr buffer2,addr iniFile
	.endif
	mov		nInx,1
	mov		edi,offset hAddins
	.while nInx<=MAX_ADDIN
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniAddIns,addr buffer1,addr szNULL,addr buffer2,128,addr iniFile
		.if eax
			invoke iniGetItem,addr buffer2,addr buffer3
			invoke strcpy,addr FileName,addr AddIn
			invoke strcat,addr FileName,addr szBackSlash
			invoke strcat,addr FileName,addr buffer3
			invoke strcmpi,addr szDragProp,addr buffer3
			.if !eax
				invoke DeleteFile,addr FileName
			.else
				invoke iniGetItem,addr buffer2,addr buffer3
				mov		al,buffer2
				.if al
					invoke DecToBin,addr buffer2
					or		eax,eax
					jne		@f
				.else
				  @@:
					invoke LoadLibrary,addr FileName
					.if eax
						mov		[edi].ADDIN.hDLL,eax
						invoke DecToBin,addr buffer3
						mov		[edi].ADDIN.fOpt,eax
						mov		eax,nInx
						mov		[edi].ADDIN.inx,eax
						add		edi,sizeof ADDIN
					.else
						invoke strcpy,addr LineTxt,addr OpenFileFail
						invoke strcat,addr LineTxt,addr FileName
						invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
					.endif
				.endif
			.endif
		.endif
		inc		nInx
	.endw
	ret

iniHook endp

DllHook proc hWin:HWND
	LOCAL	espsave:DWORD

	pushad
	mov		eax,1
	mov		edi,offset hAddins
	.while eax<=MAX_ADDIN
		push	eax
		mov		eax,[edi].ADDIN.hDLL
		.if eax
			invoke GetProcAddress,eax,offset szInstallDll
			.if !eax
				invoke GetProcAddress,[edi].ADDIN.hDLL,offset szInstallDllEx
				.if !eax
					invoke MessageBox,hWin,offset szInstallDll,offset AppName,MB_OK
				.else
					push	edi
					mov		espsave,esp
					push	[edi].ADDIN.hDLL
					push	[edi].ADDIN.fOpt
					push	hWin
					call	eax
					mov		esp,espsave
					pop		edi
					mov		ecx,[eax]
					mov		[edi].ADDIN.fhook1,ecx
					mov		ecx,[eax+4]
					mov		[edi].ADDIN.fhook2,ecx
					invoke GetProcAddress,[edi].ADDIN.hDLL,offset szDllProc
					mov		[edi].ADDIN.lpDllProc,eax
					.if !eax
						invoke MessageBox,hWin,offset szDllProc,offset AppName,MB_OK
					.endif
				.endif
			.else
				push	edi
				push	[edi].ADDIN.fOpt
				push	hWin
				call	eax
				pop		edi
				mov		[edi].ADDIN.fhook1,eax
				mov		[edi].ADDIN.fhook2,ecx
				invoke GetProcAddress,[edi].ADDIN.hDLL,offset szDllProc
				mov		[edi].ADDIN.lpDllProc,eax
				.if !eax
					invoke MessageBox,hWin,offset szDllProc,offset AppName,MB_OK
				.endif
			.endif
		.endif
		pop		eax
		add		edi,sizeof ADDIN
		inc		eax
	.endw
	invoke DllProc,hWnd,AIM_ADDINSLOADED,0,0,RAM_ADDINSLOADED
	popad
	ret

DllHook endp

DllProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM,fHookFun:DWORD
	LOCAL	nInx:DWORD
	LOCAL	espsave:DWORD

	mov		nInx,1
	mov		edi,offset hAddins
	xor		eax,eax
	.while nInx<=MAX_ADDIN && !eax
		.if dword ptr [edi].ADDIN.lpDllProc
			mov		edx,[edi].ADDIN.fhook1
			mov		ecx,uMsg
			.if ecx>WM_USER+128 && ecx<=WM_USER+128+32
				mov		edx,[edi].ADDIN.fhook2
			.endif
			and		edx,fHookFun
			.if edx
				push	edi
				mov		espsave,esp
				push	lParam
				push	wParam
				push	uMsg
				push	hWin
				call	[edi].ADDIN.lpDllProc
				mov		esp,espsave
				pop		edi
			.endif
		.endif
		add		edi,sizeof ADDIN
		inc		nInx
	.endw
	ret

DllProc endp

iniPathFix proc lpPth:DWORD

	invoke iniFixPath,lpPth,addr App,addr iniFolderA
	invoke iniFixPath,lpPth,addr Bin,addr iniFolderB
	invoke iniFixPath,lpPth,addr CurPro,addr iniFolderC
	invoke iniFixPath,lpPth,addr AddIn,addr iniFolderD
	invoke iniFixPath,lpPth,addr Dbg,addr iniFolderE
	invoke iniFixPath,lpPth,addr Hlp,addr iniFolderH
	invoke iniFixPath,lpPth,addr Incl,addr iniFolderI
	invoke iniFixPath,lpPth,addr Lib,addr iniFolderL
	invoke iniFixPath,lpPth,addr Mac,addr iniFolderM
	invoke iniFixPath,lpPth,addr Pro,addr iniFolderP
	invoke iniFixPath,lpPth,addr AppPath,addr iniFolderR
	invoke iniFixPath,lpPth,addr Snp,addr iniFolderS
	invoke iniFixPath,lpPth,addr Tpl,addr iniFolderT
	ret

iniPathFix endp

iniSetCodeBlocks proc uses ebx esi edi
	LOCAL	buffer[4]:BYTE

	mov		edi,offset rablkdef
	mov		esi,offset rablkdefstr
	invoke RtlZeroMemory,edi,sizeof rablkdef
	invoke RtlZeroMemory,esi,sizeof rablkdefstr
	xor		ebx,ebx
	.while ebx<MAXBLOCKDEF
		inc		ebx
		invoke BinToDec,ebx,addr buffer
		invoke GetPrivateProfileString,addr iniCodeBlock,addr buffer,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniAsmFile
	  .break .if !eax
		push	ebx
		xor		ebx,ebx
		.while ebx<5
			invoke iniGetItem,addr iniBuffer,esi
			.if byte ptr [esi]
				.if ebx==4
					invoke DecToBin,esi
					mov		[edi+ebx*4],eax
					invoke DecToBin,addr iniBuffer
					shl		eax,16
					or		[edi+ebx*4],eax
				.else
					invoke strlen,esi
					mov		[edi+ebx*4],esi
					mov		byte ptr [esi+eax+1],0
					lea		esi,[esi+eax+2]
				.endif
			.else
				mov		dword ptr [edi+ebx*4],0
			.endif
			inc		ebx
		.endw
		pop		ebx
		lea		edi,[edi+sizeof RABLOCKDEF]
	.endw
	ret

iniSetCodeBlocks endp

iniReadPaths proc uses edi,lpIni:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	nInx:DWORD

	.if lpIni
		invoke strcpy,addr iniAsmFile,addr AppPath
		invoke strcat,addr iniAsmFile,addr szBackSlash
		invoke strcat,addr iniAsmFile,lpIni
		invoke strcat,addr iniAsmFile,addr FTIni
	.endif
	invoke GetFileAttributes,addr iniAsmFile
	.if eax!=INVALID_HANDLE_VALUE
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderA,addr szNULL,addr App,128,addr iniAsmFile
		.if !eax
			invoke strcpy,addr App,addr AppPath
		.endif
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderB,addr szNULL,addr Bin,128,addr iniAsmFile
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderD,addr szNULL,addr AddIn,128,addr iniAsmFile
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderE,addr szNULL,addr Dbg,128,addr iniAsmFile
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderH,addr szNULL,addr Hlp,128,addr iniAsmFile
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderI,addr szNULL,addr Incl,128,addr iniAsmFile
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderL,addr szNULL,addr Lib,128,addr iniAsmFile
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderM,addr szNULL,addr Mac,128,addr iniAsmFile
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderP,addr szNULL,addr Pro,128,addr iniAsmFile
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderS,addr szNULL,addr Snp,128,addr iniAsmFile
		invoke GetPrivateProfileString,addr iniPaths,addr iniFolderT,addr szNULL,addr Tpl,128,addr iniAsmFile

		mov		eax,12
	  @@:
		push	eax
		invoke iniPathFix,addr App
		invoke iniPathFix,addr Bin
		invoke iniPathFix,addr CurPro
		invoke iniPathFix,addr AddIn
		invoke iniPathFix,addr Dbg
		invoke iniPathFix,addr Hlp
		invoke iniPathFix,addr Incl
		invoke iniPathFix,addr Lib
		invoke iniPathFix,addr Mac
		invoke iniPathFix,addr Pro
		invoke iniPathFix,addr Snp
		invoke iniPathFix,addr Tpl
		pop		eax
		dec		eax
		jne		@b
		;Open
		mov		nInx,0
		mov		edi,offset ALLFilterString
	  @@:
		invoke BinToDec,nInx,addr buffer
		invoke GetPrivateProfileString,addr iniOpen,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr iniAsmFile
		.if eax
			invoke iniGetItem,addr buffer,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			invoke iniGetItem,addr buffer,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			mov		byte ptr [edi],0
			inc		nInx
			jmp		@b
		.endif
		mov		dword ptr buffer,'crs'
		invoke GetPrivateProfileString,addr iniOpen,addr buffer,addr iniDefSrc,addr buffer,sizeof buffer,addr iniAsmFile
		.if eax
			mov		edi,offset SRCFilterString
			invoke iniGetItem,addr buffer,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			invoke iniGetItem,addr buffer,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			mov		byte ptr [edi],0
			mov		edi,offset DefSrcExt-1
			.while buffer
				mov		byte ptr [edi],'.'
				inc		edi
				invoke iniGetItem,addr buffer,edi
				invoke strlen,edi
				lea		edi,[edi+eax+1]
			.endw
			mov		byte ptr [edi],0
		.endif
		mov		dword ptr buffer,'rdh'
		invoke GetPrivateProfileString,addr iniOpen,addr buffer,addr iniDefHdr,addr buffer,sizeof buffer,addr iniAsmFile
		.if eax
			mov		edi,offset HDRFilterString
			invoke iniGetItem,addr buffer,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			invoke iniGetItem,addr buffer,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			mov		byte ptr [edi],0
			mov		edi,offset DefHdrExt-1
			.while buffer
				mov		byte ptr [edi],'.'
				inc		edi
				invoke iniGetItem,addr buffer,edi
				invoke strlen,edi
				lea		edi,[edi+eax+1]
			.endw
			mov		byte ptr [edi],0
		.endif
		mov		dword ptr buffer,'dom'
		invoke GetPrivateProfileString,addr iniOpen,addr buffer,addr iniDefMod,addr buffer,sizeof buffer,addr iniAsmFile
		.if eax
			mov		edi,offset MODFilterString
			invoke iniGetItem,addr buffer,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			invoke iniGetItem,addr buffer,edi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			mov		byte ptr [edi],0
			mov		edi,offset DefModExt-1
			.while buffer
				mov		byte ptr [edi],'.'
				inc		edi
				invoke iniGetItem,addr buffer,edi
				invoke strlen,edi
				lea		edi,[edi+eax+1]
			.endw
			mov		byte ptr [edi],0
		.endif
		;Edit
		;Comment char
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditCmntChar,addr szDefCmntChar,addr szCmntChar,sizeof szCmntChar,addr iniAsmFile
		;Comment block
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditCmntBlock,addr szNULL,addr iniBuffer,128,addr iniAsmFile
		invoke iniGetItem,addr iniBuffer,addr CmntBlockStart
		invoke iniGetItem,addr iniBuffer,addr CmntBlockEnd
		;Brace match
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditBraceMatch,addr szNULL,addr buffer,sizeof buffer,addr iniAsmFile
		invoke lstrlen,addr buffer
		mov		edx,dword ptr buffer[eax-3]
		.if edx=='}C{'
			mov		dword ptr buffer[eax-3],0Dh
		.endif
		invoke SendMessage,hOutREd,REM_BRACKETMATCH,0,addr buffer
		;Font
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditFont,addr szCNFont,addr lfntcode.lfFaceName,32,addr iniAsmFile
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditFontHeight,-12,addr iniAsmFile
		mov 	lfntcode.lfHeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditFontWeight,400,addr iniAsmFile
		mov 	lfntcode.lfWeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditFontItalic,0,addr iniAsmFile
		mov		lfntcode.lfItalic,al
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditFontCharSet,0,addr iniAsmFile
		mov 	lfntcode.lfCharSet,al
		;Text Font
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditTxtFont,addr szCNFont,addr lfnttxt.lfFaceName,32,addr iniAsmFile
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditTxtFontHeight,-12,addr iniAsmFile
		mov 	lfnttxt.lfHeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditTxtFontWeight,400,addr iniAsmFile
		mov 	lfnttxt.lfWeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditTxtFontItalic,0,addr iniAsmFile
		mov 	lfnttxt.lfItalic,al
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditTxtFontCharSet,0,addr iniAsmFile
		mov 	lfnttxt.lfCharSet,al
		;Hex Font
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditHexFont,addr szCNFont,addr lfnthex.lfFaceName,32,addr iniAsmFile
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditHexFontHeight,-12,addr iniAsmFile
		mov 	lfnthex.lfHeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditHexFontWeight,400,addr iniAsmFile
		mov 	lfnthex.lfWeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditHexFontItalic,0,addr iniAsmFile
		mov 	lfnthex.lfItalic,al
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditHexFontCharSet,0,addr iniAsmFile
		mov 	lfnthex.lfCharSet,al
		;Line number font
		invoke GetPrivateProfileString,addr iniEdit,addr iniLnrFont,addr iniDefLnrFont,addr lfntlnr.lfFaceName,32,addr iniAsmFile
		invoke GetPrivateProfileInt,addr iniEdit,addr iniLnrFontHeight,-8,addr iniAsmFile
		mov 	lfntlnr.lfHeight,eax
		;Dialog Edit Font
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditDlgFont,addr szLBFont,addr lfntdlg.lfFaceName,32,addr iniAsmFile
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditDlgFontHeight,-11,addr iniAsmFile
		mov 	lfntdlg.lfHeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditDlgFontWeight,400,addr iniAsmFile
		mov 	lfntdlg.lfWeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditDlgFontItalic,0,addr iniAsmFile
		mov 	lfntdlg.lfItalic,al
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditDlgFontCharSet,0,addr iniAsmFile
		mov 	lfntdlg.lfCharSet,al
		;Tool Font
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditToolFont,addr szLBFont,addr lfnttool.lfFaceName,32,addr iniAsmFile
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditToolFontHeight,-12,addr iniAsmFile
		mov 	lfnttool.lfHeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditToolFontWeight,400,addr iniAsmFile
		mov 	lfnttool.lfWeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditToolFontItalic,0,addr iniAsmFile
		mov 	lfnttool.lfItalic,al
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditToolFontCharSet,0,addr iniAsmFile
		mov 	lfnttool.lfCharSet,al
		;Printer Font
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditPrnFont,addr szCNFont,addr lfntprn.lfFaceName,32,addr iniAsmFile
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditPrnFontHeight,-12,addr iniAsmFile
		mov 	lfntprn.lfHeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditPrnFontWeight,400,addr iniAsmFile
		mov 	lfntprn.lfWeight,eax
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditPrnFontCharSet,0,addr iniAsmFile
		mov 	lfntprn.lfCharSet,al
		invoke GetPrnCaps
		.if eax
			mov		edx,offset iniDefPrnPageInch
		.else
			mov		edx,offset iniDefPrnPagemm
		.endif
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditPrnPage,edx,addr iniBuffer,128,addr iniAsmFile
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		psd.ptPaperSize.x,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		psd.ptPaperSize.y,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		psd.rtMargin.left,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		psd.rtMargin.top,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		psd.rtMargin.right,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		psd.rtMargin.bottom,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		prnOrientation,eax
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditPrnOption,addr iniDefPrnOption,addr iniBuffer,128,addr iniAsmFile
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PrnPageNumber,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PrnHeading,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PrnTime,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PrnProDes,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PrnUseColors,eax
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditPrnColor,addr iniDefPrnColor,addr buffer,sizeof buffer,addr iniAsmFile
		push	ebx
		mov		ecx,5+16
		mov		ebx,offset PrnColors
		.while ecx
			push	ecx
			invoke iniGetItem,addr buffer,addr iniBuffer
			invoke DecToBin,addr iniBuffer
			mov		[ebx],eax
			add		ebx,4
			pop		ecx
			dec		ecx
		.endw
		pop		ebx
		;TabSize
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditTabSize,4,addr iniAsmFile
		mov 	TabSize,eax
		;Backup
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditBackup,9,addr iniAsmFile
		mov 	Backup,eax
		;Auto Save
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditAutoSave,1,addr iniAsmFile
		and		eax,1
		mov 	AutoSave,eax
		;Threaded build
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditThreadBuild,1,addr iniAsmFile
		mov		make.fExecThread,eax
		;Change notify
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditChangeNotify,1,addr iniAsmFile
		mov		fChangeNotify,eax
		;Minimize on build
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditMinimize,0,addr iniAsmFile
		mov		fMinimize,eax
		;Auto Indent
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditAutoIndent,1,addr iniAsmFile
		and		eax,1
		mov 	AutoIndent,eax
		;Api List
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditApiList,1,addr iniAsmFile
		and		eax,1
		mov 	ShowApiList,eax
		;ApiConstants
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditApiConst,0,addr iniAsmFile
		and		eax,1
		mov 	ApiConst,eax
		;Api Struct
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditApiStruct,1,addr iniAsmFile
		and		eax,1
		mov 	ShowApiStruct,eax
		;Api Word Convert
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditApiWordConv,1,addr iniAsmFile
		and		eax,1
		mov 	ApiWordConv,eax
		;Api Word Local
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditApiWordLocal,1,addr iniAsmFile
		and		eax,1
		mov 	ApiWordLocal,eax
		;Api ToolTip
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditApiToolTip,1,addr iniAsmFile
		and		eax,1
		mov 	ShowApiToolTip,eax
		;Properties
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditProperties,1,addr iniAsmFile
		and		eax,1
		mov 	ShowProperties,eax
		;MouseWheel
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditMouseWheel,0,addr iniAsmFile
		and		eax,1
		mov 	MouseWheel,eax
		;Pos And Size
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditSaveSize,0,addr iniAsmFile
		and		eax,1
		mov 	SaveSize,eax
		;Maximize
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditMaximize,0,addr iniAsmFile
		and		eax,1
		mov 	EditMax,eax
		;CodeWriteMacro
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditCodeWrite,0,addr iniAsmFile
		and		eax,1
		mov		CodeWriteMacro,eax
		;TabToSpc
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditTabToSpc,0,addr iniAsmFile
		and		eax,1
		mov		TabToSpc,eax
		;Procs to api list
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditProcsToApi,1,addr iniAsmFile
		and		eax,1
		mov		fAutoRefresh,eax
		;Enter list on Tab
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditEnterOnTab,0,addr iniAsmFile
		and		eax,1
		mov		fEnterOnTab,eax
		;Proc in statusbar
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditProcInSBar,0,addr iniAsmFile
		and		eax,1
		mov		fProcInSBar,eax
		;Shift+Space
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditApiShiftSpace,1,addr iniAsmFile
		and		eax,1
		mov		ApiShiftSpace,eax
		;Code Files
		invoke GetPrivateProfileString,addr iniEdit,addr iniEditCodeFiles,addr iniDefCodeFiles,addr szCodeFiles,64,addr iniAsmFile
		;Linenumbers on open
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditLnrOnOpen,0,addr iniAsmFile
		and		eax,1
		mov		LnrOnOpen,eax
		;Page size
		invoke GetPrivateProfileInt,addr iniEdit,addr iniPageSize,66,addr iniAsmFile
		mov 	nPageSize,eax
		;Open Collapsed
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditOpenCollapsed,0,addr iniAsmFile
		mov 	fOpenCollapsed,eax
		;Auto brackets
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditAutoBrackets,1,addr iniAsmFile
		mov 	fAutoBrackets,eax
		;Hilite line
		invoke GetPrivateProfileInt,addr iniEdit,addr iniHiliteLine,0,addr iniAsmFile
		mov 	HiliteLine,eax
		;Hilite comment
		invoke GetPrivateProfileInt,addr iniEdit,addr iniHiliteCmnt,0,addr iniAsmFile
		mov 	HiliteCmnt,eax
		;Code tooltip
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditCodeTooltip,1,addr iniAsmFile
		mov 	fCodeTooltip,eax
		;Line spacing
		invoke GetPrivateProfileInt,addr iniEdit,addr iniEditLnSpc,0,addr iniAsmFile
		mov 	nLnSpc,eax
		;Error
		invoke GetPrivateProfileInt,addr iniError,addr iniErrBookMark,3,addr iniAsmFile
		mov		fErrBookMark,eax
		;Dialog
		;Grid
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogGrid,1,addr iniAsmFile
		and		eax,1
		mov 	fGrid,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogGridcx,3,addr iniAsmFile
		.if eax<2
			mov		eax,2
		.endif
		mov 	Gridcx,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogGridcy,3,addr iniAsmFile
		.if eax<2
			mov		eax,2
		.endif
		mov 	Gridcy,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogSnapToGrid,1,addr iniAsmFile
		and		eax,1
		mov 	fSnapToGrid,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogGridLine,0,addr iniAsmFile
		and		eax,1
		mov 	fGridLine,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogGridColor,0,addr iniAsmFile
		mov 	GridColor,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogShowSize,1,addr iniAsmFile
		and		eax,1
		mov 	fShowSizePos,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogSaveRC,1,addr iniAsmFile
		and		eax,1
		mov		fSaveRcFile,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogSimpleProperty,0,addr iniAsmFile
		and		eax,1
		mov		fSimpleProperty,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogLimittedFont,0,addr iniAsmFile
		and		eax,1
		mov		fLimittedFont,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogDlgID,1000,addr iniAsmFile
		mov		DlgIDN,eax
		invoke GetPrivateProfileInt,addr iniDialog,addr iniDialogCtrlID,1001,addr iniAsmFile
		mov		CtrlIDN,eax
		;Color
		invoke UpDateAssemblerIni
		invoke GetPrivateProfileInt,addr iniColor,addr iniUseColor,1,addr iniAsmFile
		and		eax,1
		mov 	fUseHighLight,eax
		invoke GetPrivateProfileInt,addr iniColor,addr iniUseDivLine,1,addr iniAsmFile
		and		eax,1
		mov 	fUseDivLine,eax
		invoke GetPrivateProfileInt,addr iniColor,addr iniNoFlicker,0,addr iniAsmFile
		and		eax,1
		mov 	fNoFlicker,eax
		mov		edi,offset iniColors
	  @@:
		mov		edx,[edi]
		mov		eax,[edi+4]
		add		edi,8
		push	edx
		invoke GetPrivateProfileInt,addr iniColor,edi,eax,addr iniAsmFile
		pop		edx
		mov		[edx],eax
		invoke strlen,edi
		add		edi,eax
		inc		edi
		mov		eax,[edi]
		or		eax,eax
		jne		@b
		mov		nInx,0
		mov		buffer,'C'
		.while nInx<16
			invoke BinToDec,nInx,addr buffer[1]
			invoke GetPrivateProfileInt,addr iniColor,addr buffer,16711680,addr iniAsmFile
			mov		edx,nInx
			mov 	radcol.keywords[edx*4],eax
			inc		nInx
		.endw
		;Syntax back colors
		mov		edi,offset backcol
		mov		eax,racol.cmntback
		mov		[edi+0*4],eax
		mov		eax,racol.strback
		mov		[edi+1*4],eax
		mov		eax,racol.numback
		mov		[edi+2*4],eax
		mov		eax,racol.oprback
		mov		[edi+3*4],eax
		mov		nInx,0
		mov		buffer,'B'
		.while nInx<16
			invoke BinToDec,nInx,addr buffer[1]
			invoke GetPrivateProfileInt,addr iniColor,addr buffer,00C0F0F0h,addr iniAsmFile
			mov		edx,nInx
			mov 	[edi+edx*4+4*4],eax
			inc		nInx
		.endw
		invoke GetPrivateProfileString,addr iniColor,addr iniCustColors,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniAsmFile
		mov		edi,offset CustColors
		xor		eax,eax
		.while eax<16
			push	eax
			invoke iniGetItem,addr iniBuffer,addr buffer
			invoke DecToBin,addr buffer
			mov		[edi],eax
			pop		eax
			add		edi,4
			inc		eax
		.endw
		mov		eax,FALSE
	.else
		invoke strcpy,addr LineTxt,addr OpenFileFail
		invoke strcat,addr LineTxt,addr iniAsmFile
		invoke strcat,addr LineTxt,addr LanguagePack
		invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

iniReadPaths endp

iniSetF1Help proc uses ebx

	mov		ebx,offset iniAsmFile
	invoke GetPrivateProfileString,addr iniKeyHelp,addr iniKeyHelpF1,addr szNULL,addr F1,255,ebx
	.if !eax
		mov		ebx,offset iniFile
	.endif
	;KeyHelp
	invoke GetPrivateProfileString,addr iniKeyHelp,addr iniKeyHelpF1,addr szNULL,addr F1,255,ebx
	invoke iniPathFix,addr F1
	invoke GetPrivateProfileString,addr iniKeyHelp,addr iniKeyHelpCF1,addr szNULL,addr CF1,255,ebx
	invoke iniPathFix,addr CF1
	invoke GetPrivateProfileString,addr iniKeyHelp,addr iniKeyHelpSF1,addr szNULL,addr SF1,255,ebx
	invoke iniPathFix,addr SF1
	invoke GetPrivateProfileString,addr iniKeyHelp,addr iniKeyHelpCSF1,addr szNULL,addr CSF1,255,ebx
	invoke iniPathFix,addr CSF1
	
	mov	ebx,offset iniFile
	Invoke GetPrivateProfileInt, Addr iniOnlineHelp, Addr iniDefaultProvider, 0, ebx
	mov OnlineHelpProvider, eax
	
	mov	ebx,offset iniFile
	Invoke GetPrivateProfileInt, Addr iniOnlineHelp, Addr iniF1OnlineHelp, 0, ebx
	mov OnlineHelpUseF1, eax
	
	ret

iniSetF1Help endp

iniRead proc
	LOCAL	buffer[256]:BYTE

	;Get ini path & add filename
	invoke iniGetAppPath,addr AppPath
	invoke strcpy,addr iniFile,addr AppPath
	invoke strcat,addr iniFile,addr iniFilename
	;Check if ini file exists
	invoke GetFileAttributes,addr iniFile
	.if eax!=-1
		invoke GetPrivateProfileString,addr iniWindow,addr iniFolderR,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniFile
		.if eax
			;Debug mode
			invoke strcpy,addr AppPath,addr iniBuffer
			invoke strcpy,addr iniFile,addr AppPath
			invoke strcat,addr iniFile,addr iniFilename
		.endif
		;Version
		invoke GetPrivateProfileInt,addr iniVersion,addr iniVersion,0,addr iniFile
		.if eax<2215
			push	ebx
			xor		ebx,ebx
			.while ebx<MAXTHEME
				mov		byte ptr prnbuff,0
				invoke BinToDec,ebx,addr buffer
				invoke GetPrivateProfileString,addr iniColor,addr buffer,addr szNULL,addr prnbuff,16384,addr iniFile
				.if byte ptr prnbuff
					mov		edx,offset prnbuff
					.while byte ptr [edx]!=','
						inc		edx
					.endw
					mov		ecx,offset iniBuffer
					.while TRUE
						mov		al,[edx]
						mov		[ecx],al
						inc		edx
						inc		ecx
						.break .if byte ptr [edx]==','
					.endw
					mov		byte ptr [ecx],0
					xor		ecx,ecx
					.while ecx<20
						push	ecx
						invoke strcat,addr prnbuff,addr iniBuffer
						pop		ecx
						inc		ecx
					.endw
					invoke WritePrivateProfileString,addr iniColor,addr buffer,addr prnbuff,addr iniFile
				.endif
				inc		ebx
			.endw
			pop		ebx
		.elseif eax<2220
			invoke WritePrivateProfileString,addr iniWindow,addr iniWinTool1,addr szTool1Update,addr iniFile
		.endif
		invoke BinToDec,nRadASMVer,addr iniBuffer
		invoke WritePrivateProfileString,addr iniVersion,addr iniVersion,addr iniBuffer,addr iniFile
		;Language
		invoke GetPrivateProfileString,addr iniWindow,addr szLanguage,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniFile
		.if eax
			invoke strcpy,addr lngFile,addr AppPath
			invoke strcat,addr lngFile,addr szLangPath
			invoke strcat,addr lngFile,addr iniBuffer
		.else
			mov		lngFile,0
		.endif
		;Window
		;Maximized
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinMaximized,0,addr iniFile
		and		eax,1
		mov 	winM,eax
		;Topmost
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinTopMost,0,addr iniFile
		and		eax,1
		mov 	winT,eax
		;SingleInstance
		invoke GetPrivateProfileInt,addr iniWindow,addr iniSingleInstance,0,addr iniFile
		and		eax,1
		mov		SingleInstance,eax
		;Position
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinTop,2,addr iniFile
		mov 	winY,eax
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinLeft,5,addr iniFile
		mov 	winX,eax
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinHeight,596,addr iniFile
		mov 	winHt,eax
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinWidth,790,addr iniFile
		mov 	winWt,eax
		;Toolbar
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinToolBar,1,addr iniFile
		and		eax,1
		mov 	winTbr,eax
		;Statusbar
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinStatusBar,1,addr iniFile
		and		eax,1
		mov 	winSbr,eax
		;Code complete list
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinCCList,addr iniDefCCList,addr iniBuffer,sizeof iniBuffer,addr iniFile
		invoke DecToBin,offset iniBuffer
		.if eax>600 || eax<100
			mov		eax,100
		.endif
		mov		apilbwt,eax
		invoke iniGetItem,offset iniBuffer,addr buffer
		invoke DecToBin,offset iniBuffer
		.if eax>600 || eax<100
			mov		eax,100
		.endif
		mov		apilbht,eax
		;Tool Windows
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinToolBox,addr iniDefTool,addr ToolBox,64,addr iniFile
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinProject,addr iniDefTool,addr Project,64,addr iniFile
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinOutput,addr iniDefTool,addr Output,64,addr iniFile
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinProperty,addr iniDefTool,addr Property,64,addr iniFile
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinTabTool,addr iniDefTool,addr TabTool,64,addr iniFile
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinInfoTool,addr iniDefTool,addr InfoTool,64,addr iniFile
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinTool1,addr iniDefTool,addr Tool1,64,addr iniFile
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinTool2,addr iniDefTool,addr Tool2,64,addr iniFile
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinClipping,addr iniDefClipping,addr Clipping,64,addr iniFile
		invoke strlen,addr Clipping
		.if eax==9
			mov		dword ptr Clipping[9],'7,6,'
			mov		dword ptr Clipping[13],'8,'
		.elseif eax!=15
			invoke strcpy,addr Clipping,addr iniDefClipping
		.endif
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinDivider,1,addr iniFile
		and		eax,1
		mov 	fDivider,eax
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinMultiLine,1,addr iniFile
		and		eax,1
		mov 	fMultiLine,eax
		invoke GetPrivateProfileInt,addr iniWindow,addr iniWinRightCaption,1,addr iniFile
		and		eax,1
		mov 	fRightCaption,eax
		invoke GetPrivateProfileInt,addr iniWindow,addr iniAutoLoad,1,addr iniFile
		mov		fAutoLoadPro,eax
		;Dialog font
		invoke GetPrivateProfileString,addr iniWindow,addr iniEditFont,offset szNULL,offset iniBuffer,sizeof iniBuffer,offset iniFile
		.if eax
			invoke iniGetItem,addr iniBuffer,addr lfntide.lfFaceName
			invoke DecToBin,offset iniBuffer
			mov		lfntide.lfHeight,eax
			invoke iniGetItem,offset iniBuffer,addr buffer
			invoke DecToBin,offset iniBuffer
			mov		lfntide.lfItalic,al
			invoke iniGetItem,offset iniBuffer,addr buffer
			invoke DecToBin,offset iniBuffer
			mov		lfntide.lfWeight,eax
			invoke iniGetItem,offset iniBuffer,addr buffer
			invoke DecToBin,offset iniBuffer
			mov		lfntide.lfCharSet,al
		.else
			invoke strcpy,addr lfntide.lfFaceName,addr szLBFont
			mov		lfntide.lfHeight,-11
			mov		lfntide.lfWeight,400
			mov		lfntide.lfCharSet,0
		.endif
		;Dialog magnify
		invoke GetPrivateProfileInt,addr iniWindow,addr iniMagnify,32,offset iniFile
		mov		nLngSize,eax
		;Find
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinFind,addr iniDefLoc,addr iniBuffer,64,addr iniFile
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PosFindLeft,eax
		invoke DecToBin,addr iniBuffer
		mov		PosFindTop,eax
		;Goto
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinGoto,addr iniDefLoc,addr iniBuffer,64,addr iniFile
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PosGotoLeft,eax
		invoke DecToBin,addr iniBuffer
		mov		PosGotoTop,eax
		;Project wizard
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinProWiz,addr iniDefLoc,addr iniBuffer,64,addr iniFile
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PosProWizLeft,eax
		invoke DecToBin,addr iniBuffer
		mov		PosProWizTop,eax
		invoke GetPrivateProfileString,addr iniAccept,addr iniAccept,addr szNULL,addr szaccept,sizeof szaccept,addr iniFile
		;Project options
		invoke GetPrivateProfileString,addr iniWindow,addr iniWinProOpt,addr iniDefProOpt,addr iniBuffer,64,addr iniFile
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PosProOptLeft,eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		PosProOptTop,eax
		invoke DecToBin,addr iniBuffer
		mov		PosProOptWt,eax
		;Splash screen
		invoke GetPrivateProfileString,addr iniSplash,addr iniSplashBmp,addr szNULL,addr SplashBmp,256,addr iniFile
		invoke iniPathFix,addr SplashBmp
		invoke GetPrivateProfileInt,addr iniSplash,addr iniSplashnShow,0,addr iniFile
		shl		eax,1
		mov		Splashtc,eax
		;Sniplet
		invoke GetPrivateProfileInt,addr iniSniplet,addr iniSnipletSelAll,1,addr iniFile
		mov		fSelectAll,eax
		invoke GetPrivateProfileInt,addr iniSniplet,addr iniSnipletCopyTo,2,addr iniFile
		mov		nCopyTo,eax
		invoke GetPrivateProfileInt,addr iniSniplet,addr iniSnipletClose,0,addr iniFile
		mov		fClose,eax
		invoke GetPrivateProfileInt,addr iniSniplet,addr iniSnipletExpanded,1,addr iniFile
		mov		fExpanded,eax
		invoke GetPrivateProfileInt,addr iniSniplet,addr iniWinLeft,30,addr iniFile
		mov		SnipLeft,eax
		invoke GetPrivateProfileInt,addr iniSniplet,addr iniWinTop,30,addr iniFile
		mov		SnipTop,eax
		invoke GetPrivateProfileInt,addr iniSniplet,addr iniWinWidth,540,addr iniFile
		mov		SnipWidth,eax
		invoke GetPrivateProfileInt,addr iniSniplet,addr iniWinHeight,360,addr iniFile
		mov		SnipHeight,eax
		invoke GetPrivateProfileInt,addr iniSniplet,addr iniSnipletSplit,150,addr iniFile
		mov		SnipSplit,eax
		;Template
		invoke GetPrivateProfileString,addr iniTemplate,addr iniTemplateTxt,addr szNULL,addr szFTTxt,256,addr iniFile
		invoke GetPrivateProfileString,addr iniTemplate,addr iniTemplateBin,addr szNULL,addr szFTBin,256,addr iniFile
		invoke GetPrivateProfileString,addr iniAssembler,addr iniAssembler,addr szNULL,addr iniBuffer,128,addr iniFile
		.while iniBuffer
			invoke iniGetItem,addr iniBuffer,addr buffer
			;Paths
			invoke iniReadPaths,addr buffer
			.if !eax
				;File browser
				invoke GetPrivateProfileString,offset iniFileBrowser,offset iniFileBrowserFilter,offset szNULL,offset FileFilter,sizeof FileFilter,offset iniFile
				mov		byte ptr nFileBrowser,'0'
				push	edi
				mov		edi,offset FilePaths
				.while byte ptr nFileBrowser<='9'
					invoke GetPrivateProfileString,offset iniFileBrowser,offset nFileBrowser,offset szNULL,edi,sizeof FilePath,offset iniFile
					.if !eax && byte ptr nFileBrowser=='0'
						invoke strcpy,edi,offset Pro
					.endif
					invoke iniPathFix,edi
					add		edi,MAX_PATH
					inc		byte ptr nFileBrowser
				.endw
				mov		byte ptr nFileBrowser,'0'
				invoke strcpy,offset FilePath,offset FilePaths
				pop		edi
				mov		eax,FALSE
				ret
			.endif
		.endw
		invoke MessageBox,NULL,addr NoLanguagePack,addr AppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
		ret
	.endif
	invoke strcpy,addr LineTxt,addr OpenFileFail
	invoke strcat,addr LineTxt,addr iniFile
	invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
	mov		eax,TRUE
	ret

iniRead endp

iniSetAsmMenu proc uses esi
	LOCAL	buffer[256]:BYTE
	LOCAL	nID:DWORD

	invoke GetPrivateProfileString,addr iniAssembler,addr iniAssembler,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniFile
	xor		eax,eax
	inc		eax
	.while eax
		invoke DeleteMenu,hMnuAsm,0,MF_BYPOSITION
	.endw
	mov		nID,23000
	xor		eax,eax
	.while TRUE
		invoke iniGetItem,addr iniBuffer,addr buffer
		.break .if !buffer
		invoke AppendMenu,hMnuAsm,MF_STRING,nID,addr buffer
		inc		nID
	.endw
	ret

iniSetAsmMenu endp

iniDestroySubMenu proc uses esi edi

	mov		esi,offset MenuData
	mov		edi,esi
	add		edi,sizeof MenuData
	.while esi<edi
		mov		eax,[esi].MENU.hSub
		.if eax
			invoke DestroyMenu,eax
			mov		[esi].MENU.hSub,0
		.endif
		add		esi,sizeof MENU
	.endw
	ret

iniDestroySubMenu endp

iniMenu proc uses edi,lpIniKey:DWORD,lpIni:DWORD,mid:DWORD,lpnAccel:DWORD,lpAccel:DWORD,nMax:DWORD
	LOCAL	iMnu:DWORD
	LOCAL	buffer[MAX_PATH+64]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	buffer3[16]:BYTE
	LOCAL	buffer4[64]:BYTE
	LOCAL	hMnu:DWORD
	LOCAL	hSub:DWORD
	LOCAL	nSCut:DWORD
	LOCAL	nVer:DWORD

	invoke SendMessage,hClient,WM_MDIGETACTIVE,0,addr fMaximized
	mov		iMnu,1
	mov		hSub,0
	invoke GetPrivateProfileInt,lpIniKey,addr iniVer,0,lpIni
	mov		nVer,eax
	.if !eax
		mov		dword ptr buffer,'001'
		invoke WritePrivateProfileString,lpIniKey,addr iniVer,addr buffer,lpIni
	.endif
  @@:
	mov		eax,iMnu
	cmp		eax,nMax
	jg		@f
	invoke BinToDec,iMnu,addr buffer
	invoke GetPrivateProfileString,lpIniKey,addr buffer,addr szNULL,addr buffer,sizeof buffer,lpIni
	.if eax
		mov		eax,mid
		.if fMaximized
			inc		eax
		.endif

		invoke GetSubMenu,hMenu,eax
		mov		hMnu,eax
		mov		al,buffer[0]
		.if al=='-'
			invoke AppendMenu,hMnu,MF_SEPARATOR,0,0
		.else
			mov		nSCut,0
			;Menu text
			invoke iniGetItem,addr buffer,addr buffer2
			;Shortcut
			invoke iniGetItem,addr buffer,addr buffer3
			mov		al,buffer3
			.if al>='0' && al<='9'
				invoke DecToBin,addr buffer3
				.if eax
					.if !nVer
						invoke ConvertShortcut,eax
						push	eax
						mov		edx,eax
						invoke BinToDec,edx,addr buffer3
						invoke BinToDec,iMnu,addr buffer4
						invoke strcpy,offset tempbuff,addr buffer2
						invoke strcat,offset tempbuff,addr szComma
						invoke strcat,offset tempbuff,addr buffer3
						invoke strcat,offset tempbuff,addr szComma
						invoke strcat,offset tempbuff,addr buffer
						invoke WritePrivateProfileString,lpIniKey,addr buffer4,offset tempbuff,lpIni
						pop		eax
					.endif
					mov		nSCut,eax
					invoke strlen,addr buffer2
					lea		edi,buffer2[eax]
					mov		al,09h
					stosb
					invoke GetAccelString,nSCut,edi
					mov		edx,lpnAccel
					mov		eax,[edx]
					mov		edx,sizeof tagACCEL
					mul		edx
					mov		edi,lpAccel
					add		edi,eax
					mov		eax,nSCut
					movzx	edx,ah
					xor		ah,ah
					shl		edx,2
					or		edx,FVIRTKEY or FNOINVERT
					mov		(tagACCEL ptr [edi]).fVirt,dl
					mov		(tagACCEL ptr [edi]).key,ax
					mov		eax,MenuID
					mov		(tagACCEL ptr [edi]).cmd,ax
					mov		edx,lpnAccel
					inc		dword ptr [edx]
				.endif
				invoke iniGetItem,addr buffer,addr buffer3
			.endif
			invoke strlen,addr buffer2
			.if word ptr buffer2=='..'
				.if !hSub
					mov		edx,MenuID
					dec		edx
					invoke GetMenuString,hMnu,edx,addr buffer4,sizeof buffer4,MF_BYCOMMAND
					invoke CreatePopupMenu
					mov		hSub,eax
					mov		edx,MenuPtr
					mov		(MENU ptr [edx]).hSub,eax
					mov		edx,MenuID
					dec		edx
					invoke ModifyMenu,hMnu,edx,MF_BYCOMMAND or MF_POPUP,hSub,addr buffer4
				.endif
				invoke AppendMenu,hSub,MF_STRING,MenuID,addr buffer2[2]
			.elseif word ptr buffer2=='$$'
				mov		hSub,0
			.else
				invoke AppendMenu,hMnu,MF_STRING,MenuID,addr buffer2
				mov		hSub,0
			.endif
			mov		edx,MenuPtr
			mov		al,buffer3[0]
			mov		(MENU ptr [edx]).param,al
			mov		eax,nSCut
			mov		(MENU ptr [edx]).scut,eax
			mov		eax,MenuID
			mov		(MENU ptr [edx]).mnuid,eax
			invoke iniPathFix,addr buffer
			mov		edx,MenuPtr
			invoke strcpy,addr (MENU ptr [edx]).cmnd,addr buffer
			inc		MenuID
			add		MenuPtr,sizeof MENU
		.endif
		inc		iMnu
		jmp		@b
	.endif
  @@:
	ret

iniMenu endp

SetupMenus proc uses edi,hWin:HWND
	LOCAL	mii:MENUITEMINFO

	;Menu
	invoke LoadMenu,hInstance,IDR_MDIMENU
	mov		hMenu,eax
	invoke DeleteMenu,hMenu,45000,MF_BYCOMMAND
	;Tool menu
	invoke LoadMenu,hInstance,IDR_PROMENU
	mov		hToolMenu,eax
	;Dialog edit
	invoke GetSubMenu,hToolMenu,2
	mov		hMnuDlg,eax

	;Prepare mii
	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_SUBMENU
	;Recent files
	invoke GetMenuItemInfo,hMenu,IDM_FILE_RECENT,FALSE,addr mii
	mov		eax,mii.hSubMenu
	mov		hMnuRecent,eax
	;Set assembler
	invoke GetMenuItemInfo,hMenu,IDM_PROJECT_SET_ASSEMBLER,FALSE,addr mii
	mov		eax,mii.hSubMenu
	mov		hMnuAsm,eax
	;Mdi
	invoke GetSubMenu,hMenu,MENUWINDOW
	invoke SendMessage,hClient,WM_MDISETMENU,hMenu,eax
	invoke SendMessage,hClient,WM_MDIREFRESHMENU,0,0
	invoke UpdateMenu,hToolMenu,998
	invoke UpdateMenu,hMenu,999
	invoke DrawMenuBar,hWnd
	ret

SetupMenus endp

UpdateAccelOption proc uses ebx esi edi,hMnu:DWORD
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[128]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	mii:MENUITEMINFO
	LOCAL	nAccel:DWORD
	LOCAL	hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,8192
	mov		hMem,eax
	invoke CopyAcceleratorTable,hAccel,NULL,0
	mov		nAccel,eax
	invoke CopyAcceleratorTable,hAccel,hMem,nAccel
	invoke DestroyAcceleratorTable,hAccel
	mov		nInx,1
  @@:
	invoke BinToDec,nInx,addr buffer
	invoke GetPrivateProfileString,addr iniAccel,addr buffer,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniFile
	.if eax
		invoke iniGetItem,addr iniBuffer,addr buffer
		invoke DecToBin,addr buffer
		mov		ebx,hMem
		mov		ecx,nAccel
		inc		ecx
		.while ecx
			.if ax==[ebx].tagACCEL.cmd || ![ebx].tagACCEL.cmd
				.if ![ebx].tagACCEL.cmd
					mov		[ebx].tagACCEL.cmd,ax
					inc		nAccel
				.endif
				;Caption
				invoke iniGetItem,addr iniBuffer,addr buffer1
				invoke iniGetItem,addr iniBuffer,addr buffer
				invoke DecToBin,addr buffer
				mov		[ebx].tagACCEL.key,ax
				invoke DecToBin,addr iniBuffer
				or		al,FVIRTKEY or FNOINVERT
				mov		[ebx].tagACCEL.fVirt,al
				mov		esi,offset iniBuffer
				invoke strcpy,esi,addr buffer1
				invoke strlen,esi
				lea		esi,[esi+eax]
				call GetKeyStr
				movzx	edx,[ebx].tagACCEL.cmd
				mov		mii.cbSize,sizeof mii
				mov		mii.fMask,MIIM_TYPE or MIIM_DATA
				mov		mii.dwTypeData,offset iniBuffer
				mov		mii.cch,sizeof iniBuffer
				mov		mii.fType,MFT_STRING
				mov		mii.dwItemData,0
				invoke SetMenuItemInfo,hMnu,edx,FALSE,addr mii
				.break
			.endif
			add		ebx,sizeof tagACCEL
			dec		ecx
		.endw
		inc		nInx
		jmp		@b
	.endif
	mov		esi,hMem
	mov		iniBuffer,0
	.while [esi].tagACCEL.cmd
		mov		edi,esi
		add		edi,sizeof tagACCEL
		.while [edi].tagACCEL.cmd
			movzx	eax,[esi].tagACCEL.key
			movzx	ecx,[esi].tagACCEL.fVirt
			.if ax==[edi].tagACCEL.key && cl==[edi].tagACCEL.fVirt
				push	esi
				push	edi
				mov		ebx,esi
				lea		esi,buffer
				call	GetKeyStr
				invoke strcat,addr iniBuffer,addr buffer[1]
				invoke strcat,addr iniBuffer,addr szCrLf
				pop		edi
				pop		esi
			.endif
			add		edi,sizeof tagACCEL
		.endw
		add		esi,sizeof tagACCEL
	.endw
	invoke CreateAcceleratorTable,hMem,nAccel
	mov		hAccel,eax
	invoke GlobalFree,hMem
	ret

GetKeyStr:
	movzx	eax,[ebx].tagACCEL.key
	.if eax
		mov		byte ptr [esi],VK_TAB
		inc		esi
		movzx	eax,[ebx].tagACCEL.fVirt
		test	eax,FALT
		.if !ZERO?
			push	eax
			invoke strcpy,esi,offset szAlt
			invoke strlen,esi
			lea		esi,[esi+eax]
			pop		eax
		.endif
		test	eax,FCONTROL
		.if !ZERO?
			push	eax
			invoke strcpy,esi,offset szCtrl
			invoke strlen,esi
			lea		esi,[esi+eax]
			pop		eax
		.endif
		test	eax,FSHIFT
		.if !ZERO?
			push	eax
			invoke strcpy,esi,offset szShift
			invoke strlen,esi
			lea		esi,[esi+eax]
			pop		eax
		.endif
		movzx	eax,[ebx].tagACCEL.key
		mov		edi,offset szAclKeys
		.while byte ptr [edi+1]
			.if al==[edi]
				.break
			.endif
			inc		edi
			push	eax
			invoke strlen,edi
			lea		edi,[edi+eax+1]
			pop		eax
		.endw
		inc		edi
		invoke strcpy,esi,edi
	.endif
	retn

UpdateAccelOption endp

iniAddMenu proc uses ebx esi edi
	LOCAL	hMnu:DWORD
	LOCAL	nAccel:DWORD
	LOCAL	buffer[128]:BYTE
	LOCAL	hMem:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,8192
	mov		hMem,eax
	invoke iniDestroySubMenu
	.if hAccel
		invoke DestroyAcceleratorTable,hAccel
	.endif
	invoke LoadAccelerators,hInstance,IDR_MAINACCEL
	mov		hAccel,eax
	invoke CopyAcceleratorTable,hAccel,NULL,0
	mov		nAccel,eax
	invoke CopyAcceleratorTable,hAccel,hMem,nAccel
	invoke DestroyAcceleratorTable,hAccel

	invoke RtlZeroMemory,addr MenuData,sizeof MenuData
	mov		MenuID,20001
	.while MenuID<20128
		invoke DeleteMenu,hMenu,MenuID,MF_BYCOMMAND
		inc MenuID
	.endw
	.if fMaximized
		invoke GetSubMenu,hMenu,MENUMAKE+1
	.else
		invoke GetSubMenu,hMenu,MENUMAKE
	.endif
	mov		hMnu,eax
	mov		MenuID,0
	.while MenuID<128
		invoke DeleteMenu,hMnu,0,MF_BYPOSITION
		inc MenuID
	.endw
	.if fMaximized
		invoke GetSubMenu,hMenu,MENUTOOL+1
	.else
		invoke GetSubMenu,hMenu,MENUTOOL
	.endif
	mov		hMnu,eax
	mov		MenuID,0
	.while MenuID<128
		invoke DeleteMenu,hMnu,3,MF_BYPOSITION
		inc MenuID
	.endw
	.if fMaximized
		invoke GetSubMenu,hMenu,MENUMACRO+1
	.else
		invoke GetSubMenu,hMenu,MENUMACRO
	.endif
	mov		hMnu,eax
	mov		MenuID,0
	.while MenuID<128
		invoke DeleteMenu,hMnu,3,MF_BYPOSITION
		inc MenuID
	.endw
	.if fMaximized
		invoke GetSubMenu,hMenu,MENUHELP+1
	.else
		invoke GetSubMenu,hMenu,MENUHELP
	.endif
	mov		hMnu,eax
	mov		MenuID,0
	.while MenuID<128
		invoke DeleteMenu,hMnu,2,MF_BYPOSITION
		inc MenuID
	.endw
	mov		MenuPtr,offset MenuData
	mov		MenuID,20001
	invoke iniMenu,addr iniMenuMake,addr iniAsmFile,MENUMAKE,addr nAccel,hMem,64
	push	MenuID
	mov		dword ptr buffer,'nuoc'
	mov		dword ptr buffer[4],'t'
	invoke GetPrivateProfileInt,addr iniMRUPro,addr buffer,4,addr iniFile
	.if eax>9
		mov		eax,9
	.endif
	invoke iniMenu,addr iniMRUPro,addr iniFile,MENUFILE,addr nAccel,hMem,eax
	pop		eax
	mov		ProMenuID,0
	.if eax!=MenuID
		mov		ProMenuID,eax
	.endif
	mov		eax,MenuID
	mov		UserBtnID,eax
	mov		dword ptr buffer,'1'
	invoke GetPrivateProfileString,addr iniMenuTool,addr buffer,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniAsmFile
	.if eax
		mov		edx,offset iniAsmFile
	.else
		mov		edx,offset iniFile
	.endif
	invoke iniMenu,addr iniMenuTool,edx,MENUTOOL,addr nAccel,hMem,64
	invoke iniMenu,addr iniMenuMacro,addr iniAsmFile,MENUMACRO,addr nAccel,hMem,64
	invoke GetPrivateProfileString,addr iniMenuHelp,addr buffer,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniAsmFile
	.if eax
		mov		edx,offset iniAsmFile
	.else
		mov		edx,offset iniFile
	.endif
	invoke iniMenu,addr iniMenuHelp,edx,MENUHELP,addr nAccel,hMem,64
	
	; Insert sep and online search menu item here, set id to 127
	
	invoke CreateAcceleratorTable,hMem,nAccel
	mov		hAccel,eax
	invoke GlobalFree,hMem
	invoke UpdateAccelOption,hMenu
	invoke DllProc,hMenu,AIM_MENUREBUILD,0,0,RAM_MENUREBUILD
	ret

iniAddMenu endp

iniDisMenu proc uses esi
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE

	invoke GetPrivateProfileString,addr iniMakeDefNoPro,addr iniMenuMake,addr szNULL,addr buffer,64,addr iniAsmFile
	mov		esi,offset MenuData
  @@:
	mov		al,(MENU ptr [esi]).param
	.if al=='M'
		push	eax
		invoke iniGetItem,addr buffer,addr buffer1
		mov		al,buffer1
		.if al=='1'
			invoke EnableMenuItem,hMenu,(MENU ptr [esi]).mnuid,MF_BYCOMMAND	or MF_ENABLED
			invoke SendMessage,hToolBar,TB_ENABLEBUTTON,(MENU ptr [esi]).mnuid,TRUE
		.else
			invoke EnableMenuItem,hMenu,(MENU ptr [esi]).mnuid,MF_BYCOMMAND	or MF_GRAYED
			invoke SendMessage,hToolBar,TB_ENABLEBUTTON,(MENU ptr [esi]).mnuid,FALSE
		.endif
		pop		eax
	.endif
	add		esi,size MENU
	or		al,al
	jne		@b
	ret

iniDisMenu endp

iniWinSaveFont proc

	invoke strcpy,addr iniBuffer,addr lfntide.lfFaceName
	invoke strcat,addr iniBuffer,addr szComma
	mov		edx,lfntide.lfHeight
	invoke iniPutItem,edx,addr iniBuffer,TRUE
	movzx	edx,lfntide.lfItalic
	invoke iniPutItem,edx,addr iniBuffer,TRUE
	mov		edx,lfntide.lfWeight
	invoke iniPutItem,edx,addr iniBuffer,TRUE
	movzx	edx,lfntide.lfCharSet
	invoke iniPutItem,edx,addr iniBuffer,FALSE
	invoke WritePrivateProfileString,addr iniWindow,addr iniEditFont,addr iniBuffer,addr iniFile
	invoke BinToDec,nLngSize,addr iniBuffer
	invoke WritePrivateProfileString,addr iniWindow,addr iniMagnify,addr iniBuffer,addr iniFile
	ret

iniWinSaveFont endp

iniWinSavePos proc
	LOCAL	Rct:RECT

	invoke IsZoomed,hWnd
	mov 	winM,eax
	.if !eax
		invoke IsIconic,hWnd
		.if !eax
			invoke GetWindowRect,hWnd,addr Rct
			m2m 	winX,Rct.left
			m2m 	winY,Rct.top
			mov 	eax,Rct.right
			sub 	eax,winX
			mov 	winWt,eax
			mov 	eax,Rct.bottom
			sub 	eax,winY
			mov 	winHt,eax
			invoke BinToDec,winY,addr iniBuffer
			invoke WritePrivateProfileString,addr iniWindow,addr iniWinTop,addr iniBuffer,addr iniFile
			invoke BinToDec,winX,addr iniBuffer
			invoke WritePrivateProfileString,addr iniWindow,addr iniWinLeft,addr iniBuffer,addr iniFile
			invoke BinToDec,winHt,addr iniBuffer
			invoke WritePrivateProfileString,addr iniWindow,addr iniWinHeight,addr iniBuffer,addr iniFile
			invoke BinToDec,winWt,addr iniBuffer
			invoke WritePrivateProfileString,addr iniWindow,addr iniWinWidth,addr iniBuffer,addr iniFile
		.endif
	.endif
	invoke BinToDec,winT,addr iniBuffer
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinTopMost,addr iniBuffer,addr iniFile
	invoke BinToDec,winTbr,addr iniBuffer
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinToolBar,addr iniBuffer,addr iniFile
	invoke BinToDec,winSbr,addr iniBuffer
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinStatusBar,addr iniBuffer,addr iniFile
	invoke BinToDec,winM,addr iniBuffer
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinMaximized,addr iniBuffer,addr iniFile
	;Sniplet
	invoke BinToDec,SnipLeft,addr iniBuffer
	invoke WritePrivateProfileString,addr iniSniplet,addr iniWinLeft,addr iniBuffer,addr iniFile
	invoke BinToDec,SnipTop,addr iniBuffer
	invoke WritePrivateProfileString,addr iniSniplet,addr iniWinTop,addr iniBuffer,addr iniFile
	invoke BinToDec,SnipWidth,addr iniBuffer
	invoke WritePrivateProfileString,addr iniSniplet,addr iniWinWidth,addr iniBuffer,addr iniFile
	invoke BinToDec,SnipHeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniSniplet,addr iniWinHeight,addr iniBuffer,addr iniFile
	invoke BinToDec,SnipSplit,addr iniBuffer
	invoke WritePrivateProfileString,addr iniSniplet,addr iniSnipletSplit,addr iniBuffer,addr iniFile
	;Tool windows
	invoke iniToolSave,hTlb,addr iniWinToolBox
	invoke iniToolSave,hPbr,addr iniWinProject
	invoke iniToolSave,hOut,addr iniWinOutput
	invoke iniToolSave,hPrp,addr iniWinProperty
	invoke iniToolSave,hTab,addr iniWinTabTool
	invoke iniToolSave,hInf,addr iniWinInfoTool
	invoke iniToolSave,hTl1,addr iniWinTool1
	invoke iniToolSave,hTl2,addr iniWinTool2
	mov		eax,fRightCaption
	or		al,30h
	mov		dword ptr iniBuffer,eax
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinRightCaption,addr iniBuffer,addr iniFile
	mov		eax,fDivider
	or		al,30h
	mov		dword ptr iniBuffer,eax
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinDivider,addr iniBuffer,addr iniFile
	mov		eax,fMultiLine
	or		al,30h
	mov		dword ptr iniBuffer,eax
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinMultiLine,addr iniBuffer,addr iniFile
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinClipping,addr Clipping,addr iniFile
	;Find
	mov		iniBuffer,0
	invoke iniPutItem,PosFindLeft,addr iniBuffer,TRUE
	invoke iniPutItem,PosFindTop,addr iniBuffer,FALSE
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinFind,addr iniBuffer,addr iniFile
	;Goto
	mov		iniBuffer,0
	invoke iniPutItem,PosGotoLeft,addr iniBuffer,TRUE
	invoke iniPutItem,PosGotoTop,addr iniBuffer,FALSE
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinGoto,addr iniBuffer,addr iniFile
	;Project wizard
	mov		iniBuffer,0
	invoke iniPutItem,PosProWizLeft,addr iniBuffer,TRUE
	invoke iniPutItem,PosProWizTop,addr iniBuffer,FALSE
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinProWiz,addr iniBuffer,addr iniFile
	;Project options
	mov		iniBuffer,0
	invoke iniPutItem,PosProOptLeft,addr iniBuffer,TRUE
	invoke iniPutItem,PosProOptTop,addr iniBuffer,TRUE
	invoke iniPutItem,PosProOptWt,addr iniBuffer,FALSE
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinProOpt,addr iniBuffer,addr iniFile
	;Code complete list
	mov		iniBuffer,0
	invoke iniPutItem,apilbwt,addr iniBuffer,TRUE
	invoke iniPutItem,apilbht,addr iniBuffer,FALSE
	invoke WritePrivateProfileString,addr iniWindow,addr iniWinCCList,addr iniBuffer,addr iniFile
	ret

iniWinSavePos endp

iniSnipletSave proc

	invoke BinToDec,fSelectAll,addr iniBuffer
	invoke WritePrivateProfileString,addr iniSniplet,addr iniSnipletSelAll,addr iniBuffer,addr iniFile
	invoke BinToDec,nCopyTo,addr iniBuffer
	invoke WritePrivateProfileString,addr iniSniplet,addr iniSnipletCopyTo,addr iniBuffer,addr iniFile
	invoke BinToDec,fClose,addr iniBuffer
	invoke WritePrivateProfileString,addr iniSniplet,addr iniSnipletClose,addr iniBuffer,addr iniFile
	invoke BinToDec,fExpanded,addr iniBuffer
	invoke WritePrivateProfileString,addr iniSniplet,addr iniSnipletExpanded,addr iniBuffer,addr iniFile
	ret

iniSnipletSave endp

iniEditSave proc
	LOCAL buffer[1024]:BYTE

	;Code font
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditFont,addr lfntcode.lfFaceName,addr iniAsmFile
	invoke BinToDec,lfntcode.lfHeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditFontHeight,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,lfntcode.lfWeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditFontWeight,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfntcode.lfItalic
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditFontItalic,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfntcode.lfCharSet
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditFontCharSet,addr iniBuffer,addr iniAsmFile
	;Text font
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditTxtFont,addr lfnttxt.lfFaceName,addr iniAsmFile
	invoke BinToDec,lfnttxt.lfHeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditTxtFontHeight,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,lfnttxt.lfWeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditTxtFontWeight,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfnttxt.lfItalic
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditTxtFontItalic,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfnttxt.lfCharSet
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditTxtFontCharSet,addr iniBuffer,addr iniAsmFile
	;Hex font
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditHexFont,addr lfnthex.lfFaceName,addr iniAsmFile
	invoke BinToDec,lfnthex.lfHeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditHexFontHeight,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,lfnthex.lfWeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditHexFontWeight,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfnthex.lfItalic
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditHexFontItalic,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfnthex.lfCharSet
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditHexFontCharSet,addr iniBuffer,addr iniAsmFile
	;Linenumber font
	invoke WritePrivateProfileString,addr iniEdit,addr iniLnrFont,addr lfntlnr.lfFaceName,addr iniAsmFile
	invoke BinToDec,lfntlnr.lfHeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniLnrFontHeight,addr iniBuffer,addr iniAsmFile
	;Dialog edit font
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditDlgFont,addr lfntdlg.lfFaceName,addr iniAsmFile
	invoke BinToDec,lfntdlg.lfHeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditDlgFontHeight,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,lfntdlg.lfWeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditDlgFontWeight,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfntdlg.lfItalic
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditDlgFontItalic,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfntdlg.lfCharSet
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditDlgFontCharSet,addr iniBuffer,addr iniAsmFile
	;Tool font
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditToolFont,addr lfnttool.lfFaceName,addr iniAsmFile
	invoke BinToDec,lfnttool.lfHeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditToolFontHeight,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,lfnttool.lfWeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditToolFontWeight,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfnttool.lfItalic
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditToolFontItalic,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfnttxt.lfCharSet
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditToolFontCharSet,addr iniBuffer,addr iniAsmFile
	;Printer font
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditPrnFont,addr lfntprn.lfFaceName,addr iniAsmFile
	invoke BinToDec,lfntprn.lfHeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditPrnFontHeight,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,lfntprn.lfWeight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditPrnFontWeight,addr iniBuffer,addr iniAsmFile
	movzx	edx,lfntprn.lfCharSet
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditPrnFontCharSet,addr iniBuffer,addr iniAsmFile
	;Printer page
	mov		buffer,0
	invoke iniPutItem,psd.ptPaperSize.x,addr buffer,TRUE
	invoke iniPutItem,psd.ptPaperSize.y,addr buffer,TRUE
	invoke iniPutItem,psd.rtMargin.left,addr buffer,TRUE
	invoke iniPutItem,psd.rtMargin.top,addr buffer,TRUE
	invoke iniPutItem,psd.rtMargin.right,addr buffer,TRUE
	invoke iniPutItem,psd.rtMargin.bottom,addr buffer,TRUE
	invoke iniPutItem,prnOrientation,addr buffer,FALSE
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditPrnPage,addr buffer,addr iniAsmFile
	mov		buffer,0
	invoke iniPutItem,PrnPageNumber,addr buffer,TRUE
	invoke iniPutItem,PrnHeading,addr buffer,TRUE
	invoke iniPutItem,PrnTime,addr buffer,TRUE
	invoke iniPutItem,PrnProDes,addr buffer,TRUE
	invoke iniPutItem,PrnUseColors,addr buffer,FALSE
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditPrnOption,addr buffer,addr iniAsmFile
	push	ebx
	mov		buffer,0
	mov		ebx,offset PrnColors
	mov		ecx,5+16-1
	.while ecx
		push	ecx
		mov		ecx,[ebx]
		invoke iniPutItem,ecx,addr buffer,TRUE
		add		ebx,4
		pop		ecx
		dec		ecx
	.endw
	mov		ecx,[ebx]
	invoke iniPutItem,ecx,addr buffer,FALSE
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditPrnColor,addr buffer,addr iniAsmFile
	pop		ebx
	;Misc
	invoke BinToDec,TabSize,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditTabSize,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,Backup,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditBackup,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,AutoSave,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditAutoSave,addr iniBuffer,addr iniAsmFile
	mov		eax,make.fExecThread
	invoke BinToDec,eax,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditThreadBuild,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fChangeNotify,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditChangeNotify,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fMinimize,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditMinimize,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fAutoLoadPro,addr iniBuffer
	invoke WritePrivateProfileString,addr iniWindow,addr iniAutoLoad,addr iniBuffer,addr iniFile

	invoke BinToDec,AutoIndent,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditAutoIndent,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,ShowApiList,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditApiList,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,ShowApiToolTip,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditApiToolTip,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,ShowProperties,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditProperties,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,MouseWheel,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditMouseWheel,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,SaveSize,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditSaveSize,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,EditMax,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditMaximize,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,ApiConst,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditApiConst,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,CodeWriteMacro,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditCodeWrite,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,TabToSpc,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditTabToSpc,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,ShowApiStruct,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditApiStruct,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,ApiWordConv,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditApiWordConv,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,ApiWordLocal,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditApiWordLocal,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,ApiShiftSpace,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditApiShiftSpace,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,SingleInstance,addr iniBuffer
	invoke WritePrivateProfileString,addr iniWindow,addr iniSingleInstance,addr iniBuffer,addr iniFile
	invoke BinToDec,HiliteLine,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniHiliteLine,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,HiliteCmnt,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniHiliteCmnt,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fAutoRefresh,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditProcsToApi,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fEnterOnTab,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditEnterOnTab,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fProcInSBar,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditProcInSBar,addr iniBuffer,addr iniAsmFile
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditCodeFiles,addr szCodeFiles,addr iniAsmFile
	invoke BinToDec,LnrOnOpen,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditLnrOnOpen,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,nPageSize,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniPageSize,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fOpenCollapsed,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditOpenCollapsed,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fAutoBrackets,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditAutoBrackets,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fCodeTooltip,addr iniBuffer
	invoke WritePrivateProfileString,addr iniEdit,addr iniEditCodeTooltip,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fErrBookMark,addr iniBuffer
	invoke WritePrivateProfileString,addr iniError,addr iniErrBookMark,addr iniBuffer,addr iniAsmFile
	ret

iniEditSave endp

iniDialogSave proc

	invoke BinToDec,fGrid,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogGrid,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,Gridcx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogGridcx,addr iniBuffer,addr iniAsmFile

	invoke BinToDec,Gridcy,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogGridcy,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fSnapToGrid,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogSnapToGrid,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fGridLine,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogGridLine,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,GridColor,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogGridColor,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fShowSizePos,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogShowSize,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fSaveRcFile,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogSaveRC,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fSimpleProperty,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogSimpleProperty,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fLimittedFont,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogLimittedFont,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,DlgIDN,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogDlgID,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,CtrlIDN,addr iniBuffer
	invoke WritePrivateProfileString,addr iniDialog,addr iniDialogCtrlID,addr iniBuffer,addr iniAsmFile

	ret

iniDialogSave endp

iniColSave proc uses esi
	LOCAL	nInx:DWORD
	LOCAL	buffer[16]:BYTE

	invoke BinToDec,fUseHighLight,addr iniBuffer
	invoke WritePrivateProfileString,addr iniColor,addr iniUseColor,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fUseDivLine,addr iniBuffer
	invoke WritePrivateProfileString,addr iniColor,addr iniUseDivLine,addr iniBuffer,addr iniAsmFile
	invoke BinToDec,fNoFlicker,addr iniBuffer
	invoke WritePrivateProfileString,addr iniColor,addr iniNoFlicker,addr iniBuffer,addr iniAsmFile

	mov		esi,offset iniColors
  @@:
	mov		edx,[esi]
	mov		edx,[edx]
	add		esi,8
	invoke BinToDec,edx,addr iniBuffer
	invoke WritePrivateProfileString,addr iniColor,esi,addr iniBuffer,addr iniAsmFile
	invoke strlen,esi
	add		esi,eax
	inc		esi
	mov		eax,[esi]
	or		eax,eax
	jne		@b
	mov		buffer,'C'
	mov		nInx,0
	.while nInx<16
		invoke BinToDec,nInx,addr buffer[1]
		mov		edx,nInx
		mov		edx,radcol.keywords[edx*4]
		invoke BinToDec,edx,addr iniBuffer
		invoke WritePrivateProfileString,addr iniColor,addr buffer,addr iniBuffer,addr iniAsmFile
		inc		nInx
	.endw
	mov		buffer,'B'
	mov		nInx,0
	.while nInx<16
		invoke BinToDec,nInx,addr buffer[1]
		mov		edx,nInx
		mov		edx,backcol[edx*4+4*4]
		invoke BinToDec,edx,addr iniBuffer
		invoke WritePrivateProfileString,addr iniColor,addr buffer,addr iniBuffer,addr iniAsmFile
		inc		nInx
	.endw
	mov		iniBuffer,0
	mov		nInx,0
	mov		esi,offset CustColors
	.while nInx<15
		invoke iniPutItem,[esi],addr iniBuffer,TRUE
		add		esi,4
		inc		nInx
	.endw
	invoke iniPutItem,[esi],addr iniBuffer,FALSE
	invoke WritePrivateProfileString,addr iniColor,addr iniCustColors,addr iniBuffer,addr iniAsmFile
	ret

iniColSave endp

iniToolSave proc uses ebx,hTool:DWORD,lpIni:DWORD
	LOCAL	buffer[128]:BYTE

	mov		buffer[0],0
	invoke ToolMessage,hTool,TLM_GET_STRUCT,0
	mov		ebx,edx
	assume ebx:ptr DOCKING
	and		[ebx].Visible,1
	and		[ebx].Docked,1
	invoke iniPutItem,[ebx].Visible,addr buffer,TRUE
	invoke iniPutItem,[ebx].Docked,addr buffer,TRUE
	invoke iniPutItem,[ebx].Position,addr buffer,TRUE
	invoke iniPutItem,[ebx].IsChild,addr buffer,TRUE
	invoke iniPutItem,[ebx].DockWidth,addr buffer,TRUE
	invoke iniPutItem,[ebx].DockHeight,addr buffer,TRUE
	invoke iniPutItem,[ebx].FloatRect.left,addr buffer,TRUE
	invoke iniPutItem,[ebx].FloatRect.top,addr buffer,TRUE
	invoke iniPutItem,[ebx].FloatRect.right,addr buffer,TRUE
	invoke iniPutItem,[ebx].FloatRect.bottom,addr buffer,FALSE
	assume ebx:nothing
	invoke WritePrivateProfileString,addr iniWindow,lpIni,addr buffer,addr iniFile
	mov		eax,hTool
	invoke GetToolPtr
	mov		eax,(TOOL ptr [edx]).hWin
	invoke DestroyWindow,eax
	ret

iniToolSave endp

iniFileBrowserSave proc uses edi
	LOCAL	buffer[4]:BYTE

	mov		dword ptr buffer,'0'
	mov		edi,offset FilePaths
	.while buffer<='9'
		invoke WritePrivateProfileString,offset iniFileBrowser,addr buffer,edi,offset iniFile
		inc		buffer
		add		edi,MAX_PATH
	.endw
	invoke WritePrivateProfileString,offset iniFileBrowser,offset iniFileBrowserFilter,offset FileFilter,offset iniFile
	ret

iniFileBrowserSave endp

ParseBuffer proc uses edi esi,hHeap:DWORD,pBuffer:DWORD, nSize:DWORD, ArrayOffset:DWORD,pArray:DWORD
	LOCAL	buffer[128]:BYTE
	LOCAL	InProgress:DWORD

	mov		InProgress,FALSE
	lea		esi,buffer
	mov		edi,pBuffer
	invoke CharLower,edi
	mov		ecx,nSize
SearchLoop:
	or		ecx,ecx
	jz		Finished
	cmp		byte ptr [edi]," "
	je		EndOfWord
	cmp		byte ptr [edi],VK_TAB
	je		EndOfWord
	mov		InProgress,TRUE
	mov		al,byte ptr [edi]
	cmp		al,'-'
	je		SkipIt
	cmp		al,'+'
	je		SkipIt
	mov		byte ptr [esi],al
	inc		esi
SkipIt:
	inc		edi
	dec		ecx
	jmp		SearchLoop
EndOfWord:
	cmp		InProgress,TRUE
	je		WordFound
	jmp		SkipIt
WordFound:
	mov		byte ptr [esi],0
	push	ecx
	; store the word in a WORDINFO structure
	invoke xHeapAlloc,hHeap,HEAP_ZERO_MEMORY,sizeof WORDINFO
	push	esi
	mov		esi,eax
	assume esi:ptr WORDINFO
	invoke strlen,addr buffer
	mov		[esi].WordLen,eax
	push	ArrayOffset
	pop		[esi].pColor
	inc		eax
	invoke xHeapAlloc,hHeap,HEAP_ZERO_MEMORY,eax
	mov		[esi].pszWord,eax
	mov		edx,eax
	invoke strcpy,edx,addr buffer
	mov		eax,pArray
	movzx	edx,byte ptr [buffer]
	shl		edx,2		; multiply by 4
	add		eax,edx
	.if dword ptr [eax]==0
		mov		dword ptr [eax],esi
	.else
		push	dword ptr [eax]
		pop		[esi].NextLink
		mov		dword ptr [eax],esi
	.endif
	pop		esi
	pop		ecx
	lea		esi,buffer
	mov		InProgress,FALSE
	jmp		SkipIt
Finished:
	.if InProgress==TRUE
		; store the word in a WORDINFO structure
		invoke xHeapAlloc,hHeap,HEAP_ZERO_MEMORY,sizeof WORDINFO
		push	esi
		mov		esi,eax
		assume esi:ptr WORDINFO
		invoke strlen,addr buffer
		mov		[esi].WordLen,eax
		push	ArrayOffset
		pop		[esi].pColor
		inc		eax
		invoke xHeapAlloc,hHeap,HEAP_ZERO_MEMORY,eax
		mov		[esi].pszWord,eax
		mov		edx,eax
		invoke strcpy,edx,addr buffer
		mov		eax,pArray
		movzx	edx,byte ptr [buffer]
		shl		edx,2		; multiply by 4
		add		eax,edx
		.if dword ptr [eax]==0
			mov		dword ptr [eax],esi
		.else
			push	dword ptr [eax]
			pop		[esi].NextLink
			mov		dword ptr [eax],esi
		.endif
		pop		esi
	.endif
	ret
	assume esi:nothing

ParseBuffer endp

SetBlockDef proc uses ebx esi

	invoke GetProcAddress,hRAEdit,addr szSetBlockDef
	.if eax
		mov		ebx,eax
		;Reset
		push	0
		call	ebx
		mov		esi,offset rablkdef
		.while [esi].RABLOCKDEF.lpszStart
			push	esi
			call	ebx
			mov		edx,[esi].RABLOCKDEF.lpszStart
			call	TestIt
			mov		edx,[esi].RABLOCKDEF.lpszEnd
			call	TestIt
			lea		esi,[esi+sizeof RABLOCKDEF]
		.endw
	.endif
	ret

TestIt:
	.if edx
		.while byte ptr [edx]
			.if byte ptr [edx]=='|'
				mov		byte ptr [edx],0
			.endif
			inc		edx
		.endw
	.endif
	retn

SetBlockDef endp

FillHiliteInfo proc uses ebx esi edi
	LOCAL	pTemp:DWORD
	LOCAL	BlockSize:DWORD
	LOCAL	pColor:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	lpMax:DWORD

	invoke GetProcAddress,hRAEdit,addr szSetHiliteWords
	.if eax
		mov		edi,eax
		;Reset
		push	0
		push	0
		call	edi
		invoke GetFileAttributes,addr iniAsmFile
		.if eax!=-1
			;Words from inifile
			mov		nInx,0
			.while nInx<16
				mov		buffer,'C'
				invoke BinToDec,nInx,addr buffer[1]
				invoke GetPrivateProfileString,addr iniKeyWords,addr buffer,addr szNULL,offset tempbuff,sizeof tempbuff,addr iniAsmFile
				.if eax
					mov		eax,nInx
					push	offset tempbuff
					push	radcol.keywords[eax*4]
					call	edi
				.endif
				inc		nInx
			.endw
			;Words from api files
			mov		esi,lpWordList
			mov		eax,esi
			add		eax,rpProjectWordList
			mov		lpMax,eax
			.while [esi].PROPERTIES.nSize && esi<lpMax
				movzx	eax,[esi].PROPERTIES.nType
				.if eax=='C'
					;Api constants
					lea		ebx,[esi+sizeof PROPERTIES]
					invoke strlen,ebx
					lea		ebx,[ebx+eax+1]
					.while byte ptr [ebx]
						lea		edx,buffer
						mov		word ptr [edx],'^'
						inc		edx
						mov		ecx,edx
						.while byte ptr [ebx]!=',' && byte ptr [ebx]
							mov		al,byte ptr [ebx]
							mov		byte ptr [edx],al
							inc		ebx
							inc		edx
						.endw
						.if byte ptr [ebx]==','
							inc		ebx
						.endif
						mov		byte ptr [edx],0
						sub		ecx,edx
						neg		ecx
						.if ecx>1 || byte ptr [edx-1]<'0' || byte ptr [edx-1]>'9'
							lea		edx,buffer
							push	edx
							push	radcol.keywords[13*4]
							call	edi
						.endif
					.endw
				.elseif eax=='A'
					;Api's
					lea		edx,buffer
					mov		byte ptr [edx],'^'
					inc		edx
					invoke strcpy,edx,addr [esi+sizeof PROPERTIES]
					lea		edx,buffer
					push	edx
					push	radcol.keywords[14*4]
					call	edi
				.elseif eax=='S'
					;Structures
					lea		edx,buffer
					mov		byte ptr [edx],'^'
					inc		edx
					invoke strcpy,edx,addr [esi+sizeof PROPERTIES]
					lea		edx,buffer
					push	edx
					push	radcol.keywords[15*4]
					call	edi
				.elseif eax=='M' || eax=='W'
					;Messages and wordlist
					lea		edx,buffer
					mov		byte ptr [edx],'^'
					inc		edx
					invoke strcpy,edx,addr [esi+sizeof PROPERTIES]
					lea		edx,buffer
					push	edx
					push	radcol.keywords[13*4]
					call	edi
				.endif
				mov		edx,[esi].PROPERTIES.nSize
				lea		esi,[esi+edx+sizeof PROPERTIES]
			.endw
		.endif
	.endif
	.if hMainHeap
		invoke HeapDestroy,hMainHeap
	.endif
	invoke HeapCreate,HEAP_NO_SERIALIZE,64,1024*1024
	mov		hMainHeap,eax
	; Zero out the array
	invoke RtlZeroMemory,addr ASMSyntaxArray,sizeof ASMSyntaxArray
	; Check whether the file exists
	invoke GetFileAttributes,addr iniAsmFile
	.if eax!=-1
		; allocate a block of memory from the heap for the strings
		mov		BlockSize,1024*10
		invoke xHeapAlloc,hMainHeap,0,BlockSize
		mov		pTemp,eax
		mov		nInx,0
		.while nInx<16
			mov		buffer,'C'
			invoke BinToDec,nInx,addr buffer[1]
			invoke GetPrivateProfileString,addr iniKeyWords,addr buffer,addr szNULL,offset tempbuff,sizeof tempbuff,addr iniAsmFile
			.if eax
				mov		eax,nInx
				lea		eax,PrnColors[eax*4+5*4]
				mov		pColor,eax
				lea		edi,buffer
				call	GetWords
			.endif
			inc		nInx
		.endw
		invoke HeapFree,hMainHeap,0,pTemp
	.endif
	ret

GetWords:
	invoke GetPrivateProfileString,addr iniKeyWords,edi,addr szNULL,pTemp,BlockSize,addr iniAsmFile
	.if eax!=0
		inc		eax
		.if eax==BlockSize	; the buffer is too small
			add		BlockSize,1024*10
			invoke HeapReAlloc,hMainHeap,0,pTemp,BlockSize
			mov		pTemp,eax
			jmp		GetWords
		.endif
		invoke ParseBuffer,hMainHeap,pTemp,eax,pColor,addr ASMSyntaxArray
	.endif
	retn

FillHiliteInfo endp

iniGetAppPath proc lpPathBuffer:DWORD
	LOCAL	buffer[128]:BYTE

	invoke GetModuleFileName,0,addr buffer,128
	invoke iniRStripStr,addr buffer,'\'
	invoke strcpy,lpPathBuffer,addr buffer
	ret

iniGetAppPath endp

iniFixPath proc lpStr:DWORD,lpPth:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	pushad
  iniFixPath1:
	invoke iniInStr,lpStr,lpSrc
	.if eax!=-1
		push	eax
		invoke strcpy,addr buffer,lpStr
		lea		esi,buffer
		mov		edi,lpStr
		pop		eax
		.if eax!=0
		  @@:
			movsb
			dec		eax
			jne		@b
		.endif
		invoke strlen,lpSrc
		add		esi,eax
		push	esi
		mov		esi,lpPth
	  @@:
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		or		al,al
		jne		@b
		dec		edi
		pop		esi
	  @@:
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
		or		al,al
		jne		@b
		jmp		iniFixPath1
	.endif
	popad
	ret

iniFixPath endp

iniInStr proc lpStr:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	push	esi
	push	edi
	mov		esi,lpSrc
	lea		edi,buffer
iniInStr0:
	mov		al,[esi]
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		iniInStr0
	mov		edi,lpStr
	dec		edi
iniInStr1:
	inc		edi
	push	edi
	lea		esi,buffer
iniInStr2:
	mov		ah,[esi]
	or		ah,ah
	je		iniInStr8;Found
	mov		al,[edi]
	or		al,al
	je		iniInStr9;Not found
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	inc		esi
	inc		edi
	cmp		al,ah
	jz		iniInStr2
	pop		edi
	jmp		iniInStr1
iniInStr8:
	pop		eax
	sub		eax,lpStr
	pop		edi
	pop		esi
	ret
iniInStr9:
	pop		edi
	mov		eax,-1
	pop		edi
	pop		esi
	ret

iniInStr endp

iniRStripStr proc lpStr:DWORD,nByte:DWORD

	pushad
	mov		esi,lpStr
	invoke strlen,lpStr
	add		esi,eax
	mov		ecx,eax
	mov		eax,nByte
	inc		ecx
  @@:
	dec		ecx
	je		@f
	dec		esi
	cmp		al,[esi]
	jne		@b
	mov		[esi],ah
  @@:
	mov		nByte,esi
	popad
	mov		eax,nByte
	ret

iniRStripStr endp

iniGetItem proc lpSource:DWORD,lpDest:DWORD

	push	esi
	push	edi
	mov		esi,lpSource
	mov		edi,lpDest
  @@:
	mov		al,[esi]
	cmp		al,','
	jz		@f
	or		al,al
	jz		@f
	mov		[edi],al
	inc		esi
	inc		edi
	jmp		@b
  @@:
	or		al,al
	jz		@f
	inc		esi
	mov		al,0
  @@:
	mov		[edi],al
	mov		eax,edi
	sub		eax,lpDest
	push	eax
	mov		edi,lpSource
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jnz		@b
	pop		eax
	pop		edi
	pop		esi
	ret

iniGetItem endp

iniGetItemW proc lpSource:DWORD,lpDest:DWORD

	push	esi
	push	edi
	mov		esi,lpSource
	mov		edi,lpDest
  @@:
	mov		ax,[esi]
	cmp		ax,','
	jz		@f
	or		ax,ax
	jz		@f
	mov		[edi],ax
	inc		esi
	inc		esi
	inc		edi
	inc		edi
	jmp		@b
  @@:
	or		ax,ax
	jz		@f
	inc		esi
	inc		esi
	mov		ax,0
  @@:
	mov		[edi],ax
	mov		eax,edi
	sub		eax,lpDest
	push	eax
	mov		edi,lpSource
  @@:
	mov		ax,[esi]
	mov		[edi],ax
	inc		esi
	inc		esi
	inc		edi
	inc		edi
	or		ax,ax
	jnz		@b
	pop		eax
	pop		edi
	pop		esi
	ret

iniGetItemW endp

iniPutItem proc uses edi,Value:DWORD,lpDest:DWORD,fComma:DWORD
	LOCAL	buffer[16]:BYTE

	invoke BinToDec,Value,addr buffer
	invoke strlen,lpDest
	mov		edi,lpDest
	add		edi,eax
	invoke strcpy,edi,addr buffer
	.if fComma
		invoke strlen,lpDest
		mov		edi,lpDest
		add		edi,eax
		mov		word ptr [edi],','
	.endif
	ret

iniPutItem endp

iniWriteSection proc uses edi,lpKey:DWORD,lpValue:DWORD,lpSection:DWORD

	mov		edi,lpSection
	invoke strcpy,edi,lpKey
	invoke strlen,edi
	add		edi,eax
	mov		byte ptr [edi],'='
	inc		edi
	invoke strcpy,edi,lpValue
	invoke strlen,edi
	add		edi,eax
	mov		byte ptr [edi+1],0
	mov		eax,edi
	sub		eax,lpSection
	ret

iniWriteSection endp

