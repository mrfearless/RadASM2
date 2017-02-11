#include "C:\GoAsm\IncludeA\Comdef.inc"

Unknown STRUCT
   QueryInterface         DD
   AddRef               DD
   Release               DD
Unknown ends

IShellLink STRUCT
   IUnknown            Unknown      <>

   GetPath               DD
   GetIDList             DD
   SetIDList            DD
   GetDescription         DD
   SetDescription         DD
   GetWorkingDirectory      DD
   SetWorkingDirectory      DD
   GetArguments         DD
   SetArguments         DD
   GetHotkey            DD
   SetHotkey            DD
   GetShowCmd            DD
   SetShowCmd            DD
   GetIconLocation         DD
   SetIconLocation         DD
   SetRelativePath         DD
   Resolve               DD
   SetPath               DD
IShellLink ENDS

IPersistFile STRUCT
   IUnknown      Unknown      <>

   GetClassID      DD
   IsDirty         DD
   Load         DD
   Save         DD
   SaveCompleted   DD
   GetCurFile      DD
IPersistFile ENDS

.DATA
	IID_IShellLink		GUID GUID_IID_IShellLinkA
	CLSID_ShellLink		GUID GUID_CLSID_ShellLink
	IID_IPersistFile	GUID GUID_IID_IPersistFile
;##################################################################

.CODE

GetLinkTarget FRAME lpLINKPATH,lpbuffer
   LOCAL psl            :D
   LOCAL ppf            :D
   LOCAL pwsz            :D
   LOCAL wsz[MAX_PATH]      :W

   ; This procedure extracts the location (path) of the object referenced by a shortcut.
   ; lpLINKPATH contains the full path of the lnk file, lpbuffer is a buffer of the size
   ; MAX_PATH that recieves the resulting path of the referenced object. If lpLINKPATH and
   ; lpbuffer point to the same buffer the link path will be replaced by the referenced
   ; path. The procedure does not perform a size verification on the buffer so an exception
   ; may occur if the buffer size is less than MAX_PATH.

   lea eax,psl
   push eax
   lea eax,IID_IShellLink
   push eax
   push CLSCTX_INPROC_SERVER
   push NULL
   lea eax,CLSID_ShellLink
   push eax
   call CoCreateInstance
   cmp eax,S_OK
   je >.OleGood
      push eax
      jmp >>.OleBad
   .OleGood

   lea eax,ppf
   push eax
   lea eax,IID_IPersistFile
   push eax
   push [psl]
   mov edi,[psl]
   mov edi,[edi]
   call [edi+IShellLink.IUnknown.QueryInterface]
   cmp eax,S_OK
   je >.IPersistFileFound
      push eax
      jmp >.NoPersist
   .IPersistFileFound

  push MAX_PATH
  lea eax,wsz
  mov [pwsz],eax
  push eax
  push -1
  push [lpLINKPATH]
  push NULL
  push CP_ACP
  call MultiByteToWideChar

   push STGM_READ
   push [pwsz]
   push [ppf]
   mov edi,[ppf]
   mov edi,[edi]
   call [edi+IPersistFile.Load]
   cmp eax,S_OK
   je >.IPersistLoaded
      push eax
      jmp >.AllDone
   .IPersistLoaded

   push NULL
   push NULL
   push MAX_PATH
   push [lpbuffer]
   push [psl]
   mov edi,[psl]
   mov edi,[edi]
   call [edi+IShellLink.GetPath]
   cmp eax,NOERROR
   je >.Success
      push eax
      jmp >.AllDone
   .Success
      push S_OK

   .AllDone
   push [ppf]
   mov edi,[ppf]
   mov edi,[edi]
   call [edi+IPersistFile.IUnknown.Release]

   .NoPersist
   push [psl]
   mov edi,[psl]
   mov edi,[edi]
   call [edi+IShellLink.IUnknown.Release]

   .OleBad
   pop eax

   ret
endf
