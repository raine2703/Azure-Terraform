
//Creating Storage account with random name and deny all connection firewall rule.

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
storage_acc_name = "storage"
location = "North Europe"
}

resource "azurerm_resource_group" "resource-group" {
  name     = local.resource_group_name
  location = local.location
}

//generating random number
resource "random_uuid" "random-uuid" {
}

//Getting my ip, incase i want to allow my PC access to SA
data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

//Creating SA
resource "azurerm_storage_account" "storage-account" {
  name = lower(join("", ["${local.storage_acc_name}", substr(random_uuid.random-uuid.result,0,8)]))  
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  depends_on = [
    azurerm_resource_group.resource-group,
    random_uuid.random-uuid
  ]
    network_rules {
    default_action             = "Deny"
 //   ip_rules                   = [data.http.ip.response_body]
 //   virtual_network_subnet_ids = [azurerm_subnet.example.id]
  }
}

//Checking outputs
output "Random-Number" {
  value = random_uuid.random-uuid.result
}
output "Storage-Name" {
  value = azurerm_storage_account.storage-account.name
}
output "ip" {
  value = data.http.ip.response_body
}
