# Project Configuration
project_name = "vibes"
location     = "Australia East"

# Networking Configuration
vnet_address_space        = "10.0.0.0/16"
app_subnet_address_prefix = "10.0.1.0/24"
pe_subnet_address_prefix  = "10.0.2.0/24"

# Container Registry Configuration
acr_sku           = "Basic"
acr_admin_enabled = true

# App Service Configuration
app_service_sku       = "B1"
app_service_always_on = false
docker_image          = "vibes-app:latest"

# Additional App Settings
app_settings = {
  "CUSTOM_SETTING" = "value"
}

# Azure DevOps Configuration (Optional)
# Set enable_devops_pipeline = true to create Azure DevOps resources
enable_devops_pipeline = true

# Required if enable_devops_pipeline = true
azuredevops_org_service_url       = "https://dev.azure.com/kaiftait"
azuredevops_personal_access_token = ""  # Set in secrets.tfvars
azure_subscription_name           = "f9dc50e2-b88a-4c20-b3ad-0c6add93a139"

# Service Principal for Azure DevOps Service Connection
# Create a service principal with Contributor access to your subscription
devops_service_principal_id  = "138589e0-46da-45e0-834e-0945e0c9bf75"
devops_service_principal_key = ""  # Set in secrets.tfvars

# DevOps Settings
devops_min_reviewers = 1
devops_create_pipelines = true  # YAML files now exist in GitHub repository

# GitHub Integration (Optional - use your existing GitHub repo)
devops_use_github_repo = true
github_repo_name = "spik3r/iac"
github_personal_access_token = ""  # Set in secrets.tfvars
