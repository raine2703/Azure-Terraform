//Creating VNet with Subnet that has service endpoint enabled for SQL server

//Creating Vnet
resource "azurerm_virtual_network" "virtual-network" {
  name                = local.virtual_network.name
  address_space       = [local.virtual_network.adress_space]
  location            = local.location
  resource_group_name = local.resource_group_name
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating SubnetA
resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = ["10.0.0.0/24"]
//Adding service endpoint for SQL
  service_endpoints = ["Microsoft.Sql"]
  depends_on = [
    azurerm_virtual_network.virtual-network
  ]
}

//Creating NSG
resource "azurerm_network_security_group" "network-security-group" {
  name                = local.nsg_name
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "RDP"
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
    azurerm_resource_group.resource-group
  ]
}

//Assigning NSGs to SubnetA
resource "azurerm_subnet_network_security_group_association" "NSGAssociation" {
  subnet_id                 = azurerm_subnet.SubnetA.id 
  network_security_group_id = azurerm_network_security_group.network-security-group.id
  depends_on = [
    azurerm_resource_group.resource-group,
    azurerm_virtual_network.virtual-network
  ]
}
