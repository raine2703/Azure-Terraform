# The storage account will be used to store the script for Custom Script extension

resource "azurerm_storage_account" "rnstorage2783x" {
  name                     = "rnstorage2783"
  resource_group_name      = local.resource_group_name
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"  
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = "rnstorage2783"
  container_access_type = "blob"
  depends_on=[
    azurerm_storage_account.rnstorage2783x
    ]
}

resource "azurerm_storage_blob" "IISConfig" {
  name                   = "IIS_Config.ps1"
  storage_account_name   = "rnstorage2783"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "IIS_Config.ps1"
   depends_on=[azurerm_storage_container.data,
    azurerm_storage_account.rnstorage2783x]
}


resource "azurerm_virtual_machine_extension" "productionvmextension" {  
  name                 = "productionvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm["production"].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IISConfig,
    azurerm_windows_virtual_machine.vm
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.rnstorage2783x.name}.blob.core.windows.net/data/IIS_Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"     
    }
SETTINGS


}
