$account = Get-AzAutomationAccount

#$Runbook = Get-AzAutomationRunbook -AutomationAccountName $account.AutomationAccountName -ResourceGroupName $account.ResourceGroupName | Where-Object {$_.Name -eq 'Server_Management'}

Get-AzAutomationJob -ResourceGroupName $account.ResourceGroupName -RunbookName 'Server_Management' -AutomationAccountName $account.AutomationAccountName