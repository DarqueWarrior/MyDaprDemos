function Deploy-AWSInfrastructure {
    [CmdletBinding()]
    param ()

    begin {
        Push-Location -Path './deploy/aws'
    }

    process {
        Deploy-AWS -skipSecrets
    }

    end {
        Pop-Location
    }
}