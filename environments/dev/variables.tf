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
  description = "Docker image name and tag (without registry URL)"
  type        = string
  default     = "vibes-app:latest"
}

variable "app_settings" {
  description = "Additional application settings"
  type        = map(string)
  default     = {}
}

# Azure DevOps Variables
variable "enable_devops_pipeline" {
  description = "Enable Azure DevOps pipeline creation"
  type        = bool
  default     = false
}

variable "azuredevops_org_service_url" {
  description = "Azure DevOps organization service URL (e.g., https://dev.azure.com/yourorg)"
  type        = string
  default     = ""
}

variable "azuredevops_personal_access_token" {
  description = "Azure DevOps Personal Access Token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure_subscription_name" {
  description = "Name of the Azure subscription"
  type        = string
  default     = ""
}

variable "devops_service_principal_id" {
  description = "Service Principal ID for Azure DevOps service connection"
  type        = string
  default     = ""
  sensitive   = true
}

variable "devops_service_principal_key" {
  description = "Service Principal key for Azure DevOps service connection"
  type        = string
  default     = ""
  sensitive   = true
}

variable "devops_min_reviewers" {
  description = "Minimum number of reviewers required for pull requests"
  type        = number
  default     = 1
}

variable "devops_create_pipelines" {
  description = "Whether to create build pipelines (set to true after pushing YAML files)"
  type        = bool
  default     = false
}

variable "devops_use_github_repo" {
  description = "Use GitHub repository instead of Azure DevOps Git"
  type        = bool
  default     = false
}

variable "github_repo_name" {
  description = "GitHub repository name (e.g., 'spik3r/iac')"
  type        = string
  default     = ""
}

variable "github_personal_access_token" {
  description = "GitHub Personal Access Token for service connection"
  type        = string
  default     = ""
  sensitive   = true
}

# Application Insights Variables
variable "log_retention_days" {
  description = "Data retention in days for Log Analytics workspace"
  type        = number
  default     = 30
}

variable "app_insights_sampling_percentage" {
  description = "Sampling percentage for Application Insights"
  type        = number
  default     = 100
}

variable "app_insights_disable_ip_masking" {
  description = "Whether to disable IP masking in Application Insights"
  type        = bool
  default     = false
}

variable "enable_monitoring_alerts" {
  description = "Whether to enable monitoring alerts"
  type        = bool
  default     = false
}

variable "alert_email_receivers" {
  description = "List of email receivers for alerts"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "error_rate_threshold" {
  description = "Threshold for error rate alert (number of exceptions)"
  type        = number
  default     = 10
}

variable "response_time_threshold_ms" {
  description = "Threshold for response time alert in milliseconds"
  type        = number
  default     = 5000
}

variable "enable_availability_test" {
  description = "Whether to enable availability test"
  type        = bool
  default     = false
}

variable "availability_test_frequency" {
  description = "Frequency of availability test in seconds"
  type        = number
  default     = 300
}

variable "availability_threshold_percentage" {
  description = "Threshold percentage for availability alert"
  type        = number
  default     = 90
}