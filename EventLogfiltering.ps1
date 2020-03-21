#Newest
get-eventlog -LogName Security -Newest 10

#by Time
$after = get-date -date '02/07/2019 00:00:00'
Get-EventLog -LogName Security -After $after

$before = get-date -date '02/07/2019 00:00:00'
Get-EventLog -LogName Security -before $before

Get-EventLog -LogName Security -before (get-date).AddDays(-1) -after (get-date).AddDays(-2)

#Failed Audits
$exampleEvent = Get-EventLog -EntryType FailureAudit -LogName Security | Select-Object -first 1 -Property *
Get-EventLog -LogName System -UserName "*\robin"
Get-EventLog -LogName System -UserName "NT*"

#InstanceID
Get-EventLog -LogName System -InstanceId 1500

#Source
Get-EventLog -LogName System -Source 'disk'

#Advanced Message Parsing

$exampleEvent = Get-EventLog -EntryType FailureAudit -LogName Security | Select-Object -first 1 -Property *
$exampleEvent
($exampleEvent.Message | select-string -Pattern 'Account for Which Logon Failed:\r\n\s+Security ID:\s+(.*)' | Select-Object -ExpandProperty matches).groups[1].value
