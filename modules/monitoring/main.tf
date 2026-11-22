# Monitoring and Observability Module - main.tf

resource "azurerm_log_analytics_workspace" "law" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "ag" {
  name                = "${var.name}-ag"
  resource_group_name = var.resource_group_name
  short_name          = "PlatAlerts"

  email_receiver {
    name                    = "OperationsTeam"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }

  tags = var.tags
}

# Example Enterprise Metric Alerts
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  count               = var.enable_vmss_alert ? 1 : 0
  name                = "${var.name}-vmss-high-cpu"
  resource_group_name = var.resource_group_name
  scopes              = [var.monitored_vmss_id]
  description         = "Alert when VMSS Average CPU utilization exceeds 85%"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachineScaleSets"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "appgw_unhealthy_hosts" {
  count               = var.enable_appgw_alert ? 1 : 0
  name                = "${var.name}-appgw-unhealthy-hosts"
  resource_group_name = var.resource_group_name
  scopes              = [var.monitored_appgw_id]
  description         = "Alert when Application Gateway detects unhealthy backend hosts"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "UnhealthyHostCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.ag.id
  }

  tags = var.tags
}
