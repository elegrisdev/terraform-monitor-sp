resource "azurerm_log_analytics_workspace" "law" {
  name                = format("logs-%s-%s", lower(var.dep_generic_map.service_name), lower(var.dep_generic_map.full_env_code))
  location            = var.dep_generic_map.location
  resource_group_name = var.resource_group_name
  retention_in_days   = var.logs_config_map.retention_in_days
  sku                 = var.logs_config_map.sku
}