# This will start the deletion of a resource group but not wait.

[CmdletBinding()]
param (
    [Parameter(
        Position = 0,
        HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
    )]
    [string]
    $rgName = "dapr_binding_demo",

    [Parameter(
        HelpMessage = "Set to the location of the resources to use."
    )]
    [ValidateSet("all", "local", "azure", "aws")]
    [string]
    $env = "all",

    [switch]
    $force
)

# Put the sampleRequests.http file back the way it was
git restore ./sampleRequests.http

if ($env -eq 'all' -or $env -eq 'local') {
    # Remove the myTestFile.txt
    Remove-Item ./tempfiles/myTestFile.txt -ErrorAction SilentlyContinue
}

if ($env -eq 'all' -or $env -eq 'azure') {
    if ($force.IsPresent) {
        az group delete --resource-group $rgName --no-wait --yes
    }
    else {
        az group delete --resource-group $rgName --no-wait
    }

    # Remove local_secrets.json
    Remove-Item ./components/azure/local_secrets.json -ErrorAction SilentlyContinue
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
}