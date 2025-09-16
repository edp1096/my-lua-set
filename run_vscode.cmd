@echo off

if not exist vscode (
    echo Folder 'vscode' not found & echo Please install first & ping -n 3 127.0.0.1 >nul & exit
)

set VSCODE_RUN_COMMAND=vscode\bin\code.cmd --reuse-window --extensions-dir vscode/data/extension --user-data-dir vscode/data/user-data

set HOME=%cd%\home
@REM set USERPROFILE=%cd%\home\user-profile
set APPDATA=%cd%\home\user-profile\AppData\Roaming
set LOCALAPPDATA=%cd%\home\user-profile\AppData\Local

set GIT_CEILING_DIRECTORIES=%cd%\playground

set PATH=%cd%\my_cmds;%cd%\bin;C:\Windows;C:\Windows\System;C:\Windows\System32
set PATH=%cd%\git;%cd%\git\cmd;%cd%\git\mingw64\bin;%cd%\git\usr\bin;%PATH%

if exist mingw (
    set PATH=%cd%\mingw\mingw64\bin;%cd%\mingw\mingw64\x86_64-w64-mingw32\bin;%PATH%
)
if exist cmake (
    set PATH=%cd%\cmake\bin;%PATH%
)
if exist xmake (
    set PATH=%cd%\xmake;%PATH%
)
if exist lua (
    set PATH=%cd%\lua\bin;%cd%\lua\lib;%PATH%
    set LUA_INCLUDE_DIR=%cd%\lua\include
    set LUA_LIBRARIES=%cd%\lua\lib
)
if exist love2d (
    set PATH=%cd%\love2d;%PATH%
)
if exist defold (
    set PATH=%cd%\defold;%PATH%
)

@REM %SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -WindowStyle hidden "vscode\bin\code.cmd --reuse-window --extensions-dir vscode/data/extension --user-data-dir vscode/data/user-data"
echo Set WshShell = CreateObject("WScript.Shell") > temp.vbs
echo WshShell.Run """%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe"" -NoProfile -Command ""%VSCODE_RUN_COMMAND%""", 0, False >> temp.vbs
cscript //nologo temp.vbs
del temp.vbs
