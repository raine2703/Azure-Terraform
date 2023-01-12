//Creating LAW for Application Insights
resource "azurerm_log_analytics_workspace" "appworkspace" {
  name                = "laworkspaceforwebapp"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

//Creating Application insights. Logs sent to appworkspace.
resource "azurerm_application_insights" "appinsights" {
  name                = "appinsights"
  location            = local.location
  resource_group_name = local.resource_group_name
  // web for asp.net
  application_type    = "web"
  workspace_id = azurerm_log_analytics_workspace.appworkspace.id
  depends_on = [
    azurerm_log_analytics_workspace.appworkspace
  ]
}
