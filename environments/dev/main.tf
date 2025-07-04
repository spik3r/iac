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

provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url       = var.azuredevops_org_service_url
  personal_access_token = var.azuredevops_personal_access_token
}

locals {
  environment = "dev"
  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = var.location

  tags = local.common_tags
}

module "networking" {
  source = "../../modules/networking"

  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  vnet_address_space        = var.vnet_address_space
  app_subnet_address_prefix = var.app_subnet_address_prefix
  pe_subnet_address_prefix  = var.pe_subnet_address_prefix

  tags = local.common_tags
}

module "container_registry" {
  source = "../../modules/container-registry"

  registry_name       = "${var.project_name}acr${local.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled

  tags = local.common_tags
}

module "app_service" {
  source = "../../modules/app-service"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  sku_name            = var.app_service_sku

  docker_image             = var.docker_image
  docker_registry_url      = "https://${module.container_registry.login_server}"
  docker_registry_username = null
  docker_registry_password = null

  subnet_id               = module.networking.app_subnet_id
  enable_vnet_integration = true

  app_settings = merge(var.app_settings, {
    ASPNETCORE_ENVIRONMENT = "Development"
    PORT                   = "80"
  })

  always_on               = var.app_service_always_on
  detailed_error_messages = true
  failed_request_tracing  = true
  application_logs_level  = "Information"

  tags = local.common_tags
}

# Grant the App Service managed identity access to pull from ACR
resource "azurerm_role_assignment" "app_service_acr_pull" {
  scope                = module.container_registry.registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.app_service.principal_id
}

data "azurerm_client_config" "current" {}

# DevOps Pipeline Module (optional - only deploy if DevOps variables are provided)
module "devops_pipeline" {
  count  = var.enable_devops_pipeline ? 1 : 0
  source = "../../modules/devops-pipeline"

  project_name = var.project_name
  environment  = local.environment
  location     = var.location
  tags         = local.common_tags

  subscription_id   = data.azurerm_client_config.current.subscription_id
  subscription_name = var.azure_subscription_name
  tenant_id         = data.azurerm_client_config.current.tenant_id

  service_principal_id  = var.devops_service_principal_id
  service_principal_key = var.devops_service_principal_key

  resource_group_name     = azurerm_resource_group.main.name
  container_registry_name = module.container_registry.registry_name
  app_service_name        = module.app_service.app_service_name

  acr_admin_username = module.container_registry.admin_username
  acr_admin_password = module.container_registry.admin_password

  min_reviewers          = var.devops_min_reviewers
  create_pipelines       = var.devops_create_pipelines
  
  # GitHub Integration
  use_github_repo              = var.devops_use_github_repo
  github_repo_name             = var.github_repo_name
  github_repo_id               = var.github_repo_name  # For most cases, repo_id can be same as repo_name
  github_personal_access_token = var.github_personal_access_token
}
