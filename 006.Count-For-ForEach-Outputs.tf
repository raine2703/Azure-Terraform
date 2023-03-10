
//Examples with count, for_each, for and outputs

locals {

  resource_group_name = "RG3"
  location = "North Europe"
  
  //List (Tuple) Massive of values. Index 0,1,3.. available if needed.
  role=["prod","test"]
  rg46=["RG4","RG5", "RG6"]
  
  //Map (Object) Key-Value Pairs
  rg = {
    "RG10" = "North Europe"
    "RG11" = "West Europe"
  }
  virtual_network = {
    name = "vnet"
    address_space = "10.0.0.0/16"
  }
  common-tags = {
    "environment" = "staging"
    "tier" = 3
    "department" = "IT"
  }
  
}
  
  
resource "azurerm_resource_group" "resource-group" {
  name     = local.resource_group_name
  location = local.location
} 
  
  
//Count example for Storage with for tags
resource "azurerm_storage_account" "rnstorageacc2703x52" {
  
  count = 2 
  
      name                     = "${count.index}countstoragern2"
      resource_group_name      = "RG3"
      location                 = "North Europe"
      account_tier             = "Standard"
      account_replication_type = "LRS"
      account_kind = "StorageV2"
      tags = {
        //environment = local.common-tags.environment
        //tier = local.common-tags.tier
        //department = local.common-tags.department

        //Instead using FOR expression:
        for a,b in local.common-tags : a=>"${b}" 
      }
      depends_on = [
        azurerm_resource_group.resource-group
      ]
}
  
//To get name, id, location etc. in output:(iterate true list elements and output id of each one ) 
output "Count-StorageID-from-resourceblock" {
  value = [ for x in azurerm_storage_account.rnstorageacc2703x52 : x.id ]
}

  
//Creat 3 containers to rnstorageacc2703x52 using same count feature. See how SA name is accessed!
resource "azurerm_storage_container" "container" {
  
  count = 2
  
      name                  = "container"
      storage_account_name  = azurerm_storage_account.rnstorageacc2703x52[count.index].name
      container_access_type = "blob"
  
}

  
  
//Count example for RG
resource "azurerm_resource_group" "RG012" {
  
   count = 2
  
      name     = "${count.index}RG"
      location = "North Europe"
  
}

  
//For_each example for Storage Account
resource "azurerm_storage_account" "rnstorageacc2703x52x" {
  
  for_each = toset(local.role)
  
      name                     = "${each.key}foreach"
      resource_group_name      = "RG3"
      location                 = "North Europe"
      account_tier             = "Standard"
      account_replication_type = "LRS"
      account_kind = "StorageV2"
      depends_on = [
        azurerm_resource_group.resource-group ]
  
}
  
output "For_Each-StorageID" {
  value = [ for x in azurerm_storage_account.rnstorageacc2703x52x : x.id ]
}

  
//Creat 3 containers to rnstorageacc2703x52x using same for each feature
resource "azurerm_storage_container" "container2" {
  
  for_each = azurerm_storage_account.rnstorageacc2703x52x
  
      name                  = "container2"
      storage_account_name  = azurerm_storage_account.rnstorageacc2703x52x[each.key].name
      container_access_type = "blob"
  
}


//For_each example for RG from local list
resource "azurerm_resource_group" "RG46" {
  
  for_each = toset(local.rg46)
  
      name     = "${each.key}-RG"
      location = "North Europe"
  
}
  
output "RG46-ID-from-resourceblock-that-uses-for-each" {
  value = [ for x in azurerm_resource_group.RG46 : x.id ]
}
output "RG46-ID-from-resourceblock-without-for-each" {
  value = azurerm_resource_group.resource-group.name
  //if for each have not been used, there are no name = value pairs available.
}

  
//Creating RG from local Map (Object)
resource "azurerm_resource_group" "RG1011" {
  
  for_each = local.rg
  
      name     = each.key
      location = each.value
  
}
  
//Accessing map object from resource block
output "RG1011-from-resourceblock" {
  value = [ for x in azurerm_resource_group.RG1011 : "${x.id} is id, ${x.name} is name"]
}

  
//Testing outputs from local variables
  
  
output "RG46-index-value-from-locals" {
  value = [ for x,y in local.rg46 : "Index is ${x}, Value is ${y}"]
}  
  
//For all list items take index (optional) and value. Default just value.
output "roles-index-value" {
  value = [ for x,y in local.role : "Index is ${x}, value is ${y}"]
  //formula [for i, v in var.list : "${i} is ${v}"]
}
    
output "roles-just-value" {
  value = [ for x in local.role : "Value is ${x}"]
  //formula [for i, v in var.list : "${i} is ${v}"]
}

//for all elements map take key an value
output "vnet-key-value" {
  value = [for a, b in local.virtual_network : "Key is ${a}, value is ${b}"]
  //formula [for k, v in var.map : length(k) + length(v)] 
}
    
    
