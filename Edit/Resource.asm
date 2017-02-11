
IDD_DLGRESOURCE			equ 3600
IDC_GRDRESOURCE			equ 3601
IDC_BTNRESEXPORT		equ 3602
IDC_BTNRESADD			equ 3603
IDC_BTNRESDELETE		equ 3604

RESROW struct
	nType		dd ?
	lpszName	dd ?
	nID			dd ?
	lpszFile	dd ?
RESROW ends

.data

szResourceType			db 'BITMAP   ,CURSOR   ,ICON     ,IMAGE    ,MIDI     ,WAVE     ,AVI      ,RCDATA   ,MANIFEST ,FONT     ,ANICURSOR,RT_HTML  ',0
szManifest				db 'MANIFEST ',0
szResRc					db 'Res.rc',0

.data?

hResGrd					dd ?

.code

ResourceSave proc uses ebx edi
	LOCAL	nRows:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	invoke GlobalLock,eax
	mov		edi,eax
	push	edi
	invoke SendMessage,hResGrd,GM_GETROWCOUNT,0,0
	mov		nRows,eax
	xor		ebx,ebx
	.while ebx<nRows
		lea		eax,[ebx+1]
		invoke BinToDec,eax,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,'='
		stosb

		mov		ecx,ebx
		shl		ecx,16
		add		ecx,1
		invoke SendMessage,hResGrd,GM_GETCELLDATA,ecx,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,2
		invoke SendMessage,hResGrd,GM_GETCELLDATA,ecx,edi
		invoke BinToDec,[edi],edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		mov		ecx,ebx
		shl		ecx,16
		invoke SendMessage,hResGrd,GM_GETCELLDATA,ecx,edi
		invoke BinToDec,[edi],edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,3
		invoke SendMessage,hResGrd,GM_GETCELLDATA,ecx,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,0
		stosb
		inc		ebx
	.endw
	mov		al,0
	stosb
	pop		edi
	invoke WritePrivateProfileSection,addr iniResource,edi,addr ProjectFile
	invoke GlobalUnlock,edi
	invoke GlobalFree,edi
	ret

ResourceSave endp

ResourceExport proc uses edi,fOut:DWORD
	LOCAL	buffer[MAX_PATH+128]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	buffer3[64]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	nMiss:DWORD
	LOCAL	hWrMem:DWORD
	LOCAL	fManifest:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov     hWrMem,eax
	invoke GlobalLock,hWrMem
	mov		edi,hWrMem
	mov		fManifest,FALSE
	xor		eax,eax
	mov		nInx,eax
	mov		nMiss,eax
	;#define
	.while nInx<256
		inc		nInx
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniResource,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		.if eax
			mov		nMiss,0
			;Name
			invoke iniGetItem,addr buffer,addr buffer1
			;ID
			invoke iniGetItem,addr buffer,addr buffer2
			;Type
			invoke iniGetItem,addr buffer,addr buffer3
			.if !fManifest && buffer3=='8'
				mov		fManifest,TRUE
				mov		dword ptr buffer2,'42'
				invoke strcpy,addr buffer1,offset szManifest
				dec		nInx
			.endif
			invoke DecToBin,addr buffer2
			;Must have both name and ID
			.if eax && buffer1
				invoke SaveStr,edi,addr szDEFINE
				add		edi,eax
				mov		al,' '
				stosb
				invoke SaveStr,edi,addr buffer1
				add		edi,eax
				sub		eax,39-8
				neg		eax
				.if eax>80000000h
					xor		eax,eax
				.endif
				xor		edx,edx
				idiv	TabSize
				inc		eax
				mov		ecx,eax
				mov		al,09h
				rep stosb
				invoke SaveStr,edi,addr buffer2
				add		edi,eax
				mov		ax,0A0Dh
				stosw
			.endif
		.else
			inc		nMiss
			.break .if nMiss>10
		.endif
	.endw
	xor		eax,eax
	mov		nInx,eax
	mov		nMiss,eax
	.while nInx<256
		inc		nInx
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniResource,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		.if eax
			mov		nMiss,0
			;Name
			invoke iniGetItem,addr buffer,addr buffer1
			;ID
			invoke iniGetItem,addr buffer,addr buffer2
			.if buffer1
				;Name
				lea		eax,buffer1
			.else
				;ID
				lea		eax,buffer2
			.endif
			invoke SaveStr,edi,eax
			add		edi,eax
			sub		eax,23
			neg		eax
			.if sdword ptr eax<0
				xor		eax,eax
			.endif
			xor		edx,edx
			idiv	TabSize
			inc		eax
			mov		ecx,eax
			mov		al,09h
			rep stosb
			invoke iniGetItem,addr buffer,addr buffer1
			invoke DecToBin,addr buffer1
			push	eax
			invoke strcpy,addr buffer1,offset szResourceType
			pop		eax
			inc		eax
			.while eax
				push	eax
				invoke iniGetItem,addr buffer1,addr buffer2
				pop		eax
				dec		eax
			.endw
			invoke SaveStr,edi,addr buffer2
			add		edi,eax
			mov		al,' '
			stosb
			invoke SaveStr,edi,addr szDISCARDABLE
			add		edi,eax
			mov		al,' '
			stosb
			mov		al,'"'
			stosb
			lea		eax,buffer
			.while byte ptr [eax]
				.if byte ptr [eax]=='\'
					mov		byte ptr [eax],'/'
				.endif
				inc		eax
			.endw
			invoke SaveStr,edi,addr buffer
			add		edi,eax
			mov		al,'"'
			stosb
			mov		ax,0A0Dh
			stosw
		.else
			inc		nMiss
			.break .if nMiss>10
		.endif
	.endw
	.if fOut
		invoke OutputSelect,2
		invoke OutputClear
		invoke ShowOutput
		invoke TextToOutput,hWrMem
	.else
		invoke GetPrivateProfileString,addr iniProject,addr szResRc,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		.if !eax
			;Delete resources from main RC
			mov		dword ptr buffer,'1'
			invoke WritePrivateProfileString,addr iniProject,addr szResRc,addr buffer,addr ProjectFile
			mov		dword ptr buffer,0
			invoke DllProc,hWnd,AIM_RCUPDATE,1,addr buffer,RAM_RCUPDATE
		.endif
		mov		word ptr buffer,'0'
		invoke GetPrivateProfileString,addr iniMakeFile,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		invoke strlen,addr buffer
		sub		eax,4
		mov		byte ptr buffer[eax],0
		invoke strcpy,addr buffer1,addr ProjectPath
		invoke strcat,addr buffer1,addr szRes
		invoke strcat,addr buffer1,addr buffer
		invoke strcat,addr buffer1,addr szResRc
		invoke GetFileAttributes,addr buffer1
		.if eax==-1
			invoke DllProc,hWnd,AIM_PROJECTADDNEW,-2,addr ProjectFile,RAM_PROJECTADDNEW
		.endif
		invoke CreateFile,addr buffer1,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strlen,hWrMem
			mov		nBytes,eax
			invoke WriteFile,hFile,hWrMem,nBytes,addr nBytes,NULL
			invoke CloseHandle,hFile
			inc		fResChanged
			invoke DllProc,hWnd,AIM_RCSAVED,4,addr buffer1,RAM_RCSAVED
		.endif
	.endif
	invoke GlobalUnlock,hWrMem
	invoke GlobalFree,hWrMem
	ret

ResourceExport endp

ResourceProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	col:COLUMN
	LOCAL	row:RESROW
	LOCAL	nInx:DWORD
	LOCAL	nMiss:DWORD
	LOCAL	buffer[MAX_PATH+128]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	buffer2[64]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_GRDRESOURCE
		mov		hResGrd,eax
		invoke SendMessage,hResGrd,GM_SETBACKCOLOR,radcol.project,0
		invoke SendMessage,hResGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hResGrd,GM_SETTEXTCOLOR,radcol.projecttext,0
		;Add Type column
		invoke CalcSize,100
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrType
		mov		col.halign,ALIGN_LEFT
		mov		col.calign,ALIGN_LEFT
		mov		col.ctype,TYPE_COMBOBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hResGrd,GM_ADDCOL,0,addr col
		invoke strcpy,addr buffer,addr szResourceType
		.while byte ptr buffer
			invoke iniGetItem,addr buffer,addr buffer1
			invoke SendMessage,hResGrd,GM_COMBOADDSTRING,0,addr buffer1
		.endw
		;Add Name column
		invoke CalcSize,100
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrName
		mov		col.halign,ALIGN_LEFT
		mov		col.calign,ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,31
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hResGrd,GM_ADDCOL,0,addr col
		;Add ID column
		invoke CalcSize,50
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrID
		mov		col.halign,ALIGN_RIGHT
		mov		col.calign,ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,6
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hResGrd,GM_ADDCOL,0,addr col
		;Add File column
		invoke CalcSize,150
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrFile
		mov		col.halign,ALIGN_LEFT
		mov		col.calign,ALIGN_LEFT
		mov		col.ctype,TYPE_BUTTON
		mov		col.ctextmax,MAX_PATH
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hResGrd,GM_ADDCOL,0,addr col
		xor		eax,eax
		mov		nInx,eax
		mov		nMiss,eax
		.while nInx<256
			inc		nInx
			invoke BinToDec,nInx,addr buffer1
			invoke GetPrivateProfileString,addr iniResource,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
			.if eax
				mov		nMiss,0
				;Name
				invoke iniGetItem,addr buffer,addr buffer2
				lea		eax,buffer2
				mov		row.lpszName,eax
				;ID
				invoke iniGetItem,addr buffer,addr buffer1
				invoke DecToBin,addr buffer1
				mov		row.nID,eax
				;Type
				invoke iniGetItem,addr buffer,addr buffer1
				invoke DecToBin,addr buffer1
				mov		row.nType,eax
				;File
				lea		eax,buffer
				mov		row.lpszFile,eax
				invoke SendMessage,hResGrd,GM_ADDROW,0,addr row
			.else
				inc		nMiss
				.break .if nMiss>10
			.endif
		.endw
		invoke SendMessage,hResGrd,GM_SETCURSEL,0,0
		invoke SetLanguage,hWin,IDD_DLGRESOURCE,FALSE
	.elseif eax==WM_COMMAND
		invoke SetFocus,hResGrd
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke ResourceSave
				invoke ResourceExport,FALSE
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNRESEXPORT
				invoke ResourceSave
				invoke ResourceExport,TRUE
			.elseif eax==IDC_BTNRESADD
				invoke SendMessage,hResGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hResGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hResGrd
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNRESDELETE
				invoke SendMessage,hResGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hResGrd,GM_DELROW,eax,0
				pop		eax
				invoke SendMessage,hResGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hResGrd
				xor		eax,eax
				jmp		Ex
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		push	esi
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if eax==hResGrd
			mov		eax,[esi].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hResGrd,GM_COLUMNSORT,[esi].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BUTTONCLICK
				;Cell button clicked
				invoke strcpy,addr buffer,[esi].GRIDNOTIFY.lpdata
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ecx,[esi].GRIDNOTIFY.row
				shl		ecx,16
				invoke SendMessage,hResGrd,GM_GETCELLDATA,ecx,addr buffer2
				mov		eax,dword ptr buffer2
				.if eax==0
					mov		eax,offset BMPFilterString
				.elseif eax==1
					mov		eax,offset CURFilterString
				.elseif eax==2
					mov		eax,offset ICOFilterString
				.elseif eax==3
					mov		eax,offset IMGFilterString
				.elseif eax==4
					mov		eax,offset MIDFilterString
				.elseif eax==5
					mov		eax,offset WAVFilterString
				.elseif eax==6
					mov		eax,offset AVIFilterString
				.elseif eax==7
					mov		eax,offset RCDFilterString
				.elseif eax==8
					mov		eax,offset XMLFilterString
				.elseif eax==9
					mov		eax,offset FNTFilterString
				.elseif eax==10
					mov		eax,offset ANIFilterString
				.elseif eax==11
					mov		eax,offset HTMLFilterString
				.else
					xor		eax,eax
				.endif
				mov		ofn.lpstrFilter,eax
				mov		ofn.lpstrDefExt,NULL
				mov		ofn.lpstrInitialDir,offset ProjectPath
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke RemovePath,addr buffer,offset ProjectPath,addr buffer1
					mov		edx,[esi].GRIDNOTIFY.lpdata
					invoke strcpy,edx,eax
					mov		[esi].GRIDNOTIFY.fcancel,FALSE
				.else
					mov		[esi].GRIDNOTIFY.fcancel,TRUE
				.endif
			.endif
		.endif
		pop		esi
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

ResourceProc endp
