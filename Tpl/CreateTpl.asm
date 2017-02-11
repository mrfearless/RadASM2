;Type
;Name
;Description
;[*BEGINTXT*]
;.Asm
;[*ENDTXT*]
;[*BEGINTXT*]
;.Inc
;[*ENDTXT*]
;[*BEGINTXT*]
;.Rc
;[*ENDTXT*]
;[*BEGINTXT*]
;.Def
;[*ENDTXT*]
;[*BEGINTXT*]
;\Mod\MyModule.asm
;[*ENDTXT*]
;[*BEGINBIN*]
;MyDialog.Dlg
;[*ENDBIN*]
;[*BEGINBIN*]
;MyMenu.Mnu
;[*ENDBIN*]
;
.const

IDD_DLGTPLCREATE	equ 2000
IDC_EDTTPLDESCR		equ 2001
IDC_LSTTPLC			equ 2002
IDC_BTNTPLADD		equ 2003
IDC_BTNTPLREMOVE	equ 2004
IDC_STCTPLFILE		equ 2005
IDC_BTNTPLFILE		equ 2006

.data

szTplRes			db 'Res\*.*',0

szBeginPro			db '[*BEGINPRO*]',0Dh,0Ah,0
szEndPro			db '[*ENDPRO*]',0Dh,0Ah,0
szBeginDef			db '[*BEGINDEF*]',0Dh,0Ah,0
szEndDef			db '[*ENDDEF*]',0Dh,0Ah,0
szBeginTxt			db '[*BEGINTXT*]',0Dh,0Ah,0
szEndTxt			db '[*ENDTXT*]',0Dh,0Ah,0
szBeginBin			db '[*BEGINBIN*]',0Dh,0Ah,0
szEndBin			db '[*ENDBIN*]',0Dh,0Ah,0
szProjectName		db '[*PROJECTNAME*]',0

.data?

TplFileName			db 256 dup(?)
TplDescr			db 2048 dup(?)
fTplAddPth			dd ?

.code

TplCopyStr proc

  @@:
	mov		al,[esi]
	mov		[edi],al
	or		al,al
	je		@f
	inc		esi
	inc		edi
	jmp		@b
  @@:
	ret

TplCopyStr endp

TplFileType proc uses esi edi,lpFileName:DWORD
	LOCAL	buffer[64]:BYTE

	mov		esi,lpFileName
	invoke strlen,esi
	lea		esi,[esi+eax]
	lea		edi,buffer
  @@:
	dec		esi
	mov		al,[esi]
	cmp		al,'.'
	je		@f
	or		al,al
	jne		@b
	inc		esi
  @@:
	mov		al,[esi]
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		@b
	dec		edi
	mov		ax,'.'
	mov		[edi],ax
	invoke iniInStr,addr szFTTxt,addr buffer
	.if eax!=-1
		mov		eax,1
		ret
	.endif
	invoke iniInStr,addr szFTBin,addr buffer
	.if eax!=-1
		mov		eax,2
		ret
	.endif
	mov		eax,0
	ret

TplFileType endp

TplAddTxtFile proc uses edi,hWin:HWND
	LOCAL	strt:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	mov		strt,edi
	invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		mov		esi,offset szBeginTxt
		call	TplCopyStr
		invoke strlen,addr ProjectPath
		mov		esi,offset FileName
		add		esi,eax
		call	TplCopyStr
		mov		ax,0A0Dh
		stosw
		invoke ReadFile,hFile,edi,400000,addr nBytes,NULL
		invoke CloseHandle,hFile
		add		edi,nBytes
		mov		al,[edi-1]
		.if al!=0Ah
			mov		ax,0A0Dh
			stosw
		.endif
		mov		esi,offset szEndTxt
		call	TplCopyStr
		mov		eax,edi
		sub		eax,strt
	.else
		invoke strcpy,addr LineTxt,addr OpenFileFail
		invoke strcat,addr LineTxt,addr FileName
		invoke MessageBox,hWnd,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		mov		eax,-1
	.endif
	ret

TplAddTxtFile endp

TplAddBinFile proc uses edi,hWin:HWND
	LOCAL	strt:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	hMem:DWORD

	mov		strt,edi
	invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		mov		esi,offset szBeginBin
		call TplCopyStr
		invoke strlen,addr ProjectPath
		mov		esi,offset FileName
		add		esi,eax
		call	TplCopyStr
		mov		ax,0A0Dh
		stosw

		invoke GetFileSize,hFile,NULL
		.if eax
			mov		nBytes,eax
			invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,nBytes
			mov     hMem,eax
			invoke GlobalLock,hMem
			invoke ReadFile,hFile,hMem,nBytes,addr nBytes,NULL
			invoke CloseHandle,hFile
			mov		esi,hMem
			mov		ah,0
			.while nBytes
				mov		al,[esi]
				shr		al,4
				add		al,30h
				.if al>'9'
					add		al,7
				.endif
				stosb
				mov		al,[esi]
				and		al,0Fh
				add		al,30h
				.if al>'9'
					add		al,7
				.endif
				stosb
				inc		ah
				.if ah==32
					mov		ax,0A0Dh
					stosw
					mov		ah,0
				.endif
				inc		esi
				dec		nBytes
			.endw
			.if ah
				mov		ax,0A0Dh
				stosw
			.endif
			invoke GlobalUnlock,hMem
			invoke GlobalFree,hMem
		.endif
		mov		esi,offset szEndBin
		call	TplCopyStr
		mov		eax,edi
		sub		eax,strt
	.else
		invoke strcpy,addr LineTxt,addr OpenFileFail
		invoke strcat,addr LineTxt,addr FileName
		invoke MessageBox,hWnd,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		mov		eax,-1
	.endif
	ret

TplAddBinFile endp

TplAddFile proc uses edi,hWin:HWND

	invoke TplFileType,addr FileName
	.if eax==1
		invoke TplAddTxtFile,hWin
	.elseif eax==2
		invoke TplAddBinFile,hWin
	.else
		invoke strcpy,addr LineTxt,addr txtUF
		invoke strcat,addr LineTxt,addr FileName
		invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		mov		eax,-1
	.endif
	ret

TplAddFile endp

TplAddDef proc lpAppKey:DWORD

	mov		al,'['
	stosb
	invoke strcat,edi,lpAppKey
	invoke strlen,lpAppKey
	add		edi,eax
	mov		eax,0A0D5Dh
	stosd
	dec		edi
	invoke GetPrivateProfileSection,lpAppKey,addr tempbuff,sizeof tempbuff,addr ProjectFile
	mov		esi,offset tempbuff
	.while TRUE
		mov		al,[esi]
	  .break .if !al
		call	TplCopyStr
		inc		esi
		mov		eax,0A0Dh
		stosd
		sub		edi,2
	.endw
	ret

TplAddDef endp

CreateTemplate proc uses edi,hWin:HWND
	LOCAL	hMem:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	hFile:DWORD
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer1[16]:BYTE
	LOCAL	iNbr:DWORD

	invoke CreateFile,addr TplFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*1024*8
		mov     hMem,eax
		invoke GlobalLock,hMem
		mov		edi,hMem
		mov		esi,offset ProjectType
		call	TplCopyStr
		mov		ax,0A0Dh
		stosw
		mov		ax,'1'
		mov		buffer1[0],al
		mov		buffer1[1],ah
		invoke GetPrivateProfileString,addr iniMakeFile,addr buffer1,addr szNULL,addr buffer,64,addr ProjectFile
		lea		esi,buffer
		dec		esi
	  @@:
		inc		esi
		mov		al,[esi]
		cmp		al,'.'
		jne		@b
		mov		eax,0A0Dh
		mov		[esi],eax
		lea		esi,buffer
		call	TplCopyStr
		invoke GetDlgItemText,hWin,IDC_EDTTPLDESCR,addr TplDescr,2048
		mov		esi,offset TplDescr
		call	TplCopyStr
		mov		al,[edi-1]
		.if al!=0Ah
			mov		ax,0A0Dh
			stosw
		.endif
		mov		esi,offset szBeginPro
		call	TplCopyStr
		mov		esi,offset szBeginDef
		call	TplCopyStr
		invoke	TplAddDef,addr iniMakeDef
		invoke	TplAddDef,addr iniMakeFile
		invoke	TplAddDef,addr iniResource
		invoke	TplAddDef,addr iniStringTable
		invoke	TplAddDef,addr iniAccel
		invoke	TplAddDef,addr iniVerInf
		invoke	TplAddDef,addr iniProjectGroup
		mov		esi,offset szEndDef
		call	TplCopyStr
		mov		iNbr,PRO_START_FILE
	  @@:
		invoke GetFileNameFromID,iNbr
		.if eax
			push	eax
			invoke strcpy,addr FileName,addr ProjectPath
			pop		eax
			invoke strcat,addr FileName,eax
			invoke TplAddFile,hWin
			.if eax!=-1
				add		edi,eax
				mov		eax,edi
				sub		eax,hMem
				mov		nBytes,eax
				invoke WriteFile,hFile,hMem,nBytes,addr nBytes,NULL
				mov		edi,hMem
			.endif
		.endif
		mov		eax,iNbr
		inc		eax
		mov		iNbr,eax
		cmp		eax,1512
		jl		@b
		mov		esi,offset szEndPro
		call	TplCopyStr
		mov		eax,edi
		sub		eax,hMem
		mov		nBytes,eax
		invoke WriteFile,hFile,hMem,nBytes,addr nBytes,NULL
		mov		edi,hMem
		invoke SendDlgItemMessage,hWin,IDC_LSTTPLC,LB_GETCOUNT,0,0
		.if eax
			mov		iNbr,0
		  @@:
			push	eax
			invoke SendDlgItemMessage,hWin,IDC_LSTTPLC,LB_GETTEXT,iNbr,addr buffer
			invoke strcpy,addr FileName,addr ProjectPath
			invoke strcat,addr FileName,addr buffer
			invoke TplAddFile,hWin
			.if eax!=-1
				add		edi,eax
				mov		eax,edi
				sub		eax,hMem
				mov		nBytes,eax
				invoke WriteFile,hFile,hMem,nBytes,addr nBytes,NULL
				mov		edi,hMem
			.endif
			pop		eax
			inc		iNbr
			dec		eax
			jne		@b
		.endif
		invoke CloseHandle,hFile
		invoke GlobalUnlock,hMem
		invoke GlobalFree,hMem
		mov		eax,FALSE
	.else
		invoke strcpy,addr LineTxt,addr SaveFileFail
		invoke strcat,addr LineTxt,addr TplFileName
		invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		mov		eax,TRUE
	.endif
	ret

CreateTemplate endp

TplCreateProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM, lParam:LPARAM
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetDlgItemText,hWin,IDC_STCTPLFILE,addr TplFileName
		invoke SendDlgItemMessage,hWin,IDC_EDTTPLDESCR,EM_LIMITTEXT,2047,0
		invoke strcpy,addr buffer,addr ProjectPath
		invoke strcat,addr buffer,addr szTplRes
		mov		fTplAddPth,FALSE
		invoke SetLanguage,hWin,IDD_DLGTPLCREATE,FALSE
	.elseif eax==WM_COMMAND
		mov 	eax,wParam
		and		eax,0FFFFh
		.if eax==IDOK
			mov		al,TplFileName[0]
			.if al
				push	esi
				push	edi
				invoke CreateTemplate,hWin
				pop		edi
				pop		esi
				.if !eax
					invoke EndDialog,hWin,NULL
				.endif
			.endif
		.elseif eax==IDCANCEL
			invoke EndDialog,hWin,NULL
		.elseif eax==IDC_BTNTPLFILE
		    invoke RtlZeroMemory,addr ofn,sizeof ofn
			mov		ofn.lStructSize,sizeof ofn
			m2m		ofn.hwndOwner,hWin
			m2m		ofn.hInstance,hInstance
			mov		ofn.lpstrFilter,offset TPLFilterString
			mov		ofn.lpstrFile,offset TplFileName
			mov		ofn.nMaxFile,sizeof TplFileName
			mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
		    mov		ofn.lpstrDefExt,offset DefTplExt
		    mov		ofn.lpstrInitialDir,offset Tpl
			invoke GetSaveFileName,addr ofn
			.if eax!=0
				invoke SetDlgItemText,hWin,IDC_STCTPLFILE,addr TplFileName
			.endif
		.elseif eax==IDC_BTNTPLADD
		    invoke RtlZeroMemory,addr ofn,sizeof ofn
			mov		ofn.lStructSize,sizeof ofn
			m2m		ofn.hwndOwner,hWin
			m2m		ofn.hInstance,hInstance
			mov		ofn.lpstrFilter,offset ANYFilterString
			mov		tempbuff,0
			mov		eax,offset tempbuff
			mov		ofn.lpstrFile,eax
			mov		ofn.nMaxFile,sizeof tempbuff
			mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_ALLOWMULTISELECT or OFN_EXPLORER
		    mov		ofn.lpstrDefExt,0
			.if fTplAddPth
			    mov		ofn.lpstrInitialDir,0
			.else
			    mov		ofn.lpstrInitialDir,offset ProjectPath
			.endif
			mov		fTplAddPth,TRUE
			invoke GetOpenFileName,addr ofn
			.if eax
				push	esi
				mov		esi,offset tempbuff
				invoke strlen,esi
				add		esi,eax
				inc		esi
				.if !byte ptr [esi]
					invoke strlen,addr ProjectPath
					invoke SendDlgItemMessage,hWin,IDC_LSTTPLC,LB_ADDSTRING,0,addr tempbuff[eax]
				.else
					.while byte ptr [esi]
						invoke strcpy,addr buffer,offset tempbuff
						invoke strcat,addr buffer,offset szBackSlash
						invoke strcat,addr buffer,esi
						invoke strlen,esi
						add		esi,eax
						inc		esi
						invoke strlen,addr ProjectPath
						invoke SendDlgItemMessage,hWin,IDC_LSTTPLC,LB_ADDSTRING,0,addr buffer[eax]
					.endw
				.endif
				pop		esi
			.endif
		.elseif eax==IDC_BTNTPLREMOVE
			invoke SendDlgItemMessage,hWin,IDC_LSTTPLC,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				invoke SendDlgItemMessage,hWin,IDC_LSTTPLC,LB_DELETESTRING,eax,0
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TplCreateProc endp

