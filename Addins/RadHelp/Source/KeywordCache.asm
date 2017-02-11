

; You can use up to 65536 keyword files at a time in theory, although a 4kb buffer is allocated for every
; keyword file. So merging 65536 files requires 256mb of free memory for the file buffers alone :)

; Keyword file format:	- Plain text file, no line can be longer than 4kb
;						- First line: keyword set identifier (short, no spaces, no "=") example: win32api
;						- Second line: keyword set description (No "=" allowed). example: Windows API's
;						- Next lines: keywords. One per line + lowercase + sorted
; Cache file format:	- Binary file
;						- First 128 dword's: Index. 
;						- Index[0] = Number of keywordlists / Index[4] = Length of headers 
;						- Asciiz keyword list info:	(filename without path/extension),0
;													(keyword set identifier),0
;													(keyword set description),0
;						- Asciiz keywords: keyword,0,WORD 0-based # of keywordlist keyword came from
;						- No keyword can be longer than 50 bytes


OpenCache proto
RebuildCache proto
CloseCache proto
FindKeyword proto :dword
GetFirstLine proto :dword,:dword
GetNextLine proto :dword

listinfo struct
	pFileID dd ?
	pName dd ?
	pDescription dd ?
	pHelpfile dd ?
listinfo ends

liststruct STRUCT ; Only used in RebuildCache
	hFile dd ?
	hBuffer dd ?
	pBuffer dd ?
	BufferSize dd ?
liststruct ends

.data?
	KwCacheFilename db MAX_PATH dup (?)
	KwFiles db 512 dup (?)
	pIniFile dd ?
	hCacheFile dd ?
	hCacheMapping dd ?
	pCache dd ?
	pListInfo dd ?
	
	temp db 256 DUP (?)
	
.code

OpenCache proc uses esi edi ebx 
	
	mov eax,lpData
	mov eax,(ADDINDATA ptr [eax]).lpIniAsmFile
	mov pIniFile,eax
	test eax,eax
	jz RadAsmIni
	
	invoke GetPrivateProfileString,addr szRadHelp,addr szKwCacheFile,addr szQ,addr KwCacheFilename,sizeof KwCacheFilename,pIniFile
	invoke GetPrivateProfileString,addr szRadHelp,addr szKwLists,addr szQ,addr KwFiles,sizeof KwFiles,pIniFile
	
	.if KwFiles=="?"
RadAsmIni:
		mov eax,lpData
		mov eax,(ADDINDATA ptr [eax]).lpIniFile
		mov pIniFile,eax
		invoke GetPrivateProfileString,addr szRadHelp,addr szKwCacheFile,addr szQ,addr KwCacheFilename,sizeof KwCacheFilename,pIniFile
		invoke GetPrivateProfileString,addr szRadHelp,addr szKwLists,addr szQ,addr KwFiles,sizeof KwFiles,pIniFile
		.if KwFiles=="?"
			Msg "OpenCache: No helpfiles specified. Help will not be available."
			jmp Abort
		.endif
	.endif
	
	invoke lcase,addr KwFiles

;	.if KwCacheFilename=="?"
;		invoke RebuildCache
;		test eax,eax
;		jz Abort
;	.endif
	cmp KwCacheFilename,"?"
	je DoRebuild
	
	invoke CreateFile,addr KwCacheFilename,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_FLAG_RANDOM_ACCESS,0
	cmp eax,INVALID_HANDLE_VALUE
	je DoRebuild
	mov hCacheFile,eax
	invoke CreateFileMapping,hCacheFile,0,PAGE_READONLY or SEC_COMMIT,0,0,0
	mov hCacheMapping,eax
	invoke MapViewOfFile,hCacheMapping,FILE_MAP_READ,0,0,0
	mov pCache,eax
	mov edi,eax
	
	; Count the number of lists specified in the ini file and rebuild the cache if the counts don't match
	mov esi,offset KwFiles
	xor ecx,ecx
	and Options,(not fHasDefault)
CountOne:
	mov edx,esi
	inc ecx
@@:	lodsb
	cmp al,","
	je CountOne
	cmp al,0
	jne @b
	mov eax,ecx
	.if (dword ptr [edx]=="afed") && (dword ptr [edx+4]=="tlu") ; "default",0
		or Options,fHasDefault
		dec eax ; Don't count the default entry, as it's not in the cachefile
	.endif
	cmp eax,[edi]
	jne DoRebuild
	
	; Allocate the structs to describe the keyword lists
	inc ecx ; Last entry is for default
	shl ecx,4
	invoke GlobalAlloc,GMEM_FIXED,ecx
	mov pListInfo,eax
	
	; Now compare each entry and rebuild the cachefile if entries don't match
	; Also store info about each keywordlist into the pListInfo structs
	assume ebx:ptr listinfo
	mov esi,offset KwFiles
	mov ebx,pListInfo
	mov edx,[edi]
	add edi,128*4
	mov [ebx].pFileID,edi
ListCheck:	
	mov al,[esi]
	inc esi
	mov cl,[edi]
	inc edi
	cmp al,","
	je @f
	cmp al,0
	je @f
	cmp al,cl
	je ListCheck
	jmp DoRebuild
	
@@:	cmp byte ptr [edi-1],0
	jne DoRebuild
	; Store position of name and seek past it
	mov [ebx].pName,edi
@@:	cmp byte ptr [edi],0
	lea edi,[edi+1]
	jne @B
	
	; Store position of description and seek past it
	mov [ebx].pDescription,edi
@@:	cmp byte ptr [edi],0
	lea edi,[edi+1]
	jne @B
	; Check if this was the last entry
	dec edx
	jz Done
	; Else continue with the next
	add ebx,16
	mov [ebx].pFileID,edi
	jmp ListCheck
Done:

	; Now all that needs to be done is to fetch the helpfile names from the ini file

	mov esi,pCache 
	mov esi,[esi] ; Get helpfile count from cachefile

	.if Options & fHasDefault
		add ebx,16
		mov [ebx].pFileID,CTEXT("default") 
		inc esi
	.endif

	mov ebx,pListInfo
@@:	invoke GlobalAlloc,GMEM_FIXED,MAX_PATH
	mov [ebx].pHelpfile,eax
	invoke GetPrivateProfileString,addr szRadHelp,[ebx].pFileID,CTEXT("(None)"),[ebx].pHelpfile,MAX_PATH,pIniFile
	add ebx,16
	dec esi
	jnz @B
	
	assume ebx:nothing
	
	; Done :)
	
	mov eax,TRUE
	ret
	
DoRebuild:
	invoke RebuildCache ; RebuildCache will call OpenCache if it was successful
	ret
	
Abort:
	invoke CloseCache
	mov eax,FALSE
	ret
	
OpenCache endp

CloseCache proc uses esi edi 
	
	mov esi,pListInfo
	mov edi,pCache
	.if edi
		mov edi,[edi]
		.if esi && edi
		@@: invoke GlobalFree,(listinfo ptr [esi]).pHelpfile
			add esi,sizeof listinfo
			dec edi
			jnz @B
		.endif
	.endif

	invoke UnmapViewOfFile,pCache
	mov pCache,0
	invoke CloseHandle,hCacheMapping
	invoke CloseHandle,hCacheFile
	invoke GlobalFree,pListInfo
	mov pListInfo,0
	ret

CloseCache endp

GetFirstLine proc uses esi edi ebx pliststruct:dword,pfilename:dword
	
	mov edi,pliststruct
	assume edi:ptr liststruct
	
	invoke CreateFile,pfilename,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0
	.if eax==INVALID_HANDLE_VALUE
		Msg "GetFirstLine: Unable to open input file."
		xor eax,eax
		ret
	.endif
	mov [edi].hFile,eax
	
	invoke GetFileSize,[edi].hFile,0
	.if eax>4096
		mov eax,4096
	.endif
	mov [edi].BufferSize,eax
	mov [edi].pBuffer,eax
	
	invoke GlobalAlloc,GMEM_FIXED,eax
	mov [edi].hBuffer,eax
	add [edi].pBuffer,eax
	
	invoke GetNextLine,edi

	assume edi:nothing
	ret

GetFirstLine endp

GetNextLine proc uses esi edi ebx pliststruct:dword
	
	mov ebx,pliststruct
	assume ebx:ptr liststruct
	
CheckAgain:

	; Check if there is a complete line in the buffer
	mov esi,[ebx].pBuffer
	mov edi,esi ; esi = edi = pBuffer
	
	mov ecx,[ebx].hBuffer
	sub ecx,esi
	add ecx,[ebx].BufferSize	
	mov edx,ecx ; ecx = edx = amount of unread data still in buffer
				; (Unread data is from pBuffer to end of buffer)
	jz DontCopy ; There's no unread data left in the buffer
	
@@:	mov al,[esi]
	inc esi
	
	.if al=="=" 				; Ugly application-specific hack
		mov byte ptr [esi-1],0	;
	.endif						;
	
	; These two conditional jumps are ordered this way to ensure
	; that a CrLf is never split between two reads.
	dec ecx 
	jz NeedMoreData
	cmp al,13
	jne @b
	; Zero-terminate the line and return its length in eax
	dec esi
	mov byte ptr [esi],0
	mov eax,esi
	sub eax,edi
	ret
	
NeedMoreData:
	; Before reading the new data, move the old data to the front of the buffer
	mov esi,edi
	mov edi,[ebx].hBuffer
	mov ecx,edx
	rep movsb
	
DontCopy:
	; All the unread data is now at the start of the buffer, so pBuffer=hBuffer
	; edx still contains the amount of unread data in the buffer
	mov eax,[ebx].hBuffer
	mov [ebx].pBuffer,eax
	
	; Calculate where and how much to read into the buffer
	mov esi,[ebx].hBuffer
	add esi,edx
	mov edi,[ebx].BufferSize
	sub edi,edx
	jz LineTooLong ; No space left, buffer is already full
	
	; Read the data
	invoke ReadFile,[ebx].hFile,esi,edi,addr [ebx].BufferSize,0
	.if eax==0
		invoke GetErrDescription,0
		xor eax,eax
		ret
	.endif
	
	; Handle end-of-file
	.if [ebx].BufferSize==0
		invoke CloseHandle,[ebx].hFile
		invoke GlobalFree,[ebx].hBuffer
		mov [ebx].hBuffer,0
		mov [ebx].pBuffer,0
		xor eax,eax
		ret
	.endif
	
	; Correct BufferSize
	mov eax,esi
	sub eax,[ebx].hBuffer
	add [ebx].BufferSize,eax
	
	; Find the first end-of-line in the new data
	jmp CheckAgain
	
	assume ebx:nothing
	
LineTooLong:
	Msg "GetNextLine: Line does not fit in buffer."
	xor eax,eax
	ret

GetNextLine endp

RebuildCache proc uses esi edi ebx
LOCAL listfn[512]:byte
LOCAL plistfn:dword
LOCAL hFile:dword
LOCAL plists:dword
LOCAL Index[128]:dword
LOCAL bw:dword

	invoke CloseCache

	; Initialize the index
	lea edi,Index
	xor eax,eax
	mov ecx,128
	rep stosd
	
	; Delete the old cachefile if it exists
	invoke DeleteFile,addr KwCacheFilename
	
	; Get a filename for the cache file
	mov ebx,lpData
	invoke lstrcpy,addr listfn,(ADDINDATA ptr [ebx]).lpAddIn
	invoke GetTempFileName,addr listfn,CTEXT("hlp"),0,addr KwCacheFilename
	invoke WritePrivateProfileString,addr szRadHelp,addr szKwCacheFile,addr KwCacheFilename,pIniFile
	
	; Set up the path portion for the list filenames
	mov esi,(ADDINDATA ptr [ebx]).lpAddIn
	lea edi,listfn
	
@@:
	mov al,[esi]
	inc esi
	mov [edi],al
	inc edi
	cmp al,0
	jne @B
	.if byte ptr [edi-2]=="\"
		dec edi
	.endif
	mov byte ptr [edi-1],"\"
	mov plistfn,edi

	; Count the number of keyword files to merge
	mov esi,offset KwFiles
	xor ecx,ecx
CountOne:
	mov edx,esi
	inc ecx
@@:	lodsb
	cmp al,","
	je CountOne
	cmp al,0
	jne @b


	.if (dword ptr [edx]=="afed") && (dword ptr [edx+4]=="tlu") ; "default",0
		dec ecx ; Don't count the default entry, as it's not a real file
		jz Abort
		mov byte ptr [edx-1],0
	.endif
	mov Index[0],ecx
	inc ecx
	
	; Allocate memory for liststruct structs
	shl ecx,4
	invoke GlobalAlloc,GPTR,ecx 
	mov plists,eax
	
	; Create the new cache file
	invoke CreateFile,addr KwCacheFilename,GENERIC_WRITE or GENERIC_READ,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_ARCHIVE or FILE_FLAG_SEQUENTIAL_SCAN,0
	cmp eax,INVALID_HANDLE_VALUE
	je Abort
	mov hFile,eax
	
	; The index will be written later, so leave this area open for now
	invoke SetFilePointer,hFile,128*4,0,FILE_BEGIN
	
	; Open the list files, initialize the structs, allocate buffers for them and read the first data into them
	; Also the filename, name and description of each keyword list is copied to the cache file
	mov esi,offset KwFiles

	
	mov ebx,plists
	assume ebx:ptr liststruct
OpenListsLoop:
	; Get the complete filename for this list into listfn
	mov edi,plistfn
@@:	mov al,[esi]
	inc esi
	mov [edi],al
	inc edi
	cmp al,","
	je @f
	cmp al,0
	jne @b
@@:	
	

	mov byte ptr [edi-1],0 ; Don't place extension yet, it needs to be copied to the cachefile first

	; Write the zero-terminated filename (without path or extension) to the cachefile
	mov edx,edi
	sub edx,plistfn
	invoke WriteFile,hFile,plistfn,edx,addr bw,0
	
	; Now place the extension since we need to open the file (happens in the GetFirstLine call)
	mov dword ptr [edi-1],"lwk." ;.kwl = keyword list
	mov byte ptr [edi+3],0

	; Copy the first two lines from the keyword list to the cache file as zero-terminated strings
	
	; Copy the first line
	invoke GetFirstLine,ebx,addr listfn
	test eax,eax
	jz Abort
	mov ecx,[ebx].pBuffer ; Save old buffer position
	inc eax ; Copy the terminating 0 as well
	mov edx,eax
	inc eax ; Skip another byte in the buffer (CrLf=2 bytes,0=1 byte)
	add [ebx].pBuffer,eax
	invoke WriteFile,hFile,ecx,edx,addr bw,0
	
	; Copy the second line
	invoke GetNextLine,ebx ; The only difference with the first line :)
	test eax,eax
	jz Abort
	mov ecx,[ebx].pBuffer ; Save old buffer position
	inc eax ; Copy the terminating 0 as well
	mov edx,eax
	inc eax ; Skip another byte in the buffer (CrLf=2 bytes,0=1 byte)
	add [ebx].pBuffer,eax
	invoke WriteFile,hFile,ecx,edx,addr bw,0
	
	; Refill the buffer if needed
	invoke GetNextLine,ebx 
	test eax,eax
	jz Abort
	
	; Point ebx to the next liststruct
	add ebx,sizeof liststruct
	
	; Loop if there's another entry in KwFiles
	cmp byte ptr [esi-1],0
	jne OpenListsLoop
	
	assume ebx:nothing
	
	; Index entry 4 is relative offset to start of keyword data (= length of headers)
	invoke SetFilePointer,hFile,0,0,FILE_CURRENT
	mov Index[4],eax

	; This is where the real merging is done.
	jmp EnterMergeLoop

	
MergeLoop:	
		
	; edi points to the liststruct that contains the entry to write
	assume edi:ptr liststruct

	invoke StrLen,[edi].pBuffer
	.if eax>KeywordBufferLen
		Msg "Keyword too long."
		jmp Abort
	.endif
	inc eax
	mov ebx,eax
	
	; Update the index if needed
	mov eax,[edi].pBuffer
	mov al,[eax]
	and eax,07fh
	lea eax,Index[eax*4]
	.if dword ptr [eax]==0
		push eax
		invoke SetFilePointer,hFile,0,0,FILE_CURRENT
		pop edx
		mov [edx],eax
	.endif
	
	; Happy-happy hack to make keyword replacement work
	; Works together with the other piece of code labelled "ugly" (in GetNextLine)
	; This piece of code also updates the input buffer position
	mov esi,[edi].pBuffer
	add esi,ebx
	.if byte ptr [esi]==10
		mov byte ptr [esi],0
		inc ebx
		mov edx,[edi].pBuffer
		add [edi].pBuffer,ebx
	.else
		invoke StrLen,esi
		add ebx,eax
		inc ebx
		mov edx,[edi].pBuffer
		add [edi].pBuffer,ebx
		inc [edi].pBuffer
	.endif
	
	; Write that entry to the cache file.
	invoke WriteFile,hFile,edx,ebx,addr bw,0
	
	; Write the number of the keyword list the entry came from (WORD)
	mov eax,edi
	sub eax,plists
	shr eax,4
	mov word ptr listfn,ax ; This buffer isn't used anymore anyway
	invoke WriteFile,hFile,addr listfn,2,addr bw,0
	
	; Refill the buffer if needed
	invoke GetNextLine,edi 

EnterMergeLoop:

	assume esi:ptr liststruct
	; Find which one of the listfiles has the lowest entry
	mov ebx,Index[0] ; = number of input files
	mov esi,plists
	lea edi,[esi+16]
	dec ebx
	js Abort ; No entries
@@:	.if [edi].pBuffer==0
		mov edi,esi
	.elseif [esi].pBuffer!=0
		invoke strcmp,[edi].pBuffer,[esi].pBuffer
		.if !(eax & 80000000h) ; Test sign bit
			mov edi,esi
		.endif
	.endif
	add esi,16
	dec ebx
	jns @b
	assume esi:Nothing

	; Check if all the listfiles have reached the eof
	cmp [edi].pBuffer,0
	jne MergeLoop
	
	assume edi:nothing
	
	; Last index entry gives length of file - this is relied on in
	; the FindKeyword procc
	invoke SetFilePointer,hFile,0,0,FILE_CURRENT
	mov Index[127*4],eax 
	
	; Write the index to the start of the file
	invoke SetFilePointer,hFile,0,0,FILE_BEGIN
	invoke WriteFile,hFile,addr Index,128*4,addr bw,0
	
	; Done :) The input file buffers and handles have already been freed in 
	; GetNextLine as each file reached the EOF 
	invoke CloseHandle,hFile
	invoke GlobalFree,plists
	
	invoke OpenCache
	
	ret
	
Abort:
	mov esi,plists
	mov ebx,Index[0]
	.if esi && ebx
	@@:	invoke GlobalFree,(liststruct ptr [esi]).hBuffer
		invoke CloseHandle,(liststruct ptr [esi]).hFile
		add esi,sizeof liststruct
		dec ebx
		jnz @B
	.endif
	invoke CloseHandle,hFile
	invoke GlobalFree,plists
	invoke DeleteFile,addr KwCacheFilename
	Msg "RebuildCache failed. Help will not be available."
	mov eax,FALSE
	ret

RebuildCache endp

FindKeyword proc uses esi edi ebx pKeyword:dword
	
LOCAL kwlen:dword
	mov edi,pCache
	test edi,edi
	jz NotFound
	
	invoke StrLen,pKeyword
	mov kwlen,eax
	
	mov eax,pKeyword
	mov al,[eax]
	and eax,07fh
	test eax,eax
	jz NotFound

	shl eax,2
	add edi,eax
	mov esi,[edi]
	add esi,pCache
@@:	add edi,4
	mov edx,[edi]
	cmp edx,0
	je @B
	mov edi,edx
	add edi,pCache
@@:
;invoke TextOutput,esi
	invoke StrLen,esi
	.if eax==kwlen
		invoke strcmp,esi,pKeyword
		shl eax,1
		jz FoundIt ; eax==0
		jnc NotFound ; eax>0
		mov eax,kwlen
	.endif
	add esi,eax
	inc esi
	.if byte ptr [esi]!=0
		invoke StrLen,esi
		add esi,eax
	.endif
	add esi,3
	cmp esi,edi
	js @B
NotFound:
	.if !(Options & fHasDefault)
		xor eax,eax
		ret
	.endif
	mov eax,pCache
	mov eax,[eax] ; eax = number of keywordlists = ID of default keywordlist
	jmp ReturnListFilename
FoundIt:
	add esi,kwlen
	add esi,2
	mov al,[esi-1]
	.if al!=0
		mov edi,pKeyword
	@@:	mov [edi],al
		inc edi
		mov al,[esi]
		inc esi
		cmp al,0
		jne @b
		mov byte ptr [edi],0
	.endif
	mov ax,[esi]
	and eax,0ffffh
ReturnListFilename:
	shl eax,4
	add eax,pListInfo
	mov eax,(listinfo ptr [eax]).pHelpfile
	ret

FindKeyword endp
