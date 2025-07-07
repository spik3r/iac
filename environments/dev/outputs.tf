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

# DevOps Outputs (only available if DevOps pipeline is enabled)
output "devops_project_name" {
  description = "Name of the Azure DevOps project"
  value       = var.enable_devops_pipeline ? module.devops_pipeline[0].devops_project_name : null
}

output "devops_project_url" {
  description = "URL of the Azure DevOps project"
  value       = var.enable_devops_pipeline ? "${var.azuredevops_org_service_url}/${module.devops_pipeline[0].devops_project_name}" : null
}

output "git_repository_url" {
  description = "URL of the Git repository"
  value       = var.enable_devops_pipeline ? module.devops_pipeline[0].git_repository_url : null
}

output "build_deploy_pipeline_id" {
  description = "ID of the build and deploy pipeline"
  value       = var.enable_devops_pipeline ? module.devops_pipeline[0].build_deploy_pipeline_id : null
}

output "rollback_pipeline_id" {
  description = "ID of the rollback pipeline"
  value       = var.enable_devops_pipeline ? module.devops_pipeline[0].rollback_pipeline_id : null
}

# Application Insights Outputs
output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = module.application_insights.application_insights_name
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.application_insights.connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.application_insights.instrumentation_key
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = module.application_insights.log_analytics_workspace_name
}