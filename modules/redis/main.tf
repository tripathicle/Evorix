# Azure Cache for Redis Module - main.tf

resource "azurerm_redis_cache" "redis" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku_name
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_network_access_enabled
  zones                         = var.sku_name == "Premium" ? var.zones : null

  redis_configuration {
    maxmemory_reserved              = var.sku_name == "Premium" ? 50 : null
    maxmemory_delta                 = var.sku_name == "Premium" ? 50 : null
    maxfragmentationmemory_reserved = var.sku_name == "Premium" ? 50 : null
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "redis_diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_redis_cache.redis.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}
