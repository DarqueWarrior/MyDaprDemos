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
    $rgName = "dapr_observability_demo",

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
        # azureComponents/otel-local-config.yaml
        $instrumentationKey = $deployment.properties.outputs.instrumentationKey.value

        Write-Verbose "instrumentationKey = $instrumentationKey"

        # Populating azureComponents/otel-local-config.yaml
        $config = $(Get-Content ../azureComponents/otel-local-config.yaml | Convertfrom-Yaml)
        $config.exporters.azuremonitor.instrumentation_key = $instrumentationKey

        Write-Output 'Saving ./azureComponents/otel-local-config.yaml'
        $config | ConvertTo-Yaml | Set-Content ../azureComponents/otel-local-config.yaml
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

    $config = $(Get-Content ./azureComponents/otel-local-config.yaml | Convertfrom-Yaml)

    # If you don't find the ./azureComponents/local_secrets.json run the setup.ps1 in deploy folder
    if ($config.exporters.azuremonitor.instrumentation_key -eq "") {
        Write-Output "./azureComponents/local_secrets.json not found running setup"
        Deploy-Infrastructure -rgName $rgName -location $location
    }

    # Make sure the dapr_zipkin container is not running.
    docker stop dapr_zipkin

    Write-Output "dapr run -a serviceA -p 5000 -H 3500 --components-path ./azureComponents -- dotnet run --project ./serviceA/serviceA.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run -a serviceB -p 5010 --components-path ./azureComponents -- dotnet run --project ./serviceB/serviceB.csproj --urls "http://localhost:5010" `n"
    Write-Output "dapr run -a serviceC -p 5020 --components-path ./azureComponents -- dotnet run --project ./serviceC/serviceC.csproj --urls "http://localhost:5020" `n"

    tye run ./src/tye_cloud.yaml
}
else {
    Write-Output "Running demo with local resources"

    # Make sure the dapr_zipkin container is running.
    docker start dapr_zipkin

    Write-Output "dapr run -a serviceA -p 5000 -H 3500 -- dotnet run --project ./serviceA/serviceA.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run -a serviceB -p 5010 -- dotnet run --project ./serviceB/serviceB.csproj --urls "http://localhost:5010" `n"
    Write-Output "dapr run -a serviceC -p 5020 -- dotnet run --project ./serviceC/serviceC.csproj --urls "http://localhost:5020" `n"

    tye run ./src/tye_local.yaml
}