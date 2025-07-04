terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.10"
    }
  }
}

# Azure DevOps Project
resource "azuredevops_project" "main" {
  name               = "${var.project_name}-${var.environment}"
  description        = "DevOps project for ${var.project_name} ${var.environment} environment"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  features = {
    "boards"       = "enabled"
    "repositories" = "enabled"
    "pipelines"    = "enabled"
    "testplans"    = "disabled"
    "artifacts"    = "enabled"
  }
}

# Service Connection to Azure Resource Manager
resource "azuredevops_serviceendpoint_azurerm" "main" {
  project_id                             = azuredevops_project.main.id
  service_endpoint_name                  = "Azure-${var.environment}"
  description                           = "Azure Resource Manager connection for ${var.environment}"
  service_endpoint_authentication_scheme = "ServicePrincipal"
  
  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = var.subscription_name
  
  credentials {
    serviceprincipalid  = var.service_principal_id
    serviceprincipalkey = var.service_principal_key
  }
}

# Variable Group for common pipeline variables
resource "azuredevops_variable_group" "main" {
  project_id   = azuredevops_project.main.id
  name         = "${var.project_name}-${var.environment}-variables"
  description  = "Common variables for ${var.project_name} ${var.environment} pipelines"
  allow_access = true

  variable {
    name  = "AZURE_SUBSCRIPTION_ID"
    value = var.subscription_id
  }

  variable {
    name  = "RESOURCE_GROUP_NAME"
    value = var.resource_group_name
  }

  variable {
    name  = "CONTAINER_REGISTRY_NAME"
    value = var.container_registry_name
  }

  variable {
    name  = "APP_SERVICE_NAME"
    value = var.app_service_name
  }

  variable {
    name  = "DOCKER_IMAGE_NAME"
    value = var.docker_image_name
  }

  variable {
    name  = "ENVIRONMENT"
    value = var.environment
  }

  variable {
    name         = "SERVICE_CONNECTION_NAME"
    value        = azuredevops_serviceendpoint_azurerm.main.service_endpoint_name
    is_secret    = false
  }
}

# Variable Group for secrets
resource "azuredevops_variable_group" "secrets" {
  project_id   = azuredevops_project.main.id
  name         = "${var.project_name}-${var.environment}-secrets"
  description  = "Secret variables for ${var.project_name} ${var.environment} pipelines"
  allow_access = true

  variable {
    name      = "ACR_USERNAME"
    value     = var.acr_admin_username
    is_secret = true
  }

  variable {
    name      = "ACR_PASSWORD"
    value     = var.acr_admin_password
    is_secret = true
  }
}

# GitHub Service Connection (if using GitHub repository)
resource "azuredevops_serviceendpoint_github" "main" {
  count = var.use_github_repo ? 1 : 0
  
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "GitHub-${var.environment}"
  description          = "GitHub connection for ${var.project_name}"
  
  auth_personal {
    personal_access_token = var.github_personal_access_token
  }
  

}

# Git Repository (only create if not using GitHub)
resource "azuredevops_git_repository" "main" {
  count = var.use_github_repo ? 0 : 1
  
  project_id = azuredevops_project.main.id
  name       = var.project_name
  initialization {
    init_type = "Clean"
  }
}

# Build and Deploy Pipeline (created only if YAML files exist)
resource "azuredevops_build_definition" "build_deploy" {
  count = var.create_pipelines ? 1 : 0
  
  project_id = azuredevops_project.main.id
  name       = "${var.project_name}-build-deploy-${var.environment}"
  path       = "\\Pipelines"

  repository {
    repo_type             = var.use_github_repo ? "GitHub" : "TfsGit"
    repo_id               = var.use_github_repo ? var.github_repo_name : azuredevops_git_repository.main[0].id
    branch_name           = var.use_github_repo ? "refs/heads/main" : azuredevops_git_repository.main[0].default_branch
    yml_path              = "pipelines/build-deploy.yml"
    service_connection_id = var.use_github_repo ? azuredevops_serviceendpoint_github.main[0].id : null
  }

  variable_groups = [
    azuredevops_variable_group.main.id,
    azuredevops_variable_group.secrets.id
  ]

  # Enable CI triggers
  queue_status = "enabled"
  
  ci_trigger {
    use_yaml = true
  }
  
  depends_on = [
    azuredevops_git_repository.main,
    azuredevops_serviceendpoint_github.main
  ]
}

# Grant pipeline access to GitHub service connection for rollback
resource "azuredevops_pipeline_authorization" "github_rollback" {
  count = var.use_github_repo && var.create_pipelines ? 1 : 0
  
  project_id  = azuredevops_project.main.id
  resource_id = azuredevops_serviceendpoint_github.main[0].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.rollback[0].id
  
  depends_on = [azuredevops_build_definition.rollback]
}


# Grant pipeline access to GitHub service connection
resource "azuredevops_pipeline_authorization" "github_build_deploy" {
  count = var.use_github_repo && var.create_pipelines ? 1 : 0
  
  project_id  = azuredevops_project.main.id
  resource_id = azuredevops_serviceendpoint_github.main[0].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.build_deploy[0].id
  
  depends_on = [azuredevops_build_definition.build_deploy]
}
# Rollback Pipeline (created only if YAML files exist)
resource "azuredevops_build_definition" "rollback" {
  count = var.create_pipelines ? 1 : 0
  
  project_id = azuredevops_project.main.id
  name       = "${var.project_name}-rollback-${var.environment}"
  path       = "\\Pipelines"

  repository {
    repo_type             = var.use_github_repo ? "GitHub" : "TfsGit"
    repo_id               = var.use_github_repo ? var.github_repo_name : azuredevops_git_repository.main[0].id
    branch_name           = var.use_github_repo ? "refs/heads/main" : azuredevops_git_repository.main[0].default_branch
    yml_path              = "pipelines/rollback.yml"
    service_connection_id = var.use_github_repo ? azuredevops_serviceendpoint_github.main[0].id : null
  }

  variable_groups = [
    azuredevops_variable_group.main.id,
    azuredevops_variable_group.secrets.id
  ]

  variable {
    name           = "TARGET_VERSION"
    value          = ""
    allow_override = true
  }

  queue_status = "enabled"
  
  depends_on = [
    azuredevops_git_repository.main,
    azuredevops_serviceendpoint_github.main
  ]
}