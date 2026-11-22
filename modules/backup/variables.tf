variable "name" {
  type        = string
  description = "Name of the Recovery Services Vault"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Recovery Services Vault"
}

variable "location" {
  type        = string
  description = "Azure Region for Recovery Services Vault"
}

variable "sku" {
  type        = string
  description = "SKU for Recovery Services Vault: Standard or RS0"
  default     = "Standard"
}

variable "storage_mode_type" {
  type        = string
  description = "Storage redundancy: GeoRedundant, LocallyRedundant, or ZoneRedundant"
  default     = "GeoRedundant"
}

variable "soft_delete_enabled" {
  type        = bool
  description = "Enable soft delete for backed up items"
  default     = true
}

variable "retention_daily_count" {
  type        = number
  description = "Daily retention count"
  default     = 30
}

variable "retention_weekly_count" {
  type        = number
  description = "Weekly retention count"
  default     = 4
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Backup resources"
  default     = {}
}
