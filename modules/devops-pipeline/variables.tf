variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "subscription_name" {
  description = "Azure subscription name"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "service_principal_id" {
  description = "Service principal ID for Azure DevOps connection"
  type        = string
}

variable "service_principal_key" {
  description = "Service principal key for Azure DevOps connection"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Name of the resource group containing app resources"
  type        = string
}

variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "app_service_name" {
  description = "Name of the App Service"
  type        = string
}

variable "docker_image_name" {
  description = "Base name of the Docker image (without tag)"
  type        = string
  default     = "vibes-app"
}

variable "acr_admin_username" {
  description = "ACR admin username"
  type        = string
  sensitive   = true
}

variable "acr_admin_password" {
  description = "ACR admin password"
  type        = string
  sensitive   = true
}

variable "min_reviewers" {
  description = "Minimum number of reviewers required for PR"
  type        = number
  default     = 1
}

variable "create_pipelines" {
  description = "Whether to create build pipelines (set to true after pushing YAML files)"
  type        = bool
  default     = false
}

variable "use_github_repo" {
  description = "Use GitHub repository instead of Azure DevOps Git"
  type        = bool
  default     = false
}

variable "github_repo_name" {
  description = "GitHub repository name (e.g., 'username/repository')"
  type        = string
  default     = ""
}

variable "github_repo_id" {
  description = "GitHub repository ID (can be same as repo_name for most cases)"
  type        = string
  default     = ""
}

variable "github_personal_access_token" {
  description = "GitHub Personal Access Token for service connection"
  type        = string
  default     = ""
  sensitive   = true
}