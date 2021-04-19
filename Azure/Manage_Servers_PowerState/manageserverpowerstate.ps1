$resoureGroups = Get-AzResourceGroup

foreach ($resoureGroup in $resoureGroups){

    $vms = Get-AzVM -ResourceGroupName $resoureGroup.ResourceGroupName

    if($vms.count -gt 0){
        
        if(((get-date).ToString('%H') -le 7) -and ((get-date).ToString('%H') -ge 20)){
            write-host "server should be turned off"
            foreach ($vm in $vms){
                Get-AzVM -Name $vm.Name | Stop-AzVM
            }
            

        } else {
            write-host "server should be turned on"
        }
    }

}