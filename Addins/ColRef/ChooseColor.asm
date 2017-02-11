PicBtnProc PROC hMenuI:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	;Subclassed PicColor button
	
	.if uMsg==WM_LBUTTONDOWN
;		mov eax,wParam
;		invoke SetDlgItemText,hCCDlg,IDC_BTN5,SADD('End Capture')
		invoke LoadCursor,hInstance,IDR_PICCUR
		invoke SetCursor,eax
		invoke InstallHook
		invoke CallWindowProc,OldWndProc,hPic,uMsg,eax,lParam
		ret
		
	.elseif uMsg==WM_LBUTTONUP
		mov eax,wParam
;		invoke SetDlgItemText,hCCDlg,IDC_BTN5,SADD('Capture')
		
		invoke LoadCursor,hInstance,IDC_ARROW
		invoke SetCursor,eax
		invoke UninstallHook

		test fOption,2 ;Disable color flashing set color at end
		je @F
		xor eax,eax
		mov al,byte ptr [Dcolor + 2]
		push eax
		invoke wsprintf,addr colref,SADD('%ld')
		invoke SetDlgItemText,hCCDlg,708,addr colref
		mov al,byte ptr [Dcolor + 1]
		push eax
		invoke wsprintf,addr colref,SADD('%ld')
		invoke SetDlgItemText,hCCDlg,707,addr colref
		mov al,byte ptr Dcolor
		push eax
		invoke wsprintf,addr colref,SADD('%ld')
		invoke SetDlgItemText,hCCDlg,706,addr colref
	@@:
		
		invoke CallWindowProc,OldWndProc,hPic,uMsg,eax,lParam
		ret
		
	.else
		invoke CallWindowProc,OldWndProc,hPic,uMsg,wParam,lParam
		ret
		
	.endif
	xor eax,eax
	ret
PicBtnProc endp

CCHookProc PROC hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	LOCAL hDC			:DWORD
	LOCAL color			:dword
	LOCAL lpPoint		:POINT
	LOCAL hwnd			:dword
	LOCAL rVal			:DWORD
	LOCAL gVal			:DWORD
	LOCAL bVal			:DWORD
	LOCAL rect			:RECT
	LOCAL times			:dword

	.IF uMsg == WM_CTLCOLORDLG
		mov eax,wParam
		mov hDC,eax
		mov eax,hBrush
		ret

	.ELSEIF uMsg == WM_CTLCOLORSTATIC
		mov eax,wParam
		mov hDC,eax
		invoke SetTextColor,hDC,0
		invoke SetBkColor,hDC,Dialogcolor
		mov eax,hBrush
		ret

	.elseif uMsg==WM_INITDIALOG
		push	TRUE
		push	offset szColref
		push	hWin
		mov		eax,lpPStruct
		call	[eax].ADDINPROCS.lpSetLanguage
		mov eax,hWin
		mov hCCDlg,eax
		invoke LoadIcon,hInstance,IDR_ICON
		invoke SendMessage,hCCDlg,WM_SETICON,NULL,eax

		mov eax,lParam
		mov pCHOOSECOLOR,eax
		
		;Make the dialog topmost
		invoke SetWindowPos,hCCDlg,HWND_TOPMOST,dlgpos.x,dlgpos.y,0,0,SWP_SHOWWINDOW or SWP_NOSIZE; or SWP_NOMOVE
		
		;Subclass the PicColor button
		invoke GetDlgItem,hWin,IDC_BTN5
		mov hPic,eax
		invoke SetWindowLong,hPic,GWL_WNDPROC,addr PicBtnProc
		mov OldWndProc,eax
;		invoke SendMessage,hCCDlg,WM_SETTEXT,0,ADDR szAppTitle

	.elseif uMsg==WM_LBUTTONUP
		invoke GetCursorPos,ADDR lpPoint
		invoke ScreenToClient,hCCDlg,ADDR lpPoint
		invoke ChildWindowFromPoint,hCCDlg,lpPoint.x,lpPoint.y
		push eax
		invoke GetDlgItem,hCCDlg,710
		pop ecx
		.IF eax==ecx
			invoke SetDlgItemInt,hCCDlg,705,120,FALSE
		.ENDIF
		
	.elseif uMsg==WM_MOUSEHOOK
		;Pic color
		invoke GetCursorPos,addr lpPoint
		;invoke WindowFromPoint,lpPoint.x,lpPoint.y
		;mov hwnd,eax
		;invoke ScreenToClient,hwnd,addr lpPoint
		invoke GetDC,0 ;,hwnd
		invoke GetPixel,eax,lpPoint.x,lpPoint.y
		mov color,eax
		mov Dcolor,eax
		invoke Colors,eax
		
		;Write pic color to common dialog
		test fOption,2 ;Disable color flashing
		jne @F
		xor eax,eax
		mov al,byte ptr [color + 2]
		push eax
		invoke wsprintf,addr colref,SADD('%ld')
		invoke SetDlgItemText,hCCDlg,708,addr colref
		mov al,byte ptr [color + 1]
		push eax
		invoke wsprintf,addr colref,SADD('%ld')
		invoke SetDlgItemText,hCCDlg,707,addr colref
		mov al,byte ptr color
		push eax
		invoke wsprintf,addr colref,SADD('%ld')
		invoke SetDlgItemText,hCCDlg,706,addr colref
	@@:

	.elseif uMsg==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if (eax==IDC_BTN1 || eax==IDC_BTN2 || eax==IDC_BTN3);Insert buttons
				.IF eax==IDC_BTN1 ;insert RGB
					invoke GetDlgItemText,hCCDlg,IDC_EDT1,offset szString,12
				.elseif eax==IDC_BTN2 ;insert hex value
					invoke GetDlgItemText,hCCDlg,IDC_EDT2,offset szString,12
				.elseif eax==IDC_BTN3 ;insert decimal value
					invoke GetDlgItemText,hCCDlg,IDC_EDT3,offset szString,12
				.endif

				mov eax,lpHStruct
				invoke SendMessage,[eax].ADDINHANDLES.hEdit,EM_REPLACESEL,TRUE,offset szString
				invoke PostMessage,hCCDlg,WM_COMMAND,IDABORT,NULL
				
			.elseif eax==IDC_BTN4 ;Color ref button
				invoke SetDlgItemText,hCCDlg,IDC_EDT1,0
				invoke SetDlgItemText,hCCDlg,IDC_EDT2,0
				invoke SetDlgItemText,hCCDlg,IDC_EDT3,0
				mov eax,lpHStruct
				mov eax,[eax].ADDINHANDLES.hEdit
				push eax
				mov eax,[lpPStruct]
				mov eax,(ADDINPROCS ptr [eax]).lpGetWordFromPos
				call	eax
				invoke ParseInput,eax
				invoke SelectToDialog,eax
				
			.elseif eax==1 ;OK button
				invoke GetDlgItemInt,hCCDlg,706,NULL,FALSE
				mov rVal,eax
				invoke GetDlgItemInt,hCCDlg,707,NULL,FALSE
				mov gVal,eax
				invoke GetDlgItemInt,hCCDlg,708,NULL,FALSE
				mov bVal,eax

				xor eax,eax
				mov edx,bVal
				mov al,dl
				shl eax,8
				mov edx,gVal
				mov al,dl
				shl eax,8
				mov edx,rVal
				mov al,dl
				invoke Colors,eax

			.else
				mov eax,0
				ret
			.endif

			mov eax,TRUE
			ret
		.endif
	.elseif uMsg==WM_MOVE
		invoke GetWindowRect,hWin,addr rect
		mov	eax,rect.left
		mov dlgpos.x,eax
		mov	eax,rect.top
		mov dlgpos.y,eax
	.ENDIF

	mov eax,0
	ret

CCHookProc ENDP