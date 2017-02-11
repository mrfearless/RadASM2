
IDD_DLGACCELOPTION	equ 4600
IDC_GRDACCEL		equ 4601
IDC_BTNACLOPTDEL	equ 3

.data?

hAclGrd				dd ?
hAclMnu				dd ?

.code

SaveAccelOption proc uses ebx esi edi
	LOCAL	buffer[8]:BYTE

	mov		dword ptr iniBuffer,'=1'
	invoke WritePrivateProfileSection,addr iniAccel,addr iniBuffer,addr iniFile
	invoke SendMessage,hAclGrd,GM_GETROWCOUNT,0,0
	mov		esi,eax
	xor		ebx,ebx
	.while ebx<esi
		mov		edi,offset iniBuffer
		mov		ecx,ebx
		shl		ecx,16
		invoke SendMessage,hAclGrd,GM_GETCELLDATA,ecx,edi
		invoke BinToDec,[edi],edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,1
		invoke SendMessage,hAclGrd,GM_GETCELLDATA,ecx,edi
		invoke strlen,edi
		lea		edi,[edi+eax]
		mov		al,','
		stosb
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,2
		invoke SendMessage,hAclGrd,GM_GETCELLDATA,ecx,edi
		push	esi
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
		xor		esi,esi
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,3
		invoke SendMessage,hAclGrd,GM_GETCELLDATA,ecx,edi
		.if dword ptr [edi]
			or		esi,FCONTROL
		.endif
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,4
		invoke SendMessage,hAclGrd,GM_GETCELLDATA,ecx,edi
		.if dword ptr [edi]
			or		esi,FSHIFT
		.endif
		mov		ecx,ebx
		shl		ecx,16
		add		ecx,5
		invoke SendMessage,hAclGrd,GM_GETCELLDATA,ecx,edi
		.if dword ptr [edi]
			or		esi,FALT
		.endif
		invoke BinToDec,esi,edi
		pop		esi
		inc		ebx
		invoke BinToDec,ebx,addr buffer
		invoke WritePrivateProfileString,addr iniAccel,addr buffer,addr iniBuffer,addr iniFile
	.endw
	invoke UpdateAccelOption,hMenu
	ret

SaveAccelOption endp

AccelOptionProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	col:COLUMN
	LOCAL	row[6]:DWORD
	LOCAL	nInx:DWORD
	LOCAL	mii:MENUITEMINFO
	LOCAL	fCtrl:DWORD
	LOCAL	fShift:DWORD
	LOCAL	fAlt:DWORD
	LOCAL	buffer[16]:BYTE
	LOCAL	buffer1[128]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetMenu,hWin
		mov		hAclMnu,eax
		invoke GetDlgItem,hWin,IDC_GRDACCEL
		mov		hAclGrd,eax
		invoke SendMessage,hWin,WM_GETFONT,0,0
		invoke SendMessage,hAclGrd,WM_SETFONT,eax,FALSE
		invoke SendMessage,hAclGrd,GM_SETBACKCOLOR,radcol.project,0
		invoke SendMessage,hAclGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hAclGrd,GM_SETTEXTCOLOR,radcol.projecttext,0
		;ID
		mov		col.colwt,0
		mov		col.lpszhdrtext,NULL
		mov		col.halign,ALIGN_LEFT
		mov		col.calign,ALIGN_LEFT
		mov		col.ctype,TYPE_EDITLONG
		mov		col.ctextmax,11
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hAclGrd,GM_ADDCOL,0,addr col
		;Caption
		invoke CalcSize,180
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szHdrCaption
		mov		col.halign,ALIGN_LEFT
		mov		col.calign,ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,63
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hAclGrd,GM_ADDCOL,0,addr col
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
		invoke SendMessage,hAclGrd,GM_ADDCOL,0,addr col
		;Fill Keys in the combo
		mov		esi,offset szAclKeys+1
		.while byte ptr [esi]
			invoke SendMessage,hAclGrd,GM_COMBOADDSTRING,2,esi
			invoke strlen,esi
			lea		esi,[esi+eax+2]
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
		invoke SendMessage,hAclGrd,GM_ADDCOL,0,addr col
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
		invoke SendMessage,hAclGrd,GM_ADDCOL,0,addr col
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
		invoke SendMessage,hAclGrd,GM_ADDCOL,0,addr col
		mov		nInx,1
	  @@:
		invoke BinToDec,nInx,addr iniBuffer
		invoke GetPrivateProfileString,addr iniAccel,addr iniBuffer,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniFile
		.if eax
			;ID
			invoke iniGetItem,addr iniBuffer,addr buffer
			invoke DecToBin,addr buffer
			mov		row[0*4],eax
			;Caption
			invoke iniGetItem,addr iniBuffer,addr buffer1
			lea		eax,buffer1
			mov		row[1*4],eax
			;Key
			invoke iniGetItem,addr iniBuffer,addr buffer
			invoke DecToBin,addr buffer
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
			invoke SendMessage,hAclGrd,GM_ADDROW,0,addr row
			inc		nInx
			jmp		@b
		.endif
		invoke UpdateAccelOption,hAclMnu
		invoke SendMessage,hAclGrd,GM_SETCURSEL,1,0
		invoke SetLanguage,hWin,IDD_DLGACCELOPTION,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SaveAccelOption
				.if byte ptr iniBuffer
					invoke MessageBox,hWin,addr iniBuffer,addr szDuplicateAccel,MB_ICONERROR or MB_OK
				.else
					invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNACLOPTDEL
				invoke SendMessage,hAclGrd,GM_GETCURROW,0,0
				.if eax!=-1
					invoke SendMessage,hAclGrd,GM_DELROW,eax,0
				.endif
			.else
				mov		ebx,eax
				invoke SendMessage,hAclGrd,GM_GETROWCOUNT,0,0
				mov		esi,eax
				xor		ecx,ecx
				.while ecx<esi
					push	ecx
					shl		ecx,16
					invoke SendMessage,hAclGrd,GM_GETCELLDATA,ecx,addr nInx
					pop		ecx
					.break .if ebx==nInx
					inc		ecx
				.endw
				.if ecx==esi
					xor		eax,eax
					mov		fCtrl,eax
					mov		fShift,eax
					mov		fAlt,eax
					mov		row[0*4],ebx
					mov		mii.cbSize,sizeof mii
					mov		mii.fMask,MIIM_TYPE
					mov		mii.dwTypeData,offset iniBuffer
					mov		mii.cch,sizeof iniBuffer
					invoke GetMenuItemInfo,hAclMnu,ebx,FALSE,addr mii
					mov		ebx,offset iniBuffer
					.while byte ptr [ebx] && byte ptr [ebx]!=VK_TAB
						inc		ebx
					.endw
					xor		edi,edi
					.if byte ptr [ebx]==VK_TAB
						mov		byte ptr [ebx],0
						inc		ebx
						invoke iniInStr,ebx,offset szHdrCtrl
						inc		eax
						mov		fCtrl,eax
						invoke iniInStr,ebx,offset szHdrShift
						inc		eax
						mov		fShift,eax
						invoke iniInStr,ebx,offset szHdrAlt
						inc		eax
						mov		fAlt,eax
						invoke strlen,ebx
						.while byte ptr [ebx+eax-1]!='+' && eax
							dec		eax
						.endw
						lea		ebx,[ebx+eax]
						mov		esi,offset szAclKeys+1
						.while byte ptr [esi]
							invoke strcmp,ebx,esi
							.if !eax
								.break
							.endif
							inc		edi
							invoke strlen,esi
							lea		esi,[esi+eax+2]
						.endw
					.endif
					mov		row[1*4],offset iniBuffer
					mov		row[2*4],edi
					mov		eax,fCtrl
					mov		row[3*4],eax
					mov		eax,fShift
					mov		row[4*4],eax
					mov		eax,fAlt
					mov		row[5*4],eax
					invoke SendMessage,hAclGrd,GM_ADDROW,0,addr row
				.endif
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		edx,lParam
		mov		eax,[edx].NMHDR.hwndFrom
		.if eax==hAclGrd
			mov		eax,[edx].NMHDR.code
			.if eax==GN_HEADERCLICK
				;Sort the grid by column, invert sorting order
				invoke SendMessage,hAclGrd,GM_COLUMNSORT,[edx].GRIDNOTIFY.col,SORT_INVERT
			.elseif eax==GN_BEFORESELCHANGE
				.if ![edx].GRIDNOTIFY.col
					mov		[edx].GRIDNOTIFY.col,1
				.endif
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

AccelOptionProc endp
