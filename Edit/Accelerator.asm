IDD_DLGACCELERATOR				equ 4700
IDC_BTNACLDEL					equ 4701
IDC_BTNACLADD					equ 4702
IDC_BTNACLEXP					equ 4703
IDC_GRDACLEDT					equ 4704
IDC_EDTACLID					equ 4705
IDC_EDTACLNAME					equ 4706

.const

szAclRc				db 'Acl.rc',0

.data?

hAclEdtGrd		dd ?

.code

AccelEditSave proc uses ebx esi edi,hWin:HWND
	LOCAL	nRows:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
	invoke GlobalLock,eax
	mov		edi,eax
	push	edi
	;Name
	invoke strcpy,edi,addr iniVerNme
	invoke strlen,edi
	lea		edi,[edi+eax]
	mov		al,'='
	stosb
	invoke GetDlgItemText,hWin,IDC_EDTACLNAME,edi,32
	invoke strlen,edi
	lea		edi,[edi+eax]
	mov		al,0
	stosb
	;ID
	invoke strcpy,edi,addr iniVerID
	invoke strlen,edi
	lea		edi,[edi+eax]
	mov		al,'='
	stosb
	invoke GetDlgItemText,hWin,IDC_EDTACLID,edi,5
	invoke strlen,edi
	lea		edi,[edi+eax]
	mov		al,0
	stosb

	invoke SendMessage,hAclEdtGrd,GM_GETROWCOUNT,0,0
	mov		nRows,eax
	xor		ebx,ebx
	.while ebx<nRows
		lea		eax,[ebx+1]
		invoke BinToDec,eax,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,'='
		stosb

		;Name
		mov		ecx,ebx
		shl		ecx,16
		invoke SendMessage,hAclEdtGrd,GM_GETCELLDATA,ecx,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		;ID
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,1
		invoke SendMessage,hAclEdtGrd,GM_GETCELLDATA,ecx,edi
		invoke BinToDec,[edi],edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		;Key
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,2
		invoke SendMessage,hAclEdtGrd,GM_GETCELLDATA,ecx,edi
		mov		esi,offset szAclKeys
		mov		eax,[edi]
		.while eax
			push	eax
			inc		esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			pop		eax
			dec		eax
		.endw
		movzx	eax,byte ptr [esi]
		invoke BinToDec,eax,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		;Ctrl
		xor		esi,esi
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,3
		invoke SendMessage,hAclEdtGrd,GM_GETCELLDATA,ecx,edi
		.if dword ptr [edi]
			or		esi,FCONTROL
		.endif
		;Shift
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,4
		invoke SendMessage,hAclEdtGrd,GM_GETCELLDATA,ecx,edi
		.if dword ptr [edi]
			or		esi,FSHIFT
		.endif
		;Alt
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,5
		invoke SendMessage,hAclEdtGrd,GM_GETCELLDATA,ecx,edi
		.if dword ptr [edi]
			or		esi,FALT
		.endif
		invoke BinToDec,esi,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,0
		stosb
		inc		ebx
	.endw
	mov		al,0
	stosb
	stosb
	pop		edi
	invoke WritePrivateProfileSection,addr iniAccel,edi,addr ProjectFile
	invoke GlobalUnlock,edi
	invoke GlobalFree,edi
	ret

AccelEditSave endp

AccelEditExport proc uses esi edi,fOut:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[64]:BYTE
	LOCAL	buffer2[64]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	nMiss:DWORD
	LOCAL	hWrMem:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,1024*16
	mov     hWrMem,eax
	invoke GlobalLock,hWrMem
	mov		edi,hWrMem
    invoke GetPrivateProfileString,addr iniAccel,addr iniVerNme,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
	.if eax
		invoke SaveStr,edi,addr szDEFINE
		add		edi,eax
		mov		al,' '
		stosb
		;Name
		invoke strcpy,edi,addr buffer
		invoke strlen,edi
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
		;ID
		invoke GetPrivateProfileInt,addr iniAccel,addr iniVerID,1,addr ProjectFile
		invoke BinToDec,eax,edi
		invoke strlen,edi
		add		edi,eax
		mov		ax,0A0Dh
		stosw
	.endif
	xor		eax,eax
	mov		nInx,eax
	mov		nMiss,eax
	;#define
	.while nInx<512
		inc		nInx
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniAccel,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
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
    invoke GetPrivateProfileString,addr iniAccel,addr iniVerNme,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
	.if buffer
		;Name
		invoke strcpy,edi,addr buffer
	.else
		;ID
		invoke GetPrivateProfileInt,addr iniAccel,addr iniVerID,1,addr ProjectFile
		invoke BinToDec,eax,edi
	.endif
	invoke strlen,edi
	add		edi,eax
	mov		al,' '
	stosb
	invoke SaveStr,edi,addr szACCELERATOR
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
		invoke GetPrivateProfileString,addr iniAccel,addr buffer1,addr szNULL,addr buffer,sizeof buffer,addr ProjectFile
		.if eax
			mov		nMiss,0
			mov		ax,'  '
			stosw
			;Name
			invoke iniGetItem,addr buffer,addr buffer1
			;ID
			invoke iniGetItem,addr buffer,addr buffer2
			;Key
			invoke iniGetItem,addr buffer,edi
			invoke strlen,edi
			lea		edi,[edi+eax]
			mov		al,','
			stosb
			.if buffer1
				;Name
				lea		eax,buffer1
			.else
				;ID
				lea		eax,buffer2
			.endif
			invoke SaveStr,edi,eax
			add		edi,eax
			mov		al,','
			stosb
			invoke SaveStr,edi,addr szVIRTKEY
			add		edi,eax
			mov		al,','
			stosb
			invoke SaveStr,edi,addr szNOINVERT
			add		edi,eax
			invoke DecToBin,addr buffer
			mov		esi,eax
			test	esi,FSHIFT
			.if !ZERO?
				mov		al,','
				stosb
				invoke SaveStr,edi,addr szSHIFT
				add		edi,eax
			.endif
			test	esi,FCONTROL
			.if !ZERO?
				mov		al,','
				stosb
				invoke SaveStr,edi,addr szCONTROL
				add		edi,eax
			.endif
			test	esi,FALT
			.if !ZERO?
				mov		al,','
				stosb
				invoke SaveStr,edi,addr szALT
				add		edi,eax
			.endif
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
		invoke strcat,addr buffer1,addr szAclRc
		invoke GetFileAttributes,addr buffer1
		.if eax==-1
			invoke DllProc,hWnd,AIM_PROJECTADDNEW,-4,addr ProjectFile,RAM_PROJECTADDNEW
		.endif
		invoke CreateFile,addr buffer1,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strlen,hWrMem
			mov		nBytes,eax
			invoke WriteFile,hFile,hWrMem,nBytes,addr nBytes,NULL
			invoke CloseHandle,hFile
			inc		fResChanged
			invoke DllProc,hWnd,AIM_RCSAVED,6,addr buffer1,RAM_RCSAVED
		.endif
	.endif
	invoke GlobalUnlock,hWrMem
	invoke GlobalFree,hWrMem
	ret

AccelEditExport endp

AccelEditProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[32]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	col:COLUMN
	LOCAL	row[6]:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetPrivateProfileString,addr iniAccel,addr iniVerNme,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr ProjectFile
		invoke SetDlgItemText,hWin,IDC_EDTACLNAME,addr iniBuffer
		invoke SendDlgItemMessage,hWin,IDC_EDTACLNAME,EM_LIMITTEXT,31,0
		invoke GetPrivateProfileInt,addr iniAccel,addr iniVerID,0,addr ProjectFile
		invoke SetDlgItemInt,hWin,IDC_EDTACLID,eax,FALSE
		invoke SendDlgItemMessage,hWin,IDC_EDTACLID,EM_LIMITTEXT,5,0
		invoke GetDlgItem,hWin,IDC_GRDACLEDT
		mov		hAclEdtGrd,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hAclEdtGrd,WM_SETFONT,eax,FALSE
		invoke SendMessage,hAclEdtGrd,GM_SETBACKCOLOR,radcol.project,0
		invoke SendMessage,hAclEdtGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hAclEdtGrd,GM_SETTEXTCOLOR,radcol.projecttext,0
		;Name
		invoke CalcSize,140
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrName
		mov		col.halign,ALIGN_LEFT
		mov		col.calign,ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,31
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hAclEdtGrd,GM_ADDCOL,0,addr col
		;ID
		invoke CalcSize,40
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrID
		mov		col.halign,ALIGN_RIGHT
		mov		col.calign,ALIGN_RIGHT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,5
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hAclEdtGrd,GM_ADDCOL,0,addr col
		;Keys
		invoke CalcSize,76
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrKey
		mov		col.halign,ALIGN_LEFT
		mov		col.calign,ALIGN_LEFT
		mov		col.ctype,TYPE_COMBOBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hAclEdtGrd,GM_ADDCOL,0,addr col
		;Fill Keys in the combo
		mov		esi,offset szAclKeys
		.while byte ptr [esi+1]
			inc		esi
			invoke SendMessage,hAclEdtGrd,GM_COMBOADDSTRING,2,esi
			invoke strlen,esi
			lea		esi,[esi+eax+1]
		.endw
		;Ctrl
		invoke CalcSize,38
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrCtrl
		mov		col.halign,ALIGN_CENTER
		mov		col.calign,ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hAclEdtGrd,GM_ADDCOL,0,addr col
		;Shift
		invoke CalcSize,38
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrShift
		mov		col.halign,ALIGN_CENTER
		mov		col.calign,ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hAclEdtGrd,GM_ADDCOL,0,addr col
		;Alt
		invoke CalcSize,38
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrAlt
		mov		col.halign,ALIGN_CENTER
		mov		col.calign,ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hAclEdtGrd,GM_ADDCOL,0,addr col
		mov		nInx,1
	  @@:
		invoke BinToDec,nInx,addr buffer1
		invoke GetPrivateProfileString,addr iniAccel,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr ProjectFile
		.if eax
			;Name
			invoke iniGetItem,addr iniBuffer,addr buffer1
			lea		eax,buffer1
			mov		row[0*4],eax
			;ID
			invoke iniGetItem,addr iniBuffer,addr buffer2
			invoke DecToBin,addr buffer2
			mov		row[1*4],eax
			;Key
			invoke iniGetItem,addr iniBuffer,addr buffer2
			invoke DecToBin,addr buffer2
			mov		ebx,eax
			xor		edi,edi
			mov		esi,offset szAclKeys
			.while byte ptr [esi+1]
				.if bl==[esi]
					.break
				.endif
				inc		edi
				inc		esi
				invoke strlen,esi
				lea		esi,[esi+eax+1]
			.endw
			mov		row[2*4],edi
			;Ctrl,Shift,Alt
			invoke DecToBin,addr iniBuffer
			mov		edx,eax
			and		eax,FCONTROL
			mov		row[3*4],eax
			mov		eax,edx
			and		eax,FSHIFT
			mov		row[4*4],eax
			mov		eax,edx
			and		eax,FALT
			mov		row[5*4],eax
			invoke SendMessage,hAclEdtGrd,GM_ADDROW,0,addr row
			inc		nInx
			jmp		@b
		.endif
		.if nInx>1
			invoke SendMessage,hAclEdtGrd,GM_SETCURSEL,0,0
			invoke SetFocus,hAclEdtGrd
		.endif
		invoke SetLanguage,hWin,IDD_DLGACCELERATOR,FALSE
		mov		eax,FALSE
		ret
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke AccelEditSave,hWin
				invoke AccelEditExport,FALSE
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNACLADD
				invoke SendMessage,hAclEdtGrd,GM_ADDROW,0,NULL
				invoke SendMessage,hAclEdtGrd,GM_SETCURSEL,0,eax
			.elseif eax==IDC_BTNACLDEL
				invoke SendMessage,hAclEdtGrd,GM_GETCURROW,0,0
				.if eax!=-1
					invoke SendMessage,hAclEdtGrd,GM_DELROW,eax,0
				.endif
			.elseif eax==IDC_BTNACLEXP
				invoke AccelEditSave,hWin
				invoke AccelEditExport,TRUE
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

AccelEditProc endp
