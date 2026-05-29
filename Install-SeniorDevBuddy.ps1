<#
.SYNOPSIS
    Deployment and verification utility for the Senior-Dev-Buddy CLI tool.
.DESCRIPTION
    Validates host environment compliance by verifying administrative privileges 
    and Chocolatey package manager availability. 
.NOTES
    Lead Developer: tycrotius
    Assisted by:    Senior-Dev-Buddy (AI)
    Architecture:   Module-ready / Script Execution
    Minimum PS:     5.1
#>

function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-ChocoInstalled {
    return [bool](Get-Command choco -ErrorAction SilentlyContinue)
}

function Start-Installation {
    $projectName = "senior-dev-buddy"
    $chocoInstallCmd = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    # Fast-track command to spawn an elevated shell pointing directly to the current working directory
    $elevateCmd = "Start-Process powershell -ArgumentList '-NoExit', '-Command', 'Set-Location -LiteralPath ''$PWD''' -Verb RunAs"

    Write-Host "--- Initiating Environment Validation for: $projectName ---" -ForegroundColor Cyan

    # Operational Gate 1: Evaluate Administrative Privileges
    if (-not (Test-IsAdmin)) {
        Write-Host "[!] CRITICAL ERROR: Insufficient execution privileges." -ForegroundColor Red
        Write-Host "[*] REMEDIATION GUIDE:" -ForegroundColor Yellow
        Write-Host "    To provision system-wide tools, this session must run elevated." -ForegroundColor Yellow
        Write-Host "    You can right-click your PowerShell icon and select 'Run as Administrator'," -ForegroundColor Yellow
        Write-Host "    OR simply copy-paste and run this command to spawn an admin shell here:" -ForegroundColor Yellow
        Write-Host "`n$elevateCmd`n" -ForegroundColor White
        return $false
    }

    # Operational Gate 2: Verify Package Manager Availability
    if (-not (Test-ChocoInstalled)) {
        Write-Host "[!] CRITICAL ERROR: Chocolatey package manager is missing from the system PATH." -ForegroundColor Red
        Write-Host "[*] REMEDIATION GUIDE:" -ForegroundColor Yellow
        Write-Host "    Chocolatey is required to manage open-source and local dependencies natively." -ForegroundColor Yellow
        Write-Host "    Execute the following bootstrap string to install Chocolatey now:" -ForegroundColor Yellow
        Write-Host "`n$chocoInstallCmd`n" -ForegroundColor White
        return $false
    }

    # Execution Layer
    Write-Host "[OK] Environment baseline verified. Proceeding with system deployment..." -ForegroundColor Green
    return $true
}

if ($MyInvocation.InvocationName -ne '.') {
    $success = Start-Installation
    if (-not $success) { exit 1 }
}
