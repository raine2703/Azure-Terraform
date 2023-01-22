//Creating vnet with subnets for each vnet
resource "azurerm_virtual_network" "network" {
  for_each = local.environment
  name                = "${each.key}-network"
  location            = local.location  
  resource_group_name = local.resource_group_name
  address_space       = [each.value]
  depends_on = [
    azurerm_resource_group.resource-group
  ]  
  subnet {
    name           = "${each.key}subnet"
    //cidrsubnet(prefix, newbits, netnum). Converting 10.0.0.0/16 to 10.0.0.0/24 for subnet.
    address_prefix = cidrsubnet(each.value,8,0)
  }
} 

//Creating NSG for each vnet
resource "azurerm_network_security_group" "nsg" {
  for_each = local.environment
  name                = "${each.key}-nsg"
  location            = local.location 
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
depends_on = [
    azurerm_virtual_network.network
  ]
}

//Assigning nsg to subnets
resource "azurerm_subnet_network_security_group_association" "nsg-link" {
  for_each = local.environment
  //for each vnet taking subnet 0 (as we have only 1 subnet)
  subnet_id                 = azurerm_virtual_network.network[each.key].subnet.*.id[0]
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

  depends_on = [
    azurerm_virtual_network.network,
    azurerm_network_security_group.nsg
  ]
}

