//Creating VM with Vnet, Subnet, NIC, NSG, NSG Rule, Subnet-NSG association.

//terraform plan -out main.tfplan
//terraform apply main.tfplan

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "d030343c-fdd7-47cb-a6b7-b7027471025d"
  tenant_id = "c20a49b8-2914-4624-a197-1e882bd3abf4"
  client_id = "8498fe17-629b-4ad3-9d14-a6c2c37b90a9"
  client_secret = "Yrr8Q~dHXo1wZZV-sl_gvzt61ZvxEpeIOd8.Gdo_"
  features {}
}


//Creating Resources:

resource "azurerm_resource_group" "RG3" {
  name     = "RG3"
  location = "North Europe"
}

resource "azurerm_virtual_network" "Vnet1" {
  name                = "Vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG3.location
  resource_group_name = azurerm_resource_group.RG3.name
  depends_on = [
    azurerm_resource_group.RG3
  ]
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.RG3.name
  virtual_network_name = azurerm_virtual_network.Vnet1.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_virtual_network.Vnet1
  ]
}

resource "azurerm_network_interface" "VM1NIC" {
  name                = "VM1NIC"
  location            = azurerm_resource_group.RG3.location
  resource_group_name = azurerm_resource_group.RG3.name

  ip_configuration {
    name                          = "IPConfig"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    azurerm_subnet.SubnetA
  ]
}

resource "azurerm_network_security_group" "NSG1" {
  name                = "NSG1"
  location            = azurerm_resource_group.RG3.location
  resource_group_name = azurerm_resource_group.RG3.name

  security_rule {
    name                       = "tcp-inbount-allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [
    azurerm_subnet.SubnetA
  ]
}

resource "azurerm_subnet_network_security_group_association" "NSG1-Association" {
  subnet_id                 = azurerm_subnet.SubnetA.id
  network_security_group_id = azurerm_network_security_group.NSG1.id
  depends_on = [
    azurerm_network_security_group.NSG1
  ]
}

resource "azurerm_windows_virtual_machine" "VM1" {
  name                = "VM1"
  resource_group_name = azurerm_resource_group.RG3.name
  location            = azurerm_resource_group.RG3.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.VM1NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_subnet_network_security_group_association.NSG1-Association
  ]
}
