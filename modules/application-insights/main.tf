terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Log Analytics Workspace for Application Insights
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.retention_in_days

  tags = var.tags
}

# Application Insights
resource "azurerm_application_insights" "main" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = var.application_type

  # Sampling configuration
  sampling_percentage = var.sampling_percentage

  # Disable IP masking for better debugging (can be enabled for production)
  disable_ip_masking = var.disable_ip_masking

  tags = var.tags
}

# Action Group for alerts (optional)
resource "azurerm_monitor_action_group" "main" {
  count               = var.create_action_group ? 1 : 0
  name                = "${var.application_insights_name}-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "appinsights"

  dynamic "email_receiver" {
    for_each = var.alert_email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  tags = var.tags
}

# Metric Alert for high error rate
resource "azurerm_monitor_metric_alert" "error_rate" {
  count               = var.create_alerts ? 1 : 0
  name                = "${var.application_insights_name}-high-error-rate"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when error rate is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "exceptions/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.error_rate_threshold
  }

  dynamic "action" {
    for_each = var.create_action_group ? [1] : []
    content {
      action_group_id = azurerm_monitor_action_group.main[0].id
    }
  }

  tags = var.tags
}

# Metric Alert for high response time
resource "azurerm_monitor_metric_alert" "response_time" {
  count               = var.create_alerts ? 1 : 0
  name                = "${var.application_insights_name}-high-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Alert when response time is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_threshold_ms
  }

  dynamic "action" {
    for_each = var.create_action_group ? [1] : []
    content {
      action_group_id = azurerm_monitor_action_group.main[0].id
    }
  }

  tags = var.tags
}

# Availability Test (optional)
resource "azurerm_application_insights_web_test" "main" {
  count                   = var.create_availability_test ? 1 : 0
  name                    = "${var.application_insights_name}-availability"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.main.id
  kind                    = "ping"
  frequency               = var.availability_test_frequency
  timeout                 = var.availability_test_timeout
  enabled                 = true
  geo_locations           = var.availability_test_locations

  configuration = <<XML
<WebTest Name="${var.application_insights_name}-availability" Id="${uuid()}" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="${uuid()}" Version="1.1" Url="${var.availability_test_url}" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML

  tags = var.tags
}

# Availability Test Alert
resource "azurerm_monitor_metric_alert" "availability" {
  count               = var.create_availability_test && var.create_alerts ? 1 : 0
  name                = "${var.application_insights_name}-availability-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights_web_test.main[0].id]
  description         = "Alert when availability test fails"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Insights/webtests"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold_percentage
  }

  dynamic "action" {
    for_each = var.create_action_group ? [1] : []
    content {
      action_group_id = azurerm_monitor_action_group.main[0].id
    }
  }

  tags = var.tags
}