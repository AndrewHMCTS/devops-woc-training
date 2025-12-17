resource "azurerm_log_analytics_workspace" "appservice" {
  name                = "law-devopswoc-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.env
    Purpose     = "app-service-monitoring"
  }
}

resource "azurerm_application_insights" "apps" {
  for_each            = local.webapps
  name                = "appi-${each.value.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  workspace_id        = azurerm_log_analytics_workspace.appservice.id
  application_type    = "web"

  tags = {
    Environment = var.env
    App         = each.key
  }
}

resource "azurerm_monitor_diagnostic_setting" "apps" {
  for_each                   = local.webapps
  name                       = "diag-${each.value.name}"
  target_resource_id         = azurerm_linux_web_app.apps[each.key].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.appservice.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  dynamic "enabled_log" {
    for_each = ["AppServiceHTTPLogs", "AppServiceConsoleLogs", "AppServiceAppLogs", "AppServiceAuditLogs", "AppServiceIPSecAuditLogs", "AppServicePlatformLogs"]
    content {
      category = enabled_log.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "appplan" {
  name                       = "diag-woc-${var.env}"
  target_resource_id         = azurerm_service_plan.appplan.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.appservice.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

