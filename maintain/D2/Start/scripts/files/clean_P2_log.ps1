if (get-item "C:\Program Files\7-Zip\7z.exe")
{$7zipPath = "C:\Program Files\7-Zip\7z.exe"}

if (get-item "C:\7-Zip\7z.exe")
{$7zipPath = "C:\7-Zip\7z.exe"}

#$7zipPath = "C:\7-Zip\7z.exe"
set-Alias 7zip $7zipPath


$date = get-date -Format yyyyMMdd
$now=get-date  -format "yyyyMMddHH"


$Log_dirs = (get-childitem -Path "D:\Log\","L:\Log\" -Recurse | where mode -like d*).FullName

foreach($log_dir in $Log_dirs){

$path= $log_dir+"\"+$date
$path_7z = $path + ".7z"

$logs=(Get-ChildItem -Path $log_dir -Exclude *.7z| where {($_.Name -NotLike "*$now*" ) -and ($_.Mode -ne "d-----") }).FullName

New-Item -ItemType Directory -Path $path
move-item  $logs -Destination $path

7zip a -mx=1 -sdel -bsp1  $path_7z $path 
}