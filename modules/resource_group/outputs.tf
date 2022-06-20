output "id" {
  value = element(concat(azurerm_resource_group.rg.*.id, tolist([""])), 0)
}

output "name" {
  value = format("rg-%s-%s", lower(var.name_suffix), lower(var.full_env_code))
}

output "location" {
  value = element(concat(azurerm_resource_group.rg.*.location, tolist([""])), 0)
}