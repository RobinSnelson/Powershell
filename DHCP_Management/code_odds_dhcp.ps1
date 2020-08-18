#Display All Scopes
Get-DhcpServerv4Scope -ComputerName dby-hq-dc-03p

#Fill Variable with scopes
$scopes = Get-DhcpServerv4Scope -ComputerName dby-hq-dc-03p
$scopes | export-csv c:\temp\Active_directory_DHCP_Scopes.csv -NoTypeInformation    #chnage path and name of csv if needed