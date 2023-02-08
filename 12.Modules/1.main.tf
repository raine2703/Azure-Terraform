//Modules for RG, Networking, VM

locals {
  resource_group_name = "RG3"
  resource_group_location = "North Europe"
}

//Resource group module
module "general_module"{
    source="./modules/general"
    rg_name = local.resource_group_name
    rg_location = local.resource_group_location
}

//Networking module
module "networking_module" {
  source="./modules/networking"
  resource_group_name=local.resource_group_name
  location=local.resource_group_location
  virtual_network_name="vnet"
  virtual_network_address_space="10.0.0.0/16"
  subnet_names=["prod","test"]
  //Like if/then. If true, bastion is created, false then no. Terraform does not have if/then. Workaround.
  bastion_required=false
  //Linking NSG names for Subnets
  network-security_group_names={
    "prod-nsg"="prod"
    "test-nsg"="test"}
  //Defining multiple NSG rules. Set containing Objects.
  network_security_group_rules=[{
      id=1,
      priority="100",
      network_security_group_name="prod-nsg"
      destination_port_range="3389"
      access="Allow"
  },
  {
      id=2,
      priority="200",
      network_security_group_name="test-nsg"
      destination_port_range="3389"
      access="Allow"
  },
  {
      id=3,
      priority="400",
      network_security_group_name="prod-nsg"
      destination_port_range="443"
      access="Allow"
  }
  ]
}

//Generating random number for storage account name
resource "random_uuid" "random-uuid" {
}

//Creating Storage account
module "sa_module"{
    source="./modules/storage-account"
    //Playing with reverse logic. If false SA will be created. If true will not be created.
    storage2_not_required=false
    resource_group_name = local.resource_group_name
    location = "North Europe"
    storage_account_name = lower(join("", ["storage1", substr(random_uuid.random-uuid.result,0,8)]))  
    depends_on = [
      module.general_module.resource-group
    ]
}

//Using same module to create second storage account. 
//storage2_not_required=true means it will NOT be created
module "sa_module2"{
    source="./modules/storage-account"
    //Playing with reverse logic
    storage2_not_required=true
    resource_group_name = local.resource_group_name
    location = "North Europe"
    storage_account_name = lower(join("", ["storage2", substr(random_uuid.random-uuid.result,0,8)]))  
    depends_on = [
      module.general_module.resource-group
    ]
}
