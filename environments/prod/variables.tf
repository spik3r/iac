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

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.1.0.0/16"
}

variable "app_subnet_address_prefix" {
  description = "Address prefix for the app service subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "pe_subnet_address_prefix" {
  description = "Address prefix for the private endpoints subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "acr_sku" {
  description = "SKU for the container registry"
  type        = string
  default     = "Standard"
}

variable "acr_admin_enabled" {
  description = "Enable admin user for the container registry"
  type        = bool
  default     = false
}

variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "P1v3"
}

variable "app_service_always_on" {
  description = "Keep the app service always on"
  type        = bool
  default     = true
}

variable "docker_image" {
  description = "Docker image name and tag (without registry URL)"
  type        = string
  default     = "vibes-app:latest"
}

variable "app_settings" {
  description = "Additional application settings"
  type        = map(string)
  default     = {}
}