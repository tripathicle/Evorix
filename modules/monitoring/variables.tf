variable "name" {
  type        = string
  description = "Name of the Log Analytics Workspace"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Monitoring resources"
}

variable "location" {
  type        = string
  description = "Azure Region for Monitoring resources"
}

variable "retention_in_days" {
  type        = number
  description = "Log retention period in days"
  default     = 30
}

variable "alert_email" {
  type        = string
  description = "Email recipient for platform alerts"
  default     = "platform-ops@example.com"
}

variable "enable_vmss_alert" {
  type        = bool
  description = "Enable VMSS CPU metric alert"
  default     = true
}

variable "monitored_vmss_id" {
  type        = string
  description = "Resource ID of the VMSS to monitor with CPU metric alerts"
  default     = null
}

variable "enable_appgw_alert" {
  type        = bool
  description = "Enable Application Gateway unhealthy hosts alert"
  default     = false
}

variable "monitored_appgw_id" {
  type        = string
  description = "Resource ID of the Application Gateway to monitor"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Monitoring resources"
  default     = {}
}
