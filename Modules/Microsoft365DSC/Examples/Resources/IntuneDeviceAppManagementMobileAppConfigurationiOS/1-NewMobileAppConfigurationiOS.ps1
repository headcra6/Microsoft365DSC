<#
This example creates a new Intune iOS Mobile Application Configuration.
#>

Configuration Example
{
    param(
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $credsGlobalAdmin
    )
    Import-DscResource -ModuleName Microsoft365DSC

    node localhost
    {
        IntuneDeviceAppManagementMobileAppConfigurationiOS AddNewMobileAppConfigiOS
        {
            DisplayName          = 'Contoso'
            Description          = 'Contoso Policy'
            Ensure               = 'Present'
            Credential           = $credsGlobalAdmin;
        }
    }
}
