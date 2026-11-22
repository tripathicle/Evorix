# Azure SQL Database Module - main.tf

resource "azurerm_mssql_server" "sql" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.admin_username
  administrator_login_password  = var.admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_network_access_enabled

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "db" {
  name           = var.database_name
  server_id      = azurerm_mssql_server.sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  sku_name       = var.sku_name
  zone_redundant = var.zone_redundant
  max_size_gb    = var.max_size_gb

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "sql_diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.database_name}-diag"
  target_resource_id         = azurerm_mssql_database.db.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
