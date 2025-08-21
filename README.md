Scripts for portable Lua toy creation on Windows

## Install
```powershell
.\install_update_all.ps1
```

## Installation scripts
* `ExecutionPolicy` should be set to `RemoteSigned` and unblock `ps1` files
    ```powershell
    ExecutionPolicy # Check
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned # Set as RemoteSigned
    Unblock-File *.ps1 # Unblock ps1 files
    ```
* MinGW
    * install_mingw.ps1 - Install MinGW
* Lua
    * install_lua.ps1 - Install Lua
* Vscode, Git
    * install_update_vscode_git.ps1 - Install vscode, git. Update vscode
    * run_vscode.cmd - Run vscode
* delete_all.cmd - Delete all installed

## Others
* playground/ - Workspace for Lua practice
