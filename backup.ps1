$ErrorActionPreference = "Continue"
$root = $PSScriptRoot
$configs = Join-Path $root "configs"

Write-Host "=== Backup started ===" -ForegroundColor Cyan

if (Test-Path $configs) { Remove-Item $configs -Recurse -Force }

$folders = @("terminal", "ohmyposh", "powershell", "flow", "windhawk", "startallback")
foreach ($f in $folders) {
    New-Item -ItemType Directory -Force -Path (Join-Path $configs $f) | Out-Null
}

$termSrc = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $termSrc) {
    Copy-Item $termSrc (Join-Path $configs "terminal\settings.json") -Force
    Write-Host "[OK] Terminal settings" -ForegroundColor Green
} else { Write-Host "[SKIP] Terminal" -ForegroundColor Yellow }

$amroSrc = "$HOME\amro.omp.json"
if (Test-Path $amroSrc) {
    Copy-Item $amroSrc (Join-Path $configs "ohmyposh\amro.omp.json") -Force
    Write-Host "[OK] amro theme" -ForegroundColor Green
} else { Write-Host "[SKIP] amro" -ForegroundColor Yellow }

if (Test-Path $PROFILE) {
    Copy-Item $PROFILE (Join-Path $configs "powershell\profile.ps1") -Force
    Write-Host "[OK] PowerShell profile" -ForegroundColor Green
} else { Write-Host "[SKIP] profile" -ForegroundColor Yellow }

$flowApp = "$env:APPDATA\FlowLauncher"
$flowMainSettings = Join-Path $flowApp "Settings\Settings.json"
if (Test-Path $flowMainSettings) {
    New-Item -ItemType Directory -Force -Path (Join-Path $configs "flow\Settings") | Out-Null
    Copy-Item $flowMainSettings (Join-Path $configs "flow\Settings\Settings.json") -Force
    Write-Host "[OK] Flow main settings" -ForegroundColor Green
}
$flowThemes = Join-Path $flowApp "Themes"
if (Test-Path $flowThemes) {
    Copy-Item $flowThemes (Join-Path $configs "flow\Themes") -Recurse -Force
    Write-Host "[OK] Flow themes" -ForegroundColor Green
}
$flowPlugins = Join-Path $flowApp "Plugins"
if (Test-Path $flowPlugins) {
    Get-ChildItem $flowPlugins -Directory | Select-Object -ExpandProperty Name | Out-File (Join-Path $configs "flow\installed-plugins.txt") -Encoding utf8
    Write-Host "[OK] Flow plugin list" -ForegroundColor Green
}

$whSrc = "$env:PROGRAMDATA\Windhawk\userprofile.json"
if (Test-Path $whSrc) {
    Copy-Item $whSrc (Join-Path $configs "windhawk\userprofile.json") -Force
    Write-Host "[OK] Windhawk profile" -ForegroundColor Green
} else { Write-Host "[SKIP] Windhawk" -ForegroundColor Yellow }

$sabReg = Join-Path $configs "startallback\startallback.reg"
reg export "HKCU\SOFTWARE\StartIsBack" $sabReg /y 2>$null
if (Test-Path $sabReg) { Write-Host "[OK] StartAllBack registry" -ForegroundColor Green }

reg export "HKCU\SOFTWARE\Microsoft\Windows\DWM" (Join-Path $configs "windows-accent.reg") /y 2>$null
Write-Host "[OK] Windows accent" -ForegroundColor Green

Write-Host "=== Backup done ===" -ForegroundColor Cyan
