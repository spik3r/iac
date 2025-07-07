variable "application_insights_name" {
  description = "Name of the Application Insights instance"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "application_type" {
  description = "Type of application being monitored"
  type        = string
  default     = "web"
  
  validation {
    condition     = contains(["web", "java", "HockeyAppBridge", "other"], var.application_type)
    error_message = "Application type must be one of: web, java, HockeyAppBridge, other."
  }
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.log_analytics_sku)
    error_message = "Invalid Log Analytics SKU."
  }
}

variable "retention_in_days" {
  description = "Data retention in days for Log Analytics workspace"
  type        = number
  default     = 30
  
  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "sampling_percentage" {
  description = "Sampling percentage for Application Insights"
  type        = number
  default     = 100
  
  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

variable "disable_ip_masking" {
  description = "Whether to disable IP masking in Application Insights"
  type        = bool
  default     = false
}

variable "create_action_group" {
  description = "Whether to create an action group for alerts"
  type        = bool
  default     = false
}

variable "create_alerts" {
  description = "Whether to create metric alerts"
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

variable "create_availability_test" {
  description = "Whether to create an availability test"
  type        = bool
  default     = false
}

variable "availability_test_url" {
  description = "URL to test for availability"
  type        = string
  default     = ""
}

variable "availability_test_frequency" {
  description = "Frequency of availability test in seconds"
  type        = number
  default     = 300
  
  validation {
    condition     = contains([300, 600, 900], var.availability_test_frequency)
    error_message = "Availability test frequency must be 300, 600, or 900 seconds."
  }
}

variable "availability_test_timeout" {
  description = "Timeout for availability test in seconds"
  type        = number
  default     = 30
}

variable "availability_test_locations" {
  description = "List of locations for availability test"
  type        = list(string)
  default = [
    "us-ca-sjc-azr",
    "us-tx-sn1-azr",
    "us-il-ch1-azr"
  ]
}

variable "availability_threshold_percentage" {
  description = "Threshold percentage for availability alert"
  type        = number
  default     = 90
  
  validation {
    condition     = var.availability_threshold_percentage >= 0 && var.availability_threshold_percentage <= 100
    error_message = "Availability threshold must be between 0 and 100."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}