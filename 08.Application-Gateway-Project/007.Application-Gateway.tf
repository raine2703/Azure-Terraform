//Pulbic ip for gateway
resource "azurerm_public_ip" "gatewayip" {
  name                = "gateway-ip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static" 
  //So its not basic
  sku="Standard"
  sku_tier = "Regional"
  depends_on = [
    azurerm_resource_group.resource-group
  ]

}

//Additional subnet in the virtual network for gateway
resource "azurerm_subnet" "appsubnet" {
  name                 = "appsubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"] 
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

//Creating Application Gateway
resource "azurerm_application_gateway" "appgateway" {
  name                = "app-gateway"
  resource_group_name = local.resource_group_name
  location            = local.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    //Two vms
    capacity = 2
  }

  //Adding to new subnet  
  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.appsubnet.id
  }

  frontend_port {
    name = "front-end-port"
    //Gateway will listen to
    port = 80
  }

  //Front end ip  
  frontend_ip_configuration {
    name                 = "front-end-ip-config"
    public_ip_address_id = azurerm_public_ip.gatewayip.id    
  }

  depends_on = [
    azurerm_public_ip.gatewayip,
    azurerm_subnet.subnetA,
    azurerm_windows_virtual_machine.vm,
    azurerm_virtual_machine_extension.vmextension
  ]

   //Dynamically creating 2 backend pools 
   dynamic backend_address_pool {  
     for_each = toset(local.role)
     content {
      name  = "${backend_address_pool.value}-pool"
      ip_addresses = [
        //taking private ip address of each nic
      "${azurerm_network_interface.nic[backend_address_pool.value].private_ip_address}"
      ]
    }
   }

      backend_http_settings {
    name                  = "HTTPSetting"
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

 http_listener {
    name                           = "gateway-listener"
    frontend_ip_configuration_name = "front-end-ip-config"
    frontend_port_name             = "front-end-port"
    protocol                       = "Http"
  }

 request_routing_rule {
    name               = "RoutingRuleA"
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "RoutingPath"
    http_listener_name = "gateway-listener"    
    priority = 1
  }

  url_path_map {
    name                               = "RoutingPath"    
    default_backend_address_pool_name   = "${local.role[0]}-pool"
    default_backend_http_settings_name  = "HTTPSetting"
   
     dynamic path_rule {
      for_each = toset(local.role)
       content {
      name                          = "${path_rule.value}RoutingRule"
      backend_address_pool_name     = "${path_rule.value}-pool"
      backend_http_settings_name    = "HTTPSetting"
      paths = [
        "/${path_rule.value}/*",
      ]
    }
     }
    
  }

}
