data "azuread_client_config" "current" {}

resource "azuread_application" "app" {
  display_name     = var.sp_config_map.display_name
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = var.sp_config_map.sign_in_audience

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "b0afded3-3588-46d8-8b3d-9842eff778da"
      type = "Role"
    }

    resource_access {
      id   = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30"
      type = "Role"
    }
  }
}

resource "azuread_application_password" "app_password" {
  application_object_id = azuread_application.app.id
}

resource "azuread_service_principal" "service_principal" {
  application_id               = azuread_application.app.application_id
  owners                       = [data.azuread_client_config.current.object_id]
  app_role_assignment_required = false
}
