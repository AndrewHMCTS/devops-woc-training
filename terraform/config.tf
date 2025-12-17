locals {
  grafana_dashboard_json = jsonencode({
    annotations = {
      list = []
    }
    editable             = true
    fiscalYearStartMonth = 0
    graphTooltip         = 0
    panels = [
      {
        datasource = {
          type = "grafana-azure-monitor-datasource"
          uid  = "azure-monitor"
        }
        fieldConfig = {
          defaults = {
            color = {
              mode = "palette-classic"
            }
            custom = {
              axisCenteredZero = false
              axisColorMode    = "text"
              axisLabel        = ""
              axisPlacement    = "auto"
              barAlignment     = 0
              drawStyle        = "line"
              fillOpacity      = 10
              gradientMode     = "none"
              hideFrom = {
                tooltip = false
                viz     = false
                legend  = false
              }
              lineInterpolation = "linear"
              lineWidth         = 1
              pointSize         = 5
              scaleDistribution = {
                type = "linear"
              }
              showPoints = "never"
              spanNulls  = false
            }
            mappings = []
            thresholds = {
              mode = "absolute"
              steps = [
                {
                  color = "green"
                  value = null
                },
                {
                  color = "red"
                  value = 10
                }
              ]
            }
            unit = "short"
          }
          overrides = []
        }
        gridPos = {
          h = 8
          w = 12
          x = 0
          y = 0
        }
        id = 1
        options = {
          legend = {
            calcs       = []
            displayMode = "list"
            placement   = "bottom"
            showLegend  = true
          }
          tooltip = {
            mode = "single"
            sort = "none"
          }
        }
        targets = [
          {
            azureMonitor = {
              aggregation      = "Total"
              dimensionFilters = []
              metricName       = "Http5xx"
              metricNamespace  = "Microsoft.Web/sites"
              resourceGroup    = "$resource_group"
              resourceName     = "$app_service"
              timeGrain        = "auto"
            }
            datasource = {
              type = "grafana-azure-monitor-datasource"
              uid  = "azure-monitor"
            }
            queryType = "Azure Monitor"
            refId     = "A"
          }
        ]
        title = "HTTP 5xx Errors"
        type  = "timeseries"
      },
      {
        datasource = {
          type = "grafana-azure-monitor-datasource"
          uid  = "azure-monitor"
        }
        fieldConfig = {
          defaults = {
            color = {
              mode = "thresholds"
            }
            mappings = []
            thresholds = {
              mode = "absolute"
              steps = [
                {
                  color = "green"
                  value = null
                },
                {
                  color = "yellow"
                  value = 2
                },
                {
                  color = "red"
                  value = 5
                }
              ]
            }
            unit = "s"
          }
          overrides = []
        }
        gridPos = {
          h = 8
          w = 12
          x = 12
          y = 0
        }
        id = 2
        options = {
          orientation = "auto"
          reduceOptions = {
            values = false
            calcs  = ["lastNotNull"]
            fields = ""
          }
          showThresholdLabels  = false
          showThresholdMarkers = true
        }
        targets = [
          {
            azureMonitor = {
              aggregation      = "Average"
              dimensionFilters = []
              metricName       = "AverageResponseTime"
              metricNamespace  = "Microsoft.Web/sites"
              resourceGroup    = "$resource_group"
              resourceName     = "$app_service"
              timeGrain        = "auto"
            }
            datasource = {
              type = "grafana-azure-monitor-datasource"
              uid  = "azure-monitor"
            }
            queryType = "Azure Monitor"
            refId     = "A"
          }
        ]
        title = "Average Response Time"
        type  = "gauge"
      }
    ]
    schemaVersion = 38
    tags          = ["azure", "app-service"]
    templating = {
      list = [
        {
          current = {}
          datasource = {
            type = "grafana-azure-monitor-datasource"
            uid  = "azure-monitor"
          }
          definition  = "ResourceGroups()"
          hide        = 0
          includeAll  = false
          multi       = false
          name        = "resource_group"
          options     = []
          query       = "ResourceGroups()"
          refresh     = 1
          regex       = ""
          skipUrlSync = false
          sort        = 0
          type        = "query"
        },
        {
          current = {}
          datasource = {
            type = "grafana-azure-monitor-datasource"
            uid  = "azure-monitor"
          }
          definition  = "ResourceNames($resource_group, Microsoft.Web/sites)"
          hide        = 0
          includeAll  = false
          multi       = false
          name        = "app_service"
          options     = []
          query       = "ResourceNames($resource_group, Microsoft.Web/sites)"
          refresh     = 1
          regex       = ""
          skipUrlSync = false
          sort        = 0
          type        = "query"
        }
      ]
    }
    time = {
      from = "now-6h"
      to   = "now"
    }
    timepicker = {}
    timezone   = "browser"
    title      = "App Service Monitoring"
    version    = 0
  })
}

resource "local_file" "grafana_dashboard" {
  content  = local.grafana_dashboard_json
  filename = "${path.module}/grafana-app-service-dashboard.json"
}