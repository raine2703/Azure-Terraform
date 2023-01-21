//Creating storage account. Will be used to save CS
resource "azurerm_storage_account" "vmstore4577687" {
  name                     = "vmstore4577687x"
  resource_group_name      = local.resource_group_name
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"  
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating container
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = "vmstore4577687x"
  container_access_type = "blob"
  depends_on=[
    azurerm_storage_account.vmstore4577687
    ]
}

//Uploading custom script
resource "azurerm_storage_blob" "IISConfig" {
  name                   = "IIS_Config.ps1"
  storage_account_name   = "vmstore4577687x"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "IIS_Config.ps1"
   depends_on=[azurerm_storage_container.data,
    azurerm_storage_account.vmstore4577687]
}

//Adding extension to vms in scale set
resource "azurerm_virtual_machine_scale_set_extension" "scalesetextension" {
  name                 = "scalesetextension"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.appset.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"
  depends_on = [
    azurerm_storage_blob.IISConfig
  ]
  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.vmstore4577687.name}.blob.core.windows.net/data/IIS_Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"     
    }
SETTINGS

}
