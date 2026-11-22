# Cosmos DB Module - main.tf

resource "azurerm_cosmosdb_account" "cosmos" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  public_network_access_enabled = var.public_network_access_enabled

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.zone_redundant
  }

  dynamic "geo_location" {
    for_each = var.failover_location != null ? [1] : []
    content {
      location          = var.failover_location
      failover_priority = 1
      zone_redundant    = false
    }
  }

  tags = var.tags
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

resource "azurerm_monitor_diagnostic_setting" "cosmos_diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.name}-diag"
  target_resource_id         = azurerm_cosmosdb_account.cosmos.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
