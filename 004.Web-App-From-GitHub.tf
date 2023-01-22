
//Creating Azure App Service plan with Web app. Source code used from Github.
  
//Defining local variables
locals {
  resource_group_name = "RG3"
  location = "North Europe"
   }

//Creating Resource Group
resource "azurerm_resource_group" "resource-group" {
  name     = local.resource_group_name
  location = local.location
}

//Creating B1 service plan. F1 is for free.
resource "azurerm_service_plan" "ServicePlan" {
  name                = "ServicePlan"
  resource_group_name = local.resource_group_name
  location            = local.location
  os_type             = "Windows"
  sku_name            = "B1"
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating Web App
resource "azurerm_windows_web_app" "WebAppRn2703" {
  name                = "WebAppRn2703"
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.ServicePlan.id

  site_config {
    application_stack {
        current_stack = "dotnet"
        dotnet_version = "v6.0"
    }
  }
  depends_on = [
    azurerm_service_plan.ServicePlan
  ]
}

//Adding Github Repo as source
resource "azurerm_app_service_source_control" "appservice_sourcecontrol" {
  app_id   = azurerm_windows_web_app.WebAppRn2703.id
  repo_url = "https://github.com/raine2703/WebApp"
  //Important that branch name is set correctly
  branch   = "main"
  //Example with manual integration. Without CI/CD.
  use_manual_integration = true
  depends_on = [
    azurerm_windows_web_app.WebAppRn2703
  ]
}
