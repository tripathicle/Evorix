variable "server_name" {
  type        = string
  description = "Name of the Azure MSSQL Server (must be globally unique)"
}

variable "database_name" {
  type        = string
  description = "Name of the Azure SQL Database"
  default     = "appdb"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for SQL Database"
}

variable "location" {
  type        = string
  description = "Azure Region for SQL Database"
}

variable "admin_username" {
  type        = string
  description = "Administrator login name for SQL Server"
  default     = "sqladmin"
}

variable "admin_password" {
  type        = string
  description = "Administrator password for SQL Server"
  sensitive   = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is allowed"
  default     = false
}

variable "sku_name" {
  type        = string
  description = "SKU for SQL database (e.g. S0, GP_Gen5_2, BC_Gen5_2)"
  default     = "GP_Gen5_2"
}

variable "zone_redundant" {
  type        = bool
  description = "Whether to enable zone redundancy for high availability"
  default     = true
}

variable "max_size_gb" {
  type        = number
  description = "Max size in GB for SQL database"
  default     = 32
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
  description = "Tags applied to SQL resources"
  default     = {}
}
