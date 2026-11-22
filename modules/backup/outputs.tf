output "vault_id" {
  description = "The ID of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.rsv.id
}

output "vault_name" {
  description = "The Name of the Recovery Services Vault"
  value       = azurerm_recovery_services_vault.rsv.name
}

output "policy_id" {
  description = "The ID of the VM backup policy"
  value       = azurerm_backup_policy_vm.policy.id
}
