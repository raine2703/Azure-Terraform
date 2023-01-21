//Creating vm scale set
resource "azurerm_windows_virtual_machine_scale_set" "appset" {  
  name                = "appset"
  resource_group_name = local.resource_group_name
  location            = local.location 
  sku                = "Standard_D2s_v3"
  instances = var.number_of_machines
  admin_username      = "adminuser"
  admin_password      = "Azure@123"  
  //Usually set to manual, but for CS to be installed setting it to automatic
  upgrade_mode = "Automatic"
    
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

  //Creating nic's for vms in scale set
  network_interface {
    name="scaleset-interface"
    primary=true

    ip_configuration {
    name="internal"
    primary=true
    subnet_id=azurerm_subnet.subnetA.id
    //Adding as backend pools to load balancer
    load_balancer_backend_address_pool_ids=[azurerm_lb_backend_address_pool.scalesetpool.id]
  }
  }
  depends_on = [
    azurerm_subnet.subnetA,    
    azurerm_resource_group.resource-group,
    azurerm_lb_backend_address_pool.scalesetpool
  ]
}
