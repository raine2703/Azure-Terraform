//Defining variables that will be used to create Storage account. Variables passed from main module.

variable "storage_account_name" {
  type=string
  description="This defines the name of the virtual network"
}

variable "resource_group_name" {
  type=string
  description="This defines the resource group name"
}

variable "location" {
  type=string
  description="This defines the location"
}

variable "storage2_not_required" {
  type=bool
  description="Is SA not required?"
  //default = false
}
  
