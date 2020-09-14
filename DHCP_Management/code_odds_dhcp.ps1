#Display All Scopes
Get-DhcpServerv4Scope -ComputerName 

#Fill Variable with scopes
$scopes = Get-DhcpServerv4Scope -ComputerName 
$scopes | export-csv c:\temp\Active_directory_DHCP_Scopes.csv -NoTypeInformation    #chnage path and name of csv if needed