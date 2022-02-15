
[CmdletBinding()]
param (
   
    $forts3_ip
)
#Импорт скрипта с описанием полигона
$d2path=$PSScriptRoot+"\config.ps1"
. $d2path
if(!($forts3_ip)){
    $forts3_ip=$forts3.ip
}
            $result=@{}
        
            Import-Module sqlps -ErrorAction 4
            #Список баз
            $bases =    'ASTRA',                                                                                       
                        'FUTURES',                                                                                     
                        'FUTURES_MOSCOW_Log',                                                                          
                        'IR_REPL',                                                                                     
                        'IR_TERM',                                                                                                                                                                                                                                                                                                                                                   
                        'MM',                                                                                                                                                                                                                                                                    
                        'OPTIONS',                                                                                     
                        'OPTIONS_MOSCOW_Log',                                                                          
                        'TestGO',                                                                                      
                        'WEB',                                                                                         
                        'zSQLupdate',
                        'msdb' 
                    
                    Invoke-Command -ComputerName $forts3_ip -Credential $mycred -ScriptBlock {
                    restart-service "MSSQLSERVER" -Force
                     }
                    
                    Write-host ""
                    Write-host "Запускаем восстановление баз :" 
                    foreach($base in $bases){write-host $base}
                    
            #Создаем отдельный джоб для восстановления каждой базы
            foreach($base in $bases)
            {
                
                    $script=
                    "USE [master]
                    GO
                    EXECUTE [dbo].[SinglebaseRestore] '$bkp_path_forts3', $base
                    "
                  
                    $null=start-job -Name $base -ScriptBlock  { param ($script, $forts3_ip) Invoke-SqlCmd -ServerInstance $forts3_ip -Database 'master' -Username sa -Password 12345678 -Query "$script" -QueryTimeout 36000 -Verbose *>&1 } -ArgumentList $script, $forts3_ip
                    Start-Sleep 5
                    }
                    Get-Job
                    $null=Get-Job|wait-job
                    $jobs=Get-Job
                    
                    foreach($job in $jobs){
                    $res=$null
                    $resBasename=$null
                    $resSucces=$null
                    
                    $res+=Receive-Job -name $job.Name -Keep
                    $res
                    $resBasename= ($res| select-string -Pattern "Starting to restore database:").ToString().split(":")[-1]
                    
                    if ($res| select-string -Pattern "RESTORE DATABASE successfully"){

                        $result_String=   $res| select-string -Pattern "RESTORE DATABASE successfully"
                    }

                    if (!($res| select-string -Pattern "RESTORE DATABASE successfully")){
                        $result_String=   $res
                    }
                   
                    
                    $result[$resBasename]=$result_String
                    
                    }
                
           
            $null=Get-Job|Remove-Job
            Write-Host   ""
            write-host "Результат восстановления:"
            $result|ft 
            Start-Sleep 5  
 