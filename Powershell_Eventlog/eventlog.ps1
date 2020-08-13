#Region Speed Test
$time = Measure-Command {$results = Get-Eventlog -LogName Application -Newest 10000}
$time.TotalSeconds

$time = Measure-Command {$results = Get-Eventlog -LogName Application -ComputerName HeliosDC -Newest 10000}
$time.TotalSeconds