# Resource Group
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# App Service
output "app_service_name" {
  description = "Name of the App Service"
  value       = module.app_service.app_service_name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = module.app_service.app_service_url
}

output "app_service_principal_id" {
  description = "Principal ID of the App Service managed identity"
  value       = module.app_service.principal_id
}

# Container Registry
output "container_registry_name" {
  description = "Name of the container registry"
  value       = module.container_registry.registry_name
}

output "container_registry_login_server" {
  description = "Login server of the container registry"
  value       = module.container_registry.login_server
}

# Application Insights
output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = module.application_insights.application_insights_name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.application_insights.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.application_insights.connection_string
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.application_insights.log_analytics_workspace_name
}

# Networking
output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "app_service_subnet_id" {
  description = "ID of the App Service subnet"
  value       = module.networking.app_subnet_id
}