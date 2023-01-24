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

. ../.scripts/common.ps1

# Remove local_secrets.json
Remove-Item ./charts/local.yaml -Force -ErrorAction SilentlyContinue
Remove-Item ./charts/charts/ -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ./components/local/local.env -Force -ErrorAction SilentlyContinue
Remove-Item ./components/local/local_secrets.json -Force -ErrorAction SilentlyContinue

Remove-ResourceGroup -name $rgName -force:$force

Write-Output "Getting soft deleted cognitive services"
$cs = $(az cognitiveservices account list-deleted --subscription $env:AZURE_SUB_ID --query [].name --output tsv)
$loc = $(az cognitiveservices account list-deleted --subscription $env:AZURE_SUB_ID --query [].location --output tsv)

if ($null -ne $cs) {
    Write-Output "Purging cognitive services $cs"
    az cognitiveservices account purge --subscription $env:AZURE_SUB_ID --name $cs --resource-group $rgName --location $loc
}