## Run
```powershell
mingw32-make
lua main.lua
```

## Compile and run
```powershell
luac -o main.luac .\main.lua
luac -s -o main.luac .\main.lua # Strip debug info

lua .\main.luac
```

## srLua
First, compile and copy from `playground/srLua`
```powershell
./srglue.exe ./srlua.exe ./main.lua say.exe
./say.exe
# Hello world!
# Goodbye world!
```
