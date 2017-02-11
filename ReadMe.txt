NOTE:
To do this you need a not yet released build of RadASM 2.2.0.9

Creating a RadASM project from existing sources.
------------------------------------------------

Here I will use masm examples. Other programming languages should work in a simular way.

Creating a RadASM project from sources in C:\masm32\examples\exampl01\3dframes
------------------------------------------------------------------------------

In this folder there are two source files, 3dframes.asm and rsrc.rc.
This means that it is a 'Win32 App' type project.

From RadASM File menu select New Project.
Select Assembler: masm
Select Project Type: Win32 App
Set Project Name to: 3dframes
Set Project Description to: 3dframes (or whatever you want)
Set Projects Folder to: C:\masm32\examples\exampl01
Click Next>
Do NOT select any template.
Click Next>
Make shure you uncheck the File Creation.
You might want to create the Bak folder.
Click Next>
Click Finish
You will get a warning: Folder exists. Create project anyway?
Click Yes
You should now have an empty project opened.
From RadASM Project menu select Add Existing / Files.
In the Add Existing Files dialog select Files Of Type: All Files
While holding Ctrl key click on 3dframes.asm and rsrc.rc
Click Open
This will add 3dframes.asm and rsrc.rc to the project.

By default RadASM wants the resource script to have a name identical to the project name.
You can choose to rename rsrc.rc to 3dframes.rc or use Project / Main Project Files
and change 3dframes.rc to rsrc.rc and 3dframes.res to rsrc.res

You are now ready to build the project.

Adding a new project type: Empty make.bat
-----------------------------------------

In masm.ini change the following:

[Project]
Type=Win32 App,Console App,Dll Project,Ocx Project,LIB Project,NMAKE Project,Win32 App (no res),Dos App,Dos App (.com),Driver (.sys),Empty make.bat

In masm.ini add the following:

[Empty make.bat]
Files=0,0,0,0,0
Folders=1,0,0
MenuMake=0,0,0,1,1,1,1,0,0,0
;x=FileToDelete/CheckExistsOnExit,
;(O)utput/(C)onsole/0,Command,
;MakeFile1[,MakeFile2[,MakeFile3...]]
1=0
2=0
3=5,O,build.bat
4=0,0,,5
5=0
6=0
7=0,0,"$E\OllyDbg",5

Creating a project with a .bat file to build the project.
---------------------------------------------------------

To ilustrate this create a build.bat file in C:\masm32\examples\exampl01\comctls with the following content

rc /V rsrc.rc
ml /c /coff /Cp /nologo comctls.asm
link /SUBSYSTEM:WINDOWS /RELEASE /VERSION:4.0 comctls.obj rsrc.res

Creating a RadASM project from sources in C:\masm32\examples\exampl01\comctls
------------------------------------------------------------------------------

In this folder there are two source files, comctls.asm and rsrc.rc.
There is also a build.bat file used to build the project.
This means that it is a 'Empty make.bat' type project.

From RadASM File menu select New Project.
Select Assembler: masm
Select Project Type: Empty make.bat
Set Project Name to: comctls
Set Project Description to: comctls (or whatever you want)
Set Projects Folder to: C:\masm32\examples\exampl01
Click Next>
Do NOT select any template.
Click Next>
Make shure you uncheck the File Creation.
You might want to create the Bak folder.
Click Next>
Click Finish
You will get a warning: Folder exists. Create project anyway?
Click Yes
You should now have an empty project opened.
From RadASM Project menu select Add Existing / Files.
In the Add Existing Files dialog select Files Of Type: All Files
While holding Ctrl key click on comctls.asm and rsrc.rc
Click Open
This will add comctls.asm and rsrc.rc to the project.

Now you can choose to rename build.bat to make.bat or use Project Options and change:

Link: 5,O,make.bat to 5,O,build.bat

You are now ready to build the project.

KetilO
