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

### Azure
# Remove clear out the vault name environment variable 
$env:AZURE_KEY_VAULT_NAME = $null 

Write-Output "Waiting for resource group to be deleted so the keyvault can be purged"
$sw = [Diagnostics.Stopwatch]::StartNew()

if ($force.IsPresent) {
    az group delete --resource-group $rgName --yes
}
else {
    az group delete --resource-group $rgName
}

Write-Output "Getting soft deleted key vaults"
$vault = $(az keyvault list-deleted --subscription $env:AZURE_SUB_ID --resource-type vault --query [].name --output tsv)

if ($null -ne $vault) {
    Write-Output "Purging key vault $vault"
    az keyvault purge --subscription $env:AZURE_SUB_ID --name $vault
}

$sw.Stop()

Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deleting a Azure Key Vault"

### AWS
# Delete AWS resources
if ($(Test-Path ./deploy/aws/terraform.tfvars)) {
    Push-Location ./deploy/aws
    $sw = [Diagnostics.Stopwatch]::StartNew()
    terraform destroy -auto-approve

    # If you don't do this you will have to wait 7 days to create a secret with the same name
    aws secretsmanager delete-secret --secret-id dapr-secret --region $env:AWS_DEFAULT_REGION --force-delete-without-recovery
    $sw.Stop()

    Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deleting a AWS Secrets Manager"
    Pop-Location
}

# Remove all terraform files
Remove-Item ./deploy/aws/terraform.tfvars -Force -ErrorAction SilentlyContinue
Remove-Item ./deploy/aws/terraform.tfstate -Force -ErrorAction SilentlyContinue
Remove-Item ./deploy/aws/.terraform -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item ./deploy/aws/.terraform.lock.hcl -Force -ErrorAction SilentlyContinue
Remove-Item ./deploy/aws/terraform.tfstate.backup -Force -ErrorAction SilentlyContinue