# Download and install Tiled with dynamic filename detection
$repoURL = "https://api.github.com/repos/edp1096/tiled/releases/latest"

# Get latest release information from GitHub API
Write-Host "Fetching latest release information..."
$releaseInfo = Invoke-RestMethod -Uri $repoURL

# Find Windows x86_64 ZIP file
$asset = $releaseInfo.assets | Where-Object { $_.name -like "*Windows_x86_64.zip" }

if (-not $asset) {
    Write-Error "Could not find Windows x86_64 ZIP file in latest release"
    exit 1
}

$downloadURL = $asset.browser_download_url
$filename = $asset.name

Write-Host "Found file: $filename"
Write-Host "Download URL: $downloadURL"

# Create directory and download
Import-Module BitsTransfer
New-Item -Force -ErrorAction SilentlyContinue -ItemType Directory -Path "tiled" | Out-Null

Write-Host "Downloading $filename..."
Start-BitsTransfer -Destination $filename -Source $downloadURL

# Extract the zip file
Write-Host "Extracting $filename..."
tar -xf $filename -C tiled

# Clean up
Remove-Item -Force $filename

Write-Host "Tiled installation completed in ./tiled/ directory"