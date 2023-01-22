
//How to use count and ${count.index} Meta Argument

resource "azurerm_storage_account" "rnstorageacc2703x52" {
  count = 3  
  name                     = "${count.index}rnstorageacc2703x52"
  resource_group_name      = "RnRG32"
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  depends_on = [
    azurerm_resource_group.RG
  ]
}

//In result 3 Storage accounts will be created

