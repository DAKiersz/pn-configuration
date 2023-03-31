# A DSC Template for configuring PN1 local machine

Configuration PN1 {

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'PsDscResources'

    # Ask for elevated permissions, if not already running as admin.
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "This script must be run as Administrator. Restarting with elevated permissions..."
        Start-Sleep -Seconds 2
        Start-Process pwsh.exe -Verb runAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "$($MyInvocation.MyCommand.Path)"'
    }
    
    # TODO look into LCM
    # TODO metadata

    Node localhost
    {
        # Start Menu: Disable Bing Search
        Registry DisableBingSearch {
            Ensure = 'Present'
            Key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
            ValueName = 'BingSearchEnabled'
            ValueData = 0
            ValueType = 'DWord'
        }

        # TODO Disable Cortana fully
        # Start Menu: Disable Cortana
        Registry DisableCortanaSearch {
            Ensure = 'Present'
            Key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search'
            ValueName = 'CortanaConsent'
            ValueData = 0
            ValueType = 'DWord'
        }

        # TODO Disable location tracking fully

        # Disable Advertising info
        File AdvertisingInfoTelemetry {
            Ensure = 'Present'
            DestinationPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
            Type = 'File'
        }
        
        Registry DisableAdvertisingID {
            Ensure = 'Present'
            Key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo'
            ValueName = 'Enabled'
            ValueData = 0
            ValueType = 'DWord'
            DependsOn = '[File]AdvertisingInfoTelemetry'
        }

        # Disable Telemetry
        Registry DisableDatacollection {
            Ensure = 'Present'
            Key = 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection'
            ValueName = 'AllowTelemetry'
            ValueData = 0
            ValueType = 'DWord'
        }

        # Disable DiagTrack
        File DiagTrackTelemetry {
            Ensure = 'Present'
            DestinationPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\DiagTrack'
            Type = 'File'
        }

        Registry DisableDiagTrack {
            Ensure = 'Present'
            Key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\DiagTrack'
            ValueName = 'AllowTelemetry'
            ValueData = 0
            ValueType = 'DWord'
            DependsOn = '[File]DiagTrackTelemetry'
        }

        # Disable Windows Error Reporting
        Registry DisableWindowsErrorReporting {
            Ensure = 'Present'
            Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting'
            ValueName = 'Disabled'
            ValueData = 1
            ValueType = 'DWord'
        }

        # Disable Customer Experience Improvement Program
        Registry DisableCustomerExperienceImprovementProgram {
            Ensure = 'Present'
            Key = 'HKLM:\Software\Policies\Microsoft\SQMClient\Windows'
            ValueName = 'CEIPEnable'
            ValueData = 0
            ValueType = 'DWord'
        }
    }
}

#Start-DscConfiguration -Path "." -Wait -Force -Verbose