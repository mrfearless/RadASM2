;;Just checking out Radasm's plugin interface
;;Martial Code 2001

include asciitab.inc
.code

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD 

	mov eax,hInst
	mov hInstance,eax
	mov  eax,TRUE 
	ret 

DllEntry Endp

AddMenu proc
	LOCAL	nMnu:DWORD
	LOCAL	hMnu:DWORD

	.if AsciiMenuID
		mov		nMnu,6
		;Adjust topmost popup if maximized.
		mov		eax,[lpDStruct]
		mov		eax,(ADDINDATA ptr [eax]).fMaximized
		.if eax
			inc		nMnu
		.endif
		;Get handle of menu
		mov		eax,[lpHStruct]
		mov		eax,(ADDINHANDLES ptr [eax]).hMenu
		;Get handle of Tools popup
		invoke GetSubMenu,eax,nMnu		;Tools menu
		mov		hMnu,eax
		;Add our menuitem
		invoke AppendMenu,hMnu,MF_STRING,AsciiMenuID,addr szAsciiMenu
	.endif
	ret

AddMenu endp

InstallDll proc hWin:dword,fOpt:Dword

	push ebx
	mov eax,fOpt
	.if eax
		invoke SendMessage,hWin,AIM_GETHANDLES,0,0;	;Get pointer to handles struct
		mov	lpHStruct,eax
		invoke SendMessage,hWin,AIM_GETPROCS,0,0;Get pointer to proc struct
		mov	lpPStruct,eax
		invoke SendMessage,hWin,AIM_GETDATA,0,0	;Get pointer to data struct
		mov	lpDStruct,eax
		mov ebx,eax
		invoke StrLen,(ADDINDATA PTR[ebx]).lpAddIn
		push eax ;push stringlength
		invoke MemCopy,(ADDINDATA PTR[ebx]).lpAddIn,addr szEMFpathname,eax
		pop eax ;pop string length
		lea ecx,[szEMFpathname+eax]
		invoke MemCopy,addr szEMFilename,ecx,14
		invoke SendMessage,hWin,AIM_GETMENUID,0,0;get our own menu id
		mov	AsciiMenuID,eax
		mov mytbbutton.idCommand,eax ;toolbar button will have the same id as our menuitem
		invoke AddMenu
		mov ebx,[lpHStruct]
		mov ebx,(ADDINHANDLES ptr [ebx]).hToolBar
		invoke SendMessage,ebx,TB_GETIMAGELIST,0,0
		push eax
		invoke LoadBitmap,hInstance,IDBMP_TBBMP
		pop edx
		push eax
		invoke ImageList_AddMasked,edx,eax,000000h
		mov	mytbbutton.iBitmap,eax
		pop eax
		invoke DeleteObject,eax
		invoke SendMessage,ebx,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
		invoke SendMessage,ebx,TB_INSERTBUTTON,-1,offset mytbbutton
;		invoke CreateDialogParamW,hInstance,IDD_DLG,hWin,offset DlgProc,NULL
		push NULL
		push offset DlgProc
		push hWin
		push IDD_DLG
		push hInstance
		mov eax,lpPStruct
		call [eax].ADDINPROCS.lpModelessDialog
		mov hDlgwnd,eax
		;tell RA what msgs we want to be sent
		mov eax,RAM_COMMAND or RAM_INITMENUPOPUP or RAM_CLOSE or RAM_TBRTOOLTIP or RAM_MENUREBUILD
	.endif
	;must return NULL in ecx and edx
	mov	ecx,RAM_ADDINSLOADED
	xor edx,edx
	pop ebx
	ret

InstallDll endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

DllProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	mnui:MENUITEMINFO

	mov eax,uMsg
	.if eax==AIM_COMMAND
		mov ecx,wParam
		and ecx,0FFFFh
		.if ecx==AsciiMenuID
			invoke ShowWindow,hDlgwnd,SW_SHOWNORMAL or SW_RESTORE
			mov eax,TRUE
			ret
		.endif
	.elseif eax==AIM_INITMENUPOPUP
		mov eax,[lpHStruct]
		mov eax,(ADDINHANDLES ptr [eax]).hEdit
		mov hEdt,eax
		;Enable/disable the menuitem
		mov		edx,MF_GRAYED
		.if eax
			mov		edx,MF_ENABLED
		.endif
		mov		eax,[lpHStruct]
		mov		eax,(ADDINHANDLES ptr [eax]).hMenu
		invoke EnableMenuItem,eax,AsciiMenuID,edx
	.elseif eax==AIM_CLOSE
		;Now is the time to kill timers, free memory, destroy windows, unhook, delete menuitems and delete toolbar buttons
		invoke DestroyWindow,hDlgwnd
		mov edx,lpHStruct
		mov eax,[edx].ADDINHANDLES.hMenu
		invoke DeleteMenu,eax,AsciiMenuID,MF_BYCOMMAND
		mov edx,[lpHStruct]
		invoke SendMessage,(ADDINHANDLES ptr [edx]).hToolBar,TB_COMMANDTOINDEX,AsciiMenuID,0
		mov edx,[lpHStruct]
		invoke SendMessage,(ADDINHANDLES ptr [edx]).hToolBar,TB_DELETEBUTTON,eax,0
		mov AsciiMenuID,0
	.elseif eax==AIM_TBRTOOLTIP
		mov		eax,wParam
		.if eax==AsciiMenuID
			push sizeof szBuff/2
			push offset szBuff
			push 4000
			push offset szAppName
			mov eax,lpPStruct
			call [eax].ADDINPROCS.lpGetLangString
			.if !eax
				mov eax,offset szAsciiToolTip
			.else
				mov eax,offset szBuff
				;To tell RadASM it's unicode
				mov edx,123456
			.endif
			ret
		.endif
	.elseif eax==AIM_ADDINSLOADED || eax==AIM_MENUREBUILD
		.if eax==AIM_MENUREBUILD
			invoke AddMenu
		.else
			push sizeof szBuff/2
			push offset szBuff
			push offset szAppName
			push offset szAppName
			mov eax,lpPStruct
			call [eax].ADDINPROCS.lpGetLangString
			.if eax
				invoke SendMessageW,hDlgwnd,WM_SETTEXT,0,offset szBuff
			.endif
		.endif
		push sizeof buffer/2
		lea eax,buffer
		push eax
		push 2000
		push offset szAppName
		mov eax,lpPStruct
		call [eax].ADDINPROCS.lpGetLangString
		.if eax
			mov mnui.cbSize,sizeof mnui
			mov mnui.fMask,MIIM_TYPE
			mov mnui.fType,MFT_STRING
			lea eax,buffer
			mov mnui.dwTypeData,eax
			;Insert our menuitem
			mov edx,[lpHStruct]
			invoke SetMenuItemInfoW,(ADDINHANDLES ptr [edx]).hMenu,AsciiMenuID,FALSE,addr mnui
		.endif
	.endif
	mov eax,FALSE;for all messages except private WM_COMMANDs,
	ret

DllProc endp

DlgProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL hdc:HDC
	local Clientrect:RECT
	local X_mouse:dword
	local Y_mouse:dword
	local ps:PAINTSTRUCT
		
	.IF uMsg== WM_PAINT
		invoke BeginPaint,hWnd,addr ps
		mov hdc,eax
		lea ecx,Clientrect
		invoke GetClientRect,hWnd,ecx
		lea ecx,Clientrect
		invoke PlayEnhMetaFile,hdc,hEMF,ecx;play EMF opened during WM_INITDIALOG
		invoke EndPaint,hWnd,addr ps
		mov edx,0	;calculate X and Y pixels/division
		mov eax,Clientrect.right
		mov ecx,17
		div ecx
		mov X_div,eax
		mov edx,0
		mov eax,Clientrect.bottom
		mov ecx,9
		div ecx
		mov Y_div,eax
	.ELSEIF uMsg==WM_LBUTTONDOWN
		mov eax,lParam
		push eax ;save lParam
		and eax,0FFFFh	;convert xposition of mouse into an index which corresponds
		mov edx,0				;to character hex value
		div X_div
		dec eax
		mov X_mouse,eax
		pop eax;restore lParam
		rol eax,16	;convert xposition of mouse into an index which corresponds
		and eax,0FFFFh ;to character hex value
		mov edx,0
		div Y_div
		dec eax
		mov Y_mouse,eax
		.if nBytes<MAXBYTES
			mov ecx,nBytes
			lea eax,[szBuf+ecx+1]
			invoke wsprintf,eax,addr szfrmt,X_mouse,Y_mouse
			add nBytes,2
			invoke revstr,addr szBuf,addr szrevBuf ;the chars are printed in byte swapped order
			call clrOut														;
			invoke textOut,addr szrevBuf;send text to RA's output window
		.else
			invoke MessageBox,hWnd,addr szBuffull,NULL,MB_OK
		.endif
	.ELSEIF uMsg==WM_RBUTTONDOWN
		.if nBytes>0 ;remove last char from buffer
			call clrOut
			sub nBytes,2
			mov ecx,nBytes
			lea eax,[szBuf+ecx+1]
			mov byte ptr[eax],NULL
			cmp nBytes,NULL
			jne @f
			mov szrevBuf,NULL
			jmp zerolength
			@@:
			invoke revstr,addr szBuf,addr szrevBuf
		  zerolength:
			invoke textOut,addr szrevBuf;send text to RA's output window
		.endif
	.ELSEIF uMsg==WM_SIZE
		invoke InvalidateRect,hWnd,NULL,FALSE
	.ELSEIF uMsg==WM_RBUTTONDBLCLK
		call clrOut	;empty entire buffer
		xor eax,eax
		mov nBytes,eax
		lea eax,[szBuf+1]
		mov byte ptr [eax],NULL
	.ELSEIF uMsg==WM_HOTKEY
		cmp hEdt,NULL
		je close ;on exit send chars to active edit window
		invoke SendMessage,hEdt,EM_REPLACESEL,TRUE,addr szrevBuf
	  close:
		invoke ShowWindow,hWnd,SW_HIDE
		;clear buffer
		xor eax,eax
		mov nBytes,eax
		lea eax,[szBuf+1]
		mov byte ptr [eax],NULL
	.ELSEIF uMsg==WM_INITDIALOG
		push FALSE
		push offset szAppName
		push hWnd
		mov eax,lpPStruct
		call [eax].ADDINPROCS.lpSetLanguage
		mov eax,lpDStruct
		push eax ;push pointer
		invoke StrLen,(ADDINDATA PTR[eax]).lpAddIn
		pop	ecx ;pop pointer
		push eax ;push stringlength
		invoke MemCopy,(ADDINDATA PTR[ecx]).lpAddIn,addr szEMFpathname,eax
		pop eax ;pop string length
		lea ecx,[szEMFpathname+eax]
		invoke MemCopy,addr szEMFilename,ecx,14
		invoke GetEnhMetaFile,offset szEMFpathname
		mov hEMF,eax
		.if eax==NULL
			invoke MessageBox,hWnd,addr szerr,NULL,MB_OK
			invoke SendMessage,hWnd,WM_DESTROY,NULL,NULL
			mov eax,0
			ret
		.endif
		xor eax,eax
		mov nBytes,eax
		mov ecx,offset szrevBuf
		mov byte ptr[ecx],NULL
		invoke LoadIcon,hInstance,IDI_ICON ;load icon from resource file
		invoke SendMessage,hWnd,WM_SETICON,NULL,eax ;tell dialog to set it's icon
	.ELSEIF uMsg==WM_SETFOCUS
		invoke RegisterHotKey,hWnd,101h,NULL,1Bh
	.ELSEIF uMsg==WM_KILLFOCUS
		invoke UnregisterHotKey,hWnd,101h
	.ELSEIF uMsg==WM_DESTROY
		invoke DeleteEnhMetaFile,hEMF
		invoke UnregisterHotKey,hWnd,101h
	.ELSEIF uMsg==WM_CLOSE
		invoke SendMessage,hWnd,WM_HOTKEY,NULL,NULL
	.ELSE
		mov eax,FALSE
		ret
	.ENDIF
	mov eax,TRUE
	ret

DlgProc endp

textOut proc lpszStr

	pushad
	push lpszStr
	mov	eax,[lpPStruct]
	call	(ADDINPROCS ptr [eax]).lpTextOut
	popad	
	ret

textOut endp

clrOut proc

	pushad
	mov	eax,[lpPStruct]
	call	(ADDINPROCS ptr [eax]).lpClearOut
	popad	
	ret

clrOut endp

;;used for debugging
hexOut proc val:DWORD

	pushad
	push	val
	mov		eax,[lpPStruct]
	call	(ADDINPROCS ptr [eax]).lpHexOut
	popad
	ret

hexOut endp

end DllEntry

