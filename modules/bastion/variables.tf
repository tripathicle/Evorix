variable "name" {
  type        = string
  description = "Name of the Bastion Host"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Bastion Host"
}

variable "location" {
  type        = string
  description = "Azure Region for Bastion"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID of AzureBastionSubnet (must be /26 or larger)"
}

variable "sku" {
  type        = string
  description = "SKU for Bastion: Basic or Standard"
  default     = "Standard"
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for Bastion public IP"
  default     = ["1", "2", "3"]
}

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings"
  default     = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for Bastion audit logging"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Bastion resources"
  default     = {}
}
