;#########################################################################
;		Assembler directives
.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include RADToolBar.inc

.code

;#########################################################################
;		Common AddIn Procedures
DllMainCRTStartup proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret

DllMainCRTStartup Endp

GrayedImageList proc uses ebx esi edi
	LOCAL	hIml:DWORD
	LOCAL	hDC:HDC
	LOCAL	mDC:HDC
	LOCAL	hBmp:DWORD
	LOCAL	nCount:DWORD
	LOCAL	rect:RECT

	mov		eax,lpHandles
	invoke SendMessage,[eax].ADDINHANDLES.hToolBar,TB_GETIMAGELIST,0,0
	mov		hIml,eax
	invoke ImageList_GetImageCount,hIml
	mov		nCount,eax
	shl		eax,4
	mov		rect.left,0
	mov		rect.top,0
	mov		rect.right,eax
	mov		rect.bottom,16
	invoke ImageList_Create,16,16,ILC_MASK or ILC_COLOR24,nCount,10
	mov		hNewImlGray,eax
	mov		eax,lpHandles
	invoke GetDC,NULL
	mov		hDC,eax
	invoke CreateCompatibleDC,hDC
	mov		mDC,eax
	invoke CreateCompatibleBitmap,hDC,rect.right,16
	mov		hBmp,eax
	mov		eax,lpHandles
	invoke ReleaseDC,NULL,hDC
	invoke SelectObject,mDC,hBmp
	push	eax
	invoke CreateSolidBrush,0C0C0C0h
	push	eax
	invoke FillRect,mDC,addr rect,eax
	xor		ecx,ecx
	.while ecx<nCount
		push	ecx
		invoke ImageList_Draw,hIml,ecx,mDC,rect.left,0,ILD_TRANSPARENT
		pop		ecx
		add		rect.left,16
		inc		ecx
	.endw
	invoke GetPixel,mDC,0,0
	mov		ebx,eax
	xor		esi,esi
	.while esi<16
		xor		edi,edi
		.while edi<rect.right
			invoke GetPixel,mDC,edi,esi
			.if eax!=ebx
				bswap	eax
				shr		eax,8
				movzx	ecx,al			; red
				imul	ecx,ecx,66
				movzx	edx,ah			; green
				imul	edx,edx,129
				add		edx,ecx
				shr		eax,16			; blue
				imul	eax,eax,25
				add		eax,edx
				add		eax,128
				shr		eax,8
				add		eax,16
				imul	eax,eax,010101h
				and		eax,0F0F0F0h
				shr		eax,2
				or		eax,808080h
				invoke SetPixel,mDC,edi,esi,eax
			.endif
			inc		edi
		.endw
		inc		esi
	.endw
	pop		eax
	invoke DeleteObject,eax
	pop		eax
	invoke SelectObject,mDC,eax
	invoke DeleteDC,mDC
	invoke ImageList_AddMasked,hNewImlGray,hBmp,ebx
	invoke DeleteObject,hBmp
	mov		ebx,lpHandles
	invoke SendMessage,[ebx].ADDINHANDLES.hToolBar,TB_SETDISABLEDIMAGELIST,0,hNewImlGray
	invoke SendMessage,[ebx].ADDINHANDLES.hPrpTbr,TB_SETDISABLEDIMAGELIST,0,hNewImlGray
	invoke SendMessage,[ebx].ADDINHANDLES.hPbrTbr,TB_SETDISABLEDIMAGELIST,0,hNewImlGray
	ret

GrayedImageList endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD

	mov	ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov	lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov	lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov	lpData,eax
	; If Option (fOpt) = 0 then exit
	mov eax,fOpt
	mov fOption,eax
	test eax,eax
	jne @F
		xor ecx,ecx
		xor edx,edx
		ret
	@@:
	mov eax,lpHandles
	mov eax,[eax].ADDINHANDLES.hToolBar
	mov hToolBar,eax
	invoke SendMessage, hToolBar, TB_GETBITMAP, UserBtnID1, 0
	mov Button1Def, eax
	invoke SendMessage, hToolBar, TB_GETBITMAP, UserBtnID2, 0
	mov Button2Def, eax
	invoke GetIniFile
	.IF fOpt & 1
		.if !OldhWinProc
			mov eax,lpHandles
			invoke SetWindowLong,[eax].ADDINHANDLES.hWnd,GWL_WNDPROC,OFFSET SubProc
			mov OldhWinProc,eax
		.endif
		mov AppClosing,FALSE
		invoke ReadToolBar
		invoke GetWindowLong,hToolBar,GWL_STYLE
		or eax,CCS_ADJUSTABLE
		invoke SetWindowLong,hToolBar,GWL_STYLE,eax
		invoke SaveDefToolBar ; save the start up toolbar
		invoke LoadToolBar ; Load the custom toolbar if there is one
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpToolBarStatus
	.ENDIF
	mov	eax,RAM_CLOSE
	test	fOpt,16+8
	.if !ZERO?
		mov eax, RAM_COMMANDDONE or RAM_COMMAND or RAM_TBRTOOLTIP or RAM_CLOSE or RAM_MENUREBUILD
	.endif
	mov ecx,RAM_UNHOOK or RAM_ADDINSLOADED
	xor edx,edx
	ret 

InstallDll Endp

GetOptions proc

	mov eax,offset AddinOpt
	ret

GetOptions endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc uses edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from
	mov		eax,uMsg
	.if eax==AIM_CLOSE
		mov		edi,lpHandles
		.if OldhWinProc
			mov		AppClosing,TRUE
			invoke LoadDefToolBar
			invoke GetWindowLong,hToolBar,GWL_STYLE
			and		eax,-1 xor CCS_ADJUSTABLE
			invoke SetWindowLong,hToolBar,GWL_STYLE,eax
			;Let the next in the chain unhook me
			push	RAM_UNHOOK
			push	OldhWinProc
			push	offset SubProc
			push	AIM_UNHOOK
			push	[edi].ADDINHANDLES.hWnd
			mov 	eax,lpProc
			call 	[eax].ADDINPROCS.lpDllProc
			invoke GetWindowLong,[edi].ADDINHANDLES.hWnd,GWL_WNDPROC
			.if eax==offset SubProc
				;My hook is on top, just unhook me
				invoke SetWindowLong,[edi].ADDINHANDLES.hWnd,GWL_WNDPROC,OldhWinProc
			.endif
			mov		OldhWinProc,0
		.endif
		.if hNewIml
			invoke SendMessage,hToolBar,TB_SETIMAGELIST,0,hOldIml
			invoke InvalidateRect,hToolBar,NULL,FALSE
			invoke SendMessage,[edi].ADDINHANDLES.hPrpTbr,TB_SETIMAGELIST,0,hOldIml
			invoke InvalidateRect,[edi].ADDINHANDLES.hPrpTbr,NULL,FALSE
			invoke SendMessage,[edi].ADDINHANDLES.hPbrTbr,TB_SETIMAGELIST,0,hOldIml
			invoke InvalidateRect,[edi].ADDINHANDLES.hPbrTbr,NULL,FALSE
			invoke ImageList_Destroy,hNewIml
			mov		hNewIml,NULL
		.endif
		.if hNewImlGray
			invoke SendMessage,[edi].ADDINHANDLES.hToolBar,TB_SETDISABLEDIMAGELIST,0,NULL
			invoke SendMessage,[edi].ADDINHANDLES.hPrpTbr,TB_SETDISABLEDIMAGELIST,0,NULL
			invoke SendMessage,[edi].ADDINHANDLES.hPbrTbr,TB_SETDISABLEDIMAGELIST,0,NULL
			invoke ImageList_Destroy,hNewImlGray
			mov		hNewImlGray,0
		.endif
		invoke UpdateWindow,hToolBar
		invoke UpdateWindow,[edi].ADDINHANDLES.hPrpTbr
		invoke UpdateWindow,[edi].ADDINHANDLES.hPbrTbr
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpToolBarStatus
	.elseif eax==AIM_COMMAND
		mov eax, wParam
		cmp eax, 48008
		jz _yes
			xor eax, eax
		_yes:
		mov EditFlag, eax
	.elseif eax==AIM_COMMANDDONE
		cmp EditFlag, 0
		jz @F
			.if fOption & 8
				invoke TBChangeIcon, offset IniKey1, UserBtnID1, Button1Def
				invoke TBChangeIcon, offset IniKey2, UserBtnID2, Button2Def
				invoke UpdateToolTips
				xor eax, eax
			.elseif fOption & 16
				invoke UpdateToolTips
				xor eax, eax
			.endif
			mov EditFlag, eax
		@@:
	.elseif eax==AIM_TBRTOOLTIP
		mov eax, wParam
		movzx eax, ax
		.if eax == UserBtnID1
			mov eax, offset FileDesc1
		.elseif eax == UserBtnID2
			mov eax, offset FileDesc2
		.else
			xor eax, eax
		.endif
		jmp Ex
	.elseif eax==AIM_MENUREBUILD
		invoke GetIniFile
		.if fOption == 1
			invoke TBChangeIcon, offset IniKey1, UserBtnID1, Button1Def
			invoke TBChangeIcon, offset IniKey2, UserBtnID2, Button2Def
			invoke UpdateToolTips
		.elseif fOption == 2
			invoke UpdateToolTips
		.endif
	.elseif eax==AIM_UNHOOK
		mov eax,lpHandles
		mov eax,[eax].ADDINHANDLES.hWnd
		.if eax==hWin
			mov eax,wParam
			.if eax==OldhWinProc
				;Remove the hook from the chain
				mov eax,lParam
				mov OldhWinProc,eax
				mov eax,TRUE
				jmp Ex
			.endif
		.endif
	.elseif eax==AIM_ADDINSLOADED
		.IF fOption &4
			invoke UpdateToolbar
		.endif
		.if fOption & 8
			invoke TBChangeIcon,offset IniKey1,UserBtnID1,Button1Def
			invoke TBChangeIcon,offset IniKey2,UserBtnID2,Button2Def
			invoke UpdateToolTips
		.elseif fOption & 16
			mov eax, lpData
			invoke lstrcpy,offset IcoPath,[eax].ADDINDATA.lpAddIn
			invoke lstrcat,offset IcoPath,offset Icon1File
			invoke TBLoadIcon, UserBtnID1,Button1Def,offset IcoPath
			mov eax, lpData
			invoke lstrcpy,offset IcoPath,[eax].ADDINDATA.lpAddIn
			invoke lstrcat,offset IcoPath,offset Icon2File
			invoke TBLoadIcon, UserBtnID2,Button2Def,offset IcoPath
			invoke UpdateToolTips
		.endif
		.IF fOption &2
			invoke GrayedImageList
		.endif
		mov edi,lpHandles
		invoke InvalidateRect,[edi].ADDINHANDLES.hToolBar,NULL,TRUE
		invoke InvalidateRect,[edi].ADDINHANDLES.hPrpTbr,NULL,TRUE
		invoke InvalidateRect,[edi].ADDINHANDLES.hPbrTbr,NULL,TRUE
		invoke UpdateWindow,[edi].ADDINHANDLES.hToolBar
		invoke UpdateWindow,[edi].ADDINHANDLES.hPrpTbr
		invoke UpdateWindow,[edi].ADDINHANDLES.hPbrTbr
	.endif
	mov eax,FALSE
  Ex:
	ret
DllProc Endp

SubProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL ti		:TOOLINFO

	mov	eax, uMsg
	.IF eax == WM_NOTIFY
		mov eax,lParam
		mov eax,[eax].NMHDR.code
		.IF eax == TBN_QUERYINSERT
			mov eax,TRUE
			ret

		.ELSEIF eax == TBN_QUERYDELETE
			mov eax,TRUE
			ret

		.ELSEIF eax == TBN_INITCUSTOMIZE
			mov eax,TBNRF_HIDEHELP
			ret

		.ELSEIF eax == TBN_RESET
			invoke LoadDefToolBar
			ret

		.ELSEIF eax == TBN_ENDADJUST
			invoke SaveToolBar
			ret

		.ELSEIF eax == TBN_GETBUTTONINFOW
			push	esi
			push	edi
			mov edi,lParam
			mov esi,[edi].NMTOOLBAR.iItem
			add edi,NMTOOLBAR.tbButton
			.IF esi <= nTotalBtns
				mov eax,SIZEOF RADTBBUTTON
				imul esi
				add eax,OFFSET tbrbtns
				.IF [eax].RADTBBUTTON.TBB.idCommand == 0
					mov [eax].RADTBBUTTON.TBB.fsStyle,TBSTYLE_SEP
				.endif
				push eax
				invoke MemCopy,eax,edi,SIZEOF TBBUTTON
				pop eax
				mov edi,lParam
				add eax,RADTBBUTTON.szNAME
				mov [edi].NMTOOLBAR.pszText,eax
				mov [edi].NMTOOLBAR.cchText,79
				mov eax,TRUE
			.ELSE
				mov eax,FALSE
			.ENDIF
			pop		edi
			pop		esi
			ret

		.ELSE
			invoke CallWindowProc,OldhWinProc,hWin, uMsg, wParam, lParam
			ret
		.ENDIF

	.ELSE
		invoke CallWindowProc,OldhWinProc,hWin, uMsg, wParam, lParam
		ret
	.endif

	ret
SubProc Endp

;#########################################################################

UpdateToolbar proc uses edi
	LOCAL NewCount		:DWORD
	LOCAL OldCount		:DWORD
	LOCAL hdc			:DWORD
	LOCAL hMemdc		:DWORD
	LOCAL hbmp			:DWORD
	LOCAL OldObj		:DWORD
	LOCAL rect			:RECT
	LOCAL hbrush		:DWORD

	mov rect.left,0
	mov rect.top,0
	mov rect.right,16
	mov rect.bottom,16

	invoke ImageList_LoadImage,hInstance,10000,16,255,0C0C0C0h,IMAGE_BITMAP,LR_CREATEDIBSECTION
	mov hNewIml,eax

	invoke SendMessage,hToolBar,TB_GETIMAGELIST,0,0
	mov hOldIml,eax

	invoke SendMessage,	hToolBar,TB_SETIMAGELIST,0,NULL

	invoke ImageList_GetImageCount,hOldIml
	mov OldCount,eax
	invoke ImageList_GetImageCount,hNewIml
	mov NewCount,eax

	.IF eax < OldCount
		invoke GetDC,NULL
		mov hdc,eax	
		invoke CreateCompatibleDC,hdc
		mov hMemdc,eax
		invoke CreateCompatibleBitmap,hdc,16,16
		mov hbmp,eax
		invoke ReleaseDC,NULL,hdc
		invoke CreateSolidBrush,0C0C0C0h
		mov hbrush, eax
		mov edi,NewCount
		.REPEAT
			invoke SelectObject,hMemdc,hbmp
			mov OldObj,eax
			invoke FillRect,hMemdc,ADDR rect,hbrush
			invoke ImageList_Draw,hOldIml,edi,hMemdc,0,0,ILD_TRANSPARENT;ILD_NORMAL
			invoke SelectObject,hMemdc,OldObj
			invoke ImageList_AddMasked,hNewIml,hbmp,0C0C0C0h
			inc edi
		.UNTIL edi == OldCount
		invoke DeleteObject,hbrush
		invoke DeleteObject,hbmp
		invoke DeleteDC,hMemdc
	.ENDIF

	invoke SendMessage,	hToolBar,TB_SETIMAGELIST,0,hNewIml
	mov edi,lpHandles
	invoke SendMessage,[edi].ADDINHANDLES.hPrpTbr,TB_SETIMAGELIST,0,hNewIml
	invoke SendMessage,[edi].ADDINHANDLES.hPbrTbr,TB_SETIMAGELIST,0,hNewIml

	ret

UpdateToolbar endp

ReadToolBar proc uses edi
	LOCAL ti		:TOOLINFO
	LOCAL hTBTips	:DWORD

	invoke SendMessage,hToolBar,TB_GETTOOLTIPS,0,0
	mov hTBTips,eax

	invoke SendMessage,hToolBar,TB_BUTTONCOUNT,0,0
	mov nTotalBtns,eax

	mov edi,OFFSET tbrbtns
	mov ti.cbSize,SIZEOF TOOLINFO
	mov ti.uFlags,NULL
	mov ti.lpszText,OFFSET TBTextBuffer
	mov eax,hToolBar
	mov ti.hWnd,eax

	mov eax,0
	.WHILE eax < nTotalBtns
		push eax
		invoke SendMessage,hToolBar,TB_GETBUTTON,eax,edi
		mov eax,[edi].RADTBBUTTON.TBB.idCommand
		mov ti.uId,eax
		invoke SendMessage,hTBTips,TTM_GETTEXT,0,ADDR ti

		add edi,RADTBBUTTON.szNAME
		invoke lstrcpyW,edi,OFFSET TBTextBuffer

		add edi,SIZEOF RADTBBUTTON.szNAME
		pop eax
		inc eax
	.ENDW

	ret
ReadToolBar endp

SaveDefToolBar proc
	LOCAL tbsp		:TBSAVEPARAMS
    
    mov tbsp.hkr,HKEY_CURRENT_USER
    mov tbsp.pszSubKey,OFFSET SubKey
    mov tbsp.pszValueName,OFFSET tbdefvalue
	invoke SendMessage,hToolBar,TB_SAVERESTORE,TRUE,ADDR tbsp
	ret

SaveDefToolBar endp

LoadDefToolBar proc
	LOCAL tbsp		:TBSAVEPARAMS
    
    mov tbsp.hkr,HKEY_CURRENT_USER
    mov tbsp.pszSubKey,OFFSET SubKey
    mov tbsp.pszValueName,OFFSET tbdefvalue
	invoke SendMessage,hToolBar,TB_SAVERESTORE,FALSE,ADDR tbsp
	ret

LoadDefToolBar endp

SaveToolBar proc
	LOCAL tbsp		:TBSAVEPARAMS

	.IF AppClosing == FALSE
	    mov tbsp.hkr,HKEY_CURRENT_USER
	    mov tbsp.pszSubKey,OFFSET SubKey
	    mov tbsp.pszValueName,OFFSET tbvalue
		invoke SendMessage,hToolBar,TB_SAVERESTORE,TRUE,ADDR tbsp
	.ENDIF
	ret

SaveToolBar endp

LoadToolBar proc
	LOCAL tbsp		:TBSAVEPARAMS
	LOCAL hKey		:DWORD

	; Check to see if the toolbar is empty
	; if it is load the default toolbar and save it as the current
	invoke RegOpenKeyEx,HKEY_CURRENT_USER,OFFSET SubKey,NULL,KEY_ALL_ACCESS,ADDR hKey
	.IF eax == ERROR_SUCCESS
		invoke RegCloseKey,hKey
		mov tbsp.hkr,HKEY_CURRENT_USER
	    mov tbsp.pszSubKey,OFFSET SubKey
	    mov tbsp.pszValueName,OFFSET tbvalue
		invoke SendMessage,hToolBar,TB_SAVERESTORE,FALSE,ADDR tbsp
	.ELSE
		invoke SaveToolBar
	.ENDIF

	ret

LoadToolBar endp

;######################################################################

TBChangeIcon	PROC IniKey :DWORD, UserBtnID :DWORD, ButtonDef :DWORD
	LOCAL FileBuffer[MAX_PATH]	:BYTE
	LOCAL hICON					:DWORD

	invoke UpdateIniKey
	invoke GetPrivateProfileString, offset IniSection, IniKey, offset IniKeyDef, ADDR FileBuffer, MAX_PATH, lpIniAsmFile
	invoke CompareString, LOCALE_SYSTEM_DEFAULT, 0, ADDR FileBuffer, -1, offset IniKeyDef, -1
	.if eax != 2
		invoke Parsestring, ADDR FileBuffer, REQUEST_PATH
		invoke FixPath, ADDR FileBuffer
		xor ecx, ecx
		mov hICON, ecx
		invoke ExtractIconEx, ADDR FileBuffer, ecx, ecx, ADDR hICON, 1
		dec eax
		jnz @F
		invoke UpdateIcon,hICON,UserBtnID
	.else
		@@:
		invoke SendMessage,hToolBar,TB_CHANGEBITMAP,UserBtnID,ButtonDef
	.endif
	ret
TBChangeIcon	ENDP

TBLoadIcon	PROC UserBtnID :DWORD, ButtonDef :DWORD, ICOPath
	invoke LoadImage,NULL,ICOPath,IMAGE_ICON,16,16,LR_LOADFROMFILE
	test eax, eax
	jz @F
		invoke UpdateIcon,eax,UserBtnID
		ret
	@@:
		invoke SendMessage,hToolBar,TB_CHANGEBITMAP,UserBtnID,ButtonDef
		xor	eax, eax
	ret
TBLoadIcon	ENDP

UpdateIcon	PROC hICON :DWORD, IDButton:DWORD
	LOCAL myDC		:DWORD
	LOCAL hBmp		:DWORD
	LOCAL PrevBmp	:DWORD
	LOCAL hIml		:DWORD
	LOCAL iOld		:DWORD
	LOCAL iNew		:DWORD

	invoke GetDC, hToolBar
	push eax
	push 16
	push 16
	push eax
	invoke CreateCompatibleDC, eax
	mov myDC, eax
	call CreateCompatibleBitmap
	mov hBmp, eax
	invoke SelectObject, myDC, eax
	mov PrevBmp, eax
	push hToolBar
	call ReleaseDC

	invoke GetSysColor, COLOR_BTNFACE
	invoke CreateSolidBrush, eax
	push eax
	invoke SelectObject, myDC, eax
	push eax
	push myDC
	invoke CreateRectRgn, 0, 0, 16, 16
	push eax
	invoke PaintRgn, myDC, eax
	;Region
	call DeleteObject
	;Old Brush
	call SelectObject
	;Brush
	call DeleteObject

	xor eax,eax
	invoke DrawIconEx,myDC,eax,eax,hICON,16,16,eax,eax,DI_NORMAL
	invoke DestroyIcon,hICON

	invoke SelectObject,myDC,PrevBmp
	invoke DeleteDC,myDC

	invoke SendMessage,hToolBar,TB_GETIMAGELIST,0,0
	mov hIml,eax
	invoke SendMessage,hToolBar,TB_GETBITMAP,IDButton,0
	mov iOld,eax
	invoke GetSysColor,COLOR_BTNFACE
	invoke ImageList_AddMasked,hIml,hBmp,eax
	mov iNew,eax
	invoke ImageList_GetIcon,hIml,eax,ILD_NORMAL
	push eax
	invoke ImageList_ReplaceIcon,hIml,iOld,eax
	pop eax
	invoke DestroyIcon,eax
	invoke ImageList_Remove,hIml,iNew

	invoke DeleteObject,hBmp
	ret
UpdateIcon	ENDP

Parsestring	PROC USES edi esi edx eax, ItemArray :DWORD, Request :DWORD

	; Request:
	; 			REQUEST_DESCRIPTION - returns the description column
	; 			REQUEST_PATH		- returns the path column

	mov eax, ItemArray
	dec eax
	xor edx, edx
	@@:
		inc eax
		cmp BYTE PTR [eax], dl
		jnz @B
	mov WORD PTR [eax], ','

	xor ecx, ecx	; ecx = current byte pointer
	xor edi, edi	; edi = current comma number
					; edx = current word pointer

	_loop:
		mov eax, ItemArray
		mov al, BYTE PTR [eax+ecx]
		test al, al
		jz _close
		cmp al, ','
		jnz _not_com
			inc edi
			cmp edi, Request
			jnz _not_req
				mov eax, ItemArray
				add ecx, eax
				add edx, eax
				mov BYTE PTR [ecx], 0
				mov eax, ItemArray
				@@:
					mov cl, BYTE PTR [edx]
					inc edx
					mov BYTE PTR [eax], cl
					inc eax
					test cl, cl
					jnz @B
				ret
			_not_req:
			mov edx, ecx
			inc edx
		_not_com:
	inc ecx
	jmp _loop
	_close:
	ret
Parsestring	ENDP

GetIniKey	PROC USES ebx, Current :DWORD, Result :DWORD

	LOCAL Key[2]				:BYTE
	LOCAL FileBuffer[MAX_PATH]	:BYTE

	mov ecx, Current
	movzx ebx, BYTE PTR [ecx]
	xor eax, eax
	inc ebx
	mov Key[1], al
	@@:
		mov Key[0], bl
		invoke GetPrivateProfileString, ADDR IniSection, ADDR Key, offset IniKeyDef, ADDR FileBuffer, MAX_PATH, lpIniAsmFile
		invoke Parsestring, ADDR FileBuffer, REQUEST_DESCRIPTION
		cmp FileBuffer, '-'
		jnz @F
			inc ebx
			jmp @B
	@@:
	movzx eax, Key
	mov ecx, Result
	mov WORD PTR [ecx], ax
	ret
GetIniKey	ENDP

UpdateToolTips	PROC
	invoke UpdateIniKey
	invoke GetPrivateProfileString, offset IniSection, offset IniKey1, offset IniKeyDef, offset FileDesc1, MAX_PATH, lpIniAsmFile
	invoke Parsestring, offset FileDesc1, REQUEST_DESCRIPTION
	invoke GetPrivateProfileString, offset IniSection, offset IniKey2, offset IniKeyDef, offset FileDesc2, MAX_PATH, lpIniAsmFile
	invoke Parsestring, offset FileDesc2, REQUEST_DESCRIPTION
	ret
UpdateToolTips	ENDP

UpdateIniKey	PROC
	mov WORD PTR [IniKey1], '0'
	invoke GetIniKey, offset IniKey1, offset IniKey1
	invoke GetIniKey, offset IniKey1, offset IniKey2
	ret
UpdateIniKey	ENDP

FixPath	PROC USES ebx Buffer :DWORD

	mov eax, Buffer
	mov ecx, lpData
	push [ecx].ADDINDATA.lpBin
	push 'B'
	push eax
	push [ecx].ADDINDATA.lpAddIn
	push 'D'
	push eax
	push [ecx].ADDINDATA.lpHlp
	push 'H'
	push eax
	push [ecx].ADDINDATA.lpIncl
	push 'I'
	push eax
	push [ecx].ADDINDATA.lpLib
	push 'L'
	push eax
	push [ecx].ADDINDATA.lpMac
	push 'M'
	push eax
	push [ecx].ADDINDATA.lpPro
	push 'P'
	push eax
	push [ecx].ADDINDATA.lpApp
	push 'R'
	push eax
	push [ecx].ADDINDATA.lpSnp
	push 'S'
	push eax
	push [ecx].ADDINDATA.lpTpl
	push 'T'
	push eax
	mov ebx, 10
	@@:
		call InsertPath
		dec ebx
		jnz @B
	ret
FixPath	ENDP

InsertPath	PROC lpBuffer :DWORD, lpFind :DWORD, lpPath :DWORD

	LOCAL LocalBuffer[MAX_PATH]	:BYTE

	mov ecx, lpBuffer
	cmp BYTE PTR [ecx], '$'
	jnz _exit

	inc ecx
	movzx eax, BYTE PTR [ecx]
	cmp eax, lpFind
	jnz _exit

	invoke lstrcpy, ADDR LocalBuffer, lpPath
	mov eax, lpBuffer
	inc eax
	inc eax
	invoke lstrcat, ADDR LocalBuffer, eax
	invoke lstrcpy, lpBuffer, ADDR LocalBuffer
	xor eax, eax
	inc eax
	ret

	_exit:
	xor eax, eax
	ret

InsertPath	ENDP

GetIniFile	PROC

	LOCAL LocalBuffer[MAX_PATH]	:BYTE

	mov eax, lpData
	mov ecx, [eax].ADDINDATA.lpIniAsmFile
	mov lpIniAsmFile, ecx

	mov WORD PTR [IniKey1], '1'
	invoke GetPrivateProfileString, offset IniSection, offset IniKey1, offset IniKeyDef, ADDR LocalBuffer, MAX_PATH, lpIniAsmFile
	cmp LocalBuffer, '?'
	jnz @F
		mov eax, lpData
		mov ecx, [eax].ADDINDATA.lpIniFile
		mov lpIniAsmFile, ecx
	@@:
	ret
GetIniFile	ENDP

;######################################################################

End DllMainCRTStartup
