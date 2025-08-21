Scripts for portable Lua toy creation on Windows

## Installation
```powershell
.\install_all.ps1
```
* Trouble shooting - `ExecutionPolicy` should be set to `RemoteSigned` and unblock `ps1` files
    ```powershell
    ExecutionPolicy                                     # Check
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned # Set as RemoteSigned
    Unblock-File *.ps1                                  # Unblock ps1 files
    ```

## Scripts for installation
* MinGW
    * install_mingw.ps1 - Install [MinGW](https://github.com/brechtsanders/winlibs_mingw)
* Lua
    * install_lua.ps1 - Install Lua
    * install_luarocks.ps1 - Install LuaRocks
* Vscode, Git
    * install_update_vscode_git.ps1 - Install vscode, git. Update vscode
    * run_vscode.cmd - Run vscode
* delete_all.cmd - Delete all installed

## Folders
* playground - Workspace for Lua practice
* my_cmd - Place for custom scripts

## Note
* Environment paths - Make HOME, APPDATA, LOCALAPPDATA are changed. See `run_vscode.cmd`
