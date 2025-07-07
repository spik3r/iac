output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = azurerm_application_insights.main.id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.main.name
}

output "instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "Connection string for Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "app_id" {
  description = "Application ID for Application Insights"
  value       = azurerm_application_insights.main.app_id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_primary_shared_key" {
  description = "Primary shared key for Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "action_group_id" {
  description = "ID of the action group (if created)"
  value       = var.create_action_group ? azurerm_monitor_action_group.main[0].id : null
}

output "availability_test_id" {
  description = "ID of the availability test (if created)"
  value       = var.create_availability_test ? azurerm_application_insights_web_test.main[0].id : null
}