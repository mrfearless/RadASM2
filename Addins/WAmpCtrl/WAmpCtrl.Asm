; just for fun!

;!!NOTE: need WinAmp 2.x

;!!TODO: add volume control

include WAmpCtrl.inc
include WinAmpStatus.inc
include ControlDlgProc.inc


.code
; =======================================================
DllEntry proc hInst:HINSTANCE, reason:dword, reserved1:dword
        m2m     hInstance, hInst
        return TRUE
DllEntry endp

; =======================================================
InstallDll proc uses ebx esi hWin:dword, fOpt:dword
        ;
        ;  fOpt is a value read from ini and passed to the dll
        ;  Use for option settings
        ;

        ; Optimization, saves us 3 clock cycles per use with the invoke command
        ;
        mov     ebx, hWin
;        mov     hWnd, ebx

        ; Get a pointer to the handles structure
        ;
        scall   esi = SendMessage, ebx, AIM_GETHANDLES, 0, 0
        mov     lpHStruct, eax

        ; Get a pointer to the data structure
        ;
        scall   esi, ebx, AIM_GETDATA, 0, 0
        mov     lpDStruct, eax

        ; If Option (fOpt) = 0 then exit
        ;
        mov     eax, fOpt

        .IF !eax
            ret
        .ENDIF

        ZeroMemory offset tbbutton, sizeof TBBUTTON + sizeof TBADDBITMAP
        
        invoke  SendMessage, hWin, AIM_GETMENUID, 0, 0 ; Get our own menu id
        mov     nMyButtonID, eax

        mov     tbbutton.idCommand, eax ;toolbar button will have the same id as our menuitem

        mov     esi, lpHStruct

        m2m     addbitmap.hInst, hInstance

        invoke  InsertTButton, [esi].ADDINHANDLES.hToolBar, IDB_AMP, eax

        ; Tell RadASM messages we want to hook
        ;
        mov     eax, RAM_COMMAND or RAM_TBRTOOLTIP or RAM_TIMER

        ; ECX and EDX must be null before we return
        ;
        xor     ecx, ecx
        xor     edx, edx
        mov     hDialog, ecx

        ret
InstallDll endp

; =======================================================
DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

        ; This proc handles messages sent from RadASM to our dll
        ;
        mov     eax, uMsg

        .IF eax == WM_COMMAND
            mov     eax, wParam
            and     eax, 0FFFFh

            .IF eax == nMyButtonID
                mov     eax, hDialog
                .IF !eax
                    invoke  DialogBoxParam, hInstance, IDD_DLG1, NULL, offset ControlDlgProc, NULL
                .ELSE
                    invoke  SetForegroundWindow, eax
                .ENDIF
                return TRUE
            .ENDIF

        .ELSEIF eax == AIM_TIMER
            mov     eax, hDialog
            .IF eax
                invoke  UpdateDialog, eax
            .ENDIF            

        .ELSEIF eax == AIM_TBRTOOLTIP
            mov     eax, wParam
            .IF eax == nMyButtonID
                invoke  WinAmpStatusAsText
                ret
            .ENDIF

        .ENDIF ; uMsg

        return FALSE ; for all messages except private WM_COMMANDs
DllProc endp

; =======================================================
end DllEntry
