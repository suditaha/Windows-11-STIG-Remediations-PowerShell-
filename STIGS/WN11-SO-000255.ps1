<#
.SYNOPSIS
    This PowerShell script remediates Windows 11 STIG WN11-SO-000255 by automatically denying elevation requests for standard users.

.DESCRIPTION
    User Account Control controls how elevation requests are handled for standard users. DISA STIG WN11-SO-000255
    requires standard user elevation requests to be automatically denied. This prevents standard users from attempting
    to elevate privileges by entering administrator credentials at a UAC prompt.

.NOTES
    Author         : Sid Taha
    LinkedIn       : linkedin.com/in/sudita
    GitHub         : github.com/suditaha
    Date Created   : 2026-05-16
    Last Modified  : 2026-05-16
    Version        : 1.1
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-SO-000255

.TESTED ON
    Date(s) Tested : 2026-05-16
    Tested By      : Sid Taha
    Systems Tested : Windows 11
    PowerShell Ver.: 5.1+

.USAGE
    Run PowerShell as Administrator.
    Example syntax:
        PS C:\> .\WN11-SO-000255_Remediation.ps1
#>

# Remediate Windows 11 STIG: Automatically deny elevation requests for standard users
# Registry equivalent:
# [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
# "ConsentPromptBehaviorUser"=dword:00000000
#
# Value meanings:
# 0 = Automatically deny elevation requests (STIG compliant)
# 1 = Prompt for credentials on the secure desktop
# 3 = Prompt for credentials

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ValueName    = "ConsentPromptBehaviorUser"
$ValueType    = "DWord"
$ValueData    = 0

try {
    if (-not (Test-Path -Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
    }

    New-ItemProperty `
        -Path $RegistryPath `
        -Name $ValueName `
        -PropertyType $ValueType `
        -Value $ValueData `
        -Force | Out-Null

    Write-Host "Registry value configured successfully."
}
catch {
    Write-Host "Failed to configure registry value."
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}

try {
    $Verification = Get-ItemProperty -Path $RegistryPath -Name $ValueName -ErrorAction Stop
    $CurrentValue = $Verification.$ValueName

    Write-Host "`nVerification Results:"
    Write-Host "Registry Path : $RegistryPath"
    Write-Host "Value Name    : $ValueName"
    Write-Host "Value Data    : $CurrentValue"

    if ($CurrentValue -eq $ValueData) {
        Write-Host "`nSTIG remediation applied successfully: Standard user elevation requests are automatically denied."
    }
    else {
        Write-Host "`nSTIG remediation failed: Registry value is not set correctly."
        exit 1
    }
}
catch {
    Write-Host "`nSTIG remediation failed: Unable to verify registry value."
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
