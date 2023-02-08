//Creating Networking

//To get dependency that RG is created we need to get it as output from module that creates it. 
module general_module_dependency{
    //going to general folder to get RG name and location
    source=".././general"
    //rg name and location expected as variables for general module, have to pass them
    rg_name = var.resource_group_name
    rg_location = var.location
}

resource "azurerm_virtual_network" "network" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.virtual_network_address_space]
  depends_on = [
    //dependency to output from general module
    module.general_module_dependency.resource-group
  ]  
} 

resource "azurerm_subnet" "subnets" {  
    for_each=var.subnet_names  
    name                 = each.key
    resource_group_name  = var.resource_group_name
    virtual_network_name = var.virtual_network_name
    //creating subnets with cidrsubnet function and iterations true items we have in list
    address_prefixes     = [cidrsubnet(var.virtual_network_address_space,8,index(tolist(var.subnet_names),each.key))]
    depends_on = [
      azurerm_virtual_network.network
    ]
}

resource "azurerm_subnet" "bastionsubnet" {  
  //if bastion_required=true create this resourece. Terraform does not have if/then option available.
  //if its true, assign count to 1
  count =var.bastion_required ? 1 : 0 
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.10.0/24"]
  depends_on = [
    azurerm_virtual_network.network
  ]
}

//Bastion public ip
resource "azurerm_public_ip" "bastionip" {  
  count =var.bastion_required ? 1 : 0 
  name                = "bastion-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static" 
  sku = "Standard" 
 depends_on = [
   module.general_module_dependency.resource-group
 ]
}

//Creating bastion and assigin subnet and ip with [] as we use count
resource "azurerm_bastion_host" "appbastion" {
  count =var.bastion_required ? 1 : 0 
  name                = "appbastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastionsubnet[0].id
    public_ip_address_id = azurerm_public_ip.bastionip[0].id
  }
}

//Creating NSG for each subnet
resource "azurerm_network_security_group" "nsg" {
  for_each=var.network-security_group_names
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_virtual_network.network
  ]
}

//assigning nsg's to their subnets 
resource "azurerm_subnet_network_security_group_association" "nsg-link" {  
  for_each=var.network-security_group_names
  subnet_id                 = azurerm_subnet.subnets[each.value].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

  depends_on = [
    azurerm_virtual_network.network,
    azurerm_network_security_group.nsg
  ]
}

//Assiging nsg's to vnet's as defined in main
resource "azurerm_network_security_rule" "nsgrules" {
  //This is a bit tricky:
  //Going true each block one by one. For each id assign values object has. A way how to access list of objects.
  //id is now each.key, priority, access etc is each.value.
  //So as going true each id you get access to its different values. COOL.
 for_each={for rule in var.network_security_group_rules:rule.id=>rule}
  name                        = "${each.value.access}-${each.value.destination_port_range}"
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = each.value.access
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg[each.value.network_security_group_name].name
  depends_on = [
   module.general_module_dependency.resource-group,
   azurerm_network_security_group.nsg
 ]
}

