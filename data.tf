data "azuread_client_config" "current" {}

data "azurerm_client_config" "current" {}

data "local_file" "pwsh_script_audit" {
  filename = "./scripts/Post-ServicePrincipals-Audit.ps1"
}

data "local_file" "pwsh_script_expiration" {
  filename = "./scripts/Post-ServicePrincipals-Report.ps1"
}

