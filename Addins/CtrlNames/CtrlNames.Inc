
;#########################################################################
;		Include files

	include windows.inc
	include kernel32.inc
	include user32.inc

;#########################################################################
;		Libraries

	includelib kernel32.lib
	includelib user32.lib

;#########################################################################
;		RadASM Add In Include

	include \RadASM\Masm\Inc\radasm.inc

;#########################################################################
;		Prototypes

	DLLProc					PROTO :DWORD, :DWORD, :DWORD, :DWORD
	InstallDLL				PROTO :DWORD, :DWORD
	
	TYPES struct
		ID				dd ?
		lpclass			dd ?
		notused			dd ?
		style			dd ?
		exstyle			dd ?
		lpidname		dd ?
		lpcaption		dd ?
		lprc			dd ?
		nmethod			dd ?
		methods			dd ?
		flist			dd 4 dup(?)
	TYPES ends

.const

	CtrlID		db 'DLG_',0
				db 'Dialog',0
				db 'EDT_',0
				db 0
				db 'STC_',0
				db 'Static',0
				db 'GRP_',0
				db 'GroupBox',0
				db 'BTN_',0
				db 'Button',0
				db 'CHK_',0
				db 'CheckBox',0
				db 'RBN_',0
				db 'RadioButton',0
				db 'CBO_',0
				db 0
				db 'LST_',0
				db 0
				db 'SCB_',0
				db 0
				db 'SCB_',0
				db 0
				db 'TAB_',0
				db 0
				db 'PGB_',0
				db 0
				db 'TRV_',0
				db 0
				db 'LSV_',0
				db 0
				db 'TRB_',0
				db 0
				db 'UDN_',0
				db 0
				db 'IMG_',0
				db 0
				db 'TBR_',0
				db 0
				db 'SBR_',0
				db 'StatusBar',0
				db 'DTP_',0
				db 0
				db 'MVI_',0
				db 0
				db 'RED_',0
				db 'RichEdit',0
				db 'UDC_',0
				db 'UDCCLASS',0
				db 'CBE_',0
				db 0
				db 'SHP_',0
				db 0
				db 'IPA_',0
				db 0
				db 'ANI_',0
				db 0
				db 'HOT_',0
				db 0
				db 'PGR_',0
				db 0
				db 'PGR_',0
				db 0
				db 'REB_',0
				db 0
				db 'HDR_',0
				db 0
				db 0
				db 0

.data?

	hInstance	dd ?			;Dll's module handle
	lpData		dd ?			;Pointer to data struct
	OldPtr		dd 128 dup(?)	;Holds old ptr's
