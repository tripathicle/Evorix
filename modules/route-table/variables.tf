variable "name" {
  type        = string
  description = "Name of the Route Table"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the route table"
}

variable "disable_bgp_route_propagation" {
  type        = bool
  description = "Whether to disable the propagation of routes from Virtual Network Gateway"
  default     = false
}

variable "routes" {
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  description = "List of user-defined routes to add to the route table"
  default     = []
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of Subnet IDs to associate with this route table"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the Route Table"
  default     = {}
}
