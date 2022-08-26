# This will start the deletion of a resource group but not wait.

[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
    )]
    [string]
    $rgName = "dapr_secrets_demo",

    [Parameter(
        HelpMessage = "Set to the location of the resources to use."
    )]
    [ValidateSet("all", "azure", "aws")]
    [string]
    $env = "all",

    [switch]
    $force
)

if ($env -eq 'all' -or $env -eq 'azure') {
    # Remove clear out the vault name environment variable 
    $env:AZURE_KEY_VAULT_NAME = $null 

    Write-Output "Waiting for resource group to be deleted so the keyvault can be purged"
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
}

if ($env -eq 'all' -or $env -eq 'aws') {
    ### AWS
    # Delete AWS resources
    if ($(Test-Path ./deploy/aws/terraform.tfvars)) {
        Push-Location ./deploy/aws
        $sw = [Diagnostics.Stopwatch]::StartNew()
        terraform destroy -auto-approve
        $sw.Stop()

        Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deleting a AWS S3"
        Pop-Location
    }

    # Remove all terraform files
    Remove-Item ./deploy/aws/terraform.tfvars -Force -ErrorAction SilentlyContinue
    Remove-Item ./deploy/aws/terraform.tfstate -Force -ErrorAction SilentlyContinue
    Remove-Item ./deploy/aws/.terraform -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item ./deploy/aws/.terraform.lock.hcl -Force -ErrorAction SilentlyContinue
    Remove-Item ./deploy/aws/terraform.tfstate.backup -Force -ErrorAction SilentlyContinue

    # When you delete a secret, Secrets Manager doesn't immediately delete the
    # secret. Secrets Manager schedules the secret for deletion after a
    # recovery window of a minimum of seven days. This means that you can't 
    # recreate a secret using the same name using the AWS Management Console
    # until the recovery window ends. You can permanently delete a secret 
    # without any recovery window using the AWS Command Line Interface (AWS CLI)
    Write-Output "Purging secret my-secret"
    aws secretsmanager delete-secret --secret-id my-secret --force-delete-without-recovery --region $env:AWS_DEFAULT_REGION
}