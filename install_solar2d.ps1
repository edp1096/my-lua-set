# Replace 'your-username/your-repo' with your actual GitHub repository
$repoURL = "https://api.github.com/repos/edp1096/solar2d/releases/latest"

$releaseInfo = Invoke-RestMethod -Uri $repoURL
$asset = $releaseInfo.assets | Where-Object { $_.name -like "*Solar2D-Windows*.zip" }

if (-not $asset) {
    Write-Error "Solar2D Windows ZIP not found"
    exit 1
}

Import-Module BitsTransfer
New-Item -Force -ItemType Directory -Path "solar2d" | Out-Null

Write-Host "Downloading $($asset.name)..."
Start-BitsTransfer -Destination $asset.name -Source $asset.browser_download_url

Write-Host "Extracting..."
tar -xf $asset.name -C .
Remove-Item -Force $asset.name

Rename-Item -Path ".\Solar2D" -NewName "solar2d"

Write-Host "Solar2D installed."