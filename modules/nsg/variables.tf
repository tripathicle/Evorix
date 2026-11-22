variable "name" {
  type        = string
  description = "The name of the Network Security Group"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the NSG is created"
}

variable "location" {
  type        = string
  description = "Azure region where the NSG will reside"
}

variable "security_rules" {
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  }))
  description = "List of network security rules to configure"
  default     = []
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of Subnet IDs to associate with this NSG"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the NSG"
  default     = {}
}
