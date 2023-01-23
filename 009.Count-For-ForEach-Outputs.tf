
//Examples with count, for_each, for and outputs

//Defining local variables
locals {
  //Variables
  resource_group_name = "RG3"
  location = "North Europe"
  
  //List (Tuple) Massive of values. Indext 0,1,3.. available if needed.
  role=["videos","images"]
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
}

//Count example for Storage
resource "azurerm_storage_account" "rnstorageacc2703x52" {
  count = 2 
  name                     = "${count.index}countstoragern2"
  resource_group_name      = "RG3"
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}
//To get name, id, location etc in output:(iterate true list elements and output id of each one ) 
output "Count-StorageID-from-resourceblock" {
  value = [ for x in azurerm_storage_account.rnstorageacc2703x52 : x.id ]
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
  name                     = "${each.key}foreachstorage"
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

//For_each example for RG
resource "azurerm_resource_group" "RG46" {
  for_each = toset(local.rg46)
  name     = "${each.key}-RG"
  location = "North Europe"
}

output "RG46-ID-from-resourceblock" {
  value = [ for x in azurerm_resource_group.RG46 : x.id ]
}
//Outout from locals
output "RG46-index-value-from-locals" {
  value = [ for x,y in local.rg46 : "${x} is ${y}"]
}

//Creating from Map (Object)
resource "azurerm_resource_group" "RG1011" {
  for_each = local.rg
  name     = each.key
  location = each.value
}

//Accessing map object from resource block
output "RG1011-from-resourceblock" {
  value = [ for x in azurerm_resource_group.RG1011 : "${x.id} is id, ${x.name} is name"]
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
