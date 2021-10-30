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
    $rgName = "dapr_pubsub_demo",

    [Parameter(
        Position = 1,
        HelpMessage = "The location to store the meta data for the deployment."
    )]
    [string]
    $location = "eastus",

    [Parameter(
        HelpMessage = "Set to the location of the resources to use."
    )]
    [ValidateSet("local", "azure", "aws", "gcp")]
    [string]
    $env = "local",

    [Parameter(
        HelpMessage = "When provided deploys the cloud infrastructure without running the demo"
    )]
    [switch]
    $deployOnly,

    [Parameter(
        HelpMessage = "When provided the dapr run is skipped. This is used from the tasks to launch the debugger because it will call daprd run."
    )]
    [switch]
    $skipDaprRun
)

. "./.scripts/Deploy-AWSInfrastructure.ps1"
. "./.scripts/Deploy-GCPInfrastructure.ps1"
. "./.scripts/Deploy-AzureInfrastructure.ps1"

# This will deploy the infrastructure without running the demo. You can use
# this flag to set everything up before you run the demos to save time. Some
# infrastucture can take some time to deploy.
if ($deployOnly.IsPresent) {
    if ($env -eq 'local' -or $env -eq 'aws') {
        Deploy-AWSInfrastructure
    }

    if ($env -eq 'local' -or $env -eq 'gcp') {
        Deploy-GCPInfrastructure
    }

    if ($env -eq 'local' -or $env -eq 'azure') {
        Deploy-AzureInfrastructure -rgName $rgName -location $location
    }
    
    return
}

# Load the sample requests file for the demo
code ./sampleRequests.http

if ($env -eq "azure") {
    # If you don't find the ./components/azure/local_secrets.json run the setup.ps1 in deploy folder
    $fileMissing = $(Test-Path -Path './components/azure/local_secrets.json') -eq $false

    # Or if the ./components/azure/local_secrets.json is present make sure
    # the IP address in there matches our current IP. If not we need to deploy
    # again to update the firewall rules.
    $myIp = $(Invoke-WebRequest https://ifconfig.me/ip).Content

    if ($fileMissing -or
        $myIp -ne $(Get-Content -Path './components/azure/local_secrets.json' | ConvertFrom-Json).ipAddress
    ) {
        if ($fileMissing) {
            Write-Output "Could not find ./components/azure/local_secrets.json"
        }
        else {
            Write-Output "IP Address has changed"
        }
        
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
elseif ($env -eq "gcp") {
    # If you don't find the ./deploy/gcp/terraform.tfvars run the setup.ps1 in deploy folder
    if ($(Test-Path -Path './deploy/gcp/terraform.tfvars') -eq $false) {
        Write-Output "Could not find ./deploy/gcp/terraform.tfvars"
        Deploy-GCPInfrastructure
    }
}

if ($skipDaprRun.IsPresent -eq $false) {
    Write-Output "Running demo with $env resources"
    Write-Output "dapr run --app-id app1 --app-port 5013 --dapr-http-port 3500 --components-path ./components/$env -- dotnet run --project ./src/ `n"

    dapr run --app-id app1 --app-port 5013 --dapr-http-port 3500 --components-path ./components/$env -- dotnet run --project ./src/
}