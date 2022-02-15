Invoke-WebRequest -Uri "ftp://10.50.130.110/TEMP/clean_P2_log.ps1" -OutFile "c:\utils\clean_P2_log.ps1"


$Action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument '-NonInteractive -NoLogo -NoProfile -File "c:\utils\clean_P2_log.ps1"'
$Trigger = New-ScheduledTaskTrigger -Daily -At 3am
$Settings = New-ScheduledTaskSettingsSet
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings
Register-ScheduledTask -TaskName 'clean_P2_log' -InputObject $Task -User 'Administrator' -Password 'P@ss4delta'