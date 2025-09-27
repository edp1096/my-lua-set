$uri = "https://api.github.com/repos/bjornbytes/lovr/releases"
$json = Invoke-WebRequest -UseBasicParsing -Uri $uri | ConvertFrom-Json

# Find first release that has ucrt asset
foreach ($release in $json) {
    $asset = $release.assets | Where-Object {
        $_.name -match "-win64" -and $_.name -match ".zip"
    }
    if ($asset) {
        break
    }
}

$lovrDownloadURL = $asset.browser_download_url
$version = $release.tag_name.replace("v", "")

# write-output $release.name
# write-output $lovrDownloadURL

import-module bitstransfer
new-item -force -ea 0 -itemtype directory -path lovr | out-null
start-bitstransfer -destination lovr.zip -source $lovrDownloadURL
tar -xf lovr.zip -C lovr

copy -force -recurse -path "love-$version-win64\*" "lovr"
remove-item -force -ea 0 -recurse "love-$version-win64" | out-null
remove-item -force lovr.zip
