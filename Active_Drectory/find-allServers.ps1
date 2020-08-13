function find-allServers {
    [CmdletBinding()]
    param (
        
    )

    #fill  the variable with all operating systems NOT required
    $operatingsystems = @('Windows 7 Professional','Windows 10 Pro','Windows XP Professional',$null)
    #get all the computer objects in active directory
    $servers = get-adcomputer -Filter * -Properties * | Where-Object {$operatingsystems -contains $_.OperatingSystem} | Select-Object Name,OperatingSystem,IPV4address,Description | sort-object Name,OperatingSystem
    #Export answers to a csv
    $servers | export-csv .\serversinactivedirectory.csv
    

}

