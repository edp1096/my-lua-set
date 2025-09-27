$uri = "https://api.github.com/repos/git-for-windows/git/releases/latest"

$json = Invoke-WebRequest -UseBasicParsing -Uri $uri | ConvertFrom-Json

$versions = $json.name.Split()
$version = $versions[$versions.length - 1]
$version = $version -replace "\.windows.*",  ""
$version = $version -replace "v",  ""

$asset = $json.assets | Where-Object { $_.name -match "busybox-64-bit.zip" }

$gitDownloadURL = $asset.browser_download_url


import-module bitstransfer

new-item -force -ea 0 -itemtype directory -path git | out-null
start-bitstransfer -destination git.zip -source $gitDownloadURL
tar -xf git.zip -C git
remove-item -force git.zip


$workingMode = "install"
if (Test-Path -Path "vscode" -PathType Container) {
    $workingMode = "update"
}

if ($workingMode -eq "install") {
    new-item -force -ea 0 -itemtype directory -path vscode\data\user-data\User | out-null
}


start-bitstransfer -destination vscode.zip -source https://go.microsoft.com/fwlink/?Linkid=850641
tar -xf vscode.zip -C vscode
copy-item -force assets\*.json vscode\data\user-data\User
remove-item -force vscode.zip

.\shortcut_create.ps1
copy-item -force "Lua Code.lnk" $env:UserProfile\desktop

if ($workingMode -eq "update") {
    exit
}

cd vscode
$env:NODE_NO_WARNINGS = 1
bin\code.cmd --extensions-dir .\data\extension --user-data-dir .\data\user-data --install-extension vscode-icons-team.vscode-icons
bin\code.cmd --extensions-dir .\data\extension --user-data-dir .\data\user-data --install-extension sumneko.lua
bin\code.cmd --extensions-dir .\data\extension --user-data-dir .\data\user-data --install-extension ilich8086.launcher
bin\code.cmd --extensions-dir .\data\extension --user-data-dir .\data\user-data --install-extension actboy168.lua-debug
bin\code.cmd --extensions-dir .\data\extension --user-data-dir .\data\user-data --install-extension formulahendry.code-runner
$env:NODE_NO_WARNINGS = 0
cd ..
