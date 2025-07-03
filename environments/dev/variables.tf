variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "vibes"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_subnet_address_prefix" {
  description = "Address prefix for the app service subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "pe_subnet_address_prefix" {
  description = "Address prefix for the private endpoints subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "acr_sku" {
  description = "SKU for the container registry"
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Enable admin user for the container registry"
  type        = bool
  default     = true
}

variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "B1"
}

variable "app_service_always_on" {
  description = "Keep the app service always on"
  type        = bool
  default     = false
}

variable "docker_image" {
  description = "Docker image for the web app"
  type        = string
  default     = "mcr.microsoft.com/dotnet/samples:aspnetapp"
}

variable "app_settings" {
  description = "Additional application settings"
  type        = map(string)
  default     = {}
}