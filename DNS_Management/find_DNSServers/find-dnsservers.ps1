$domainControllers = Get-ADDomainController
$domain = Get-ADDomain

foreach($dc in $domainControllers){

    $session = New-CimSession -ComputerName $dc.hostname

    $networks = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -filter 'IPEnabled=True' -CimSession $session

    foreach ($network in $networks){

        $dnsServers = $network.DNSServerSearchOrder
        $networkName = $network.description

        if(!$dnsServers){
            $PrimaryDNSServer = "Notset"
            $SecondaryDNSServer = "Notset"
        } elseif($DNSServers.count -eq 1) {
            $PrimaryDNSServer = $DNSServers[0]
            $SecondaryDNSServer = "Notset"
        } else {
            $PrimaryDNSServer = $DNSServers[0]
            $SecondaryDNSServer = $DNSServers[1]
        }
    }

    $DNSObject = New-Object -Type PSObject
    $DNSObject | Add-Member -MemberType NoteProperty -Name ComputerName -Value ($dc.HostName).ToUpper()
    $DNSObject | Add-Member -MemberType NoteProperty -Name PrimaryDNSServer -Value $PrimaryDNSServer
    $DNSObject | Add-Member -MemberType NoteProperty -Name SecondaryDNSServer -Value $SecondaryDNSServer
    $DNSObject | Add-Member -MemberType NoteProperty -Name IsDHCPEnabled -Value $IsDHCPEnabled
    $DNSObject | Add-Member -MemberType NoteProperty -Name NetworkName -Value $NetworkName
    #$DNSObject

    if($DNSObject.PrimaryDNSServer -ne "Notset"){
        $dnsNSRecords = $null
        $dnsNSRecords = Get-DnsServerResourceRecord -ComputerName $DNSObject.PrimaryDNSServer -ZoneName $domain.DNSRoot -RRType Ns
       # $dnsNSRecords
    }

    $DNSServersObject= New-Object -TypeName PSObject

    $val = 0

    while($val -le ($dnsNSRecords.count - 1)){
        $DNSServersObject | Add-Member -MemberType NoteProperty -Name "DNSServer$val" -Value $dnsNSRecords[$val].recorddata.nameserver
        $val ++
    }


    $DNSServersObject | Format-List
    
    
}










