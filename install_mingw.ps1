$uri = "https://api.github.com/repos/brechtsanders/winlibs_mingw/releases"
$json = Invoke-WebRequest -UseBasicParsing -Uri $uri | ConvertFrom-Json


# Find first release that has the specified runtime asset
$runtimeVersion = "msvcrt"
foreach ($release in $json) {
    $asset = $release.assets | Where-Object {
        $_.name -match "posix-seh" -and $_.name -match ".zip" -and
        $_.name -notmatch "llvm" -and $_.name -notmatch ".sha" -and
        $_.name -match $runtimeVersion
    }
    if ($asset) {
        break
    }
}

$mingwDownloadURL = $asset.browser_download_url

# write-output $release.name
# write-output $mingwDownloadURL

import-module bitstransfer
new-item -force -ea 0 -itemtype directory -path mingw | out-null
start-bitstransfer -destination mingw.zip -source $mingwDownloadURL
tar -xf mingw.zip -C mingw
remove-item -force mingw.zip