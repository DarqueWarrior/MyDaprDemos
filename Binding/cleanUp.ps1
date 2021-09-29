# This will start the deletion of a resource group but not wait.

[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
    )]
    [string]
    $rgName = "dapr_binding_demo",

    [switch]
    $force
)

# Put the sampleRequests.http file back the way it was
git restore ./sampleRequests.http

# Remove the myTestFile.txt
Remove-Item ./tempfiles/myTestFile.txt -ErrorAction SilentlyContinue

# Remove local_secrets.json
Remove-Item ./components/azure/local_secrets.json -ErrorAction SilentlyContinue

if ($force.IsPresent) {
    az group delete --resource-group $rgName --no-wait --yes
}
else {
    az group delete --resource-group $rgName --no-wait
}