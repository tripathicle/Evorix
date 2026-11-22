variable "prefix" {
  type        = string
  description = "Prefix for bootstrap resources"
  default     = "ea-landing-zone"
}

variable "location" {
  type        = string
  description = "Azure Region for Terraform state storage"
  default     = "eastus"
}

variable "storage_account_prefix" {
  type        = string
  description = "Prefix for storage account (alphanumeric only, 3-18 chars)"
  default     = "tfstate"
}

variable "replication_type" {
  type        = string
  description = "Storage replication type (e.g. LRS, GRS, ZRS)"
  default     = "GRS"
}

variable "container_name" {
  type        = string
  description = "Storage container name for tfstate files"
  default     = "tfstate"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default = {
    Project     = "Enterprise-Azure-Landing-Zone"
    ManagedBy   = "Terraform"
    Purpose     = "Terraform-Remote-State"
    Environment = "Bootstrap"
  }
}
