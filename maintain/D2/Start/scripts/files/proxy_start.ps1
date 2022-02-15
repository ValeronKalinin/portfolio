[CmdletBinding()]
        param (
            $proxy
        )
        
        if(!($proxy)){
            $d2path=$PSScriptRoot+"\d2.ps1"
            . $d2path
            $proxyip=$proxy.ip
        }
        
      write-host ""
      write-host "Запускаем Прокси $proxyip"
      Import-Module Posh-SSH
      $SSHUsername = 'spectra'
      $SSHPassword = 'spectra'
      $SSHpass = ConvertTo-SecureString -AsPlainText $SSHPassword -Force
      $SSHmycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SSHUsername, $SSHpass
      $SSHSession = New-SSHSession -ComputerName $proxyip -Credential $SSHmycred -AcceptKey -ConnectionTimeout 3600
      $SSH = $SSHSession | New-SSHShellStream
      $SSH.WriteLine( 'rm -f /app/log/Proxy/* & /app/start.sh &  ll /app/log/Proxy/p2*11.log' )
      Start-Sleep 5
      $SSH.WriteLine( 'll /app/log/Proxy/p2*11.log' )
      Start-Sleep 5
      $SSH.Read()
      $sshSession | Remove-SSHSession