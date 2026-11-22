variable "hub_resource_group_name" {
  type        = string
  description = "Resource Group of the Hub VNet"
}

variable "hub_vnet_name" {
  type        = string
  description = "Name of the Hub VNet"
}

variable "hub_vnet_id" {
  type        = string
  description = "Resource ID of the Hub VNet"
}

variable "spoke_resource_group_name" {
  type        = string
  description = "Resource Group of the Spoke VNet"
}

variable "spoke_vnet_name" {
  type        = string
  description = "Name of the Spoke VNet"
}

variable "spoke_vnet_id" {
  type        = string
  description = "Resource ID of the Spoke VNet"
}

variable "allow_gateway_transit" {
  type        = bool
  description = "Allow gateway transit on the Hub side"
  default     = false
}

variable "use_remote_gateways" {
  type        = bool
  description = "Use remote gateway on the Spoke side (requires gateway transit on Hub and deployed gateway)"
  default     = false
}
