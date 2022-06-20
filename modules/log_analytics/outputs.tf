output "workspace_id" {
  value = azurerm_log_analytics_workspace.law.workspace_id
}

output "workspace_key" {
  value = azurerm_log_analytics_workspace.law.primary_shared_key
  sensitive = true
}

output "id" {
  value =azurerm_log_analytics_workspace.law.id
}