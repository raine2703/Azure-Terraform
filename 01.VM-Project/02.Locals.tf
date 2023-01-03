locals {
resource_group_name = "RG"
location = "North Europe"
virtual_network = {
    name = "vnet"
    adress_space = "10.0.0.0/16"
}
nsg_name = "NSG"
vm_size = "Standard_B2s"
vm_username = "adminuser"
vm_password = "P@$$w0rd1234!"
vm_storage_account_type = "Standard_LRS"
vm_sku = "2022-Datacenter"
}


