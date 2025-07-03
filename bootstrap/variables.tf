variable "resource_group_name" {
  description = "Name of the resource group for Terraform state"
  type        = string
  default     = "rg-terraform-state"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Australia East"
}

variable "storage_account_prefix" {
  description = "Prefix for the storage account name"
  type        = string
  default     = "tfstate"
  
  validation {
    condition     = length(var.storage_account_prefix) <= 16
    error_message = "Storage account prefix must be 16 characters or less."
  }
}

variable "container_name" {
  description = "Name of the blob container for Terraform state"
  type        = string
  default     = "tfstate"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "shared"
    Purpose     = "terraform-state"
    ManagedBy   = "terraform"
  }
}