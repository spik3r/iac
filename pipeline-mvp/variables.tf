# Project Configuration
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

# Azure Subscription Configuration
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
  description = "Service principal ID for Azure connection"
  type        = string
  sensitive   = true
}

variable "service_principal_key" {
  description = "Service principal key for Azure connection"
  type        = string
  sensitive   = true
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

# Git Repository Configuration
variable "git_repository_url" {
  description = "Git repository URL (GitHub format: https://github.com/username/repo)"
  type        = string
}

variable "github_username" {
  description = "GitHub username"
  type        = string
}

variable "github_personal_access_token" {
  description = "GitHub personal access token with repo permissions"
  type        = string
  sensitive   = true
}

# Docker Configuration
variable "docker_image_name" {
  description = "Name of the Docker image"
  type        = string
  default     = "vibes-app"
}

# Dev Environment Configuration (from your existing infrastructure)
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