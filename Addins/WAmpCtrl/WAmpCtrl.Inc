.386
.model flat,stdcall   ; 32 bit memory model
option scoped         ; local labels are enabled, global labels inside
                      ; PROC should be defined with double colons (LABEL::)
option casemap:none   ; case sensitive

include windows.inc
include kernel32.inc
include user32.inc
include C:\RadASM\Masm\Include\radasm.inc

includelib kernel32.lib
includelib user32.lib


; Prototypes ============================================
DLLProc     proto :dword, :dword, :dword, :dword
InstallDLL  proto :dword, :dword

; Read-only data ========================================
.const

IDD_DLG1        equ     1000
IDC_TBR1        equ     1001

IDB_AMP         equ     600

IDB_BACKWARD    equ     601
IDB_FORWARD     equ     602
IDB_PLAY        equ     603
IDB_PAUSE       equ     604
IDB_STOP        equ     605
IDB_CLOSE       equ     606

; Initialized data ======================================
.data


; Non-initialized data ==================================
.data?
hInstance       HINSTANCE   ?  ; Dll's module handle
hDialog         HWND    ?
lpHStruct       dword   ?      ; Pointer to handles struct
lpDStruct       dword   ?      ; Pointer to data struct

nMyButtonID     dword   ?      ; our menu ID obtained from RA

tbbutton        TBBUTTON        <>
addbitmap       TBADDBITMAP     <>
