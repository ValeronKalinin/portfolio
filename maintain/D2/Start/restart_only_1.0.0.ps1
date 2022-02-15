        
        [CmdletBinding()]
        param (
            $coredispip
        )
        
        if(!($coredispip)){
            $d2path=$PSScriptRoot+"\scripts\config.ps1"
            . $d2path
            $coredispip=$coredisp.ip
            $abacus_ip=$abacus.ip
            
        }

        $coreSPath = $PSScriptRoot+"\scripts\core_fullrestart_1.0.0.ps1"
        Get-Job|Remove-Job
        cd .\scripts\  

      Write-host "Останавливаем службы"
      .\stop.ps1
      Write-host "Удаляем логи и локальные базы"
      .\deleteLogsBases.ps1 -loglevel 1 -delete 3 

      Invoke-Command -ComputerName $abacus_ip -Credential $mycred -ScriptBlock {

        restart-service "MSSQLSERVER" -Force
        Start-Sleep 30
     }
     Start-Sleep 30
      Write-host "Запускаем ядро" -ForegroundColor Green
. $coreSPath
Write-host "Переводим время" -ForegroundColor Green
.\timeSync.ps1

Write-host "Стартуем полигон" -ForegroundColor Green
.\start.ps1 