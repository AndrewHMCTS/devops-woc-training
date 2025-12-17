resource "azurerm_dashboard_grafana" "frontback" {
  name                  = "grafana-frontback-${var.env}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  grafana_major_version = 11

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.grafana.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.env
    Purpose     = "full-stack-monitoring"
  }
}

##diagnostics required for dashboard
data "azurerm_monitor_diagnostic_categories" "kv" {
  resource_id = azurerm_key_vault.kv.id
}

resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = "send-all-to-law"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.appservice.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.kv.log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.kv.metrics
    content {
      category = metric.value
    }
  }
}


data "azurerm_monitor_diagnostic_categories" "webapps" {
  for_each    = azurerm_linux_web_app.apps
  resource_id = each.value.id
}

resource "azurerm_monitor_diagnostic_setting" "webapps" {
  for_each = azurerm_linux_web_app.apps

  name                       = "send-all-to-law"
  target_resource_id         = each.value.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.appservice.id

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.webapps[each.key].log_category_types
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.webapps[each.key].metrics
    content {
      category = metric.value
    }
  }
}
