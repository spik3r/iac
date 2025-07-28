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