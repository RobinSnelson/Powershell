#Collects the total usage stats intotals for all Space Used, CPU's used and RAM usage 
$vcenterName = Read-Host -Prompt "enter the name of the vCenter"
$creds = get-credential -Message "Enter credentials to connect to vcenter"
Connect-VIServer -Server $vcenterName -Credential $creds

$vms = Get-Vm

foreach($vm in $vms){

    $spaceProvisioned  = $spaceProvisioned + $vm.ProvisionedSpaceGB

    $spaceUsed = $spaceUsed + $vm.UsedSpaceGB

    $usedCPU = $usedCPU + $vm.numcpu

    $memoryProvisioned = $memoryProvisioned + $vm.memoryGb

}

$ProvisionedSpace = [math]::Round($spaceProvisioned,2)
$usedSpace = [math]::Round($spaceUsed,2)
$CPUUsed = [math]::Round($usedCPU,2)
$Provisionedmemory = [math]::Round($memoryProvisioned,2)

write-output "Provisioned space is $ProvisionedSpace"
write-output "used Space is $usedSpace"
write-output "used CPU is $CPUUsed"
Write-Output "Provisioned memory is $Provisionedmemory"