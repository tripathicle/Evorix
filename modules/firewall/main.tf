# Azure Firewall Module - main.tf

resource "azurerm_public_ip" "fw_pip" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_firewall_policy" "policy" {
  name                     = "${var.name}-policy"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku_tier
  threat_intelligence_mode = var.threat_intel_mode

  dynamic "intrusion_detection" {
    for_each = var.sku_tier == "Premium" ? [1] : []
    content {
      mode = "Alert"
    }
  }

  dns {
    proxy_enabled = true
  }

  tags = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "rules" {
  name               = "DefaultRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 100

  network_rule_collection {
    name     = "CoreNetworkRules"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "Allow-NTP"
      protocols             = ["UDP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }

    rule {
      name                  = "Allow-DNS"
      protocols             = ["UDP", "TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }

    rule {
      name                  = "Allow-Azure-KMS"
      protocols             = ["TCP"]
      source_addresses      = ["*"]
      destination_addresses = ["23.102.135.246", "20.118.99.224"]
      destination_ports     = ["1688"]
    }
  }

  application_rule_collection {
    name     = "CoreApplicationRules"
    priority = 300
    action   = "Allow"

    rule {
      name             = "Allow-OS-Updates-And-Package-Repositories"
      source_addresses = ["*"]
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      destination_fqdns = [
        "*.ubuntu.com",
        "*.canonical.com",
        "packages.microsoft.com",
        "archive.ubuntu.com",
        "security.ubuntu.com"
      ]
    }
  }
}

resource "azurerm_firewall" "fw" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.policy.id
  zones               = var.zones

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }

  tags = var.tags

  depends_on = [azurerm_firewall_policy_rule_collection_group.rules]
}

resource "azurerm_monitor_diagnostic_setting" "fw_diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_firewall.fw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
