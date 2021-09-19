# This will start the deletion of a resource group but not wait.

[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
    )]
    [string]
    $rgName = "dapr_secrets_demo",

    [switch]
    $force
)

# Remove clear out the vault name environment variable 
$env:VAULTNAME = $null 

Write-Output "Waiting for resource group to be deleted so the keyvault can be purged"
if ($force.IsPresent) {
    az group delete --resource-group $rgName --yes
}
else {
    az group delete --resource-group $rgName
}

Write-Output "Getting soft deleted key vaults"
$vault = $(az keyvault list-deleted --subscription $env:SUBID --resource-type vault --query [].name --output tsv)

if ($null -ne $vault) {
    Write-Output "Purging key vault $vault"
    az keyvault purge --subscription $env:SUBID --name $vault
}