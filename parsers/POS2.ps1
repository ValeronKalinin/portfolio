#$list = (Get-ChildItem -File -Path C:\git\scripts\commons\linux_commons\POS).Name

#foreach ($l in $list) {
    $lpath=  "C:\Проекты\615_VS_70\pos.csv"    #"C:\git\scripts\commons\linux_commons\POS\"+ $l
    $wpath =  "C:\Проекты\615_VS_70\pos_70.csv"#"C:\git\scripts\commons\win_commons\POS\" + $l
$linux=import-csv -Path $lpath  -Delimiter ";"
$windows = import-csv -Path $wpath -Delimiter ";"

$linux = $linux| select -ExcludeProperty replID,replRev  -Property * |sort isin_id,client_code -CaseSensitive
$windows = $windows | select -ExcludeProperty replID,replRev,last_quantity -Property * |sort isin_id,client_code -CaseSensitive

$i=0

#write-host $i

if ($linux.Count -eq $windows.Count)
{
    #$i=0
    while ($i -lt $linux.Count)
    {   
        
        if ((Compare-Object -ReferenceObject  $linux[$i] -DifferenceObject $windows[$i] -Property replAct,client_code,isin_id,xpos,xbuys_qty,xsells_qty,xopen_qty,waprice,net_volume,net_volume_ruropt_type,last_deal_id,account_type -IncludeEqual).sideindicator -ne "==")
        {
            Write-Host "Не совпадает"
            $i
            $linux[$i]
            $windows[$i]

        }
        <#if ((Compare-Object -ReferenceObject  $linux[$i] -DifferenceObject $windows[$i] -Property  -IncludeEqual).sideindicator -ne "==")
        {
            Write-Host "Не совпадает"
            $i
            $linux[$i]
            $windows[$i]

        }#>
        #Compare-Object -ReferenceObject  $linux[$i] -DifferenceObject $windows[$i] -Property replAct,Code,Isin,XQuantity,XBuyQuantity,XSellQuantity,XOpenQuantity,WAPrice,NetVolumeSteps,VMClose,NetVolumeRur,OptType,LastDealID,AccountType 
        $i++
    }

}


else {

    write-host "Не совпадает количество строк" $linux.Count $windows.count

}
#}
$linux.Count
$i