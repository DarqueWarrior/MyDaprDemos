# This will start the deletion of a resource group but not wait.

[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
    )]
    [string]
    $rgName = "dapr_pubsub_demo",

    [Parameter(
        HelpMessage = "Set to the location of the resources to use."
    )]
    [ValidateSet("all", "azure", "aws")]
    [string]
    $env = "all",

    [switch]
    $force
)

. ../.scripts/common.ps1

if ($env -eq 'all' -or $env -eq 'azure') {
    # Remove local_secrets.json
    Remove-Item ./components/azure/local_secrets.json -ErrorAction SilentlyContinue

    Remove-ResourceGroup -name $rgName -force:$force -nowait
}

if ($env -eq 'all' -or $env -eq 'aws') {
    ### AWS
    Remove-AWS
}