$lua_version = "5.4.8"

$uri = "https://www.lua.org/download.html"
$response = Invoke-WebRequest -UseBasicParsing -Uri $uri
$htmlContent = $response.Content
if ($htmlContent -match "lua-(\d+\.\d+\.\d+)\.tar\.gz") {
    $lua_version = $matches[1]
    Write-Output "Found Lua version: $lua_version"
}
Write-Output "Lua version is $lua_version"

# Download and extract Lua source
Start-BitsTransfer -Destination "lua-$lua_version.zip" -Source "https://www.lua.org/ftp/lua-$lua_version.tar.gz"
tar -xf "lua-$lua_version.zip" -C .

# Set up directory paths
$work_dir = $PSScriptRoot
$lua_install_dir = Join-Path $work_dir "lua"
$compiler_bin_dir = Join-Path $work_dir "mingw\mingw64\bin"
$lua_build_dir = Join-Path $work_dir "lua-$lua_version"
$env:PATH = "$compiler_bin_dir;$env:PATH"

# Move to src and run make
cd $lua_build_dir
mingw32-make PLAT=mingw

# Create directory structure
New-Item -Force -ItemType Directory -Path $lua_install_dir | Out-Null
New-Item -Force -ItemType Directory -Path (Join-Path $lua_install_dir "doc") | Out-Null
New-Item -Force -ItemType Directory -Path (Join-Path $lua_install_dir "bin") | Out-Null
New-Item -Force -ItemType Directory -Path (Join-Path $lua_install_dir "include") | Out-Null

# Copy files to create binary distribution
Copy-Item (Join-Path $lua_build_dir "doc\*.*") (Join-Path $lua_install_dir "doc\") -Force
Copy-Item (Join-Path $lua_build_dir "src\*.exe") (Join-Path $lua_install_dir "bin\") -Force
Copy-Item (Join-Path $lua_build_dir "src\*.dll") (Join-Path $lua_install_dir "bin\") -Force
Copy-Item (Join-Path $lua_build_dir "src\luaconf.h") (Join-Path $lua_install_dir "include\") -Force
Copy-Item (Join-Path $lua_build_dir "src\lua.h") (Join-Path $lua_install_dir "include\") -Force
Copy-Item (Join-Path $lua_build_dir "src\lualib.h") (Join-Path $lua_install_dir "include\") -Force
Copy-Item (Join-Path $lua_build_dir "src\lauxlib.h") (Join-Path $lua_install_dir "include\") -Force
Copy-Item (Join-Path $lua_build_dir "src\lua.hpp") (Join-Path $lua_install_dir "include\") -Force

# Test Lua installation
& (Join-Path $lua_install_dir "bin\lua.exe") -e "print [[Hello Lua!]];print[[Simple Lua test successful!]]"

Write-Output ""

cd ..

Remove-Item -Force -Recurse -Path "lua-$lua_version.zip"
Remove-Item -Force -Recurse -Path "lua-$lua_version"
