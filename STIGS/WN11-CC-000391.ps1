<#
.SYNOPSIS
    This PowerShell script remediates Windows 11 STIG WN11-CC-000391 by disabling Internet Explorer 11 as a standalone browser.

.DESCRIPTION
    DISA STIG WN11-CC-000391 requires Internet Explorer 11 to be disabled as a standalone browser.
    This script configures the required registry policy to suppress IE standalone access.

.NOTES
    Author         : Sid Taha
    LinkedIn       : linkedin.com/in/sudita
    GitHub         : github.com/suditaha
    Date Created   : 2026-05-16
    Last Modified  : 2026-05-16
    Version        : 1.1
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-CC-000391

.TESTED ON
    Date(s) Tested : 2026-05-16
    Tested By      : Sid Taha
    Systems Tested : Windows 11
    PowerShell Ver.: 5.1+

.USAGE
    Run PowerShell as Administrator.
    Example syntax:
        PS C:\> .\WN11-CC-000391_Remediation.ps1
#>

# Registry equivalent:
# HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main
# NotifyDisableIEOptions = 0

$BasePath     = "HKLM:\SOFTWARE\Policies\Microsoft"
$IEPath       = "$BasePath\Internet Explorer"
$RegistryPath = "$IEPath\Main"
$ValueName    = "NotifyDisableIEOptions"
$ValueType    = "DWord"
$ValueData    = 0

try {
    # Create parent path if missing
    if (-not (Test-Path $BasePath)) {
        throw "Base registry path does not exist."
    }

    if (-not (Test-Path $IEPath)) {
        New-Item -Path $BasePath -Name "Internet Explorer" -Force -ErrorAction Stop | Out-Null
    }

    if (-not (Test-Path $RegistryPath)) {
        New-Item -Path $IEPath -Name "Main" -Force -ErrorAction Stop | Out-Null
    }

    New-ItemProperty `
        -Path $RegistryPath `
        -Name $ValueName `
        -PropertyType $ValueType `
        -Value $ValueData `
        -Force `
        -ErrorAction Stop | Out-Null

    Write-Host "Registry value configured successfully."
}
catch {
    Write-Host "Failed to configure registry setting."
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}

# Verification
try {
    $Verification = Get-ItemProperty -Path $RegistryPath -Name $ValueName -ErrorAction Stop
    $CurrentValue = $Verification.$ValueName

    Write-Host "`nVerification Results:"
    Write-Host "Registry Path : $RegistryPath"
    Write-Host "Value Name    : $ValueName"
    Write-Host "Value Data    : $CurrentValue"

    if ($CurrentValue -eq $ValueData) {
        Write-Host "`nSTIG remediation applied successfully: Internet Explorer standalone browser access disabled."
    }
    else {
        Write-Host "`nSTIG remediation failed: Incorrect registry value."
        exit 1
    }
}
catch {
    Write-Host "`nSTIG remediation failed during verification."
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
