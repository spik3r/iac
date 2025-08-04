# Azure DevOps Project
output "devops_project_id" {
  description = "ID of the Azure DevOps project"
  value       = azuredevops_project.main.id
}

output "devops_project_name" {
  description = "Name of the Azure DevOps project"
  value       = azuredevops_project.main.name
}

output "devops_project_url" {
  description = "URL of the Azure DevOps project"
  value       = "${var.azuredevops_org_service_url}/${azuredevops_project.main.name}"
}

# Service Connections
output "azure_service_connection_id" {
  description = "ID of the Azure service connection"
  value       = azuredevops_serviceendpoint_azurerm.dev.id
}

output "github_service_connection_id" {
  description = "ID of the GitHub service connection"
  value       = var.git_repository_url != "" ? azuredevops_serviceendpoint_github.main[0].id : null
}

# Variable Groups
output "dev_variable_group_id" {
  description = "ID of the dev variable group"
  value       = azuredevops_variable_group.dev.id
}

output "secrets_variable_group_id" {
  description = "ID of the secrets variable group"
  value       = azuredevops_variable_group.secrets.id
}

# Pipeline
output "build_pipeline_id" {
  description = "ID of the build pipeline"
  value       = var.create_pipelines ? azuredevops_build_definition.build_deploy[0].id : null
}

output "build_pipeline_url" {
  description = "URL of the build pipeline"
  value       = var.create_pipelines ? "${var.azuredevops_org_service_url}/${azuredevops_project.main.name}/_build?definitionId=${azuredevops_build_definition.build_deploy[0].id}" : null
}