$list = (Get-ChildItem -File -Path C:\git\scripts\commons\linux_commons\POS).Name| select -First 1

foreach ($l in $list) {
    $lpath= "C:\git\scripts\commons\linux_commons\POS\"+ $l
    $wpath =  "C:\git\scripts\commons\win_commons\POS\" + $l
$linux=import-csv -Path $lpath  -Delimiter ";"
$windows = import-csv -Path $wpath -Delimiter ";"

$linux = $linux| select -ExcludeProperty replID,replRev  -Property * #|sort code,isin -CaseSensitive
$windows = $windows | select -ExcludeProperty replID,replRev -Property * #|sort code,isin -CaseSensitive



write-host $l


if ($linux.Count -eq $windows.Count)
{
    Compare-Object -ReferenceObject  $linux -DifferenceObject $windows -Property replAct,Code,Isin,XQuantity,XBuyQuantity,XSellQuantity,XOpenQuantity,WAPrice,NetVolumeSteps,VMClose,NetVolumeRur,OptType,LastDealID,AccountType 


}


else {

    write-host "Не совпадает количество строк" $linux.Count $windows.count

}
}