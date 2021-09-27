# This will call setup of every demo.

[CmdletBinding()]
param ()

$demos = @('Binding')
# $demos = @('Binding', 'Observability', 'PubSub', 'StateStore', 'Secrets')

foreach ($demo in $demos) {
    Write-Host "Setting up $demo"
    
    Push-Location "../$demo/deploy"
    ./setup.ps1
    Pop-Location   
}