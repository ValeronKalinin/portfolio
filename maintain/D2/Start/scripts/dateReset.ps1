        
        [CmdletBinding()]
        param (
            $coredispip
        )
        
        if(!($coredispip)){
            . .\config.ps1
            $coredispip=$coredisp.ip
        }
        
      write-host ""
      write-host "Переводим время на $datereset"
      Import-Module Posh-SSH
      $SSHUsername = 'spectra'
      $SSHPassword = 'spectra'
      $SSHpass = ConvertTo-SecureString -AsPlainText $SSHPassword -Force
      $SSHmycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SSHUsername, $SSHpass
      $SSHSession = New-SSHSession -ComputerName $coredispip -Credential $SSHmycred -AcceptKey -ConnectionTimeout 3600
      $SSH = $SSHSession | New-SSHShellStream
      $dateresetstring="/app/_dateReset_D2.sh " + "$datereset"
      $SSH.WriteLine( "$dateresetstring")
      $SSH.Expect("dateReset Finish")
      
      $sshSession | Remove-SSHSession

      foreach ($server in $poligon.keys){
        Write-Host "Переводим время: " $server
        #Invoke-Command -ComputerName $server -Credential  $mycred   -ScriptBlock { w32tm /resync; Get-date }        
        Invoke-Command -ComputerName $server -Credential  $mycred   -ScriptBlock { Start-Service  NTP;start-sleep 10;Restart-Service -Force NTP;start-sleep 10; Start-Service  NTP;Get-date   } 
        }
        Write-Host "Переводим время: " $root.ip
        #Invoke-Command -ComputerName $server -Credential  $mycred   -ScriptBlock { w32tm /resync; Get-date }        
        Invoke-Command -ComputerName $root.ip -Credential  $mycred   -ScriptBlock { Start-Service  NTP;start-sleep 10;Restart-Service -Force NTP;start-sleep 10; Start-Service  NTP;Get-date   } 