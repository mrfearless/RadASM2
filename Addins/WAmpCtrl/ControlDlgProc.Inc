; Read-only data ========================================
.const
ID_CLOSE        equ     WINAMP_FORWARD + 1

ToolTips        dd      CTEXT("Previous"), CTEXT("Play"), CTEXT("Pause"), CTEXT("Stop"), \
                        CTEXT("Next"), CTEXT("Close")

; =======================================================
.code

InsertTButton proc hTbr:HANDLE, bmID:dword, idCommand:dword
        invoke  SendMessage, hTbr, TB_BUTTONSTRUCTSIZE, sizeof TBBUTTON, 0

        .IF idCommand
            mov     tbbutton.fsStyle, TBSTYLE_BUTTON
            m2m     addbitmap.nID, bmID
            invoke  SendMessage, hTbr, TB_ADDBITMAP, 1, offset addbitmap

            ; TB_ADDBITMAP returns the index of the bitmap
            mov     tbbutton.iBitmap, eax
            m2m     tbbutton.idCommand, idCommand
        .ELSE
            mov     tbbutton.fsStyle, TBSTYLE_SEP
        .ENDIF
        mov     tbbutton.fsState, TBSTATE_ENABLED
        invoke  SendMessage, hTbr, TB_INSERTBUTTON, -1, offset tbbutton
        ret
InsertTButton endp

; =======================================================
UpdateDialog proc uses ebx esi hDlg:HWND

        ; Enable or disable button
        invoke  WinAmpStatusAsInt
        .IF eax
            mov     ebx, MAKELONG(TBSTATE_ENABLED,0)
        .ELSE
            mov     ebx, MAKELONG(TBSTATE_INDETERMINATE,0)
        .ENDIF
        scall   esi=SendDlgItemMessage, hDlg, IDC_TBR1, TB_SETSTATE, WINAMP_BACKWARD, ebx
        scall   esi, hDlg, IDC_TBR1, TB_SETSTATE, WINAMP_PLAY, ebx
        scall   esi, hDlg, IDC_TBR1, TB_SETSTATE, WINAMP_PAUSE, ebx
        scall   esi, hDlg, IDC_TBR1, TB_SETSTATE, WINAMP_STOP, ebx
        scall   esi, hDlg, IDC_TBR1, TB_SETSTATE, WINAMP_FORWARD, ebx

        ; Update caption
        invoke  WinAmpStatusAsText
        mov     ecx, eax
        mov     al, byte ptr [ecx]
        .IF al == 'N'
            add     ecx, 13
        .ENDIF
        invoke  SendMessage, hDlg, WM_SETTEXT, 0, ecx
        invoke  SendDlgItemMessage, hDlg, IDC_TBR1, TB_SETSTYLE, 0, TBSTYLE_FLAT or TBSTYLE_TOOLTIPS
        ret
UpdateDialog endp

; =======================================================
ControlDlgProc proc hDlg:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

        mov     eax, uMsg
        .IF eax == WM_INITDIALOG

            ; ToolBar
            push    ebx
            mov     eax, hDlg
            mov     hDialog, eax
            invoke  GetDlgItem, eax, IDC_TBR1
            mov     ebx, eax
            scall   esi = InsertTButton, ebx, IDB_BACKWARD, WINAMP_BACKWARD
            scall   esi, ebx, IDB_PLAY, WINAMP_PLAY
            scall   esi, ebx, IDB_PAUSE, WINAMP_PAUSE
            scall   esi, ebx, IDB_STOP, WINAMP_STOP
            scall   esi, ebx, IDB_FORWARD, WINAMP_FORWARD
            scall   esi, ebx, 0, 0   ; separator
            scall   esi, ebx, 0, 0
            scall   esi, ebx, IDB_CLOSE, ID_CLOSE
            scall   esi, ebx, 0, 0
            pop     ebx
            
            invoke  UpdateDialog, hDlg

        .ELSEIF eax == WM_COMMAND
            mov     eax, wParam
            .IF (eax == WINAMP_PLAY || eax == WINAMP_STOP || eax == WINAMP_PAUSE || \
                 eax == WINAMP_BACKWARD || eax == WINAMP_FORWARD)
                invoke  SendMessage, hWinAmp, WM_COMMAND, eax, 0
                invoke  UpdateDialog, hDlg

            .ELSEIF eax == ID_CLOSE
                xor     eax, eax
                mov     hDialog, eax
                invoke  SendMessage, hDlg, WM_CLOSE, eax, eax
            .ENDIF

        .ELSEIF eax==WM_NOTIFY
            mov     edx, lParam
            mov     eax, [edx].NMHDR.code
            .IF eax == TTN_NEEDTEXT
                ; Toolbar tooltip
                mov     eax, [edx].NMHDR.idFrom
                sub     eax, WINAMP_BACKWARD
                mov     eax, ToolTips[eax * sizeof dword]
                mov     [edx].TOOLTIPTEXT.lpszText, eax
            .ENDIF

        .ELSEIF eax == WM_CLOSE
            invoke  EndDialog, hDlg, 0
        .ELSE
            return  FALSE
        .ENDIF
        return TRUE
ControlDlgProc endp
; =======================================================

