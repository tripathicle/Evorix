variable "name" {
  type        = string
  description = "Name of the Application Gateway"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Application Gateway"
}

variable "location" {
  type        = string
  description = "Azure region for the Application Gateway"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID of AppGatewaySubnet"
}

variable "zones" {
  type        = list(string)
  description = "Availability Zones for Application Gateway redundancy"
  default     = ["1", "2", "3"]
}

variable "waf_mode" {
  type        = string
  description = "WAF Mode: Prevention or Detection"
  default     = "Prevention"
  validation {
    condition     = contains(["Prevention", "Detection"], var.waf_mode)
    error_message = "waf_mode must be Prevention or Detection."
  }
}

variable "min_capacity" {
  type        = number
  description = "Minimum capacity units for autoscale"
  default     = 2
}

variable "max_capacity" {
  type        = number
  description = "Maximum capacity units for autoscale"
  default     = 10
}

variable "backend_port" {
  type        = number
  description = "Port used by backend servers"
  default     = 80
}

variable "health_probe_path" {
  type        = string
  description = "Health probe HTTP path"
  default     = "/healthz"
}

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings"
  default     = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for diagnostics"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Application Gateway resources"
  default     = {}
}
