//Creating VM with Vnet, Subnets, NIC, NSG, NSG Rule, Subnet-NSG association.

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


//Defining local variables for reuse purpose

locals {
  resource_group_name = "RG3"
  location = "North Europe"
//local variable based on map (object) type
  virtual_network = {
    name = "Vnet1"
    adress_space = "10.0.0.0/16"
  }
//using list
  subnets = [
    {
      name = "SubnetA"
      address_range = "10.0.1.0/24"
    },
    {
      name = "SubnetB"
      address_range = "10.0.2.0/24"
    }
  ]
  NIC_name = "VM1NIC"
  NSG_name = "NSG1"
  VM_name = "VM1"
  VM_size = "Standard_B2s"
  VM_storage_account_type = "Standard_LRS"
  VM_sku = "2022-Datacenter"

  VM_username = "adminuser"
  VM_password = "P@$$w0rd1234!"
  
}


//Creating Resources:

resource "azurerm_resource_group" "RG3" {
//using local variables
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "Vnet1" {
//using local object variables
  name                = local.virtual_network.name
  address_space       = [local.virtual_network.adress_space]
  location            = local.location
  resource_group_name = local.resource_group_name
  depends_on = [
//each next resource depends on previous to be created
    azurerm_resource_group.RG3
  ]
}

resource "azurerm_subnet" "SubnetA" {
//using list variables
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[0].address_range]
  depends_on = [
    azurerm_virtual_network.Vnet1
  ]
}

resource "azurerm_subnet" "SubnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = [local.subnets[1].address_range]
  depends_on = [
    azurerm_virtual_network.Vnet1
  ]
}

resource "azurerm_network_interface" "VM1NIC" {
  name                = local.NIC_name
  location            = local.location
  resource_group_name = local.resource_group_name

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
  name                = local.NSG_name
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
  name                = local.VM_name
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = local.VM_size
  admin_username      = local.VM_username
  admin_password      = local.VM_password
  network_interface_ids = [
    azurerm_network_interface.VM1NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = local.VM_storage_account_type
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = local.VM_sku
    version   = "latest"
  }
  depends_on = [
    azurerm_subnet_network_security_group_association.NSG1-Association
  ]
}