echo off
cls
echo Deleting files
echo del Assembly.zip
del Assembly.zip
echo del HighLevel.zip
del HighLevel.zip
echo del Language.zip
del Language.zip
echo del RadASMIDE.zip
del RadASMIDE.zip
echo del RAHelp.zip
del RAHelp.zip
echo del Release.zip
del Release.zip
echo del Release\Addins\*.tmp
del Release\Addins\*.tmp
pause

echo off
cls
echo Lager RadASMIDE.zip
cd Release
"C:\Program Files\WinZip\winzip32.exe" -a -r -p ..\RadASMIDE.zip @..\ReleaseRadASMIDE.def
cd ..
pause

echo off
cls
echo Lager Assembly.zip
cd Release
"C:\Program Files\WinZip\winzip32.exe" -a -r -p ..\Assembly.zip @..\ReleaseAssembly.def
cd ..
pause

echo off
cls
echo Lager HighLevel.zip
cd Release
"C:\Program Files\WinZip\winzip32.exe" -a -r -p ..\HighLevel.zip @..\ReleaseHighLevel.def
cd ..
pause

echo off
cls
echo Lager Language.zip
cd Release
"C:\Program Files\WinZip\winzip32.exe" -a -r -p ..\Language.zip Language\*.*
cd ..
pause

echo off
cls
echo Lager RAHelp.zip
cd Release
"C:\Program Files\WinZip\winzip32.exe" -a -r -p ..\RAHelp.zip Help\RadASM.chm
cd ..
pause

echo off
cls
echo Lager Release.zip
cd Release
"C:\Program Files\WinZip\winzip32.exe" -a -r ..\Release.zip *.*
cd ..
pause
