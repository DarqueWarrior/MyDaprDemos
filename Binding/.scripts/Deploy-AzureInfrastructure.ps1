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
        Write-Output 'Deploying the infrastructure'

        $sw = [Diagnostics.Stopwatch]::StartNew()

        $deployment = $(az deployment sub create --name $rgName `
                --location $location `
                --template-file ./azure/main.bicep `
                --parameters location=$location `
                --parameters rgName=$rgName `
                --output json) | ConvertFrom-Json

        $sw.Stop()

        Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deploying Microsoft.Storage/storageAccounts@2019-06-01"

        # Store the outputs from the deployment to create
        # ./components/azure/local_secrets.json
        $storageAccountKey = $deployment.properties.outputs.storageAccountKey.value
        $storageAccountName = $deployment.properties.outputs.storageAccountName.value

        Write-Verbose "storageAccountKey = $storageAccountKey"
        Write-Verbose "storageAccountName = $storageAccountName"

        # Creating components/azure/local_secrets.json
        $secrets = [PSCustomObject]@{
            key  = $storageAccountKey
            acct = $storageAccountName
        }

        Write-Output 'Saving ./components/azure/local_secrets.json for local secret store'
        $secrets | ConvertTo-Json | Set-Content ../components/azure/local_secrets.json
    }

    end {
        Pop-Location
    }
}