resource "azurerm_service_plan" "main" {
  name                = "${var.name_prefix}-asp"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = "${var.name_prefix}-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    always_on = var.always_on

    application_stack {
      docker_image_name   = var.docker_image
      docker_registry_url = var.docker_registry_url
    }

    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        ip_address                = ip_restriction.value.ip_address
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
      }
    }
  }

  app_settings = merge(
    var.app_settings,
    var.docker_registry_username != null && var.docker_registry_password != null ? {
      DOCKER_REGISTRY_SERVER_URL      = var.docker_registry_url
      DOCKER_REGISTRY_SERVER_USERNAME = var.docker_registry_username
      DOCKER_REGISTRY_SERVER_PASSWORD = var.docker_registry_password
    } : {}
  )

  identity {
    type = "SystemAssigned"
  }

  logs {
    detailed_error_messages = var.detailed_error_messages
    failed_request_tracing  = var.failed_request_tracing

    application_logs {
      file_system_level = var.application_logs_level
    }

    http_logs {
      file_system {
        retention_in_days = var.http_logs_retention_days
        retention_in_mb   = var.http_logs_retention_mb
      }
    }
  }

  tags = var.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  count          = var.subnet_id != null ? 1 : 0
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = var.subnet_id
}