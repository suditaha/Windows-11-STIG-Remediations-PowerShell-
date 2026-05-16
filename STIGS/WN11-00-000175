<#
.SYNOPSIS
    This PowerShell script remediates Windows 11 STIG WN11-00-000175 by disabling the Secondary Logon service.

.DESCRIPTION
    The Secondary Logon service (seclogon) enables users and processes to start programs using alternate credentials
    via features such as "Run as different user." This can increase the risk of privilege escalation or unauthorized
    credential use. DISA STIG WN11-00-000175 requires this service to be disabled.

.NOTES
    Author         : Sid Taha
    LinkedIn       : linkedin.com/in/sudita
    GitHub         : github.com/suditaha
    Date Created   : 2026-05-15
    Last Modified  : 2026-05-15
    Version        : 1.1
    CVEs           : N/A
    Plugin IDs     : N/A
    STIG-ID        : WN11-00-000175

.TESTED ON
    Date(s) Tested : 2026-05-15
    Tested By      : Sid Taha
    Systems Tested : Windows 11
    PowerShell Ver.: 5.1+

.USAGE
    Run PowerShell as Administrator.
    Example syntax:
        PS C:\> .\WN11-00-000175_Remediation.ps1
#>

# Remediate Windows 11 STIG: Disable Secondary Logon service

$ServiceName = "seclogon"

# Verify service exists
$Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($null -eq $Service) {
    Write-Host "Service '$ServiceName' not found. Exiting."
    exit 1
}

# Disable service startup first so it will not restart after reboot
try {
    Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction Stop
    Write-Host "Startup type set to Disabled for service: $ServiceName"
}
catch {
    Write-Host "Failed to set startup type for service '$ServiceName'."
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}

# Refresh service status
$Service = Get-Service -Name $ServiceName

# Stop the service if currently running
if ($Service.Status -eq "Running") {
    try {
        Stop-Service -Name $ServiceName -Force -ErrorAction Stop

        # Wait up to 30 seconds for the service to stop
        $Service.WaitForStatus("Stopped", "00:00:30")

        Write-Host "Stopped service: $ServiceName"
    }
    catch {
        Write-Host "Warning: Startup type was disabled, but the service could not be stopped immediately."
        Write-Host "Error: $($_.Exception.Message)"
        Write-Host "A reboot may be required for the service to fully stop."
    }
}
else {
    Write-Host "Service '$ServiceName' is already stopped."
}

# Final verification
$Verification = Get-Service -Name $ServiceName

Write-Host "`nVerification Results:"
Write-Host "Service Name : $($Verification.Name)"
Write-Host "Status       : $($Verification.Status)"
Write-Host "Startup Type : $($Verification.StartType)"

if ($Verification.StartType -eq "Disabled" -and $Verification.Status -eq "Stopped") {
    Write-Host "`nSTIG remediation applied successfully: $ServiceName is stopped and disabled."
}
elseif ($Verification.StartType -eq "Disabled" -and $Verification.Status -ne "Stopped") {
    Write-Host "`nPartial remediation applied: $ServiceName is disabled but still running."
    Write-Host "Restart the system, then verify again with:"
    Write-Host "Get-Service seclogon | Select-Object Name, Status, StartType"
}
else {
    Write-Host "`nSTIG remediation failed: $ServiceName is not fully compliant."
    exit 1
}
