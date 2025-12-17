resource "azurerm_dashboard_grafana" "frontback" {
  name                              = "grafana-frontback-${var.env}"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = azurerm_resource_group.rg.location
  grafana_major_version             = 11
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true

  azure_monitor_workspace_integrations {
    resource_id = azurerm_log_analytics_workspace.appservice.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.env
    Purpose     = "full-stack-monitoring"
  }
}

resource "azurerm_role_assignment" "grafana_monitoring_reader_law" {
  name                 = "grafana-monitoring-reader-law-${var.env}"
  scope                = azurerm_log_analytics_workspace.appservice.id
  role_definition_name = "Monitoring Reader"
  principal_id         = each.value.identity[0].principal_id
}

resource "azurerm_role_assignment" "grafana_monitoring_reader_apps" {
  for_each = {
    for combo in flatten([
      for dashboard_key, dashboard in {
        fullstack = azurerm_dashboard_grafana.frontback
        } : [
        for app_key, app in azurerm_linux_web_app.apps : {
          key          = "${dashboard_key}-${app_key}"
          dashboard_id = dashboard.identity[0].principal_id
          app_id       = app.id
        }
      ]
    ]) : combo.key => combo
  }

  scope                = each.value.app_id
  role_definition_name = "Monitoring Reader"
  principal_id         = each.value.dashboard_id
}

resource "azurerm_role_assignment" "grafana_monitoring_reader_appinsights" {
  for_each = {
    for combo in flatten([
      for dashboard_key, dashboard in {
        fullstack = azurerm_dashboard_grafana.frontback
        } : [
        for app_key, appinsights in azurerm_application_insights.apps : {
          key            = "${dashboard_key}-${app_key}"
          dashboard_id   = dashboard.identity[0].principal_id
          appinsights_id = appinsights.id
        }
      ]
    ]) : combo.key => combo
  }

  scope                = each.value.appinsights_id
  role_definition_name = "Monitoring Reader"
  principal_id         = each.value.dashboard_id
}