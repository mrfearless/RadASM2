DlgProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL lpKey [4]:byte
	LOCAL nSize:dword
	LOCAL hfont:HFONT

	mov	eax,uMsg
	;======================================
	.if eax==WM_INITDIALOG
		;Group assembler radio buttons and masm is default
		invoke CheckRadioButton,hWin,IDC_RBN1,IDC_RBN4,IDC_RBN1
		mov dword ptr [lpAsm],'msam'
		;Group project type radio buttons and Win32 App is default
		invoke CheckRadioButton,hWin,IDC_RBN5,IDC_RBN6,IDC_RBN5
		push offset AppType1
		pop pAppType
		
		;Default check Assemble, Link and run checkboxes
		invoke CheckDlgButton,hWin,IDC_CHK2,BST_CHECKED
		invoke CheckDlgButton,hWin,IDC_CHK3,BST_CHECKED
		invoke CheckDlgButton,hWin,IDC_CHK6,BST_CHECKED
		
		;Get handles of edit controls
		invoke GetDlgItem,hWin,IDC_EDT1
		mov hEdt1,eax
		invoke GetDlgItem,hWin,IDC_EDT2
		mov hEdt2,eax
		invoke GetDlgItem,hWin,IDC_EDT3
		mov hEdt3,eax
		
		;Set new fonts in edit controls
		mov lfnt.lfWeight,FW_BOLD
		invoke CreateFontIndirect,addr lfnt
		mov hfont,eax
		invoke SendMessage,hEdt1,WM_SETFONT,hfont,0
		invoke SendMessage,hEdt2,WM_SETFONT,hfont,0
		invoke SendMessage,hEdt3,WM_SETFONT,hfont,0

		;Get active file name and folder name
		call Sort
		invoke SetDlgItemText,hWin,IDC_EDT1,addr lpFileName
		invoke SetDlgItemText,hWin,IDC_EDT2,0
		invoke SetDlgItemText,hWin,IDC_EDT3,addr lpFolder
	;======================================
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		and		eax,0FFFFh
		;======================================
		.if lParam != 0
			mov edx,wParam
			shr edx,16
			.if dx == BN_CLICKED
				;======================================
				;Assembler radio buttons
				.if ax==IDC_RBN1
					invoke CheckRadioButton,hWin,IDC_RBN1,IDC_RBN4,IDC_RBN1
					mov dword ptr [lpAsm],'msam'
				.elseif ax==IDC_RBN2
					invoke CheckRadioButton,hWin,IDC_RBN1,IDC_RBN4,IDC_RBN2
					mov dword ptr [lpAsm],'msaf'
				.elseif ax==IDC_RBN3
					invoke CheckRadioButton,hWin,IDC_RBN1,IDC_RBN4,IDC_RBN3
					mov dword ptr [lpAsm],'msat'
				.elseif ax==IDC_RBN4
					invoke CheckRadioButton,hWin,IDC_RBN1,IDC_RBN4,IDC_RBN4
					mov dword ptr [lpAsm],'msan'
				;=====================================
				;Project type radio buttons
				.elseif ax==IDC_RBN5
					invoke CheckRadioButton,hWin,IDC_RBN5,IDC_RBN9,IDC_RBN5
						push offset AppType1
						pop pAppType
						invoke CheckDlgButton,hWin,IDC_CHK6,BST_CHECKED
				.elseif ax==IDC_RBN6
					invoke CheckRadioButton,hWin,IDC_RBN5,IDC_RBN9,IDC_RBN6
						push offset AppType2
						pop pAppType
						invoke CheckDlgButton,hWin,IDC_CHK6,BST_CHECKED
				.elseif ax==IDC_RBN7
					invoke CheckRadioButton,hWin,IDC_RBN5,IDC_RBN9,IDC_RBN7
						push offset AppType3
						pop pAppType
						invoke CheckDlgButton,hWin,IDC_CHK6,BST_UNCHECKED
				.elseif ax==IDC_RBN8
					invoke CheckRadioButton,hWin,IDC_RBN5,IDC_RBN9,IDC_RBN8
						push offset AppType4
						pop pAppType
				.elseif ax==IDC_RBN9
					invoke CheckRadioButton,hWin,IDC_RBN5,IDC_RBN9,IDC_RBN9
						push offset AppType5
						pop pAppType
				;=====================================
				;OK button
				.elseif ax==IDC_BTN1 
					;Get Project description from edit control
					invoke GetDlgItemText,hWin,IDC_EDT2,addr lpDescr,128
					.if eax!=0 ;if no description, new try
						;Get new project file name
						call CreateProjectFileName
											
						;======================================
						;Write to project file
						invoke WritePrivateProfileString,SADD('Project'),SADD('Assembler'),addr lpAsm,addr lpRapFile
						invoke WritePrivateProfileString,SADD('Project'),SADD('Type'),pAppType,addr lpRapFile
						invoke WritePrivateProfileString,SADD('Project'),SADD('Description'),addr lpDescr,addr lpRapFile
						
						;======================================
						;Get data from assembler ini file
						mov	esi,[lpDStruct]
						mov	esi,(ADDINDATA ptr [esi]).lpIniFile ;Get pointer of assembler ini file name
						lea edi, lpIniFile
						invoke lstrlen,esi
						mov ecx,eax
						rep movsb
						mov eax,lpAsm ;assembler choosen
						mov dword ptr [edi-10],eax ;Insert choosen assembler name in string
						mov dword ptr [edi-6],'ini.' ;Add extension
						mov dword ptr [edi-2],0 ;zero termination
						;Get string from keys in assembler ini file and write to project file
						invoke GetPrivateProfileString,SADD('Edit'),SADD('BacupPath'),0,addr lpReturnedString,128,addr lpIniFile
						invoke WritePrivateProfileString,SADD('Project'),SADD('Backup'),addr lpReturnedString,addr lpRapFile
						
						invoke GetPrivateProfileString,SADD('Edit'),SADD('Group'),0,addr lpReturnedString,128,addr lpIniFile
						invoke WritePrivateProfileString,SADD('Project'),SADD('Group'),addr lpReturnedString,addr lpRapFile
						
						invoke GetPrivateProfileString,SADD('Edit'),SADD('GroupExpand'),0,addr lpReturnedString,128,addr lpIniFile
						invoke WritePrivateProfileString,SADD('Project'),SADD('GroupExpand'),addr lpReturnedString,addr lpRapFile
						
						;======================================
						;Write to debug key in project file
						invoke WritePrivateProfileString,SADD('Project'),SADD('Debug'),SADD('0'),addr lpRapFile
	
						;======================================
						;Get menu settings from checkboxes and write to menu key in project file
						xor ecx,ecx
				@@:
						mov eax,IDC_CHK1
						add eax,ecx
						push ecx
						invoke IsDlgButtonChecked,hWin,eax
						add al,30h
						pop ecx
						mov byte ptr [Menudef+2*ecx],al
						inc ecx
						cmp ecx,8
						jle @B
						invoke WritePrivateProfileString,SADD('MakeDef'),SADD('Menu'),addr Menudef,addr lpRapFile
						
						;======================================
						;Get strings from section MakeDef keys 1 to 6 in assembler ini file
						mov dword ptr [lpKey],'1'
				lbl_nxt:
						invoke GetPrivateProfileString,pAppType,addr lpKey,0,addr lpReturnedString,128,addr lpIniFile
						;If key=3 i.e link check if compile rc is choosen. If true add ,4 otherwise not
						.if dword ptr [lpKey]=='3'
							invoke StrLen,addr lpReturnedString
							mov nSize,eax
							lea esi,lpReturnedString
							add esi,nSize
							dec esi 
							mov eax,dword ptr [esi] ;Look at the last byte. Is it 4
							.if byte ptr [Menudef]=='1'
								cmp eax,'4' ;Compile RC is choosen, add ,4
								je @F
								inc esi
								mov word ptr [esi],'4,'
								mov byte ptr [esi+1],0
				@@:
							.else
								cmp eax,'4' ;Compile RC is not choosen, end with 3
								jne @F
								dec esi
								mov word ptr [esi],0
				@@:
							.endif
						.endif
						;Write to project ini file
						invoke WritePrivateProfileString,SADD('MakeDef'),addr lpKey,addr lpReturnedString,addr lpRapFile
						add byte ptr [lpKey],1 ;next key
						cmp lpKey,'7'
						jne lbl_nxt
						
						;======================================
						;Write make files to project ini file
						lea esi,lpFileName ;Load active file name with extension
						lea edi,lpMakeFile ;Load address of buffer of make file names
						invoke lstrlen,esi
						mov nSize,eax
						mov ecx,eax
						rep movsb ;copy to buffer
						mov dword ptr [edi-4],0 ;remove extension
						mov dword ptr [lpKey],'0' ;first key
	lbl_back:
						push ecx ;stor number of characters
						;Get extension from assembler ini file
						invoke GetPrivateProfileString,SADD('MakeFiles'),addr lpKey,0,addr lpReturnedString,128,addr lpIniFile
					    invoke lstrlen,addr lpMakeFile ;Get number of characters
					    mov edx,offset lpMakeFile ;Load pointer of make file name
					    mov ecx,offset lpReturnedString ;Load pointer of make retrieved extension
					    add edx, eax ;move pointer to the end of make file name
	  			@@:
					    mov al,[ecx]
					    mov [edx],al ;add each byte of extension to make file name
					    inc ecx
					    inc edx
					    test al,al ;if al=0 then all extension copied to make file name
					    jne @B
						;Write to project ini file
						invoke WritePrivateProfileString,SADD('MakeFiles'),addr lpKey,addr lpMakeFile,addr lpRapFile
						pop ecx ;restore numer of characters
						lea edi,lpMakeFile ;prepare fo next make file name
						mov eax,nSize
						mov dword ptr [edi+eax-4],0
						inc ecx
						cmp ecx,9
						ja @F ;If equal to 10 jump
						add byte ptr [lpKey],1
						jmp lbl_back
				@@:
						cmp ecx,10
						ja @F ;If more than 10 finished
						mov word ptr [lpKey],'01'
						jmp lbl_back
				@@:
						
						;======================================
						;Write active file name to project file
						invoke WritePrivateProfileString,SADD('Files'),SADD('1'),addr lpFileName,addr lpRapFile
						
						;Close dialog
						invoke SendMessage,hWin,WM_CLOSE,0,0
						
						;Open project workspace
						call OpenProject
					.endif
				;======================================
				;Cancle button
				.elseif ax == IDC_BTN2 
					invoke SendMessage,hWin,WM_CLOSE,0,0
				.endif
			.endif
		.endif
	;======================================
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,0
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

DlgProc Endp

OpenProject proc
	
	;Open project workspace
	mov eax,[lpDStruct]
	mov edx,(ADDINDATA ptr [eax]).lpFile
	invoke lstrcpy,edx,addr lpRapFile
	push TRUE
	mov eax,[lpPStruct]
	call (ADDINPROCS ptr [eax]).lpOpenProject
	ret

OpenProject endp

CreateProjectFileName proc
	
	;Get new project file name
	mov	esi,[lpDStruct]
	mov	esi,(ADDINDATA ptr [esi]).lpFile ;Get pointer of active file name incl whole path
	lea edi,lpRapFile ;load address of buffer of new project file name
	invoke lstrlen,esi
	mov ecx,eax
	rep movsb ;copy active file name and path to project file name buffer
	mov dword ptr [edi-4],'par.' ;change extension to .rap
	ret

CreateProjectFileName endp

FindRap proc uses edi esi FilePointer:dword 
;	LOCAL FindData:WIN32_FIND_DATA
	
	;File is activated. Make a seach pattern for '*.rap'
	invoke RtlZeroMemory,addr lpRapFile,128 ;Clear buffer
	xor ecx,ecx
	mov esi,FilePointer 
	lea edi,lpRapFile
	invoke lstrlen,FilePointer
	add esi,eax
	push eax
	xor ecx,ecx
@@:
	cmp byte ptr [esi],'\'
	je @F
	dec esi
	inc ecx
	jmp @B
@@:		
	pop eax
	sub eax,ecx
	mov ecx,eax
	inc ecx
	mov esi,FilePointer
	rep movsb ;copy from FilePointer to lpRapFile up to "\"
	push edi
	mov byte ptr [edi],'*' ;Add "*" after "\"
	mov dword ptr[edi+1],'par.' ;Add ".par" after "*" equ to seach pattern.
	
	invoke FindFirstFile,addr lpRapFile,addr FindData
	.if eax==INVALID_HANDLE_VALUE
		;Project file found in folder
		add esp,4 ;adjust for the push edi
		mov eax,FALSE 
	.else
		;Project file found in folder
		invoke FindClose,eax ;Close handle of Find function
		pop eax ;Retrieve pointer to last "\" in lpRapfile string
		mov byte ptr [eax],0 ;terminate with zero
		invoke lstrcat,addr lpRapFile,addr FindData.cFileName ;Add project file name to project path
		mov eax,TRUE  
	.endif
		
	ret

FindRap endp

;======================================
include Sort.asm
