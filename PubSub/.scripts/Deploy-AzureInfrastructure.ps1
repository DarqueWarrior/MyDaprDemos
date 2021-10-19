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
        # Generate password
        $uppercase = "ABCDEFGHKLMNOPRSTUVWXYZ".tochararray()
        $lowercase = "abcdefghiklmnoprstuvwxyz".tochararray()
        $number = "0123456789".tochararray()
        $special = "$%&/()=?}{@#*+!".tochararray()

        $password = ($uppercase | Get-Random -count 2) -join ''
        $password += ($lowercase | Get-Random -count 5) -join ''
        $password += ($number | Get-Random -count 2) -join ''
        $password += ($special | Get-Random -count 2) -join ''

        # Get the IP address for the firewall runs
        $myIp = $(Invoke-WebRequest https://ifconfig.me/ip).Content
        Write-Verbose "IP Address = $myIp"

        Write-Output 'Deploying the infrastructure'
        
        $sw = [Diagnostics.Stopwatch]::StartNew()

        $deployment = $(az deployment sub create --name $rgName `
                --location $location `
                --template-file ./azure/main.bicep `
                --parameters location=$location `
                --parameters rgName=$rgName `
                --parameters adminPassword=$password `
                --parameters ipAddress=$myIp `
                --output json) | ConvertFrom-Json

        $sw.Stop()

        Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deploying a Azure Key Vault"

        # Store the outputs from the deployment to create
        # ./components/azure/local_secrets.json
        $databaseName = $deployment.properties.outputs.databaseName.value
        $eventHubsEndpoint = $deployment.properties.outputs.eventHubsEndpoint.value
        $storageAccountKey = $deployment.properties.outputs.storageAccountKey.value
        $administratorLogin = $deployment.properties.outputs.administratorLogin.value
        $serviceBusEndpoint = $deployment.properties.outputs.serviceBusEndpoint.value
        $storageAccountName = $deployment.properties.outputs.storageAccountName.value
        $fullyQualifiedDomainName = $deployment.properties.outputs.fullyQualifiedDomainName.value

        Write-Verbose "databaseName = $databaseName"
        Write-Verbose "storageAccountKey = $storageAccountKey"
        Write-Verbose "eventHubsEndpoint = $eventHubsEndpoint"
        Write-Verbose "storageAccountName = $storageAccountName"
        Write-Verbose "administratorLogin = $administratorLogin"
        Write-Verbose "serviceBusEndpoint = $serviceBusEndpoint"
        Write-Verbose "fullyQualifiedDomainName = $fullyQualifiedDomainName"

        $connectionString = "server=$fullyQualifiedDomainName;database=$databaseName;user id=$administratorLogin;Password=$password;port=1433;"

        # Creating components/azure/local_secrets.json
        $secrets = [PSCustomObject]@{
            ipAddress           = $myIp
            databaseName        = $databaseName
            sqlConnectionString = $connectionString
            eventHubsEndpoint   = $eventHubsEndpoint
            serviceBusEndpoint  = $serviceBusEndpoint
            storageAccountName  = $storageAccountName
            storageAccountKey   = $storageAccountKey
        }

        Write-Output 'Saving ./components/azure/local_secrets.json for local secret store'
        $secrets | ConvertTo-Json | Set-Content ../components/azure/local_secrets.json
    }

    end {
        Pop-Location
    }
}