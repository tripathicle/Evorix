variable "name" {
  type        = string
  description = "Name of the Azure Firewall"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Azure Firewall"
}

variable "location" {
  type        = string
  description = "Azure Region for Azure Firewall"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the AzureFirewallSubnet (must be /26 or larger)"
}

variable "sku_tier" {
  type        = string
  description = "SKU tier of the Firewall: Standard or Premium"
  default     = "Premium"
  validation {
    condition     = contains(["Standard", "Premium"], var.sku_tier)
    error_message = "The sku_tier must be either 'Standard' or 'Premium'."
  }
}

variable "threat_intel_mode" {
  type        = string
  description = "Threat Intelligence mode: Off, Alert, or Deny"
  default     = "Alert"
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for Azure Firewall redundancy"
  default     = ["1", "2", "3"]
}

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings"
  default     = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for diagnostic logs"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Azure Firewall resources"
  default     = {}
}
