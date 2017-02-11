;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include Res2Dlg.inc
include BitmapFromMemory.ASM

;#########################################################################
;	Specific to the Add In

.data
	strMenuText			BYTE				"Res2Dlg",0
	FileExists			DWORD				TRUE
	AddInString			BYTE				"Enable Res2Dlg",0
	AddinOpt			ADDINOPT			<OFFSET AddInString,1,1>
						ADDINOPT			<0,0,0>

.data?
	hSubMenu			DWORD				?
	lpHandles			DWORD				?
	lpProcs				DWORD				?
	lpData				DWORD				?
	RES2DLGID			DWORD				?
	RAVer				DWORD				?

.code

DllEntry	PROC hInst :DWORD, reason :DWORD, reserved1 :DWORD
    mov eax, hInst
    mov hInstance, eax
    xor eax, eax
    inc eax
    ret
DllEntry	ENDP

InstallDll	PROC hWin :DWORD, fOpt :DWORD
	invoke SendMessage, hWin, AIM_GETHANDLES, 0, 0
	mov	lpHandles, eax
	invoke SendMessage, hWin, AIM_GETPROCS, 0, 0
	mov lpProcs, eax
	invoke SendMessage, hWin, AIM_GETDATA, 0, 0
	mov lpData, eax
	mov ecx, 4
	add ecx, [eax].ADDINDATA.fMaximized
	push ecx
	invoke SendMessage, hWin, AIM_GETMENUID, 0, 0
	mov RES2DLGID, eax
	invoke SendMessage, hWin, AIM_GETHANDLES, 0, 0
	push [eax].ADDINHANDLES.hMenu
	call GetSubMenu
	mov hSubMenu, eax
	invoke AppendMenu, eax, MF_STRING, RES2DLGID, offset strMenuText

	mov eax,lpData
	mov eax,[eax].ADDINDATA.nRadASMVer
	mov RAVer,eax

	invoke GetSystemSizes

	mov eax, RAM_COMMAND or RAM_INITMENUPOPUP or AIM_CLOSE
	xor edx,edx
	xor ecx,ecx
	ret
InstallDll	ENDP

DllProc	PROC hWin :DWORD, uMsg :DWORD, wParam :DWORD, lParam :DWORD
	cmp uMsg, AIM_COMMAND
	jnz @F
		mov eax, wParam
		cmp RES2DLGID, eax
		jnz _end
			mov eax,lpHandles
			mov eax,[eax].ADDINHANDLES.hWnd
			invoke DialogBoxParam,hInstance,500,eax,OFFSET DlgProc,NULL
			mov eax,TRUE
			ret

	@@:
	cmp uMsg, AIM_CLOSE
	jnz @F
		mov eax,lpData
		mov ecx,4
		add ecx,[eax].ADDINDATA.fMaximized
		mov eax,lpHandles
		invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,ecx
		invoke DeleteMenu,eax,RES2DLGID,MF_BYCOMMAND

	@@:
	cmp uMsg, AIM_INITMENUPOPUP
	jnz _end
		mov eax, lpData
		mov eax, [eax].ADDINDATA.fProject
		xor eax, 1
		or eax, MF_BYCOMMAND
		invoke EnableMenuItem, hSubMenu, RES2DLGID, eax
	_end:
	xor eax, eax
	ret
DllProc	ENDP

AddToProject proc pszFilename:DWORD
	.IF FileExists == FALSE
		mov edi,lpProcs
		push FALSE			; fModule
		push TRUE			; fUpdateTree
		push pszFilename	; lpFileName
		call [edi].ADDINPROCS.lpAddProjectFile
		mov		eax,lpData
		.if [eax].ADDINDATA.nRadASMVer>=2014
			;RadASM 2.0.1.4
			;Open the project file
			mov eax,[eax].ADDINDATA.lpFile
			invoke lstrcpy,eax,pszFilename
			cmp RAVer,2027
			jl @F
				Push FALSE
			@@:
			call [edi].ADDINPROCS.lpOpenProjectFile
			;Save the RC file
			push TRUE
			mov eax,lpHandles
			push [eax].ADDINHANDLES.hMdiCld
			call [edi].ADDINPROCS.lpExportDialog
			;Let ReallyRad update main RC file
			push RAM_PROJECTADDNEW
			push pszFilename
			push 1
			push AIM_PROJECTADDNEW
			mov eax,lpHandles
			push [eax].ADDINHANDLES.hWnd
			call [edi].ADDINPROCS.lpDllProc
		.endif
	.ENDIF
	ret
AddToProject endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

;#########################################################################
;	Res2Dlg

DlgProc proc uses edi ebx esi hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL LVItem			:LV_ITEM
	LOCAL LVTextBuffer[64]	:BYTE
	LOCAL sInfo				:SCROLLINFO
	LOCAL pt				:POINT
	LOCAL lpRECT			:RECT

	.if uMsg == WM_INITDIALOG
		mov eax,hWin
		mov hDlg,eax
		invoke GetDlgItem,hDlg,1001
		mov hListView,eax
		invoke SetUpListView
		invoke GetDlgItem,hDlg,234
		mov hPrevBox,eax
;		invoke SetWindowLong,hPrevBox,GWL_WNDPROC,OFFSET ResPreviewSubProc
;		mov pResPreviewProc,eax
		invoke GetDlgItem,hDlg,237
		mov vScroll,eax
		invoke GetDlgItem,hDlg,238
		mov hScroll,eax
		invoke LoadCursor,NULL,IDC_SIZEALL
		mov hCURSOR,eax
		invoke GetSystemSizes
		mov sInfo.cbSize,SIZEOF SCROLLINFO
		mov sInfo.fMask,SIF_ALL
		mov sInfo.nMin,0
		mov sInfo.nPage,277
		mov sInfo.nMax,277
		mov sInfo.nPos,0
		mov sInfo.nTrackPos,0
		invoke SetScrollInfo,vScroll,SB_CTL,ADDR sInfo,TRUE
		mov sInfo.nPage,517
		mov sInfo.nMax,517
		invoke SetScrollInfo,hScroll,SB_CTL,ADDR sInfo,TRUE

	.ELSEIF uMsg == WM_VSCROLL
		mov eax,lParam
		invoke memfill,ADDR sInfo,0,SIZEOF SCROLLINFO
		mov sInfo.cbSize,SIZEOF SCROLLINFO
		mov sInfo.fMask,SIF_ALL
		invoke GetScrollInfo,lParam,SB_CTL,ADDR sInfo
		mov eax,wParam
		.IF ax == SB_BOTTOM
			mov eax,sInfo.nMax
			mov sInfo.nPos,eax
			mov sInfo.nTrackPos,eax

		.ELSEIF ax == SB_LINEDOWN
			inc sInfo.nPos
			inc sInfo.nTrackPos

		.ELSEIF ax == SB_LINEUP
			dec sInfo.nPos
			dec sInfo.nTrackPos

		.ELSEIF ax == SB_PAGEDOWN
			mov eax,sInfo.nPage
			add sInfo.nPos,eax
			add sInfo.nTrackPos,eax

		.ELSEIF ax == SB_PAGEUP
			mov eax,sInfo.nPage
			sub sInfo.nPos,eax
			sub sInfo.nTrackPos,eax

		.ELSEIF ax == SB_THUMBPOSITION
			mov eax,sInfo.nTrackPos
			mov sInfo.nPos,eax

		.ELSEIF ax == SB_THUMBTRACK
			mov eax,sInfo.nTrackPos
			mov sInfo.nPos,eax

		.ELSEIF ax == SB_TOP
			mov sInfo.nPos,0
			mov sInfo.nTrackPos,0

		.endif

		mov sInfo.fMask,SIF_POS or SIF_TRACKPOS
		invoke SetScrollInfo,lParam,SB_CTL,ADDR sInfo,TRUE

		invoke GetWindowRect,hDisplayDialog,ADDR lpRECT
		mov eax,lpRECT.left
		mov pt.x,eax
		mov eax,lpRECT.top
		mov pt.y,eax
		invoke ScreenToClient,hPrevBox,ADDR pt
		mov eax,10
		sub eax,sInfo.nPos
		invoke SetWindowPos,hDisplayDialog,NULL,pt.x,eax,0,0,SWP_NOSIZE or SWP_NOZORDER

	.ELSEIF uMsg == WM_HSCROLL
		mov eax,lParam
		invoke memfill,ADDR sInfo,0,SIZEOF SCROLLINFO
		mov sInfo.cbSize,SIZEOF SCROLLINFO
		mov sInfo.fMask,SIF_ALL
		invoke GetScrollInfo,lParam,SB_CTL,ADDR sInfo
		mov eax,wParam
		.IF ax == SB_BOTTOM
			mov eax,sInfo.nMax
			mov sInfo.nPos,eax
			mov sInfo.nTrackPos,eax

		.ELSEIF ax == SB_LINEDOWN
			inc sInfo.nPos
			inc sInfo.nTrackPos

		.ELSEIF ax == SB_LINEUP
			dec sInfo.nPos
			dec sInfo.nTrackPos

		.ELSEIF ax == SB_PAGEDOWN
			mov eax,sInfo.nPage
			add sInfo.nPos,eax
			add sInfo.nTrackPos,eax

		.ELSEIF ax == SB_PAGEUP
			mov eax,sInfo.nPage
			sub sInfo.nPos,eax
			sub sInfo.nTrackPos,eax

		.ELSEIF ax == SB_THUMBPOSITION
			mov eax,sInfo.nTrackPos
			mov sInfo.nPos,eax

		.ELSEIF ax == SB_THUMBTRACK
			mov eax,sInfo.nTrackPos
			mov sInfo.nPos,eax

		.ELSEIF ax == SB_TOP
			mov sInfo.nPos,0
			mov sInfo.nTrackPos,0

		.endif
		mov sInfo.fMask,SIF_POS or SIF_TRACKPOS
		invoke SetScrollInfo,lParam,SB_CTL,ADDR sInfo,TRUE

		invoke GetWindowRect,hDisplayDialog,ADDR lpRECT
		mov eax,lpRECT.left
		mov pt.x,eax
		mov eax,lpRECT.top
		mov pt.y,eax
		invoke ScreenToClient,hPrevBox,ADDR pt
		mov eax,10
		sub eax,sInfo.nPos
		invoke SetWindowPos,hDisplayDialog,NULL,eax,pt.y,0,0,SWP_NOSIZE or SWP_NOZORDER

	.elseif uMsg == WM_COMMAND
		.IF hDisplayDialog != INVALID_HANDLE_VALUE
			invoke SendMessage,hDisplayDialog,WM_CLOSE,0,0
			mov hDisplayDialog,INVALID_HANDLE_VALUE
		.ENDIF
		mov eax,wParam
		mov dx,ax
		movzx edx,dx
		.IF dx == 1002
			invoke GetResources
		.ELSEIF dx == 1003
			invoke SendMessage,hListView,LVM_GETNEXTITEM,-1,LVNI_SELECTED
			mov LVItem.imask,LVIF_TEXT or LVIF_PARAM
			mov LVItem.iItem,eax
			mov LVItem.iSubItem,0
			lea eax,LVTextBuffer
			mov LVItem.pszText,eax
			mov LVItem.cchTextMax,63
			invoke SendMessage,hListView,LVM_GETITEM,LVItem.iItem,ADDR LVItem
			.IF LVItem.lParam == RT_DIALOG
				invoke SaveDlgResource,hLibForRes,LVItem.pszText,LVItem.lParam
			.ELSEIF LVItem.lParam == RT_BITMAP
				invoke SaveBmpResource,hLibForRes,LVItem.pszText
			.ELSEIF LVItem.lParam == RT_GROUP_ICON
				invoke SaveIconResource,hLibForRes,LVItem.pszText
			.ELSEIF LVItem.lParam == RT_RCDATA
				invoke SaveDataResource,hLibForRes,LVItem.pszText,RT_RCDATA,OFFSET szDefAnyExt,OFFSET szAnyFilterStr
			.ELSEIF LVItem.lParam == RT_STRING
				invoke SaveStringResource,hLibForRes,0
			.ELSEIF LVItem.lParam == RT_GROUP_CURSOR
				invoke SaveCursorResource,hLibForRes,LVItem.pszText,RT_GROUP_CURSOR
			.ELSEIF LVItem.lParam == RT_ANICURSOR
				invoke SaveDataResource,hLibForRes,LVItem.pszText,RT_ANICURSOR,ADDR szDefAniCurExt,ADDR szAniCurFilterStr
			.ELSEIF LVItem.lParam == RT_ANIICON
				invoke SaveDataResource,hLibForRes,LVItem.pszText,RT_ANIICON,ADDR szDefAniCurExt,ADDR szAniCurFilterStr
			.ELSEIF LVItem.lParam == RT_LVIMAGE
				invoke SaveDataResource,hLibForRes,LVItem.pszText,RT_LVIMAGE,ADDR szDefImgExt,ADDR szImgFilterStr
			.ELSEIF LVItem.lParam == RT_FONT
				invoke SaveDataResource,hLibForRes,LVItem.pszText,RT_FONT,ADDR szDefFntExt,ADDR szFntFilterStr
			.ELSE
				mov eax,LVItem.lParam
				.IF eax > 65535
					invoke lstrcmpi,LVItem.lParam,OFFSET szRT_IMAGE
					.IF eax == 0
						invoke SaveDataResource,hLibForRes,LVItem.pszText,LVItem.lParam,OFFSET szDefImgExt,OFFSET szImgFilterStr
					.endif
					invoke lstrcmpi,LVItem.lParam,OFFSET szRT_AVI
					.IF eax == 0
						invoke SaveDataResource,hLibForRes,LVItem.pszText,LVItem.lParam,OFFSET szDefAviExt,OFFSET szAviFilterStr
					.endif
				.endif
			.ENDIF
		.ELSEIF dx == 1004
			invoke SendMessage,hListView,LVM_GETNEXTITEM,-1,LVNI_SELECTED
			mov LVItem.imask,LVIF_TEXT or LVIF_PARAM
			mov LVItem.iItem,eax
			mov LVItem.iSubItem,0
			lea eax,LVTextBuffer
			mov LVItem.pszText,eax
			mov LVItem.cchTextMax,63
			invoke SendMessage,hListView,LVM_GETITEM,LVItem.iItem,ADDR LVItem
			.IF LVItem.lParam == RT_BITMAP
				invoke ShowBmpPreview,hWin,234,hLibForRes,ADDR LVTextBuffer
			.ELSEIF LVItem.lParam == RT_DIALOG
				invoke ShowDlgPreview,hLibForRes,ADDR LVTextBuffer,LVItem.lParam
			.ELSEIF LVItem.lParam == RT_GROUP_ICON
				invoke ShowIconPreview,hLibForRes,ADDR LVTextBuffer,LVItem.lParam
			.ELSEIF LVItem.lParam == RT_GROUP_CURSOR
				invoke ShowIconPreview,hLibForRes,ADDR LVTextBuffer,LVItem.lParam
			.ELSEIF  LVItem.lParam == RT_STRING
				invoke ShowTextPreview,hLibForRes
			.ELSEIF LVItem.lParam == RT_RCDATA
				invoke MessageBox,hDlg,OFFSET szNoPreview,NULL,MB_OK
			.ELSEIF LVItem.lParam == RT_ANICURSOR
				invoke ShowDefaultPreview,hLibForRes,ADDR LVTextBuffer,RT_ANICURSOR,OFFSET szDefAniCurExt
			.ELSEIF LVItem.lParam == RT_ANIICON
				invoke ShowDefaultPreview,hLibForRes,ADDR LVTextBuffer,RT_ANIICON,OFFSET szDefAniCurExt
			.ELSEIF LVItem.lParam == RT_LVIMAGE
				invoke ShowImgPreview,hLibForRes,LVItem.pszText,RT_LVIMAGE
			.ELSEIF LVItem.lParam == RT_FONT
				invoke ShowDefaultPreview,hLibForRes,ADDR LVTextBuffer,RT_FONT,OFFSET szDefFntExt
			.ELSE
				mov eax,LVItem.lParam
				.IF eax > 65535
					invoke lstrcmpi,LVItem.lParam,OFFSET szRT_IMAGE
					.IF eax == 0
						invoke ShowImgPreview,hLibForRes,LVItem.pszText,LVItem.lParam
					.endif
					invoke lstrcmpi,LVItem.lParam,OFFSET szRT_AVI
					.IF eax == 0
						invoke MessageBox,hDlg,OFFSET szNoPreview,NULL,MB_OK
					.endif
				.endif
			.endif
		.ELSEIF dx == 1005
			invoke InvalidateRect,hPrevBox,NULL,TRUE
			invoke UpdateWindow,hPrevBox
		.endif

	.ELSEIF uMsg == WM_NOTIFY
		mov ebx, lParam
		mov eax,[ebx].NMHDR.code
		.IF eax == LVN_ITEMCHANGED
			.IF hDisplayDialog != INVALID_HANDLE_VALUE
				invoke SendMessage,hDisplayDialog,WM_CLOSE,0,0
				mov hDisplayDialog,INVALID_HANDLE_VALUE
			.ENDIF
			invoke InvalidateRect,hPrevBox,NULL,TRUE
			invoke UpdateWindow,hPrevBox
		.endif
		xor eax,eax
		ret

	.ELSEIF uMsg == WM_ACTIVATE
		.IF hDisplayDialog != INVALID_HANDLE_VALUE
			invoke SendMessage,hDisplayDialog,WM_CLOSE,0,0
			mov hDisplayDialog,INVALID_HANDLE_VALUE
		.ENDIF

	.elseif uMsg == WM_CLOSE
		.IF hDisplayDialog != INVALID_HANDLE_VALUE
			invoke SendMessage,hDisplayDialog,WM_CLOSE,0,0
			mov hDisplayDialog,INVALID_HANDLE_VALUE
		.ENDIF
		.IF hResBmp != INVALID_HANDLE_VALUE
			invoke DeleteObject,hResBmp
			mov hResBmp,INVALID_HANDLE_VALUE
		.endif
		.IF hResIcon != INVALID_HANDLE_VALUE
			invoke DestroyIcon,hResIcon
			mov hResIcon,INVALID_HANDLE_VALUE
		.endif
		.IF hLibForRes != INVALID_HANDLE_VALUE
			invoke FreeLibrary,hLibForRes
		.ENDIF
		invoke ImageList_Destroy,hLVIml
		invoke EndDialog,hWin,0

	.else
		mov		eax,FALSE
		ret
	.endif

	mov		eax,TRUE
	ret
DlgProc endp

LoadResourceImage proc hModule:DWORD,pResName:DWORD,ResTypeNumber:DWORD,pcColors:DWORD
	LOCAL hFindRes		:DWORD
	LOCAL hResData		:DWORD
	LOCAL pResData		:DWORD
	LOCAL hDC			:DWORD
	LOCAL cbBits		:DWORD
	LOCAL RGBQuadSize	:DWORD

	invoke FindResource,hModule,pResName,ResTypeNumber
	mov hFindRes,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax

	mov edi,pResData
	movzx ecx,[edi].BITMAPINFO.bmiHeader.biBitCount
	mov cbBits,ecx
	.IF pcColors
		mov eax,pcColors
		mov [eax],ecx
	.ENDIF

	invoke GetDC,hDlg
	mov hDC,eax

	mov ecx,cbBits
	mov eax,1
	shl eax,cl
	mov edx,SIZEOF RGBQUAD
	imul edx
	mov RGBQuadSize,eax
	.IF cbBits >= 24 ; There is no RGBQUAD array for 24 bit
		mov RGBQuadSize,0
		mov eax,0
	.ENDIF
	add eax,SIZEOF BITMAPINFOHEADER
	add eax,pResData

	invoke CreateDIBitmap,hDC,edi,CBM_INIT,eax,edi,DIB_RGB_COLORS
	push eax
	invoke ReleaseDC,hDlg,hDC
	pop eax
	ret
LoadResourceImage endp

LoadResourceIcon proc hModule:DWORD,pResName:DWORD,ResTypeNumber:DWORD
	LOCAL hFindRes		:DWORD
	LOCAL hResData		:DWORD
	LOCAL pResData		:DWORD
	LOCAL ResSize		:DWORD
	LOCAL iName[16]		:BYTE

	mov al,"#"
	mov iName,al

	invoke FindResource,hModule,pResName,ResTypeNumber
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax
	.IF pResData == NULL
		ret
	.endif

	mov eax,pResData
	add eax,SIZEOF GRPICONDIR
	movzx ecx,[eax].GRPICONDIRENTRY.nID

	lea eax,iName
	inc eax
	invoke dwtoa,ecx,eax

	.IF ResTypeNumber == RT_GROUP_ICON
		invoke FindResource,hModule,ADDR iName,RT_ICON
	.ELSE
		invoke FindResource,hModule,ADDR iName,RT_CURSOR
	.ENDIF
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax

	.IF pResData == NULL
		ret
	.endif

	.IF ResTypeNumber == RT_GROUP_ICON
		invoke CreateIconFromResource,pResData,ResSize,TRUE,030000h
	.ELSE
		invoke CreateIconFromResource,pResData,ResSize,FALSE,030000h
	.ENDIF
	push eax
	invoke FreeResource,hResData
	pop eax
	ret
LoadResourceIcon endp

SaveDlgResource proc hModule:DWORD,pResName:DWORD,ResTypeNumber:DWORD
	LOCAL hFindRes		:DWORD
	LOCAL hResData		:DWORD
	LOCAL pResData		:DWORD
	LOCAL ResSize		:DWORD
	LOCAL DialogID		:DWORD

	invoke OpenFileForWrite,ADDR szDefDLGExt,ADDR szDLGFilterStr
	mov hDlgFile,eax
	.IF eax == INVALID_HANDLE_VALUE
		ret
	.ENDIF

	invoke FindResource,hModule,pResName,ResTypeNumber
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax
	.IF pResData == NULL
		ret
	.endif

	mov edx,pResName
	inc edx
	invoke atodw,edx
	mov DialogID,eax

	invoke BuildDlgFile,pResData

	invoke FlushFileBuffers,hDlgFile
	invoke CloseHandle,hDlgFile

	invoke AddToProject,ADDR ofwFilePath

	invoke FreeResource,hResData
	ret

SaveDlgResource endp

SaveBmpResource proc hModule:DWORD,pResName:DWORD
	LOCAL hBitmap		:DWORD
	LOCAL hDIB			:DWORD
	LOCAL hFile			:DWORD
	LOCAL hDC			:DWORD
	LOCAL hMemDC1		:DWORD
	LOCAL hMemDC2		:DWORD
	LOCAL bmp			:BITMAP
	LOCAL cColors		:DWORD
	LOCAL imgX			:DWORD
	LOCAL imgY			:DWORD
	LOCAL OldObj		:DWORD

	invoke OpenFileForWrite,OFFSET szDefBMPExt,OFFSET szBMPFilterStr
	mov hFile,eax
	.IF eax == INVALID_HANDLE_VALUE
		ret
	.ENDIF

	invoke LoadResourceImage,hModule,pResName,RT_BITMAP,ADDR cColors
	mov hDIB,eax
	
	invoke GetObject,hDIB,SIZEOF BITMAP,ADDR bmp

	mov eax,bmp.bmWidth
	mov imgX,eax
	mov eax,bmp.bmHeight
	mov imgY,eax

	invoke GetDC,hDlg
	mov hDC,eax
	invoke CreateCompatibleBitmap,hDC,imgX,imgY
	mov hBitmap,eax
	invoke CreateCompatibleDC,hDC
	mov hMemDC1,eax
	invoke CreateCompatibleDC,hDC
	mov hMemDC2,eax
	invoke ReleaseDC,hDlg,hDC
	invoke SelectObject,hMemDC1,hDIB
	invoke SelectObject,hMemDC2,hBitmap
	mov OldObj,eax

	invoke BitBlt,hMemDC2,0,0,imgX,imgY,hMemDC1,0,0,SRCCOPY

	invoke SelectObject,hMemDC1,OldObj
	invoke SelectObject,hMemDC2,OldObj
	invoke DeleteDC,hMemDC1
	invoke DeleteDC,hMemDC2
	invoke DeleteObject,hDIB

	invoke SaveBitmap,hBitmap,hFile,cColors
	invoke FlushFileBuffers,hFile
	invoke CloseHandle,hFile

	invoke DeleteObject,hBitmap

	ret
SaveBmpResource endp

SaveIconResource proc uses edi esi hModule:DWORD,pResName:DWORD
	LOCAL hFindRes				:DWORD
	LOCAL hResData				:DWORD
	LOCAL pResData				:DWORD
	LOCAL ResSize				:DWORD
	LOCAL iCount				:DWORD
	LOCAL pOutput				:DWORD
	LOCAL hFile					:DWORD
	LOCAL cbWritten				:DWORD
	LOCAL cbWrite				:DWORD
	LOCAL iResName[16]			:BYTE
	LOCAL StrOffset				:DWORD

	invoke OpenFileForWrite,ADDR szDefIcoExt,ADDR szIcoFilterStr
	mov hFile,eax
	.IF eax == INVALID_HANDLE_VALUE
		ret
	.endif

	mov al,"#"
	mov iResName,al

	invoke FindResource,hModule,pResName,RT_GROUP_ICON
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax
	.IF pResData == NULL
		ret
	.endif

	; Calculte the size of the file
	mov edi,pResData
	xor ecx,ecx
	mov cx,[edi].GRPICONDIR.idCount
	mov iCount,ecx
	add edi,SIZEOF GRPICONDIR
	mov eax,SIZEOF GRPICONDIR
	.REPEAT
		add eax,[edi].GRPICONDIRENTRY.dwBytesInRes
		add eax,SIZEOF GRPICONDIRENTRY
		add edi,SIZEOF GRPICONDIRENTRY
	.UNTILCXZ
	mov ecx,iCount
	shl ecx,1
	add eax,ecx
	mov cbWrite,eax
	invoke GlobalAlloc,GMEM_FIXED,eax
	mov pOutput,eax

	mov esi,pResData
	mov edi,pOutput
	; Copy the header (MemCopy,Source,Dest,#Btyes
	invoke MemCopy,pResData,pOutput,SIZEOF GRPICONDIR
	; Move the pointers up
	add esi,SIZEOF GRPICONDIR
	add edi,SIZEOF GRPICONDIR
	; Copy the array of Icon dir entries
	mov ecx,0
	.REPEAT
		push ecx
		; Copy the icon entry
		invoke MemCopy,esi,edi,SIZEOF GRPICONDIRENTRY
		; mov the pointers up
		add esi,SIZEOF GRPICONDIRENTRY
		add edi,SIZEOF GRPICONDIRENTRY
		; An extra 2 for the destination index
		add edi,2
		pop ecx
		inc ecx
	.UNTIL ecx == iCount

	mov ecx,0
	; reset the source index to the first GRPICONDIRENTRY
	mov esi,pResData
	add esi,SIZEOF GRPICONDIR
	; reset the Destination index to the first ICONDIRENTRY
	mov eax,pOutput
	add eax,SIZEOF GRPICONDIR
	mov StrOffset,eax
	.REPEAT
		push ecx
		; Get the id of the icon
		lea ecx,iResName
		inc ecx
		movzx eax,[esi].GRPICONDIRENTRY.nID
		invoke dwtoa,eax,ecx

		; Get a copy of the icon resource
		invoke FindResource,hModule,ADDR iResName,RT_ICON
		mov hFindRes,eax
		invoke SizeofResource,hModule,hFindRes
		mov ResSize,eax
		invoke LoadResource,hModule,hFindRes
		mov hResData,eax
		invoke LockResource,hResData
		mov pResData,eax

		; Copy the icon data to the buffer
		invoke MemCopy,pResData,edi,[esi].GRPICONDIRENTRY.dwBytesInRes

		; move the offset of this data to the array
		mov ecx,edi
		sub ecx,pOutput
		mov eax,StrOffset
		mov [eax].ICONDIRENTRY.dwImageOffset,ecx
		add StrOffset,SIZEOF ICONDIRENTRY

		; Increment the destination pointer
		add edi,[esi].GRPICONDIRENTRY.dwBytesInRes

		; Increment the source pointer
		add esi,SIZEOF GRPICONDIRENTRY
		pop ecx
		inc ecx

	.UNTIL ecx == iCount

	invoke WriteFile,hFile,pOutput,cbWrite,ADDR cbWritten,NULL
	invoke FlushFileBuffers,hFile
	invoke CloseHandle,hFile

	invoke GlobalFree,pOutput
	ret

SaveIconResource endp

SaveDataResource proc hModule:DWORD,pResName:DWORD,ResTypeNumber:DWORD,ResExt:DWORD,ResFilter:DWORD
	LOCAL hFindRes		:DWORD
	LOCAL hResData		:DWORD
	LOCAL pResData		:DWORD
	LOCAL ResSize		:DWORD
	LOCAL cbWrite		:DWORD
	LOCAL hDataFile		:DWORD

	invoke FindResource,hModule,pResName,ResTypeNumber
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax

	.IF hFindRes == 0
		ret
	.ENDIF

	mov ecx,pResData
	mov ecx,[ecx+6] ; Offset of JFIF in a jpeg file
	mov eax,pResData
	mov eax,[eax] ; Offset of GIF8 in a GIF file
	shl eax,8
	shr eax,8
	.IF eax == "FIG" && (ResTypeNumber == OFFSET szRT_IMAGE || ResTypeNumber == RT_LVIMAGE)
		mov ResExt,OFFSET szDefGifExt
		mov ResFilter,OFFSET szGifFilterStr
	.ELSEIF ecx == "FIFJ" && (ResTypeNumber == OFFSET szRT_IMAGE || ResTypeNumber == RT_LVIMAGE)
		mov ResExt,OFFSET szDefImgExt
		mov ResFilter,OFFSET szImgFilterStr
	.endif

	invoke OpenFileForWrite,ResExt,ResFilter
	mov hDataFile,eax
	.IF eax == INVALID_HANDLE_VALUE
		ret
	.ENDIF

	invoke WriteFile,hDataFile,pResData,ResSize,ADDR cbWrite,NULL

	invoke FlushFileBuffers,hDataFile
	invoke CloseHandle,hDataFile
	invoke FreeResource,hResData
	ret

SaveDataResource endp

SaveCursorResource proc uses edi esi hModule:DWORD,pResName:DWORD,ResTypeNumber:DWORD
	LOCAL hFindRes				:DWORD
	LOCAL hResData				:DWORD
	LOCAL pResData				:DWORD
	LOCAL ResSize				:DWORD
	LOCAL pOutput				:DWORD
	LOCAL hFile					:DWORD
	LOCAL cbWrite				:DWORD
	LOCAL iResName[16]			:BYTE
	LOCAL CurHeader				:CURSORHEADER

	invoke OpenFileForWrite,ADDR szDefCurExt,ADDR szCurFilterStr
	mov hFile,eax
	.IF eax == INVALID_HANDLE_VALUE
		ret
	.endif
	mov al,"#"
	mov iResName,al

	invoke FindResource,hModule,pResName,RT_GROUP_CURSOR
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax
	.IF pResData == NULL
		ret
	.endif

	mov edi,pResData
	lea esi,CurHeader

	mov CurHeader.idReserved,0
	mov ax,[edi].GRPICONDIR.idType
	mov CurHeader.idType,ax
	mov ax,[edi].GRPICONDIR.idCount
	mov CurHeader.idCount,ax

	add edi,6
	mov ax,[edi].CURSORDIRENTRY.wWidth
	mov CurHeader.bWidth,al

	mov ax,[edi].CURSORDIRENTRY.wHeight
	shr ax,1
	mov CurHeader.bHeight,al

	mov CurHeader.wPlanes,0
	mov eax,[edi].CURSORDIRENTRY.dwBytesInRes
	sub eax,4
	mov CurHeader.dwBytesInRes,eax

	mov edi,pResData
	add edi,6
	lea ecx,iResName
	inc ecx
	movzx eax,[edi].CURSORDIRENTRY.nID
	invoke dwtoa,eax,ecx

	; Get a copy of the icon resource
	invoke FindResource,hModule,ADDR iResName,RT_CURSOR
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax

	mov edi,pResData
	invoke GlobalAlloc,GMEM_FIXED,ResSize
	mov pOutput,eax
	invoke MemCopy,pResData,pOutput,ResSize
	mov esi,eax
	; Get the hotspot
	mov ax,[edi]
	mov CurHeader.HotSpot.x,ax
	mov ax,[edi+2]
	mov CurHeader.HotSpot.y,ax

	mov DWORD PTR [esi],SIZEOF CurHeader + 4 ; add dword for this offset

	invoke WriteFile,hFile,ADDR CurHeader,SIZEOF CurHeader,ADDR cbWrite,NULL
	invoke WriteFile,hFile,pOutput,ResSize,ADDR cbWrite,NULL

	invoke FlushFileBuffers,hFile
	invoke CloseHandle,hFile
	invoke GlobalFree,pOutput

	ret
SaveCursorResource endp

PreviewDialogProc proc uses ebx esi edi hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL bmp			:BITMAP
	LOCAL	hDC			:DWORD
	LOCAL	ps			:PAINTSTRUCT
	LOCAL	transDC		:DWORD
	LOCAL	lpRECT		:RECT
	LOCAL	OldObj		:DWORD
	LOCAL	sInfo		:SCROLLINFO
	LOCAL	pt			:POINT
	LOCAL	hIconWin	:DWORD

	.if uMsg == WM_INITDIALOG
		mov eax,hWin
		mov hDisplayDialog,eax
		invoke GetWindowLong,hWin,GWL_STYLE
		or eax,WS_CHILD
		invoke SetWindowLong,hWin,GWL_STYLE,eax
		invoke SetParent,hWin,hPrevBox
		.IF hResBmp != INVALID_HANDLE_VALUE
			invoke GetObject,lParam,SIZEOF BITMAP,ADDR bmp
			invoke GetSystemMetrics,SM_CYCAPTION
			add eax,bmp.bmHeight
			add eax,8
			mov ecx,bmp.bmWidth
			add ecx,8
			invoke SetWindowPos,hWin,HWND_TOP,0,0,ecx,eax,SWP_NOMOVE or SWP_NOZORDER
			invoke GetDlgItem,hDisplayDialog,1001
			invoke ShowWindow,eax,SW_HIDE
		.ELSE
			invoke GetDlgItem,hWin,1001
			mov hIconWin,eax
			invoke ShowWindow,hIconWin,SW_SHOW
			invoke SendMessage,hIconWin,STM_SETIMAGE,IMAGE_ICON,lParam
			invoke GetClientRect,hIconWin,ADDR rct
			invoke GetSystemMetrics,SM_CYCAPTION
			add eax,rct.bottom
			add eax,8
			mov ecx,rct.right
			add ecx,8
			invoke SetWindowPos,hWin,HWND_TOP,0,0,ecx,eax,SWP_NOMOVE or SWP_NOZORDER
		.endif
		invoke GetWindowRect,hWin,ADDR lpRECT
		mov sInfo.fMask,SIF_RANGE
		mov sInfo.cbSize,SIZEOF SCROLLINFO
		mov sInfo.nMin,0
		mov eax,lpRECT.right
		sub eax,lpRECT.left
		add eax,20
		mov sInfo.nMax,eax
		invoke SetScrollInfo,hScroll,SB_CTL,ADDR sInfo,TRUE
		mov eax,lpRECT.bottom
		sub eax,lpRECT.top
		add eax,20
		mov sInfo.nMax,eax
		invoke SetScrollInfo,vScroll,SB_CTL,ADDR sInfo,TRUE
		mov eax,lParam

	.elseif uMsg == WM_CLOSE
		invoke EndDialog,hWin,0
		invoke DestroyWindow,hWin

	.elseif uMsg==WM_NCPAINT
		mov eax,TRUE
		ret

	.elseif uMsg==WM_SYSCOMMAND
		.if wParam==0000F012h
			mov		eax,FALSE
		.else
			mov		eax,TRUE
		.endif
		ret

	.ELSEIF uMsg==WM_LBUTTONDOWN
		invoke SetCursor,hCURSOR
		invoke ReleaseCapture
		invoke SendMessage,hWin,WM_NCLBUTTONDOWN, HTCAPTION,0

	.ELSEIF uMsg==WM_MOVE
		invoke GetWindowRect,hDisplayDialog,ADDR lpRECT
		mov eax,lpRECT.left
		mov pt.x,eax
		mov eax,lpRECT.top
		mov pt.y,eax
		invoke ScreenToClient,hPrevBox,ADDR pt

		mov sInfo.cbSize,SIZEOF SCROLLINFO
		mov sInfo.fMask,SIF_POS
		mov eax,10
		sub eax,pt.x
		mov sInfo.nPos,eax
		invoke SetScrollInfo,hScroll,SB_CTL,ADDR sInfo,TRUE
		
		mov sInfo.cbSize,SIZEOF SCROLLINFO
		mov sInfo.fMask,SIF_POS
		mov eax,10
		sub eax,pt.y
		mov sInfo.nPos,eax
		invoke SetScrollInfo,vScroll,SB_CTL,ADDR sInfo,TRUE

	.ELSEIF uMsg == WM_PAINT && hResBmp != INVALID_HANDLE_VALUE
		invoke BeginPaint,hWin,ADDR ps
			mov hDC,eax
			invoke GetObject,hResBmp,SIZEOF BITMAP,ADDR bmp
			invoke CreateCompatibleDC,hDC
			mov transDC,eax
			invoke SelectObject,transDC,hResBmp
			mov OldObj,eax
			invoke GetClientRect,hWin,ADDR rct
			invoke PatBlt,hDC,0,0,rct.right,rct.bottom,BLACKNESS
			invoke BitBlt,hDC,0,0,rct.right,rct.bottom,transDC,0,0,SRCCOPY
			invoke SelectObject,transDC,OldObj
			invoke DeleteDC,transDC
		invoke EndPaint,hWin,ADDR ps

	.else
		mov		eax,FALSE
		ret
	.endif

	ret
PreviewDialogProc endp

ShowBmpPreview proc hWin:DWORD,idControl:DWORD,hModule:DWORD,pResName:DWORD

	.IF hModule == INVALID_HANDLE_VALUE
		xor eax,eax
		dec eax
		ret
	.endif

	.IF hResIcon != INVALID_HANDLE_VALUE
		invoke DestroyIcon,hResIcon
		mov hResIcon,INVALID_HANDLE_VALUE
	.endif
	.IF hResBmp != INVALID_HANDLE_VALUE
		invoke DeleteObject,hResBmp
		mov hResBmp,INVALID_HANDLE_VALUE
	.endif

	invoke LoadResourceImage,hModule,pResName,RT_BITMAP,NULL
	mov hResBmp,eax

	invoke CreateDialogParam,hInstance,600,NULL,OFFSET PreviewDialogProc,hResBmp

	ret
ShowBmpPreview endp

ShowImgPreview proc hModule:DWORD,pResName:DWORD,ResTypeNumber:DWORD
	LOCAL hFindRes				:DWORD
	LOCAL hResData				:DWORD
	LOCAL pResData				:DWORD
	LOCAL ResSize				:DWORD

	invoke FindResource,hModule,pResName,ResTypeNumber
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax
	.IF hResBmp != INVALID_HANDLE_VALUE
		invoke DeleteObject,hResBmp
		mov hResBmp,INVALID_HANDLE_VALUE
	.endif
	.IF hResIcon != INVALID_HANDLE_VALUE
		invoke DestroyIcon,hResIcon
		mov hResIcon,INVALID_HANDLE_VALUE
	.endif
	invoke BitmapFromMemory,pResData,ResSize
	mov hResBmp,eax
	
	invoke CreateDialogParam,hInstance,600,NULL,OFFSET PreviewDialogProc,hResBmp

	ret

ShowImgPreview endp

ShowDlgPreview proc hModule:DWORD,pResName:DWORD,ResTypeNumber:DWORD
	LOCAL hFindRes		:DWORD
	LOCAL hResData		:DWORD
	LOCAL pResData		:DWORD
	LOCAL ResSize		:DWORD

	invoke FindResource,hModule,pResName,ResTypeNumber
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax
	.IF pResData == NULL
		ret
	.endif

	invoke CreateMemDialog,pResData,ResSize

	invoke FreeResource,hResData
	ret
ShowDlgPreview endp

ShowIconPreview proc hModule:DWORD,pResName:DWORD,ResTypeNumber:DWORD

	.IF hModule == INVALID_HANDLE_VALUE
		xor eax,eax
		dec eax
		ret
	.endif

	.IF hResBmp != INVALID_HANDLE_VALUE
		invoke DeleteObject,hResBmp
		mov hResBmp,INVALID_HANDLE_VALUE
	.endif
	.IF hResIcon != INVALID_HANDLE_VALUE
		invoke DestroyIcon,hResIcon
		mov hResIcon,INVALID_HANDLE_VALUE
	.endif

	invoke LoadResourceIcon,hModule,pResName,ResTypeNumber
	mov hResIcon,eax

	invoke CreateDialogParam,hInstance,600,NULL,OFFSET PreviewDialogProc,hResIcon
	mov hDisplayDialog,eax

	invoke DestroyIcon,hResIcon
	mov hResIcon,INVALID_HANDLE_VALUE
	ret
ShowIconPreview endp

ShowTextPreview proc hModule:DWORD
	LOCAL NullBuffer		:DWORD
	
	mov NullBuffer,0

	invoke CreateWindowEx,NULL,OFFSET EditClass,ADDR NullBuffer,WS_THICKFRAME or ES_MULTILINE or WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_HSCROLL,10,10,495,255,hPrevBox,1000,hInstance,NULL
	mov hDisplayDialog,eax
	invoke SaveStringResource,hModule,-1
	ret
ShowTextPreview endp

ShowDefaultPreview proc hModule:DWORD,pResName:DWORD,ResTypeNumber:DWORD,pExtension:DWORD
	LOCAL hFindRes				:DWORD
	LOCAL hResData				:DWORD
	LOCAL pResData				:DWORD
	LOCAL ResSize				:DWORD
	LOCAL hDataFile				:DWORD
	LOCAL szTempFile[MAX_PATH]	:DWORD
	LOCAL cbWrite				:DWORD
	LOCAL sei					:SHELLEXECUTEINFO

	jmp @F
		TempFileName db	"\res2dlgtemp.",0
		ShellOpenVerb db "open",0
	@@:

	invoke FindResource,hModule,pResName,ResTypeNumber
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax

	invoke GetTempPath,MAX_PATH,ADDR szTempFile
	invoke lstrcat,ADDR szTempFile,OFFSET TempFileName
	invoke lstrcat,ADDR szTempFile,pExtension

	invoke CreateFile,ADDR szTempFile,GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov hDataFile,eax
	invoke WriteFile,hDataFile,pResData,ResSize,ADDR cbWrite,NULL
	invoke CloseHandle,hDataFile

	mov sei.cbSize,SIZEOF SHELLEXECUTEINFO
	mov sei.fMask,SEE_MASK_NOCLOSEPROCESS
	mov eax,hDlg
	mov sei.hwnd,eax
	mov sei.lpVerb,OFFSET ShellOpenVerb
	lea eax,szTempFile
	mov sei.lpDirectory,eax
	mov sei.lpFile,eax
	mov sei.nShow,SW_SHOW
	mov sei.lpIDList,NULL
	mov sei.lpClass,NULL
	mov sei.hkeyClass,NULL
	mov sei.dwHotKey,NULL
	mov sei.hIcon,NULL
	mov sei.hMonitor,NULL

	invoke ShellExecuteEx,ADDR sei
	.IF eax == TRUE
		invoke WaitForSingleObject,sei.hProcess,20000
		invoke TerminateProcess,sei.hProcess,NULL
		invoke CloseHandle,sei.hProcess
		invoke DeleteFile,ADDR szTempFile
	.ELSE
		invoke MessageBox,hDlg,OFFSET szNoPreview,NULL,MB_OK
	.ENDIF
	
	ret

ShowDefaultPreview endp

OFNHookSaveProc Proc hOFDlg:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

;		All this procedure does is get rid on that annoying
;		explorer window that surrounds the save as window
;		By using a hook procedure the mdi window is not drawn :)

	xor eax,eax
	ret

OFNHookSaveProc endp

ResEnumFunction proc hModule:DWORD,lpType:DWORD,lpName:DWORD,lParam:DWORD
	LOCAL rsName[64]		:BYTE
	LOCAL ResTypeName[32]	:BYTE
	LOCAL hResFind			:DWORD
	LOCAL ResSize[64]		:BYTE
	LOCAL Supported			:DWORD
	LOCAL IconIndex			:DWORD
	LOCAL UnKnown			:DWORD

	mov UnKnown,FALSE
	mov Supported,FALSE
	mov eax,lpName
	shr eax,16
	.IF ax == 0
		lea ecx,rsName
		mov BYTE PTR [ecx],"#"
		inc ecx
		invoke dwtoa,lpName,ecx
	.ELSE
		invoke lstrcpy,ADDR rsName,lpName
	.endif

	.IF lParam == RT_BITMAP
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_BITMAP
		mov IconIndex,ICO_BITMAP
		mov Supported,TRUE
	.ELSEIF lParam == RT_ACCELERATOR
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_ACCELERATOR
	.ELSEIF lParam == RT_ANICURSOR
		mov IconIndex,ICO_ANI
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_ANICURSOR
		mov Supported,TRUE
	.ELSEIF lParam == RT_ANIICON
		mov IconIndex,ICO_ANI
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_ANIICON
		mov Supported,TRUE
	.ELSEIF lParam == RT_DIALOG
		mov IconIndex,ICO_DIALOG
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_DIALOG
		mov Supported,TRUE
	.ELSEIF lParam == RT_DLGINCLUDE
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_DLGINCLUDE
	.ELSEIF lParam == RT_FONT
		mov IconIndex,ICO_FONT
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_FONT
		mov Supported,TRUE
	.ELSEIF lParam == RT_FONTDIR
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_FONTDIR
	.ELSEIF lParam == RT_GROUP_CURSOR
		mov IconIndex,ICO_CURSOR
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_GROUP_CURSOR
		mov Supported,TRUE
	.ELSEIF lParam == RT_GROUP_ICON
		mov IconIndex,ICO_ICON
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_GROUP_ICON
		mov Supported,TRUE
	.ELSEIF lParam == RT_HTML
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_HTML
	.ELSEIF lParam == RT_MANIFEST
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_MANIFEST
	.ELSEIF lParam == RT_MENU
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_MENU
	.ELSEIF lParam == RT_MESSAGETABLE
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_MESSAGETABLE
	.ELSEIF lParam == RT_PLUGPLAY
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_PLUGPLAY
	.ELSEIF lParam == RT_RCDATA
		mov IconIndex,ICO_BINARY
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_RCDATA
		mov Supported,TRUE
	.ELSEIF lParam == RT_STRING
		mov IconIndex,ICO_TEXT
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_STRING
		mov Supported,TRUE
	.ELSEIF lParam == RT_VERSION
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_VERSION
	.ELSEIF lParam == RT_VXD
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_VXD
	.ELSEIF lParam == RT_LVIMAGE
		mov IconIndex,ICO_IMAGE
		invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_IMAGE
		mov Supported,TRUE
	.ELSE
		mov UnKnown,TRUE
	.ENDIF

	invoke FindResource,hModule,ADDR rsName,lParam
	mov hResFind,eax
	invoke SizeofResource,hModule,hResFind
	mov ecx,eax
	.IF lParam == RT_GROUP_ICON
;		sub eax,6
;		xor edx,edx
;		mov ecx,14
;		div cl
;		mov ecx,eax
;		invoke dwtoa,ecx,ADDR ResSize
;		invoke lstrcat,ADDR ResSize,OFFSET szIcons
		invoke GetIconSize,hModule,lpName
		mov ecx,eax
		invoke dwtoa,ecx,ADDR ResSize
		invoke lstrcat,ADDR ResSize,OFFSET szBytes
	.ELSEIF lParam == RT_GROUP_CURSOR
		invoke GetCursorSize,hModule,lpName
		mov ecx,eax
		invoke dwtoa,ecx,ADDR ResSize
		invoke lstrcat,ADDR ResSize,OFFSET szBytes
	.ELSEIF UnKnown == FALSE
		invoke dwtoa,ecx,ADDR ResSize
		invoke lstrcat,ADDR ResSize,OFFSET szBytes
	.ELSE
		invoke dwtoa,ecx,ADDR ResSize
		invoke lstrcat,ADDR ResSize,OFFSET szBytes
		mov eax,lParam
		.IF eax > 65535
			invoke lstrcmpi,lParam,OFFSET szRT_IMAGE
			.IF eax == 0
				mov IconIndex,ICO_IMAGE
				invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_IMAGE
				mov lParam,OFFSET szRT_IMAGE
				mov Supported,TRUE
				jmp alldone
			.endif
			invoke lstrcmpi,lParam,OFFSET szRT_AVI
			.IF eax == 0
				mov IconIndex,ICO_ANI
				invoke lstrcpy,ADDR ResTypeName,OFFSET szRT_AVI
				mov lParam,OFFSET szRT_AVI
				mov Supported,TRUE
				jmp alldone
			.endif
		.endif
	.ENDIF

	alldone:
	.IF Supported == TRUE
		invoke LVAddItem,IconIndex,ADDR rsName,ADDR ResTypeName,ADDR ResSize,lParam
	.ENDIF

	xor eax,eax
	inc eax
	ret

ResEnumFunction endp

ResTypeEnumFunction proc hModule:DWORD,lpszType:DWORD,lParam:DWORD

	invoke EnumResourceNames,hLibForRes,lpszType,OFFSET ResEnumFunction,lpszType
	mov eax,TRUE
	ret

ResTypeEnumFunction endp

GetIconSize proc uses edi esi hModule:DWORD,pResName:DWORD
	LOCAL hFindRes				:DWORD
	LOCAL hResData				:DWORD
	LOCAL pResData				:DWORD
	LOCAL ResSize				:DWORD
	LOCAL iCount				:DWORD

	invoke FindResource,hModule,pResName,RT_GROUP_ICON
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax

	; Calculte the size of the file
	mov edi,pResData
	xor ecx,ecx
	mov cx,[edi].GRPICONDIR.idCount
	mov iCount,ecx
	add edi,SIZEOF GRPICONDIR
	mov eax,SIZEOF GRPICONDIR
	.REPEAT
		add eax,[edi].GRPICONDIRENTRY.dwBytesInRes
		add eax,SIZEOF GRPICONDIRENTRY
		add edi,SIZEOF GRPICONDIRENTRY
	.UNTILCXZ
	mov ecx,iCount
	shl ecx,1
	add eax,ecx

	ret
GetIconSize endp

GetCursorSize proc uses edi esi hModule:DWORD,pResName:DWORD
	LOCAL hFindRes				:DWORD
	LOCAL hResData				:DWORD
	LOCAL pResData				:DWORD
	LOCAL ResSize				:DWORD
	LOCAL iResName[16]			:BYTE

	mov al,"#"
	mov iResName,al

	invoke FindResource,hModule,pResName,RT_GROUP_CURSOR
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax
	.IF pResData == NULL
		ret
	.endif

	mov edi,pResData
	add edi,6
	lea ecx,iResName
	inc ecx
	movzx eax,[edi].CURSORDIRENTRY.nID
	invoke dwtoa,eax,ecx

	; Get a copy of the icon resource
	invoke FindResource,hModule,ADDR iResName,RT_CURSOR
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax

	mov eax,ResSize
	add eax,SIZEOF CURSORHEADER

	ret
GetCursorSize endp

GetResources proc
	LOCAL ofn						:OPENFILENAME
	LOCAL ofrFilePath[MAX_PATH]		:BYTE
	LOCAL ofrFileTitle[64]			:BYTE
	LOCAL hFile						:DWORD

	mov ofn.lStructSize,SIZEOF OPENFILENAME
	mov eax,hDlg
	mov ofn.hwndOwner,eax
	mov eax,hInstance
	mov ofn.hInstance,NULL
	mov ofn.lpstrFilter,OFFSET szExeFilterStr
	mov ofn.lpstrCustomFilter,NULL
	mov ofn.nMaxCustFilter,NULL
	mov ofn.nFilterIndex,1
	lea eax,ofrFilePath
	mov DWORD PTR [eax],0
	mov ofn.lpstrFile,eax
	mov ofn.nMaxFile,SIZEOF ofrFilePath
	lea eax,ofrFileTitle
	mov ofn.lpstrFileTitle,eax
	mov ofn.nMaxFileTitle,SIZEOF ofrFileTitle
	mov ofn.lpstrInitialDir,NULL
	mov ofn.lpstrTitle,OFFSET szOpenCaption
	mov ofn.Flags,OFN_FILEMUSTEXIST or OFN_NONETWORKBUTTON or OFN_EXPLORER or OFN_ENABLEHOOK or OFN_HIDEREADONLY
	mov ofn.lpfnHook,OFFSET OFNHookSaveProc ; Just use the save hook to get rid of the explorer
	mov ofn.lpTemplateName,NULL
	mov ofn.lpstrDefExt,OFFSET szDefExeExt
	mov ofn.lCustData,NULL

	invoke GetOpenFileName,ADDR ofn
	test eax,eax
	jnz short @F
		mov eax,-1
		jmp EndOpenExe
	@@:

	invoke CreateFile,ADDR ofrFilePath,GENERIC_READ,NULL,NULL,OPEN_ALWAYS,FILE_ATTRIBUTE_ARCHIVE,NULL
	mov hFile,eax
	.IF hFile == INVALID_HANDLE_VALUE
		invoke MessageBox,hDlg,OFFSET szNoHandle,NULL,MB_YESNO
		.IF eax == IDNO
			ret
		.ELSE
			jmp @F
		.ENDIF
	.endif
	invoke PECheckCompress,hFile
	.IF eax == -1
		invoke MessageBox,NULL,OFFSET szNoLoad,NULL,MB_OK
		jmp EndOpenExe
	.endif
@@:
	invoke SendMessage,hListView,LVM_DELETEALLITEMS,0,0

	invoke LoadLibraryEx,ADDR ofrFilePath,NULL,LOAD_LIBRARY_AS_DATAFILE
	mov hLibForRes,eax
	.IF eax != NULL
		invoke EnumResourceTypes,hLibForRes,OFFSET ResTypeEnumFunction,NULL
	.ENDIF

	EndOpenExe:

	ret

GetResources endp

SetUpListView proc uses edi
	LOCAL LVColumn		:LV_COLUMN

	invoke ImageList_Create,16,16,ILC_MASK or ILC_COLOR24,1,10
	mov hLVIml,eax

	;Dialog - 0
	invoke LoadIcon,NULL,IDI_APPLICATION
	invoke ImageList_ReplaceIcon,hLVIml,-1,eax

	mov edi,0
	.REPEAT
		mov eax,edi
		add eax,7000
		invoke LoadIcon,hInstance,eax
		push eax
		invoke ImageList_ReplaceIcon,hLVIml,-1,eax
		pop eax
		invoke DestroyIcon,eax
		inc edi
	.UNTIL edi == ICO_LAST

	invoke SendMessage,hListView,LVM_SETIMAGELIST,LVSIL_SMALL,hLVIml

	mov LVColumn.imask,LVCF_FMT or LVCF_TEXT or LVCF_WIDTH
	mov LVColumn.fmt,LVCFMT_LEFT
	mov LVColumn.lx,130
	mov LVColumn.pszText,OFFSET szColumn0
	mov LVColumn.cchTextMax,SIZEOF szColumn0
	invoke SendMessage,hListView,LVM_INSERTCOLUMN,0,ADDR LVColumn

	mov LVColumn.imask,LVCF_FMT or LVCF_TEXT or LVCF_WIDTH
	mov LVColumn.fmt,LVCFMT_LEFT
	mov LVColumn.lx,130
	mov LVColumn.pszText,OFFSET szColumn1
	mov LVColumn.cchTextMax,SIZEOF szColumn1
	invoke SendMessage,hListView,LVM_INSERTCOLUMN,1,ADDR LVColumn

	mov LVColumn.imask,LVCF_FMT or LVCF_TEXT or LVCF_WIDTH or LVCF_SUBITEM
	mov LVColumn.fmt,LVCFMT_LEFT
	mov LVColumn.lx,90
	mov LVColumn.pszText,OFFSET szColumn2
	mov LVColumn.cchTextMax,SIZEOF szColumn2
	mov LVColumn.iSubItem,1
	invoke SendMessage,hListView,LVM_INSERTCOLUMN,2,ADDR LVColumn

	invoke SendMessage,hListView,LVM_SETEXTENDEDLISTVIEWSTYLE,LVS_EX_GRIDLINES or LVS_EX_FULLROWSELECT,LVS_EX_GRIDLINES or LVS_EX_FULLROWSELECT

	ret
SetUpListView endp

LVAddItem proc Image:DWORD,Col0:DWORD,Col1:DWORD,Col2:DWORD,lParam:DWORD
	LOCAL LVItem		:LV_ITEM
	LOCAL ItemID		:DWORD

	invoke SendMessage,hListView,LVM_GETITEMCOUNT,0,0
	mov ItemID,eax

	mov LVItem.imask,LVIF_PARAM or LVIF_TEXT or LVIF_IMAGE
	mov LVItem.iSubItem,0
	mov eax,Col0
	mov LVItem.pszText,eax

	mov eax,Image
	mov LVItem.iImage,eax
	mov eax,ItemID
	mov LVItem.iItem,eax
	mov eax,lParam
	mov LVItem.lParam,eax
	invoke SendMessage,hListView,LVM_INSERTITEM,0,ADDR LVItem
	mov ItemID,eax

	mov eax,Col1
	mov LVItem.pszText,eax
	mov eax,ItemID
	mov LVItem.iItem,eax
	mov LVItem.iSubItem,1
	mov LVItem.imask,LVIF_TEXT
	invoke SendMessage,hListView,LVM_SETITEM,0,ADDR LVItem

	mov eax,Col2
	mov LVItem.pszText,eax
	mov eax,ItemID
	mov LVItem.iItem,eax
	mov LVItem.iSubItem,2
	mov LVItem.imask,LVIF_TEXT
	invoke SendMessage,hListView,LVM_SETITEM,0,ADDR LVItem

	mov eax,ItemID
	ret
LVAddItem endp

OpenFileForWrite proc pExtension:DWORD,pFileFilter:DWORD
	LOCAL ofn						:OPENFILENAME

	mov FileExists,TRUE

	mov ofn.lStructSize,SIZEOF OPENFILENAME
	mov eax,hDlg
	mov ofn.hwndOwner,eax
	mov eax,hInstance
	mov ofn.hInstance,NULL
	mov eax,pFileFilter
	mov ofn.lpstrFilter,eax
	mov ofn.lpstrCustomFilter,NULL
	mov ofn.nMaxCustFilter,NULL
	mov ofn.nFilterIndex,1
	mov eax,OFFSET ofwFilePath
	mov [eax],DWORD PTR 0
	mov ofn.lpstrFile,eax
	mov ofn.nMaxFile,SIZEOF ofwFilePath
	mov ofn.lpstrFileTitle,NULL
	mov ofn.nMaxFileTitle,0
	mov edi,lpData
	mov eax,[edi].ADDINDATA.lpProjectPath
	mov ofn.lpstrInitialDir,eax
	mov ofn.lpstrTitle,NULL
	mov ofn.Flags,OFN_NONETWORKBUTTON or OFN_HIDEREADONLY or OFN_OVERWRITEPROMPT
	mov ofn.lpfnHook,NULL
	mov ofn.lpTemplateName,NULL
	mov eax,pExtension
	mov ofn.lpstrDefExt,eax

	invoke GetSaveFileName,ADDR ofn
	test eax,eax
	jnz @F
		mov eax,INVALID_HANDLE_VALUE
		ret
	@@:
;
;	mov eax,ofn.Flags
;	and eax,OFN_EXTENSIONDIFFERENT
;	test eax,eax
;	jz @F
;		mov eax,INVALID_HANDLE_VALUE
;		ret
;	@@:

	invoke exist,ADDR ofwFilePath
	.IF eax == 0
		invoke CreateFile,\
		ADDR ofwFilePath,\
		GENERIC_WRITE,\
		NULL,\
		NULL,\
		OPEN_ALWAYS,\
		FILE_ATTRIBUTE_ARCHIVE,\
		NULL
		
		mov FileExists,FALSE
	.ELSE
		invoke CreateFile,\
		ADDR ofwFilePath,\
		GENERIC_WRITE,\
		NULL,\
		NULL,\
		OPEN_ALWAYS or TRUNCATE_EXISTING,\
		FILE_ATTRIBUTE_ARCHIVE,\
		NULL
		
		mov FileExists,TRUE
	.ENDIF

	ret
OpenFileForWrite endp

FindClassIndex proc pszClassName:DWORD
	LOCAL	buffer[32]		:BYTE

	mov ClassIndex,0
	mov ecx,1
	.WHILE ecx < 32
		push ecx
		add ecx,300
		invoke LoadString,hInstance,ecx,ADDR buffer,32
		invoke lstrcmpi,pszClassName,ADDR buffer
		.IF eax == 0
			pop ecx
			mov ClassIndex,ecx
			.BREAK
		.endif
		pop ecx
		inc ecx
	.endw

	.IF ClassIndex == 3
		mov eax,DlgXItemTemplate.style
		and eax,0000000Fh
		.IF eax == 2 || eax == 3
			mov ClassIndex,5
		.ELSEIF eax == 4 || eax == 5 || eax == 6 || eax == 9
			mov ClassIndex,6
		.ELSEIF eax == 7
			mov ClassIndex,3
		.ELSEIF eax == 8
			mov ClassIndex,24
		.ELSE
			mov ClassIndex,4
		.ENDIF

	.ELSEIF ClassIndex == 2
		mov eax,DlgXItemTemplate.style
		and eax,0000000Fh
		.IF eax == SS_BITMAP
			mov ClassIndex,17
			jmp @F
		.ELSEIF eax == SS_ICON
			mov ClassIndex,17
			jmp @F
		.ELSEIF eax == SS_BLACKFRAME
			mov ClassIndex,25
			jmp @F
		.ELSEIF eax == SS_GRAYFRAME
			mov ClassIndex,25
			jmp @F
		.ELSEIF eax == SS_WHITEFRAME
			mov ClassIndex,25
			jmp @F
		.ELSEIF eax == SS_BLACKRECT
			mov ClassIndex,25
			jmp @F
		.ELSEIF eax == SS_GRAYRECT
			mov ClassIndex,25
			jmp @F
		.ELSEIF eax == SS_WHITERECT
			mov ClassIndex,25
			jmp @F
		.ELSEIF eax == SS_OWNERDRAW
			mov ClassIndex,25
			jmp @F
		.endif

		; HANDLE THE ETCHED STATICS SEPERATELY FOR SOME REASON
		mov eax,DlgXItemTemplate.style
		and eax,SS_ETCHEDFRAME
		.IF eax == SS_ETCHEDFRAME
			mov ClassIndex,25
			jmp @F
		.endif
		mov eax,DlgXItemTemplate.style
		and eax,SS_ETCHEDHORZ
		.IF eax == SS_ETCHEDHORZ
			mov ClassIndex,25
			jmp @F
		.endif
		mov eax,DlgXItemTemplate.style
		and eax,SS_ETCHEDVERT
		.IF eax == SS_ETCHEDVERT
			mov ClassIndex,25
			jmp @F
		.endif
		; Don't know what the hell this one is
		mov eax,DlgXItemTemplate.style
		and eax,11
		.IF eax == 11
			mov ClassIndex,25
			jmp @F
		.endif

	.ELSEIF ClassIndex == 9
		mov eax,DlgXItemTemplate.style
		and eax,SBS_VERT
		.IF eax == SBS_VERT
			mov ClassIndex,10
		.endif

	.ELSEIF ClassIndex == 29
		mov eax,DlgXItemTemplate.style
		and eax,CCS_VERT 
		.IF eax != CCS_VERT
			mov ClassIndex,30
		.endif

	.endif

	@@:

	mov eax,ClassIndex
	ret
FindClassIndex endp

ReadDlgNHeader proc StartReadAt:DWORD
	LOCAL dlgOrd		:DWORD
	LOCAL Tempbuffer[8]	:BYTE
	; THIS PROC IS A PATCH TO DECOMPILE THE OLDER DIALOG FORMAT INTO A DIALOGEX FORMAT

	lea eax,DlgNTemplate
	mov edi,StartReadAt
	invoke MemCopy,StartReadAt,eax,18
	add edi,18

	mov DlgXTemplate.dlgVer,0
	mov DlgXTemplate.signature,0
	mov DlgXTemplate.helpID,0
	mov eax,DlgNTemplate.style
	mov DlgXTemplate.style,eax
	mov eax,DlgNTemplate.dwExtendedStyle
	mov DlgXTemplate.exStyle,eax

	mov ax,DlgNTemplate.cdit
	mov DlgXTemplate.cDlgItems,ax
	mov ax,DlgNTemplate.x
	mov DlgXTemplate.x,ax
	mov ax,DlgNTemplate.y
	mov DlgXTemplate.y,ax
	mov ax,DlgNTemplate.lx
	mov DlgXTemplate.lx,ax
	mov ax,DlgNTemplate.ly
	mov DlgXTemplate.ly,ax

	mov DlgXTemplate.pmenu,OFFSET szmenu
	mov DlgXTemplate.pwindowClass,OFFSET szwindowClass
	mov DlgXTemplate.ptitle,OFFSET sztitle

	mov ax,[edi]
	.IF ax == 0
		mov DlgXTemplate.pmenu,NULL
		mov DlgXTemplate.pmenuord,NULL
		add edi,2
	.ELSEIF ax== 0FFFFh
		add edi,2
		movzx eax,ax
		mov DlgXTemplate.pmenuord,eax
		add edi,2
	.ELSE ; ax != 0FFFFh && ax != 0
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR szmenu,MaxMenu,NULL,NULL
		pop edi
		shl eax,1
		add edi,eax
		mov DlgXTemplate.pmenuord,NULL
	.ENDIF

	; Word align the pointer
	add edi,1
	and edi,-2

	mov ax,[edi]
	.IF ax == 0
		mov DlgXTemplate.pwindowClassord,NULL
		add edi,2
	.ELSEIF ax== 0FFFFh
		add edi,2
		movzx eax,ax
		mov DlgXTemplate.pwindowClassord,eax
		add edi,2
	.ELSE ; ax != 0FFFFh && ax != 0
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR szwindowClass,MaxClass,NULL,NULL
		pop edi
		shl eax,1
		add edi,eax
		mov DlgXTemplate.pwindowClassord,NULL
	.ENDIF

	; Word align the pointer
	add edi,1
	and edi,-2

	mov ax,[edi]
	.IF ax == 0
		; no data
		mov DlgXTemplate.ptitle,NULL
		add edi,2
	.ELSEIF ax== 0FFFFh
		; ordinal
		add edi,2
		movzx eax,ax
		mov dlgOrd,eax
		invoke dw2a,dlgOrd,ADDR Tempbuffer
		lea edx,sztitle
		mov DlgXTemplate.ptitle,edx
		mov al,"#"
		mov [edx],al
		push edi
		invoke szCatStr,ADDR sztitle,ADDR Tempbuffer
		pop edi
		add edi,2
	.ELSE ; ax != 0FFFFh && ax != 0
		; text
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR sztitle,MaxCap,NULL,NULL
		pop edi
		shl eax,1
		add edi,eax
	.ENDIF

	; Word align the pointer
	add edi,1
	and edi,-2

	; Check for the DS_SETFONT flag
	mov eax,DlgNTemplate.style
	test eax,DS_SETFONT
	jz @F
		; Read the Font information
		mov	ax,[edi]
		mov DlgXTemplate.pointsize,ax
		mov DlgXTemplate.pfont,OFFSET szFont
		add edi,2
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR szFont,MaxFont,NULL,NULL
		shl eax,1
		pop edi
		; Add the length of the string
		add edi,eax
	@@:

	; DWORD align the pointer for the first item
	add edi,3
	and edi,-4

	mov NextItemPos,edi
	mov eax,edi
	ret
ReadDlgNHeader endp

ReadDlgXHeader proc StartReadAt:DWORD
	LOCAL dlgOrd		:DWORD
	LOCAL Tempbuffer[8]	:BYTE

	; Get the template signature to verify the dialog type
	mov edi,StartReadAt
	movzx eax,WORD PTR [edi+2]
	mov DlgXTemplate.signature,ax
	.IF eax != 0FFFFh ; If this isn't a dialogex type
		invoke ReadDlgNHeader,StartReadAt
		mov eax,0
		ret
	.endif

	lea eax,DlgXTemplate
	mov edi,StartReadAt
	invoke MemCopy,StartReadAt,eax,26 ; copy the first 26 bytes of info directly to the struct

	mov DlgXTemplate.pmenu,OFFSET szmenu
	mov DlgXTemplate.pwindowClass,OFFSET szwindowClass
	mov DlgXTemplate.ptitle,OFFSET sztitle
	add edi,26

	; Decode unicode strings if necessary
	mov ax,[edi]
	.IF ax == 0
		mov DlgXTemplate.pmenu,NULL
		mov DlgXTemplate.pmenuord,NULL
		add edi,2
	.ELSEIF ax== 0FFFFh
		add edi,2
		movzx eax,ax
		mov DlgXTemplate.pmenuord,eax
		add edi,2
	.ELSE ; ax != 0FFFFh && ax != 0
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR szmenu,MaxMenu,NULL,NULL
		pop edi
		shl eax,1
		add edi,eax
		mov DlgXTemplate.pmenuord,NULL
	.ENDIF

;	add edi,1
;	and edi,-2

	mov ax,[edi]
	.IF ax == 0
		mov DlgXTemplate.pwindowClass,NULL
		mov DlgXTemplate.pwindowClassord,NULL
		add edi,2
	.ELSEIF ax== 0FFFFh
		add edi,2
		movzx eax,ax
		mov DlgXTemplate.pwindowClassord,eax
		add edi,2
	.ELSE ; ax != 0FFFFh && ax != 0
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR szwindowClass,MaxClass,NULL,NULL
		pop edi
		shl eax,1
		add edi,eax
		mov DlgXTemplate.pwindowClassord,NULL
	.ENDIF

	add edi,1
	and edi,-2

	mov ax,[edi]
	.IF ax == 0
		; no data
		mov DlgXTemplate.ptitle,NULL
		add edi,2
	.ELSEIF ax== 0FFFFh
		; ordinal
		add edi,2
		movzx eax,ax
		mov dlgOrd,eax
		invoke dw2a,dlgOrd,ADDR Tempbuffer
		lea edx,sztitle
		mov DlgXTemplate.ptitle,edx
		mov al,"#"
		mov [edx],al
		push edi
		invoke szCatStr,ADDR sztitle,ADDR Tempbuffer
		pop edi
		add edi,2
	.ELSE ; ax != 0FFFFh && ax != 0
		; text
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR sztitle,MaxCap,NULL,NULL
		pop edi
		shl eax,1
		add edi,eax
	.ENDIF

	add edi,1
	and edi,-2

	; Copy the font properties into the structure
	lea eax,DlgXTemplate.pointsize
	invoke MemCopy,edi,eax,6
	add edi,6

	; Get the font name and copy it to the buffer & set the pointer
	mov DlgXTemplate.pfont,OFFSET szFont
	push edi
	invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR szFont,MaxFont,NULL,NULL
	shl eax,1
	pop edi
	; Add the length of the string
	add edi,eax
	; DWORD align the result
	add edi,3
	and edi,-4
	mov NextItemPos,edi
	mov eax,1
	ret
ReadDlgXHeader endp

ReadDlgNItem proc uses ecx edx edi StartReadAt:DWORD
	LOCAL dlgOrd			:DWORD
	LOCAL Tempbuffer[16]	:BYTE
	; THIS PROC IS A PATCH TO DECOMPILE THE OLDER DIALOG FORMAT INTO A DIALOGITEMEX FORMAT

	invoke memfill,ADDR ResItemClass,64,NULL
	invoke memfill,ADDR ResItemTitle,MaxCap,NULL

	lea eax,DlgNItemTemplate
	mov edi,StartReadAt

	invoke MemCopy,edi,eax,18
	add edi,18

	mov eax,DlgNItemTemplate.style
	mov DlgXItemTemplate.style,eax	
	mov eax,DlgNItemTemplate.dwExtendedStyle
	mov DlgXItemTemplate.exStyle,eax
	mov ax,DlgNItemTemplate.x
	mov DlgXItemTemplate.x,ax
	mov ax,DlgNItemTemplate.y
	mov DlgXItemTemplate.y,ax
	mov ax,DlgNItemTemplate.lx
	mov DlgXItemTemplate.lx,ax
	mov ax,DlgNItemTemplate.cy
	mov DlgXItemTemplate.ly,ax
	mov ax,DlgNItemTemplate.id
	mov DlgXItemTemplate.id,ax

	mov DlgXItemTemplate.ptitle,OFFSET ResItemTitle
	mov DlgXItemTemplate.pwindowClass,OFFSET ResItemClass

	mov ax,[edi]
	.IF ax== 0FFFFh
		add edi,2
		mov ax,[edi]
		movzx eax,ax
		mov DlgXItemTemplate.pwindowClassOrd,eax
		.IF eax == dlgButton
			invoke lstrcpy,ADDR ResItemClass,ADDR ButtonClass
		.ELSEIF eax == dlgEdit
			invoke lstrcpy,ADDR ResItemClass,ADDR EditClass
		.ELSEIF eax == dlgStatic
			invoke lstrcpy,ADDR ResItemClass,ADDR StaticClass
		.ELSEIF eax == dlgListbox
			invoke lstrcpy,ADDR ResItemClass,ADDR ListBoxClass
		.ELSEIF eax == dlgScrollbar
			invoke lstrcpy,ADDR ResItemClass,ADDR ScrollBarClass
		.ELSEIF eax == dlgCombobox
			invoke lstrcpy,ADDR ResItemClass,ADDR ComboBoxClass
		.ENDIF
		add edi,2
	.ELSE
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR ResItemClass,MaxClass,NULL,NULL
		pop edi
		shl eax,1
		add edi,eax
	.ENDIF

	mov ax,[edi]
	.IF ax == 0
		mov DlgXItemTemplate.ptitle,NULL
		add edi,4 ; jump ahead past the null terminator
	.ELSEIF ax== 0FFFFh
		invoke memfill,ADDR ResItemTitle,64,NULL
		add edi,2
		mov ax,[edi]
		movzx eax,ax
		mov dlgOrd,eax
		invoke dw2a,dlgOrd,ADDR Tempbuffer
		lea edx,ResItemTitle
		mov DlgXItemTemplate.ptitle,edx
		mov al,"#"
		mov [edx],al
		invoke szCatStr,ADDR ResItemTitle,ADDR Tempbuffer
		add edi,2
	.ELSE ; ax != 0FFFFh && ax != 0
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR ResItemTitle,MaxCap,NULL,NULL
		add eax,1
		and eax,-2
		pop edi
		shl eax,1
		add edi,eax
	.ENDIF

;	add edi,3
;	and edi,-4

	mov ax,[edi]
	mov DlgXItemTemplate.extracount,ax
	movzx eax,ax
;	add edi,eax	; Jump past any creation data (it is not imported)
	add edi,2
	mov NextItemPos,edi

	; ###########################################
	ret
ReadDlgNItem endp

ReadDlgXItem proc uses ecx edx edi StartReadAt:DWORD
	LOCAL dlgOrd			:DWORD
	LOCAL Tempbuffer[16]	:BYTE

	movzx eax,DlgXTemplate.signature
	.IF eax != 0FFFFh
		invoke ReadDlgNItem,StartReadAt
		ret
	.endif

	invoke memfill,ADDR ResItemClass,64,NULL
	invoke memfill,ADDR ResItemTitle,MaxCap,NULL

	lea eax,DlgXItemTemplate
	mov edi,StartReadAt
	invoke MemCopy,edi,eax,24
	add edi,24

	mov DlgXItemTemplate.ptitle,OFFSET ResItemTitle
	mov DlgXItemTemplate.pwindowClass,OFFSET ResItemClass

	mov ax,[edi]
	.IF ax == 0
		mov DlgXItemTemplate.pwindowClass,NULL
		add edi,2 ;##################
	.ELSEIF ax== 0FFFFh
		add edi,2
		mov ax,[edi]
		movzx eax,ax
		mov DlgXItemTemplate.pwindowClassOrd,eax
		.IF eax == dlgButton
			invoke lstrcpy,ADDR ResItemClass,ADDR ButtonClass
		.ELSEIF eax == dlgEdit
			invoke lstrcpy,ADDR ResItemClass,ADDR EditClass
		.ELSEIF eax == dlgStatic
			invoke lstrcpy,ADDR ResItemClass,ADDR StaticClass
		.ELSEIF eax == dlgListbox
			invoke lstrcpy,ADDR ResItemClass,ADDR ListBoxClass
		.ELSEIF eax == dlgScrollbar
			invoke lstrcpy,ADDR ResItemClass,ADDR ScrollBarClass
		.ELSEIF eax == dlgCombobox
			invoke lstrcpy,ADDR ResItemClass,ADDR ComboBoxClass
		.ENDIF
		add edi,2
	.ELSE ; ax != 0FFFFh && ax != 0
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR ResItemClass,MaxClass,NULL,NULL
		push eax
		pop eax
		pop edi
		shl eax,1
		add edi,eax
	.ENDIF

	mov ax,[edi]
	.IF ax == 0
		mov DlgXItemTemplate.ptitle,NULL
		add edi,2 ; ##############################
	.ELSEIF ax== 0FFFFh
		invoke memfill,ADDR ResItemTitle,64,NULL
		add edi,2
		mov ax,[edi]
		movzx eax,ax
		mov dlgOrd,eax
		invoke dw2a,dlgOrd,ADDR Tempbuffer
		lea edx,ResItemTitle
		mov DlgXItemTemplate.ptitle,edx
		mov al,"#"
		mov [edx],al
		invoke szCatStr,ADDR ResItemTitle,ADDR Tempbuffer
		add edi,2
	.ELSE ; ax != 0FFFFh && ax != 0
		push edi
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,-1,ADDR ResItemTitle,MaxCap,NULL,NULL
		pop edi
		shl eax,1
		add edi,eax
	.ENDIF

	mov ax,[edi]
	mov DlgXItemTemplate.extracount,ax
	mov eax,edi
	add eax,2
	add eax,3
	and eax,-4
	mov NextItemPos,eax
	ret
ReadDlgXItem endp

SnapToGrid proc

	mov		ecx,GridX
	mov		eax,DlgItem.x
	xor		edx,edx
	div		ecx
	mul		ecx
	mov		DlgItem.x,eax
	mov		eax,DlgItem.ccx
	xor		edx,edx
	div		ecx
	mul		ecx
	inc		eax
	mov		DlgItem.ccx,eax

	mov		ecx,GridY
	mov		eax,DlgItem.y
	xor		edx,edx
	div		ecx
	mul		ecx
	mov		DlgItem.y,eax
	mov		eax,DlgItem.ccy
	xor		edx,edx
	div		ecx
	mul		ecx
	inc		eax
	mov		DlgItem.ccy,eax
	ret

SnapToGrid endp

SaveBitmap Proc hBitmap:DWORD,hFile:DWORD,cClrBits:DWORD
	LOCAL cbWrite				:DWORD
	LOCAL bmp					:BITMAP
	LOCAL dwNumColors			:DWORD
	LOCAL hDC					:DWORD
	LOCAL hDC_DIB				:DWORD
	LOCAL ImageWidth			:DWORD
	LOCAL pBMI					:DWORD
	LOCAL RGBQuadSize			:DWORD
	LOCAL DataSize				:DWORD
	LOCAL pBFH					:DWORD
	LOCAL pData					:DWORD
	LOCAL pRGBQuad				:DWORD
	LOCAL imgX					:DWORD
	LOCAL imgY					:DWORD

	invoke GetObject,hBitmap,SIZEOF BITMAP,ADDR bmp
	mov eax,bmp.bmWidth
	mov ImageWidth,eax
	mov eax,bmp.bmHeight
	mov imgY,eax

	; Calculate size of RGBQUAD array
	mov ecx,cClrBits
	mov eax,1
	shl eax,cl
	mov dwNumColors,eax
	mov edx,SIZEOF RGBQUAD
	imul edx
	mov RGBQuadSize,eax

;	Calculate Data size
	mov eax,ImageWidth
	imul cClrBits
	add eax,31
	and eax,-31
	shr eax,3
	imul imgX
	mov DataSize,eax

	; Create a memory buffer
	.IF cClrBits == 24 ; There is no RGBQUAD array for 24 bit
		mov dwNumColors,0
		mov RGBQuadSize,0
		mov eax,0
	.ENDIF
	add eax,SIZEOF BITMAPINFOHEADER
	add eax,SIZEOF BITMAPFILEHEADER
	add eax,DataSize
	invoke GlobalAlloc,GMEM_FIXED,eax

	mov pBFH,eax
	add eax,SIZEOF BITMAPFILEHEADER
	mov pBMI,eax
	add eax,SIZEOF BITMAPINFOHEADER
	mov pRGBQuad,eax
	add eax,RGBQuadSize
	mov pData,eax

	invoke GetDC,hDlg
	mov hDC,eax
	invoke CreateCompatibleDC,hDC
	mov hDC_DIB,eax
	invoke ReleaseDC,hDlg,hDC

	mov edi,pBMI
	mov [edi].BITMAPINFO.bmiHeader.biXPelsPerMeter,0
	mov [edi].BITMAPINFO.bmiHeader.biYPelsPerMeter,0
	mov eax,dwNumColors
	mov [edi].BITMAPINFO.bmiHeader.biClrUsed,eax
	mov [edi].BITMAPINFO.bmiHeader.biClrImportant,0

	mov [edi].BITMAPINFO.bmiHeader.biSize,SIZEOF BITMAPINFOHEADER
	mov eax,bmp.bmWidth
	mov [edi].BITMAPINFO.bmiHeader.biWidth,eax
	mov eax,bmp.bmHeight
	mov [edi].BITMAPINFO.bmiHeader.biHeight,eax
	mov [edi].BITMAPINFO.bmiHeader.biPlanes,1
	mov [edi].BITMAPINFO.bmiHeader.biCompression,BI_RGB
	mov eax,cClrBits
	mov [edi].BITMAPINFO.bmiHeader.biBitCount,ax
	mov eax,DataSize
	mov [edi].BITMAPINFO.bmiHeader.biSizeImage,eax

	invoke GetDIBits,hDC_DIB,hBitmap,0,imgY,pData,pBMI,DIB_RGB_COLORS

	mov esi,pBFH
	mov [esi].BITMAPFILEHEADER.bfType,"MB"
	mov eax,RGBQuadSize
	add eax,DataSize
	add eax,SIZEOF BITMAPINFOHEADER + SIZEOF BITMAPFILEHEADER
	mov [esi].BITMAPFILEHEADER.bfSize,eax
	mov [esi].BITMAPFILEHEADER.bfReserved1,0
	mov [esi].BITMAPFILEHEADER.bfReserved2,0
	mov eax,RGBQuadSize
	add eax,sizeof BITMAPFILEHEADER
	add eax,sizeof BITMAPINFOHEADER	
	mov [esi].BITMAPFILEHEADER.bfOffBits,eax

	mov ecx,SIZEOF BITMAPFILEHEADER
	add ecx,sizeof BITMAPINFOHEADER
	add ecx,DataSize
	add ecx,RGBQuadSize
	invoke WriteFile,hFile,pBFH,ecx,ADDR cbWrite,NULL

	invoke DeleteDC,hDC_DIB
	invoke GlobalFree,pBFH
	invoke DeleteObject,hBitmap

	ret
SaveBitmap endp

CalculateBaseUnits proc
	LOCAL	hDC			:HANDLE
	LOCAL	hDlgDC		:HANDLE
	LOCAL	lf			:LOGFONT
	LOCAL	tm			:TEXTMETRIC
	LOCAL	hFont		:HANDLE
	LOCAL	OldObject	:HANDLE

	mov eax,DlgXTemplate.pfont
	.IF !eax
		invoke GetDialogBaseUnits
		movzx edx,ax
		shl edx,9
		mov DBUX,edx
		shr eax,16
		movzx eax,ax
		shl eax,9
		mov DBUY,eax

		lea eax,szFont
		mov DlgXTemplate.pfont,eax
		invoke lstrcpy,eax,ADDR szDefFont
		mov DlgXTemplate.pointsize,10
		jmp @F
	.endif

	invoke GetDC,hDlg
	mov hDlgDC,eax
	invoke CreateCompatibleDC,hDlgDC
	mov hDC,eax
	invoke ReleaseDC,hDlg,hDC

	invoke GetDeviceCaps,hDC,LOGPIXELSY
	mul DlgXTemplate.pointsize
	mov ecx,72
	mov edx,0
	div ecx
	neg eax

	mov lf.lfHeight,eax
	mov lf.lfWidth,0
	mov lf.lfEscapement,0
	mov lf.lfOrientation,0
	mov lf.lfWeight,700	; Always Bold
	mov lf.lfItalic,FALSE
	mov lf.lfUnderline,FALSE
	mov lf.lfStrikeOut,FALSE
	mov lf.lfCharSet,DEFAULT_CHARSET
	mov lf.lfOutPrecision,OUT_DEFAULT_PRECIS
	mov lf.lfClipPrecision,CLIP_DEFAULT_PRECIS
	mov lf.lfQuality,DEFAULT_QUALITY

	invoke lstrcpy,ADDR lf.lfFaceName,DlgXTemplate.pfont
	invoke CreateFontIndirect,ADDR lf
	mov hFont,eax

	invoke SelectObject,hDC,hFont
	mov OldObject,eax

	invoke GetTextMetrics,hDC,ADDR tm
	mov eax,tm.tmAveCharWidth
	shl eax,9
	mov DBUX,eax
	mov eax,tm.tmHeight
	shl eax,9
	mov DBUY,eax

	invoke SelectObject,hDC,OldObject
	invoke DeleteDC,hDC
	invoke DeleteObject,hFont

	@@:

	mov eax,SystemMetric.CXSIZEFRAME
	shl eax,1
	sub eax,1
	mov ADDTOX,eax

	mov eax,SystemMetric.CYSIZEFRAME
	shl eax,1
	sub eax,1
	mov DLGFRAME,eax
	add eax,SystemMetric.CYCAPTION
	mov ADDTOY,eax

	mov eax,SystemMetric.CXEDGE
	mov DLGFRAME,eax

	ret
CalculateBaseUnits endp

DlgCreate proc
	LOCAL BYTESWRITTEN		:DWORD

	mov	DlgHdr.ver,101
	mov	DlgHdr.changed,FALSE
	invoke lstrcpy,ADDR DlgHdr.class,DlgXTemplate.pwindowClass
	invoke memfill,ADDR DlgHdr.menuid,32,0
	invoke lstrcpy,ADDR DlgHdr.font,DlgXTemplate.pfont
	mov	DlgHdr.fontsize,8
	mov	DlgHdr.fontht,-10
	mov	DlgHdr.undo,NULL
	movzx eax,DlgXItemTemplate.id
	.IF eax != 0
		; Add 1 to the Control ID to set the StartID
		inc eax
	.ELSE
		; Default the StartID to 1001 if no Control ID is specified
		mov eax,1001
	.ENDIF
	mov	DlgHdr.ctlid,eax
	mov	DlgHdr.hmnu,NULL
	mov	DlgHdr.htlb,NULL
	mov	DlgHdr.hstb,NULL
	mov	DlgHdr.locked,FALSE
	mov	DlgHdr.hfont,NULL
	mov	DlgHdr.spare1,NULL

	mov DlgItem.hwnd,TRUE
	mov DlgItem.partype,1
	mov DlgItem.oldproc,NULL
	mov DlgItem.hpar,NULL
	mov DlgItem.hcld,NULL
	mov eax,DlgXTemplate.style
	mov DlgItem.style,eax
	mov eax,DlgXTemplate.exStyle
	mov DlgItem.exstyle,eax

	.IF DlgXTemplate.exStyle & WS_EX_TOOLWINDOW
		; Small caption is used
		mov eax,SystemMetric.CYCAPTION
		sub ADDTOY,eax
		mov eax,SystemMetric.CYSMCAPTION
		add ADDTOY,eax
	.ELSEIF !(DlgXTemplate.style & WS_CAPTION)
		; No Caption is used
		mov eax,SystemMetric.CYCAPTION
		sub ADDTOY,eax
	.ENDIF

	.IF !(DlgXTemplate.style & WS_CAPTION)
		mov ADDTOX,0
	.ENDIF

	movzx eax,DlgXTemplate.x
	invoke MulDiv,eax,DBUX,4
	shr eax,9
	mov DlgItem.x,eax

	movzx eax,DlgXTemplate.y
	invoke MulDiv,eax,DBUY,8
	shr eax,9
	mov DlgItem.y,eax

	movzx eax,DlgXTemplate.lx
	invoke MulDiv,eax,DBUX,4
	shr eax,9
	add eax,ADDTOX
	mov DlgItem.ccx,eax

	movzx eax,DlgXTemplate.ly
	invoke MulDiv,eax,DBUY,8
	shr eax,9
	add eax,ADDTOY
	mov DlgItem.ccy,eax

	invoke lstrcpy,ADDR DlgItem.caption,DlgXTemplate.ptitle
	mov DlgItem.ntype,0
	mov DlgItem.ntypeid,NULL
	mov DlgItem.tab,0

	.IF DlgID != -1
		mov eax,DlgID
		mov DlgItem.id,eax
		invoke lstrcpy,ADDR DlgItem.idname,ADDR DlgName
	.ELSE
		invoke lstrcpy,ADDR DlgItem.idname,ADDR ResName
		mov DlgItem.id,0
	.ENDIF

	mov DlgItem.undo,NULL
	mov DlgItem.himg,NULL

	invoke SnapToGrid
	invoke WriteFile,hDlgFile,ADDR DlgHdr,SIZEOF DLGHEAD,ADDR BYTESWRITTEN,NULL
	invoke WriteFile,hDlgFile,ADDR DlgItem,SIZEOF DIALOG,ADDR BYTESWRITTEN,NULL
	ret
DlgCreate endp

DlgAddControl proc uses ecx edx edi TabIndex:DWORD
	LOCAL BYTESWRITTEN		:DWORD

	invoke FindClassIndex,DlgXItemTemplate.pwindowClass
	.IF eax == 0 || eax > 31
		ret
	.ELSE
		mov DlgItem.ntype,eax
	.ENDIF

	mov DlgItem.hwnd,TRUE
	mov DlgItem.partype,0
	mov DlgItem.oldproc,NULL
	mov DlgItem.hpar,NULL
	mov DlgItem.hcld,NULL

	mov eax,DlgXItemTemplate.style
	mov DlgItem.style,eax
	mov eax,DlgXItemTemplate.exStyle
	mov DlgItem.exstyle,eax

	movzx eax,DlgXItemTemplate.x
	invoke MulDiv,eax,DBUX,4
	shr eax,9
	mov DlgItem.x,eax

	movzx eax,DlgXItemTemplate.y
	invoke MulDiv,eax,DBUY,8
	shr eax,9
	add eax,DLGFRAME
	mov DlgItem.y,eax

	movzx eax,DlgXItemTemplate.lx
	invoke MulDiv,eax,DBUX,4
	shr eax,9
	add eax,DLGFRAME
	mov DlgItem.ccx,eax

	movzx eax,DlgXItemTemplate.ly
	invoke MulDiv,eax,DBUY,8
	shr eax,9
	add eax,DLGFRAME
	mov DlgItem.ccy,eax

	invoke lstrcpy,ADDR DlgItem.caption,DlgXItemTemplate.ptitle
	mov DlgItem.ntypeid,NULL
	mov eax,TabIndex
	mov DlgItem.tab,eax

	movzx eax,DlgXItemTemplate.id
	mov DlgItem.id,eax

	invoke memfill,ADDR DlgItem.idname,32,0
	mov DlgItem.undo,NULL
	mov DlgItem.himg,NULL

	invoke SnapToGrid
	invoke WriteFile,hDlgFile,ADDR DlgItem,SIZEOF DIALOG,ADDR BYTESWRITTEN,NULL
	invoke memfill,ADDR DlgItem.caption,MaxCap,0
	ret
DlgAddControl endp

BuildDlgFile proc StartReadAt:DWORD
	invoke memfill,ADDR DlgXTemplate,SIZEOF DLGTEMPLATEEX,0
	invoke memfill,ADDR DlgXItemTemplate,SIZEOF DLGITEMTEMPLATEEX,0

	invoke ReadDlgXHeader,StartReadAt
	invoke CalculateBaseUnits
	invoke DlgCreate

	.IF hDlgFile != INVALID_HANDLE_VALUE
		mov ecx,0
		movzx edx,DlgXTemplate.cDlgItems
		.WHILE ecx <= edx
			push edx
			push ecx
			invoke memfill,ADDR DlgXItemTemplate,SIZEOF DLGITEMTEMPLATEEX,0
			pop ecx
			pop edx
			invoke ReadDlgXItem,NextItemPos
			invoke DlgAddControl,ecx
			inc ecx
		.ENDW
	.ENDIF
	ret
BuildDlgFile endp

GetSystemSizes proc uses edi

	invoke GetSystemMetrics,SM_CXEDGE
	mov SystemMetric.CXEDGE,eax
	invoke GetSystemMetrics,SM_CYEDGE
	mov SystemMetric.CYEDGE,eax
	invoke GetSystemMetrics,SM_CXSIZEFRAME
	mov SystemMetric.CXSIZEFRAME,eax
	invoke GetSystemMetrics,SM_CYSIZEFRAME
	mov SystemMetric.CYSIZEFRAME,eax
	invoke GetSystemMetrics,SM_CYCAPTION
	mov SystemMetric.CYCAPTION,eax
	invoke GetSystemMetrics,SM_CYSMCAPTION
	mov SystemMetric.CYSMCAPTION,eax

	;get the grid sizes
;	mov edi,lpData
;	mov edi,[edi].ADDINDATA.lpIniAsmFile
;	invoke GetPrivateProfileInt,ADDR szGridAppName,ADDR szGRIDXKEY,1,edi
;	mov GridX,eax
;
;	mov edi,lpData
;	mov edi,[edi].ADDINDATA.lpIniAsmFile
;	invoke GetPrivateProfileInt,ADDR szGridAppName,ADDR szGRIDYKEY,1,edi
;	mov GridY,eax

	ret
GetSystemSizes endp

DummyDlgProc proc uses ebx esi edi hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL	lpRECT			:RECT
	LOCAL	sInfo			:SCROLLINFO
	LOCAL	pt				:POINT

	.IF uMsg == WM_INITDIALOG
		mov eax,hWnd
		mov hDisplayDialog,eax
		invoke GetWindowLong,hWnd,GWL_STYLE
		or eax,WS_CHILD
		invoke SetWindowLong,hWnd,GWL_STYLE,eax
		invoke SetParent,hWnd,hPrevBox
		invoke EnumChildWindows,hWnd,ADDR EnumChildProc,NULL
		invoke ShowWindow,hWnd,SW_SHOWNORMAL
		invoke SetWindowPos,hWnd,NULL,10,10,0,0,SWP_NOSIZE or SWP_NOZORDER
		;Draw active caption
		invoke SendMessage,hWnd,WM_NCACTIVATE,1,0

		invoke GetWindowRect,hWnd,ADDR lpRECT
		mov sInfo.fMask,SIF_RANGE
		mov sInfo.cbSize,SIZEOF SCROLLINFO
		mov sInfo.nMin,0
		mov eax,lpRECT.right
		sub eax,lpRECT.left
		add eax,20
		mov sInfo.nMax,eax
		invoke SetScrollInfo,hScroll,SB_CTL,ADDR sInfo,TRUE
		mov eax,lpRECT.bottom
		sub eax,lpRECT.top
		add eax,20
		mov sInfo.nMax,eax
		invoke SetScrollInfo,vScroll,SB_CTL,ADDR sInfo,TRUE
		mov eax,lParam
		mov iCaption,eax

	.ELSEIF uMsg == WM_CLOSE
		mov hDisplayDialog,INVALID_HANDLE_VALUE
		invoke EndDialog,hWnd,0

	.elseif uMsg==WM_SYSCOMMAND
		.if wParam==0000F012h
			mov		eax,FALSE
		.else
			mov		eax,TRUE
		.endif
		ret
	.elseif uMsg==WM_NCPAINT
		mov eax,iCaption
		ret

	.ELSEIF uMsg==WM_LBUTTONDOWN
		invoke SetCursor,hCURSOR
		invoke ReleaseCapture
		invoke SendMessage,hWnd,WM_NCLBUTTONDOWN, HTCAPTION,0

	.ELSEIF uMsg==WM_MOVE
		invoke GetWindowRect,hDisplayDialog,ADDR lpRECT
		mov eax,lpRECT.left
		mov pt.x,eax
		mov eax,lpRECT.top
		mov pt.y,eax
		invoke ScreenToClient,hPrevBox,ADDR pt

		mov sInfo.cbSize,SIZEOF SCROLLINFO
		mov sInfo.fMask,SIF_POS
		mov eax,10
		sub eax,pt.x
		mov sInfo.nPos,eax
		invoke SetScrollInfo,hScroll,SB_CTL,ADDR sInfo,TRUE
		
		mov sInfo.cbSize,SIZEOF SCROLLINFO
		mov sInfo.fMask,SIF_POS
		mov eax,10
		sub eax,pt.y
		mov sInfo.nPos,eax
		invoke SetScrollInfo,vScroll,SB_CTL,ADDR sInfo,TRUE

	.ELSE
		mov eax,FALSE
		ret

	.ENDIF

	mov eax, TRUE
	ret
DummyDlgProc endp

ChildProc proc uses ebx esi edi hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg>=WM_MOUSEFIRST && uMsg<=WM_MOUSELAST
		;Redirect all mouse messages to parent
		invoke GetParent,hWnd
		invoke PostMessage,eax,uMsg,wParam,lParam
		xor		eax,eax
		ret
	.endif
	invoke GetWindowLong,hWnd,GWL_USERDATA
	invoke CallWindowProc,eax,hWnd,uMsg,wParam,lParam
	ret

ChildProc endp

EnumChildProc proc uses ebx esi edi hWnd:HWND,lParam:LPARAM
	LOCAL tempClassName[64]	:BYTE

	invoke GetWindowLong,hWnd,GWL_EXSTYLE
	or eax,WS_EX_CONTROLPARENT
	invoke SetWindowLong,hWnd,GWL_EXSTYLE,eax
	;Get old wndproc
	invoke GetClassName,hWnd,ADDR tempClassName,64
	invoke lstrcmpi,ADDR tempClassName,OFFSET Shit
	.IF eax != 0
		invoke GetWindowLong,hWnd,GWL_WNDPROC
		;Save it in userdata
		invoke SetWindowLong,hWnd,GWL_USERDATA,eax
		;Subclass the control
		invoke SetWindowLong,hWnd,GWL_WNDPROC,offset ChildProc
	.ELSE
		invoke EnableWindow,hWnd,FALSE
	.ENDIF
	mov eax,TRUE
	ret
EnumChildProc endp

ResetScrollBar proc
	LOCAL sInfo		:SCROLLINFO

	mov sInfo.nMax,517
	mov sInfo.nMin,0
	mov sInfo.fMask,SIF_RANGE
	invoke SetScrollInfo,hScroll,SB_CTL,ADDR sInfo,TRUE

	mov sInfo.nMax,227
	mov sInfo.nMin,0
	mov sInfo.fMask,SIF_RANGE
	invoke SetScrollInfo,vScroll,SB_CTL,ADDR sInfo,TRUE

	ret
ResetScrollBar endp

CreateMemDialog proc  uses ebx esi edi StartReadAt:DWORD,ResSize:DWORD
	LOCAL	pHeap		:DWORD
	LOCAL	DlgType		:DWORD
	LOCAL	DlgCap		:DWORD

	.IF hDisplayDialog != INVALID_HANDLE_VALUE
		invoke SendMessage,hDisplayDialog,WM_CLOSE,0,0
		mov hDisplayDialog,INVALID_HANDLE_VALUE
	.ENDIF

	invoke ReadDlgXHeader,StartReadAt
	mov DlgType,eax

	invoke GlobalAlloc,GMEM_FIXED,ResSize
	mov pHeap,eax

	invoke MemCopy,StartReadAt,pHeap,ResSize
	mov edi,pHeap
	.IF DlgType == 1	; Adjust pointer for DialogEx
		add edi,12
	.ENDIF
	mov eax,[edi]
	push eax
	.IF eax & WS_CAPTION
		mov DlgCap,FALSE
	.ELSE
		mov DlgCap,TRUE
		mov ax,[edi+10]
		mov edx,SystemMetric.CXSIZEFRAME
		add ax,dx
		mov [edi+10],ax
		mov ax,[edi+12]
		mov edx,SystemMetric.CYSIZEFRAME
		add ax,dx
		mov edx,SystemMetric.CYCAPTION
		add ax,dx
		mov [edi+12],ax
	.ENDIF
	pop eax
	and eax,0BFFFFFFFh	; Remove the WS_CHILD style
	mov [edi],eax

	invoke DialogBoxIndirectParam,hInstance,pHeap,NULL,ADDR DummyDlgProc,DlgCap
	.IF eax == INVALID_HANDLE_VALUE
		invoke GetLastError
		.IF eax == 1407
			invoke MessageBox,hDlg,ADDR szCustClassErr,ADDR szwindowClass,MB_OK
		.ELSEIF eax == 1813
			invoke MessageBox,hDlg,ADDR szResourceError,NULL,MB_OK
		.ENDIF
	.ENDIF

	invoke GlobalFree,pHeap
	ret
CreateMemDialog endp

StringEnumerator proc hModule:DWORD,lpType:DWORD,lpName:DWORD,lParam:DWORD
	LOCAL hFindRes			:DWORD
	LOCAL hResData			:DWORD
	LOCAL pResData			:DWORD
	LOCAL ResSize			:DWORD
	LOCAL ResEnd			:DWORD
	LOCAL len				:DWORD
	LOCAL szString[64]		:BYTE
	LOCAL cbWrite			:DWORD
	LOCAL gtlx				:GETTEXTLENGTHEX

	invoke FindResource,hModule,lpName,lpType
	mov hFindRes,eax
	invoke SizeofResource,hModule,hFindRes
	mov ResSize,eax
	invoke LoadResource,hModule,hFindRes
	mov hResData,eax
	invoke LockResource,hResData
	mov pResData,eax

	add eax,ResSize
	mov ResEnd,eax

	;Scan ahead to non-zero
	mov edi,pResData
	mov eax,[edi]
	.WHILE eax == 0
		inc edi
		mov al,[edi]
		.IF edi >= ResEnd
			mov eax,FALSE
			ret
		.ENDIF
	.endw

	.REPEAT
		; Get the length in WCHARS of this item
		xor eax,eax
		mov al,[edi]
		mov len,eax
		.BREAK .IF eax == 0
		; move the pointer to the start of the string
		add edi,2
		; Clear the buffer
		invoke RtlZeroMemory,ADDR szString,64
		invoke WideCharToMultiByte,CP_ACP,NULL,edi,len,ADDR szString,63,NULL,NULL
		push eax
		lea ecx,szString
		add ecx,eax
		mov BYTE PTR [ecx],13
		mov BYTE PTR [ecx+1],10
		; The string is in szString----------------
		.IF lParam != INVALID_HANDLE_VALUE
		;	lea ecx,szString
		;	add ecx,eax
		;	mov BYTE PTR [ecx],13
		;	mov BYTE PTR [ecx+1],10
			add eax,2
			mov ecx,eax
			invoke WriteFile,lParam,ADDR szString,ecx,ADDR cbWrite,NULL
		.ELSE
		;	lea ecx,szString
		;	add ecx,eax
		;	mov BYTE PTR [ecx],13
		;	mov BYTE PTR [ecx+1],10
			mov gtlx.flags,GTL_NUMCHARS
			mov gtlx.codepage,CP_ACP
			; Make sure the caret is at the end of the edit control
			invoke SendMessage,hDisplayDialog,EM_GETTEXTLENGTHEX,ADDR gtlx,0
			invoke SendMessage,hDisplayDialog,EM_SETSEL,eax,eax
			invoke SendMessage,hDisplayDialog,EM_REPLACESEL,0,ADDR szString
		.ENDIF
		;------------------------------------------
		pop eax
		shl eax,1
		add edi,eax
		mov al,[edi]
		;Scan ahead to non-zero
		.WHILE eax == 0
			inc edi
			mov al,[edi]
			.IF edi >= ResEnd
				mov eax,TRUE
				ret
			.ENDIF
		.endw
	.UNTIL edi >= ResEnd

	mov eax,TRUE
	ret

StringEnumerator endp

SaveStringResource proc hModule:DWORD,lParam:DWORD
	LOCAL hFile			:DWORD

	.IF lParam == 0
		invoke OpenFileForWrite,OFFSET szTxtCurExt,OFFSET szTxtFilterStr
		mov hFile,eax
		; Enumerate the string Resources and save them one at a time
		invoke EnumResourceNames,hModule,RT_STRING,OFFSET StringEnumerator,hFile
		invoke FlushFileBuffers,hFile
		invoke CloseHandle,hFile
	.ELSEIF lParam == -1
		invoke EnumResourceNames,hModule,RT_STRING,OFFSET StringEnumerator,INVALID_HANDLE_VALUE
	.ENDIF

	ret
SaveStringResource endp

PECheckCompress proc uses edi hPEFile:DWORD
	LOCAL nrvadirectories	:DWORD
	LOCAL nsections			:DWORD
	LOCAL iSize				:DWORD
	LOCAL SectionName[16]	:BYTE

	invoke CreateFileMapping,hPEFile,NULL,PAGE_READONLY,0,0,NULL
	mov hMapFile,eax
	invoke SetLastError,0
	invoke MapViewOfFile,hMapFile,FILE_MAP_READ,0,0,0
	mov pMapFile,eax
	invoke GetLastError
	.IF eax != 0
		push -1
		jmp NoMapping
	.endif

	mov eax,pMapFile
	.IF [eax].IMAGE_DOS_HEADER.e_magic != IMAGE_DOS_SIGNATURE
		push -1
		jmp LeaveProc
	.ENDIF

	mov eax,pMapFile
	mov edi,[eax].IMAGE_DOS_HEADER.e_lfanew

	add edi,pMapFile
	mov eax,[edi].IMAGE_NT_HEADERS.Signature
	.IF eax != IMAGE_NT_SIGNATURE
		push -1
		jmp LeaveProc
	.ENDIF

	movzx eax,[edi].IMAGE_NT_HEADERS.FileHeader.NumberOfSections
;	movzx eax,ax
	mov nsections,eax

	mov eax,[edi].IMAGE_NT_HEADERS.OptionalHeader.NumberOfRvaAndSizes
	mov nrvadirectories,eax

	push edi ; Save the base address of IMAGE_NT_HEADERS
;	mov eax,OFFSET IMAGE_NT_HEADERS.OptionalHeader ; .DataDirectory
	add edi,OFFSET IMAGE_NT_HEADERS.OptionalHeader ; .DataDirectory

	mov eax,[edi+112].IMAGE_DATA_DIRECTORY.isize ; Physical size of resource section
	mov iSize,eax

	pop edi ; Restore the base address of IMAGE_NT_HEADERS
;	mov eax,SIZEOF IMAGE_NT_HEADERS
	add edi,SIZEOF IMAGE_NT_HEADERS ; Move the pointer to the first IMAGE_SECTION_HEADER

	xor ecx,ecx
	.WHILE ecx < nsections
		push ecx
		lea eax,SectionName
		mov [eax],DWORD PTR 0
		mov [eax+4],DWORD PTR 0
		invoke lstrcpyn,ADDR SectionName,edi,8
		invoke lstrcmpi,ADDR SectionName,OFFSET szResource
		.IF eax == 0
			; This is acutally the virtual size entry there is a Union present
			mov eax,[edi].IMAGE_SECTION_HEADER.Misc.PhysicalAddress
			.IF eax != iSize
				push -1
				jmp LeaveProc
			.endif
		.ENDIF
		add edi,SIZEOF IMAGE_SECTION_HEADER
		pop ecx
		inc ecx
	.ENDW

	push 0
	LeaveProc:
	invoke UnmapViewOfFile,pMapFile
	NoMapping:
	invoke CloseHandle,hMapFile
	invoke CloseHandle,hPEFile
	pop eax
	ret
PECheckCompress ENDP

SaveToRap proc pResFileName:DWORD,ResID:DWORD,TypeOfRes:DWORD
	LOCAL OutputBuffer[1023]	:BYTE
	LOCAL KeyName[16]			:BYTE
	LOCAL pProject				:DWORD
	LOCAL ResType				:DWORD

	invoke MessageBox,hDlg,OFFSET szSaveRap,OFFSET szResourceSect,MB_YESNO
	.IF eax == IDNO
		mov eax,-1
		ret
	.endif
	mov eax,lpData
	mov eax,[eax].ADDINDATA.lpProject
	mov pProject,eax

	.IF TypeOfRes == RT_STRING
		invoke wsprintf,ADDR OutputBuffer,OFFSET szStringFormat,ResID,pResFileName
		invoke GetNextIniEntry,OFFSET szStringSect
		mov ecx,eax
		invoke dwtoa,ecx,ADDR KeyName
		invoke WritePrivateProfileString,OFFSET szStringSect,ADDR KeyName,ADDR OutputBuffer,pProject
	.ELSE
		.IF TypeOfRes == RT_BITMAP
			mov ResType,0
		.ELSEIF TypeOfRes == RT_GROUP_CURSOR
			mov ResType,1
		.ELSEIF TypeOfRes == RT_GROUP_ICON
			mov ResType,2
		.ENDIF
		invoke wsprintf,ADDR OutputBuffer,OFFSET szResFormat,ResID,ResType,pResFileName
		invoke GetNextIniEntry,OFFSET szResourceSect
		mov ecx,eax
		invoke dwtoa,ecx,ADDR KeyName
		invoke WritePrivateProfileString,OFFSET szResourceSect,ADDR KeyName,ADDR OutputBuffer,pProject
	.ENDIF
	ret
SaveToRap endp

ALIGN 16
GetNextIniEntry proc pSectionName:DWORD
	LOCAL pBuffer				:DWORD
	LOCAL pProject				:DWORD
	LOCAL EndOfSection			:DWORD
	LOCAL StringBuffer[256]		:BYTE

	mov eax,lpData
	mov eax,[eax].ADDINDATA.lpProject
	mov pProject,eax

	invoke GlobalAlloc,GMEM_FIXED,32767
	mov pBuffer,eax

	invoke GetPrivateProfileSection,pSectionName,pBuffer,32767,pProject
	add eax,pBuffer
	mov EndOfSection,eax
	mov edi,pBuffer

	.REPEAT
		invoke cpystr,ADDR StringBuffer,edi
		inc edi
		add edi,eax
	.UNTIL edi >= EndOfSection

	invoke GlobalFree,pBuffer
	; find the =
	lea edi,StringBuffer
	.REPEAT
		mov al,[edi]
		inc edi
	.UNTIL al == "="
	mov BYTE PTR [edi-1],0
	invoke atodw,ADDR StringBuffer
	inc eax
	ret
GetNextIniEntry endp

ALIGN 16
cpystr PROC uses esi edi ecx Dest:DWORD,Source:DWORD
	invoke StrLen,Source
	push eax		;save String length
	shr  eax,2		;eax = eax / 4
	add eax,1
	mov ecx,eax
	mov esi,Source
	mov edi,Dest
	
	@@:
		mov eax, [esi]
		add esi, 4
		mov [edi], eax
		add edi, 4
		sub ecx,1
	jnz @B

	pop eax			;load String length
;	add eax,Dest
	ret
cpystr ENDP

End DllEntry
