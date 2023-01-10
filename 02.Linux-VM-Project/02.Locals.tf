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
