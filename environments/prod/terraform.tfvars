project_name = "vibes"
location     = "Australia East"

# Networking
vnet_address_space         = "10.1.0.0/16"
app_subnet_address_prefix  = "10.1.1.0/24"
pe_subnet_address_prefix   = "10.1.2.0/24"

# Container Registry
acr_sku           = "Standard"
acr_admin_enabled = false

# App Service
app_service_sku      = "P1v3"
app_service_always_on = true

# Application
docker_image = "vibes-app:latest"

app_settings = {
  "CUSTOM_SETTING" = "prod-value"
}