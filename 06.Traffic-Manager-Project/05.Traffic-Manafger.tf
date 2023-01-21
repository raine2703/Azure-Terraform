//Creating Traffic Manager
resource "azurerm_traffic_manager_profile" "tmprofile" {
  name                   = "tmprofile"
  resource_group_name    = local.resource_group_name
  //Priority method  - when one site goes down then switch to another (based on priority)
  //Performance method for least latency
  traffic_routing_method = "Performance"

  //DNS name for Traffic manager  
  dns_config {
    relative_name = "WebAppRnx"
    ttl           = 100
  }

  //Monitoring  
  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
depends_on = [
  azurerm_resource_group.resource-group
]
  }

//Defining primary endpoint. This adds custom domain for web app as well (no need for aditional azurerm_app_service_custom_hostname_binding).
resource "azurerm_traffic_manager_azure_endpoint" "primaryendpoint" {
  name               = "primaryendpoint"
  profile_id         = azurerm_traffic_manager_profile.tmprofile.id
  //priority = 1, use when "Priority method" used as routhing method
  weight             = 100
  target_resource_id = azurerm_windows_web_app.WebApp1.id

  custom_header {
    name="host"
    value="${azurerm_windows_web_app.WebApp1.name}.azurewebsites.net"
  }

  depends_on = [
    azurerm_windows_web_app.WebApp1
  ]
}

//Defining Secondary endpoint. This adds custom domain for web app as well (no need for aditional azurerm_app_service_custom_hostname_binding) 
resource "azurerm_traffic_manager_azure_endpoint" "secondaryendpoint" {
  name               = "secondaryendpoint"
  profile_id         = azurerm_traffic_manager_profile.tmprofile.id
  //priority = 2, use when "Priority method" used as routhing method
  weight             = 100
  target_resource_id = azurerm_windows_web_app.WebApp2.id

  custom_header {
    name="host"
    value="${azurerm_windows_web_app.WebApp2.name}.azurewebsites.net"
  }

  depends_on = [
    azurerm_windows_web_app.WebApp2
  ]
}
