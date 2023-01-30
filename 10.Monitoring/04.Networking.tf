resource "azurerm_virtual_network" "vnet" {
  name                = local.virtual_network.name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]  
  
   depends_on = [
     azurerm_resource_group.resource-group   ]
  }


  resource "azurerm_subnet" "subnetA" {  
  name                 = "SubnetA"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
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
    azurerm_resource_group.resource-group
  ]
}

resource "azurerm_subnet_network_security_group_association" "appnsglink" {  
  subnet_id                 = azurerm_subnet.subnetA.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_network_security_group.nsg
  ]
}
