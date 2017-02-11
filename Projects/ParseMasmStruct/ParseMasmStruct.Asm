.386
.model flat, stdcall  ;32 bit memory model
option casemap :none  ;case sensitive

include ParseMasmStruct.inc
include Misc.asm

.code

;########################################################################

DlgProc proc uses esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hMemFile:HGLOBAL
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_EDT1
		mov		hEdt,eax
		; Size of structures
		invoke ReadTheFile,addr szStructSizeFileName
		mov		hMemFile,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
		mov		hMemStructSize,eax
		invoke ParseStructSizeFile,hMemFile,hMemStructSize
		; Free the file memory
		invoke GlobalFree,hMemFile

		; Size of types
		invoke ReadTheFile,addr szTypeSizeFileName
		mov		hMemFile,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
		mov		hMemTypeSize,eax
		invoke ParseSizeFile,hMemFile,hMemTypeSize
		; Free the file memory
		invoke GlobalFree,hMemFile

		; Size of constants
		invoke ReadTheFile,addr szConstSizeFileName
		mov		hMemFile,eax
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,512*1024
		mov		hMemConstSize,eax
		invoke ParseSizeFile,hMemFile,hMemConstSize
		; Free the file memory
		invoke GlobalFree,hMemFile

		; Create font and set it to edit box
		invoke CreateFontIndirect,addr Courier_New_9
		mov		hEditFont,eax
		invoke SendDlgItemMessage,hWin,IDC_EDT1,WM_SETFONT,hEditFont,FALSE
		; Add combobox items
		mov		esi,offset ComboItems
		.while byte ptr [esi].COMBOITEM.szName
			invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_ADDSTRING,0,addr [esi].COMBOITEM.szName
			invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_SETITEMDATA,eax,[esi].COMBOITEM.lpItem
			lea		esi,[esi+sizeof COMBOITEM]
		.endw
		invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_SETCURSEL,0,0
		invoke SetDlgItemText,hWin,IDC_EDT1,addr szTestStruct1
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				; Do the parsing
				mov		fShowResult,TRUE
				invoke ParseMasmStruct
			.elseif eax==IDC_BTNSTRUCT
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,offset szINCFilterString
				mov		buffer[0],0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.lpstrDefExt,NULL
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke FromInc,addr buffer,addr szStruct,addr szEnds
				.endif
			.elseif eax==IDC_BTNUNION
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,offset szINCFilterString
				mov		buffer[0],0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.lpstrDefExt,NULL
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke FromInc,addr buffer,addr szUnion,addr szEnds
				.endif
			.elseif eax==IDCANCEL
				; Exit
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.endif
		.elseif edx==CBN_SELCHANGE
			; Get combobox itemdata and update edit box
			invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_GETCURSEL,0,0
			invoke SendDlgItemMessage,hWin,IDC_CBO1,CB_GETITEMDATA,eax,0
			invoke SetDlgItemText,hWin,IDC_EDT1,eax
		.endif
	.elseif eax==WM_CLOSE
		; Free the font
		invoke DeleteObject,hEditFont
		; Free memory
		invoke GlobalFree,hMemStructSize
		invoke GlobalFree,hMemTypeSize
		invoke GlobalFree,hMemConstSize
		; End the dialog
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc endp

start:

include Test.asm

	invoke GetModuleHandle,NULL
	mov		hInstance,eax
    invoke InitCommonControls
	invoke DialogBoxParam,hInstance,IDD_DIALOG1,NULL,addr DlgProc,NULL
	invoke ExitProcess,0

end start
