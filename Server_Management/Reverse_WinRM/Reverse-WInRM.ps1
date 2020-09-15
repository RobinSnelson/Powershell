#stop the service
stop-service winrm

#Disable the service winrm
Set-Service -Name winrm -StartupType Disabled

#delete the listener created
winrm delete winrm/config/listener?Address=*+Transport=HTTP

#set reg key    
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy -Value 0

#confirm key value
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name LocalAccountTokenFilterPolicy