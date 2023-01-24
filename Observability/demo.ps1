# This script issues and displays the correct dapr run command for running with
# local or cloud resources. To run in the clould add -env azure parameter. If the
# script determines the infrastructure has not been deployed it will call the
# setup script first.
[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
    )]
    [string]
    $rgName = "dapr_observability_demo",

    [Parameter(
        Position = 1,
        HelpMessage = "The location to store the meta data for the deployment."
    )]
    [string]
    $location = "eastus",
    
    [Parameter(
        HelpMessage = "Set to the location of the resources to use."
    )]
    [ValidateSet("local", "azure")]
    [string]
    $env = "local",

    [Parameter(
        HelpMessage = "When provided deploys the cloud infrastructure without running the demo"
    )]
    [switch]
    $deployOnly
)

. "./.scripts/Deploy-AzureInfrastructure.ps1"

# This will deploy the infrastructure without running the demo. You can use
# this flag to set everything up before you run the demos to save time. Some
# infrastucture can take some time to deploy.
if ($deployOnly.IsPresent) {
    Deploy-AzureInfrastructure -rgName $rgName -location $location
    return
}

# Load the sample requests file for the demo
code ./sampleRequests.http

if ($env -eq "azure") {
    Write-Output "Running demo with cloud resources"

    $config = $(Get-Content ./config/azure/otel-local-config.yaml | Convertfrom-Yaml)

    # If you don't find the ./config/azure/local_secrets.json run the setup.ps1 in deploy folder
    if ($config.exporters.azuremonitor.instrumentation_key -eq "") {
        Write-Output "Could not find ./config/azure/local_secrets.json"
        Deploy-AzureInfrastructure -rgName $rgName -location $location
    }

    # Make sure the dapr_zipkin container is not running.
    # Don't need zipkin because this demo uses the 
    # otel/opentelemetry-collector-contrib-dev image
    docker stop dapr_zipkin

    Write-Output "dapr run -a serviceA -p 5000 -H 3500 -- dotnet run --project ./serviceA/serviceA.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run -a serviceB -p 5010 -- dotnet run --project ./serviceB/serviceB.csproj --urls "http://localhost:5010" `n"
    Write-Output "dapr run -a serviceC -p 5020 -- dotnet run --project ./serviceC/serviceC.csproj --urls "http://localhost:5020" `n"

    # Launches Application Insights container
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