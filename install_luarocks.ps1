$lua_path = Join-Path $PSScriptRoot "lua"
if (-not (Test-Path $lua_path)) {
    Write-Warning "Lua folder not found at: $lua_path"
    Write-Output "Please ensure Lua is installed in the lua directory before running this script."

    pause
    exit 1
}

$uri = "https://api.github.com/repos/luarocks/luarocks/releases"
$json = Invoke-WebRequest -UseBasicParsing -Uri $uri | ConvertFrom-Json

foreach ($release in $json) {
    $asset = $release.assets | Where-Object {
        $_.name -match "-windows-64\.zip$" -and
        $_.name -notmatch "\.asc"
    } | Select-Object -First 1
    if ($asset) {
        break
    }
}

$luarocksDownloadURL = $asset.browser_download_url
$luarocksFilename = $asset.name

Write-Output "Found LuaRocks: $($release.name)"
Write-Output "Downloading: $luarocksFilename"

Start-BitsTransfer -Destination $luarocksFilename -Source $luarocksDownloadURL
tar -xf $luarocksFilename -C .

$luarocksExtractedDir = $luarocksFilename -replace '\.zip$', ''

# Set paths
$work_dir = $PSScriptRoot
$lua_install_dir = Join-Path $work_dir "lua"
$lua_bin_dir = Join-Path $lua_install_dir "bin"
$luarocks_extracted_path = Join-Path $work_dir $luarocksExtractedDir

# Move files to lua/bin and clean up
Copy-Item (Join-Path $luarocks_extracted_path "luarocks.exe") $lua_bin_dir -Force
Copy-Item (Join-Path $luarocks_extracted_path "luarocks-admin.exe") $lua_bin_dir -Force
Remove-Item -Force -Recurse $luarocks_extracted_path
Remove-Item -Force $luarocksFilename

$mingw_bin_dir = Join-Path $work_dir "mingw\mingw64\bin"

# Set LuaRocks configuration
& (Join-Path $lua_bin_dir "luarocks.exe") config lua_dir $lua_install_dir
& (Join-Path $lua_bin_dir "luarocks.exe") config lua_interpreter "lua.exe"
& (Join-Path $lua_bin_dir "luarocks.exe") config variables.CC "gcc"
& (Join-Path $lua_bin_dir "luarocks.exe") config variables.LD "gcc"
& (Join-Path $lua_bin_dir "luarocks.exe") config variables.AR "ar"
& (Join-Path $lua_bin_dir "luarocks.exe") config variables.RANLIB "ranlib"

Write-Output ""