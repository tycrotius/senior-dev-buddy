# Resolve the path absolutely before Describe
$CoreScript = Resolve-Path "$PSScriptRoot\..\src\buddy.ps1" -ErrorAction Stop

Describe "buddy.ps1 Parameter Validation" {
    
    It "Accepts valid model names and temperature" {
        { & $CoreScript.Path -Model "gpt-4o" -Temperature 0.5 } | Should -Not -Throw
    }

    It "Throws error when temperature exceeds the valid range (0.0 - 1.0)" {
        # The script block {} is mandatory here for Should -Throw
        { & $CoreScript.Path -Temperature 1.5 } | Should -Throw
    }
}
