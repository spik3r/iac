# Core Configuration
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "vibes"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Australia East"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "vibes-dev"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "vibes-dev-rg"
}

# Networking Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "enable_vnet_integration" {
  description = "Enable VNet integration for App Service"
  type        = bool
  default     = true
}

# Container Registry Configuration
variable "container_registry_sku" {
  description = "SKU for the container registry"
  type        = string
  default     = "Basic"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.container_registry_sku)
    error_message = "Container registry SKU must be Basic, Standard, or Premium."
  }
}

# App Service Configuration
variable "app_service_plan_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "B1"
}

variable "docker_image_name" {
  description = "Name of the Docker image"
  type        = string
  default     = "vibes-app"
}

variable "docker_image_tag" {
  description = "Tag of the Docker image"
  type        = string
  default     = "latest"
}

variable "additional_app_settings" {
  description = "Additional app settings for the App Service"
  type        = map(string)
  default     = {}
}

# Optional secrets (can be provided via secrets.tfvars)
variable "client_id" {
  description = "Azure Service Principal Client ID (optional)"
  type        = string
  default     = null
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret (optional)"
  type        = string
  default     = null
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID (optional)"
  type        = string
  default     = null
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID (optional)"
  type        = string
  default     = null
  sensitive   = true
}

variable "docker_registry_username" {
  description = "Docker registry username (optional, for external registries)"
  type        = string
  default     = null
  sensitive   = true
}

variable "docker_registry_password" {
  description = "Docker registry password (optional, for external registries)"
  type        = string
  default     = null
  sensitive   = true
}

variable "alert_email_addresses" {
  description = "List of email addresses for alerts (optional)"
  type        = list(string)
  default     = []
}

variable "database_connection_string" {
  description = "Database connection string (optional)"
  type        = string
  default     = null
  sensitive   = true
}

variable "api_keys" {
  description = "Map of API keys and secrets (optional)"
  type        = map(string)
  default     = {}
  sensitive   = true
}