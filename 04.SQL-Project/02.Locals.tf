//Defining local variables
locals {
  resource_group_name = "RG3"
  location = "North Europe"
  dbuseraname = "dbadmin"
  sqlservername = "dbserver2013x"
  version = "12.0"
  db1name = "db1"
  db2name = "db2"
  virtual_network = {
    name = "vnet"
    adress_space = "10.0.0.0/16"
  }
  nsg_name = "NSG"
  vm_name = "vm1"
  vm_size = "Standard_B2s"
  vm_storage_account_type = "Standard_LRS"
  vm_sku = "2022-Datacenter"
  vm_username = "adminuser"
}
