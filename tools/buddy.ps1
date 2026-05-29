if (Test-Path $LogicPath) {
    & $LogicPath @args
} else {
    Write-Error "Kernlogik nicht gefunden unter: $LogicPath"
    exit 1
}