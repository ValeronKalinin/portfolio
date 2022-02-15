#Чтение файла Виндового конвертера
$logpathwin = "C:\проекты\615_VS_70\" #"D:\EDB_converter\edbexport\win.csv"
[array]$win = @()
$i = 0
$linecounter = 0
$fileWin = [System.io.File]::Open($logpathwin, 'Open', 'Read', 'ReadWrite')
#$file = [System.io.File]::Open( $logpath, 'Open', 'Read', 'ReadWrite')
$streamreaderwin = New-Object System.IO.StreamReader($fileWin)

#Чтение файла Линуксового конвертера
$logpathlin = "C:\проекты\615_VS_70\orders_70.csv" #"D:\EDB_converter\edbexport\lin.csv"
[array]$lin = @()
$filelin = [System.io.File]::Open($logpathlin, 'Open', 'Read', 'ReadWrite')
#$file = [System.io.File]::Open( $logpath, 'Open', 'Read', 'ReadWrite')
$streamreaderlin = New-Object System.IO.StreamReader($filelin)
    
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
while (!( $StreamReaderwin.EndOfStream ) ) {
    while ($i -lt 50 -and !( $StreamReaderlin.EndOfStream )) {
    

        $linewin = ($StreamReaderwin.ReadLine()).trim()
        [array]$win += $linewin
        
        $linelin = ($StreamReaderlin.ReadLine()).trim()
        [array]$lin += $linelin
        $i++
        $linecounter++

    }
    if ((@(Compare-Object $lin $win).Length -eq 0) -eq $false) {
        $linecounter
        Compare-Object $lin $win
       
        break
    }
    else {
        #$linecounter
        [array]$win = @()
        [array]$lin = @()
        $i = 0
    }
      
}
    
      
$Timer.Stop()
write-host $Timer.Elapsed
    
   
    
      
    