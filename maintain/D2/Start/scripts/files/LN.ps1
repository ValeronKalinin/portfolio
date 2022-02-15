
$CS_path= "C:\git\v2\scripts\config_service.ini"


$config=get-content -Path $CS_path
$new_config=$null

[int]$ln=(Select-String '\[config\]'  -path $CS_path| select LineNumber).LineNumber

$new_config +=  $config[0..($ln-2)]
#$first_part= $config[0..($ln-2)]| out-file  config_service_1.ini

$lifenums = $config[($ln-1)..$config.Length]

foreach ($line in $lifenums )
{
    $Lifenum=$null

    if($line|select-string  -pattern "="){

        $string_value=$line.split("=")[0]
        [int]$lifenum=$line.split("=")[1]

        $newline=$string_value+"="+($lifenum+1).ToString()
        #$newline|out-file .\config_service_1.ini -Append
        $new_config+= $newline
    }
    else{
        $new_config += $line
        #$line|out-file .\config_service_1.ini -Append
    }
}

$new_config| set-content -Path $CS_path
#remove-item .\config_service.ini
#rename-item -path .\config_service_1.ini -newname .\config_service.ini
 


