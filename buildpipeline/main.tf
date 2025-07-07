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

  backend "azurerm" {
    # Backend configuration will be provided via backend config file
    # or command line arguments during terraform init
  }
}

# Provider for iac-admin subscription (where ACR and pipelines live)
provider "azurerm" {
  alias           = "admin"
  subscription_id = var.admin_subscription_id
  features {}
}

# Provider for target environments (dev, uat, prod)
provider "azurerm" {
  alias           = "target"
  subscription_id = var.target_subscription_id
  features {}
}

provider "azuredevops" {
  org_service_url       = var.azuredevops_org_service_url
  personal_access_token = var.azuredevops_personal_access_token
}

locals {
  name_prefix = "${var.project_name}-admin"
  
  common_tags = {
    Environment = "admin"
    Project     = var.project_name
    ManagedBy   = "terraform"
    Purpose     = "build-pipeline"
  }
}

# Resource Group for admin infrastructure
resource "azurerm_resource_group" "admin" {
  provider = azurerm.admin
  name     = "${local.name_prefix}-rg"
  location = var.location

  tags = local.common_tags
}

# Admin Container Registry (central registry for all environments)
resource "azurerm_container_registry" "admin" {
  provider            = azurerm.admin
  name                = "${var.project_name}acradmin"
  resource_group_name = azurerm_resource_group.admin.name
  location            = azurerm_resource_group.admin.location
  sku                 = var.admin_acr_sku
  admin_enabled       = true

  # Enable geo-replication for better performance across regions
  dynamic "georeplications" {
    for_each = var.admin_acr_geo_replications
    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
    }
  }

  tags = local.common_tags
}

# Azure DevOps Project for build pipelines
resource "azuredevops_project" "build" {
  name               = "${var.project_name}-build"
  description        = "Build and deployment pipelines for ${var.project_name}"
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

# Service Connection to Admin Subscription (for ACR operations)
resource "azuredevops_serviceendpoint_azurerm" "admin" {
  project_id                             = azuredevops_project.build.id
  service_endpoint_name                  = "Azure-Admin"
  description                           = "Azure Resource Manager connection for admin subscription"
  service_endpoint_authentication_scheme = "ServicePrincipal"
  
  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.admin_subscription_id
  azurerm_subscription_name = var.admin_subscription_name
  
  credentials {
    serviceprincipalid  = var.admin_service_principal_id
    serviceprincipalkey = var.admin_service_principal_key
  }
}

# Service Connection to Target Subscription (for environment deployments)
resource "azuredevops_serviceendpoint_azurerm" "target" {
  project_id                             = azuredevops_project.build.id
  service_endpoint_name                  = "Azure-Target"
  description                           = "Azure Resource Manager connection for target environments"
  service_endpoint_authentication_scheme = "ServicePrincipal"
  
  azurerm_spn_tenantid      = var.tenant_id
  azurerm_subscription_id   = var.target_subscription_id
  azurerm_subscription_name = var.target_subscription_name
  
  credentials {
    serviceprincipalid  = var.target_service_principal_id
    serviceprincipalkey = var.target_service_principal_key
  }
}

# GitHub Service Connection
resource "azuredevops_serviceendpoint_github" "main" {
  count = var.use_github_repo ? 1 : 0
  
  project_id            = azuredevops_project.build.id
  service_endpoint_name = "GitHub-Build"
  description          = "GitHub connection for ${var.project_name} build pipelines"
  
  auth_personal {
    personal_access_token = var.github_personal_access_token
  }
}

# Variable Group for Admin/Build variables
resource "azuredevops_variable_group" "admin" {
  project_id   = azuredevops_project.build.id
  name         = "${var.project_name}-admin-variables"
  description  = "Admin subscription variables for build pipelines"
  allow_access = true

  variable {
    name  = "ADMIN_SUBSCRIPTION_ID"
    value = var.admin_subscription_id
  }

  variable {
    name  = "ADMIN_RESOURCE_GROUP_NAME"
    value = azurerm_resource_group.admin.name
  }

  variable {
    name  = "ADMIN_CONTAINER_REGISTRY_NAME"
    value = azurerm_container_registry.admin.name
  }

  variable {
    name  = "ADMIN_SERVICE_CONNECTION_NAME"
    value = azuredevops_serviceendpoint_azurerm.admin.service_endpoint_name
  }

  variable {
    name  = "TARGET_SERVICE_CONNECTION_NAME"
    value = azuredevops_serviceendpoint_azurerm.target.service_endpoint_name
  }

  variable {
    name  = "DOCKER_IMAGE_NAME"
    value = var.docker_image_name
  }

  variable {
    name  = "PROJECT_NAME"
    value = var.project_name
  }
}

# Variable Group for Admin secrets
resource "azuredevops_variable_group" "admin_secrets" {
  project_id   = azuredevops_project.build.id
  name         = "${var.project_name}-admin-secrets"
  description  = "Secret variables for admin build pipelines"
  allow_access = true

  variable {
    name      = "ADMIN_ACR_USERNAME"
    value     = azurerm_container_registry.admin.admin_username
    is_secret = true
  }

  variable {
    name      = "ADMIN_ACR_PASSWORD"
    value     = azurerm_container_registry.admin.admin_password
    is_secret = true
  }
}

# Variable Group for Target Environment variables (will be used by deployment pipelines)
resource "azuredevops_variable_group" "target_dev" {
  project_id   = azuredevops_project.build.id
  name         = "${var.project_name}-dev-variables"
  description  = "Development environment variables"
  allow_access = true

  variable {
    name  = "TARGET_SUBSCRIPTION_ID"
    value = var.target_subscription_id
  }

  variable {
    name  = "DEV_RESOURCE_GROUP_NAME"
    value = var.dev_resource_group_name
  }

  variable {
    name  = "DEV_CONTAINER_REGISTRY_NAME"
    value = var.dev_container_registry_name
  }

  variable {
    name  = "DEV_APP_SERVICE_NAME"
    value = var.dev_app_service_name
  }

  variable {
    name  = "ENVIRONMENT"
    value = "dev"
  }
}

# Build and Deploy Pipeline
resource "azuredevops_build_definition" "build_deploy" {
  count = var.create_pipelines ? 1 : 0
  
  project_id = azuredevops_project.build.id
  name       = "${var.project_name}-build-deploy"
  path       = "\\Build"

  repository {
    repo_type             = var.use_github_repo ? "GitHub" : "TfsGit"
    repo_id               = var.github_repo_name
    branch_name           = "refs/heads/main"
    yml_path              = "buildpipeline/pipelines/build-deploy.yml"
    service_connection_id = var.use_github_repo ? azuredevops_serviceendpoint_github.main[0].id : null
  }

  variable_groups = [
    azuredevops_variable_group.admin.id,
    azuredevops_variable_group.admin_secrets.id,
    azuredevops_variable_group.target_dev.id
  ]

  queue_status = "enabled"
  
  ci_trigger {
    use_yaml = true
  }
}

# PR Pipeline
resource "azuredevops_build_definition" "pr" {
  count = var.create_pipelines ? 1 : 0
  
  project_id = azuredevops_project.build.id
  name       = "${var.project_name}-pr"
  path       = "\\Build"

  repository {
    repo_type             = var.use_github_repo ? "GitHub" : "TfsGit"
    repo_id               = var.github_repo_name
    branch_name           = "refs/heads/main"
    yml_path              = "buildpipeline/pipelines/pr.yml"
    service_connection_id = var.use_github_repo ? azuredevops_serviceendpoint_github.main[0].id : null
  }

  variable_groups = [
    azuredevops_variable_group.admin.id,
    azuredevops_variable_group.admin_secrets.id,
    azuredevops_variable_group.target_dev.id
  ]

  queue_status = "enabled"
  
  pr_trigger {
    use_yaml = true
  }
}

# Deploy Pipeline (for deploying existing versions)
resource "azuredevops_build_definition" "deploy" {
  count = var.create_pipelines ? 1 : 0
  
  project_id = azuredevops_project.build.id
  name       = "${var.project_name}-deploy"
  path       = "\\Deploy"

  repository {
    repo_type             = var.use_github_repo ? "GitHub" : "TfsGit"
    repo_id               = var.github_repo_name
    branch_name           = "refs/heads/main"
    yml_path              = "buildpipeline/pipelines/deploy.yml"
    service_connection_id = var.use_github_repo ? azuredevops_serviceendpoint_github.main[0].id : null
  }

  variable_groups = [
    azuredevops_variable_group.admin.id,
    azuredevops_variable_group.admin_secrets.id,
    azuredevops_variable_group.target_dev.id
  ]

  variable {
    name           = "TARGET_VERSION"
    value          = ""
    allow_override = true
  }

  variable {
    name           = "TARGET_ENVIRONMENT"
    value          = "dev"
    allow_override = true
  }

  queue_status = "enabled"
}

# Grant pipeline access to service connections
resource "azuredevops_pipeline_authorization" "admin_build_deploy" {
  count = var.use_github_repo && var.create_pipelines ? 1 : 0
  
  project_id  = azuredevops_project.build.id
  resource_id = azuredevops_serviceendpoint_azurerm.admin.id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.build_deploy[0].id
}

resource "azuredevops_pipeline_authorization" "target_build_deploy" {
  count = var.use_github_repo && var.create_pipelines ? 1 : 0
  
  project_id  = azuredevops_project.build.id
  resource_id = azuredevops_serviceendpoint_azurerm.target.id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.build_deploy[0].id
}

resource "azuredevops_pipeline_authorization" "github_build_deploy" {
  count = var.use_github_repo && var.create_pipelines ? 1 : 0
  
  project_id  = azuredevops_project.build.id
  resource_id = azuredevops_serviceendpoint_github.main[0].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.build_deploy[0].id
}

# Similar authorizations for PR pipeline
resource "azuredevops_pipeline_authorization" "github_pr" {
  count = var.use_github_repo && var.create_pipelines ? 1 : 0
  
  project_id  = azuredevops_project.build.id
  resource_id = azuredevops_serviceendpoint_github.main[0].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.pr[0].id
}

# Similar authorizations for deploy pipeline
resource "azuredevops_pipeline_authorization" "github_deploy" {
  count = var.use_github_repo && var.create_pipelines ? 1 : 0
  
  project_id  = azuredevops_project.build.id
  resource_id = azuredevops_serviceendpoint_github.main[0].id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.deploy[0].id
}