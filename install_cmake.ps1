$uri = "https://api.github.com/repos/Kitware/CMake/releases"
$json = Invoke-WebRequest -UseBasicParsing -Uri $uri | ConvertFrom-Json

# Find first release that has ucrt asset
foreach ($release in $json) {
    $asset = $release.assets | Where-Object {
        $_.name -match "-windows-x86_64.zip" -and
        $_.name -notmatch "llvm" -and $_.name -notmatch ".sha"
    }
    if ($asset) {
        $fname = $asset.name
        break
    }
}

$cmakeDownloadURL = $asset.browser_download_url
$version = $release.tag_name.replace("v", "")

# write-output $version
# write-output $cmakeDownloadURL

import-module bitstransfer
new-item -force -ea 0 -itemtype directory -path cmake | out-null
start-bitstransfer -destination cmake.zip -source $cmakeDownloadURL
tar -xf cmake.zip -C .

# rename-item "cmake-$version-windows-x86_64" "cmake"
copy -force -recurse -path "cmake-$version-windows-x86_64\*" "cmake"

sleep 3

remove-item -force -ea 0 -recurse "cmake-$version-windows-x86_64" | out-null
remove-item -force cmake.zip
