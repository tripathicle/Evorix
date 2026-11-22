variable "name" {
  type        = string
  description = "Name of the Private DNS Resolver"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for DNS Resolver"
}

variable "location" {
  type        = string
  description = "Azure region for the DNS Resolver"
}

variable "virtual_network_id" {
  type        = string
  description = "Resource ID of the Hub VNet"
}

variable "inbound_subnet_id" {
  type        = string
  description = "Subnet ID for inbound DNS queries (must have Microsoft.Network/dnsResolvers delegation)"
}

variable "outbound_subnet_id" {
  type        = string
  description = "Subnet ID for outbound DNS resolution (must have Microsoft.Network/dnsResolvers delegation)"
}

variable "forwarding_rules" {
  type = map(object({
    domain_name = string
    enabled     = optional(bool, true)
    target_dns_servers = list(object({
      ip_address = string
      port       = optional(number, 53)
    }))
  }))
  description = "Map of forwarding rules for on-premises or custom DNS domains"
  default     = {}
}

variable "linked_virtual_network_ids" {
  type        = list(string)
  description = "List of Virtual Network IDs to link to the DNS forwarding ruleset"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to DNS Resolver resources"
  default     = {}
}
