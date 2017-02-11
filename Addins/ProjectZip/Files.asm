.data?

wfd					WIN32_FIND_DATA <>

.code

SetZipFile proc uses ebx esi,lpFileName:DWORD

	mov		esi,lpFileName
	invoke lstrlen,esi
	mov		ebx,eax
	sub		ebx,4
	mov		eax,[esi+ebx]
	and		eax,5F5F5FFFh
	.if eax=='PAR.'
		mov		szZipFile,'\'
		inc		ebx
		invoke lstrcpyn,offset szZipFile+1,esi,ebx
		lea		esi,szZipFile[ebx]
		.if fOption&2
			invoke GetDateFormat,NULL,NULL,NULL,offset szDateFmtFile,esi,7
			add		esi,6
		.endif
		mov		dword ptr [esi],'piz.'
		mov		byte ptr [esi+4],0
	.endif
	ret

SetZipFile endp

FileDir proc uses ebx esi edi,lpPth:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hwfd:DWORD
	LOCAL	lvi:LV_ITEM
	LOCAL	pMem:DWORD
	LOCAL	syst:SYSTEMTIME

	mov		szZipFile,0
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,128*1024
	mov		pMem,eax
	mov		esi,eax
	;Make the path local
	invoke lstrcpy,addr buffer,lpPth
	;Check if path ends with '\'. If not, add.
	invoke lstrlen,addr buffer
	dec		eax
	.if buffer[eax]!='\'
		;Add '\'
		inc		eax
		mov		buffer[eax],'\'
	.endif
	;Add '*.*'
	inc		eax
	mov		dword ptr buffer[eax],'*.*'
	;Find first match, if any
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		;Save returned handle
		mov		hwfd,eax
	  Next:
		;Check if found is a dir
		mov		eax,wfd.dwFileAttributes
		and		eax,FILE_ATTRIBUTE_DIRECTORY
		.if eax
			;Do not include '.' and '..'
			mov		ax,word ptr wfd.cFileName
			.if ax!='.'
				.if ax=='..'
					mov		buffer,'.'
				.else
					mov		buffer,'D'
				.endif
				invoke lstrcpy,addr buffer[1],addr wfd.cFileName
				invoke SendMessage,hLB,LB_ADDSTRING,0,addr buffer
			.endif
		.else
			invoke SetZipFile,addr wfd.cFileName
			;Add file
			mov		buffer,'F'
			invoke lstrcpy,addr buffer[1],addr wfd.cFileName
			invoke SendMessage,hLB,LB_ADDSTRING,0,addr buffer
		.endif
		invoke SendMessage,hLB,LB_SETITEMDATA,eax,esi
		mov		eax,wfd.nFileSizeLow
		mov		[esi].FILEINFO.dwSizeLow,eax
		mov		eax,wfd.nFileSizeHigh
		mov		[esi].FILEINFO.dwSizeHigh,eax
		mov		eax,wfd.ftLastWriteTime.dwLowDateTime
		mov		[esi].FILEINFO.dwTimeLow,eax
		mov		eax,wfd.ftLastWriteTime.dwHighDateTime
		mov		[esi].FILEINFO.dwTimeHigh,eax
		add		esi,sizeof FILEINFO
		;Any more matches?
		invoke FindNextFile,hwfd,addr wfd
		or		eax,eax
		jne		Next
		;No more matches, close handle
		invoke FindClose,hwfd
	.endif
	invoke SendMessage,hLV,LVM_DELETEALLITEMS,0,0
	xor		ebx,ebx
  @@:
	invoke SendMessage,hLB,LB_GETTEXT,ebx,addr buffer
	.if eax!=LB_ERR
		invoke SendMessage,hLB,LB_GETITEMDATA,ebx,0
		mov		esi,eax
		mov		lvi.imask,LVIF_TEXT or LVIF_IMAGE
		mov		lvi.iItem,ebx
		mov		lvi.iSubItem,0
		lea		eax,buffer[1]
		mov		lvi.pszText,eax
		movzx	eax,buffer
		.if eax=='.'
			mov		lvi.iImage,0
		.elseif eax=='D'
			mov		lvi.iImage,1
		.else
			mov		lvi.iImage,2
		.endif
		push	eax
		invoke SendMessage,hLV,LVM_INSERTITEM,0,addr lvi
		pop		eax
		.if eax=='F'
			;Size
			push	[esi].FILEINFO.dwSizeLow
			push	offset szSizeFmt
			lea		eax,buffer
			push	eax
			call	wsprintfA
			add		esp,3*4
			mov		lvi.imask,LVIF_TEXT
			mov		lvi.iItem,ebx
			mov		lvi.iSubItem,1
			lea		eax,buffer
			mov		lvi.pszText,eax
			invoke SendMessage,hLV,LVM_SETITEM,0,addr lvi
			xor		eax,eax
		.endif
		.if eax!='.'
			lea		edi,[esi].FILEINFO.dwTimeLow
			invoke FileTimeToLocalFileTime,edi,edi
			invoke FileTimeToSystemTime,edi,addr syst
			lea		edi,syst
			;Date
			invoke GetDateFormat,NULL,NULL,edi,offset szDateFmt,addr buffer,sizeof buffer
			;Time
			invoke GetTimeFormat,NULL,TIME_FORCE24HOURFORMAT,edi,offset szTimeFmt,addr buffer[11],sizeof buffer-11
			mov		lvi.imask,LVIF_TEXT
			mov		lvi.iItem,ebx
			mov		lvi.iSubItem,2
			lea		eax,buffer
			mov		lvi.pszText,eax
			invoke SendMessage,hLV,LVM_SETITEM,0,addr lvi
		.endif
		inc		ebx
		jmp		@b
	.endif
	invoke GlobalFree,pMem
	invoke SendMessage,hLB,LB_RESETCONTENT,0,0
	invoke lstrcpy,addr buffer,offset szDestFolder
	invoke lstrcat,addr buffer,offset szZipFile
	invoke SendMessage,hED,WM_SETTEXT,0,addr buffer
	invoke SetDlgItemText,hDlg,IDC_EDTCURRENT,lpPth
	invoke GetDlgItem,hDlg,IDC_BTNZIP
	invoke EnableWindow,eax,FALSE
	invoke GetDlgItem,hDlg,IDC_BTNMAIL
	invoke EnableWindow,eax,FALSE
	ret

FileDir endp

