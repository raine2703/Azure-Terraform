//Creating azure service plan, web app, deployment slot and enabled server logging

//Creating S1 Service plan.  S1 needed to have Deployment Slots
resource "azurerm_service_plan" "ServicePlan" {
  name                = local.service_plan_name
  resource_group_name = local.resource_group_name
  location            = local.location
  os_type             = local.os_type
  sku_name            = local.service_plan_sku
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating Web App
resource "azurerm_windows_web_app" "WebAppRn2703" {
  name                = local.web_app_name
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.ServicePlan.id

  site_config {
    application_stack {
        current_stack = "dotnet"
        dotnet_version = "v6.0"
    }
  }
//Enabling Web server logs. Connection with shared access signature.
  logs {
    detailed_error_messages = true
  http_logs {    
    azure_blob_storage {        
        retention_in_days=7   
        sas_url =  "https://${azurerm_storage_account.storage-account.name}.blob.core.windows.net/${azurerm_storage_container.logs.name}${data.azurerm_storage_account_blob_container_sas.accountsas.sas}"
    }
}
}
  depends_on = [
    azurerm_service_plan.ServicePlan
  ]
}
