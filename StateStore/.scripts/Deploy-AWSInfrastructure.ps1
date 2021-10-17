function Deploy-AWSInfrastructure {
    [CmdletBinding()]
    param ()
    
    begin {
        Push-Location -Path './deploy'
    }

    process {
        Write-Output 'Deploying the AWS infrastructure'
        
        
        Write-Output 'Saving ./aws/terraform.tfvars for terraform'
        "access_key = `"$env:AWS_ACCESS_KEY_ID`" `nsecret_key = `"$env:AWS_SECRET_ACCESS_KEY`"" | Set-Content ./aws/terraform.tfvars
    }

    end {
        Pop-Location
    }
}