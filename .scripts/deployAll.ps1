# This will call setup of every demo.

[CmdletBinding()]
param ()

$demos = @('Binding', 'Observability', 'PubSub', 'Secrets', 'StateStore', 'DevOps')

foreach ($demo in $demos) {
    Write-Host "*******************************************"
    Write-Host "Setting up $demo"
    Write-Host "*******************************************"
    
    Push-Location "../$demo"
    ./demo.ps1 -deployOnly
    Pop-Location   
}