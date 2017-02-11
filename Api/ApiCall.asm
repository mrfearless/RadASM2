
.data

iniApi			db 'Api',0
iniApiTrig		db 'Trig',0
iniApiCall		db 'Call',0
iniApiConst		db 'Const',0
iniApiStruct	db 'Struct',0
iniApiType		db 'Type',0
iniApiWord		db 'Word',0
iniApiMessage	db 'Message',0
iniApiArray		db 'Array',0
iniApiInc		db 'Inc',0
iniApiLib		db 'Lib',0

apilbwt			dd 200
apilbht			dd 150

.data?

lpApiLine		dd ?
nCommaCont		dd ?
fNoTrig			dd ?
ApiOfs			dd ?
szApiToolTip	db 16384 dup(?)
szIniApi		db 256 dup(?)

.code

ApiCallLoad proc
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileString,addr szIniApi,addr iniApiTrig,addr szNULL,addr szInvoke,sizeof szInvoke,addr iniAsmFile
	invoke GetPrivateProfileString,addr szIniApi,addr iniApiInc,addr szNULL,addr iniBuffer,64,addr iniAsmFile
	invoke iniGetItem,addr iniBuffer,addr szInclude
	invoke iniGetItem,addr iniBuffer,addr szIncludeSt
	invoke iniGetItem,addr iniBuffer,addr szIncludeEn
	invoke GetPrivateProfileString,addr szIniApi,addr iniApiLib,addr szNULL,addr iniBuffer,64,addr iniAsmFile
	invoke iniGetItem,addr iniBuffer,addr szIncludeLib
	invoke iniGetItem,addr iniBuffer,addr szIncludeLibSt
	invoke iniGetItem,addr iniBuffer,addr szIncludeLibEn
	invoke GetPrivateProfileString,addr szIniApi,addr iniApiCall,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniAsmFile
	.if eax
		.while iniBuffer
			invoke strcpy,addr buffer,addr AppPath
			invoke strcat,addr buffer,addr szBackSlash
			invoke strlen,addr buffer
			invoke iniGetItem,addr iniBuffer,addr buffer[eax]
			invoke AddFileToWordList,'A',0,addr buffer,2
		.endw
	.endif
	mov		fNoTrig,0
	mov		al,szInvoke
	.if !al
		inc		fNoTrig
	.endif
	ret

ApiCallLoad endp

ApiUpper proc uses esi edi,lpSrc:DWORD,lpDst:DWORD

	mov		esi,lpSrc
	mov		edi,lpDst
ApiUpper1:
	mov		al,[esi]
	cmp		al,0Dh
	jne		@f
	xor		al,al
  @@:
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	mov		[edi],al
	inc		esi
	inc		edi
	.if (al>='0' && al<='9') || al>='@'
		jmp		ApiUpper1
	.elseif al==' ' || al==VK_TAB || al==','
		dec		edi
		xor		al,al
	.endif
	mov		byte ptr [edi],0
	ret

ApiUpper endp

ApiFind proc uses esi,lpSrc:DWORD,lpApi:DWORD

	mov		edi,lpApi
ApiFind1:
	mov		lpApi,edi
	cmp		[edi].PROPERTIES.nType,'p'
	je		@f
	cmp		[edi].PROPERTIES.nType,'A'
	jne		Skip
  @@:
	mov		esi,lpSrc
	lea		ecx,[edi+sizeof PROPERTIES]
	dec		esi
	dec		ecx
	xor		eax,eax
ApiFind2:
	inc		esi
	inc		ecx
	mov		ah,[esi]
	mov		al,[ecx]
	or		ah,ah
	je		Found
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	cmp		al,ah
	je		ApiFind2
  Skip:
	mov		ecx,[edi].PROPERTIES.nSize
	lea		edi,[edi+ecx+sizeof PROPERTIES]
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	jne		ApiFind1
	dec		eax
  Found:
	mov		edi,lpApi
	ret

ApiFind endp

ApiSrc proc uses ecx esi edi,lpStr:DWORD,len:DWORD
	LOCAL	buffer[256]:BYTE

	m2m		hLB,hLBS
	mov		esi,lpStr
	dec		esi
	dec		findtext.chrg.cpMin
	inc		len
  @@:
	;Skip tab & spc
	inc		esi
	inc		findtext.chrg.cpMin
	dec		len
	mov		al,[esi]
	cmp		al,09h
	je		@b
	cmp		al,' '
	je		@b
	cmp		al,'('
	je		@b
	or		al,al
	jne		@f
	mov		eax,-1
	ret
  @@:
	cmp		al,0Dh
	jne		@f
	mov		eax,-1
	ret
  @@:
	invoke ApiUpper,esi,addr buffer
	or		al,al
	je		@f
	mov		eax,-1
	ret
  @@:
	invoke strlen,addr buffer
	.if eax<len
		mov		eax,-1
		ret
	.endif
	invoke SendMessage,hLB,WM_SETREDRAW,FALSE,0
	invoke SendMessage,hLB,LB_RESETCONTENT,0,0
	mov		edi,lpWordList
  Nxt:
	invoke ApiFind,addr buffer,edi
	.if eax!=-1
		lea		esi,[edi+sizeof PROPERTIES]
		invoke strlen,esi
		movzx	eax,byte ptr [esi+eax+1]
		push	eax
		invoke SendMessage,hLB,LB_ADDSTRING,0,esi
		pop		edx
		.if edx
			mov		edx,','
		.endif
		.if [edi].PROPERTIES.nType=='p'
			or		edx,10000h
		.endif
		invoke SendMessage,hLB,LB_SETITEMDATA,eax,edx
		mov		fApi,1
		mov		eax,[edi].PROPERTIES.nSize
		lea		edi,[edi+eax+sizeof PROPERTIES]
		mov		eax,[edi].PROPERTIES.nSize
		or		eax,eax
		jne		Nxt
	.endif
	invoke SendMessage,hLB,LB_SETCURSEL,0,0
	invoke SendMessage,hLB,WM_SETREDRAW,TRUE,0
	ret

ApiSrc endp

ApiMatch proc lpSrc:DWORD
	LOCAL	fFound:DWORD

	pushad
	mov		fFound,FALSE
	mov		edi,lpWordList
  Nx:
	.if	[edi].PROPERTIES.nType=='A'	|| [edi].PROPERTIES.nType=='p'
		mov		esi,lpSrc
		lea		ecx,[edi+sizeof	PROPERTIES]
		dec		esi
		dec		ecx
	  @@:
		inc		esi
		inc		ecx
		mov		al,[esi]
		.if	al
			cmp		al,[ecx]
			je		@b
		.endif
		.if	al=='.'	|| al=='('	|| al==','	|| al==' ' || al==VK_TAB ||	!al
			mov		al,[ecx]
			.if	!al
				mov		fFound,TRUE
				jmp		Ex
			.endif
		.endif
	.endif
	mov		ecx,[edi].PROPERTIES.nSize
	lea		edi,[edi+ecx+sizeof	PROPERTIES]
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	jne		Nx
  Ex:
	popad
	mov		eax,fFound
	ret

ApiMatch endp

IsWordInvoke proc uses esi edi,lpWord:DWORD

	.if nAsm==nCPP
		invoke ApiMatch,lpWord
		.if eax
			xor		ecx,ecx
			mov		eax,TRUE
		.endif
	.else
		mov		edi,offset szInvoke
	  @@:
		call	TestWord
		je		Ex
		.while byte ptr [edi]
			mov		al,[edi]
			inc		edi
			cmp		al,','
			je		@b
		.endw
		xor		eax,eax
		ret
	  Ex:
		mov		eax,ecx
	.endif
	ret

TestWord:
	mov		esi,lpWord
	xor		ecx,ecx
  @@:
	mov		al,[esi+ecx]
	mov		ah,[edi+ecx]
	.if ah==','
		xor		ah,ah
	.elseif ah>='A' && ah<='Z'
		or		ah,20h
	.endif
	.if al==' ' || al==VK_TAB
		xor		al,al
	.elseif al>='A' && al<='Z'
		or		al,20h
	.endif
	cmp		al,ah
	jne		@f
	inc		ecx
	cmp		al,'('
	je		@f
	or		al,al
	jne		@b
  @@:
	retn

IsWordInvoke endp

IsLineInvoke proc uses esi edi,hWin:HWND,nPos:DWORD

	mov		ApiOfs,0
	invoke GetLine,hWin
	mov		esi,offset LineTxt
	mov		LineStart,esi
	mov		LinePos,esi
	mov		eax,nPos
	.if eax
		mov		ecx,eax
		mov		al,szInvoke
		.if fNoTrig && !al
			;Remove spacees
			.while ecx && (byte ptr [esi+ecx]==' ' || byte ptr [esi+ecx]==VK_TAB)
				dec		ecx
			.endw
			.while ecx
				mov		al,[esi+ecx-1]
				.break .if al=='=' || al=='('
				.if al==')'
					.while ecx && byte ptr [esi+ecx]!='('
						dec		ecx
					.endw
				.elseif al=='"' || al=="'"
					dec		ecx
					.while ecx && al!=[esi+ecx]
						dec		ecx
					.endw
				.endif
				.if ecx
					dec		ecx
				.endif
			.endw
			.if byte ptr [esi+ecx-1]=='('
				dec		ecx
				.while ecx
					mov		al,[esi+ecx-1]
					.break .if al=='=' || al=='('
					.if al==')'
						.while ecx && byte ptr [esi+ecx]!='('
							dec		ecx
						.endw
					.elseif al=='"' || al=="'"
						dec		ecx
						.while ecx && al!=[esi+ecx]
							dec		ecx
						.endw
					.endif
					.if ecx
						dec		ecx
					.endif
				.endw
			.endif
			;Remove spacees
			.while byte ptr [esi+ecx]==' ' || byte ptr [esi+ecx]==VK_TAB
				inc		ecx
			.endw
			lea		esi,[esi+ecx]
			.if word ptr [esi]=='.w'
				add		esi,2
			.endif
			mov		LinePos,esi
			sub		esi,offset LineTxt
			mov		ApiOfs,esi
			mov		eax,TRUE
			jmp		Ex
		.endif
		dec		ecx
		lea		esi,[esi+ecx]
	  @@:
		.while esi>offset LineTxt
			mov		al,[esi-1]
			.if al==')'
				xor		ecx,ecx
				.while esi>offset LineTxt
					dec		esi
					mov		al,[esi]
					.if al=='('
						dec		ecx
					.elseif al==')'
						inc		ecx
					.endif
					.break .if !ecx
				.endw
				.while esi>offset LineTxt
					dec		esi
					mov		al,[esi]
					.break .if al==','
				.endw
				.if esi>offset LineTxt
					dec		esi
				.endif
			.endif
			.break .if al==' ' || al==',' || al==VK_TAB || al=='('
			.if esi>offset LineTxt
				dec		esi
			.endif
		.endw
		invoke IsWordInvoke,esi
		.if eax
			lea		esi,[esi+ecx]
			mov		LinePos,esi
			sub		esi,offset LineTxt
			mov		ApiOfs,esi
		.elseif esi>offset LineTxt
			dec		esi
			jmp		@b
		.endif
	.endif
  Ex:
	ret

IsLineInvoke endp

IncSrc proc uses ecx esi edi,lpStr:DWORD

	m2m		hLB,hLBS
	mov		esi,lpStr
	dec		esi
	dec		findtext.chrg.cpMin
  @@:
	;Skip tab & spc
	inc		esi
	inc		findtext.chrg.cpMin
	mov		al,[esi]
	cmp		al,09h
	je		@b
	cmp		al,' '
	je		@b
	or		al,al
	jne		@f
	mov		eax,-1
	ret
  @@:
	invoke SendMessage,hLB,LB_RESETCONTENT,0,0
	invoke FileTrvDir,offset Incl,esi
	mov		fInc,TRUE
	invoke SendMessage,hLB,LB_SETCURSEL,0,0
	ret

IncSrc endp

IsLineInclude proc uses esi edi,hWin:HWND

	invoke GetLine,hWin
	mov		esi,offset LineTxt
	mov		edi,offset LineWord
	invoke GetWord
	mov		edi,offset szInclude-1
	mov		esi,offset LineWord-1
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	.if al>='A' && al<='Z'
		or		al,20h
	.endif
	cmp		al,[edi]
	jne		@f
	or		al,al
	jne		@b
	mov		eax,TRUE
	ret
  @@:
	mov		eax,FALSE
	ret

IsLineInclude endp

LibSrc proc uses ecx esi edi,lpStr:DWORD

	m2m		hLB,hLBS
	mov		esi,lpStr
	dec		esi
	dec		findtext.chrg.cpMin
  @@:
	;Skip tab & spc
	inc		esi
	inc		findtext.chrg.cpMin
	mov		al,[esi]
	cmp		al,09h
	je		@b
	cmp		al,' '
	je		@b
	or		al,al
	jne		@f
	mov		eax,-1
	ret
  @@:
	invoke SendMessage,hLB,LB_RESETCONTENT,0,0
	invoke FileTrvDir,offset Lib,esi
	mov		fLib,TRUE
	invoke SendMessage,hLB,LB_SETCURSEL,0,0
	ret

LibSrc endp

IsLineIncludeLib proc uses esi edi,hWin:HWND

	invoke GetLine,hWin
	mov		esi,offset LineTxt
	mov		edi,offset LineWord
	invoke GetWord
	mov		edi,offset szIncludeLib-1
	mov		esi,offset LineWord-1
  @@:
	inc		esi
	inc		edi
	mov		al,[esi]
	.if al>='A' && al<='Z'
		or		al,20h
	.endif
	cmp		al,[edi]
	jne		@f
	or		al,al
	jne		@b
	mov		eax,TRUE
	ret
  @@:
	mov		eax,FALSE
	ret

IsLineIncludeLib endp

ApiCheck proc uses edx,hWin:HWND,nChar:DWORD

	xor		eax,eax
	mov		fApi,eax
	mov		fInc,eax
	mov		fLib,eax
	mov		eax,nChar
	.if (eax>='0' && eax<='9') || eax>='@' || eax==08h
		;Check if any selection is made
		invoke SendMessage,hWin,EM_EXGETSEL,0,addr findtext.chrg
		mov		eax,findtext.chrg.cpMin
		.if eax==findtext.chrg.cpMax
			;Get start of line
			invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,eax
			invoke SendMessage,hWin,EM_LINEINDEX,eax,0
			mov		findtext.chrg.cpMin,eax
			sub		eax,findtext.chrg.cpMax
			neg		eax
			;Check if invoke is found
			invoke IsLineInvoke,hWin,eax
			.if eax
				mov		eax,LinePos
				sub		eax,LineStart
				add		findtext.chrg.cpMin,eax
				mov		eax,findtext.chrg.cpMax
				sub		eax,findtext.chrg.cpMin
				invoke ApiSrc,LinePos,eax
			.else
				;Check if include is found
				invoke IsLineInclude,hWin
				.if eax
					mov		eax,LinePos
					sub		eax,LineStart
					add		findtext.chrg.cpMin,eax
					mov		eax,findtext.chrg.cpMax
					invoke IncSrc,LinePos
				.else
					;Check if includelib is found
					invoke IsLineIncludeLib,hWin
					.if eax
						mov		eax,LinePos
						sub		eax,LineStart
						add		findtext.chrg.cpMin,eax
						mov		eax,findtext.chrg.cpMax
						invoke LibSrc,LinePos
					.endif
				.endif
			.endif
		.endif
	.endif
	ret

ApiCheck endp

IsLineApi proc uses esi edi
	LOCAL	buffer[256]:BYTE

	mov		esi,LinePos
	lea		edi,buffer
	invoke GetWord
	mov		al,buffer
	or		al,al
	je		Ex
	invoke ApiUpper,addr buffer,addr buffer
	mov		edi,lpWordList
  Nxt:
	mov		eax,[edi].PROPERTIES.nSize
	or		eax,eax
	je		Ex
	invoke ApiFind,addr buffer,edi
	inc		eax
	je		Ex
	dec		eax
	je		@f
	mov		eax,[edi].PROPERTIES.nSize
	lea		edi,[edi+eax+sizeof PROPERTIES]
	jmp		Nxt
  @@:
	lea		edi,[edi+sizeof PROPERTIES]
	invoke strlen,edi
	lea		esi,[edi+eax+1]
	xor		eax,eax
	.if byte ptr [esi]
		invoke strcpy,offset szApiToolTip,edi
		.if nAsm==nBCET
			mov		eax,offset szLPA
		.else
			mov		eax,offset szComma
		.endif
		invoke strcat,offset szApiToolTip,eax
		invoke strcat,offset szApiToolTip,esi
		mov		edi,offset szApiToolTip
		mov		eax,','
	.endif
	mov		lptrApi,edi
	ret
  Ex:
	mov		eax,-1
	ret

IsLineApi endp

ApiComma proc uses ecx esi

	mov		esi,offset LineTxt
	add		esi,ApiOfs
	xor		edx,edx
	xor		eax,eax
	mov		ecx,LineEn
	sub		ecx,LineSt
	sub		ecx,ApiOfs
	jbe		Ex
  @@:
	mov		al,[esi]
	.if eax==',' || (eax=='<' && !edx) || (eax=='(' && fNoTrig && !edx)
		inc		edx
	.elseif eax=='"' || eax=="'" || eax=='('
		.if eax=='('
			mov		eax,')'
		.endif
		inc		esi
		dec		ecx
		je		Ex
		.while al!=byte ptr [esi]
			inc		esi
			dec		ecx
			je		Ex
		.endw
	.endif
	inc		esi
	loop	@b
  Ex:
	mov		eax,edx
	mov		nCommaCont,eax
	ret

ApiComma endp

ApiSkipWord proc lpPos:DWORD

	mov		edx,lpPos
	.while byte ptr [edx] && byte ptr [edx]!=',' && byte ptr [edx]!=' ' && byte ptr [edx]!=VK_TAB
		inc		edx
	.endw
	.while byte ptr [edx]==',' || byte ptr [edx]==' ' || byte ptr [edx]==VK_TAB
		inc		edx
	.endw
	mov		eax,edx
	ret

ApiSkipWord endp

ApiToolTip proc uses ecx edi,hWin:HWND
	LOCAL	pt:POINT
	LOCAL	ptW:POINT
	LOCAL	rect:RECT
	LOCAL	hDC:HDC
	LOCAL	cc:DWORD
	LOCAL	ccW:DWORD
	LOCAL	hOldFont:DWORD
	LOCAL	lnht:DWORD

	.if ShowApiToolTip
		invoke SendMessage,hWin,EM_EXGETSEL,0,addr findtext.chrg
		;Get start of line
		invoke SendMessage,hWin,EM_EXLINEFROMCHAR,0,findtext.chrg.cpMin
		invoke SendMessage,hWin,EM_LINEINDEX,eax,0
		mov		findtext.chrg.cpMin,eax
		sub		eax,findtext.chrg.cpMax
		neg		eax
		invoke IsLineInvoke,hWin,eax
		.if eax
		  @@:
			invoke IsLineApi
			.if (nAsm==nHLA || nAsm==nCPP || nAsm==nBCET || nAsm==nFP) && eax==-1
				invoke ApiSkipWord,LinePos
				.if byte ptr [eax]
					mov		LinePos,eax
					sub		eax,offset LineTxt
					add		eax,findtext.chrg.cpMin
					.if eax<findtext.chrg.cpMax
						jmp		@b
					.endif
				.endif
				jmp		Ex
			.endif
			.if eax!=-1
				.if al==','
					;Show Tlt
				  Showtt:
					invoke GetCaretPos,addr pt
					invoke SendMessage,hWin,EM_GETRECT,0,addr rect
					invoke ClientToScreen,hWin,addr rect.left
					;Get line height
					invoke GetWindowLong,hWin,0
					mov		edx,[eax].RAEDIT.fntinfo.fntht
					add		edx,[eax].RAEDIT.fntinfo.linespace
					add		edx,3
					mov		lnht,edx
					mov		eax,pt.x
					add		rect.left,eax
					mov		eax,pt.y
					add		eax,lnht
					add		rect.top,eax
					invoke GetDC,hTlt
					mov		hDC,eax
					invoke SelectObject,hDC,hLBFont
					mov		hOldFont,eax
					;Comma calkulation
					invoke strlen,lptrApi
					mov		ecx,eax
					mov		edi,lptrApi
					mov		lpApiLine,edi
					invoke ApiComma
					mov		ah,al
					.while byte ptr [edi] && byte ptr [edi]!=',' &&  byte ptr [edi]!='('
						inc		edi
					.endw
					.if byte ptr [edi]==',' ||  byte ptr [edi]=='('
						inc		edi
					.endif
					mov		ecx,','
					jmp		Ent
				  @@:
					mov		al,[edi]
					inc		edi
					.if al=='('
						shl		ecx,8
						mov		cl,')'
					.endif
					or		al,al
					je		@f
					.if al!=cl && al==')'
						jmp		@f
					.endif
					cmp		al,cl
					jne		@b
					.if cl!=','
						shr		ecx,8
						inc		edi
					.endif
				  Ent:
					dec		ah
					jne		@b
				  @@:
					sub		edi,lptrApi
					mov		ccW,edi
					invoke GetTextExtentPoint32,hDC,lptrApi,ccW,addr ptW
					mov		eax,ptW.x
					sub		rect.left,eax
					sub		rect.left,2
					invoke strlen,lptrApi
					mov		cc,eax
					invoke GetTextExtentPoint32,hDC,lptrApi,cc,addr pt
					add		pt.x,4
					add		pt.y,3
					invoke SetWindowText,hTlt,lptrApi
					invoke SetWindowPos,hTlt,0,rect.left,rect.top,pt.x,pt.y,SWP_NOZORDER or SWP_SHOWWINDOW or SWP_NOACTIVATE
					invoke UpdateWindow,hTlt
					mov		edi,lptrApi
					add		edi,ccW
					mov		eax,ptW.x
					mov		rect.left,eax
					mov		rect.top,0
					mov		rect.right,99
					mov		rect.bottom,16
					invoke SetBkMode,hDC,TRANSPARENT
					invoke SetTextColor,hDC,0D00000h
					mov		lptrApi,edi
					dec		edi
					mov		ah,','
				  @@:
					inc		edi
					mov		al,[edi]
					.if al=='('
						invoke GetTextExtentPoint32,hDC,edi,1,addr pt
						mov		eax,pt.x
						add		rect.left,eax
						inc		lptrApi
						mov		ah,')'
						jmp		@b
					.endif
					dec		edi
				  @@:
					inc		edi
					mov		al,[edi]
					or		al,al
					je		@f
					cmp		al,')'
					je		@f
					cmp		al,ah
					jne		@b
				  @@:
					sub		edi,lptrApi
					invoke DrawText,hDC,lptrApi,edi,addr rect,DT_LEFT or DT_NOCLIP or DT_VCENTER
					add		edi,2
					invoke lstrcpyn,addr szTltSel,lptrApi,edi
					m2m		fTlt,hWin
					m2m		fTltLine,Line
					invoke SelectObject,hDC,hOldFont
					invoke ReleaseDC,hTlt,hDC
					invoke ApiConstList,lpApiLine,nCommaCont
					ret
				.endif
			.endif
		.else
			mov		eax,nAsm
			.if eax==nMASM || eax==nTASM
				invoke IsLineStruct
				cmp		eax,-1
				jne		Showtt
			.endif
		.endif
	.endif
  Ex:
	.if fTlt
		mov		fTlt,0
		invoke ShowWindow,hTlt,SW_HIDE
	.endif
	ret

ApiToolTip endp

HideApiToolTip proc hWin:HWND
	mov		eax,fTlt
	.if eax
		.if eax!=hWin
			mov		fTlt,0
			invoke ShowWindow,hTlt,SW_HIDE
		.else
			mov		eax,Line
			.if eax!=fTltLine
				invoke ShowWindow,hTlt,SW_HIDE
				mov		fTlt,0
			.endif
		.endif
	.endif
	ret

HideApiToolTip endp

ShowListBox proc hWin:HWND
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	MaxX:DWORD
	LOCAL	MaxY:DWORD
	LOCAL	lnht:DWORD

	invoke ShowWindow,hTlt,SW_HIDE
	mov		fTlt,0
	invoke SendMessage,hLB,LB_GETCOUNT,0,0
	.if eax
		invoke GetWindowRect,hLB,addr rect
		mov		eax,rect.right
		sub		eax,rect.left
		mov		apilbwt,eax
		mov		eax,rect.bottom
		sub		eax,rect.top
		mov		apilbht,eax
		invoke GetSystemMetrics,SM_CXSCREEN
		mov		MaxX,eax
		invoke GetSystemMetrics,SM_CYSCREEN
		mov		MaxY,eax
		invoke GetCaretPos,addr pt
		; Show LB
		invoke SendMessage,hWin,EM_GETRECT,0,addr rect
		invoke ClientToScreen,hWin,addr rect.left
		mov		edx,apilbwt
		mov		eax,pt.x
		add		rect.left,eax
		mov		eax,rect.left
		add		eax,edx
		.if sdword ptr eax>MaxX
			sub		rect.left,edx
			jnb		@f
			mov		eax,rect.left
			add		apilbwt,eax
			mov		rect.left,0
		  @@:
		.endif
		;Get line height
		invoke GetWindowLong,hWin,0
		mov		edx,[eax].RAEDIT.fntinfo.fntht
		add		edx,[eax].RAEDIT.fntinfo.linespace
		add		edx,3
		mov		lnht,edx
		mov		eax,edx
		add		eax,pt.y
		mov		edx,apilbht
		add		rect.top,eax
		mov		eax,rect.top
		add		eax,edx
		.if sdword ptr eax>MaxY
			add		edx,lnht
			add		edx,3
			sub		rect.top,edx
			jnb		@f
			mov		eax,rect.top
			add		apilbht,eax
			mov		rect.top,0
		  @@:
		.endif
		invoke MoveWindow,hLB,rect.left,rect.top,apilbwt,apilbht,TRUE
		invoke ShowWindow,hLB,SW_SHOWNOACTIVATE
;PrintDec rect.left
;PrintDec rect.top
;PrintDec apilbwt
;PrintDec apilbht
	.else
		invoke ShowWindow,hLB,SW_HIDE
	.endif
	ret

ShowListBox endp

ApiListBox proc hWin:HWND

	.if fApi && ShowApiList
		invoke ShowListBox,hWin
		m2m		fLB,hWin
		xor		eax,eax
		mov		fLBConst,eax
		mov		fLBStruct,eax
		mov		fLBWord,eax
		mov		fLBType,eax
	.elseif fInc || fLib
		invoke SendMessage,hLB,LB_GETCOUNT,0,0
		.if eax
			invoke ShowListBox,hWin
		.else
			invoke ShowWindow,hLB,SW_HIDE
		.endif
		m2m		fLB,hWin
		xor		eax,eax
		mov		fLBConst,eax
		mov		fLBStruct,eax
		mov		fLBWord,eax
		mov		fLBType,eax
	.elseif fLB
		; Hide LB
		invoke ShowWindow,hLB,SW_HIDE
		xor		eax,eax
		mov		fLB,eax
		mov		fLBConst,eax
		mov		fLBStruct,eax
		mov		fLBWord,eax
		mov		fLBType,eax
	.endif
	ret

ApiListBox endp

