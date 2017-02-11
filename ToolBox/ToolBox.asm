.const

NoOfButtons		equ 34
ButtonSize		equ 26

;Used by RadASM 1.2.0.5
CCDEF struct
	ID			dd ?					;Controls uniqe ID
	lptooltip	dd ?					;Pointer to tooltip text
	hbmp		dd ?					;Handle of bitmap
	lpcaption	dd ?					;Pointer to default caption text
	lpname		dd ?					;Pointer to default id-name text
	lpclass		dd ?					;Pointer to class text
	style		dd ?					;Default style
	exstyle		dd ?					;Default ex-style
	flist1		dd ?					;Property listbox 1
	flist2		dd ?					;Property listbox 2
	disable		dd ?					;Disable controls child windows. 0=No, 1=Use method 1, 2=Use method 2
CCDEF ends

;Used by RadASM 2.1.0.4
CCDEFEX struct
	ID			dd ?					;Controls uniqe ID
	lptooltip	dd ?					;Pointer to tooltip text
	hbmp		dd ?					;Handle of bitmap
	lpcaption	dd ?					;Pointer to default caption text
	lpname		dd ?					;Pointer to default id-name text
	lpclass		dd ?					;Pointer to class text
	style		dd ?					;Default style
	exstyle		dd ?					;Default ex-style
	flist1		dd ?					;Property listbox 1
	flist2		dd ?					;Property listbox 2
	flist3		dd ?					;Property listbox 3
	flist4		dd ?					;Property listbox 4
	lpproperty	dd ?
	lpmethod	dd ?
CCDEFEX ends

CUSTCTRL struct
	hDll		dd ?
CUSTCTRL ends

.data

iniCustCtrl			db 'CustCtrl',0
;Dll functions
szGetDef			db 'GetDef',0
szGetDefEx			db 'GetDefEx',0

nButtons			dd NoOfButtons
hButtons			dd NoOfButtons+32 dup(0)
szToolBoxTlt		db 'Pointer,EditText,Static,GroupBox,Button,CheckBox,RadioButton,ComboBox,ListBox,HScroll,VScroll,TabStrip,ProgressBar,TreeView,'
					db 'ListView,TrackBar,UpDown,Image,ToolBar,StatusBar,DatePicker,MonthView,RichEdit,UserDefinedControl,ImageCombo,Shape,IPAddress,'
					db 'Animate,HotKey,HPager,VPager,ReBar,Header,Syslink',0
					db 512 dup(0)
.data?

OldToolBoxBtnProc	dd ?
CustBuff			db 1024 dup(?)
CustCtrl			CUSTCTRL 32 dup(<?>)

.code

GetCustomControls proc uses ebx esi edi
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	espsave:DWORD
	LOCAL	nID:DWORD
	LOCAL	nPr:DWORD
	LOCAL	mDC:HDC
	LOCAL	nColor:DWORD

	mov		ebx,offset CustTypes
	mov		esi,offset CustCtrl
	mov		edi,offset CustBuff
	mov		nPr,NO_OF_PR
	mov		nInx,1
  Nxt:
	invoke BinToDec,nInx,addr buffer
	invoke GetPrivateProfileString,offset iniCustCtrl,addr buffer,offset szNULL,addr buffer,sizeof buffer,offset iniFile
	.if eax
		invoke iniGetItem,addr buffer,addr buffer1
		invoke DecToBin,addr buffer
		mov		nID,eax
		invoke LoadLibrary,addr buffer1
		.if eax
			mov		[esi].CUSTCTRL.hDll,eax
		    invoke GetProcAddress,[esi].CUSTCTRL.hDll,offset szGetDefEx
			.if eax
				xor		ecx,ecx
			  @@:
				push	eax
				push	ecx
				mov		espsave,esp
				push	ecx
				call	eax
				mov		esp,espsave
				.if eax
					mov		edi,eax
					call	GetDef
					call	GetDefEx
					add		ebx,sizeof TYPES
					add		esi,sizeof CUSTCTRL
					inc		nButtons
				.endif
				pop		ecx
				pop		eax
				inc		ecx
				cmp		ecx,nID
				jb		@b
			.else
			    invoke GetProcAddress,[esi].CUSTCTRL.hDll,offset szGetDef
				.if eax
					xor		ecx,ecx
				  @@:
					push	eax
					push	ecx
					mov		espsave,esp
					push	ecx
					call	eax
					mov		esp,espsave
					.if eax
						mov		edi,eax
						call	GetDef
						add		ebx,sizeof TYPES
						add		esi,sizeof CUSTCTRL
						inc		nButtons
					.endif
					pop		ecx
					pop		eax
					inc		ecx
					cmp		ecx,nID
					jb		@b
				.else
					invoke FreeLibrary,[esi].CUSTCTRL.hDll
					mov		[esi].CUSTCTRL.hDll,0
					invoke MessageBox,NULL,offset szGetDef,offset AppName,MB_OK or MB_ICONERROR
				.endif
			.endif
		.else
			invoke strcpy,addr LineTxt,addr OpenFileFail
			invoke strcat,addr LineTxt,addr buffer1
			invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		.endif
		inc		nInx
		jmp		Nxt
	.endif
	ret

GetDef:
	mov		eax,[edi].CCDEF.ID
	mov		[ebx].TYPES.ID,eax
	mov		eax,[edi].CCDEF.lpcaption
	mov		[ebx].TYPES.lpcaption,eax
	mov		eax,[edi].CCDEF.lpname
	mov		[ebx].TYPES.lpidname,eax
	mov		eax,[edi].CCDEF.lpclass
	mov		[ebx].TYPES.lpclass,eax
	mov		eax,[edi].CCDEF.style
	mov		[ebx].TYPES.style,eax
	mov		eax,[edi].CCDEF.exstyle
	mov		[ebx].TYPES.exstyle,eax
	mov		eax,[edi].CCDEF.flist1
	mov		[ebx].TYPES.flist,eax
	mov		eax,[edi].CCDEF.flist2
	mov		[ebx].TYPES.flist[4],eax
	xor		eax,eax
	mov		[ebx].TYPES.flist[8],eax
	mov		[ebx].TYPES.flist[12],eax
	mov		[ebx].TYPES.nmethod,eax
	mov		[ebx].TYPES.methods,eax
	mov		[ebx].TYPES.lprc,offset ConRC
	mov		[ebx].TYPES.ht,100
	mov		[ebx].TYPES.wt,100
	mov		eax,[edi].CCDEF.hbmp
	.if !eax
		invoke LoadBitmap,hInstance,IDB_CUSTCTL
	.endif
	push	eax
	invoke CreateCompatibleDC,NULL
	mov		mDC,eax
	pop		eax
	push	eax
	invoke SelectObject,mDC,eax
	push	eax
	invoke GetPixel,mDC,0,0
	mov		nColor,eax
	pop		eax
	invoke SelectObject,mDC,eax
	invoke DeleteDC,mDC
	pop		eax
	push	eax
	invoke ImageList_AddMasked,hBoxIml,eax,nColor  ; background colour
	pop		eax
	invoke DeleteObject,eax
	mov		buffer,','
	invoke strcpy,addr buffer[1],[edi].CCDEF.lptooltip
	invoke strcat,offset szToolBoxTlt,addr buffer
	invoke strcat,offset szCtlText,addr buffer
	retn

GetDefEx:
	mov		eax,[edi].CCDEFEX.flist3
	mov		[ebx].TYPES.flist[8],eax
	mov		eax,[edi].CCDEFEX.flist4
	mov		[ebx].TYPES.flist[12],eax
	mov		eax,[edi].CCDEFEX.lpmethod
	.if eax
		mov		edx,nPr
		mov		[ebx].TYPES.nmethod,edx
		mov		[ebx].TYPES.methods,eax
	.endif
	mov		edx,[edi].CCDEFEX.lpproperty
	.while byte ptr [edx]
		push	edx
		mov		buffer,','
		invoke iniGetItem,edx,addr buffer[1]
		invoke strcat,offset PrAll,addr buffer
		mov		ecx,nPr
		inc		nPr
		mov		eax,80000000h
		.if ecx>=128
		.elseif ecx>=96
			sub		ecx,96
			shr		eax,cl
			or		[ebx].TYPES.flist[12],eax
		.elseif ecx>=64
			sub		ecx,64
			shr		eax,cl
			or		[ebx].TYPES.flist[8],eax
		.elseif ecx>=32
			sub		ecx,32
			shr		eax,cl
			or		[ebx].TYPES.flist[4],eax
		.else
			shr		eax,cl
			or		[ebx].TYPES.flist[0],eax
		.endif
		pop		edx
	.endw
	retn

GetCustomControls endp

ToolBoxReset proc uses ecx edi

	mov		ecx,nButtons
	dec		ecx
	mov		edi,offset hButtons+4
  @@:
	push	ecx
	push	edi
	mov		eax,[edi]
	invoke SendMessage,eax,BM_SETCHECK,BST_UNCHECKED,0
	pop		edi
	add		edi,4
	pop		ecx
	loop	@b
	invoke SendMessage,hButtons[0],BM_SETCHECK,BST_CHECKED,0
	mov		ToolBoxID,0
	ret

ToolBoxReset endp

ToolBoxSize proc uses ecx esi,lParam:LPARAM
	LOCAL	wt:DWORD
	LOCAL	xP:DWORD
	LOCAL	yP:DWORD
	LOCAL	hBtn:DWORD

	mov		eax,lParam
	and		eax,0FFFFh
	mov		wt,eax
	mov		xP,0
	mov		yP,0
	mov		ecx,nButtons
	mov		esi,offset hButtons
  @@:
	push	ecx
	push	esi
	mov		eax,dword ptr [esi]
	mov		hBtn,eax
	invoke MoveWindow,hBtn,xP,yP,ButtonSize,ButtonSize,TRUE
	add		xP,ButtonSize
	mov		eax,xP
	add		eax,ButtonSize
	.if eax>wt
		mov		xP,0
		add		yP,ButtonSize
	.endif
	pop		esi
	pop		ecx
	add		esi,4
	loop	@b
	ret

ToolBoxSize endp

ToolBoxBtnProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==WM_LBUTTONDOWN
		mov		eax,ToolBoxID
		shl		eax,2
		mov		ebx,offset hButtons
		add		ebx,eax
		invoke SendMessage,[ebx],BM_SETCHECK,BST_UNCHECKED,0
		invoke SendMessage,hWin,BM_SETCHECK,BST_CHECKED,0
		invoke GetWindowLong,hWin,GWL_ID
		mov		ToolBoxID,eax
		invoke GetParent,hWin
		invoke SetFocus,eax
		xor		eax,eax
		ret
	.endif
    invoke CallWindowProc,OldToolBoxBtnProc,hWin,uMsg,wParam,lParam
	ret

ToolBoxBtnProc endp

Do_ToolBoxButton proc hWin:HWND,CtlID:DWORD,hIml:DWORD,ImgID:DWORD
    LOCAL	hBtn:DWORD
	LOCAL	ti:TOOLINFO
	LOCAL	buffer[32]:BYTE

	invoke CreateWindowEx,0,addr szButton,0,
			WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or BS_PUSHLIKE or BS_AUTORADIOBUTTON or BS_ICON,
			0,0,0,0,hWin,CtlID,hInstance,NULL
	mov		hBtn,eax
	invoke ImageList_GetIcon,hIml,ImgID,ILD_NORMAL
	invoke SendMessage,hBtn,BM_SETIMAGE,IMAGE_ICON,eax
	invoke SetWindowLong,hBtn,GWL_WNDPROC,offset ToolBoxBtnProc
	mov		OldToolBoxBtnProc,eax
	invoke iniGetItem,addr szToolBoxTlt,addr buffer
	mov		ti.cbSize,sizeof TOOLINFO
	mov		ti.uFlags,TTF_IDISHWND or TTF_SUBCLASS
	mov		ti.hWnd,0
	m2m		ti.uId,hBtn
	mov		ti.hInst,0
	lea		eax,buffer
	mov		ti.lpszText,eax
	invoke SendMessage,hToolTip,TTM_ADDTOOL,NULL,addr ti
	mov		eax,hBtn
	ret

Do_ToolBoxButton endp

Do_ToolBox proc uses ecx edi
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer2[64]:BYTE
    LOCAL   sTool:DOCKING
    LOCAL   hWin:HWND
    LOCAL   CtlID:DWORD
    LOCAL   ImgID:DWORD

    mov		sTool.ID,3
    mov     sTool.Caption,offset szNULL
	invoke strcpy,addr buffer,addr ToolBox
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Visible,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Docked,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Position,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.IsChild,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.DockWidth,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.DockHeight,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.left,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.top,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.right,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.bottom,eax
    invoke CreateWindowEx,0,addr szStatic,NULL,
            WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_VISIBLE or SS_NOTIFY,
            0,0,0,0,hWnd,0,hInstance,0
	mov     hWin,eax
	invoke Do_ImageList,hInstance,IDB_TOOLBOX,20,32,0,0C0C0C0h,0
	mov     hBoxIml,eax
	invoke CreateWindowEx,NULL,addr ToolTipsClassName,NULL,\
	       TTS_ALWAYSTIP,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,
	       hInstance,NULL
	mov		hToolTip,eax
	invoke GetCustomControls
	mov		CtlID,0
	mov		ImgID,0
	mov		ecx,nButtons
	mov		edi,offset hButtons
  @@:
	push	ecx
	push	edi
	invoke Do_ToolBoxButton,hWin,CtlID,hBoxIml,ImgID
	pop		edi
	mov		[edi],eax
	add		edi,4
	inc		CtlID
	inc		ImgID
	pop		ecx
	loop	@b
	invoke ToolBoxReset
    invoke ToolMessage,hWin,TLM_CREATE,addr sTool
    mov     eax,hWin
    ret

Do_ToolBox endp

