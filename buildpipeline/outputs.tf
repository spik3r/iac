output "admin_resource_group_name" {
  description = "Name of the admin resource group"
  value       = azurerm_resource_group.admin.name
}

output "admin_container_registry_name" {
  description = "Name of the admin container registry"
  value       = azurerm_container_registry.admin.name
}

output "admin_container_registry_login_server" {
  description = "Login server URL of the admin container registry"
  value       = azurerm_container_registry.admin.login_server
}

output "admin_container_registry_id" {
  description = "ID of the admin container registry"
  value       = azurerm_container_registry.admin.id
}

output "devops_project_id" {
  description = "ID of the Azure DevOps project"
  value       = azuredevops_project.build.id
}

output "devops_project_name" {
  description = "Name of the Azure DevOps project"
  value       = azuredevops_project.build.name
}

output "admin_service_connection_id" {
  description = "ID of the admin Azure service connection"
  value       = azuredevops_serviceendpoint_azurerm.admin.id
}

output "target_service_connection_id" {
  description = "ID of the target Azure service connection"
  value       = azuredevops_serviceendpoint_azurerm.target.id
}

output "github_service_connection_id" {
  description = "ID of the GitHub service connection"
  value       = var.use_github_repo ? azuredevops_serviceendpoint_github.main[0].id : null
}

output "build_deploy_pipeline_id" {
  description = "ID of the build-deploy pipeline"
  value       = var.create_pipelines ? azuredevops_build_definition.build_deploy[0].id : null
}

output "pr_pipeline_id" {
  description = "ID of the PR pipeline"
  value       = var.create_pipelines ? azuredevops_build_definition.pr[0].id : null
}

output "deploy_pipeline_id" {
  description = "ID of the deploy pipeline"
  value       = var.create_pipelines ? azuredevops_build_definition.deploy[0].id : null
}