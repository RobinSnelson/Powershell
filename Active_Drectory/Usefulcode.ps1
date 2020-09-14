$safemodepassword = read-host -Prompt "Enter Safe mode password" -AsSecureString

Install-ADDSDomainController -SkipPreChecks -DomainName "Test.local" -SafeModeAdministratorPassword $safemodepassword -InstallDns -Confirm:$false

Install-ADDSDomain -Credential (Get-Credential CORP\EnterpriseAdmin1) -NewDomainName child -ParentDomainName "corp.contoso.com" -InstallDNS -CreateDNSDelegation -DomainMode Win2003 -ReplicationSourceDC "DC1.corp.contoso.com" -SiteName "Houston" -DatabasePath "D:\NTDS" -SYSVOLPath "D:\SYSVOL" -LogPath "E:\Logs" -NoRebootOnCompletion

Install-ADDSDomain -ParentDomainName "Test.local" -SafeModeAdministratorPassword $safemodepassword -InstallDns -Confirm:$false


$safemodepassword = read-host -Prompt "Enter Safe mode password" -AsSecureString
Install-ADDSForest -DomainName "Test.local" -SafeModeAdministratorPassword $safemodepassword -InstallDns -Confirm:$false


