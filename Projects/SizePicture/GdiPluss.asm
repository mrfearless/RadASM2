
.const

szMimeType				db 'image/jpeg',0

.data?

gdiplSTI				GdiplusStartupInput <>
token					dd ?
EncoderClsid			GUID <>
szDefPicture			db MAX_PATH dup(?)

;Temporary data
HorRes					dd ?
VerRes					dd ?
imagen1					dd ?
imagen2					dd ?
lFormat					dd ?
grafic					dd ?
wbuffer					dw MAX_PATH dup(?)

.code

Save_Image proc uses ebx,lpImage:DWORD,lpFileName:DWORD

	invoke MultiByteToWideChar,CP_ACP,0,lpFileName,-1,offset wbuffer,MAX_PATH
	mov		wbuffer[eax*2],0
	invoke GdipSaveImageToFile,lpImage,offset wbuffer,offset EncoderClsid,0
	ret

Save_Image endp

Load_Image proc uses ebx,lpLoadFileName:DWORD,wt:DWORD,ht:DWORD,lpSaveFileName:DWORD
	LOCAL	hBmp:DWORD
	LOCAL	iwt:DWORD
	LOCAL	iht:DWORD

	; Convert Image Filename to Wide character other wise it will return error
	invoke MultiByteToWideChar,CP_ACP,0,lpLoadFileName,-1,offset wbuffer,MAX_PATH
	mov		wbuffer[eax*2],0
	; Load image from file and save bitmap to imagen1
	invoke GdipLoadImageFromFile,addr wbuffer,addr imagen1
	.if !eax
		; Get original image pixel format (usually 32 Bit color) and save it to lFormat
		invoke GdipGetImagePixelFormat,imagen1,addr lFormat
		; Get control dimensions
		; C++ Bitmap::Bitmap(width, height, format) Create new bitmap with widht and height just set and same pixel format as the original image and save it to imagen2
		invoke GdipCreateBitmapFromScan0,wt,ht,0,lFormat,0,addr imagen2
		; Set graphic interpolation mode to high quality output
		;	Shrink the image using low-quality interpolation.(InterpolationModeNearestNeighbor)
		;	Shrink the image using medium-quality interpolation. (InterpolationModeHighQualityBilinear)
		;	Shrink the image using high-quality interpolation. (InterpolationModeHighQualityBicubic)
		invoke GdipSetInterpolationMode,grafic,InterpolationModeHighQualityBicubic
		; Get original image Horizontal resolution and save it to HorRes variable
		invoke GdipGetImageHorizontalResolution,imagen1,addr HorRes
		; Get original image Vertical resolution and save it to VerRes variable
		invoke GdipGetImageVerticalResolution,imagen1,addr VerRes
		; Set new image vertical and horizontal resolution to match orignal image resolution
		invoke GdipBitmapSetResolution,imagen2,HorRes,VerRes
		; Get width and height in pixels
		invoke GdipGetImageWidth,imagen1,addr iwt
		invoke GdipGetImageHeight,imagen1,addr iht
		; Calculate the ratio*256
		mov		eax,iwt
		shl		eax,8
		mov		ecx,iht
		xor		edx,edx
		div		ecx
		mov		ebx,eax
		; Create new graphics object from new image
		invoke GdipGetImageGraphicsContext,imagen2,addr grafic
		;	 RGB 0,0,0
		; Set image background to Black color
		invoke GdipGraphicsClear,grafic,0
		; Draw resized original image to graphic object of new bitmap
		; Calculate width and offset
		mov		eax,ht
		mul		ebx
		shr		eax,8
		mov		wt,eax
		; Get picture offset
		mov		eax,PIXWT
		sub		eax,wt
		sar		eax,1
		invoke GdipDrawImageRectI,grafic,imagen1,eax,0,wt,ht
		; Destroy orignal image
		invoke GdipDisposeImage,imagen1
		; Delete new image graphic object
		invoke GdipDeleteGraphics,grafic
		; Create standard GDI Bitmap from Gdi+ Bitmap and save bitmap handle in hBitmap variable
		; If you want to rotate image use:
		;invoke GdipImageRotateFlip,imagen2,Rotate90FlipNone
		invoke GdipCreateHBITMAPFromBitmap,imagen2,addr hBmp,0
		mov		edx,lpSaveFileName
		.if edx
			.if byte ptr [edx]
				invoke Save_Image,imagen2,lpSaveFileName
			.endif
		.endif
		; Set VB Picture box control image to our new resized image
		invoke GdipDisposeImage,imagen2
		mov		eax,hBmp
	.else
		xor		eax,eax
	.endif
	ret

Load_Image endp

; ==========================================================================
; GetEncoderClsid
; The function GetEncoderClsid in the following example receives the MIME
; type of an encoder and returns the class identifier (CLSID) of that encoder.
; The MIME types of the encoders built into GDI+ are as follows:
;   image/bmp
;   image/jpeg
;   image/gif
;   image/tiff
;   image/png
; ==========================================================================
GetEncoderClsid proc
	LOCAL	numEncoders:DWORD
	LOCAL	nSize:DWORD
	LOCAL	hMem:DWORD

	invoke MultiByteToWideChar,CP_ACP,0,offset szMimeType,-1,offset wbuffer,MAX_PATH
	mov		wbuffer[eax*2],0
	invoke GdipGetImageEncodersSize,addr numEncoders,addr nSize
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,nSize
	mov		hMem,eax
	invoke GdipGetImageEncoders,numEncoders,nSize,hMem
	mov		ebx,hMem
	.while numEncoders
		invoke lstrcmpiW,[ebx].ImageCodecInfo.MimeType,offset wbuffer
		.if !eax
			invoke RtlMoveMemory,offset EncoderClsid,addr [ebx].ImageCodecInfo.ClassID,sizeof GUID
			.break
		.endif
		add		ebx,sizeof ImageCodecInfo
		dec		numEncoders
	.endw
	invoke GlobalFree,hMem
	ret

GetEncoderClsid endp

GetImage proc lpLoadFileName:DWORD,wt:DWORD,ht:DWORD,lpSaveFileName:DWORD
	LOCAL	hBmp:DWORD

	mov		eax,INVALID_HANDLE_VALUE
	mov		edx,lpSaveFileName
	.if edx
		.if byte ptr [edx]
			invoke GetFileAttributes,edx
		.endif
	.endif
	.if eax!=INVALID_HANDLE_VALUE
		; Get the tumbnail
		invoke MultiByteToWideChar,CP_ACP,0,lpSaveFileName,-1,offset wbuffer,MAX_PATH
		mov		wbuffer[eax*2],0
		; Load image from file and save bitmap to imagen1
		invoke GdipLoadImageFromFile,addr wbuffer,addr imagen1
		invoke GdipCreateHBITMAPFromBitmap,imagen1,addr hBmp,0
		invoke GdipDisposeImage,imagen1
		mov		eax,hBmp
	.else
		mov		eax,INVALID_HANDLE_VALUE
		mov		edx,lpLoadFileName
		.if edx
			.if byte ptr [edx]
				invoke GetFileAttributes,edx
			.endif
		.endif
		.if eax!=INVALID_HANDLE_VALUE
			invoke Load_Image,lpLoadFileName,wt,ht,lpSaveFileName
		.else
			invoke Load_Image,addr szDefPicture,wt,ht,0
		.endif
	.endif
	ret

GetImage endp

GdipInit proc

	; Initialize GDI+ Librery
	mov		gdiplSTI.GdiplusVersion,1
	push	NULL
	lea		eax,gdiplSTI
	push	eax
	lea		eax,token
	push	eax
	call	GdiplusStartup
	; Get Gdi+ jpeg encoder clsid for saving jpeg's
	invoke GetEncoderClsid
	ret

GdipInit endp
