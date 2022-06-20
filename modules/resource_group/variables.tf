variable "full_env_code" {
  description = "Environment code name"
}

variable "location" {
  description = "Location in which to deploy resources"
}

variable "destroy_resource_groups" {
  description = "Force delete the resource group if locked"
  default     = false
}

variable "create" {
  description = "Creation Flag"
  type        = bool
  default     = false
}

variable "enable_delete_lock" {
  description = "Enable or disable resource group lock"
}

variable "name_suffix" {
  description = "Name to append to the full_env_code. "
}

variable "tags" {
  default = {}
}