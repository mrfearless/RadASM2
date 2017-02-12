
MAKE struct
	hThread		dd ?
	hRead		dd ?
	hWrite		dd ?
	pInfo		PROCESS_INFORMATION <?>
	uExit		dd ?
	fRun		dd ?
	fExecThread	dd ?
MAKE ends

;Dialogs\Accept.dlg
IDD_DLGACCEPT					equ 6100
IDC_IMGACCEPT					equ 1001
IDC_STCACCEPT					equ 1002
IDC_STCCOMMAND					equ 1003
IDC_CHKDONTASK					equ 1004

.data

szErr1				db '**Error** ',0
szErr2				db '**Warning** ',0
szErr2b				db '**Fatal** ',0
szErr3				db 'Error ',0
szErr4				db ']:',0
szErr5				db '):-',0
szErr6				db 'Error in file ',0
szErr7				db 'at line ',0

iniErrIdentify		db 'Identify',0
iniSkipWords		db 'Skip',0
iniErrIdentifyDef	db 'error',0
szdotexe			db '.exe',0

.data?

OldOutputProc		dd ?
OldOutREdProc		dd ?
hOutREd1			dd ?
hOutREd2			dd ?
hOutREd3			dd ?
outbuffer			db 2048 dup(?)
make				MAKE <>
identify			db 64 dup(?)
identify1			db 64 dup(?)
nSkip				dd ?
nErrAsm				dd ?
fThreadWait			dd ?

.code

SetOutFocus proc

	invoke GetFocus
	xor		edx,edx
	.if eax==hOutREd1 || eax==hOutREd2 || eax==hOutREd3 || eax==hOutBtn1 || eax==hOutBtn2 || eax==hOutBtn3
		inc		edx
	.endif
	push	edx
	mov		eax,hOut
	call    GetToolPtr
	pop		eax
	.if eax!=[edx].TOOL.dFocus
		mov     [edx].TOOL.dFocus,eax
		invoke ToolMsg,hOut,TLM_CAPTION,0
	.endif
	ret

SetOutFocus endp

OutputError proc uses esi edi,hWin:HWND
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[32]:BYTE
	LOCAL	buffer2[32]:BYTE
	LOCAL	buffer3[32]:BYTE
	LOCAL	nInx:DWORD

	invoke SendMessage,hWin,REM_GETWORD,sizeof buffer1,addr buffer1
	lea		esi,buffer1
	lea		edi,buffer2
  @@:
	mov		al,[esi]
	.if (al>='A' && al<='Z') || (al>='a' && al<='z')
		mov		[edi],al
		inc		edi
		inc		esi
		jmp		@b
	.endif
	mov		byte ptr [edi],0
	invoke strcpy,addr buffer1,esi
	mov		nInx,1
  @@:
	inc		nInx
	invoke BinToDec,nInx,addr buffer
	invoke GetPrivateProfileString,addr iniError,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr iniAsmFile
	.if eax
		invoke iniGetItem,addr buffer,addr buffer3
		invoke strcmp,addr buffer2,addr buffer3
		.if !eax
			invoke strcpy,addr buffer2,addr buffer			
			invoke strcat,addr buffer2,addr szSpace
			invoke strcat,addr buffer2,addr buffer1
			invoke BinToDec,1,addr buffer
			invoke GetPrivateProfileString,addr iniError,addr buffer,addr szNULL,addr buffer,sizeof buffer,addr iniAsmFile
			.if eax
				invoke SendMessage,hWin,REM_GETWORD,sizeof buffer1,addr buffer1
				invoke iniPathFix,addr buffer
				invoke ShellExecute,hWnd,NULL,addr buffer,addr buffer1,NULL,SW_SHOWNORMAL
			.endif
		.else
			jmp		@b
		.endif
	.endif
	xor		eax,eax
	ret

OutputError endp

OutputDblClick proc uses esi edi,hWin:HWND,fSkipBS:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[32]:BYTE
	LOCAL	chrg:CHARRANGE

	xor		eax,eax
	.if AsmFlag
		invoke GetLine,hWin
		mov		eax,offset LineTxt
		.while byte ptr [eax]
			.if byte ptr [eax]=='/'
				mov		byte ptr [eax],'\'
			.endif
			inc		eax
		.endw
		mov		esi,offset LineTxt
		lea		edi,buffer
		invoke GetPrivateProfileInt,addr iniError,addr ininAsm,0,addr iniAsmFile
		.if eax==98 || eax==99
			invoke GetPrivateProfileInt,addr iniError,addr iniSkipWords,0,addr iniAsmFile
			mov		ecx,eax
			.while byte ptr [esi] && ecx
				.if byte ptr [esi]==' '
					.while byte ptr [esi]==' '
						inc		esi
					.endw
					dec		ecx
				.else
					inc		esi
				.endif
			.endw
			.while byte ptr [esi] && byte ptr [esi]!='.'
				mov		al,[esi]
				mov		[edi],al
				inc		esi
				inc		edi
			.endw
			.if byte ptr [esi]=='.'
				.while byte ptr [esi] && byte ptr [esi]!=' '
					mov		al,[esi]
					mov		[edi],al
					inc		esi
					inc		edi
				.endw
				mov		byte ptr [edi],0
				lea		edi,buffer1
				.while byte ptr [esi] && byte ptr [esi]==' '
					inc		esi
				.endw
				invoke lstrcpyn,edi,esi,31
				lea		esi,buffer
				jmp		FileFound
			.endif
		.else
			dec		esi
		  @@:
			inc		esi
			mov		al,[esi]
			cmp		al,20h
			je		@b
			cmp		al,09h
			je		@b
			cmp		al,'"'
			je		@b
		  @@:
			mov		ax,[esi]
			.if al=='\' && fSkipBS
				inc		esi
				lea		edi,buffer
				jmp		@b
			.endif
			mov		[edi],al
			cmp		al,09h
			je		@f
			cmp		al,0Dh
			je		@f
			cmp		al,'('
			je		@f
			cmp		al,'['
			je		@f
			cmp		al,'"'
			je		@f
			.if al==':' && ah!='\'
				jmp		@f
			.endif
			inc		esi
			inc		edi
			or		al,al
			jne		@b
		  @@:
			mov		al,[edi-1]
			.if al==' '
				dec		edi
				jmp		@b
			.endif
			mov		al,0
			mov		[edi],al
			invoke lstrcpyn,addr buffer1,esi,31
			lea		esi,buffer
			mov		edi,offset szErr1
			call	TestErr
			.if eax
				lea		esi,buffer
				mov		edi,offset szErr2
				call	TestErr
				.if eax
					lea		esi,buffer
					mov		edi,offset szErr2b
					call	TestErr
					.if eax
						lea		esi,buffer
						mov		edi,offset szErr3
						call	TestErr
						.if eax
							lea		esi,buffer
						.endif
					.endif
				.endif
			.endif
		  FileFound:
			.if fProject
				mov		ax,[esi]
				.if ax=='\.'
					add		esi,2
				.endif
				.if al=='\' || ah==':'
					mov		FileName,0
				.else
					invoke strcpy,addr FileName,addr ProjectPath
				.endif
				call	TestFileName
				invoke strcat,addr FileName,esi
			.else
				invoke strcpy,addr FileName,esi
			.endif
			.if !fSkipBS
				invoke OutputError,hWin
			.endif
			invoke ProjectOpenFile,fSkipBS
			.if !eax && hEdit
				lea		esi,buffer1
				dec		esi
			  @@:
				inc		esi
				mov		al,[esi]
				cmp		al,'0'
				jl		@b
				cmp		al,'9'
				jg		@b
				invoke DecToBin,esi
				dec		eax
				invoke SendMessage,hEdit,EM_LINEINDEX,eax,0
				mov		chrg.cpMin,eax
				mov		chrg.cpMax,eax
				invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
				invoke VerticalCenter,hEdit,REM_VCENTER
				invoke SetFocus,hEdit
				xor		eax,eax
				inc		eax
			.else
				xor		eax,eax
			.endif
		.endif
	.endif
	ret

TestErr:
	movzx	eax,byte ptr [edi]
	.if eax
		cmp		al,[esi]
		jne		@f
		inc		esi
		inc		edi
		jmp		TestErr
	.endif
  @@:
	retn

TestFileName:
	mov		eax,[esi]
	and		eax,0FFFFFFh
	.if eax=='\..'
		push	esi
		invoke strlen,addr FileName
		lea		esi,FileName[eax]
		dec		esi
		dec		esi
		.while byte ptr [esi]!='\' && esi>=offset FileName
			mov		byte ptr [esi],0
			dec		esi
		.endw
		pop		esi
		add		esi,3
		jmp		TestFileName
	.endif
	retn

OutputDblClick endp

OutputProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_COMMAND
		.if wParam>=1 && wParam<=3
			.if wParam==1
				m2m		hOutREd,hOut1
				invoke ShowWindow,hOut1,SW_SHOW
				invoke SetParent,hOutBtn1,hOut1
				invoke SetParent,hOutBtn2,hOut1
				invoke SetParent,hOutBtn3,hOut1
				invoke ShowWindow,hOut2,SW_HIDE
				invoke ShowWindow,hOut3,SW_HIDE
			.elseif wParam==2
				m2m		hOutREd,hOut2
				invoke ShowWindow,hOut2,SW_SHOW
				invoke SetParent,hOutBtn1,hOut2
				invoke SetParent,hOutBtn2,hOut2
				invoke SetParent,hOutBtn3,hOut2
				invoke ShowWindow,hOut1,SW_HIDE
				invoke ShowWindow,hOut3,SW_HIDE
			.elseif wParam==3
				m2m		hOutREd,hOut3
				invoke ShowWindow,hOut3,SW_SHOW
				invoke SetParent,hOutBtn1,hOut3
				invoke SetParent,hOutBtn2,hOut3
				invoke SetParent,hOutBtn3,hOut3
				invoke ShowWindow,hOut1,SW_HIDE
				invoke ShowWindow,hOut2,SW_HIDE
			.endif
			invoke SetFocus,hOutREd
		.endif
		xor		eax,eax
		jmp		Ex
	.elseif eax==WM_LBUTTONDBLCLK
		invoke DllProc,hWin,AIM_OUTPUTDBLCLK,wParam,lParam,RAM_OUTPUTDBLCLK
		or		eax,eax
		jne		@f
		invoke OutputDblClick,hWin,FALSE
		.if !eax && fProject
			invoke OutputDblClick,hWin,TRUE
		.endif
	  @@:
		xor		eax,eax
		jmp		Ex
	.endif
	invoke CallWindowProc,OldOutputProc,hWin,uMsg,wParam,lParam
  Ex:
	ret

OutputProc endp

OutREdProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_SETFOCUS || eax==WM_KILLFOCUS
		invoke SetOutFocus
	.endif
	invoke CallWindowProc,OldOutREdProc,hWin,uMsg,wParam,lParam
	ret

OutREdProc endp

Do_OutPutTool proc
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer2[64]:BYTE
    LOCAL   sTool:DOCKING
    LOCAL   hWin:HWND

	assume eax:nothing
    mov		sTool.ID,2
    mov     sTool.Caption,offset szOutPutCaption
	invoke strcpy,addr buffer,addr Output
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Visible,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Docked,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.Position,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.IsChild,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.DockWidth,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.DockHeight,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.left,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.top,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.right,eax
    invoke iniGetItem,addr buffer,addr buffer2
    invoke DecToBin,addr buffer2
    mov     sTool.FloatRect.bottom,eax
	invoke CreateWindowEx,0,addr szStatic,NULL,
			WS_CHILD or WS_VISIBLE or SS_NOTIFY or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,
			0,0,0,0,hWnd,0,hInstance,0
	mov		hWin,eax
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,
            addr RAEditClass,0,
            WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NOSIZEGRIP or STYLE_NOSTATE or STYLE_NODBLCLICK or STYLE_DRAGDROP,
            0,0,0,0,hWin,0,hInstance, 0
	mov		hOut3,eax
    invoke SetWindowLong,hOut3,GWL_WNDPROC,addr OutputProc
    mov		OldOutputProc,eax
	invoke SendMessage,hOut3,REM_SUBCLASS,0,offset OutREdProc
	mov		OldOutREdProc,eax
	invoke GetWindowLong,hOut3,0
	mov		eax,[eax].RAEDIT.edtb.hwnd
	mov		hOutREd3,eax
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,
            addr RAEditClass,0,
            WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NOSIZEGRIP or STYLE_NOSTATE or STYLE_NODBLCLICK or STYLE_DRAGDROP,
            0,0,0,0,hWin,0,hInstance, 0
	mov		hOut2,eax
    invoke SetWindowLong,hOut2,GWL_WNDPROC,addr OutputProc
	invoke SendMessage,hOut2,REM_SUBCLASS,0,offset OutREdProc
	invoke GetWindowLong,hOut2,0
	mov		eax,[eax].RAEDIT.edtb.hwnd
	mov		hOutREd2,eax
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,
            addr RAEditClass,0,
            WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHILITE or STYLE_NOSIZEGRIP or STYLE_NOSTATE or STYLE_NODBLCLICK or STYLE_DRAGDROP,
            0,0,0,0,hWin,0,hInstance, 0
	mov		hOut1,eax
	mov		hOutREd,eax
    invoke SetWindowLong,hOut1,GWL_WNDPROC,addr OutputProc
	invoke SendMessage,hOut1,REM_SUBCLASS,0,offset OutREdProc
	invoke GetWindowLong,hOut1,0
	mov		eax,[eax].RAEDIT.edtb.hwnd
	mov		hOutREd1,eax
	invoke CreateWindowEx,0,addr szButton,0,
			WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or \
			BS_AUTORADIOBUTTON or WS_GROUP,
			-1,0,12,12,hOut1,1,hInstance,NULL
	mov		hOutBtn1,eax
	invoke CreateWindowEx,0,addr szButton,0,
			WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or \
			BS_AUTORADIOBUTTON,
			-1,12,12,12,hOut1,2,hInstance,NULL
	mov		hOutBtn2,eax
	invoke CreateWindowEx,0,addr szButton,0,
			WS_VISIBLE or WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or \
			BS_AUTORADIOBUTTON,
			-1,24,12,12,hOut1,3,hInstance,NULL
	mov		hOutBtn3,eax
    invoke ToolMessage,hWin,TLM_CREATE,addr sTool
	invoke ShowWindow,hOut1,SW_SHOW
	invoke SendMessage,hOutBtn1,BM_SETCHECK,BST_CHECKED,0
    invoke SetFormat,hOut3,hFont,hFont,hFont,FALSE
    invoke SetFormat,hOut2,hFont,hFont,hFont,FALSE
    invoke SetFormat,hOut1,hFont,hFont,hFont,FALSE
	invoke SendMessage,hOut3,REM_GETCOLOR,0,addr racol
	invoke SendMessage,hOut3,REM_SETCOLOR,0,addr racol
	invoke SendMessage,hOut2,REM_SETCOLOR,0,addr racol
	invoke SendMessage,hOut1,REM_SETCOLOR,0,addr racol
	invoke SetParent,hOutBtn1,hOut1
	invoke SetParent,hOutBtn2,hOut1
	invoke SetParent,hOutBtn3,hOut1
    mov     eax,hWin
    ret

Do_OutPutTool endp

ToolOutputSize proc lParam:LPARAM
	LOCAL	wt:DWORD
	LOCAL	ht:DWORD

	mov		eax,lParam
	and		eax,0FFFFh
	mov		wt,eax
	mov		eax,lParam
	shr		eax,16
	mov		ht,eax
	invoke MoveWindow,hOut1,0,0,wt,ht,TRUE
	invoke MoveWindow,hOut2,0,0,wt,ht,TRUE
	invoke MoveWindow,hOut3,0,0,wt,ht,TRUE
	ret

ToolOutputSize endp

OutputSelect proc nInx:DWORD

	invoke SendMessage,hOutBtn1,BM_SETCHECK,FALSE,0
	invoke SendMessage,hOutBtn2,BM_SETCHECK,FALSE,0
	invoke SendMessage,hOutBtn3,BM_SETCHECK,FALSE,0
	mov		eax,nInx
	.if eax==3
		mov		eax,hOutBtn3
	.elseif eax==2
		mov		eax,hOutBtn2
	.else
		mov		eax,hOutBtn1
	.endif
	invoke SendMessage,eax,BM_SETCHECK,TRUE,0
	invoke SendMessage,hOutREd,WM_COMMAND,nInx,0
	ret

OutputSelect endp

;Replace $0...$19 with project file
FixMake proc lpBuff:DWORD
	LOCAL nInx:DWORD
	LOCAL buffer[4]:BYTE
	LOCAL buffer1[128]:BYTE

	mov		nInx,19
  @@:
	mov		buffer[0],'$'
	invoke BinToDec,nInx,addr buffer[1]
	invoke GetPrivateProfileString,addr iniMakeFile,addr buffer[1],addr szNULL,addr buffer1,128,addr ProjectFile
	.if eax
		invoke iniFixPath,lpBuff,addr buffer1,addr buffer
	.endif
	dec		nInx
	jns		@b
	ret

FixMake endp

ShowOutput proc

	invoke ToolMessage,hOut,TLM_GET_VISIBLE,0
	.if !eax
		invoke ToolMessage,hOut,TLM_HIDE,0
	.endif
	ret

ShowOutput endp

FindErrors proc uses esi edi,lpBuff:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	nErr:DWORD
	LOCAL	iLine:DWORD
	LOCAL	nLine:DWORD
	LOCAL	iLastLine:DWORD
	LOCAL	fSkipBS:DWORD

	invoke GetPrivateProfileString,addr iniError,addr iniErrIdentify,addr iniErrIdentifyDef,addr identify1,sizeof identify1,addr iniAsmFile
	invoke iniGetItem,addr identify1,addr identify
	invoke GetPrivateProfileInt,addr iniError,addr iniSkipWords,0,addr iniAsmFile
	mov		nSkip,eax
	invoke GetPrivateProfileInt,addr iniError,addr ininAsm,0,addr iniAsmFile
	.if !eax
		mov		eax,nAsm
	.endif
	mov		nErrAsm,eax
	.if fProject && fErrBookMark
		invoke SendMessage,hOutREd,EM_GETLINECOUNT,0,0
		mov		iLastLine,-1
		xor		edx,edx
		mov		nErr,edx
		.while edx<eax
			push	eax
			push	edx
			mov		nLine,edx
			call	TestLine
			pop		edx
			pop		eax
			inc		edx
		.endw
		.if nErr
			invoke SendMessage,hWnd,WM_COMMAND,IDM_EDIT_NEXTERROR,0
		.endif
	.endif
	ret

TestLine:
	mov		word ptr LineTxt,sizeof LineTxt-4
	invoke SendMessage,hOutREd,EM_GETLINE,edx,addr LineTxt
	mov		byte ptr LineTxt[eax],0
	mov		eax,offset LineTxt
	.while byte ptr [eax]
		.if byte ptr [eax]=='/'
			mov		byte ptr [eax],'\'
		.endif
		inc		eax
	.endw
	mov		fSkipBS,0
	mov		eax,nErrAsm
	.if eax==nMASM
		call	GetMasmErr
		.if !eax
			inc		eax
			mov		fSkipBS,eax
			call	GetMasmErr
		.endif
	.elseif eax==nTASM
		call	GetTasmErr
		.if !eax
			inc		eax
			mov		fSkipBS,eax
			call	GetTasmErr
		.endif
	.elseif eax==nFASM
		call	GetFasmErr
		.if !eax
			inc		eax
			mov		fSkipBS,eax
			call	GetFasmErr
		.endif
	.elseif eax==nGOASM
		call	GetGoAsmErr
		.if !eax
			inc		eax
			mov		fSkipBS,eax
			call	GetGoAsmErr
		.endif
	.elseif eax==nHLA || eax==nFP
		call	GetHlaErr
		.if !eax
			inc		eax
			mov		fSkipBS,eax
			call	GetHlaErr
		.endif
	.elseif eax==nCPP
		call	GetCppErr
		.if !eax
			inc		eax
			mov		fSkipBS,eax
			call	GetCppErr
		.endif
	.elseif eax==nBCET
		call	GetMasmErr
		.if !eax
			inc		eax
			mov		fSkipBS,eax
			call	GetMasmErr
		.endif
	.else
		call	GetAnyErr
		.if !eax
			inc		eax
			mov		fSkipBS,eax
			call	GetAnyErr
		.endif
	.endif
	retn

AdjustForBP:
	mov		ecx,hEdit
	xor		edx,edx
	mov		edi,offset BreakPoint
  @@:
	.if ecx==[edi]
		.if eax>[edi+4]
			inc		edx
		.endif
	.endif
	add		edi,3*4
	cmp		edi,offset BreakPoint+sizeof BreakPoint
	jne		@b
	sub		eax,edx
	retn

Trim:
	.while byte ptr [edi-1]==' '
		dec		edi
	.endw
	mov		byte ptr [edi],0
	retn

SetErr:
	.while byte ptr [esi] && (byte ptr [esi]<'0' || byte ptr [esi]>'9')
		inc		esi
	.endw
	invoke DecToBin,esi
	dec		eax
	call	AdjustForBP
	mov		iLine,eax
	.if eax!=iLastLine && nErr<128
		inc		nErr
		mov		iLastLine,eax
		invoke SendMessage,hEdit,EM_LINEINDEX,iLine,0
		mov		chrg.cpMin,eax
		mov		chrg.cpMax,eax
		invoke SendMessage,hEdit,EM_EXSETSEL,0,addr chrg
		invoke VerticalCenter,hEdit,REM_VCENTER
		invoke SetErrorBookMark,hEdit,iLine
	.endif
	invoke SendMessage,hOutREd,REM_SETHILITELINE,nLine,0;1
	invoke SendMessage,hOutREd,REM_SETBOOKMARK,nLine,7
	xor		eax,eax
	inc		eax
	retn

TestFileName:
	mov		eax,[edi]
	and		eax,0FFFFFFh
	.if eax=='\..'
		push	edi
		invoke strlen,addr FileName
		lea		edi,FileName[eax]
		dec		edi
		dec		edi
		.while byte ptr [edi]!='\' && edi>=offset FileName
			mov		byte ptr [edi],0
			dec		edi
		.endw
		pop		edi
		add		edi,3
		jmp		TestFileName
	.endif
	retn

OpenErrFile:
	push	edi
	mov		edi,lpBuff
	.if byte ptr [edi]=='"'
		inc		edi
	.endif
	mov		ax,word ptr [edi]
	.if ax=='\.'
		add		edi,2
	.endif
	.if al=='\' || ah==':'
		mov		FileName,0
	.else
		invoke strcpy,addr FileName,addr ProjectPath
	.endif
	call	TestFileName
	invoke strcat,addr FileName,edi
	invoke strlen,addr FileName
	.if byte ptr FileName[eax-1]==','
		dec		eax
		mov		byte ptr FileName[eax],0
	.endif
	.if byte ptr FileName[eax-1]=='"'
		dec		eax
		mov		byte ptr FileName[eax],0
	.endif
	invoke GetFileAttributes,addr FileName
	test	eax,FILE_ATTRIBUTE_DIRECTORY
	.if ZERO?
		invoke ProjectOpenFile,FALSE
	.endif
	pop		edi
	retn

GetMasmErr:
	invoke iniInStr,addr LineTxt,addr szErr3
	inc		eax
	.if eax
		mov		esi,offset LineTxt
		call	GetMasmFileName
		.if ah && al=='('
			call	OpenErrFile
			.if !eax
				call	SetErr
			.else
				xor		eax,eax
			.endif
		.else
			xor		eax,eax
		.endif
	.endif
	retn

GetMasmFileName:
	mov		edi,lpBuff
	xor		eax,eax
  @@:
	mov		al,[esi]
	inc		esi
	.if al=='\' && fSkipBS
		mov		edi,lpBuff
		jmp		@b
	.endif
	.if al!='(' && al
		.if al=='.'
			inc		ah
		.endif
		mov		[edi],al
		inc		edi
		jmp		@b
	.endif
	call	Trim
	retn

GetTasmErr:
	invoke iniInStr,addr LineTxt,addr szErr1
	inc		eax
	.if !eax
		invoke iniInStr,addr LineTxt,addr szErr2
		inc		eax
		.if !eax
			invoke iniInStr,addr LineTxt,addr szErr2b
			inc		eax
		.endif
	.endif
	.if eax
		mov		esi,offset LineTxt
		call	GetTasmFileName
		.if ah && al=='('
			call	OpenErrFile
			.if !eax
				call	SetErr
			.else
				xor		eax,eax
			.endif
		.else
			xor		eax,eax
		.endif
	.endif
	retn

GetTasmFileName:
	mov		edi,lpBuff
	xor		eax,eax
  @@:
	mov		al,[esi]
	inc		esi
	.if al=='\' && fSkipBS
		mov		edi,lpBuff
		jmp		@b
	.elseif al=='*' && byte ptr [esi]==' '
		inc		esi
		mov		edi,lpBuff
		jmp		@b
	.endif
	.if al!='(' && al
		.if al=='.'
			inc		ah
		.endif
		mov		[edi],al
		inc		edi
		jmp		@b
	.endif
	call	Trim
	retn

GetFasmErr:
	invoke iniInStr,addr LineTxt,addr szErr4
	inc		eax
	.if eax
		mov		esi,offset LineTxt
		call	GetFasmFileName
		.if ah && al=='['
			call	OpenErrFile
			.if !eax
				call	SetErr
			.else
				xor		eax,eax
			.endif
		.else
			xor		eax,eax
		.endif
	.endif
	retn

GetFasmFileName:
	mov		edi,lpBuff
	xor		eax,eax
  @@:
	mov		al,[esi]
	inc		esi
	.if al=='\' && fSkipBS
		mov		edi,lpBuff
		jmp		@b
	.endif
	.if al!='[' && al
		.if al=='.'
			inc		ah
		.endif
		mov		[edi],al
		inc		edi
		jmp		@b
	.endif
	call	Trim
	retn

GetGoAsmErr:
	invoke iniInStr,addr LineTxt,addr szErr5
	inc		eax
	.if eax
		mov		esi,offset LineTxt
		call	GetGoAsmFileName
		.if ah
			mov		esi,offset LineTxt+5
			call	OpenErrFile
			.if !eax
				call	SetErr
			.else
				xor		eax,eax
			.endif
		.else
			xor		eax,eax
		.endif
	.endif
	retn

GetGoAsmFileName:
	.while byte ptr [esi]
		.break .if byte ptr [esi]=='('
		inc		esi
	.endw
	.if byte ptr [esi]=='('
		inc		esi
	.endif
	invoke strlen,esi
	.while eax
		.break .if byte ptr [esi+eax]==')'
		dec		eax
	.endw
	.if byte ptr [esi+eax]==')'
		mov		byte ptr [esi+eax],0
	.endif
	mov		edi,lpBuff
	xor		eax,eax
  @@:
	mov		al,[esi]
	inc		esi
	.if al=='\' && fSkipBS
		mov		edi,lpBuff
		jmp		@b
	.endif
	.if al
		.if al=='.'
			inc		ah
		.endif
		mov		[edi],al
		inc		edi
		jmp		@b
	.endif
	call	Trim
	retn

GetHlaErr:
	invoke iniInStr,addr LineTxt,addr szErr6
	inc		eax
	.if eax
		mov		esi,offset LineTxt
		call	GetHlaFileName
		.if ah && al=='"'
			mov		esi,offset LineTxt
			invoke iniInStr,esi,addr szErr7
			inc		eax
			.if eax
				add		esi,eax
				add		esi,7
				call	OpenErrFile
				.if !eax
					call	SetErr
				.else
					xor		eax,eax
				.endif
			.else
				xor		eax,eax
			.endif
		.else
			xor		eax,eax
		.endif
	.endif
	retn

GetHlaFileName:
	mov		edi,lpBuff
	add		esi,15
	xor		eax,eax
  @@:
	mov		al,[esi]
	inc		esi
	.if al=='\' && fSkipBS
		mov		edi,lpBuff
		jmp		@b
	.endif
	.if al!='"' && al
		.if al=='.'
			inc		ah
		.endif
		mov		[edi],al
		inc		edi
		jmp		@b
	.endif
	call	Trim
	retn

GetCppErr:
	invoke iniInStr,addr LineTxt,addr szErr3
	inc		eax
	.if eax
		.if eax==1
			mov		esi,offset LineTxt
			add		esi,6
			call	GetCppFileName
			.if ah
				call	OpenErrFile
				.if !eax
					call	SetErr
				.else
					xor		eax,eax
				.endif
			.else
				xor		eax,eax
			.endif
		.else
			jmp		GetMasmErr
		.endif
	.endif
	retn

GetCppFileName:
	mov		edi,lpBuff
	xor		eax,eax
  @@:
	mov		al,[esi]
	inc		esi
	.if al=='\' && fSkipBS
		mov		edi,lpBuff
		jmp		@b
	.endif
	.if al!=':' && al
		.if al=='.'
			inc		ah
		.endif
		mov		[edi],al
		inc		edi
		jmp		@b
	.elseif al==':'
		.while byte ptr [esi]==' '
			inc		esi
		.endw
	.endif
	call	Trim
	retn

SkipSpace:
	.while byte ptr [esi]==' '
		inc		esi
	.endw
	retn

SkipWord:
	.while byte ptr [esi]!=' ' && byte ptr [esi]
		inc		esi
	.endw
	retn

GetAnyErr:
	movzx	eax,identify
	.if eax
		invoke iniInStr,addr LineTxt,addr identify
		.if eax==-1
			.if identify1
				invoke iniInStr,addr LineTxt,addr identify1
			.endif
		.endif
		inc		eax
		.if eax
			mov		esi,offset LineTxt
			call	SkipSpace
			mov		ecx,nSkip
			.while ecx
				call	SkipWord
				call	SkipSpace
				dec		ecx
			.endw
			call	GetAnyFileName
			.if ah
				call	OpenErrFile
				.if !eax
				  @@:
					call	SkipSpace
					.if byte ptr [esi]=='(' || byte ptr [esi]=='[' || byte ptr [esi]==':'
						inc		esi
						jmp		@b
					.endif
					call	SetErr
				.else
					xor		eax,eax
				.endif
			.else
				xor		eax,eax
			.endif
		.endif
	.endif
	retn

GetAnyFileName:
	mov		edi,lpBuff
	xor		eax,eax
  @@:
	mov		al,[esi]
	inc		esi
	.if al=='\' && fSkipBS
		mov		edi,lpBuff
		jmp		@b
	.endif
	.if al!=' ' && al && al!='('
		.if al=='.'
			inc		ah
		.endif
		mov		[edi],al
		inc		edi
		jmp		@b
	.elseif al==' ' && !ah
		mov		[edi],al
		inc		edi
		jmp		@b
	.endif
	call	Trim
	retn

FindErrors endp

AcceptDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke LoadIcon,0,IDI_QUESTION
		invoke SendDlgItemMessage,hWin,IDC_IMGACCEPT,STM_SETIMAGE,IMAGE_ICON,eax
		invoke SetDlgItemText,hWin,IDC_STCCOMMAND,lParam
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke IsDlgButtonChecked,hWin,IDC_CHKDONTASK
				.if eax
					mov		eax,2
				.else
					mov		eax,1
				.endif
				invoke EndDialog,hWin,eax
			.elseif eax==IDCANCEL
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

AcceptDlgProc endp

GetCommand proc uses esi edi,lpCommand:DWORD,Param:DWORD
	LOCAL	buffer[256]:BYTE

	mov		esi,lpCommand
	.if byte ptr [esi]=='"'
		inc		esi
		.while byte ptr [esi]!='"' && byte ptr [esi]
			inc		esi
		.endw
		dec		esi
	.else
		.while byte ptr [esi]!=' ' && byte ptr [esi]
			inc		esi
		.endw
		dec		esi
	.endif
	.while byte ptr [esi]!='\' && esi>lpCommand
		dec		esi
	.endw
	.if byte ptr [esi]=='\'
		inc		esi
	.endif
	lea		edi,buffer
	.while byte ptr [esi]!='"' && byte ptr [esi]!=' ' && byte ptr [esi]
		mov		al,[esi]
		mov		[edi],al
		inc		esi
		inc		edi
	.endw
	mov		byte ptr [edi],0
	invoke CharLower,addr buffer
	invoke strlen,addr buffer
	.if eax>4
		mov		eax,dword ptr buffer[eax-4]
	.endif
	.if eax!='exe.' && eax!='tab.'
		invoke strcat,addr buffer,addr szdotexe
	.endif
	invoke iniInStr,addr szaccept,addr buffer
	.if eax==-1
		invoke iniInStr,addr sztempaccept,addr buffer
	.endif
	.if eax==-1
		invoke LoadCursor,0,IDC_ARROW
		invoke SetCursor,eax
		invoke ModalDialog,hInstance,IDD_DLGACCEPT,hWnd,offset AcceptDlgProc,lpCommand
		push	eax
		.if eax==2
			.if !Param
				.if szaccept
					invoke strcat,addr szaccept,addr szComma
				.endif
				invoke strcat,addr szaccept,addr buffer
				invoke WritePrivateProfileString,addr iniAccept,addr iniAccept,addr szaccept,addr iniFile
			.else
				.if sztempaccept
					invoke strcat,addr sztempaccept,addr szComma
				.endif
				invoke strcat,addr sztempaccept,addr buffer
			.endif
		.endif
		invoke LoadCursor,0,IDC_WAIT
		invoke SetCursor,eax
		pop		eax
	.else
		mov		eax,1
	.endif
	ret

GetCommand endp

MakeThreadProc proc uses ebx,Param:DWORD
	LOCAL	sat:SECURITY_ATTRIBUTES
	LOCAL	startupinfo:STARTUPINFO
	LOCAL	bytesRead:DWORD
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileInt,addr iniAccept,addr iniDontAsk,0,addr iniFile
	.if !eax
		mov		fThreadWait,TRUE
		invoke GetCommand,addr outbuffer,Param
		mov		fThreadWait,FALSE
		or		eax,eax
		je		Ex
	.endif
	invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,addr outbuffer
	invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,addr szCrLf
	invoke SendMessage,hOutREd,EM_SCROLLCARET,0,0
	mov		eax,Param
	.if eax==0
		mov sat.nLength,sizeof SECURITY_ATTRIBUTES
		mov sat.lpSecurityDescriptor,NULL
		mov sat.bInheritHandle,TRUE
		invoke CreatePipe,addr make.hRead,addr make.hWrite,addr sat,NULL
		.if eax==NULL
			;CreatePipe failed
			mov		eax,10
		.else
			mov startupinfo.cb,sizeof STARTUPINFO
			invoke GetStartupInfo,addr startupinfo
			mov eax,make.hWrite
			mov startupinfo.hStdOutput,eax
			mov startupinfo.hStdError,eax
			;Create process
			.if make.fRun
				mov startupinfo.dwFlags,STARTF_USESHOWWINDOW
				mov startupinfo.wShowWindow,SW_SHOWNORMAL
				invoke CreateProcess,NULL,addr outbuffer,NULL,NULL,FALSE,NULL,NULL,NULL,addr startupinfo,addr make.pInfo
			.else
				mov startupinfo.dwFlags,STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
				mov startupinfo.wShowWindow,SW_HIDE
				invoke CreateProcess,NULL,addr outbuffer,NULL,NULL,TRUE,NULL,NULL,NULL,addr startupinfo,addr make.pInfo
			.endif
			.if eax==NULL
				;CreateProcess failed
				invoke CloseHandle,make.hRead
				invoke CloseHandle,make.hWrite
				mov		eax,11
			.else
				.if make.fRun
					invoke WaitForSingleObject,make.pInfo.hProcess,INFINITE
					invoke GetExitCodeProcess,make.pInfo.hProcess,addr make.uExit
					invoke CloseHandle,make.hWrite
					invoke CloseHandle,make.hRead
					invoke CloseHandle,make.pInfo.hThread
					invoke CloseHandle,make.pInfo.hProcess
				.else
					invoke CloseHandle,make.hWrite
					invoke RtlZeroMemory,addr outbuffer,sizeof outbuffer
					xor		ebx,ebx
					.while TRUE
						invoke ReadFile,make.hRead,addr outbuffer[ebx],1,addr bytesRead,NULL
						.if eax==NULL
							.if ebx
								call	OutputText
							.endif
							.break
						.else
							.if outbuffer[ebx]==0Ah || ebx==511
								call	OutputText
							.else
								inc		ebx
							.endif
						.endif
					.endw
					invoke GetExitCodeProcess,make.pInfo.hProcess,addr make.uExit
					invoke CloseHandle,make.hRead
					invoke CloseHandle,make.pInfo.hThread
					invoke CloseHandle,make.pInfo.hProcess
				.endif
				mov		eax,make.uExit
			.endif
		.endif
	.elseif eax==1 || eax==2
		dec		eax
		push	eax
		mov		edx,offset outbuffer
		xor		ebx,ebx
		.while byte ptr [edx]
			.if byte ptr [edx]=='"'
				inc		edx
				.while byte ptr [edx]!='"'
					inc		edx
				.endw
			.elseif byte ptr [edx]==' '
				lea		ebx,[edx+1]
				mov		byte ptr [edx],0
				dec		edx
			.endif
			inc		edx
		.endw
		pop		eax
		invoke ShellExecute,hWnd,NULL,addr outbuffer[eax],ebx,NULL,SW_SHOWDEFAULT
		.if eax<=32
			invoke hexOut,eax
		.else
			xor		eax,eax
		.endif
		mov		make.uExit,eax
	.endif
  Ex:
	ret

OutputText:
	mov		outbuffer[ebx+1],0
	invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,addr outbuffer
	invoke SendMessage,hOutREd,EM_SCROLLCARET,0,0
	xor		ebx,ebx
	retn

MakeThreadProc endp

OutPutMake proc uses ebx esi,lpCommandLine:DWORD,lpFileName:DWORD
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	iNbr:DWORD
	LOCAL	fQuote:DWORD
	LOCAL	chrg:CHARRANGE
	LOCAL	msg:MSG
	LOCAL	notfound:DWORD
	LOCAL	errAsm:DWORD

	invoke GetPrivateProfileInt,addr iniError,addr ininAsm,0,addr iniAsmFile
	mov		errAsm,eax
	mov		make.fRun,FALSE
	mov		notfound,0
	invoke GetCursor
	push	eax
	invoke LoadCursor,0,IDC_WAIT
	invoke SetCursor,eax
	invoke OutputSelect,1
	.if fDebug
		mov		edx,lpCommandLine
		xor		eax,eax
		mov		ah,[edx]
		mov		al,'1'
		mov		[edx],eax
	.endif
	mov		fQuote,0
	mov		dword ptr outbuffer,0
	.if fProject
		invoke GetPrivateProfileString,addr iniMakeDef,lpCommandLine,addr szNULL,addr iniBuffer,SizeOf iniBuffer,addr ProjectFile
		.if !eax
		   	invoke GetPrivateProfileString,addr ProjectType,lpCommandLine,addr szNULL,addr iniBuffer,SizeOf iniBuffer,addr iniAsmFile
		.endif
	.else
		invoke GetPrivateProfileString,addr iniMakeDefNoPro,lpCommandLine,addr szNULL,addr iniBuffer,SizeOf iniBuffer,addr iniAsmFile
	.endif
	;Get file to delete
	invoke iniGetItem,addr iniBuffer,addr tempbuff
	movzx	eax,tempbuff
	push	eax
	.if al!='0'
		;Get filename
		push	eax
		mov		edx,dword ptr tempbuff[1]
		push	edx
		.if al>='0' && al<='9'
			invoke GetPrivateProfileString,addr iniMakeFile,addr tempbuff,addr szNULL,addr tempbuff,SizeOf tempbuff,addr ProjectFile
		.else
			call AddFile
		.endif
		pop		edx
		and		edx,5F5F5FFFh
		pop		eax
		.if al=='*' && edx=='JBO.'
			invoke strlen,addr tempbuff
			.while byte ptr tempbuff[eax-1]!='\' && eax
				dec		eax
			.endw
		.else
			xor		eax,eax
		.endif
		;Save it for delete and 'exist on exit test'
		invoke strcpy,addr buffer2,addr tempbuff[eax]
		mov		eax,lpFileName
		.if dword ptr [eax]=='9999'
			xor		eax,eax
			ret
		.endif
	.endif
	;Get (O)utput or (C)onsole
	invoke iniGetItem,addr iniBuffer,addr tempbuff
	movzx	ebx,word ptr tempbuff
	.if bl=='0'
		invoke iniGetItem,addr iniBuffer,addr prnbuff
		invoke iniPathFix,addr prnbuff
		invoke FixMake,addr prnbuff
	.else
		;Get command
		invoke iniGetItem,addr iniBuffer,addr outbuffer
		invoke iniPathFix,addr outbuffer
		invoke FixMake,addr outbuffer
	.endif
  @@:
	;Get file nbr
	mov		tempbuff[1],0
	invoke iniGetItem,addr iniBuffer,addr tempbuff
	mov		ax,word ptr tempbuff
	.if ax
		.if bh=='N' || bh==';'
			mov		fQuote,0
		.else
			mov		fQuote,1
		.endif
		.if (al>='1' && al<='9' && ah==0) || (ah>='0' && ah<='9' && al=='1')
			push	eax
			;Get filename
			invoke GetPrivateProfileString,addr iniMakeFile,addr tempbuff,addr szNULL,addr tempbuff,SizeOf tempbuff,addr ProjectFile
			call AddFile
			pop		eax
			.if ax=='3' || ax=='31'
				mov		iNbr,1
				.while iNbr<PRO_START_OBJ
					invoke GetFileNameFromID,iNbr
					.if eax
						invoke strcpy,addr tempbuff,eax
						invoke iniInStr,addr tempbuff,addr FTObj
						.if eax!=-1
							call AddFile
						.endif
					.endif
					inc		iNbr
				.endw
			.endif
			jmp @b
		.endif
		call AddFile
		jmp @b
	.endif
	call	ParsePipe
	.if bh==';'
		invoke strlen,addr outbuffer
		mov		word ptr outbuffer[eax],';'
	.endif
	.if bl=='O'
		invoke ShowOutput
		.if notfound
			mov		eax,TRUE
			ret
		.else
			invoke GetFileAttributes,addr buffer2
			.if eax!=-1
				invoke DeleteFile,addr buffer2
				.if !eax
					invoke LoadCursor,0,IDC_ARROW
					invoke SetCursor,eax
					mov		chrg.cpMin,-1
					mov		chrg.cpMax,-1
					invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,addr szFileDelErr
					invoke strlen,addr buffer2
					lea		esi,buffer2
					add		esi,eax
					mov		ax,0Dh
					mov		[esi],ax
					mov		chrg.cpMin,-1
					mov		chrg.cpMax,-1
					invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
					invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,addr buffer2
					mov		eax,TRUE
					ret
				.endif
			.endif
		.endif
		invoke SetFocus,hWnd
		xor		eax,eax
		call	ExecThread
		mov		chrg.cpMin,-1
		mov		chrg.cpMax,-1
		invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
		invoke SendMessage,hOutREd,EM_HIDESELECTION,FALSE,0
		invoke SendMessage,hOutREd,EM_SCROLLCARET,0,0
		invoke SetFocus,hOutREd
		mov		AsmFlag,TRUE
	.elseif bl=='C'
		;Console
		pop		eax
		push	'0'
		invoke WinExec,addr outbuffer,SW_SHOWDEFAULT
	.elseif bl=='0'
		;Run
		mov		make.fRun,TRUE
		.if fProject
			.if outbuffer[2]
				.if bh=='N' || bh==';'
					xor		ax,ax
				.else
					mov		ax,'"'
				.endif
				mov		word ptr tempbuff,ax
				.if outbuffer[3]!=':'
					invoke strcat,addr tempbuff,addr ProjectPath
				.endif
				mov		eax,2
				.if bh=='N' || bh==';'
					dec		eax
				.endif
				invoke strcat,addr tempbuff,addr outbuffer[eax]
				.if byte ptr prnbuff
					invoke strcat,addr prnbuff,addr szSpace
				.endif
				invoke strcat,addr prnbuff,addr tempbuff
			.endif
			invoke strcpy,addr outbuffer,addr prnbuff
			call	ParsePipe
			invoke TextToOutput,offset szExec
			.if fMinimize
				invoke ShowWindow,hWnd,SW_MINIMIZE
				mov		eax,0
				call	ExecThread
				invoke IsIconic,hWnd
				.if eax
					invoke ShowWindow,hWnd,SW_RESTORE
				.endif
				xor		eax,eax
			.else
				mov		eax,1
				call	ExecThread
			.endif
			jmp		@f
		.else
			call	ParsePipe
			invoke TextToOutput,offset szExec
			mov		eax,2
			call	ExecThread
		.endif
	.endif
	pop		eax
	.if al!='0'
		.if make.uExit!=1234
			;Check if file exists
			invoke GetFileAttributes,addr buffer2
			.if eax==-1 || iNbr
				;Error
				mov		eax,TRUE
			.else
				xor		eax,eax
			.endif
		.else
			invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,offset szTerminated
			;Error
			mov		eax,1234
		.endif
	.else
		xor		eax,eax
	.endif
  @@:
	pop		edx
	push	eax
	invoke SetCursor,edx
	pop		eax
	.if !eax && errAsm==98
		invoke FindErrors,addr tempbuff
		xor		eax,eax
	.endif
	ret

ExecThread:
	.if make.fExecThread
		xor		esi,esi
		mov		edx,eax
		invoke CreateThread,NULL,NULL,addr MakeThreadProc,edx,NORMAL_PRIORITY_CLASS,addr iNbr
		mov		make.hThread,eax
		.while TRUE
			invoke GetExitCodeThread,make.hThread,addr iNbr
			.break .if iNbr!=STILL_ACTIVE
			.if !fThreadWait
				invoke LoadCursor,0,IDC_WAIT
				invoke SetCursor,eax
			.endif
			invoke GetMessage,addr msg,NULL,0,0
			mov		eax,msg.message
			.if eax==WM_CHAR
				.if msg.wParam==VK_ESCAPE
					invoke TerminateProcess,make.pInfo.hProcess,1234
				.endif
			.elseif eax!=WM_CLOSE && (eax<WM_MOUSEFIRST || eax>WM_MOUSELAST)
				.if  eax==WM_TIMER
					inc		esi
					.if esi==4
						invoke SendMessage,hOutREd,EM_EXGETSEL,0,addr chrg
						push	chrg.cpMin
						mov		eax,chrg.cpMax
						sub		eax,chrg.cpMin
						.if eax<30
							add		chrg.cpMin,eax
							invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
						.endif
						invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,addr szSpace
						inc		chrg.cpMax
						pop		chrg.cpMin
						invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
						xor		esi,esi
					.endif
				.endif
				invoke TranslateMessage,addr msg
				invoke DispatchMessage,addr msg
			.endif
		.endw
		invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,addr szNULL
		invoke CloseHandle,make.hThread
		.if iNbr==10
			invoke MessageBox,hWnd,addr CreatePipeError,addr AppName,MB_ICONERROR+MB_OK
		.elseif iNbr==11
			invoke lstrcpy,addr tempbuff,addr CreateProcessError
			invoke lstrcat,addr tempbuff,addr outbuffer
			invoke MessageBox,hWnd,addr tempbuff,addr AppName,MB_ICONERROR+MB_OK
		.endif
		mov		eax,iNbr
	.else
		invoke MakeThreadProc,eax
		mov		iNbr,eax
	.endif
	retn

AddFile:
	invoke iniPathFix,addr tempbuff
	;Quote String
	.if fQuote
		mov		ax,'"'
	.else
		xor		ax,ax
	.endif
	mov		word ptr buffer1,ax
	invoke strcat,addr tempbuff,addr buffer1
	invoke strcat,addr buffer1,addr tempbuff
	invoke strcpy,addr tempbuff,addr buffer1
	;Add filename to command
	invoke strlen,addr outbuffer
	lea		edx,outbuffer[eax]
	.if byte ptr [edx-1]!=':'
		mov		word ptr [edx],' '
		inc		edx
	.endif
	push	edx
	mov		eax,fQuote
	mov		eax,dword ptr tempbuff[eax]
	push	eax
	.if ax=='.$'
		.if hMdiCld
			mov		edx,fQuote
			inc		edx
			invoke strcpy,addr buffer1,addr tempbuff[edx]
			mov		edx,fQuote
			invoke GetWindowText,hMdiCld,addr tempbuff[edx],sizeof tempbuff-1
			invoke iniRStripStr,addr tempbuff,'.'
			invoke strcat,addr tempbuff,addr buffer1
		.endif
	.elseif al=='$'
		.if hMdiCld
			mov		edx,fQuote
			inc		edx
			invoke strcpy,addr buffer1,addr tempbuff[edx]
			mov		edx,fQuote
			invoke GetWindowText,hMdiCld,addr tempbuff[edx],sizeof tempbuff-1
			invoke strcat,addr tempbuff,addr buffer1
		.endif
	.elseif al=='*'
		mov		edx,fQuote
		inc		edx
		invoke strcpy,addr buffer1,addr tempbuff[edx]
		mov		edx,fQuote
		invoke strcpy,addr tempbuff[edx],lpFileName
		invoke strcat,addr tempbuff,addr buffer1
	.endif
	.if fQuote
		invoke strlen,addr tempbuff
		dec		eax
		invoke lstrcpyn,addr buffer1,addr tempbuff[1],eax
	.else
		invoke strcpy,addr buffer1,addr tempbuff
	.endif
	pop		edx
	.if dl!='*' && dl!='$' && edx!='crsr'
		invoke iniInStr,addr buffer1,addr FTObj
		.if eax==-1
			invoke iniInStr,addr buffer1,addr FTRes
		.endif
		.if eax!=-1
			invoke GetFileAttributes,addr buffer1
			.if eax==-1
				inc		notfound
				invoke TextToOutput,offset szNotFound
				invoke TextToOutput,addr buffer1
			.endif
		.endif
	.endif
	invoke iniInStr,addr tempbuff,addr FTRes
	.if eax!=-1
		.if !fProject
			invoke GetFileAttributes,addr buffer1
		.endif
	.else
		inc		eax
	.endif
	pop		edx
	.if eax!=-1
		invoke strcpy,edx,addr tempbuff
	.endif
	retn

ParsePipe:
	mov		eax,TRUE
	.while eax!=-1
		invoke iniInStr,addr outbuffer,offset szPipe
		.if eax!=-1
			lea		eax,[outbuffer+eax]
			mov		byte ptr [eax],','
		.endif
	.endw
	retn

OutPutMake endp

OutputClear proc

	pushad
	mov		AsmFlag,FALSE
	invoke SendMessage,hOutREd,WM_SETTEXT,0,addr szNULL
	popad
	ret

OutputClear endp

hexOut proc hex:DWORD

	pushad
    mov     eax,hex
    invoke hexEax
	invoke TextToOutput,addr strHex
	popad
	ret

hexOut endp

hexStrOut proc lphex:DWORD,nBytes:DWORD

	pushad
    mov     esi,lphex
	mov		ecx,nBytes
  @@:
	push	ecx
	mov		eax,[esi]
    invoke hexEax
	invoke TextToOutput,addr strHex+6
	add		esi,1
	pop		ecx
	dec		ecx
	jne		@b
	popad
	ret

hexStrOut endp

TextToOutput proc lpText:DWORD
	LOCAL	chrg:CHARRANGE

	pushad
	mov		chrg.cpMin,-1
	mov		chrg.cpMax,-1
	invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
	invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,lpText
	invoke SendMessage,hOutREd,EM_EXSETSEL,0,addr chrg
	invoke SendMessage,hOutREd,EM_REPLACESEL,FALSE,addr szCrLf
	invoke SendMessage,hOutREd,EM_SCROLLCARET,0,0
	popad
	ret

TextToOutput endp
