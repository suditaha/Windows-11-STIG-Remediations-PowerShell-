<#
.SYNOPSIS
    This PowerShell script remediates Windows 11 STIG WN11-SO-000250 by configuring User Account Control (UAC)
    to prompt administrators for consent on the secure desktop.

.DESCRIPTION
    User Account Control helps prevent unauthorized changes to the operating system by requiring elevation approval
    for administrative actions. DISA STIG WN11-SO-000250 requires the behavior of the elevation prompt for
    administrators in Admin Approval Mode to be set to "Prompt for consent on the secure desktop."

.NOTES
    Author         : Sid Taha
    LinkedIn       : linkedin.com/in/sudita
    GitHub         : github.com/suditaha
    Date Created   : 2026-05-16
    Last Modified  : 2026-05-16
    Version        : 1.0
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-SO-000250

.TESTED ON
    Date(s) Tested : 2026-05-16
    Tested By      : Sid Taha
    Systems Tested : Windows 11
    PowerShell Ver.: 5.1+

.USAGE
    Run PowerShell as Administrator.
    Example syntax:
        PS C:\> .\WN11-SO-000250_Remediation.ps1
#>

# Remediate Windows 11 STIG: Configure UAC elevation prompt behavior for administrators
# Registry equivalent:
# [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
# "ConsentPromptBehaviorAdmin"=dword:00000002
#
# Value meanings:
# 0 = Elevate without prompting
# 1 = Prompt for credentials on secure desktop
# 2 = Prompt for consent on secure desktop (STIG compliant)
# 3 = Prompt for credentials
# 4 = Prompt for consent
# 5 = Prompt for consent for non-Windows binaries

$RegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$ValueName    = "ConsentPromptBehaviorAdmin"
$ValueType    = "DWord"
$ValueData    = 2

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
        Write-Host "`nSTIG remediation applied successfully: UAC administrator elevation prompts are configured for consent on the secure desktop."
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
