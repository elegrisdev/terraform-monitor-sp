resource "azurerm_automation_account" "aa" {
  name                = format("aa-%s-%s", lower(var.dep_generic_map.service_name), lower(var.dep_generic_map.full_env_code))
  location            = var.dep_generic_map.location
  resource_group_name = var.resource_group_name
  sku_name            = var.aa_config_map.sku_name
}

resource "azurerm_automation_module" "module_msal" {
  name                    = "MSAL.PS"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.aa.name

  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/msal.ps.4.37.0.nupkg"
  }
}

resource "azurerm_automation_credential" "credentials" {
  automation_account_name = azurerm_automation_account.aa.name
  resource_group_name     = var.resource_group_name
  name                    = var.aa_config_map.credential_name
  username                = var.sp_username  # azuread_application.app.application_id
  password                = var.sp_password # azuread_application_password.app_password.value
}

resource "azurerm_automation_schedule" "schedule_daily" {
  name                    = var.aa_config_map.schedule_name
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.aa.name
  frequency               = var.aa_config_map.schedule_frequency
  interval                = var.aa_config_map.schedule_interval
  timezone                = var.aa_config_map.schedule_timezone
  start_time              = var.aa_config_map.schedule_start_time
  description             = var.aa_config_map.schedule_description
}