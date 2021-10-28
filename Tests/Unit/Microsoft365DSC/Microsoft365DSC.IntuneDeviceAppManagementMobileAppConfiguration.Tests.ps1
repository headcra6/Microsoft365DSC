[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath "..\..\Unit" `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\Stubs\Microsoft365.psm1" `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\Stubs\Generic.psm1" `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "IntuneDeviceAppManagementMobileAppConfiguration" -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString "Pass@word1" -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {

            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }

            Mock -CommandName Update-MgDeviceAppManagementMobileAppConfiguration -MockWith {
            }
            Mock -CommandName New-MgDeviceAppManagementMobileAppConfiguration -MockWith {
            }
            Mock -CommandName Remove-MgDeviceAppManagementMobileAppConfiguration -MockWith {
            }
        }

        # Test contexts
        Context -Name "When the Intune iOS Application Configuration doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Intune iOS Application Configuration'
                    Description        = 'Test Definition'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-MgDeviceAppManagementMobileAppConfiguration -MockWith {
                    return $null
                }
            }

            It "Should return absent from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should create the Intune iOS Application Configuration from the Set method" {
                Set-TargetResource @testParams
                Should -Invoke -CommandName "New-MgDeviceAppManagementMobileAppConfiguration" -Exactly 1
            }
        }

        Context -Name "When the Intune iOS Application Configuration already exists and is NOT in the Desired State" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Intune iOS Application Configuration'
                    Description        = 'Test Definition'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-MgDeviceAppManagementMobileAppConfiguration -MockWith {
                    return @{
                        DisplayName = 'Test Intune iOS Application Configuration'
                        Description = 'Different Value'
                        Id          = 'ecea44fd-d6cf-4be9-85a6-33e76a0c0630'
                        TargetedMobileApps   = '{5b0a1753-03f9-4dd8-8666-a622daf357d5}'
                        Version              = 1
                        AdditionalProperties = @{
                            '@odata.type'  = '#microsoft.graph.iosMobileAppConfiguration'
                            Settings        = @(
                                @{
                                    appConfigKey = 'com.microsoft.outlook.EmailProfile.EmailAddress'
                                    appConfigKeyType = 'stringType'
                                    appConfigKeyValue = '{{mail}}'
                                },
                                @{
                                    appConfigKey = 'com.microsoft.outlook.Mail.FocusedInbox'
                                    appConfigKeyType = 'booleanType'
                                    appConfigKeyValue = 'true'
                                }
                            )
                        }
                    }
                }
            }

            It "Should return Present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should update the Intune iOS Application Configuration from the Set method" {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Update-MgDeviceAppManagementMobileAppConfiguration -Exactly 1
            }
        }

        Context -Name "When the Intune iOS Application Configuration already exists and IS in the Desired State" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Intune iOS Application Configuration'
                    Description        = 'Test Definition'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-MgDeviceAppManagementMobileAppConfiguration -MockWith {
                    return @{
                        DisplayName        = 'Test Intune iOS Application Configuration'
                        Description        = 'Test Definition'
                        AdditionalProperties = @{
                            '@odata.type'  = '#microsoft.graph.iosMobileAppConfiguration'
                        }
                    }
                }
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "When the Intune iOS Application Configuration exists and it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName             = 'Test Intune iOS Application Configuration'
                    Description             = 'Test Definition'
                    Ensure                  = 'Absent'
                    Credential              = $Credential
                }

                Mock -CommandName Get-MgDeviceAppManagementMobileAppConfiguration -MockWith {
                    return @{
                        DisplayName = 'Test Intune iOS Application Configuration'
                        Description = 'Different Value'
                        Id          = 'ecea44fd-d6cf-4be9-85a6-33e76a0c0630'
                        TargetedMobileApps   = '{5b0a1753-03f9-4dd8-8666-a622daf357d5}'
                        Version              = 1
                        AdditionalProperties = @{
                            '@odata.type'  = '#microsoft.graph.iosMobileAppConfiguration'
                            Settings        = @(
                                @{
                                    appConfigKey = 'com.microsoft.outlook.EmailProfile.EmailAddress'
                                    appConfigKeyType = 'stringType'
                                    appConfigKeyValue = '{{mail}}'
                                },
                                @{
                                    appConfigKey = 'com.microsoft.outlook.Mail.FocusedInbox'
                                    appConfigKeyType = 'booleanType'
                                    appConfigKeyValue = 'true'
                                }
                            )
                        }
                    }
                }
            }

            It "Should return Present from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It "Should return true from the Test method" {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should remove the Intune iOS Application Configuration from the Set method" {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Remove-MgDeviceAppManagementMobileAppConfiguration -Exactly 1
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgDeviceAppManagementMobileAppConfiguration -MockWith {
                    return @{
                        DisplayName = 'Test Intune iOS Application Configuration'
                        Description = 'Different Value'
                        Id          = 'ecea44fd-d6cf-4be9-85a6-33e76a0c0630'
                        TargetedMobileApps   = '{5b0a1753-03f9-4dd8-8666-a622daf357d5}'
                        Version              = 1
                        AdditionalProperties = @{
                            '@odata.type'  = '#microsoft.graph.iosMobileAppConfiguration'
                            Settings        = @(
                                @{
                                    appConfigKey = 'com.microsoft.outlook.EmailProfile.EmailAddress'
                                    appConfigKeyType = 'stringType'
                                    appConfigKeyValue = '{{mail}}'
                                },
                                @{
                                    appConfigKey = 'com.microsoft.outlook.Mail.FocusedInbox'
                                    appConfigKeyType = 'booleanType'
                                    appConfigKeyValue = 'true'
                                }
                            )
                        }
                    }
                }
            }

            It "Should Reverse Engineer resource from the Export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
