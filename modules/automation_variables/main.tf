resource "azurerm_automation_variable_string" "variable_string" {
  name                    = var.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  value                   = var.value
  encrypted               = var.encrypted
}

# resource "azurerm_automation_variable_string" "workspace_id" {
#   name                    = "workspace_id"
#   resource_group_name     = var.resource_group_name
#   automation_account_name = azurerm_automation_account.aa.name
#   value                   = azurerm_log_analytics_workspace.law.workspace_id
# }

# resource "azurerm_automation_variable_string" "workspace_key" {
#   name                    = "workspace_key"
#   resource_group_name     = var.resource_group_name
#   automation_account_name = azurerm_automation_account.aa.name
#   value                   = azurerm_log_analytics_workspace.law.primary_shared_key
#   encrypted               = true
# }

# resource "azurerm_automation_variable_string" "tenant_id" {
#   name                    = "tenant_id"
#   resource_group_name     = var.resource_group_name
#   automation_account_name = azurerm_automation_account.aa.name
#   value                   = var.tenant_id
# }
