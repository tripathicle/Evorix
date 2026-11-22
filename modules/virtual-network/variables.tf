variable "name" {
  type        = string
  description = "Name of the Virtual Network"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group where the Virtual Network will reside"
}

variable "location" {
  type        = string
  description = "Azure Region for the Virtual Network"
}

variable "address_space" {
  type        = list(string)
  description = "The address space used by the virtual network in CIDR notation"
}

variable "dns_servers" {
  type        = list(string)
  description = "List of custom DNS servers for the Virtual Network"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the Virtual Network"
  default     = {}
}
