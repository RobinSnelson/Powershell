#Find all DHCP Servers on environment
$dhcpServers = Get-DhcpServerInDC

#get scope reservations by dhcp server
foreach($dhcpServer in $dhcpServers) {

        #Fill Variable with all Scopes from a DHCP Server
        $scopes = Get-DhcpServerv4Scope -ComputerName $dhcpServer

        #Gets all Reservations for each of the scopes and adds them to a variable
        foreach($scope in $scopes){
        $reservations = $null
        $reservations = Get-DhcpServerv4Reservation -ScopeId $scope.ScopeId -ComputerName $dhcpServer
        $reservations | Out-File -FilePath "c:\Temp\DHCP_Reservations\$($scope.Name).txt"
        }


}