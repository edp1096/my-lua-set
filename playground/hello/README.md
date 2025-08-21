## Run
```powershell
lua main.lua
```

## Compile and run
```powershell
luac -o hello.lc .\main.lua
luac -s -o hello.lc .\main.lua # Strip debug info

lua .\hello.lc
```
