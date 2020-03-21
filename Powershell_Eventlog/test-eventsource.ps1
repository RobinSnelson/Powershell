function test-eventsource{
Param(
    [Parameter(mandatory=$true)]
    [string]$sourcename
    )
    [System.Diagnostics.EventLog]::SourceExists($sourcename)
}





$answer = test-eventsource -sourcename 'Powershell'

$answer
