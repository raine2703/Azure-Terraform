//Creating Storage account, Container, SAS token

//For random storage name
resource "random_uuid" "random-uuid" {
}

resource "azurerm_storage_account" "storage-account" {
  name = lower(join("", ["${local.storage_acc_name}", substr(random_uuid.random-uuid.result,0,8)]))    
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating Container for logs
resource "azurerm_storage_container" "logs" {
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.storage-account.name
  container_access_type = "blob"
  depends_on = [
    azurerm_storage_account.storage-account
  ]
}

//Generating SAS
data "azurerm_storage_account_blob_container_sas" "accountsas" {
  connection_string = azurerm_storage_account.storage-account.primary_connection_string
  container_name=azurerm_storage_container.logs.name
  https_only        = true  
  
  start  = "2023-01-01"
  expiry = "2023-01-30"

  permissions {
    read   = true
    add    = true
    create = false
    write  = true
    delete = true
    list   = true
  }
  depends_on = [
    azurerm_storage_account.storage-account
  ]
}

//Full SAS
output "sas" {
  value=nonsensitive("https://${azurerm_storage_account.storage-account.name}.blob.core.windows.net/${azurerm_storage_container.logs.name}${data.azurerm_storage_account_blob_container_sas.accountsas.sas}")
  }
