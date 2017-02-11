;#########################################################################
;	Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;	Include file

include SourceSafe.inc

.code

;#########################################################################
;	Common AddIn Procedures

DllEntry proc hInst:HINSTANCE,reason:DWORD,reserved1:DWORD

	mov		eax,hInst
	mov		hInstance,eax
	mov		eax,TRUE
	ret

DllEntry Endp

InStrng proc lpStr:DWORD,lpSrc:DWORD
	LOCAL	buffer[256]:BYTE

	push	esi
	push	edi
	mov		esi,lpSrc
	lea		edi,buffer
iniInStr0:
	mov		al,[esi]
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	mov		[edi],al
	inc		esi
	inc		edi
	or		al,al
	jne		iniInStr0
	mov		edi,lpStr
	dec		edi
iniInStr1:
	inc		edi
	push	edi
	lea		esi,buffer
iniInStr2:
	mov		ah,[esi]
	or		ah,ah
	je		iniInStr8;Found
	mov		al,[edi]
	or		al,al
	je		iniInStr9;Not found
	cmp		al,'a'
	jl		@f
	cmp		al,'z'
	jg		@f
	and		al,5Fh
  @@:
	inc		esi
	inc		edi
	cmp		al,ah
	jz		iniInStr2
	pop		edi
	jmp		iniInStr1
iniInStr8:
	pop		eax
	sub		eax,lpStr
	pop		edi
	pop		esi
	ret
iniInStr9:
	pop		edi
	mov		eax,-1
	pop		edi
	pop		esi
	ret

InStrng endp

SourceSafe proc lpCmnd:DWORD
	LOCAL	bytesRead:DWORD

	invoke lstrcpy,addr Result,addr Path
	invoke lstrcat,addr Result,addr szBS
	invoke lstrcat,addr Result,lpCmnd
	mov		sat.nLength,sizeof SECURITY_ATTRIBUTES
	mov		sat.lpSecurityDescriptor,NULL
	mov		sat.bInheritHandle,TRUE
	invoke CreatePipe,addr hRead,addr hWrite,addr sat,32*1024
	.if eax
		mov		sinf.cb,sizeof STARTUPINFO
		invoke GetStartupInfo,addr sinf
		mov		eax,hWrite
		mov		sinf.hStdOutput,eax
		mov		sinf.hStdError,eax
		mov		eax,hRead
		mov		sinf.hStdInput,eax
		mov		sinf.dwFlags,STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES
		mov		sinf.wShowWindow,SW_HIDE
		.if (fOption & 1)
			;Debug
			push	offset Result
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpTextOut
		.endif
		invoke CreateProcess,NULL,addr Result,NULL,NULL,TRUE,NULL,NULL,NULL,addr sinf,addr pinf
		.if eax
			mov		Result,0
			invoke WaitForSingleObject,pinf.hProcess,5000
			push	eax
			.if eax==WAIT_TIMEOUT
				invoke TerminateProcess,pinf.hProcess,eax
			.endif
			.if !fNoRead
				invoke ReadFile,hRead,addr Result,sizeof Result,addr bytesRead,NULL
				mov		eax,bytesRead
				mov		Result[eax],0
				pop		eax
				push	eax
			.endif
			.if eax || (fOption & 1)
				;Debug or error
				push	offset Result
				mov		eax,lpProc
				call	[eax].ADDINPROCS.lpTextOut
			.endif
			invoke CloseHandle,hWrite
			invoke CloseHandle,hRead
			invoke CloseHandle,pinf.hProcess
			invoke CloseHandle,pinf.hThread
			pop		eax
		.else
			mov		Result,al
			dec		eax
		.endif
	.else
		mov		Result,al
		dec		eax
	.endif
	ret

SourceSafe endp

CmndCP proc lpProject:DWORD
	LOCAL	buffer[256]:BYTE

	invoke wsprintf,addr buffer,addr szCP,lpProject,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	invoke InStrng,addr Result,addr szNotExist
	inc		eax
	.if ZERO?
		;Project exists
		inc		eax
	.else
		xor		eax,eax
	.endif
	ret

CmndCP endp

CmndCreate proc lpProject:DWORD
	LOCAL	buffer[256]:BYTE

	mov		fNoRead,TRUE
	invoke wsprintf,addr buffer,addr szCreate,lpProject,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	mov		fNoRead,FALSE
	ret

CmndCreate endp

CmndWorkFolder proc
	LOCAL	buffer[256]:BYTE

	mov		fNoRead,TRUE
	invoke wsprintf,addr buffer,addr szWorkFolder,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	mov		fNoRead,FALSE
	ret

CmndWorkFolder endp

CmndAdd proc uses esi,lpFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE

	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	mov		esi,offset TempPath
	invoke lstrcpy,esi,lpFile
	invoke lstrlen,esi
	xor		edx,edx
	.while eax
		.if byte ptr [esi+eax]=='\'
			mov		byte ptr [esi+eax],0
			.if !edx
				push	eax
				push	edx
				invoke SetCurrentDirectory,addr [esi+eax+1]
				pop		edx
				pop		eax
			.endif
			inc		edx
		.endif
		dec		eax
	.endw
	.while edx
		push	edx
		invoke CmndCreate,esi
		invoke CmndCP,esi
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		pop		edx
		dec		edx
	.endw
	mov		fNoRead,TRUE
	invoke wsprintf,addr buffer,addr szAdd,esi,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	mov		fNoRead,FALSE
	invoke CmndCP,addr Project
	invoke SetCurrentDirectory,addr buffer1
	ret

CmndAdd endp

CmndDel proc lpFile:DWORD
	LOCAL	buffer[256]:BYTE

	mov		fNoRead,TRUE
	invoke wsprintf,addr buffer,addr szDel,lpFile,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	mov		fNoRead,FALSE
	ret

CmndDel endp

CmndGet proc lpFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	val:DWORD

	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	invoke GetFullPathName,lpFile,sizeof buffer,addr buffer,addr val
	mov		eax,val
	mov		byte ptr [eax-1],0
	invoke SetCurrentDirectory,addr buffer
	mov		fNoRead,TRUE
	invoke wsprintf,addr buffer,addr szGet,lpFile,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	mov		fNoRead,FALSE
	invoke SetCurrentDirectory,addr buffer1
	ret

CmndGet endp

CmndCheckInKeepOut proc lpFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	val:DWORD

	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	invoke GetFullPathName,lpFile,sizeof buffer,addr buffer,addr val
	mov		eax,val
	mov		byte ptr [eax-1],0
	invoke SetCurrentDirectory,addr buffer
	mov		fNoRead,TRUE
	invoke wsprintf,addr buffer,addr szCheckInKeepOut,lpFile,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	mov		fNoRead,FALSE
	invoke SetCurrentDirectory,addr buffer1
	ret

CmndCheckInKeepOut endp

CmndCheckIn proc lpFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	val:DWORD

	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	invoke GetFullPathName,lpFile,sizeof buffer,addr buffer,addr val
	mov		eax,val
	mov		byte ptr [eax-1],0
	invoke SetCurrentDirectory,addr buffer
	mov		fNoRead,TRUE
	invoke wsprintf,addr buffer,addr szCheckIn,lpFile,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	mov		fNoRead,FALSE
	invoke SetCurrentDirectory,addr buffer1
	ret

CmndCheckIn endp

CmndUndoCheckOut proc lpFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	val:DWORD

	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	invoke GetFullPathName,lpFile,sizeof buffer,addr buffer,addr val
	mov		eax,val
	mov		byte ptr [eax-1],0
	invoke SetCurrentDirectory,addr buffer
	mov		fNoRead,TRUE
	invoke wsprintf,addr buffer,addr szUndoCheckOut,lpFile,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	mov		fNoRead,FALSE
	invoke SetCurrentDirectory,addr buffer1
	ret

CmndUndoCheckOut endp

CmndCheckOut proc lpFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	val:DWORD

	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	invoke GetFullPathName,lpFile,sizeof buffer,addr buffer,addr val
	mov		eax,val
	mov		byte ptr [eax-1],0
	invoke SetCurrentDirectory,addr buffer
	mov		fNoRead,TRUE
	invoke wsprintf,addr buffer,addr szCheckOut,lpFile,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	mov		fNoRead,FALSE
	invoke SetCurrentDirectory,addr buffer1
	ret

CmndCheckOut endp

CmndDifference proc uses esi,lpFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	val:DWORD

	invoke GetCurrentDirectory,sizeof buffer1,addr buffer1
	invoke GetFullPathName,lpFile,sizeof buffer,addr buffer,addr val
	mov		eax,val
	mov		byte ptr [eax-1],0
	invoke SetCurrentDirectory,addr buffer
	invoke lstrcpy,offset TempPath,lpFile
	invoke lstrlen,offset TempPath
	xor		edx,edx
	.while eax
		.if byte ptr TempPath[eax]=='\'
			mov		byte ptr TempPath[eax],0
			inc		edx
		.endif
		dec		eax
	.endw
	mov		esi,offset TempPath
	.while edx
		push	edx
		invoke CmndCP,esi
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		pop		edx
		dec		edx
	.endw
	invoke wsprintf,addr buffer,addr szDifference,esi,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	invoke InStrng,addr Result,addr szNoDifference
	inc		eax
	.if ZERO?
		;Changed
		inc		eax
	.else
		xor		eax,eax
	.endif
	push	eax
	invoke CmndCP,addr Project
	invoke SetCurrentDirectory,addr buffer1
	pop		eax
	ret

CmndDifference endp

;Check if file is checked out
CmndStatus proc uses esi,lpFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE

	invoke lstrcpy,offset TempPath,lpFile
	invoke lstrlen,offset TempPath
	xor		edx,edx
	.while eax
		.if byte ptr TempPath[eax]=='\'
			mov		byte ptr TempPath[eax],0
			inc		edx
		.endif
		dec		eax
	.endw
	mov		esi,offset TempPath
	.while edx
		push	edx
		invoke CmndCP,esi
		invoke lstrlen,esi
		lea		esi,[esi+eax+1]
		pop		edx
		dec		edx
	.endw
	invoke wsprintf,addr buffer,addr szStatus,esi,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	invoke InStrng,addr Result,addr szNoFiles
	inc		eax
	.if ZERO?
		;Project exists
		inc		eax
	.else
		xor		eax,eax
	.endif
	push	eax
	invoke CmndCP,addr Project
	pop		eax
	ret

CmndStatus endp

;Check if file is checked out, no project
CmndStatusNoP proc lpFile:DWORD
	LOCAL	buffer[256]:BYTE

	invoke wsprintf,addr buffer,addr szStatusNoP,lpFile,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	invoke InStrng,addr Result,addr szNoFiles
	inc		eax
	.if ZERO?
		;Project exists
		inc		eax
	.else
		xor		eax,eax
	.endif
	ret

CmndStatusNoP endp

;Check if file is added to project
CmndProperties proc lpFile:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[MAX_PATH]:BYTE
	LOCAL	buffer2[MAX_PATH]:BYTE
	LOCAL	val:DWORD

	invoke wsprintf,addr buffer,addr szProperties,lpFile,addr UserName,addr PassWord
	invoke SourceSafe,addr buffer
	xor		eax,eax
	mov		ecx,offset Result
	.while byte ptr [ecx]
		.if byte ptr [ecx]==VK_RETURN
			inc		eax
		.endif
		inc		ecx
	.endw
	.if eax<3
		;File is not added to project
		xor		eax,eax
	.endif
	ret

CmndProperties endp

CmndRename proc lpOldFile:DWORD,lpNewFile:DWORD
	LOCAL	buffold[MAX_PATH]:BYTE
	LOCAL	buffnew[MAX_PATH]:BYTE

	mov		fNoRead,TRUE
	invoke wsprintf,addr FileName,addr szRename,lpOldFile,lpNewFile,addr UserName,addr PassWord
	invoke SourceSafe,addr FileName
	mov		fNoRead,FALSE
	ret

CmndRename endp

GetItem proc uses ebx
	LOCAL	tvi:TV_ITEMEX

	mov		ebx,lpHandles
	mov		ebx,[ebx].ADDINHANDLES.hPbrTrv
	invoke SendMessage,ebx,TVM_GETNEXTITEM,TVGN_CARET,0
	.if eax
		mov		tvi.hItem,eax
		mov		tvi.imask,TVIF_PARAM
		invoke SendMessage,ebx,TVM_GETITEM,0,addr tvi
		.if tvi.lParam
			mov		eax,tvi.lParam
			mov		nFileID,eax
		.endif
	.endif
	ret

GetItem endp

CheckLoadedEnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

    invoke GetWindowLong,hWin,GWL_ID
    .if eax>=ID_FIRSTCHILD && eax<=ID_LASTCHILD
		invoke GetWindowLong,hWin,0
		.if eax==ID_EDIT || eax==ID_EDITTXT
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke lstrcmpi,lParam,addr buffer
			.if !eax
				mov		eax,hWin
				mov		hFound,eax
				xor		eax,eax
				ret
			.endif
		.endif
	.endif
	mov		eax,TRUE
	ret

CheckLoadedEnumProc endp

CheckLoadedDlgEnumProc proc hWin:HWND,lParam:LPARAM
	LOCAL	buffer[MAX_PATH]:BYTE

    invoke GetWindowLong,hWin,GWL_ID
    .if eax>=ID_FIRSTCHILD &&  eax<=ID_LASTCHILD
		invoke GetWindowLong,hWin,0
		.if eax==ID_DIALOG
			invoke GetWindowText,hWin,addr buffer,sizeof buffer
			invoke lstrcmpi,lParam,addr buffer
			.if !eax
				mov		eax,hWin
				mov		hFound,eax
				xor		eax,eax
				ret
			.endif
		.endif
	.endif
	mov		eax,TRUE
	ret

CheckLoadedDlgEnumProc endp

IsLoaded proc lpFileName:DWORD
	LOCAL	vTmp:DWORD
	LOCAL	hCld:HWND

	mov		hFound,0
	mov		fChanged,0
	mov		eax,lpHandles
	mov		eax,[eax].ADDINHANDLES.hClient
	invoke EnumChildWindows,eax,addr CheckLoadedEnumProc,lpFileName
	.if hFound
		invoke GetWindowLong,hFound,GWL_USERDATA
		mov		hCld,eax
		invoke GetFileAttributes,lpFileName
		and		eax,FILE_ATTRIBUTE_READONLY
		.if eax
			mov		eax,TRUE
		.endif
		invoke SendMessage,hCld,REM_READONLY,0,eax
		invoke SendMessage,hCld,WM_PAINT,0,0
		invoke SendMessage,hCld,EM_GETMODIFY,0,0
		mov		fChanged,eax
		mov		nFileType,ID_EDIT
	.else
		mov		eax,lpHandles
		mov		eax,[eax].ADDINHANDLES.hClient
		invoke EnumChildWindows,eax,addr CheckLoadedDlgEnumProc,lpFileName
		.if hFound
			invoke GetFileAttributes,lpFileName
			and		eax,FILE_ATTRIBUTE_READONLY
			mov		vTmp,eax
			invoke SetWindowLong,hFound,8,eax
			invoke GetWindowLong,hFound,4
			.if eax
				mov		eax,(DLGHEAD ptr [eax]).changed
				mov		fChanged,eax
			.endif
			push	vTmp
			push	hFound
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpUpdateSizeingRect
			mov		nFileType,ID_DIALOG
		.endif
	.endif
	mov		eax,hFound
	ret

IsLoaded endp

UpdateItem proc uses ebx,iNbr:DWORD
	LOCAL	hItem:DWORD
	LOCAL	hChild:DWORD
	LOCAL	tvi:TV_ITEMEX
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	vTmp:DWORD

	mov		ebx,lpHandles
	mov		ebx,[ebx].ADDINHANDLES.hPbrTrv
	invoke SendMessage,ebx,TVM_GETNEXTITEM,TVGN_ROOT,0
	.while eax
		mov		hItem,eax
		invoke SendMessage,ebx,TVM_GETNEXTITEM,TVGN_CHILD,eax
		.while eax
			mov		hChild,eax
			mov		tvi.hItem,eax
			mov		tvi.imask,TVIF_PARAM or TVIF_IMAGE or TVIF_SELECTEDIMAGE or TVIF_TEXT
			lea		eax,buffer
			mov		tvi.pszText,eax
			mov		tvi.cchTextMax,sizeof buffer
			invoke SendMessage,ebx,TVM_GETITEM,0,addr tvi
			mov		eax,tvi.lParam
			.if	eax==iNbr
				mov		tvi.imask,TVIF_IMAGE or TVIF_SELECTEDIMAGE
				mov		eax,lpData
				mov		eax,[eax].ADDINDATA.lpProjectPath
				invoke lstrcpy,addr buffer1,eax
				invoke lstrcat,addr buffer1,addr buffer
				invoke GetFullPathName,addr buffer1,sizeof buffer,addr buffer,addr vTmp
				lea		eax,buffer
				push	eax
				mov		eax,lpProc
				mov		eax,[eax].ADDINPROCS.lpGetFileType
				call	eax
				.if	iNbr>=1000
					.if	eax==9
						mov		eax,1
					.elseif	eax==3
						mov		eax,10
					.endif
				.endif
				.if	eax>=30
					mov		eax,7
				.endif
				push	eax
				invoke GetFileAttributes,addr buffer
				and		eax,FILE_ATTRIBUTE_READONLY
				pop		edx
				.if eax
					add		edx,11
				.endif
				add		edx,46
				mov		tvi.iImage,edx
				mov		tvi.iSelectedImage,edx
				invoke SendMessage,ebx,TVM_SETITEM,0,addr tvi
				invoke IsLoaded,addr buffer
				ret
			.endif
			invoke SendMessage,ebx,TVM_GETNEXTITEM,TVGN_NEXT,hChild
		.endw
		invoke SendMessage,ebx,TVM_GETNEXTITEM,TVGN_NEXT,hItem
		.if !eax
			invoke SendMessage,ebx,TVM_GETNEXTITEM,TVGN_CHILD,hItem
		.endif
	.endw
	ret

UpdateItem endp

AddProjectDlgProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nID:DWORD
	LOCAL	nMiss:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	hMem:DWORD
	LOCAL	nMatch:DWORD
	LOCAL	fCP:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,64*1024
		mov		hMem,eax
		mov		edi,eax
		mov		ebx,lpProc
		mov		ebx,[ebx].ADDINPROCS.lpGetFileNameFromID
		invoke CmndCP,addr Project
		mov		fCP,eax
		mov		nMatch,0
		mov		nMiss,0
		mov		nID,1
		.while nID<1500
			push	nID
			call	ebx
			.if eax
				.if byte ptr [eax]!='.'
					mov		esi,eax
					xor		eax,eax
					.if fCP
						;Project exists
						;Check if file is added to project
						invoke CmndProperties,esi
					.endif
					push	eax
					push	eax
					push	esi
					push	edi
					lea		edi,[esi+eax]
					mov		esi,hMem
					.while byte ptr [esi]
						invoke lstrcmpi,esi,edi
						.if !eax
							invoke wsprintf,addr buffer,addr szDuplicate,esi
							invoke MessageBox,hWin,addr buffer,addr szError,MB_OK or MB_ICONSTOP
							inc		nMatch
						.endif
						invoke lstrlen,esi
						lea		esi,[esi+eax+1]
					.endw
					pop		edi
					pop		esi
					pop		eax
					invoke lstrcpy,edi,addr [esi+eax]
					invoke lstrlen,edi
					lea		edi,[edi+eax+1]
					pop		eax
					.if !eax
						;File is not added to project, add it
						invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_ADDSTRING,0,esi
						push	eax
						invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETITEMDATA,eax,nID
						pop		eax
						invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETSEL,TRUE,eax
					.endif
				.endif
				mov		nMiss,0
			.else
				inc		nMiss
				.if nMiss>20
					.if nID>1000
						.break
					.endif
					mov		nMiss,0
					mov		nID,1000
				.endif
			.endif
			inc		nID
		.endw
		invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETCARETINDEX,0,0
		.if fCP
			;Project exists
			invoke GetDlgItem,hWin,IDC_EDTGROUP
			invoke EnableWindow,eax,FALSE
		.endif
		invoke SetDlgItemText,hWin,IDC_EDTGROUP,addr Project
		.if nMatch
			;Duplicate files
			invoke GetDlgItem,hWin,1
			invoke EnableWindow,eax,FALSE
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetCursor
				push	eax
				invoke LoadCursor,NULL,IDC_WAIT
				invoke SetCursor,eax
				invoke GetDlgItemText,hWin,IDC_EDTGROUP,addr Project,sizeof Project
				mov		eax,lpData
				mov		eax,[eax].ADDINDATA.lpProject
				invoke WritePrivateProfileString,addr szSourceSafe,addr szProject,addr Project,eax
				invoke CmndCP,addr Project
				.if !eax
					;Create the project
					invoke CmndCreate,offset Project
					;Set active
					invoke CmndCP,addr Project
					;Set working folder
					invoke CmndWorkFolder
				.endif
				mov		nID,0
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETSEL,nID,0
					.break .if eax==LB_ERR
					.if eax
						invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,nID,addr buffer
						invoke CmndAdd,addr buffer
						invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETITEMDATA,nID,0
						invoke UpdateItem,eax
					.endif
					inc		nID
				.endw
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				pop		eax
				invoke SetCursor,eax
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

AddProjectDlgProc endp

GetProjectDlgProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nID:DWORD
	LOCAL	nMiss:DWORD
	LOCAL	buffer[256]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke CmndCP,addr Project
		.if eax
			;Project exists
			mov		ebx,lpProc
			mov		ebx,[ebx].ADDINPROCS.lpGetFileNameFromID
			mov		nMiss,0
			mov		nID,1
			.while nID<1500
				push	nID
				call	ebx
				.if eax
					mov		esi,eax
					;Check if file is added to project
					invoke CmndProperties,esi
					.if eax
						;File is added to project
						;Check if file is checked out, no project
						invoke CmndStatusNoP,esi
						.if !eax
							;File is not checked out
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_ADDSTRING,0,esi
							push	eax
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETITEMDATA,eax,nID
							pop		eax
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETSEL,TRUE,eax
						.endif
					.endif
					mov		nMiss,0
				.else
					inc		nMiss
					.if nMiss>20
						.if nID>1000
							.break
						.endif
						mov		nMiss,0
						mov		nID,1000
					.endif
				.endif
				inc		nID
			.endw
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETCARETINDEX,0,0
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetCursor
				push	eax
				invoke LoadCursor,NULL,IDC_WAIT
				invoke SetCursor,eax
				invoke CmndCP,addr Project
				mov		nID,0
				.while TRUE
					invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETSEL,nID,0
					.break .if eax==LB_ERR
					.if eax
						invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,nID,addr buffer
						invoke CmndGet,addr buffer
						invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETITEMDATA,nID,0
						invoke UpdateItem,eax
					.endif
					inc		nID
				.endw
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				pop		eax
				invoke SetCursor,eax
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

GetProjectDlgProc endp

CheckInDlgProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nID:DWORD
	LOCAL	nMiss:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	vTmp:DWORD
	LOCAL	fKeepCheckedOut:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke CmndCP,addr Project
		.if eax
			;Project exist
			mov		ebx,lpProc
			mov		ebx,[ebx].ADDINPROCS.lpGetFileNameFromID
			mov		nMiss,0
			mov		nID,1
			.while nID<1500
				push	nID
				call	ebx
				.if eax
					mov		esi,eax
					;Check if file is added to project
					invoke CmndProperties,esi
					.if eax
						;File is added to project
						;Check if file is checked out
						invoke CmndStatus,esi
						.if eax
							;File is checked out
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_ADDSTRING,0,esi
							push	eax
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETITEMDATA,eax,nID
							pop		eax
							mov		edx,nID
							.if edx==nFileID
								invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETSEL,TRUE,eax
							.endif
						.endif
					.endif
					mov		nMiss,0
				.else
					inc		nMiss
					.if nMiss>20
						.if nID>1000
							.break
						.endif
						mov		nMiss,0
						mov		nID,1000
					.endif
				.endif
				inc		nID
			.endw
			invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_SETCARETINDEX,0,0
		.endif
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke GetCursor
				push	eax
				invoke LoadCursor,NULL,IDC_WAIT
				invoke SetCursor,eax
				invoke CmndCP,addr Project
				.if eax
					;Project exist
					invoke IsDlgButtonChecked,hWin,IDC_CHKCHECKOUT
					mov		fKeepCheckedOut,eax
					lea		esi,buffer
					mov		nID,0
					.while TRUE
						invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETSEL,nID,0
						.break .if eax==LB_ERR
						.if eax
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,nID,esi
							mov		eax,lpData
							mov		eax,[eax].ADDINDATA.lpProjectPath
							invoke lstrcpy,addr Result,eax
							invoke lstrcat,addr Result,esi
							invoke GetFullPathName,addr Result,sizeof buffer,esi,addr vTmp
							invoke IsLoaded,esi
							.if fChanged
								mov		eax,lpProc
								.if nFileType==ID_EDIT
									push	hFound
									call	[eax].ADDINPROCS.lpSaveEdit
								.elseif nFileType==ID_DIALOG
									push	FALSE
									push	hFound
									call	[eax].ADDINPROCS.lpSaveDialog
								.endif
							.endif
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETTEXT,nID,esi
							.if fKeepCheckedOut
								invoke CmndCheckInKeepOut,esi
							.else
								invoke CmndCheckIn,esi
							.endif
							invoke SendDlgItemMessage,hWin,IDC_LSTFILES,LB_GETITEMDATA,nID,0
							invoke UpdateItem,eax
						.endif
						inc		nID
					.endw
				.endif
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				pop		eax
				invoke SetCursor,eax
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

CheckInDlgProc endp

AddMenu proc nID:DWORD,lpText:DWORD

	mov		edx,4
	;Adjust topmost popup if maximized
	mov		eax,[lpData]
	.if [eax].ADDINDATA.fMaximized
		inc		edx
	.endif
	;Get handle of Project popup
	mov		eax,[lpHandles]
	invoke GetSubMenu,[eax].ADDINHANDLES.hMenu,edx
	;Add our menuitem
	invoke AppendMenu,eax,MF_STRING,nID,lpText
	ret

AddMenu endp

AddProMenu proc nID:DWORD,lpText:DWORD

	mov		edx,4
	;Get handle of Project popup
	mov		eax,[lpHandles]
	invoke GetSubMenu,[eax].ADDINHANDLES.hToolMenu,0
	;Add our menuitem
	.if lpText
		invoke AppendMenu,eax,MF_STRING,nID,lpText
	.else
		invoke AppendMenu,eax,MF_SEPARATOR,nID,NULL
	.endif
	ret

AddProMenu endp

InstallDll proc uses ebx hWin:DWORD,fOpt:DWORD

	mov		ebx,hWin
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov		lpHandles,eax
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov		lpProc,eax
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov		lpData,eax
	.if [eax].ADDINDATA.nRadASMVer>=2202
		mov		eax,fOpt
		mov		fOption,eax
		; Allocate menu id's
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDRunSS,eax
		invoke AddMenu,eax,addr szMnuRunSS
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDAddFiles,eax
		invoke AddMenu,eax,addr szMnuAddFiles
		mov		eax,[lpHandles]
		invoke EnableMenuItem,[eax].ADDINHANDLES.hMenu,IDAddFiles,MF_BYCOMMAND or MF_GRAYED
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDSeparator,eax
		invoke AddProMenu,eax,NULL
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDCheckIn,eax
		invoke AddProMenu,eax,addr szMnuCheckIn
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDCheckOut,eax
		invoke AddProMenu,eax,addr szMnuCheckOut
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDUndoCheckOut,eax
		invoke AddProMenu,eax,addr szMnuUndoCheckOut
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov		IDGetLatest,eax
		invoke AddProMenu,eax,addr szMnuGetLatest
		mov		ebx,lpData
		mov		ebx,[ebx].ADDINDATA.lpIniFile
		invoke GetPrivateProfileString,addr szSourceSafe,addr szPath,addr szNULL,addr Path,sizeof Path,ebx
		invoke GetPrivateProfileString,addr szSourceSafe,addr szUserName,addr szNULL,addr UserName,sizeof UserName,ebx
		invoke GetPrivateProfileString,addr szSourceSafe,addr szPassWord,addr szNULL,addr PassWord,sizeof PassWord,ebx
		; Messages to hook into
		mov		eax,RAM_COMMAND or RAM_CLOSE or RAM_PROJECTOPENED or RAM_PROJECTCLOSED or RAM_CONTEXTMENU or RAM_PROJECTADDNEW or RAM_PROJECTREMOVE
		mov		ecx,RAM_PROJECTRENAME
	.else
		xor		eax,eax
		xor		ecx,ecx
	.endif
	; EDX must be null before we return
	xor		edx,edx
	ret 

InstallDll Endp

GetOptions proc
	
	mov		eax,offset AddinOpt
	ret

GetOptions endp

DllProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	vTmp:DWORD

	mov		eax,uMsg
	.if eax==AIM_COMMAND
		mov		eax,wParam
		movzx	edx,ax
		shr		eax,16
		.if eax==BN_CLICKED
			.if edx==IDRunSS
				invoke CmndCP,addr Project
				invoke wsprintf,addr buffer,addr szRun,offset UserName,offset PassWord
				invoke ShellExecute,hWin,NULL,addr szRunSSEXP,addr buffer,addr Path,SW_SHOW
			.elseif edx==IDAddFiles
				invoke DialogBoxParam,hInstance,IDD_DLGADDFILES,hWin,addr AddProjectDlgProc,NULL
			.elseif edx==IDCheckIn
				invoke DialogBoxParam,hInstance,IDD_DLGCHECKIN,hWin,addr CheckInDlgProc,NULL
			.elseif edx==IDCheckOut
				.if nFileID
					invoke CmndCP,addr Project
					.if eax
						mov		eax,lpProc
						mov		eax,[eax].ADDINPROCS.lpGetFileNameFromID
						push	nFileID
						call	eax
						.if eax
							invoke CmndCheckOut,eax
							invoke UpdateItem,nFileID
						.endif
					.endif
				.endif
			.elseif edx==IDUndoCheckOut
				.if nFileID
					invoke CmndCP,addr Project
					.if eax
						mov		eax,lpProc
						mov		eax,[eax].ADDINPROCS.lpGetFileNameFromID
						push	nFileID
						call	eax
						.if eax
							mov		esi,eax
							mov		eax,lpData
							mov		eax,[eax].ADDINDATA.lpProjectPath
							invoke lstrcpy,addr buffer,eax
							invoke lstrcat,addr buffer,esi
							invoke GetFullPathName,addr buffer,sizeof buffer,addr buffer,addr vTmp
							invoke IsLoaded,addr buffer
							invoke CmndDifference,esi
							.if eax || fChanged
								invoke wsprintf,addr Result,addr szChanged,addr buffer
								invoke MessageBox,hWin,addr Result,addr szSourceSafe,MB_ICONQUESTION or MB_YESNO
								.if eax==IDNO
									jmp		Ex
								.endif
							.endif
							.if hFound
								.if fChanged
									.if nFileType==ID_EDIT
										invoke GetWindowLong,hFound,GWL_USERDATA
										invoke SendMessage,eax,EM_SETMODIFY,FALSE,0
									.elseif nFileType==ID_DIALOG
										invoke GetWindowLong,hFound,4
										mov		[eax].DLGHEAD.changed,FALSE
									.endif
								.endif
								invoke SendMessage,hFound,WM_CLOSE,0,0
								invoke CmndUndoCheckOut,esi
								invoke UpdateItem,nFileID
								mov		edx,lpData
								invoke lstrcpy,[edx].ADDINDATA.lpFile,addr buffer
								mov		eax,lpProc
								push	TRUE
								call	[eax].ADDINPROCS.lpOpenProjectFile
							.else
								invoke CmndUndoCheckOut,esi
								invoke UpdateItem,nFileID
							.endif
						.endif
					.endif
				.endif
			.elseif edx==IDGetLatest
				invoke DialogBoxParam,hInstance,IDD_DLGGETFILES,hWin,addr GetProjectDlgProc,NULL
			.endif
		.endif
	.elseif eax==AIM_CLOSE
		;Remove all menu items
		mov		ebx,lpHandles
		mov		ebx,[ebx].ADDINHANDLES.hMenu
		invoke DeleteMenu,ebx,IDRunSS,MF_BYCOMMAND
		invoke DeleteMenu,ebx,IDAddFiles,MF_BYCOMMAND
		mov		ebx,lpHandles
		mov		ebx,[ebx].ADDINHANDLES.hToolMenu
		invoke DeleteMenu,ebx,IDSeparator,MF_BYCOMMAND
		invoke DeleteMenu,ebx,IDCheckIn,MF_BYCOMMAND
		invoke DeleteMenu,ebx,IDCheckOut,MF_BYCOMMAND
		invoke DeleteMenu,ebx,IDUndoCheckOut,MF_BYCOMMAND
		invoke DeleteMenu,ebx,IDGetLatest,MF_BYCOMMAND
	.elseif eax==AIM_PROJECTCLOSED
		mov		eax,[lpHandles]
		invoke EnableMenuItem,[eax].ADDINHANDLES.hMenu,IDAddFiles,MF_BYCOMMAND or MF_GRAYED
		mov		Project,0
	.elseif eax==AIM_PROJECTOPENED
		mov		eax,lpData
		mov		eax,[eax].ADDINDATA.lpProject
		invoke GetPrivateProfileString,addr szSourceSafe,addr szProject,addr szNULL,addr Project,sizeof Project,eax
		.if !eax
			invoke lstrcpy,addr Project,addr szRoot
			mov		eax,lpData
			mov		eax,[eax].ADDINDATA.lpProject
			invoke lstrcpy,addr buffer,eax
			invoke lstrlen,addr buffer
			lea		edx,buffer
			.while eax
				.if byte ptr [edx+eax]=='.'
					mov		byte ptr [edx+eax],0
				.elseif byte ptr [edx+eax-1]=='\'
					.break
				.endif
				dec		eax
			.endw
			invoke lstrcat,addr Project,addr [edx+eax]
		.endif
		invoke CmndCP,addr Project
		mov		eax,[lpHandles]
		invoke EnableMenuItem,[eax].ADDINHANDLES.hMenu,IDAddFiles,MF_BYCOMMAND or MF_ENABLED
	.elseif eax==AIM_PROJECTADDNEW
		invoke CmndCP,addr Project
		.if eax
			;Project exists
			invoke wsprintf,addr Result,addr szAddNew,lParam
			invoke MessageBox,hWin,addr Result,addr szSourceSafe,MB_ICONQUESTION or MB_YESNO
			.if eax==IDYES
				lea		eax,buffer
				push	eax
				push	lParam
				mov		eax,lpProc
				call	[eax].ADDINPROCS.lpRemoveProjectPath
				invoke lstrcpy,addr buffer,eax
				invoke CmndAdd,addr buffer
				mov		nFileID,0
				invoke GetItem
				.if nFileID
					invoke UpdateItem,nFileID
				.endif
			.endif
		.endif
	.elseif eax==AIM_PROJECTRENAME
		invoke CmndCP,addr Project
		.if eax
			;Project exists
			;Check if file is added to project
			invoke CmndProperties,wParam
			.if eax
				;File is added to project, rename it
				invoke CmndRename,wParam,lParam
			.endif
		.endif
	.elseif eax==AIM_PROJECTREMOVE
		invoke CmndCP,addr Project
		.if eax
			;Project exists
			lea		eax,buffer
			push	eax
			push	lParam
			mov		eax,lpProc
			call	[eax].ADDINPROCS.lpRemoveProjectPath
			invoke lstrcpy,addr buffer,eax
			;Check if file is added to project
			invoke CmndProperties,addr buffer
			.if eax
				;File is added to project, prompt to remove it
				invoke wsprintf,addr Result,addr szRemoveFile,lParam
				invoke MessageBox,hWin,addr Result,addr szSourceSafe,MB_ICONQUESTION or MB_YESNO
				.if eax==IDYES
					invoke CmndDel,addr buffer
				.endif
			.endif
		.endif
	.elseif eax==AIM_CONTEXTMENU
		mov		nFileID,0
		mov		ebx,[lpHandles]
		mov		ebx,[ebx].ADDINHANDLES.hToolMenu
		mov		eax,lpData
		.if [eax].ADDINDATA.fProject
			mov		eax,[eax].ADDINDATA.lpProject
			invoke GetPrivateProfileString,addr szSourceSafe,addr szProject,addr szNULL,addr buffer,sizeof buffer,eax
			.if eax
				invoke CmndCP,addr Project
			.endif
		.else
			xor		eax,eax
		.endif
		.if eax
			mov		eax,lpHandles
			mov		eax,[eax].ADDINHANDLES.hPbr
			.if eax==hWin
				mov		eax,lpHandles
				mov		eax,[eax].ADDINHANDLES.hPbrTrv
				invoke IsWindowVisible,eax
				.if eax
					invoke GetItem
				.endif
			.endif
			.if nFileID
				mov		eax,lpProc
				mov		eax,[eax].ADDINPROCS.lpGetFileNameFromID
				push	nFileID
				call	eax
				.if eax
					mov		esi,eax
					;Check if file is added to project
					invoke CmndProperties,esi
					.if eax
						;File is added to project
						;Check if file is checked out, no project
						invoke CmndStatusNoP,esi
						.if eax
							;Checked out
							invoke EnableMenuItem,ebx,IDCheckOut,MF_BYCOMMAND or MF_GRAYED
							;Check if file is checked out to this project
							invoke CmndStatus,esi
							.if eax
								invoke EnableMenuItem,ebx,IDUndoCheckOut,MF_BYCOMMAND or MF_ENABLED
							.else
								invoke EnableMenuItem,ebx,IDUndoCheckOut,MF_BYCOMMAND or MF_GRAYED
							.endif
						.else
							;Checked in
							invoke EnableMenuItem,ebx,IDCheckOut,MF_BYCOMMAND or MF_ENABLED
							invoke EnableMenuItem,ebx,IDUndoCheckOut,MF_BYCOMMAND or MF_GRAYED
						.endif
					.else

						;File not added to project
						invoke EnableMenuItem,ebx,IDCheckOut,MF_BYCOMMAND or MF_GRAYED
						invoke EnableMenuItem,ebx,IDUndoCheckOut,MF_BYCOMMAND or MF_GRAYED
					.endif
				.endif
			.else
				;No file selected
				invoke EnableMenuItem,ebx,IDCheckOut,MF_BYCOMMAND or MF_GRAYED
				invoke EnableMenuItem,ebx,IDUndoCheckOut,MF_BYCOMMAND or MF_GRAYED
			.endif
			invoke EnableMenuItem,ebx,IDCheckIn,MF_BYCOMMAND or MF_ENABLED
			invoke EnableMenuItem,ebx,IDGetLatest,MF_BYCOMMAND or MF_ENABLED
		.else
			;Project not added to source safe
			invoke EnableMenuItem,ebx,IDCheckIn,MF_BYCOMMAND or MF_GRAYED
			invoke EnableMenuItem,ebx,IDCheckOut,MF_BYCOMMAND or MF_GRAYED
			invoke EnableMenuItem,ebx,IDUndoCheckOut,MF_BYCOMMAND or MF_GRAYED
			invoke EnableMenuItem,ebx,IDGetLatest,MF_BYCOMMAND or MF_GRAYED
		.endif
	.endif
  Ex:
	mov eax,FALSE
	ret

DllProc Endp

;#########################################################################

End DllEntry
