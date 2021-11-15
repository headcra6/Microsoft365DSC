function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (

        [Parameter(Mandatory = $True)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $TargetedMobileApps,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Int32]
        $Version,

        [Parameter()]
        [System.String]
        $EncodedSettingXml,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AppConfigSettings,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Write-Verbose -Message "Checking for the Intune iOS Application Configuration {$DisplayName}"

    $M365DSCConnectionSplat = @{
        Workload = 'MicrosoftGraph'
        InboundParameters = $PSBoundParameters
        ProfileName = 'Beta'
    }
    $ConnectionMode = New-M365DSCConnection @M365DSCConnectionSplat
    Select-MGProfile -Name 'Beta' | Out-Null

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace("MSFT_", "")
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $ResourceName)
    $data.Add("Method", $MyInvocation.MyCommand)
    $data.Add("Principal", $Credential.UserName)
    $data.Add("TenantId", $TenantId)
    $data.Add("ConnectionMode", $ConnectionMode)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $nullResult = $PSBoundParameters
    $nullResult.Ensure = 'Absent'

    try
    {
        $appConfiguration = Get-MgDeviceAppManagementMobileAppConfiguration -Filter "displayName eq '$DisplayName'" `
            -ErrorAction Stop | Where-Object -FilterScript { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.iosMobileAppConfiguration' }

        if ($null -eq $appConfiguration)
        {
            Write-Verbose -Message "No Intune iOS Application Configuration {$DisplayName} was found"
            return $nullResult
        }

        $appSettingsObj = Get-M365DSCIntuneDeviceAppManagementMobileAppConfigurationiOSSettings -Properties $appConfiguration.AdditionalProperties

        Write-Verbose -Message "Found Intune iOS Application Configuration {$DisplayName}"
        return @{
            Description                                                 = $appConfiguration.Description
            DisplayName                                                 = $appConfiguration.DisplayName
            TargetedMobileApps                                          = $appConfiguration.TargetedMobileApps
            RoleScopeTagIds                                             = $appConfiguration.RoleScopeTagIds
            Version                                                     = $appConfiguration.Version
            EncodedSettingXml                                           = $appConfiguration.EncodedSettingXml
            AppConfigSettings                                           = $appSettingsObj
            Ensure                                                      = "Present"
            Credential                                                  = $Credential
            ApplicationId                                               = $ApplicationId
            TenantId                                                    = $TenantId
            ApplicationSecret                                           = $ApplicationSecret
            CertificateThumbprint                                       = $CertificateThumbprint
        }
    }
    catch
    {
        try
        {
            Write-Verbose -Message $_
            $tenantIdValue = ""
            $tenantIdValue = $Credential.UserName.Split('@')[1]
            Add-M365DSCEvent -Message $_ -EntryType 'Error' `
                -EventID 1 -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $tenantIdValue
        }
        catch
        {
            Write-Verbose -Message $_
        }
        return $nullResult
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (

        [Parameter(Mandatory = $True)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $TargetedMobileApps,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Int32]
        $Version,

        [Parameter()]
        [System.String]
        $EncodedSettingXml,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AppConfigSettings,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    $M365DSCConnectionSplat = @{
        Workload = 'MicrosoftGraph'
        InboundParameters = $PSBoundParameters
        ProfileName = 'Beta'
    }
    $ConnectionMode = New-M365DSCConnection @M365DSCConnectionSplat
    Select-MGProfile -Name 'Beta' | Out-Null

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace("MSFT_", "")
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $ResourceName)
    $data.Add("Method", $MyInvocation.MyCommand)
    $data.Add("Principal", $Credential.UserName)
    $data.Add("TenantId", $TenantId)
    $data.Add("ConnectionMode", $ConnectionMode)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    $currentAppConfiguration = Get-TargetResource @PSBoundParameters
    $PSBoundParameters.Remove("Ensure") | Out-Null
    $PSBoundParameters.Remove("Credential") | Out-Null
    $PSBoundParameters.Remove("ApplicationId") | Out-Null
    $PSBoundParameters.Remove("TenantId") | Out-Null
    $PSBoundParameters.Remove("ApplicationSecret") | Out-Null
    if ($Ensure -eq 'Present' -and $currentAppConfiguration.Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Creating new Intune iOS Application Configuration {$DisplayName}"
        $PSBoundParameters.Remove('DisplayName') | Out-Null
        $PSBoundParameters.Remove('Description') | Out-Null
        $AdditionalProperties = Convert-M365DSCIntuneDeviceAppManagementMobileAppConfigurationiOSSettingsListToAdditionalProperties -Properties ([System.Collections.Hashtable]$AppConfigSettings)
        New-MgDeviceAppManagementMobileAppConfiguration -DisplayName $DisplayName `
            -Description $Description `
            -RoleScopeTagIds $RoleScopeTagIds `
            -TargetedMobileApps $TargetedMobileApps `
            -Version $Version
            -AdditionalProperties $AdditionalProperties
    }
    elseif ($Ensure -eq 'Present' -and $currentAppConfiguration.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating existing Intune iOS Application Configuration {$DisplayName}"
        $appConfiguration = Get-MgDeviceAppManagementMobileAppConfiguration -Filter "displayName eq '$DisplayName'" `
            -ErrorAction Stop | Where-Object -FilterScript { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.iosMobileAppConfiguration' }

        $PSBoundParameters.Remove('DisplayName') | Out-Null
        $PSBoundParameters.Remove('Description') | Out-Null
        $AdditionalProperties = Convert-M365DSCIntuneDeviceAppManagementMobileAppConfigurationiOSSettingsListToAdditionalProperties -Properties ([System.Collections.Hashtable]$AppConfigSettings)
        Update-MgDeviceAppManagementMobileAppConfiguration -AdditionalProperties $AdditionalProperties `
            -Description $Description `
            -RoleScopeTagIds $RoleScopeTagIds `
            -TargetedMobileApps $TargetedMobileApps `
            -Version $Version
            -AdditionalProperties $AdditionalProperties
            -ManagedDeviceMobileAppConfigurationId $appConfiguration.Id
    }
    elseif ($Ensure -eq 'Absent' -and $currentAppConfiguration.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Removing Intune iOS Application Configuration {$DisplayName}"
        $appConfiguration = Get-MgDeviceAppManagementMobileAppConfiguration -Filter "displayName eq '$DisplayName'" `
            -ErrorAction Stop | Where-Object -FilterScript { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.iosMobileAppConfiguration' }

        Remove-MgDeviceAppManagementMobileAppConfiguration -ManagedDeviceMobileAppConfigurationId $appConfiguration.Id
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (

        [Parameter(Mandatory = $True)]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Description,

        [Parameter()]
        [System.String[]]
        $TargetedMobileApps,

        [Parameter()]
        [System.String[]]
        $RoleScopeTagIds,

        [Parameter()]
        [System.Int32]
        $Version,

        [Parameter()]
        [System.String]
        $EncodedSettingXml,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $AppConfigSettings,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet('Absent', 'Present')]
        $Ensure,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )
    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace("MSFT_", "")
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $ResourceName)
    $data.Add("Method", $MyInvocation.MyCommand)
    $data.Add("Principal", $Credential.UserName)
    $data.Add("TenantId", $TenantId)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion
    Write-Verbose -Message "Testing of Intune iOS Application Configuration {$DisplayName}"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $ValuesToCheck = $PSBoundParameters
    $ValuesToCheck.Remove('Credential') | Out-Null
    $ValuesToCheck.Remove('ApplicationId') | Out-Null
    $ValuesToCheck.Remove('TenantId') | Out-Null
    $ValuesToCheck.Remove('ApplicationSecret') | Out-Null

    $TestResult = Test-M365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck $ValuesToCheck.Keys

    Write-Verbose -Message "Test-TargetResource returned $TestResult"

    return $TestResult
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $ApplicationSecret,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    $M365DSCConnectionSplat = @{
        Workload = 'MicrosoftGraph'
        InboundParameters = $PSBoundParameters
        ProfileName = 'Beta'
    }
    $ConnectionMode = New-M365DSCConnection @M365DSCConnectionSplat
    Select-MGProfile -Name 'Beta' | Out-Null

    #region Telemetry
    $ResourceName = $MyInvocation.MyCommand.ModuleName.Replace("MSFT_", "")
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $ResourceName)
    $data.Add("Method", $MyInvocation.MyCommand)
    $data.Add("Principal", $Credential.UserName)
    $data.Add("TenantId", $TenantId)
    $data.Add("ConnectionMode", $ConnectionMode)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    try
    {
        [array]$appConfigurations = Get-MgDeviceAppManagementMobileAppConfiguration `
            -ErrorAction Stop | Where-Object `
            -FilterScript { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.iosMobileAppConfiguration' }
        $i = 1
        $dscContent = ''
        if ($appConfigurations.Length -eq 0)
        {
            Write-Host $Global:M365DSCEmojiGreenCheckMark
        }
        else
        {
            Write-Host "`r`n" -NoNewLine
        }
        foreach ($appConfiguration in $appConfigurations)
        {
            Write-Host "    |---[$i/$($appConfigurations.Count)] $($appConfiguration.DisplayName)" -NoNewline
            $params = @{
                DisplayName           = $appConfiguration.DisplayName
                Ensure                = 'Present'
                Credential            = $Credential
                ApplicationId         = $ApplicationId
                TenantId              = $TenantId
                ApplicationSecret     = $ApplicationSecret
                CertificateThumbprint = $CertificateThumbprint
            }
            $Results = Get-TargetResource @Params
            $Results = Update-M365DSCExportAuthenticationResults -ConnectionMode $ConnectionMode `
                -Results $Results

            if ($Results.AppConfigSettings.Count -gt 0) {
                $Results.AppConfigSettings = Get-M365DSCIntuneDeviceAppManagementMobileAppConfigurationiOSSettingsAsString -AppConfigSettings $Results.AppConfigSettings
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential

            if ($null -ne $Results.AppConfigSettings) {
                $currentDSCBlock = Convert-DSCStringParamToVariable -DSCBlock $currentDSCBlock `
                    -ParameterName "AppConfigSettings"
            }
            $dscContent += $currentDSCBlock
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            $i++
            Write-Host $Global:M365DSCEmojiGreenCheckMark
        }
        return $dscContent
    }
    catch
    {
        Write-Host $Global:M365DSCEmojiRedX
        Write-Host $_
        if ($_.Exception -like '*401*')
        {
            Write-Host "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
        }
        try
        {
            Write-Verbose -Message $_
            $tenantIdValue = $Credential.UserName.Split('@')[1]

            Add-M365DSCEvent -Message $_ -EntryType 'Error' `
                -EventID 1 -Source $($MyInvocation.MyCommand.Source) `
                -TenantId $tenantIdValue
        }
        catch
        {
            Write-Verbose -Message $_
        }
        return ""
    }
}

function Get-M365DSCIntuneDeviceAppManagementMobileAppConfigurationiOSSettings
{
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        $Properties
    )

    Write-Verbose -Message "Retrieving settings from current configuration"
    $appConfigSettings = @()
    foreach ($setting in $Properties.settings) {
        $settingKeyValuePair=@{}
        foreach ($key in $setting.Keys) {
            $settingKeyValuePair.Add($key,$setting.$key)
        }
        $appConfigSettings += $settingKeyValuePair
    }

    return $appConfigSettings
}

function Get-M365DSCIntuneDeviceAppManagementMobileAppConfigurationiOSSettingsAsString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]
        $AppConfigSettings
    )

    $stringContent = "@(`r`n"
    foreach ($setting in $AppConfigSettings)
    {
        $stringContent += "`t`t`t`tMSFT_IntuneAppConfigurationSettingItem { `r`n"
        $stringContent += "`t`t`t`t`tappConfigKey                = '" + $setting.appConfigKey + "'`r`n"
        $stringContent += "`t`t`t`t`tappConfigKeyType            = '" + $setting.appConfigKeyType + "'`r`n"
        $stringContent += "`t`t`t`t`tappConfigKeyValue           = '" + $setting.appConfigKeyValue + "'`r`n"
        $StringContent += "`t`t`t`t}`r`n"
    }
    $stringContent += "`t`t`t)"
    return $stringContent
}

Export-ModuleMember -Function *-TargetResource
