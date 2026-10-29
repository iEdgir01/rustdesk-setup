# Installs RustDesk (if missing) and points it at the Fixetics self-hosted server.
# Run in an elevated PowerShell:
#   irm https://raw.githubusercontent.com/iEdgir01/rustdesk-setup/main/setup.ps1 | iex
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Exported from Settings > Network (reversed base64 of host/relay/key). The key is public by design.
$cfg = '==Qfi0zdUBlWHRDS6VWVo50Tw8GarcFM0FFeHVTcpJVTsR2SyUDNr8GMEVzalp3ciojI5V2aiwiIiojIpBXYiwiIhpnLvNmLzNWa0VGepZmLrNXZkR3c1JnI6ISehxWZyJCLiEmeu82YuM3YpRXZ4lmZus2clRGdzVnciojI0N3boJye'

$admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $admin) { throw 'Run PowerShell as Administrator, then paste the command again.' }

$exe = "$env:ProgramFiles\RustDesk\rustdesk.exe"
if (-not (Test-Path $exe)) {
    Write-Host 'Downloading RustDesk...'
    $rel = Invoke-RestMethod https://api.github.com/repos/rustdesk/rustdesk/releases/latest
    $url = ($rel.assets | Where-Object name -like '*x86_64.exe' | Select-Object -First 1).browser_download_url
    $tmp = "$env:TEMP\rustdesk-$($rel.tag_name).exe"
    Invoke-WebRequest $url -OutFile $tmp -UseBasicParsing
    Write-Host "Installing RustDesk $($rel.tag_name)..."
    Start-Process $tmp '--silent-install'
    # ponytail: the installer returns before it finishes; poll for the service, 90s ceiling
    for ($i = 0; $i -lt 90 -and -not (Get-Service RustDesk -ErrorAction SilentlyContinue); $i++) { Start-Sleep 1 }
    if (-not (Test-Path $exe)) { throw 'RustDesk install did not finish in time.' }
    Start-Sleep 5
}

Write-Host 'Applying server settings...'
Start-Process $exe "--config $cfg" -Wait
Restart-Service RustDesk -ErrorAction SilentlyContinue

$id = (& $exe --get-id | Out-String).Trim()
Write-Host "Done. This PC's RustDesk ID: $id" -ForegroundColor Green
