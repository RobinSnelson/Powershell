
#This script checks the servers in the named list for any service running where the user startname is the local administrator
#Need a list of servers to check
$servers = get-content ".\serverlist.txt"

Add-Content -path ".\Services.csv" -value '"ComputerName""Log On Name","Service Name"'
$file = ".\Services.csv"

foreach($server in $servers){
    $services = $null

    $services = Get-WmiObject win32_service -ComputerName $server | Format-Table Name,startname,startmode

    foreach($service in $services){
        if($service.startname -eq ".\Administrator"){

            $newline = "{0},{1},{2}" -f $server,$service.startname,$service.name
            $newline | add-content -Path $file

        }


    }


}

