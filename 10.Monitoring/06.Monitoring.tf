//Creating action group
resource "azurerm_monitor_action_group" "email_alert" {
  name                = "email-alert"
  resource_group_name = local.resource_group_name
  short_name          = "email-alert"

  email_receiver {
    name          = "send-email-alert"
    email_address = "raitis.neitals@gmail.com"
    use_common_alert_schema = true
  }
}

//Network alert
resource "azurerm_monitor_metric_alert" "Network_threshold_alert" {
  name                = "Network-threshold-alert"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_windows_virtual_machine.vm1.id]
  description         = "The alert will be sent if the  Network Out bytes exceeds 70 bytes"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network Out Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 70
    
  }

  action {
    action_group_id = azurerm_monitor_action_group.email_alert.id
  }

  depends_on = [
    azurerm_windows_virtual_machine.vm1,
    azurerm_monitor_action_group.email_alert
  ]
}

//Activity log alert
resource "azurerm_monitor_activity_log_alert" "virtual_machine_operation" {
  name                = "virtual-machine-restart"
  resource_group_name = local.resource_group_name
  scopes              = [azurerm_resource_group.resource-group.id]
  description         = "This alert will be sent if the virtual machine is restarted"

  criteria {
    resource_id    = azurerm_windows_virtual_machine.vm1.id
    operation_name = "Microsoft.Compute/virtualMachines/restart/action"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.email_alert.id
   
  }

  depends_on = [
    azurerm_windows_virtual_machine.vm1,
    azurerm_monitor_action_group.email_alert
  ]
}
