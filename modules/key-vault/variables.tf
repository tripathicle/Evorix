variable "name" {
  type        = string
  description = "Name of the Azure Key Vault (must be globally unique, 3-24 alphanumerics and hyphens)"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Key Vault"
}

variable "location" {
  type        = string
  description = "Azure Region for Key Vault"
}

variable "sku_name" {
  type        = string
  description = "SKU for Key Vault: standard or premium"
  default     = "standard"
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days for soft delete retention"
  default     = 90
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection"
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed"
  default     = false
}

variable "allowed_ip_ranges" {
  type        = list(string)
  description = "List of public IP addresses / CIDRs allowed to access Key Vault"
  default     = []
}

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings"
  default     = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for audit logs"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Key Vault"
  default     = {}
}
