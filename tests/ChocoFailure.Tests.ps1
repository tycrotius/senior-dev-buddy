<#
.SYNOPSIS
    Pester regression testing suite for negative execution flows.
.NOTES
    Lead Developer: tycrotius
    Assisted by:    Senior-Dev-Buddy (AI)
#>

Describe "Installer Failure Scenarios (Emulated Environment)" {
    BeforeAll {
        . "C:\Projects\senior-dev-buddy\Install-SeniorDevBuddy.ps1"
    }
    
    Context "Prerequisite Negative Constraints" {
        It "Should abort operation gracefully when administrative access is denied" {
            Mock Test-IsAdmin { return $false }
            Mock Test-ChocoInstalled { return $true }
            
            $result = Start-Installation
            $result | Should -Be $false
        }

        It "Should abort operation if Chocolatey is missing" {
            Mock Test-IsAdmin { return $true }
            Mock Test-ChocoInstalled { return $false }
            
            $result = Start-Installation
            $result | Should -Be $false
        }
    }
}
