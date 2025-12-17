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