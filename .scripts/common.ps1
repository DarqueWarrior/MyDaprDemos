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