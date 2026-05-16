<#
.SYNOPSIS
    This PowerShell script remediates Windows 11 STIG WN11-SO-000070 by configuring the machine inactivity limit to 15 minutes or less.

.DESCRIPTION
    The machine inactivity limit controls how long a system can remain idle before Windows automatically locks the session.
    DISA STIG WN11-SO-000070 requires the system to lock after 15 minutes or less of inactivity. This script sets the
    inactivity timeout to 900 seconds, which equals 15 minutes.

.NOTES
    Author         : Sid Taha
    LinkedIn       : linkedin.com/in/sudita
    GitHub         : github.com/suditaha
    Date Created   : 2026-05-15
    Last Modified  : 2026-05-15
    Version        : 1.0
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-SO-000070

.TESTED ON
    Date(s) Tested : 2026-05-15
    Tested By      : Sid Taha
    Systems Tested : Windows 11
    PowerShell Ver.: 5.1+

.USAGE
    Run PowerShell as Administrator.
    Example syntax:
        PS C:\> .\WN11-SO-000070_Remediation.ps1
#>

# Remediate Windows 11 STIG: Configure machine inactivity limit to 15 minutes or less
# Registry equivalent:
# [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
# "InactivityTimeoutSecs"=dword:00000384

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ValueName    = "InactivityTimeoutSecs"
$ValueType    = "DWord"
$ValueData    = 900   # 900 seconds = 15 minutes

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
    Write-Host "Value Data    : $CurrentValue seconds"

    if ($CurrentValue -le 900 -and $CurrentValue -gt 0) {
        Write-Host "`nSTIG remediation applied successfully: Machine inactivity limit is configured to 15 minutes or less."
    }
    else {
        Write-Host "`nSTIG remediation failed: Machine inactivity limit is not configured correctly."
        exit 1
    }
}
catch {
    Write-Host "`nSTIG remediation failed: Unable to verify registry value."
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
