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

            Write-Host "Останавливаем сервис: " $s.name
                    $s.state = (Invoke-Command -ComputerName $server -Credential $mycred -ScriptBlock {
                            Stop-Service -name $using:s.name -Force
                            $st = get-service -name $using:s.name
                            return $st.Status 
                        }).value
                    Start-Sleep 2      

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