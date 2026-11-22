# Azure Backup and Disaster Recovery Module - main.tf

resource "azurerm_recovery_services_vault" "rsv" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  storage_mode_type   = var.storage_mode_type
  soft_delete_enabled = var.soft_delete_enabled

  tags = var.tags
}

resource "azurerm_backup_policy_vm" "policy" {
  name                = "${var.name}-daily-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = var.retention_daily_count
  }

  dynamic "retention_weekly" {
    for_each = var.retention_weekly_count > 0 ? [1] : []
    content {
      count    = var.retention_weekly_count
      weekdays = ["Sunday"]
    }
  }
}
