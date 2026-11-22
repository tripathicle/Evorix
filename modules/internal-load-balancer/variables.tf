variable "name" {
  type        = string
  description = "Name of the Internal Load Balancer"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Internal Load Balancer"
}

variable "location" {
  type        = string
  description = "Azure region for the Internal Load Balancer"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID of InternalLbSubnet"
}

variable "zones" {
  type        = list(string)
  description = "Availability Zones for zone redundancy"
  default     = ["1", "2", "3"]
}

variable "frontend_port" {
  type        = number
  description = "Port to listen on the frontend"
  default     = 8080
}

variable "backend_port" {
  type        = number
  description = "Port to forward traffic to backend VMs"
  default     = 8080
}

variable "probe_protocol" {
  type        = string
  description = "Health probe protocol: Tcp or Http"
  default     = "Http"
}

variable "probe_path" {
  type        = string
  description = "Path for HTTP health probe"
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
  description = "Tags applied to Internal Load Balancer resources"
  default     = {}
}
