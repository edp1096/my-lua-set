## Run
```powershell
lua main.lua
```

## Compile and run
```powershell
luac -o hello.luac .\main.lua
luac -s -o hello.luac .\main.lua # Strip debug info

lua .\hello.luac
```
