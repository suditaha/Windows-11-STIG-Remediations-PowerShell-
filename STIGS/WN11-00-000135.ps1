<#
.SYNOPSIS
    This PowerShell script remediates Windows 11 STIG WN11-00-000135 by enabling Windows Defender Firewall for all profiles.

.DESCRIPTION
    Windows Defender Firewall helps protect the system by filtering inbound and outbound network traffic.
    DISA STIG WN11-00-000135 requires Windows Defender Firewall to be enabled for the Domain, Private,
    and Public profiles.

.NOTES
    Author         : Sid Taha
    LinkedIn       : linkedin.com/in/sudita
    GitHub         : github.com/suditaha
    Date Created   : 2026-05-15
    Last Modified  : 2026-05-15
    Version        : 1.0
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-00-000135

.TESTED ON
    Date(s) Tested : 2026-05-15
    Tested By      : Sid Taha
    Systems Tested : Windows 11
    PowerShell Ver.: 5.1+

.USAGE
    Run PowerShell as Administrator.
    Example syntax:
        PS C:\> .\WN11-00-000135_Remediation.ps1
#>

# Remediate Windows 11 STIG: Enable Windows Defender Firewall for all profiles

$Profiles = @("Domain", "Private", "Public")

try {
    Set-NetFirewallProfile -Profile $Profiles -Enabled True -ErrorAction Stop
    Write-Host "Windows Defender Firewall enabled for Domain, Private, and Public profiles."
}
catch {
    Write-Host "Failed to enable Windows Defender Firewall profiles."
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}

# Final verification
$Verification = Get-NetFirewallProfile -Profile $Profiles |
    Select-Object Name, Enabled

Write-Host "`nVerification Results:"
$Verification | Format-Table -AutoSize

$NonCompliantProfiles = $Verification | Where-Object { $_.Enabled -ne $true }

if ($NonCompliantProfiles.Count -eq 0) {
    Write-Host "`nSTIG remediation applied successfully: Windows Defender Firewall is enabled for all profiles."
}
else {
    Write-Host "`nSTIG remediation failed: One or more firewall profiles are not enabled."
    $NonCompliantProfiles | Format-Table -AutoSize
    exit 1
}
