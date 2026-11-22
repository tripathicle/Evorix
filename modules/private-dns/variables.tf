variable "resource_group_name" {
  type        = string
  description = "Resource Group where Private DNS Zones reside"
}

variable "dns_zone_names" {
  type        = list(string)
  description = "List of Private DNS Zone names to create"
}

variable "virtual_network_ids" {
  type        = map(string)
  description = "Map of VNet Name to VNet Resource ID to link with Private DNS Zones"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to Private DNS Zone resources"
  default     = {}
}
