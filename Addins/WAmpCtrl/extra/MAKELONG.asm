; =======================================================
MAKELONG macro l:=<0>, h:=<0>
    LOCAL a

    if ((OPATTR(l) AND 4) AND (OPATTR(h) AND 4))

        a = (h SHL 16) + l
        exitm <a>

    elseif ((OPATTR(l)) AND 4)

        ifdifi <h>,<eax>
            mov     eax, h
        endif

        ifidni <l>,<eax>
            mov     ecx, eax
        endif

        shl     eax, 16
        ifidni <l>,<eax>
            or      eax, ecx
        else
            or      eax, l
        endif
        exitm <eax>

    elseif ((OPATTR(h)) AND 4)
        a = (h SHL 16)

        ifdifi <l>,<eax>
            mov     eax, l
        endif

        or      eax, a
        exitm <eax>
    else
        ifidni <l>,<eax>
            ifidni <h>,<ecx>
                mov     edx, eax
            else            
                mov     ecx, eax
            endif
        endif

        ifdifi <h>,<eax>
            mov     eax, h
        endif
        shl     eax, 16

        ifidni <l>,<eax>
            ifidni <h>,<ecx>
                or      eax, edx
            else
                or      eax, ecx
            endif
        else
            or      eax, l
        endif

        exitm <eax>
    endif
endm

MAKELPARAM  textequ <MAKELONG>
; =======================================================
