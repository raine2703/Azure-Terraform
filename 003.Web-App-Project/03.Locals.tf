//Defining local variables
locals {
  resource_group_name = "RG3"
  location = "North Europe"
  service_plan_name = "ServicePlan"
  os_type = "Windows"
  service_plan_sku = "S1"
  web_app_name = "WebAppRn2703"
  staging_repository = "https://github.com/raine2703/WebApp"
  branch = "main"
  storage_acc_name = "storage"
}
