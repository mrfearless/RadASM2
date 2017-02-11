
IDD_DLGPROJECTGROUPS	equ 4500
IDC_TRVPROJECT			equ 4501
IDC_EDTDEFGROUP			equ 4506

.const

szNewGroup				db 'New Group',0
CombSort_Const			REAL4 1.3

.data?

hProjectGroup			HWND ?
hGrpTrv					dd ?
hGrpRoot				dd ?
szGroupGroupBuff		db 4096 dup(?)
profile					PROFILE 2048 dup(<>)
groupexpand				dd 64 dup(?)
TVDragItem				dd ?
hDragIml				dd ?
szFirstVisible			db 256 dup(?)
lpOldGroupTrvEditProc	dd ?
nScrollPos				dd ?

.code

CombSort PROC uses ebx esi edi,lpArr:DWORD,count:DWORD
	LOCAL	Gap:DWORD
	LOCAL	eFlag:DWORD

	mov		eax,count
	mov		Gap,eax
	mov		ebx,lpArr
	dec		count
  @Loop1:
	fild	Gap								; load integer memory operand to divide
	fdiv	CombSort_Const					; divide number by 1.3
	fistp	Gap								; store result back in integer memory operand
	dec		Gap
	jnz		@F
	mov		Gap,1
  @@:
	mov		eFlag,0
	mov		esi,count
	sub		esi,Gap
	xor		ecx,ecx							; low value index
  @Loop2:
	mov 	edx,ecx
	add 	edx,Gap							; high value index
	;Get offsets to row data
	push	edx
	mov		edx,[ebx+edx*4]
	mov		edi,[ebx+ecx*4]
	;Get cell data
	push	ecx
	invoke lstrcmpi,[edi],[edx]
	pop		ecx
	pop		edx
	cmp		eax,0
	jle 	@F
	mov 	eax,[ebx+ecx*4]					; lower value
	mov 	edi,[ebx+edx*4]					; higher value
	mov 	[ebx+edx*4],eax
	mov 	[ebx+ecx*4],edi
	inc 	eFlag
  @@:
	inc 	ecx
	cmp 	ecx,esi
	jle 	@Loop2
	cmp 	eFlag,0
	jg		@Loop1
	cmp 	Gap,1
	jg		@Loop1
	ret

CombSort ENDP

GroupGetProjectFiles proc uses ebx esi edi
	LOCAL	hMem:HGLOBAL
	LOCAL	n:DWORD

	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,2048*4
	mov		hMem,eax
	mov		ebx,eax
	mov		esi,hMemPro
	mov		edi,offset profile
	invoke RtlZeroMemory,edi,sizeof profile
	mov		n,0
  Nxt:
	.if  byte ptr [esi]
		invoke DecToBin,esi
		.while byte ptr [esi] && byte ptr [esi]!='='
			inc		esi
		.endw
		.if byte ptr [esi]=='='
			inc		esi
			.if byte ptr [esi] && eax
				mov		[edi].PROFILE.lpszFile,esi
				mov		[edi].PROFILE.iNbr,eax
				invoke GetFileImg,esi
				.if [edi].PROFILE.iNbr>=PRO_START_OBJ
					.if eax==9
						mov		eax,1
					.elseif eax==3
						mov		eax,10
					.endif
				.endif
				.if eax>=30
					mov		eax,7
				.endif
				invoke ProGetGroup,[edi].PROFILE.iNbr,eax
				mov		[edi].PROFILE.nGrp,eax
				mov		[ebx],edi
				inc		n
				lea		edi,[edi+sizeof PROFILE]
				lea		ebx,[ebx+4]
			.endif
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			jmp		Nxt
		.endif
	.endif
	.if sdword ptr n>1
		invoke CombSort,hMem,n
	.endif
	invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,2048*sizeof PROFILE
	push	eax
	mov		edi,eax
	push	edi
	mov		ebx,hMem
	.while dword ptr [ebx]
		mov		esi,[ebx]
		mov		ecx,sizeof PROFILE
		rep		movsb
		lea		ebx,[ebx+4]
	.endw
	pop		edi
	invoke RtlMoveMemory,offset profile,edi,sizeof profile
	invoke GlobalFree,edi
	invoke GlobalFree,hMem
	ret

GroupGetProjectFiles endp

GetGroupState proc hTrv:HWND,hItem:DWORD
	LOCAL	tvi:TVITEM

	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_CHILD,hItem
	.while eax
		mov		tvi.hItem,eax
		mov		tvi._mask,TVIF_PARAM or TVIF_STATE
		invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvi
		.if sdword ptr tvi.lParam<0 && eax
			mov		eax,tvi.state
			and		eax,TVIS_EXPANDED
			mov		groupstate[edi*4],eax
			lea		edi,[edi+1]
			invoke GetGroupState,hTrv,tvi.hItem
		.endif
		invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
	.endw
	ret

GetGroupState endp

SetGroupState proc hTrv:HWND,hItem:DWORD
	LOCAL	tvi:TVITEM

	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_CHILD,hItem
	.while eax
		mov		tvi.hItem,eax
		mov		tvi._mask,TVIF_PARAM or TVIF_STATE
		invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvi
		.if sdword ptr tvi.lParam<0 && eax
			mov		eax,groupstate[edi*4]
			.if eax
				invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,tvi.hItem
			.endif
			lea		edi,[edi+1]
			invoke SetGroupState,hTrv,tvi.hItem
		.endif
		invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
	.endw
	ret

SetGroupState endp

GroupAddNode proc uses esi,hTrv:HWND,lpFileName:DWORD,iNbr:DWORD,nGrp:DWORD,fModule:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE

	; Get parent node
	mov		eax,nGrp
	mov		edx,sizeof PROGROUP
	dec		eax
	mul		edx
	lea		esi,groupgrp[eax]
	; Find filetype
	invoke GetFileImg,lpFileName
	.if fModule
		.if eax==9
			mov		eax,1
		.elseif eax==3
			mov		eax,10
		.endif
	.endif
	.if eax>=30
		mov		eax,7
	.endif
	; Check if read only
	push	eax
	invoke strcpy,addr buffer,addr ProjectPath
	invoke strcat,addr buffer,lpFileName
	invoke GetFileAttributes,addr buffer
	mov		edx,eax
	pop		eax
	test	edx,FILE_ATTRIBUTE_READONLY
	.if !ZERO?
		add		eax,11
	.endif
	add		eax,IML_START
	mov		edx,[esi].PROGROUP.hGrp
	.if !edx
		mov		edx,hGrpRoot
	.endif
	invoke Do_TreeViewAddNode,hTrv,edx,NULL,lpFileName,eax,eax,iNbr
	ret

GroupAddNode endp

GroupExpandAll proc hTrv:HWND,hItem:DWORD

  @@:
	invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,hItem
	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_CHILD,hItem
	.if eax
		invoke GroupExpandAll,hTrv,eax
	.endif
	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_NEXT,hItem
	.if eax
		mov		hItem,eax
		jmp		@b
	.endif
	ret

GroupExpandAll endp

GroupCollapseAll proc hTrv:HWND,hItem:DWORD

  @@:
	invoke SendMessage,hTrv,TVM_EXPAND,TVE_COLLAPSE,hItem
	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_CHILD,hItem
	.if eax
		invoke GroupCollapseAll,hTrv,eax
	.endif
	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_NEXT,hItem
	.if eax
		mov		hItem,eax
		jmp		@b
	.endif
	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
	invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,eax
	ret

GroupCollapseAll endp

GroupUpdateTrv proc uses ebx esi edi,hTrv:HWND
	LOCAL	iNbr:DWORD
	LOCAL	iInx:DWORD
	LOCAL	hPrevPro[32]:DWORD

	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
	.if eax
		; Delete root
		invoke SendMessage,hTrv,TVM_DELETEITEM,0,eax
	.endif
	; Add root
	invoke Do_TreeViewAddNode,hTrv,TVI_ROOT,NULL,addr ProjectDescr,IML_START+0,IML_START+0,0
	mov		hGrpRoot,eax
	mov		hPrevPro[0],eax
	; Add project groups
	mov		esi,offset szGroupGroupBuff
	mov		edi,offset groupgrp
	invoke RtlZeroMemory,edi,sizeof groupgrp
	mov		iNbr,0
	.while byte ptr [esi] && iNbr<64
		inc		iNbr
		mov		ebx,iNbr
		neg		ebx
		.if byte ptr [esi]=='.'
			push	esi
			xor		edx,edx
			.while byte ptr [esi]=='.'
				inc		esi
				inc		edx
			.endw
			shr		edx,1
			mov		iInx,edx
			mov		edx,iInx
			invoke Do_TreeViewAddNode,hTrv,hPrevPro[edx*4],NULL,esi,IML_START+0,IML_START+0,ebx
			mov		edx,iInx
			inc		edx
			mov		hPrevPro[edx*4],eax
			pop		esi
		.else
			invoke Do_TreeViewAddNode,hTrv,hGrpRoot,NULL,esi,IML_START+0,IML_START+0,ebx
			mov		hPrevPro[4],eax
		.endif
		mov		[edi].PROGROUP.hGrp,eax
		mov		[edi].PROGROUP.lpszGrp,esi
		invoke strlen,esi
		lea		esi,[esi+eax+1]
		lea		edi,[edi+sizeof PROGROUP]
	.endw
	; Sort groups
	invoke SendMessage,hTrv,TVM_SORTCHILDREN,0,hGrpRoot
	xor		ebx,ebx
	mov		esi,offset groupgrp
	.while [esi].PROGROUP.lpszGrp
		mov		eax,[esi].PROGROUP.hGrp
		.if eax
			push	eax
			invoke SendMessage,hTrv,TVM_SORTCHILDREN,0,eax
			pop		edx
			.if groupexpand[ebx*4]
				invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,edx
			.endif
		.endif
		lea		esi,[esi+sizeof PROGROUP]
		inc		ebx
	.endw
	; Add files
	mov		esi,offset profile
	.while [esi].PROFILE.lpszFile
		.if [esi].PROFILE.iNbr<PRO_START_OBJ
			invoke GroupAddNode,hTrv,[esi].PROFILE.lpszFile,[esi].PROFILE.iNbr,[esi].PROFILE.nGrp,FALSE
		.else
			invoke GroupAddNode,hTrv,[esi].PROFILE.lpszFile,[esi].PROFILE.iNbr,[esi].PROFILE.nGrp,TRUE
		.endif
		lea		esi,[esi+sizeof PROFILE]
	.endw
	xor		ebx,ebx
	mov		esi,offset groupgrp
	.while [esi].PROGROUP.lpszGrp
		mov		eax,[esi].PROGROUP.hGrp
		.if eax
			.if groupexpand[ebx*4]
				invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,eax
			.endif
		.endif
		lea		esi,[esi+sizeof PROGROUP]
		inc		ebx
	.endw
	; Expand root
	invoke SendMessage,hTrv,TVM_EXPAND,TVE_EXPAND,hGrpRoot
	ret

GroupUpdateTrv endp

GroupGetExpand proc uses ebx esi edi,hTrv:HWND
	LOCAL	tvi:TVITEM
	
	mov		edi,offset groupgrp
	.while [edi].PROGROUP.hGrp
		mov		tvi._mask,TVIF_STATE
		mov		tvi.stateMask,TVIS_EXPANDED
		mov		eax,[edi].PROGROUP.hGrp
		mov		tvi.hItem,eax
		invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvi
		mov		esi,offset szGroupGroupBuff
		xor		ebx,ebx
		.while byte ptr [esi]
			invoke strcmp,esi,[edi].PROGROUP.lpszGrp
			.if !eax
				mov		eax,tvi.state
				and		eax,TVIS_EXPANDED
				mov		groupexpand[ebx*4],eax
			.endif
			invoke strlen,esi
			lea		esi,[esi+eax+1]
			inc		ebx
		.endw
		lea		edi,[edi+sizeof PROGROUP]
	.endw
	ret

GroupGetExpand endp

GroupHasGroupItem proc hTrv:HWND,hItem:DWORD
	LOCAL	tvi:TVITEM

	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_CHILD,hItem
	.while eax
		mov		tvi.hItem,eax
		mov		tvi._mask,TVIF_PARAM
		invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvi
		.if sdword ptr tvi.lParam>0 && eax
			.break
		.endif
		invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
	.endw
	ret

GroupHasGroupItem endp

GroupHasGroupGroup proc hTrv:HWND,hItem:DWORD
	LOCAL	tvi:TVITEM

	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_CHILD,hItem
	.while eax
		mov		tvi.hItem,eax
		mov		tvi._mask,TVIF_PARAM
		invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvi
		.if sdword ptr tvi.lParam<0 && eax
			.break
		.endif
		invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_NEXT,tvi.hItem
	.endw
	ret

GroupHasGroupGroup endp

GroupFindItem proc hTrv:HWND,hItem:DWORD,nInx:DWORD,nGroup:DWORD
	LOCAL	tvi:TVITEM

  @@:
	.if nInx
		mov		tvi._mask,TVIF_PARAM
		mov		eax,hItem
		mov		tvi.hItem,eax
		invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvi
		mov		edx,nGroup
		.if edx==tvi.lParam
			mov		eax,hItem
			mov		edx,nInx
			ret
		.endif
	.endif
	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_CHILD,hItem
	.if eax
		mov		edx,nInx
		inc		edx
		invoke GroupFindItem,hTrv,eax,edx,nGroup
		.if eax
			ret
		.endif
	.endif
	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_NEXT,hItem
	.if eax
		mov		hItem,eax
		jmp		@b
	.endif
	xor		eax,eax
	xor		edx,edx
	ret

GroupFindItem endp

GroupGetGroups proc uses ebx esi edi,hTrv:HWND
	LOCAL	tvi:TVITEM

	mov		edi,offset szGroupGroupBuff
	invoke RtlZeroMemory,edi,sizeof szGroupGroupBuff
	xor		ebx,ebx
	.while sdword ptr ebx>-32
		dec		ebx
		invoke GroupFindItem,hTrv,hGrpRoot,0,ebx
		.if eax
			mov		tvi._mask,TVIF_TEXT
			mov		tvi.hItem,eax
			.while edx>1
				mov		word ptr [edi],'..'
				add		edi,2
				dec		edx
			.endw
			mov		tvi.cchTextMax,64
			mov		tvi.pszText,edi
			invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvi
			invoke strlen,edi
			lea		edi,[edi+eax+1]
		.endif
	.endw
	ret

GroupGetGroups endp

GroupUpdateGroup proc uses ebx esi edi,hTrv:HWND

	invoke GroupGetGroups,hTrv
	invoke GroupUpdateTrv,hTrv
	ret

GroupUpdateGroup endp

GroupGetFirstVisible proc uses ebx,hTrv:HWND

	invoke GetScrollPos,hTrv,SB_VERT
	mov		nScrollPos,eax
	ret

GroupGetFirstVisible endp

GroupEnsureVisible proc hTrv:HWND

	invoke SetScrollPos,hTrv,SB_VERT,nScrollPos,TRUE
	ret

GroupEnsureVisible endp

GroupSaveGroups proc uses esi,hTrv:HWND
	LOCAL	buffer[8]:BYTE
	LOCAL	buffer1[8]:BYTE

	mov		esi,offset szGroupGroupBuff
	.while byte ptr [esi]
		invoke strlen,esi
		lea		esi,[esi+eax]
		.if byte ptr [esi+1]
			mov		byte ptr [esi],','
			inc		esi
		.endif
	.endw
	invoke WritePrivateProfileString,addr iniProjectGroup,addr iniProjectGroup,addr szGroupGroupBuff,addr ProjectFile
	mov		esi,offset profile
	.while [esi].PROFILE.lpszFile
		invoke BinToDec,[esi].PROFILE.iNbr,addr buffer
		invoke BinToDec,[esi].PROFILE.nGrp,addr buffer1
		invoke WritePrivateProfileString,addr iniProjectGroup,addr buffer,addr buffer1,addr ProjectFile
		lea		esi,[esi+sizeof PROFILE]
	.endw
	ret

GroupSaveGroups endp

GroupTVBeginDrag proc hWin:HWND,hParent:HWND,lParam:LPARAM
	LOCAL	DragStart:POINT
	LOCAL	tvi:TVITEM

	mov		edx,lParam
	mov		eax,[edx].NMTREEVIEW.itemNew.hItem
	mov		TVDragItem,eax
	mov		tvi.hItem,eax
	mov		tvi._mask,TVIF_IMAGE or TVIF_PARAM
	invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
	.if sdword ptr tvi.lParam>0
		mov		eax,tvi.iImage
		cmp		eax,0
		je		Ex
		mov		tvi._mask,TVIF_STATE
		mov		tvi.state,TVIS_DROPHILITED
		invoke SendMessage,hWin,TVM_SETITEM,0,addr tvi
		invoke GetCursorPos,addr DragStart
		invoke SendMessage,hWin,TVM_SELECTITEM,TVGN_DROPHILITE,TVDragItem
		invoke SendMessage,hWin,TVM_CREATEDRAGIMAGE,0,TVDragItem
		mov		hDragIml,eax
		invoke ImageList_BeginDrag,hDragIml,0,-8,-8
		invoke GetDesktopWindow
		invoke ImageList_DragEnter,eax,DragStart.x,DragStart.y
		invoke SetCapture,hParent
		mov		IsDragging,TRUE
	.else
		mov		TVDragItem,0
	.endif
  Ex:
	ret

GroupTVBeginDrag endp

GroupTVEndDrag proc uses ebx esi,hWin:HWND
	LOCAL	pt:POINT
	LOCAL	hroot:DWORD
	LOCAL	tvi:TVITEM
	LOCAL	tvht:TV_HITTESTINFO
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	nGrp:DWORD

	invoke ReleaseCapture
	invoke GetCursorPos,addr pt
	invoke WindowFromPoint,pt.x,pt.y
	.if eax==hWin
		invoke SendMessage,hWin,WM_SETREDRAW,FALSE,0
		invoke SendMessage,hWin,TVM_SELECTITEM,TVGN_DROPHILITE,NULL
		invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_ROOT,NULL
		mov		hroot,eax
		invoke GetCursorPos,addr tvht.pt
		invoke ScreenToClient,hWin,addr tvht.pt
		invoke SendMessage,hWin,TVM_HITTEST,0,addr tvht
		.if !eax
			invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_LASTVISIBLE,NULL
		.endif
		.if eax!=hroot
			mov		tvi._mask,TVIF_PARAM
			mov		tvi.hItem,eax
			invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
			mov		edx,tvi.lParam
			mov		eax,tvi.hItem
			.if sdword ptr edx>=0
				invoke SendMessage,hWin,TVM_GETNEXTITEM,TVGN_PARENT,eax
				.if eax==hroot
					mov		eax,tvht.hItem
				.endif
			.endif
			; The group item number is here
			mov		tvi.hItem,eax
			mov 	buffer,0
			lea		eax,buffer
			mov 	tvi.pszText,eax
			mov		tvi.cchTextMax,sizeof buffer
			mov		tvi._mask,TVIF_TEXT or TVIF_PARAM
			invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
			mov		ebx,tvi.lParam
			neg		ebx
			invoke lstrlen,addr buffer
			.if eax
				invoke GroupGetExpand,hWin
				mov		eax,TVDragItem
				mov		tvi.hItem,eax
				mov		tvi._mask,TVIF_PARAM
				invoke SendMessage,hWin,TVM_GETITEM,0,addr tvi
				mov		eax,tvi.lParam
				mov		esi,offset profile
				.while [esi].PROFILE.lpszFile
					.if eax==[esi].PROFILE.iNbr
						mov		[esi].PROFILE.nGrp,ebx
						.break
					.endif
					lea		esi,[esi+sizeof PROFILE]
				.endw
				invoke GroupGetFirstVisible,hWin
				invoke GroupUpdateTrv,hWin
				invoke GroupEnsureVisible,hWin
			.endif
		.endif
		invoke SendMessage,hWin,WM_SETREDRAW,TRUE,0
	.endif
	invoke ReleaseCapture
	invoke GetDesktopWindow
	invoke ImageList_DragLeave,eax
	invoke ImageList_EndDrag
	invoke ImageList_Destroy,hDragIml
	ret

GroupTVEndDrag endp

GroupTrvEditProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_GETDLGCODE
		mov		eax,DLGC_WANTALLKEYS
	.else
		invoke CallWindowProc,lpOldGroupTrvEditProc,hWin,uMsg,wParam,lParam
	.endif
	ret

GroupTrvEditProc endp

GroupAddGroup proc hTrv:HWND
	LOCAL	tvis:TV_INSERTSTRUCT
	LOCAL	tvi:TVITEM

	invoke SendMessage,hTrv,TVM_GETNEXTITEM,TVGN_CARET,0
	.if eax
		mov		tvis.item._mask,TVIF_PARAM
		mov		tvis.item.hItem,eax
		mov		tvis.hParent,eax
		mov		tvis.hInsertAfter,TVI_FIRST
		invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvis.item
		mov		eax,tvis.item.lParam
		mov		ebx,eax
		mov		edi,eax
		.if sdword ptr eax<=0
			invoke GroupHasGroupItem,hTrv,tvis.item.hItem
			.if eax
				dec		edi
			.endif
			mov		eax,edi
			neg		eax
			mov		edx,offset profile
			.while [edx].PROFILE.lpszFile
				.if [edx].PROFILE.nGrp>=eax
					inc		[edx].PROFILE.nGrp
				.endif
				lea		edx,[edx+sizeof PROFILE]
			.endw
			mov		edi,-32
			.while edi!=ebx
				invoke GroupFindItem,hTrv,hGrpRoot,0,edi
				.if eax
					mov		tvi._mask,TVIF_PARAM
					mov		tvi.hItem,eax
					invoke SendMessage,hTrv,TVM_GETITEM,0,addr tvi
					dec		tvi.lParam
					invoke SendMessage,hTrv,TVM_SETITEM,0,addr tvi
				.endif
				inc		edi
			.endw
			mov		tvis.item._mask,TVIF_PARAM or TVIF_TEXT or TVIF_IMAGE or TVIF_SELECTEDIMAGE
			mov		tvis.item.pszText,offset szNewGroup
			mov		tvis.item.iImage,IML_START+0
			mov		tvis.item.iSelectedImage,IML_START+0
			dec		tvis.item.lParam
			invoke SendMessage,hTrv,TVM_INSERTITEM,0,addr tvis
			invoke GroupGetExpand,hTrv
			invoke GroupUpdateGroup,hTrv
			invoke GroupFindItem,hTrv,0,0,tvis.item.lParam
			push	eax
			invoke SendMessage,hTrv,TVM_ENSUREVISIBLE,0,eax
			pop		eax
			invoke SendMessage,hTrv,TVM_EDITLABEL,0,eax
		.endif
	.endif
	ret

GroupAddGroup endp

ProjectGroupsProc proc uses ebx esi edi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	buffer[64]:BYTE
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	tvis:TV_INSERTSTRUCT
	LOCAL	tvi:TVITEM
	LOCAL	tvht:TV_HITTESTINFO

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hProjectGroup,eax
		invoke GetDlgItem,hWin,IDC_TRVPROJECT
		mov		hGrpTrv,eax
		invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
		xor		edi,edi
		invoke GetGroupState,hPbrTrv,eax
		invoke SendMessage,hGrpTrv,TVM_SETBKCOLOR,0,radcol.project
		invoke SendMessage,hGrpTrv,TVM_SETTEXTCOLOR,0,radcol.projecttext
		invoke SendMessage,hGrpTrv,TVM_SETIMAGELIST,0,hTbrIml
		mov		edi,offset szGroupGroupBuff
		mov		esi,offset szGroupBuff
		mov		ecx,sizeof szGroupGroupBuff
		rep movsb
		invoke GroupGetProjectFiles
		invoke GroupUpdateTrv,hGrpTrv
		invoke SendMessage,hGrpTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
		push	eax
		invoke GroupCollapseAll,hGrpTrv,eax
		pop		eax
		xor		edi,edi
		invoke SetGroupState,hGrpTrv,eax
		invoke SetDlgItemText,hWin,IDC_EDTDEFGROUP,addr szGroups
		invoke SetLanguage,hWin,IDD_DLGPROJECTGROUPS,FALSE
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDOK
				invoke SendMessage,hGrpTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
				xor		edi,edi
				invoke GetGroupState,hGrpTrv,eax
				invoke GroupSaveGroups,hGrpTrv
				invoke GetProjectFiles,FALSE
				invoke SendMessage,hPbrTrv,TVM_GETNEXTITEM,TVGN_ROOT,0
				push	eax
				invoke GroupCollapseAll,hPbrTrv,eax
				pop		eax
				xor		edi,edi
				invoke SetGroupState,hPbrTrv,eax
				invoke GetDlgItemText,hWin,IDC_EDTDEFGROUP,offset szGroups,sizeof szGroups
				invoke WritePrivateProfileString,addr iniProjectGroup,addr iniProjectGroup,addr szGroups,addr iniAsmFile
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDM_GROUPEXPAND
				invoke GroupExpandAll,hGrpTrv,0
			.elseif eax==IDM_GROUPCOLLAPSE
				invoke GroupCollapseAll,hGrpTrv,0
			.elseif eax==IDM_GROUPADD
				invoke GroupAddGroup,hGrpTrv
			.elseif eax==IDM_GROUPDELETE
				invoke SendMessage,hGrpTrv,TVM_GETNEXTITEM,TVGN_CARET,0
				.if eax
					mov		tvis.item._mask,TVIF_PARAM
					mov		tvis.item.hItem,eax
					invoke SendMessage,hGrpTrv,TVM_GETITEM,0,addr tvis.item
					mov		eax,tvis.item.lParam
					.if sdword ptr eax<0
						mov		ebx,eax
						invoke SendMessage,hGrpTrv,TVM_GETCOUNT,0,0
						.if eax>1
							mov		eax,ebx
							neg		eax
							mov		edx,offset profile
							.while [edx].PROFILE.lpszFile
								.if [edx].PROFILE.nGrp>=eax
									dec		[edx].PROFILE.nGrp
								.endif
								lea		edx,[edx+sizeof PROFILE]
							.endw
							invoke SendMessage,hGrpTrv,TVM_DELETEITEM,0,tvis.item.hItem
							.while sdword ptr ebx>-32
								dec		ebx
								invoke GroupFindItem,hGrpTrv,hGrpRoot,0,ebx
								.if eax
									mov		tvi._mask,TVIF_PARAM
									mov		tvi.hItem,eax
									invoke SendMessage,hGrpTrv,TVM_GETITEM,0,addr tvi
									inc		tvi.lParam
									invoke SendMessage,hGrpTrv,TVM_SETITEM,0,addr tvi
								.endif
							.endw
							invoke GroupGetExpand,hGrpTrv
							invoke GroupUpdateGroup,hGrpTrv
						.endif
					.endif
				.endif
			.elseif eax==IDM_GROUPEDIT
				invoke SendMessage,hGrpTrv,TVM_GETNEXTITEM,TVGN_CARET,0
				.if eax
					mov		tvi._mask,TVIF_PARAM
					mov		tvi.hItem,eax
					invoke SendMessage,hGrpTrv,TVM_GETITEM,0,addr tvi
					mov		eax,tvi.lParam
					.if sdword ptr eax<0
						invoke SetFocus,hGrpTrv
						invoke SendMessage,hGrpTrv,TVM_EDITLABEL,0,tvi.hItem
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_CONTEXTMENU
		mov		eax,wParam
		.if eax==hGrpTrv
			mov		edx,lParam
			movsx	eax,dx
			shr		edx,16
			movsx	edx,dx
			mov		tvht.pt.x,eax
			mov		tvht.pt.y,edx
			invoke ScreenToClient,hGrpTrv,addr tvht.pt
			invoke SendMessage,hGrpTrv,TVM_HITTEST,0,addr tvht
			test	tvht.flags,TVHT_ONITEM
			.if !ZERO?
				invoke GetSubMenu,hToolMenu,5
				mov		ebx,eax
				invoke SendMessage,hGrpTrv,TVM_SELECTITEM,TVGN_CARET,tvht.hItem
				mov		tvi._mask,TVIF_PARAM
				mov		eax,tvht.hItem
				mov		tvi.hItem,eax
				invoke SendMessage,hGrpTrv,TVM_GETITEM,0,addr tvi
				.if sdword ptr tvi.lParam<0
					mov		edi,MF_ENABLED or MF_BYCOMMAND
				.else
					mov		edi,MF_GRAYED or MF_BYCOMMAND
				.endif
				invoke EnableMenuItem,ebx,IDM_GROUPEDIT,edi
				.if sdword ptr tvi.lParam<0
					invoke GroupHasGroupGroup,hGrpTrv,tvi.hItem
					.if eax
						mov		edi,MF_GRAYED or MF_BYCOMMAND
					.else
						mov		edi,MF_ENABLED or MF_BYCOMMAND
					.endif
				.else
					mov		edi,MF_GRAYED or MF_BYCOMMAND
				.endif
				invoke EnableMenuItem,ebx,IDM_GROUPDELETE,edi
				.if sdword ptr tvi.lParam<=0
					mov		edi,MF_ENABLED or MF_BYCOMMAND
				.endif
				invoke EnableMenuItem,ebx,IDM_GROUPADD,edi
				invoke ClientToScreen,hGrpTrv,addr tvht.pt
				invoke TrackPopupMenu,ebx,TPM_LEFTALIGN or TPM_RIGHTBUTTON,tvht.pt.x,tvht.pt.y,0,hWnd,0
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		mov		ebx,lParam
		mov		eax,[ebx].NMHDR.hwndFrom
		.if eax==hGrpTrv
			mov		eax,[ebx].NMHDR.code
			.if eax==TVN_BEGINDRAGW || eax==TVN_BEGINDRAG
				.if sdword ptr [ebx].NM_TREEVIEW.itemNew.lParam>0
					invoke GroupTVBeginDrag,[ebx].NMHDR.hwndFrom,hWin,lParam
				.else
					invoke SendMessage,[ebx].NMHDR.hwndFrom,TVM_SELECTITEM,TVGN_CARET,[ebx].NM_TREEVIEW.itemNew.hItem
				.endif
			.elseif eax==TVN_BEGINLABELEDITW || eax==TVN_BEGINLABELEDIT
				invoke SendMessage,hGrpTrv,TVM_GETEDITCONTROL,0,0
				push	eax
				invoke SetWindowLong,eax,GWL_WNDPROC,offset GroupTrvEditProc
				mov		lpOldGroupTrvEditProc,eax
				pop		eax
				.if sdword ptr [ebx].NMTVDISPINFO.item.lParam>=0
					invoke PostMessage,hGrpTrv,TVM_ENDEDITLABELNOW,TRUE,0
				.endif
			.elseif eax==TVN_ENDLABELEDIT
				.if [ebx].NMTVDISPINFO.item.pszText && sdword ptr [ebx].NMTVDISPINFO.item.lParam<0
					invoke SendMessage,hGrpTrv,TVM_SETITEM,0,addr [ebx].NMTVDISPINFO.item
					invoke GroupGetExpand,hGrpTrv
					invoke GroupUpdateGroup,hGrpTrv
				.endif
			.elseif eax==TVN_ENDLABELEDITW
				.if [ebx].NMTVDISPINFO.item.pszText && sdword ptr [ebx].NMTVDISPINFO.item.lParam<0
					invoke lstrlenW,[ebx].NMTVDISPINFO.item.pszText
					mov		edx,eax
					invoke WideCharToMultiByte,CP_ACP,0,[ebx].NMTVDISPINFO.item.pszText,edx,addr buffer,sizeof buffer,NULL,NULL
					mov		byte ptr buffer[eax],0
					lea		eax,buffer
					mov		[ebx].NMTVDISPINFO.item.pszText,eax
					invoke SendMessage,hGrpTrv,TVM_SETITEM,0,addr [ebx].NMTVDISPINFO.item
					invoke GroupGetExpand,hGrpTrv
					invoke GroupUpdateGroup,hGrpTrv
				.endif
			.endif
		.endif
	.elseif eax==WM_LBUTTONUP
		.if IsDragging
			mov		IsDragging,FALSE
			invoke GroupTVEndDrag,hGrpTrv
		.endif
	.elseif eax==WM_MOUSEMOVE
		.if IsDragging
			invoke GetCursorPos,addr pt
			invoke ImageList_DragMove,pt.x,pt.y
			invoke GetWindowRect,hGrpTrv,addr rect
			invoke GetScrollPos,hGrpTrv,SB_VERT
			mov		ebx,eax
			mov		edx,pt.y
			.if sdword ptr edx<rect.top
				dec		ebx
				mov		eax,ebx
				shl		eax,16
				or		eax,SB_LINEUP
				invoke SendMessage,hGrpTrv,WM_VSCROLL,eax,0
			.elseif sdword ptr edx>rect.bottom
				inc		ebx
				mov		eax,ebx
				shl		eax,16
				or		eax,SB_LINEDOWN
				invoke SendMessage,hGrpTrv,WM_VSCROLL,eax,0
			.endif
		.endif
	.elseif eax==WM_CLOSE
		mov		hProjectGroup,0
		invoke EndDialog,hWin,NULL
	.else
		mov eax,FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

ProjectGroupsProc endp
