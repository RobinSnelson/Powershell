#finds all vmware modules on the computer and removes them
$AZmodules = Get-Module -Name AZ.* -ListAvailable

foreach($azmodule in $azmodules){
    uninstall-module -name $azmodule.Name -force -Confirm:$false
}

$azureRMmodules = Get-Module -Name AZureRM.* -ListAvailable

foreach($azurermmodule in $azurermmodules){
    uninstall-module -name $azurermmodule.Name -force -Confirm:$false
}