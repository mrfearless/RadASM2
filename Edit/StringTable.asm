
;Edit\StringTable.dlg
IDD_DLGSTRINGTABLE		equ 3700
IDC_GRDSTRINGTABLE		equ 3701
IDC_BTNSTRADD			equ 3703
IDC_BTNSTRDELETE		equ 3704
IDC_BTNSTREXPORT		equ 3702

STRROW struct
	lpszName	dd ?
	nID			dd ?
	lpszString	dd ?
STRROW ends

.const

iniStringTable			db 'StringTable',0
szSTRINGTABLE			db 'STRINGTABLE',0
szStrRc					db 'Str.rc',0

.data?

hStrGrd					dd ?

.code

StringTableSave proc uses ebx edi
	LOCAL	nRows:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	invoke GlobalLock,eax
	mov		edi,eax
	push	edi
	invoke SendMessage,hStrGrd,GM_GETROWCOUNT,0,0
	mov		nRows,eax
	xor		ebx,ebx
	.while ebx<nRows
		lea		eax,[ebx+1]
		invoke BinToDec,eax,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,'='
		stosb
		mov		al,'"'
		stosb
		;Name
		mov		ecx,ebx
		shl		ecx,16
		invoke SendMessage,hStrGrd,GM_GETCELLDATA,ecx,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		;ID
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,1
		invoke SendMessage,hStrGrd,GM_GETCELLDATA,ecx,edi
		invoke BinToDec,[edi],edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		;String
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,2
		invoke SendMessage,hStrGrd,GM_GETCELLDATA,ecx,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,'"'
		stosb
		mov		al,0
		stosb
		inc		ebx
	.endw
	mov		al,0
	stosb
	stosb
	pop		edi
	invoke WritePrivateProfileSection,addr iniStringTable,edi,addr ProjectFile
	invoke GlobalUnlock,edi
	invoke GlobalFree,edi
	ret

StringTableSave endp

StringTableExport proc uses edi,fOut:DWORD
	LOCAL	buffer[512+128]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	nMiss:DWORD
	LOCAL	hWrMem:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	mov     hWrMem,eax
	invoke GlobalLock,hWrMem
	mov		edi,hWrMem
	xor		eax,eax
	mov		nInx,eax
	mov		nMiss,eax
	;#define
	.while nInx<512
		inc		nInx
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniStringTable,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		.if eax
			mov		nMiss,0
			;Name
			invoke iniGetItem,addr buffer,addr buffer1
			;ID
			invoke iniGetItem,addr buffer,addr buffer2
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
	invoke SaveStr,edi,addr szSTRINGTABLE
	add		edi,eax
	mov		al,' '
	stosb
	invoke SaveStr,edi,addr szDISCARDABLE
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	invoke SaveStr,edi,addr szBEGIN
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	xor		eax,eax
	mov		nInx,eax
	mov		nMiss,eax
	.while nInx<512
		inc		nInx
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniStringTable,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		.if eax
			mov		nMiss,0
			mov		ax,'  '
			stosw
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
			sub		eax,27-2
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
			mov		al,'"'
			stosb
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
	invoke SaveStr,edi,addr szEND
	add		edi,eax
	mov		ax,0A0Dh
	stosw
	.if fOut
		invoke OutputSelect,2
		invoke OutputClear
		invoke ShowOutput
		invoke TextToOutput,hWrMem
	.else
		mov		word ptr buffer,'0'
		invoke GetPrivateProfileString,addr iniMakeFile,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		invoke strlen,addr buffer
		sub		eax,4
		mov		byte ptr buffer[eax],0
		invoke strcpy,addr buffer1,addr ProjectPath
		invoke strcat,addr buffer1,addr szRes
		invoke strcat,addr buffer1,addr buffer
		invoke strcat,addr buffer1,addr szStrRc
		invoke GetFileAttributes,addr buffer1
		.if eax==-1
			invoke DllProc,hWnd,AIM_PROJECTADDNEW,-1,addr ProjectFile,RAM_PROJECTADDNEW
		.endif
		invoke CreateFile,addr buffer1,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strlen,hWrMem
			mov		nBytes,eax
			invoke WriteFile,hFile,hWrMem,nBytes,addr nBytes,NULL
			invoke CloseHandle,hFile
			inc		fResChanged
			invoke DllProc,hWnd,AIM_RCSAVED,5,addr buffer1,RAM_RCSAVED
		.endif
	.endif
	invoke GlobalUnlock,hWrMem
	invoke GlobalFree,hWrMem
	ret

StringTableExport endp

StringTableProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	col:COLUMN
	LOCAL	row:STRROW
	LOCAL	nInx:DWORD
	LOCAL	nMiss:DWORD
	LOCAL	buffer[512+128]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	buffer2[64]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetDlgItem,hWin,IDC_GRDSTRINGTABLE
		mov		hStrGrd,eax
		invoke SendMessage,hStrGrd,GM_SETBACKCOLOR,radcol.project,0
		invoke SendMessage,hStrGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hStrGrd,GM_SETTEXTCOLOR,radcol.projecttext,0
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
		invoke SendMessage,hStrGrd,GM_ADDCOL,0,addr col
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
		invoke SendMessage,hStrGrd,GM_ADDCOL,0,addr col
		;Add String column
		invoke CalcSize,250
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrString
		mov		col.halign,ALIGN_LEFT
		mov		col.calign,ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,512
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hStrGrd,GM_ADDCOL,0,addr col
		xor		eax,eax
		mov		nInx,eax
		mov		nMiss,eax
		.while nInx<512
			inc		nInx
			invoke BinToDec,nInx,addr buffer1
			invoke GetPrivateProfileString,addr iniStringTable,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
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
				;String
				lea		eax,buffer
				mov		row.lpszString,eax
				invoke SendMessage,hStrGrd,GM_ADDROW,0,addr row
			.else
				inc		nMiss
				.break .if nMiss>10
			.endif
		.endw
		invoke SendMessage,hStrGrd,GM_SETCURSEL,0,0
		invoke SetLanguage,hWin,IDD_DLGSTRINGTABLE,FALSE
	.elseif eax==WM_COMMAND
		invoke SetFocus,hStrGrd
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke StringTableSave
				invoke StringTableExport,FALSE
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNSTREXPORT
				invoke StringTableSave
				invoke StringTableExport,TRUE
			.elseif eax==IDC_BTNSTRADD
				invoke SendMessage,hStrGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hStrGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hStrGrd
				xor		eax,eax
				jmp		Ex
			.elseif eax==IDC_BTNSTRDELETE
				invoke SendMessage,hStrGrd,GM_GETCURROW,0,0
				push	eax
				invoke SendMessage,hStrGrd,GM_DELROW,eax,0
				pop		eax
				invoke SendMessage,hStrGrd,GM_SETCURSEL,0,eax
				invoke SetFocus,hStrGrd
				xor		eax,eax
				jmp		Ex
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,[edx].NMHDR.hwndFrom
		.if eax==hStrGrd
			mov		eax,[edx].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hStrGrd,GM_COLUMNSORT,[edx].GRIDNOTIFY.col,SORT_INVERT
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
  Ex:
	ret

StringTableProc endp
