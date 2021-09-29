# This will call cleanUp of every demo.

[CmdletBinding()]
param (
    [switch]
    $Force
)

$demos = @('Binding', 'Observability', 'PubSub', 'StateStore', 'Secrets')

foreach ($demo in $demos) {
    Write-Host "Cleaning up $demo"
    
    Push-Location "../$demo"
    ./cleanUp.ps1 -force:$Force.IsPresent
    Pop-Location   
}