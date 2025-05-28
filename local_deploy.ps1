# PowerShell deployment script for Windows

$AddonName = Split-Path -Leaf $PWD

Write-Host "Deploying $AddonName to local WoW installation..." -ForegroundColor Yellow

# Common WoW installation paths for Windows
$WowPaths = @(
    "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns",
    "C:\Program Files\World of Warcraft\_retail_\Interface\AddOns",
    "$env:PROGRAMFILES\World of Warcraft\_retail_\Interface\AddOns",
    "${env:PROGRAMFILES(x86)}\World of Warcraft\_retail_\Interface\AddOns"
)

# Find the WoW installation
$AddonPath = ""
foreach ($path in $WowPaths) {
    $retailPath = Split-Path -Parent (Split-Path -Parent $path)
    if (Test-Path $retailPath) {
        $AddonPath = $path
        break
    }
}

if (-not $AddonPath) {
    Write-Host "Error: Could not find WoW installation" -ForegroundColor Red
    Write-Host "Please make sure World of Warcraft is installed in one of these locations:"
    foreach ($path in $WowPaths) {
        $installPath = Split-Path -Parent (Split-Path -Parent $path)
        Write-Host "  - $installPath"
    }
    exit 1
}

# Create target directory
$TargetDir = Join-Path $AddonPath $AddonName
if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

# Copy files
Write-Host "Copying files to: $TargetDir"
Copy-Item -Path ".\*" -Destination $TargetDir -Recurse -Force -Exclude @("local_deploy.ps1", "local_deploy.sh", ".git", ".gitignore")

Write-Host "✓ $AddonName deployed successfully!" -ForegroundColor Green
Write-Host "Remember to reload your UI in-game with /reload" -ForegroundColor Yellow