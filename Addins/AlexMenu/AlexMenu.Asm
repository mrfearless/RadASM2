.486
.model flat,stdcall
option casemap:none

include AlexMenu.inc

.code

DllEntryAddin proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntryAddin Endp

FindPos proc uses ebx,hMnu:DWORD,nID:DWORD,nPos:DWORD
	LOCAL	lpFound:DWORD

	mov		lpFound,0
	mov		eax,nID
	mov		ecx,nPos
	mov		edx,hMnu
	mov		ebx,offset mnudata
	.while ebx<offset mnudata+sizeof mnudata
		.if edx==[ebx].MNUDATA.hMnu
			.if eax
				.if eax==[ebx].MNUDATA.nID
					mov		lpFound,ebx
					.break
				.endif
			.else
				.if ecx==[ebx].MNUDATA.nPos
					mov		lpFound,ebx
					.break
				.endif
			.endif
		.endif
		.if !lpFound
			.if ![ebx].MNUDATA.nID && ![ebx].MNUDATA.nPos
				mov		lpFound,ebx
			.endif
		.endif
		add		ebx,sizeof MNUDATA
	.endw
	mov		eax,lpFound
	ret

FindPos endp

CalculateMenu proc uses ebx esi edi,nStyle:DWORD
	LOCAL	mii:MENUITEMINFO
	LOCAL	hDC:HDC
	LOCAL	pt:POINT
	LOCAL	buffer[256]:BYTE
	LOCAL	nPos:DWORD
	LOCAL	fBar:DWORD
	LOCAL	hMnu:DWORD

	mov		eax,lpHandles
	invoke SendMessage,[eax].ADDINHANDLES.hToolBar,TB_GETIMAGELIST,0,0
	mov		hIml,eax
	mov		eax,lpHandles
	invoke SendMessage,[eax].ADDINHANDLES.hToolBar,TB_GETDISABLEDIMAGELIST,0,0
	mov		hImlGray,eax
	invoke GetDC,NULL
	mov		hDC,eax
	mov		eax,hMnuFont
	invoke SelectObject,hDC,eax
	push	eax
	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hMenu
	mov		edx,TRUE
	call	GetMenuItems
	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hToolMenu
	mov		edx,TRUE
	call	GetMenuItems
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,NULL,hDC
	ret

TransLateID:
	xor		edx,edx
	mov		esi,offset MnuBmp
	.while word ptr [esi]
		.if ax==[esi]
			movzx	edx,word ptr [esi+2]
			retn
		.endif
		add		esi,4
	.endw
	retn

GetMenuItems:
	push	hMnu
	push	nPos
	push	fBar
	mov		hMnu,eax
	mov		fBar,edx
	xor		eax,eax
	.if edx
		mov		edx,lpHandles
		mov		ecx,hMnu
		.if ecx==[edx].ADDINHANDLES.hMenu
			mov		edx,lpData
			.if [edx].ADDINDATA.fMaximized
				inc		eax
			.endif
		.endif
	.endif
	mov		nPos,eax
  @@:
	mov		mii.cbSize,sizeof MENUITEMINFO
	mov		mii.fMask,MIIM_DATA or MIIM_ID or MIIM_SUBMENU or MIIM_TYPE
	lea		eax,buffer
	mov		word ptr [eax],0
	mov		mii.dwTypeData,eax
	mov		mii.cch,sizeof buffer/2
	.if fNT
		invoke GetMenuItemInfoW,hMnu,nPos,TRUE,addr mii
		.if eax
			.if !fBar
				test	mii.fType,MFT_SEPARATOR
				.if ZERO?
					mov		mii.fMask,MIIM_DATA or MIIM_TYPE
					.if nStyle
						test	mii.fType,MFT_OWNERDRAW
						.if ZERO?
							invoke FindPos,hMnu,mii.wID,nPos
							.if eax
								mov		ebx,eax
								mov		eax,hMnu
								mov		[ebx].MNUDATA.hMnu,eax
								mov		eax,mii.wID
								mov		[ebx].MNUDATA.nID,eax
								mov		eax,nPos
								mov		[ebx].MNUDATA.nPos,eax
								mov		mii.dwItemData,ebx
								or		mii.fType,MFT_OWNERDRAW
								lea		ecx,buffer
								lea		edi,[ebx].MNUDATA.szString
								.while word ptr [ecx] && word ptr [ecx]!=VK_TAB
									mov		ax,[ecx]
									mov		[edi],ax
									inc		ecx
									inc		ecx
									inc		edi
									inc		edi
								.endw
								mov		word ptr [edi],0
								xor		eax,eax
								lea		edi,[ebx].MNUDATA.szAccel
								.if word ptr [ecx]
									inc		ecx
									inc		ecx
									.while word ptr [ecx]
										mov		ax,[ecx]
										mov		[edi],ax
										inc		ecx
										inc		ecx
										inc		edi
										inc		edi
									.endw
									mov		word ptr [edi],0
									invoke lstrlenW,addr [ebx].MNUDATA.szAccel
									mov		edx,eax
									invoke GetTextExtentPoint32W,hDC,addr [ebx].MNUDATA.szAccel,edx,addr pt
									mov		eax,pt.x
									add		eax,20
								.endif
								mov		[ebx].MNUDATA.wt,eax
								invoke lstrlenW,addr [ebx].MNUDATA.szString
								mov		edx,eax
								invoke GetTextExtentPoint32W,hDC,addr [ebx].MNUDATA.szString,edx,addr pt
								mov		eax,pt.x
								add		eax,25
								add		[ebx].MNUDATA.wt,eax
								mov		eax,mii.wID
								call	TransLateID
								.if edx
									.if edx>100
										mov		eax,lpHandles
										mov		eax,[eax].ADDINHANDLES.hToolBar
										invoke SendMessage,eax,TB_GETBITMAP,edx,0
									.else
										mov		eax,edx
									.endif
									inc		eax
									mov		[ebx].MNUDATA.iImage,eax
								.else
									mov		eax,mii.wID
									mov		ecx,lpData
									mov		ecx,[ecx].ADDINDATA.UserBtnID
									sub		ecx,eax
									neg		ecx
									mov		edx,lpHandles
									mov		edx,[edx].ADDINHANDLES.hToolBar
									.if !ecx || ecx==1
										add		ecx,29991
										invoke SendMessage,edx,TB_GETBITMAP,ecx,0
										.if eax
											inc		eax
											mov		[ebx].MNUDATA.iImage,eax
										.endif
									.else
										invoke SendMessage,edx,TB_GETBITMAP,eax,0
										.if eax
											inc		eax
											mov		[ebx].MNUDATA.iImage,eax
										.endif
									.endif
								.endif
								invoke SetMenuItemInfoW,hMnu,nPos,TRUE,addr mii
							.else
								PrintHex eax
							.endif
						.endif
					.else
						mov		ebx,mii.dwItemData
						.if ebx
							test	mii.fType,MFT_OWNERDRAW
							.if !ZERO?
								and		mii.fType,-1 xor MFT_OWNERDRAW
								mov		mii.dwItemData,0
								lea		eax,buffer
								mov		mii.dwTypeData,eax
								invoke lstrcpyW,addr buffer,addr [ebx].MNUDATA.szString
								.if [ebx].MNUDATA.szAccel
									invoke lstrlenW,addr buffer
									mov		edx,eax
									mov		dword ptr buffer[edx*2],VK_TAB
									invoke lstrcpyW,addr buffer[edx*2+2],addr [ebx].MNUDATA.szAccel
								.endif
								invoke SetMenuItemInfoW,hMnu,nPos,TRUE,addr mii
							.endif
						.endif
					.endif
				.endif
			.endif
			mov		eax,mii.hSubMenu
			.if eax
				mov		edx,FALSE
				call	GetMenuItems
			.endif
			inc		nPos
			jmp		@b
		.endif
	.else
		invoke GetMenuItemInfo,hMnu,nPos,TRUE,addr mii
		.if eax
			.if !fBar
				test	mii.fType,MFT_SEPARATOR
				.if ZERO?
					mov		mii.fMask,MIIM_DATA or MIIM_TYPE
					.if nStyle
						test	mii.fType,MFT_OWNERDRAW
						.if ZERO?
							invoke FindPos,hMnu,mii.wID,nPos
							.if eax
								mov		ebx,eax
								mov		eax,hMnu
								mov		[ebx].MNUDATA.hMnu,eax
								mov		eax,mii.wID
								mov		[ebx].MNUDATA.nID,eax
								mov		eax,nPos
								mov		[ebx].MNUDATA.nPos,eax
								mov		mii.dwItemData,ebx
								or		mii.fType,MFT_OWNERDRAW
								lea		ecx,buffer
								lea		edi,[ebx].MNUDATA.szString
								.while byte ptr [ecx] && byte ptr [ecx]!=VK_TAB
									mov		al,[ecx]
									mov		[edi],al
									inc		ecx
									inc		edi
								.endw
								mov		byte ptr [edi],0
								xor		eax,eax
								lea		edi,[ebx].MNUDATA.szAccel
								.if byte ptr [ecx]
									inc		ecx
									.while byte ptr [ecx]
										mov		al,[ecx]
										mov		[edi],al
										inc		ecx
										inc		edi
									.endw
									mov		byte ptr [edi],0
									invoke lstrlen,addr [ebx].MNUDATA.szAccel
									mov		edx,eax
									invoke GetTextExtentPoint32,hDC,addr [ebx].MNUDATA.szAccel,edx,addr pt
									mov		eax,pt.x
									add		eax,20
								.endif
								mov		[ebx].MNUDATA.wt,eax
								invoke lstrlen,addr [ebx].MNUDATA.szString
								mov		edx,eax
								invoke GetTextExtentPoint32,hDC,addr [ebx].MNUDATA.szString,edx,addr pt
								mov		eax,pt.x
								add		eax,25
								add		[ebx].MNUDATA.wt,eax
								mov		eax,mii.wID
								call	TransLateID
								.if edx
									.if edx>100
										mov		eax,lpHandles
										mov		eax,[eax].ADDINHANDLES.hToolBar
										invoke SendMessage,eax,TB_GETBITMAP,edx,0
									.else
										mov		eax,edx
									.endif
									inc		eax
									mov		[ebx].MNUDATA.iImage,eax
								.else
									mov		eax,mii.wID
									mov		ecx,lpData
									mov		ecx,[ecx].ADDINDATA.UserBtnID
									sub		ecx,eax
									neg		ecx
									mov		edx,lpHandles
									mov		edx,[edx].ADDINHANDLES.hToolBar
									.if !ecx || ecx==1
										add		ecx,29991
										invoke SendMessage,edx,TB_GETBITMAP,ecx,0
										.if eax
											inc		eax
											mov		[ebx].MNUDATA.iImage,eax
										.endif
									.else
										invoke SendMessage,edx,TB_GETBITMAP,eax,0
										.if eax
											inc		eax
											mov		[ebx].MNUDATA.iImage,eax
										.endif
									.endif
								.endif
								invoke SetMenuItemInfo,hMnu,nPos,TRUE,addr mii
							.endif
						.endif
					.else
						mov		ebx,mii.dwItemData
						.if ebx
							test	mii.fType,MFT_OWNERDRAW
							.if !ZERO?
								and		mii.fType,-1 xor MFT_OWNERDRAW
								mov		mii.dwItemData,0
								lea		eax,buffer
								mov		mii.dwTypeData,eax
								invoke lstrcpy,addr buffer,addr [ebx].MNUDATA.szString
								.if [ebx].MNUDATA.szAccel
									invoke lstrlen,addr buffer
									mov		dword ptr buffer[eax],VK_TAB
									invoke lstrcat,addr buffer,addr [ebx].MNUDATA.szAccel
								.endif
								invoke SetMenuItemInfo,hMnu,nPos,TRUE,addr mii
							.endif
						.endif
					.endif
				.endif
			.endif
			mov		eax,mii.hSubMenu
			.if eax
				mov		edx,FALSE
				call	GetMenuItems
			.endif
			inc		nPos
			jmp		@b
		.endif
	.endif
	pop		fBar
	pop		nPos
	pop		hMnu
	retn

CalculateMenu endp

WndProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	mDC:HDC

	mov		eax,uMsg
	.if eax==WM_MEASUREITEM
		mov		ebx,lParam
		.if [ebx].MEASUREITEMSTRUCT.CtlType==ODT_MENU
			mov		edx,[ebx].MEASUREITEMSTRUCT.itemData
			.if edx
				mov		eax,[edx].MNUDATA.wt
				mov		[ebx].MEASUREITEMSTRUCT.itemWidth,eax
				mov		eax,MnuFontHt
				mov		[ebx].MEASUREITEMSTRUCT.itemHeight,eax
			.endif
			xor		eax,eax
			jmp		Ex
		.endif
	.elseif eax==WM_DRAWITEM
		mov		ebx,lParam
		.if [ebx].DRAWITEMSTRUCT.CtlType==ODT_MENU
			mov		esi,[ebx].DRAWITEMSTRUCT.itemData
			.if esi
				invoke CreateCompatibleDC,[ebx].DRAWITEMSTRUCT.hdc
				mov		mDC,eax
				mov		rect.left,0
				mov		rect.top,0
				mov		edx,[ebx].DRAWITEMSTRUCT.rcItem.right
				mov		rect.right,edx
				mov		eax,MnuFontHt
				mov		rect.bottom,eax
				invoke CreateCompatibleBitmap,[ebx].DRAWITEMSTRUCT.hdc,edx,eax
				invoke SelectObject,mDC,eax
				push	eax
				mov		eax,hMnuFont
				invoke SelectObject,mDC,eax
				push	eax
				invoke SetBkMode,mDC,TRANSPARENT
				mov		eax,hMenuBrush
				.if !eax
					mov		eax,COLOR_MENU+1
				.endif
				invoke FillRect,mDC,addr rect,eax
				mov		eax,COLOR_GRAYTEXT
				test	[ebx].DRAWITEMSTRUCT.itemState,ODS_GRAYED
				.if ZERO?
					mov		eax,COLOR_MENUTEXT
					test	[ebx].DRAWITEMSTRUCT.itemState,ODS_SELECTED
					.if !ZERO?
						test	[ebx].DRAWITEMSTRUCT.itemState,ODS_CHECKED
						.if !ZERO?
							mov		rect.left,19
						.elseif [esi].MNUDATA.iImage
							mov		rect.left,19
						.endif
						invoke FillRect,mDC,addr rect,COLOR_HIGHLIGHT+1
						mov		eax,COLOR_HIGHLIGHTTEXT
					.endif
				.endif
				mov		rect.left,20
				sub		rect.right,15
				invoke GetSysColor,eax
				invoke SetTextColor,mDC,eax
				call	PaintText
				mov		eax,[esi].MNUDATA.iImage
				.if eax
					dec		eax
					mov		edx,MnuFontHt
					sub		edx,18
					shr		edx,1
					inc		edx
					test	[ebx].DRAWITEMSTRUCT.itemState,ODS_GRAYED
					.if !ZERO?
						.if hImlGray
							invoke ImageList_Draw,hImlGray,eax,mDC,1,edx,ILD_TRANSPARENT
						.else
							invoke ImageList_Draw,hIml,eax,mDC,1,edx,ILD_MASK or ILD_TRANSPARENT
						.endif
					.else
						test	[ebx].DRAWITEMSTRUCT.itemState,ODS_CHECKED
						.if !ZERO?
							invoke ImageList_Draw,hIml,eax,mDC,1,edx,ILD_TRANSPARENT
						.else
							invoke ImageList_Draw,hIml,eax,mDC,1,edx,ILD_TRANSPARENT
							test	[ebx].DRAWITEMSTRUCT.itemState,ODS_SELECTED
							.if !ZERO?
								mov		rect.left,0
								mov		rect.right,18
								mov		edx,MnuFontHt
								sub		edx,18
								shr		edx,1
								mov		rect.top,edx
								add		edx,18
								mov		rect.bottom,edx
								invoke DrawEdge,mDC,addr rect,BDR_RAISEDINNER,BF_RECT
							.endif
						.endif
					.endif
				.endif
				test	[ebx].DRAWITEMSTRUCT.itemState,ODS_CHECKED
				.if !ZERO?
					mov		rect.left,1
					mov		rect.right,17
					mov		edx,MnuFontHt
					sub		edx,18
					shr		edx,1
					inc		edx
					mov		rect.top,edx
					add		edx,16
					mov		rect.bottom,edx
					test	[ebx].DRAWITEMSTRUCT.itemState,ODS_GRAYED
					.if !ZERO?
						.if ![esi].MNUDATA.iImage
							invoke ImageList_Draw,hIml,41,mDC,0,rect.top,ILD_MASK or ILD_TRANSPARENT
						.endif
						invoke GetStockObject,GRAY_BRUSH
						dec		rect.left
						inc		rect.right
						dec		rect.top
						inc		rect.bottom
						invoke FrameRect,mDC,addr rect,eax
					.else
						.if ![esi].MNUDATA.iImage
							invoke ImageList_Draw,hIml,41,mDC,0,rect.top,ILD_TRANSPARENT
						.endif
						dec		rect.left
						inc		rect.right
						dec		rect.top
						inc		rect.bottom
						invoke DrawEdge,mDC,addr rect,BDR_SUNKENOUTER,BF_RECT
					.endif
				.endif
				invoke BitBlt,[ebx].DRAWITEMSTRUCT.hdc,0,[ebx].DRAWITEMSTRUCT.rcItem.top,[ebx].DRAWITEMSTRUCT.rcItem.right,MnuFontHt,mDC,0,0,SRCCOPY
				pop		eax
				invoke SelectObject,mDC,eax
				pop		eax
				invoke SelectObject,mDC,eax
				invoke DeleteObject,eax
				invoke DeleteDC,mDC
			.endif
			xor		eax,eax
			inc		eax
			jmp		Ex
		.endif
	.endif
	invoke CallWindowProc,lpOldWndProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

PaintText:
	.if fNT
		invoke lstrlenW,addr [esi].MNUDATA.szString
		.if eax
			mov		edx,eax
			invoke DrawTextW,mDC,addr [esi].MNUDATA.szString,edx,addr rect,DT_VCENTER or DT_SINGLELINE
			invoke lstrlenW,addr [esi].MNUDATA.szAccel
			.if eax
				mov		edx,eax
				invoke DrawTextW,mDC,addr [esi].MNUDATA.szAccel,edx,addr rect,DT_VCENTER or DT_SINGLELINE or DT_RIGHT
			.endif
		.endif
	.else
		invoke lstrlen,addr [esi].MNUDATA.szString
		.if eax
			mov		edx,eax
			invoke DrawText,mDC,addr [esi].MNUDATA.szString,edx,addr rect,DT_VCENTER or DT_SINGLELINE
			invoke lstrlen,addr [esi].MNUDATA.szAccel
			.if eax
				mov		edx,eax
				invoke DrawText,mDC,addr [esi].MNUDATA.szAccel,edx,addr rect,DT_VCENTER or DT_SINGLELINE or DT_RIGHT
			.endif
		.endif
	.endif
	retn

WndProc endp

OSSpecific PROC uses ebx
	LOCAL	osvi:OSVERSIONINFO

	invoke GetModuleHandle,offset szUserLib
	mov		ebx,eax
	mov		osvi.dwOSVersionInfoSize,sizeof OSVERSIONINFO
	invoke GetVersionEx,addr osvi
	xor		eax,eax
	.IF osvi.dwPlatformId==VER_PLATFORM_WIN32_WINDOWS
		.IF osvi.dwMinorVersion==0 ; Win95
		.ELSE
			inc		eax
		.endif
	.ELSEIF osvi.dwPlatformId==VER_PLATFORM_WIN32_NT
		.IF osvi.dwMajorVersion<5 ; NT3.51 NT4
		.ELSE
			inc		eax
		.endif
		mov		fNT,TRUE
	.ENDIF
	.if eax
		invoke GetProcAddress,ebx,offset szSetMenuInfo
		mov		pSetMenuInfo,eax
	.endif
	ret

OSSpecific ENDP

SetMenuInfo proc param1:DWORD,param2:DWORD
	.IF pSetMenuInfo
		push param2
		push param1
		call pSetMenuInfo
	.ENDIF
	ret
SetMenuInfo endp

MakeBitMap proc uses esi edi,barcolor:DWORD,bodycolor:DWORD
	LOCAL	hBmp:DWORD
	LOCAL	hDC:DWORD
	LOCAL	hMemDC:DWORD
	LOCAL	hDeskTop:DWORD

	invoke GetDesktopWindow
	mov hDeskTop,eax
	invoke GetDC,hDeskTop
	mov hDC,eax
	invoke CreateCompatibleDC,hDC
	mov hMemDC,eax
	invoke CreateCompatibleBitmap,hDC,600,8
	mov hBmp,eax
	invoke ReleaseDC,hDeskTop,hDC
	invoke SelectObject,hMemDC,hBmp
	push eax
	xor esi,esi
	.while esi<8
		xor edi,edi
		.if StyleMenu
			.WHILE edi<19
				invoke SetPixel,hMemDC,edi,esi,barcolor
				inc edi
			.ENDW
		.else
			.WHILE edi<16
				invoke SetPixel,hMemDC,edi,esi,barcolor
				inc edi
			.ENDW
		.endif
		.WHILE edi<600
			invoke SetPixel,hMemDC,edi,esi,bodycolor
			inc edi
		.ENDW
		inc esi
	.endw
	pop eax
	invoke SelectObject,hMemDC,eax
	invoke DeleteDC,hMemDC
	mov eax,hBmp
	ret

MakeBitMap endp

CoolMenus proc uses edi,BarColor:DWORD,BodyColor:DWORD,fReset:DWORD
	LOCAL	MInfo:MENUINFO

	.if fReset
		invoke GetSysColorBrush,COLOR_MENU
	.else
		.IF !hMenuBmp
			invoke MakeBitMap,BarColor,BodyColor
			mov hMenuBmp,eax
			invoke CreatePatternBrush,eax
			mov hMenuBrush,eax
		.ENDIF
		mov eax,hMenuBrush
	.endif
	mov MInfo.hbrBack,eax
	mov MInfo.cbSize,SIZEOF MENUINFO
	mov MInfo.fMask,MIM_BACKGROUND or MIM_APPLYTOSUBMENUS
	xor edi,edi
  @@:
	mov eax,lpHandles
	invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,edi
	.if eax
		mov edx,eax
		invoke SetMenuInfo,edx,ADDR MInfo
		inc edi
		jmp @b
	.endif
	mov edx,lpHandles
	invoke SetMenuInfo,[edx].ADDINHANDLES.hToolMenu,ADDR MInfo
	mov eax,lpHandles
	invoke GetSystemMenu,[eax].ADDINHANDLES.hWnd,FALSE
	mov edx,eax
	invoke SetMenuInfo,edx,ADDR MInfo
	ret

CoolMenus endp

SetMenus proc fOpt:DWORD

	invoke GetSysColor,COLOR_MENU
	mov ecx,eax
	mov edx,eax
	mov eax,fOpt
	and eax,01Ch
	.if eax==04h
		mov ecx,0FFFFFFh
	.elseif eax==08h
		mov ecx,0E4CFCFh
	.elseif eax==0Ch
		mov ecx,0CFE4CFh
	.elseif eax==10h
		mov ecx,0CFCFE4h
	.endif
	mov eax,fOpt
	and eax,0E0h
	.if eax==20h
		mov edx,0FFFFFFh
	.elseif eax==40h
		mov edx,0E4CFCFh
	.elseif eax==60h
		mov edx,0CFE4CFh
	.elseif eax==80h
		mov edx,0CFCFE4h
	.endif
	mov eax,fOpt
	and eax,0FCh
	.if eax
		invoke CoolMenus,ecx,edx,FALSE
	.else
		invoke CoolMenus,ecx,edx,TRUE
	.endif
	ret

SetMenus endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx esi edi,hWin:DWORD,fOpt:DWORD
	LOCAL	ncm:NONCLIENTMETRICS

	mov	ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov lpHandles,eax
	;Get pointer to procs struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov lpProcs,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0
	mov lpData,eax
	mov ncm.cbSize,sizeof NONCLIENTMETRICS
	invoke SystemParametersInfo,SPI_GETNONCLIENTMETRICS,sizeof NONCLIENTMETRICS,addr ncm,0
	invoke CreateFontIndirect,addr ncm.lfMenuFont
	mov		hMnuFont,eax
	mov		eax,ncm.lfMenuFont.lfHeight
	.if sdword ptr eax<0
		neg		eax
	.endif
	add		eax,6
	.if eax<18
		mov		eax,18
	.endif
	mov		MnuFontHt,eax
	mov eax,lpHandles
	invoke SendMessage,[eax].ADDINHANDLES.hToolBar,TB_GETIMAGELIST,0,0
	mov hIml,eax
	mov eax,lpHandles
	invoke SendMessage,[eax].ADDINHANDLES.hToolBar,TB_GETDISABLEDIMAGELIST,0,0
	mov hImlGray,eax
	invoke OSSpecific
	mov eax,fOpt
	mov fOptions,eax
	and eax,3
	mov StyleMenu,eax
	invoke CalculateMenu,eax
	.if !lpOldWndProc
		invoke SetWindowLong,ebx,GWL_WNDPROC,offset WndProc
		mov lpOldWndProc,eax
	.endif
	invoke SetMenus,fOpt
	; Messages to hook into
	mov	eax,RAM_CLOSE or RAM_INITMENUPOPUP or RAM_PROJECTOPENED or RAM_PROJECTCLOSED
	mov ecx,RAM_UNHOOK or RAM_LANGUAGECHANGE 
	; EDX must be null before we return
	xor edx,edx
	ret

InstallDll Endp

GetOptions proc

	mov eax,offset AddinOpt
	ret

GetOptions endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov	eax,uMsg
	.if eax==AIM_CLOSE
		invoke CalculateMenu,0
		invoke RtlZeroMemory,offset mnudata,sizeof mnudata
		.if lpOldWndProc
			;Let the next in the chain unhook me
			push RAM_UNHOOK
			push lpOldWndProc
			push offset WndProc
			push AIM_UNHOOK
			mov eax,lpHandles
			push [eax].ADDINHANDLES.hWnd
			mov eax,lpProcs
			call [eax].ADDINPROCS.lpDllProc
			mov eax,lpHandles
			invoke GetWindowLong,[eax].ADDINHANDLES.hWnd,GWL_WNDPROC
			.if eax==offset WndProc
				;My hook is on top, just unhook me
				mov eax,lpHandles
				invoke SetWindowLong,[eax].ADDINHANDLES.hWnd,GWL_WNDPROC,lpOldWndProc
			.endif
			mov lpOldWndProc,0
		.endif
		.if hMenuBrush
			invoke DeleteObject,hMenuBrush
			invoke DeleteObject,hMenuBmp
			mov hMenuBrush,0
			mov hMenuBmp,0
		.endif
		.if hMnuFont
			invoke DeleteObject,hMnuFont
			mov		hMnuFont,0
		.endif
	.elseif eax==AIM_INITMENUPOPUP
;		invoke SetMenus,fOptions
		invoke CalculateMenu,StyleMenu
	.elseif eax==AIM_UNHOOK
		mov eax,lpHandles
		mov eax,[eax].ADDINHANDLES.hWnd
		.if eax==hWin
			mov eax,wParam
			.if eax==lpOldWndProc
				;Remove the hook from the chain
				mov eax,lParam
				mov lpOldWndProc,eax
				mov eax,TRUE
				jmp Ex
			.endif
		.endif
	.elseif eax==AIM_LANGUAGECHANGE || eax==AIM_PROJECTOPENED || eax==AIM_PROJECTCLOSED
		invoke CalculateMenu,0
		invoke RtlZeroMemory,offset mnudata,sizeof mnudata
		invoke SetMenus,fOptions
	.endif
	mov eax,FALSE
  Ex:
	ret

DllProc Endp

End DllEntryAddin
