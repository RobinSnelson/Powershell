$username = "Username"
$userPassword = "Password"

$secureUserPassword = ConvertTo-SecureString -String $userPassword -AsPlainText -Force

New-LocalUser -Name $username -Password $secureUserPassword -PasswordNeverExpires -Description "User for Ansible" -FullName "Ansible User"

Add-LocalGroupMember -Name "Administrators" -Member $username