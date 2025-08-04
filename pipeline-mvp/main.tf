terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 0.11.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url       = var.azuredevops_org_service_url
  personal_access_token = var.azuredevops_personal_access_token
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Create Azure DevOps Project
resource "azuredevops_project" "main" {
  name               = var.project_name
  description        = "DevOps project for ${var.project_name} - MVP setup"
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

# Create Azure Service Connection for the dev environment
resource "azuredevops_serviceendpoint_azurerm" "dev" {
  project_id                             = azuredevops_project.main.id
  service_endpoint_name                  = "${var.project_name}-dev-connection"
  description                           = "Azure service connection for dev environment"
  service_endpoint_authentication_scheme = "ServicePrincipal"
  
  credentials {
    serviceprincipalid  = var.service_principal_id
    serviceprincipalkey = var.service_principal_key
  }
  
  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.subscription_id
  azurerm_subscription_name = var.subscription_name
}

# Create GitHub Service Connection
resource "azuredevops_serviceendpoint_github" "main" {
  project_id            = azuredevops_project.main.id
  service_endpoint_name = "${var.project_name}-github-connection"
  description          = "GitHub service connection for ${var.project_name}"
  
  auth_personal {
    personal_access_token = var.github_personal_access_token
  }
}

# Create Variable Group for Dev Environment
resource "azuredevops_variable_group" "dev" {
  project_id   = azuredevops_project.main.id
  name         = "${var.project_name}-dev-variables"
  description  = "Variables for dev environment"
  allow_access = true

  variable {
    name  = "AZURE_SUBSCRIPTION_ID"
    value = var.subscription_id
  }

  variable {
    name  = "RESOURCE_GROUP_NAME"
    value = var.dev_resource_group_name
  }

  variable {
    name  = "CONTAINER_REGISTRY_NAME"
    value = var.dev_container_registry_name
  }

  variable {
    name  = "APP_SERVICE_NAME"
    value = var.dev_app_service_name
  }

  variable {
    name  = "DOCKER_IMAGE_NAME"
    value = var.docker_image_name
  }

  variable {
    name  = "ENVIRONMENT"
    value = "dev"
  }
}

# Create Variable Group for Secrets
resource "azuredevops_variable_group" "secrets" {
  project_id   = azuredevops_project.main.id
  name         = "${var.project_name}-secrets"
  description  = "Secret variables for pipelines"
  allow_access = true

  variable {
    name         = "SERVICE_PRINCIPAL_ID"
    secret_value = var.service_principal_id
    is_secret    = true
  }

  variable {
    name         = "SERVICE_PRINCIPAL_KEY"
    secret_value = var.service_principal_key
    is_secret    = true
  }

  variable {
    name         = "TENANT_ID"
    secret_value = var.tenant_id
    is_secret    = true
  }
}

# Create Build Pipeline
resource "azuredevops_build_definition" "build_deploy" {
  count      = var.create_pipelines ? 1 : 0
  project_id = azuredevops_project.main.id
  name       = "${var.project_name}-build-deploy"
  path       = "\\${var.project_name}"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type               = "GitHub"
    repo_id                 = var.git_repository_url
    branch_name            = "refs/heads/main"
    yml_path               = "azure-pipelines.yml"
    service_connection_id  = azuredevops_serviceendpoint_github.main.id
  }

  variable_groups = [
    azuredevops_variable_group.dev.id,
    azuredevops_variable_group.secrets.id
  ]
}

# Grant pipeline permissions to service connections
resource "azuredevops_pipeline_authorization" "azure_connection" {
  count       = var.create_pipelines ? 1 : 0
  project_id  = azuredevops_project.main.id
  resource_id = azuredevops_serviceendpoint_azurerm.dev.id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.build_deploy[0].id
}

resource "azuredevops_pipeline_authorization" "github_connection" {
  count       = var.create_pipelines ? 1 : 0
  project_id  = azuredevops_project.main.id
  resource_id = azuredevops_serviceendpoint_github.main.id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.build_deploy[0].id
}

# Local values for common tags
locals {
  common_tags = {
    Environment = "dev"
    Project     = var.project_name
    ManagedBy   = "terraform"
    Purpose     = "pipeline-mvp"
  }
}