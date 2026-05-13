 <#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author         : Josh Madakor
    LinkedIn       : linkedin.com/in/joshmadakor/
    GitHub         : github.com/joshmadakor1
    Date Created   : 2024-09-09
    Last Modified  : 2024-09-09
    Version        : 1.0
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-AU-000500

.TESTED ON
    Date(s) Tested : 2024-09-09
    Tested By      : Josh Madakor
    Systems Tested : Windows 10 Pro, Build 22H2
    PowerShell Ver.: 5.1.17763.6189

.USAGE
    Put any usage instructions here.
    Example syntax:
        PS C:\> .\__remediation_template(STIG-ID-WN10-AU-000500).ps1
#>

# YOUR CODE GOES HERE

# Remediate Windows STIG: Configure Application Event Log maximum size
# Registry equivalent:
# [HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application]
# "MaxSize"=dword:00032768

$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application'
$ValueName    = 'MaxSize'
$ValueType    = 'DWord'
$ValueData    = 0x00032768   # 206,696 bytes

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

Write-Host "STIG remediation applied: Application Event Log MaxSize set to $ValueData bytes." 
