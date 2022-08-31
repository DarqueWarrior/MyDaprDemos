# This will call cleanUp of every demo.

[CmdletBinding()]
param (
    [switch]
    $Force
)

. ./demos.ps1

foreach ($demo in $demos) {
    Write-Host "*******************************************"
    Write-Host "Cleaning up $demo"
    Write-Host "*******************************************"
    
    Push-Location "../$demo"
    ./cleanUp.ps1 -force:$Force
    Pop-Location   
}