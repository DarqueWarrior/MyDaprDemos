# This will start the deletion of a resource group but not wait.

[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
    )]
    [string]
    $rgName = "stateStoreDemo",

    [switch]
    $force
)

if ($force.IsPresent) {
    az group delete --resource-group $rgName --no-wait --yes
}
else {
    az group delete --resource-group $rgName --no-wait
}
