//Using networking module 2 times to create different resources

module "networking_module"{
    source="./networking"
    resource_group_name = "RG4"
    location = "North Europe"
    virtual_network_name = "vnet1"
    virtual_network_address_space = "10.0.0.0/16"
}

module "staging_networking_module"{
    source="./networking"
    resource_group_name = "RG5"
    location = "North Europe"
    virtual_network_name = "vnet2"
    virtual_network_address_space = "10.0.0.0/16"
}

//Different approach. Creating resource group, then using modules to add Storage Accounts to it.

resource "azurerm_resource_group" "resource-group" {
  name     = "RG7"
  location = "North Europe"
}

module "sa_module"{
    source="./storage-account"
    resource_group_name = azurerm_resource_group.resource-group.name
    location = "North Europe"
    storage_account_name = "randomstorageaccname1"
    depends_on = [
      azurerm_resource_group.resource-group
    ]
}

module "sa_module2"{
    source="./storage-account"
    resource_group_name = azurerm_resource_group.resource-group.name
    location = "North Europe"
    storage_account_name = "randomstorageaccname2"
    depends_on = [
      azurerm_resource_group.resource-group
    ]
}
