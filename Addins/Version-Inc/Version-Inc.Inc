
;--------------------------------------------------------------------------------

INCVALUE MACRO iPos:REQ, iLastDigit:VARARG
    mov al, [esi+iPos]

    .if ( al == "9" )
        mov al, "0"
        mov [esi+iPos], al
        IF iPos EQ 0 ; if 1st digit is incremented need to reset digit 4
            mov al, "0"
            mov [esi+iLastDigit], al            
        ENDIF     
     
    .elseif ( al >= "0") && ( al < "9") ; only increment
        inc al
        mov [esi+iPos], al
    .endif
            
ENDM

READINCWRITEVALUE MACRO lpKey:REQ, lpDefault:REQ
    invoke GetPrivateProfileString, ADDR szVerInf, lpKey, lpDefault, ADDR szBuf, sizeof szBuf, [ebx].lpProject
    .if ( eax ) ; got some characters
        invoke incversion, ADDR szBuf
        mov bUpdateVersion, eax
        invoke WritePrivateProfileString, ADDR szVerInf, lpKey, ADDR szBuf, [ebx].lpProject
    .else
        ; write default
        invoke WritePrivateProfileString, ADDR szVerInf, lpKey, lpDefault, [ebx].lpProject        
        mov bUpdateVersion, FALSE
    .endif
ENDM       

;--------------------------------------------------------------------------------

ADDINOPT struct
	lpStr			dd ?
	nAnd			dd ?
	nOr				dd ?
ADDINOPT ends

.data

tempDATE                TEXTEQU @Date
tempTIME                TEXTEQU @Time

tmpd                    CATSTR @SubStr(%tempDATE,4,3),@SubStr(%tempDATE,0,3),<20>,@SubStr(%tempDATE,7,2)
DateText                CATSTR <">, tmpd, <">
TimeText                CATSTR <">, tempTIME, <">

szVersionInc            db "Version-Inc", 0
szError                 db "This RadASM Addin Requires Version 1.2.1.6 Or Higher", 0
szOptions               db "Options", 0
szAbout                 db "Code by X05.", 13, 10, "email: X05_44960@hotmail.com", 13, 10, 13, 10
                        db "Version-Inc v1.1 (rev2)", 13, 10
                        db "Compiled: ", DateText, " ", TimeText, 0
szVerInf                db "VerInf", 0
szFV                    db "FV", 0
szFileVersion           db "FileVersion", 0
szPV                    db "PV", 0
szProductVersion        db "ProductVersion", 0
szDefaultFVPV           db "1.0.0.0", 0
szDefault               db "1.0.0", 0
szEnabled               db "Enabled", 0
szWarningX              db 13, 10, "Unrecognised version format. Example: 1.0.0.0", 13, 10, "String possibly in other format. You need to manually reset it", 13, 10, 0
szWarningXXXX           db 13, 10, "Unrecognised version format. Example: 1.0.0.5000", 13, 10, "String incorrect size", 13, 10, 0
szIniDefault            db "52", 0 ; disabled, xxxx, file+product, warning
szClose                 db "Close", 0

AddinOpt				ADDINOPT <offset szVersionInc,1,1>
						ADDINOPT <0,0,0>

;--------------------------------------------------------------------------------

.data?

hInstance               dd ?	; Dll's module handle
hWnd                    dd ?    ; handle to radasm
lpHStruct               dd ?	; Pointer to handles struct
lpPStruct               dd ?	; Pointer to proc struct
lpDStruct               dd ?	; Pointer to data struct
IDVersionInc            dd ?    ; id for menu
iLoadOptions            dd ?    ; load options, 0=disabled, 1 for fileversion only, 2 for file+product version
bError                  dd ?    ; error during increment?

;--------------------------------------------------------------------------------
