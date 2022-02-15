

param (
    $ip
)
#$servers=$null
$Username = 'administrator'
$Password = 'P@ss4delta'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force

$SecureString = $pass
# Users you password securly
$mycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString 
#$servers=@()
function getinfo {
    param (
        $ip,
        $cred,
        [array]$ch,
        [bool]$recurse = $false
    )
    $ProgressPreference = "SilentlyContinue"
    $Global:check += $ch
    #$Global:check=$Global:check| select -Unique
    $inis = @()
    $All_routers = @()
    
    # find services
    $p2_services = (Get-WmiObject win32_service |where {$_.Name -like "P2*" -or $_.Name -Like "MSSQLSERVER" -or $_.Name -Like "SQLSERVERAGENT"} | select name, pathname, state, status)
    

    $services = @()
    $Mainobj = New-Object -TypeName psobject
    Add-Member -InputObject $Mainobj -MemberType NoteProperty -Name "Name" -Value $ip
    
    foreach ($p2_service in $p2_services) {   
        $string=$null
        $string=(([regex]::Split($p2_service.pathname, "/ini:|-INI:")).split('"') | select-string -Pattern ";" -SimpleMatch -NotMatch | select-string -Pattern ".ini" -SimpleMatch).ToString()
        if($string -eq $null){$string="нет ini"}
        $obj = New-Object -TypeName psobject
        Add-Member -InputObject $obj -MemberType NoteProperty -Name "Name" -Value $p2_service.name
        Add-Member -InputObject $obj -MemberType NoteProperty -Name "String" -Value $string
        Add-Member -InputObject $obj -MemberType NoteProperty -Name "State" -Value $p2_service.state
        Add-Member -InputObject $obj -MemberType NoteProperty -Name "Status" -Value $p2_service.status
        $inis += $obj

    }

    foreach ($ini in $inis) {   
            
        [array]$routers = @()
        $remote_path = $ini.String
        $Logs = $null
        $dbs = $null
        [array]$inifiles = @()
        $inifiles += $remote_path

        $tempdisk_path = $remote_path.split('$')[0] + "$"


        #Находим роутеры
        if ($connections_file = Get-Content -Path $remote_path -ErrorAction 4 | Select-String -Pattern "connections_ini" -SimpleMatch ) {   

            $connections_file = $connections_file.tostring().split("=")[1] 
            #Write-host "connections_file "$connections_file
            $remote_path_connectionfiles = $connections_file 
            foreach ($router in Get-Content -Path $remote_path_connectionfiles | Select-String -Pattern "ROUTEINFO", ";" -NotMatch -SimpleMatch) {
                [array]$routers += ($router.tostring().split("=")[-1].trim()).trim()
                $All_routers += ($router.tostring().split("=")[-1].trim()).split(":")[0].Trim()
            }
                
        }

        else {
            foreach ($router in Get-Content -Path $remote_path -ErrorAction 4 | Select-String -Pattern ";" -NotMatch -SimpleMatch | Select-String -Pattern "direct", "default"  -SimpleMatch) {

                [array]$routers += ($router.tostring().split("=")[-1].trim()).trim()
                $All_routers += ($router.tostring().split("=")[-1].trim()).split(":")[0].Trim()
            }

        }
        # Кусок с обнаружением файлов логов
        $logs = Get-Content $remote_path -ErrorAction 4 | Select-String  -Pattern "currentdir" | 
        foreach { $_ -replace "currentdir=", "" } | select -Unique | foreach { get-childitem -Recurse $_ |
            ? name -like "*.ini" | foreach { [array]$inifiles += $_.FullName.ToLower(); (get-content -Path $_.fullname -ErrorAction 4| select-string -pattern "logfile=") -replace "logfile=", "" -replace "\.log", '.*log' } | select -Unique }
        
        
        if ($logs -eq $null) {
            $logs = (get-childitem (get-item -Path $remote_path -ErrorAction 4).DirectoryName).FullName | foreach { get-childitem -Recurse $_ |
                ? name -like "*.ini" | foreach { [array]$inifiles += $_.FullName.ToLower(); (get-content -Path $_.fullname -ErrorAction 4| select-string -pattern "logfile=") -replace "logfile=", "" -replace "\.log", '.*log' } | select -Unique }
        }
        $logpaths = @()
         
        foreach ($log in $logs) {
            if($log -ne $null -and (Test-Path -Path $log -ErrorAction 4)){
            $logpaths += ((get-item -Path $log -ErrorAction 4).DirectoryName).ToLower()
            }
        } 
        $logpaths+= "D:\log\forts2"
        $dbs = Get-Content $remote_path -ErrorAction 4 | Select-String -Pattern "currentdir" | 
        foreach { $_ -replace "currentdir=", "" } | select -Unique | foreach { get-childitem -Recurse $_ -ErrorAction 4|
            ? name -like "*.ini" | foreach { (get-content -Path $_.fullname -ErrorAction 4| select-string -pattern "\..?db$|\.db.?$|\\data\\" )  -replace "data_path=", "" -replace "data_path = ", "" -replace "/", "\\" } | select -Unique }
                 
        $dbs = $dbs | foreach { $_.tostring().split(";")[-1] | select-string -pattern "^\w:\\.*\..?db.?$|^\w:\\.*\.db.?$|\\data\\" }  
        
        if ($Dbs -eq $null) {
            $Dbs = (get-childitem (get-item -Path $remote_path -ErrorAction 4).DirectoryName).FullName | foreach { get-childitem -Recurse $_ -ErrorAction 4|
                ? name -like "*.ini" | foreach { (get-content -Path $_.fullname -ErrorAction 4| select-string -pattern "\..?db$|\.db.?$|\\data\\" )  -replace "data_path=", "" -replace "data_path = ", "" -replace "/", "\\" } | select -Unique }
        }
      $dbs
        $DbPaths = @()
        foreach ($file in (Get-ChildItem -file -Recurse -Path "D:\Data\","E:\EDB\" -ea 4).FullName){
            $dbs+=$file
            }
            
        foreach ($db in $Dbs) {
        if((get-item  -Path $db -ErrorAction 4).Exists)
           {
               if((get-item  -Path $db -ErrorAction 4).PSIsContainer -eq $false){
            $DbPaths += ((get-item -Path $db -ErrorAction 4).DirectoryName).ToLower()
        }
            
            if((get-item -Path $db -ErrorAction 4).Attributes -eq "Directory"){
            $DbPaths += ((get-item -Path $db -ErrorAction 4).fullName).ToLower()
            }
        }
        
        }
         
        if (Get-PSDrive -Name "target" -ErrorAction SilentlyContinue | out-null) {
            Remove-PSDrive target -ErrorAction SilentlyContinue
        }

        $serviceobj = New-Object -TypeName psobject
        Add-Member -InputObject $serviceobj -MemberType NoteProperty -Name "IP" -Value $ip
        Add-Member -InputObject $serviceobj -MemberType NoteProperty -Name "Name" -Value $ini.Name
        Add-Member -InputObject $serviceobj -MemberType NoteProperty -Name "State" -Value $ini.State
        Add-Member -InputObject $serviceobj -MemberType NoteProperty -Name "Configs" -Value ($inifiles | sort | select -Unique)        
        Add-Member -InputObject $serviceobj -MemberType NoteProperty -Name "Logs" -Value ($logpaths | select -Unique)
        Add-Member -InputObject $serviceobj -MemberType NoteProperty -Name "DBs" -Value ($DbPaths | select -Unique)
        Add-Member -InputObject $serviceobj -MemberType NoteProperty -Name "Routers" -Value $routers

        $services += $serviceobj

    }
    Add-Member -InputObject $Mainobj  -MemberType NoteProperty -Name "Service" -Value $services
    $Global:servers += $Mainobj

    $All_routers = $All_routers | select -Unique
    #Write-host ""
    return $Global:servers
}


getinfo -ip $ip