;Exception handler by Edgar Hansen (Donkey)

MODULEINFO struct
	lpBaseOfDll	DD ?
	SizeOfImage	DD ?
	EntryPoint	DD ?
MODULEINFO ENDS

_Hyperlink			PROTO	:DWORD,:DWORD,:DWORD,:DWORD
ErrorDlgProc		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
FormatURL			PROTO	:DWORD,:DWORD,:DWORD
StackDump			PROTO	:DWORD,:DWORD
FindModuleByAddr9x	PROTO	:DWORD,:DWORD
FindModuleByAddrNT	PROTO	:DWORD,:DWORD
CheckOSVersion		PROTO
BuildFlagString		PROTO	:DWORD,:DWORD
FinalHandler		PROTO	:DWORD
GetExcptText		PROTO	:DWORD
InitHyperLinkClass	PROTO

HLM_SETTYPE			equ	WM_USER+200 ; lParam = HLINK_URL/HLINK_EMAIL wndxtra 0
HLM_SETHOTCOLOR		equ	WM_USER+201 ; lParam = Hot color wndxtra 4
HLM_SETTEXTCOLOR	equ	WM_USER+202 ; lParam = Normal text color wndxtra 8
HLM_SETSUBJECT		equ	WM_USER+203 ; lParam = Email subject line wndxtra 24
HLM_SETBODY			equ	WM_USER+204 ; lParam = Email body wndxtra 28
HLM_SETUNDERLINE	equ	WM_USER+205 ; lParam = Underline link TRUE/FALSE wndxtra 32
HLM_SETLINK			equ	WM_USER+206	; lParam = Hyperlink URL wndxtra 36
HLINK_URL			equ	0
HLINK_EMAIL			equ	1

.data

LinkFont			LOGFONT	<-11,0,0,0,FW_NORMAL,FALSE,FALSE,0,0,0,0,0,0,"Courier new">

expt0C0000005h		db	"EXCEPTION_ACCESS_VIOLATION",0
expt0C000008Ch		db	"EXCEPTION_ARRAY_BOUNDS_EXCEEDED",0
expt080000003h		db	"EXCEPTION_BREAKPOINT",0
expt080000002h		db	"EXCEPTION_DATATYPE_MISALIGNMENT",0
expt0C000008Dh		db	"EXCEPTION_FLT_DENORMAL_OPERAND",0
expt0C000008Eh		db	"EXCEPTION_FLT_DIVIDE_BY_ZERO",0
expt0C000008Fh		db	"EXCEPTION_FLT_INEXACT_RESULT",0
expt0C0000090h		db	"EXCEPTION_FLT_INVALID_OPERATION",0
expt0C0000091h		db	"EXCEPTION_FLT_OVERFLOW",0
expt0C0000092h		db	"EXCEPTION_FLT_STACK_CHECK",0
expt0C0000093h		db	"EXCEPTION_FLT_UNDERFLOW",0
expt0C000001Dh		db	"EXCEPTION_ILLEGAL_INSTRUCTION",0
expt0C0000006h		db	"EXCEPTION_IN_PAGE_ERROR",0
expt0C0000094h		db	"EXCEPTION_INT_DIVIDE_BY_ZERO",0
expt0C0000095h		db	"EXCEPTION_INT_OVERFLOW",0
expt080000004h		db	"EXCEPTION_SINGLE_STEP",0
exptOTHER			db	"UNKNOWN_EXCEPTION",0

szOSVersion0		db	"Windows version %u.%u %s",13,10,0
szOSVersion1		db	"Windows 95 %s",13,10,0
szOSVersion2		db	"Windows 98 %s",13,10,0
szOSVersion3		db	"Windows ME %s",13,10,0
szOSVersion5		db	"Windows NT 4 %s",13,10,0
szOSVersion6		db	"Windows 2000 %s",13,10,0
szOSVersion7		db	"Windows XP %s",13,10,0
szOSVersion8		db	"Windows 2003 %s",13,10,0

szTrapModuleFmt		db	"Module name: %s (%s)",13,10,0

szTrapExcCodeFmt	db	"Exception code: %Xh",13,10,"%s",13,10,\
						"Instruction pointer: %0.8Xh",13,10,13,10,0

szTrapRegsFmt		db	"Registers:",13,10,\
						"eax=%0.8Xh ebx=%0.8Xh ecx=%0.8Xh",13,10,\
						"edx=%0.8Xh esi=%0.8Xh edi=%0.8Xh",13,10,\
						"ebp=%0.8Xh esp=%0.8Xh eip=%0.8Xh",13,10,\
						13,10,0

szTrapSegFmt		db	"Segment registers:",13,10,\
						"CS=%0.4Xh DS=%0.4Xh SS=%0.4Xh",13,10,\
						"ES=%0.4Xh FS=%0.4Xh GS=%0.4Xh",13,10,\
						13,10,0

flgdata				db	"Flags: ",0
errlnktext			db	"Report this error",0
errlnkaddr			db	"radasmide@hotmail.com",0
errlnksubj			db	"Exception report",0
hlc_szMailTo 		db	"mailto:",0
hlc_szSubject		db	"?subject=",0
hlc_szBody			db	"&body=",0
hlc_szOpen			db	"open",0
UDC_HyperClass		db	"UDC_HyperLink",0

szTrapStackFmt		db	13,10,"Stack:",13,10,\
						"%0.8X %0.8X %0.8X %0.8X",13,10,\
						"%0.8X %0.8X %0.8X %0.8X",13,10,\
						"%0.8X %0.8X %0.8X %0.8X",13,10,\
						"%0.8X %0.8X %0.8X %0.8X",0

kjdlaks				db	"%%%0.2X",0
szdefmodulename		db	"undetermined",0

.code

FinalHandler proc uses esi edi pExceptInfo
	LOCAL buffer[384]		:BYTE
	LOCAL szBody[384]		:BYTE
	LOCAL osvi				:OSVERSIONINFO

	; Clear the direction flag just in case
	cld
	
	; Clean up any things here, like freeing memory and handles

	mov BYTE PTR [buffer],0
	mov BYTE PTR [szBody],0

	mov eax,[pExceptInfo]
	mov edi,[eax+EXCEPTION_POINTERS.pExceptionRecord]
	mov esi,[eax+EXCEPTION_POINTERS.ContextRecord]
	
	mov [osvi.dwOSVersionInfoSize],SIZEOF OSVERSIONINFO
	invoke GetVersionEx,ADDR osvi
	mov eax,VER_PLATFORM_WIN32_WINDOWS
	and eax,[osvi.dwPlatformId]
	jz NT
	invoke FindModuleByAddr9x,[edi+EXCEPTION_RECORD.ExceptionAddress],addr buffer
	jmp @F
	NT:
	invoke FindModuleByAddrNT,[edi+EXCEPTION_RECORD.ExceptionAddress],addr buffer
	@@:

	mov edx,lpDStruct
	invoke wsprintf,addr szBody,OFFSET szTrapModuleFmt,addr buffer,[edx].ADDINDATA.lpszAppName

	cmp [osvi.dwMajorVersion],4
	jne XP2K
		cmp [osvi.dwMinorVersion],0
		jne @F
			cmp [osvi.dwPlatformId],VER_PLATFORM_WIN32_WINDOWS
			jne NT4
				invoke wsprintf,addr buffer,offset szOSVersion1,\
					addr osvi.szCSDVersion
				jmp OSVERSION
			NT4:
				invoke wsprintf,addr buffer,offset szOSVersion5,\
					addr osvi.szCSDVersion
				jmp OSVERSION
		@@:
		cmp [osvi.dwMinorVersion],10
		jne @F
			invoke wsprintf,addr buffer,offset szOSVersion2,\
				addr osvi.szCSDVersion
			jmp OSVERSION
		@@:
		cmp [osvi.dwMinorVersion],90
		jne @F
			invoke wsprintf,addr buffer,offset szOSVersion3,\
				addr osvi.szCSDVersion
			jmp OSVERSION
		@@:
	XP2K:
	cmp [osvi.dwMajorVersion],5
	jne OTHER
		cmp [osvi.dwMinorVersion],0
		jne @F
			invoke wsprintf,addr buffer,offset szOSVersion6,\
				addr osvi.szCSDVersion
			jmp OSVERSION
		@@:
		cmp [osvi.dwMinorVersion],1
		jne @F
			invoke wsprintf,addr buffer,offset szOSVersion7,\
				addr osvi.szCSDVersion
			jmp OSVERSION
		@@:
		cmp [osvi.dwMinorVersion],2
		jne @F
			invoke wsprintf,addr buffer,offset szOSVersion8,\
				addr osvi.szCSDVersion
			jmp OSVERSION
		@@:
	jmp OSVERSION
	OTHER:
	; Other
		invoke wsprintf,addr buffer,offset szOSVersion0,\
			[osvi.dwMajorVersion],[osvi.dwMinorVersion],addr osvi.szCSDVersion
	OSVERSION:
	invoke lstrcat,addr szBody,addr buffer

	invoke GetExcptText,[edi+EXCEPTION_RECORD.ExceptionCode]
	mov edx,[edi+EXCEPTION_RECORD.ExceptionAddress]

	invoke wsprintf,addr buffer,OFFSET szTrapExcCodeFmt,[edi+EXCEPTION_RECORD.ExceptionCode],eax,edx
	invoke lstrcat,addr szBody,addr buffer
	invoke wsprintf, addr buffer, OFFSET szTrapRegsFmt, [esi+CONTEXT.regEax],\
		[esi+CONTEXT.regEbx], [esi+CONTEXT.regEcx], [esi+CONTEXT.regEdx],\
		[esi+CONTEXT.regEsi], [esi+CONTEXT.regEdi], [esi+CONTEXT.regEbp],\
		[esi+CONTEXT.regEsp], [esi+CONTEXT.regEip]
	invoke lstrcat,addr szBody,addr buffer
	invoke wsprintf, addr buffer, OFFSET szTrapSegFmt, [esi+CONTEXT.regCs], \
		[esi+CONTEXT.regDs], [esi+CONTEXT.regSs], [esi+CONTEXT.regEs], \
		[esi+CONTEXT.regFs], [esi+CONTEXT.regGs]
	invoke lstrcat,addr szBody,addr buffer

	invoke BuildFlagString,addr buffer,[esi+CONTEXT.regFlag]
	invoke lstrcat,addr szBody,addr buffer
	invoke StackDump,addr szBody,[esi+CONTEXT.regEsp]

	invoke DialogBoxParam,hInstance,1000,0,ADDR ErrorDlgProc,addr szBody
	mov eax,EXCEPTION_EXECUTE_HANDLER
	ret

FinalHandler endp

StackDump proc uses edi esi pOutString,pStack

	invoke lstrlen,[pOutString]
	mov edi,eax
	add edi,[pOutString]
	mov esi,[pStack]
	mov ecx,15
	@@:
		mov eax,ecx
		shl eax,2
		push [esi+eax]
		dec ecx
		jns @B

	push offset szTrapStackFmt
	push edi
	call wsprintf
	add esp,72

	RET
	
StackDump endp

BuildFlagString PROC uses edi pString,eflagdata

	invoke lstrcpy,[pString],offset flgdata
	mov edi,[pString]
	add edi,6

	mov BYTE PTR [edi],0
	mov eax,[eflagdata]
	bt eax,0
	jnc @F
	mov DWORD PTR [edi],"FC "
	add edi,3
	@@:
	bt eax,2
	jnc @F
	mov DWORD PTR [edi],"FP "
	add edi,3
	@@:
	bt eax,4
	jnc @F
	mov DWORD PTR [edi],"FA "
	add edi,3
	@@:
	bt eax,6
	jnc @F
	mov DWORD PTR [edi],"FZ "
	add edi,3
	@@:
	bt eax,7
	jnc @F
	mov DWORD PTR [edi],"FS "
	add edi,3
	@@:
	bt eax,8
	jnc @F
	mov DWORD PTR [edi],"FT "
	add edi,3
	@@:
	bt eax,9
	jnc @F
	mov DWORD PTR [edi],"FI "
	add edi,3
	@@:
	bt eax,10
	jnc @F
	mov DWORD PTR [edi],"FD "
	add edi,3
	@@:
	bt eax,11
	jnc @F
	mov DWORD PTR [edi],"FO "
	add edi,3
	@@:
	mov BYTE PTR [edi],13
	mov BYTE PTR [edi+1],10
	mov BYTE PTR [edi+2],0

	RET
BuildFlagString endp

GetExcptText PROC ExCode
	mov eax, [ExCode]
	@@:
	cmp eax,0C0000005h ; EXCEPTION_ACCESS_VIOLATION
	jne @F
		mov eax,OFFSET expt0C0000005h
		jmp exitproc
	@@:
	cmp eax,0C000008Ch ;EXCEPTION_ARRAY_BOUNDS_EXCEEDED
	jne @F
		mov eax,OFFSET expt0C000008Ch
		jmp exitproc
	@@:
	cmp eax,080000003h ;EXCEPTION_BREAKPOINT
	jne @F
		mov eax,OFFSET expt080000003h
		jmp exitproc
	@@:
	cmp eax,080000002h ;EXCEPTION_DATATYPE_MISALIGNMENT
	jne @F
		mov eax,OFFSET expt080000002h
		jmp exitproc
	@@:
	cmp eax,0C000008Dh ;EXCEPTION_FLT_DENORMAL_OPERAND
	jne @F
		mov eax,OFFSET expt0C000008Dh
		jmp exitproc
	@@:
	cmp eax,0C000008Eh ;EXCEPTION_FLT_DIVIDE_BY_ZERO
	jne @F
		mov eax,OFFSET expt0C000008Eh
		jmp exitproc
	@@:
	cmp eax,0C000008Fh ;EXCEPTION_FLT_INEXACT_RESULT
	jne @F
		mov eax,OFFSET expt0C000008Fh
		jmp exitproc
	@@:
	cmp eax,0C0000090h ;EXCEPTION_FLT_INVALID_OPERATION
	jne @F
		mov eax,OFFSET expt0C0000090h
		jmp exitproc
	@@:
	cmp eax,0C0000091h ;EXCEPTION_FLT_OVERFLOW
	jne @F
		mov eax,OFFSET expt0C0000091h
		jmp exitproc
	@@:
	cmp eax,0C0000092h ;EXCEPTION_FLT_STACK_CHECK
	jne @F
		mov eax,OFFSET expt0C0000092h
		jmp exitproc
	@@:
	cmp eax,0C0000093h ;EXCEPTION_FLT_UNDERFLOW
	jne @F
		mov eax,OFFSET expt0C0000093h
		jmp exitproc
	@@:
	cmp eax,0C000001Dh ;EXCEPTION_ILLEGAL_INSTRUCTION
	jne @F
		mov eax,OFFSET expt0C000001Dh
		jmp exitproc
	@@:
	cmp eax,0C0000006h ;EXCEPTION_IN_PAGE_ERROR
	jne @F
		mov eax,OFFSET expt0C0000006h
		jmp exitproc
	@@:
	cmp eax,0C0000094h ;EXCEPTION_INT_DIVIDE_BY_ZERO
	jne @F
		mov eax,OFFSET expt0C0000094h
		jmp exitproc
	@@:
	cmp eax,0C0000095h ;EXCEPTION_INT_OVERFLOW
	jne @F
		mov eax,OFFSET expt0C0000095h
		jmp exitproc
	@@:
	cmp eax,080000004h ;EXCEPTION_SINGLE_STEP
	jne @F
		mov eax,OFFSET expt080000004h
		jmp exitproc
	@@:
		mov eax,OFFSET exptOTHER
	exitproc:
	ret
GetExcptText endp

ErrorDlgProc PROC uses edi esi ebx hwnd,uMsg,wParam,lParam

	.IF [uMsg] == WM_INITDIALOG
		invoke LoadIcon,NULL,IDI_ERROR
		invoke SendDlgItemMessage,[hwnd],1006,STM_SETICON,eax,0
		invoke SendDlgItemMessage,[hwnd],1004,WM_SETFONT,NULL,TRUE
		invoke SendDlgItemMessage,[hwnd],1005,WM_SETFONT,NULL,TRUE
		invoke CreateFontIndirect,OFFSET LinkFont
		invoke SendDlgItemMessage,[hwnd],1003,WM_SETFONT,eax,TRUE
		invoke SendDlgItemMessage,[hwnd],1003,WM_SETTEXT,0,[lParam]

		; Set up hyperlink
		invoke SendDlgItemMessage,[hwnd],1001,WM_SETTEXT,0,OFFSET errlnktext
		invoke SendDlgItemMessage,[hwnd],1001,HLM_SETLINK,0,OFFSET errlnkaddr
		invoke SendDlgItemMessage,[hwnd],1001,HLM_SETHOTCOLOR,0,0FF0000h
		invoke SendDlgItemMessage,[hwnd],1001,HLM_SETTEXTCOLOR,0,0
		invoke SendDlgItemMessage,[hwnd],1001,HLM_SETTYPE,0,HLINK_EMAIL
		invoke SendDlgItemMessage,[hwnd],1001,HLM_SETSUBJECT,0,OFFSET errlnksubj
		invoke SendDlgItemMessage,[hwnd],1001,HLM_SETBODY,0,[lParam]
		invoke SendDlgItemMessage,[hwnd],1001,HLM_SETUNDERLINE,0,TRUE

	.ELSEIF [uMsg] == WM_COMMAND
		movzx eax,WORD PTR [wParam]
		.IF eax == 1002
			invoke PostMessage,[hwnd],WM_CLOSE,0,0
		.ELSEIF eax == 1007
			invoke SendMessage,hWnd,WM_COMMAND,40009,0
		.ENDIF

	.ELSEIF [uMsg] == WM_CLOSE
		invoke SendDlgItemMessage,[hwnd],1003,EM_SETSEL,0,-1
		invoke SendDlgItemMessage,[hwnd],1003,WM_COPY,0,0
		invoke SendDlgItemMessage,[hwnd],1003,WM_GETFONT,0,0
		invoke DeleteObject,eax
		invoke EndDialog,[hwnd],0

	.ELSE
		mov eax,FALSE
		ret

	.ENDIF

	mov eax, TRUE
	ret

ErrorDlgProc ENDP

FindModuleByAddr9x proc uses edi esi ebx Address,pModuleName
	LOCAL pID						:DWORD
	LOCAL hSnap						:DWORD
	LOCAL me32						:MODULEENTRY32
	LOCAL hlib						:DWORD
	LOCAL pCreateToolhelp32Snapshot	:DWORD
	LOCAL pModule32First			:DWORD
	LOCAL pModule32Next				:DWORD

	.data
		szthelp		db	"kernel32.dll",0
		szsnapshot	db	"CreateToolhelp32Snapshot",0
		szmodfirst	db	"Module32First",0
		szmodnext	db	"Module32Next",0
	.code

	mov me32.dwSize,SIZEOF MODULEENTRY32

	invoke LoadLibrary,offset szthelp
	or eax,eax
	jnz @F
	ret
	@@:
	mov [hlib],eax
	invoke GetProcAddress,[hlib],offset szsnapshot
	mov [pCreateToolhelp32Snapshot],eax
	invoke GetProcAddress,[hlib],offset szmodfirst
	mov [pModule32First],eax
	invoke GetProcAddress,[hlib],offset szmodnext
	mov [pModule32Next],eax

	invoke lstrcpy,[pModuleName],offset szdefmodulename
	invoke GetCurrentProcessId
	mov [pID],eax

	push [pID]
	push TH32CS_SNAPMODULE
	call [pCreateToolhelp32Snapshot]
	mov [hSnap],eax

	lea eax,me32
	push eax
	push [hSnap]
	call [pModule32First]
	jmp L2
	L1:
		mov eax,[me32.modBaseAddr]
		mov ecx,[me32.modBaseSize]
		add ecx,eax
		cmp [Address],eax
		jb @F
		cmp [Address],ecx
		ja @F
		invoke lstrcpy,[pModuleName],addr me32.szModule
		jmp DONE
		@@:
		lea eax,me32
		push eax
		push [hSnap]
		call [pModule32Next]
		L2:
		or eax,eax
		jnz L1
	DONE:
	invoke CloseHandle,[hSnap]
	invoke FreeLibrary,[hlib]

	RET
FindModuleByAddr9x endp

FindModuleByAddrNT proc uses edi esi ebx Address,pModuleName

	LOCAL pID					:DWORD
	LOCAL hProcess				:DWORD
	LOCAL hMods[1024]			:DWORD
	LOCAL cbNeeded				:DWORD
	LOCAL modinfo				:MODULEINFO
	LOCAL hModule				:DWORD
	
	LOCAL hlib					:DWORD
	LOCAL pEnumProcessModules	:DWORD
	LOCAL pGetModuleInformation	:DWORD
	LOCAL ModName[MAX_PATH]		:BYTE

	.data
		szpsapi		db	"psapi.dll",0
		szenummods	db	"EnumProcessModules",0
		szgetmodinf	db	"GetModuleInformation",0
		szgetmodbas	db	"GetModuleBaseNameA",0
	.code
	
	invoke LoadLibrary,offset szpsapi
	or eax,eax
	jnz @F
	ret
	@@:
	mov [hlib],eax
	invoke GetProcAddress,[hlib],offset szenummods
	mov [pEnumProcessModules],eax
	invoke GetProcAddress,[hlib],offset szgetmodinf
	mov [pGetModuleInformation],eax
	
	invoke lstrcpy,[pModuleName],offset szdefmodulename
	mov ebx,[Address]
	invoke GetCurrentProcessId
	mov [pID],eax
	invoke OpenProcess,PROCESS_QUERY_INFORMATION+PROCESS_VM_READ,FALSE,[pID]
	mov [hProcess],eax

	lea eax,cbNeeded
	push eax
	push 1024
	lea eax,hMods
	push eax
	push [hProcess]
	call [pEnumProcessModules]
	or eax,eax
	jz DONE
		mov edi,[cbNeeded]
		shr edi,2
		lea esi,hMods
		L1:
		mov eax,[esi]
		mov [hModule],eax
		add esi,4

		push SIZEOF MODULEINFO
		lea eax,modinfo
		push eax
		push [hModule]
		push [hProcess]
		call [pGetModuleInformation]
		or eax,eax
		jz DONE
		cmp ebx,[modinfo.lpBaseOfDll]
		jg L2
			dec edi
			or edi,edi
			js DONE
			jmp L1
		L2:
			mov eax,[modinfo.SizeOfImage]
			add eax,[modinfo.lpBaseOfDll]
			cmp ebx,eax
			jl L3
			dec edi
			or edi,edi
			js DONE
			jmp L1
		L3:
		invoke GetModuleFileName,[hModule],addr ModName,MAX_PATH
		invoke GetFileTitle,addr ModName,[pModuleName],256

	DONE:
	invoke CloseHandle,[hProcess]
	invoke FreeLibrary,[hlib]
	RET
FindModuleByAddrNT endp

; Hyperlink code is reusable

_Hyperlink PROC uses ebx hlc_hWin,hlc_uMsg,hlc_wParam,hlc_lParam
	LOCAL hlc_tme				:TRACKMOUSEEVENT
	LOCAL hlc_ps				:PAINTSTRUCT
	LOCAL hlc_hdc				:DWORD
	LOCAL hlc_strlen			:DWORD
	LOCAL hlc_prc				:RECT
	LOCAL hlc_color				:DWORD
	LOCAL hlc_pt				:POINT
	LOCAL hlc_text[2048]		:BYTE
	LOCAL hlc_pSubject			:DWORD

	cmp DWORD PTR [hlc_uMsg],WM_SETTEXT
	jne WMCREATE
		; Get the border size
		invoke GetWindowRect,[hlc_hWin],ADDR hlc_prc
		mov eax,[hlc_prc.right]
		sub eax,[hlc_prc.left]
		push eax
		mov eax,[hlc_prc.bottom]
		sub eax,[hlc_prc.top]
		push eax
		invoke GetClientRect,[hlc_hWin],ADDR hlc_prc
		pop eax
		sub eax,[hlc_prc.bottom]
		pop ecx
		push eax
		sub ecx,[hlc_prc.right]
		push ecx

		invoke GetDC,[hlc_hWin]
		mov [hlc_hdc],eax

		invoke GetWindowLong,[hlc_hWin],20
		or eax,eax
		jnz @F
			invoke GetStockObject,SYSTEM_FONT
		@@:
		invoke SelectObject,[hlc_hdc],eax
		invoke lstrlen,[hlc_lParam]
		mov ecx,eax
		invoke DrawText,[hlc_hdc],[hlc_lParam],ecx,ADDR hlc_prc,DT_CALCRECT
		pop ecx
		add ecx,[hlc_prc.right]
		sub ecx,[hlc_prc.left]

		pop eax
		add eax,[hlc_prc.bottom]
		sub eax,[hlc_prc.top]
		invoke SetWindowPos,[hlc_hWin],HWND_TOP,0,0,ecx,eax,SWP_NOMOVE or SWP_NOZORDER
		invoke ReleaseDC,[hlc_hWin],[hlc_hdc]
		jmp DONE

	WMCREATE:
	cmp DWORD PTR [hlc_uMsg],WM_CREATE
	jne HLMSETTYPE
		invoke GlobalAlloc,GPTR,4192
		invoke SetWindowLong,[hlc_hWin],12,eax
		jmp DONE

	HLMSETTYPE:
	cmp DWORD PTR [hlc_uMsg],HLM_SETTYPE
	jne HLMSETUNDERLINE
		invoke SetWindowLong,[hlc_hWin],0,[hlc_lParam]
		ret

	HLMSETUNDERLINE:
	cmp DWORD PTR [hlc_uMsg],HLM_SETUNDERLINE
	jne HLMSETHOTCOLOR
		invoke SetWindowLong,[hlc_hWin],32,[hlc_lParam]
		ret

	HLMSETHOTCOLOR:
	cmp DWORD PTR [hlc_uMsg],HLM_SETHOTCOLOR
	jne HLMSETTEXTCOLOR
		invoke SetWindowLong,[hlc_hWin],4,[hlc_lParam]
		; set the current color if necessary
		invoke GetCursorPos,ADDR hlc_pt
		invoke GetParent,[hlc_hWin]
		push eax
		mov ecx,eax
		invoke ScreenToClient,ecx,ADDR hlc_pt
		pop ecx
		invoke ChildWindowFromPoint,ecx,[hlc_pt.x],[hlc_pt.y]
		cmp eax,[hlc_hWin]
		jne @F
			invoke SetWindowLong,[hlc_hWin],16,[hlc_lParam]
			mov DWORD PTR [hlc_tme.cbSize],SIZEOF TRACKMOUSEEVENT
			mov DWORD PTR [hlc_tme.dwFlags],TME_LEAVE
			mov eax,[hlc_hWin]
			mov [hlc_tme.hwndTrack],eax
			mov DWORD PTR [hlc_tme.dwHoverTime],HOVER_DEFAULT
			invoke _TrackMouseEvent,ADDR hlc_tme
		@@:
		invoke InvalidateRect,[hlc_hWin],NULL,TRUE
		invoke UpdateWindow,[hlc_hWin]
		ret

	HLMSETTEXTCOLOR:
	cmp DWORD PTR [hlc_uMsg],HLM_SETTEXTCOLOR
	jne HLMSETSUBJECT
		invoke SetWindowLong,[hlc_hWin],8,[hlc_lParam]
		; set the current color if necessary
		invoke GetCursorPos,ADDR hlc_pt
		invoke GetParent,[hlc_hWin]
		push eax
		mov ecx,eax
		invoke ScreenToClient,ecx,ADDR hlc_pt
		pop ecx
		invoke ChildWindowFromPoint,ecx,[hlc_pt.x],[hlc_pt.y]
		cmp eax,[hlc_hWin]
		je @F
			invoke SetWindowLong,[hlc_hWin],16,[hlc_lParam]
		@@:
		invoke InvalidateRect,[hlc_hWin],NULL,TRUE
		invoke UpdateWindow,[hlc_hWin]
		ret

	HLMSETSUBJECT:
	cmp DWORD PTR [hlc_uMsg],HLM_SETSUBJECT
	jne HLMSETLINK
		invoke lstrlen,[hlc_lParam]
		inc eax
		mov [hlc_strlen],eax
		invoke GetWindowLong,[hlc_hWin],24
		mov [hlc_pSubject],eax
		or eax,eax
		jz @F
			invoke GlobalFree,eax
		@@:
		invoke GlobalAlloc,GPTR,[hlc_strlen]
		mov [hlc_pSubject],eax
		cmp DWORD PTR [hlc_strlen],1024
		jl @F
			mov eax,[hlc_lParam]
			add eax,1023
			mov BYTE PTR [eax],0
		@@:
		invoke lstrcpy,[hlc_pSubject],[hlc_lParam]
		invoke SetWindowLong,[hlc_hWin],24,[hlc_pSubject]
		ret

	HLMSETLINK:
	cmp DWORD PTR [hlc_uMsg],HLM_SETLINK
	jne HLMSETBODY
		invoke lstrlen,[hlc_lParam]
		inc eax
		mov [hlc_strlen],eax
		invoke GetWindowLong,[hlc_hWin],36
		mov [hlc_pSubject],eax
		or eax,eax
		jz @F
			invoke GlobalFree,eax
		@@:
		invoke GlobalAlloc,GPTR,[hlc_strlen]
		mov [hlc_pSubject],eax
		cmp DWORD PTR [hlc_strlen],1024
		jl @F
			mov eax,[hlc_lParam]
			add eax,1023
			mov BYTE PTR [eax],0
		@@:
		invoke lstrcpy,[hlc_pSubject],[hlc_lParam]
		invoke SetWindowLong,[hlc_hWin],36,[hlc_pSubject]
		ret

	HLMSETBODY:
	cmp DWORD PTR [hlc_uMsg],HLM_SETBODY
	jne WMSETFONT
		invoke lstrlen,[hlc_lParam]
		inc eax
		mov [hlc_strlen],eax
		invoke GetWindowLong,[hlc_hWin],28
		mov [hlc_pSubject],eax
		or eax,eax
		jz @F
			invoke GlobalFree,eax
		@@:
		invoke GlobalAlloc,GPTR,[hlc_strlen]
		mov [hlc_pSubject],eax
		cmp DWORD PTR [hlc_strlen],1024
		jl @F
			mov eax,[hlc_lParam]
			add eax,1023
			mov BYTE PTR [eax],0
		@@:
		invoke lstrcpy,[hlc_pSubject],[hlc_lParam]
		invoke SetWindowLong,[hlc_hWin],28,[hlc_pSubject]
		ret

	WMSETFONT:
	cmp DWORD PTR [hlc_uMsg],WM_SETFONT
	jne WMLBUTTONDOWN
		; The def window proc does not do fonts so it has to be done manually
		invoke SetWindowLong,[hlc_hWin],20,[hlc_wParam]
		invoke GetWindowText,[hlc_hWin],ADDR hlc_text,256
		invoke SetWindowText,[hlc_hWin],ADDR hlc_text
		mov eax,[hlc_lParam]
		or eax,eax
		jz @F
			invoke InvalidateRect,[hlc_hWin],NULL,TRUE
			invoke UpdateWindow,[hlc_hWin]
		@@:
		ret

	WMLBUTTONDOWN:
	cmp DWORD PTR [hlc_uMsg],WM_LBUTTONDOWN
	jne WMMOUSEMOVE
		invoke GetWindowLong,[hlc_hWin],12
		mov [hlc_pSubject],eax

		invoke GetWindowLong,[hlc_hWin],0
		cmp eax,HLINK_URL
		jne B1
			invoke GetWindowLong,[hlc_hWin],36
			mov [hlc_pSubject],eax
			invoke lstrlen,eax
			jnz @F
				invoke GetWindowText,[hlc_hWin],[hlc_pSubject],256
			@@:
		B1:
		cmp eax,HLINK_EMAIL
		jne B2
			invoke GetWindowLong,[hlc_hWin],36
			mov ebx,eax
			invoke lstrlen,ebx
			jnz @F
				xor ebx,ebx
			@@:
			invoke lstrcpy,[hlc_pSubject],addr hlc_szMailTo
			mov eax,[hlc_pSubject]
			add eax,7
			or ebx,ebx
			jz @F
				invoke lstrcpy,eax,ebx
				jmp B0
			@@:
				invoke GetWindowText,[hlc_hWin],eax,240
			B0:
			invoke GetWindowLong,[hlc_hWin],24
			or eax,eax
			jz B2
				push eax
				invoke lstrcat,[hlc_pSubject],addr hlc_szSubject
				pop eax
				mov DWORD PTR [hlc_strlen],2048
				invoke lstrcat,[hlc_pSubject],eax
				invoke GetWindowLong,[hlc_hWin],28
				or eax,eax
				jz B2
				push eax
				invoke lstrcat,[hlc_pSubject],OFFSET hlc_szBody
				pop eax
				invoke lstrcat,[hlc_pSubject],eax
		B2:
		invoke FormatURL,[hlc_pSubject],addr hlc_text,TRUE
		invoke ShellExecute, [hlc_hWin], addr hlc_szOpen,addr hlc_text, 0, 0, SW_SHOWNORMAL
		jmp DONE

	WMMOUSEMOVE:
	cmp DWORD PTR [hlc_uMsg],WM_MOUSEMOVE
	jne WMMOUSELEAVE
		; The first mouse move message changes the color
		invoke GetWindowLong,[hlc_hWin],4
		push eax
		invoke SetWindowLong,[hlc_hWin],16,eax
		pop ecx
		cmp eax,ecx
		je DONE
			mov DWORD PTR [hlc_tme.cbSize],SIZEOF TRACKMOUSEEVENT
			mov DWORD PTR [hlc_tme.dwFlags],TME_LEAVE
			mov eax,[hlc_hWin]
			mov [hlc_tme.hwndTrack],eax
			mov DWORD PTR [hlc_tme.dwHoverTime],HOVER_DEFAULT
			invoke _TrackMouseEvent,ADDR hlc_tme
			invoke InvalidateRect,[hlc_hWin],NULL,TRUE
		jmp DONE

	WMMOUSELEAVE:
	cmp DWORD PTR [hlc_uMsg],WM_MOUSELEAVE
	jne WMPAINT
		invoke GetWindowLong,[hlc_hWin],8
		invoke SetWindowLong,[hlc_hWin],16,eax
		invoke InvalidateRect,[hlc_hWin],NULL,TRUE
		ret

	WMPAINT:
	cmp DWORD PTR [hlc_uMsg],WM_PAINT
	jne WMDESTROY
		invoke GetWindowText,[hlc_hWin],ADDR hlc_text,256
		mov [hlc_strlen],eax
		invoke GetWindowLong,[hlc_hWin],16
		mov [hlc_color],eax
		invoke BeginPaint,[hlc_hWin],ADDR hlc_ps
			mov [hlc_hdc],eax
			invoke GetWindowLong,[hlc_hWin],20
			invoke SelectObject,[hlc_hdc],eax
			invoke SetTextColor,[hlc_hdc],[hlc_color]
			invoke GetSysColor,COLOR_3DFACE
			invoke SetBkMode,[hlc_hdc],TRANSPARENT
			invoke TextOut,[hlc_hdc],0,0,ADDR hlc_text,[hlc_strlen]

			invoke GetWindowLong,[hlc_hWin],32 ; Underline
			or eax,eax
			jz @F
				; a line is drawn
				invoke CreatePen,PS_SOLID,1,[hlc_color]
				invoke SelectObject,[hlc_hdc],eax
				push eax
				invoke GetClientRect,[hlc_hWin],ADDR hlc_prc
				dec DWORD PTR [hlc_prc.bottom]
				invoke MoveToEx,[hlc_hdc],0,[hlc_prc.bottom],NULL
				invoke LineTo,[hlc_hdc],[hlc_prc.right],[hlc_prc.bottom]
				pop eax
				invoke SelectObject,[hlc_hdc],eax
				invoke DeleteObject,eax
			@@:

		invoke EndPaint,[hlc_hWin],ADDR hlc_ps
		ret

	WMDESTROY:
	cmp DWORD PTR [hlc_uMsg],WM_DESTROY
	jne DONE
		invoke GetWindowLong,[hlc_hWin],12
		or eax,eax
		jz @F
			invoke GlobalFree,eax
		@@:
		invoke GetWindowLong,[hlc_hWin],24
		or eax,eax
		jz @F
			invoke GlobalFree,eax
		@@:
		invoke GetWindowLong,[hlc_hWin],28
		or eax,eax
		jz @F
			invoke GlobalFree,eax
		@@:
		invoke GetWindowLong,[hlc_hWin],36
		or eax,eax
		jz @F
			invoke GlobalFree,eax
		@@:

	DONE:
	invoke DefWindowProc,[hlc_hWin],[hlc_uMsg],[hlc_wParam],[hlc_lParam]
	ret

_Hyperlink ENDP

InitHyperLinkClass PROC
	LOCAL hlc_wcx			:WNDCLASSEX

	mov DWORD PTR [hlc_wcx.cbSize],SIZEOF WNDCLASSEX
	mov DWORD PTR [hlc_wcx.style], CS_HREDRAW + CS_VREDRAW
	mov		eax,hInstance
	mov DWORD PTR [hlc_wcx.hInstance],eax
	mov DWORD PTR [hlc_wcx.lpszClassName],OFFSET UDC_HyperClass
	mov DWORD PTR [hlc_wcx.cbClsExtra],0
	mov DWORD PTR [hlc_wcx.cbWndExtra],40
	mov DWORD PTR [hlc_wcx.lpfnWndProc],OFFSET _Hyperlink
	mov DWORD PTR [hlc_wcx.hIcon],NULL
	mov DWORD PTR [hlc_wcx.hIconSm],NULL
	invoke GetStockObject,NULL_BRUSH
	mov DWORD PTR [hlc_wcx.hbrBackground],eax
	mov DWORD PTR [hlc_wcx.lpszMenuName],NULL

	invoke LoadCursor,NULL,IDC_HAND
	mov [hlc_wcx.hCursor],eax

	invoke RegisterClassEx,ADDR hlc_wcx

	ret


InitHyperLinkClass ENDP

FormatURL PROC uses ebx esi edi pString,pOutString,DoPercent
	
	mov edi,[pOutString]
	mov esi,[pString]
	mov ebx,[DoPercent]

	L0:
	mov al,[esi]
	cmp al,0
	je DONE

	; Chars
	cmp al,"a"
	jb @F
	cmp al,"z"
	jbe NORMAL
	@@:
	cmp al,"A"
	jb @F
	cmp al,"Z"
	jbe NORMAL
	@@:
	cmp al,"0"
	jb @F
	cmp al,"9"
	jbe NORMAL
	@@:

	; Allowed
	cmp al,"-"
	je NORMAL
	cmp al,"_"
	je NORMAL
	cmp al,"."
	je NORMAL
	cmp al,"!"
	je NORMAL
	cmp al,"-"
	je NORMAL
	cmp al,"*"
	je NORMAL
	cmp al,27h
	je NORMAL
	cmp al,"("
	je NORMAL
	cmp al,")"
	je NORMAL

	; Reserved
	cmp al,";"
	je NORMAL
	cmp al,"/"
	je NORMAL
	cmp al,"?"
	je NORMAL
	cmp al,":"
	je NORMAL
	cmp al,"@"
	je NORMAL
	cmp al,"&"
	je NORMAL
	cmp al,"="
	je NORMAL
	cmp al,"+"
	je NORMAL
	cmp al,"$"
	je NORMAL
	cmp al,","
	je NORMAL

	REPLACE:
	cmp al,"%"
	jne @F
	or ebx,ebx
	jz NORMAL
	@@:
	movzx edx,al
	invoke wsprintf,edi,OFFSET kjdlaks,edx
	add edi,3
	inc esi
	jmp L0

	NORMAL:
	movsb
	jmp L0
	
	DONE:
	mov BYTE PTR [edi],0
	ret
FormatURL ENDP

