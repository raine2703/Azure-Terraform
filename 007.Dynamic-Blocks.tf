
// Creating NSG rules with Dynamic blocks

locals {
resource_group_name = "RG"
location = "North Europe"
networksecuritygroup_rules=[
    {
      priority=200
      destination_port_range="3389"
    },
    {
      priority=300
      destination_port_range="80"
    }
  ]
}

resource "azurerm_resource_group" "resource-group" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_network_security_group" "network-security-group" {
  name                = "NSG"
  location            = local.location
  resource_group_name = local.resource_group_name

//Defing NSG rule as Dynamic Block with multiple possible input variables

  dynamic "security_rule" {
    for_each = local.networksecuritygroup_rules
    content {
        name                       = "Allow-${security_rule.value.destination_port_range}"
        priority                   = security_rule.value.priority
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = security_rule.value.destination_port_range
        source_address_prefix      = "*"
        destination_address_prefix = "*"    
      }
    }
    depends_on = [
        azurerm_resource_group.resource-group
  ]
}
