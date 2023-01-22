//Public ip for vms
resource "azurerm_public_ip" "ip" {
 for_each = local.environment
  name                = "${each.key}-ip"
  resource_group_name = local.resource_group_name
  location            = local.location  
  allocation_method   = "Dynamic"
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

resource "azurerm_network_interface" "interface" {
  for_each = local.environment
  name                = "${each.key}-interface"
  location            = local.location  
  resource_group_name = local.resource_group_name

  //Assigning public ip to both vms. To check that peering works from one to another vm.  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_virtual_network.network[each.key].subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"    
    public_ip_address_id = azurerm_public_ip.ip[each.key].id
  }

  depends_on = [
    azurerm_virtual_network.network
  ]
}

//Creating vm for each vnet 
resource "azurerm_windows_virtual_machine" "vm" {
  for_each = local.environment
  name                = "${each.key}vm"
  resource_group_name = local.resource_group_name
  location            = local.location 
  size                = "Standard_D2s_v3"
  admin_username      = "raitisn"
  admin_password      = "Azure@123"      
    network_interface_ids = [
    azurerm_network_interface.interface[each.key].id,
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
    azurerm_virtual_network.network,
    azurerm_network_interface.interface
  ]
}
