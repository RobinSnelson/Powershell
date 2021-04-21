$account = Get-AzAutomationAccount

$startDate = (Get-Date "19:30:00")
$expireDate = (Get-Date).AddDays(30)

[System.DayOfWeek[]]$DaysToRun = @([System.DayOfWeek]::Monday..[System.DayOfWeek]::Sunday)

#New-AzAutomationSchedule -AutomationAccountName $account.AutomationAccountName -Name "DailyAt1900" -StartTime $startDate  -WeekInterval 1 -DaysOfWeek $DaysToRun -ResourceGroupName $account.ResourceGroupName

New-AzAutomationSchedule -AutomationAccountName $account.AutomationAccountName -Name "DailyAt1930" -StartTime $startDate -DayInterval 1 -ResourceGroupName $account.ResourceGroupName -ExpiryTime $expireDate


Set-AzAutomationSchedule -Name "DailyAt1930" -AutomationAccountName $account.AutomationAccountName  -ResourceGroupName $account.ResourceGroupName -






