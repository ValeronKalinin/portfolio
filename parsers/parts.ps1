#Чтение файла Виндового конвертера
$logpathwin = "C:\проекты\615_VS_70\part_615_4.csv" #"D:\EDB_converter\edbexport\win.csv"
[array]$win = @()
$i = 0
$linecounter = 0
$fileWin = [System.io.File]::Open($logpathwin, 'Open', 'Read', 'ReadWrite')
#$file = [System.io.File]::Open( $logpath, 'Open', 'Read', 'ReadWrite')
$streamreaderwin = New-Object System.IO.StreamReader($fileWin)

#Чтение файла Линуксового конвертера
$logpathlin = "C:\проекты\615_VS_70\part_70_subrisk.csv" #"D:\EDB_converter\edbexport\lin.csv"
[array]$lin = @()
$filelin = [System.io.File]::Open($logpathlin, 'Open', 'Read', 'ReadWrite')
#$file = [System.io.File]::Open( $logpath, 'Open', 'Read', 'ReadWrite')
$streamreaderlin = New-Object System.IO.StreamReader($filelin)
    
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
while (!( $StreamReaderwin.EndOfStream ) ) {
   # while ($i -lt 50 -and !( $StreamReaderlin.EndOfStream )) {
    

        $win = ($StreamReaderwin.ReadLine()).split(';')[2,3,4,7]#[2..15]
        #[array]$win += $linewin.split(';')[2..15]
        
        $lin = ($StreamReaderlin.ReadLine()).split(';')[2,3,4,7]#[2..15]
        #[array]$lin += $linelin.split(';')[2..15]
       # $i++
        $linecounter++

    #}
    if ((@(Compare-Object $lin $win).Length -eq 0) -eq $false) {
        #$linecounter
        if ($win[1] -eq $lin[1]){
            
            $csv_winstring=$null
            $csv_linstring=$null
            foreach ($item in $win)
            {
                $csv_winstring+=($item +';')

            }
            foreach ($item in $lin)
            {
                $csv_linstring+=($item +';')

            }

           $csv_winstring| Add-Content -Path "C:\Проекты\615_VS_70\part_diff4.csv" 
           $csv_linstring| Add-Content -Path "C:\Проекты\615_VS_70\part_diff4.csv" 
            
           
            
        }
        else {

            Write-host "Not EQ"
            $win[1] 
            $lin[1]
            break

        }
        
    }
    else {
        #$linecounter
        #[array]$win = @()
        #[array]$lin = @()
        $win =$null
        $lin =$null
       
        $i = 0
    }
      
}
    
      
$Timer.Stop()
write-host $Timer.Elapsed
    
   
    
      
    