; = by HardCode =========================================
return macro param
    ifnb <param>
        if ((OPATTR(param)) AND 12h)
            mov eax, param
        elseif (param EQ 0)
            sub eax, eax
        elseif (param EQ 1)
            sub eax, eax
            inc eax
        elseif (param EQ -1)
            sub eax, eax
            dec eax
        else
            mov eax, param
        endif
    endif
    ret
endm
; =======================================================
;return MACRO arg
;        mov eax, arg
;        ret
;ENDM
