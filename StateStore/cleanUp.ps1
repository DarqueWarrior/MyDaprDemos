# This will start the deletion of a resource group but not wait.

[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
    )]
    [string]
    $rgName = "dapr_statestore_demo",

    [switch]
    $force,

    [switch]
    $timing
)

. ../.scripts/common.ps1

### Azure
# Remove local_secrets.json
Remove-Item ./components/azure/local_secrets.json -ErrorAction SilentlyContinue

if ($timing.IsPresent) {
    $sw = [Diagnostics.Stopwatch]::StartNew()

    Remove-ResourceGroup -name $rgName

    $sw.Stop()

    Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deleting a Azure Cosmos DB"
}
else {
    Remove-ResourceGroup -name $rgName -nowait
}

### AWS
# Remove local_secrets.json
Remove-Item ./components/aws/local_secrets.json -ErrorAction SilentlyContinue

# Delete AWS resources
if ($(Test-Path ./deploy/aws/terraform.tfvars)) {
    Push-Location ./deploy/aws
    $sw = [Diagnostics.Stopwatch]::StartNew()
    terraform destroy -auto-approve
    $sw.Stop()

    Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deleting a AWS DynamoDB"
    Pop-Location
}

# Remove all terraform files
Remove-Item ./deploy/aws/terraform.tfvars -Force -ErrorAction SilentlyContinue
Remove-Item ./deploy/aws/terraform.tfstate -Force -ErrorAction SilentlyContinue
Remove-Item ./deploy/aws/.terraform -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item ./deploy/aws/.terraform.lock.hcl -Force -ErrorAction SilentlyContinue
Remove-Item ./deploy/aws/terraform.tfstate.backup -Force -ErrorAction SilentlyContinue