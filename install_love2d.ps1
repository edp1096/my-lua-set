$uri = "https://api.github.com/repos/love2d/love/releases"
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

$love2dDownloadURL = $asset.browser_download_url
$version = $release.tag_name.replace("v", "")

# write-output $release.name
# write-output $love2dDownloadURL

import-module bitstransfer
new-item -force -ea 0 -itemtype directory -path love2d | out-null
start-bitstransfer -destination love2d.zip -source $love2dDownloadURL
tar -xf love2d.zip -C .

copy -force -recurse -path "love-$version-win64\*" "love2d"
remove-item -force -ea 0 -recurse "love-$version-win64" | out-null
remove-item -force love2d.zip
