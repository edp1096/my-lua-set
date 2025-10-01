write-output "MinGW" ; .\install_mingw.ps1
write-output "CMake" ; .\install_cmake.ps1
write-output "vscode, git" ; .\install_update_vscode_git.ps1
write-output "Lua" ; .\install_lua.ps1
write-output "LuaRocks" ; .\install_luarocks.ps1
write-output "LuaJIT" ; .\install_luajit.ps1 # Since clone is the only way, Git is necessary

write-output "Love2D" ; .\install_love2d.ps1
write-output "Defold" ; .\install_defold.ps1
write-output "Tiled" ; .\install_tiled.ps1
write-output "ResourceHacker" ; .\install_resource_hacker.ps1

# write-output "LibreSprite" ; .\install_libresprite.ps1
# write-output "Solar2D" ; .\install_solar2d.ps1
# write-output "Lovr" ; .\install_lovr.ps1

<# Webfont - not work so not use #>
# write-output "Add webfont for vscode" ; .\webfont_add_to_vscode.ps1
# write-output "Fix checksum of vscode for webfont" ; .\webfont_fix_vscode_checksum.ps1

pause