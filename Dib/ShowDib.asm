.const

IDM_SHOW_NORMAL			equ 1
IDM_SHOW_CENTRE			equ 2
IDM_SHOW_STRETCH		equ 3
IDM_SHOW_ISOSTRETCH		equ 4

.data?

pbmfh		dd ?
pbmi		dd ?
pBits		dd ?
cxDib		dd ?
cyDib		dd ?
cxClient	dd ?
cyClient	dd ?
hBmpMem		dd ?

.code

DibShow proc hdc:HDC,_pbmi:DWORD,_pBits:DWORD,_cxDib:DWORD,_cyDib:DWORD,_cxClient:DWORD,_cyClient:DWORD,_wShow:DWORD

	mov	eax,_wShow
	.if	eax==IDM_SHOW_NORMAL
		invoke	SetDIBitsToDevice,hdc,0,0,_cxDib,_cyDib,0,0,0,_cyDib,_pBits,_pbmi,DIB_RGB_COLORS
	.elseif eax==IDM_SHOW_CENTRE
		;(cxClient-cxDib)/2
		mov	eax,_cxClient
		sub eax,_cxDib
		shr eax,1
		;(cyClient-cyDib)/2
		mov ecx,_cyClient
		sub ecx,_cyDib
		shr ecx,1	
		invoke SetDIBitsToDevice,hdc,eax,ecx,_cxDib,_cyDib,0,0,0,_cyDib,_pBits,_pbmi,DIB_RGB_COLORS
	.elseif eax==IDM_SHOW_STRETCH
		invoke SetStretchBltMode,hdc,COLORONCOLOR 
		invoke StretchDIBits,hdc,0,0,_cxClient,_cyClient,0,0,_cxDib,_cyDib,_pBits,_pbmi,DIB_RGB_COLORS,SRCCOPY
	.elseif eax==IDM_SHOW_ISOSTRETCH
		invoke SetStretchBltMode, hdc, COLORONCOLOR
		invoke SetMapMode, hdc, MM_ISOTROPIC
		invoke SetWindowExtEx, hdc, _cxDib, _cyDib, 0
		invoke SetViewportExtEx,hdc,_cxClient,_cyClient,0
		;Get cxDib/2 and cyDib/2
		mov		eax,_cxDib
		shr		eax,1
		mov		ecx,_cyDib
		shr		ecx,1
		invoke SetWindowOrgEx,hdc,eax,ecx,0
		;Get cxClient/2 and cyClient/2
		mov		eax,_cxClient
		shr		eax,1
		mov		ecx,_cyClient
		shr		ecx,1
		invoke SetViewportOrgEx,hdc,eax,ecx,0
		invoke StretchDIBits,hdc,0,0,_cxDib,_cyDib,0,0,_cxDib,_cyDib,_pBits,_pbmi,DIB_RGB_COLORS,SRCCOPY
	.endif
	ret

DibShow endp

GetSplash proc uses ebx esi
	LOCAL	bSuccess:DWORD
	LOCAL	dwFileSize:DWORD
	LOCAL	dwHighSize:DWORD
	LOCAL	dwBytesRead:DWORD
	LOCAL	hFile:HANDLE

	invoke CreateFile,addr SplashBmp,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_FLAG_SEQUENTIAL_SCAN,0
	mov		hFile,eax
	.if eax==INVALID_HANDLE_VALUE
		mov		eax,0
		ret
	.endif
	invoke GetFileSize,hFile,ADDR dwHighSize
	mov		dwFileSize,eax
	.if dwHighSize
		invoke CloseHandle,hFile
		mov		eax,0
		ret
	.endif
	invoke xGlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,dwFileSize
	mov		hBmpMem,eax
	invoke GlobalLock,hBmpMem
	mov		pbmfh,eax
	mov		ebx,eax
	.if !pbmfh
		invoke CloseHandle,hFile
		mov		eax,0
		ret
	.endif
	invoke ReadFile,hFile,pbmfh,dwFileSize,ADDR dwBytesRead,0
	mov		bSuccess,eax
	invoke CloseHandle,hFile
	mov		eax,dwBytesRead
	;Get file type from header; must be BM
	mov		cx,BITMAPFILEHEADER.bfType[ebx]
	;Size (in bytes) of bitmap
	mov		edx,BITMAPFILEHEADER.bfSize[ebx]
	;Note for the type comparison we need to compare against MB & not BM
	.if !bSuccess || eax!=dwFileSize || cx!="MB" || edx!=dwFileSize
		invoke GlobalUnlock,pbmfh
		invoke GlobalFree,hBmpMem	 
		mov		eax,0
		ret
	.endif
	mov		ebx,pbmfh
	mov		eax,sizeof BITMAPFILEHEADER	; BITMAPINFO immediately follows
	add		eax,ebx				; the header (pointed to by ebx)
	mov		pbmi,eax			; Points to bitmap information
	mov		esi,eax				; save to reg as well
	mov		eax,BITMAPFILEHEADER.bfOffBits[ebx]; offset from BMFH struct to pix bits
	add		eax,ebx
	mov		pBits,eax			; This is a pointer to the actual DIB pixel bits 
	;Get the DIB width & height
	.IF  BITMAPINFO.bmiHeader.biSize[esi]== sizeof BITMAPCOREHEADER
		;width & height are WORDs
		xor		eax,eax
		mov		ax,BITMAPCOREHEADER.bcWidth[esi]
		mov		cxDib, eax
		mov		ax,BITMAPCOREHEADER.bcHeight[esi]
		mov		cyDib,eax
	.ELSE
		;width & heght are DWORDs
		mov		eax,BITMAPINFO.bmiHeader.biWidth[esi]
		mov		cxDib, eax
		mov		eax,BITMAPINFO.bmiHeader.biHeight[esi]
		.IF eax<1
			neg		eax					; Get abs value
		.ENDIF	
		mov		cyDib,eax			
	.ENDIF
	mov		eax,TRUE
	ret

GetSplash endp
