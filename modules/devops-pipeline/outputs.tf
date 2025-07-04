output "devops_project_id" {
  description = "ID of the Azure DevOps project"
  value       = azuredevops_project.main.id
}

output "devops_project_name" {
  description = "Name of the Azure DevOps project"
  value       = azuredevops_project.main.name
}

output "git_repository_id" {
  description = "ID of the Git repository"
  value       = var.use_github_repo ? var.github_repo_name : (length(azuredevops_git_repository.main) > 0 ? azuredevops_git_repository.main[0].id : null)
}

output "git_repository_url" {
  description = "URL of the Git repository"
  value       = var.use_github_repo ? "https://github.com/${var.github_repo_name}" : (length(azuredevops_git_repository.main) > 0 ? azuredevops_git_repository.main[0].remote_url : null)
}

output "github_service_connection_name" {
  description = "Name of the GitHub service connection"
  value       = var.use_github_repo ? azuredevops_serviceendpoint_github.main[0].service_endpoint_name : null
}

output "build_deploy_pipeline_id" {
  description = "ID of the build and deploy pipeline"
  value       = var.create_pipelines ? azuredevops_build_definition.build_deploy[0].id : null
}

output "rollback_pipeline_id" {
  description = "ID of the rollback pipeline"
  value       = var.create_pipelines ? azuredevops_build_definition.rollback[0].id : null
}

output "service_connection_name" {
  description = "Name of the Azure service connection"
  value       = azuredevops_serviceendpoint_azurerm.main.service_endpoint_name
}

output "variable_group_id" {
  description = "ID of the main variable group"
  value       = azuredevops_variable_group.main.id
}

output "secrets_variable_group_id" {
  description = "ID of the secrets variable group"
  value       = azuredevops_variable_group.secrets.id
}