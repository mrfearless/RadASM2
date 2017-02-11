
IDD_DLGOPTMNU		equ 3200
IDC_LSTME			equ 3201
IDC_BTNMFILE		equ 3203
IDC_EDTMEITEM		equ 3207
IDC_EDTMECMND		equ 3208
IDC_BTNMEU			equ 3202
IDC_BTNMED			equ 3204
IDC_BTNMEADD		equ 3205
IDC_BTNMEDEL		equ 3206
IDC_EDTMNUCBO		equ 3209

.data?

fType				dd ?
lpMnuIniFile		dd ?
lpAppName			dd ?
fUpdate				dd ?
lpFilePath			dd ?
lpFilter			dd ?

.code

EditGet proc uses esi edi,hWin:HWND
	LOCAL	buffer0[256]:BYTE
	LOCAL	nInx:DWORD

	invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		mov		nInx,eax
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETTEXT,nInx,addr buffer0
		lea		esi,buffer0
		dec		esi
	  @@:
		inc		esi
		mov		al,[esi]
		cmp		al,09h
		jne		@b
		mov		al,0
		mov		[esi],al
		inc		esi
		invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,WM_SETTEXT,0,esi
		invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,WM_SETTEXT,0,addr buffer0
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETITEMDATA,nInx,0
		mov		edi,eax
		mov		nInx,0
		.while TRUE
			invoke SendDlgItemMessage,hWin,IDC_EDTMNUCBO,CB_GETITEMDATA,nInx,0
			.if eax==CB_ERR
				mov		nInx,0
				.break
			.elseif eax==edi
				.break
			.endif
			inc		nInx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_EDTMNUCBO,CB_SETCURSEL,nInx,0
	.endif
	ret

EditGet endp

EditUpdate proc uses esi,hWin:HWND
	LOCAL	buffer[512]:BYTE
	LOCAL	nInx:DWORD

	.if fUpdate
		invoke GetDlgItemText,hWin,IDC_EDTMEITEM,addr buffer,256
		invoke strlen,addr buffer
		lea		esi,buffer
		add		esi,eax
		mov		byte ptr [esi],09h
		inc		esi
		invoke GetDlgItemText,hWin,IDC_EDTMECMND,esi,256
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
		.if eax==LB_ERR
			mov		eax,0
		.endif
		mov		nInx,eax
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_DELETESTRING,nInx,0
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_INSERTSTRING,nInx,addr buffer
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMNUCBO,CB_GETCURSEL,0,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMNUCBO,CB_GETITEMDATA,eax,0
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETITEMDATA,nInx,eax
	.endif
	ret

EditUpdate endp

MenuOptionSave proc uses esi edi,hWin:HWND
	LOCAL	buffer0[512]:BYTE
	LOCAL	buffer1[512]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	nIni:DWORD

	mov		dword ptr buffer0,'=reV'
	mov		dword ptr buffer0[4],'001'
	mov		dword ptr buffer0[8],0
	invoke WritePrivateProfileSection,lpAppName,addr buffer0,lpMnuIniFile
	mov		nInx,0
	mov		nIni,1
	.while TRUE
		invoke RtlZeroMemory,addr buffer0,sizeof buffer0
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETTEXT,nInx,addr buffer0
	  .break .if eax==LB_ERR
		mov		al,buffer0[1]
		.if al
			lea		esi,buffer0
			lea		edi,buffer1
		  @@:
			mov		al,[esi]
			.if al==09h
				mov		al,','
				stosb
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETITEMDATA,nInx,0
				invoke BinToDec,eax,edi
				invoke strlen,edi
				add		edi,eax
				mov		al,','
				stosb
				mov		eax,fType
				stosb
				mov		al,','
			.endif
			stosb
			inc		esi
			or		al,al
			jne		@b
			invoke BinToDec,nIni,addr buffer0
			invoke WritePrivateProfileString,lpAppName,addr buffer0,addr buffer1,lpMnuIniFile
			inc		nIni
		.endif
		inc		nInx
	.endw
	invoke iniAddMenu
	invoke iniDisMenu
	invoke SetMakeMenu
	ret

MenuOptionSave endp

MenuOptionProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer0[512]:BYTE
	LOCAL	buffer1[256+32]:BYTE
	LOCAL	buffer2[256]:BYTE
	LOCAL	nInx:DWORD
	LOCAL	val:DWORD
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetLanguage,hWin,IDD_DLGOPTMNU,FALSE
		.if fNT
			invoke GetWindowTextW,hWin,addr buffer0,sizeof buffer0/2
			mov		eax,lParam
			.if eax>5
				mov		eax,5
			.endif
			.while eax
				push	eax
				invoke iniGetItemW,addr buffer0,addr buffer1
				pop		eax
				dec		eax
			.endw
			invoke SetWindowTextW,hWin,addr buffer1
		.else
			invoke GetWindowText,hWin,addr buffer0,sizeof buffer0
			mov		eax,lParam
			.if eax>5
				mov		eax,5
			.endif
			.while eax
				push	eax
				invoke iniGetItem,addr buffer0,addr buffer1
				pop		eax
				dec		eax
			.endw
			invoke SetWindowText,hWin,addr buffer1
		.endif
		invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,EM_LIMITTEXT,64,0
		invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,EM_LIMITTEXT,128,0
		mov		val,160
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETTABSTOPS,1,addr val
		.if lParam==1
			;Make
			mov		fType,'M'
			mov		lpMnuIniFile,offset iniAsmFile
			mov		lpAppName,offset iniMenuMake
			invoke GetDlgItem,hWin,IDC_BTNMFILE
			invoke ShowWindow,eax,SW_HIDE
			invoke GetDlgItem,hWin,IDC_EDTMECMND
			mov		val,eax
			invoke GetClientRect,val,addr rect
			add		rect.bottom,3
			add		rect.right,22
			invoke SetWindowPos,val,NULL,0,0,rect.right,rect.bottom,SWP_NOMOVE or SWP_NOZORDER
		.elseif lParam==2
			;Tools
			mov		fType,'T'
			mov		dword ptr buffer0,'1'
			invoke GetPrivateProfileString,addr iniMenuTool,addr buffer0,addr szNULL,addr buffer0,sizeof buffer0,addr iniAsmFile
			.if eax
				mov		edx,offset iniAsmFile
			.else
				mov		edx,offset iniFile
			.endif
			mov		lpMnuIniFile,edx
			mov		lpAppName,offset iniMenuTool
			mov		lpFilePath,offset AppPath
			mov		lpFilter,offset szFilterTools
		.elseif lParam==3
			mov		fType,'H'
			;Help
			mov		dword ptr buffer0,'1'
			invoke GetPrivateProfileString,addr iniMenuHelp,addr buffer0,addr szNULL,addr buffer0,sizeof buffer0,addr iniAsmFile
			.if eax
				mov		edx,offset iniAsmFile
			.else
				mov		edx,offset iniFile
			.endif
			mov		lpMnuIniFile,edx
			mov		lpAppName,offset iniMenuHelp
			mov		lpFilePath,offset Hlp
			mov		lpFilter,offset szFilterHelp
		.elseif lParam==4
			;Keyboard macro
			mov		fType,'K'
			mov		lpMnuIniFile,offset iniAsmFile
			mov		lpAppName,offset iniMenuMacro
			mov		lpFilePath,offset Mac
			mov		lpFilter,offset szFilterMacro
		.else
			;Keyboard macro
			mov		fType,'K'
			mov		lpMnuIniFile,offset iniAsmFile
			mov		lpAppName,offset iniMenuMacro
			mov		lpFilePath,offset Mac
			mov		lpFilter,offset szFilterMacro
		.endif
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNMEU,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+3,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTNMED,BM_SETIMAGE,IMAGE_ICON,eax
		mov		nInx,1
	  @@:
		invoke BinToDec,nInx,addr buffer0
		invoke GetPrivateProfileString,lpAppName,addr buffer0,addr szNULL,addr buffer0,256,lpMnuIniFile
		.if eax
			invoke iniGetItem,addr buffer0,addr buffer1
			invoke iniGetItem,addr buffer0,addr buffer2
			mov		val,0
			mov		al,buffer2
			.if al>='0' && al<='9'
				invoke DecToBin,addr buffer2
				mov		val,eax
				invoke iniGetItem,addr buffer0,addr buffer2
			.endif
			invoke strcat,addr buffer1,addr szTab
			invoke strcat,addr buffer1,addr buffer0
			invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_ADDSTRING,0,addr buffer1
			invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETITEMDATA,eax,val
			inc		nInx
			cmp		nInx,32
			jle		@b
		.endif
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,0,0
		invoke MnuSetCbo,hWin,IDC_EDTMNUCBO
		mov		fUpdate,0
		invoke EditGet,hWin
		mov		fUpdate,1
		.if lParam>9999
			mov		buffer0[0],09h
			mov		buffer0[1],0
			invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_INSERTSTRING,0,addr buffer0
			invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,0,0
			invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,WM_SETTEXT,0,addr szNULL
			invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,WM_SETTEXT,0,addr szNULL
			invoke SetDlgItemText,hWin,IDC_EDTMECMND,lParam
		.endif
		mov		lpMnuIniFile,offset iniAsmFile
		invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCOUNT,0,0
		.if eax>31
			invoke GetDlgItem,hWin,IDC_BTNMEADD
			invoke EnableWindow,eax,FALSE
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke MenuOptionSave,hWin
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNMEU
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
				.if eax
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETTEXT,nInx,addr buffer0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_DELETESTRING,nInx,0
					dec		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_INSERTSTRING,nInx,addr buffer0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
				.endif
			.elseif eax==IDC_BTNMED
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
				mov		nInx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCOUNT,0,0
				dec		eax
				.if eax!=nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETTEXT,nInx,addr buffer0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_DELETESTRING,nInx,0
					inc		nInx
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_INSERTSTRING,nInx,addr buffer0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
				.endif
			.elseif eax==IDC_BTNMEADD
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
				.if eax==LB_ERR
					mov		eax,0
				.endif
				mov		nInx,eax
				mov		buffer0[0],09h
				mov		buffer0[1],0
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_INSERTSTRING,nInx,addr buffer0
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
				invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,WM_SETTEXT,0,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,WM_SETTEXT,0,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_EDTMNUCBO,CB_SETCURSEL,0,0
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCOUNT,0,0
				.if eax>31
					invoke GetDlgItem,hWin,IDC_BTNMEADD
					invoke EnableWindow,eax,FALSE
				.endif
			.elseif eax==IDC_BTNMEDEL
				mov		fUpdate,0
				invoke SendDlgItemMessage,hWin,IDC_EDTMECMND,WM_SETTEXT,0,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_EDTMEITEM,WM_SETTEXT,0,addr szNULL
				invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_DELETESTRING,nInx,0
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
					.if eax==LB_ERR
						dec		nInx
						invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_SETCURSEL,nInx,0
					.endif
					invoke SendDlgItemMessage,hWin,IDC_EDTMNUCBO,CB_SETCURSEL,0,0
					invoke EditGet,hWin
					invoke SendDlgItemMessage,hWin,IDC_LSTME,LB_GETCOUNT,0,0
					.if eax<32
						invoke GetDlgItem,hWin,IDC_BTNMEADD
						invoke EnableWindow,eax,TRUE
					.endif
				.endif
				mov		fUpdate,1
			.elseif eax==IDC_BTNMFILE
				invoke RtlZeroMemory,offset ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				m2m		ofn.hwndOwner,hWin
				m2m		ofn.hInstance,hInstance
				mov		eax,lpFilePath
				mov		ofn.lpstrInitialDir,eax
				mov		eax,lpFilter
				mov		ofn.lpstrFilter,eax
				mov		ofn.lpstrDefExt,0
				mov		ofn.lpstrTitle,0
				lea		eax,buffer0
				mov		ofn.lpstrFile,eax
				invoke GetDlgItemText,hWin,IDC_EDTMECMND,addr buffer0,sizeof buffer0
				mov		ofn.nMaxFile,sizeof buffer0
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					.if fType=='K'
						invoke RemovePath,addr buffer0,lpFilePath,addr buffer1
						.if byte ptr [eax]=='\'
							inc		eax
						.endif
						invoke strcpy,addr buffer0,eax
					.endif
					invoke SetDlgItemText,hWin,IDC_EDTMECMND,addr buffer0
				.endif
			.endif
		.elseif edx==EN_CHANGE
			invoke EditUpdate,hWin
		.elseif edx==LBN_SELCHANGE
			.if eax==IDC_EDTMNUCBO
				invoke EditUpdate,hWin
			.else
				mov		fUpdate,FALSE
				invoke EditGet,hWin
				mov		fUpdate,TRUE
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

MenuOptionProc endp
