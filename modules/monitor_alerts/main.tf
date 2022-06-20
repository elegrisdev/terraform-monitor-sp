resource "azurerm_monitor_scheduled_query_rules_alert" "alert" {
  name                = var.alerts_config_map.name
  location            = var.dep_generic_map.location
  resource_group_name = var.resource_group_name

  action {
    action_group           = var.action_group_ids
    email_subject          = var.alerts_config_map.email_subject
    custom_webhook_payload = "{}"
  }
  data_source_id = var.log_analytics_id
  enabled        = var.alerts_config_map.enabled
  query          = var.alerts_config_map.query
  severity       = var.alerts_config_map.severity
  frequency      = var.alerts_config_map.frequency
  time_window    = var.alerts_config_map.time_window
  trigger {
    operator  = var.alerts_config_map.trigger_operator
    threshold = var.alerts_config_map.trigger_threshold
  }
}
