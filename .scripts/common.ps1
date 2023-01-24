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

    begin {

    }

    process {
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

    end {

    }
}

function Remove-AWS {
    # Remove local_secrets.json
    Remove-Item ./components/aws/local_secrets.json -ErrorAction SilentlyContinue

    # Delete AWS resources
    if ($(Test-Path ./deploy/aws/terraform.tfvars)) {
        Push-Location ./deploy/aws
        terraform destroy -auto-approve
        Pop-Location
    }

    # Remove all terraform files
    Remove-Item ./deploy/aws/terraform.tfvars -Force -ErrorAction SilentlyContinue
    Remove-Item ./deploy/aws/terraform.tfstate -Force -ErrorAction SilentlyContinue
    Remove-Item ./deploy/aws/.terraform -Force -Recurse -ErrorAction SilentlyContinue
    Remove-Item ./deploy/aws/.terraform.lock.hcl -Force -ErrorAction SilentlyContinue
    Remove-Item ./deploy/aws/terraform.tfstate.backup -Force -ErrorAction SilentlyContinue
}

function Deploy-AWS {
    [CmdletBinding()]
    param (
        [switch]
        $skipSecrets
    )

    begin {

    }

    process {
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

    end {

    }
}