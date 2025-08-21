Scripts for portable Lua toy creation on Windows

## Run
```powershell
.\install_update_all.ps1
```

## Scripts
* `ExecutionPolicy` should be set to `RemoteSigned` and unblock `ps1` files
    ```powershell
    ExecutionPolicy # Check
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned # Set as RemoteSigned
    Unblock-File *.ps1 # Unblock ps1 files
    ```
* delete_all.cmd - Delete all installed
* MinGW
    * install_update_mingw.ps1 - Install/update MinGW
* Lua
    * install_update_lua.ps1 - Install/update Lua
* Vscode, Git
    * install_update_vscode_git.ps1 - Install vscode, git. Update vscode
    * run_vscode.cmd - Run vscode

## Others
* playground/ - Workspace for Lua practice
