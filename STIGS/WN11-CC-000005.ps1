<#
.SYNOPSIS
    This PowerShell script remediates Windows 11 STIG WN11-CC-000005 by disabling camera access from the lock screen.

.DESCRIPTION
    Camera access from the lock screen could allow unauthorized use of the device camera before a user has logged on.
    DISA STIG WN11-CC-000005 requires camera access from the lock screen to be disabled. This script enables the
    "Prevent enabling lock screen camera" policy by setting the NoLockScreenCamera registry value.

.NOTES
    Author         : Sid Taha
    LinkedIn       : linkedin.com/in/sudita
    GitHub         : github.com/suditaha
    Date Created   : 2026-05-16
    Last Modified  : 2026-05-16
    Version        : 1.0
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-CC-000005

.TESTED ON
    Date(s) Tested : 2026-05-16
    Tested By      : Sid Taha
    Systems Tested : Windows 11
    PowerShell Ver.: 5.1+

.USAGE
    Run PowerShell as Administrator.
    Example syntax:
        PS C:\> .\WN11-CC-000005_Remediation.ps1
#>

# Remediate Windows 11 STIG: Disable camera access from the lock screen
# Registry equivalent:
# [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization]
# "NoLockScreenCamera"=dword:00000001

$RegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$ValueName    = "NoLockScreenCamera"
$ValueType    = "DWord"
$ValueData    = 1

try {
    # Ensure registry path exists
    if (-not (Test-Path -Path $RegistryPath)) {
        New-Item -Path $RegistryPath -Force | Out-Null
    }

    # Create or update registry value
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

# Final verification
try {
    $Verification = Get-ItemProperty -Path $RegistryPath -Name $ValueName -ErrorAction Stop
    $CurrentValue = $Verification.$ValueName

    Write-Host "`nVerification Results:"
    Write-Host "Registry Path : $RegistryPath"
    Write-Host "Value Name    : $ValueName"
    Write-Host "Value Data    : $CurrentValue"

    if ($CurrentValue -eq $ValueData) {
        Write-Host "`nSTIG remediation applied successfully: Camera access from the lock screen is disabled."
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
