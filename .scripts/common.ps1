function Remove-ResourceGroup {
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            HelpMessage = "The name of the resource group to be created. All resources will be place in the resource group and start with name."
        )]
        [string]
        $name,

        [switch]
        $nowait,

        [switch]
        $force
    )
    Write-Host "Cleaning up azure"

    if (@(az group list --query [].name --output tsv).IndexOf($name) -ne -1) {
        if ($force.IsPresent) {
            if ($nowait.IsPresent) {
                az group delete --resource-group $name --no-wait --yes
            }
            else {
                az group delete --resource-group $name --yes
            }
        }
        else {
            if ($nowait.IsPresent) {
                az group delete --resource-group $name --no-wait
            }
            else {
                az group delete --resource-group $name
            }
        }
    }
    else {
        Write-Verbose "Resource group '$name' not found."
    }
}

function Remove-Terraform {
    [CmdletBinding()]
    param (
        [string]
        $provider
    )

    Write-Host "Cleaning up $provider"
    
    # Remove local_secrets.json
    Remove-Item "./components/$provider/local_secrets.json" -ErrorAction SilentlyContinue

    # Delete Gcp resources
    if ($(Test-Path "./deploy/$provider/terraform.tfstate")) {
        Push-Location "./deploy/$provider"
        terraform destroy -auto-approve
        Pop-Location
    }
        
    # Remove all terraform files
    Remove-Item "./deploy/$provider/terraform.tfvars" -Force -ErrorAction SilentlyContinue
    Remove-Item "./deploy/$provider/terraform.tfstate" -Force -ErrorAction SilentlyContinue
    Remove-Item "./deploy/$provider/.terraform.lock.hcl" -Force -ErrorAction SilentlyContinue
    Remove-Item "./deploy/$provider/terraform.tfstate.backup" -Force -ErrorAction SilentlyContinue
    Remove-Item "./deploy/$provider/.terraform" -Force -Recurse -ErrorAction SilentlyContinue
}

function Remove-Gcp {
    Remove-Terraform -provider gcp
}

function Remove-AWS {
    Remove-Terraform -provider aws
}

function Deploy-GCP {
    [CmdletBinding()]
    param (
        [switch]
        $skipSecrets
    )
    
    Write-Output 'Deploying the GCP infrastructure'

    Write-Output 'Saving ./terraform.tfvars for terraform'
    "project_id = `"$env:GCP_DEFAULT_PROJECT`" `nregion = `"$env:GCP_DEFAULT_REGION`" `nlocation = `"$env:GCP_DEFAULT_LOCATION`"" | Set-Content ./terraform.tfvars

    if ($(Test-Path ./.terraform) -eq $false) {
        terraform init
    }

    terraform apply -auto-approve

    if (-not $skipSecrets.IsPresent) {
        Write-Output 'Saving ../../components/gcp/local_secrets.json for local secret store'
        $env:GCP_KEY | Set-Content ../../components/gcp/local_secrets.json
    }
}

function Deploy-AWS {
    [CmdletBinding()]
    param (
        [switch]
        $skipSecrets
    )
    
    Write-Output 'Deploying the AWS infrastructure'

    Write-Output 'Saving ./terraform.tfvars for terraform'
    "access_key = `"$env:AWS_ACCESS_KEY_ID`" `nsecret_key = `"$env:AWS_SECRET_ACCESS_KEY`"" | Set-Content ./terraform.tfvars

    if ($(Test-Path ./.terraform) -eq $false) {
        terraform init
    }

    terraform apply -auto-approve

    if (-not $skipSecrets.IsPresent) {
        # Creating components/aws/local_secrets.json
        $secrets = [PSCustomObject]@{
            accessKey = $env:AWS_ACCESS_KEY_ID
            secretKey = $env:AWS_SECRET_ACCESS_KEY
        }

        Write-Output 'Saving ../../components/aws/local_secrets.json for local secret store'
        $secrets | ConvertTo-Json | Set-Content ../../components/aws/local_secrets.json
    }
}