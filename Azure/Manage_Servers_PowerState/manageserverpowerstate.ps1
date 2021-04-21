

#Code comes from a troeubleshooting article on AZure Microsoft Docs
$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint "<CertificateThumbprint>"
#Select the subscription you want to work with
Select-AzSubscription -SubscriptionName '<YourSubscriptionNameGoesHere>'

#Test and get outputs of the subscriptions you granted access.
$subscriptions = Get-AzSubscription
foreach($subscription in $subscriptions)
{
    Set-AzContext $subscription
    Write-Output $subscription.Name
}



$resoureGroups = Get-AzResourceGroup

foreach ($resoureGroup in $resoureGroups){

    $vms = Get-AzVM -ResourceGroupName $resoureGroup.ResourceGroupName

    if($vms.count -gt 0){
        
        if(((get-date).ToString('%H') -le 7) -and ((get-date).ToString('%H') -ge 20)){
            write-host "server should be turned off"
            foreach ($vm in $vms){
                Get-AzVM -Name $vm.Name | Stop-AzVM -Confirm:$false -Force
            }
            

        } else {
           foreach ($vm in $vms){
                Write-Output "server should be turned on"
                $powerstate = (Get-AzVM -Name $vm.Name -Status).PowerState
                    if ($powerstate -eq "VM deallocated"){
                        Get-AzVM -Name $vm.Name | Start-AzVM -Confirm:$false -Force
                    }
           }
        }
    }
}