#Include "DialogPreview.Inc"
#Include "C:\RadASM\GoAsm\Inc\RadAsm.inc"

ADDINOPT struct
	lpStr			dd ?
	nAnd			dd ?
	nOr				dd ?
ADDINOPT ends

.data
	hInstance		DD		0
	lpHandles		DD		0
	lpProcs			DD		0
	lpData			DD		0

	AddInID			DD		0
	Options			DD		0
	hFont			DD		0
	hToolbar		DD		0
	hMainDlg		DD		0
	hBmp			DD		0
	hLVIml			DD		0
	hTVIml			DD		0
	hLVImlLarge		DD		0
	
	ClassName		DB		"PreviewClass",0

	szTipText		DB		"Preview Dialog",0
	szDlgClass		DB		"DlgEdit",0
	
	AddinOpt		ADDINOPT <0,0,0>

.code

GetOptions:
	mov eax,offset AddinOpt
	ret

DllEntryPoint	FRAME hInst, reason, reserved1
    mov eax,[hInst]
    mov [hInstance], eax
    xor eax, eax
    inc eax
    ret
ENDF

InstallDll FRAME hWin, fOpt
	uses ebx,edi
;	LOCAL tbab		:TBADDBITMAP
	LOCAL tbb		:TBBUTTON
;	LOCAL hDC		:D
;	LOCAL memdc		:D
;	LOCAL hbrsh		:D

	invoke SendMessage, [hWin], AIM_GETHANDLES, 0, 0
	mov	[lpHandles], eax
	invoke SendMessage, [hWin], AIM_GETPROCS, 0, 0
	mov [lpProcs], eax
	invoke SendMessage, [hWin], AIM_GETDATA, 0, 0
	mov [lpData], eax
	mov eax,[fOpt]
	mov [Options],eax

	invoke SendMessage, [hWin], AIM_GETMENUID, 0, 0
	mov [AddInID], eax

	mov eax,[lpHandles]
	mov eax,[eax+ADDINHANDLES.hToolBar]
	mov [hToolbar],eax

	invoke LoadBitmap,[hInstance],1297
	mov [hBmp],eax

;	invoke GetDC,[hToolbar]
;	mov [hDC],eax
;	invoke CreateCompatibleDC,[hDC]
;	mov [memdc],eax
;	invoke ReleaseDC,[hDC]
;	invoke SelectObject,[memdc],[hBmp]
;	mov ebx,eax
;	invoke GetSysColor,COLOR_3DFACE
;	invoke CreateSolidBrush,eax
;	mov [hbrsh],eax
;	invoke SelectObject,[memdc],eax
;	mov edi,eax
;	invoke GetPixel,[memdc],0,0
;	invoke FloodFill,[memdc],0,0,0
;	invoke SelectObject,[memdc],edi
;	invoke DeleteObject,[hbrsh]
;	invoke SelectObject,[memdc],ebx
;	invoke DeleteDC,[memdc]
;
;	mov D[tbab.hInst],NULL
;	mov eax,[hBmp]
;	mov D[tbab.nID],eax
;	invoke SendMessage,[hToolbar],TB_ADDBITMAP,1,offset tbab
;
	invoke SendMessage,[hToolbar],TB_GETIMAGELIST,0,0
	invoke ImageList_AddMasked,eax,[hBmp],0C0C0C0h
	mov [tbb.iBitmap],eax
	mov eax,[AddInID]
	mov [tbb.idCommand],eax
	mov D[tbb.fsState],TBSTATE_ENABLED
	mov D[tbb.fsStyle],TBSTYLE_BUTTON
	mov D[tbb.dwData],0
	mov D[tbb.iString],NULL
	;Add a button to the toolbar
	invoke SendMessage,[hToolbar],TB_ADDBUTTONS,1,ADDR tbb
	invoke DeleteObject,[hBmp]

	mov eax,RAM_COMMAND + RAM_CLOSE + RAM_TBRTOOLTIP
	xor ecx,ecx
	xor edx,edx
	ret
ENDF

DllProc	FRAME hWin, uMsg, wParam, lParam

	cmp D[uMsg], AIM_COMMAND
	jnz >.TBRTOOLTIP
		mov eax, [wParam]
		cmp [AddInID], eax
		jnz >>.ExitMsgLoop
			mov eax,[lpHandles]
			mov eax,[eax+ADDINHANDLES.hDialog]
			or eax,eax
			jz >>.ExitMsgLoop
			mov [hMainDlg],eax
			invoke WinFromDialog,eax
			mov eax,TRUE
			ret

	.TBRTOOLTIP
	cmp D[uMsg],AIM_TBRTOOLTIP
	jnz >.AIMCLOSE
		movzx eax,W[wParam]
		cmp eax,[AddInID]
		jne >>.ExitMsgLoop
			mov eax,offset szTipText
			ret

	.AIMCLOSE
	cmp D[uMsg], AIM_CLOSE
	jnz >.ExitMsgLoop
		invoke SendMessage,[hToolbar],TB_COMMANDTOINDEX,[AddInID],0
		invoke SendMessage,[hToolbar],TB_DELETEBUTTON,eax,0
		invoke ImageList_Destroy,[hLVIml]
		invoke ImageList_Destroy,[hTVIml]
		invoke ImageList_Destroy,[hLVImlLarge]
		mov D[hLVIml],NULL
		mov D[hTVIml],NULL
		mov D[hLVImlLarge],NULL

	.ExitMsgLoop
	xor eax, eax
	ret
ENDF

EnumDialog FRAME hwnd,lParam
	uses ebx,edi,esi
	LOCAL ExStyle		:D
	LOCAL Style			:D
	LOCAL dwID			:D
	LOCAL szText[1024]	:B
	LOCAL szClass[64]	:B
	LOCAL ClRect		:RECT
	LOCAL pRect			:RECT
	LOCAL hChild		:D

	invoke GetWindowLong,[hwnd],GWL_EXSTYLE
	mov [ExStyle],eax
	invoke GetWindowLong,[hwnd],GWL_STYLE
	mov [Style],eax
	invoke GetWindowLong,[hwnd],GWL_ID
	mov [dwID],eax
	invoke GetWindowText,[hwnd],offset szText,1024
	invoke GetClassName,[hwnd],offset szClass,64
	invoke GetWindowRect,[hwnd],offset ClRect
	mov eax,[ClRect.left]
	sub D[ClRect.right],eax
	mov eax,[ClRect.top]
	sub D[ClRect.bottom],eax
	invoke lstrcmpi,offset szClass,"Static"
	or eax,eax
	jnz >
	invoke FindWindowEx,[hwnd],NULL,NULL,NULL
	or eax,eax
	jnz >>.EXIT
	:
	invoke lstrcmpi,offset szClass,"SysHeader32"
	or eax,eax
	jnz >
	invoke GetParent,[hwnd]
	cmp eax,[hMainDlg]
	jne >>.EXIT
	:
	
	invoke ScreenToClient,[hMainDlg],offset ClRect
	invoke lstrcmpi,offset szClass,"combobox"
	or eax,eax
	jnz >
		mov eax,[Style]
		and eax,2
		jz >
		invoke SendMessage,[hwnd],CB_GETDROPPEDCONTROLRECT,0,offset pRect
		mov eax,[pRect.bottom]
		sub eax,[pRect.top]
		mov [ClRect.bottom],eax
	:

	invoke CreateWindowEx,[ExStyle],offset szClass,offset szText,[Style],\
		[ClRect.left],[ClRect.top],[ClRect.right],[ClRect.bottom],\
		[lParam],[dwID],[hInstance],NULL
	mov [hChild],eax

	invoke SendMessage,[hChild],WM_SETFONT,[hFont],TRUE
	invoke EnableWindow,[hChild],TRUE
	
	invoke lstrcmpi,offset szClass,"listbox"
	or eax,eax
	jnz >
		invoke PopulateListBox,[hChild]
		jmp >>.EXIT
	:
	invoke lstrcmpi,offset szClass,"combobox"
	or eax,eax
	jnz >
		invoke PopulateComboBox,[hChild]
		jmp >.EXIT
	:
	invoke lstrcmpi,offset szClass,"SysListView32"
	or eax,eax
	jnz >
		invoke PopulateListview,[hChild]
		jmp >.EXIT
	:
	invoke lstrcmpi,offset szClass,"SysTreeView32"
	or eax,eax
	jnz >
		invoke PopulateTreeview,[hChild]
		jmp >.EXIT
	:
	invoke lstrcmpi,offset szClass,"SysHeader32"
	or eax,eax
	jnz >
		invoke PopulateHeader,[hChild]
		jmp >.EXIT
	:
	.EXIT
	mov eax,TRUE
	RET
ENDF

WinFromDialog FRAME hDlg
	LOCAL rect			:RECT
	LOCAL wc			:WNDCLASSEX
	LOCAL msg			:MSG
	LOCAL hwnd			:D
	LOCAL dwExStyle		:D
	LOCAL dwStyle		:D
	LOCAL AppName[64]	:B
	LOCAL hDlgDC		:D

	invoke GetWindowLong,[hDlg],GWL_EXSTYLE
	mov [dwExStyle],eax

	invoke GetWindowLong,[hDlg],GWL_STYLE
	xor eax,WS_CHILD
	mov [dwStyle],eax

	
	invoke FindWindowEx,[hDlg],0,0,0
	or eax,eax
	jz >
	invoke SendMessage,eax,WM_GETFONT,0,0
	or eax,eax
	jnz >F1
	:
	invoke GetStockObject,DEFAULT_GUI_FONT
	F1:
	mov [hFont],eax

	invoke GetWindowRect,[hDlg],offset rect
	mov eax,[rect.left]
	sub D[rect.right],eax
	mov eax,[rect.top]
	sub D[rect.bottom],eax
	invoke GetWindowText,[hDlg],offset AppName,64

	mov D[wc.cbSize],SIZEOF WNDCLASSEX
	mov D[wc.style], CS_HREDRAW + CS_VREDRAW
	mov [wc.lpfnWndProc], OFFSET WndProc
	mov D[wc.cbClsExtra],NULL
	mov D[wc.cbWndExtra],NULL
	push [hInstance]
	pop [wc.hInstance]
	mov D[wc.hbrBackground],COLOR_BTNFACE+1
	mov D[wc.lpszMenuName],NULL
	mov [wc.lpszClassName],OFFSET ClassName
	
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov [wc.hIcon],eax
	mov [wc.hIconSm],eax
	
	invoke LoadCursor,NULL,IDC_ARROW
	mov [wc.hCursor],eax
	
	invoke RegisterClassEx, addr wc
	invoke CreateWindowEx,[dwExStyle],ADDR ClassName,ADDR AppName,\
			[dwStyle],[rect.left],\
			[rect.top],[rect.right],[rect.bottom],NULL,NULL,\
			[hInstance],NULL

	mov [hwnd],eax

	; Create each of the children in turn through an enumeration
	invoke EnumChildWindows,[hDlg],offset EnumDialog,[hwnd]

	invoke ShowWindow, [hwnd],SW_SHOWNORMAL
	invoke UpdateWindow, [hwnd]

	:
		invoke GetMessage, ADDR msg,NULL,0,0
		or eax,eax
		jz >
			invoke IsDialogMessage, [hwnd], ADDR msg
			or eax,eax
			jnz <
		invoke TranslateMessage, ADDR msg
		invoke DispatchMessage, ADDR msg
		jmp <
	:

	mov eax,[msg.wParam]
	RET
ENDF

WndProc FRAME hWnd, uMsg, wParam, lParam

	.WM_CREATE
	cmp D[uMsg],WM_CREATE
	jne >.WM_COMMAND
		jmp >>.EXIT

	.WM_COMMAND
	cmp D[uMsg],WM_COMMAND
	jne >.WM_CLOSE
		jmp >>.EXIT

	.WM_CLOSE
	cmp D[uMsg],WM_CLOSE
	jne >.WM_DESTROY
		invoke DestroyWindow,[hWnd]
		jmp >>.EXIT

	.WM_DESTROY
	cmp D[uMsg],WM_DESTROY
	jne >.DEFPROC
		invoke PostQuitMessage,NULL
		jmp >>.DEFPROC

	.DEFPROC
		invoke DefWindowProc,[hWnd],[uMsg],[wParam],[lParam]		
		ret

	.EXIT

	xor eax,eax
	ret
ENDF

PopulateListBox FRAME hwnd
	uses ebx
	xor ebx,ebx
	:
	invoke SendMessage,[hwnd],LB_ADDSTRING,0,offset szTipText
	inc ebx
	cmp ebx,10
	jb <

	RET
ENDF

PopulateComboBox FRAME hwnd
	uses ebx
	xor ebx,ebx
	:
	invoke SendMessage,[hwnd],CB_ADDSTRING,0,offset szTipText
	inc ebx
	cmp ebx,10
	jb <

	RET
ENDF

PopulateTreeview FRAME hwnd
	uses ebx
	LOCAL tvis		:TV_INSERTSTRUCT
	LOCAL hpar		:D

	cmp D[hTVIml],0
	jne >>.INSERTITEMS
	
	invoke ImageList_Create,16,16,ILC_MASK + ILC_COLOR24,1,10
	mov [hTVIml],eax
	invoke LoadIcon,NULL,IDI_APPLICATION
	push eax
	invoke ImageList_AddIcon,[hTVIml],eax
	pop eax
	invoke DestroyIcon,eax
	invoke LoadIcon,NULL,IDI_QUESTION
	push eax
	invoke ImageList_AddIcon,[hTVIml],eax
	pop eax
	invoke DestroyIcon,eax

	.INSERTITEMS

	invoke SendMessage,[hwnd],TVM_SETIMAGELIST,TVSIL_NORMAL,[hTVIml]

	; INSERT A NODE

	mov D[tvis.hParent],NULL
	mov D[tvis.hInsertAfter],NULL
	mov D[tvis.itemex.pszText],offset szTipText
	mov D[tvis.itemex.iImage],0
	mov D[tvis.itemex.iSelectedImage],0
	mov D[tvis.itemex.imask],TVIF_TEXT + TVIF_IMAGE + TVIF_SELECTEDIMAGE
	invoke SendMessage,[hwnd],TVM_INSERTITEM,0,addr tvis
	mov [hpar],eax
	
	xor ebx,ebx
	L1:
	
	mov eax,[hpar]
	mov D[tvis.hParent],eax
	mov D[tvis.hInsertAfter],NULL
	mov D[tvis.itemex.pszText],offset szTipText
	mov D[tvis.itemex.iImage],1
	mov D[tvis.itemex.iSelectedImage],1
	mov D[tvis.itemex.imask],TVIF_TEXT + TVIF_IMAGE + TVIF_SELECTEDIMAGE
	invoke SendMessage,[hwnd],TVM_INSERTITEM,0,addr tvis
	
	inc ebx
	cmp ebx,3
	jl <<L1
	

	; INSERT ANOTHER NODE

	mov D[tvis.hParent],NULL
	mov D[tvis.hInsertAfter],NULL
	mov D[tvis.itemex.pszText],offset szTipText
	mov D[tvis.itemex.iImage],0
	mov D[tvis.itemex.iSelectedImage],0
	mov D[tvis.itemex.imask],TVIF_TEXT + TVIF_IMAGE + TVIF_SELECTEDIMAGE
	invoke SendMessage,[hwnd],TVM_INSERTITEM,0,addr tvis
	mov [hpar],eax
	
	xor ebx,ebx
	L1:
	
	mov eax,[hpar]
	mov D[tvis.hParent],eax
	mov D[tvis.hInsertAfter],NULL
	mov D[tvis.itemex.pszText],offset szTipText
	mov D[tvis.itemex.iImage],1
	mov D[tvis.itemex.iSelectedImage],1
	mov D[tvis.itemex.imask],TVIF_TEXT + TVIF_IMAGE + TVIF_SELECTEDIMAGE
	invoke SendMessage,[hwnd],TVM_INSERTITEM,0,addr tvis
	
	inc ebx
	cmp ebx,3
	jl <<L1
	
	RET
ENDF

PopulateListview FRAME hwnd
	uses ebx
	LOCAL lvi			:LV_ITEM
	LOCAL LVColumn		:LV_COLUMN

	invoke SendMessage,[hwnd],LVM_GETHEADER,0,0
	invoke EnableWindow,eax,TRUE
	
	cmp D[hLVIml],0
	jne >>.INSERTITEMS
	
	invoke ImageList_Create,16,16,ILC_MASK + ILC_COLOR24,1,10
	mov [hLVIml],eax
	invoke ImageList_Create,32,32,ILC_MASK + ILC_COLOR24,1,10
	mov [hLVImlLarge],eax
	invoke LoadIcon,NULL,IDI_APPLICATION
	push eax
	invoke ImageList_AddIcon,[hLVIml],eax
	pop eax
	push eax
	invoke ImageList_AddIcon,[hLVImlLarge],eax
	pop eax
	invoke DestroyIcon,eax
	invoke LoadIcon,NULL,IDI_QUESTION
	push eax
	invoke ImageList_AddIcon,[hLVIml],eax
	pop eax
	push eax
	invoke ImageList_AddIcon,[hLVImlLarge],eax
	pop eax
	invoke DestroyIcon,eax
	
	.INSERTITEMS
	
	invoke SendMessage,[hwnd],LVM_SETIMAGELIST,LVSIL_SMALL,[hLVIml]
	invoke SendMessage,[hwnd],LVM_SETIMAGELIST,LVSIL_NORMAL,[hLVImlLarge]

	; Make 2 column headers
	mov D[LVColumn.imask],LVCF_FMT + LVCF_TEXT + LVCF_WIDTH
	mov D[LVColumn.fmt],LVCFMT_LEFT
	mov D[LVColumn.lx],200
	push "Column 1"
	pop [LVColumn.pszText]
	mov D[LVColumn.cchTextMax],9
	invoke SendMessage,[hwnd],LVM_INSERTCOLUMN,0,ADDR LVColumn

	mov D[LVColumn.imask],LVCF_FMT + LVCF_TEXT + LVCF_WIDTH
	mov D[LVColumn.fmt],LVCFMT_LEFT
	mov D[LVColumn.lx],99
	push "Column 0"
	pop [LVColumn.pszText]
	mov D[LVColumn.cchTextMax],9
	invoke SendMessage,[hwnd],LVM_INSERTCOLUMN,0,ADDR LVColumn
	
	invoke SendMessage,[hwnd],LVM_SETEXTENDEDLISTVIEWSTYLE,LVS_EX_FULLROWSELECT + LVS_EX_GRIDLINES,LVS_EX_GRIDLINES + LVS_EX_FULLROWSELECT
	
	; add 3 items
	xor ebx,ebx
	
	L1:
		mov D[lvi.imask],LVIF_PARAM + LVIF_TEXT + LVIF_IMAGE
		mov D[lvi.iSubItem],0
		push "Dialog preview"
		pop [lvi.pszText]

		mov eax,ebx
		and eax,1
		mov [lvi.iImage],eax
		mov D[lvi.lParam],eax
		mov [lvi.iItem],ebx
		invoke SendMessage,[hwnd],LVM_INSERTITEM,0,ADDR lvi
		mov [lvi.iItem],eax

		push "LVS_EX_FULLROWSELECT + LVS_EX_GRIDLINES"
		pop [lvi.pszText]
		mov D[lvi.iSubItem],1
		mov D[lvi.imask],LVIF_TEXT
		invoke SendMessage,[hwnd],LVM_SETITEM,0,ADDR lvi
		inc ebx
		cmp ebx,3
	jl <<L1
	
	ret
	.ICON
	
	RET
ENDF

PopulateHeader FRAME hwnd
	LOCAL hdi		:HD_ITEM
	LOCAL rect		:RECT
	
	invoke GetClientRect,[hwnd],OFFSET rect
	
	mov eax,[rect.right]
	shr eax,2
	mov [hdi.lxy],eax

	mov D[hdi.imask],HDI_TEXT+HDI_WIDTH+HDI_FORMAT
	mov D[hdi.fmt],HDF_STRING+HDF_CENTER

	mov D[hdi.pszText],OFFSET szDlgClass
	invoke SendMessage,[hwnd],HDM_INSERTITEM,0,OFFSET hdi
	mov D[hdi.pszText],OFFSET szDlgClass
	invoke SendMessage,[hwnd],HDM_INSERTITEM,0,OFFSET hdi
	mov D[hdi.pszText],OFFSET szDlgClass
	invoke SendMessage,[hwnd],HDM_INSERTITEM,0,OFFSET hdi
	mov D[hdi.pszText],OFFSET szDlgClass
	invoke SendMessage,[hwnd],HDM_INSERTITEM,0,OFFSET hdi
	
	RET
ENDF