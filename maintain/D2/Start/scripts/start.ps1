[CmdletBinding()]
param (
    $delete = $null,
    $loglevel = $null
)
. .\config.ps1
$servers = @{ }
$ips = $poligon.Keys
foreach ($ip in $ips) {
    $servers[$ip] = (Invoke-Command -ComputerName $ip -Credential $mycred -FilePath $scrdir -ArgumentList $ip  | select service) 
}  


foreach ($o in $order  ) {
    $server = $o
    Write-Host
    Write-Host -ForegroundColor Red"`n" $server  
                
    #  Конец синхронизации      
    foreach ($s in $servers["$o"].service) {

        if ($poligon[$server] -contains $s.name) {

            Write-Host "Запускаем сервис: " $s.name
                    $s.state = (Invoke-Command -ComputerName $server -Credential $mycred -ScriptBlock {
                            Start-Service -name $using:s.name
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
Write-Host "Ждем 120 секунд"
Start-Sleep 120
write-host ""
write-host "Проверяем состояние PreLS"

Import-Module Posh-SSH
$SSHUsername = 'spectra'
$SSHPassword = 'spectra'
$SSHpass = ConvertTo-SecureString -AsPlainText $SSHPassword -Force
$SSHmycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SSHUsername, $SSHpass
$SSHSession = New-SSHSession -ComputerName $coredisp.iP  -Credential $SSHmycred -AcceptKey -ConnectionTimeout 3600
$SSH = $SSHSession | New-SSHShellStream
$SSH.WriteLine( 'cat /app/log/CoreDispatcher/*.log| grep "PreLS(.).state ----> Ready"' )
Start-Sleep 3
$SSHdata=$null
$PreLS_start_check=$null
$SSHdata=$SSH.read()
if( $SSHdata -match "PreLS\(0\)" -and $SSHdata -match "PreLS\(1\)" -and $SSHdata -match "PreLS\(2\)" -and $SSHdata -match "PreLS\(3\)" )
{$PreLS_start_check=$true
}    

$SSHdata
if($PreLS_start_check -eq $true)
{
    $HS_counter=invoke-command -ComputerName $abacus.iP -Credential $mycred -ScriptBlock {


    $ska_msg=(get-childitem -Path "D:\log\ska\" -Recurse| where name -like "ska_msg*.log"| select -last 1).FullName
    foreach ($line in (get-content -Path $ska_msg -ReadCount 0) )
    {
        if ($line -match "HandshakePacket")
        {
            $HS_counter+=1
        }
    } 
    return $HS_counter
    
    
} 

write-host ""
write-host "Запускаем startup.sql"
$startupsql_path=$PSScriptRoot +"\sql\startup.sql"
$jobs_abacus=$PSScriptRoot +"\sql\start_jobs_abacus.sql"
$jobs_lybero=$PSScriptRoot +"\sql\start_jobs_lybero.sql"

if ($HS_counter%2 -eq 0)
    {
        Invoke-SqlCmd -ServerInstance $abacus.iP -Database 'master' -Username sa -Password 12345678 -InputFile $startupsql_path  -QueryTimeout 3600 -Verbose 4>&1
        #Invoke-SqlCmd -ServerInstance $abacus.iP -Database 'master' -Username sa -Password 12345678 -InputFile $jobs_abacus  -QueryTimeout 3600 -Verbose 4>&1
        #Invoke-SqlCmd -ServerInstance $lybero.iP -Database 'master' -Username sa -Password 12345678 -InputFile $jobs_lybero  -QueryTimeout 3600 -Verbose 4>&1
    }
    Start-Sleep 30
}

write-host ""
write-host "Проверяем состояние ядра"
$SSH.WriteLine( 'cat /app/log/CoreDispatcher/*.log| grep "Changing state: Stop -> Play"' )
Start-Sleep 3
$SSH.read()

$sshSession | Remove-SSHSession

start-sleep 300
invoke-command -ComputerName $abacus.iP -Credential $mycred -ScriptBlock {start-service -Name SQLSERVERAGENT}
invoke-command -ComputerName $lybero.iP -Credential $mycred -ScriptBlock {start-service -Name SQLSERVERAGENT}
Start-Sleep 120
invoke-command -ComputerName $abacus.iP -Credential $mycred -ScriptBlock {get-service -Name SQLSERVERAGENT}
invoke-command -ComputerName $lybero.iP -Credential $mycred -ScriptBlock {get-service -Name SQLSERVERAGENT}
write-host "Запускаем Джобы"

$jobs_abacus=$PSScriptRoot +"\sql\start_jobs_abacus.sql"
$jobs_lybero=$PSScriptRoot +"\sql\start_jobs_lybero.sql"

if ($HS_counter%2 -eq 0)
    {
        
        Invoke-SqlCmd -ServerInstance $abacus.iP -Database 'master' -Username sa -Password 12345678 -InputFile $jobs_abacus  -QueryTimeout 3600 -Verbose 4>&1
        Invoke-SqlCmd -ServerInstance $lybero.iP -Database 'master' -Username sa -Password 12345678 -InputFile $jobs_lybero  -QueryTimeout 3600 -Verbose 4>&1
    }
    Start-Sleep 30
