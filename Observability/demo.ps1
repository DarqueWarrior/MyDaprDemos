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

    $config = $(Get-Content ./azureComponents/otel-local-config.yaml | Convertfrom-Yaml)
    
    # If you don't find the ./azureComponents/local_secrets.json run the setup.ps1 in deploy folder
    if ($config.exporters.azuremonitor.instrumentation_key -eq "") {
        Write-Output "./azureComponents/local_secrets.json not found running setup"
        Push-Location
        Set-Location -Path './deploy'
        ./setup.ps1
        Pop-Location
    }

    # Make sure the dapr_zipkin container is not running.
    docker stop dapr_zipkin
    
    Write-Output "dapr run -a serviceA -p 5000 -H 3500 --components-path ./azureComponents -- dotnet run --project ./serviceA/serviceA.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run -a serviceB -p 5010 --components-path ./azureComponents -- dotnet run --project ./serviceB/serviceB.csproj --urls "http://localhost:5010" `n"
    Write-Output "dapr run -a serviceC -p 5020 --components-path ./azureComponents -- dotnet run --project ./serviceC/serviceC.csproj --urls "http://localhost:5020" `n"

    tye run ./src/tye_cloud.yaml
}
else {
    Write-Output "Running demo with local resources"

    # Make sure the dapr_zipkin container is running.
    docker start dapr_zipkin

    Write-Output "dapr run -a serviceA -p 5000 -H 3500 -- dotnet run --project ./serviceA/serviceA.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run -a serviceB -p 5010 -- dotnet run --project ./serviceB/serviceB.csproj --urls "http://localhost:5010" `n"
    Write-Output "dapr run -a serviceC -p 5020 -- dotnet run --project ./serviceC/serviceC.csproj --urls "http://localhost:5020" `n"

    tye run ./src/tye_local.yaml
}