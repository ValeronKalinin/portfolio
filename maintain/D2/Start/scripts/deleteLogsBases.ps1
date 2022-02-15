[CmdletBinding()]
param (
    $delete = $null,
    $loglevel = $null
)
. .\config.ps1
$servers = @{ }
$ips = $poligon.Keys
foreach ($ip in $ips) {
    $servers[$ip] = (Invoke-Command -ComputerName $ip -Credential $mycred -FilePath $scrdir -ArgumentList $ip | select service) 
}  

foreach ($o in $order  ) {
    $server = $o
    Write-Host
    Write-Host -ForegroundColor Red"`n" $server  
                
    #  Конец синхронизации      
   
    ####################################### Начало основного цикла скрипта ############################################
    foreach ($s in $servers["$o"].service) {

        if ($poligon[$server] -contains $s.name) {

            ########################################## Удаление логов и баз##########################################                           
                        
            if ($delete -eq 3 -and $s.state -eq "Running") {
                Write-Host "ОСтанавливаем сервис : " $s.name
                Invoke-Command -ComputerName $server -Credential $mycred -ScriptBlock {
                    Stop-Service -name $using:s.name -Force }
                Start-Sleep 5
            }
            #Удаление логов
            if ($delete -eq 0 -or ($delete -ge 2 -and $delete -le 3)) {
                if ($s.state -eq "Running" -and $delete -ne 3) {
                    Write-Host "Необходимо сначала остановить сервис"

                }
                else {
                                
                    Write-Host "Удаляем логи: " 
                            
                    foreach ($log in $s.logs) {
                        Invoke-Command -ComputerName $server -Credential $mycred -ScriptBlock {
                               
                            (get-childitem -Path "D:\Log\","L:\Log\" -Recurse | where name -like *.7z).FullName | foreach {Remove-Item -Path $_}
                            get-childitem -Path $using:log -File -Recurse  | remove-item  -Force
                        }
                    }
                }
            }
            # Удаление локальных баз
            if ($delete -eq 1 -or ($delete -ge 2 -and $delete -le 3)) {
                if ($s.state -eq "Running" -and $delete -ne 3) {
                    Write-Host "Необходимо сначала остановить сервис"

                }
                else {

                    Write-Host "Удаляем локальные базы: " 
                    foreach ($db in $s.DBs) {
                        Invoke-Command -ComputerName $server -Credential $mycred -ScriptBlock {

                            get-childitem -Path $using:db -File -Recurse  | remove-item -Force
                        }
                    }

                }
                            
            }

            ########################################### Отображение информации о полигоне ###################################

            if ($loglevel -ge 1 -or $loglevel -eq $null ) {
                Write-Host  $s.name "`t"  -NoNewline -ForegroundColor Yellow
                if ($s.state -eq "Running") { Write-Host $s.state -ForegroundColor Green }
                else { Write-Host $s.state -ForegroundColor Red }  
            }
            # Логи и базы            
            if ($loglevel -ge 2 -and $loglevel -lt 5) {
                if ($s.logs -ne $null)
                { ($s.logs | foreach { write-host $_.tostring() -ForegroundColor DarkGray }) } else { write-host "Нет логов" -ForegroundColor DarkGray }
                if ($s.DBs -ne $null)
                { ($s.DBs | foreach { if ($_ -ne $null) { write-host $_.tostring() } }) } else { write-host "Нет баз" -ForegroundColor DarkGray }
            }
            # Логи базы и роутеры
            if ($loglevel -eq 3 -and $loglevel -lt 5) { ($s.Routers | foreach { write-host $_.tostring() -ForegroundColo White }) }

            # Логи базы роутеры и конфиги
            if ($loglevel -eq 4) { ($s.Configs | foreach { write-host $_.tostring() -ForegroundColo DarkCyan }) } 
                        
        }

    }  
}