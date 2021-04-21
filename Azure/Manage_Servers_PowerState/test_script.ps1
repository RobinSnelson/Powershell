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

write-output $resoureGroups