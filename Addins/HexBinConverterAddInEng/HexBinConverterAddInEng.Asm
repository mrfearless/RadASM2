; ÌÎÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÊÎ?
; Ì?ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?Ì?
; Ì?? ÜÜÛÛÛÛÛÛÛÛÛ   ÜÜÛÛÛÛÛÛÛÜÜ   ÜÛÛÛÛÛÛÛÛÛÜ ?Ì?
; Ì?? ÛÛÛÛÛÛÛÛÛßß   ÛÛÛÛÛÛÛÛÛßß   ßÛÛÛÛÛÛÛÛÛß ?Ì?
; Ì?? ÛÛ            ÛÛß               ÛÛÛ     ?Ì?
; Ì?? ÛÛ            ÛÛ                ÛÛÛ     ?Ì?
; Ì?? ÛÛÛÛÛÛÛÛÛÜÜ   ÛÛ                ÛÛÛ     ?Ì?
; Ì?? ßßÛÛÛÛÛÛÛÛÛ   ÛÛ                ÛÛÛ     ?Ì?
; Ì??          ÛÛ   ÛÛ                ÛÛÛ     ?Ì?
; Ì??          ÛÛ   ÛÛÜ               ÛÛÛ     ?Ì?
; Ì?? ÜÜÛÛÛÛÛÛÛÛÛ   ÛÛÛÛÛÛÛÛÛÜÜ       ÛÛÛ     ?Ì?
; Ì?? ÛÛÛÛÛÛÛÛÛßß   ßßÛÛÛÛÛÛÛßß       ßÛß     ?Ì?
; Ì??                                         ?Ì?
; Ì??                home of secret reversers®?Ì?
; Ì?ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?Ì?
; HexBinConverter RadASM Addin v1.0
; _______________________________________________________________________________
; Author    : BlueDeviL <bluedevil@sctzine.com>
; Tester    : ErrorInside <errorinside@sctzine.com>
; IDE       : RADAssembler v2.2.2.3 <http://masm32.com/board/index.php?board=24.0>
; Template  : BlueDeviL // SCT
; Date      : 28/08/2018
; License   : MIT
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;																  www.sctzine.com

.486
.model flat, stdcall
option casemap :none


include HexBinConverterAddInEng.inc

.code

; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
;		Common addin procedures
DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
; _______________________________________________________________________________
; DLL entry procedure
; Receives  :
; Returns   : 
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	mov eax, hInst
	mov hInstance, eax
	mov eax, TRUE
	ret
DllEntry Endp

AddMenu proc
; _______________________________________________________________________________
; Adds our addin's name to where we declared
; Receives  :
; Returns   :  
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	mov	edx,6								;6 = tools menu
	;Adjust topmost popup if maximized
	mov	eax,[lpData]
	.if [eax].ADDINDATA.fMaximized
		inc	edx
	.endif

	;eax = pointer to handles struct
	mov	eax,[lpHandles]
	
	;GetSubMenu; Retrieves a handle to the drop-down menu or submenu activated by the specified menu item.
	invoke GetSubMenu,\
		[eax].ADDINHANDLES.hMenu,\			;HMENU	hMenu,A handle to the menu.
		edx									;int	nPos,The zero-based relative position in the specified menu of an item that activates a drop-down menu or submenu.(4:project, 6:Tools gibi)
	
	;eax  = handle comes from we specified from GetSubMenu
	;Appends a new item to the end of the specified menu bar, drop-down menu, submenu, or shortcut menu.
	invoke AppendMenu,\
		eax,\								;HMENU	hMenu,A handle to the menu bar, drop-down menu, submenu, or shortcut menu to be changed.
		MF_STRING,\							;UINT	uFlags,MF_STRING declares we are going to use a string at menu, we can declare a bitmap
		IDAddIn,\							;UINT_PTR uIDNewItem,The identifier of the new menu item or, if the uFlags parameter is set to MF_POPUP, a handle to the drop-down menu or submenu. 
		addr szCnvrtAddin					;LPCTSTR lpNewItem,The content of the new menu item.
	
	ret

AddMenu endp

; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
InstallDll proc uses ebx hWin:DWORD, fOpt:DWORD
; _______________________________________________________________________________
; !!! THIS PROC MUST BE EXPORTED !!! (it is autoexported if MakeDef is enabled with option 2)
; Receives  : hWin, handle of window
;             fOpt, ini'den okunan ve dll'e geçen ayar seçenekleri için kullanýlan deðer
; Returns   : eax, hooked messages
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	mov	ebx,hWin
	
	;Get pointer to handles struct
	invoke SendMessage,ebx,AIM_GETHANDLES,0,0;	
	mov	lpHandles,eax

	;Get pointer to proc struct
	invoke SendMessage,ebx,AIM_GETPROCS,0,0
	mov	lpProc,eax

	;Get pointer to data struct
	invoke SendMessage,ebx,AIM_GETDATA,0,0	
	mov	lpData,eax

	mov eax,fOpt
	test eax,eax
	je @F
		;allocate new menu ID
		invoke SendMessage,ebx,AIM_GETMENUID,0,0
		mov IDAddIn,eax
		mov mytbbutton.idCommand,eax ;toolbar item gets the same ID as menu item
		;add menu item
		invoke AddMenu
		
		mov ebx,[lpHandles]
		mov ebx,[ADDINHANDLES ptr[ebx]].hToolBar
		invoke SendMessage,ebx,TB_GETIMAGELIST,0,0
		push eax
		invoke LoadBitmap,hInstance,ikonBMP
		pop edx
		push eax
		;Adds an image or images to an image list, generating a mask from the specified bitmap.The ImageList_AddMasked function copies the bitmap to an internal data structure.
		invoke ImageList_AddMasked,\	;Bitmaps with color depth greater than 8bpp are not supported. Be sure to use the DeleteObject function to delete hbmImage after the function returns.
				edx,\					;HIMAGELIST himl, A handle to the image list. 
				eax,\					;HBITMAP hbmImage, A handle to the bitmap that contains one or more images. 
				0FFFFFFh				;The color used to generate the mask. (R,G,B)
		mov mytbbutton.iBitmap,eax
		pop eax
		
		;The DeleteObject function deletes a logical pen, brush, font, bitmap, region, or palette, freeing all system resources associated with the object. After the object is deleted, the specified handle is no longer valid.
		invoke DeleteObject,eax
		invoke SendMessage,ebx,TB_BUTTONSTRUCTSIZE,sizeof TBBUTTON,0
		invoke SendMessage,ebx,TB_INSERTBUTTON,-1,offset mytbbutton
		
		; Messages to hook into
		mov eax, AddInHook(AIM_COMMAND,AIM_CLOSE)
		or	eax, AddInHook(AIM_MENUREBUILD,AIM_TBRTOOLTIP)
		mov ecx, RAM_ADDINSLOADED
	@@:
	; EDX must be null before we return
	xor edx, edx
	ret 

InstallDll Endp

GetOptions proc
; _______________________________________________________________________________
; gets offset of addin options and sets eax 
; Receives  : AddinOpt from RadASM.inc
; Returns   : EAX=offset of AddinOpt
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	mov		eax,offset AddinOpt
	ret

GetOptions endp

DllProc proc hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
; _______________________________________________________________________________
; !!! THIS PROC MUST BE EXPORTED !!! (it is autoexported if MakeDef is enabled with option 2)
; This proc heandles messages between our dll and radasm
; Receives  : hWin, handle of dialog
;             uMsg, message
;             wParam, Additional message information. The contents of this parameter depend on the value of the uMsg parameter.
;             lParam, Additional message information. The contents of this parameter depend on the value of the uMsg parameter.
; Returns   : 
; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	LOCAL	buffer[256]:BYTE
	LOCAL	mii:MENUITEMINFO

	mov	eax, uMsg
	.if eax == AIM_COMMAND
		mov eax,wParam
		movzx edx,ax
		shr eax, 16
		.IF edx == IDAddIn && eax == BN_CLICKED
			; Your addin has been selected
			push NULL
			push offset PencereIslemi
			push hWin
			push pencere
			push hInstance
			mov eax,lpProc
			call [eax].ADDINPROCS.lpModalDialog
		.ENDIF

	.ELSEIF eax==AIM_CLOSE
		;always return FALSE
		;Now is the time to kill timers, free memory, destroy windows, unhook, delete menuitems and delete toolbar buttons
		.IF IDAddIn
			mov		eax,lpHandles
			mov		eax,[eax].ADDINHANDLES.hMenu
			invoke DeleteMenu,eax,IDAddIn,MF_BYCOMMAND
			mov		edx,[lpHandles]
			invoke SendMessage,(ADDINHANDLES ptr [edx]).hToolBar,TB_COMMANDTOINDEX,IDAddIn,0
			mov		edx,[lpHandles]
			invoke SendMessage,(ADDINHANDLES ptr [edx]).hToolBar,TB_DELETEBUTTON,eax,0
			mov		IDAddIn,0
		.ENDIF
	.ELSEIF eax==AIM_MENUREBUILD
		call AddMenu
		call UpdateMenu
	.ELSEIF eax==AIM_ADDINSLOADED
		call UpdateMenu
	.ELSEIF eax==AIM_TBRTOOLTIP
		mov		eax,wParam
		.IF eax==IDAddIn
			push sizeof buffer/2
			lea eax,buffer
			push eax
			push 4000
			push offset szAppName
			mov eax,lpProc
			call [eax].ADDINPROCS.lpGetLangString
			.if !eax
				mov eax,offset szCnvrtAddinTp
			.else
				lea eax,buffer
				;To tell RadASM it's unicode
				mov edx,123456
			.endif
			ret
		.endif
	.ELSEIF eax==AIM_PROJECTCLOSE
		;
	.ELSEIF eax==AIM_PROJECTOPENED
		;
	.endif

	mov eax,FALSE
	ret
	
UpdateMenu:
	;Update menu text
	push	sizeof buffer/2
	lea		eax,buffer
	push	eax
	push	2000
	push	offset szAppName
	mov		eax,lpProc
	call	[eax].ADDINPROCS.lpGetLangString
	.if eax
		mov		mii.cbSize,sizeof MENUITEMINFO
		mov		mii.fMask,MIIM_TYPE
		mov		mii.fType,MFT_STRING
		lea		eax,buffer
		mov		mii.dwTypeData,eax
		mov		edx,lpHandles
		invoke SetMenuItemInfoW,[edx].ADDINHANDLES.hMenu,IDAddIn,FALSE,addr mii
	.endif
	retn
;	
DllProc Endp

; ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
PencereIslemi proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
;
; [TR] Dialogumuzun ana islemi. Baslarken ne yapacagi, tuslara basilinca ne olacagini
; burada programliyoruz. Daha yrintili bir ifade ile Dialog kutusuna gönderilecek 
; mesajlarin islendigi yer bu yordam.
; [ENG] DialogProc
; Receives: hWin, dialog kutusu handle degeri
;           uMsg, mesaj
;           wParam, mesaja özgü ek bilgi
;           lParam, mesaja özgü ek bilgi 
; Returns:  eax=TRUE hersey yolunda giderse
; _______________________________________________________________________________
	mov		eax,uMsg
	.if eax==WM_INITDIALOG
	invoke LoadIcon,hInstance,5001
	invoke SendMessage,hWin,WM_SETICON,ICON_BIG,eax
	mov		eax,hWin
	mov		hDlg,eax
;	push	FALSE
;	push	offset szAppName
;	push	hWin
;	mov		eax,lpProc
;	call	[eax].ADDINPROCS.lpSetLanguage
;	mov		eax,lpData
	invoke SendDlgItemMessage,hWin,edtHEX,EM_LIMITTEXT,8,0		;edtHEX max 8 karakter ile sýnýrlandýr
	invoke SendDlgItemMessage,hWin,edtBIN,EM_LIMITTEXT,20h,0	;edtBIN max 32 karakter ile sýnýrlandýr
	invoke GetDlgItem,hWin,edtHEX								;edtHEX editinin "handle"ýný al eax'e yaz
	invoke SetWindowLong,eax,GWL_WNDPROC,addr EditAFKontrolu	;SetWindowLong APIsi ile EditAFKontrolu fonksiyonunda
																;belirttiðimiz þekilde edtHEX editinin davranýþýný
																;deðiþtir.Biz bu fonk. ile bu edite sadece 0-9 ve A-F
																;karakterlerinin yazýlabilmesine izin verdik.
	mov EskiPenIslemi,eax
	
	invoke GetDlgItem,hWin,edtBIN								;edtHEX editinin "handle"ýný al eax'e yaz
	invoke SetWindowLong,eax,GWL_WNDPROC,addr EditIkiKontrolu	;SetWindowLong APIsi ile EditIkiKontrolu fonksiyonunda
																;belirttiðimiz þekilde edtBIN editinin davranýþýný
																;deðiþtir.Biz bu fonk. ile bu edite sadece 0-1
																;karakterlerinin yazýlabilmesine izin verdik.
	mov EskiPenIslemi,eax
	mov kntrlBAYRAK,TRUE
	
	.elseif eax==WM_COMMAND
	mov eax,wParam
	mov edx,wParam
	shr edx,16
		.if dx==BN_CLICKED
			.if ax==btnKAPAT
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif ax==btnYARDIM
				invoke MessageBox,hWin,addr msgYardim,addr msgBaslik,MB_APPLMODAL
			.endif
		.endif
		shr eax,16
		.if ax==EN_SETFOCUS
			invoke SendMessage,lParam,WM_GETTEXT,24h,addr tampon2
		.elseif ax==(EN_UPDATE) && (kntrlBAYRAK)
			invoke SendMessage,lParam,WM_GETTEXT,24h,addr tampon1
			mov ecx,eax
			mov eax,wParam
			and eax,0000FFFFh
			.if ax==edtHEX
				mov kntrlBAYRAK,FALSE
				invoke HexOlarakAl,addr tampon1,ecx
				mov eax,ebx
				push eax
				push ebx
				invoke OnA2Iki,eax
				invoke wsprintf,addr tampon3,addr formatubits,eax
				invoke SetDlgItemText,hWin,lblBITS,addr tampon3
				invoke SetDlgItemText,hWin,edtBIN,addr tampon2
				invoke SetDlgItemText,hWin,edtBIN2,addr tampon2
				pop ebx
				pop eax
				invoke wsprintf,addr tampon3,addr formats,ebx
				invoke SetDlgItemText,hWin,edtDEC,addr tampon3
				mov kntrlBAYRAK,TRUE
			.elseif ax==edtBIN
				mov kntrlBAYRAK,FALSE
				
				sub eax,eax
				mov ebx,ecx
				or ebx,ebx
				je _islemyapma
				invoke Iki2OnA,addr tampon1,ecx
				
				_islemyapma:
				mov tampon4,ebx;ebx'de HEX deðerim var
				;aþaðýdaki 2 kodla kaç bitlik 2lik deðer girdiðimi yazdýrýyorum
				invoke wsprintf,addr tampon2E,addr formatubits,ecx
				invoke SetDlgItemText,hWin,lblBITS,addr tampon2E
				
				;aþaðýdaki 2 kodla edtHEX'e girdiðim ikilik deðerin HEX karþýlýðýný yazdýrýyorum
				invoke wsprintf,addr tampon3E,addr formatX,tampon4
				invoke SetDlgItemText,hWin,edtHEX,addr tampon3E
				
				;aþaðýdaki 2 kodl ile de ikilik deðerin onluk karþýlýðýný yazdýrýyorum
				invoke wsprintf,addr tampon1E,addr formats,ebx
				invoke SetDlgItemText,hWin,edtDEC,addr tampon1E
				
				;invoke OnA2Iki,tampon4
				invoke SetDlgItemText,hWin,edtBIN2,addr tampon1
				
				mov kntrlBAYRAK,TRUE
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

PencereIslemi endp

comment *
[TR] HexOlarakAl fonksiyonunu kullanýcýnýn edite girdiði 32bitlik HEX deðerini alýp
ebx yazmacýna (oradanda CikanDeger deðiþkenine) yazdýrmak için yazdým. Böylece
Yazmacýn bir tanesinde kullanýcýnýn girmiþ olduðu hex deðerini kolaylýkla kull
anabilmiþ oluyorum.
[ENG] HexOlarakAl = GetAsHexadecimal, gets the string from edit as it is hexadecimal
remember we permit only hex charachers on our edit
*
HexOlarakAl proc GelenDeger:DWORD,GelenUzunluk:DWORD

mov esi,GelenDeger
mov ecx,GelenUzunluk
xor ebx,ebx


donguB:
shl ebx,4
dongu:
xor eax,eax
lodsb
push ecx
cmp al,30h
jb _son
cmp al,39h
ja _AFKontrol
sub al,30h
_devam:
add bl,al
pop ecx
loop donguB
mov CikanDeger,ebx
_son:

ret

_AFKontrol:
cmp al,41h
jb _son
cmp al,46h
ja _son
sub al,37h
jmp _devam

HexOlarakAl endp

comment *
[TR] OnA2Iki iþlemi onaltýlýk bir sayýyý  ikilik bir sayýya çevirmek için  yazdýðým
bir iþlemdir. Intel Opcodelarýnda BT olarak tanýmlanmýþ "Bit Test" komutu var.
Bu komut ile yazmaca aldýðýmýz sayýnýn her bir bitini test ederek tekrar yazdý
rýyoruz. Yazdýrdýðýmýz rakamlar bize o sayýnýn ikilik deðerini veriyor

[ENG] OnA2Iki = Hex2Bin
*
OnA2Iki proc GelenDeger:DWORD

mov edi,offset tampon2
mov ecx,1Fh
xor ebx,ebx
xchg edx,eax

_BitKontrol:
bt edx,ecx
setb al
or al,30h
stos byte ptr es:[edi]
dec ecx
jns _BitKontrol

mov ecx,20h
xchg edi,esi
sub esi,ecx

_DonguHB:
lods byte ptr ds:[esi]
cmp al,31h
je _DonguHB2
loopd _DonguHB
_DonguHB2:
xchg eax,ecx
pop edi
pop esi
pop edx
pop ecx

ret

OnA2Iki endp

comment *
[TR] Iki2OnA iþlemi adýndan da anlaþýlacaðý gibi ikilik bir sayýyý onaltýlýk deðere
dönüþtürmeye yarar.
[ENG] Iki2OnA = Bin2Hex 
*
Iki2OnA proc GelenDeger:DWORD,GelenUzunluk:DWORD

push eax
push ecx
push edi
sub eax,eax
xor edi,edi
mov ecx,GelenUzunluk
mov esi,offset tampon1
_donbasa:
lods byte ptr[esi]
or al,al
je _SayilarBitti
sub al,30h
_SayilarBitti:
add edi,edi
or edi,eax
dec ecx
jnz _donbasa
mov tampon3,edi
mov ebx,edi

;sonradan eklendi
mov ecx,GelenUzunluk
mov esi,offset tampon1
_basi:
lods byte ptr[esi]
cmp al,31h
je _dallan
loopd _basi
_dallan:
;buraya kadar
pop edi
;pop ecx
pop eax

ret

Iki2OnA endp

comment *
[TR] EditAFKontrolu bizim SubClassing için kullandýðýmýz 2 fonkisyondan birisi. Aþa
ðýdaki fonksiyonda edite sadece A-F, 0-9 ve Backspace tuþalarýnýn kullanýmýna
izin veriyoruz. Bu fonksiyomun iþlemesi için ise PencereIsleminin WM_INITDIALOG
bölümünde önce davranýþýný deðiþtireceðimiz editin handlený alýp daha sonrada
"SetWindowLong" APIsi ile aþaðýdaki foksiyonu çaðýrarak editimizin davranýþýný 
deðiþtiriyoruz.

Bir alttaki fonksiyonda ise edit binary(ikilik) olduðu için sadece "0" ve "1"
karakterlerinin yazdýrýlabilmesine ve yine Backspace tuþunun kullanýlabilmesine
izin verdim.

[ENG] EditAFKontrolu means: Controls if user entered from 0 to 9 and from A to F in edit
and allow user to backspace
Note: I have added this subroutine frum Iczelions subclassing tutorial
*
EditAFKontrolu proc hEdit:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	.if uMsg==WM_CHAR
		mov eax,wParam
		.if (al>="0" && al<="9") || (al>="A" && al<="F") || (al>="a" && al<="f") || al==VK_BACK
			.if al>="a" && al<="f"
				sub al,20h
			.endif
			invoke CallWindowProc,EskiPenIslemi,hEdit,uMsg,eax,lParam
			ret
		.else
			invoke MessageBeep,0FFFFFFFFh
		.endif
		ret
	.else
	invoke CallWindowProc,EskiPenIslemi,hEdit,uMsg,wParam,lParam
	.endif
	ret

EditAFKontrolu endp

comment *
[ENG] EditIkiKontrolu means: Controls if user entered from 0 to 9 and from A to F in edit
and allow user to backspace
*
EditIkiKontrolu proc hEdit:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
.if uMsg==WM_CHAR
	mov eax,wParam
	.if (al>="0" && al<="1") || al==VK_BACK
		invoke CallWindowProc,EskiPenIslemi,hEdit,uMsg,eax,lParam
		ret
	.else
		invoke MessageBeep,0FFFFFFFFh
	.endif
.else
	invoke CallWindowProc,EskiPenIslemi,hEdit,uMsg,wParam,lParam
	ret
.endif
xor eax,eax
ret
EditIkiKontrolu endp

End DllEntry
