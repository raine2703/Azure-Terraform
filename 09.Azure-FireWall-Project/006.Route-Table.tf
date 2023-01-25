//Creating route table to route all traffic from Subnet to Firewall
resource "azurerm_route_table" "firewallroutetable" {
  name                          = "firewall-route-table"
  location                      = local.location
  resource_group_name           = local.resource_group_name
  disable_bgp_route_propagation = true
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Routing all traffic to internet true Firewall (virtual aplliacance)
//Associating with Route with Subnet
resource "azurerm_route" "firewallroute" {
  name                = "acceptanceTestRoute1"
  resource_group_name = local.resource_group_name
  route_table_name    = azurerm_route_table.firewallroutetable.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  //Firewall ip address
  next_hop_in_ip_address = azurerm_firewall.appfirewall.ip_configuration[0].private_ip_address

  depends_on = [
    azurerm_route_table.firewallroutetable
  ]
}

//Associating that traffic from SubnetA should be routed to FW
resource "azurerm_subnet_route_table_association" "subnetassociation" {
  subnet_id      = azurerm_subnet.subnetA.id
  route_table_id = azurerm_route_table.firewallroutetable.id
}
