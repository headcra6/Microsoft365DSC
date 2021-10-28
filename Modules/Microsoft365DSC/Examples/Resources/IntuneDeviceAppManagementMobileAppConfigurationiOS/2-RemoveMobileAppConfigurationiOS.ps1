<#
This example removes an existing Intune iOS Mobile Application Configuration.
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
        IntuneDeviceAppManagementMobileAppConfigurationiOS RemoveMobileAppConfigiOS
        {
            DisplayName          = 'Contoso'
            Description          = 'Contoso Policy'
            Ensure               = 'Absent'
            Credential           = $credsGlobalAdmin;
        }
    }
}
