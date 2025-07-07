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

# Admin Subscription Configuration
variable "admin_subscription_id" {
  description = "Azure subscription ID for admin/build infrastructure"
  type        = string
}

variable "admin_subscription_name" {
  description = "Azure subscription name for admin/build infrastructure"
  type        = string
}

variable "admin_service_principal_id" {
  description = "Service principal ID for admin subscription"
  type        = string
}

variable "admin_service_principal_key" {
  description = "Service principal key for admin subscription"
  type        = string
  sensitive   = true
}

# Target Subscription Configuration
variable "target_subscription_id" {
  description = "Azure subscription ID for target environments (dev, uat, prod)"
  type        = string
}

variable "target_subscription_name" {
  description = "Azure subscription name for target environments"
  type        = string
}

variable "target_service_principal_id" {
  description = "Service principal ID for target subscription"
  type        = string
}

variable "target_service_principal_key" {
  description = "Service principal key for target subscription"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

# Azure DevOps Configuration
variable "azuredevops_org_service_url" {
  description = "Azure DevOps organization service URL"
  type        = string
}

variable "azuredevops_personal_access_token" {
  description = "Azure DevOps personal access token"
  type        = string
  sensitive   = true
}

# GitHub Configuration
variable "use_github_repo" {
  description = "Whether to use GitHub repository for source control"
  type        = bool
  default     = true
}

variable "github_repo_name" {
  description = "GitHub repository name (format: owner/repo)"
  type        = string
  default     = ""
}

variable "github_personal_access_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
  default     = ""
}

# Container Registry Configuration
variable "admin_acr_sku" {
  description = "SKU for admin container registry"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.admin_acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_acr_geo_replications" {
  description = "List of geo-replication configurations for admin ACR"
  type = list(object({
    location                = string
    zone_redundancy_enabled = bool
  }))
  default = []
}

variable "docker_image_name" {
  description = "Name of the Docker image"
  type        = string
  default     = "vibes-app"
}

# Target Environment Configuration
variable "dev_resource_group_name" {
  description = "Resource group name for dev environment"
  type        = string
}

variable "dev_container_registry_name" {
  description = "Container registry name for dev environment"
  type        = string
}

variable "dev_app_service_name" {
  description = "App service name for dev environment"
  type        = string
}

# Pipeline Configuration
variable "create_pipelines" {
  description = "Whether to create Azure DevOps pipelines"
  type        = bool
  default     = true
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}