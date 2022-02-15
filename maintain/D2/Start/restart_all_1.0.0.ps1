[CmdletBinding()]
param (
    [switch]$ar
)
Get-Job|Remove-Job
cd .\scripts\
Write-host "Останавливаем службы"
.\stop.ps1
Write-host "Удаляем логи и локальные базы"
.\deleteLogsBases.ps1 -loglevel 1 -delete 3 
Write-host "Стартуем джобы для восстановление баз"
#$coreSPath = $PSScriptRoot+"\scripts\core_fullrestart.ps1"
$AbacusRPath = $PSScriptRoot+"\scripts\abacus_restore_1.0.0.ps1"
$lyberoRPath=$PSScriptRoot+"\scripts\lybero_restore_1.0.0.ps1"
$fortsRPath=$PSScriptRoot+"\scripts\forts3_restore.ps1"
$coreSPath = $PSScriptRoot+"\scripts\core_fullrestart_1.0.0.ps1"

Start-Job -name "ABACUS" -ScriptBlock  {param ($AbacusRPath) powershell.exe -NoExit -command $AbacusRPath}  -ArgumentList $AbacusRPath
if ($ar){
Start-Job -name "LYBERO" -ScriptBlock  {param ($lyberoRPath) powershell.exe -NoExit -command $lyberoRPath} -ArgumentList $lyberoRPath,$ar
Start-Job -name "FORTS" -ScriptBlock  { param ($fortsRPath) powershell.exe -NoExit -command $fortsRPath} -ArgumentList $fortsRPath,$ar
}
else{
Start-Job -name "LYBERO" -ScriptBlock  {param ($lyberoRPath) powershell.exe -NoExit -command $lyberoRPath} -ArgumentList $lyberoRPath
Start-Job -name "FORTS" -ScriptBlock  { param ($fortsRPath) powershell.exe -NoExit -command $fortsRPath} -ArgumentList $fortsRPath
}
while ($jobscount -ne 3)
{
   $jobscount=(get-job | where state  -Like "Completed").Count
   start-sleep 60

   Write-Host "Состояние джобов" -ForegroundColor Yellow
   get-job

}

$jobres=get-job| Receive-Job 
if($jobres -match "Завершено с ошибкой"){
    
    $jobres

    Write-Host "Восстановление баз завершено с ошибкой" -ForegroundColor Red

    Get-Job|Remove-Job
    BREAK
}
Write-host "Результат восстановления" -ForegroundColor Green
$jobres   

Write-host "Запускаем ядро" -ForegroundColor Green
. $coreSPath
Write-host "Переводим время" -ForegroundColor Green
.\timeSync.ps1

Write-host "Стартуем полигон" -ForegroundColor Green
.\start.ps1 