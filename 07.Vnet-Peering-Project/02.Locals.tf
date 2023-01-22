//Defining local variables
locals {
  resource_group_name = "RG3"
  location = "North Europe"
  environment = {
    production="10.0.0.0/16"
    test="10.1.0.0/16"
    }
}
