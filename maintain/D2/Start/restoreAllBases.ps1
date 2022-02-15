[CmdletBinding()]
param (
    [switch]$ar
)
Get-Job|Remove-Job
Set-Location .\scripts\

$AbacusRPath = $PSScriptRoot+"\scripts\abacus_restore_1.0.0.ps1"
$lyberoRPath=$PSScriptRoot+"\scripts\lybero_restore_1.0.0.ps1"
$fortsRPath=$PSScriptRoot+"\scripts\forts3_restore.ps1"

if($ar){
    Start-Job -name "ABACUS" -ScriptBlock  {param ($abacusRPath) powershell.exe -NoExit -command $abacusRPath}  -ArgumentList $abacusRPath, $ar
    Start-Job -name "LYBERO" -ScriptBlock  {param ($lyberoRPath) powershell.exe -NoExit -command $lyberoRPath} -ArgumentList $lyberoRPath, $ar
    Start-Job -name "FORTS" -ScriptBlock  { param ($fortsRPath) powershell.exe -NoExit -command $fortsRPath} -ArgumentList $fortsRPath, $ar
}
else
{
Start-Job -name "ABACUS" -ScriptBlock  {param ($abacusRPath) powershell.exe -NoExit -command $abacusRPath}  -ArgumentList $abacusRPath
Start-Job -name "LYBERO" -ScriptBlock  {param ($lyberoRPath) powershell.exe -NoExit -command $lyberoRPath} -ArgumentList $lyberoRPath
Start-Job -name "FORTS" -ScriptBlock  { param ($fortsRPath) powershell.exe -NoExit -command $fortsRPath} -ArgumentList $fortsRPath
}

while ($jobscount -ne 3)
{
   $jobscount=(get-job | where state  -Like "Completed").Count
   Write-Host "Состояние джобов" -ForegroundColor Yellow
   get-job
   start-sleep 60
    cls
   
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

get-job| Receive-Job
Get-Job|Remove-Job