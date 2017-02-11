
IDD_ENVIROMENTOPTION			equ 6000
IDC_BTNENVIROMENTADD			equ 1001
IDC_BTNENVIROMENTDEL			equ 1002
IDC_LSTENVIROMENT				equ 1003
IDC_EDTENVIROMENTNAME			equ 1005
IDC_EDTENVIROMENTVALUE			equ 1004

.data?

hEnvMem		dd ?
pNextVal	dd ?

.code

EnviromentOptionsProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[512]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		push	ebx
		push	edi
		invoke SetLanguage,hWin,IDD_ENVIROMENTOPTION,FALSE
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
		mov		hEnvMem,eax
		mov		edi,eax
		mov		ebx,1
		.while TRUE
			invoke BinToDec,ebx,addr buffer
			invoke GetPrivateProfileString,addr iniEnv,addr buffer,NULL,edi,512,addr iniAsmFile
		  .break .if !eax
			invoke iniGetItem,edi,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_ADDSTRING,0,addr buffer
			invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_SETITEMDATA,eax,edi
			add		edi,384
			inc		ebx
		.endw
		mov		pNextVal,edi
		invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_SETCURSEL,0,0
		call	SetEdit
		pop		edi
		pop		ebx
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				mov		dword ptr buffer,0
				invoke WritePrivateProfileSection,addr iniEnv,addr buffer,addr iniAsmFile
				push	ebx
				push	edi
				xor		ebx,ebx
				xor		eax,eax
				.while eax!=LB_ERR
					invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_GETTEXT,ebx,addr buffer
					.if eax!=LB_ERR && eax
						invoke strcat,addr buffer,addr szComma
						invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_GETITEMDATA,ebx,0
						invoke strcat,addr buffer,eax
						mov		eax,ebx
						inc		eax
						invoke BinToDec,eax,addr iniBuffer
						invoke WritePrivateProfileString,addr iniEnv,addr iniBuffer,addr buffer,addr iniAsmFile
						xor		eax,eax
					.endif
					inc		ebx
				.endw
				pop		edi
				pop		ebx
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				invoke SetEnviroment
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNENVIROMENTADD
				mov		buffer,0
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_ADDSTRING,0,addr buffer
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_SETITEMDATA,eax,pNextVal
				pop		eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_SETCURSEL,eax,0
				add		pNextVal,384
				call	SetEdit
			.elseif eax==IDC_BTNENVIROMENTDEL
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_GETCURSEL,0,0
				mov		ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_DELETESTRING,ebx,0
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_SETCURSEL,ebx,0
				.if eax==LB_ERR
					dec		ebx
					invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_SETCURSEL,ebx,0
				.endif
				call	SetEdit
			.endif
		.elseif edx==EN_CHANGE
			push	ebx
			push	eax
			invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_GETCURSEL,0,0
			mov		ebx,eax
			pop		eax
			.if eax==IDC_EDTENVIROMENTNAME
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_GETITEMDATA,ebx,0
				push	eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_DELETESTRING,ebx,0
				invoke GetDlgItemText,hWin,IDC_EDTENVIROMENTNAME,addr buffer,128
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_INSERTSTRING,ebx,addr buffer
				pop		eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_SETITEMDATA,ebx,eax
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_SETCURSEL,ebx,0
			.elseif eax==IDC_EDTENVIROMENTVALUE
				invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_GETITEMDATA,ebx,0
				invoke GetDlgItemText,hWin,IDC_EDTENVIROMENTVALUE,eax,384
			.endif
			pop		ebx
		.elseif edx==LBN_SELCHANGE
			call	SetEdit
		.endif
	.elseif eax==WM_CLOSE
		invoke GlobalFree,hEnvMem
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

SetEdit:
	invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_GETCURSEL,0,0
	.if eax!=LB_ERR
		push	eax
		invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_GETITEMDATA,eax,0
		invoke SetDlgItemText,hWin,IDC_EDTENVIROMENTVALUE,eax
		pop		edx
		invoke SendDlgItemMessage,hWin,IDC_LSTENVIROMENT,LB_GETTEXT,edx,addr buffer
		invoke SetDlgItemText,hWin,IDC_EDTENVIROMENTNAME,addr buffer
	.else
		mov		buffer,0
		invoke SetDlgItemText,hWin,IDC_EDTENVIROMENTNAME,addr buffer
		invoke SetDlgItemText,hWin,IDC_EDTENVIROMENTVALUE,addr buffer
	.endif
	retn

EnviromentOptionsProc endp
