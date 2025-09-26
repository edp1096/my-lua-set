# LuaJIT Installation Script for Windows with MinGW

param(
    [string]$Branch = "v2.1"
)

$mingw_path = Join-Path $PSScriptRoot "mingw"
if (-not (Test-Path $mingw_path)) {
    Write-Warning "MinGW folder not found at: $mingw_path"
    Write-Output "Please ensure MinGW is installed in the mingw directory before running this script."
    pause
    exit 1
}

$git_path = Join-Path $PSScriptRoot "git"
if (-not (Test-Path $git_path)) {
    Write-Warning "Git folder not found at: $git_path"
    Write-Output "Please ensure Git is installed in the git directory before running this script."
    pause
    exit 1
}

Write-Output "LuaJIT branch: $Branch"

# Set up directory paths
$work_dir = $PSScriptRoot
$luajit_install_dir = Join-Path $work_dir "luajit"
$compiler_bin_dir = Join-Path $work_dir "mingw\mingw64\bin"
$git_dir = Join-Path $work_dir "git\cmd"
$luajit_build_dir = Join-Path $work_dir "luajit_src"
$env:PATH = "$compiler_bin_dir;$git_dir;$env:PATH"

# Clone LuaJIT repository
git clone --depth 1 --branch $Branch "https://github.com/LuaJIT/LuaJIT.git" $luajit_build_dir

# Move to src and run make
cd $luajit_build_dir
mingw32-make "CC=gcc" "TARGET_SYS=Windows"

# Create directory structure
New-Item -Force -ItemType Directory -Path $luajit_install_dir | Out-Null
New-Item -Force -ItemType Directory -Path (Join-Path $luajit_install_dir "bin") | Out-Null
New-Item -Force -ItemType Directory -Path (Join-Path $luajit_install_dir "lib") | Out-Null
New-Item -Force -ItemType Directory -Path (Join-Path $luajit_install_dir "include") | Out-Null
New-Item -Force -ItemType Directory -Path (Join-Path $luajit_install_dir "share\luajit-2.1\jit") | Out-Null

# Copy files to create binary distribution
Copy-Item (Join-Path $luajit_build_dir "src\luajit.exe") (Join-Path $luajit_install_dir "bin\") -Force
Copy-Item (Join-Path $luajit_build_dir "src\lua51.dll") (Join-Path $luajit_install_dir "bin\") -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $luajit_build_dir "src\*.lib") (Join-Path $luajit_install_dir "lib\") -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $luajit_build_dir "src\*.a") (Join-Path $luajit_install_dir "lib\") -Force -ErrorAction SilentlyContinue
Copy-Item (Join-Path $luajit_build_dir "src\luajit.h") (Join-Path $luajit_install_dir "include\") -Force
Copy-Item (Join-Path $luajit_build_dir "src\lua.h") (Join-Path $luajit_install_dir "include\") -Force
Copy-Item (Join-Path $luajit_build_dir "src\lualib.h") (Join-Path $luajit_install_dir "include\") -Force
Copy-Item (Join-Path $luajit_build_dir "src\lauxlib.h") (Join-Path $luajit_install_dir "include\") -Force
Copy-Item (Join-Path $luajit_build_dir "src\luaconf.h") (Join-Path $luajit_install_dir "include\") -Force
Copy-Item (Join-Path $luajit_build_dir "src\jit\*") (Join-Path $luajit_install_dir "share\luajit-2.1\jit\") -Force -ErrorAction SilentlyContinue

## Create compatibility executables
#Copy-Item (Join-Path $luajit_install_dir "bin\luajit.exe") (Join-Path $luajit_install_dir "bin\lua.exe") -Force
#Copy-Item (Join-Path $luajit_install_dir "bin\luajit.exe") (Join-Path $luajit_install_dir "bin\luac.exe") -Force

# Test LuaJIT installation
& (Join-Path $luajit_install_dir "bin\luajit.exe") -e "print('Hello LuaJIT!'); print('LuaJIT test successful!')"

# Test bytecode compilation
& (Join-Path $luajit_install_dir "bin\luajit.exe") -b -e "print('bytecode test')" "test.out"
if (Test-Path "test.out") {
    Write-Output "Bytecode compilation test successful"
    Remove-Item "test.out" -Force
}

Write-Output ""

cd ..

Remove-Item -Force -Recurse -Path $luajit_build_dir