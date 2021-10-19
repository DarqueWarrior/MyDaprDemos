# This script issues and displays the correct dapr run command for running with
# local or cloud resources. To run in the clould add the -env azure parameter.
# If the script determines the infrastructure has not been deployed it will 
# call the setup script first.
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
        HelpMessage = "Set to the location of the resources to use."
    )]
    [ValidateSet("local", "azure", "aws")]
    [string]
    $env = "local",

    [Parameter(
        HelpMessage = "When provided deploys the cloud infrastructure without running the demo."
    )]
    [switch]
    $deployOnly
)

. "./.scripts/Deploy-AWSInfrastructure.ps1"
. "./.scripts/Deploy-AzureInfrastructure.ps1"

# This will deploy the infrastructure without running the demo. You can use
# this flag to set everything up before you run the demos to save time. Some
# infrastucture can take some time to deploy.
# This will deploy the infrastructure without running the demo. You can use
# this flag to set everything up before you run the demos to save time. Some
# infrastucture can take some time to deploy.
if ($deployOnly.IsPresent) {    
    Deploy-AWSInfrastructure
    Deploy-AzureInfrastructure -rgName $rgName -location $location    
    return
}

# We need to change which @itemName line is used. With the local local storage
# component the item name is fileName whereas with the blob storage component
# it is blobName.
$file = Get-Content -Path ./sampleRequests.http

if ($env -eq "azure") {
    $file[3] = '# @itemName = fileName'
    $file[8] = '@itemName = blobName'
    $file[13] = '# @itemName = key'
}
elseif ($env -eq "aws") {
    $file[3] = '# @itemName = fileName'
    $file[8] = '# @itemName = blobName'
    $file[13] = '@itemName = key'
}
else {
    $file[3] = '@itemName = fileName'
    $file[8] = '# @itemName = blobName'
    $file[13] = '# @itemName = key'
}

Set-Content -Path ./sampleRequests.http -Value $file

# Load the sample requests file for the demo
code ./sampleRequests.http

if ($env -eq "azure") {    
    # If you don't find the ./components/azure/local_secrets.json run the setup.ps1 in deploy folder
    if ($(Test-Path -Path './components/azure/local_secrets.json') -eq $false) {
        Write-Output "Could not find ./components/azure/local_secrets.json"
        Deploy-AzureInfrastructure -rgName $rgName -location $location
    }
}
elseif ($env -eq "aws") {
    # If you don't find the ./deploy/aws/terraform.tfvars run the setup.ps1 in deploy folder
    if ($(Test-Path -Path './deploy/aws/terraform.tfvars') -eq $false) {
        Write-Output "Could not find ./deploy/aws/terraform.tfvars"
        Deploy-AWSInfrastructure
    }
}

Write-Output "Running demo with $env resources"
Write-Output "dapr run --app-id $env --dapr-http-port 3500 --components-path ./components/$env `n"

dapr run --app-id $env --dapr-http-port 3500 --components-path ./components/$env