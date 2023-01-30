//Creating NIC
resource "azurerm_network_interface" "nic" {
  for_each = toset(local.role)
  name                = "${each.key}-interface"
  location            = local.location  
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"    
  }

  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

//Creating VMs
resource "azurerm_windows_virtual_machine" "vm" {
  for_each = toset(local.role)
  name                = "${each.key}vm"
  resource_group_name = local.resource_group_name
  location            = local.location 
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "Azure@123"      
    network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
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
    azurerm_virtual_network.vnet,
    azurerm_network_interface.nic
  ]
}

//Checking some outputs

//How to output nic id from [] ? this is how:
//For all elements in LIST network interface go true and take id. 
output "nic-id" {
  value = [ for x in azurerm_network_interface.nic : x.id ]
}

//For all list (or tuple) take values. Index (optional) and value.
//role=["videos","images"]  
output "roles" {
  value = [ for x,y in local.role : "${x} is ${y}"]
  //formula [for i, v in var.list : "${i} is ${v}"]
}

//for all elements map (or object) (values identified by name) take key an value
output "vnet" {
  value = [for a, b in local.virtual_network : "${a} is ${b}"]
  //formula [for k, v in var.map : length(k) + length(v)] 
}

