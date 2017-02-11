#Include "DragProp.Inc"
#Include "C:\RadASM\GoAsm\Inc\RadAsm.inc"
#include "IShellLink.asm"

ADDINOPT struct
	lpStr			dd ?
	nAnd			dd ?
	nOr				dd ?
ADDINOPT ends

.data
	hInstance		DD		0
	lpHandles		DD		0
	lpProcs			DD		0
	lpData			DD		0
	pWndProc		DD		0
	pTrvProc		DD		0

	hDragIml		DD		0
	TVDragItem		DD		0

	hPropBox		DD		0
	hPropTreeView	DD		0
	hTab			DD		0
	hRadASM			DD		0

	IsDragging		DD		0

	AddinOpt		ADDINOPT	<0,0,0>

.code

GetOptions:
	mov eax,offset AddinOpt
	ret

DllEntryPoint	FRAME hInst, reason, reserved1
    mov eax,[hInst]
    mov [hInstance], eax
    xor eax, eax
    inc eax
    ret
ENDF

InstallDll FRAME hWin, fOpt

	invoke SendMessage, [hWin], AIM_GETHANDLES, 0, 0
	mov	[lpHandles], eax
	invoke SendMessage, [hWin], AIM_GETPROCS, 0, 0
	mov [lpProcs], eax
	invoke SendMessage, [hWin], AIM_GETDATA, 0, 0
	mov [lpData], eax

	invoke SubClassPbrWin

	mov eax,RAM_CLOSE
	xor ecx,ecx
	xor edx,edx
	ret
ENDF

DllProc	FRAME hWin, uMsg, wParam, lParam

	cmp D[uMsg], AIM_CLOSE
	jnz >.ExitMsgLoop
		invoke SetWindowLong,[hPropBox],GWL_WNDPROC,[pWndProc]
		invoke SetWindowLong,[hPropTreeView],GWL_WNDPROC,[pTrvProc]
		invoke GetWindowLong,[hPropTreeView],GWL_EXSTYLE
		xor eax,WS_EX_ACCEPTFILES
		invoke SetWindowLong,[hPropTreeView],GWL_EXSTYLE,eax

	.ExitMsgLoop
	xor eax, eax
	ret
ENDF

SubClassPbrWin FRAME
	LOCAL hwnd	:D
	
	mov eax,[lpHandles]
	mov ecx,[eax+ADDINHANDLES.hPbrTrv]
	mov [hPropTreeView],ecx

	mov ecx,[eax+ADDINHANDLES.hTab]
	mov [hTab],ecx

	mov ecx,[eax+ADDINHANDLES.hWnd]
	mov [hRadASM],ecx

	mov eax,[eax+ADDINHANDLES.hPbr]
	mov [hPropBox],eax

	invoke SetWindowLong,eax,GWL_WNDPROC,offset PBRSubClass
	mov [pWndProc],eax

	invoke GetWindowLong,[hPropTreeView],GWL_STYLE
	and eax,0FFFFFFEFh
	invoke SetWindowLong,[hPropTreeView],GWL_STYLE,eax

	invoke GetWindowLong,[hPropTreeView],GWL_EXSTYLE
	or eax,WS_EX_ACCEPTFILES
	invoke SetWindowLong,[hPropTreeView],GWL_EXSTYLE,eax

	invoke SetWindowLong,[hPropTreeView],GWL_WNDPROC,offset TVSubClass
	mov [pTrvProc],eax

	RET
ENDF

PBRSubClass FRAME hwnd,uMsg,wParam,lParam
	LOCAL pt					:POINT

	cmp D[uMsg],WM_NOTIFY
	jne >>.WM_LBUTTONUP
		mov eax,[lParam]
		cmp D[eax+NMHDR.code],TVN_BEGINDRAG
		jne >>.EXIT
			mov D[IsDragging],TRUE
			invoke TVBeginDrag,[eax+NMHDR.hwndFrom],[lParam]
			jmp >>.EXIT

	.WM_LBUTTONUP
	cmp D[uMsg],WM_LBUTTONUP
	jne >.WM_MOUSEMOVE
		cmp D[IsDragging],TRUE
		jne >>.EXIT
			mov D[IsDragging],FALSE
			invoke TVEndDrag
			jmp >>.EXIT

	.WM_MOUSEMOVE
	cmp D[uMsg],WM_MOUSEMOVE
	jne >.EXIT
		cmp D[IsDragging],TRUE
		jne >.EXIT
			invoke GetCursorPos,ADDR pt
			invoke ImageList_DragMove,[pt.x],[pt.y]
			jmp >.EXIT

	.EXIT
	invoke CallWindowProc,[pWndProc],[hwnd],[uMsg],[wParam],[lParam]
	RET
ENDF

TVSubClass FRAME hwnd,uMsg,wParam,lParam
	uses ebx
	LOCAL FileName[MAX_PATH]	:B

	cmp D[uMsg],WM_DROPFILES
	jne >>.EXIT
		invoke DragQueryFile,[wParam],-1,ADDR FileName,MAX_PATH
		mov ebx,eax
		D1:
			dec ebx
			invoke DragQueryFile,[wParam],ebx,ADDR FileName,MAX_PATH
			invoke GetLinkTarget,ADDR FileName,ADDR FileName
			invoke GetFileAttributes,ADDR FileName
			and eax,FILE_ATTRIBUTE_DIRECTORY
			jnz >D2
				push FALSE
				push TRUE
				push offset FileName
				mov eax,[lpProcs]
				mov eax,[eax+ADDINPROCS.lpAddProjectFile]
				call eax
		D2:
		or ebx,ebx
		jnz <<D1
		invoke DragFinish,[wParam]
		xor eax,eax
		ret

	.EXIT
	invoke CallWindowProc,[pTrvProc],[hwnd],[uMsg],[wParam],[lParam]
	RET
ENDF

TVBeginDrag FRAME hParent,lParam
	LOCAL DragStart		:POINT
	LOCAL tvi			:TVITEM
	LOCAL rect			:RECT

	mov eax,[hParent]
	cmp eax,[hPropTreeView]
	je >
		ret
	:
	mov edi,[lParam]
	mov eax,[edi+NM_TREEVIEW.itemNew.hItem]
	mov [TVDragItem],eax

	mov [tvi.hItem],eax
	mov D[tvi.imask],TVIF_IMAGE
	invoke SendMessage,[hPropTreeView],TVM_GETITEM,0,ADDR tvi
	mov eax,[tvi.iImage]
	cmp eax,0
	jne >
		ret
	:
	mov D[tvi.imask],TVIF_STATE
	mov D[tvi.state],TVIS_DROPHILITED
	invoke SendMessage,[hPropTreeView],TVM_SETITEM,0,ADDR tvi

	invoke GetCursorPos,ADDR DragStart
	invoke SendMessage,[hPropTreeView],TVM_SELECTITEM,TVGN_DROPHILITE,[TVDragItem]

	invoke SendMessage,[hPropTreeView],TVM_CREATEDRAGIMAGE,0,[TVDragItem]
	mov [hDragIml],eax

	invoke ImageList_BeginDrag,[hDragIml],0,-8,-8
	invoke GetDesktopWindow
	invoke ImageList_DragEnter,eax,[DragStart.x],[DragStart.y]
	invoke SetCapture,[hPropBox]

	ret
ENDF

TVEndDrag FRAME
	uses ebx
	LOCAL pt					:POINT
	LOCAL hroot					:D
	LOCAL tvi					:TVITEM
	LOCAL tvht					:TV_HITTESTINFO
	LOCAL buffer[MAX_PATH]		:B
	LOCAL hNewParent			:D
	LOCAL GroupIndex			:D
	LOCAL FileIndex				:D
	LOCAL Index[16]				:B
	LOCAL Value[16]				:B

	invoke SendMessage,[hPropTreeView],TVM_SELECTITEM,TVGN_DROPHILITE,NULL

	invoke ReleaseCapture
	invoke GetDesktopWindow
	invoke ImageList_DragLeave,eax
	invoke ImageList_EndDrag
	invoke ImageList_Destroy,[hDragIml]

	invoke GetCursorPos,ADDR pt
	invoke ScreenToClient,[hPropBox],ADDR pt
	invoke ChildWindowFromPoint,[hPropBox],[pt.x],[pt.y]
	cmp eax,[hPropTreeView]
	jne >>.TABDROP
		invoke SendMessage,[hPropTreeView],TVM_GETNEXTITEM,TVGN_ROOT,NULL
		mov [hroot],eax
		invoke GetCursorPos,ADDR tvht.pt
		invoke ScreenToClient,[hPropTreeView],ADDR tvht.pt
		invoke SendMessage,[hPropTreeView],TVM_HITTEST,0,ADDR tvht
		or eax,eax
		jnz >
		invoke SendMessage,[hPropTreeView],TVM_GETNEXTITEM,TVGN_LASTVISIBLE,NULL
		:
		cmp eax,[hroot]
		jne >
			ret
		:
		invoke SendMessage,[hPropTreeView],TVM_GETNEXTITEM,TVGN_PARENT,eax
		cmp eax,[hroot]
		jne >
			mov eax,[tvht.hItem]
		:
		mov [hNewParent],eax
		mov B[buffer],0
		; The group item number is here
		mov [tvi.hItem],eax
		mov eax,offset buffer
		mov [tvi.pszText],eax
		mov D[tvi.cchTextMax],256
		mov D[tvi.imask],TVIF_TEXT
		invoke SendMessage,[hPropTreeView],TVM_GETITEM,0,ADDR tvi
		invoke lstrlen,offset buffer
		or eax,eax
		jnz >
			ret
		:
		invoke FindGroupIndex,offset buffer
		or eax,eax
		jns >
			ret
		:
		mov [GroupIndex],eax
		invoke FindFileIndex,[TVDragItem]
		mov [FileIndex],eax
		or eax,eax
		jnz >
			ret
		:
		; OK we have a file index and a group index
		; We have to update the RAP file

		invoke wsprintf,offset Index,"%u",[FileIndex]
		add esp,12

		invoke wsprintf,offset Value,"%u",[GroupIndex]
		add esp,12

		mov eax,[lpData]
		mov eax,[eax+ADDINDATA.lpProject]
		invoke WritePrivateProfileString,"Group",offset Index,offset Value,eax

		;How do I update the window ????
;		invoke TVMoveItem,[hPropTreeView],[TVDragItem],[hNewParent]
		;Update the treeview
		invoke SendMessage,[hPropTreeView],TVM_DELETEITEM,0,TVI_ROOT
		mov eax,[lpProcs]
		push 0
		call [eax+ADDINPROCS.lpGetProjectFiles]

		jmp >>.EXIT

	.TABDROP
	invoke GetCursorPos,ADDR pt
	invoke ScreenToClient,[hRadASM],ADDR pt
	invoke ChildWindowFromPoint,[hRadASM],[pt.x],[pt.y]
	cmp eax,[hTab]
	jne >>.EXIT
		; A file has been dropped into the tab strip
		mov eax,[TVDragItem]
		mov [tvi.hItem],eax
		mov D[tvi.imask],TVIF_TEXT
		mov edx,[lpData]
		mov eax,[edx+ADDINDATA.lpFile]
		mov edx,[edx+ADDINDATA.lpProjectPath]
		invoke lstrcpy,eax,edx
		mov edx,[lpData]
		mov eax,[edx+ADDINDATA.lpFile]
		push eax
		invoke lstrlen,eax
		pop edx
		add edx,eax
		mov D[tvi.pszText],edx
		sub eax,MAX_PATH
		neg eax
		mov D[tvi.cchTextMax],eax
		invoke SendMessage,[hPropTreeView],TVM_GETITEM,0,ADDR tvi
		mov eax,[lpProcs]
		mov eax,[eax+ADDINPROCS.lpOpenProjectFile]
		call eax

	.EXIT
	ret
ENDF

TVMoveItem FRAME hTrv,hTVItem,hParent
	LOCAL tvis					:TV_INSERTSTRUCT
	LOCAL szBuffer[MAX_PATH]	:B

	mov eax,[hTVItem]
	mov [tvis.itemex.hItem],eax
	mov D[tvis.itemex.imask],TVIF_TEXT+TVIF_IMAGE+TVIF_PARAM+TVIF_STATE+TVIF_SELECTEDIMAGE
	mov eax,OFFSET szBuffer
	mov D[tvis.itemex.pszText],eax
	mov D[tvis.itemex.cchTextMax],MAX_PATH
	invoke SendMessage,[hTrv],TVM_GETITEM,0,offset tvis.itemex

	mov eax,[hParent]
	mov [tvis.hParent],eax
	mov D[tvis.hInsertAfter],TVI_SORT
	invoke SendMessage,[hTrv],TVM_INSERTITEM,0,OFFSET tvis

	invoke SendMessage,[hTrv],TVM_DELETEITEM,0,[hTVItem]

	RET
ENDF

FindGroupIndex FRAME pszGroupName
	uses ebx,edi,esi
	LOCAL pszGroups		:D
	LOCAL hHeap			:D

	invoke GetProcessHeap
	mov [hHeap],eax
	invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,4096
	mov [pszGroups],eax

	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.lpProject]
	
	invoke GetPrivateProfileString,"Group","Group","",[pszGroups],4096,eax
	or eax,eax
	jz >.EXIT
	mov ecx,eax
	mov edi,[pszGroups]
	xor ebx,ebx
	L1:
	mov al,","
	mov esi,edi
	inc ebx
	repne scasb
	or ecx,ecx
	jz >
	mov B[edi-1],0
	:
	push ecx
	invoke lstrcmpi,esi,[pszGroupName]
	pop ecx
	or eax,eax
	jz >.FOUNDIT
	or ecx,ecx
	jz >.EXIT
	jmp <<L1

	.FOUNDIT
		invoke HeapFree,[hHeap],NULL,[pszGroups]
		mov eax,ebx
		ret

	.EXIT
	invoke HeapFree,[hHeap],NULL,[pszGroups]
	mov eax,-1
	ret
ENDF

FindFileIndex FRAME hItem
	LOCAL tvi	:TVITEM

	mov D[tvi.imask],TVIF_PARAM
	mov eax,[hItem]
	mov [tvi.hItem],eax
	invoke SendMessage,[hPropTreeView],TVM_GETITEM,0,ADDR tvi

	mov eax,[tvi.lParam]
	ret

ENDF
