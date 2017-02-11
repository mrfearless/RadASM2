.386
.model flat,stdcall
option casemap:none

include PDBExplore.inc
include Misc.asm
include PDBFile.asm

.code

CldDlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ofn:OPENFILENAME
	LOCAL	buffer[MAX_PATH]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hCldDlg,eax
		invoke SetCurrentStream
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWnd,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNBROWSE
				;Zero out the ofn struct
				invoke RtlZeroMemory,addr ofn,sizeof ofn
				;Setup the ofn struct
				mov		ofn.lStructSize,sizeof ofn
				push	hWin
				pop		ofn.hwndOwner
				push	hInstance
				pop		ofn.hInstance
				mov		ofn.lpstrFilter,offset szPDBFilterString
				mov		buffer[0],0
				lea		eax,buffer
				mov		ofn.lpstrFile,eax
				mov		ofn.nMaxFile,sizeof buffer
				mov		ofn.lpstrDefExt,NULL
				mov		ofn.Flags,OFN_FILEMUSTEXIST or OFN_HIDEREADONLY or OFN_PATHMUSTEXIST
				;Show the Open dialog
				invoke GetOpenFileName,addr ofn
				.if eax
					invoke SetDlgItemText,hWin,IDC_EDTFILE,addr buffer
					invoke CloseStreams
					invoke OpenPdbFile,addr buffer
					.if !eax
						invoke SetCurrentStream
						invoke DumpStream,offset stream,0
					.endif
				.endif
			.elseif eax==IDC_BTNPREVIOUS
				.if nCurrentStream
					dec		nCurrentStream
					invoke SetCurrentStream
					mov		eax,nCurrentStream
					mov		edx,offset stream
					lea		edx,[edx+eax*sizeof STREAM]
					invoke DumpStream,edx,eax
				.endif
			.elseif eax==IDC_BTNNEXT
				mov		eax,nCurrentStream
				inc		eax
				.if eax<nStreams
					inc		nCurrentStream
					invoke SetCurrentStream
					mov		eax,nCurrentStream
					mov		edx,offset stream
					lea		edx,[edx+eax*sizeof STREAM]
					invoke DumpStream,edx,eax
				.endif
			.elseif eax==IDC_BTNSAVE
				.if nStreams
					invoke SaveStream,nCurrentStream
				.endif
			.endif
		.endif
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

CldDlgProc endp

WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	cldrect:RECT

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWnd,eax
		invoke GetDlgItem,hWin,IDC_REDDEBUG
		mov		hEdt,eax
		invoke CreateFontIndirect,addr Courier_New_10
		mov		hFont,eax
		invoke SendMessage,hEdt,WM_SETFONT,hFont,FALSE
		invoke SendMessage,hEdt,EM_EXLIMITTEXT,0,1024*1024
		invoke CreateDialogParam,hInstance,IDD_DLGCHILD,hWin,addr CldDlgProc,0
	.elseif eax==WM_SIZE
		; Move and size the rich edit control
		invoke GetClientRect,hWin,addr rect
		mov		eax,rect.bottom
		sub		eax,70
		invoke MoveWindow,hEdt,0,0,rect.right,eax,TRUE
		; Move the cild dialog
		invoke GetClientRect,hCldDlg,addr cldrect
		mov		eax,rect.bottom
		sub		eax,65
		mov		edx,rect.right
		sub		edx,cldrect.right
		invoke MoveWindow,hCldDlg,edx,eax,cldrect.right,cldrect.bottom,TRUE
	.elseif eax==WM_CLOSE
		invoke CloseStreams
		invoke DeleteObject,hFont
		invoke DestroyWindow,hWin
	.elseif eax==WM_DESTROY
		invoke PostQuitMessage,NULL
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.endif
	xor    eax,eax
	ret

WndProc endp

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize,sizeof WNDCLASSEX
	mov		wc.style,CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc,offset WndProc
	mov		wc.cbClsExtra,NULL
	mov		wc.cbWndExtra,DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground,COLOR_BTNFACE+1
	mov		wc.lpszMenuName,NULL
	mov		wc.lpszClassName,offset szClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov		wc.hIcon,eax
	mov		wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov		wc.hCursor,eax
	invoke RegisterClassEx,addr wc
	invoke CreateDialogParam,hInstance,IDD_MAIN,NULL,addr WndProc,NULL
	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd
	.while TRUE
		invoke GetMessage,addr msg,NULL,0,0
	  .BREAK .if !eax
		invoke IsDialogMessage,hCldDlg,addr msg
		.if !eax
			invoke TranslateMessage,addr msg
			invoke DispatchMessage,addr msg
		.endif
	.endw
	mov		eax,msg.wParam
	ret

WinMain endp

start:

	invoke LoadLibrary,addr szRichEditDLL
	.if eax
		mov		hRichEdDLL,eax
		invoke GetModuleHandle,NULL
		mov    hInstance,eax
		invoke GetCommandLine
		mov		CommandLine,eax
		invoke InitCommonControls
		invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
		invoke FreeLibrary,hRichEdDLL
	.else
		invoke MessageBox,0,addr szRichEditDLL,addr szRichEditDLL,MB_OK
	.endif
	invoke ExitProcess,0

end start
