output "name" {
  value = azurerm_automation_account.aa.name
}

output "schedule_name" {
  value = azurerm_automation_schedule.schedule_daily.name
}