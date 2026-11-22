# Internal Load Balancer Module - main.tf

resource "azurerm_lb" "ilb" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "internal-frontend"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    zones                         = var.zones
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.ilb.id
  name            = "backend-pool"
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id     = azurerm_lb.ilb.id
  name                = "health-probe"
  port                = var.backend_port
  protocol            = var.probe_protocol
  request_path        = var.probe_protocol == "Http" ? var.probe_path : null
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "rule" {
  loadbalancer_id                = azurerm_lb.ilb.id
  name                           = "ilb-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "internal-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.probe.id
  floating_ip_enabled            = false
  idle_timeout_in_minutes        = 15
}

resource "azurerm_monitor_diagnostic_setting" "ilb_diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_lb.ilb.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "LoadBalancerAlertEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
