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
    $rgName = "dapr_devops_demo",

    [Parameter(
        Position = 1,
        HelpMessage = "The location to store the meta data for the deployment."
    )]
    [string]
    $location = "eastus",

    [Parameter(
        HelpMessage = "Set to the location of the resources to use."
    )]
    [ValidateSet("local", "azure")]
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

. "./.scripts/Deploy-AzureInfrastructure.ps1"

# This will deploy the infrastructure without running the demo. You can use
# this flag to set everything up before you run the demos to save time. Some
# infrastucture can take some time to deploy.
if ($deployOnly.IsPresent) {
    Deploy-AzureInfrastructure -rgName $rgName -location $location
    return
}

if ($env -eq "azure") {
    Write-Output "Running demo with cloud resources"

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

    if ($skipDaprRun.IsPresent -eq $false) {
        Write-Output "dapr run --app-id app1 --app-port 5013 --dapr-http-port 3500 --components-path ./components/azure -- dotnet run --project ./src/ `n"

        dapr run --app-id app1 --app-port 5013 --dapr-http-port 3500 --components-path ./components/azure -- dotnet run --project ./src/
    }
}
else {
    Write-Output "Running demo with local resources"

    # Make sure the dapr_zipkin container is running.
    docker start dapr_zipkin
    
    # Creating components/azure/local_secrets.json
    $secrets = [PSCustomObject]@{
        apiKey            = $env:APIKEY
        apiKeySecret      = $env:APIKEYSECRET
        accessToken       = $env:ACCESSTOKEN
        accessTokenSecret = $env:ACCESSTOKENSECRET
    }

    Write-Output 'Saving ./components/azure/local_secrets.json for local secret store'
    $secrets | ConvertTo-Json | Set-Content ./components/local/local_secrets.json

    Write-Output "dapr run --app-id viewer --app-port 5000 --components-path ./components/local -- dotnet run --project ./src/viewer/viewer.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run --app-id processor --app-port 5030 --components-path ./components/local -- dotnet run --project ./src/processor/processor.csproj --urls "http://localhost:5030" `n"
    Write-Output "dapr run --app-id provider --app-port 5040 --components-path ./components/local -- dotnet run --project ./src/provider/provider.csproj --urls "http://localhost:5040" `n"

    tye run ./src/tye_local.yaml
}