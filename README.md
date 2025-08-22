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

## Run
After installation, you will see a shortcut on Windows Desktop. Just run it and write Lua code in vscode.

## Scripts for installation
* MinGW
    * install_mingw.ps1 - Install [MinGW](https://github.com/brechtsanders/winlibs_mingw) UCRT
* Lua
    * install_lua.ps1 - Install Lua
    * install_luarocks.ps1 - Install LuaRocks
* Vscode, Git
    * install_update_vscode_git.ps1 - Install vscode, git. Update vscode
    * run_vscode.cmd - Run vscode
* delete_all.cmd - Delete all installed programs and files except for the playground folder

## Folders
* playground - Workspace for Lua project
* my_cmd - Place your scripts or executable files here

## Note
* Environment paths - vscode runs with the environment variables changed. See `run_vscode.cmd`
