#This script will get provisioned,used Space and the number of alocated vCPU

$creds = Get-Credential -Message "Enter Credentials for the vCenter"

$vcsa67 = "vcsa67"

Connect-VIServer -Server $vcsa67 -Credential $creds

$vms = Get-Vm

foreach($vm in $vms){

    $spaceProvisioned  = $spaceProvisioned + $vm.ProvisionedSpaceGB

    $spaceUsed = $spaceUsed + $vm.UsedSpaceGB

    $usedCPU = $usedCPU + $vm.numcpu

}

$ProvisionedSpace = [math]::Round($spaceProvisioned,2)
$usedSpace = [math]::Round($spaceUsed,2)
$CPUUsed = [math]::Round($usedCPU,2)

write-output "Amount of Datastore space that is provisioned is $ProvisionedSpace"
write-output "The amount Datastore space actually used is $usedSpace"
write-output "Number of CPUs used is $CPUUsed"



Disconnect-VIServer -Server $vcsa67