variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the App Service Plan"
  type        = string
  default     = "B1"
}

variable "docker_image" {
  description = "Docker image for the web app"
  type        = string
}

variable "docker_registry_url" {
  description = "Docker registry URL"
  type        = string
  default     = "https://index.docker.io"
}

variable "docker_registry_username" {
  description = "Docker registry username"
  type        = string
  default     = null
  sensitive   = true
}

variable "docker_registry_password" {
  description = "Docker registry password"
  type        = string
  default     = null
  sensitive   = true
}

variable "app_settings" {
  description = "Application settings for the web app"
  type        = map(string)
  default     = {}
}

variable "always_on" {
  description = "Keep the app always on"
  type        = bool
  default     = true
}

variable "subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
  default     = null
}

variable "ip_restrictions" {
  description = "IP restrictions for the web app"
  type = list(object({
    ip_address                = optional(string)
    virtual_network_subnet_id = optional(string)
    name                      = string
    priority                  = number
    action                    = string
  }))
  default = []
}

variable "detailed_error_messages" {
  description = "Enable detailed error messages"
  type        = bool
  default     = false
}

variable "failed_request_tracing" {
  description = "Enable failed request tracing"
  type        = bool
  default     = false
}

variable "application_logs_level" {
  description = "Application logs level"
  type        = string
  default     = "Information"
}

variable "http_logs_retention_days" {
  description = "HTTP logs retention in days"
  type        = number
  default     = 7
}

variable "http_logs_retention_mb" {
  description = "HTTP logs retention in MB"
  type        = number
  default     = 35
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}