variable "dep_generic_map" {
  type = map(any)
}

variable "alerts_config_map" {
    type = map(any)
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "action_group_ids" {
  type = set(string)
}

variable "log_analytics_id" {
  
}