
IDD_FINDDLG			equ 102
IDC_FINDCBO			equ 1001
IDC_REPLACESTATIC	equ 1009
IDC_REPLACEEDIT		equ 1002
IDC_MATCHCASE		equ 1003
IDC_WHOLEWORD		equ 1004
IDC_PROJECT			equ 1005
IDC_DOWN			equ 1006
IDC_UP				equ 1007
IDC_ALL				equ 1008
IDC_REPLACE			equ 1010
IDC_REPLACEALL		equ 1011
IDC_CHKWHITESPACE	equ 1014

.code

;########################################################################

WriteCbo proc hDlg:DWORD
	LOCAL	hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[260]:BYTE
	LOCAL	buffer1[32]:BYTE

	.if fProject
		invoke GetDlgItem,hDlg,IDC_FINDCBO
		mov		hWin,eax
		mov		dword ptr buffer,'=1'
		mov		nInx,0
		invoke WritePrivateProfileSection,offset iniWinFind,addr buffer,offset ProjectFile
		.while nInx<10
			mov		buffer,'"'
			invoke SendMessage,hWin,CB_GETLBTEXT,nInx,addr buffer[1]
		  .break .if eax==CB_ERR
			invoke strlen,addr buffer
			mov		word ptr buffer[eax],'"'
			inc		nInx
			invoke BinToDec,nInx,addr buffer1
			invoke WritePrivateProfileString,offset iniWinFind,addr buffer1,addr buffer,offset ProjectFile
		.endw
	.endif
	ret

WriteCbo endp

ReadCbo proc hDlg:DWORD
	LOCAL	hWin:HWND
	LOCAL	nInx:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[32]:BYTE

	.if fProject
		invoke GetDlgItem,hDlg,IDC_FINDCBO
		mov		hWin,eax
		mov		nInx,1
		.while nInx<11
			invoke BinToDec,nInx,addr buffer1
			invoke GetPrivateProfileString,offset iniWinFind,addr buffer1,offset szNULL,addr buffer,sizeof buffer,offset ProjectFile
			.if eax
				invoke SendMessage,hWin,CB_ADDSTRING,0,addr buffer
			.endif
			inc		nInx
		.endw
	.endif
	ret

ReadCbo endp

FindCbo proc hDlg:DWORD
	LOCAL	hWin:HWND
	LOCAL	txtLen:DWORD

	invoke GetDlgItem,hDlg,IDC_FINDCBO
	mov		hWin,eax
	invoke GetWindowTextLength,hWin
	inc		eax ; space for NULL
	mov		txtLen,eax
	.if eax>1 ; some text entered
		invoke GetWindowText,hWin,offset FindBuffer,sizeof FindBuffer
		; find 
		invoke SendMessage,hWin,CB_FINDSTRINGEXACT,-1,offset FindBuffer
		.if eax!=-1 ; if item found
			invoke SendMessage,hWin,CB_DELETESTRING,eax,eax
		.endif
		; insert string
		invoke SendMessage,hWin,CB_INSERTSTRING,0,offset FindBuffer
		; set list selection
		invoke SendMessage,hWin,CB_SETCURSEL,0,0
		; select text in combobox
		invoke SendMessage,hWin,CB_SETEDITSEL,0,txtLen
	.endif                
	ret

FindCbo endp

FixFind proc lpFind:DWORD,lpFix:DWORD,fWhiteSpace:DWORD

	mov		ecx,lpFind
	mov		edx,lpFix
	.while byte ptr [ecx]
		mov		ax,[ecx]
		.if ax=='I^' || ax=='i^'
			mov		al,VK_TAB
			inc		ecx
		.elseif ax=='M^' || ax=='m^'
			mov		al,VK_RETURN
			inc		ecx
		.endif
		mov		[edx],al
		inc		ecx
		inc		edx
	.endw
	mov		byte ptr [edx],0
	.if fWhiteSpace
		xor		ah,ah
		mov		ecx,lpFix
		mov		edx,lpFix
		xor		eax,eax
		.while byte ptr [ecx]
			.if !ah
				; Skip indent
				.while byte ptr [ecx]==VK_SPACE || byte ptr [ecx]==VK_TAB
					inc		ecx
				.endw
			.endif
			mov		al,[ecx]
			.if al==VK_TAB
				mov		al,VK_SPACE
			.endif
			.if al==VK_SPACE && edx>lpFix
				.if byte ptr [edx-1]==VK_SPACE
					dec		edx
				.endif
			.endif
			mov		[edx],al
			inc		ah
			.if al==VK_RETURN
				xor		ah,ah
			.endif
			inc		ecx
			inc		edx
		.endw
		mov		byte ptr [edx],0
	.endif
	ret

FixFind endp

SearchProc proc hDlg:DWORD,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hWin:HWND

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		m2m		hSearch,hDlg
		mov		ProFileNo,1
		invoke ReadCbo,hDlg
		mov		eax,BST_UNCHECKED
		.if fMatchCase
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hDlg,IDC_MATCHCASE,eax
		mov		eax,BST_UNCHECKED
		.if fWholeWord
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hDlg,IDC_WHOLEWORD,eax
		mov		eax,BST_UNCHECKED
		.if fIgnoreWhiteSpace
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hDlg,IDC_CHKWHITESPACE,eax
		mov		eax,BST_UNCHECKED
		.if fProjectSearch
			mov		eax,BST_CHECKED
		.endif
		invoke CheckDlgButton,hDlg,IDC_PROJECT,eax
		mov		fReplaceAll,FALSE
		.if fSearchUp
			invoke CheckRadioButton,hDlg,IDC_DOWN,IDC_ALL,IDC_UP
		.else
			.if fSearchAll
				invoke CheckRadioButton,hDlg,IDC_DOWN,IDC_ALL,IDC_ALL
			.else
				invoke CheckRadioButton,hDlg,IDC_DOWN,IDC_ALL,IDC_DOWN
			.endif
		.endif
		invoke SetDlgItemText,hDlg,IDC_FINDCBO,offset FindBuffer
		invoke SendDlgItemMessage,hDlg,IDC_REPLACEEDIT,EM_LIMITTEXT,255,0
		invoke SetDlgItemText,hDlg,IDC_REPLACEEDIT,offset ReplaceBuffer
		.if !lParam
			;Disable replace
			invoke GetDlgItem,hDlg,IDC_REPLACEEDIT
			mov     hWin,eax
			invoke GetWindowLong,hWin,GWL_STYLE
			xor     eax, WS_VISIBLE
			invoke SetWindowLong,hWin,GWL_STYLE,eax
			invoke GetDlgItem,hDlg,IDC_REPLACESTATIC
			mov     hWin,eax
			invoke GetWindowLong,hWin,GWL_STYLE
			xor     eax,WS_VISIBLE
			invoke SetWindowLong,hWin,GWL_STYLE,eax
			invoke GetDlgItem,hDlg,IDC_REPLACEALL
			invoke EnableWindow,eax,FALSE
		.else
			invoke SetWindowText,hDlg,offset szReplace
		.endif
		invoke MoveWin,hDlg,offset PosFindLeft
		invoke SetLanguage,hDlg,IDD_FINDDLG,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK && hEdit
				call	Find
			.elseif eax==IDCANCEL
				invoke SendMessage,hDlg,WM_CLOSE,0,0
			.elseif eax==IDC_REPLACE && hEdit
				invoke GetDlgItem,hDlg,IDC_REPLACEEDIT
				mov     hWin,eax
				invoke GetWindowLong,hWin,GWL_STYLE
				test    eax,WS_VISIBLE
				jne     @f
				;enable replace
				or      eax, WS_VISIBLE
				invoke SetWindowLong,hWin,GWL_STYLE,eax
				invoke GetDlgItem,hDlg,IDC_REPLACESTATIC
				mov     hWin,eax
				invoke GetWindowLong,hWin,GWL_STYLE
				or     eax, WS_VISIBLE
				invoke SetWindowLong,hWin,GWL_STYLE,eax
				invoke SetWindowText,hDlg,offset szReplace
				invoke InvalidateRect,hDlg,NULL,TRUE
				invoke GetDlgItem,hDlg,IDC_REPLACEALL
				invoke EnableWindow,eax,TRUE
				jmp		Ex
			  @@:
				;Replace
				call	Replace
				call	Find
			.elseif eax==IDC_REPLACEALL && hEdit
			  @@:
				call	Replace
				call	Find
				.if fFind!=-1
					inc		dword ptr fReplaceAll
					jmp		@b
				.endif
				invoke BinToDec,fReplaceAll,offset iniBuffer
				invoke strcat,offset iniBuffer,offset Replacements
				invoke MessageBox,hDlg,offset iniBuffer,offset AppName,MB_OK
				mov		fReplaceAll,0
			.elseif eax==IDC_MATCHCASE
				xor		fMatchCase,TRUE
			.elseif eax==IDC_WHOLEWORD
				xor		fWholeWord,TRUE
			.elseif eax==IDC_CHKWHITESPACE
				xor		fIgnoreWhiteSpace,TRUE
			.elseif eax==IDC_PROJECT
				xor		fProjectSearch,TRUE
			.elseif eax==IDC_DOWN
				mov		fSearchUp,FALSE
				mov		fSearchAll,FALSE
			.elseif eax==IDC_UP
				mov		fSearchUp,TRUE
				mov		fSearchAll,FALSE
			.elseif eax==IDC_ALL
				mov		fSearchUp,FALSE
				mov		fSearchAll,TRUE
			.endif
		.endif
	.elseif eax==WM_ACTIVATE
		call	FindInit
	.elseif eax==WM_CLOSE
		invoke WriteCbo,hDlg
		invoke SaveWinPos,hDlg,offset PosFindLeft
		mov		hSearch,0
		.if hEdit
			invoke SetFocus,hEdit
		.endif
		invoke DestroyWindow,hDlg
	.else
		mov		eax,FALSE
		ret
	.endif
  Ex:
	mov		eax,TRUE
	ret

FindInit:
	.if hEdit
		invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findchrg
		mov		eax,findchrg.cpMin
		mov		findchrg.cpMax,eax
		mov		findtext.chrgText.cpMin,eax
		mov		findtext.chrgText.cpMax,eax
	.endif
	mov		findtext.chrg.cpMax,-1
	mov		fFind,-1
	retn

Find:
	invoke FindCbo,hDlg
	invoke GetDlgItemText,hDlg,IDC_FINDCBO,offset FindBuffer,sizeof FindBuffer
	.if eax!=0
		invoke FixFind,offset FindBuffer,offset FindBufferFixed,fIgnoreWhiteSpace
		mov		uFlags,0
		.if fProjectSearch
			invoke CheckRadioButton,hDlg,IDC_DOWN,IDC_ALL,IDC_DOWN
			mov		fSearchUp,FALSE
			mov		fSearchAll,FALSE
			.if fProSearch==FALSE
			  @@:
				.if ProFileNo<1512
					invoke Scan,ProFileNo,fMatchCase,fWholeWord,fIgnoreWhiteSpace
					inc		ProFileNo
					or		eax,eax
					je		@b
					mov		findtext.chrgText.cpMin,0
					mov		findtext.chrgText.cpMax,0
					invoke SendMessage,hEdit,EM_SETSEL,0,0
					invoke SetFocus,hDlg
					mov		fProSearch,TRUE
				.else
					mov		ProFileNo,1
					mov		fProSearch,FALSE
					invoke MessageBox,hDlg,offset AllFiles,offset AppName,MB_OK
					jmp		ExFind
				.endif
			.endif
		.endif
		.if fSearchUp
			mov		eax,findtext.chrgText.cpMin
			dec		eax
			mov		findtext.chrg.cpMin,eax
			mov		findtext.chrg.cpMax,0
		.else
			or		uFlags,FR_DOWN
			.if fSearchAll
				mov		eax,findtext.chrgText.cpMax
				mov		findtext.chrg.cpMin,eax
				.if findchrg.cpMin
					mov		findtext.chrg.cpMax,-1
				.endif
			.else
				mov		eax,findtext.chrgText.cpMax
				mov		findtext.chrg.cpMin,eax
				mov		findtext.chrg.cpMax,-1
			.endif
		.endif
		.if fMatchCase
			or		uFlags,FR_MATCHCASE
		.endif
		.if fWholeWord
			or		uFlags,FR_WHOLEWORD
		.endif
		.if fIgnoreWhiteSpace
			or		uFlags,FR_IGNOREWHITESPACE
		.endif
		mov		findtext.lpstrText,offset FindBufferFixed
		invoke SendMessage,hEdit,EM_FINDTEXTEX,uFlags,addr findtext
		.if eax!=-1
			mov		edx,findtext.chrgText.cpMax
			.if edx>=findtext.chrg.cpMax && fSearchAll
				mov		eax,-1
			.endif
		.endif
		mov     fFind,eax
		.if eax!=-1
			invoke SendMessage,hEdit,EM_EXSETSEL,0,addr findtext.chrgText
			invoke VerticalCenter,hEdit,REM_VCENTER
			invoke SendMessage,hEdit,REM_REPAINT,0,TRUE
		.else
			.if fProSearch
				mov		fProSearch,FALSE
				jmp		Find
			.elseif fSearchAll && findchrg.cpMin
				invoke strlen,offset FindBufferFixed
				push	eax
				mov		eax,findchrg.cpMax
				pop		edx
				add		eax,edx
				mov		findtext.chrg.cpMax,eax
				xor		eax,eax
				mov		findtext.chrgText.cpMin,eax
				mov		findtext.chrgText.cpMax,eax
				mov		findchrg.cpMin,eax
				mov		findchrg.cpMax,eax
				jmp		Find
			.endif
			invoke SendMessage,hEdit,EM_EXGETSEL,0,addr findchrg
			invoke SendMessage,hEdit,EM_EXSETSEL,0,addr findchrg
			invoke VerticalCenter,hEdit,REM_VCENTER
			call	FindInit
			invoke MessageBox,hDlg,offset szSearchFinished,offset AppName,MB_OK
		.endif
	.endif
  ExFind:
	retn

Replace:
	.if fFind!=-1
		invoke GetDlgItemText,hDlg,IDC_REPLACEEDIT,offset ReplaceBuffer,sizeof ReplaceBuffer
		invoke FixFind,offset ReplaceBuffer,offset ReplaceBufferFixed,FALSE
		invoke SendMessage,hEdit,EM_REPLACESEL,TRUE,offset ReplaceBufferFixed
		invoke strlen,offset ReplaceBufferFixed
		add		eax,findtext.chrgText.cpMin
		mov		findtext.chrgText.cpMax,eax
		invoke SendMessage,hEdit,EM_EXSETSEL,0,addr findtext.chrgText
		.if fSearchUp
			;Move to start of word
			m2m		findtext.chrg.cpMin,findtext.chrg.cpMax
		.elseif fSearchAll && findtext.chrg.cpMax!=-1
			invoke strlen,offset FindBufferFixed
			push	eax
			invoke strlen,offset ReplaceBufferFixed
			pop		edx
			sub		eax,edx
			add		findtext.chrg.cpMax,eax
		.endif
	.endif
	retn

SearchProc endp

