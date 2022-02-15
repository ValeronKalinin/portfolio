. .\config.ps1
foreach ($server in $poligon.keys){
Write-Host "Переводим время: " $server
#Invoke-Command -ComputerName $server -Credential  $mycred   -ScriptBlock { w32tm /resync; Get-date }        
Invoke-Command -ComputerName $server -Credential  $mycred   -ScriptBlock { Start-Service  NTP;start-sleep 10;Restart-Service -Force NTP;start-sleep 10; Start-Service  NTP;Get-date     } 
}