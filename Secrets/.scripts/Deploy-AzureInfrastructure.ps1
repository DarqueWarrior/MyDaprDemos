# This function will run an bicep deployment to deploy all the required
# resources into Azure. All the keys, tokens and endpoints will be
# automatically retreived and written to ./components/azure/local_secrets.json.
# PowerShell Core 7 (runs on macOS, Linux and Windows)
# Azure CLI (log in, runs on macOS, Linux and Windows)
function Deploy-AzureInfrastructure {
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
        # We need to get the object id for the service principal
        $objectId = $(az ad sp show `
                --id $env:AZURE_APP_ID `
                --query id `
                --output tsv)

        Write-Verbose "ObjectID = $objectId"

        Write-Output 'Deploying the infrastructure'
        $deployment = $(az deployment sub create --name $rgName `
                --location $location `
                --parameters rgName=$rgName `
                --parameters objectId=$objectId `
                --parameters location=$location `
                --parameters tenantId=$env:AZURE_TENANT `
                --template-file ./azure/main.bicep `
                --output json) | ConvertFrom-Json

        if(-not $deployment) {
            Pop-Location
            throw "Deployment failed"
        }
        
        $keyvaultName = $deployment.properties.outputs.keyvaultName.value
        
        Write-Verbose "keyvaultName = $keyvaultName"
        
        Write-Output 'Setting AZURE_KEY_VAULT_NAME environment variable'
        $env:AZURE_KEY_VAULT_NAME = $keyvaultName
    }
    
    end {
        Pop-Location
    }
}