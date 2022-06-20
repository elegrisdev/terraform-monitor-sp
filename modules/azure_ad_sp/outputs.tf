output "sp_username" {
  value = azuread_application.app.application_id
}

output "sp_password" {
  value =  azuread_application_password.app_password.value
}