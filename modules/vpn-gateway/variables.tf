variable "name" {
  type        = string
  description = "Name of the Virtual Network Gateway"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for Virtual Network Gateway"
}

variable "location" {
  type        = string
  description = "Azure Region for Virtual Network Gateway"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID of GatewaySubnet in the Hub VNet"
}

variable "sku" {
  type        = string
  description = "SKU for the VPN Gateway (e.g. VpnGw1AZ, VpnGw2AZ)"
  default     = "VpnGw2AZ"
}

variable "active_active" {
  type        = bool
  description = "Enable Active-Active mode for high availability"
  default     = true
}

variable "enable_bgp" {
  type        = bool
  description = "Enable BGP routing"
  default     = false
}

variable "bgp_asn" {
  type        = number
  description = "BGP Autonomous System Number (ASN) for Azure Gateway"
  default     = 65515
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for Public IPs"
  default     = ["1", "2", "3"]
}

variable "enable_onprem_connection" {
  type        = bool
  description = "Flag to enable local network gateway and connection"
  default     = false
}

variable "onprem_gateway_address" {
  type        = string
  description = "Public IP address of the on-premises VPN device"
  default     = null
}

variable "onprem_address_spaces" {
  type        = list(string)
  description = "CIDR address spaces of the on-premises network"
  default     = []
}

variable "onprem_bgp_asn" {
  type        = number
  description = "On-premises BGP ASN"
  default     = null
}

variable "onprem_bgp_peering_address" {
  type        = string
  description = "On-premises BGP peering IP address"
  default     = null
}

variable "shared_key" {
  type        = string
  description = "Pre-shared key (PSK) for the IPSec tunnel"
  default     = null
  sensitive   = true
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
  description = "Tags applied to VPN Gateway resources"
  default     = {}
}
