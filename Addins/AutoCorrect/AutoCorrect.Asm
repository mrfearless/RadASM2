;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Some parts of this code from sources of a nice app. Shortcut Mannager. From Roman Nowicki.  
; Only a few modifications.
;
; In fact this addin not finished yet. So, welcome bug reports, advices, praises :P really
; will glad to hear. Now working only(at least for me).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;#########################################################################
;		Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;		Include file

include AutoCorrect.inc		
 

.code

; Modifiying the original
RemoveTilde PROC caretInd:DWORD, lpszStr:DWORD

	dec eax					; zero idexed	
	mov cpos, eax			; save caret pos (zero ind. accord. to first char)
	mov eax, lpszStr
	add eax, cpos			; go to ~
	mov byte ptr[eax],0		; ~ -> 00
	inc eax
	invoke lstrcat,lpszStr,eax			

	RET
RemoveTilde ENDP


; RET: string number
LoadStringsToMem PROC stringArrAdr:DWORD, addrTable:DWORD

	mov	eax, stringArrAdr
	mov eax,[eax]				; 1.0.4
	mov indice,0
	xor	ecx, ecx

	mov edx, addrTable			; addresses array of string parts in mem
	mov [edx+ecx*4], eax		; first string address is easy ;)

another:		
	cmp byte ptr[eax], 0FFh		; another string, another address
	je	@F
	inc eax
	jmp another
@@:	
	mov byte ptr[eax],0			; FF -> 00 (terminate part of string)
	inc eax						; next char
	inc	ecx						; increase array indice
	cmp byte ptr[eax], 0		; finished?
	je  finishes	
	mov [edx+ecx*4], eax		; else get other adress

	jmp another
	 
finishes:
	mov	indice, ecx

	RET

LoadStringsToMem ENDP

; bOpen: 1(put to mem) ; 0(put to listv)
; RET : 0(ok) ; 1(empty .dat)
LoadListFromFile PROC bOpen:DWORD
LOCAL	empFile
LOCAL	text1[500]:	BYTE
LOCAL	text2[500]:	BYTE
		
		mov	empFile, 0		; file exist and not zero length

		cmp	bOpen,1			; 1.0.4
		jne	@f
		invoke RtlZeroMemory,pszOlds,4096	; init mem
		invoke RtlZeroMemory,pszNews,4096	; for a new usage
@@:			
		invoke CreateFile,addr DataFullName,GENERIC_READ+GENERIC_WRITE,FILE_SHARE_READ,0,\
				OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		mov hFile,eax
		invoke GetFileSize,eax,addr fileSize
		mov fileSize,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,fileSize
		mov pMemory,eax
		invoke ReadFile,hFile,pMemory,fileSize,ADDR SizeRW,NULL
		mov listIndex,0

		push edi
		push esi

		mov ecx,fileSize
		cmp ecx,0
		je finishopen0		; file is empty
		add ecx,1			; prepare to next loop
		push ecx
		mov esi,pMemory		; ESI = .dat
		jmp ok 				; zero text

	compare1:
		pop ecx
		dec ecx
		jz finishopen
		push ecx
		mov al,[esi]
		inc esi
		cmp al,DIVSIGN		; AL == FF ? (string ending)
		je SendString		; send to new or old
		mov [edi],al
		inc edi
		jmp compare1

; from .dat 
; recure = 1	first column
; recure = 2	

	SendString:
		cmp	bOpen,1
		jne	@F
		mov [edi],al		; end string "0xFF"
@@:			
		inc recure						
	one:
		cmp recure,1
		jne two
		cmp	bOpen,1
		jne	@F
		invoke lstrcat,pszOlds,addr text
		jmp ok
@@:		
		invoke	lstrcpy, addr text1, offset text
		jmp ok

	two:
		cmp	bOpen,1
		jne @F	
		invoke lstrcat,pszNews,addr text
		jmp pass
@@:		
		invoke	lstrcpy, addr text2, offset text

; a couple of item is ready to listv

; 1. column
		mov eax,listIndex
		mov lvi.iItem,eax
		mov lvi.iSubItem,0
		invoke	lstrcpy, offset text, addr text1
		invoke SendMessage,hList,LVM_INSERTITEM,0,addr lvi
; 2. column
		inc lvi.iSubItem	; iSubItem = 1
		invoke	lstrcpy, offset text, addr text2
		invoke SendMessage,hList,LVM_SETITEM,0,addr lvi


		inc listIndex		; iItem ++
	pass:		
		mov recure,0
	ok:
		xor eax,eax

	clearstring2:				; clear temp buffer
		mov text[eax],0			
		inc eax
		cmp eax,MAX_STRING
		jne clearstring2
		lea edi,text			; EDI = offset text
		jmp compare1

	finishopen0:
		mov empFile, 1			; file has zero length, no item to adding listv						

	finishopen:
		pop esi
		pop edi

		invoke GlobalFree,pMemory
		invoke CloseHandle,hFile
		
		mov	eax, empFile
	RET

LoadListFromFile ENDP

SaveProcedure proc
LOCAL idcolumn	:DWORD
LOCAL idvers	:DWORD

	mov eax,listIndex
	mov ecx,1000
	mul ecx
	invoke GlobalAlloc,GPTR,eax			; 1.0.4
	mov pMemory,eax
	mov idvers,0
	mov idcolumn,0
	cmp listIndex,0
	je endsave
			 
copy_to_memory:
	mov eax,idcolumn
	mov lvi.iSubItem,eax
	invoke SendMessage,hList,LVM_GETITEMTEXT,idvers,addr lvi
	invoke lstrcat,pMemory,addr text
	invoke lstrcat,pMemory,addr divstring
	cmp idcolumn,1
	je przesun_wiersz
	inc idcolumn
	jmp copy_to_memory

przesun_wiersz:
	inc idvers
	mov eax,idvers
	cmp listIndex,eax
	je endsave
	mov idcolumn,0
	jmp copy_to_memory

endsave:		
	invoke CreateFile,addr DataFullName,GENERIC_READ or GENERIC_WRITE ,\
                   FILE_SHARE_READ + FILE_SHARE_WRITE,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov hFile,eax
	invoke SetFilePointer,hFile,0,0,FILE_BEGIN
	invoke lstrlen,pMemory
	invoke WriteFile,hFile,pMemory,eax,offset SizeRW,NULL		; 1.0.4
	invoke GlobalFree,pMemory
	invoke CloseHandle,hFile
	 
	ret
SaveProcedure endp

AddMenu proc
	LOCAL	nMnu:DWORD
	LOCAL	hMnu:DWORD

	.if IDAddIn
		mov		nMnu,6
		;Adjust topmost popup if maximized.
		mov		eax,[lpData]
		mov		eax,(ADDINDATA ptr [eax]).fMaximized
		.if eax
			inc		nMnu
		.endif
		;Get handle of menu
		mov		eax,[lpHandles]
		mov		eax,(ADDINHANDLES ptr [eax]).hMenu
		;Get handle of Tools popup
		invoke GetSubMenu,eax,nMnu		;Tools menu
		mov		hMnu,eax
		;Add our menuitem
		invoke AppendMenu,hMnu,MF_STRING,IDAddIn,addr szMenuString
	.endif
	ret

AddMenu endp

InsertColumn proc
	;
	;	1. Column
	;
	mov lvc.imask,LVCF_TEXT+LVCF_WIDTH+LVCF_SUBITEM+LVCF_FMT
	mov lvc.fmt,LVCFMT_LEFT
	mov lvc.lx,120
	invoke SendMessage,hList, LVM_INSERTCOLUMN,0,addr lvc

	;
	;	2. Column
	;	
	or lvc.imask,LVCF_FMT+LVCF_WIDTH
	mov lvc.fmt,LVCFMT_LEFT
	mov lvc.lx,269
	invoke SendMessage,hList, LVM_INSERTCOLUMN, 1 ,addr lvc
	
	ret
InsertColumn endp
 
; needs indent work
; RET (EndDialog - nResult): 1(accepted) ; 0(canceled)
MultilineDlg proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetDlgItemText,hWin,EDT_MULTI,pszMulti
		mov	eax, 1
		ret
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==BTN_MULTOK
				invoke GetDlgItemText,hWin,EDT_MULTI,pszMulti,2000
				invoke EndDialog,hWin,1
			.elseif eax==BTN_MULTCAN
				invoke EndDialog,hWin,0
			.endif		
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

MultilineDlg endp

SetEditTexts PROC
	
	invoke SendMessage,hList,LVM_GETNEXTITEM,-1,LVNI_FOCUSED+LVNI_ALL
	mov lvi.iItem,eax
	
   	mov lvi.iSubItem,0
	invoke SendMessage,hList,LVM_GETITEM,0,addr lvi
	invoke SetDlgItemText,g_hDlgAuto,EDT_OLD,addr text
	
   	mov lvi.iSubItem,1
	invoke SendMessage,hList,LVM_GETITEM,0,addr lvi			 
	invoke SetDlgItemText,g_hDlgAuto,EDT_NEW,addr text
	invoke lstrcpy,pszMulti,addr text		 	
	
	RET

SetEditTexts ENDP

; Subclassed ListView (to responsing enter too)
ListWndProc PROC hListv:DWORD,uMsg:DWORD,wParam:DWORD,lparam:DWORD

	.IF uMsg==WM_GETDLGCODE
		 mov eax, DLGC_WANTALLKEYS	;DLGC_WANTTAB or DLGC_WANTARROWS ;
		 ret
	.ELSEIF uMsg==WM_KEYDOWN
		 .if wParam==VK_RETURN
		 	call	SetEditTexts	
		 .elseif wParam==VK_TAB
		 	invoke GetDlgItem,g_hDlgAuto,BTN_MULTI
		 	invoke PostMessage,g_hDlgAuto,WM_NEXTDLGCTL,eax,TRUE
		 .elseif wParam==VK_ESCAPE	
		 	invoke PostMessage,g_hDlgAuto,WM_CLOSE,0,0
		 .endif
	.elseif uMsg==WM_LBUTTONDBLCLK
		call	SetEditTexts
	.endif
		invoke CallWindowProc, OldListWndProc, hListv, uMsg, wParam, lparam
	
    ret
ListWndProc ENDP


AutoCorrectDlg proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL	lv_findinfo: 	LV_FINDINFO
LOCAL	tmpStrO[500]:	BYTE
LOCAL	tmpStrN[500]:	BYTE
LOCAL	foundItem

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke	GetDlgItem,hWin,LSV_LIST
		mov hList,eax
		
		push hWin
		pop	g_hDlgAuto
		
		invoke  SetWindowLong, eax, GWL_WNDPROC, offset ListWndProc
		mov     OldListWndProc,eax
			 	
		invoke InsertColumn
		invoke SendMessage,hList,LVM_SETEXTENDEDLISTVIEWSTYLE,\
				LVS_EX_GRIDLINES or LVS_EX_FULLROWSELECT,\
				LVS_EX_GRIDLINES or LVS_EX_FULLROWSELECT
		mov	listIndex, 0
		invoke	LoadListFromFile,0
		mov ismulti,0

; Get mem for a possible multiline usage
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,2000				
		mov pszMulti,eax
		
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==BTN_CHANGE
				invoke GetDlgItemText,hWin,EDT_OLD,addr text,MAX_STRING			; get string old
				.if eax == 0
					mov	eax, FALSE
					ret					
				.endif
				mov lv_findinfo.flags,LVFI_STRING
				mov lv_findinfo.psz,offset text
				invoke SendMessage,hList,LVM_FINDITEM,-1,addr lv_findinfo		; search in listv
				mov lvi.iItem,eax				
				.if eax != -1			; if found
					mov foundItem, eax
					invoke lstrcpy,addr tmpStrO, addr text										
					invoke GetDlgItemText,hWin,EDT_NEW,addr tmpStrN,MAX_STRING
					.if eax == 0
						mov		eax,FALSE
						ret					
					.endif												
					mov lvi.iSubItem,1
					invoke SendMessage,hList,LVM_GETITEMTEXT,lvi.iItem,addr lvi	; get sub item
					invoke lstrcmp,lvi.pszText, addr tmpStrN					; compare
					.if eax != 0		; if not equal														
						invoke lstrcpy,addr text,addr tmpStrN
						push foundItem
						pop  lvi.iItem
						mov  lvi.iSubItem,1						
						invoke SendMessage,hList,LVM_SETITEM,0,addr lvi			; replace newer				
					.endif
				.else					; both are not exist, add them
					push listIndex		; get next position
					pop  lvi.iItem		; to struct
					invoke GetDlgItemText,hWin,EDT_OLD,addr text,MAX_STRING		; get another old
					.if eax == 0
						mov		eax,FALSE
						ret					
					.endif					
					mov lvi.iSubItem,0		
					invoke SendMessage,hList,LVM_INSERTITEM,0,addr lvi			; add another old
					
					invoke GetDlgItemText,hWin,EDT_NEW,addr text,MAX_STRING 	; get another new												
					.if eax == 0
						mov		eax,FALSE
						ret					
					.endif
					inc lvi.iSubItem		
					invoke SendMessage,hList,LVM_SETITEM,0,addr lvi				; add another new

					inc listIndex												; appoint next place												
				.endif	
			.elseif eax==BTN_DELETE
				.if listIndex!=0
					invoke SendMessage,hList,LVM_GETNEXTITEM,-1,LVNI_FOCUSED
					.if eax!=-1
						invoke SendMessage,hList,LVM_DELETEITEM,eax,0
						dec listIndex
					.endif
				.endif			
			.elseif eax==BTN_OK
				invoke 	SaveProcedure										; save to .dat 
				invoke	LoadListFromFile,1									; prepare mem again
				.if eax==0						; 0 = OK												
					invoke  LoadStringsToMem,addr pszOlds,addr AddrTableOld	; get olds to mem
					invoke  LoadStringsToMem,addr pszNews,addr AddrTableNew	; get news to mem
				.endif				
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==BTN_CANCEL || eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==BTN_MULTI
				invoke DialogBoxParam,hInstance,DLG_MULT,hWin,addr MultilineDlg,0
				mov	ismulti, eax
				.if ismulti
					invoke SetDlgItemText,hWin,EDT_NEW,pszMulti
				.endif				
			.endif
		.endif
	.elseif eax==WM_CLOSE
		;	Free multi's
		;		
		invoke GlobalFree,pszMulti
		; remove the subclass
		invoke SetWindowLong,hList,GWL_WNDPROC,OldListWndProc
		; and then...		
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

AutoCorrectDlg endp

;#########################################################################

; 1. gets prior tabs+spaces (szSpacesnTabs)
; 2. gets indice in addr table -if any- string snippet (AddrTableOld)
; poz : caret pos		
; RET: caret pos from first col. (-1 : if word not found in listv)
DealWithBeforeSpace proc uses esi, poz:DWORD
LOCAL	buffer[300]:BYTE

	mov countSPTB,0				; init 
	mov	esi, offset szLine
	mov	eax, esi
	add eax, poz 				; EAX = caret pos
	mov	byte ptr[eax], 0
	dec eax						; step back from NULL	 	
 	
	.while eax >= esi
		mov dl, byte ptr[eax]		
		.break .if dl == VK_SPACE || dl == VK_TAB 				
		dec eax
	.endw
 
	inc eax					; pass last space or tab 
	push eax				; save beginning of last word's addr
	
	invoke lstrcpy,addr buffer,eax

	;
	; Ready for a compare
	; conserve ESI - EBX

	xor	ecx, ecx							; addr table indice
	 	 	
	.while ecx <= indice 					; 
		mov	eax, offset AddrTableOld
		mov edx, dword ptr [eax+ecx*4]		; EDX = AddrTableOld[ecx]
		mov tmpIndice, ecx					; appoint new(will replace) string indice(or save temp.)

		invoke lstrcmp,addr buffer,edx		; is this same as last word?
		.if !eax							; if eq, this is a word in keyw list		
; get all spaces & tabs till first alfanumeric char. For a possible multiline indent
			invoke lstrcpy,addr szSpacesnTabs,addr emptystring	; first init for current string
			push edi						; save edi
			mov edi, offset szSpacesnTabs	; edi as szSpacesnTabs
			mov al, byte ptr[esi]
			.while al == VK_SPACE || al == VK_TAB
				mov	byte ptr[edi], al
				inc esi						; switch to next char
				inc edi						; next place
				mov al, byte ptr[esi]		; get another
				inc countSPTB				; inc space or tab count
			.endw
			mov	byte ptr[edi], 0			; terminate string
			pop	edi							; restore edi	
			pop eax							; restore last word's addr			
			mov	esi, offset szLine		
			sub eax, esi					; eax : how much far the caret form first(0.) column			
			ret
		.endif
		mov ecx, tmpIndice					; restore table indice
		inc ecx
	.endw
	pop eax									; restore stack
	xor	eax,eax								; any fitting
	dec eax									; return -1
					
	RET

DealWithBeforeSpace ENDP

; sorry for so plenty of crap. But i couldn't find a solution yet for ignoring space char in RAEdit
; In a single not a big problem but if ~ in next line, after paste indented string, space char
; is spoiling the order. I had to separate these situations. So welcome suggestions.
PrepareToReplace PROC uses esi edi, pIndexedString:DWORD

	mov esi, offset tempBuffer
	invoke lstrcpy,esi,pIndexedString		; 1.0.4 (preserve original in mem)
	mov cpos,0								; init cpos
	
; first prepare the single line but has ~ char	
	invoke InString,1,esi,offset szCRLF		; is including cr+lf
	.if !eax								; if has no cr+lf(single line, simple str)
		invoke InString,1,esi,offset szTilde; is includes ~ 
		.if eax >= 1
			invoke RemoveTilde,eax,esi		; find ~ index, remove and use another buf 
;			mov esi, offset cbuf			; then use this string(w/o '~')
		.endif
	.else									; has cr+lf
; now prepare the multilines. First ready for indent, later remove ~, also learn caret pos choice.
; ready to indent	
		mov bMult,1							; sign as multiline
		invoke lstrcpy,addr sztmpMulti,addr emptystring
		mov edi, offset sztmpMulti
		.while byte ptr[esi] != 0			; until new string finished
			mov	al, byte ptr[esi]			; get a char from new(as in listv)
			.if al == 10					; if linefeed							
				mov byte ptr[edi],al		; concat LF to prev. string
				mov byte ptr[edi+1],0		; null (temp. terminate sztmpMulti)
				invoke lstrcat,addr sztmpMulti,addr szSpacesnTabs	; after cr+lf add indent spaces
				add edi, countSPTB			; jump over spaces+tabs									
			.else							; if not a LF(10)
				mov byte ptr[edi],al		; only concat to previous string						  					
			.endif	
			inc esi							; switch next char
			inc edi							; prepare to next
		.endw
		mov byte ptr[edi],0					; 1.0.4 (terminate whole string)
		mov	esi, offset sztmpMulti			; use the latest string(added indent)

; Now, if any, remove ~ ,also learn caret pos choice					
		invoke InString,1,esi,offset szTilde	; is this includes '~'
		.if eax >= 1
			invoke RemoveTilde,eax,esi			; then remove ~ and put it in a new buffer(cbuf)
;			mov esi, offset cbuf				; if ~ processed, new string is cbuf(ESI)
		.endif					
	.endif ; multis			

	mov eax, esi
 													 		
	RET
	
PrepareToReplace ENDP

RAEditProc proc uses ebx, hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL toStartOfThisLine,lineLen,nLine
LOCAL sel:	CHARRANGE

	mov eax,uMsg

	.if eax==WM_CHAR	;WM_KEYDOWN
		mov  edx,wParam
		.if edx == VK_SPACE
			mov bMult,0
			mov ebx,lpHandles
			invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_EXGETSEL,0,addr sel
			invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_LINELENGTH,sel.cpMin,0	; length of line 
			inc eax					
			mov lineLen,eax			; leading spaces, tabs count included
			invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_EXLINEFROMCHAR,0,sel.cpMin ; line index 
			mov nLine,eax			; nLine : bu satýr
			invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_LINEINDEX,nLine,0		; length until this line
			mov toStartOfThisLine, eax
			
			mov	eax,offset szLine			; first WORD max. len 
			mov	word ptr [eax], 300			; let it 300
			invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_GETLINE,nLine,addr szLine ; get whole line				
			mov	eax,sel.cpMin				; EAX = until caret
			sub eax,toStartOfThisLine		; EAX = first column to caret									
			invoke DealWithBeforeSpace, eax
			.if eax != -1					; -1 : not found in list. Else;
				add eax, toStartOfThisLine	; eax : from (0,0) to prior to word before caret
				mov startofw, eax
				invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_SETSEL,eax,sel.cpMin ; select last word
				mov	ecx, tmpIndice  							
				mov	eax, AddrTableNew[ecx*4]; get the string as listv
 												
				invoke PrepareToReplace,eax

; Now, EAX has a string addr. And it's indented(if req), '~' removed, cpos is caret addr.								 				
													
				invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_REPLACESEL,TRUE,eax  	; replace
				.if cpos					; if string needs caret positioning (~) 
					mov eax, startofw		; starting pos of keyword(if is) string
					add eax, cpos			; add this ~ pos
					.if bMult				; if was a mult
						dec eax				; really dont know why needs :P maybe later. Now i finished.
					.endif	
 					invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_SETSEL,eax,eax 		; set caret pos
; Comment below tree lines to allowing space char after paste. Thanks to KetilO. 					
 					invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_SCROLLCARET,0,0		; This tree lines are	
 					xor eax, eax														; to prevent the
 					ret																	; space char after
				.endif																	; replacing.
			.endif ; if an exist keyword			
		.endif ; vk_space
	.endif ; wm_keydown
	invoke CallWindowProc,OldEditProc1,hWnd,uMsg,wParam,lParam
case:
	ret
RAEditProc endp
   																							
;#########################################################################
;		Common AddIn Procedures

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntry Endp

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD

	mov	ebx,hWin

	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0
	mov	lpHandles,eax
	
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov	lpProc,eax

	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov	lpData,eax

	invoke InitCommonControls
	
	; Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov IDAddIn,eax
	call AddMenu							; 1.0.1
	
	; Messages to hook into
	mov	eax, RAM_COMMAND OR RAM_CLOSE OR RAM_PROJECTOPENED OR RAM_PROJECTCLOSE OR RAM_MDIACTIVATE OR RAM_MENUREBUILD OR RAM_INITMENUPOPUP
	mov ecx, RAM_UNHOOK

	; EDX must be null before we return
	xor edx, edx
	ret 

InstallDll Endp

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

; Export this proc (it is autoexported if MakeDef is enabled with option 2)
DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	; This proc handles messages sent from RadASM to our dll
	; Return TRUE to prevent RadASM and other DLL's from

	mov	eax, uMsg		    				
	.if eax == AIM_COMMAND
		mov eax,wParam
		movzx edx,ax
		shr eax, 16
		.if edx == IDAddIn && eax == BN_CLICKED
			; Your addin has been selected
			mov	eax, lpHandles
			mov	eax, [eax].ADDINHANDLES.hWnd		; Get the parent handle
			invoke DialogBoxParam,hInstance,DLG_CORRECT,eax,offset AutoCorrectDlg,NULL
			mov		eax,TRUE
			jmp		Ex
		.endif
	.elseif eax==AIM_UNHOOK
		mov		eax,hWin
		mov		ecx,wParam
		mov		edx,lParam
		.if eax==hEdt1 && ecx==OldEditProc1
			;Remove the hook from the chain
			mov		OldEditProc1,edx
			mov		eax,TRUE
			jmp		Ex
		.elseif eax==hEdt2 && ecx==OldEditProc2
			;Remove the hook from the chain
			mov		OldEditProc2,edx
			mov		eax,TRUE
			jmp		Ex
		.endif
	.elseif eax==AIM_CLOSE
		;Undo subclassing
		.if OldEditProc1
			invoke UnHook,hEdt1,offset RAEditProc,OldEditProc1
			mov		OldEditProc1,0
		.endif
		.if OldEditProc2
			invoke UnHook,hEdt2,offset RAEditProc,OldEditProc2
			mov		OldEditProc2,0
		.endif
		mov edx,lpHandles
		invoke DeleteMenu,[edx].ADDINHANDLES.hMenu,IDAddIn,MF_BYCOMMAND
		mov	IDAddIn,0		
	.elseif eax==AIM_MENUREBUILD
		invoke AddMenu
	.elseif eax==AIM_INITMENUPOPUP
		mov eax, lpData
		mov eax, [eax].ADDINDATA.fProject
		;Enable/disable the menuitem
		mov	edx,MF_GRAYED
		.if eax
			mov	edx,MF_ENABLED
		.endif
		mov		eax,[lpHandles]
		mov		eax,(ADDINHANDLES ptr [eax]).hMenu
		invoke EnableMenuItem,eax,IDAddIn,edx
	.elseif eax==AIM_MDIACTIVATE
		;A new mdi window is selected
		.if hWin
			invoke GetWindowLong,hWin,0                     ;Get editor type
			.if eax==ID_EDIT
				mov		eax,wParam
				.if eax==hWin
					.if OldEditProc1
						;Unsubclass the RAEdit windows
						invoke UnHook,hEdt1,offset RAEditProc,OldEditProc1
						invoke UnHook,hEdt2,offset RAEditProc,OldEditProc2
						xor eax, eax
						mov OldEditProc1,eax				;Set as unhooked
						mov OldEditProc2,eax				;Set as unhooked
					.endif
				.else
					;Subclass the RAEdit child windows
					invoke GetWindowLong,lParam,GWL_USERDATA
					invoke GetWindowLong,eax,0
					mov		edx,[eax].EDIT.edta.hwnd
					mov		hEdt1,edx
					mov		edx,[eax].EDIT.edtb.hwnd
					mov		hEdt2,edx
					invoke SetWindowLong,hEdt1,GWL_WNDPROC,offset RAEditProc
					mov OldEditProc1,eax
					invoke SetWindowLong,hEdt2,GWL_WNDPROC,offset RAEditProc
					mov OldEditProc2,eax
				.endif
			.endif
		.endif
	.elseif eax==AIM_PROJECTOPENED
		mov eax, lpData								; Get RadAsm path	1.0.2
		mov eax, (ADDINDATA ptr[eax]).lpAddIn		; eax = path ( w/o ending "\" ) 
		invoke lstrcpy,offset DataFullName,eax		; x:\..\RadAsm\Addins
		invoke lstrcat,offset DataFullName,offset BackSlash
		mov eax, lpData
		invoke lstrcat,offset DataFullName,addr (ADDINDATA ptr[eax]).szAssembler
		invoke lstrcat,offset DataFullName,offset DataFileName	; x:\..\RadAsm\Addins\masmAutoCorrect.dat
		
;--- olds
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4096
		mov pszOlds,eax
;--- news
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4096
		mov pszNews,eax
		invoke	LoadListFromFile,1
		.if eax==0					; 0 = OK (if .dat exist and has strings)						
			invoke  LoadStringsToMem,addr pszOlds,addr AddrTableOld
			invoke  LoadStringsToMem,addr pszNews,addr AddrTableNew
		.endif	
	.elseif eax == AIM_PROJECTCLOSE			
		;	Free News
		;
		invoke GlobalFree,pszNews
		;	Free Olds
		;		
		invoke GlobalFree,pszOlds		
	.endif

	mov eax,FALSE 
  Ex:
	ret
DllProc Endp
	
;#########################################################################

End DllEntry
    