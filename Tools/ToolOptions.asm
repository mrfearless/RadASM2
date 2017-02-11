
IDD_TOOLOPTIONS			equ 3900
IDC_BTN_TCODOWN			equ 3903
IDC_BTN_TCOUP			equ 3904
IDC_LST_TCO				equ 3905
IDC_CHK1				equ 3906
IDC_CHK2				equ 3907
IDC_CHK3				equ 3908

.code

ToolOptionSave proc uses ebx esi edi,hWin:HWND
	LOCAL		lToolPool[4*10]:DWORD

	mov		ebx,offset Clipping
	lea		edi,lToolPool
	invoke RtlZeroMemory,edi,sizeof lToolPool
	xor		eax,eax
	.while eax<8
		push	eax
		invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_GETITEMDATA,eax,0
		push	eax
		mov		esi,offset ToolPool
	  @@:
		mov		edx,[esi+4]
		.if eax==[edx].TOOL.ID
			mov		eax,[esi]
			mov		[edi],eax
			mov		eax,[esi+4]
			mov		[edi+4],eax
			mov		eax,[esi+8]
			mov		[edi+8],eax
			mov		eax,[esi+12]
			mov		[edi+12],eax
			add		edi,16
		.else
			add		esi,16
			jmp		@b
		.endif
		pop		eax
		or		al,30h
		mov		ah,','
		mov		[ebx],eax
		add		ebx,2
		pop		eax
		inc		eax
	.endw
	dec		ebx
	mov		byte ptr [ebx],0
	lea		esi,lToolPool
	mov		edi,offset ToolPool
	mov		ecx,4*8
	rep movsd
	invoke IsDlgButtonChecked,hWin,IDC_CHK1
	mov		fRightCaption,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHK2
	mov		fMultiLine,eax
	invoke IsDlgButtonChecked,hWin,IDC_CHK3
	mov		fDivider,eax
	invoke GetWindowLong,hTab,GWL_STYLE
	mov		edx,eax
	.if fMultiLine
		or		edx,TCS_MULTILINE
	.else
		and		edx,-1 xor TCS_MULTILINE
	.endif
	invoke SetWindowLong,hTab,GWL_STYLE,edx
	invoke InvalidateRect,hTab,NULL,TRUE
	invoke SendMessage,hWnd,WM_SIZE,0,0
	ret

ToolOptionSave endp

ToolOptionsProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	nInx:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+2,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTN_TCOUP,BM_SETIMAGE,IMAGE_ICON,eax
		invoke ImageList_GetIcon,hTbrIml,IMG_ARROW+3,ILD_NORMAL
		invoke SendDlgItemMessage,hWin,IDC_BTN_TCODOWN,BM_SETIMAGE,IMAGE_ICON,eax
		invoke strcpy,addr buffer,addr Clipping
		xor		ebx,ebx
		.while ebx<8
			invoke iniGetItem,addr buffer,addr buffer1
			mov		al,buffer1
			.if al=='1'
				mov		eax,offset iniWinProject
				mov		ecx,1
			.elseif al=='2'
				mov		eax,offset iniWinOutput
				mov		ecx,2
			.elseif al=='3'
				mov		eax,offset iniWinToolBox
				mov		ecx,3
			.elseif al=='4'
				mov		eax,offset iniWinProperty
				mov		ecx,4
			.elseif al=='5'
				mov		eax,offset iniWinTabTool
				mov		ecx,5
			.elseif al=='6'
				mov		eax,offset iniWinInfoTool
				mov		ecx,6
			.elseif al=='7'
				mov		eax,offset iniWinTool1
				mov		ecx,7
			.elseif al=='8'
				mov		eax,offset iniWinTool2
				mov		ecx,8
			.endif
			push	ecx
			invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_INSERTSTRING,ebx,eax
			pop		ecx
			invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_SETITEMDATA,eax,ecx
			inc		ebx
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_SETCURSEL,0,0
		.if fDivider
			invoke CheckDlgButton,hWin,IDC_CHK3,BST_CHECKED
		.endif
		.if fMultiLine
			invoke CheckDlgButton,hWin,IDC_CHK2,BST_CHECKED
		.endif
		.if fRightCaption
			invoke CheckDlgButton,hWin,IDC_CHK1,BST_CHECKED
		.endif
		invoke SetLanguage,hWin,IDD_TOOLOPTIONS,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke ToolOptionSave,hWin
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDUSE
				invoke ToolOptionSave,hWin
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTN_TCOUP
				invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_GETCURSEL,0,0
				.if eax
					mov		nInx,eax
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_GETITEMDATA,nInx,0
					mov		ebx,eax
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_DELETESTRING,nInx,0
					dec		nInx
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_INSERTSTRING,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_SETITEMDATA,nInx,ebx
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_SETCURSEL,nInx,0
				.endif
			.elseif eax==IDC_BTN_TCODOWN
				invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_GETCURSEL,0,0
				mov		nInx,eax
				invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_GETCOUNT,0,0
				dec		eax
				.if eax!=nInx
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_GETITEMDATA,nInx,0
					mov		ebx,eax
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_GETTEXT,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_DELETESTRING,nInx,0
					inc		nInx
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_INSERTSTRING,nInx,addr buffer
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_SETITEMDATA,nInx,ebx
					invoke SendDlgItemMessage,hWin,IDC_LST_TCO,LB_SETCURSEL,nInx,0
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

ToolOptionsProc endp
