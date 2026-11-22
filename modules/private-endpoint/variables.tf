variable "name" {
  type        = string
  description = "Name of the Private Endpoint"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for the Private Endpoint"
}

variable "location" {
  type        = string
  description = "Azure region for the Private Endpoint"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID of the PrivateEndpointSubnet"
}

variable "target_resource_id" {
  type        = string
  description = "Resource ID of the Azure PaaS service to link via Private Endpoint"
}

variable "subresource_names" {
  type        = list(string)
  description = "List of subresource names (e.g. ['blob'], ['vault'], ['sqlServer'])"
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "List of Private DNS Zone IDs to integrate into the Private DNS Zone Group"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the Private Endpoint"
  default     = {}
}
