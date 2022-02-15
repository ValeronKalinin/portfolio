
#Запуск секундомера
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
#Хэштаблица для хранения  пар TRAN_ID - время
$table = @{ } 
#Храним обработанные данные по каждой секунде
$result = @{ }
#Усредненные данные по каждой секунде
$Data = @()
#переменная для хранения данных таймера
$seconds = $null
$seconds_now=$null
# Файл  лога который будем парсить
$Path_Core="C:\latency\CoreDispatcher_0.2020122111.log"
$Path_Flusher="C:\latency\Flusher_0_0.2020122111.log"
#Файл вывода куда будем писать обработанные данные
$Path_out="C:\latency\latencyDisp-Flush.csv"

# Тут будем хранить направление последней операции и последний TRAN_ID
$last_direction=$null
$last_TRAN_ID=$null

# Читаем оба файла логов  Диспатчер и Флашер
$reader_Core = [System.IO.File]::OpenText($Path_Core)
$reader_Flusher = [System.IO.File]::OpenText($Path_Flusher)
$readers=@()
# Добавляем 
$readers+=$reader_Flusher   
$readers+=$reader_Core

while (!($reader_Flusher.EndOfStream)) {
    
    # Для каждого из файлов читаем строку поочередно
    foreach($reader in $readers)
{
            #если файл кончился скипаем
            if(($reader.EndOfStream)){continue}
            #Читаем строку
            $line = $reader.ReadLine()
            

             # если секунда сменилась - пишем данные
             if ($seconds -ne $seconds_now -and $seconds -ne $null -and $result.Count -ne 0) {
                $t=$null
                $tempObj = @{}
                $summ = $null 
            
                # Максимальная задержка в МИКРОСЕКУНДАХ
                $max = 0 
                foreach ($v in $result.Values) {
                        
                    if ($max -lt $v) { $max = $v }
                    
                    $summ += $v
                } 
    
                foreach ($k in $result.keys) {
                        
                    if ($t -ne $null) { break}
                    $t=$k
                    
                } 
                # Количество
                $count = $result.Count 
                # Средняя задержка в МИКРОСЕКУНДАХ                      
                $average = [math]::Round(($summ / $count), 2)    
                
                # Считаем медиану
                [array]$Mediandata=$result.Values
                [Array]::Sort($Mediandata) 
                $MedianValue = $Mediandata[[math]::Round($count / 100 * 50)]
    
                # 99 процентиль
                $P99 = $null
                $P99 = $Mediandata[[math]::Round($count / 100 * 99)]
                    
                # Собираем строку отчет�
                $tempObj["Time"]=  $t #$time.split(".")[0]  #$line.split(";")[0].split(".")[0]
                $tempObj["Average"]=$average 
                $tempObj["Median"]=$MedianValue 
                $tempObj["P99"]=$P99
                $tempObj["Count"]=$count
                $tempObj["Max"]=$max
    
                $obj=New-Object -TypeName psobject -Property $tempObj
                # сохраняем строку отчета
                $Data += $obj 
                $result = @{}
    
                # Таймер для анализа скорости обработки 1 секунды лога
                $Timer3.Stop()
                write-host $Timer3.Elapsed $seconds $seconds_now $count $table.count  $line
                $Timer3 = [System.Diagnostics.Stopwatch]::StartNew()
                $Timer3.Start() 
    
            }



            if($reader_Core.BaseStream.Name -eq $reader.BaseStream.Name) 
        {
            
            #$direction =    $line.split(":")[2].Split(";")[-1]
            $time = $line.split(";")[0]
            #$TRAN_ID = ([regex]'0x([A-Fa-f0-9]){13}').Match($line).Value
            $TRAN_ID =$line.Split(",")[0].Split(":")[-1].trim()
        
            if($null -eq $TRAN_ID){$line=$null; break}
            $table[$TRAN_ID] = $time
            break
        }  

        

        if($reader_Flusher.BaseStream.Name -eq $reader.BaseStream.Name) 
        {
            
            $time=$line.split("|")[0]
            #$TRAN_ID=  ([regex]'0x([A-Fa-f0-9]){13}').Match($line).Value #
            $TRAN_ID= ($line.Split(",")[0].split(":")[-1]).Trim()
            $seconds_now = $time.split(".")[0].split(":")[2] 
            $direction= $line.Split("T")[0].split(";")[-1].Trim()
            #$direction=([regex]'->').Match($line).Value 

            if($TRAN_ID -eq $last_TRAN_ID  -or $null -eq $TRAN_ID -or $direction -ne "<-"){$line=$null; break}
            
            if (($tstart=$table[$TRAN_ID])) {    
                
                $tfinish = $time
                #  Считаем задержку
                $latency = [math]::Round([math]::Abs(  ([timespan]$tstart).TotalMilliseconds - ([timespan]$tfinish).TotalMilliseconds), 3) * 1000
                    
                # Пишем в таблицу задержку в конкретный момент времени (время OUTPUT)
                $result[$tstart] = $latency
                    
                # Раскоментировать для проверки глазами 
                #write-host $testID " " $table.($TRAN_ID.trim()) " "  $time 

                #Удаляю из Хештаблицы запись
                $table.Remove($TRAN_ID.trim())

                $last_TRAN_ID=$TRAN_ID
                $last_direction=$direction
                $seconds = $seconds_now
            }

            if ($seconds -ne $seconds_now -and $seconds -ne $null -and $result.Count -ne 0) {
                $t=$null
                $tempObj = @{}
                $summ = $null 
            
                # Максимальная задержка в МИКРОСЕКУНДАХ
                $max = 0 
                foreach ($v in $result.Values) {
                        
                    if ($max -lt $v) { $max = $v }
                    
                    $summ += $v
                } 
    
                foreach ($k in $result.keys) {
                        
                    if ($t -ne $null) { break}
                    $t=$k
                    
                } 
                # Количество
                $count = $result.Count 
                # Средняя задержка в МИКРОСЕКУНДАХ                      
                $average = [math]::Round(($summ / $count), 2)    
                
                # Считаем медиану
                [array]$Mediandata=$result.Values
                [Array]::Sort($Mediandata) 
                $MedianValue = $Mediandata[[math]::Round($count / 100 * 50)]
    
                # 99 процентиль
                $P99 = $null
                $P99 = $Mediandata[[math]::Round($count / 100 * 99)]
                    
                # Собираем строку отчет�
                $tempObj["Time"]=  $t #$time.split(".")[0]  #$line.split(";")[0].split(".")[0]
                $tempObj["Average"]=$average 
                $tempObj["Median"]=$MedianValue 
                $tempObj["P99"]=$P99
                $tempObj["Count"]=$count
                $tempObj["Max"]=$max
    
                $obj=New-Object -TypeName psobject -Property $tempObj
                # сохраняем строку отчета
                $Data += $obj 
                $result = @{}
    
                # Таймер для анализа скорости обработки 1 секунды лога
                $Timer3.Stop()
                write-host $Timer3.Elapsed $seconds $seconds_now $count $table.count  $line
                $Timer3 = [System.Diagnostics.Stopwatch]::StartNew()
                $Timer3.Start() 
    
            }

            
        }

 }
 
}

$Timer.Stop()
write-host $Timer.Elapsed

$Data | Export-Csv -Path $Path_out -Encoding UTF8 -NoTypeInformation  
#$Data|Out-File -FilePath "C:\latency\latency.txt" 




Read-Host