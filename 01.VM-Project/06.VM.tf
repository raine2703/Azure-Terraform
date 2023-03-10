//Creating multiple Public IP addresses
resource "azurerm_public_ip" "Public-IP" {
  count=var.number-of-machines
  name                = "publicip${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating muliple NICs
resource "azurerm_network_interface" "vm1nic" {
  count=var.number-of-machines
  name                = "nic${count.index}"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "IPConfig${count.index}"
    subnet_id                     = azurerm_subnet.subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.Public-IP[count.index].id
  }
  depends_on = [
    azurerm_subnet.subnets,
    azurerm_public_ip.Public-IP
  ]
}

//Getting Password from Azure Key vault
data "azurerm_key_vault" "rkv2703x" {
  name                = "rkv2703x"
  resource_group_name = "RG2"
}

data "azurerm_key_vault_secret" "vmpassword2" {
  name         = "vmpassword2"
  key_vault_id = data.azurerm_key_vault.rkv2703x.id
}

//Creating VM
resource "azurerm_windows_virtual_machine" "virtual-machine" {
  count=var.number-of-machines  
  name                = "VM${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = local.vm_size
  admin_username      = local.vm_username
  admin_password      = data.azurerm_key_vault_secret.vmpassword2.value
  availability_set_id = azurerm_availability_set.availability-set.id
  network_interface_ids = [
    azurerm_network_interface.vm1nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = local.vm_storage_account_type
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = local.vm_sku
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.vm1nic,
    azurerm_resource_group.resource-group
  ]
}
