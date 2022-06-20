variable "script_content" {
}

variable "automation_account_name" {
  
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "dep_generic_map" {
  type = map(any)
}

variable "runbook_config_map" {
  type = map(any)
}

variable "schedule_name" {
  
}