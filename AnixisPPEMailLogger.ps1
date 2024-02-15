<#
.SYNOPSIS
    To get verbose information for PPE Mail service.

.DESCRIPTION
    The PPE Mail service only logs how many emails were sent with no further details. 
    This script should be scheduled to run near 2AM as PPE Mail is hard-coded for this daily runtime.
    Customized script as PPE Mail is currently set up on ISERV01 server at Southside Bank.

.OUTPUTS
    Hard-coded log file directory:
    D:\Program Files (x86)\Password Policy Enforcer\Log

.EXAMPLE
    Schedule this script to run with no parameters at 1:30 AM daily.

.LINK
    onenote:///J:\IT\Infrastructure\Domain%20Engineering-Administration\Domain%20Engineering-Administration%20Knowledgebase\Domain%20Tools%20-%20Software.one#Password%20Policy%20Enforcer%20email%20notification&section-id={52981389-F552-4D96-8D49-5ADAEEC42F4D}&page-id={F883DC7A-D7A0-48ED-98C6-28DE8481F5C2}&end

.NOTES
    The service account used to run the scheduled task will need modify access to the log directory
        and also local administrator access to get service information.

	Author       : Nathan Anderson
	Version      : 20240215
	Version Info : 
        1.0 3/8/2023 from test emails to log file generator.
        20240215 New style guide. Added check of PPE Mailer service Log On Account. Should be AnxPwdSvc.
#>

# Constants
$logPath = "C:\Program Files (x86)\Password Policy Enforcer\Log"
$LogFile = "C:\Program Files (x86)\Password Policy Enforcer\Log\$(get-date -format yyyyMMdd_HHmmss)-PPEMail.log"

$maxDaystoKeep = 365
$ServiceAccount = "AnxPwdSvc@southside.local"

# Constants for email alert.
$SmtpServer = "smtp.southside.com"
$To = "helpdesk@southside.com"
$From = "iserv01@southside.com"


# Initialize Log file
"$(get-date -format yyyyMMdd_HHmmss)`tInitializing Log file..."|Out-File $LogFile


# Check service for proper Log On Account
$a = (Get-WmiObject Win32_Service -Filter "Name='ppemail'").StartName
"$(get-date -format yyyyMMdd_HHmmss)`tPPE Mailer Service Log On Account = $a"|Out-File -Append $LogFile

If ($a -ne $ServiceAccount) {
    "$(get-date -format yyyyMMdd_HHmmss)`tPPE Mailer Service Log On Account is not configured correctly. Sending email..."|Out-File -Append $LogFile
    $Subject = "Systems: Netwrix PPE Mailer service is misconfigured"
    $Body = "AnixisPPEMailLogger.ps1 has determined that the Log On As credentials are mis-configured.`nCurrent Log On account for PPEMail service is $a"
    Send-MailMessage -SmtpServer $SmtpServer -To $To -From $From -Subject $Subject -Body $Body
} Else {
    "$(get-date -format yyyyMMdd_HHmmss)`tPPE Mailer Service Log On Account is configured correctly.`n"|Out-File -Append $LogFile
}



# Run PPEMail in simulation mode.
"$(get-date -format yyyyMMdd_HHmmss)`tExecuting PPEMail in Simulation mode as $(whoami)`n"|Out-File -Append $LogFile
cmd /c "C:\Program Files (x86)\Password Policy Enforcer\PPEMail.exe"|Out-File -Append $LogFile


# Clean up older log files
"`n$(get-date -format yyyyMMdd_HHmmss)`tRemoving log files older than $maxDaystoKeep days."|Out-File -Append $LogFile
$itemsToDelete = dir $logPath -File *-PPEMail.log | Where LastWriteTime -lt ((get-date).AddDays(-$maxDaystoKeep)) 
ForEach ($item in $itemsToDelete)
{ 
    Remove-Item $item.FullName -Verbose
} 
"$(get-date -format yyyyMMdd_HHmmss)`tRemoved $($itemsToDelete.count) log files."|Out-File -Append $LogFile


