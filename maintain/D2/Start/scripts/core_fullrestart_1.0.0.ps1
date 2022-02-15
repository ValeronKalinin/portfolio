        
        [CmdletBinding()]
        param (
            $coredispip
        )
        
        if(!($coredispip)){
            $d2path=$PSScriptRoot+"\config.ps1"
            . $d2path
            $coredispip=$coredisp.ip
        }
      # Меняем Lifenum
      Write-Host "Изменяем lifenum: " 
      Invoke-Command -ComputerName $root.iP -Credential  $mycred   -ScriptBlock {  <#
      
      $CS_path="C:\ReplP2\P2TSRights\P2Config\config_service.ini"
      $config=get-content -Path $CS_path
      foreach ($line in $config){
      if($line|select-string  -pattern "^\*="){
      $Lifenum=($line|select-string  -pattern "^\*=") -replace "\*=", ""        
      $newLifenum=[int]$lifenum+1
      $LNtostring = '\*='+$Lifenum
      $newLNtostring='*='+$newLifenum}
      }
      (Get-Content $CS_path) -creplace "$lntostring","$newLNtostring"| set-content -Path $CS_path
      Restart-Service "P2_TSRIGHTS" -force
      Restart-Service "P2ASNS" -force
      return $newLifenum#>
      C:\ReplP2\P2TSrights\P2Config\LN.ps1
      Restart-Service "P2_TSRIGHTS" -force
      Restart-Service "P2ASNS" -force
     
      
      }   
      write-host ""
      write-host "Запускаем ядро"
      Import-Module Posh-SSH
      $SSHUsername = 'spectra'
      $SSHPassword = 'spectra'
      $SSHpass = ConvertTo-SecureString -AsPlainText $SSHPassword -Force
      $SSHmycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SSHUsername, $SSHpass
      $SSHSession = New-SSHSession -ComputerName $coredispip -Credential $SSHmycred -AcceptKey -ConnectionTimeout 3600
      
      $SSH = $SSHSession | New-SSHShellStream
      $dateresetstring="/app/_dateReset_D2.sh " + "$datereset"
      
      write-host "Перевод времени"
      $SSH.WriteLine( "$dateresetstring" )
      $SSH.Expect("dateReset Finish")
      #write-host "Восстановление баз Абакуса"
      #$D2_abacus_restore_path=$PSScriptRoot+"\D2_abacus_restore_1.0.0.ps1"
      #. $D2_abacus_restore_path
      
      write-host "Запуск сервисов ядра"
      $SSH.WriteLine( "/app/_restart_all.sh")
      $SSH.Expect("+ echo FINISH")
      $sshSession | Remove-SSHSession