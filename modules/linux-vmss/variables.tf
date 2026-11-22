variable "name" {
  type        = string
  description = "Name of the VMSS"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group for VMSS"
}

variable "location" {
  type        = string
  description = "Azure region for the VMSS"
}

variable "sku" {
  type        = string
  description = "Virtual Machine SKU"
  default     = "Standard_D2s_v5"
}

variable "instances" {
  type        = number
  description = "Initial instance count"
  default     = 2
}

variable "min_instances" {
  type        = number
  description = "Minimum instances for autoscaling"
  default     = 2
}

variable "max_instances" {
  type        = number
  description = "Maximum instances for autoscaling"
  default     = 10
}

variable "enable_autoscale" {
  type        = bool
  description = "Enable autoscale settings"
  default     = true
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM instances"
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH Public Key for administrative access"
}

variable "zones" {
  type        = list(string)
  description = "Availability Zones to distribute VM instances across"
  default     = ["1", "2", "3"]
}

variable "upgrade_mode" {
  type        = string
  description = "Upgrade mode for the scale set: Manual, Rolling, or Automatic"
  default     = "Manual"
}

variable "os_disk_type" {
  type        = string
  description = "Storage account type for OS Disk"
  default     = "Premium_LRS"
}

variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  type    = string
  default = "22_04-lts-gen2"
}

variable "image_version" {
  type    = string
  default = "latest"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where VMSS network interfaces attach"
}

variable "load_balancer_backend_address_pool_ids" {
  type        = list(string)
  description = "List of Internal Load Balancer backend pool IDs to register with"
  default     = []
}

variable "application_gateway_backend_address_pool_ids" {
  type        = list(string)
  description = "List of Application Gateway backend pool IDs to register with"
  default     = []
}

variable "custom_data" {
  type        = string
  description = "Custom cloud-init script string"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to VMSS resources"
  default     = {}
}
