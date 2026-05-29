Describe "Chocolatey Environment Check" {
    Context "Deployment Prerequisites" {
        It "should have choco.exe available in the system path" {
            $chocoCommand = Get-Command choco -ErrorAction SilentlyContinue
            $chocoCommand | Should -Not -BeNullOrEmpty
        }

        It "should run with administrative privileges for installation" {
            $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            $isAdmin | Should -Be $true
        }
    }
}
