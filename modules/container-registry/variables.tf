variable "registry_name" {
  description = "Name of the container registry"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the registry"
  type        = string
}

variable "sku" {
  description = "SKU for the container registry"
  type        = string
  default     = "Basic"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for the registry"
  type        = bool
  default     = false
}

variable "georeplications" {
  description = "List of georeplications for the registry"
  type = list(object({
    location                = string
    zone_redundancy_enabled = bool
    tags                    = map(string)
  }))
  default = []
}

variable "acr_pull_principal_ids" {
  description = "List of principal IDs to grant AcrPull role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}