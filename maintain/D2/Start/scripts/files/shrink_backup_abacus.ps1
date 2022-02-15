Import-Module sqlps -ErrorAction 4
$Username = 'administrator'
$Password = 'P@ss4delta'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$SecureString = $pass
$mycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString 
$result=@{}

            $basesE ='FUTURES_HOPE',
            'FUTURES_HOPE_Log',
            'IR_COMBINED',
            'IR_FUT',
            'IR_OPT',
            'OPTIONS_HOPE',
            'OPTIONS_HOPE_Log',
            'TestGO',
            'WEB',
            'zSQLupdate',
                        'msdb'
            
          
                    

                    Invoke-Command -ComputerName "10.50.130.147" -Credential $mycred -ScriptBlock {

                        restart-service "MSSQLSERVER" -Force
                     }

                    Write-host "Запускаем бекап баз :" 
              
                    foreach($baseE in $basesE){write-host $baseE}
                    

            
           
          
            foreach($baseE in $basesE)
            {
                
                    $script="
                    USE [master] ;  
                     ALTER DATABASE $baseE SET RECOVERY SIMPLE ;
                     
                     USE [$baseE] ;
                     declare @namelog varchar(40)
                     set @namelog =
                    (SELECT name FROM sys.database_files
                    where type_desc like 'LOG')
                    print @namelog                   
                    DBCC SHRINKFILE (@namelog , 0, TRUNCATEONLY)



                    BACKUP DATABASE [$baseE] TO  DISK = N'D:\bak\1611_shrink\$baseE.bak' 
                    WITH NOFORMAT, NOINIT,  NAME = N'$baseE-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,COMPRESSION,  STATS = 10
                    GO"
                    
                     start-job -Name $baseE -ScriptBlock  { param ($script) Invoke-SqlCmd -ServerInstance "10.50.130.147" -Database 'master' -Username sa -Password 12345678 -Query "$script" -QueryTimeout 36000 -Verbose 4>&1} -ArgumentList $script
            
            }
         
            
                    $null=Get-Job|wait-job
                    $jobs=Get-Job
                    
                    foreach($job in $jobs){
                    $res=$null
                    $resBasename=$null
                    $resSucces=$null
                    
                    $res=Receive-Job -name $job.Name -Keep
                    $resBasename= $job.Name.ToString() #($res| select-string -Pattern "Starting to restore database:").ToString().split(":")[-1]
                    $resSucces=   $res| select-string -Pattern "BACKUP DATABASE successfully"
                    if($resSucces -eq $null){ $resSucces = "FAILED"}
                    
                    $result[$resBasename]=$resSucces
                    }
                
                
            
            #$null=Get-Job|Remove-Job
            write-host "Результат бекапа:"
            $result|ft 

            Get-Job|Remove-Job