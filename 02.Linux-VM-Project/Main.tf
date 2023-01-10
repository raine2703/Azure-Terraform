//Creating Linux VM with SSH key.
//To log in: ssh -i .\linuxkey.pem adminuser@20.223.183.94
//Installing nginx with custom script

//Creating Resource Group
resource "azurerm_resource_group" "resource-group" {
  name     = local.resource_group_name
  location = local.location
}

