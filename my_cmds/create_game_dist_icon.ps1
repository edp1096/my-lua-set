param(
    [string]$ExePath = "game.exe",
    [string]$IcoPath = "icon.ico",
    [switch]$h,
    [switch]$Help
)

# Show help function
function Show-Help {
    Write-Host @"

create_game_dist_icon.ps1 - Apply ICO to EXE using Resource Hacker CLI

USAGE:
    .\create_game_dist_icon.ps1 [OPTIONS]

OPTIONS:
    -ExePath <path>    Target EXE file path (default: game.exe)
    -IcoPath <path>    Source ICO file path (default: icon.ico)
    -h, -Help          Show this help message

EXAMPLES:
    # Use default files
    .\create_game_dist_icon.ps1

    # Specify custom files
    .\create_game_dist_icon.ps1 -ExePath "MyGame.exe" -IcoPath "my-icon.ico"

    # Full path example
    .\create_game_dist_icon.ps1 -ExePath "dist\MyGame.exe" -IcoPath "assets\icon.ico"

REQUIREMENTS:
    - ResourceHacker.exe (or ResHacker.exe) must be in PATH or current directory
    - Download from: http://www.angusj.com/resourcehacker/

DESCRIPTION:
    This script applies an ICO file to an EXE file using Resource Hacker CLI.
    It tries multiple icon group IDs and both modern and legacy Resource Hacker syntax
    for maximum compatibility with Love2D games and other executables.

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
    
    # Try different icon group IDs commonly used in Love2D and other executables
    $iconGroupIds = @("MAINICON", "1", "2000", "101", "128", "32512")
    
    foreach ($iconId in $iconGroupIds) {
        Write-Info "`n=== Trying Icon Group: $iconId ==="
        
        # Try modern Resource Hacker syntax first
        Write-Info "Trying modern syntax with ICONGROUP,$iconId,0..."
        try {
            $processInfo = New-Object System.Diagnostics.ProcessStartInfo
            $processInfo.FileName = $resourceHackerPath
            $processInfo.Arguments = "-open `"$absoluteExePath`" -save `"$absoluteExePath`" -action addoverwrite -res `"$absoluteIcoPath`" -mask ICONGROUP,$iconId,0"
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
                Write-Success "Icon successfully applied using modern syntax with ICONGROUP,$iconId,0!"
                return $true
            }
            
        } catch {
            Write-Info "Modern syntax failed: $($_.Exception.Message)"
        }
        
        # Try legacy Resource Hacker syntax
        Write-Info "Trying legacy syntax with ICONGROUP,$iconId,0..."
        try {
            $processInfo = New-Object System.Diagnostics.ProcessStartInfo
            $processInfo.FileName = $resourceHackerPath
            $processInfo.Arguments = "-modify `"$absoluteExePath`", `"$absoluteExePath`", `"$absoluteIcoPath`", ICONGROUP, $iconId, 0"
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
                Write-Success "Icon successfully applied using legacy syntax with ICONGROUP,$iconId,0!"
                return $true
            }
            
        } catch {
            Write-Info "Legacy syntax failed: $($_.Exception.Message)"
        }
        
        Write-Warning "Icon Group $iconId failed, trying next..."
    }
    
    Write-Error "All icon group IDs failed!"
    Write-Info "Manual solution:"
    Write-Info "  1. Open Resource Hacker GUI"
    Write-Info "  2. Open: $absoluteExePath"
    Write-Info "  3. Look at Icon Group folder to see existing IDs"
    Write-Info "  4. Use Action > Replace Icon to manually replace"
    return $false
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
    Write-Success "`nIcon application completed successfully!"
    Write-Info "You can verify the icon by:"
    Write-Info "  - Right-clicking the EXE and checking Properties"
    Write-Info "  - Opening the EXE in Resource Hacker GUI"
    Write-Info "  - Checking Windows Explorer (may need to refresh icon cache)"
} else {
    Write-Error "`nIcon application failed!"
    Write-Info "Manual solution: Open Resource Hacker GUI and use Action > Replace Icon"
    exit 1
}