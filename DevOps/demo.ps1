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
    [ValidateSet("local", "k8s", "multi", "node")]
    [string]
    $env = "local",

    [Parameter(
        HelpMessage = "When provided deploys the cloud infrastructure without running the demo"
    )]
    [switch]
    $deployOnly
)

. "./.scripts/Deploy-AzureInfrastructure.ps1"

# This will deploy the infrastructure without running the demo. You can use
# this flag to set everything up before you run the demos to save time. Some
# infrastucture can take some time to deploy.
if ($deployOnly.IsPresent) {
    Deploy-AzureInfrastructure -rgName $rgName -location $location
    return
}

# If you don't find the ./components/local/local_secrets.json run the setup.ps1 in deploy folder
if ($(Test-Path -Path './components/local/local_secrets.json') -eq $false) {
    Write-Output "Could not find ./components/local/local_secrets.json"
    
    Deploy-AzureInfrastructure -rgName $rgName -location $location
}

if ($env -eq "local") {
    Write-Output "Running .NET demo with local resources"

    # Make sure the dapr_zipkin container is running.
    docker start dapr_zipkin

    Write-Output "dapr run --app-id viewer --app-port 5000 --components-path ./components/local -- dotnet run --project ./src/csharp_viewer/viewer.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run --app-id processor --app-port 5030 --components-path ./components/local -- dotnet run --project ./src/csharp_processor/processor.csproj --urls "http://localhost:5030" `n"
    Write-Output "dapr run --app-id provider --app-port 5040 --components-path ./components/local -- dotnet run --project ./src/csharp_provider/provider.csproj --urls "http://localhost:5040" `n"

    tye run ./src/tye_local.yaml
}
elseif ($env -eq "multi") {
    Write-Output "Running demo with local resources"

    # Make sure the dapr_zipkin container is running.
    docker start dapr_zipkin

    # Build the java project
    mvn -f ./src/java_viewer/ clean install

    # Update Python
    pip3 install -r ./src/python_provider/requirements.txt

    Write-Output "dapr run --app-id viewer --app-port 8088 --components-path ./components/local -- java -jar ./src/java_viewer/target/app.jar `n"
    Write-Output "dapr run --app-id processor --app-port 5030 --components-path ./components/local -- dotnet run --project ./src/csharp_processor/processor.csproj --urls "http://localhost:5030" `n"
    Write-Output "dapr run --app-id provider --app-port 5040 --app-protocol grpc --components-path ./components/local -- python3 ./src/python_provider/provider.py `n"

    tye run ./src/tye_multi.yaml
}
elseif ($env -eq "node") {
    Write-Output "Running Node.js demo with local resources"

    # Make sure the dapr_zipkin container is running.
    docker start dapr_zipkin

    Push-Location ./src/javascript_processor/
    npm i
    Pop-Location

    Push-Location ./src/javascript_provider/
    npm i
    Pop-Location

    Write-Output "dapr run --app-id viewer --app-port 5000 --components-path ./components/local -- dotnet run --project ./src/csharp_viewer/viewer.csproj --urls "http://localhost:5000" `n"
    Write-Output "dapr run --app-id processor --app-port 5030 --components-path ./components/local -- node ./src/javascript_processor/app.js `n"
    Write-Output "dapr run --app-id provider --app-port 5040 --components-path ./components/local -- node ./src/javascript_provider/app.js `n"

    tye run ./src/tye_node.yaml
}
else {
    if ($null -eq $(docker images "k3d-registry.localhost:5500/*" -q)) {
        # Build all the images
        docker build -f ./src/csharp_viewer/Dockerfile -t k3d-registry.localhost:5500/csharpviewer:local ./src/csharp_viewer/
        docker build -f ./src/csharp_provider/Dockerfile -t k3d-registry.localhost:5500/csharpprovider:local ./src/csharp_provider/
        docker build -f ./src/csharp_processor/Dockerfile -t k3d-registry.localhost:5500/csharpprocessor:local ./src/csharp_processor/

        docker push k3d-registry.localhost:5500/csharpviewer:local
        docker push k3d-registry.localhost:5500/csharpprovider:local
        docker push k3d-registry.localhost:5500/csharpprocessor:local
    }

    helm dependency update ./charts/

    helm upgrade twitter ./charts/ --values ./charts/local.yaml --install --set enableZipkin=true --set viewer.viewer.nodePort='30000'
}