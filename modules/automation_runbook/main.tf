resource "azurerm_automation_runbook" "runbook" {
  name                    = format("runbook-%s-%s-%s", lower(var.dep_generic_map.service_name), lower(var.dep_generic_map.full_env_code), lower(var.runbook_config_map.name))
  location                = var.dep_generic_map.location
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  log_progress            = "true"
  log_verbose             = "true"
  description             = "PowerShell runbook for Service Principal automation"
  runbook_type            = "PowerShell"

  content = var.script_content

}

resource "azurerm_automation_job_schedule" "runbook_schedule" {
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  schedule_name           = var.schedule_name
  runbook_name            = azurerm_automation_runbook.runbook.name
}
