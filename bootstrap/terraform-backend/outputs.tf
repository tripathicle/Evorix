output "resource_group_name" {
  description = "Name of the Resource Group housing the Terraform state storage"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Name of the Storage Account hosting the state containers"
  value       = azurerm_storage_account.tfstate.name
}

output "container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.tfstate.name
}

output "storage_account_id" {
  description = "Resource ID of the Storage Account"
  value       = azurerm_storage_account.tfstate.id
}

output "backend_config_template" {
  description = "Example Terraform backend configuration block to place into backend.tf"
  value       = <<-EOT
    terraform {
      backend "azurerm" {
        resource_group_name  = "${azurerm_resource_group.tfstate.name}"
        storage_account_name = "${azurerm_storage_account.tfstate.name}"
        container_name       = "${azurerm_storage_container.tfstate.name}"
        key                  = "<env>.terraform.tfstate"
        use_azuread_auth     = true
      }
    }
  EOT
}
