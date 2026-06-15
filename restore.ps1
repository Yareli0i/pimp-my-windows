#Requires -Version 5.1
# ============================================
#  pimp-my-windows - RESTORE SCRIPT
#  Run on a fresh Windows install (as Administrator)
# ============================================

$ErrorActionPreference = "Continue"
$root = $PSScriptRoot
$configs = Join-Path $root "configs"

function Write-Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[!!] $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "[ERR] $msg" -ForegroundColor Red }

# --- Check admin rights ---
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Err "Run this script as Administrator! (right-click PowerShell -> Run as admin)"
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# --- Check configs folder exists ---
if (-not (Test-Path $configs)) {
    Write-Err "configs folder not found at $configs"
    exit 1
}

# ============================================
#  PHASE 1: Install programs via winget
# ============================================
Write-Step "PHASE 1: Installing programs"

$apps = @(
    "Microsoft.PowerShell",
    "JanDeDobbeleer.OhMyPosh",
    "Flow-Launcher.Flow-Launcher",
    "RamenSoftware.Windhawk",
    "StartIsBack.StartAllBack"
)

foreach ($app in $apps) {
    Write-Host "Installing $app ..." -ForegroundColor Gray
    winget install --id $app --source winget --accept-package-agreements --accept-source-agreements -h 2>$null
    if ($LASTEXITCODE -eq 0) { Write-OK $app } else { Write-Warn "$app (may already be installed or needs manual check)" }
}

# --- Nerd Font via Oh My Posh ---
Write-Host "Installing JetBrainsMono Nerd Font ..." -ForegroundColor Gray
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
oh-my-posh font install JetBrainsMono 2>$null
if ($LASTEXITCODE -eq 0) { Write-OK "JetBrainsMono Nerd Font" } else { Write-Warn "Nerd Font (install manually: oh-my-posh font install JetBrainsMono)" }

# ============================================
#  PHASE 2: Deploy config files
# ============================================
Write-Step "PHASE 2: Deploying configs"

# 2.1 Oh My Posh theme -> home
$amroSrc = Join-Path $configs "ohmyposh\amro.omp.json"
if (Test-Path $amroSrc) {
    Copy-Item $amroSrc "$HOME\amro.omp.json" -Force
    Write-OK "amro theme -> $HOME"
} else { Write-Warn "amro theme not found in backup" }

# 2.2 PowerShell profile -> actual $PROFILE path
$profileSrc = Join-Path $configs "powershell\profile.ps1"
if (Test-Path $profileSrc) {
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Force -Path $profileDir | Out-Null }
    Copy-Item $profileSrc $PROFILE -Force
    Write-OK "PowerShell profile -> $PROFILE"
} else { Write-Warn "profile not found in backup" }

# 2.3 Windows Terminal settings
$termDst = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$termSrc = Join-Path $configs "terminal\settings.json"
if (Test-Path $termSrc) {
    $termDir = Split-Path $termDst -Parent
    if (Test-Path $termDir) {
        Copy-Item $termSrc $termDst -Force
        Write-OK "Terminal settings deployed"
    } else { Write-Warn "Terminal not installed yet - open it once, then re-run or copy manually" }
} else { Write-Warn "terminal settings not found in backup" }

# 2.4 Flow Launcher settings (reset window coordinates)
$flowSrc = Join-Path $configs "flow\Settings\Settings.json"
$flowDstDir = "$env:APPDATA\FlowLauncher\Settings"
if (Test-Path $flowSrc) {
    # close Flow if running
    Get-Process "Flow.Launcher" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    if (-not (Test-Path $flowDstDir)) { New-Item -ItemType Directory -Force -Path $flowDstDir | Out-Null }
    # load, null out coordinates, save
    try {
        $flowJson = Get-Content $flowSrc -Raw | ConvertFrom-Json
        $coordFields = @("WindowLeft","WindowTop","SettingWindowTop","SettingWindowLeft","CustomWindowLeft","CustomWindowTop","PreviousScreenWidth","PreviousScreenHeight","PreviousDpiX","PreviousDpiY")
        foreach ($f in $coordFields) { if ($flowJson.PSObject.Properties.Name -contains $f) { $flowJson.$f = 0 } }
        $flowJson | ConvertTo-Json -Depth 20 | Out-File (Join-Path $flowDstDir "Settings.json") -Encoding utf8
        Write-OK "Flow settings deployed (coordinates reset)"
    } catch {
        Copy-Item $flowSrc (Join-Path $flowDstDir "Settings.json") -Force
        Write-Warn "Flow settings copied as-is (coordinate reset failed)"
    }
} else { Write-Warn "Flow settings not found in backup" }

# 2.5 Flow themes
$flowThemesSrc = Join-Path $configs "flow\Themes"
if (Test-Path $flowThemesSrc) {
    $flowThemesDst = "$env:APPDATA\FlowLauncher\Themes"
    if (-not (Test-Path $flowThemesDst)) { New-Item -ItemType Directory -Force -Path $flowThemesDst | Out-Null }
    Copy-Item "$flowThemesSrc\*" $flowThemesDst -Recurse -Force
    Write-OK "Flow themes deployed"
}

# 2.6 Windhawk profile
$whSrc = Join-Path $configs "windhawk\userprofile.json"
$whDst = "$env:PROGRAMDATA\Windhawk\userprofile.json"
if (Test-Path $whSrc) {
    if (Test-Path (Split-Path $whDst -Parent)) {
        Copy-Item $whSrc $whDst -Force
        Write-OK "Windhawk profile deployed (verify mods manually!)"
    } else { Write-Warn "Windhawk not installed yet - install it, then copy windhawk\userprofile.json manually" }
} else { Write-Warn "Windhawk profile not found in backup" }

# ============================================
#  PHASE 3: Apply registry tweaks
# ============================================
Write-Step "PHASE 3: Applying registry"

$sabReg = Join-Path $configs "startallback\startallback.reg"
if (Test-Path $sabReg) {
    reg import $sabReg 2>$null
    if ($LASTEXITCODE -eq 0) { Write-OK "StartAllBack settings imported" } else { Write-Warn "SAB registry import issue" }
}

$accentReg = Join-Path $configs "windows-accent.reg"
if (Test-Path $accentReg) {
    reg import $accentReg 2>$null
    if ($LASTEXITCODE -eq 0) { Write-OK "Accent color imported" } else { Write-Warn "Accent registry import issue" }
}

# ============================================
#  PHASE 4: Manual checklist
# ============================================
Write-Step "DONE - Manual steps remaining"
Write-Host @"

Automatic part finished. Now do these MANUALLY:

1. RESTART the computer (or restart explorer.exe) so StartAllBack + accent apply.

2. WINDHAWK MODS - open Windhawk, verify these mods are installed & enabled:
   - Windows 11 Taskbar Styler (theme: SimplyTransparent)
   - Taskbar Background Helper
   - Windows 11 File Explorer Styler (theme: Minimal Explorer11)
   On a new Windows build mods may need re-checking/reinstall.

3. STARTALLBACK - open it, confirm only Start Menu section is active
   (Taskbar + Explorer sections OFF - we use Windhawk for those).

4. FLOW PLUGINS - open Flow, install plugins from configs\flow\installed-plugins.txt
   via Plugin Store (sp=Spotify, ob=Obsidian, steam=SteamFlow, yt=YouTube).
   Re-login to Spotify/Steam plugins (tokens were NOT backed up for security).

5. TERMINAL - set PowerShell 7 as default profile + "Windows Terminal" as
   default terminal app (Settings -> Startup).

6. WALLPAPERS - set up via Wallpaper Engine manually.

7. Run:  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   (if profile errors)

"@ -ForegroundColor White

Write-Host "=== Restore script finished ===" -ForegroundColor Cyan
