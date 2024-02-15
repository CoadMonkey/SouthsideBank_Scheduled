$Script_Title="AnixisPPEMailLogger"
$Script_Author="Nathan Anderson"
$Script_Version="1.0"
#
Write-host $Script_Title
Write-host Version $Script_Version
Write-host Created by $Script_Author
Write-host `r`n`r`n
<#-----------------------------------------------------------------------------
Syntax: 
	AnixisPPEMailLogger
        set in scheduled tasks

Purpose:
    To get verbose logging of emails that should be sent.

Version Info:
     1.0 3/8/2023 from test emails to log file generator.

-----------------------------------------------------------------------------#>
$logPath = "D:\Program Files (x86)\Password Policy Enforcer\Log"
$LogFile = "D:\Program Files (x86)\Password Policy Enforcer\Log\$(get-date -format yyyyMMdd_HHmmss)-PPEMail.log"
$maxDaystoKeep = 365

"$(get-date -format yyyyMMdd_HHmmss)`tExecuting in Simulation mode as $(whoami)`n"|Out-File -Append $LogFile
cmd /c "D:\Program Files (x86)\Password Policy Enforcer\PPEMail.exe"|Out-File -Append $LogFile

"`n$(get-date -format yyyyMMdd_HHmmss)`tRemoving log files older than $maxDaystoKeep days."|Out-File -Append $LogFile
$itemsToDelete = dir $logPath -File *-PPEMail.log | Where LastWriteTime -lt ((get-date).AddDays(-$maxDaystoKeep)) 
ForEach ($item in $itemsToDelete)
{ 
    Remove-Item $item.FullName -Verbose
} 
"`n$(get-date -format yyyyMMdd_HHmmss)`tRemoved $($itemsToDelete.count) log files."|Out-File -Append $LogFile
