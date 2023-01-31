//Using outputs from networking module to create VM

resource "azurerm_network_interface" "appinterface" {  
  name                = "appinterface"
  location            = module.networking_module.location
  resource_group_name = module.networking_module.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.networking_module.subnetid
    private_ip_address_allocation = "Dynamic"    
  }
  depends_on = [
    module.networking_module.subnet
  ]
}


resource "azurerm_windows_virtual_machine" "appvm" {
  name                = "appvm"
  resource_group_name = module.networking_module.resource_group_name
  location            = module.networking_module.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"
  network_interface_ids = [
    azurerm_network_interface.appinterface.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.appinterface,
    module.networking_module.resource_group
  ]
}

    
