param(
    [string]$SourceDir = ".",
    [string]$DistDir = "dist",
    [string[]]$ExcludePatterns = @("*.git*", "build*.ps1", "dist", "*.tmp", "*.bak", "*.tmx"),
    [string[]]$ExcludeFiles = @(),
    [switch]$CleanDist = $true,
    [switch]$Verbose = $false
)

# Color output functions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Debug { param($Message) if ($Verbose) { Write-Host "[DEBUG] $Message" -ForegroundColor DarkGray } }

# Check if LuaJIT is available
function Test-LuaJIT {
    try {
        $null = & luajit -v 2>$null
        if ($LASTEXITCODE -eq 0) {
            $version = & luajit -v 2>&1
            Write-Success "LuaJIT found: $($version[0])"
            return $true
        }
    }
    catch {
        Write-Error "LuaJIT not found in PATH. Please install LuaJIT or add it to your PATH."
        return $false
    }
    return $false
}

# Check if item should be excluded
function Test-ShouldExclude {
    param(
        [System.IO.FileSystemInfo]$Item,
        [string]$RelativePath
    )
    
    # Check exclude patterns (wildcards)
    foreach ($pattern in $ExcludePatterns) {
        if ($Item.Name -like $pattern -or $RelativePath -like $pattern) {
            Write-Debug "Excluding by pattern '$pattern': $RelativePath"
            return $true
        }
    }
    
    # Check exclude files (exact names)
    foreach ($file in $ExcludeFiles) {
        if ($Item.Name -eq $file) {
            Write-Debug "Excluding by filename '$file': $RelativePath"
            return $true
        }
    }
    
    return $false
}

# Get relative path using simple string manipulation
function Get-RelativePath {
    param(
        [string]$From,
        [string]$To
    )
    
    $From = $From.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if ($To.StartsWith($From, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $To.Substring($From.Length)
    }
    return $To
}

# Process files recursively
function Process-Directory {
    param(
        [string]$SourcePath,
        [string]$TargetPath,
        [string]$RootSource
    )
    
    Write-Debug "Processing directory: $SourcePath"
    
    # Create target directory if it doesn't exist
    if (-not (Test-Path $TargetPath)) {
        New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
        Write-Debug "Created directory: $TargetPath"
    }
    
    $items = Get-ChildItem -Path $SourcePath -ErrorAction SilentlyContinue
    $successCount = 0
    $errorCount = 0
    $luaCount = 0
    $copyCount = 0
    $skipCount = 0
    
    foreach ($item in $items) {
        $relativePath = Get-RelativePath $RootSource $item.FullName
        
        # Check if item should be excluded
        if (Test-ShouldExclude $item $relativePath) {
            $skipCount++
            continue
        }
        
        $sourceFile = $item.FullName
        $targetFile = Join-Path $TargetPath $item.Name
        
        if ($item.PSIsContainer) {
            # Recursively process subdirectory
            Write-Debug "Entering subdirectory: $relativePath"
            $result = Process-Directory $sourceFile $targetFile $RootSource
            $successCount += $result.Success
            $errorCount += $result.Error
            $luaCount += $result.LuaFiles
            $copyCount += $result.CopyFiles
            $skipCount += $result.Skipped
        }
        elseif ($item.Extension -eq ".lua") {
            # Compile Lua file
            try {
                Write-Debug "Compiling Lua: $sourceFile -> $targetFile"
                & luajit -b $sourceFile $targetFile 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Compiled: $relativePath"
                    $successCount++
                    $luaCount++
                } else {
                    Write-Error "Failed to compile: $relativePath"
                    $errorCount++
                }
            }
            catch {
                Write-Error "Error compiling $relativePath : $($_.Exception.Message)"
                $errorCount++
            }
        }
        else {
            # Copy other files
            try {
                Write-Debug "Copying: $sourceFile -> $targetFile"
                Copy-Item $sourceFile $targetFile -Force
                Write-Info "Copied: $relativePath"
                $successCount++
                $copyCount++
            }
            catch {
                Write-Error "Error copying $relativePath : $($_.Exception.Message)"
                $errorCount++
            }
        }
    }
    
    return @{ 
        Success = $successCount; 
        Error = $errorCount; 
        LuaFiles = $luaCount; 
        CopyFiles = $copyCount; 
        Skipped = $skipCount 
    }
}

# Validate parameters
function Test-Parameters {
    # Check source directory
    if (-not (Test-Path $SourceDir)) {
        Write-Error "Source directory '$SourceDir' does not exist!"
        return $false
    }
    
    # Resolve full paths
    $script:SourceDir = Resolve-Path $SourceDir
    if ($DistDir -notlike "*:*" -and -not $DistDir.StartsWith('\')) {
        # Relative path - make it relative to source directory
        $script:DistDir = Join-Path $SourceDir $DistDir
    }
    
    # Check if dist directory is inside source directory
    if ($DistDir.StartsWith($SourceDir, [System.StringComparison]::OrdinalIgnoreCase)) {
        $distName = Split-Path $DistDir -Leaf
        if ($distName -notin $ExcludePatterns) {
            $script:ExcludePatterns += $distName
        }
    }
    
    return $true
}

# Main execution
Write-Host "Universal Lua Build Script" -ForegroundColor Magenta
Write-Host "=========================" -ForegroundColor Magenta

# Validate parameters
if (-not (Test-Parameters)) {
    exit 1
}

Write-Info "Source Directory: $SourceDir"
Write-Info "Target Directory: $DistDir" 
Write-Info "Exclude Patterns: $($ExcludePatterns -join ', ')"
if ($ExcludeFiles.Count -gt 0) {
    Write-Info "Exclude Files: $($ExcludeFiles -join ', ')"
}

# Check LuaJIT
if (-not (Test-LuaJIT)) {
    exit 1
}

# Clean dist directory if requested
if ($CleanDist -and (Test-Path $DistDir)) {
    Write-Warning "Cleaning existing target directory..."
    Remove-Item $DistDir -Recurse -Force
}

Write-Info "Starting build process..."

# Process all files
$startTime = Get-Date
$result = Process-Directory $SourceDir $DistDir $SourceDir
$endTime = Get-Date
$duration = $endTime - $startTime

# Summary
Write-Info "`n========== Build Summary =========="
Write-Info "Processing Time: $($duration.TotalSeconds.ToString('F2')) seconds"
Write-Success "Total successful operations: $($result.Success)"
Write-Info "  - Lua files compiled: $($result.LuaFiles)"
Write-Info "  - Other files copied: $($result.CopyFiles)"
Write-Info "  - Files skipped: $($result.Skipped)"

if ($result.Error -gt 0) {
    Write-Error "Total failed operations: $($result.Error)"
} else {
    Write-Info "Total failed operations: 0"
}
Write-Info "===================================="

if ($result.Error -eq 0) {
    Write-Success "`nBuild completed successfully!"
    Write-Info "Output directory: $DistDir"
    
    # Check for common game frameworks
    if (Test-Path (Join-Path $DistDir "main.lua")) {
        Write-Info "Love2D project detected. Run with: love `"$DistDir`""
    }
    exit 0
} else {
    Write-Error "`nBuild completed with $($result.Error) errors."
    exit 1
}