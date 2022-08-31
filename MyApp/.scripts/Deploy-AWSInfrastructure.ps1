function Deploy-AWSInfrastructure {
    [CmdletBinding()]
    param ()

    begin {
        Push-Location -Path './deploy/aws'
    }

    process {
        Deploy-AWS
    }

    end {
        Pop-Location
    }
}