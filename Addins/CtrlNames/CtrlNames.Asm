;#########################################################################
;	Assembler directives

.486
.model flat,stdcall
option casemap:none

;#########################################################################
;	Include file

	include CtrlNames.inc

.code

;#########################################################################
;	Common AddIn Procedures

DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD

	mov eax,hInst
	mov hInstance,eax
	mov eax,TRUE
	ret

DllEntry Endp

InstallDll proc uses ebx esi edi,hWin:DWORD,fOpt:DWORD

	;Get pointer to data struct
	invoke SendMessage,hWin,AIM_GETDATA,0,0	
	mov	lpData,eax
	;Get pointer to TYPES structures
	mov edi,[eax].ADDINDATA.lpCtlTypes
	mov esi,offset CtrlID
	mov ebx,offset OldPtr
	.while byte ptr [esi]
		mov eax,[edi].TYPES.lpidname
		mov [ebx],eax
		mov eax,[edi].TYPES.lpcaption
		mov [ebx+4],eax
		mov [edi].TYPES.lpidname,esi
		invoke lstrlen,esi
		lea esi,[esi+eax+1]
		mov [edi].TYPES.lpcaption,esi
		invoke lstrlen,esi
		lea esi,[esi+eax+1]
		lea edi,[edi+sizeof TYPES]
		lea ebx,[ebx+8]
	.endw
	mov eax,RAM_CLOSE
	xor ecx,ecx
	xor edx,edx
	ret 

InstallDll Endp

DllProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	.if uMsg==AIM_CLOSE
		push ebx
		push edi
		;Get pointer to TYPES structures
		mov	edi,lpData
		mov edi,[edi].ADDINDATA.lpCtlTypes
		;Restore old values
		mov ebx,offset OldPtr
		.while dword ptr [ebx]
			mov eax,[ebx]
			mov [edi].TYPES.lpidname,eax
			mov eax,[ebx+4]
			mov [edi].TYPES.lpcaption,eax
			lea ebx,[ebx+8]
			lea edi,[edi+sizeof TYPES]
		.endw
		pop edi
		pop ebx
	.endif
	mov eax,FALSE
	ret

DllProc Endp

;#########################################################################

End DllEntry
