param(
    [string]$GameName = "MyGame"
)

# Fixed configuration
$SourceDir = "."
$CompileDir = "compile"
$DistDir = "dist"
$LoveExePath = "../../love2d/love.exe"
$Love2DDir = "../../love2d"
$ExcludePatterns = @("*.git*", "build*.ps1", "compile", "dist", "*.tmp", "*.bak", "*.tmx")
$ExcludeFiles = @()
$CleanDist = $true
$Verbose = $false

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

# Find Love2D executable
function Find-LoveExecutable {
    if (Test-Path $LoveExePath) {
        Write-Success "Found Love2D executable: $LoveExePath"
        return (Resolve-Path $LoveExePath).Path
    }
    
    Write-Error "Love2D executable not found at: $LoveExePath"
    Write-Error "Please ensure love.exe is available at the specified path."
    return $null
}

# Check if item should be excluded
function Test-ShouldExclude {
    param(
        [System.IO.FileSystemInfo]$Item,
        [string]$RelativePath
    )
    
    foreach ($pattern in $ExcludePatterns) {
        if ($Item.Name -like $pattern -or $RelativePath -like $pattern) {
            Write-Debug "Excluding by pattern '$pattern': $RelativePath"
            return $true
        }
    }
    
    foreach ($file in $ExcludeFiles) {
        if ($Item.Name -eq $file) {
            Write-Debug "Excluding by filename '$file': $RelativePath"
            return $true
        }
    }
    
    return $false
}

# Get relative path
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
        
        if (Test-ShouldExclude $item $relativePath) {
            $skipCount++
            continue
        }
        
        $sourceFile = $item.FullName
        $targetFile = Join-Path $TargetPath $item.Name
        
        if ($item.PSIsContainer) {
            Write-Debug "Entering subdirectory: $relativePath"
            $result = Process-Directory $sourceFile $targetFile $RootSource
            $successCount += $result.Success
            $errorCount += $result.Error
            $luaCount += $result.LuaFiles
            $copyCount += $result.CopyFiles
            $skipCount += $result.Skipped
        }
        elseif ($item.Extension -eq ".lua") {
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

# Create .love file (zip archive)
function New-LoveFile {
    param(
        [string]$SourceDirectory,
        [string]$OutputPath
    )
    
    Write-Info "Creating .love file..."
    
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        
        if (Test-Path $OutputPath) {
            Remove-Item $OutputPath -Force
        }
        
        [System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDirectory, $OutputPath)
        Write-Success "Created .love file: $OutputPath"
        return $true
    }
    catch {
        Write-Error "Failed to create .love file: $($_.Exception.Message)"
        return $false
    }
}

# Create executable by combining love.exe and .love file
function New-GameExecutable {
    param(
        [string]$LoveExePath,
        [string]$LoveFilePath,
        [string]$OutputExePath
    )
    
    Write-Info "Creating standalone executable..."
    
    try {
        $loveExeBytes = [System.IO.File]::ReadAllBytes($LoveExePath)
        $loveFileBytes = [System.IO.File]::ReadAllBytes($LoveFilePath)
        $combinedBytes = $loveExeBytes + $loveFileBytes
        [System.IO.File]::WriteAllBytes($OutputExePath, $combinedBytes)
        
        Write-Success "Created executable: $OutputExePath"
        return $true
    }
    catch {
        Write-Error "Failed to create executable: $($_.Exception.Message)"
        return $false
    }
}

# Copy Love2D DLL files to distribution folder
function Copy-Love2DDlls {
    param(
        [string]$Love2DPath,
        [string]$TargetPath
    )
    
    Write-Info "Copying Love2D DLL files..."
    
    try {
        if (-not (Test-Path $Love2DPath)) {
            Write-Error "Love2D directory not found: $Love2DPath"
            return $false
        }
        
        $dllFiles = Get-ChildItem -Path $Love2DPath -Filter "*.dll" -ErrorAction SilentlyContinue
        
        if ($dllFiles.Count -eq 0) {
            Write-Warning "No DLL files found in Love2D directory"
            return $true
        }
        
        $copiedCount = 0
        foreach ($dll in $dllFiles) {
            try {
                $targetFile = Join-Path $TargetPath $dll.Name
                Copy-Item $dll.FullName $targetFile -Force
                Write-Debug "Copied DLL: $($dll.Name)"
                $copiedCount++
            }
            catch {
                Write-Error "Failed to copy DLL $($dll.Name): $($_.Exception.Message)"
            }
        }
        
        Write-Success "Copied $copiedCount DLL files"
        return $true
    }
    catch {
        Write-Error "Error copying DLL files: $($_.Exception.Message)"
        return $false
    }
}

# Validate parameters
function Test-Parameters {
    if (-not (Test-Path $SourceDir)) {
        Write-Error "Source directory '$SourceDir' does not exist!"
        return $false
    }
    
    $mainLua = Join-Path $SourceDir "main.lua"
    if (-not (Test-Path $mainLua)) {
        Write-Warning "main.lua not found in source directory. This may not be a valid Love2D project."
    }
    
    $script:SourceDir = Resolve-Path $SourceDir
    $script:CompileDir = Join-Path $SourceDir $CompileDir
    $script:DistDir = Join-Path $SourceDir $DistDir
    $script:GameName = $GameName -replace '[\\/:*?"<>|]', '_'
    
    return $true
}

# Main execution
Write-Host "Love2D Game Build & Distribution Script" -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta

if (-not (Test-Parameters)) {
    exit 1
}

Write-Info "Source Directory: $SourceDir"
Write-Info "Compile Directory: $CompileDir" 
Write-Info "Distribution Directory: $DistDir"
Write-Info "Game Name: $GameName"
Write-Info "Love2D Path: $LoveExePath"

if (-not (Test-LuaJIT)) {
    exit 1
}

$loveExe = Find-LoveExecutable
if (-not $loveExe) {
    Write-Error "Cannot proceed without Love2D executable."
    exit 1
}

if ($CleanDist) {
    if (Test-Path $CompileDir) {
        Write-Warning "Cleaning existing compile directory..."
        Remove-Item $CompileDir -Recurse -Force
    }
    if (Test-Path $DistDir) {
        Write-Warning "Cleaning existing distribution directory..."
        Remove-Item $DistDir -Recurse -Force
    }
}

Write-Info "Starting build process..."

$startTime = Get-Date
$result = Process-Directory $SourceDir $CompileDir $SourceDir
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Info "`n========== Build Summary =========="
Write-Info "Processing Time: $($duration.TotalSeconds.ToString('F2')) seconds"
Write-Success "Total successful operations: $($result.Success)"
Write-Info "  - Lua files compiled: $($result.LuaFiles)"
Write-Info "  - Other files copied: $($result.CopyFiles)"
Write-Info "  - Files skipped: $($result.Skipped)"

if ($result.Error -gt 0) {
    Write-Error "Total failed operations: $($result.Error)"
    Write-Error "Build completed with errors. Skipping packaging steps."
    exit 1
}

Write-Success "Build completed successfully!"

# Create distribution directory
Write-Info "`nCreating distribution package..."
if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
}

# Create .love file in dist directory
$loveFilePath = Join-Path $DistDir "$GameName.love"
if (New-LoveFile $CompileDir $loveFilePath) {
    $loveFileSize = (Get-Item $loveFilePath).Length
    Write-Info "Love file size: $([math]::Round($loveFileSize / 1KB, 2)) KB"
} else {
    Write-Error "Failed to create .love file"
    exit 1
}

# Create executable in dist directory
$exeFilePath = Join-Path $DistDir "$GameName.exe"
if (New-GameExecutable $loveExe $loveFilePath $exeFilePath) {
    $exeFileSize = (Get-Item $exeFilePath).Length
    Write-Info "Executable size: $([math]::Round($exeFileSize / 1MB, 2)) MB"
} else {
    Write-Error "Failed to create executable"
    exit 1
}

# Copy Love2D DLL files to dist folder
if (-not (Copy-Love2DDlls $Love2DDir $DistDir)) {
    Write-Error "Failed to copy Love2D DLL files"
    exit 1
}

Write-Info "`n========== Final Summary =========="
Write-Info "Compile directory: $CompileDir (compiled game files)"
Write-Success "Distribution package: $DistDir"
Write-Info "  - $GameName.love (Love2D game file)"
Write-Info "  - $GameName.exe (standalone executable)"  
Write-Info "  - *.dll (Love2D runtime libraries)"
Write-Info "=========================================="
Write-Success "Distribution packaging completed!"
Write-Info "You can distribute the entire 'dist' folder."