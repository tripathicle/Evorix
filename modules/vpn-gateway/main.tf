# VPN Gateway Module - main.tf

resource "azurerm_public_ip" "pip1" {
  name                = "${var.name}-pip1"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_public_ip" "pip2" {
  count               = var.active_active ? 1 : 0
  name                = "${var.name}-pip2"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vpngw" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.sku
  active_active       = var.active_active
  enable_bgp          = var.enable_bgp

  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = azurerm_public_ip.pip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }

  dynamic "ip_configuration" {
    for_each = var.active_active ? [1] : []
    content {
      name                          = "vnetGatewayConfig2"
      public_ip_address_id          = azurerm_public_ip.pip2[0].id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = var.subnet_id
    }
  }

  dynamic "bgp_settings" {
    for_each = var.enable_bgp ? [1] : []
    content {
      asn = var.bgp_asn
    }
  }

  tags = var.tags
}

resource "azurerm_local_network_gateway" "onprem" {
  count               = var.enable_onprem_connection ? 1 : 0
  name                = "${var.name}-onprem-lng"
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.onprem_gateway_address
  address_space       = var.onprem_address_spaces

  dynamic "bgp_settings" {
    for_each = var.enable_bgp && var.onprem_bgp_asn != null ? [1] : []
    content {
      asn                 = var.onprem_bgp_asn
      bgp_peering_address = var.onprem_bgp_peering_address
    }
  }

  tags = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "s2s" {
  count                      = var.enable_onprem_connection ? 1 : 0
  name                       = "${var.name}-s2s-conn"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem[0].id
  shared_key                 = var.shared_key
  enable_bgp                 = var.enable_bgp

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "vpngw_diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_virtual_network_gateway.vpngw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "GatewayDiagnosticLog"
  }

  enabled_log {
    category = "TunnelDiagnosticLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
