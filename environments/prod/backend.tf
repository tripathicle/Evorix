# Remote Terraform State Backend for Production
# Bootstrap with `bootstrap/terraform-backend` first to create the storage account and container.

# When running locally or during pipeline initialization, pass backend config:
# terraform init -backend-config="resource_group_name=<rg>" -backend-config="storage_account_name=<sa>" ...

# Uncomment the block below when ready for remote state storage:
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "gd-hubspoke-tfstate-rg"
#     storage_account_name = "gdtfstateprod01"
#     container_name       = "tfstate"
#     key                  = "prod.terraform.tfstate"
#     use_azuread_auth     = true
#   }
# }
