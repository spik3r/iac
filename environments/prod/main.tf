terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
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

locals {
  environment = "prod"
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
  
  vnet_address_space         = var.vnet_address_space
  app_subnet_address_prefix  = var.app_subnet_address_prefix
  pe_subnet_address_prefix   = var.pe_subnet_address_prefix

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
  
  docker_image            = var.docker_image
  docker_registry_url     = "https://${module.container_registry.login_server}"
  docker_registry_username = var.acr_admin_enabled ? module.container_registry.admin_username : null
  docker_registry_password = var.acr_admin_enabled ? module.container_registry.admin_password : null
  
  subnet_id               = module.networking.app_subnet_id
  enable_vnet_integration = true
  
  app_settings = merge(var.app_settings, {
    ASPNETCORE_ENVIRONMENT = "Production"
  })

  always_on                 = var.app_service_always_on
  detailed_error_messages   = false
  failed_request_tracing    = false
  application_logs_level    = "Warning"

  tags = local.common_tags
}

# Grant the App Service managed identity access to pull from ACR
resource "azurerm_role_assignment" "app_service_acr_pull" {
  scope                = module.container_registry.registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.app_service.principal_id
}