locals {

  full_env_code = format("%s-%s", lower(var.location_code), lower(var.environment_code))
  default_tags  = {}

  main_logs_config_map = lookup(var.logs_config_map, "project")
  main_aa_config_map = lookup(var.aa_config_map, "project")
  main_sp_config_map = lookup(var.sp_config_map, "project")
  expiration_runbook_config_map = lookup(var.runbook_config_map, "expiration")
  audit_runbook_config_map = lookup(var.runbook_config_map, "audit")
  action_group_config_map = lookup(var.action_group_config_map, "action_group_1")
  alerts_config_map = lookup(var.alerts_config_map, "alert_sp_expiration")
  

  dep_generic_map = {
    full_env_code = local.full_env_code
    location      = var.location
    service_name  = var.service_name
  }
}
