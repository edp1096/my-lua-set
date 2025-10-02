@echo off

rmdir home /q/s 2>nul
rmdir vscode /q/s 2>nul
rmdir git /q/s 2>nul
rmdir mingw /q/s 2>nul
rmdir cmake /q/s 2>nul
rmdir lua /q/s 2>nul
rmdir luajit /q/s 2>nul
rmdir iup /q/s 2>nul
rmdir love2d /q/s 2>nul
rmdir lovr /q/s 2>nul
rmdir defold /q/s 2>nul
rmdir solar2d /q/s 2>nul
rmdir tiled /q/s 2>nul
rmdir resource_hacker /q/s 2>nul
rmdir aseprite /q/s 2>nul
rmdir libresprite /q/s 2>nul
rmdir memaospritecreator /q/s 2>nul

del "Lua Code.lnk" 2>nul
del "%UserProfile%\desktop\Lua Code.lnk" 2>nul
