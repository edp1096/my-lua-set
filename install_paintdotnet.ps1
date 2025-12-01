# Download and install Paint.NET portable
$repoURL = "https://api.github.com/repos/paintdotnet/release/releases/latest"

# Get latest release information from GitHub API
Write-Host "Fetching latest release information..."
$releaseInfo = Invoke-RestMethod -Uri $repoURL

# Find portable x64 ZIP file
$asset = $releaseInfo.assets | Where-Object { $_.name -like "paint.net.*.portable.x64.zip" }

if (-not $asset) {
    Write-Error "Could not find portable x64 ZIP file in latest release"
    exit 1
}

$downloadURL = $asset.browser_download_url
$filename = "paintdotnet.zip"

Write-Host "Found file: $($asset.name)"
Write-Host "Download URL: $downloadURL"

# Create directory and download
Import-Module BitsTransfer
New-Item -Force -ErrorAction SilentlyContinue -ItemType Directory -Path "paintdotnet" | Out-Null

Write-Host "Downloading $($asset.name)..."
Start-BitsTransfer -Destination $filename -Source $downloadURL

# Extract the zip file
Write-Host "Extracting $filename..."
tar -xf $filename -C paintdotnet

# Clean up
Remove-Item -Force $filename

Write-Host "Paint.NET installation completed in ./paintdotnet/ directory"
