//Creating a custom Script extension to install web server on all VMs
//As example script is created locally and then uplodated to Azure Storage from where azurerm_virtual_machine_extension takes it
//Can't be uploaded to Storage-Account.tf as it has enabled Firewall. Creating new Storage Account for this example.

//Creating Storage Account
resource "azurerm_storage_account" "rnstorage2703x56" {
  name                     = "rnstorage2703x56"
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"  
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating blob container
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = "rnstorage2703x56"
  container_access_type = "blob"
  depends_on=[
    azurerm_storage_account.rnstorage2703x56
    ]
}

//Uploading script to container
resource "azurerm_storage_blob" "IISConfig" {
  name                   = "IIS-Config.ps1"
  storage_account_name   = "rnstorage2703x56"
  storage_container_name = "data"
  type                   = "Block"
  source                 = "IIS-Config.ps1"
   depends_on=[azurerm_storage_container.data]
}

//Running script on all vms
resource "azurerm_virtual_machine_extension" "vmextension" {
  count=var.number-of-machines  
  name                 = "vmextension"
  virtual_machine_id   = azurerm_windows_virtual_machine.virtual-machine[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.rnstorage2703x56.name}.blob.core.windows.net/data/IIS-Config.ps1"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS-Config.ps1"     
    }
SETTINGS

depends_on = [
  azurerm_windows_virtual_machine.virtual-machine,
  azurerm_storage_blob.IISConfig
]

}
