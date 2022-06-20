resource "azurerm_monitor_action_group" "ag" {
  name                = var.action_group_config_map.name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_config_map.short_name

  email_receiver {
    name                    = "${var.action_group_config_map.email_receiver_name}_-EmailAction-"
    email_address           = var.action_group_config_map.email_receiver_address
    use_common_alert_schema = false
  }
}