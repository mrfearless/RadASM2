include winamp\frontend.inc


; Non-initialized data ==================================
.data?

hWinAmp     HANDLE  ?
szTitle     db      1024 dup (?) ; Now playing


; =======================================================
.code
WinAmpStatusAsInt proc
; 0 - not running
; 1 - stopped
; 2 - playing
; 3 - paused
        invoke  FindWindow, CTEXT("Winamp v1.x"), NULL
        mov     hWinAmp, eax
        .IF eax
            invoke  SendMessage, eax, WM_WA_IPC, 0, IPC_ISPLAYING
            .IF eax == 3
            .ELSEIF eax != 1
                mov     eax, 1
            .ELSE
                mov     eax, 2
            .ENDIF
        .ENDIF
        ret
WinAmpStatusAsInt endp


; =======================================================
WinAmpStatusAsText proc uses esi

        invoke  WinAmpStatusAsInt
        
        .IF !eax
            mov     esi, CTEXT("WinAmp not started")
        .ELSEIF eax == 3
            mov     esi, CTEXT("WinAmp paused")
        .ELSEIF eax == 1
            mov     esi, CTEXT ("WinAmp stopped")
        .ELSE
            invoke  GetWindowText, hWinAmp, offset szTitle, sizeof szTitle
            mov     esi, offset szTitle

            .REPEAT
                mov     al, byte ptr [esi]
                inc     esi
            .UNTIL al == '.'
          
            inc     esi
            invoke  lstrlen, esi

            .IF eax > 9
                sub     eax, 9
                add     eax, esi
                mov     byte ptr [eax], 0
                inc     eax
                push    eax
                mov     edx, eax

                invoke  wsprintf, edx, CTEXT("Now playing: %s"), esi
                pop     esi
            .ELSE
                mov esi, CTEXT("Now playing: Untitled")
            .ENDIF
        .ENDIF
        mov     eax, esi
        ret
WinAmpStatusAsText endp
; =======================================================
