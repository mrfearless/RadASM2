;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include AddinMana.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

AddMenu proc

	mov		edx,8
	;Adjust topmost popup if maximized
	mov		eax,[lpData]
	.if [eax].ADDINDATA.fMaximized
		inc		edx
	.endif
	;Get handle of Option popup
	mov		eax,[lpHandles]
	invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,edx
	;Add our menuitem
	invoke AppendMenu,eax,MF_STRING,IDAddIn,addr szAddinMana
	ret

AddMenu endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx,hWin:DWORD,fOpt:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	; If Option (fOpt) = 0 then exit
	mov		eax,fOpt
	test	eax,eax
	je @F
		; Allocate a new menu id
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDAddIn,eax
		; Add menu item
		invoke AddMenu
		; Messages to hook into
		mov		eax,RAM_COMMAND or RAM_CLOSE
	@@:
	; ECX and EDX must be null before we return
	mov		ecx,RAM_ADDINSLOADED
	xor		edx,edx
	ret

InstallDll endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

BinToDec proc dwVal:DWORD,lpAscii:DWORD

	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi
	mov		eax,dwVal
	mov		edi,lpAscii
	or		eax,eax
	jns		pos
	mov		byte ptr [edi],'-'
	neg		eax
	inc		edi
  pos:		
	mov		ecx,429496730
	mov		esi,edi
  @@:
	mov		ebx,eax
	mul		ecx
	mov		eax,edx
	lea		edx,[edx*4+edx]
	add		edx,edx
	sub		ebx,edx
	add		bl,'0'
	mov		[edi],bl
	inc		edi
	or		eax,eax
	jne		@b
	mov		byte ptr [edi],al
	.while esi<edi
		dec		edi
		mov		al,[esi]
		mov		ah,[edi]
		mov		[edi],al
		mov		[esi],ah
		inc		esi
	.endw
	pop		edi
	pop		esi
	pop		edx
	pop		ecx
	pop		ebx
	ret

BinToDec endp

DecToBin proc lpStr:DWORD
	LOCAL	fNeg:DWORD

	push	ebx
	push	esi
	mov		esi,lpStr
	mov		fNeg,FALSE
	mov		al,[esi]
	.if al=='-'
		inc		esi
		mov		fNeg,TRUE
	.endif
	xor		eax,eax
  @@:
	cmp		byte ptr [esi],30h
	jb		@f
	cmp		byte ptr [esi],3Ah
	jnb		@f
	mov		ebx,eax
	shl		eax,2
	add		eax,ebx
	shl		eax,1
	xor		ebx,ebx
	mov		bl,[esi]
	sub		bl,30h
	add		eax,ebx
	inc		esi
	jmp		@b
  @@:
	.if fNeg
		neg		eax
	.endif
	pop		esi
	pop		ebx
	ret

DecToBin endp

GetIniOpt proc uses esi edi,lpFileName:DWORD
	LOCAL	nInx:DWORD
	LOCAL	buffer1[16]:BYTE
	LOCAL	buffer2[256]:BYTE

	mov		esi,lpData
	mov		esi,[esi].ADDINDATA.lpIniFile
	mov		nInx,1
	.while nInx<=MAX_ADDIN
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr szAddins,addr buffer1,addr szNULL,addr buffer2,sizeof buffer2,esi
		.if eax
			call	TestFile
			.if eax
				invoke DecToBin,eax
				mov		edx,nInx
				.break
			.endif
		.endif
		inc		nInx
		xor		eax,eax
		xor		edx,edx
	.endw
	ret

TestFile:
	mov		edi,lpFileName
	invoke lstrlen,edi
	lea		edi,[edi+eax]
	lea		edx,buffer2
	xor		ecx,ecx
	.while byte ptr [edx+ecx] && byte ptr [edx+ecx]!=','
		inc		ecx
	.endw
	push	ecx
	.while ecx
		dec		ecx
		dec		edi
		mov		al,[edx+ecx]
		mov		ah,[edi]
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		sub		al,ah
		.break .if al
	.endw
	.if !ecx && !al
		pop		eax
		lea		eax,[edx+eax]
		.if byte ptr [eax]==','
			inc		eax
		.endif
	.else
		pop		eax
		xor		eax,eax
	.endif
	retn

GetIniOpt endp

GetIniFree proc lpFileName:DWORD
	LOCAL	nInx:DWORD
	LOCAL	nFree:DWORD
	LOCAL	buffer1[16]:BYTE
	LOCAL	buffer2[256]:BYTE

	mov		nFree,0
	mov		nInx,1
	.while nInx<=MAX_ADDIN
		invoke BinToDec,nInx,addr buffer1
		mov		eax,lpData
		mov		eax,[eax].ADDINDATA.lpIniFile
		invoke GetPrivateProfileString,addr szAddins,addr buffer1,addr szNULL,addr buffer2,sizeof buffer2,eax
		.if !eax
			.if !nFree
				mov		eax,nInx
				mov		nFree,eax
			.endif
		.else
			lea		eax,buffer2
			.while byte ptr [eax] && byte ptr [eax]!=','
				inc		eax
			.endw
			mov		byte ptr [eax],0
			invoke lstrcmpi,addr buffer2,lpFileName
			.if !eax
				mov		eax,nInx
				mov		nFree,eax
				.break
			.endif
		.endif
		inc		nInx
	.endw
	mov		eax,nFree
	ret

GetIniFree endp

UpdateDll proc lpAddinState:DWORD
	LOCAL	espsave:DWORD

	pushad
	mov		esi,lpAddinState
	mov		edi,[esi].ADDINSTATE.lpAddin
	.if edi
		;Previously loaded
		push	esi
		push	edi
		mov		espsave,esp
		push	0
		push	0
		push	AIM_CLOSE
		mov		eax,lpHandles
		mov		eax,[eax].ADDINHANDLES.hWnd
		push	eax
		mov		eax,[edi].ADDIN.lpDllProc
		call	eax
		mov		esp,espsave
		pop		edi
		pop		esi
		.if [esi].ADDINSTATE.fInst
			;Update
			mov		[edi].ADDIN.fhook1,0
			mov		[edi].ADDIN.fhook2,0
			mov		eax,[esi].ADDINSTATE.fOpt
			mov		[edi].ADDIN.fOpt,eax
			invoke GetProcAddress,[edi].ADDIN.hDLL,offset szInstallDll
			.if eax
				push	[edi].ADDIN.fOpt
				mov		edx,lpHandles
				push	[edx].ADDINHANDLES.hWnd
				call	eax
				mov		[edi].ADDIN.fhook1,eax
				mov		[edi].ADDIN.fhook2,ecx
			.else
				invoke GetProcAddress,[edi].ADDIN.hDLL,offset szInstallDllEx
				.if eax
					push	esi
					push	edi
					mov		espsave,esp
					push	[edi].ADDIN.hDLL
					push	[edi].ADDIN.fOpt
					mov		edx,lpHandles
					push	[edx].ADDINHANDLES.hWnd
					call	eax
					mov		esp,espsave
					pop		edi
					pop		esi
					mov		ecx,[eax]
					mov		[edi].ADDIN.fhook1,ecx
					mov		ecx,[eax+4]
					mov		[edi].ADDIN.fhook2,ecx
				.endif
			.endif
		.else
			;Unload
			invoke FreeLibrary,[edi].ADDIN.hDLL
			xor		eax,eax
			mov		[edi].ADDIN.hDLL,eax
			mov		[edi].ADDIN.fhook1,eax
			mov		[edi].ADDIN.fhook2,eax
			mov		[edi].ADDIN.fOpt,eax
			mov		[edi].ADDIN.lpDllProc,eax
			mov		[edi].ADDIN.inx,eax
		.endif
	.endif
	popad
	ret

UpdateDll endp

LoadDll proc lpAddinState:DWORD
	LOCAL	espsave:DWORD

	pushad
	mov		edi,lpData
	mov		edi,[edi].ADDINDATA.lpAddins
	xor		ecx,ecx
	.while [edi].ADDIN.hDLL && ecx<MAX_ADDIN
		add		edi,sizeof ADDIN
		inc		ecx
	.endw
	.if ecx<MAX_ADDIN
		mov		esi,lpAddinState
		mov		ebx,[esi].ADDINSTATE.hAddin
		invoke GetProcAddress,ebx,offset szDllProc
		.if eax
			push	eax
			invoke GetProcAddress,ebx,offset szInstallDll
			.if !eax
				invoke GetProcAddress,ebx,offset szInstallDllEx
				pop		edx
				.if eax
					mov		[edi].ADDIN.hDLL,ebx
					mov		[edi].ADDIN.lpDllProc,edx
					mov		edx,[esi].ADDINSTATE.nIniInx
					mov		[edi].ADDIN.inx,edx
					mov		edx,[esi].ADDINSTATE.fOpt
					mov		[edi].ADDIN.fOpt,edx
					push	edi
					mov		espsave,esp
					push	ebx
					push	edx
					mov		edx,lpHandles
					push	[edx].ADDINHANDLES.hWnd
					call	eax
					mov		esp,espsave
					pop		edi
					mov		ecx,[eax]
					mov		[edi].ADDIN.fhook1,ecx
					mov		ecx,[eax+4]
					mov		[edi].ADDIN.fhook2,ecx
				.endif
			.else
				pop		edx
				mov		[edi].ADDIN.hDLL,ebx
				mov		[edi].ADDIN.lpDllProc,edx
				mov		edx,[esi].ADDINSTATE.nIniInx
				mov		[edi].ADDIN.inx,edx
				mov		edx,[esi].ADDINSTATE.fOpt
				mov		[edi].ADDIN.fOpt,edx
				push	edx
				mov		edx,lpHandles
				push	[edx].ADDINHANDLES.hWnd
				call	eax
				mov		[edi].ADDIN.fhook1,eax
				mov		[edi].ADDIN.fhook2,ecx
			.endif
		.endif
	.endif
	popad
	ret

LoadDll endp

SaveIniOpt proc uses esi edi,hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer1[16]:BYTE
	LOCAL	buffer2[256]:BYTE

	mov		nInx,0
  @@:
	invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETTEXT,nInx,addr buffer2
	.if eax!=LB_ERR
		invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETITEMDATA,nInx,0
		mov		esi,eax
		mov		ecx,[esi].ADDINSTATE.nIniInx
		mov		eax,[esi].ADDINSTATE.fOpt
		mov		edx,[esi].ADDINSTATE.fInst
		.if eax!=[esi].ADDINSTATE.fOptInit || (!edx && [esi].ADDINSTATE.lpAddin) || (edx && ![esi].ADDINSTATE.lpAddin)
			.if !ecx
				invoke GetIniFree,addr buffer2
				mov		ecx,eax
				mov		[esi].ADDINSTATE.nIniInx,ecx
			.endif
			.if ecx
				invoke BinToDec,ecx,addr buffer1
				lea		edi,buffer2
				invoke lstrlen,edi
				lea		edi,[edi+eax]
				mov		byte ptr [edi],','
				inc		edi
				mov		eax,[esi].ADDINSTATE.fOpt
				invoke BinToDec,eax,edi
				invoke lstrlen,edi
				lea		edi,[edi+eax]
				mov		byte ptr [edi],','
				inc		edi
				mov		eax,[esi].ADDINSTATE.fInst
				invoke BinToDec,eax,edi
				mov		eax,lpData
				mov		eax,[eax].ADDINDATA.lpIniFile
				invoke WritePrivateProfileString,addr szAddins,addr buffer1,addr buffer2,eax
				.if [esi].ADDINSTATE.lpAddin
					;Previously loaded
					invoke UpdateDll,esi
				.elseif [esi].ADDINSTATE.fInst
					;Previously not loaded
					invoke LoadDll,esi
				.endif
			.endif
		.endif
		inc		nInx
		jmp		@b
	.endif
	push	RAM_ADDINSLOADED
	push	0
	push	0
	push	AIM_ADDINSLOADED
	mov		eax,lpHandles
	push	[eax].ADDINHANDLES.hWnd
	mov		eax,lpProc
	call	[eax].ADDINPROCS.lpDllProc
	ret

SaveIniOpt endp

GetInstalled proc uses esi,hAddin:DWORD,lpDllProc:DWORD,lpAis:DWORD,lpAddinOpt:DWORD,lpFileName:DWORD

	mov		esi,lpData
	mov		esi,[esi].ADDINDATA.lpAddins
	mov		eax,lpDllProc
	mov		ecx,lpAis
	xor		edx,edx
	.while [esi].ADDIN.hDLL
		.if eax==[esi].ADDIN.lpDllProc
			mov		eax,[esi].ADDIN.fOpt
			inc		edx
			.break
		.endif
		add		esi,sizeof ADDIN
	.endw
	.if edx
		mov		[ecx].ADDINSTATE.lpAddin,esi
		mov		[ecx].ADDINSTATE.fOpt,eax
		mov		[ecx].ADDINSTATE.fOptInit,eax
		mov		eax,[esi].ADDIN.inx
		mov		[ecx].ADDINSTATE.nIniInx,eax
	.else
		mov		[ecx].ADDINSTATE.lpAddin,0
		push	edx
		push	ecx
		invoke GetIniOpt,lpFileName
		pop		ecx
		mov		[ecx].ADDINSTATE.fOpt,eax
		mov		[ecx].ADDINSTATE.fOptInit,eax
		mov		[ecx].ADDINSTATE.nIniInx,edx
		pop		edx
	.endif
	mov		[ecx].ADDINSTATE.fInst,edx
	mov		edx,hAddin
	mov		[ecx].ADDINSTATE.hAddin,edx
	mov		edx,lpAddinOpt
	mov		[ecx].ADDINSTATE.lpAddinOpt,edx
	ret

GetInstalled endp

IsAddin proc lpFileName:DWORD,lpAis:DWORD
	LOCAL	hDll:DWORD

	invoke LoadLibrary,lpFileName
	.if eax
		mov		hDll,eax
		invoke GetProcAddress,hDll,addr szInstallDll
		.if !eax
			invoke GetProcAddress,hDll,offset szInstallDllEx
		.endif
		.if eax
			invoke GetProcAddress,hDll,addr szDllProc
			.if eax
				push	eax
				invoke GetProcAddress,hDll,addr szGetOptions
				mov		edx,eax
				pop		eax
				invoke GetInstalled,hDll,eax,lpAis,edx,lpFileName
				xor		eax,eax
				inc		eax
			.endif
		.endif
		.if !eax
			push	eax
			invoke FreeLibrary,hDll
			pop		eax
		.endif
	.endif
	ret

IsAddin endp

GetAddinOptions proc uses ebx esi edi,hWin:HWND
	LOCAL	hCtl:HWND
	LOCAL	lpAddinState:DWORD
	LOCAL	nID:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE

	mov		ebx,IDC_CHK1
	invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nID,eax
		;Get AppName
		invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETTEXT,nID,addr buffer
		invoke lstrlen,addr buffer
		.while eax
			.if byte ptr buffer[eax]=='.'
				mov		buffer[eax],0
				.break
			.endif
			dec		eax
		.endw
		;Get pointer to ADDINSTATE
		invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETITEMDATA,nID,0
		mov		lpAddinState,eax
		mov		eax,[eax].ADDINSTATE.lpAddinOpt
		.if eax
			mov		esi,esp
			call	eax
			mov		esp,esi
			mov		esi,eax
			mov		nID,3000
			.while [esi].ADDINOPT.lpStr
				invoke GetDlgItem,hWin,ebx
				mov		hCtl,eax
				push	sizeof buffer1/2
				lea		eax,buffer1
				push	eax
				push	nID
				lea		eax,buffer
				push	eax
				mov		eax,lpProc
				call	[eax].ADDINPROCS.lpGetLangString
				.if eax
					invoke SendMessageW,hCtl,WM_SETTEXT,0,addr buffer1
				.else
					mov		eax,[esi].ADDINOPT.lpStr
					invoke SendMessage,hCtl,WM_SETTEXT,0,eax
				.endif
				invoke ShowWindow,hCtl,SW_SHOWNA
				;Set pointer to ADDINOPT
				invoke SetWindowLong,hCtl,GWL_USERDATA,esi
				mov		eax,lpAddinState
				mov		eax,[eax].ADDINSTATE.fOpt
				and		eax,[esi].ADDINOPT.nAnd
				xor		edx,edx
				.if eax==[esi].ADDINOPT.nOr
					inc		edx
				.endif
				invoke CheckDlgButton,hWin,ebx,edx
				add		esi,sizeof ADDINOPT
				inc		ebx
				inc		nID
			.endw
		.endif
	.endif
	.while ebx<=IDC_CHK16
		invoke CheckDlgButton,hWin,ebx,FALSE
		invoke GetDlgItem,hWin,ebx
		invoke ShowWindow,eax,SW_HIDE
		inc		ebx
	.endw
	ret

GetAddinOptions endp

SetAddinOptions proc uses ebx esi,hWin:HWND,nID:DWORD
	LOCAL	hCtl:HWND

	invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		;Get pointer to ADDINSTATE
		invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETITEMDATA,eax,0
		mov		esi,eax
		invoke IsDlgButtonChecked,hWin,nID
		mov		ebx,eax
		invoke GetDlgItem,hWin,nID
		mov		hCtl,eax
		;Get pointer to ADDINOPT
		invoke GetWindowLong,hCtl,GWL_USERDATA
		mov		edx,eax
		mov		eax,[esi].ADDINSTATE.fOpt
		mov		ecx,[edx].ADDINOPT.nAnd
		xor		ecx,-1
		and		eax,ecx
		.if ebx
			or		eax,[edx].ADDINOPT.nOr
		.endif
		mov		[esi].ADDINSTATE.fOpt,eax
		invoke GetAddinOptions,hWin
		invoke SetFocus,hCtl
	.endif
	ret

SetAddinOptions endp

ListDlls proc uses esi,hWin:HWND
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	wfd:WIN32_FIND_DATA
	LOCAL	hwfd:DWORD
	LOCAL	nInx

	mov		nInx,0
	invoke SendMessage,hWin,LB_RESETCONTENT,0,0
	mov		esi,offset ais
	mov		eax,lpData
	mov		eax,[eax].ADDINDATA.lpAddIn
	invoke lstrcpy,addr buffer,eax
	invoke lstrcat,addr buffer,addr szDll
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		mov		hwfd,eax
	  Next:
		.if nInx<MAX_ADDIN
			mov		eax,lpData
			mov		eax,[eax].ADDINDATA.lpAddIn
			invoke lstrcpy,addr buffer,eax
			invoke lstrcat,addr buffer,addr szBS
			invoke lstrcat,addr buffer,addr wfd.cFileName
			invoke IsAddin,addr buffer,esi
			.if eax
				invoke SendMessage,hWin,LB_ADDSTRING,0,addr wfd.cFileName
				invoke SendMessage,hWin,LB_SETITEMDATA,eax,esi
				add		esi,sizeof ADDINSTATE
				inc		nInx
			.endif
			invoke FindNextFile,hwfd,addr wfd
			or		eax,eax
			jne		Next
		.endif
		;No more matches, close handle
		invoke FindClose,hwfd
	.endif
	ret

ListDlls endp

GetInfo proc hWin:HWND
	LOCAL	hCtl:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	buffer1[32]:BYTE
	LOCAL	hFile:DWORD
	LOCAL	lwt:FILETIME
	LOCAL	slwt:SYSTEMTIME
	LOCAL	lpHandle:DWORD
	LOCAL	hMem:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	lpBuffer:DWORD
	LOCAL	nLang:DWORD
	LOCAL	nCP:DWORD

	invoke SetDlgItemText,hWin,IDC_STCDESC,addr szNA
	invoke SetDlgItemText,hWin,IDC_STCAUTHOR,addr szNA
	invoke SetDlgItemText,hWin,IDC_STCVERSION,addr szNA
	invoke SetDlgItemText,hWin,IDC_STCDATE,addr szNA
	invoke GetDlgItem,hWin,IDC_LSTADDINS
	mov		hCtl,eax
	invoke SendMessage,hCtl,LB_GETCURSEL,0,0
	mov		nInx,eax
	mov		eax,lpData
	mov		eax,[eax].ADDINDATA.lpAddIn
	invoke lstrcpy,addr buffer,eax
	invoke lstrcat,addr buffer,addr szBS
	invoke lstrlen,addr buffer
	invoke SendMessage,hCtl,LB_GETTEXT,nInx,addr buffer[eax]
	invoke CreateFile,addr buffer,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileTime,hFile,NULL,NULL,addr lwt
		invoke CloseHandle,hFile
		invoke FileTimeToSystemTime,addr lwt,addr slwt
		;day
		movzx	eax,slwt.wDay
		push	eax
		;month
		movzx	eax,slwt.wMonth
		push	eax
		;year
		movzx	eax,slwt.wYear
		push	eax
		push	offset szDateFormat
		lea		eax,buffer1
		push	eax
		call	wsprintf
		add		esp,3*4
		invoke SetDlgItemText,hWin,IDC_STCDATE,addr buffer1
		invoke GetFileVersionInfoSize,addr buffer,addr lpHandle
		.if eax
			mov		nBytes,eax
			invoke GlobalAlloc,GMEM_ZEROINIT or GMEM_FIXED,nBytes
			mov		hMem,eax
			invoke GetFileVersionInfo,addr buffer,0,nBytes,hMem
			.if eax
				invoke VerQueryValue,hMem,addr szVarTrans,addr lpBuffer,addr nBytes
				.if eax
					mov		eax,lpBuffer
					mov		eax,[eax]
					movzx	edx,ax
					shr		eax,16
					mov		nLang,edx
					mov		nCP,eax
					;FileDescription
					invoke wsprintf,addr buffer,addr szFileStringFormat,nLang,nCP,addr szFileDescription
					invoke VerQueryValue,hMem,addr buffer,addr lpBuffer,addr nBytes
					.if eax
						mov		eax,lpBuffer
						invoke SetDlgItemText,hWin,IDC_STCDESC,eax
					.endif
					;LegalCopyright
					invoke wsprintf,addr buffer,addr szFileStringFormat,nLang,nCP,addr szLegalCopyright
					invoke VerQueryValue,hMem,addr buffer,addr lpBuffer,addr nBytes
					.if eax
						mov		eax,lpBuffer
						invoke SetDlgItemText,hWin,IDC_STCAUTHOR,eax
					.endif
					;FileVersion
					invoke wsprintf,addr buffer,addr szFileStringFormat,nLang,nCP,addr szFileVersion
					invoke VerQueryValue,hMem,addr buffer,addr lpBuffer,addr nBytes
					.if eax
						mov		eax,lpBuffer
						invoke SetDlgItemText,hWin,IDC_STCVERSION,eax
					.endif
				.endif
			.endif
			invoke GlobalFree,hMem
		.endif
	.endif
	ret

GetInfo endp

GetHelp proc uses ebx,hWin:HWND

	invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETCURSEL,0,0
	push	eax
	mov		eax,lpData
	invoke lstrcpy,offset help,[eax].ADDINDATA.lpAddIn
	invoke lstrcat,offset help,offset szHelp
	invoke lstrlen,offset help
	pop		edx
	invoke SendDlgItemMessage,hWin,IDC_LSTADDINS,LB_GETTEXT,edx,addr help[eax]
	invoke lstrlen,offset help
	lea		ebx,help[eax-4]
	mov		nHelp,1
	mov		dword ptr [ebx],'plh.'
	invoke GetFileAttributes,offset help
	.if eax==-1
		mov		nHelp,2
		mov		dword ptr [ebx],'mhc.'
		invoke GetFileAttributes,offset help
		.if eax==-1
			mov		nHelp,3
			mov		dword ptr [ebx],'mth.'
			invoke GetFileAttributes,offset help
			.if eax==-1
				mov		nHelp,4
				mov		dword ptr [ebx],'txt.'
				invoke GetFileAttributes,offset help
				.if eax==-1
					mov		nHelp,0
					xor		ebx,ebx
				.endif
			.endif
		.endif
	.endif
	invoke GetDlgItem,hWin,IDC_BTNHELP
	invoke EnableWindow,eax,ebx
	ret

GetHelp endp

DialogProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hCtl:HWND
	LOCAL	nInx:DWORD
	LOCAL	rect:RECT
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		xor		eax,eax
		call	InitDialog
		push	FALSE
		push	offset szAppName
		push	hWin
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpSetLanguage
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if eax==BN_CLICKED
			.if edx==IDOK
				invoke SaveIniOpt,hWin
				call	Compact
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif edx==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif edx==IDC_BTNAPPLY
				invoke SaveIniOpt,hWin
				call	Compact
				invoke GetDlgItem,hWin,IDC_LSTADDINS
				mov		hCtl,eax
				invoke SendMessage,hCtl,WM_SETREDRAW,FALSE,0
				invoke SendMessage,hCtl,LB_GETTOPINDEX,0,0
				push	eax
				invoke SendMessage,hCtl,LB_GETCURSEL,0,0
				call	InitDialog
				pop		eax
				invoke SendMessage,hCtl,LB_SETTOPINDEX,eax,0
				invoke SendMessage,hCtl,WM_SETREDRAW,TRUE,0
				invoke GetDlgItem,hWin,IDC_BTNAPPLY
				invoke EnableWindow,eax,FALSE
			.elseif edx==IDC_BTNINSTALL || edx==IDC_BTNUNINSTALL
				invoke GetDlgItem,hWin,IDC_LSTADDINS
				mov		hCtl,eax
				invoke SendMessage,hCtl,LB_GETCURSEL,0,0
				mov		nInx,eax
				invoke SendMessage,hCtl,LB_GETITEMDATA,nInx,0
				xor		[eax].ADDINSTATE.fInst,TRUE
				invoke InvalidateRect,hCtl,NULL,FALSE
				invoke SetFocus,hCtl
				invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTADDINS,hCtl
				invoke GetDlgItem,hWin,IDC_BTNAPPLY
				invoke EnableWindow,eax,TRUE
			.elseif edx==IDC_BTNHELP
				invoke GetModuleHandle, addr szShellLib
				.if eax
					invoke GetProcAddress, eax, addr szShellEx
					.if eax
						push	SW_SHOWNORMAL
						push	NULL
						push	NULL
						push	offset help
						push	offset szOpen
						push	hWin
						call	eax
					.endif
				.endif
;				invoke ShellExecute,hWin,addr szOpen,addr help,NULL,NULL,SW_SHOWNORMAL
			.elseif edx>=IDC_CHK1 && edx<=IDC_CHK16
				invoke SetAddinOptions,hWin,edx
				invoke GetDlgItem,hWin,IDC_BTNAPPLY
				invoke EnableWindow,eax,TRUE
			.endif
		.elseif eax==LBN_SELCHANGE
			invoke SendMessage,lParam,LB_GETCURSEL,0,0
			.if eax!=LB_ERR
				invoke SendMessage,lParam,LB_GETITEMDATA,eax,0
				.if [eax].ADDINSTATE.fInst
					invoke GetDlgItem,hWin,IDC_BTNINSTALL
					invoke EnableWindow,eax,FALSE
					invoke GetDlgItem,hWin,IDC_BTNUNINSTALL
					invoke EnableWindow,eax,TRUE
				.else
					invoke GetDlgItem,hWin,IDC_BTNINSTALL
					invoke EnableWindow,eax,TRUE
					invoke GetDlgItem,hWin,IDC_BTNUNINSTALL
					invoke EnableWindow,eax,FALSE
				.endif
			.endif
			invoke GetAddinOptions,hWin
			invoke GetInfo,hWin
			invoke GetHelp,hWin
		.elseif eax==LBN_DBLCLK
			invoke SendMessage,hWin,WM_COMMAND,(BN_CLICKED shl 16) or IDC_BTNINSTALL,0
		.endif
	.elseif eax==WM_DRAWITEM
		push	esi
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		test	[esi].itemState,ODS_SELECTED
		.if ZERO?
			push	COLOR_WINDOW
			mov		eax,COLOR_WINDOWTEXT
		.else
			push	COLOR_HIGHLIGHT
			mov		eax,COLOR_HIGHLIGHTTEXT
		.endif
		invoke GetSysColor,eax
		invoke SetTextColor,[esi].hdc,eax
		pop		eax
		invoke GetSysColor,eax
		invoke SetBkColor,[esi].hdc,eax
		invoke ExtTextOut,[esi].hdc,0,0,ETO_OPAQUE,addr [esi].rcItem,NULL,0,NULL
		mov		eax,[esi].rcItem.left
		inc		eax
		mov		rect.left,eax
		add		eax,13
		mov		rect.right,eax
		mov		eax,[esi].rcItem.top
		inc		eax
		mov		rect.top,eax
		add		eax,13
		mov		rect.bottom,eax
		mov		eax,[esi].itemData
		.if [eax].ADDINSTATE.fInst
			mov		eax,DFCS_BUTTONCHECK or DFCS_FLAT or DFCS_CHECKED
		.else
			mov		eax,DFCS_BUTTONCHECK or DFCS_FLAT
		.endif
		invoke DrawFrameControl,[esi].hdc,addr rect,DFC_BUTTON,eax
		invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr buffer
		invoke lstrlen,addr buffer
		sub		eax,4
		mov		ecx,[esi].rcItem.top
		inc		ecx
		mov		edx,[esi].rcItem.left
		add		edx,17
		invoke TextOut,[esi].hdc,edx,ecx,addr buffer,eax
		assume esi:nothing
		pop		esi
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

Compact:
	push	esi
	push	edi
	mov		esi,lpData
	mov		esi,[esi].ADDINDATA.lpAddins
	mov		edi,esi
	xor		ecx,ecx
	xor		edx,edx
	.while ecx<MAX_ADDIN
		.if [esi].ADDIN.hDLL
			mov		eax,[esi].ADDIN.hDLL
			mov		[edi].ADDIN.hDLL,eax
			mov		eax,[esi].ADDIN.fhook1
			mov		[edi].ADDIN.fhook1,eax
			mov		eax,[esi].ADDIN.fhook2
			mov		[edi].ADDIN.fhook2,eax
			mov		eax,[esi].ADDIN.fOpt
			mov		[edi].ADDIN.fOpt,eax
			mov		eax,[esi].ADDIN.lpDllProc
			mov		[edi].ADDIN.lpDllProc,eax
			mov		eax,[esi].ADDIN.inx
			mov		[edi].ADDIN.inx,eax
			add		edi,sizeof ADDIN
			inc		edx
		.endif
		add		esi,sizeof ADDIN
		inc		ecx
	.endw
	.while edx<MAX_ADDIN
		xor		eax,eax
		mov		[edi].ADDIN.hDLL,eax
		mov		[edi].ADDIN.fhook1,eax
		mov		[edi].ADDIN.fhook2,eax
		mov		[edi].ADDIN.fOpt,eax
		mov		[edi].ADDIN.lpDllProc,eax
		mov		[edi].ADDIN.inx,eax
		add		edi,sizeof ADDIN
		inc		edx
	.endw
	pop		edi
	pop		esi
	retn

InitDialog:
	push	eax
	invoke RtlZeroMemory,offset ais,sizeof ais
	invoke GetDlgItem,hWin,IDC_LSTADDINS
	mov		hCtl,eax
	invoke ListDlls,hCtl
	pop		eax
	invoke SendMessage,hCtl,LB_SETCURSEL,eax,0
	invoke SendMessage,hWin,WM_COMMAND,(LBN_SELCHANGE shl 16) or IDC_LSTADDINS,hCtl
	retn

DialogProc endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	mii:MENUITEMINFO
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov		eax, uMsg
	.if eax == AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if edx == IDAddIn && eax == BN_CLICKED
			; Your addin has been selected
			push	NULL
			push	offset DialogProc
			push	hWin
			push	IDD_DLGADDINMANA
			push	hInstance
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpModalDialog
		.endif
	.elseif eax==AIM_CLOSE
		;Always return FALSE
		;Now is the time to kill timers, free memory, destroy windows, unhook, delete menuitems and delete toolbar buttons
		.if IDAddIn
			mov		eax,lpHandles
			mov		eax,[eax].ADDINHANDLES.hMenu
			invoke DeleteMenu,eax,IDAddIn,MF_BYCOMMAND
			mov		IDAddIn,0
		.endif
	.elseif eax==AIM_ADDINSLOADED
		;Update menu text
		push	sizeof buffer/2
		lea		eax,buffer
		push	eax
		push	2000
		push	offset szAppName
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpGetLangString
		.if eax
			mov		mii.cbSize,sizeof MENUITEMINFO
			mov		mii.fMask,MIIM_TYPE
			mov		mii.fType,MFT_STRING
			lea		eax,buffer
			mov		mii.dwTypeData,eax
			mov		edx,lpHandles
			invoke SetMenuItemInfoW,[edx].ADDINHANDLES.hMenu,IDAddIn,FALSE,addr mii
		.endif
	.endif
	mov		eax,FALSE
	ret

DllProc Endp

;#########################################################################

End DllEntry
