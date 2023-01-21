//Defining local variables
locals {
  resource_group_name = "RG3"
  location = "North Europe"
  virtual_network = {
    name="app-network"
    address_space="10.0.0.0/16"
}
}
