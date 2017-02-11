;#########################################################################
;	Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;	Include file

include Preview.inc

.code

TestProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.right
		mov		fntwt,eax
		mov		eax,rect.bottom
		mov		fntht,eax
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

TestProc endp

Do_TreeViewAddNode proc	hWin:HWND,lhPar:DWORD,lhInsAfter:DWORD,pszText:DWORD,pidSel:DWORD
	LOCAL	tvins:TV_INSERTSTRUCT

	mov		eax,lhPar
	mov		tvins.hParent,eax
	mov		eax,lhInsAfter
	mov		tvins.hInsertAfter,eax
	mov		tvins.item._mask,TVIF_TEXT or TVIF_IMAGE or	TVIF_SELECTEDIMAGE
	mov		eax,pszText
	mov		tvins.item.pszText,eax
	mov		eax,pidSel
	mov		tvins.item.iImage,eax
	mov		tvins.item.iSelectedImage,eax
	invoke SendMessage,hWin,TVM_INSERTITEM,0,addr tvins
	ret

Do_TreeViewAddNode endp

DlgEnumProc proc uses esi,hWin:HWND,lParam:LPARAM
	LOCAL	tci:TCITEM
	LOCAL	lvi:LVITEM
	LOCAL	tbb:TBBUTTON
	LOCAL	tbab:TBADDBITMAP
	LOCAL	cbei:COMBOBOXEXITEM
	LOCAL	rbbi:REBARBANDINFO
	LOCAL	hdi:HD_ITEM
	LOCAL	buffer[MAX_PATH]

	invoke GetParent,hWin
	.if eax==hDlg
		invoke GetWindowLong,hWin,GWL_ID
		mov		esi,sizeof DIALOG
		mul		esi
		mov		esi,eax
		add		esi,lpDlgMem
		add		esi,sizeof DLGHEAD
		mov		eax,[esi].DIALOG.ntypeid
		.if eax==7
			;ComboBox
			invoke SendMessage,hWin,CB_ADDSTRING,0,addr szAppName
			invoke SendMessage,hWin,CB_ADDSTRING,0,addr szAppName
			invoke SendMessage,hWin,CB_SETCURSEL,0,0
		.elseif eax==8
			;ListBox
			invoke SendMessage,hWin,LB_ADDSTRING,0,addr szAppName
			invoke SendMessage,hWin,LB_ADDSTRING,0,addr szAppName
		.elseif eax==11
			;TabControl
			mov		tci.imask,TCIF_TEXT
			mov		tci.pszText,offset szAppName
			mov		tci.cchTextMax,0
			invoke SendMessage,hWin,TCM_INSERTITEM,0,addr tci
			invoke SendMessage,hWin,TCM_INSERTITEM,1,addr tci
		.elseif eax==12
			;ProgressBar
			invoke SendMessage,hWin,PBM_STEPIT,0,0
			invoke SendMessage,hWin,PBM_STEPIT,0,0
			invoke SendMessage,hWin,PBM_STEPIT,0,0
		.elseif eax==13
			;TreeView
			mov		eax,lpHandles
			invoke SendMessage,hWin,TVM_SETIMAGELIST,0,[eax].ADDINHANDLES.hTbrIml
			invoke Do_TreeViewAddNode,hWin,TVI_ROOT,NULL,offset szAppName,42+0
			mov		edx,eax
			push	eax
			invoke Do_TreeViewAddNode,hWin,edx,NULL,offset szAppName,42+1
			mov		edx,eax
			push	eax
			invoke Do_TreeViewAddNode,hWin,edx,NULL,offset szAppName,42+2
			pop		eax
			invoke SendMessage,hWin,TVM_EXPAND,TVE_EXPAND,eax
			pop		eax
			invoke SendMessage,hWin,TVM_EXPAND,TVE_EXPAND,eax
		.elseif eax==14
			;ListView
			invoke SendMessage,hWin,LVM_SETCOLUMNWIDTH,-1,LVSCW_AUTOSIZE
			mov		eax,lpHandles
			invoke SendMessage,hWin,LVM_SETIMAGELIST,LVSIL_SMALL,[eax].ADDINHANDLES.hTbrIml
			mov		lvi.imask,LVIF_TEXT or LVIF_IMAGE
			mov		lvi.iItem,0
			mov		lvi.iSubItem,0
			mov		lvi.pszText,offset szAppName
			mov		lvi.cchTextMax,0
			mov		lvi.iImage,42+0
			invoke SendMessage,hWin,LVM_INSERTITEM,0,addr lvi
			mov		lvi.iItem,1
			mov		lvi.iImage,42+1
			invoke SendMessage,hWin,LVM_INSERTITEM,0,addr lvi
			mov		lvi.iItem,2
			mov		lvi.iImage,42+2
			invoke SendMessage,hWin,LVM_INSERTITEM,0,addr lvi
		.elseif eax==17
			;Image
			invoke GetWindowLong,hWin,GWL_STYLE
			and		eax,SS_TYPEMASK
			.if eax==SS_BITMAP
				.if [esi].DIALOG.caption
					mov		eax,lpData
					mov		eax,[eax].ADDINDATA.lpProjectPath
					invoke lstrcpy,addr buffer,eax
					invoke lstrcat,addr buffer,addr [esi].DIALOG.caption
					invoke LoadImage,NULL,addr buffer,IMAGE_BITMAP,NULL,NULL,LR_LOADFROMFILE
					push	eax
				.else
					invoke LoadBitmap,hInstance,100
					push	eax
				.endif
				invoke SendMessage,hWin,STM_SETIMAGE,IMAGE_BITMAP,eax
				pop		eax
				invoke SetWindowLong,hWin,GWL_USERDATA,eax
			.elseif eax==SS_ICON
				.if [esi].DIALOG.caption
					mov		eax,lpData
					mov		eax,[eax].ADDINDATA.lpProjectPath
					invoke lstrcpy,addr buffer,eax
					invoke lstrcat,addr buffer,addr [esi].DIALOG.caption
					invoke LoadImage,NULL,addr buffer,IMAGE_ICON,NULL,NULL,LR_LOADFROMFILE or LR_DEFAULTSIZE
					push	eax
				.else
					invoke LoadIcon,0,IDI_WINLOGO
					push	0
				.endif
				invoke SendMessage,hWin,STM_SETIMAGE,IMAGE_ICON,eax
				pop		eax
				invoke SetWindowLong,hWin,GWL_USERDATA,eax
			.endif
		.elseif eax==18
			;ToolBar
			invoke SendMessage,hWin,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
			invoke SendMessage,hWin,TB_SETBUTTONSIZE,0,00100010h
			invoke SendMessage,hWin,TB_SETBITMAPSIZE,0,00100010h
			mov		tbab.hInst,HINST_COMMCTRL
			mov		tbab.nID,IDB_STD_SMALL_COLOR
			invoke SendMessage,hWin,TB_ADDBITMAP,12,addr tbab
			mov		tbb.fsState,TBSTATE_ENABLED
			mov		tbb.dwData,0
			mov		tbb.iString,0
			mov		tbb.iBitmap,0
			mov		tbb.idCommand,0
			mov		tbb.fsStyle,TBSTYLE_SEP
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,0
			mov		tbb.idCommand,1
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,1
			mov		tbb.idCommand,2
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,2
			mov		tbb.idCommand,3
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,0
			mov		tbb.idCommand,0
			mov		tbb.fsStyle,TBSTYLE_SEP
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,3
			mov		tbb.idCommand,4
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,4
			mov		tbb.idCommand,5
			mov		tbb.fsStyle,TBSTYLE_BUTTON
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
			mov		tbb.iBitmap,0
			mov		tbb.idCommand,0
			mov		tbb.fsStyle,TBSTYLE_SEP
			invoke SendMessage,hWin,TB_ADDBUTTONS,1,addr tbb
		.elseif eax==24
			;ImageCombo
			mov		eax,lpHandles
			invoke SendMessage,hWin,CBEM_SETIMAGELIST,0,[eax].ADDINHANDLES.hTbrIml
			mov		cbei._mask,CBEIF_IMAGE or CBEIF_TEXT or CBEIF_SELECTEDIMAGE
			mov		cbei.iItem,0
			mov		cbei.pszText,offset szAppName
			mov		cbei.cchTextMax,32
			mov		cbei.iImage,42+0
			mov		cbei.iSelectedImage,42+0
			invoke SendMessage,hWin,CBEM_INSERTITEM,0,addr cbei
			mov		cbei.iItem,1
			mov		cbei.iImage,42+1
			mov		cbei.iSelectedImage,42+1
			invoke SendMessage,hWin,CBEM_INSERTITEM,0,addr cbei
			invoke SendMessage,hWin,CB_SETCURSEL,0,0
		.elseif eax==26
			;IPAddress
			invoke SendMessage,hWin,IPM_SETADDRESS,0,080818283h
		.elseif eax==27
			;Animate
			.if [esi].DIALOG.caption
				mov		eax,lpData
				mov		eax,[eax].ADDINDATA.lpProjectPath
				invoke lstrcpy,addr buffer,eax
				invoke lstrcat,addr buffer,addr [esi].DIALOG.caption
				invoke SendMessage,hWin,ACM_OPEN,0,addr buffer
			.endif
		.elseif eax==28
			;HotKey
			invoke SendMessage,hWin,HKM_SETHOTKEY,(HOTKEYF_CONTROL shl 8) or VK_A,0
		.elseif eax==31
			;Rebar
		.elseif eax==32
			;Header
			mov		hdi.imask,HDI_TEXT or HDI_WIDTH or HDI_FORMAT
			mov		hdi.lxy,100
			mov		hdi.pszText,offset szAppName
			mov		hdi.fmt,HDF_STRING
			invoke SendMessage,hWin,HDM_INSERTITEM,0,addr hdi
		.elseif eax>=33
			invoke SendMessage,hWin,WM_USER+9999,0,0
		.endif
	.endif
	mov		eax,TRUE
	ret

DlgEnumProc endp

DlgEnumDelProc proc hWin:HWND,lParam:LPARAM

	invoke GetParent,hWin
	.if eax==hDlg
		invoke GetWindowLong,hWin,GWL_USERDATA
		.if eax
			invoke DeleteObject,eax
		.endif
	.endif
	mov		eax,TRUE
	ret

DlgEnumDelProc endp

DlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT

	mov		eax,uMsg
	.if eax==WM_CLOSE
		invoke EnumChildWindows,hWin,addr DlgEnumDelProc,0
		invoke DestroyWindow,hWin
		mov		hDlg,0
	.elseif eax==WM_ACTIVATE
		mov		eax,wParam
		movzx	eax,ax
		mov		edx,lpHandles
		.if eax==WA_INACTIVE
			mov		eax,hGoTo
		.else
			mov		eax,[edx].ADDINHANDLES.hGoTo
			mov		hGoTo,eax
			mov		eax,hWin
		.endif
		mov		[edx].ADDINHANDLES.hGoTo,eax
		mov		eax,FALSE
		ret
	.elseif eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hDlg,eax
		invoke GetWindowRect,hWin,addr rect
		mov		eax,lpDlgMem
		add		eax,sizeof DLGHEAD
		test	[eax].DIALOG.style,WS_CAPTION
		.if ZERO?
			invoke GetSystemMetrics,SM_CYCAPTION
			push	eax
			invoke GetSystemMetrics,SM_CYDLGFRAME
			push	eax
			invoke GetSystemMetrics,SM_CXDLGFRAME
			push	eax
			mov		eax,rect.right
			sub		eax,rect.left
			pop		ecx
			add		eax,ecx
			add		eax,ecx
			mov		edx,rect.bottom
			sub		edx,rect.top
			pop		ecx
			add		edx,ecx
			add		edx,ecx
			pop		ecx
			add		edx,ecx
			invoke SetWindowPos,hWin,0,0,0,eax,edx,SWP_NOMOVE or SWP_NOZORDER
		.endif
		invoke EnumChildWindows,hWin,addr DlgEnumProc,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

GetCtrlSize proc uses ebx esi edi,lpDIALOG:DWORD,lpRECT:DWORD
	LOCAL	rect:RECT
	LOCAL	bux:DWORD
	LOCAL	buy:DWORD

	mov		esi,lpDIALOG
	mov		edi,lpRECT
	mov		eax,[esi].DIALOG.ntype
	.if eax==0
		invoke GetClientRect,[esi].DIALOG.hwnd,addr rect
	.else
		mov		eax,[esi].DIALOG.ccx
		mov		rect.right,eax
		mov		eax,[esi].DIALOG.ccy
		mov		rect.bottom,eax
	.endif
	invoke GetDialogBaseUnits
	movzx	edx,ax
	mov		bux,edx
	shr		eax,16
	mov		buy,eax
	mov		eax,[esi].DIALOG.x
	shl		eax,2
	mov		ebx,dfntwt
	imul	ebx
	cdq
	mov		ebx,bux
	idiv	ebx
	cdq
	mov		ebx,fntwt
	idiv	ebx
	mov		[edi],ax
	mov		eax,[esi].DIALOG.y
	shl		eax,3
	mov		ebx,dfntht
	mul		ebx
	cdq
	mov		ebx,buy
	idiv	ebx
	cdq
	mov		ebx,fntht
	idiv	ebx
	mov		[edi+2],ax
	mov		eax,rect.right
	shl		eax,2+9
	mov		ebx,dfntwt
	mul		ebx
	xor		edx,edx
	mov		ebx,bux
	idiv	ebx
	xor		edx,edx
	mov		ebx,fntwt
	idiv	ebx
	shr		eax,9
	mov		[edi+4],ax
	mov		eax,rect.bottom
	shl		eax,3+9
	mov		ebx,dfntht
	mul		ebx
	xor		edx,edx
	mov		ebx,buy
	idiv	ebx
	xor		edx,edx
	mov		ebx,fntht
	idiv	ebx
	shr		eax,9
	mov		[edi+6],ax
	ret

GetCtrlSize endp

SaveWideChar proc lpStringA:DWORD,lpStringW:DWORD

	invoke lstrlen,lpStringA
	invoke MultiByteToWideChar,CP_ACP,0,lpStringA,eax,lpStringW,256
	lea		eax,[eax*2]
	mov		edx,lpStringW
	mov		word ptr [edx+eax],0
	add		eax,2
	ret

SaveWideChar endp

ShowDialog proc uses esi edi ebx,hWin:HWND,hMem:DWORD
	LOCAL	nInx:DWORD

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,128*1024
	mov		ebx,eax
	push	eax
	mov		esi,hMem
	mov		edi,esi
	mov		lpDlgMem,esi
	add		esi,sizeof DLGHEAD
	mov		dlgdata,WS_VISIBLE or WS_CAPTION
	mov		dlgps,0
	mov		dlgfn,0
	invoke DialogBoxIndirectParam,hInstance,offset dlgdata,hWin,offset TestProc,0
	mov		eax,fntwt
	mov		dfntwt,eax
	mov		eax,fntht
	mov		dfntht,eax
	.if byte ptr [edi].DLGHEAD.font
		mov		dlgdata,WS_VISIBLE or WS_CAPTION or DS_SETFONT
		mov		eax,[edi].DLGHEAD.fontsize
		mov		dlgps,ax
		invoke SaveWideChar,addr [edi].DLGHEAD.font,offset dlgfn
	.endif
	invoke DialogBoxIndirectParam,hInstance,offset dlgdata,hWin,offset TestProc,0
	mov		eax,[esi].DIALOG.style
	.if byte ptr [edi].DLGHEAD.font
		or		eax,DS_SETFONT
	.endif
	or		eax,DS_NOFAILCREATE or WS_VISIBLE
	and		eax,-1 xor WS_CHILD
	mov		[ebx].MyDLGTEMPLATE.style,eax
	push	eax
	mov		eax,[esi].DIALOG.exstyle
	mov		[ebx].MyDLGTEMPLATE.dwExtendedStyle,eax
	push	esi
	mov		ecx,-1
	.while [esi].DIALOG.hwnd
		.if [esi].DIALOG.hwnd!=-1
			inc		ecx
		.endif
		add		esi,sizeof DIALOG
	.endw
	pop		esi
	mov		[ebx].MyDLGTEMPLATE.cdit,cx
	invoke GetCtrlSize,esi,addr [ebx].MyDLGTEMPLATE.x
	add		ebx,sizeof MyDLGTEMPLATE
	;Menu
	xor		eax,eax
	.if [edi].DLGHEAD.menuid
		mov		word ptr [ebx],-1
		add		ebx,2
		mov		word ptr [ebx],10000
	.else
		mov		word ptr [ebx],0
	.endif
	add		ebx,2
	;Class
	mov		word ptr [ebx],0
	add		ebx,2
	;Caption
	invoke SaveWideChar,addr [esi].DIALOG.caption,ebx
	add		ebx,eax
	pop		eax
	test	eax,DS_SETFONT
	.if !ZERO?
		;Fontsize
		mov		eax,[edi].DLGHEAD.fontsize
		mov		[ebx],ax
		add		ebx,2
		;Facename
		invoke SaveWideChar,addr [edi].DLGHEAD.font,ebx
		add		ebx,eax
	.endif
	add		esi,sizeof DIALOG
	xor		ecx,ecx
  @@:
	add		ebx,2
	and		ebx,0FFFFFFFCh
	call	FindCtrl
	.if [edi].DIALOG.hwnd
		push	ecx
		mov		eax,[edi].DIALOG.style
		or		eax,WS_VISIBLE
		.if [edi].DIALOG.ntype==14
			or		eax,LVS_SHAREIMAGELISTS
		.endif
		mov		[ebx].MyDLGITEMTEMPLATE.style,eax
		mov		eax,[edi].DIALOG.exstyle
		mov		[ebx].MyDLGITEMTEMPLATE.dwExtendedStyle,eax
		invoke GetCtrlSize,edi,addr [ebx].MyDLGITEMTEMPLATE.x
		mov		eax,nInx
		mov		[ebx].MyDLGITEMTEMPLATE.id,ax
		add		ebx,sizeof MyDLGITEMTEMPLATE
		mov		eax,[edi].DIALOG.ntype
		mov		edx,sizeof TYPES
		mul		edx
		mov		edx,lpData
		add		eax,[edx].ADDINDATA.lpCtlTypes
		invoke SaveWideChar,[eax].TYPES.lpclass,ebx
		add		ebx,eax
		invoke SaveWideChar,addr [edi].DIALOG.caption,ebx
		add		ebx,eax
		mov		word ptr [ebx],0
		add		ebx,2
		pop		ecx
		inc		ecx
		jmp		@b
	.endif
	pop		ebx
	;invoke DialogBoxIndirectParam,hInstance,ebx,hWin,offset DlgProc,0
	invoke CreateDialogIndirectParam,hInstance,ebx,hWin,offset DlgProc,0
	invoke GlobalFree,ebx
	ret

FindCtrl:
	mov		nInx,0
	mov		edi,esi
	.while [edi].DIALOG.hwnd
		.if [edi].DIALOG.hwnd!=-1
			inc		nInx
			.break .if ecx==[edi].DIALOG.tab
		.endif
		add		edi,sizeof DIALOG
	.endw
	retn

ShowDialog endp

;#########################################################################
;	Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry endp

InstallDll proc uses ebx hWin:DWORD,fOpt:DWORD
	LOCAL	tbb:TBBUTTON
	LOCAL	hBmp:DWORD

	invoke LoadBitmap,hInstance,100
	mov		hBmp,eax
	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0	
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	;Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov		IDAddIn,eax
	mov		ebx,lpHandles
	invoke SendMessage,[ebx].ADDINHANDLES.hToolBar,TB_GETIMAGELIST,0,0
	invoke ImageList_AddMasked,eax,hBmp,0C0C0C0h
	mov tbb.iBitmap,eax
	mov eax,IDAddIn
	mov tbb.idCommand,eax
	mov tbb.fsState,TBSTATE_ENABLED
	mov tbb.fsStyle,TBSTYLE_BUTTON
	mov tbb.dwData,0
	mov tbb.iString,NULL
	;Add a button to the toolbar
	invoke SendMessage,[ebx].ADDINHANDLES.hToolBar,TB_ADDBUTTONS,1,ADDR tbb
	invoke DeleteObject,hBmp
	;Messages to hook into
	mov		eax,RAM_COMMAND or RAM_CLOSE or RAM_TBRTOOLTIP
	;ECX and EDX must be null before we return
	xor		ecx,ecx
	xor		edx,edx
	ret 

InstallDll endp

DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	;This proc handles messages sent from RadASM to our dll
	;Return TRUE to prevent RadASM and other DLL's from

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if edx==IDAddIn && eax==BN_CLICKED
			;Your addin has been selected
			.if hDlg
				invoke SendMessage,hDlg,WM_CLOSE,0,0
			.else
				mov		eax,lpHandles
				.if [eax].ADDINHANDLES.hDialog
					;Get dialog memory
					invoke GetWindowLong,[eax].ADDINHANDLES.hMdiCld,4
					invoke ShowDialog,hWin,eax
				.endif
			.endif
			mov		eax,TRUE
			jmp		Ex
		.endif
	.elseif eax==AIM_CLOSE
		.if hDlg
			invoke SendMessage,hDlg,WM_CLOSE,0,0
		.endif
		mov		edx,lpHandles
		invoke SendMessage,[edx].ADDINHANDLES.hToolBar,TB_COMMANDTOINDEX,IDAddIn,0
		mov		edx,lpHandles
		invoke SendMessage,[edx].ADDINHANDLES.hToolBar,TB_DELETEBUTTON,eax,0
		mov		IDAddIn,0
	.elseif eax==AIM_TBRTOOLTIP
		mov		eax,wParam
		.if eax==IDAddIn
			push	sizeof szBuff/2
			push	offset szBuff
			push	4000
			push	offset szAppName
			mov		eax,lpProc
			call [eax].ADDINPROCS.lpGetLangString
			.if !eax
				mov		eax,offset szPreview
			.else
				mov		eax,offset szBuff
				;To tell RadASM it's unicode
				mov		edx,123456
			.endif
			jmp		Ex
		.endif
	.endif
	mov		eax,FALSE
  Ex:
	ret

DllProc endp

;#########################################################################

end DllEntry
