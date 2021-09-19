
# This script will run an ARM template deployment to deploy all the
# required resources into Azure. All the keys, tokens and endpoints
# will be automatically retreived and passed to the helm chart used
# in deployment. The only requirement is to populate the mysecrets.yaml
# file in the demochart folder with the twitter tokens, secrets and keys.
# If you already have existing infrastructure do not use this file.
# Simply fill in all the values of the mysecrets.yaml file and call helm
# install passing in that file using the -f flag.
# Requirements:
# Helm 3+
# PowerShell Core 7 (runs on macOS, Linux and Windows)
# Azure CLI (log in, runs on macOS, Linux and Windows)

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
    $location = "eastus"
)

# We need to get the object id for the service principal 
$objectId = $(az ad sp show --id $env:APPID --query objectId --output tsv)

Write-Output 'Deploying the infrastructure'
$deployment = $(az deployment sub create --name $rgName `
        --location $location `
        --parameters rgName=$rgName `
        --parameters objectId=$objectId `
        --parameters location=$location `
        --parameters tenantId=$env:TENANT `
        --template-file ../deploy/main.bicep `
        --output json) | ConvertFrom-Json

$keyvaultName = $deployment.properties.outputs.keyvaultName.value

Write-Verbose "keyvaultName = $keyvaultName"

# Creating VAULTNAME environment variable
$env:VAULTNAME=$keyvaultName

# After running move up a level so I don't forget and run dapr run from wrong
# location 

Set-Location -Path ..