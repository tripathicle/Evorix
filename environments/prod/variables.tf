# Prod Environment - variables.tf

variable "project_name" {
  type        = string
  description = "Project name prefix for resources"
  default     = "gd-ent"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"
  default     = "prod"
}

variable "location" {
  type        = string
  description = "Azure Region for infrastructure deployment"
  default     = "eastus"
}

variable "location_short" {
  type        = string
  description = "Short name for Azure Region (e.g. eus, wus2)"
  default     = "eus"
}

variable "owner" {
  type        = string
  description = "Owner of the deployment"
  default     = "CloudPlatformTeam"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing allocation"
  default     = "CC-PROD-PLATFORM"
}

variable "criticality" {
  type        = string
  description = "Workload criticality rating"
  default     = "Tier-1-Mission-Critical"
}

variable "extra_tags" {
  type        = map(string)
  description = "Additional tags to merge with default tags"
  default     = {}
}

# Network CIDRs
variable "hub_address_space" {
  type        = list(string)
  description = "CIDR address space for Hub VNet"
  default     = ["10.0.0.0/16"]
}

variable "spoke_address_space" {
  type        = list(string)
  description = "CIDR address space for Spoke VNet"
  default     = ["10.1.0.0/16"]
}

# Feature Flags
variable "enable_firewall" {
  type        = bool
  description = "Flag to deploy Azure Firewall"
  default     = true
}

variable "firewall_sku_tier" {
  type        = string
  description = "Azure Firewall SKU tier (Standard or Premium)"
  default     = "Premium"
}

variable "enable_bastion" {
  type        = bool
  description = "Flag to deploy Azure Bastion"
  default     = true
}

variable "enable_vpn_gateway" {
  type        = bool
  description = "Flag to deploy Azure Virtual Network Gateway"
  default     = true
}

variable "enable_application_gateway" {
  type        = bool
  description = "Flag to deploy Application Gateway WAF"
  default     = true
}

variable "enable_private_endpoints" {
  type        = bool
  description = "Flag to deploy Private Endpoints for PaaS"
  default     = true
}

variable "enable_cosmos_db" {
  type        = bool
  description = "Flag to deploy Azure Cosmos DB"
  default     = true
}

variable "enable_redis" {
  type        = bool
  description = "Flag to deploy Azure Cache for Redis"
  default     = true
}

variable "enable_monitoring" {
  type        = bool
  description = "Flag to deploy Log Analytics and Azure Monitor alerts"
  default     = true
}

variable "enable_backup" {
  type        = bool
  description = "Flag to deploy Recovery Services Vault and Backup Policies"
  default     = true
}

# VMSS & Compute Configuration
variable "admin_username" {
  type        = string
  description = "Administrator username for Linux VMs"
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH Public Key for Linux VMSS instances"
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGX8a5dF+p1k93VqM5yL01bZl81234567890abcdefgh enterprise-admin@company.com"
}

variable "frontend_vm_sku" {
  type        = string
  description = "VM SKU for Frontend VMSS"
  default     = "Standard_D2s_v5"
}

variable "frontend_instances" {
  type        = number
  description = "Instance count for Frontend VMSS"
  default     = 2
}

variable "backend_vm_sku" {
  type        = string
  description = "VM SKU for Backend VMSS"
  default     = "Standard_D2s_v5"
}

variable "backend_instances" {
  type        = number
  description = "Instance count for Backend VMSS"
  default     = 2
}

# PaaS Configuration
variable "sql_admin_username" {
  type        = string
  description = "Administrator login for SQL Server"
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  type        = string
  description = "Administrator password for SQL Server"
  default     = "P@ssw0rdEnterprise2026!#Strong"
  sensitive   = true
}
