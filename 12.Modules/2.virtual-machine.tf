//Creating VM for each subnet

//Creating NIC for each subnet and assigning it to it.
resource "azurerm_network_interface" "example" {
  for_each=module.networking_module.subnets
  name                = "${each.key}-nic"
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.networking_module.subnets[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}

//Default VM Password used from KeyVault
data "azurerm_key_vault" "rkv2703x" {
  name                = "rkv2703x"
  resource_group_name = "RG2"
}

//Geting Secret value
data "azurerm_key_vault_secret" "vmpassword2" {
  name         = "vmpassword2"
  key_vault_id = data.azurerm_key_vault.rkv2703x.id
}

//Creating VM for each subnet, assiging NIC to it
resource "azurerm_windows_virtual_machine" "example" {
  for_each=module.networking_module.subnets
  name                = "${each.key}-vm"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = data.azurerm_key_vault_secret.vmpassword2.value
  network_interface_ids = [
    azurerm_network_interface.example[each.key].id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
