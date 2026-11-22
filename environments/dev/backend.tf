# Remote Terraform State Backend for Dev Environment
# Bootstrap with `bootstrap/terraform-backend` first to create the storage account and container.

# Uncomment when remote backend is active:
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "gd-hubspoke-tfstate-rg"
#     storage_account_name = "gdtfstatedev01"
#     container_name       = "tfstate"
#     key                  = "dev.terraform.tfstate"
#     use_azuread_auth     = true
#   }
# }
