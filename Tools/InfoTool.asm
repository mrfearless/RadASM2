
.data

szTool1Caption		db 'Tool#1',0
szTool2Caption		db 'Tool#2',0

.code

Do_InfoTool proc
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer2[64]:BYTE
    LOCAL   sTool:DOCKING
    LOCAL   hWin:HWND

    mov		sTool.ID,6
    mov     sTool.Caption,offset szInfoCaption
	invoke strcpy,addr buffer,addr InfoTool
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
;	invoke CreateWindowEx,0,addr szStatic,NULL,
;			WS_CHILD or WS_VISIBLE or SS_NOTIFY or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,
;			0,0,0,0,hWnd,0,hInstance,0
	invoke CreateWindowEx,0,addr szToolCldClass,NULL,
			WS_CHILD or	WS_VISIBLE or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,
			0,0,0,0,hWnd,0,hInstance,0
	mov		hWin,eax
;    invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr RAEditClass,0,
;    		WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_VISIBLE or \
;    		STYLE_NOSPLITT or STYLE_NOLINENUMBER or STYLE_NOCOLLAPSE or STYLE_NOHSCROLL or STYLE_NOVSCROLL or STYLE_NOSIZEGRIP or STYLE_READONLY or STYLE_NOSTATE,
;            0,0,0,0,hWin,0,hInstance,0
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr szEdit,0,
    		WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_VISIBLE or \
    		WS_VSCROLL or ES_READONLY or ES_MULTILINE,
            0,0,0,0,hWin,0,hInstance,0
	mov		hInfEdt,eax
	invoke SendMessage,hInfEdt,WM_SETFONT,hLBFont,FALSE
;	invoke SendMessage,hInfEdt,REM_SELBARWIDTH,0,0
    invoke ToolMessage,hWin,TLM_CREATE,addr sTool
    mov     eax,hWin
    ret

Do_InfoTool endp

InfoToolSize proc lParam:LPARAM
	LOCAL	wt:DWORD
	LOCAL	ht:DWORD

	mov		eax,lParam
	and		eax,0FFFFh
	mov		wt,eax
	mov		eax,lParam
	shr		eax,16
	mov		ht,eax
	invoke MoveWindow,hInfEdt,0,0,wt,ht,TRUE
	ret

InfoToolSize endp

Do_Tool1 proc
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer2[64]:BYTE
    LOCAL   sTool:DOCKING
    LOCAL   hWin:HWND

    mov		sTool.ID,7
    mov     sTool.Caption,offset szTool1Caption
	invoke strcpy,addr buffer,addr Tool1
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
    invoke ToolMessage,hWin,TLM_CREATE,addr sTool
    mov     eax,hWin
    ret

Do_Tool1 endp

Do_Tool2 proc
	LOCAL	buffer[64]:BYTE
	LOCAL	buffer2[64]:BYTE
    LOCAL   sTool:DOCKING
    LOCAL   hWin:HWND

    mov		sTool.ID,8
    mov     sTool.Caption,offset szTool2Caption
	invoke strcpy,addr buffer,addr Tool2
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
    invoke ToolMessage,hWin,TLM_CREATE,addr sTool
    mov     eax,hWin
    ret

Do_Tool2 endp

