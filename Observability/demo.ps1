# This script issues and displays the correct dapr run command for running with
# local or cloud resources. To run in the clould add the -cloud switch. If the 
# script determines the infrastructure has not been deployed it will call the
# setup script first. 
[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "When provided runs demo against cloud resources"
    )]
    [switch]
    $cloud
)

# Load the sample requests file for the demo
code ./sampleRequests.http

if ($cloud.IsPresent) {
    Write-Output "Running demo with cloud resources"
    
    # If you don't find the ./azureComponents/local_secrets.json run the setup.ps1 in deploy folder
    if ($(Test-Path -Path './azureComponents/local_secrets.json') -eq $false) {
        Write-Output "./azureComponents/local_secrets.json not found running setup"
        Push-Location
        Set-Location -Path './deploy'
        ./setup.ps1
        Pop-Location
    }
    
    Write-Output "dapr run --app-id cloud --dapr-http-port 3500 --components-path ./azureComponents `n"

    tye run ./src/tye_cloud.yaml
}
else {
    Write-Output "Running demo with local resources"

    Write-Output "dapr run -a serviceA -p 5000 -H 3500 -- dotnet run --project ./serviceA/serviceA.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run -a serviceB -p 5010 -- dotnet run --project ./serviceB/serviceB.csproj --urls "http://localhost:5010" `n"
    Write-Output "dapr run -a serviceC -p 5020 -- dotnet run --project ./serviceC/serviceC.csproj --urls "http://localhost:5020" `n"

    tye run ./src/tye_local.yaml
}