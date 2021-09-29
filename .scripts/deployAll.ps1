# This will call setup of every demo.

[CmdletBinding()]
param ()

$demos = @('Binding', 'Observability', 'PubSub', 'StateStore', 'Secrets')

foreach ($demo in $demos) {
    Write-Host "Setting up $demo"
    
    Push-Location "../$demo"
    ./demo.ps1 -deployOnly
    Pop-Location   
}