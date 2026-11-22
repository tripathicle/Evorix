# Dev Environment - variables.tf

variable "project_name" {
  type        = string
  description = "Project name prefix for resources"
  default     = "gd-ent"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure Region for infrastructure deployment"
  default     = "eastus"
}

variable "location_short" {
  type        = string
  description = "Short name for Azure Region"
  default     = "eus"
}

variable "owner" {
  type        = string
  description = "Owner of the deployment"
  default     = "DevPlatformTeam"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing allocation"
  default     = "CC-DEV-SANDBOX"
}

variable "criticality" {
  type        = string
  description = "Workload criticality rating"
  default     = "Tier-3-Non-Critical"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags to merge with default tags"
  default     = {}
}

variable "hub_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "spoke_address_space" {
  type    = list(string)
  default = ["10.1.0.0/16"]
}

variable "enable_firewall" {
  type    = bool
  default = true
}

variable "firewall_sku_tier" {
  type    = string
  default = "Standard"
}

variable "enable_bastion" {
  type    = bool
  default = true
}

variable "enable_vpn_gateway" {
  type    = bool
  default = false
}

variable "enable_application_gateway" {
  type    = bool
  default = true
}

variable "enable_private_endpoints" {
  type    = bool
  default = true
}

variable "enable_cosmos_db" {
  type    = bool
  default = false
}

variable "enable_redis" {
  type    = bool
  default = false
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

variable "enable_backup" {
  type    = bool
  default = false
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_ssh_public_key" {
  type    = string
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGX8a5dF+p1k93VqM5yL01bZl81234567890abcdefgh enterprise-admin@company.com"
}

variable "frontend_vm_sku" {
  type    = string
  default = "Standard_B2s"
}

variable "frontend_instances" {
  type    = number
  default = 2
}

variable "backend_vm_sku" {
  type    = string
  default = "Standard_B2s"
}

variable "backend_instances" {
  type    = number
  default = 2
}

variable "sql_admin_username" {
  type    = string
  default = "sqladminuser"
}

variable "sql_admin_password" {
  type      = string
  default   = "P@ssw0rdDev2026!#Strong"
  sensitive = true
}
