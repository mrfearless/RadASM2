; =======================================================
CTEXT macro y:VARARG
    LOCAL sym, cursegm

    cursegm textequ <@CurSeg>

    ifidni cursegm,<_BSS>
        .data?
    elseifidni cursegm,<_DATA>
        .data
    elseifidni cursegm,<_TEXT>
        .code
    endif

    CONST segment
        ifidni <y>, <"">
            sym db 0
        elseifidni <y>,<>
            sym db 0
        else
            sym db y, 0
        endif
    CONST ends

    ifidni cursegm,<_BSS>
        .data?
    elseifidni cursegm,<_DATA>
        .data
    elseifidni cursegm,<_TEXT>
        .code
    endif
    exitm <offset sym>
endm
; =======================================================
