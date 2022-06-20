terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.10.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.23.0"
    }
  }
}

module "rg-automation-poc" {
  source             = "./modules/resource_group"
  name_suffix        = "automation"
  location           = var.location
  full_env_code      = local.full_env_code
  create             = true
  enable_delete_lock = false
}

module "logs" {
  source = "./modules/log_analytics"

  dep_generic_map = local.dep_generic_map
  logs_config_map = local.main_logs_config_map

  resource_group_name = module.rg-automation-poc.name
  depends_on = [
    module.rg-automation-poc
  ]
}

module "service_principal" {
  source = "./modules/azure_ad_sp"

  dep_generic_map = local.dep_generic_map
  sp_config_map   = local.main_sp_config_map

  resource_group_name = module.rg-automation-poc.name
  depends_on = [
    module.rg-automation-poc
  ]
}

module "runbook_expiration" {
  source = "./modules/automation_runbook"

  dep_generic_map    = local.dep_generic_map
  runbook_config_map = local.expiration_runbook_config_map

  automation_account_name = module.automation_account.name
  resource_group_name     = module.rg-automation-poc.name
  schedule_name           = module.automation_account.schedule_name
  script_content          = data.local_file.pwsh_script_expiration.content
}

module "runbook_audit" {
  source = "./modules/automation_runbook"

  dep_generic_map    = local.dep_generic_map
  runbook_config_map = local.audit_runbook_config_map

  automation_account_name = module.automation_account.name
  resource_group_name     = module.rg-automation-poc.name
  schedule_name           = module.automation_account.schedule_name
  script_content          = data.local_file.pwsh_script_audit.content
}



module "automation_account" {
  source = "./modules/automation_account"

  dep_generic_map = local.dep_generic_map
  aa_config_map   = local.main_aa_config_map

  resource_group_name = module.rg-automation-poc.name
  sp_username         = module.service_principal.sp_username
  sp_password         = module.service_principal.sp_password

  depends_on = [
    module.rg-automation-poc
  ]
}

module "automation_variable_workspace_id" {
  source = "./modules/automation_variables"

  resource_group_name     = module.rg-automation-poc.name
  name                    = "workspace_id"
  automation_account_name = module.automation_account.name
  value                   = module.logs.workspace_id
  encrypted               = false
}

module "automation_variable_workspace_key" {
  source = "./modules/automation_variables"

  resource_group_name     = module.rg-automation-poc.name
  name                    = "workspace_key"
  automation_account_name = module.automation_account.name
  value                   = module.logs.workspace_key
  encrypted               = true
}

module "automation_variable_tenant_id" {
  source = "./modules/automation_variables"

  resource_group_name     = module.rg-automation-poc.name
  name                    = "tenant_id"
  automation_account_name = module.automation_account.name
  value                   = data.azurerm_client_config.current.tenant_id
  encrypted               = false
}

module "action_group_1" {
  source = "./modules/monitor_action_groups"

  dep_generic_map         = local.dep_generic_map
  action_group_config_map = local.action_group_config_map

  resource_group_name = module.rg-automation-poc.name
}

module "alert_sp_expiration" {
  source = "./modules/monitor_alerts"

  dep_generic_map     = local.dep_generic_map
  alerts_config_map   = local.alerts_config_map
  action_group_ids    = [ module.action_group_1.id ]
  log_analytics_id    = module.logs.id
  resource_group_name = module.rg-automation-poc.name
}
