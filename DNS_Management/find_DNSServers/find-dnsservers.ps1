#Finds DNS Servers on the current network - User must have rights to log onto a DC

#Finds all domain controllers - ActiveDirectory module must be installed
if(!(Get-Module -name ActiveDirectory)){
    Write-Host "The Active Directory module is required for this script please install it on this computer or run the script on a computer with the AD module installed"
    Break
} else {
    $domainControllers = Get-ADDomainController
    $domain = Get-ADDomain
}

#goes through the list of domain controllers to look for DNS Servers
foreach($dc in $domainControllers){

    #Creates a cm-session to the DC
    $session = New-CimSession -ComputerName $dc.hostname

    #finds all networks that the DC is attached too
    $networks = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -filter 'IPEnabled=True' -CimSession $session

    #looks at each network to ascertain any dns servers are used
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

    if($DNSObject.PrimaryDNSServer -ne "Notset"){
        $dnsNSRecords = $null
        $dnsNSRecords = Get-DnsServerResourceRecord -ComputerName $DNSObject.PrimaryDNSServer -ZoneName $domain.DNSRoot -RRType Ns
    }

    $DNSServersObject= New-Object -TypeName PSObject

    $val = 0

    while($val -le ($dnsNSRecords.count - 1)){
        $DNSServersObject | Add-Member -MemberType NoteProperty -Name "DNSServer$val" -Value $dnsNSRecords[$val].recorddata.nameserver
        $val ++
    }

    Write-Host $dc.hostname
    Write-Host "---------------------"
    $DNSServersObject | Format-List
    Write-Host "---------------------"
    
    
}










