# This will call cleanUp of every demo.

[CmdletBinding()]
param (
    [switch]
    $Force
)

$demos = @('Binding', 'Observability', 'PubSub', 'Secrets', 'StateStore', 'DevOps')

foreach ($demo in $demos) {
    Write-Host "*******************************************"
    Write-Host "Cleaning up $demo"
    Write-Host "*******************************************"
    
    Push-Location "../$demo"
    ./cleanUp.ps1 -force:$Force.IsPresent
    Pop-Location   
}