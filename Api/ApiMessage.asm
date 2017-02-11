
.code

ApiMessageLoad proc
	LOCAL	buffer[256]:BYTE

	invoke GetPrivateProfileString,addr	szIniApi,addr iniApiMessage,addr szNULL,addr iniBuffer,sizeof iniBuffer,addr iniAsmFile
	.if	eax
		.while iniBuffer
			invoke strcpy,addr buffer,addr AppPath
			invoke strcat,addr buffer,addr szBackSlash
			invoke strlen,addr buffer
			invoke iniGetItem,addr iniBuffer,addr buffer[eax]
			invoke AddFileToWordList,'M',0,addr	buffer,2
		.endw
	.endif
	ret

ApiMessageLoad endp

