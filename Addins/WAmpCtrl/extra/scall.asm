; =======================================================
; STDCALL calling convention macro (improved by Eviloid)
; right to left push
; =======================================================
scall macro namefunc:REQ,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12, \
                     p13,p14,p15,p16,p17,p18,p19,p20,p21,p22
    LOCAL pos

    pos = @InStr(1,<&namefunc&>,<=>)

    if ((OPATTR(p22)) AND 16h)
       push p22
    endif
    if ((OPATTR(p21)) AND 16h) ;register(10h), const(4) or [mem](2)
       push p21
    endif
    if ((OPATTR(p20)) AND 16h)
       push p20
    endif
    if ((OPATTR(p19)) AND 16h)
       push p19
    endif
    if ((OPATTR(p18)) AND 16h)
       push p18
    endif
    if ((OPATTR(p17)) AND 16h)
       push p17
    endif
    if ((OPATTR(p16)) AND 16h)
       push p16
    endif
    if ((OPATTR(p15)) AND 16h)
       push p15
    endif
    if ((OPATTR(p14)) AND 16h)
       push p14
    endif
    if ((OPATTR(p13)) AND 16h)
       push p13
    endif
    if ((OPATTR(p12)) AND 16h)
       push p12
    endif
    if ((OPATTR(p11)) AND 16h)
       push p11
    endif
    if ((OPATTR(p10)) AND 16h)
       push p10
    endif
    if ((OPATTR(p9)) AND 16h)
       push p9
    endif
    if ((OPATTR(p8)) AND 16h)
       push p8
    endif
    if ((OPATTR(p7)) AND 16h)
       push p7
    endif
    if ((OPATTR(p6)) AND 16h)
       push p6
    endif
    if ((OPATTR(p5)) AND 16h)
       push p5
    endif
    if ((OPATTR(p4)) AND 16h)
       push p4
    endif
    if ((OPATTR(p3)) AND 16h)
       push p3
    endif
    if ((OPATTR(p2)) AND 16h)
       push p2
    endif
    if ((OPATTR(p1)) AND 16h)
       push p1
    endif
    if &pos NE 0
        mov     @SubStr(namefunc,1,pos - 1), @SubStr(namefunc, pos + 1)
        call    @SubStr(namefunc,1,pos - 1)
    else
        call    namefunc
    endif
endm

SCALL textequ <scall>
; =======================================================