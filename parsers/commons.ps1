
$list = (Get-ChildItem -File -Path C:\git\scripts\commons\linux_commons).Name

foreach ($l in $list) {
    $lpath= "C:\git\scripts\commons\linux_commons\"+ $l
    $wpath =  "C:\git\scripts\commons\win_commons\" + $l
$linux=import-csv -Path $lpath  -Delimiter ";"
$windows = import-csv -Path $wpath -Delimiter ";"

$linux = $linux| select -ExcludeProperty local_time,mod_time_ns,mod_time,replID,replRev,deal_time_ns -Property *| sort isin_id
$windows = $windows | select -ExcludeProperty local_time,mod_time_ns,mod_time,replID,replRev,deal_time_ns -Property *| sort isin_id

write-host $l

if ($linux.Count -eq $windows.Count)
{
    $i=0
    while ($i -lt $linux.Count)
    {
        Compare-Object -ReferenceObject  $linux[$i] -DifferenceObject $windows[$i] -Property replAct,sess_id,isin_id,opt_type,best_buy,xamount_buy,orders_buy_qty,xorders_buy_amount,best_sell,xamount_sell,orders_sell_qty,xorders_sell_amount,open_price ,close_price,price,trend,xamount,min_price, 
        max_price,avr_price,xcontr_count,capital,total_premium_volume,deal_count,settlement_price_open,xpos,market_price,price_assigned_by_admin,best_buy_native,xamount_buy_native,xorders_buy_amount_native,best_sell_native,
        xamount_sell_native,xorders_sell_amount_native

        $i++
    }

}


else {

    write-host "Не совпадает количество строк" $linux.Count $windows.count
}


#Compare-Object -ReferenceObject  $linux -DifferenceObject $windows -Property replAct,sess_id,isin_id,opt_type,best_buy,xamount_buy,orders_buy_qty,xorders_buy_amount,best_sell,xamount_sell,orders_sell_qty,xorders_sell_amount,open_price ,close_price,price,trend,xamount,min_price, 
#max_price,avr_price,xcontr_count,capital,total_premium_volume,deal_count,settlement_price_open,xpos,market_price,price_assigned_by_admin,best_buy_native,xamount_buy_native,xorders_buy_amount_native,best_sell_native,
#xamount_sell_native,xorders_sell_amount_native

}