#Gets all forwarders from DNS Servers
$DNSServers = Get-DnsServer

foreach($dns in $DNSServers){
    Get-DnsServerForwarder -ComputerName $dns
}