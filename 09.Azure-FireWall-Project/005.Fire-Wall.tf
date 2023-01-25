
//Public IP for FW
resource "azurerm_public_ip" "firewallip" {
  name                = "firewall-ip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static" 
  sku="Standard"
  sku_tier = "Regional"
  depends_on = [
    azurerm_resource_group.resource-group
  ]

}

//Subnet for FW
resource "azurerm_subnet" "firewallsubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = ["10.0.1.0/24"] 
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

//Creating firewall policy
resource "azurerm_firewall_policy" "firewallpolicy" {
  name                = "firewallpolicy"
  resource_group_name = local.resource_group_name
  location            = local.location
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating Azure Firewall
resource "azurerm_firewall" "appfirewall" {
  name                = "appfirewall"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewallsubnet.id
    public_ip_address_id = azurerm_public_ip.firewallip.id
  }

  sku_tier = "Standard"
  sku_name = "AZFW_VNet"

  //Linking to Policy  
  firewall_policy_id = azurerm_firewall_policy.firewallpolicy.id
  depends_on = [
    azurerm_firewall_policy.firewallpolicy,
    azurerm_resource_group.resource-group
  ]
}
  
