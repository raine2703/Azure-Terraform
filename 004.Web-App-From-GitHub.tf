//Creating Azure App Service plan with Web app. Source code used from Github.
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "d030343c-fdd7-47cb-a6b7-b7027471025d"
  tenant_id = "c20a49b8-2914-4624-a197-1e882bd3abf4"
  client_id = "8498fe17-629b-4ad3-9d14-a6c2c37b90a9"
  client_secret = "Yrr8Q~dHXo1wZZV-sl_gvzt61ZvxEpeIOd8.Gdo_"
  features {}
}

//Defining local variables
locals {
  resource_group_name = "RG3"
  location = "North Europe"
   }

//Creating Resource Group
resource "azurerm_resource_group" "resource-group" {
  name     = local.resource_group_name
  location = local.location
}

//Creating B1 service plan. F1 is for free.
resource "azurerm_service_plan" "ServicePlan" {
  name                = "ServicePlan"
  resource_group_name = local.resource_group_name
  location            = local.location
  os_type             = "Windows"
  sku_name            = "B1"
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}

//Creating Web App
resource "azurerm_windows_web_app" "WebAppRn2703" {
  name                = "WebAppRn2703"
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = azurerm_service_plan.ServicePlan.id

  site_config {
    application_stack {
        current_stack = "dotnet"
        dotnet_version = "v6.0"
    }
  }
  depends_on = [
    azurerm_service_plan.ServicePlan
  ]
}

//Adding Github Repo as source
resource "azurerm_app_service_source_control" "appservice_sourcecontrol" {
  app_id   = azurerm_windows_web_app.WebAppRn2703.id
  repo_url = "https://github.com/raine2703/WebApp"
//Important that branch name is set correctly
  branch   = "main"
  use_manual_integration = true
  depends_on = [
    azurerm_windows_web_app.WebAppRn2703
  ]
}
