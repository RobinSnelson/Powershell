$operatingsystems = @('Windows 7 Professional','Windows 10 Pro','Windows XP Professional',"Windows 10 Enterprise",$null)

$servers = get-adcomputer -Filter * -Properties * | Where-Object {$operatingsystems -notcontains $_.OperatingSystem} | Select-Object Name,OperatingSystem,IPV4address,Description | sort-object Name,OperatingSystem

$servers | export-csv .\servers.csv -NoTypeInformation