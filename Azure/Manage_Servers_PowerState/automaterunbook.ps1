$account = Get-AzAutomationAccount

$Runbook = Get-AzAutomationRunbook -AutomationAccountName $account.AutomationAccountName -ResourceGroupName $account.ResourceGroupName | Where-Object {$_.Name -eq 'Server_Management'}

$Runbook

Set-AzAutomationRunbook -Name $Runbook.AutomationAccountName -ResourceGroupName $account.ResourceGroupName -AutomationAccountName $account -Description "Starts and stops machines on a schedule"