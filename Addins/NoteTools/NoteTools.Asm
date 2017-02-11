;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include NoteTools.inc

.code

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx edi esi hWin:DWORD, fOpt:DWORD
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

	mov eax,lpHandles
	mov eax,[eax].ADDINHANDLES.hPrpLst
	mov hPrpLst,eax

	mov eax, fOpt
	mov Options,eax

	.IF Options & 8
		mov eax,lpHandles
		mov eax,[eax].ADDINHANDLES.hToolBar
		invoke SendMessage,eax,TB_GETTOOLTIPS,0,0
		push eax
		invoke SendMessage,eax,TTM_GETTIPBKCOLOR,0,0
		mov DefTipColor,eax
		pop eax
		invoke SendMessage,eax,TTM_SETTIPBKCOLOR,008AF3F9h,0

		mov eax,lpHandles
		mov eax,[eax].ADDINHANDLES.hPrpTbr
		invoke SendMessage,eax,TB_GETTOOLTIPS,0,0
		invoke SendMessage,eax,TTM_SETTIPBKCOLOR,008AF3F9h,0

		mov eax,lpHandles
		mov eax,[eax].ADDINHANDLES.hPbrTbr
		invoke SendMessage,eax,TB_GETTOOLTIPS,0,0
		invoke SendMessage,eax,TTM_SETTIPBKCOLOR,008AF3F9h,0
	.ENDIF

	.IF Options & 1
		invoke CreateBuffer
		invoke SetWindowLong,hPrpLst,GWL_WNDPROC,OFFSET ListBoxSubClass
		mov OldLBProc,eax
		invoke CreateToolTip

		invoke SendMessage, hWin, AIM_GETMENUID, 0, 0
		mov IDAddIn, eax
		mov eax, lpHandles
		invoke GetSubMenu,[eax].ADDINHANDLES.hToolMenu,4
		mov hSubMenu,eax
		invoke AppendMenu,hSubMenu,MF_SEPARATOR,NULL,NULL
		invoke AppendMenu,hSubMenu,MF_STRING OR MF_DISABLED OR MF_GRAYED,IDAddIn,OFFSET szMenuText
		mov eax, RAM_COMMAND OR RAM_PROJECTOPENED OR RAM_CONTEXTMENU OR RAM_CLOSE
	.ELSE
		mov eax,NULL
	.ENDIF

	; ECX and EDX must be null before we return
	xor ecx, ecx
	xor edx, edx
	ret 

InstallDll Endp

CreateBuffer Proc
	
	invoke GetProcessHeap
	mov hHeap,eax
	invoke HeapAlloc,hHeap,NULL,4096
	mov pProcName,eax
	ret

CreateBuffer endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc uses esi edi ebx hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	LOCAL pt			:POINT
	LOCAL ti			:TOOLINFO

	mov eax,uMsg
	.IF eax==AIM_PROJECTOPENED
		mov eax,lpData
		mov eax,[eax].ADDINDATA.lpProject
		invoke lstrcpy,OFFSET CmtFile,eax
		invoke StrLen,OFFSET CmtFile
		add eax,OFFSET CmtFile
		sub eax,4
		mov [eax],BYTE PTR 0
		invoke lstrcat,OFFSET CmtFile,OFFSET szCmtFileExt

	.ELSEIF eax==AIM_COMMAND
		mov eax, wParam
		movzx eax,ax
		.IF eax==IDAddIn
			mov eax,pProcName
			mov eax,[eax]
			.IF al != 0
				; ProcName was found edit comment
				mov eax,lpHandles
				mov eax,[eax].ADDINHANDLES.hWnd
				invoke DialogBoxParam,hInstance,1000,eax,OFFSET DlgProc,NULL

			.ENDIF
			xor	eax,eax
			inc	eax
			ret
		.ENDIF

	.ELSEIF eax==AIM_CONTEXTMENU
		invoke GetCursorPos,ADDR pt
		invoke WindowFromPoint,pt.x,pt.y
		; Make sure that this is the properties listbox
		.IF eax==hPrpLst
			; Check to see if a project is loaded
			mov eax,lpData
			mov eax,[eax].ADDINDATA.fProject
			.IF eax==TRUE
				invoke EnableMenuItem, hSubMenu, IDAddIn, MF_BYCOMMAND OR MF_ENABLED
				; Get the proc name before the menu appears
				invoke GetItemName,pProcName
			.ENDIF
		.ENDIF

	.ELSEIF eax == AIM_CLOSE
		.IF Options & 2
			invoke SendMessage,hToolTip,TTM_SETTIPBKCOLOR,DefTipColor,0
		.ENDIF

		.IF Options & 1
			mov ti.cbSize,SIZEOF TOOLINFO
			mov ti.uFlags,TTF_IDISHWND or TTF_SUBCLASS
			mov eax,hPrpLst
			mov ti.hWnd,eax
			mov ti.uId,eax
			mov eax,hInstance
			mov ti.hInst,eax
			mov ti.lpszText,LPSTR_TEXTCALLBACK
			invoke SendMessage,hToolTip,TTM_DELTOOL,0,ADDR ti

			invoke SetWindowLong,hPrpLst,GWL_WNDPROC,OldLBProc
			invoke HeapFree,hHeap,NULL,pProcName

			mov eax, lpHandles
			invoke GetSubMenu,[eax].ADDINHANDLES.hToolMenu,4
			mov hSubMenu,eax
			invoke GetMenuItemCount,hSubMenu
			mov esi,eax
			; Find the position of the menu item
			xor edi,edi
			.REPEAT
				invoke GetMenuItemID,hSubMenu,edi
				.BREAK .IF eax == IDAddIn
				inc edi
			.UNTIL edi == esi
			dec edi
			invoke DeleteMenu,hSubMenu,edi,MF_BYPOSITION
			invoke DeleteMenu,hSubMenu,IDAddIn,MF_BYCOMMAND

			invoke DestroyWindow,hToolTip
		.ENDIF

		.IF Options & 8
			mov eax,lpHandles
			mov eax,[eax].ADDINHANDLES.hToolBar
			invoke SendMessage,eax,TB_GETTOOLTIPS,0,0
			invoke SendMessage,eax,TTM_SETTIPBKCOLOR,DefTipColor,0

			mov eax,lpHandles
			mov eax,[eax].ADDINHANDLES.hPrpTbr
			invoke SendMessage,eax,TB_GETTOOLTIPS,0,0
			invoke SendMessage,eax,TTM_SETTIPBKCOLOR,DefTipColor,0
	
			mov eax,lpHandles
			mov eax,[eax].ADDINHANDLES.hPbrTbr
			invoke SendMessage,eax,TB_GETTOOLTIPS,0,0
			invoke SendMessage,eax,TTM_SETTIPBKCOLOR,DefTipColor,0
		.ENDIF

	.ENDIF
	xor	eax,eax
	ret
DllProc Endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

;#########################################################################
;		AddIn Procedures

ListBoxSubClass PROC uses ebx hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	.if uMsg == WM_NOTIFY
		mov ebx, lParam
		mov eax,[ebx].NMHDR.code
		.if eax ==  TTN_NEEDTEXT
			invoke GetItemName,pProcName
			.IF !eax
				invoke GetIniText,pProcName
				mov [ebx].TOOLTIPTEXT.lpszText,OFFSET CmtStr
				invoke SendMessage,hToolTip,TTM_SETTITLE,1,pProcName
			.ENDIF
		.endif

	.elseif uMsg == WM_MOUSEMOVE
		invoke SendMessage,hPrpLst,LB_ITEMFROMPOINT,0,lParam

		.IF eax != OldItem
			mov OldItem,eax
			invoke SendMessage,hToolTip,TTM_ACTIVATE,FALSE,0
			invoke SendMessage,hToolTip,TTM_ACTIVATE,TRUE,0
		.ENDIF
	.endif
	invoke CallWindowProc,OldLBProc,hWin,uMsg,wParam,lParam

	RET
ListBoxSubClass ENDP

CreateToolTip proc
	LOCAL ti			:TOOLINFO

	invoke SetLastError,0
	invoke CreateWindowEx,0,OFFSET szToolTipClass,OFFSET szToolTipClass,TTS_NOPREFIX,0,0,0,0,hPrpLst,0,hInstance,0
	mov hToolTip,eax

	invoke SendMessage,hToolTip,TTM_ACTIVATE,TRUE,0
	invoke SendMessage,hToolTip,TTM_SETDELAYTIME,TTDT_AUTOMATIC,500
	invoke SendMessage,hToolTip,TTM_SETMAXTIPWIDTH,0,150

	.IF Options & 2
		invoke SendMessage,hToolTip,TTM_SETTIPBKCOLOR,008AF3F9h,0
	.ENDIF

	.IF Options & 4
		invoke SendMessage,hToolTip,TTM_SETTITLE,1,OFFSET szAppName
	.ENDIF

	mov ti.cbSize,SIZEOF TOOLINFO
	mov ti.uFlags,TTF_IDISHWND or TTF_SUBCLASS
	mov eax,hPrpLst
	mov ti.hWnd,eax
	mov ti.uId,eax
	mov eax,hInstance
	mov ti.hInst,eax
	mov ti.lpszText,LPSTR_TEXTCALLBACK
	invoke SendMessage,hToolTip,TTM_ADDTOOL,0,ADDR ti

	ret
CreateToolTip endp

GetItemName PROC uses edi ecx lpProcName:DWORD
	LOCAL pt			:POINT

	mov edi,lpProcName
	mov	dword ptr [edi],0
	; Get the current cursor position
	invoke GetCursorPos,ADDR pt
	invoke ScreenToClient,hPrpLst,ADDR pt
	; Make an lParam from the POINT structure
	mov eax,pt.y
	shl eax,16 ; We only care about Y
	invoke SendMessage,hPrpLst,LB_ITEMFROMPOINT,0,eax
	; Check the high order word without trashing eax
	test	eax,0FFFF0000h
	; If there is no item we're done
	jne @@AllDone
	invoke SendMessage,hPrpLst,LB_GETTEXT,eax,lpProcName
	; Truncate the name at the first tab
	@@:
	inc edi
	mov al,[edi]
	or	al,al
	je	@F
	cmp al,9
	jne @B
	@@:
	mov [edi],BYTE PTR 0
	; the proc name is now in lpbuffer return 0
	xor	eax,eax
	@@AllDone:
	RET
GetItemName ENDP

DlgProc proc uses ebx hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	.IF uMsg==WM_INITDIALOG
		mov eax,hWin
		mov hEditDlg,eax
		invoke GetIniText,pProcName
		invoke SetDlgItemText,hEditDlg,1001,OFFSET CmtStr

	.ELSEIF uMsg==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.IF edx==BN_CLICKED
			.IF eax==IDOK
				invoke SetIniText,pProcName
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.ELSEIF eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.ENDIF
		.ENDIF

	.ELSEIF uMsg==WM_CLOSE
		invoke EndDialog,hWin,0

	.ELSE
		mov eax,FALSE
		ret
	.ENDIF

	mov eax, TRUE
	ret

DlgProc endp

GetIniText Proc lpProcName:DWORD
	mov eax,lpHandles
	mov eax,[eax].ADDINHANDLES.hPrpCbo
	invoke SendMessage,eax,WM_GETTEXT,15,OFFSET EditText
	invoke GetPrivateProfileString,OFFSET EditText,lpProcName,OFFSET szDefault,OFFSET CmtStr,127,OFFSET CmtFile
	ret
GetIniText ENDP

SetIniText Proc lpProcName:DWORD
	mov eax,lpHandles
	mov eax,[eax].ADDINHANDLES.hPrpCbo
	invoke SendMessage,eax,WM_GETTEXT,15,OFFSET EditText
	invoke GetDlgItemText,hEditDlg,1001,OFFSET CmtStr,127
	.IF eax !=0
		invoke WritePrivateProfileString,OFFSET EditText,lpProcName,OFFSET CmtStr,OFFSET CmtFile
	.ELSE
		invoke WritePrivateProfileString,OFFSET EditText,lpProcName,NULL,OFFSET CmtFile
	.ENDIF
	ret
SetIniText ENDP

;#########################################################################

End DllEntry
