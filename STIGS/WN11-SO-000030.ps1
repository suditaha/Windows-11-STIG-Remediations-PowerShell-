<#
.SYNOPSIS
    This PowerShell script remediates Windows 11 STIG WN11-SO-000030 by forcing audit policy subcategory settings to override legacy audit policy settings.

.DESCRIPTION
    Windows audit policy subcategory settings provide more granular control over auditing than legacy audit policy settings.
    DISA STIG WN11-SO-000030 requires Windows to force audit policy subcategory settings to override audit policy
    category settings. This is configured by enabling the SCENoApplyLegacyAuditPolicy registry value.

.NOTES
    Author         : Sid Taha
    LinkedIn       : linkedin.com/in/sudita
    GitHub         : github.com/suditaha
    Date Created   : 2026-05-15
    Last Modified  : 2026-05-15
    Version        : 1.0
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-SO-000030

.TESTED ON
    Date(s) Tested : 2026-05-15
    Tested By      : Sid Taha
    Systems Tested : Windows 11
    PowerShell Ver.: 5.1+

.USAGE
    Run PowerShell as Administrator.
    Example syntax:
        PS C:\> .\WN11-SO-000030_Remediation.ps1
#>

# Remediate Windows 11 STIG: Force audit policy subcategory settings to override legacy audit policy settings
# Registry equivalent:
# [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa]
# "SCENoApplyLegacyAuditPolicy"=dword:00000001

$RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$ValueName    = "SCENoApplyLegacyAuditPolicy"
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
        Write-Host "`nSTIG remediation applied successfully: Audit policy subcategory settings are forced to override legacy audit policy settings."
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
