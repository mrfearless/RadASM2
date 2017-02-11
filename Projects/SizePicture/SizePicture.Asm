.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include SizePicture.inc
include GdiPluss.asm

.code

;########################################################################

BrowseFolder proc hWin:HWND,nID:DWORD,lpCaption:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		bri.pidlRoot,0
	mov		bri.pszDisplayName,0
	mov		eax,lpCaption
	mov		bri.lpszTitle,eax
	mov		bri.ulFlags,BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT 
	mov		bri.lpfn,BrowseCallbackProc
	; get path   
	invoke SendDlgItemMessage,hWin,nID,WM_GETTEXT,sizeof buffer,addr buffer
	lea		eax,buffer
	mov		bri.lParam,eax 
	mov		bri.iImage,0
	invoke SHBrowseForFolder,offset bri
	.if !eax
		jmp		GetOut
	.endif      
	mov		pidl,eax
	invoke SHGetPathFromIDList,pidl,addr buffer
	; set new path back to edit
	invoke SendDlgItemMessage,hWin,nID,WM_SETTEXT,0,addr buffer
  GetOut:
	ret

BrowseFolder endp

;--------------------------------------------------------------------------------
; set initial folder in browser
BrowseCallbackProc proc hwnd:DWORD,uMsg:UINT,lParam:LPARAM,lpData:DWORD

	mov eax,uMsg
	.if eax==BFFM_INITIALIZED
		invoke PostMessage,hwnd,BFFM_SETSELECTION,TRUE,lpData
	.endif
	xor eax, eax
	ret

BrowseCallbackProc endp

ScanDir proc lpPth:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hwfd:DWORD

	;Make the path local
	invoke lstrcpy,addr buffer,lpPth
	;Check if path ends with '\'. If not add.
	invoke lstrlen,addr buffer
	dec		eax
	mov		al,buffer[eax]
	.if al!='\'
		invoke lstrcat,addr buffer,addr szBackSlash
	.endif
	;Add '*.jpg'
	invoke lstrcat,addr buffer,addr szJPG
	;Find first match, if any
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		;Save returned handle
		mov		hwfd,eax
	  Next:
		;Check if found is a dir
		mov		eax,wfd.dwFileAttributes
		and		eax,FILE_ATTRIBUTE_DIRECTORY
		.if eax
			;Do not include '.' and '..'
			mov		al,wfd.cFileName
			.if al!='.'
				invoke lstrlen,addr buffer
				mov		edx,eax
				push	edx
				sub		edx,3
				;Do not remove the '\'
				mov		al,buffer[edx]
				.if al=='\'
					inc		edx
				.endif
				;Add new dir to path
				invoke lstrcpy,addr buffer[edx],addr wfd.cFileName
				;Call myself again, thats recursive!
				invoke ScanDir,addr buffer
				pop		edx
				;Remove what was added
				mov		buffer[edx],0
			.endif
		.else
			invoke lstrlen,addr wfd.cFileName
			.if eax>4
				invoke lstrcmpi,addr wfd.cFileName[eax-3],offset DefJpgExt
				.if !eax
					;Add file
					invoke lstrcpy,offset OpenFileName,addr buffer
					invoke lstrlen,offset OpenFileName
					.while eax && OpenFileName[eax-1]!='\'
						dec		eax
					.endw
					mov		OpenFileName[eax],0
					invoke lstrcat,offset OpenFileName,addr wfd.cFileName
					.if DestPath
						invoke lstrcpy,offset SaveFileName,offset DestPath
						invoke wsprintf,offset Temp,offset szFmt,Inx
						invoke lstrcat,offset SaveFileName,offset Temp
						inc		Inx
						invoke GetImage,offset OpenFileName,PIXWT,PIXHT,offset SaveFileName
						invoke SendDlgItemMessage,hDlg,IDC_IMG1,STM_SETIMAGE,IMAGE_BITMAP,eax
						invoke DeleteObject,eax
						invoke SetDlgItemInt,hDlg,IDC_EDTINDEX,Inx,FALSE
					.else
						invoke GetImage,offset OpenFileName,PIXWT,PIXHT,0
						invoke SendDlgItemMessage,hDlg,IDC_IMG1,STM_SETIMAGE,IMAGE_BITMAP,eax
						invoke DeleteObject,eax
					.endif
				.endif
			.endif
		.endif
		.if !fCancel
			;Any more matches?
			invoke FindNextFile,hwfd,addr wfd
			or		eax,eax
			jne		Next
		.endif
		;No more matches, close find
		invoke FindClose,hwfd
	.endif
	ret

ScanDir endp

Convert proc lpPth:DWORD

	invoke ScanDir,lpPth
	xor		eax,eax
	mov		fCancel,eax
	mov		hThread,eax
	invoke SetDlgItemText,hDlg,IDC_BTNCONVERT,offset szConvert
	invoke SetDlgItemText,hDlg,IDCANCEL,offset szExit
	ret

Convert endp

DlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	tid:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hDlg,eax
		mov		esi,offset ptsize
		xor		edx,edx
		.while [esi+edx*sizeof POINT].POINT.x
			inc		edx
		.endw
		dec		edx
		invoke SendDlgItemMessage,hWin,IDC_UDNRES,UDM_SETRANGE,0,edx		; Set range
		invoke SendDlgItemMessage,hWin,IDC_UDNRES,UDM_SETPOS,0,0			; Set default value
		call	SetSize
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDM_FILE_OPEN
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				mov		eax,hWin
				mov		ofn.hwndOwner,eax
				mov		eax,hInstance
				mov		ofn.hInstance,eax
				mov		ofn.lpstrFilter,offset JPGFilterString
				mov		ofn.lpstrFile,offset OpenFileName
				mov		ofn.nMaxFile,sizeof OpenFileName
				mov		ofn.lpstrDefExt,0
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke GetImage,offset OpenFileName,PIXWT,PIXHT,0
					invoke SendDlgItemMessage,hWin,IDC_IMG1,STM_SETIMAGE,IMAGE_BITMAP,eax
					.if eax
						invoke DeleteObject,eax
					.endif
				.endif
			.elseif eax==IDM_FILE_SAVE
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,offset JPGFilterString
				mov		ofn.lpstrFile,offset SaveFileName
				mov		ofn.nMaxFile,sizeof SaveFileName
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
				mov		ofn.lpstrDefExt,offset DefJpgExt
				invoke GetSaveFileName,addr ofn
				.if eax
					invoke GetImage,offset OpenFileName,PIXWT,PIXHT,offset SaveFileName
					invoke SendDlgItemMessage,hWin,1001,STM_SETIMAGE,IMAGE_BITMAP,eax
					.if eax
						invoke DeleteObject,eax
					.endif
				.endif
			.elseif eax==IDM_FILE_EXIT || eax==IDCANCEL
				.if hThread
					mov		fCancel,TRUE
				.else
					invoke SendDlgItemMessage,hWin,1001,STM_SETIMAGE,IMAGE_BITMAP,0
					invoke DeleteObject,eax
					invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
				.endif
			.elseif eax==IDC_BTNCONVERT
				.if hThread
					invoke ResumeThread,hThread
					.if !eax
						invoke SuspendThread,hThread
						invoke SetDlgItemText,hWin,IDC_BTNCONVERT,offset szResume
					.else
						invoke SetDlgItemText,hWin,IDC_BTNCONVERT,offset szPause
					.endif
				.else
					invoke GetDlgItemText,hWin,IDC_EDTSOURCE,offset SourcePath,sizeof SourcePath
					.if SourcePath
						invoke GetDlgItemText,hWin,IDC_EDTDEST,offset DestPath,sizeof DestPath
						invoke GetDlgItemInt,hWin,IDC_EDTINDEX,NULL,FALSE
						mov		Inx,eax
						invoke CreateThread,NULL,NULL,addr Convert,offset SourcePath,NORMAL_PRIORITY_CLASS,addr tid
						mov		hThread,eax
						invoke SetDlgItemText,hWin,IDC_BTNCONVERT,offset szPause
						invoke SetDlgItemText,hWin,IDCANCEL,offset szStop
					.endif
				.endif
			.elseif eax==IDC_BTNSOURCE
				invoke BrowseFolder,hWin,IDC_EDTSOURCE,offset szBrowseSource
			.elseif eax==IDC_BTNDEST
				invoke BrowseFolder,hWin,IDC_EDTDEST,offset szBrowseDestination
			.endif
		.endif
	.elseif eax==WM_VSCROLL
		call	SetSize
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

SetSize:
	invoke SendDlgItemMessage,hWin,IDC_UDNRES,UDM_GETPOS,0,0
	and		eax,0FFFFh
	mov		edx,[eax*sizeof POINT+offset ptsize].POINT.x
	mov		PIXWT,edx
	mov		edx,[eax*sizeof POINT+offset ptsize].POINT.y
	mov		PIXHT,edx
	invoke wsprintf,addr buffer,offset szFmtSize,PIXWT,PIXHT
	invoke SetDlgItemText,hWin,IDC_STCSIZE,addr buffer
	retn

DlgProc endp

start:

	invoke GetModuleHandle,NULL
	mov		hInstance,eax

    invoke InitCommonControls
	invoke GdipInit
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

end start
