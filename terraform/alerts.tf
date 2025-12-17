resource "azurerm_monitor_action_group" "appservice" {
  name                = "ag-devopswoc-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "devopswoc"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
  }

  tags = {
    Environment = var.env
  }
}

resource "azurerm_monitor_metric_alert" "http_5xx" {
  for_each            = local.webapps
  name                = "alert-http5xx-${each.value.name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_web_app.apps[each.key].id]
  description         = "Alert when HTTP 5xx errors exceed 10 in 5 minutes"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
    App         = each.key
  }
}

resource "azurerm_monitor_metric_alert" "http_404" {
  for_each            = local.webapps
  name                = "alert-http404-${each.value.name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_web_app.apps[each.key].id]
  description         = "Alert when HTTP 404 errors exceed 50 in 15 minutes"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http404"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
    App         = each.key
  }
}

resource "azurerm_monitor_metric_alert" "response_time" {
  for_each            = local.webapps
  name                = "alert-responsetime-${each.value.name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_web_app.apps[each.key].id]
  description         = "Alert when average response time exceeds 5 seconds"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 5
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
    App         = each.key
  }
}

resource "azurerm_monitor_metric_alert" "memory_working_set" {
  for_each            = local.webapps
  name                = "alert-memory-${each.value.name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_web_app.apps[each.key].id]
  description         = "Alert when memory working set is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageMemoryWorkingSet"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1073741824
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
    App         = each.key
  }
}

resource "azurerm_monitor_metric_alert" "health_check" {
  for_each            = local.webapps
  name                = "alert-healthcheck-${each.value.name}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_web_app.apps[each.key].id]
  description         = "Alert when health check fails"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "HealthCheckStatus"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
    App         = each.key
  }
}

resource "azurerm_monitor_metric_alert" "cpu_percentage" {
  name                = "alert-cpu-appplan-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_service_plan.appplan.id]
  description         = "Alert when CPU percentage exceeds 80%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
  }
}

resource "azurerm_monitor_metric_alert" "memory_percentage" {
  name                = "alert-memory-appplan-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_service_plan.appplan.id]
  description         = "Alert when memory percentage exceeds 80%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
  }
}

resource "azurerm_monitor_activity_log_alert" "app_stopped" {
  name                = "alert-app-stopped-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_resource_group.rg.id]
  description         = "Alert when an app service is stopped"

  criteria {
    resource_type  = "Microsoft.Web/sites"
    operation_name = "Microsoft.Web/sites/stop/action"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
  }
}

resource "azurerm_monitor_activity_log_alert" "app_restarted" {
  name                = "alert-app-restarted-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_resource_group.rg.id]
  description         = "Alert when an app service is restarted"

  criteria {
    resource_type  = "Microsoft.Web/sites"
    operation_name = "Microsoft.Web/sites/restart/action"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
  }
}

resource "azurerm_monitor_activity_log_alert" "app_deleted" {
  name                = "alert-app-deleted-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_resource_group.rg.id]
  description         = "Alert when an app service is deleted"

  criteria {
    resource_type  = "Microsoft.Web/sites"
    operation_name = "Microsoft.Web/sites/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.appservice.id
  }

  tags = {
    Environment = var.env
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "http_500_with_logs" {
  name                = "alert-http500-logs-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [azurerm_log_analytics_workspace.appservice.id]
  severity             = 2

  criteria {
    query = <<-QUERY
      let timeRange = 5m;
      let myHttp = AppServiceHTTPLogs 
      | where TimeGenerated > ago(timeRange)
      | where ScStatus == 500 
      | project TimeGen=substring(TimeGenerated, 0, 19), CsUriStem, ScStatus, _ResourceId;
      let myConsole = AppServiceConsoleLogs 
      | where TimeGenerated > ago(timeRange)
      | project TimeGen=substring(TimeGenerated, 0, 19), ResultDescription, _ResourceId;
      myHttp 
      | join kind=inner myConsole on TimeGen, _ResourceId
      | project TimeGen, CsUriStem, ScStatus, ResultDescription, _ResourceId
      | summarize Count=count() by _ResourceId
    QUERY

    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  auto_mitigation_enabled          = false
  workspace_alerts_storage_enabled = false
  description                      = "Alert when HTTP 500 errors occur with console logs"
  display_name                     = "HTTP 500 Errors with Console Logs"
  enabled                          = true
  skip_query_validation            = false

  action {
    action_groups = [azurerm_monitor_action_group.appservice.id]
  }

  tags = {
    Environment = var.env
  }
}


