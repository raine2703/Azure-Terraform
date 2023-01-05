//Terraform Set Up - Download Terraform, Add Environment variable in Windows, Choose provider and Start using Terraform!
//Terraform as application must be registered in AAD. Also it must be granted necessary RBAC permissions on Subscription level. Contributor as example.

//terrafrom init
//terraform -version
//terraform -validate
//terraform plan -out main.tfplan
//terraform plan -out main.tfplan -var="number-of-subnets=3"
//terraform apply 
//terraform apply main.tfplan   - defines plan we created before
//terraform destroy

/* Showing outputs. 
output "SubnetA-ID" {
  value = azurerm_subnet.SubnetA.id
}
*/

//Defining to use Azure as provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
}

//Authenticating to Azure
provider "azurerm" {
  subscription_id = "d030343c-fdd7-47cb-a6b7-b7027471025d"
  tenant_id = "c20a49b8-2914-4624-a197-1e882bd3abf4"
  client_id = "8498fe17-629b-4ad3-9d14-a6c2c37b90a9"
  client_secret = "Yrr8Q~dHXo1wZZV-sl_gvzt61ZvxEpeIOd8.Gdo_"
  features {}
}

//Thats it! 
resource "azurerm_resource_group" "RG" {
  name     = "RnRG32"
  location = "North Europe"
}

