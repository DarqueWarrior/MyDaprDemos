function Deploy-GCPInfrastructure {
    [CmdletBinding()]
    param ()
    
    begin {
        Push-Location -Path './deploy/gcp'
    }

    process {
        Deploy-GCP
    }

    end {
        Pop-Location
    }
}