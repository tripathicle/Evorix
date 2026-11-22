# Standardized naming conventions for Enterprise Azure Hub-and-Spoke Infrastructure

locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.location_short}"

  # Common Resource Names
  hub_rg_name   = "${local.name_prefix}-hub-rg"
  spoke_rg_name = "${local.name_prefix}-spoke-rg"
  sec_rg_name   = "${local.name_prefix}-sec-rg"
  mgmt_rg_name  = "${local.name_prefix}-mgmt-rg"
  db_rg_name    = "${local.name_prefix}-data-rg"

  # Network Names
  hub_vnet_name   = "${local.name_prefix}-hub-vnet"
  spoke_vnet_name = "${local.name_prefix}-spoke-vnet"

  # Security & Gateways
  firewall_name = "${local.name_prefix}-afw"
  bastion_name  = "${local.name_prefix}-bas"
  vpngw_name    = "${local.name_prefix}-vpngw"
  appgw_name    = "${local.name_prefix}-appgw"
  ilb_name      = "${local.name_prefix}-ilb"

  # Compute VMSS
  frontend_vmss_name = "${local.name_prefix}-fe-vmss"
  backend_vmss_name  = "${local.name_prefix}-be-vmss"

  # Monitoring & Storage
  log_analytics_name           = "${local.name_prefix}-law"
  storage_account_name_cleaned = replace(lower("${var.project_name}${var.environment}${var.location_short}diag"), "-", "")
  key_vault_name               = substr("${local.name_prefix}-kv", 0, 24)
  sql_server_name              = "${local.name_prefix}-sqlsvr"
  cosmos_name                  = "${local.name_prefix}-cosmos"
  redis_name                   = "${local.name_prefix}-redis"
  rsv_name                     = "${local.name_prefix}-rsv"
}
