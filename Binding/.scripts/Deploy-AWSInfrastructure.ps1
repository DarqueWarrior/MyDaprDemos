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
        
        $sw = [Diagnostics.Stopwatch]::StartNew()

        if ($(Test-Path ./.terraform) -eq $false) {
            terraform init
        }

        terraform apply -auto-approve
        
        $sw.Stop()

        Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deploying aws_s3_bucket"
    }

    end {
        Pop-Location
    }
}