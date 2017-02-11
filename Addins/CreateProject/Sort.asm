Sort proc 
	;Sort out folder name, active file name with and without extension
	
	;Get pointer of active file name whole path included
	mov	esi,[lpDStruct]
	mov	esi,(ADDINDATA ptr [esi]).lpFile 
@@:
	;Get folder name
	invoke InString,1,esi,SADD('\') ;find \
	test eax,eax ;test if found
	je @F ;jump if not found. Then folder name is in lpFolder buffer
	mov ecx,eax
	dec ecx
	lea edi,lpFolder
	rep movsb	;store folder name in buffer
	mov byte ptr[edi],0 ;terminate with 0
	inc esi
	jmp @B
@@:
	
	;Get file name without extension
	push esi ;store pointer to file name
	invoke InString,1,esi,SADD('.') ;find .
	mov ecx,eax
	dec ecx
	lea edi,lpFile
	rep movsb ;stor file name in buffer
	inc edi
	mov byte ptr[edi],0 ;terminate with 0
	
	;Get find file name with extension
	pop esi
	invoke lstrlen,esi
	mov ecx,eax
	lea edi,lpFileName ;point to file name with extension
	rep movsb ;stor file name in buffer
	mov byte ptr [edi],0 ;terminate with 0

	ret

Sort endp