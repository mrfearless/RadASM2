.386
.model flat,stdcall
option casemap:none

;--------------------------------------------------------------------------------

include windows.inc
include kernel32.inc
include user32.inc

include \radasm\masm\inc\radasm.inc
include Version-Inc.inc

;--------------------------------------------------------------------------------

includelib user32.lib
includelib kernel32.lib

include masm32.inc
includelib masm32.lib
;include debug.inc
;includelib debug.lib

;#########################################################################
;		VKim's Debug

	include \masm32\include\debug.inc
	includelib \masm32\lib\debug.lib

	DBGWIN_DEBUG_ON = 1 ; include debug info into the program
	DBGWIN_EXT_INFO = 0 ; include extra debug info into the program

;--------------------------------------------------------------------------------

DialogProc     PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
DLLProc        PROTO hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
incversion     PROTO lpText:DWORD
InstallDLL     PROTO hWin:DWORD, fOpt:DWORD
loadsettings   PROTO 
savesettings   PROTO 
textOut        PROTO lpText:DWORD
Upd            PROTO
     
;--------------------------------------------------------------------------------

.const

ID_ENABLED                              equ 1
ID_X                                    equ 2
ID_XXXX                                 equ 4
ID_FILE                                 equ 8
ID_FILEPRODUCT                          equ 16
ID_WARNING                              equ 32

;Version-Inc.dlg
IDD_DLG1								equ 1000
IDC_GRP1								equ 1001
IDC_RBN_FMT1							equ 1002
IDC_RBN_FMT2							equ 1003
IDC_BTN_OK								equ 1004
IDC_BTN_CANCEL							equ 1005
IDC_GRP2								equ 1006
IDC_RBN_UPD1							equ 1007
IDC_RBN_UPD2							equ 1008
IDC_CHK_WARNING                         equ 1009
IDC_CHK_ENABLED                         equ 1010

;--------------------------------------------------------------------------------

.code

setmenustate proc bChecked:DWORD

    LOCAL mii:MENUITEMINFO
    LOCAL hMenu:DWORD

    invoke GetMenu, hWnd
    mov hMenu, eax        
    mov mii.cbSize, sizeof MENUITEMINFO
    mov mii.fMask, MIIM_STATE
    .if ( bChecked )
        mov mii.fState, MF_CHECKED
    .else
        mov mii.fState, MF_UNCHECKED
    .endif
    invoke SetMenuItemInfo, hMenu, IDVersionInc, FALSE, ADDR mii
    
    ret
setmenustate endp

;--------------------------------------------------------------------------------

textOut proc lpszStr:DWORD

	pushad
	push lpszStr
	mov	eax, [lpPStruct]
	call (ADDINPROCS ptr [eax]).lpTextOut
	popad
	
	ret
textOut endp

;--------------------------------------------------------------------------------

; increment version string
incversion proc uses ebx ecx esi, lpText:DWORD
	
	LOCAL bUpdateVersion:DWORD	
	
	; init: to store if FV / PV value incremented
    mov bUpdateVersion, FALSE	
    
    mov esi, lpText
    
    .if ( iLoadOptions & ID_XXXX )
    
       	; get length of string
        invoke lstrlen, lpText
        dec eax
        mov ecx, eax
@@:
            mov al, [esi+ecx]
            cmp al, "."
            je @F
        
        dec ecx
        test ecx, ecx
        jne @B
@@:

        .if ( ecx > 0 )
            add ecx, esi
            inc ecx
            push ecx
            push ecx
            call atodw
            inc eax ; increment it
            pop ecx
            invoke dwtoa, eax, ecx
        .endif

    .else 
    
    	; get length of string
        invoke lstrlen, lpText
        
;        PrintDword eax
;        PrintLine      
    
        ; FV / PV      
        .if ( eax == 7 ) 
            INCVALUE 6 ; digit 4
    
            .if ( al == "0" )
                mov bUpdateVersion, TRUE
                INCVALUE 4             ; digit 3: if last item incremented        
                .if ( al == "0" ) 
                    INCVALUE 2         ; digit 2: if last item incremented              
                    .if ( al == "0" ) 
                        INCVALUE 0, 6  ; digit 1: if last item incremented                    
                    .endif                
                .endif
            .endif
    
        ; FileVersion / ProductVersion
        .elseif ( eax == 5 ) 
            INCVALUE 4 ; digit 3
            .if ( al == "0" )
                INCVALUE 2             ; digit 2: if last item incremented
                .if ( al == "0" )
                    INCVALUE 0, 4      ; digit 1: if last item incremented
                .endif
            .endif
        .else  ; unknown string
            mov bError, TRUE                                    
        .endif
    .endif
    	
	mov eax, bUpdateVersion
	ret
incversion endp

;--------------------------------------------------------------------------------

; update version info
Upd proc uses ebx
	
	LOCAL hfile:DWORD
	LOCAL szBuf[64]:BYTE
	LOCAL bUpdateVersion:DWORD 
		
	assume ebx:ptr ADDINDATA	
	
	; get pointer to ADDINDATA struct
	mov ebx, [lpDStruct]

	; check if project loaded
	mov eax, [ebx].fProject
	.if ( eax )

        ; check if project has resource file
        mov eax, [ebx].fResProject
        .if ( eax )            

            ; get string from ini, increment it, write back to file (set default if failed)		
            READINCWRITEVALUE ADDR szFV, ADDR szDefaultFVPV
            .if ( iLoadOptions & ID_ENABLED )            
                READINCWRITEVALUE ADDR szFileVersion, ADDR szDefault
            .endif                

            .if ( iLoadOptions & ID_FILEPRODUCT )                   
                READINCWRITEVALUE ADDR szPV, ADDR szDefaultFVPV
                .if ( iLoadOptions & ID_ENABLED )
                    READINCWRITEVALUE ADDR szProductVersion, ADDR szDefault
                .endif
           .endif                
         
            ; refresh dialog with new info   
            push FALSE
            mov eax, [lpPStruct] 
            call [eax].ADDINPROCS.lpUpdateVerInf
        .endif
        
    .endif        

	assume ebx:nothing
	
	ret
Upd endp

;--------------------------------------------------------------------------------

; load settings from rap file
loadsettings proc

    LOCAL szBuf[16]:BYTE   

    mov eax, lpDStruct    
    invoke GetPrivateProfileString, ADDR szVersionInc, ADDR szOptions, ADDR szIniDefault, ADDR szBuf, sizeof szBuf, (ADDINDATA ptr [eax]).lpProject
    invoke atodw, ADDR szBuf
    mov iLoadOptions, eax
    
    .if ( eax & ID_ENABLED )    
        invoke setmenustate, TRUE
    .endif        

    ret
loadsettings endp

;--------------------------------------------------------------------------------

; save settings to .rap file
savesettings proc

    LOCAL szBuf[16]:BYTE  

    invoke dwtoa, iLoadOptions, ADDR szBuf

	mov eax, lpDStruct
	invoke lstrlen,[eax].ADDINDATA.lpProject
    cmp eax,4
    jg @F
  	  ret
    @@:
    mov eax, lpDStruct
    invoke WritePrivateProfileString, ADDR szVersionInc, ADDR szOptions, ADDR szBuf, (ADDINDATA ptr [eax]).lpProject

    ret
savesettings endp

; ---------------------------------------------------------------------------

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	
	mov eax, reason
	.if ( eax == DLL_PROCESS_ATTACH )
    	mov eax, hInst
    	mov hInstance, eax
    	mov eax, TRUE

;--------------------------------------------------------------------------------    	
    .elseif ( eax == DLL_PROCESS_DETACH )                
        
	.endif
	
   	ret	
DllEntry Endp


; ---------------------------------------------------------------------------

InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD
	
	LOCAL szBuf[16]:BYTE
	LOCAL hMenu:DWORD
	LOCAL hSubMenu:DWORD
	
	push hWin
	pop hWnd
	
	;
	;  fOpt is a value read from ini and passed to the dll
	;  Use for option settings
	;
	; Optimization, saves us 3 clock cycles per use with the invoke command
	;

	; Get a pointer to the handles structure
	;
	invoke SendMessage, hWin, AIM_GETHANDLES, 0, 0
	mov lpHStruct, eax
	
	; Get a pointer to the proc structure
	;
	invoke SendMessage, hWin, AIM_GETPROCS, 0, 0
	mov lpPStruct, eax
	
	; Get a pointer to the data structure
	;
	invoke SendMessage, hWin, AIM_GETDATA, 0, 0
	mov lpDStruct, eax
	
	; check lpUpdateInf exists
    mov eax, (ADDINDATA ptr [eax]).nRadASMVer	
	.if ( eax < 1216 )
        invoke MessageBox, hWin, ADDR szError, ADDR szVersionInc, MB_ICONERROR
		xor ecx, ecx
		xor edx, edx
		ret        
	.endif	
	
	; If Option (fOpt) = 0 then exit
	;
	mov eax, fOpt
	.if ( eax == 0 )
		; ECX and EDX must be null before we return
		xor ecx, ecx
		xor edx, edx
		ret
	.endif		
	
	; Allocate a new menu id
	invoke SendMessage, hWin, AIM_GETMENUID, 0, 0
	mov IDVersionInc, eax

	invoke GetMenu, hWin
	mov hMenu, eax			
	
	mov		ecx,lpDStruct
	mov		ecx,[ecx].ADDINDATA.fMaximized
	add		ecx,4
	invoke GetSubMenu, hMenu, ecx		; Project menu
	mov	hSubMenu, eax		
		
	; Add our menuitem		  
	push offset szVersionInc
	push IDVersionInc    
    push MF_STRING or MF_BYPOSITION
	push 14 ; position
    push hSubMenu
	call InsertMenu
	
	mov eax, AddInHook(AIM_COMMAND,AIM_MAKEBEGIN,AIM_MAKEDONE,AIM_CLOSE,AIM_PROJECTCLOSE,AIM_PROJECTOPENED)

	; ECX and EDX must be null before we return
	xor ecx, ecx
	xor edx, edx
	
	ret 
	
InstallDll Endp

GetOptions proc

	mov		eax,offset AddinOpt
	ret

GetOptions endp

;---------------------------------------------------------------------------

DialogProc proc uses edx, hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

	mov	eax, uMsg
	.if ( eax == WM_INITDIALOG )
	    ; version format x or xxxx
        .if ( iLoadOptions & ID_X )
    	   invoke CheckRadioButton, hWin, IDC_RBN_FMT1, IDC_RBN_FMT2, IDC_RBN_FMT1
        .else 
    	   invoke CheckRadioButton, hWin, IDC_RBN_FMT1, IDC_RBN_FMT2, IDC_RBN_FMT2
        .endif

        ; file / product
        .if ( iLoadOptions & ID_FILE )
    	   invoke CheckRadioButton, hWin, IDC_RBN_UPD1, IDC_RBN_UPD2, IDC_RBN_UPD1
        .else 
    	   invoke CheckRadioButton, hWin, IDC_RBN_UPD1, IDC_RBN_UPD2, IDC_RBN_UPD2
        .endif
        
        ; warning
        .if ( iLoadOptions & ID_WARNING )
            invoke SendDlgItemMessage, hWin, IDC_CHK_WARNING, BM_SETCHECK, BST_CHECKED, 0
        .endif        

        ; enabled
        .if ( iLoadOptions & ID_ENABLED )
            invoke SendDlgItemMessage, hWin, IDC_CHK_ENABLED, BM_SETCHECK, BST_CHECKED, 0
        .endif               
        
       ; invoke SetDlgItemInt, hWin, 1999, iLoadOptions, FALSE

;--------------------------------------------------------------------------------
	.elseif ( eax == WM_COMMAND )
		mov	eax, wParam
		mov	edx, eax
		shr	edx, 16
		and	eax, 0FFFFh
		.if ( edx == BN_CLICKED )
			.if ( eax == IDC_BTN_OK )
			    ; reset
                mov iLoadOptions, 0
                
                ; version format, x or xxxx
                invoke IsDlgButtonChecked, hWin, IDC_RBN_FMT1
                .if ( eax == BST_CHECKED )
                    mov iLoadOptions, ID_X
                .else  
                    mov iLoadOptions, ID_XXXX
                .endif

                ; file / product
                invoke IsDlgButtonChecked, hWin, IDC_RBN_UPD1
                .if ( eax == BST_CHECKED )
                    or iLoadOptions, ID_FILE
                .else
                    or iLoadOptions, ID_FILEPRODUCT
                .endif        
                
                ; warning                
                invoke IsDlgButtonChecked, hWin, IDC_CHK_WARNING
                .if ( eax == BST_CHECKED )
                    or iLoadOptions, ID_WARNING
                .else
                    and iLoadOptions, (0FFFFFFFFh-ID_WARNING)
                .endif              
                
                ; enabled       
                invoke IsDlgButtonChecked, hWin, IDC_CHK_ENABLED
                .if ( eax == BST_CHECKED )
                    or iLoadOptions, ID_ENABLED
                .else
                    and iLoadOptions, (0FFFFFFFFh-ID_ENABLED )
                .endif       
                
                ; update menu state
                mov eax, iLoadOptions
                and eax, ID_ENABLED
                invoke setmenustate, eax
                
                invoke SendMessage, hWin, WM_CLOSE, NULL, NULL                

;--------------------------------------------------------------------------------
			.elseif ( eax == IDC_BTN_CANCEL )
				invoke SendMessage, hWin, WM_CLOSE, NULL, NULL
			.endif
		.endif

;--------------------------------------------------------------------------------		
	.elseif ( eax == WM_CLOSE )
		invoke EndDialog, hWin, NULL

;--------------------------------------------------------------------------------		
	.else
		mov eax, FALSE
		ret
	.endif
	mov  eax,TRUE
	ret

DialogProc endp


;--------------------------------------------------------------------------------

DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL mii:MENUITEMINFO
    LOCAL hMenu:DWORD
    LOCAL szBuf[32]:BYTE
    LOCAL i:DWORD
    
	; This proc handles messages sent from RadASM to our dll
	
	mov	eax, uMsg
	.if ( eax == AIM_COMMAND )
		; Return TRUE to prevent RadASM and other DLL's from
		; processing Command
		;
		mov eax, wParam
		and eax, 0FFFFh
		.if ( eax == IDVersionInc )
		
            invoke GetKeyState, VK_SHIFT
            ; shift held for options
            sub ax, 0            
            .if sign?		        
		        invoke DialogBoxParam, hInstance, 1000, hWin, ADDR DialogProc, 0		        
		        ret   
		    .endif
		    
            invoke GetAsyncKeyState, VK_CONTROL
            ; control helf for about box
            sub ax, 0
            .if sign?      
		        invoke MessageBox, hWin, ADDR szAbout, ADDR szVersionInc, MB_ICONINFORMATION
		        ret
            .endif

            invoke GetMenu, hWin
            mov hMenu, eax
		
			mov mii.cbSize, sizeof MENUITEMINFO
            mov mii.fMask, MIIM_STATE
            invoke GetMenuItemInfo, hMenu, IDVersionInc, FALSE, ADDR mii
            .if ( mii.fState & MF_CHECKED )
                invoke CheckMenuItem, hMenu, IDVersionInc, MF_UNCHECKED
                and iLoadOptions, (0FFFFFFFFh-ID_ENABLED)
            .else
                invoke CheckMenuItem, hMenu, IDVersionInc, MF_CHECKED
                or iLoadOptions, ID_ENABLED
            .endif
                
		.endif

		; Returning TRUE when executing private commands speeds things up
		mov eax, FALSE		

;--------------------------------------------------------------------------------

	.elseif ( eax == AIM_MAKEBEGIN )
		; Always return FALSE 
		
    	mov bError, FALSE		
		
		mov eax, lParam		

		; check for build command 2,3
        .if ( dword ptr [eax]=="3,2" || dword ptr [eax]==",3,2" )
    		.if ( iLoadOptions & ID_ENABLED )    		  
        		invoke Upd
            .endif 		
        .endif            

		; Cleanup
		mov eax, FALSE

;--------------------------------------------------------------------------------		
	.elseif ( eax == AIM_MAKEDONE )
		; Always return FALSE

        .if ( iLoadOptions & ID_WARNING )
            .if ( bError )
                .if ( iLoadOptions & ID_XXXX )
                    invoke textOut, ADDR szWarningXXXX
                .else
                    invoke textOut, ADDR szWarningX           
                .endif                
            .endif            
        .endif            

		; Cleanup
		mov eax, FALSE

;--------------------------------------------------------------------------------
    .elseif ( eax == AIM_CLOSE )
		mov		eax,lpHStruct
		invoke DeleteMenu,[eax].ADDINHANDLES.hMenu,IDVersionInc,MF_BYCOMMAND

;--------------------------------------------------------------------------------
    .elseif ( eax == AIM_PROJECTCLOSE )
        invoke savesettings
        
		; Cleanup
		mov eax, FALSE        
    
;--------------------------------------------------------------------------------
    .elseif ( eax == AIM_PROJECTOPENED )

        invoke loadsettings
                
		; Cleanup
		mov eax, FALSE         
    
;--------------------------------------------------------------------------------    
	.else
		mov eax, FALSE
	.endif

	ret

DllProc Endp

;--------------------------------------------------------------------------------

End DllEntry
