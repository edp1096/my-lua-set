param(
    [string]$ExePath = "game.exe",
    [string]$IcoPath = "game-icon.ico",
    [switch]$h,
    [switch]$Help
)

# Show help function
function Show-Help {
    Write-Host @"

apply_icon_with_reshacker.ps1 - Apply ICO to EXE using Resource Hacker CLI

USAGE:
    .\apply_icon_with_reshacker.ps1 [OPTIONS]

OPTIONS:
    -ExePath <path>    Target EXE file path (default: game.exe)
    -IcoPath <path>    Source ICO file path (default: game-icon.ico)
    -h, -Help          Show this help message

EXAMPLES:
    # Use default files
    .\apply_icon_with_reshacker.ps1

    # Specify custom files
    .\apply_icon_with_reshacker.ps1 -ExePath "MyGame.exe" -IcoPath "my-icon.ico"

    # Full path example
    .\apply_icon_with_reshacker.ps1 -ExePath "dist\MyGame.exe" -IcoPath "assets\icon.ico"

REQUIREMENTS:
    - ResourceHacker.exe (or ResHacker.exe) must be in PATH or current directory
    - Download from: http://www.angusj.com/resourcehacker/

DESCRIPTION:
    This script applies an ICO file to an EXE file using Resource Hacker CLI.
    It tries both modern and legacy Resource Hacker syntax for compatibility.

"@
}

# Check for help flags
if ($h -or $Help) {
    Show-Help
    exit 0
}

# Color output functions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }

# Apply icon to executable using Resource Hacker CLI
function Set-ExecutableIcon {
    param(
        [string]$ExePath,
        [string]$IcoPath
    )
    
    Write-Info "Applying icon using Resource Hacker CLI..."
    Write-Info "Target EXE: $ExePath"
    Write-Info "Icon file: $IcoPath"
    
    # Find Resource Hacker
    $resourceHackerPath = $null
    $resourceHackerNames = @("ResourceHacker.exe", "ResHacker.exe")
    
    # Try current directory first
    foreach ($name in $resourceHackerNames) {
        if (Test-Path ".\$name") {
            $resourceHackerPath = ".\$name"
            Write-Info "Found Resource Hacker in current directory: $name"
            break
        }
    }
    
    # Try PATH if not found locally
    if (-not $resourceHackerPath) {
        foreach ($name in $resourceHackerNames) {
            try {
                $result = Get-Command $name -ErrorAction Stop
                $resourceHackerPath = $result.Source
                Write-Info "Found Resource Hacker in PATH: $name"
                break
            } catch {
                # Continue to next name
            }
        }
    }
    
    if (-not $resourceHackerPath) {
        Write-Error "Resource Hacker not found!"
        Write-Info "Download Resource Hacker from: http://www.angusj.com/resourcehacker/"
        Write-Info "Place ResourceHacker.exe in current directory or add to PATH"
        return $false
    }
    
    Write-Success "Using Resource Hacker: $resourceHackerPath"
    
    # Get absolute paths
    $absoluteExePath = (Resolve-Path $ExePath).Path
    $absoluteIcoPath = (Resolve-Path $IcoPath).Path
    
    # Try modern Resource Hacker syntax first
    Write-Info "`n=== Trying Modern Syntax ==="
    Write-Info "Command: -open `"$absoluteExePath`" -save `"$absoluteExePath`" -action addoverwrite -res `"$absoluteIcoPath`" -mask ICONGROUP,MAINICON,"
    
    try {
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $resourceHackerPath
        $processInfo.Arguments = "-open `"$absoluteExePath`" -save `"$absoluteExePath`" -action addoverwrite -res `"$absoluteIcoPath`" -mask ICONGROUP,MAINICON,"
        $processInfo.UseShellExecute = $false
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.CreateNoWindow = $true
        
        $process = [System.Diagnostics.Process]::Start($processInfo)
        $process.WaitForExit()
        
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $exitCode = $process.ExitCode
        
        Write-Info "Exit code: $exitCode"
        if ($stdout) { Write-Info "Output: $stdout" }
        if ($stderr) { Write-Info "Error output: $stderr" }
        
        if ($exitCode -eq 0) {
            Write-Success "✅ Icon successfully applied using modern syntax!"
            return $true
        } else {
            Write-Warning "Modern syntax failed, trying legacy syntax..."
        }
        
    } catch {
        Write-Warning "Modern syntax execution failed: $($_.Exception.Message)"
    }
    
    # Try legacy Resource Hacker syntax
    Write-Info "`n=== Trying Legacy Syntax ==="
    Write-Info "Command: -modify `"$absoluteExePath`", `"$absoluteExePath`", `"$absoluteIcoPath`", ICONGROUP, MAINICON, 0"
    
    try {
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $resourceHackerPath
        $processInfo.Arguments = "-modify `"$absoluteExePath`", `"$absoluteExePath`", `"$absoluteIcoPath`", ICONGROUP, MAINICON, 0"
        $processInfo.UseShellExecute = $false
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.CreateNoWindow = $true
        
        $process = [System.Diagnostics.Process]::Start($processInfo)
        $process.WaitForExit()
        
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $exitCode = $process.ExitCode
        
        Write-Info "Exit code: $exitCode"
        if ($stdout) { Write-Info "Output: $stdout" }
        if ($stderr) { Write-Info "Error output: $stderr" }
        
        if ($exitCode -eq 0) {
            Write-Success "✅ Icon successfully applied using legacy syntax!"
            return $true
        } else {
            Write-Error "❌ Legacy syntax also failed (exit code: $exitCode)"
            return $false
        }
        
    } catch {
        Write-Error "❌ Legacy syntax execution failed: $($_.Exception.Message)"
        return $false
    }
}

Write-Host "Resource Hacker Icon Applicator" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta

# Check if EXE file exists
if (-not (Test-Path $ExePath)) {
    Write-Error "EXE file not found: $ExePath"
    Write-Info "Use -h for help"
    exit 1
}

# Check if ICO file exists
if (-not (Test-Path $IcoPath)) {
    Write-Error "ICO file not found: $IcoPath"
    Write-Info "Use -h for help"
    exit 1
}

# Apply icon
if (Set-ExecutableIcon $ExePath $IcoPath) {
    Write-Success "`n🎉 Icon application completed successfully!"
    Write-Info "You can verify the icon by:"
    Write-Info "  - Right-clicking the EXE and checking Properties"
    Write-Info "  - Opening the EXE in Resource Hacker GUI"
    Write-Info "  - Checking Windows Explorer (may need to refresh icon cache)"
} else {
    Write-Error "`n💥 Icon application failed!"
    Write-Info "Manual solution: Open Resource Hacker GUI and use Action > Replace Icon"
    exit 1
}