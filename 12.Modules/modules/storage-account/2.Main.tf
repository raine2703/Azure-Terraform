//Creating Storage account based on defined variables

resource "azurerm_storage_account" "storage-account" {
  //Log -  if false then storage account will be created once. Workaround for if/then.
  count =var.storage2_not_required ? 0 : 1 
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
}

    
