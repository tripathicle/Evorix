variable "name" {
  type        = string
  description = "Name of the storage account (alphanumeric lowercase only, 3-24 characters)"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Storage Account"
}

variable "location" {
  type        = string
  description = "Azure region for the Storage Account"
}

variable "replication_type" {
  type        = string
  description = "Replication type: LRS, GRS, ZRS, GZRS"
  default     = "GRS"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed"
  default     = false
}

variable "allowed_ip_ranges" {
  type        = list(string)
  description = "List of public IP addresses allowed through network rules"
  default     = []
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to enable diagnostic settings"
  default     = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for diagnostics"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Storage Account"
  default     = {}
}
