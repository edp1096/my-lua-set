param(
    [string]$PngPath = "icon.png",
    [string]$IcoPath = "icon.ico"
)

Add-Type -AssemblyName System.Drawing

function Convert-PngToIcon {
    param(
        [string]$SourcePng,
        [string]$OutputIco
    )

    # Load original image
    $originalImage = [System.Drawing.Image]::FromFile((Resolve-Path $SourcePng).Path)
    $sizes = @(16, 32, 48, 64, 128, 256)

    # Create ICO file data
    $icoData = [System.Collections.Generic.List[byte]]::new()

    # ICO header (6 bytes)
    $icoData.AddRange([byte[]]@(0, 0, 1, 0))  # ICO signature
    $icoData.AddRange([BitConverter]::GetBytes([uint16]$sizes.Count))  # Number of images

    # Prepare image data
    $imageDataList = @()
    $dataOffset = 6 + ($sizes.Count * 16)  # Header + directory entries

    foreach ($size in $sizes) {
        Write-Host "Creating ${size}x${size} icon..." -ForegroundColor Cyan

        # Create resized bitmap
        $bitmap = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

        # High quality settings
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality

        # Clear background and draw image
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.DrawImage($originalImage, 0, 0, $size, $size)
        $graphics.Dispose()

        # Convert to PNG bytes
        $memoryStream = New-Object System.IO.MemoryStream
        $bitmap.Save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Png)
        $pngBytes = $memoryStream.ToArray()
        $memoryStream.Dispose()
        $bitmap.Dispose()

        # Create directory entry (16 bytes)
        $entry = [System.Collections.Generic.List[byte]]::new()

        if ($size -eq 256) {
            $entry.Add(0)  # Width (0 = 256)
            $entry.Add(0)  # Height (0 = 256)
        } else {
            $entry.Add([byte]$size)  # Width
            $entry.Add([byte]$size)  # Height
        }

        $entry.Add(0)  # Color count
        $entry.Add(0)  # Reserved
        $entry.AddRange([BitConverter]::GetBytes([uint16]1))  # Color planes
        $entry.AddRange([BitConverter]::GetBytes([uint16]32)) # Bits per pixel
        $entry.AddRange([BitConverter]::GetBytes([uint32]$pngBytes.Length))  # Data size
        $entry.AddRange([BitConverter]::GetBytes([uint32]$dataOffset))       # Data offset

        $icoData.AddRange($entry.ToArray())
        $imageDataList += ,$pngBytes
        $dataOffset += $pngBytes.Length
    }

    # Add image data
    foreach ($imageData in $imageDataList) {
        $icoData.AddRange($imageData)
    }

    # Write ICO file
    [System.IO.File]::WriteAllBytes($OutputIco, $icoData.ToArray())
    $originalImage.Dispose()
}

# Main execution
if (-not (Test-Path $PngPath)) {
    Write-Host "PNG file not found: $PngPath" -ForegroundColor Red
    exit 1
}

Write-Host "Converting $PngPath to $IcoPath..." -ForegroundColor Green

try {
    Convert-PngToIcon $PngPath $IcoPath
    Write-Host "ICO file created: $IcoPath" -ForegroundColor Green
} catch {
    Write-Host "Conversion failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}