//Creating Virtual Network
resource "azurerm_virtual_network" "virtual-network" {
  name                = local.virtual_network.name
  address_space       = [local.virtual_network.adress_space]
  location            = local.location
  resource_group_name = local.resource_group_name
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating Subnet
resource "azurerm_subnet" "SubnetA" {
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[0].address_range]
  depends_on = [
    azurerm_virtual_network.virtual-network
  ]
}

//Creating another Subnet
resource "azurerm_subnet" "SubnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[1].address_range]
  depends_on = [
    azurerm_virtual_network.virtual-network
  ]
}

//Creating Public IP
resource "azurerm_public_ip" "Public-IP" {
  name                = "${local.vm_name}-publicip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating NIC
resource "azurerm_network_interface" "vm1nic" {
  name                = local.nic_name
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "IPConfig"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.Public-IP.id
  }
  depends_on = [
    azurerm_subnet.SubnetA,
    azurerm_public_ip.Public-IP
  ]
}

//Creating NSG and allowing port 22 for SSH
resource "azurerm_network_security_group" "network-security-group" {
  name                = local.nsg_name
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
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

//Assigning NSG to SubnetA
resource "azurerm_subnet_network_security_group_association" "NSGAssociation" {
  subnet_id                 = azurerm_subnet.SubnetA.id
  network_security_group_id = azurerm_network_security_group.network-security-group.id
  depends_on = [
    azurerm_network_security_group.network-security-group,
    azurerm_subnet.SubnetA
  ]
}
