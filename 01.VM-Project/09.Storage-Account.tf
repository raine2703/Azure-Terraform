//Storage account with random name and network rules to allow only connection from VMs and my IP
/*

resource "random_uuid" "random-uuid" {
}
data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

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
    ip_rules                   = [data.http.ip.response_body]
    virtual_network_subnet_ids = azurerm_subnet.subnets.*.id
  }
}

//Checking
 output "subnet_ids" {
     value = azurerm_subnet.subnets.*.id
 }

*/
