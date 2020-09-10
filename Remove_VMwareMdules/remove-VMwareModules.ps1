#finds all vmware modules on the computer and removes them
$modules = Get-Module -Name VMware.* -ListAvailable

foreach($module in $modules){
    uninstall-module -name $module.Name -force -Confirm:$false
}