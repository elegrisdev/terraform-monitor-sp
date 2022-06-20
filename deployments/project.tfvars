location = "Canada Central"

environment_code = "poc"
service_name     = "automation"
location_code    = "canadacentral"

aa_config_map = {
  project = {
    sku_name             = "Basic"
    schedule_name        = "daily"
    schedule_frequency   = "Day"
    schedule_interval    = 1
    schedule_timezone    = "America/Toronto"
    schedule_start_time  = "2022-06-30T01:00:00-04:00"
    schedule_description = "Daily Schedule"
    credential_name      = "AzureMonitor"
  }
}

logs_config_map = {
  project = {
    sku               = "PerGB2018"
    retention_in_days = 30
  }
}

action_group_config_map = {
  action_group_1 = {
    name                   = "Automation-POC"
    short_name             = "Automation-POC"
    email_receiver_name    = "User"
    email_receiver_address = "email@email.com"
  }
}

alerts_config_map = {
  alert_sp_expiration = {
    name              = "App Registration Expiry Notification"
    email_subject     = "App Registration Expiry Notification"
    enabled           = true
    query             = <<-QUERY
                        AppRegistrationExpiration_CL
                        | summarize arg_max(TimeGenerated, *) by KeyId_g
                        | where DaysToExpiration_d <= 60 
                        | where TimeGenerated > ago(2d)
                        | project
                            TimeGenerated,
                            DisplayName_s,
                            ApplicationId_g,
                            KeyId_g,
                            Type_s,
                            StartDate_value_t,
                            EndDate_value_t,
                            Status_s,
                            DaysToExpiration_d
                        QUERY
    severity          = 1
    frequency         = 1440
    time_window       = 1440
    trigger_operator  = "GreaterThan"
    trigger_threshold = 0
  }
}

sp_config_map = {
  project = {
    display_name     = "AppRegistrationMonitoring"
    sign_in_audience = "AzureADMyOrg"
  }
}

runbook_config_map = {
  expiration = {
    name = "expiration"
  }
  audit = {
    name = "audit"
  }
}

