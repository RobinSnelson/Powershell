New-AzVirtualNetworkGatewayConnection -Name VNet1toSite1 -ResourceGroupName TestRG1 -Location 'East US' -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -ConnectionType IPsec -RoutingWeight 10 -SharedKey 'abc123'

New-AzVirtualNetworkGatewayConnection -Name VNet1toSite1 -ResourceGroupName TestRG1 -Location 'East US' -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -ConnectionType IPsec -RoutingWeight 10 -SharedKey 'abc123'

$gateway1 = Get-AzVirtualNetworkGateway -Name gatewayname -ResourceGroupName rg
$local = Get-AzLocalNetworkGateway -Name gatewayname -ResourceGroupName rg
New-AzVirtualNetworkGatewayConnection -Name gatewayname -ResourceGroupName rg -Location 'UK South' -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -ConnectionType IPsec _routingWeight 10 -SharedKey 'key'