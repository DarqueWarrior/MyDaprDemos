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
    $rgName = "dapr_devops_demo",

    [Parameter(
        Position = 1,
        HelpMessage = "The location to store the meta data for the deployment."
    )]
    [string]
    $location = "eastus",

    [Parameter(
        HelpMessage = "Set to the location of the resources to use."
    )]
    [ValidateSet("local", "k8s")]
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

# If you don't find the ./components/local/local_secrets.json run the setup.ps1 in deploy folder
if ($(Test-Path -Path './components/local/local_secrets.json') -eq $false) {
    Write-Output "Could not find ./components/local/local_secrets.json"
    
    Deploy-AzureInfrastructure -rgName $rgName -location $location
}

if ($env -eq "local") {
    Write-Output "Running demo with local resources"

    # Make sure the dapr_zipkin container is running.
    docker start dapr_zipkin

    Write-Output "dapr run --app-id viewer --app-port 5000 --components-path ./components/local -- dotnet run --project ./src/viewer/viewer.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run --app-id processor --app-port 5030 --components-path ./components/local -- dotnet run --project ./src/processor/processor.csproj --urls "http://localhost:5030" `n"
    Write-Output "dapr run --app-id provider --app-port 5040 --components-path ./components/local -- dotnet run --project ./src/provider/provider.csproj --urls "http://localhost:5040" `n"

    ~/bin/tye run ./src/tye_local.yaml
}
else {
    if ($null -eq $(docker images "k3d-registry.localhost:5500/*" -q)) {
        # Build all the images
        docker build -f ./src/viewer/Dockerfile -t k3d-registry.localhost:5500/csharpviewer:local ./src/viewer/
        docker build -f ./src/provider/Dockerfile -t k3d-registry.localhost:5500/csharpprovider:local ./src/provider/
        docker build -f ./src/processor/Dockerfile -t k3d-registry.localhost:5500/csharpprocessor:local ./src/processor/

        docker push k3d-registry.localhost:5500/csharpviewer:local
        docker push k3d-registry.localhost:5500/csharpprovider:local
        docker push k3d-registry.localhost:5500/csharpprocessor:local
    }

    helm dependency update ./charts/

    helm upgrade twitter ./charts/ -f ./charts/local.yaml -i
}