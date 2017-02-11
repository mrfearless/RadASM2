
OpenHelp proto :dword,:dword
OpenHelpExe proto :dword,:dword
OpenHelpHH proto :dword,:dword
OpenHelpHH2 proto :dword,:dword
PathCpy proto :dword,:dword
ScanForTokens proto :dword,:dword,:dword,:dword,:dword

.code

PathCpy proc pDest:dword,pSrc:dword

	mov eax,pDest
	mov ecx,pSrc
@@:	mov dl,[ecx]
	inc ecx
	mov [eax],dl
	inc eax
	cmp dl,0
	jne @B
	dec eax
	.if byte ptr [eax-1]=="\"
		dec eax
		mov byte ptr [eax],0
	.endif
	sub eax,pDest
	ret

PathCpy endp

ScanForTokens PROC uses ebx esi edi pPath:DWORD,pOut:DWORD,pArgString:DWORD, pkeyword:DWORD, pAddins:DWORD
	LOCAL Space[8]:BYTE
	LOCAL Quote[8]:BYTE
	LOCAL buffer[1024]:BYTE

	mov Space," "
	mov Space+1,0
	
	mov Quote,'"'
	mov Quote+1,0

	; Scan the string one character at a time looking for a $
	; This indicates a token character
	invoke lstrlen,[pPath]
	; EBX contains the length of the string
	mov ebx,eax
	; EDI contains the current position in the input string
	mov edi,[pPath]
	; ESI contains the current position in the output string
	mov esi,[pOut]
	mov DWORD PTR [esi],0
	SCAN:
		; Check for a $
		mov al,[edi]
		cmp al,"$"
		jne MOVBYTE
			;If a $ is encountered then get the token
			mov cl,[edi+1]
			cmp cl,0
			je EXIT
			cmp cl,"D"
			jne @F
				; Replace the token with the appropriate path
				mov edx,[pAddins]
				invoke lstrcat,[pOut],[edx+ADDINDATA.lpAddIn]
				invoke lstrlen,eax
				mov esi,[pOut]
				add esi,eax
				invoke PathAddBackslash,[pOut]
				add edi,2
				sub ebx,2
				jnz SCAN
				jmp EXIT
			@@:
			cmp cl,"A"
			jne @F
				mov edx,[pAddins]
				invoke lstrcat,[pOut],[edx+ADDINDATA.lpApp]
				invoke lstrlen,eax
				mov esi,[pOut]
				add esi,eax
				invoke PathAddBackslash,[pOut]
				add edi,2
				sub ebx,2
				jnz SCAN
				jmp EXIT
			@@:
			cmp cl,"R"
			jne @F
				mov edx,[pAddins]
				invoke lstrcat,[pOut],[edx+ADDINDATA.lpLoadPath]
				invoke lstrlen,eax
				mov esi,[pOut]
				add esi,eax
				invoke PathAddBackslash,[pOut]
				add edi,2
				sub ebx,2
				jnz SCAN
				jmp EXIT
			@@:
			cmp cl,"S"
			jne @F
				invoke GetSystemDirectory,addr buffer,1024
				invoke lstrcat,[pOut],addr buffer
				invoke lstrlen,eax
				mov esi,[pOut]
				add esi,eax
				invoke PathAddBackslash,[pOut]
				add edi,2
				sub ebx,2
				jnz SCAN
				jmp EXIT
			@@:
			cmp cl,"W"
			jne @F
				invoke GetWindowsDirectory,addr buffer,1024
				invoke lstrcat,[pOut],addr buffer
				invoke lstrlen,eax
				mov esi,[pOut]
				add esi,eax
				invoke PathAddBackslash,[pOut]
				add edi,2
				sub ebx,2
				jnz SCAN
				jmp EXIT
			@@:
			cmp cl,"H"
			jne @F
				mov edx,[pAddins]
				invoke lstrcat,[pOut],[edx+ADDINDATA.lpHlp]
				invoke lstrlen,eax
				mov esi,[pOut]
				add esi,eax
				invoke PathAddBackslash,[pOut]
				add edi,2
				sub ebx,2
				jnz SCAN
				jmp EXIT
			@@:
			cmp cl,"K"
			jne @F
				invoke lstrcat,[pOut],[pkeyword]
				invoke lstrlen,eax
				mov esi,[pOut]
				add esi,eax
				add edi,2
				sub ebx,2
				jnz SCAN
				jmp EXIT
			@@:
			; Replace $$ with a single $
			cmp cl,"$"
			jne @F
				mov [esi],cl
				inc esi
				add edi,2
				sub ebx,2
				jnz SCAN
				jmp EXIT
			@@:
			; invalid use of $ so remove it
			inc edi
			dec ebx
			jnz SCAN
			jmp EXIT

		MOVBYTE:
		mov [esi],al
		mov BYTE PTR [esi+1],0
		inc esi
		inc edi
		dec ebx
		jnz SCAN

	EXIT:
	mov BYTE PTR [esi],0

	; Get the arguments from the resulting string
	invoke PathGetArgs,[pOut]
	push eax
	invoke lstrcpy,[pArgString],eax
	pop eax
	; Null terminate the path portion
	cmp BYTE PTR [eax],0
	je @F
	mov BYTE PTR [eax-1],0
	@@:
	; Trim the spaces and remove the quotes from the path
	invoke StrTrim,[pOut],addr Space
	invoke StrTrim,[pOut],addr Quote
	; Trim only spaces from the arguments
	invoke StrTrim,[pArgString],addr Space

	RET
ScanForTokens ENDP

OpenHelp proc uses esi edi pkeyword:dword,phelpfile:dword
	
LOCAL pMem:dword
LOCAL quoted:dword
LOCAL pArgs:dword
	
	; Allocate a buffer for the completed path
	invoke GlobalAlloc,GMEM_FIXED,1024
	mov [pMem], eax
	invoke GlobalAlloc,GMEM_FIXED,1024
	mov [pArgs], eax
	
	invoke ScanForTokens,[phelpfile],[pMem],[pArgs],[pkeyword],[lpData]

	; Check the file's type and open it in the appropriate way
	invoke lcase,pMem
	invoke PathIsURL,pMem
	.if eax
		mov eax,pMem
		.if (dword ptr [eax]=="h-sm") && (dword ptr [eax+4]==":ple") ; ms-help:
			invoke OpenHelpHH2,pMem,pkeyword ; HtmlHelp2 URL
		.else
			invoke ShellExecute,0,0,pMem,0,0,SW_SHOWDEFAULT ; Normal URL
		.endif
	.else
		invoke PathFindExtension,[pMem]
		mov edx,[eax]
		.if dl==0
			invoke MessageBox,0,pMem,CTEXT("Filename has no extension"),0
			jmp Done
		.endif
		.if edx=="plh." ;.hlp
			invoke WinHelp,0,pMem,HELP_KEY,pkeyword
		.elseif edx=="exe." ;.exe
			invoke OpenHelpExe,pMem,pArgs
		.elseif edx=="mhc." || edx=="loc." ; .chm or .col
			invoke OpenHelpHH,pMem,pkeyword
		.else
			mov eax,pMem
			mov eax,[eax]
			.if eax=="non)" || al==0 ; The .ini loading code set it to "(None)" if no entry exists in the ini
				Msg "No help file set."
			.else
				Msg "Unknown extension."
			.endif
			jmp Done
		.endif
	.endif
	
Done:
	invoke GlobalFree,[pMem]
	invoke GlobalFree,[pArgs]
	
	mov eax,TRUE
	ret

OpenHelp endp

OpenHelpExe proc uses edi pexefile:dword,pargs:dword

LOCAL psi:STARTUPINFO
LOCAL ppi:PROCESS_INFORMATION
	
	mov ecx,sizeof STARTUPINFO
	lea edi,psi
	xor eax,eax
	rep stosb
	
	mov psi.cb,sizeof STARTUPINFO
	
	; Strip leading spaces from the arguments
	mov edi,pargs
	mov al," "
	repe scasb

	invoke CreateProcess,pexefile,edi,0,0,0,0,0,0,addr psi,addr ppi
	
	invoke CloseHandle,ppi.hProcess
	invoke CloseHandle,ppi.hThread
	ret

OpenHelpExe endp

OpenHelpHH proc pfilename:DWORD,pkeyword:DWORD

LOCAL link:HH_AKLINK

	; Initialize the struct
	mov link.cbStruct, sizeof HH_AKLINK
	mov link.fReserved, FALSE
	push pkeyword
	pop link.pszKeywords
	mov link.pszUrl, NULL
	mov link.pszMsgText, NULL
	mov link.pszMsgTitle, NULL
	mov link.pszWindow, NULL
	mov link.fIndexOnFail, FALSE

	.data?
		hHtmlOcx dd ?
		pHtmlHelpProc dd ?
		hHHwin dd ?
	.code
	
	; Load the ocx containing the HtmlHelpA API
	.if !hHtmlOcx || !pHtmlHelpProc
		invoke LoadLibrary,CTEXT("hhctrl.ocx")
		mov hHtmlOcx,eax
		invoke GetProcAddress,eax,CTEXT("HtmlHelpA")
		mov pHtmlHelpProc,eax
		.if !eax
			invoke FreeLibrary,hHtmlOcx
			mov hHtmlOcx,0
			Msg "Unable to load hhctrl.ocx"
			ret
		.endif
	.endif
	
	; Display the HH window if it doesn't exist
	invoke GetWindowThreadProcessId,hHHwin,NULL
	.if eax==0
		push NULL
		push HH_DISPLAY_TOPIC
		push pfilename
		push 0
		call [pHtmlHelpProc]
		mov hHHwin,eax
	.endif
	
	; Jump to the correct topic
	lea eax,link
	push eax
	push HH_KEYWORD_LOOKUP
	push pfilename
	push 0
	call [pHtmlHelpProc]

	ret

OpenHelpHH endp

OpenHelpHH2 proc pFilename:DWORD,pKeyword:DWORD
	LOCAL clbuffer[256]:BYTE
	LOCAL pathBuffer[MAX_PATH]:BYTE
		
	; Build Commandline
	
	mov eax,lpData
	invoke lstrcpy,ADDR pathBuffer,(ADDINDATA ptr [eax]).lpAddIn
	invoke PathAddBackslash,ADDR pathBuffer
	invoke lstrcpy,eax,CTEXT("\H2Viewer.exe ")

	invoke lstrcpy,ADDR clbuffer,CTEXT("/helpcol ")
	invoke lstrcat,ADDR clbuffer,pFilename
	invoke lstrcat,ADDR clbuffer,CTEXT(" /filterquery /index " ; /keyword ",'"',"K$") ; 22h,4bh,24h == "K$
	invoke lstrcat,ADDR clbuffer,pKeyword
	invoke lstrcat,ADDR clbuffer,CTEXT(' /XNav /appid RadASM')
	
	invoke OpenHelpExe,addr pathBuffer,addr clbuffer
	
	ret

OpenHelpHH2 endp
