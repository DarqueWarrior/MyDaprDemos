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
        $deployment = $(az deployment sub create --name $rgName `
                --location $location `
                --template-file ./azure/main.bicep `
                --parameters location=$location `
                --parameters rgName=$rgName `
                --output json) | ConvertFrom-Json

        # Store the outputs from the deployment to create
        # config/azure/otel-local-config.yaml
        $instrumentationKey = $deployment.properties.outputs.instrumentationKey.value

        Write-Verbose "instrumentationKey = $instrumentationKey"

        # Populating config/azure/otel-local-config.yaml
        $config = $(Get-Content ../config/azure/otel-local-config.yaml | Convertfrom-Yaml)
        $config.exporters.azuremonitor.instrumentation_key = $instrumentationKey

        Write-Output 'Saving ./config/azure/otel-local-config.yaml'
        $config | ConvertTo-Yaml | Set-Content ../config/azure/otel-local-config.yaml
    }

    end {
        Pop-Location
    }
}