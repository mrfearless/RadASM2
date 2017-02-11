.486
.model flat,stdcall
option casemap:none

;===================================
include CreateProject.inc

;======================================
CreateProjectFileName	PROTO
DlgProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM
DllEntry				PROTO	:HINSTANCE,:DWORD,:DWORD
DllProc					PROTO	:HWND,:UINT,:WPARAM,:LPARAM
FindRap					PROTO	:dword
InstallDll				PROTO	:DWORD,:DWORD
OpenProject				PROTO
Sort					PROTO

.code
;======================================
include Dlg.asm

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	
	mov eax, hInst
	mov hInstance, eax
	mov eax,TRUE
	ret
	
DllEntry Endp

InstallDll proc uses ebx hWin:DWORD,fOpt:DWORD
	
	mov ebx, hWin
	mov hWnd,ebx
	
	push fOpt
	pop fOption ;Store dll option
	
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov	lpHStruct,eax
	
	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov	lpPStruct,eax
	
	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov	lpDStruct,eax
	
	;If Option (fOpt) = 0 then exit
	mov eax, fOpt
	test eax,eax
	je lbl_ext
	
	;Clear lpFile buffer
	mov	edi,[lpDStruct]
	assume edi:ptr ADDINDATA
	invoke lstrlen,[edi].lpFile
	invoke RtlZeroMemory,[edi].lpFile,eax

	;Allocate a new menu id
	invoke SendMessage,ebx,AIM_GETMENUID,0,0
	mov IDCreateProject,eax

	;Get handle of menu
	mov	eax,[lpHStruct]
	mov	eax,(ADDINHANDLES ptr [eax]).hMenu
	mov hMenu,eax
	
	;Get handle of File popup
	invoke GetSubMenu,hMenu,0		;File menu
	mov	hMnu,eax

	;Add our menuitem
	invoke InsertMenu,hMnu,2,MF_STRING or MF_BYPOSITION,IDCreateProject,SADD('Create Project')

	; Add the "View Listing" option to the project context menu
	; Tell RadASM messages we want to hook
	mov eax, AddInHook(AIM_COMMAND,AIM_CLOSE,AIM_INITMENUPOPUP,AIM_PROJECTCLOSED,AIM_PROJECTOPENED)

	;ECX and EDX must be null before we return
lbl_ext:
	xor ecx, ecx
	xor edx, edx
	ret 
	
InstallDll Endp

DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL lpTemp:dword
	
	; This proc handles messages sent from RadASM to our dll
	mov		eax,uMsg
	;======================================
	.if eax==AIM_COMMAND
		mov eax, wParam
		; Return TRUE to prevent RadASM and other DLL's from
		; processing Command
		;======================================
		.if eax==20001 || eax==20002 || eax==20003 \
				||eax==20004 || eax==20005 || eax==20006 \
				|| eax==20007 || eax==20008
			.if fOption==1 ;if no project workspace is loaded; messagebox or not
				mov	eax,[lpDStruct]
				assume eax:ptr ADDINDATA
				.if [eax].fProject==FALSE ;Is a project loaded?
					;No
					mov eax,dword ptr [eax].lpFile ;Full path to activated file name
					mov lpTemp,eax
					mov eax,dword ptr [eax]
					.if eax!=0
						;A file is active
						invoke FindRap,lpTemp
						.if eax==TRUE
							;Yes, there is a project file in the folder but not loaded
							invoke lstrcat,addr lpMessage,addr message2
							invoke lstrcat,addr lpMessage,addr FindData.cFileName
							invoke lstrcat,addr lpMessage,addr _con
							invoke MessageBox,0,addr lpMessage,SADD('RadAsm'),MB_YESNO or MB_ICONQUESTION
							mov lpMessage,0
							.if eax==IDYES
								call OpenProject
							.else
							.endif
						.else
							;No, there is no project file in folder
							invoke MessageBox,0,addr message1,SADD('RadAsm'),MB_YESNO or MB_ICONQUESTION
							.if eax==IDYES
								invoke SendMessage,hWin,AIM_COMMAND,IDCreateProject,0
							.else
							.endif
						.endif
					.endif
				.endif
			.endif
		.elseif eax==IDCreateProject
			invoke DialogBoxParam,hInstance,IDD_DLG1,hWin,addr DlgProc,NULL 
			mov hDlg,eax
			mov eax,TRUE  
			ret
		.endif
		; Returning TRUE when executing private commands speeds things up
		mov eax, FALSE
	;======================================
	.elseif eax==AIM_INITMENUPOPUP
		; Always return FALSE
		;Find out if a file is activated
		mov	eax,[lpDStruct]
		assume eax:ptr ADDINDATA
		mov eax,dword ptr [eax].lpFile
		mov lpTemp,eax
		mov eax,dword ptr [eax]
		.if eax!=0
			;A file is active
			mov eax,lParam
			.if eax==0 || eax==1 ;File popup menu =1 when file is loaded else ==0
				;Find out if there is a project file in folder
				invoke FindRap,lpTemp
				.if eax==TRUE
					;Yes, there is a project file but not loaded
					invoke EnableMenuItem,hMnu,IDCreateProject,MF_GRAYED
;					mov flMenuItem,FALSE 
				.else
					;No, there is no project file in folder
					invoke EnableMenuItem,hMnu,IDCreateProject,MF_ENABLED
;					mov flMenuItem,TRUE
				.endif
			.endif
		.else
			;No file is active
			invoke EnableMenuItem,hMnu,IDCreateProject,MF_GRAYED
;			mov flMenuItem,FALSE 
		.endif
		; Cleanup
		mov eax, FALSE
	;======================================
	.elseif eax==AIM_PROJECTOPENED
		; Always return FALSE
		.if flDialog==TRUE   
			invoke MessageBox,0,SADD('You can now add files and dialogs etc'),SADD('RadAsm'),MB_OK
		.endif
		mov flDialog,FALSE  
		; Cleanup
		mov eax, FALSE
	;======================================
	.elseif eax==AIM_PROJECTCLOSED
		; Always return FALSE
		mov flDialog,FALSE  
		;Clear lpFile buffer
		mov	edi,[lpDStruct]
		assume edi:ptr ADDINDATA
		invoke lstrlen,[edi].lpFile
		invoke RtlZeroMemory,[edi].lpFile,eax
		; Cleanup
		mov eax, FALSE
	;======================================
	.elseif eax==AIM_CLOSE
		; Always return FALSE
		; This is where you want to kill timers, free memory, and destroy windows
		invoke DestroyWindow,hDlg
		; Cleanup
		mov eax, FALSE
	.else
		mov eax, FALSE
	.endif
	ret

DllProc Endp

End DllEntry
