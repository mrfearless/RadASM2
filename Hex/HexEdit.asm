
;Find.dlg
IDD_HEXFINDDLG			equ 4300
IDC_BTN_REPLACE			equ 2007
IDC_BTN_REPLACEALL		equ 2008
IDC_FINDTEXT			equ 2001
IDC_REPLACETEXT			equ 2002
IDC_HEXREPLACESTATIC	equ 2009
IDC_RBN_ASCII			equ 2004
IDC_RBN_HEX				equ 2003
IDC_RBN_DOWN			equ 2005
IDC_RBN_UP				equ 2006

.data

fr					dd FR_DOWN

.data?

fres				dd ?
ft					FINDTEXTEX <>
findbuff			db 256 dup(?)
replacebuff			db 256 dup(?)

.code

OpenHexEditFile proc
	LOCAL	hWin
	LOCAL	hFile:DWORD
	LOCAL	hEdt:HWND
	LOCAL	editstream:EDITSTREAM

	invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke MakeMdiCldWin,addr HexEdCldClassName,ID_EDITHEX
		mov		hWin,eax
		invoke SetWindowText,hWin,addr FileName
		invoke GetWindowLong,hWin,GWL_USERDATA
		mov		hEdt,eax
		invoke TabToolAdd,hWin,offset FileName
		;stream the text into the rahexed control
		m2m		editstream.dwCookie,hFile
		mov		editstream.pfnCallback,offset StreamInProc
		invoke SendMessage,hEdt,EM_STREAMIN,SF_TEXT,addr editstream
		invoke CloseHandle,hFile
	.endif
	ret

OpenHexEditFile endp

OpenHex proc

	mov		hFound,0
	invoke UpdateAll,IDM_FILE_OPENFILE
	.if !hFound
		invoke OpenHexEditFile
	.endif
	ret

OpenHex endp

OpenHexEdit proc hWin:HWND

	invoke RtlZeroMemory,addr ofn,sizeof ofn
	mov		ofn.lStructSize,sizeof ofn
	m2m		ofn.hwndOwner,hWin
	m2m		ofn.hInstance,hInstance
	mov		ofn.lpstrFilter,offset ANYFilterString
	mov		ofn.lpstrFile,offset FileName
	mov		byte ptr [FileName],0
	mov		ofn.nMaxFile,sizeof FileName
	mov		ofn.lpstrDefExt,offset DefSrcExt
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
	invoke GetOpenFileName,addr ofn
	.if eax
		invoke OpenHex
	.endif
	ret

OpenHexEdit endp

SaveHexEdit proc hWin:HWND
	LOCAL	hCld:DWORD
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		hCld,eax
	invoke SendMessage,hCld,EM_GETMODIFY,0,0
	.if eax
		invoke GetWindowText,hWin,addr FileName,255
		invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			;stream the text to the file
			mov		eax,hFile
			mov		editstream.dwCookie,eax
			mov		editstream.pfnCallback,offset StreamOutProc
			invoke SendMessage,hCld,EM_STREAMOUT,SF_TEXT,addr editstream
			;Initialize the modify state to false
			invoke SendMessage,hCld,EM_SETMODIFY,FALSE,0
			invoke InvalidateRect,hCld,NULL,TRUE
			invoke CloseHandle,hFile
			invoke UpdateFileTime,hWin
			xor		eax,eax
		.else
			invoke strcpy,addr LineTxt,addr SaveFileFail
			invoke strcat,addr LineTxt,addr FileName
			invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
			mov		eax,TRUE
		.endif
	.endif
	ret

SaveHexEdit endp

SaveHexEditAs proc hWin:HWND
	LOCAL	hEdt:DWORD
	LOCAL	hFile:DWORD
	LOCAL	editstream:EDITSTREAM

	invoke GetWindowLong,hWin,GWL_USERDATA
	mov		hEdt,eax
	invoke RtlZeroMemory,addr ofn,sizeof ofn
	mov ofn.lStructSize,sizeof ofn
	push	hWin
	pop		ofn.hwndOwner
	push	hInstance
	pop		ofn.hInstance
	mov		ofn.lpstrFilter,offset ANYFilterString
	mov		ofn.lpstrFile,offset AltFileName
	mov		byte ptr [AltFileName],0
	mov		ofn.nMaxFile,sizeof AltFileName
	mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST or OFN_OVERWRITEPROMPT
	mov		ofn.lpstrDefExt,NULL;offset DefSrcExt
	invoke GetSaveFileName,addr ofn
	.if eax
		invoke CreateFile,addr AltFileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
		.if eax!=INVALID_HANDLE_VALUE
			mov		hFile,eax
			invoke strcpy,addr FileName,addr AltFileName
			invoke SetWindowText,hWin,addr FileName
			;stream the text to the file
			mov		eax,hFile
			mov		editstream.dwCookie,eax
			mov		editstream.pfnCallback,offset StreamOutProc
			invoke SendMessage,hEdt,EM_STREAMOUT,SF_TEXT,addr editstream
			invoke TabToolDel,hWin
			invoke TabToolAdd,hWin,offset FileName
			;Initialize the modify state to false
			invoke SendMessage,hEdt,EM_SETMODIFY,FALSE,0
			invoke CloseHandle,hFile
			xor		eax,eax
			ret
		.else
			invoke strcpy,addr LineTxt,addr SaveFileFail
			invoke strcat,addr LineTxt,addr AltFileName
			invoke MessageBox,hWin,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
		.endif
	.else
		.if hHexEd
			invoke SetFocus,hHexEd
		.endif
	.endif
	mov		eax,TRUE
	ret

SaveHexEditAs endp

HexFind proc frType:DWORD

	;Get current selection
	invoke SendMessage,hHexEd,EM_EXGETSEL,0,offset ft.chrg
	;Setup find
	mov		eax,frType
	and		eax,FR_DOWN
	.if eax
		.if fres!=-1
			and		ft.chrg.cpMin,0FFFFFFFEh
			add		ft.chrg.cpMin,2
		.endif
		mov		ft.chrg.cpMax,-1
	.else
		.if fres!=-1
			and		ft.chrg.cpMin,0FFFFFFFEh
			sub		ft.chrg.cpMin,2
		.endif
		mov		ft.chrg.cpMax,0
	.endif
	mov		ft.lpstrText,offset findbuff
	;Do the find
	invoke SendMessage,hHexEd,EM_FINDTEXTEX,frType,offset ft
	mov		fres,eax
	.if eax!=-1
		;Mark the foud text
		invoke SendMessage,hHexEd,EM_EXSETSEL,0,offset ft.chrgText
		invoke SendMessage,hHexEd,HEM_VCENTER,0,0
	.else
		;Region searched
		.if hSearch
			invoke MessageBox,hSearch,offset szSearchFinished,offset AppName,MB_OK
		.endif
	.endif
	ret

HexFind endp

HexFindDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hCtl:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hSearch,eax
		.if lParam
			mov		eax,BN_CLICKED
			shl		eax,16
			or		eax,IDC_BTN_REPLACE
			invoke PostMessage,hWin,WM_COMMAND,eax,0
		.endif
		;Put text in edit boxes
		invoke SendDlgItemMessage,hWin,IDC_FINDTEXT,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_FINDTEXT,WM_SETTEXT,0,offset findbuff
		invoke SendDlgItemMessage,hWin,IDC_REPLACETEXT,EM_LIMITTEXT,255,0
		invoke SendDlgItemMessage,hWin,IDC_REPLACETEXT,WM_SETTEXT,0,offset replacebuff
		;Set find type
		mov		eax,fr
		and		eax,FR_HEX
		.if eax
			mov		eax,IDC_RBN_HEX
		.else
			mov		eax,IDC_RBN_ASCII
		.endif
		invoke CheckDlgButton,hWin,eax,BST_CHECKED
		;Set find direction
		mov		eax,fr
		and		eax,FR_DOWN
		.if eax
			mov		eax,IDC_RBN_DOWN
		.else
			mov		eax,IDC_RBN_UP
		.endif
		invoke CheckDlgButton,hWin,eax,BST_CHECKED
		invoke MoveWin,hWin,offset PosFindLeft
		invoke SetLanguage,hWin,IDD_HEXFINDDLG,FALSE
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if edx==BN_CLICKED
			.if eax==IDOK
				;Find the text
				invoke HexFind,fr
			.elseif eax==IDCANCEL
				;Close the find dialog
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTN_REPLACE
				invoke GetDlgItem,hWin,IDC_BTN_REPLACEALL
				mov		hCtl,eax
				invoke IsWindowEnabled,hCtl
				.if !eax
					;Enable Replace all button
					invoke EnableWindow,hCtl,TRUE
					;Set caption to Replace...
					invoke SetWindowText,hWin,offset szReplace
					;Show replace
					invoke GetDlgItem,hWin,IDC_HEXREPLACESTATIC
					invoke ShowWindow,eax,SW_SHOWNA
					invoke GetDlgItem,hWin,IDC_REPLACETEXT
					invoke ShowWindow,eax,SW_SHOWNA
				.else
					.if fres!=-1
						invoke SendMessage,hHexEd,EM_EXGETSEL,0,offset ft.chrg
						mov		eax,fr
						and		eax,FR_HEX
						or		eax,TRUE
						invoke SendMessage,hHexEd,EM_REPLACESEL,eax,offset replacebuff
						invoke strlen,offset replacebuff
						test	fr,FR_HEX
						.if ZERO?
							add		eax,eax
						.endif
						dec		eax
						add		eax,ft.chrg.cpMin
						mov		ft.chrg.cpMin,eax
						mov		ft.chrg.cpMax,eax
						invoke SendMessage,hHexEd,EM_EXSETSEL,0,offset ft.chrg
					.endif
					invoke HexFind,fr
				.endif
			.elseif eax==IDC_BTN_REPLACEALL
				.if fres==-1
					invoke HexFind,fr
				.endif
				.while fres!=-1
					mov		eax,BN_CLICKED
					shl		eax,16
					or		eax,IDC_BTN_REPLACE
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endw
			.elseif eax==IDC_RBN_HEX
				;Set hex type
				or		fr,FR_HEX
				mov		fres,-1
			.elseif eax==IDC_RBN_ASCII
				;Set ascii type
				and		fr,-1 xor FR_HEX
				mov		fres,-1
			.elseif eax==IDC_RBN_DOWN
				;Set find direction to down
				or		fr,FR_DOWN
				mov		fres,-1
			.elseif eax==IDC_RBN_UP
				;Set find direction to up
				and		fr,-1 xor FR_DOWN
				mov		fres,-1
			.endif
		.elseif edx==EN_CHANGE
			;Update text buffers
			.if eax==IDC_FINDTEXT
				invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,sizeof findbuff,offset findbuff
				mov		fres,-1
			.elseif eax==IDC_REPLACETEXT
				invoke SendDlgItemMessage,hWin,eax,WM_GETTEXT,sizeof replacebuff,offset replacebuff
				mov		fres,-1
			.endif
		.endif
	.elseif eax==WM_ACTIVATE
		mov		fres,-1
	.elseif eax==WM_CLOSE
		invoke SaveWinPos,hWin,offset PosFindLeft
		mov		hSearch,0
		.if hHexEd
			invoke SetFocus,hHexEd
		.endif
		invoke DestroyWindow,hWin
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

HexFindDlgProc endp

