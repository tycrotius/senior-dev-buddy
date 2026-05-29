<#
.SYNOPSIS
    Senior-Dev-Buddy: A pragmatic AI assistant for the command line.

.DESCRIPTION
    Central tool for tycrotius' daily development workflow.
    Supports LLM interaction via CLI parameters and pipeline context.
    
    Configuration is handled via: ~/.config/dev-buddy/config.json
    The script is optimized for productive, daily workflows.

.PARAMETER Prompt
    The instruction prompt for the Buddy. Position 0.

.PARAMETER Model
    Overrides the LLM model defined in config.json.
    Example: -Model "gpt-4o"

.PARAMETER Temperature
    Controls response creativity (Range: 0.0 - 1.0).
    Example: -Temperature 0.2

.PARAMETER PipelineInput
    Allows piping text data directly into the context.

.EXAMPLE
    buddy "Initialize new project setup"
    
.EXAMPLE
    cat .\src\engine.js | buddy "Refactor this code" -Model "gpt-4o" -Temperature 0.1

.NOTES
    Author: tycrotius
    Version: 1.1.0
    Status: Production / Active Development
#>
param (
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Prompt,

    [Parameter(Mandatory=$false)]
    [string]$Model,

    [Parameter(Mandatory=$false)]
    [ValidateRange(0.0, 1.0)]
    [float]$Temperature,

    [Parameter(ValueFromPipeline=$true)]
    [string]$PipelineInput
)

begin {
    # --------------------------------------------------------------------------
    # Initialize environment, configuration, and path validation
    # --------------------------------------------------------------------------
    $ConfigDir  = Join-Path $HOME ".config\dev-buddy"
    $ConfigFile = Join-Path $ConfigDir "config.json"

    if (!(Test-Path $ConfigFile)) {
        New-Item -Path $ConfigDir -ItemType Directory -Force | Out-Null
        $DefaultConfig = @{
            api_key     = "YOUR_API_KEY_HERE"
            api_url     = "https://api.openai.com/v1/chat/completions"
            model       = "gpt-4o"
            temperature = 0.3
        }
        $DefaultConfig | ConvertTo-Json | Out-File $ConfigFile
        Write-Error "Configuration not found. Created default at: $ConfigFile"
        exit 1
    }

    # Load configuration data
    $Config = Get-Content $ConfigFile | ConvertFrom-Json
    
    # Parameter resolution: CLI arguments take precedence
    $UsedModel = if ($Model) { $Model } else { $Config.model }
    $UsedTemp  = if ($PSBoundParameters.ContainsKey('Temperature')) { $Temperature } else { $Config.temperature }
    
    # Buffer for pipeline input
    $Buffer = @()
}

process {
    # Aggregate pipeline input data for context building
    if ($PipelineInput) { $Buffer += $PipelineInput }
}

end {
    # --------------------------------------------------------------------------
    # API logic and execution
    # --------------------------------------------------------------------------
    $FullContext = $Buffer -join "`n"

    # Validation: Ensure input is present
    if (-not $Prompt -and -not $FullContext) {
        Write-Warning "No input detected. Buddy requires instructions or pipeline data."
        exit 1
    }

    # Construct the final prompt
    $FinalPrompt = ""
    if ($FullContext) { $FinalPrompt += "--- CONTEXT ---`n$FullContext`n--- END CONTEXT ---`n`n" }
    if ($Prompt) { $FinalPrompt += $Prompt } else { $FinalPrompt += "Analyze the input." }

    # System instruction: Establishing the tycrotius persona
    $SystemPrompt = "You are the Senior-Dev-Buddy. Respond briefly, pragmatically, directly. Code-First."
    
    # Prepare API payload
    $Body = @{
        model       = $UsedModel
        messages    = @(
            @{ role = "system"; content = $SystemPrompt },
            @{ role = "user"; content = $FinalPrompt }
        )
        temperature = [double]$UsedTemp
    } | ConvertTo-Json -Depth 10 -Compress

    $Headers = @{
        "Authorization" = "Bearer $($Config.api_key)"
        "Content-Type"  = "application/json"
    }

    Write-Host "Buddy using model: $UsedModel (Temp: $UsedTemp)..." -ForegroundColor Cyan

    try {
        # Security: Enforce TLS 1.2 for API communication
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        
        $Response = Invoke-RestMethod -Method Post -Uri $Config.api_url -Headers $Headers -Body $Body -UseBasicParsing
        
        Write-Host "`n--- Senior-Dev-Buddy ---" -ForegroundColor Green
        Write-Output $Response.choices[0].message.content
        Write-Host "------------------------`n" -ForegroundColor Green
        exit 0
    }
    catch {
        # Error handling: Precise feedback
        Write-Error "API communication failed: $($_.Exception.Message)"
        exit 1
    }
}
