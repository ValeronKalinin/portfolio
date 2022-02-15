
[CmdletBinding()]
param (
   
    $lybero_ip,
    $abacus_ip,
    [switch]$ar
)
$d2path=$PSScriptRoot+"\config.ps1"
. $d2path
if(!($abacus_ip)){
    $abacus_ip=$abacus.ip
}
if(!($lybero_ip)){
    $lybero_ip=$lybero.ip
}
            $result=@{}

            Import-Module sqlps 

            $bases ='msdb',
                    #'ABA_F_REPL',
                    'zSQLupdate',
                    'WEB',
                    'IR_REPL',
                    #'ASTS_CUR',
                    #'ASTS_EQU', 
                    #'ABA_O_REPL',
                    'BILLING',
                    #'CCINTER',
                    'CLEARING_CLR',
                    'CLEARING_CLR_AR',
                    #'CLEARING_CLR_AR',
                    'CLEARING_REPL'
                    
                    
                    if($ar)
                {$bases+="CLEARING_CLR_AR"}
                    Invoke-Command -ComputerName $lybero_ip -Credential $mycred -ScriptBlock {

                        restart-service "MSSQLSERVER" -Force
                     }
                    
                    Write-host ""
                    Write-host "Запускаем восстановление баз Либеро:" 
                    foreach($base in $bases){write-host $base}
                    

            foreach($base in $bases)
            {
                
                    $script=
                    "USE [master]
                    GO
                    EXECUTE [dbo].[SinglebaseRestore] '$bkp_path_lybero', $base
                    "
                    
                     $null=start-job -Name $base -ScriptBlock  { param ($script, $lybero_ip) Invoke-SqlCmd -ServerInstance $lybero_ip -Database 'master' -Username sa -Password 12345678 -Query "$script" -QueryTimeout 36000 -Verbose *>&1} -ArgumentList $script, $lybero_ip
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
            write-host "Результат восстановления Либеро:"
            $result 
            if ($result.Values -match "failed|abnormally") {

                Write-Host "Завершено с ошибкой"
                $stop_triger =$null
                $stop_triger = 1
                return $stop_triger 
                break
            
            }    
            Write-Host "продолжение скрипта"
            start-sleep 6
            
            
    
                Write-Host   ""     
            Write-Host "Запускаем restore_sb_settings.sql"
             start-sleep 60
            $restore_sb_settingsPath=$PSScriptRoot + "\sql\restore_sb_settings.sql"
            Invoke-SqlCmd -ServerInstance $lybero_ip -Database 'master' -Username sa -Password 12345678 -InputFile $restore_sb_settingsPath  -QueryTimeout 3600 -Verbose 4>&1 
      