variable "dep_generic_map" {
  type = map(any)
}

variable "logs_config_map" {
    type = map(any)
}

variable "resource_group_name" {
  description = "Azure resource group name"
}