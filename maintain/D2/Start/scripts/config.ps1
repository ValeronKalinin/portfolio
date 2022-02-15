#   Описание узлов полигона или любых необходимых серверов
#COREDISP
$coredisp=  [PSCustomObject]@{  role = "coredisp"
                                iP="10.50.130.50"
                                services=("arbitrator", "Logger", "CoreDispatcher", "Equalizer", "P2_PostLS")}
#PROXY
$proxy=  [PSCustomObject]@{     role = "proxy"
                                iP="10.50.130.6"
                                services=("proxy", "coresnap")}                                
#ROOT
$root=      [PSCustomObject]@{  role = "root" 
                                iP="10.50.130.237"
                                services=("P2_P2Logins", "P2_TSRIGHTS", "P2ASNS")}
#ABACUS
$abacus=    [PSCustomObject]@{  role = "abacus"
                                iP = "10.50.130.147"
                                services=("P2_FO2SRV_SKA", "P2_replicators_abacus","P2_Terminators_abacus_derivativesmarketbackoffice", "P2_terminators_abacus", "MSSQLSERVER"<#, "SQLSERVERAGENT"#>)}
#CORESNAP
$coresnap=  [PSCustomObject]@{  role = "coresnap"
                                iP = "10.50.186.40"
                                services="P2INTER_FO2GO"}
#COMMON
$common=    [PSCustomObject]@{  role = "common"
                                iP = "10.50.186.38"
                                services=("P2_p2mainsvc", "P2_p2converter")}
#P2SF
$p2sf=      [PSCustomObject]@{  role = "p2sf"
                                iP = "10.50.186.34"
                                services=("P2_p2subfeeder", "P2_p2subfeeder_aux")}
#LYBERO
$lybero=    [PSCustomObject]@{  role = "lybero"
                                iP = "10.50.130.207"
                                services=("P2_terminators_lybero_derivativesmarketbackoffice", "P2_Replicators_lybero_DerivativesMarketBackoffice_base", "P2_Billing_cl","MSSQLSERVER"<#,"SQLSERVERAGENT"#>)}
#FORTS3
$forts3=    [PSCustomObject]@{  role = "forts3"
                                iP = "10.50.186.36"
                                services=("P2_Terminators_forts3", "MSSQLSERVER","SQLSERVERAGENT")}

#   Описание самого полигона, узлов над которыми будут производиться манипуляции
$poligon = @{}
$poligon.add($abacus.ip,$abacus.services)
$poligon.add($coresnap.iP, $coresnap.services)
$poligon.add($common.iP, $common.services)
$poligon.add($p2sf.iP, $p2sf.services)
$poligon.add($lybero.ip, $lybero.services)
$poligon.add($forts3.ip, $forts3.services)

#   строка описывает порядок серверов, для старта сервисов внужном порядке
$order = $abacus.iP , $common.iP, $p2sf.iP, $lybero.iP, $forts3.iP #, $coresnap.iP,

#Дата и время на полигоне
$datereset='"2021-12-27 16:40:00"'
#данные для курсов
#$day="2020-12-21 10:00:00.000"
#$nextday="2020-12-22 10:00:00.000"

#   Путь откуда восстанавливать бекапы
$bkp_path_forts3="D:\bak\2709\"
$bkp_path_lybero="E:\bak\2712\"
$bkp_path_abacus="D:\bak\2712\"

#   путь до get_P2info_fnct.ps1
$scrdir = $PSScriptRoot + '\get_P2info_fnct.ps1'
#   Задаем креды для большинства серверов
$Username = 'administrator'
$Password = 'P@ss4delta'
$pass = ConvertTo-SecureString -AsPlainText $Password -Force
$SecureString = $pass
$mycred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecureString 

#   SQL пароль SA
$Usernamesql = 'sa'
$Passwordsql = '12345678'
$passsql = ConvertTo-SecureString -AsPlainText $Passwordsql -Force
$mysqlcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Usernamesql, $passsql

$ErrorActionPreference="SilentlyContinue"