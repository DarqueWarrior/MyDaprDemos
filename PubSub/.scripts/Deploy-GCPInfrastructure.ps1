function Deploy-GCPInfrastructure {
    [CmdletBinding()]
    param ()
    
    begin {
        Push-Location -Path './deploy/gcp'
    }

    process {
        Write-Output 'Deploying the GCP infrastructure'

        Write-Output 'Saving ./terraform.tfvars for terraform'
        "project = `"$env:GCP_DEFAULT_PROJECT`" `nregion = `"$env:GCP_DEFAULT_REGION`"" | Set-Content ./terraform.tfvars

        $sw = [Diagnostics.Stopwatch]::StartNew()

        if ($(Test-Path ./.terraform) -eq $false) {
            terraform init
        }

        terraform apply -auto-approve

        $sw.Stop()

        Write-Verbose "Total elapsed time: $($sw.Elapsed.Minutes):$($sw.Elapsed.Seconds):$($sw.Elapsed.Milliseconds) for deploying a Azure Key Vault"
    }

    end {
        Pop-Location
    }
}