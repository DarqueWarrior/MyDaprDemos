# This script issues and displays the correct dapr run command for running with
# local or cloud resources. To run in the clould add the -cloud switch. If the
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
        HelpMessage = "When provided runs demo against cloud resources"
    )]
    [switch]
    $cloud,

    [Parameter(
        HelpMessage = "When provided deploys the cloud infrastructure without running the demo"
    )]
    [switch]
    $deployOnly
)

# This function will run an bicep deployment to deploy all the required
# resources into Azure. All the keys, tokens and endpoints will be
# automatically retreived and written to ./azureComponents/local_secrets.json.
# PowerShell Core 7 (runs on macOS, Linux and Windows)
# Azure CLI (log in, runs on macOS, Linux and Windows)
function Deploy-Infrastructure {
    param (
        [Parameter(
            Position = 0,
            HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
        )]
        [string]
        $rgName,

        [Parameter(
            Position = 1,
            HelpMessage = "The location to store the meta data for the deployment."
        )]
        [string]
        $location
    )
    begin {
        Push-Location -Path './deploy'
    }

    process {
        # We need to get the object id for the service principal
        $objectId = $(az ad sp show --id $env:APPID --query objectId --output tsv)

        Write-Output 'Deploying the infrastructure'
        $deployment = $(az deployment sub create --name $rgName `
                --location $location `
                --parameters rgName=$rgName `
                --parameters objectId=$objectId `
                --parameters location=$location `
                --parameters tenantId=$env:TENANT `
                --template-file ./main.bicep `
                --output json) | ConvertFrom-Json

        $keyvaultName = $deployment.properties.outputs.keyvaultName.value

        Write-Verbose "keyvaultName = $keyvaultName"

        Write-Output 'Setting VAULTNAME environment variable'
        $env:VAULTNAME = $keyvaultName
    }

    end {
        Pop-Location
    }
}

# This will deploy the infrastructure without running the demo. You can use
# this flag to set everything up before you run the demos to save time. Some
# infrastucture can take some time to deploy.
if ($deployOnly.IsPresent) {
    Deploy-Infrastructure -rgName $rgName -location $location
    return
}

# Load the sample requests file for the demo
code ./sampleRequests.http

if ($cloud.IsPresent) {
    Write-Output "Running demo with cloud resources"

    # If you don't find the ./azureComponents/local_secrets.json run the setup.ps1 in deploy folder
    if ($null -eq $env:VAULTNAME) {
        Write-Output "VAULTNAME environment variable not found running setup"
        Deploy-Infrastructure -rgName $rgName -location $location
    }

    Write-Output "dapr run --app-id cloud --dapr-http-port 3500 --components-path ./azureComponents `n"
    dapr run --app-id cloud --dapr-http-port 3500 --components-path ./azureComponents
}
else {
    Write-Output "Running demo with local resources"
    Write-Output "dapr run --app-id local --dapr-http-port 3500 --components-path ./components `n"

    dapr run --app-id local --dapr-http-port 3500 --components-path ./components
}