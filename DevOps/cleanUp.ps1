# This will start the deletion of a resource group but not wait.

[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
    )]
    [string]
    $rgName = "dapr_devops_demo",

    [switch]
    $force
)

# Remove local_secrets.json
Remove-Item ./charts/local.yaml -Force -ErrorAction SilentlyContinue
Remove-Item ./charts/charts/ -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ./components/local/local.env -Force -ErrorAction SilentlyContinue
Remove-Item ./components/local/local_secrets.json -Force -ErrorAction SilentlyContinue

if ($force.IsPresent) {
    az group delete --resource-group $rgName --no-wait --yes
}
else {
    az group delete --resource-group $rgName --no-wait
}

az group show -g $rgName -o yaml