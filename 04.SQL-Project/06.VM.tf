//VM To test connection to SQL server from SubnetA

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
  name                = "vm1nic"
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
  ]
}

//VM Password from Key Vault
data "azurerm_key_vault_secret" "vmpassword2" {
  name         = "vmpassword2"
  key_vault_id = data.azurerm_key_vault.rkv2703x.id
}

//Creating VM
resource "azurerm_windows_virtual_machine" "virtual-machine" {
  name                = local.vm_name
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = local.vm_size
  admin_username      = local.vm_username
  admin_password      = data.azurerm_key_vault_secret.vmpassword2.value
  network_interface_ids = [
    azurerm_network_interface.vm1nic.id,
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
    azurerm_network_interface.vm1nic
  ]
}
