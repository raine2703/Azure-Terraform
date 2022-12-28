//Creating Linux VM with SSH key.
//ssh -i .\linuxkey.pem adminuser@20.223.183.94


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




//Defining local variables
locals {
  resource_group_name = "RG"
  location = "North Europe"
  nic_name = "vm1nic"
  nsg_name = "nsg"
  vm_name = "linuxvm"
  vm_size = "Standard_B2s"
  vm_storage_account_type = "Standard_LRS"
  vm_username = "adminuser"
  virtual_network = {
    name = "vnet"
    adress_space = "10.0.0.0/16"
  }
  subnets = [
    {
      name = "production"
      address_range = "10.0.1.0/24"
    },
    {
      name = "test"
      address_range = "10.0.2.0/24"
    }
  ]
}



//Creating Resource Group
resource "azurerm_resource_group" "resource-group" {
  name     = local.resource_group_name
  location = local.location
}

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

//Generate key for linux vm
resource "tls_private_key" "linuxkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

//Stores the key in linuxkey.pem file NOT RECOMENDED FOR PRODUCTION USE
resource "local_file" "linuxpemkey"{
  filename = "linuxkey.pem"
  content=tls_private_key.linuxkey.private_key_pem
  depends_on = [
    tls_private_key.linuxkey
  ]
}


//Creating Linux VM
resource "azurerm_linux_virtual_machine" "virtual-machine" {
  name                = local.vm_name
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = local.vm_size
  admin_username      = local.vm_username
  network_interface_ids = [
    azurerm_network_interface.vm1nic.id,
  ]

  admin_ssh_key {
    username   = local.vm_username
    public_key = tls_private_key.linuxkey.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = local.vm_storage_account_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.vm1nic,
    tls_private_key.linuxkey
  ]
}

