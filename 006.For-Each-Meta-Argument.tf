
//How to use For Each Meta Argument  

resource "azurerm_resource_group" "RG" {
  name     = "RnRG32"
  location = "North Europe"
}

//toset() function - A set is a like a list but every item is guaranteed unique. 
//creting 3 Resource groups with for each. Using only key as a value.

resource "azurerm_resource_group" "RG3" {

  for_each = toset([ "RG1","RG2","RG3" ])

    name     = each.key
    location = "north europe"

}

//crating multiple resource gorups with for key and value

resource "azurerm_resource_group" "RG2" {

  for_each = {
    "RG4" = "North Europe"
    "RG5" = "West Europe"
}

      name     = each.key
      location = each.value

}


//Creating Storage account

resource "azurerm_storage_account" "rnstorageacc2703x52" {
  name                     = "rnstorageacc2703x52"
  resource_group_name      = azurerm_resource_group.RG.name
  location                 = azurerm_resource_group.RG.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  depends_on = [
    azurerm_resource_group.RG
  ]
}

//Creating 3 containers

resource "azurerm_storage_container" "container" {

  for_each = toset([ "data","files","documents" ])

      name                  = each.key
      storage_account_name  = azurerm_storage_account.rnstorageacc2703x52.name
      container_access_type = "blob"

}

//Uploadin multiple files

resource "azurerm_storage_blob" "testfiles" {

  for_each = {
    sample1 = "C:\\Users\\raiti\\Desktop\\Terraform\\folder1\\test1.txt"
    sample2 = "C:\\Users\\raiti\\Desktop\\Terraform\\folder2\\test2.txt"
    sample3 = "C:\\Users\\raiti\\Desktop\\Terraform\\folder3\\test3.txt"
  }

      name                   = "${each.key}.txt"
      storage_account_name   = "rnstorageacc2703x52"
      storage_container_name = "data"
      type                   = "Block"
      source                 = each.value
      depends_on = [
        azurerm_storage_account.rnstorageacc2703x52,
        azurerm_storage_container.container
  ]
}
