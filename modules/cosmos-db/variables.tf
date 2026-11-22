variable "name" {
  type        = string
  description = "Name of the Cosmos DB Account"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Cosmos DB"
}

variable "location" {
  type        = string
  description = "Primary Azure region for Cosmos DB"
}

variable "failover_location" {
  type        = string
  description = "Secondary Azure region for Cosmos DB failover"
  default     = null
}

variable "consistency_level" {
  type        = string
  description = "Cosmos DB Consistency Level"
  default     = "Session"
}

variable "zone_redundant" {
  type        = bool
  description = "Enable zone redundancy for Cosmos DB"
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed"
  default     = false
}

variable "database_name" {
  type        = string
  description = "Name of the SQL Database within Cosmos DB"
  default     = "appdatabase"
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
  description = "Tags applied to Cosmos DB"
  default     = {}
}
