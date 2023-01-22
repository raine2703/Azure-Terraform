//Storage account for cs
resource "azurerm_storage_account" "rnstorage23x1" {
  name                     = "rnstorage23x1"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"  
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Container
resource "azurerm_storage_container" "data" {
  name                  = "config"
  storage_account_name  = "rnstorage23x1"
  container_access_type = "blob"
  depends_on=[
    azurerm_storage_account.rnstorage23x1
    ]
}

//Uploading both IIS configs
resource "azurerm_storage_blob" "IISConfig" {
  for_each = toset(local.role)
  name                   = "IIS_Config_${each.key}.ps1"
  storage_account_name   = "rnstorage23x1"
  storage_container_name = "config"
  type                   = "Block"
  source                 = "IIS_Config_${each.key}.ps1"
   depends_on=[azurerm_storage_container.data,
    azurerm_storage_account.rnstorage23x1]
}


resource "azurerm_virtual_machine_extension" "vmextension" {
  for_each = toset(local.role)
  name                 = "${each.key}-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [
    azurerm_storage_blob.IISConfig
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.rnstorage23x1.name}.blob.core.windows.net/config/IIS_Config_${each.key}.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config_${each.key}.ps1"     
    }
SETTINGS

}
