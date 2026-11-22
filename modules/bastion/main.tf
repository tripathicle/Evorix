# Azure Bastion Module - main.tf

resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku                    = var.sku
  copy_paste_enabled     = true
  file_copy_enabled      = var.sku == "Standard" ? true : false
  shareable_link_enabled = var.sku == "Standard" ? true : false
  tunneling_enabled      = var.sku == "Standard" ? true : false

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "bastion_diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_bastion_host.bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "BastionAuditLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
