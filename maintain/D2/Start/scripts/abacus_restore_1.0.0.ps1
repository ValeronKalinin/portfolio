
[CmdletBinding()]
param (
    $abacus_ip,
    [switch]$ar
)
$d2path=$PSScriptRoot+"\config.ps1"
. $d2path
if(!($abacus_ip)){
    $abacus_ip=$abacus.ip
}

            $result=@{}

            Import-Module sqlps -ErrorAction 4

            $bases ='msdb',                 
                    'WEB',
                    'FUTURES_HOPE',
                    'FUTURES_HOPE_Log',
                    'IR_COMBINED',
                    'IR_FUT',
                    'IR_OPT',
                    'OPTIONS_HOPE',
                    'OPTIONS_HOPE_Log',
                    'TestGO'
                    #'zSQLupdate'
                    
                if($ar)
                {$bases+="FUTURES_AR"
                $bases+="OPTIONS_AR"}
                    Invoke-Command -ComputerName $abacus_ip -Credential $mycred -ScriptBlock {

                        restart-service "MSSQLSERVER" -Force
                        Start-Sleep 30
                     }
                    
                    Write-host ""
                    Write-host "Запускаем восстановление баз :" 
                    foreach($base in $bases){write-host $base}
                    

            foreach($base in $bases)
            {
                
                    $script=
                    "USE [master]
                    GO
                    EXECUTE [dbo].[SinglebaseRestore] '$bkp_path_abacus', $base
                    "
                    
                     $null=start-job -Name $base -ScriptBlock  { param ($script, $abacus_ip) Invoke-SqlCmd -ServerInstance $abacus_ip -Database 'master' -Username sa -Password 12345678 -Query "$script" -QueryTimeout 36000 -Verbose *>&1 } -ArgumentList $script, $abacus_ip 
                    Start-Sleep 5
                    }
                    
                    $null=Get-Job|wait-job
                    $jobs=Get-Job
                    
                    foreach($job in $jobs){
                    $res=$null
                    $resBasename=$null
                    $resSucces=$null
                    
                    $res+=Receive-Job -name $job.Name -Keep
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
            write-host "Результат восстановления Абакуса:"
            $result 
            if ($result.Values -match "failed|abnormally") {

                Write-Host "Завершено с ошибкой"
                $stop_triger =$null
                $stop_triger = 1
                return $stop_triger 
                break
            
            }    
            Write-Host "продолжение скрипта"
            Start-Sleep 5  
            
            Write-Host   ""     
            Write-Host "Запускаем restore_sb_settings.sql"
            Invoke-Command -ComputerName $abacus_ip -Credential $mycred -ScriptBlock {
                
                restart-service "MSSQLSERVER" -Force
                remove-item -Path "L:\log\forts2\" -ErrorAction 4 -Force -Recurse 
             }
             start-sleep 60
            $restore_sb_settingsPath=$PSScriptRoot + "\sql\restore_sb_settings.sql" 
            Invoke-SqlCmd -ServerInstance $abacus_ip -Database 'master' -Username sa -Password 12345678 -InputFile $restore_sb_settingsPath  -QueryTimeout 3600 -Verbose 4>&1             


               