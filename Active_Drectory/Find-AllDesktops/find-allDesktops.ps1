#set locatin to where the script is
Set-Location $PSScriptRoot

#fill  the variable with all operating systems required
$operatingsystems = @('Windows 7 Professional','Windows 10 Pro','Windows XP Professional',"Windows 10 Enterprise", $null)
#get all the computer objects in active directory
$servers = get-adcomputer -Filter * -Properties * | Where-Object {$operatingsystems -contains $_.OperatingSystem} | Select-Object Name,OperatingSystem,IPV4address,Description,lastlogondate | sort-object Name,OperatingSystem
#Export answers to a csv
$servers | export-csv .\desktopsinactivedirectory.csv
    


