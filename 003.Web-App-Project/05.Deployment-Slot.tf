//Creating deployment slot
resource "azurerm_windows_web_app_slot" "staging" {
  name           = "staging"
  app_service_id = azurerm_windows_web_app.WebAppRn2703.id
  site_config {
    application_stack {
      current_stack="dotnet"
      dotnet_version="v6.0"
    }
  }
  depends_on = [
    azurerm_service_plan.ServicePlan
  ]
}

//Uploading code to new deployment slot. Use portal to swap manually.
resource "azurerm_app_service_source_control_slot" "example" {
  slot_id  = azurerm_windows_web_app_slot.staging.id
  repo_url = local.staging_repository
  branch   = local.branch
  use_manual_integration = true
  depends_on = [
    azurerm_windows_web_app_slot.staging
  ]
}
