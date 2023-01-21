//Creating public ip for load balancer
resource "azurerm_public_ip" "loadip" {
  name                = "load-ip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku = "Standard"
depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//creating Sandard Regional load balancer
resource "azurerm_lb" "appbalancer" {
  name                = "app-balancer"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku = "Standard"
  sku_tier = "Regional"
  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.loadip.id
  }
  depends_on = [
    azurerm_public_ip.loadip
  ]
}

//Creating backend pool where scale set vms will be added
resource "azurerm_lb_backend_address_pool" "scalesetpool" {
  loadbalancer_id = azurerm_lb.appbalancer.id
  name            = "scalesetpool"
  depends_on = [
    azurerm_lb.appbalancer
  ]
}

//Health proble on port 80 as its used in https as well
resource "azurerm_lb_probe" "probeA" {
  loadbalancer_id = azurerm_lb.appbalancer.id
  name            = "probeA"
  port            = 80
  protocol = "Tcp"
  depends_on = [
    azurerm_lb.appbalancer
  ]
}

//Creating load balancer rule. Front end ip linking to backed with healh probe.
resource "azurerm_lb_rule" "RuleA" {
  loadbalancer_id                = azurerm_lb.appbalancer.id
  name                           = "RuleA"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  probe_id = azurerm_lb_probe.probeA.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.scalesetpool.id]
  depends_on = [
    azurerm_lb.appbalancer
  ]
}
