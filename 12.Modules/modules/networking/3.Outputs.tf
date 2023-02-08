//Defining outputs that will be used by other modules. For example - for depends_on valiadtion that resource is created.

output "virtual_network" {
  value=azurerm_virtual_network.network
}

output "subnets" {
  value=azurerm_subnet.subnets
}
  
