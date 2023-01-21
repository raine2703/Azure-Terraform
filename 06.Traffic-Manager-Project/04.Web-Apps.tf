//Creating Service plan for first web  app. North Europe location.
resource "azurerm_service_plan" "WebAppPlan1" {
  name                = "WebAppPlan1"
  resource_group_name = local.resource_group_name
  location            = "North Europe"
  os_type             = "Windows"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating web app
resource "azurerm_windows_web_app" "WebApp1" {
  name                = "WebApp1Rnx"
  resource_group_name = azurerm_service_plan.WebAppPlan1.resource_group_name
  location            = azurerm_service_plan.WebAppPlan1.location
  service_plan_id     = azurerm_service_plan.WebAppPlan1.id

  site_config {    
    application_stack {
    current_stack="dotnet"
    dotnet_version="v6.0"
}
  }

depends_on = [
    azurerm_service_plan.WebAppPlan1
  ]
}


//Creating Service plan for second web app. Central US location.
resource "azurerm_service_plan" "WebAppPlan2" {
  name                = "WebAppPlan2"
  resource_group_name = local.resource_group_name
  location            = "Central US"
  os_type             = "Windows"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.resource-group  ]
}

//Creating second web app
resource "azurerm_windows_web_app" "WebApp2" {
  name                = "WebApp2Rnx"
  resource_group_name = azurerm_service_plan.WebAppPlan2.resource_group_name
  location            = azurerm_service_plan.WebAppPlan2.location
  service_plan_id     = azurerm_service_plan.WebAppPlan2.id

  site_config {    
    application_stack {
    current_stack="dotnet"
    dotnet_version="v6.0"
}
  }

depends_on = [
    azurerm_service_plan.WebAppPlan2
  ]
}
