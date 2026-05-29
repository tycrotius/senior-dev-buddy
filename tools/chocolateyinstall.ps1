<#
.SYNOPSIS
    Installations-Skript für das senior-dev-buddy Chocolatey-Paket.
.DESCRIPTION
    Chocolatey führt dieses Skript beim Installieren aus. Da sich im "tools"-Ordner
    eine "buddy.bat" befindet, generiert Chocolatey automatisch einen globalen 
    Shim (Verknüpfung) in C:\ProgramData\chocolatey\bin\.
#>
$ErrorActionPreference = "Stop"

Write-Host "Senior-Dev-Buddy wird im Choco-System registriert..." -ForegroundColor Green

