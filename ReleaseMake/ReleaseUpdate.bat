echo off
cls
rem echo Pakker ut Release.zip
rem ""Z:\Program Files\Compression Programs\WinRAR\WinRar.exe" a -m5 Release.Zip Release
rem pause
echo Oppdaterer addins
copy ..\Addins\AddinMana\AddinMana.dll Release\Addins
copy ..\Addins\AdvEdit\AdvEdit.dll Release\Addins
copy ..\Addins\AlexMenu\AlexMenu.dll Release\Addins
copy ..\Addins\Collapse\Collapse.dll Release\Addins
copy ..\Addins\CppParse\CppParse.dll Release\Addins
copy ..\Addins\CreateProtoEx\CreateProtoEx.dll Release\Addins
copy ..\Addins\CtrlNames\CtrlNames.dll Release\Addins
copy ..\Addins\DlgToWin\DlgToWin.dll Release\Addins
copy ..\Addins\FbHelp\FbHelp.dll Release\Addins
copy ..\Addins\FlipCase\FlipCase.dll Release\Addins
copy ..\Addins\FpHelp\FpHelp.dll Release\Addins
copy ..\Addins\masmParse\masmParse.dll Release\Addins
copy ..\Addins\Preview\Preview.dll Release\Addins
copy ..\Addins\ProjectTimer\ProjectTimer.dll Release\Addins
copy ..\Addins\ProjectZip\ProjectZip.dll Release\Addins
copy ..\Addins\PthExpl\PthExpl*.dll Release\Addins
copy ..\Addins\RADbg\RADbg.dll Release\Addins
copy ..\Addins\RADebug\RADebug.dll Release\Addins
copy ..\Addins\RadFavs\RadFavs.dll Release\Addins
copy ..\Addins\RadHelp\Source\RadHelp.dll Release\Addins
copy ..\Addins\ReallyRad\ReallyRad.dll Release\Addins
copy ..\Addins\ResourceID\ResourceID.dll Release\Addins
copy ..\Addins\solParse\solParse.dll Release\Addins
copy ..\Addins\SourceSafe\SourceSafe.dll Release\Addins
copy ..\Addins\StyleMana\StyleMana.dll Release\Addins
copy ..\Addins\TbrCreate\TbrCreate.exe Release\Addins
copy ..\Addins\UpdateChecker\UpdateChecker.dll Release\Addins
copy ..\Addins\RadAsm.inc Release\Masm\Inc

rem copy ..\Addins\\*.dll Release\Addins

echo Oppdaterer addins hjelpefiler
copy ..\Addins\AddinMana\AddinMana.txt Release\Addins\Help
copy ..\Addins\AdvEdit\AdvEdit.txt Release\Addins\Help
copy ..\Addins\AlexMenu\AlexMenu.txt Release\Addins\Help
copy ..\Addins\Collapse\Collapse.txt Release\Addins\Help
copy ..\Addins\CreateProtoEx\CreateProtoEx.txt Release\Addins\Help
copy ..\Addins\CtrlNames\CtrlNames.txt Release\Addins\Help
copy ..\Addins\DlgToWin\DlgToWin.txt Release\Addins\Help
copy ..\Addins\FlipCase\FlipCase.txt Release\Addins\Help
copy ..\Addins\Preview\Preview.txt Release\Addins\Help
copy ..\Addins\ProjectTimer\ProjectTimer.txt Release\Addins\Help
copy ..\Addins\ProjectZip\ProjectZip.txt Release\Addins\Help
copy ..\Addins\PthExpl\PthExpl*.txt Release\Addins\Help
copy ..\Addins\RADbg\RADbg.txt Release\Addins\Help
copy ..\Addins\RADebug\RADebug.txt Release\Addins\Help
copy ..\Addins\RadFavs\RadFavs.txt Release\Addins\Help
copy ..\Addins\RadHelp\RadHelp.txt Release\Addins\Help
copy ..\Addins\ReallyRad\ReallyRad.txt Release\Addins\Help
copy ..\Addins\ResourceID\ResourceID.txt Release\Addins\Help
copy ..\Addins\SourceSafe\SourceSafe.txt Release\Addins\Help
copy ..\Addins\StyleMana\StyleMana.txt Release\Addins\Help
copy ..\Addins\UpdateChecker\UpdateChecker.txt Release\Addins\Help


rem copy ..\Addins\\*.txt Release\Addins\Help

pause

echo Oppdaterer custom controls
copy ..\..\CodeComplete\RACodeComplete.dll Release
copy ..\..\CodeComplete\RACodeComplete.inc Release\Masm\Inc

copy ..\..\FileBrowser\RAFile.dll Release
copy ..\..\FileBrowser\RAFile.inc Release\Masm\Inc

copy ..\..\Grid\RAGrid.dll Release
copy ..\..\Grid\RAGrid.inc Release\Masm\Inc

copy ..\..\HexEd\RAHexEd.dll Release
copy ..\..\HexEd\RAHexEd.inc Release\Masm\Inc

copy ..\..\Property\RAProperty.dll Release
copy ..\..\Property\RAProperty.inc Release\Masm\Inc

copy ..\..\SimEd\RAEdit.dll Release
copy ..\..\SimEd\RAEdit.inc Release\Masm\Inc

copy ..\..\SpreadSheet\SprSht.dll Release
copy ..\..\SpreadSheet\SpreadSheet.inc Release\Masm\Inc

pause

echo Oppdaterer Language
copy ..\Language\*.lng Release\Language
copy ..\RadLNG.exe Release\Language

Pause

echo Oppdaterer api filer
copy ..\ApiFiles\masmApiStruct.api Release\Masm
copy ..\ApiFiles\masmArray.api Release\Masm
copy ..\ApiFiles\masmType.api Release\Masm
copy ..\ApiFiles\cppArray.api Release\Cpp
copy ..\ApiFiles\cppType.api Release\Cpp
copy ..\ApiFiles\fbType.api Release\fb
copy ..\ApiFiles\fpType.api Release\fp

Pause

echo Oppdaterer RadASM
copy ..\RadASM.exe Release
copy ..\WhatsNew.txt Release

copy ..\RAHelp\RadASM.chm Release\Help
copy ..\RAHelp\RadASMini.rtf Release\Help

Pause
