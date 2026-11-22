variable "name" {
  type        = string
  description = "Name of the Azure Cache for Redis"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Redis"
}

variable "location" {
  type        = string
  description = "Azure Region for Redis"
}

variable "capacity" {
  type        = number
  description = "Redis cache capacity"
  default     = 1
}

variable "family" {
  type        = string
  description = "Redis cache family: C (Basic/Standard) or P (Premium)"
  default     = "P"
}

variable "sku_name" {
  type        = string
  description = "Redis SKU: Standard or Premium"
  default     = "Premium"
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for Redis Premium"
  default     = ["1", "2"]
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed"
  default     = false
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
  description = "Tags applied to Redis"
  default     = {}
}
