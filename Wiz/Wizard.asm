
.const

IDD_WIZ				equ 150
IDC_BTNBACK			equ 1001
IDC_BTNNEXT			equ 1002

IDD_WIZ1			equ 151

IDD_CBOASSEMBLER	equ 501

IDD_PT1				equ 511
IDD_PT2				equ 512
IDD_PT3				equ 513
IDD_PT4				equ 514
IDD_PT5				equ 515
IDD_PT6				equ 516
IDD_PT7				equ 517
IDD_PT8				equ 518
IDD_PT9				equ 519
IDD_PT10			equ 520
IDD_PT11			equ 521
IDD_PT12			equ 522
IDD_PT13			equ 523
IDD_PT14			equ 524
IDD_PT15			equ 525
IDD_PT16			equ 526

IDD_PN				equ 531
IDD_PD				equ 532
IDD_PF				equ 533
IDD_PFB				equ 534
;IDD_PT				equ 535
;IDD_PTB				equ 536

;**********************

IDD_WIZ2			equ 152

IDC_LSTTPL			equ	2001
IDC_EDTTPL			equ	2002

;**********************

IDD_WIZ3			equ 153

IDD_FIC1			equ 601
IDD_FIC2			equ 602
IDD_FIC3			equ 603
IDD_FIC4			equ 604
IDD_FIC5			equ 605
IDD_FIC6			equ 606
IDD_FIC7			equ 607
IDD_FIC8			equ 608
	
IDD_FOC1			equ 611
IDD_FOC2			equ 612
IDD_FOC3			equ 613
IDD_FOC4			equ 614
IDD_FOC5			equ 615
IDD_FOC6			equ 616
IDD_FOC7			equ 617
IDD_FOC8			equ 618

IMPROW struct
	fCpy		dd ?
	fInc		dd ?
	fMain		dd ?
	lpszName	dd ?
IMPROW ends

IDC_BTNIMP			equ 620

;**********************

IDD_WIZ4			equ 154

IDD_MN1				equ 701
IDD_MN2				equ 702
IDD_MN3				equ 703
IDD_MN4				equ 704
IDD_MN5				equ 705
IDD_MN6				equ 706
IDD_MN7				equ 707
IDD_MN8				equ 708
IDD_MN9				equ 709
IDD_MN10			equ 710
IDD_MN11			equ 711
IDD_MN12			equ 712
IDD_MN13			equ 713
IDD_MN14			equ 714
IDD_MN15			equ 715
IDD_MN16			equ 716

IDD_ASM				equ 721
IDD_RCC				equ 720
IDD_RUN				equ 723
IDD_LNK				equ 722
IDD_TOP				equ 726
IDD_RTO				equ 725
IDD_DBG				equ 724

;**********************

IDD_WIZIMP			equ 155

;**********************

szWiz1				db 'Project Wizard - Type & Name',0
szWiz2				db 'Project Wizard - Template',0
szWiz3				db 'Project Wizard - Files & Folders',0
szWiz4				db 'Project Wizard - Make',0

.data

iniProType			db 'Type',0
iniType				db 32 dup (0)
iniFiles			db 'Files',0
iniFolders			db 'Folders',0
iniBakPath			db '$P\Bak\',0
szResInclude		db '#include',0
szMnuEqu			db 'Mnu=',0
szBmpEqu			db 'Bmp=',0
szTemplateNone		db '(None)',0

psztitle			db ' ',0
caption				db ' ',0

.data?

hWiz				HWND ?
hPsDlg				HWND 4 dup(?)
TplFile				db 64 dup(?)
szAsm				db 64 dup(?)
szAsmIni			db 256 dup(?)
szTpl				db 256 dup(?)
bLine				db 2048 dup(?)
hMemImp				dd ?
fImpSub				dd ?
;nImpCount			dd ?

.code

ProWizFixLine proc uses esi,lpPos:DWORD,lpLine:DWORD,lpFileName:DWORD,lpReplace:DWORD
	LOCAL	buffer[256]:BYTE

	mov		esi,lpPos
	.if lpReplace
		invoke strlen,lpReplace
		add		esi,eax
	.else
	  @@:
		mov		al,[esi]
		or		al,al
		je		@f
		cmp		al,0Dh
		je		@f
		cmp		al,'.'
		je		@f
		inc		esi
		jmp		@b
	.endif
  @@:
	invoke strcpy,addr buffer,esi
	invoke strcpy,lpPos,lpFileName
	invoke strcat,lpLine,addr buffer
	ret

ProWizFixLine endp

ProWizFinish proc uses ebx esi edi
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[256]:BYTE
	LOCAL	buffer2[32]:BYTE
	LOCAL	buffer3[64]:BYTE
	LOCAL	buffer4[64]:BYTE
	LOCAL	hWin:HWND
	LOCAL	ID:DWORD
	LOCAL	hFile:DWORD
	LOCAL	fSize:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	nFun:DWORD
	LOCAL	fPro:DWORD
	LOCAL	fDef:DWORD
	LOCAL	fBin:DWORD
	LOCAL	hWrFile:DWORD

	invoke CloseProject
	.if !eax
		;Create new project folder using project name.
		mov		eax,hPsDlg[0]
		mov		hWin,eax
		invoke GetDlgItemText,hWin,IDD_PF,addr buffer,sizeof buffer
		invoke strlen,addr buffer
		lea		edx,buffer
		add		edx,eax
		dec		edx
		mov		al,[edx]
		.if al!='\'
			mov		ax,'\'
			mov		word ptr buffer1[0],ax
			invoke strcat,addr buffer,addr buffer1
		.endif
		invoke GetDlgItemText,hWin,IDD_PN,addr buffer1,sizeof buffer1
		invoke strlen,addr buffer1
		dec		eax
		.while eax && byte ptr buffer1[eax]==' '
			mov		byte ptr buffer1[eax],0
			dec		eax
		.endw
		invoke strcat,addr buffer,addr buffer1
		invoke CreateDirectory,addr buffer,NULL
		.if eax
			;Get project filename (.rap)
		  CreateTheFolder:
			mov		ax,'\'
			mov		word ptr buffer2[0],ax
			invoke strcat,addr buffer,addr buffer2
			invoke strcpy,addr ProjectPath,addr buffer
			invoke strcat,addr buffer,addr buffer1
			invoke strcat,addr buffer,addr FTRap
			invoke strcpy,addr ProjectFile,addr buffer
			invoke WritePrivateProfileString,addr iniProject,addr iniAssembler,addr szAsm,addr ProjectFile
			;Write project type to project file
			mov		ID,IDD_PT1
			mov		ebx,16
		  @@:
			invoke IsDlgButtonChecked,hWin,ID
			.if eax==BST_CHECKED
				invoke GetDlgItemText,hWin,ID,addr buffer,sizeof buffer
				invoke WritePrivateProfileString,addr iniProject,addr iniProjectType,addr buffer,addr ProjectFile
;				invoke GetPrivateProfileString,addr buffer,addr iniApi,addr iniApi,addr buffer4,sizeof buffer4,addr szAsmIni
;				invoke WritePrivateProfileString,addr iniProject,addr iniApi,addr buffer4,addr ProjectFile
			.endif
			inc		ID
			dec		ebx
			jne		@b
			;Write project description to project file
			invoke GetDlgItemText,hWin,IDD_PD,addr buffer,sizeof buffer
			.if !eax
				invoke GetDlgItemText,hWin,IDD_PN,addr buffer,sizeof buffer
			.endif
			invoke WritePrivateProfileString,addr iniProject,addr iniProjectDescription,addr buffer,addr ProjectFile
			;Write backup path to project file
			invoke WritePrivateProfileString,addr iniProject,addr iniProjectBackup,addr iniBakPath,addr ProjectFile
			;Create selected project folders
			mov		eax,hPsDlg[8]
			mov		hWin,eax
			mov		ID,IDD_FOC1
			mov		ebx,8
		  @@:
			invoke IsDlgButtonChecked,hWin,ID
			.if eax==BST_CHECKED
				invoke GetDlgItemText,hWin,ID,addr buffer2,5
				invoke strcpy,addr FileName,addr ProjectPath
				invoke strcat,addr FileName,addr buffer2
				invoke CreateDirectory,addr FileName,NULL
			.endif
			inc		ID
			dec		ebx
			jne		@b
			;Create selected project files
			;and add them to project
			mov		ID,IDD_FIC1
			mov		eax,hPsDlg[8]
			mov		hWin,eax
			mov		ebx,8
		  @@:
			invoke IsDlgButtonChecked,hWin,ID
			.if eax==BST_CHECKED
				invoke strcpy,addr FileName,addr ProjectPath
				invoke strcat,addr FileName,addr buffer1
				mov		ax,'.'
				mov		word ptr buffer2[0],ax
				invoke strcat,addr FileName,addr buffer2
				invoke GetDlgItemText,hWin,ID,addr buffer2,5
				invoke strcat,addr FileName,addr buffer2
				invoke GetFileAttributes,addr FileName
				.if eax==-1
				  CreateTheFile:
					invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						invoke CloseHandle,eax
						invoke AddProjectFile,addr FileName,FALSE,FALSE
					.else
						invoke strcpy,addr LineTxt,addr SaveFileFail
						invoke strcat,addr LineTxt,addr FileName
						invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
					.endif
				.else
					;File exists
					invoke strcpy,addr tempbuff,addr FileName
					invoke strcat,addr tempbuff,addr szFileErr
					invoke MessageBox,hWin,addr tempbuff,addr AppName,MB_YESNO or MB_ICONERROR or MB_DEFBUTTON2
					.if eax==6
						jmp		CreateTheFile
					.endif
				.endif
			.endif
			inc		ID
			dec		ebx
			jne		@b
			.if hMemImp
				;Import
				mov		edi,hMemImp
				lea		esi,[edi+MAX_PATH]
				lea		ebx,[edi+144*1024]
				.while byte ptr [esi]
					.if dword ptr [esi+MAX_PATH]
						;Copy
						invoke strcpy,addr tempbuff,edi
						invoke strcat,addr tempbuff,addr szBackSlash
						invoke strcat,addr tempbuff,esi
						invoke strcpy,ebx,esi
						invoke strlen,ebx
						lea		ebx,[ebx+eax+1]
						invoke strcpy,addr FileName,addr ProjectPath
						.if dword ptr [esi+MAX_PATH+8]
							;Main
							invoke strlen,addr FileName
							lea		eax,FileName[eax]
							push	eax
							invoke strcat,addr FileName,addr buffer1
							invoke strlen,esi
							.while eax && byte ptr [esi+eax]!='.'
								dec		eax
							.endw
							.if byte ptr [esi+eax]=='.'
								invoke strcat,addr FileName,addr [esi+eax]
							.endif
							pop		eax
							invoke strcpy,ebx,eax
							invoke strlen,ebx
							lea		ebx,[ebx+eax+1]
						.else
							invoke strcat,addr FileName,esi
							invoke strcpy,ebx,esi
							invoke strlen,ebx
							lea		ebx,[ebx+eax+1]
						.endif
						push	ebx
						invoke strlen,addr ProjectPath
						lea		ebx,FileName[eax]
						.while byte ptr [ebx]
							.if byte ptr [ebx]=='\'
								mov		byte ptr [ebx],0
								invoke GetFileAttributes,addr FileName
								.if eax==-1
									invoke CreateDirectory,addr FileName,NULL
								.endif
								mov		byte ptr [ebx],'\'
							.endif
							inc		ebx
						.endw
						pop		ebx
						invoke CopyFile,offset tempbuff,addr FileName,FALSE
						.if dword ptr [esi+MAX_PATH+4]
							;Add
							invoke AddProjectFile,addr FileName,FALSE,FALSE
						.endif
						invoke strcpy,ebx,addr FileName
						invoke strlen,ebx
						lea		ebx,[ebx+eax+1]
					.endif
					lea		esi,[esi+MAX_PATH+4+4+4]
				.endw
			.endif
			;Copy project file ext from ini to project filename.ext
			mov		ebx,0
			mov		edi,offset tempbuff
		  @@:
			invoke BinToDec,ebx,addr buffer2
			invoke GetPrivateProfileString,addr iniMakeFile,addr buffer2,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
			.if eax
				invoke strcpy,edi,addr buffer2
				invoke strlen,edi
				lea		edi,[edi+eax]
				mov		word ptr [edi],'='
				invoke strcat,edi,addr buffer1
				invoke strcat,edi,addr iniBuffer
				invoke strlen,edi
				lea		edi,[edi+eax+1]
				mov		byte ptr [edi],0
			.endif
			inc		ebx
			cmp		ebx,32
			jne		@b
			invoke WritePrivateProfileSection,addr iniMakeFile,addr tempbuff,addr ProjectFile
			;Check if template is used
			.if TplFile
				;Template used
				call	Template
				.if !eax
					mov		ebx,0
				  @@:
					invoke BinToDec,ebx,addr buffer2
					invoke GetPrivateProfileString,addr iniMakeFile,addr buffer2,addr szNULL,addr iniBuffer,128,addr ProjectFile
					.if eax
						;Check if file is main projectfile
						invoke SearchMem,addr iniBuffer,addr buffer3,FALSE,TRUE,FALSE
						.if eax
							;File is main project file. Rename it
							mov		edx,eax
							invoke ProWizFixLine,edx,addr iniBuffer,addr buffer1,addr buffer3
						.endif
						invoke WritePrivateProfileString,addr iniMakeFile,addr buffer2,addr iniBuffer,addr ProjectFile
					.endif
					inc		ebx
					cmp		ebx,32
					jne		@b
				.endif
			.endif
			;Write active make menu items to project file
			mov		eax,hPsDlg[12]
			mov		hWin,eax
			mov		ID,IDD_MN1
			lea		edi,buffer
			mov		ebx,16
		  @@:
			invoke IsDlgButtonChecked,hWin,ID
			.if eax==BST_CHECKED
				mov		eax,'1,'
			.else
				mov		eax,'0,'
			.endif
			mov		[edi],eax
			add		edi,2
			inc		ID
			dec		ebx
			jne		@b
			invoke WritePrivateProfileString,addr iniMakeDef,addr iniMakeDefMenu,addr buffer[1],addr ProjectFile
			;Write make commands to project file
			mov		dword ptr buffer2,'1'
			invoke GetDlgItemText,hWin,IDD_RCC,addr buffer,sizeof buffer
			invoke WritePrivateProfileString,addr iniMakeDef,addr buffer2,addr buffer,addr ProjectFile
			mov		dword ptr buffer2,'2'
			invoke GetDlgItemText,hWin,IDD_ASM,addr buffer,sizeof buffer
			invoke WritePrivateProfileString,addr iniMakeDef,addr buffer2,addr buffer,addr ProjectFile
			mov		dword ptr buffer2,'3'
			invoke GetDlgItemText,hWin,IDD_LNK,addr buffer,sizeof buffer
			invoke WritePrivateProfileString,addr iniMakeDef,addr buffer2,addr buffer,addr ProjectFile
			mov		dword ptr buffer2,'4'
			invoke GetDlgItemText,hWin,IDD_RUN,addr buffer,sizeof buffer
			invoke WritePrivateProfileString,addr iniMakeDef,addr buffer2,addr buffer,addr ProjectFile
			mov		dword ptr buffer2,'5'
			invoke GetDlgItemText,hWin,IDD_RTO,addr buffer,sizeof buffer
			invoke WritePrivateProfileString,addr iniMakeDef,addr buffer2,addr buffer,addr ProjectFile
			mov		dword ptr buffer2,'6'
			invoke GetDlgItemText,hWin,IDD_TOP,addr buffer,sizeof buffer
			invoke WritePrivateProfileString,addr iniMakeDef,addr buffer2,addr buffer,addr ProjectFile
			mov		dword ptr buffer2,'7'
			invoke GetDlgItemText,hWin,IDD_DBG,addr buffer,sizeof buffer
			invoke WritePrivateProfileString,addr iniMakeDef,addr buffer2,addr buffer,addr ProjectFile
			invoke GetPrivateProfileInt,addr iniProject,addr iniProjectGroup,1,addr szAsmIni
			.if eax
				mov		dword ptr buffer2,'1'
			.else
				mov		dword ptr buffer2,'0'
			.endif
			invoke WritePrivateProfileString,addr iniProject,addr iniProjectGroup,addr buffer2,addr ProjectFile
			invoke GetPrivateProfileInt,addr iniProject,addr iniProjectGroupExpand,1,addr szAsmIni
			.if eax
				mov		dword ptr buffer2,'1'
			.else
				mov		dword ptr buffer2,'0'
			.endif
			invoke WritePrivateProfileString,addr iniProject,addr iniProjectGroupExpand,addr buffer2,addr ProjectFile
			;Project created, open it
			invoke strcpy,addr FileName,addr ProjectFile
			invoke strcpy,addr iniAsmFile,addr szAsmIni
			invoke iniReadPaths,NULL
			invoke GetProject
			.if hMemImp
				mov		eax,hMemImp
				lea		eax,[eax+144*1024]
				invoke DllProc,hWnd,AIM_IMPORTED,addr ProjectFile,eax,RAM_IMPORTED
			.endif
			mov		eax,FALSE
		.else
			invoke SetLanguage,hPsDlg[0],IDD_WIZ1,TRUE
			invoke SetLanguage,hPsDlg[4],IDD_WIZ2,TRUE
			invoke SetLanguage,hPsDlg[8],IDD_WIZ3,TRUE
			invoke SetLanguage,hPsDlg[12],IDD_WIZ4,TRUE
			invoke strcpy,addr tempbuff,addr buffer
			invoke GetFileAttributes,addr buffer
			.if eax!=-1
				invoke strcat,addr tempbuff,addr szFolderErr2
				invoke MessageBox,hWin,addr tempbuff,addr AppName,MB_YESNO or MB_ICONERROR or MB_DEFBUTTON2
				.if eax==6
					jmp		CreateTheFolder
				.endif
			.else
				invoke strcat,addr tempbuff,addr szFolderErr1
				invoke MessageBox,hWin,addr tempbuff,addr AppName,MB_OK or MB_ICONERROR
			.endif
			mov		eax,TRUE
		.endif
	.endif
	ret

Template:
	;Get template filename
	invoke strcpy,addr FileName,addr szTpl
	mov		word ptr buffer2[0],'\'
	invoke strcat,addr FileName,addr buffer2
	invoke strcat,addr FileName,addr TplFile
	;Open template file
	invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	.if eax!=INVALID_HANDLE_VALUE
		mov		hFile,eax
		invoke GetFileSize,hFile,NULL
		mov		fSize,eax
		mov		nFun,0
		mov		fPro,0
		mov		fDef,0
		mov		nBytes,0
		mov		dword ptr buffer4,0
		mov		dword ptr prnbuff,0
		lea		esi,tempbuff
		lea		edi,bLine
		;Exstract files and add them to project
		.while fSize || nBytes
			.if !nBytes
				;Fill buffer with template data
				mov		eax,sizeof tempbuff
				mov		nBytes,eax
				push	edi
				invoke ReadFile,hFile,addr tempbuff,nBytes,addr nBytes,NULL
				pop		edi
				mov		eax,nBytes
				sub		fSize,eax
				lea		esi,tempbuff
			.endif
			mov		al,[esi]
			mov		[edi],al
			inc		esi
			inc		edi
			.if al==0Ah
				;End of line
				;Process the line
				push	esi
				mov		byte ptr [edi],0
				.if nFun==0
					;Project type skipped
					inc		nFun
				.elseif nFun==1
					;Old project name
					invoke strcpy,addr buffer3,addr bLine
					invoke strlen,addr buffer3
					lea		edi,buffer3
					add		edi,eax
					sub		edi,2
					mov		byte ptr [edi],0
					inc		nFun
				.elseif nFun==2
					;Wait for [*BEGINPRO*], [*BEGINTXT*] or  [*BEGINBIN*]
					invoke strcmp,addr bLine,addr szBeginPro
					.if eax
						invoke strcmp,addr bLine,addr szBeginTxt
						.if eax
							invoke strcmp,addr bLine,addr szBeginBin
							.if !eax
								;[*BEGINBIN*] Bin file
								mov		fBin,TRUE
								mov		nFun,4
							.endif
						.else
							;[*BEGINTXT*] Txt file
							mov		fBin,FALSE
							mov		nFun,4
						.endif
					.else
						;[*BEGINPRO*] Following is project files
						mov		fPro,TRUE
						inc		nFun
					.endif
				.elseif nFun==3
					;Wait for [*ENDPRO*], [*BEGINDEF*], [*ENDDEF*],  [*BEGINTXT*] or  [*BEGINBIN*]
					invoke strcmp,addr bLine,addr szBeginDef
					.if eax
						invoke strcmp,addr bLine,addr szEndDef
						.if eax
							invoke strcmp,addr bLine,addr szBeginTxt
							.if eax
								invoke strcmp,addr bLine,addr szBeginBin
								.if eax
									invoke strcmp,addr bLine,addr szEndPro
									.if eax
										.if fDef
											mov		al,bLine
											.if al=='['
												mov		al,buffer4
												.if al
													;Save the def to project file
													call SaveDef
												.endif
												mov		eax,offset prnbuff
												mov		fDef,eax
												mov		dword ptr [eax],0
												invoke strlen,addr bLine[1]
												sub		eax,2
												invoke lstrcpyn,addr buffer4,addr bLine[1],eax
											.else
												invoke strlen,addr bLine
												sub		eax,1
												push	eax
												invoke lstrcpyn,fDef,addr bLine,eax
												pop		eax
												add		eax,fDef
												mov		dword ptr [eax],0
												mov		fDef,eax
											.endif
										.endif
									.else
										;[*ENDPRO*] End of project files
										mov		fPro,FALSE
									.endif
								.else
									;Bin file
									mov		fBin,TRUE
									inc		nFun
								.endif
							.else
								;Txt file
								mov		fBin,FALSE
								inc		nFun
							.endif
						.else
							;End def
							mov		al,buffer4
							.if al
								;Save the def to project file
								call SaveDef
							.endif
							mov		fDef,FALSE
						.endif
					.else
						;Begin def
						mov		eax,offset prnbuff
						mov		fDef,eax
					.endif
				.elseif nFun==4
					;File name
				  FnNxt:
					invoke SearchMem,addr bLine,addr szProjectName,TRUE,FALSE,FALSE
					.if eax
						mov		esi,eax
						invoke ProWizFixLine,esi,addr bLine,addr buffer1,addr szProjectName
						jmp		FnNxt
					.endif
					.if fPro
						;Check if file is main projectfile
						invoke SearchMem,addr bLine,addr buffer3,FALSE,TRUE,FALSE
						.if eax
							;File is main project file. Rename the file
							mov		esi,eax
							invoke ProWizFixLine,esi,addr bLine,addr buffer1,addr buffer3
						.endif
					.else
						;Check if file is main Dlg Rc file
						mov		eax,'glD'
						mov		dword ptr buffer2,eax
						invoke strcpy,addr buffer,addr buffer3
						invoke strcat,addr buffer,addr buffer2
						invoke SearchMem,addr bLine,addr buffer,FALSE,TRUE,FALSE
						.if eax
							;File is main Dlg Rc file. Rename it
							push	eax
							invoke strcpy,addr buffer,addr buffer1
							invoke strcat,addr buffer,addr buffer2
							pop		esi
							invoke ProWizFixLine,esi,addr bLine,addr buffer,NULL
						.else
							;Check if file is main Mnu Rc file
							mov		eax,'unM'
							mov		dword ptr buffer2,eax
							invoke strcpy,addr buffer,addr buffer3
							invoke strcat,addr buffer,addr buffer2
							invoke SearchMem,addr bLine,addr buffer,FALSE,TRUE,FALSE
							.if eax
								;File is main Mnu Rc file. Rename it
								push	eax
								invoke strcpy,addr buffer,addr buffer1
								invoke strcat,addr buffer,addr buffer2
								pop		esi
								invoke ProWizFixLine,esi,addr bLine,addr buffer,NULL
							.else
								;Check if file is main Res Rc file
								mov		eax,'seR'
								mov		dword ptr buffer2,eax
								invoke strcpy,addr buffer,addr buffer3
								invoke strcat,addr buffer,addr buffer2
								invoke SearchMem,addr bLine,addr buffer,FALSE,TRUE,FALSE
								.if eax
									;File is main Res Rc file. Rename it
									push	eax
									invoke strcpy,addr buffer,addr buffer1
									invoke strcat,addr buffer,addr buffer2
									pop		esi
									invoke ProWizFixLine,esi,addr bLine,addr buffer,NULL
								.else
									;Check if file is main Str Rc file
									mov		eax,'rtS'
									mov		dword ptr buffer2,eax
									invoke strcpy,addr buffer,addr buffer3
									invoke strcat,addr buffer,addr buffer2
									invoke SearchMem,addr bLine,addr buffer,FALSE,TRUE,FALSE
									.if eax
										;File is main Str Rc file. Rename it
										push	eax
										invoke strcpy,addr buffer,addr buffer1
										invoke strcat,addr buffer,addr buffer2
										pop		esi
										invoke ProWizFixLine,esi,addr bLine,addr buffer,NULL
									.else
										;Check if file is main Ver Rc file
										mov		eax,'reV'
										mov		dword ptr buffer2,eax
										invoke strcpy,addr buffer,addr buffer3
										invoke strcat,addr buffer,addr buffer2
										invoke SearchMem,addr bLine,addr buffer,FALSE,TRUE,FALSE
										.if eax
											;File is main Ver Rc file. Rename it
											push	eax
											invoke strcpy,addr buffer,addr buffer1
											invoke strcat,addr buffer,addr buffer2
											pop		esi
											invoke ProWizFixLine,esi,addr bLine,addr buffer,NULL
										.else
											;Check if file is main Acl Rc file
											mov		eax,'lcA'
											mov		dword ptr buffer2,eax
											invoke strcpy,addr buffer,addr buffer3
											invoke strcat,addr buffer,addr buffer2
											invoke SearchMem,addr bLine,addr buffer,FALSE,TRUE,FALSE
											.if eax
												;File is main Acl Rc file. Rename it
												push	eax
												invoke strcpy,addr buffer,addr buffer1
												invoke strcat,addr buffer,addr buffer2
												pop		esi
												invoke ProWizFixLine,esi,addr bLine,addr buffer,NULL
											.else
												;Check if file is main Lng Rc file
												mov		eax,'gnL'
												mov		dword ptr buffer2,eax
												invoke strcpy,addr buffer,addr buffer3
												invoke strcat,addr buffer,addr buffer2
												invoke SearchMem,addr bLine,addr buffer,FALSE,TRUE,FALSE
												.if eax
													;File is main Lng Rc file. Rename it
													push	eax
													invoke strcpy,addr buffer,addr buffer1
													invoke strcat,addr buffer,addr buffer2
													pop		esi
													invoke ProWizFixLine,esi,addr bLine,addr buffer,NULL
												.endif
											.endif
										.endif
									.endif
								.endif
							.endif
						.endif
					.endif
					invoke strlen,addr bLine
					lea		edi,bLine
					add		edi,eax
					sub		edi,2
					mov		byte ptr [edi],0
					invoke strcpy,addr FileName,addr ProjectPath
					invoke strlen,addr FileName
					mov		edi,offset FileName
					add		edi,eax
					lea		esi,bLine
				  @@:
					mov		al,[esi]
					cmp		al,'\'
					jne		Nxt
					;Create folder
					mov		byte ptr [edi],0
					push	esi
					push	edi
					invoke CreateDirectory,addr FileName,NULL
					pop		edi
					pop		esi
					mov		al,'\'
				  Nxt:
					mov		[edi],al
					inc		esi
					inc		edi
					or		al,al
					jne		@b
					invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						mov		hWrFile,eax
						.if fPro
							;Add to project
							invoke AddProjectFile,addr FileName,FALSE,FALSE
						.endif
					.else
						invoke strcpy,addr LineTxt,addr SaveFileFail
						invoke strcat,addr LineTxt,addr FileName
						invoke MessageBox,NULL,addr LineTxt,addr AppName,MB_OK or MB_ICONERROR
					.endif
					inc		nFun
				.elseif nFun==5
					;Line, [*ENDTXT*] or  [*ENDBIN*]
					invoke strcmp,addr bLine,addr szEndTxt
					.if eax
						invoke strcmp,addr bLine,addr szEndBin
						.if !eax
							;Close file
							invoke CloseHandle,hWrFile
							invoke GetFileImg,offset FileName
							.if eax==5
								;Dlg file
								invoke CreateFile,addr FileName,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
								mov		hWrFile,eax
								invoke ReadFile,hWrFile,addr prnbuff,sizeof DLGHEAD,addr nFun,NULL
								invoke CloseHandle,hWrFile
								push	esi
								mov		esi,offset prnbuff
								lea		esi,[esi].DLGHEAD.menuid
								;Check if file is main projectfile
								invoke SearchMem,esi,addr buffer3,FALSE,TRUE,FALSE
								.if eax
									;File is main project file. Rename it
									mov		edx,eax
									invoke ProWizFixLine,edx,esi,addr buffer1,addr buffer3
									invoke CreateFile,addr FileName,GENERIC_WRITE,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
									mov		hWrFile,eax
									invoke WriteFile,hWrFile,addr prnbuff,sizeof DLGHEAD,addr nFun,NULL
									invoke CloseHandle,hWrFile
								.endif
								pop		esi
							.endif
							mov		hWrFile,0
							mov		nFun,3
						.else
							;Write line
							push	nBytes
							.if fBin
								;Bin file
								lea		esi,bLine
								lea		edi,buffer2
								mov		nBytes,0
							  @@:
								mov		al,[esi]
								cmp		al,0Dh
								je		@f
								inc		esi
								.if al>='A'
									sub		al,'A'-10
								.else
									sub		al,'0'
								.endif
								mov		ah,al
								mov		al,[esi]
								inc		esi
								.if al>='A'
									sub		al,'A'-10
								.else
									sub		al,'0'
								.endif
								shl		ah,4
								add		ah,al
								mov		[edi],ah
								inc		edi
								inc		nBytes
								jmp		@b
							  @@:
								invoke WriteFile,hWrFile,addr buffer2,nBytes,addr nBytes,NULL
							.else
								;Txt file
							  @@:
								invoke SearchMem,addr bLine,addr szProjectName,TRUE,FALSE,FALSE
								.if eax
									mov		esi,eax
									invoke ProWizFixLine,esi,addr bLine,addr buffer1,addr szProjectName
									jmp		@b
								.endif
								invoke SearchMem,addr bLine,addr szInclude,FALSE,TRUE,FALSE
								.if !eax
									;.def file
									invoke SearchMem,addr bLine,addr szLibrary,FALSE,TRUE,FALSE
									.if !eax
										invoke SearchMem,addr bLine,addr szResInclude,FALSE,TRUE,FALSE
										.if !eax
											;.tbr file
											invoke SearchMem,addr bLine,addr szMnuEqu,FALSE,FALSE,FALSE
											.if !eax
												invoke SearchMem,addr bLine,addr szBmpEqu,FALSE,FALSE,FALSE
												.if !eax
													invoke SearchMem,addr bLine,addr buffer3,FALSE,TRUE,FALSE
												.endif
											.endif
										.endif
									.endif
								.endif
								.if eax
									lea		esi,bLine
								  @@:
									invoke SearchMem,esi,addr buffer3,FALSE,FALSE,FALSE
									.if eax
										mov		esi,eax
										invoke ProWizFixLine,esi,addr bLine,addr buffer1,addr buffer3
										invoke strlen,addr buffer3
										add		esi,eax
										jmp		@b
									.else
										invoke strcpy,addr buffer,addr buffer3
										mov		eax,'glD'
										mov		dword ptr buffer2,eax
										invoke strcat,addr buffer,addr buffer2
										invoke SearchMem,addr bLine,addr buffer,FALSE,TRUE,FALSE
										.if eax
											push	eax
											invoke strcpy,addr buffer,addr buffer1
											invoke strcat,addr buffer,addr buffer2
											pop		esi
											invoke ProWizFixLine,esi,addr bLine,addr buffer,NULL
										.else
											invoke strcpy,addr buffer,addr buffer3
											mov		eax,'unM'
											mov		dword ptr buffer2,eax
											invoke strcat,addr buffer,addr buffer2
											invoke SearchMem,addr bLine,addr buffer,FALSE,TRUE,FALSE
											.if eax
												push	eax
												invoke strcpy,addr buffer,addr buffer1
												invoke strcat,addr buffer,addr buffer2
												pop		esi
												invoke ProWizFixLine,esi,addr bLine,addr buffer,NULL
											.endif
										.endif
									.endif
								.endif
								invoke strlen,addr bLine
								mov		nBytes,eax
								invoke WriteFile,hWrFile,addr bLine,nBytes,addr nBytes,NULL
							.endif
							pop		nBytes
						.endif
					.else
						;Close file
						invoke CloseHandle,hWrFile
						mov		hWrFile,0
						mov		nFun,3
					.endif
				.endif
				pop		esi
				lea		edi,bLine
			.endif
			dec		nBytes
		.endw
		invoke CloseHandle,hFile
		xor		eax,eax
	.endif
	retn

SaveDef:
	invoke WritePrivateProfileSection,addr buffer4,addr prnbuff,addr ProjectFile
	retn

ProWizFinish endp

SetParentCaption proc hWin:HWND
	LOCAL	buffer[128]:BYTE

	.if fNT
		invoke GetWindowTextW,hWin,addr buffer,sizeof buffer/2
		invoke GetParent,hWin
		mov		edx,eax
		invoke SetWindowTextW,edx,addr buffer
	.else
		invoke GetWindowText,hWin,addr buffer,sizeof buffer/2
		invoke GetParent,hWin
		mov		edx,eax
		invoke SetWindowText,edx,addr buffer
	.endif
	ret

SetParentCaption endp

DialogFunc1 proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	;This dialog processes property page 1
	LOCAL	buffer[128]:BYTE
	LOCAL	ID:DWORD
	LOCAL	nInx:DWORD

	mov		eax,uMsg
	.if	eax==WM_NOTIFY
		mov	ebx,lParam
		mov	eax,NMHDR.code[ebx]
		.if eax==PSN_SETACTIVE			; page gaining focus
			invoke SetParentCaption,hWin
			invoke GetDlgItemText,hWin,IDD_PN,addr buffer,128
;			.if eax
;				invoke GetDlgItemText,hWin,IDD_PD,addr buffer,128
;				.if eax
;					invoke PostMessage,hWiz,PSM_SETWIZBUTTONS,0,PSWIZB_NEXT
;				.else
;					invoke PostMessage,hWiz,PSM_SETWIZBUTTONS,0,0
;				.endif
;			.else
;				invoke PostMessage,hWiz,PSM_SETWIZBUTTONS,0,0
;			.endif
			.if eax
				mov		eax,PSWIZB_NEXT
			.endif
			xor		edx,edx
			invoke PostMessage,hWiz,PSM_SETWIZBUTTONS,edx,eax
		.endif
	.elseif eax==WM_COMMAND
		mov 	eax,wParam
		mov		edx,eax
		shr		edx,16
		and		eax,0FFFFh
		.if eax==IDD_CBOASSEMBLER && edx==CBN_SELCHANGE
			call SetIni
		.elseif eax>=IDD_PT1 && eax<=IDD_PT16
			invoke GetDlgItemText,hWin,eax,addr iniType,31
			invoke SendMessage,hPsDlg[4],WM_INITDIALOG,0,TRUE
			invoke SendMessage,hPsDlg[8],WM_INITDIALOG,0,0
			invoke SendMessage,hPsDlg[12],WM_INITDIALOG,0,0
		.elseif eax==IDD_PN || eax==IDD_PD
			mov		eax,wParam
			shr		eax,16
			.if eax==EN_CHANGE
;				invoke GetDlgItemText,hWin,IDD_PN,addr buffer,128
;				.if eax
;					invoke GetDlgItemText,hWin,IDD_PD,addr buffer,128
;					.if eax
;						invoke SendMessage,hWiz,PSM_SETWIZBUTTONS,0,PSWIZB_NEXT
;					.else
;						invoke SendMessage,hWiz,PSM_SETWIZBUTTONS,0,0
;					.endif
;				.else
;
;					invoke SendMessage,hWiz,PSM_SETWIZBUTTONS,0,0
;				.endif
				invoke GetDlgItemText,hWin,IDD_PN,addr buffer,128
				.if eax
					mov		eax,PSWIZB_NEXT
				.endif
				xor		edx,edx
				invoke PostMessage,hWiz,PSM_SETWIZBUTTONS,edx,eax
			.endif
		.elseif eax==IDD_PFB
			invoke BrowseFolder,hWin,IDD_PF
		.endif
	.elseif eax==WM_INITDIALOG
		m2m		hPsDlg[0],hWin
		invoke GetPrivateProfileString,addr iniAssembler,addr iniAssembler,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniFile
	  @@:
		invoke iniGetItem,addr iniBuffer,addr buffer
		.if buffer
			invoke SendDlgItemMessage,hWin,IDD_CBOASSEMBLER,CB_ADDSTRING,0,addr buffer
			mov		ebx,eax
			invoke strcmpi,addr buffer,addr szAssembler
			.if !eax
				mov		nInx,ebx
			.endif
			jmp		@b
		.endif
		invoke SendDlgItemMessage,hWin,IDD_CBOASSEMBLER,CB_SETCURSEL,nInx,0
		invoke GetDlgItem,hWin,IDD_PN
		invoke SendMessage,eax,EM_LIMITTEXT,16,0
		invoke GetDlgItem,hWin,IDD_PD
		invoke SendMessage,eax,EM_LIMITTEXT,127,0
		call SetIni
	.else
		return FALSE
	.endif
	return TRUE

SetIni:
	invoke GetDlgItemText,hWin,IDD_CBOASSEMBLER,addr szAsm,31
	invoke strcpy,addr szAsmIni,addr AppPath
	invoke strcat,addr szAsmIni,addr szBackSlash
	invoke strcat,addr szAsmIni,addr szAsm
	invoke strcat,addr szAsmIni,addr FTIni
	call SetTpe
	retn

SetTpe:
	invoke GetPrivateProfileString,addr iniProject,addr iniProType,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
	mov		ID,IDD_PT1
	mov		ebx,16
  @@:
	invoke iniGetItem,addr iniBuffer,addr buffer
	.if buffer
		invoke GetDlgItem,hWin,ID
		invoke ShowWindow,eax,SW_SHOW
		invoke SetDlgItemText,hWin,ID,addr buffer
	.else
		invoke GetDlgItem,hWin,ID
		invoke ShowWindow,eax,SW_HIDE
	.endif
	inc		ID
	dec		ebx
	jne		@b
	invoke CheckRadioButton,hWin,IDD_PT1,IDD_PT16,IDD_PT1
	invoke GetDlgItemText,hWin,IDD_PT1,addr iniType,31
	invoke GetPrivateProfileString,addr iniPaths,addr iniFolderP,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
	invoke iniPathFix,addr iniBuffer
	invoke SetDlgItemText,hWin,IDD_PF,addr iniBuffer
	invoke GetDlgItemText,hWin,IDD_PT1,addr iniType,31
	invoke SendMessage,hPsDlg[4],WM_INITDIALOG,0,TRUE
	invoke SendMessage,hPsDlg[8],WM_INITDIALOG,0,0
	invoke SendMessage,hPsDlg[12],WM_INITDIALOG,0,0
	retn

DialogFunc1 endp

DialogFunc2 proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This dialog processes property page 2
	LOCAL	buffer[256]:BYTE
	LOCAL	hwfd:DWORD
	LOCAL	hFile:DWORD
	LOCAL	nBytes:DWORD
	LOCAL	buffer1[3000]:BYTE

	mov	eax,uMsg
	.if	eax==WM_NOTIFY
		mov		ebx,lParam
		mov		eax,NMHDR.code[ebx]
		.if eax==PSN_SETACTIVE			; page gaining focus
			invoke SetParentCaption,hWin
			invoke PostMessage,hWiz,PSM_SETWIZBUTTONS,0,PSWIZB_NEXT or PSWIZB_BACK
		.endif
	.elseif eax==WM_INITDIALOG
		m2m		hPsDlg[4],hWin
		.if lParam
			invoke SendDlgItemMessage,hWin,IDC_LSTTPL,LB_RESETCONTENT,0,0
			invoke SendDlgItemMessage,hWin,IDC_LSTTPL,LB_ADDSTRING,0,offset szTemplateNone
			invoke GetPrivateProfileString,addr iniPaths,addr iniFolderT,addr szNULL,addr buffer,sizeof buffer,addr szAsmIni
			invoke iniPathFix,addr buffer
			invoke strcpy,addr szTpl,addr buffer
			invoke strlen,addr buffer
			lea		esi,buffer
			add		esi,eax
			mov		eax,'t.*\'
			mov		[esi],eax
			add		esi,4
			mov		eax,'lp'
			mov		[esi],eax
			invoke FindFirstFile,addr buffer,addr wfd
			.if eax!=INVALID_HANDLE_VALUE
				mov		hwfd,eax
			  Nx:
				invoke strcpy,addr buffer1,addr szTpl
				invoke strlen,addr buffer1
				lea		esi,buffer1
				add		esi,eax
				mov		eax,'\'
				mov		[esi],eax
				invoke strcat,addr buffer1,addr wfd.cFileName
				invoke CreateFile,addr buffer1,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
				.if eax!=INVALID_HANDLE_VALUE
					mov		hFile,eax
					invoke RtlZeroMemory,addr buffer1,sizeof buffer1
					invoke ReadFile,hFile,addr buffer1,64,addr nBytes,NULL
					invoke CloseHandle,hFile
					lea		esi,buffer1
					dec		esi
				  @@:
					inc		esi
					mov		al,[esi]
					cmp		al,0Dh
					jne		@b
					mov		al,0
					mov		[esi],al
					invoke lstrcmpi,addr buffer1,addr iniType
					.if !eax
						invoke SendDlgItemMessage,hWin,IDC_LSTTPL,LB_ADDSTRING,0,addr wfd.cFileName
					.endif
				.endif
				invoke FindNextFile,hwfd,addr wfd
				or		eax,eax
				jne		Nx
				invoke FindClose,hwfd
				invoke SendDlgItemMessage,hWin,IDC_LSTTPL,LB_GETCOUNT,0,0
				.if eax
					invoke SendDlgItemMessage,hWin,IDC_LSTTPL,LB_SETCURSEL,0,0
					mov		eax,(LBN_SELCHANGE shl 16) or IDC_LSTTPL
					invoke SendMessage,hWin,WM_COMMAND,eax,0
				.endif
			.endif
		.endif
	.elseif eax==WM_COMMAND
		mov		eax,wParam
		shr		eax,16
		.if eax==LBN_SELCHANGE
			mov		eax,wParam
			movzx	eax,ax
			.if eax==IDC_LSTTPL
				mov		TplFile,0
				invoke SetDlgItemText,hWin,IDC_EDTTPL,addr szNULL
				invoke strcpy,addr buffer1,addr szTpl
				invoke strlen,addr buffer1
				lea		esi,buffer1
				add		esi,eax
				mov		eax,'\'
				mov		[esi],eax
				inc		esi
				invoke SendDlgItemMessage,hWin,IDC_LSTTPL,LB_GETCURSEL,0,0
				.if eax
					invoke SendDlgItemMessage,hWin,IDC_LSTTPL,LB_GETTEXT,eax,esi
					invoke strcpy,addr TplFile,esi
					invoke CreateFile,addr buffer1,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
					.if eax!=INVALID_HANDLE_VALUE
						mov		hFile,eax
						invoke RtlZeroMemory,addr buffer1,sizeof buffer1
						invoke ReadFile,hFile,addr buffer1,sizeof buffer1,addr nBytes,NULL
						invoke CloseHandle,hFile
						lea		esi,buffer1
						dec		esi
					  @@:
						inc		esi
						mov		al,[esi]
						cmp		al,0Ah
						jne		@b
					  @@:
						inc		esi
						mov		al,[esi]
						cmp		al,0Ah
						jne		@b
						inc		esi
						invoke iniInStr,esi,addr szBeginPro
						.if eax
							push	esi
							add		esi,eax
							mov		al,0
							mov		[esi],al
							pop		esi
						.endif
						invoke SetDlgItemText,hWin,IDC_EDTTPL,esi
					.endif
				.endif
			.endif
			invoke SendMessage,hPsDlg[12],WM_INITDIALOG,0,0
		.elseif eax==LBN_DBLCLK
			invoke SendMessage,hWiz,WM_COMMAND,IDC_BTNNEXT,0
		.endif
	.else
		return FALSE
	.endif
	return TRUE

DialogFunc2	endp

ImpDir proc hGrd:HWND,lpPth:DWORD,nPthLen:DWORD
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	hwfd:DWORD
	LOCAL	row:IMPROW

	;Make the path local
	invoke strcpy,addr buffer,lpPth
	;Check if path ends with '\'. If not add.
	invoke strlen,addr buffer
	dec		eax
	mov		al,buffer[eax]
	.if al!='\'
		invoke strcat,addr buffer,addr szBackSlash
	.endif
	;Add '*.*'
	invoke strcat,addr buffer,addr szAPA
	;Find first match, if any
	invoke FindFirstFile,addr buffer,addr wfd
	.if eax!=INVALID_HANDLE_VALUE
		;Save returned handle
		mov		hwfd,eax
	  Next:
		;Check if found is a dir
		mov		eax,wfd.dwFileAttributes
		and		eax,FILE_ATTRIBUTE_DIRECTORY
		.if eax
			;Do not include '.' and '..'
			mov		al,wfd.cFileName
			.if al!='.' && fImpSub
				invoke strlen,addr buffer
				mov		edx,eax
				push	edx
				sub		edx,3
				;Do not remove the '\'
				mov		al,buffer[edx]
				.if al=='\'
					inc		edx
				.endif
				;Add new dir to path
				invoke strcpy,addr buffer[edx],addr wfd.cFileName
				;Call myself again, thats recursive!
				invoke ImpDir,hGrd,addr buffer,nPthLen
				pop		edx
				;Remove what was added
				mov		buffer[edx],0
			.endif
		.else
			;Add file
			invoke SendMessage,hGrd,GM_GETROWCOUNT,0,0
			;Max 500 files
			cmp		eax,500
			jge		Done
			mov		row.fCpy,0
			mov		row.fInc,0
			mov		row.fMain,0
			invoke strcpy,addr tempbuff,addr buffer
			invoke strlen,addr tempbuff
			lea		edx,[eax-3]
			invoke strcpy,addr tempbuff[edx],addr wfd.cFileName
			mov		eax,nPthLen
			lea		eax,tempbuff[eax+1]
			mov		row.lpszName,eax
			invoke SendMessage,hGrd,GM_ADDROW,0,addr row
		.endif
		;Any more matches?
		invoke FindNextFile,hwfd,addr wfd
		or		eax,eax
		jne		Next
		;No more matches, close find
	  Done:
		invoke FindClose,hwfd
	.endif
	ret

ImpDir endp

WizImpProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	hGrd:HWND
	LOCAL	col:COLUMN
	LOCAL	buffer[MAX_PATH]:BYTE
	LOCAL	row:IMPROW
	LOCAL	nRows:DWORD

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetLanguage,hWin,IDD_WIZIMP,FALSE
		invoke GetDlgItem,hWin,1001
		mov		hGrd,eax
		invoke SendMessage,hGrd,GM_SETBACKCOLOR,radcol.project,0
		invoke SendMessage,hGrd,GM_SETGRIDCOLOR,808080h,0
		invoke SendMessage,hGrd,GM_SETTEXTCOLOR,radcol.projecttext,0
		;Add Copy column
		invoke CalcSize,48
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szImpCpy
		mov		col.halign,ALIGN_CENTER
		mov		col.calign,ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Add Add file column
		invoke CalcSize,48
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szImpAdd
		mov		col.halign,ALIGN_CENTER
		mov		col.calign,ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Add Main file column
		invoke CalcSize,48
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szImpMain
		mov		col.halign,ALIGN_CENTER
		mov		col.calign,ALIGN_CENTER
		mov		col.ctype,TYPE_CHECKBOX
		mov		col.ctextmax,0
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		;Add File column
		invoke CalcSize,170
		mov		col.colwt,eax
		mov		col.lpszhdrtext,offset szImpFile
		mov		col.halign,ALIGN_LEFT
		mov		col.calign,ALIGN_LEFT
		mov		col.ctype,TYPE_EDITTEXT
		mov		col.ctextmax,63
		mov		col.lpszformat,0
		mov		col.himl,0
		mov		col.hdrflag,0
		invoke SendMessage,hGrd,GM_ADDCOL,0,addr col
		.if hMemImp
			push	esi
			mov		esi,hMemImp
			invoke SetDlgItemText,hWin,1003,esi
			add		esi,MAX_PATH
			.while byte ptr [esi]
				mov		eax,[esi+MAX_PATH]
				mov		row.fCpy,eax
				mov		eax,[esi+MAX_PATH+4]
				mov		row.fInc,eax
				mov		eax,[esi+MAX_PATH+8]
				mov		row.fMain,eax
				mov		row.lpszName,esi
				invoke SendMessage,hGrd,GM_ADDROW,0,addr row
				add		esi,MAX_PATH+4+4+4
			.endw
			pop		esi
			invoke GlobalFree,hMemImp
			mov		hMemImp,0
		.endif
		invoke CheckDlgButton,hWin,1004,fImpSub
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==1
				invoke GetDlgItem,hWin,1001
				mov		hGrd,eax
				invoke xGlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,256*1024
				mov		hMemImp,eax
				push	esi
				mov		esi,hMemImp
				invoke GetDlgItemText,hWin,1003,esi,MAX_PATH
				add		esi,MAX_PATH
				invoke SendMessage,hGrd,GM_GETROWCOUNT,0,0
				mov		nRows,eax
				push	ebx
				xor		ebx,ebx
				.while ebx<nRows
					;File name
					mov		ecx,ebx
					shl		ecx,16
					add		ecx,3
					invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,esi
					add		esi,MAX_PATH
					;Copy
					mov		ecx,ebx
					shl		ecx,16
					invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,esi
					add		esi,4
					;Include
					mov		ecx,ebx
					shl		ecx,16
					add		ecx,1
					invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,esi
					add		esi,4
					;Main
					mov		ecx,ebx
					shl		ecx,16
					add		ecx,2
					invoke SendMessage,hGrd,GM_GETCELLDATA,ecx,esi
					add		esi,4
					inc		ebx
				.endw
				pop		ebx
				pop		esi
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==2
				invoke SendMessage,hWin,WM_CLOSE,0,0
			.elseif eax==1002
				invoke BrowseFolder,hWin,1003
				.if eax
					invoke GetDlgItemText,hWin,1003,addr buffer,sizeof buffer
					invoke strlen,addr buffer
					push	eax
					invoke GetDlgItem,hWin,1001
					push	eax
					invoke SendMessage,eax,GM_RESETCONTENT,0,0
					pop		edx
					pop		eax
					.if eax==3
						dec		eax
					.endif
					invoke ImpDir,edx,addr buffer,eax
				.endif
			.elseif eax==1004
				invoke IsDlgButtonChecked,hWin,1004
				mov		fImpSub,eax
				invoke GetDlgItem,hWin,1001
				invoke SendMessage,eax,GM_GETROWCOUNT,0,0
				.if eax
					invoke GetDlgItemText,hWin,1003,addr buffer,sizeof buffer
					invoke strlen,addr buffer
					push	eax
					invoke GetDlgItem,hWin,1001
					push	eax
					invoke SendMessage,eax,GM_RESETCONTENT,0,0
					pop		edx
					pop		eax
					.if eax==3
						dec		eax
					.endif
					invoke ImpDir,edx,addr buffer,eax
				.endif
			.endif
		.elseif edx==EN_CHANGE
			.if eax==1003
				invoke SendDlgItemMessage,hWin,1001,GM_RESETCONTENT,0,0
			.endif
		.endif
	.elseif eax==WM_NOTIFY
		push	esi
		mov		esi,lParam
		mov		eax,[esi].NMHDR.hwndFrom
		.if [esi].NMHDR.idFrom==1001
			mov		eax,[esi].NMHDR.code
			.if [esi].GRIDNOTIFY.col==3 && eax==GN_BEFOREEDIT
				mov		[esi].GRIDNOTIFY.fcancel,TRUE
			.endif
		.endif
		pop		esi
	.elseif eax==WM_CLOSE
		invoke EndDialog,hWin,NULL
	.else
		return FALSE
	.endif
	return TRUE

WizImpProc endp

DialogFunc3 proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This dialog processes property page 3
	LOCAL	buffer[128]:BYTE
	LOCAL	buffer1[128]:BYTE
	LOCAL	ID:DWORD

	mov	eax,uMsg
	.if	eax==WM_NOTIFY
		mov		ebx,lParam
		mov		eax,NMHDR.code[ebx]
		.if eax==PSN_SETACTIVE			; page gaining focus
			invoke SetParentCaption,hWin
			invoke PostMessage,hWiz,PSM_SETWIZBUTTONS,0,PSWIZB_NEXT or PSWIZB_BACK
		.endif
	.elseif eax==WM_COMMAND
		.if wParam==IDC_BTNIMP
			invoke ModalDialog,hInstance,IDD_WIZIMP,hWin,addr WizImpProc,0
		.endif
	.elseif eax==WM_INITDIALOG
		m2m		hPsDlg[8],hWin
		invoke GetPrivateProfileString,addr iniProject,addr iniFiles,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
		invoke GetPrivateProfileString,addr iniType,addr iniFiles,addr szNULL,addr buffer,sizeof buffer,addr szAsmIni
		mov		ID,IDD_FIC1
		mov		ebx,8
	  @@:
		invoke iniGetItem,addr iniBuffer,addr buffer1
		.if buffer1
			invoke GetDlgItem,hWin,ID
			invoke ShowWindow,eax,SW_SHOW
			invoke SetDlgItemText,hWin,ID,addr buffer1
			invoke iniGetItem,addr buffer,addr buffer1
			.if buffer1=='1'
				invoke CheckDlgButton,hWin,ID,BST_CHECKED
			.else
				invoke CheckDlgButton,hWin,ID,BST_UNCHECKED
			.endif
		.else
			invoke GetDlgItem,hWin,ID
			invoke ShowWindow,eax,SW_HIDE
			invoke CheckDlgButton,hWin,ID,BST_UNCHECKED
		.endif
		inc		ID
		dec		ebx
		jnz		@b
		invoke GetPrivateProfileString,addr iniProject,addr iniFolders,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
		invoke GetPrivateProfileString,addr iniType,addr iniFolders,addr szNULL,addr buffer,sizeof buffer,addr szAsmIni
		mov		ID,IDD_FOC1
		mov		ebx,8
	  @@:
		invoke iniGetItem,addr iniBuffer,addr buffer1
		.if buffer1
			invoke GetDlgItem,hWin,ID
			invoke ShowWindow,eax,SW_SHOW
			invoke SetDlgItemText,hWin,ID,addr buffer1
			invoke iniGetItem,addr buffer,addr buffer1
			.if buffer1=='1'
				invoke CheckDlgButton,hWin,ID,BST_CHECKED
			.else
				invoke CheckDlgButton,hWin,ID,BST_UNCHECKED
			.endif
		.else
			invoke GetDlgItem,hWin,ID
			invoke ShowWindow,eax,SW_HIDE
			invoke CheckDlgButton,hWin,ID,BST_UNCHECKED
		.endif
		inc		ID
		dec		ebx
		jnz		@b
	.else
		return FALSE
	.endif
	return TRUE

DialogFunc3	endp

InitDialog4 proc hWin:HWND,lpIni:DWORD,lpType:DWORD
	LOCAL	buffer[256]:BYTE
	LOCAL	buffer1[128]:BYTE
	LOCAL	ID:DWORD

	invoke GetPrivateProfileString,lpType,addr iniMakeDefMenu,addr szNULL,addr iniBuffer,sizeof iniBuffer,lpIni
	.if !eax
		invoke GetPrivateProfileString,lpType,addr iniMenuMake,addr szNULL,addr iniBuffer,sizeof iniBuffer,lpIni
	.endif
	invoke GetPrivateProfileString,addr iniProject,addr iniMenuMake,addr szNULL,addr buffer,sizeof buffer,offset szAsmIni
	mov		ID,IDD_MN1
	mov		ebx,16
  @@:
	invoke iniGetItem,addr buffer,addr buffer1
	.if buffer1
		invoke GetDlgItem,hWin,ID
		invoke ShowWindow,eax,SW_SHOW
		invoke SetDlgItemText,hWin,ID,addr buffer1
		invoke iniGetItem,addr iniBuffer,addr buffer1
		.if buffer1=='1'
			invoke CheckDlgButton,hWin,ID,BST_CHECKED
		.else
			invoke CheckDlgButton,hWin,ID,BST_UNCHECKED
		.endif
	.else
		invoke iniGetItem,addr iniBuffer,addr buffer1
		invoke GetDlgItem,hWin,ID
		invoke ShowWindow,eax,SW_HIDE
		invoke CheckDlgButton,hWin,ID,BST_UNCHECKED
	.endif
	inc		ID
	dec		ebx
	jnz		@b
	mov		buffer1[1],0
	mov		buffer1[0],'1'
	invoke GetPrivateProfileString,lpType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,lpIni
	.if !eax
		invoke GetPrivateProfileString,addr iniType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
	.endif
	invoke SetDlgItemText,hWin,IDD_RCC,addr iniBuffer
	mov		buffer1[0],'2'
	invoke GetPrivateProfileString,lpType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,lpIni
	.if !eax
		invoke GetPrivateProfileString,addr iniType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
	.endif
	invoke SetDlgItemText,hWin,IDD_ASM,addr iniBuffer
	mov		buffer1[0],'3'
	invoke GetPrivateProfileString,lpType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,lpIni
	.if !eax
		invoke GetPrivateProfileString,addr iniType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
	.endif
	invoke SetDlgItemText,hWin,IDD_LNK,addr iniBuffer
	mov		buffer1[0],'4'
	invoke GetPrivateProfileString,lpType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,lpIni
	.if !eax
		invoke GetPrivateProfileString,addr iniType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
	.endif
	invoke SetDlgItemText,hWin,IDD_RUN,addr iniBuffer
	mov		buffer1[0],'5'
	invoke GetPrivateProfileString,lpType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,lpIni
	.if !eax
		invoke GetPrivateProfileString,addr iniType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
	.endif
	invoke SetDlgItemText,hWin,IDD_RTO,addr iniBuffer
	mov		buffer1[0],'6'
	invoke GetPrivateProfileString,lpType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,lpIni
	.if !eax
		invoke GetPrivateProfileString,addr iniType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
	.endif
	invoke SetDlgItemText,hWin,IDD_TOP,addr iniBuffer
	mov		buffer1[0],'7'
	invoke GetPrivateProfileString,lpType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,lpIni
	.if !eax
		invoke GetPrivateProfileString,addr iniType,addr buffer1,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr szAsmIni
	.endif
	invoke SetDlgItemText,hWin,IDD_DBG,addr iniBuffer
	ret

InitDialog4 endp

DialogFunc4	proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	; This dialog processes property page 4
	LOCAL	buffer[256]:BYTE

	mov	eax,uMsg
	.if	eax==WM_NOTIFY
		mov		ebx,lParam
		mov		eax,NMHDR.code[ebx]
		.if eax==PSN_SETACTIVE			; page gaining focus
			invoke SetParentCaption,hWin
			invoke PostMessage,hWiz,PSM_SETWIZBUTTONS,0,PSWIZB_FINISH or PSWIZB_BACK	 
		.endif
	.elseif eax==WM_INITDIALOG
		m2m		hPsDlg[12],hWin
		.if TplFile
			;Get template filename
			invoke strcpy,addr buffer,addr szTpl
			mov		word ptr iniBuffer,'\'
			invoke strcat,addr buffer,addr iniBuffer
			invoke strcat,addr buffer,addr TplFile
			invoke GetPrivateProfileString,offset iniMakeDef,addr iniMakeDefMenu,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr buffer
			.if eax
				invoke InitDialog4,hWin,addr buffer,offset iniMakeDef
			.else
				invoke InitDialog4,hWin,offset szAsmIni,offset iniType
			.endif
		.else
			invoke InitDialog4,hWin,offset szAsmIni,offset iniType
		.endif
	.else
		return FALSE
	.endif
	return TRUE

DialogFunc4	endp

WizProc proc uses ebx,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	nmhdr:NMHDR

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		mov		eax,hWin
		mov		hWiz,eax
		invoke MoveWin,hWin,offset PosProWizLeft
		invoke SetLanguage,hWin,IDD_WIZ,FALSE
		invoke ModelessDialog,hInstance,IDD_WIZ1,hWin,addr DialogFunc1,0
		push	eax
		invoke SetWindowText,eax,addr szWiz1
		pop		eax
		invoke SetLanguage,eax,IDD_WIZ1,2
		invoke ModelessDialog,hInstance,IDD_WIZ2,hWin,addr DialogFunc2,0
		push	eax
		invoke SetWindowText,eax,addr szWiz2
		pop		eax
		invoke SetLanguage,eax,IDD_WIZ2,2
		invoke ModelessDialog,hInstance,IDD_WIZ3,hWin,addr DialogFunc3,0
		push	eax
		invoke SetWindowText,eax,addr szWiz3
		pop		eax
		invoke SetLanguage,eax,IDD_WIZ3,2
		invoke ModelessDialog,hInstance,IDD_WIZ4,hWin,addr DialogFunc4,0
		push	eax
		invoke SetWindowText,eax,addr szWiz4
		pop		eax
		invoke SetLanguage,eax,IDD_WIZ4,2
		mov		eax,hWin
		mov		nmhdr.hwndFrom,eax
		mov		nmhdr.idFrom,IDD_WIZ
		mov		nmhdr.code,PSN_SETACTIVE
		invoke SendMessage,hPsDlg[0],WM_NOTIFY,IDD_WIZ,addr nmhdr
		invoke SendMessage,hPsDlg[0],WM_COMMAND,(BN_CLICKED shl 16) or IDD_PT1,0
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDC_BTNBACK
				; < Back
				mov		eax,hWin
				mov		nmhdr.hwndFrom,eax
				mov		nmhdr.idFrom,IDD_WIZ
				mov		nmhdr.code,PSN_SETACTIVE
				invoke GetWindowLong,hWin,GWL_USERDATA
				.if eax==0
				.elseif eax==1
					invoke ShowWindow,hPsDlg[0],SW_SHOW
					invoke ShowWindow,hPsDlg[4],SW_HIDE
					invoke SetWindowLong,hWin,GWL_USERDATA,0
					invoke SendMessage,hPsDlg[0],WM_NOTIFY,IDD_WIZ,addr nmhdr
				.elseif eax==2
					invoke ShowWindow,hPsDlg[4],SW_SHOW
					invoke ShowWindow,hPsDlg[8],SW_HIDE
					invoke SetWindowLong,hWin,GWL_USERDATA,1
					invoke SendMessage,hPsDlg[4],WM_NOTIFY,IDD_WIZ,addr nmhdr
				.elseif eax==3
					invoke ShowWindow,hPsDlg[8],SW_SHOW
					invoke ShowWindow,hPsDlg[12],SW_HIDE
					invoke SetWindowLong,hWin,GWL_USERDATA,2
					invoke SendMessage,hPsDlg[8],WM_NOTIFY,IDD_WIZ,addr nmhdr
				.endif
			.elseif eax==IDC_BTNNEXT
				; Next >
				mov		eax,hWin
				mov		nmhdr.hwndFrom,eax
				mov		nmhdr.idFrom,IDD_WIZ
				mov		nmhdr.code,PSN_SETACTIVE
				invoke GetWindowLong,hWin,GWL_USERDATA
				.if eax==0
					invoke ShowWindow,hPsDlg[4],SW_SHOW
					invoke ShowWindow,hPsDlg[0],SW_HIDE
					invoke SetWindowLong,hWin,GWL_USERDATA,1
					invoke SendMessage,hPsDlg[4],WM_NOTIFY,IDD_WIZ,addr nmhdr
				.elseif eax==1
					invoke ShowWindow,hPsDlg[8],SW_SHOW
					invoke ShowWindow,hPsDlg[4],SW_HIDE
					invoke SetWindowLong,hWin,GWL_USERDATA,2
					invoke SendMessage,hPsDlg[8],WM_NOTIFY,IDD_WIZ,addr nmhdr
				.elseif eax==2
					invoke ShowWindow,hPsDlg[12],SW_SHOW
					invoke ShowWindow,hPsDlg[8],SW_HIDE
					invoke SetWindowLong,hWin,GWL_USERDATA,3
					invoke SendMessage,hPsDlg[12],WM_NOTIFY,IDD_WIZ,addr nmhdr
				.elseif eax==3
				.endif
			.elseif eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDOK
				invoke GetDlgItem,hWin,IDOK
				invoke IsWindowVisible,eax
				.if eax
					invoke ProWizFinish
					.if !eax
						invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
					.endif
				.endif
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke SaveWinPos,hWin,offset PosProWizLeft
		invoke EndDialog,hWin,NULL
	.elseif eax==PSM_SETWIZBUTTONS
		invoke GetDlgItem,hWin,IDC_BTNBACK
		test	lParam,PSWIZB_BACK
		.if !ZERO?
			invoke EnableWindow,eax,TRUE
		.else
			invoke EnableWindow,eax,FALSE
		.endif
		invoke GetDlgItem,hWin,IDC_BTNNEXT
		test	lParam,PSWIZB_NEXT
		.if !ZERO?
			invoke EnableWindow,eax,TRUE
		.else
			invoke EnableWindow,eax,FALSE
		.endif
		test	lParam,PSWIZB_FINISH
		.if !ZERO?
			invoke GetDlgItem,hWin,IDOK
			invoke ShowWindow,eax,SW_SHOW
			invoke GetDlgItem,hWin,IDC_BTNNEXT
			invoke ShowWindow,eax,SW_HIDE
		.else
			invoke GetDlgItem,hWin,IDC_BTNNEXT
			invoke ShowWindow,eax,SW_SHOW
			invoke GetDlgItem,hWin,IDOK
			invoke ShowWindow,eax,SW_HIDE
		.endif
	.else
		return FALSE
	.endif
	return TRUE

WizProc endp

ProWizShow proc hWin:HWND

	invoke ModalDialog,hInstance,IDD_WIZ,hWin,addr WizProc,0
	ret

ProWizShow endp

