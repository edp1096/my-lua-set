@echo off

rmdir home /q/s 2>nul
rmdir vscode /q/s 2>nul
rmdir git /q/s 2>nul
rmdir mingw /q/s 2>nul
rmdir cmake /q/s 2>nul
rmdir lua /q/s 2>nul
rmdir love2d /q/s 2>nul

del "Lua Code.lnk" 2>nul
del "%UserProfile%\desktop\Lua Code.lnk" 2>nul
