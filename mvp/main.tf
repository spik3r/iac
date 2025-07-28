terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  
  # Optional: Use service principal if provided in secrets.tfvars
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

# Data source for current Azure client configuration
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Networking Module
module "networking" {
  source = "../modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  name_prefix        = var.name_prefix
  vnet_address_space = var.vnet_address_space[0]
  
  tags = local.common_tags
}

# Container Registry Module
module "container_registry" {
  source = "../modules/container-registry"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  registry_name      = replace("${var.name_prefix}acr", "-", "")  # ACR names can't have hyphens
  sku                = var.container_registry_sku
  
  tags = local.common_tags
}

# Application Insights Module
module "application_insights" {
  source = "../modules/application-insights"

  resource_group_name            = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  application_insights_name     = "${var.name_prefix}-appinsights"
  log_analytics_workspace_name = "${var.name_prefix}-logs"
  
  tags = local.common_tags
}

# App Service Module
module "app_service" {
  source = "../modules/app-service"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  name_prefix        = var.name_prefix
  
  # App Service Plan configuration
  sku_name = var.app_service_plan_sku
  
  # Container configuration
  docker_registry_url = "https://${module.container_registry.login_server}"
  docker_image       = "${var.docker_image_name}:${var.docker_image_tag}"
  
  # Networking
  subnet_id = var.enable_vnet_integration ? module.networking.app_subnet_id : null
  enable_vnet_integration = var.enable_vnet_integration
  
  # Container registry credentials (if using external registry)
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
  
  # App settings including Application Insights and secrets
  app_settings = merge(
    var.additional_app_settings,
    var.api_keys,
    {
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.application_insights.connection_string
      "ApplicationInsights__ConnectionString" = module.application_insights.connection_string
      "APPINSIGHTS_INSTRUMENTATIONKEY" = module.application_insights.instrumentation_key
    },
    var.database_connection_string != null ? {
      "ConnectionStrings__DefaultConnection" = var.database_connection_string
    } : {}
  )
  
  tags = local.common_tags
}

# Role assignment for App Service to pull from ACR
resource "azurerm_role_assignment" "app_service_acr_pull" {
  scope                = module.container_registry.registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.app_service.principal_id
}

# Local values for common tags
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}