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
    [ValidateSet("local", "azure", "aws")]
    [string]
    $env = "local",

    [Parameter(
        HelpMessage = "When provided deploys the cloud infrastructure without running the demo"
    )]
    [switch]
    $deployOnly
)

. "./.scripts/Deploy-AWSInfrastructure.ps1"
. "./.scripts/Deploy-AzureInfrastructure.ps1"

# This will deploy the infrastructure without running the demo. You can use
# this flag to set everything up before you run the demos to save time. Some
# infrastucture can take some time to deploy.
if ($deployOnly.IsPresent) {
    $sw = [Diagnostics.Stopwatch]::StartNew()
    Deploy-AWSInfrastructure
    $sw.Stop()

    Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deploying a AWS Secrets Manager"

    $sw.Start()
    Deploy-AzureInfrastructure -rgName $rgName -location $location
    $sw.Stop()

    Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deploying a Azure KeyVault"
    return
}

# Load the sample requests file for the demo
code ./sampleRequests.http

# Make sure the Zipkin container is running. The Observiblity demo stops it.
docker start dapr_zipkin

if ($env -eq "azure") {
    $error.clear()

    Write-Output "Running demo with Azure resources"

    # If you don't find the ./components/azure/local_secrets.json run the setup.ps1 in deploy folder
    if ($null -eq $env:AZURE_KEY_VAULT_NAME) {
        Write-Output "Could not find AZURE_KEY_VAULT_NAME environment variable"
        Deploy-AzureInfrastructure -rgName $rgName -location $location
    }

    if ($error[0]) {
        Write-Error $error[0]
        return
    }

    Write-Output "dapr run --app-id azure --dapr-http-port 3500 --components-path ./components/azure `n"
    dapr run --app-id azure --dapr-http-port 3500 --components-path ./components/azure
}
elseif ($env -eq "aws") {
    Write-Output "Running demo with AWS resources"

    # If you don't find the ./deploy/aws/terraform.tfvars deploy infrastucture
    if ($(Test-Path -Path './deploy/aws/terraform.tfvars') -eq $false) {
        Write-Output "Could not find ./deploy/aws/terraform.tfvars"
        $sw = [Diagnostics.Stopwatch]::StartNew()
        Deploy-AWSInfrastructure
        $sw.Stop()

        Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deploying a AWS DynamoDB"
    }

    Write-Output "dapr run --app-id aws --dapr-http-port 3500 --components-path ./components/aws `n"
    dapr run --app-id aws --dapr-http-port 3500 --components-path ./components/aws
}
else {
    Write-Output "Running demo with local resources"
    Write-Output "dapr run --app-id local --dapr-http-port 3500 --components-path ./components/local `n"

    dapr run --app-id local --dapr-http-port 3500 --components-path ./components/local
}