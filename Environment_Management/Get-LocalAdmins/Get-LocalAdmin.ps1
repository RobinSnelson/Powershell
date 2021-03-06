function get-localadmin { 
param ($strcomputer) 
 
$admins = Get-WmiObject win32_groupuser –computer $strcomputer  
$admins = $admins | Where-Object {$_.groupcomponent –like '*"Administrators"'} 
 
$admins | ForEach-Object { 
    $_.partcomponent –match “.+Domain\=(.+)\,Name\=(.+)$” > $null
    $matches[1].trim('"') + “\” + $matches[2].trim('"') 
    }
}

$operatingsystems = @('Windows 7 Professional','Windows 10 Pro','Windows XP Professional',$null)
$servers = get-adcomputer -Filter * -Properties * | Where-Object {$operatingsystems -notcontains $_.OperatingSystem} | Select-Object Name,OperatingSystem,IPV4address,Description | sort-object Name,OperatingSystem

forEach($server in $servers){
    if(test-connection -ComputerName $($server.Name) -quiet){
        Write-Output  $server.name
        $localAdmins = Get-localAdmin -strcomputer $server.Name

        if($localAdmins.count -gt 0){
            $localadmins
        } else {
            Write-Output "$($server.name) does not appear to have any administrators"
        }
    } else {
        Write-Output "$($server.name) is not responding on the network" 
    }
}
