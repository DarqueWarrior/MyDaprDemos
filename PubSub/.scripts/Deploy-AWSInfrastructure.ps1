function Deploy-AWSInfrastructure {
    [CmdletBinding()]
    param ()
    
    begin {
        Push-Location -Path './deploy/aws'
    }

    process {
        Write-Output 'Deploying the AWS infrastructure'

        Write-Output 'Saving ./terraform.tfvars for terraform'
        "access_key = `"$env:AWS_ACCESS_KEY_ID`" `nsecret_key = `"$env:AWS_SECRET_ACCESS_KEY`"" | Set-Content ./terraform.tfvars

        if ($(Test-Path ./.terraform) -eq $false) {
            terraform init
        }

        terraform apply -auto-approve

        # Creating components/aws/local_secrets.json
        $secrets = [PSCustomObject]@{
            accessKey  = $env:AWS_ACCESS_KEY_ID
            secretKey = $env:AWS_SECRET_ACCESS_KEY
        }

        Write-Output 'Saving ../../components/aws/local_secrets.json for local secret store'
        $secrets | ConvertTo-Json | Set-Content ../../components/aws/local_secrets.json
    }

    end {
        Pop-Location
    }
}