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
        $Settings,

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

        Write-Verbose -Message "Found Intune iOS Application Configuration {$DisplayName}"
        return @{
            Description                                                 = $appConfiguration.Description
            DisplayName                                                 = $appConfiguration.DisplayName
            TargetedMobileApps                                          = $appConfiguration.TargetedMobileApps
            RoleScopeTagIds                                             = $appConfiguration.RoleScopeTagIds
            Version                                                     = $appConfiguration.Version
            EncodedSettingXml                                           = $appConfiguration.EncodedSettingXml
            Settings                                                    = $appConfiguration.Settings
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
        $Settings,

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
        $AdditionalProperties = Get-M365DSCIntuneDeviceAppManagementMobileAppConfigurationiOSAdditionalProperties -Properties ([System.Collections.Hashtable]$PSBoundParameters)
        New-MgDeviceAppManagementMobileAppConfiguration -DisplayName $DisplayName `
            -Description $Description `
            -AdditionalProperties $AdditionalProperties
    }
    elseif ($Ensure -eq 'Present' -and $currentAppConfiguration.Ensure -eq 'Present')
    {
        Write-Verbose -Message "Updating existing Intune iOS Application Configuration {$DisplayName}"
        $appConfiguration = Get-MgDeviceAppManagementMobileAppConfiguration -Filter "displayName eq '$DisplayName'" `
            -ErrorAction Stop | Where-Object -FilterScript { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.iosMobileAppConfiguration' }

        $PSBoundParameters.Remove('DisplayName') | Out-Null
        $PSBoundParameters.Remove('Description') | Out-Null
        $AdditionalProperties = Get-M365DSCIntuneDeviceAppManagementMobileAppConfigurationiOSAdditionalProperties -Properties ([System.Collections.Hashtable]$PSBoundParameters)
        Update-MgDeviceAppManagementMobileAppConfiguration -AdditionalProperties $AdditionalProperties `
            -Description $Description `
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
        $Settings,

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
    #$ResourceName = "IntuneDeviceAppManagementMobileAppConfigurationiOS"
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
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $ResourceName `
                -ConnectionMode $ConnectionMode `
                -ModulePath $PSScriptRoot `
                -Results $Results `
                -Credential $Credential
                #-ModulePath $PSScriptRoot `
                #-ModulePath "D:\Github\Microsoft365DSC\Modules\Microsoft365DSC\DSCResources\MSFT_IntuneDeviceAppManagementMobileAppConfigurationiOS\MSFT_IntuneDeviceAppManagementMobileAppConfigurationiOS.psm1" `
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

function Get-M365DSCIntuneDeviceAppManagementMobileAppConfigurationiOSAdditionalProperties
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = 'true')]
        [System.Collections.Hashtable]
        $Properties
    )

    $results = @{"@odata.type" = "#microsoft.graph.iosMobileAppConfiguration"}
    foreach ($property in $properties.Keys)
    {
        if ($property -ne 'Verbose')
        {
            $propertyName = $property[0].ToString().ToLower() + $property.Substring(1, $property.Length - 1)
            $propertyValue = $properties.$property
            $results.Add($propertyName, $propertyValue)
        }
    }
    return $results
}

Export-ModuleMember -Function *-TargetResource
