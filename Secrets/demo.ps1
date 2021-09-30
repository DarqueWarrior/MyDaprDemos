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
    $rgName = "dapr_secrets_demo",

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

    # If you don't find the ./components/azure/local_secrets.json run the setup.ps1 in deploy folder
    if ($null -eq $env:VAULTNAME) {
        Write-Output "VAULTNAME environment variable not found running setup"
        Deploy-AzureInfrastructure -rgName $rgName -location $location
    }

    Write-Output "dapr run --app-id cloud --dapr-http-port 3500 --components-path ./components/azure `n"
    dapr run --app-id cloud --dapr-http-port 3500 --components-path ./components/azure
}
else {
    Write-Output "Running demo with local resources"
    Write-Output "dapr run --app-id local --dapr-http-port 3500 --components-path ./components/local `n"

    dapr run --app-id local --dapr-http-port 3500 --components-path ./components/local
}