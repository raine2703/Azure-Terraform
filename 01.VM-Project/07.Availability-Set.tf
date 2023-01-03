//Creating availability set
resource "azurerm_availability_set" "availability-set" {
  name                = "vm-availability-set"
  location            = local.location
  resource_group_name = local.resource_group_name
  platform_fault_domain_count = 3
  platform_update_domain_count = 3
  depends_on = [
    azurerm_resource_group.resource-group
  ]
}
