#Include "RadFavs.Inc"
#Include "C:\RadASM\GoAsm\Inc\RadAsm.inc"

ADDINOPT struct
	lpStr			dd ?
	nAnd			dd ?
	nOr				dd ?
ADDINOPT ends

MENUSTRUCT struct
	szMenuText		DB	64 DUP
	szPath			DB	MAX_PATH DUP
ENDS

.data
	hInstance		DD		0
	lpHandles		DD		0
	lpProcs			DD		0
	lpData			DD		0

	hFavMenu		DD		0
	hRadASM			DD		0
	hManageDlg		DD		0

	TopIDIndex		DD		0

	FavsID			DD		0
	AddToID			DD		0
	ManageID		DD		0
	FirstID			DD		0
	LastID			DD		0

	DrgListMsg		DD		0
	
	pSetMenuInfo	DD		0
	pGetMenuInfo	DD		0

	IDTable			DD		2048 DUP (?)

	szAddDlg		DB		"RadFavs#1",0
	szManageDlg		DB		"RadFavs#2",0
	szAppName		DB		"RadFavs",0
	szFavourites	DB		"Favourites",0
	szAddToFavs		DB		"Add to favourites",0
	szManageFavs	DB		"Manage favourites",0

	AddinOpt		ADDINOPT	<0,0,0>

.code

GetOptions:
	mov eax,offset AddinOpt
	ret

DllEntryPoint FRAME hInst, reason, reserved1
    mov eax,[hInst]
    mov [hInstance], eax
    xor eax, eax
    inc eax
    ret
ENDF

InstallDll FRAME hWin, fOpt
	uses ebx
	LOCAL menui				:MENUINFO
	LOCAL IniPath[MAX_PATH]	:B
	LOCAL cbWrite			:D
	LOCAL menuii			:MENUITEMINFO

	invoke SendMessage, [hWin], AIM_GETHANDLES, 0, 0
	mov	[lpHandles], eax
	invoke SendMessage, [hWin], AIM_GETPROCS, 0, 0
	mov [lpProcs], eax
	invoke SendMessage, [hWin], AIM_GETDATA, 0, 0
	mov [lpData], eax

	invoke CreatePopupMenu
	mov [hFavMenu],eax

	mov eax,[hWin]
	mov [hRadASM],eax

	; Get the path of the favourites
	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.lpLoadPath]
	invoke lstrcpy,offset IniPath,eax
	invoke lstrcat,offset IniPath,"\RadFavs.ini"

	invoke GetFileAttributes,offset IniPath
	or eax,eax
	jns >
		invoke DeleteFile,offset IniPath
		invoke CreateFile,offset IniPath,GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,NULL,NULL
		mov ebx,eax
		invoke WriteFile,ebx,"[Favourites]",12,offset cbWrite,NULL
		invoke CloseHandle,ebx
	:

	invoke SendMessage, [hWin], AIM_GETMENUID, 0, 0
	mov [FavsID],eax

	invoke SendMessage, [hWin], AIM_GETMENUID, 0, 0
	mov [AddToID],eax
	invoke AppendMenu,[hFavMenu],MF_ENABLED + MF_STRING,[AddToID],offset szAddToFavs

	invoke SendMessage, [hWin], AIM_GETMENUID, 0, 0
	mov [ManageID],eax
	invoke AppendMenu,[hFavMenu],MF_ENABLED + MF_STRING,[ManageID],offset szManageFavs

	invoke AppendMenu,[hFavMenu],MF_SEPARATOR,NULL,offset szManageFavs

	xor ebx,ebx
	:
	invoke SendMessage, [hRadASM], AIM_GETMENUID, 0, 0
	mov ecx,offset IDTable
	mov [ecx+ebx*8],eax
	inc ebx
	cmp ebx,1024
	jl <

	mov D[menuii.cbSize],sizeof MENUITEMINFO
	mov D[menuii.fMask],MIIM_ID+MIIM_SUBMENU+MIIM_TYPE
	mov eax,[FavsID]
	mov D[menuii.wID],eax
	mov eax,[hFavMenu]
	mov D[menuii.hSubMenu],eax
	mov D[menuii.fType],MFT_STRING
	mov D[menuii.dwTypeData],offset szFavourites
	mov eax,[lpHandles]
	invoke InsertMenuItem,[eax+ADDINHANDLES.hMenu],-1,TRUE,addr menuii

	invoke GetGlobalFavs,[hFavMenu]

	; If this is WinNT4 or Win95 the Get/SetMenuInfo functions
	; are not available and will not execute.
	invoke GetModuleHandle,"User32.dll"
	mov ebx,eax
	invoke GetProcAddress,ebx,"SetMenuInfo"
	mov [pSetMenuInfo],eax
	invoke GetProcAddress,ebx,"GetMenuInfo"
	mov [pGetMenuInfo],eax

	; be sure our menu has the same appearance as the others
	mov D[menui.cbSize],SIZEOF MENUINFO
	mov D[menui.fmask],MIM_BACKGROUND
	mov eax,[lpHandles]
	mov eax,[eax+ADDINHANDLES.hMenu]
	invoke GetSubMenu,eax,1
	invoke GetMenuInfo,eax,offset menui
	invoke SetMenuInfo,[hFavMenu],offset menui

	invoke DrawMenuBar,[hRadASM]

	invoke RegisterWindowMessage,"commctrl_DragListMsg"
	mov [DrgListMsg],eax

	mov eax,RAM_CLOSE+RAM_COMMAND
	mov ecx,RAM_ADDINSLOADED
	xor edx,edx
	ret
ENDF

FreeMenuBuffers FRAME hmenu
	uses ebx,esi

	mov esi,offset IDTable
	xor ebx,ebx
	L2:
		mov eax,[esi+ebx*8+4]
		or eax,eax
		jz >.EXIT
		invoke GlobalHandle,eax
		invoke GlobalFree,eax
		mov D[esi+ebx*8+4],0
		inc ebx
		cmp ebx,1024
		jl <L2

	.EXIT
	RET
ENDF

GetGlobalFavs FRAME hmenu
	uses ebx,edi,esi
	LOCAL buffer[324]		:B
	LOCAL IniPath[MAX_PATH]	:B
	LOCAL Index[16]			:B

	mov eax,[IDTable]
	mov D[FirstID],eax
	mov D[LastID],eax

	; Get the path of the favourites
	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.lpLoadPath]
	invoke lstrcpy,offset IniPath,eax
	invoke lstrcat,offset IniPath,"\RadFavs.ini"

	xor ebx,ebx
	L1:
		inc ebx
		invoke wsprintf,offset Index,"%u",ebx
		add esp,12
		invoke GetPrivateProfileString,"Favourites",offset Index,"",\
			offset buffer,324,offset IniPath
		or eax,eax
		jz >>.EXIT
		push eax
		inc eax
		invoke GlobalAlloc,GMEM_ZEROINIT,eax
		mov edi,eax
		mov esi,eax
		invoke lstrcpy,eax,offset buffer
		pop ecx
		mov al,","
		repne scasb
		mov B[edi-1],0

		mov edx,offset IDTable
		mov ecx,[TopIDIndex]
		mov [edx+ecx*8+4],esi
		mov eax,[edx+ecx*8]

		mov [LastID],eax
		invoke AppendMenu,[hmenu],MF_ENABLED + MF_STRING,eax,esi
		inc D[TopIDIndex]
		cmp D[TopIDIndex],1024
		jl <<L1

	.EXIT
	RET
ENDF

AddToFavourites FRAME
	uses ebx,esi,edi
	LOCAL MenuLabel[64]		:B
	LOCAL FileName[MAX_PATH]:B
	LOCAL Index[16]			:B
	LOCAL IniPath[MAX_PATH]	:B
	LOCAL OutString[324]	:B
	LOCAL DlgStruct[2]		:D
	
	LOCAL pPath				:D

	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.fProject]
	or eax,eax
	jz >>.EXIT
	cmp D[TopIDIndex],1024
	jge >>.EXIT

	mov eax,OFFSET MenuLabel
	mov D[DlgStruct],eax
	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.lpProject]
	mov D[DlgStruct+4],eax

	; Get the path of the favourites
	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.lpLoadPath]
	invoke lstrcpy,offset IniPath,eax
	invoke lstrcat,offset IniPath,"\RadFavs.ini"

	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.lpProject]
	invoke GetPrivateProfileString,"Project","Description","",OFFSET MenuLabel,64,eax

	push offset DlgStruct
	push offset EnterLabelDlgProc
	push [hRadASM]
	push 1000
	push [hInstance]
	mov eax,[lpProcs]
	call [eax+ADDINPROCS.lpModalDialog]
	or eax,eax
	js >>.EXIT

	; Get next index
	xor ebx,ebx
	:
		inc ebx
		invoke wsprintf,offset Index,"%u",ebx
		add esp,12
		invoke GetPrivateProfileString,"Favourites",offset Index,"",\
			offset FileName,MAX_PATH,offset IniPath
		or eax,eax
		jnz <
	:

	mov B[FileName],","
	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.lpProject]
	invoke lstrcpy,offset FileName+1,eax

	invoke lstrcpy,offset OutString,offset MenuLabel
	invoke lstrcat,offset OutString,offset FileName

	invoke WritePrivateProfileString,"Favourites",offset Index,offset OutString,offset IniPath

	invoke lstrlen,offset OutString
	inc eax
	invoke GlobalAlloc,GMEM_ZEROINIT,eax
	mov edi,eax
	mov esi,eax
	invoke lstrcpy,eax,offset OutString
	mov al,","
	repne scasb
	mov B[edi-1],0

	mov edx,offset IDTable
	mov ecx,[TopIDIndex]
	mov [edx+ecx*8+4],esi
	mov eax,[edx+ecx*8]
	mov [LastID],eax
	invoke AppendMenu,[hFavMenu],MF_ENABLED + MF_STRING,eax,esi
	inc D[TopIDIndex]

	.EXIT
	RET
ENDF

EnterLabelDlgProc FRAME hwnd,uMsg,wParam,lParam
	uses ebx,edi
	cmp D[uMsg],WM_INITDIALOG
	jne >M1
		invoke GetDlgItem,[hwnd],1002
		mov ebx,eax
		mov edi,[lParam]
		invoke GetDlgItem,[hwnd],1004
		invoke SendMessage,eax,WM_SETTEXT,0,[edi+4]
		invoke SendMessage,ebx,WM_SETTEXT,0,[edi]
		invoke SendMessage,ebx,EM_LIMITTEXT,63,0
		invoke SetWindowLong,ebx,GWL_USERDATA,[edi]
		mov B[edi],0
		push FALSE
		push offset szAddDlg
		push [hwnd]
		mov eax,[lpProcs]
		call [eax+ADDINPROCS.lpSetLanguage]
		jmp >.EXIT

	M1:
	cmp D[uMsg],WM_CLOSE
	jne >M2
		invoke EndDialog,[hwnd],-1
		jmp >.EXIT

	M2:
	cmp D[uMsg],WM_COMMAND
	jne >.DEFPROC
		movzx eax,W[wParam]
		cmp eax,IDOK
		jne >C1
			invoke GetDlgItem,[hwnd],1002
			mov ebx,eax
			invoke GetWindowLong,ebx,GWL_USERDATA
			invoke SendMessage,ebx,WM_GETTEXT,64,eax
			invoke EndDialog,[hwnd],0
			jmp >.EXIT
		C1:
		cmp eax,IDCANCEL
		jne >.DEFPROC
			invoke PostMessage,[hwnd],WM_CLOSE,0,0
			jmp >.EXIT

	.DEFPROC
		xor eax,eax
		ret

	.EXIT

	xor eax,eax
	inc eax
	RET
ENDF

DllProc	FRAME hWin, uMsg, wParam, lParam
	uses ebx
	LOCAL tbuf[16]			:B
	LOCAL menuii			:MENUITEMINFO
	LOCAL buffer[256]		:B

	cmp D[uMsg], AIM_COMMAND
	jnz >>.AIMCLOSE
		movzx eax,W[wParam]
		cmp eax,[FirstID]
		jl >>.ADDTOFAVS
		cmp eax,[LastID]
		jg >>.ExitMsgLoop
		mov edx,offset IDTable
		xor ecx,ecx
		:
		cmp eax,[edx+ecx*8]
		jz >
		inc ecx
		cmp ecx,1024
		jl <
		jmp >>.ExitMsgLoop
		:
		mov eax,[edx+ecx*8+4]
		or eax,eax
		jz >>.ExitMsgLoop
		push eax
		invoke lstrlen,eax
		pop ecx
		lea eax,[ecx+eax+1]
		mov ecx,[lpData]
		mov ecx,[ecx+ADDINDATA.lpFile]
		invoke lstrcpy,ecx,eax
		mov eax,[lpProcs]
		mov eax,[eax+ADDINPROCS.lpOpenProject]
		push TRUE
		call eax
		jmp >>.ExitMsgLoop

		.ADDTOFAVS
		cmp eax,[AddToID]
		jne >.EDITFAVS
		invoke AddToFavourites
		
		jmp >>.ExitMsgLoop
		.EDITFAVS
		cmp eax,[ManageID]
		jne >>.ExitMsgLoop
;			invoke DialogBoxParam,[hInstance],1100,[hRadASM],offset ManageDlgProc,NULL
			push NULL
			push offset ManageDlgProc
			push [hRadASM]
			push 1100
			push [hInstance]
			mov eax,[lpProcs]
			call [eax+ADDINPROCS.lpModalDialog]
		jmp >>.ExitMsgLoop

	.AIMCLOSE
	cmp D[uMsg], AIM_CLOSE
	jnz >.AIMADDINSLOADED
		invoke FreeMenuBuffers,[hFavMenu]
		mov eax,[lpHandles]
		mov eax,[eax+ADDINHANDLES.hMenu]
		invoke DeleteMenu,eax,[hFavMenu],MF_BYCOMMAND
		invoke DrawMenuBar,[hRadASM]
		mov D[TopIDIndex],0

	.AIMADDINSLOADED
	cmp D[uMsg], AIM_ADDINSLOADED
	jnz >.ExitMsgLoop
		mov		edx,2000
		mov		ecx,[FavsID]
		call	Translate
		mov		edx,2001
		mov		ecx,[AddToID]
		call	Translate
		mov		edx,2002
		mov		ecx,[ManageID]
		call	Translate
		invoke DrawMenuBar,[hRadASM]
	.ExitMsgLoop
	xor eax, eax
	ret

Translate:
	push	ecx
	push	128
	lea		eax,buffer
	push	eax
	push	edx
	push	offset szAppName
	mov		eax,[lpProcs]
	call	[eax+ADDINPROCS.lpGetLangString]
	pop		ecx
	or		eax,eax
	je		>
		mov		D[menuii.cbSize],sizeof MENUITEMINFO
		mov		D[menuii.fMask],MIIM_TYPE
		mov		D[menuii.fType],MFT_STRING
		lea		eax,buffer
		mov		D[menuii.dwTypeData],eax
		;Insert our menuitem
		mov		edx,[lpHandles]
		invoke SetMenuItemInfoW,[edx+ADDINHANDLES.hMenu],ecx,FALSE,addr menuii
	:
	retn

ENDF

ManageDlgProc FRAME hwnd,uMsg,wParam,lParam
	uses edi,ebx,esi
	LOCAL pt			:POINT
	LOCAL rect			:RECT
	LOCAL buffer[256]	:B

	mov eax,[uMsg]
	.WMINITDIALOG
		cmp eax,WM_INITDIALOG
		jne >>.DRAGLIST
		invoke GetDlgItem,[hwnd],1101
		mov ebx,eax
		invoke MakeDragList,ebx
		mov esi,offset IDTable
		L1:
		mov edi,[esi+4]
		or edi,edi
		jz > L2
		invoke SendMessage,ebx,LB_ADDSTRING,0,edi
		push eax
		invoke lstrlen,edi
		lea eax,[edi+eax+1]
		pop edx
		invoke SendMessage,ebx,LB_SETITEMDATA,edx,eax
		add esi,8
		jmp L1
		L2:
		invoke GetDlgItem,[hwnd],1106
		invoke SendMessage,eax,EM_LIMITTEXT,63,0
		push FALSE
		push offset szManageDlg
		push [hwnd]
		mov eax,[lpProcs]
		call [eax+ADDINPROCS.lpSetLanguage]
		JMP >>.EXIT

	.DRAGLIST
		cmp eax,[DrgListMsg]
		jne >>.WMCOMMAND
			mov edi,[lParam]
			cmp D[edi+DRAGLISTINFO.uNotification],DL_BEGINDRAG
			jne >.DL_DRAGGING
				invoke SendDlgItemMessage,[hwnd],1101,LB_GETCOUNT,0,0
				or eax,eax
				jz >>.EXIT
				invoke LBItemFromPt,[edi+DRAGLISTINFO.hWnd],[edi+DRAGLISTINFO.ptCursor.x],\
					[edi+DRAGLISTINFO.ptCursor.y],FALSE
				push eax
				invoke DrawInsert,[hwnd],[edi+DRAGLISTINFO.hWnd],eax
				pop eax
				invoke SetWindowLong,[edi+DRAGLISTINFO.hWnd],GWL_USERDATA,eax
				invoke SetWindowLong,[hwnd],DWL_MSGRESULT,TRUE
				mov eax,TRUE
				ret

			.DL_DRAGGING
			cmp D[edi+DRAGLISTINFO.uNotification],DL_DRAGGING
			jne >>.DL_DROPPED
				invoke LBItemFromPt,[edi+DRAGLISTINFO.hWnd],[edi+DRAGLISTINFO.ptCursor.x],\
					[edi+DRAGLISTINFO.ptCursor.y],FALSE
				or eax,eax
				jns >>D3
					; Check to see if the listbox needs scrolling
					invoke GetCursorPos,offset pt
					invoke GetWindowRect,[edi+DRAGLISTINFO.hWnd],offset rect
					mov eax,[pt.y]
					cmp eax,[rect.top]
					jg >D1
						invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_GETTOPINDEX,0,0
						or eax,eax
						jz >D2
						dec eax
						invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_SETTOPINDEX,eax,0
						jmp >D2
					D1:
					cmp eax,[rect.bottom]
					jl >D2
						invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_GETTOPINDEX,0,0
						inc eax
						invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_SETTOPINDEX,eax,0
					D2:
					invoke SetWindowLong,[hwnd],DWL_MSGRESULT, DL_STOPCURSOR
					mov eax,TRUE
					ret
				D3:
				invoke DrawInsert,[hwnd],[edi+DRAGLISTINFO.hWnd],eax
				invoke SetWindowLong,[hwnd],DWL_MSGRESULT,DL_MOVECURSOR
				mov eax,TRUE
				ret

			.DL_DROPPED
			cmp D[edi+DRAGLISTINFO.uNotification],DL_DROPPED
			jne >>.EXIT
				invoke SendDlgItemMessage,[hwnd],1101,LB_GETCOUNT,0,0
				or eax,eax
				jz >>.EXIT
				invoke GetWindowLong,[edi+DRAGLISTINFO.hWnd],GWL_USERDATA
				mov ebx,eax
				invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_GETTEXT,ebx,offset buffer
				invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_GETITEMDATA,ebx,0
				mov esi,eax
				invoke LBItemFromPt,[edi+DRAGLISTINFO.hWnd],[edi+DRAGLISTINFO.ptCursor.x],\
					[edi+DRAGLISTINFO.ptCursor.y],FALSE
				or eax,eax
				jns >
					ret
				:
				invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_INSERTSTRING,eax,offset buffer
				push eax
				invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_SETITEMDATA,eax,esi
				pop eax
				invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_SETCURSEL,eax,0
				cmp ebx,eax
				jl >
					inc ebx
				:
				invoke SendMessage,[edi+DRAGLISTINFO.hWnd],LB_DELETESTRING,ebx,0
				invoke DrawInsert,[hwnd],[edi+DRAGLISTINFO.hWnd],-1				
				jmp >>.EXIT

	.WMCOMMAND
		cmp eax,WM_COMMAND
		jne >>.WMCONTEXTMENU
		movzx eax,W[wParam+2]
		cmp eax,LBN_SELCHANGE
		jne >>C1
			invoke SendMessage,[lParam],LB_GETCURSEL,0,0
			cmp eax,LB_ERR
			jz >>.EXIT
			mov ebx,eax
			invoke SendMessage,[lParam],LB_GETITEMDATA,ebx,0
			or eax,eax
			jz >>.EXIT
				push eax
				invoke GetDlgItem,[hwnd],1104
				pop ecx
				invoke GetRAPInfo,ecx,eax
				invoke SendMessage,[lParam],LB_GETTEXT,ebx,offset buffer
				invoke GetDlgItem,[hwnd],1106
				invoke SendMessage,eax,WM_SETTEXT,0,offset buffer
				jmp >>.EXIT
		C1:
		movzx eax,W[wParam]
		cmp eax,1
		jne >C2
			invoke GetDlgItem,[hwnd],1101
			invoke RebuildFavsFile,eax
			invoke PostMessage,[hwnd],WM_CLOSE,0,0
			jmp >>.EXIT
		C2:
		cmp eax,2
		jne >C3
			invoke PostMessage,[hwnd],WM_CLOSE,0,0
			jmp >>.EXIT
		C3:
		cmp eax,1108
		jne >>.EXIT
			invoke GetDlgItem,[hwnd],1101
			mov ebx,eax
			invoke GetDlgItem,[hwnd],1106
			invoke SendMessage,eax,WM_GETTEXT,64,offset buffer
			or eax,eax
			jz >>.EXIT
			invoke SendMessage,ebx,LB_GETCURSEL,0,0
			mov esi,eax
			or eax,eax
			js >>.EXIT
			invoke SendMessage,ebx,LB_GETITEMDATA,esi,0
			mov edi,eax
			or eax,eax
			jz >>.EXIT
			invoke SendMessage,ebx,LB_INSERTSTRING,esi,offset buffer
			push eax
			invoke SendMessage,ebx,LB_SETITEMDATA,eax,edi
			inc esi
			invoke SendMessage,ebx,LB_DELETESTRING,esi,0
			pop eax
			invoke SendMessage,ebx,LB_SETCURSEL,eax,0
			jmp >>.EXIT

	.WMCONTEXTMENU
		cmp eax,WM_CONTEXTMENU
		jne >>.WMCLOSE
		invoke GetCursorPos,offset pt
		invoke GetDlgItem,[hwnd],1101
		mov edi,eax
		invoke ScreenToClient,edi,offset pt
		mov ecx,[pt.y]
		shl ecx,16
		mov cx,[pt.x]
		invoke SendMessage,edi,LB_ITEMFROMPOINT,0,ecx
		mov esi,eax
		shr eax,16
		or eax,eax
		jnz >>.EXIT
		invoke SendMessage,edi,LB_SETCURSEL,esi,0
		invoke GetCursorPos,offset pt

		invoke SendMessage,edi,LB_GETITEMDATA,esi,0
		or eax,eax
		jz >
		push eax
		invoke GetDlgItem,[hwnd],1104
		pop ecx
		invoke GetRAPInfo,ecx,eax
		invoke SendMessage,edi,LB_GETTEXT,esi,offset buffer
		invoke GetDlgItem,[hwnd],1106
		invoke SendMessage,eax,WM_SETTEXT,0,offset buffer
		:

		invoke CreatePopupMenu
		mov ebx,eax
		invoke AppendMenu,ebx,MF_ENABLED + MF_STRING,10000,"Delete"
		invoke TrackPopupMenuEx,ebx,TPM_RETURNCMD,[pt.x],[pt.y],[hwnd],NULL
		;
		cmp eax,10000
		jne >
			invoke SendMessage,edi,LB_DELETESTRING,esi,0
		:
		invoke DestroyMenu,ebx
		jmp >.EXIT

	.WMCLOSE
		cmp eax,WM_CLOSE
		jne >.DEFPROC
		INVOKE EndDialog,[hwnd],0

	.DEFPROC
		mov EAX,FALSE
		RET

	.EXIT

	MOV EAX, TRUE
	RET
ENDF

GetRAPInfo FRAME pRAPFile,hOutput
	LOCAL outstring[1024]		:B
	LOCAL hFile					:D
	LOCAL lwt					:FILETIME
	LOCAL lwtLocal				:FILETIME
	LOCAL stLocal				:SYSTEMTIME

	LOCAL szFileTime[64]		:B
	LOCAL szTempDate[64]		:B
	LOCAL szTempTime[64]		:B

	LOCAL szAssembler[1024]		:B
	LOCAL szType[1024]			:B
	LOCAL szDescription[1024]	:B

	invoke CreateFile,[pRAPFile],GENERIC_READ,NULL,NULL,OPEN_EXISTING,NULL,NULL
	mov [hFile],eax
	cmp eax,INVALID_HANDLE_VALUE
	je >>.EXIT

	invoke GetFileTime,eax,NULL,NULL,offset lwt
	invoke CloseHandle,[hFile]

	invoke FileTimeToLocalFileTime,offset lwt,offset lwtLocal
	invoke FileTimeToSystemTime,OFFSET lwtLocal,OFFSET stLocal

	invoke GetDateFormat,LOCALE_SYSTEM_DEFAULT,NULL,\
		OFFSET stLocal,"d MMM yyyy",OFFSET szTempDate,64
	invoke GetTimeFormat,LOCALE_SYSTEM_DEFAULT,NULL,\
		OFFSET stLocal,"hh:mm tt",OFFSET szTempTime,64

	invoke GetPrivateProfileString,"Project","Assembler","",\
			offset szAssembler,1024,[pRAPFile]
	invoke GetPrivateProfileString,"Project","Type","",\
			offset szType,1024,[pRAPFile]
	invoke GetPrivateProfileString,"Project","Description","",\
			offset szDescription,1024,[pRAPFile]

	invoke wsprintf,offset outstring,offset outfmt,offset szAssembler,\
		offset szType,offset szDescription,OFFSET szTempDate,OFFSET szTempTime
	add esp,28

	invoke SendMessage,[hOutput],WM_SETTEXT,0,offset outstring

	RET

	.EXIT

	invoke SendMessage,[hOutput],WM_SETTEXT,0,"File not found"

	RET

	outfmt: DB "Assembler : %s",13,10,"Type : %s",13,10,"Description : %s",13,10,13,10,"Last write :",13,10,"Date : %s",13,10,"Time : %s",0

ENDF

RebuildFavsFile FRAME hListBox
	uses ebx,esi,edi
	LOCAL szLabel[64]		:B
	LOCAL Index[16]			:B
	LOCAL OutString[324]	:B
	LOCAL cbWrite			:D
	LOCAL IniPath[MAX_PATH]	:B

	mov eax,[lpData]
	mov eax,[eax+ADDINDATA.lpLoadPath]
	invoke lstrcpy,offset IniPath,eax
	invoke lstrcat,offset IniPath,"\RadFavs.ini"

	mov D[Index],0
	invoke WritePrivateProfileSection,"Favourites",NULL,offset IniPath

	invoke SendMessage,[hListBox],LB_GETCOUNT,0,0
	mov ebx,eax
	or eax,eax
	jz >>.REMOVEALL
	xor esi,esi
	L1:
		invoke SendMessage,[hListBox],LB_GETTEXT,esi,offset szLabel
		invoke SendMessage,[hListBox],LB_GETITEMDATA,esi,0
		invoke wsprintf,offset OutString,"%s,%s",offset szLabel,eax
		add esp,16
		inc esi
		invoke wsprintf,offset Index,"%u",esi
		add esp,12
		invoke WritePrivateProfileString,"Favourites",offset Index,\
			offset OutString,offset IniPath
		cmp esi,ebx
		jl <L1

	.REMOVEALL

	invoke FreeMenuBuffers,[hFavMenu]

	; Delete the favourites in the menu, they start at index 3
	invoke GetMenuItemCount,[hFavMenu]
	mov esi,eax
	mov ebx,3
	L2:
		invoke RemoveMenu,[hFavMenu],3,MF_BYPOSITION
		inc ebx
		cmp ebx,esi
		jl <L2

	mov D[TopIDIndex],0
	invoke GetGlobalFavs,[hFavMenu]

	.EXIT
	RET
ENDF

SetMenuInfo	FRAME hMenu,lpcmi

	mov eax,[pSetMenuInfo]
	or eax,eax
	jz >.EXIT
		push [lpcmi]
		push [hMenu]
		call eax
	.EXIT

	ret
ENDF

GetMenuInfo	FRAME hMenu,lpcmi

	mov eax,[pGetMenuInfo]
	or eax,eax
	jz >.EXIT
		push [lpcmi]
		push [hMenu]
		call eax
	.EXIT

	ret
ENDF
