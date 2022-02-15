
$65=@{}
$70=@{}
$header = 0..37
$65 =  Import-Csv "C:\проекты\615_VS_70\orders.csv" -Delimiter ";" -Header $header
$65=$65| sort "0"
$70= Import-Csv "C:\проекты\615_VS_70\orders_70.csv" -Delimiter ";" -Header $header
$70=$70| sort "0"
 
# Compare-Object $65 $70 -IncludeEqual


 $list= $65.Count
 $i=0
 while ($i -lt $list-1)
 {
 if ((Compare-Object $65[$i]  $70[$i] -Property "0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37" -IncludeEqual).sideindicator -ne "==")
 {
 $65[$i] }



$i++
 }


