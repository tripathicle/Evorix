variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the subnets will be created"
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network in which the subnets will be created"
}

variable "subnets" {
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string), [])
    private_endpoint_network_policies = optional(string, "Disabled")
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    })), [])
  }))
  description = "Map of subnets to create inside the virtual network"
}
