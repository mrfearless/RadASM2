.const

;Pro\ProOption.dlg
IDD_PROOPTION							equ 2700
IDC_PROMNU1								equ 2701
IDC_PROMNU2								equ 2702
IDC_PROMNU3								equ 2703
IDC_PROMNU4								equ 2704
IDC_PROMNU5								equ 2705
IDC_PROMNU6								equ 2706
IDC_PROMNU7								equ 2707
IDC_PROMNU8								equ 2708
IDC_PROMNU9								equ 2709
IDC_PROMNU10							equ 2710
IDC_PROMNU11							equ 2711
IDC_PROMNU12							equ 2712
IDC_PROMNU13							equ 2713
IDC_PROMNU14							equ 2714
IDC_PROMNU15							equ 2715
IDC_PROMNU16							equ 2716
IDC_EDTPRODESCRIPTION					equ 2740

IDC_EDTCOMPILERC						equ 2741
IDC_EDTASSEMBLE							equ 2742
IDC_EDTLINK								equ 2743
IDC_EDTRUN								equ 2744
IDC_EDTDBG								equ 2745
IDC_EDTRESTOOBJ							equ 2746
IDC_EDTASMMODULE						equ 2747

IDC_EDTCOMPILERCD						equ 2751
IDC_EDTASSEMBLED						equ 2752
IDC_EDTLINKD							equ 2753
IDC_EDTRUND								equ 2754
IDC_EDTDBGD								equ 2755
IDC_EDTRESTOOBJD						equ 2756
IDC_EDTASMMODULED						equ 2757

IDC_RBNRELEASE							equ 2722
IDC_RBNDEBUG							equ 2723
IDC_CHKGROUP							equ 2724
IDC_CHKGROUPEXPAND						equ 2725
IDC_GRPPO								equ 2726
IDC_BTNPATHS							equ 2730
IDC_BTNMAIN								equ 2731

.data?

poht		dd ?

.code

OptProjectComp proc uses esi edi,hWin:HWND

	invoke IsDlgButtonChecked,hWin,IDC_RBNDEBUG
	.if eax
		mov		esi,IDC_EDTCOMPILERCD
		mov		edi,IDC_EDTCOMPILERC
	.else
		mov		esi,IDC_EDTCOMPILERC
		mov		edi,IDC_EDTCOMPILERCD
	.endif
	mov		eax,7
	.while eax
		push	eax
		invoke GetDlgItem,hWin,esi
		invoke ShowWindow,eax,SW_SHOW
		invoke GetDlgItem,hWin,edi
		invoke ShowWindow,eax,SW_HIDE
		inc		esi
		inc		edi
		pop		eax
		dec		eax
	.endw
	ret

OptProjectComp endp

OptProjectSave proc uses ebx edi,hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	ID:DWORD
	LOCAL	fChanged:DWORD
	LOCAL	tvi:TVITEM

	mov		fChanged,0
	invoke GetPrivateProfileString,addr iniProject,addr iniProjectDescription,addr szNULL,addr iniBuffer,128,addr ProjectFile
	invoke GetDlgItemText,hWin,IDC_EDTPRODESCRIPTION,addr buffer,127
	invoke lstrcmp,addr iniBuffer,addr buffer
	.if eax
		invoke WritePrivateProfileString,addr iniProject,addr iniProjectDescription,addr buffer,addr ProjectFile
		mov		tvi.imask,TVIF_TEXT
		mov		eax,hRoot
		mov		tvi.hItem,eax
		lea		eax,buffer
		mov		tvi.pszText,eax
		invoke SendMessage,hPbrTrv,TVM_SETITEM,0,addr tvi
	.endif
	mov		ID,IDC_PROMNU1
	lea		edi,buffer
	mov		ebx,16
  @@:
	invoke IsDlgButtonChecked,hWin,ID
	.if eax==BST_CHECKED
		mov		eax,'1,'
	.else
		mov		eax,'0,'
	.endif
	mov		[edi],eax
	add		edi,2
	inc		ID
	dec		ebx
	jne		@b
	invoke WritePrivateProfileString,addr iniMakeDef,addr iniMakeDefMenu,addr buffer[1],addr ProjectFile
	invoke IsDlgButtonChecked,hWin,IDC_RBNDEBUG
	.if eax
		mov		dword ptr buffer,'1'
		mov		fDebug,TRUE
	.else
		mov		dword ptr buffer,'0'
		mov		fDebug,FALSE
	.endif
	invoke WritePrivateProfileString,addr iniProject,addr iniDebug,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'1'
	invoke GetDlgItemText,hWin,IDC_EDTCOMPILERC,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'2'
	invoke GetDlgItemText,hWin,IDC_EDTASSEMBLE,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'3'
	invoke GetDlgItemText,hWin,IDC_EDTLINK,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'4'
	invoke GetDlgItemText,hWin,IDC_EDTRUN,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'5'
	invoke GetDlgItemText,hWin,IDC_EDTRESTOOBJ,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'6'
	invoke GetDlgItemText,hWin,IDC_EDTASMMODULE,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'7'
	invoke GetDlgItemText,hWin,IDC_EDTDBG,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'11'
	invoke GetDlgItemText,hWin,IDC_EDTCOMPILERCD,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'21'
	invoke GetDlgItemText,hWin,IDC_EDTASSEMBLED,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'31'
	invoke GetDlgItemText,hWin,IDC_EDTLINKD,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'41'
	invoke GetDlgItemText,hWin,IDC_EDTRUND,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'51'
	invoke GetDlgItemText,hWin,IDC_EDTRESTOOBJD,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'61'
	invoke GetDlgItemText,hWin,IDC_EDTASMMODULED,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	mov		dword ptr buffer1,'71'
	invoke GetDlgItemText,hWin,IDC_EDTDBGD,addr buffer,255
	invoke WritePrivateProfileString,addr iniMakeDef,addr buffer1,addr buffer,addr ProjectFile
	invoke GetPrivateProfileInt,addr iniProject,addr iniProjectGroup,0,addr ProjectFile
	push	eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKGROUP
	pop		edx
	.if eax!=edx
		inc		fChanged
		.if eax
			mov		dword ptr buffer1,'1'
			mov		fGroup,TRUE
		.else
			mov		dword ptr buffer1,'0'
			mov		fGroup,FALSE
		.endif
		invoke WritePrivateProfileString,addr iniProject,addr iniProjectGroup,addr buffer1,addr ProjectFile
	.endif
	invoke GetPrivateProfileInt,addr iniProject,addr iniProjectGroupExpand,0,addr ProjectFile
	push	eax
	invoke IsDlgButtonChecked,hWin,IDC_CHKGROUPEXPAND
	pop		edx
	.if eax!=edx
		.if eax
			mov		dword ptr buffer1,'1'
			mov		fGroupExpand,TRUE
		.else
			mov		dword ptr buffer1,'0'
			mov		fGroupExpand,FALSE
		.endif
		invoke WritePrivateProfileString,addr iniProject,addr iniProjectGroupExpand,addr buffer1,addr ProjectFile
	.endif
	invoke SetMakeMenu
	invoke GetPrivateProfileString,addr	iniProject,addr	iniAssembler,addr szNULL,addr buffer,sizeof	buffer,addr	ProjectFile
	invoke strlen,addr buffer
	lea		eax,[buffer+eax]
	mov		dword ptr [eax],' - '
	.if	fDebug
		invoke strcat,addr buffer,addr iniDebug
	.else
		invoke strcat,addr buffer,addr iniRelease
	.endif
	invoke SendMessage,hStatus,SB_SETTEXT,2,addr buffer
	.if fChanged
		invoke SendMessage,hPbrTrv,TVM_DELETEITEM,0,hRoot
		invoke GetProjectFiles,FALSE
	.endif
	ret

OptProjectSave endp

OptProjectProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ID:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	rect:RECT
	LOCAL	wt:DWORD
	LOCAL	pt:POINT
	LOCAL	hCtl:DWORD

	mov		eax,uMsg
    .if eax==WM_INITDIALOG
    	push	PosProOptLeft
    	push	PosProOptTop
    	push	PosProOptWt
		invoke SetLanguage,hWin,IDD_PROOPTION,FALSE
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		poht,eax
		pop		PosProOptWt
		pop		PosProOptTop
		pop		PosProOptLeft
		invoke SetWindowPos,hWin,NULL,PosProOptLeft,PosProOptTop,PosProOptWt,eax,SWP_NOZORDER
    	invoke GetPrivateProfileString,addr iniProject,addr iniMenuMake,addr szNULL,addr iniBuffer,128,addr iniAsmFile
		mov		ID,IDC_PROMNU1
		mov		ebx,16
	  @@:
		invoke iniGetItem,addr iniBuffer,addr buffer
		mov		al,buffer[0]
		.if al
			invoke GetDlgItem,hWin,ID
			invoke ShowWindow,eax,SW_SHOW
			invoke SetDlgItemText,hWin,ID,addr buffer
		.else
			invoke GetDlgItem,hWin,ID
			invoke ShowWindow,eax,SW_HIDE
		.endif
		inc		ID
		dec		ebx
		jne		@b
		invoke GetPrivateProfileString,addr iniMakeDef,addr iniMakeDefMenu,addr szNULL,addr iniBuffer,128,addr ProjectFile
		mov		ID,IDC_PROMNU1
		mov		ebx,16
	  @@:
		invoke iniGetItem,addr iniBuffer,addr buffer
		mov		al,buffer[0]
		.if al=='1'
			invoke CheckDlgButton,hWin,ID,BST_CHECKED
		.endif
		inc		ID
		dec		ebx
		jne		@b
		invoke SendDlgItemMessage,hWin,IDC_EDTPRODESCRIPTION,EM_LIMITTEXT,127,0
		invoke GetPrivateProfileString,addr iniProject,addr iniProjectDescription,addr szNULL,addr iniBuffer,128,addr ProjectFile
		invoke SetDlgItemText,hWin,IDC_EDTPRODESCRIPTION,addr iniBuffer
		.if fDebug
			mov		eax,IDC_RBNDEBUG
		.else
			mov		eax,IDC_RBNRELEASE
		.endif
		invoke CheckRadioButton,hWin,IDC_RBNRELEASE,IDC_RBNDEBUG,eax
		invoke SendDlgItemMessage,hWin,IDC_EDTCOMPILERC,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTASSEMBLE,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTLINK,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTRUN,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTDBG,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTRESTOOBJ,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTASMMODULE,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTCOMPILERCD,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTASSEMBLED,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTLINKD,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTRUND,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTDBGD,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTRESTOOBJD,EM_LIMITTEXT,223,0
		invoke SendDlgItemMessage,hWin,IDC_EDTASMMODULED,EM_LIMITTEXT,223,0
		mov		dword ptr buffer,'1'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTCOMPILERC,addr iniBuffer
		mov		dword ptr buffer,'2'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTASSEMBLE,addr iniBuffer
		mov		dword ptr buffer,'3'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTLINK,addr iniBuffer
		mov		dword ptr buffer,'4'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTRUN,addr iniBuffer
		mov		dword ptr buffer,'5'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTRESTOOBJ,addr iniBuffer
		mov		dword ptr buffer,'6'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTASMMODULE,addr iniBuffer
		mov		dword ptr buffer,'7'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTDBG,addr iniBuffer
		mov		dword ptr buffer,'11'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTCOMPILERCD,addr iniBuffer
		mov		dword ptr buffer,'21'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTASSEMBLED,addr iniBuffer
		mov		dword ptr buffer,'31'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTLINKD,addr iniBuffer
		mov		dword ptr buffer,'41'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTRUND,addr iniBuffer
		mov		dword ptr buffer,'51'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTRESTOOBJD,addr iniBuffer
		mov		dword ptr buffer,'61'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTASMMODULED,addr iniBuffer
		mov		dword ptr buffer,'71'
		invoke GetPrivateProfileString,addr iniMakeDef,addr buffer,addr szNULL,addr iniBuffer,224,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,addr buffer,addr szNULL,addr iniBuffer,224,addr iniAsmFile
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTDBGD,addr iniBuffer
		invoke GetPrivateProfileInt,addr iniProject,addr iniProjectGroup,1,addr ProjectFile
		invoke CheckDlgButton,hWin,IDC_CHKGROUP,eax
		invoke GetPrivateProfileInt,addr iniProject,addr iniProjectGroupExpand,1,addr ProjectFile
		invoke CheckDlgButton,hWin,IDC_CHKGROUPEXPAND,eax
		invoke OptProjectComp,hWin
		invoke GetDlgItem,hWin,IDUSE
		invoke EnableWindow,eax,FALSE
    .elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDOK
				invoke GetDlgItem,hWin,IDUSE
				invoke IsWindowEnabled,eax
				.if eax
					invoke OptProjectSave,hWin
				.endif
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDUSE
				invoke OptProjectSave,hWin
				invoke SetLanguage,hWin,IDD_PROOPTION,TRUE
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,FALSE
			.elseif eax==IDC_BTNPATHS
				invoke ModalDialog,hInstance,IDD_PATHOPTION,hWin,addr PathOptionProc,0
			.elseif eax==IDC_BTNMAIN
				invoke ModalDialog,hInstance,IDD_DLGMAINFILES,hWin,addr MainFilesDialogProc,0
			.elseif eax>=IDC_PROMNU1 && eax<=IDC_PROMNU16
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,TRUE
			.elseif eax>=IDC_RBNRELEASE && eax<=IDC_RBNDEBUG
				invoke OptProjectComp,hWin
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,TRUE
			.elseif eax==IDC_CHKGROUP || eax==IDC_CHKGROUPEXPAND
				invoke GetDlgItem,hWin,IDUSE
				invoke EnableWindow,eax,TRUE
			.endif
		.elseif edx==EN_CHANGE
			invoke GetDlgItem,hWin,IDUSE
			invoke EnableWindow,eax,TRUE
		.endif
	.elseif eax==WM_SIZING
		mov		edx,lParam
		mov		eax,[edx].RECT.top
		add		eax,poht
		mov		[edx].RECT.bottom,eax
		mov		eax,[edx].RECT.right
		sub		eax,[edx].RECT.left
		.if eax<337
			mov		eax,[edx].RECT.left
			add		eax,337
			mov		[edx].RECT.right,eax
		.elseif eax>1024
			mov		eax,[edx].RECT.left
			add		eax,1024
			mov		[edx].RECT.right,eax
		.endif
	.elseif eax==WM_SIZE || eax==WM_MOVE
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.left
		mov		PosProOptLeft,eax
		mov		eax,rect.top
		mov		PosProOptTop,eax
		mov		eax,rect.right
		sub		eax,rect.left
		mov		PosProOptWt,eax
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.right
		mov		wt,eax
		mov		pt.x,0
		mov		pt.y,0
		invoke ClientToScreen,hWin,addr pt
		mov		eax,IDC_GRPPO
		call SizeCtl
		mov		eax,IDC_EDTPRODESCRIPTION
		call SizeCtl
		mov		eax,IDC_EDTCOMPILERC
		call SizeCtl
		mov		eax,IDC_EDTCOMPILERCD
		call SizeCtl
		mov		eax,IDC_EDTASSEMBLE
		call SizeCtl
		mov		eax,IDC_EDTASSEMBLED
		call SizeCtl
		mov		eax,IDC_EDTLINK
		call SizeCtl
		mov		eax,IDC_EDTLINKD
		call SizeCtl
		mov		eax,IDC_EDTRUN
		call SizeCtl
		mov		eax,IDC_EDTRUND
		call SizeCtl
		mov		eax,IDC_EDTDBG
		call SizeCtl
		mov		eax,IDC_EDTDBGD
		call SizeCtl
		mov		eax,IDC_EDTRESTOOBJ
		call SizeCtl
		mov		eax,IDC_EDTRESTOOBJD
		call SizeCtl
		mov		eax,IDC_EDTASMMODULE
		call SizeCtl
		mov		eax,IDC_EDTASMMODULED
		call SizeCtl
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

  SizeCtl:
	invoke GetDlgItem,hWin,eax
	mov		hCtl,eax
	invoke GetWindowRect,hCtl,addr rect
	mov		eax,pt.x
	sub		rect.left,eax
	sub		rect.right,eax
	mov		eax,rect.top
	sub		rect.bottom,eax
	mov		eax,wt
	sub		eax,6
	sub		eax,rect.left
	mov		rect.right,eax
	invoke SetWindowPos,hCtl,NULL,0,0,rect.right,rect.bottom,SWP_NOMOVE or SWP_NOZORDER
	retn

OptProjectProc endp
