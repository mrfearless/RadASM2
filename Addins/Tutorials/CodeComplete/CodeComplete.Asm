;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include CodeComplete.inc

.code

IsLineCoInvoke proc uses esi edi,npos:DWORD

	mov		esi,offset linebuff
	mov		edi,offset szCoInvoke
	dec		esi
	mov		ecx,npos
	inc		ecx
  @@:
	dec		ecx
	je		Ex
	inc		esi
	mov		al,[esi]
	cmp		al,VK_SPACE
	je		@b
	cmp		al,VK_TAB
	je		@b
	dec		esi
	dec		edi
	inc		ecx
  @@:
	dec		ecx
	je		Ex
	inc		esi
	inc		edi
	mov		al,[edi]
	mov		ah,[esi]
;	;Not case sensitive
;	.if al>='a' && al<='z'
;		and		al,5Fh
;	.endif
;	.if ah>='a' && ah<='z'
;		and		ah,5Fh
;	.endif
	sub		ah,al
	je		@b
	.if !al && (ah==VK_SPACE || ah==VK_TAB)
		.while byte ptr [esi]==VK_SPACE || byte ptr [esi]==VK_TAB
			inc		esi
		.endw
		mov		eax,esi
	.else
		jmp		Ex
	.endif
	ret
  Ex:
	;Not found
	xor		eax,eax
	ret

IsLineCoInvoke endp

UnHook proc hWin:HWND,lpThisProc:DWORD,lpOldProc:DWORD

	invoke GetWindowLong,hWin,GWL_WNDPROC
	.if eax==lpThisProc
		;Last in chain, just unhook
		invoke SetWindowLong,hWin,GWL_WNDPROC,lpOldProc
	.else
		;Let the next in the chain unhook me
		push	RAM_UNHOOK
		push	lpOldProc
		push	lpThisProc
		push	AIM_UNHOOK
		push	hWin
		mov		eax,lpProc
		call	[eax].ADDINPROCS.lpDllProc
	.endif
	ret

UnHook endp

ShowListBox proc hWin:HWND
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	MaxX:DWORD
	LOCAL	MaxY:DWORD
	LOCAL	lbwt:DWORD
	LOCAL	lbht:DWORD
	LOCAL	lnht:DWORD

	;Get pointer to EDIT structure
	invoke GetWindowLong,hWin,0
	;Get line height
	mov		edx,[eax].EDIT.fntinfo.fntht
	add		edx,[eax].EDIT.fntinfo.linespace
	mov		lnht,edx
	;Get size of listbox
	invoke GetWindowRect,hLB,addr rect
	mov		eax,rect.right
	sub		eax,rect.left
	mov		lbwt,eax
	mov		eax,rect.bottom
	sub		eax,rect.top
	mov		lbht,eax
	;Get screen size
	invoke GetSystemMetrics,SM_CXSCREEN
	mov		MaxX,eax
	invoke GetSystemMetrics,SM_CYSCREEN
	mov		MaxY,eax
	;Get caret position
	invoke GetCaretPos,addr pt
	invoke ClientToScreen,hWin,addr pt
	;Position and show the LB
	mov		edx,lbwt
	mov		eax,pt.x
	add		eax,edx
	.if eax>MaxX
		sub		eax,MaxX
		sub		pt.x,eax
	.endif
	mov		edx,lbht
	mov		eax,pt.y
	add		eax,lnht
	add		eax,edx
	.if eax>MaxY
		add		edx,3
		sub		pt.y,edx
	.else
		mov		eax,lnht
		add		eax,3
		add		pt.y,eax
	.endif
	invoke MoveWindow,hLB,pt.x,pt.y,lbwt,lbht,TRUE
	invoke ShowWindow,hLB,SW_SHOWNOACTIVATE
	ret

ShowListBox endp

ShowToolTip proc hWin:HWND,lpszFun:DWORD,nComma:DWORD
	LOCAL	hDC:HDC
	LOCAL	pt:POINT
	LOCAL	ptW:POINT
	LOCAL	ptC:POINT

	;Get caret position
	invoke GetCaretPos,addr pt
	invoke ClientToScreen,hWin,addr pt
	;Get pointer to EDIT structure
	invoke GetWindowLong,hWin,0
	;Get line height
	mov		edx,[eax].EDIT.fntinfo.fntht
	add		edx,[eax].EDIT.fntinfo.linespace
	add		edx,3
	add		pt.y,edx
	;Set the tooltip text
	invoke SetWindowText,hTlt,lpszFun
	invoke GetDC,hTlt
	mov		hDC,eax
	invoke SendMessage,hTlt,WM_GETFONT,0,0
	invoke SelectObject,hDC,eax
	push	eax
	;Get size of all the text
	invoke lstrlen,lpszFun
	mov		edx,eax
	invoke GetTextExtentPoint32,hDC,lpszFun,edx,addr ptW
	add		ptW.x,4
	add		ptW.y,3
	;Get size of text up to the current comma
	mov		edx,lpszFun
	mov		ecx,nComma
	.while TRUE
		.if byte ptr [edx]==','
			dec		ecx
		.endif
		.break .if !ecx || byte ptr [edx]==0
		inc		edx
	.endw
	inc		edx
	push	edx
	sub		edx,lpszFun
	invoke GetTextExtentPoint32,hDC,lpszFun,edx,addr ptC
	;Adjust the tooltip position
	mov		eax,ptC.x
	sub		pt.x,eax
	invoke MoveWindow,hTlt,pt.x,pt.y,ptW.x,ptW.y,TRUE
	invoke ShowWindow,hTlt,SW_SHOWNA
	invoke UpdateWindow,hTlt
	;Draw the current parameter blue
	invoke SetBkMode,hDC,TRANSPARENT
	invoke SetTextColor,hDC,0D00000h
	pop		edx
	xor		ecx,ecx
	.while byte ptr [edx+ecx] && byte ptr [edx+ecx]!=','
		inc		ecx
	.endw
	invoke TextOut,hDC,ptC.x,0,edx,ecx
	;Restore old font
	pop		eax
	invoke SelectObject,hDC,eax
	invoke ReleaseDC,hTlt,hDC
	ret

ShowToolTip endp

Filter proc lpWord:DWORD,lpTyped:DWORD

	mov		ecx,lpWord
	mov		edx,lpTyped
  @@:
	mov		al,[ecx]
	mov		ah,[edx]
	inc		ecx
	inc		edx
	.if ah && !(ah==',' && !al)
		;Not case sensitive
		.if al>='a' && al<='z'
			and		al,5Fh
		.endif
		.if ah>='a' && ah<='z'
			and		ah,5Fh
		.endif
		sub		al,ah
		je		@b
		;Not found
		xor		eax,eax
	.else
		;Found
		mov		eax,edx
	.endif
	ret

Filter endp

MdiChildProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	pt:POINT
	LOCAL	buffer[256]:BYTE
	LOCAL	nFilter:DWORD
	LOCAL	lpFun:DWORD

	.if uMsg==WM_NOTIFY
		push	ebx
		;Get pointer to RASELCHANGE structure
		mov		ebx,lParam
		;Check if it is SEL_TEXT notification
		.if [ebx].RASELCHANGE.seltyp==SEL_TEXT
			mov		eax,[ebx].RASELCHANGE.line
			.if eax!=nLine || [ebx].RASELCHANGE.fchanged
				mov		nLine,eax
				.if fLB
					;Hide the listbox
					mov		fLB,FALSE
					invoke ShowWindow,hLB,SW_HIDE
				.endif
				.if [ebx].RASELCHANGE.fchanged
					;Get the line text
					push	esi
					push	edi
					mov		esi,[ebx].RASELCHANGE.lpLine
					mov		ecx,[esi].CHARS.len
					lea		esi,[esi+sizeof CHARS]
					mov		edi,offset linebuff
					rep movsb
					;Zero terminate line
					mov		byte ptr [edi],0
					.if byte ptr [edi-1]==VK_RETURN
						;Dont want CR
						mov		byte ptr [edi-1],0
					.endif
					mov		eax,[ebx].RASELCHANGE.chrg.cpMin
					sub		eax,[ebx].RASELCHANGE.cpLine
					invoke IsLineCoInvoke,eax
					.if eax
						mov		edi,eax
						sub		eax,offset linebuff
						mov		nPos,eax
						invoke SendMessage,hLB,LB_RESETCONTENT,0,0
						;put some text into listbox
						mov		esi,offset szSomeText
						.while byte ptr [esi]
							lea		edx,buffer
							push	esi
							.while byte ptr [esi] && byte ptr [esi]!=','
								mov		al,[esi]
								mov		[edx],al
								inc		esi
								inc		edx
							.endw
							mov		byte ptr [edx],0
							invoke Filter,addr buffer,edi
							pop		edx
							.if eax
								mov		fLB,TRUE
								mov		lpFun,edx
								movzx	eax,byte ptr [eax-1]
								mov		nFilter,eax
								invoke SendMessage,hLB,LB_ADDSTRING,0,addr buffer
								invoke SendMessage,hLB,LB_SETITEMDATA,eax,2
							.endif
							invoke lstrlen,esi
							lea		esi,[esi+eax+1]
						.endw
						invoke SendMessage,hLB,LB_GETCOUNT,0,0
						.if eax==1 && nFilter==','
							;Count commas
							mov		edx,[ebx].RASELCHANGE.chrg.cpMin
							sub		edx,[ebx].RASELCHANGE.cpLine
							xor		ecx,ecx
							xor		eax,eax
							.while ecx<edx
								.if linebuff[ecx]==','
									inc		eax
								.endif
								inc		ecx
							.endw
							push	eax
							;Set tooltip position
							invoke GetFocus
							pop		edx
							invoke ShowToolTip,eax,lpFun,edx
							mov		fTlt,TRUE
						.elseif eax
							;Set listbox position
							mov		fLB,TRUE
							invoke GetFocus
							invoke ShowListBox,eax
							invoke SendMessage,hLB,LB_SETCURSEL,0,0
							mov		fTlt,FALSE
							invoke ShowWindow,hTlt,SW_HIDE
						.endif
					.endif
					pop		edi
					pop		esi
				.endif
			.endif
		.endif
		pop		ebx
	.endif
	invoke CallWindowProc,OldMdiChildProc,hWin,uMsg,wParam,lParam
	ret

MdiChildProc endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE

	.if uMsg==WM_DRAWITEM && fLB
		push	esi
		mov		esi,lParam
		assume esi:ptr DRAWITEMSTRUCT
		.if [esi].CtlType==ODT_LISTBOX
			test	[esi].itemState,ODS_SELECTED
			.if ZERO?
				push	COLOR_WINDOW
				mov		eax,COLOR_WINDOWTEXT
			.else
				push	COLOR_HIGHLIGHT
				mov		eax,COLOR_HIGHLIGHTTEXT
			.endif
			invoke GetSysColor,eax
			invoke SetTextColor,[esi].hdc,eax
			pop		eax
			invoke GetSysColor,eax
			invoke SetBkColor,[esi].hdc,eax
			invoke SetBkMode,[esi].hdc,TRANSPARENT
			mov		eax,[esi].itemData
			mov		edx,lpHandles
			invoke ImageList_Draw,[edx].ADDINHANDLES.hTypeIml,eax,[esi].hdc,[esi].rcItem.left,[esi].rcItem.top,ILD_NORMAL
			mov		[esi].rcItem.left,18
			invoke SendMessage,[esi].hwndItem,LB_GETTEXT,[esi].itemID,addr buffer
			invoke ExtTextOut,[esi].hdc,20,[esi].rcItem.top,ETO_OPAQUE,addr [esi].rcItem,addr buffer,eax,NULL
			pop		esi
			xor		eax,eax
			ret
		.endif
		assume esi:nothing
		pop		esi
	.endif
	invoke CallWindowProc,OldWndProc,hWin,uMsg,wParam,lParam
	ret

WndProc endp

;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx,hWin:DWORD,fOpt:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0	
	mov		lpHandles,eax
	;Get handle of unsorted popup listbox
	mov		edx,[eax].ADDINHANDLES.hLBU
	mov		hLB,edx
	;Get handle of tooltip (static)
	mov		edx,[eax].ADDINHANDLES.hTlt
	mov		hTlt,edx
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax

	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax

	;Subclass mdi frame
	mov		hWnd,ebx
	invoke SetWindowLong,ebx,GWL_WNDPROC,offset WndProc
	mov		OldWndProc,eax

	; Messages to hook into
	mov		eax,RAM_CLOSE or RAM_MDIACTIVATE
	mov		ecx,RAM_UNHOOK or RAM_EDITCHAR or RAM_EDITKEYDOWN
	; EDX must be null before we return
	xor		edx,edx
	ret

InstallDll Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
; This proc handles messages sent from RadASM to our dll
; Return TRUE to prevent RadASM and other DLL's from
DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[64]:BYTE
	LOCAL	chrg:CHARRANGE

	mov		eax,uMsg
	.if eax==AIM_MDIACTIVATE
		;A new edit window is selected, reset flags and hide listbox
		xor		eax,eax
		dec		eax
		mov		nLine,eax
		mov		nPos,eax
		.if fLB
			invoke ShowWindow,hLB,SW_HIDE
			mov		fLB,FALSE
		.endif
		.if hWin
			invoke GetWindowLong,hWin,0                           ;Get editor type
			.if eax==ID_EDIT
				mov		eax,wParam
				.if eax==hWin
					.if OldMdiChildProc
						;Unsubclass the MdiChild window
						invoke SetWindowLong,wParam,GWL_WNDPROC,OldMdiChildProc
					.endif
				.else
					;Subclass the Mdi Child window
					invoke SetWindowLong,lParam,GWL_WNDPROC,offset MdiChildProc
					mov OldMdiChildProc,eax
					mov		eax,lParam
					mov		hMdi,eax
				.endif
			.endif
		.endif
	.elseif eax==AIM_CLOSE
		;Undo all subclassing
		.if OldWndProc
			invoke UnHook,hWnd,offset WndProc,OldWndProc
			mov		OldWndProc,0
		.endif
		.if OldMdiChildProc
			invoke UnHook,hMdi,offset MdiChildProc,OldMdiChildProc
			mov		OldMdiChildProc,0
		.endif
	.elseif eax==AIM_UNHOOK
		mov		eax,hWin
		mov		ecx,wParam
		mov		edx,lParam
		.if eax==hWnd && ecx==OldWndProc
			;Remove the hook from the chain
			mov		OldWndProc,edx
			mov		eax,TRUE
			jmp		Ex
		.elseif eax==hMdi && ecx==OldMdiChildProc
			;Remove the hook from the chain
			mov		OldMdiChildProc,edx
			mov		eax,TRUE
			jmp		Ex
		.endif
	.elseif eax==AIM_EDITKEYDOWN
		.if fLB
			mov		eax,lParam
			shr		eax,16
			and		eax,3FFh
			.if eax==0150h || eax==0148h || eax==0151h || eax==0149h
				invoke PostMessage,hLB,WM_KEYDOWN,wParam,lParam
				mov		eax,TRUE
				jmp		Ex
			.elseif wParam==VK_SPACE
				invoke GetKeyState,VK_CONTROL
				and		eax,80h
				push	eax
				invoke GetKeyState,VK_SHIFT
				and		eax,80h
				pop		edx
				xor		eax,edx
				.if eax
					mov		eax,TRUE
					mov		fDoIt,eax
					jmp		Ex
				.endif
			.endif
		.endif
	.elseif eax==AIM_EDITCHAR
		.if fLB
			mov		eax,wParam
			.if eax==VK_TAB || eax==VK_RETURN || fDoIt
				invoke SendMessage,hLB,LB_GETCURSEL,0,0
				.if eax!=LB_ERR
					mov		edx,eax
					invoke SendMessage,hLB,LB_GETTEXT,edx,addr buffer
					invoke lstrcat,addr buffer,addr szComma
					invoke SendMessage,hWin,EM_EXGETSEL,0,addr chrg
					invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,chrg.cpMin
					invoke SendMessage,hWin,EM_LINEINDEX,eax,0
					add		eax,nPos
					mov		chrg.cpMin,eax
					invoke SendMessage,hWin,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hWin,EM_REPLACESEL,TRUE,addr buffer
				.endif
				;Hide listbox
				mov		fLB,FALSE
				invoke ShowWindow,hLB,SW_HIDE
				xor		eax,eax
				mov		fDoIt,eax
				inc		eax
				jmp		Ex
			.elseif eax==VK_ESCAPE
				;Hide listbox
				mov		fLB,FALSE
				invoke ShowWindow,hLB,SW_HIDE
				mov		eax,TRUE
				jmp		Ex
			.endif
		.endif
 	.endif
	xor eax,eax
  Ex:
	ret

DllProc Endp

;#########################################################################

End DllEntry

