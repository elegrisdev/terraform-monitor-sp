variable "service_name" {}
variable "location" {}
variable "environment_code" {
  description = "Environment code"
}
variable "location_code" {
  description = "Location code"
}

variable "aa_config_map" {
  type    = map(any)
  default = {}
}

variable "logs_config_map" {
  type    = map(any)
  default = {}
}

variable "action_group_config_map" {
  type    = map(any)
  default = {}
}

variable "alerts_config_map" {
  type    = map(any)
  default = {}
}

variable "sp_config_map" {
  type    = map(any)
  default = {}
}

variable "runbook_config_map" {
  type    = map(any)
  default = {}
}
