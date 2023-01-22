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

//Creating Subnets
resource "azurerm_subnet" "subnets" {
  count=var.number-of-subnets
  name                 = "Subnet${count.index}"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
//Adding Service endpoint for storage
  service_endpoints = ["Microsoft.Storage"]
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
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Assigning NSG to Subnets
resource "azurerm_subnet_network_security_group_association" "NSGAssociation" {
  count=var.number-of-subnets
  subnet_id                 = azurerm_subnet.subnets[count.index].id 
  network_security_group_id = azurerm_network_security_group.network-security-group.id
  depends_on = [
    azurerm_resource_group.resource-group,
    azurerm_virtual_network.virtual-network
  ]
}
