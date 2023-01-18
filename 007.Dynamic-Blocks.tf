
// Creating NSG rules with Dynamic blocks

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "d030343c-fdd7-47cb-a6b7-b7027471025d"
  tenant_id = "c20a49b8-2914-4624-a197-1e882bd3abf4"
  client_id = "8498fe17-629b-4ad3-9d14-a6c2c37b90a9"
  client_secret = "Yrr8Q~dHXo1wZZV-sl_gvzt61ZvxEpeIOd8.Gdo_"
  features {}
}

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
