TextOutput proto :dword

.data?
dd? hCtLb,OldLbProc,hFnt1,pCtLbStream,CtLbWidth,CtLbHeight

.data
Arial_8 LOGFONT <-11,0,0,0,700,0,0,0,-18,3,2,1,34,"Arial">

.code
CtLbErrMsg proc pszText
	mov eax,pAddinHandles
	invoke MessageBox,[eax].ADDINHANDLES.hWnd,pszText,T('CodeTemplates Addin Error'),MB_OK or MB_ICONERROR
	ret
CtLbErrMsg endp

;returns success bool
CtFsCreate proc uses edi pFileName
LOCAL hFile,dwFsize
	invoke CreateFile,pFileName,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	mov hFile,eax
	.if eax != INVALID_HANDLE_VALUE
		invoke GetFileSize,eax,0
		mov dwFsize,eax
		invoke VirtualAlloc,0,eax,MEM_COMMIT,PAGE_READWRITE
		mov pCtLbStream,eax
		.if eax
			invoke ReadFile,hFile,pCtLbStream,dwFsize,addr dwFsize,0
			.if eax
				invoke CloseHandle,hFile
				return TRUE
			.endif
			invoke VirtualFree,pCtLbStream,0,MEM_RELEASE
		.endif
		invoke CloseHandle,hFile
	.endif
	xor ecx,ecx
	mov pCtLbStream,ecx
	mov eax,ecx;FALSE
	ret
CtFsCreate endp

CtFsFree proc
	mov edx,pCtLbStream
	.if edx != 0
		invoke VirtualFree,edx,0,MEM_RELEASE
	.endif
	ret
CtFsFree endp

CtLbHide proc
	invoke ShowWindow,hCtLb,SW_HIDE
	ret
CtLbHide endp

CtLbPopup proc
LOCAL pt:POINT
	invoke GetCaretPos,addr pt
	add pt.y,1
	add pt.x,1
	invoke SetWindowPos,hCtLb,HWND_TOPMOST,pt.x,pt.y,CtLbWidth,CtLbHeight,SWP_SHOWWINDOW
	invoke SendMessage,hCtLb,LB_SETCURSEL,0,0
	invoke SetFocus,hCtLb
	ret
CtLbPopup endp

CtLbGetIndent proc uses ebx 
LOCAL pMem,nRes,nLine,sel:CHARRANGE
	mov ebx,pAddinHandles
	invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_EXGETSEL,0,addr sel
	invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_LINELENGTH,sel.cpMin,0
	mov nRes,eax
	invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_EXLINEFROMCHAR,0,sel.cpMin
	mov nLine,eax
	mov eax,nRes
	and eax,-2 ; align to nearest word boundary
	add eax,2
	invoke GetMem,eax
	mov ecx,nRes
	mov word ptr [eax],cx
	mov pMem,eax
	invoke SendMessage,[ebx].ADDINHANDLES.hEdit,EM_GETLINE,nLine,eax
	xor ecx,ecx
	mov eax,pMem
	mov edx,nRes
	.while ecx<edx && ( byte ptr [eax+ecx] == VK_TAB || byte ptr [eax+ecx] == VK_SPACE)
		inc ecx
	.endw
	mov eax,pMem; its freed, dont worry
	mov edx,ecx
	ret
CtLbGetIndent endp

CountCRLF proc pStr
	mov edx,pStr
	xor eax,eax
@0:
	cmp byte ptr [edx],0
	je @2
	cmp byte ptr [edx],13
	jne @1
	cmp byte ptr [edx+1],10
	jne @1
	inc eax
@1:
	inc edx
	jmp @0
@2:	
	ret
CountCRLF endp 

CpyAndIndent proc uses esi edi ebx dest,src,pindnt,indnt,pcaretpos
LOCAL CaretChr:byte
	mov al,'~'
	.if nAsm==7
		mov al,'@'
	.endif	
	mov CaretChr,al
	mov edi,dest
	mov esi,src
	xor edx,edx
	mov ecx,pcaretpos
	mov [ecx],edx	
	.repeat
		mov al,[esi]
		inc esi
		.if al==CaretChr
			mov ecx,pcaretpos
			mov [ecx],edx
		.else
			mov [edi],al
			inc edi
		.endif
		inc edx
		.break .if !al
		.continue .if al != CR
		mov al,[esi]
		inc esi
		mov [edi],al
		inc edi
		.break .if !al
		.break .if al != LF
		; StrNCpy
		mov ecx,indnt
		mov ebx,pindnt
		add edx,ecx
		.while ecx
			mov al,[ebx]
			inc ebx
			mov [edi],al
			inc edi
			dec ecx
		.endw
		
	.until FALSE
@@End:
	mov ecx,pcaretpos
	mov eax,[ecx]
	.if !eax
		dec edx
		mov [ecx],edx
	.endif
	ret
CpyAndIndent endp


CtLbSelected proc uses ebx esi edi
LOCAL pMem,dwCaretPos,dwStartPos,dwEndPos,pInd,nInd,nCrlfs
LOCAL pSnipp,cchSnipp,pnewSnipp,newcchSnipp
	invoke SendMessage,hCtLb,LB_GETCURSEL,0,0
	.if eax != LB_ERR
		invoke SendMessage,hCtLb,LB_GETITEMDATA,eax,0
		mov pSnipp,eax
		invoke CtLbGetIndent
		mov pInd,eax
		mov nInd,edx
		invoke StrLen,pSnipp
		test eax,eax
		mov cchSnipp,eax
		.if zero?
			invoke FreeMem,pInd
			jmp @@Err 
		.endif
		invoke CountCRLF,pSnipp
		mov nCrlfs,eax
		mul nInd
		add eax,cchSnipp
		inc eax
		mov newcchSnipp,eax
		invoke GetMem,eax
		mov pnewSnipp,eax
 		;;; Make indented buffer
		;;; and exclude ~ for caret
		invoke CpyAndIndent,pnewSnipp,pSnipp,pInd,nInd,addr dwCaretPos
		mov eax,pAddinHandles
		lea edx,dwEndPos
		lea ecx,dwStartPos
		invoke SendMessage,[eax].ADDINHANDLES.hEdit,EM_GETSEL,ecx,edx
		mov eax,pAddinHandles
		invoke SendMessage,[eax].ADDINHANDLES.hEdit,EM_REPLACESEL,TRUE,pnewSnipp
		;; adjust caret position
		mov eax,dwCaretPos
		add eax,dwStartPos
		mov edx,pAddinHandles
		invoke SendMessage,[edx].ADDINHANDLES.hEdit,EM_SETSEL,eax,eax
		invoke FreeMem,pInd
		invoke FreeMem,pnewSnipp
		invoke CtLbHide
	.endif
	ret
@@Err:
	invoke CtLbErrMsg,T('Error in snipplet')
	invoke CtLbHide
	ret

CtLbSelected endp

CtLbSaveDim proc
LOCAL rc:RECT
	invoke GetWindowRect,hCtLb,addr rc
	mov eax,rc.right
	mov edx,rc.bottom
	sub eax,rc.left
	sub edx,rc.top
	mov CtLbWidth,eax
	mov CtLbHeight,edx
	ret
CtLbSaveDim endp

CtLbProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	mov eax,uMsg
	.if eax == WM_KILLFOCUS
		invoke CtLbSaveDim
		invoke CtLbHide
	.elseif eax == WM_KEYDOWN
		.if wParam == VK_ESCAPE
			invoke CtLbSaveDim
			invoke CtLbHide
			jmp @@Handled
		.elseif wParam == VK_RETURN
			invoke CtLbSaveDim
			invoke CtLbSelected
			jmp @@Handled
		.endif
	.elseif eax == WM_LBUTTONDBLCLK
		invoke CtLbSaveDim
		invoke CtLbSelected
		jmp @@Handled
	.endif
	invoke CallWindowProc,OldLbProc,hWnd,uMsg,wParam,lParam
	ret
@@Handled: 
	return TRUE
CtLbProc endp

; KetilO
StrChr2 proc lpStr:DWORD,chr:DWORD
	
	mov		eax,lpStr
	mov		edx,chr
	.while byte ptr [eax]
		.if [eax]==dx
			ret
		.endif
		inc		eax
	.endw
	xor		eax,eax
	dec		eax
	ret

StrChr2 endp

CtLbCreate proc uses esi edi ebx
LOCAL pos2,tbuf[200h]:byte
	
	;; open code templates file and stream it to memory
	lea edi,tbuf
	xor ecx,ecx
	mov esi,pAddinData
	mov eax,[esi].ADDINDATA.nAsm
	mov nAsm,eax	
	mov [edi],cl
	invoke StrConCat,edi,[esi].ADDINDATA.lpAddIn,T('\'),\
	addr [esi].ADDINDATA.szAssembler,T('.ct'),0
	invoke CtFsCreate,edi
	.if !eax 
		invoke GetMem,200h
		push eax
		invoke StrCpy,eax,T('*** Error opening code templates file',13,10)
		mov eax,[esp]
		invoke StrConCat,eax,T('*** '),edi,T(13,10,'*** Please setup the .ct file for your assembler',13,10,'*** or disable CodeTemplates addin with Addin Manager'),0
		mov eax,[esp]
		invoke TextOutput,eax
		call FreeMem
		return FALSE
	.endif
	
	; get width and height from radasm.ini
	mov edx,pAddinData
	invoke IniSetFileName,[edx].ADDINDATA.lpIniFile
	invoke IniSetSection,T('CodeTemplates')
	invoke IniReadInt,T('Width'),165
	mov CtLbWidth,eax
	invoke IniReadInt,T('Height'),120
	mov CtLbHeight,eax
	
	;; create the listbox
	mov eax,pAddinHandles
	mov edx,[eax].ADDINHANDLES.hWnd
	;; i think i corectly cloned hLB from radasm
	invoke CreateWindowEx,WS_EX_WINDOWEDGE,T('LISTBOX'),0, \
	WS_POPUP or WS_CLIPSIBLINGS or WS_CLIPCHILDREN or \
	WS_BORDER or WS_VSCROLL or WS_THICKFRAME or LBS_SORT or \
	LBS_HASSTRINGS or LBS_USETABSTOPS,0,0,CtLbWidth,CtLbHeight,edx,0,hInstance,0
	mov hCtLb,eax
	.if !eax
		invoke CtFsFree
		invoke CtLbErrMsg,T('Error creating code templates listbox control')
		return FALSE
	.endif
	invoke SetWindowLong,hCtLb,GWL_WNDPROC,offset CtLbProc
	mov OldLbProc,eax
	invoke CreateFontIndirect,addr Arial_8
	mov hFnt1,eax
	invoke SendMessage,hCtLb,WM_SETFONT,eax,TRUE
	
	 
	;; populate the ctlb
	;; CRUDE!,CRUDE!
	;; The snipplet file syntax is not strictly checked!
	mov edi,pCtLbStream
	inc edi
	jmp @F
	.while TRUE
		.if nAsm==7
			invoke StrChr2,edi,'*['
		.else
			invoke StrChr,edi,'{'
		.endif
		inc eax
		mov edi,eax
		jz @ErrorInSnipp
		xor ecx,ecx
		cmp word ptr [eax-3],0A0DH
		sete cl
		add ecx,ecx
		sub eax,ecx
		mov byte ptr [eax-1],0; bound snipplet
	@@:	
		.if nAsm==7
			inc edi
			invoke StrChr2,edi,']*'
		.else
			invoke StrChr,edi,'}'
		.endif
		inc eax
		mov esi,eax
		jz @ErrorInSnipp
		sub eax,edi
		.break .if eax == 1
		mov byte ptr [esi-1],0
		invoke SendMessage,hCtLb,LB_ADDSTRING,0,edi
		.if nAsm==7
			mov byte ptr [esi-1],'*'
			inc esi
		.else
			mov byte ptr [esi-1],'}'
		.endif
		xor ecx,ecx
		cmp word ptr [esi],0A0DH
		sete cl
		add ecx,ecx
		add esi,ecx
		invoke SendMessage,hCtLb,LB_SETITEMDATA,eax,esi; position in stream
		mov edi,esi
	.endw
	;EAX==TRUE
	ret

@ErrorInSnipp:
	invoke CtLbErrMsg,T('Error while parsing')
	invoke CtFsFree
	return FALSE
	
CtLbCreate endp

CtLbDestroy proc 
	invoke CtFsFree
	mov eax,hCtLb
	.if eax
		invoke DestroyWindow,eax
		invoke IniWriteInt,T('Width'),CtLbWidth
		invoke IniWriteInt,T('Height'),CtLbHeight
	.endif
	mov eax,hFnt1
	.if eax
		invoke DeleteObject,eax
	.endif
	ret
CtLbDestroy endp


