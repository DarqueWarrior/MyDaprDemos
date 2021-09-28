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
    $rgName = "dapr_binding_demo",

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
    [CmdletBinding()]
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
        Write-Output 'Deploying the infrastructure'
        $deployment = $(az deployment sub create --name $rgName `
                --location $location `
                --template-file ./main.bicep `
                --parameters location=$location `
                --parameters rgName=$rgName `
                --output json) | ConvertFrom-Json

        # Store the outputs from the deployment to create
        # ./azureComponents/local_secrets.json
        $storageAccountKey = $deployment.properties.outputs.storageAccountKey.value
        $storageAccountName = $deployment.properties.outputs.storageAccountName.value

        Write-Verbose "storageAccountKey = $storageAccountKey"
        Write-Verbose "storageAccountName = $storageAccountName"

        # Creating azureComponents/local_secrets.json
        $secrets = [PSCustomObject]@{
            key  = $storageAccountKey
            acct = $storageAccountName
        }

        Write-Output 'Saving ./azureComponents/local_secrets.json for local secret store'
        $secrets | ConvertTo-Json | Set-Content ../azureComponents/local_secrets.json
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

# We need to change which @itemName line is used. With the local local storage
# component the item name is fileName whereas with the blob storage component
# it is blobName.
$file = Get-Content -Path ./sampleRequests.http

if ($cloud.IsPresent) {
    $file[3] = '# @itemName = fileName'
    $file[8] = '@itemName = blobName'
}
else {
    $file[3] = '@itemName = fileName'
    $file[8] = '# @itemName = blobName'
}

Set-Content -Path ./sampleRequests.http -Value $file

# Load the sample requests file for the demo
code ./sampleRequests.http

if ($cloud.IsPresent) {
    Write-Output "Running demo with cloud resources"

    # If you don't find the ./azureComponents/local_secrets.json run the setup.ps1 in deploy folder
    if ($(Test-Path -Path './azureComponents/local_secrets.json') -eq $false) {
        Write-Output "./azureComponents/local_secrets.json not found running setup"
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