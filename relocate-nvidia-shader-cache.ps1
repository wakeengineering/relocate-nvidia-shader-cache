param(
    [switch]$WrapperLaunched,
    [string]$DXCache = "I:\NVIDIAShaderCache\DXCache",
    [string]$GLCache = "I:\NVIDIAShaderCache\GLCache"
)

if (-not $WrapperLaunched) {
    try {
        Add-Type -AssemblyName System.Windows.Forms | Out-Null
        [System.Windows.Forms.MessageBox]::Show(
            'This script must be launched via relocate-nvidia-shader-cache-wrapper.cmd so it can elevate and pass configuration safely.',
            'Run via wrapper',
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    } catch {
        Write-Error 'This script must be launched via relocate-nvidia-shader-cache-wrapper.cmd so it can elevate and pass configuration safely.'
    }
    exit 1
}

# Define target paths (Change these to your desired storage locations)
if ([string]::IsNullOrWhiteSpace($DXCache)) { $DXCache = "I:\NVIDIAShaderCache\DXCache" }
if ([string]::IsNullOrWhiteSpace($GLCache)) { $GLCache = "I:\NVIDIAShaderCache\GLCache" }

$dxcache = $DXCache
$glcache = $GLCache

$dxcache = $DXCache
$glcache = $GLCache


# Define local NVIDIA paths
$localNvidiaDir = "$env:LOCALAPPDATA\NVIDIA"
$localDXCache = Join-Path $localNvidiaDir "DXCache"
$localGLCache = Join-Path $localNvidiaDir "GLCache"

function Setup-Junction {
    param (
        [string]$SourcePath,
        [string]$TargetPath
    )

    # 1. Ensure Target Directory (the "real" storage) exists
    if (-not (Test-Path $TargetPath)) {
        Write-Host "Creating target directory: $TargetPath" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
    }

    $shouldCreate = $true

    if (Test-Path $SourcePath) {
        $item = Get-Item $SourcePath
        
        # Check if it's already a junction/link
        if ($item.Attributes -match "ReparsePoint") {
            $target = (Get-Item $SourcePath).Target
            if ($target -eq $TargetPath) {
                Write-Host "Link already correctly points to $TargetPath for $SourcePath. Skipping." -ForegroundColor Green
                $shouldCreate = $false
            } else {
                Write-Host "Link points to wrong location or is different type. Removing..." -ForegroundColor Yellow
                Remove-Item $SourcePath -Force -Recurse
            }
        } else {
            Write-Host "Directory $SourcePath exists but is not a link. Deleting to replace with junction..." -ForegroundColor Yellow
            # Note: This deletes existing cache files in the local folder!
            Remove-Item $SourcePath -Force -Recurse
        }
    }

    if ($shouldCreate) {
        Write-Host "Creating junction: $SourcePath -> $TargetPath" -ForegroundColor Cyan
        try {
            # Ensure parent directory exists (e.g. %LOCALAPPDATA%\NVIDIA)
            $parent = Split-Path $SourcePath
            if (-not (Test-Path $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }
            
            # Using Junction (Hard link for directories)
            New-Item -ItemType Junction -Path $SourcePath -Value $TargetPath -Force | Out-Null
            Write-Host "Successfully created junction." -ForegroundColor Green
        } catch {
            Write-Error "Failed to create junction: $_"
        }
    }
}

# Run for DXCache
Setup-Junction -SourcePath $localDXCache -TargetPath $dxcache

# Run for GLCache
Setup-Junction -SourcePath $localGLCache -TargetPath $glcache

Write-Host "`nOperation complete." -ForegroundColor Gray
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
