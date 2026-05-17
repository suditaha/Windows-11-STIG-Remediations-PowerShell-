<#
.SYNOPSIS
    This PowerShell script remediates Windows 11 STIG WN11-SO-000245 by enabling User Account Control approval mode for the built-in Administrator account.

.DESCRIPTION
    User Account Control approval mode for the built-in Administrator account requires the built-in Administrator
    to run with Admin Approval Mode enabled instead of running all elevated applications with full administrative
    privileges by default. DISA STIG WN11-SO-000245 requires this setting to be enabled.

.NOTES
    Author         : Sid Taha
    LinkedIn       : linkedin.com/in/sudita
    GitHub         : github.com/suditaha
    Date Created   : 2026-05-15
    Last Modified  : 2026-05-15
    Version        : 1.0
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-SO-000245

.TESTED ON
    Date(s) Tested : 2026-05-15
    Tested By      : Sid Taha
    Systems Tested : Windows 11
    PowerShell Ver.: 5.1+

.USAGE
    Run PowerShell as Administrator.
    Example syntax:
        PS C:\> .\WN11-SO-000245_Remediation.ps1
#>

# Remediate Windows 11 STIG: Enable UAC approval mode for the built-in Administrator account
# Registry equivalent:
# [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
# "FilterAdministratorToken"=dword:00000001

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ValueName    = "FilterAdministratorToken"
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
        Write-Host "`nSTIG remediation applied successfully: UAC approval mode for the built-in Administrator account is enabled."
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
