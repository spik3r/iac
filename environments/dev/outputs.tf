output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = module.app_service.app_service_url
}

output "container_registry_login_server" {
  description = "Login server for the container registry"
  value       = module.container_registry.login_server
}

output "container_registry_name" {
  description = "Name of the container registry"
  value       = module.container_registry.registry_name
}